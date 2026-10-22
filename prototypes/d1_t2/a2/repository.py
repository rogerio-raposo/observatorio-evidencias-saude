"""OES A2-G4 experimental PostgreSQL repository — STATIC SOURCE ONLY.

NOT EXECUTION VALIDATED. Never import/run without a separately approved gate.
A supplied DedicatedConnectionFactory, when invoked by an authorized future
caller, must return a new, exclusively owned, synchronous Psycopg 3 connection
with autocommit=False, as the restricted application role. No connection occurs
at import/construction. Nominal injection cannot verify that ownership promise.

Writing follows a per-scenario row lock protocol. Concurrent *creation* may
raise a named unique constraint violation; callers must roll back, start a
new transaction, and decide idempotency from that fresh transaction. No
automatic retry, SQL, or infrastructure effects occur while defining classes.
"""
from __future__ import annotations

from copy import deepcopy
from dataclasses import dataclass
from typing import Any, Callable

from prototypes.d1_t2.a1.repository import Receipt, RepositoryConflict, ScenarioState
from .codec import jsonb_value, psycopg_jsonb
from .errors import (
    AdapterInfrastructureError, CommitConfirmedCleanupFailed,
    CommitOutcomeUnknown, ConnectionAcquisitionError, ConnectionCloseNotConfirmed,
    PersistenceIntegrityError, RollbackNotConfirmed,
)

_SCHEMA = "oes_t2a2_proto"  # Constant qualified names, never interpolated from input.


class DedicatedConnectionFactory:
    """Explicit integration-boundary promise to open a *new owned* connection.

    The opener MUST allocate a synchronous Psycopg connection solely for one
    Unit of Work or independent read; a pool lease, borrowed connection, cached
    object or externally shared session violates this contract. Construction
    never calls the opener. Requiring this nominal wrapper prevents accidental
    injection of a bare callable, but is not evidence of exclusive ownership,
    server identity, effective role, transport security or session provenance.
    Such claims require an independently authorized operational preflight.
    """

    def __init__(self, open_new_connection: Callable[[], Any]) -> None:
        if not callable(open_new_connection):
            raise TypeError("open_new_connection must be callable")
        self._opener = open_new_connection

    def open_new_connection(self) -> Any:
        """Acquire a dedicated handle or raise an acquisition-specific error.

        A raised opener cannot return a handle to this adapter: the opener
        remains responsible for disposing anything allocated before it raised.
        Shape checks reject missing/obviously invalid handles, but cannot
        attest Psycopg class identity, freshness or exclusive ownership.
        """
        try:
            conn = self._opener()
        except Exception as exc:
            raise ConnectionAcquisitionError(
                "dedicated connection acquisition failed; retry prohibited"
            ) from exc
        if conn is None:
            raise ConnectionAcquisitionError(
                "dedicated connection factory returned no connection; retry prohibited"
            )
        try:
            methods_valid = all(callable(getattr(conn, name, None))
                                for name in ("execute", "rollback", "commit", "close"))
        except Exception as exc:
            raise ConnectionAcquisitionError(
                "dedicated connection interface inspection failed; retry prohibited"
            ) from exc
        if not methods_valid:
            # Never attempt rollback/close on an obviously invalid object:
            # no valid transaction or ownership has been established.
            raise ConnectionAcquisitionError(
                "dedicated connection factory returned invalid handle; retry prohibited"
            )
        return conn


@dataclass(frozen=True)
class StoredEvent:
    sequence: int
    kind: str
    data: dict[str, Any]


class PostgresScenarioRepository:
    """Lazy repository; opening a Unit of Work is the only write entry point."""

    def __init__(self, connection_factory: DedicatedConnectionFactory) -> None:
        # An explicit nominal integration boundary discourages accidentally
        # passing a pooled/borrowed callable. It cannot attest the opener's
        # behavior; passive state checks remain necessary but insufficient.
        if not isinstance(connection_factory, DedicatedConnectionFactory):
            raise TypeError("DedicatedConnectionFactory explicitly required")
        self._connections = connection_factory

    def begin_command(self, scenario_id: str, request_id: str,
                      fingerprint: str) -> "PostgresUnitOfWork":
        if not all((scenario_id, request_id, fingerprint)):
            raise RepositoryConflict("scenario, request and fingerprint required")
        return PostgresUnitOfWork(self._connections, scenario_id, request_id, fingerprint)

    def read_consistent_snapshot(self, scenario_id: str) -> tuple[ScenarioState | None, list[dict], list[Receipt]]:
        """Proposed single-MVCC-snapshot read; cannot claim replay validated."""
        conn = self._connections.open_new_connection()
        primary: BaseException | None = None
        try:
            _require_clean_owned_connection(conn)
            conn.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
            row = conn.execute(
                "SELECT revision, state FROM oes_t2a2_proto.scenario WHERE scenario_id = %s",
                (scenario_id,),
            ).fetchone()
            scenario = ScenarioState(int(row[0]), deepcopy(row[1])) if row else None
            # Query even when scenario is absent; otherwise _validate_loaded
            # receives fabricated empty collections and cannot detect orphans.
            events = _load_events(conn, scenario_id)
            receipts = _load_receipts(conn, scenario_id)
            _validate_loaded(scenario, events, receipts)
            return scenario, events, receipts
        except BaseException as exc:
            primary = exc
            raise
        finally:
            # Exactly one read-only rollback; preserve a query failure if
            # rollback/close also fails. On clean reads, cleanup errors surface.
            report = _dispose_connection(conn, rollback=True, primary=primary)
            if report.rollback_error is not None:
                # Read-only rollback uncertainty is distinct from a failed
                # close, even when a read error already exists.
                failure = RollbackNotConfirmed(rollback_error=report.rollback_error)
                failure.close_error = report.close_error
                failure.close_observation_error = report.close_observation_error
                raise failure from (primary if primary is not None else report.rollback_error)
            if _close_failed(report):
                # SA-12: preserve the original read error as the cause while
                # exposing the unconfirmed client-side close by type.
                failure = _close_not_confirmed(report)
                raise failure from (primary if primary is not None else _close_failure_cause(report))


class PostgresUnitOfWork:
    """Single command with explicit COMMIT and outcome-aware cleanup."""

    def __init__(self, factory: DedicatedConnectionFactory, scenario_id: str,
                 request_id: str, fingerprint: str) -> None:
        # Direct construction must not bypass the nominal factory boundary.
        if not isinstance(factory, DedicatedConnectionFactory):
            raise TypeError("DedicatedConnectionFactory explicitly required")
        self._factory = factory
        self.scenario_id, self.request_id, self.fingerprint = scenario_id, request_id, fingerprint
        self._conn: Any | None = None
        self._finished = False
        self._entered = False
        self._prior: ScenarioState | None = None
        self._staged: dict[str, Any] = {}
        # PENDING is the *only* status for which context exit rolls back.
        # COMMITTED and OUTCOME_UNKNOWN must never be reclassified by cleanup.
        self._outcome = "NEW"
        self._loaded_events: list[dict] | None = None
        self._validated = False
        self.cleanup_failed = False
        # Never infer close from self._conn being reset to None. This flag is
        # set only by a successful close() plus an observed conn.closed=True.
        self._connection_closed_observed = False

    @property
    def safe_to_retry_create_collision(self) -> bool:
        """Only a pre-COMMIT write failure with confirmed rollback + close.

        This is a *source-level contract*, not proof of driver/network safety.
        Any failed rollback or connection close suppresses collision retry.
        """
        return (
            self._entered and self._finished
            and self._outcome == "ROLLED_BACK_AFTER_WRITE_FAILURE"
            and self._connection_closed_observed
            and not self.cleanup_failed
        )

    def __enter__(self) -> "PostgresUnitOfWork":
        if self._entered or self._finished:
            raise RepositoryConflict("unit of work already used")
        # Consume the one-shot UoW *before* calling the external opener.
        # A failed acquisition must never leave a re-enterable NEW object.
        # If the opener raises, no handle was returned and this adapter has
        # nothing it can safely roll back or close.
        self._finished = True
        self._outcome = "ACQUISITION_FAILED"
        conn = self._factory.open_new_connection()
        self._conn = conn
        try:
            _require_clean_owned_connection(conn)
            conn.execute("SET TRANSACTION ISOLATION LEVEL READ COMMITTED")
            row = conn.execute(
                "SELECT revision, state FROM oes_t2a2_proto.scenario "
                "WHERE scenario_id = %s FOR UPDATE", (self.scenario_id,),
            ).fetchone()
            self._prior = ScenarioState(int(row[0]), deepcopy(row[1])) if row else None
            self._entered = True
            self._finished = False  # Active until explicit commit/rollback or exit.
            self._outcome = "PENDING"
            return self
        except BaseException as exc:
            self._finished = True
            self._outcome = "START_FAILED"
            self._conn = None
            report = _dispose_connection(conn, rollback=True, primary=exc)
            self._connection_closed_observed = report.closed_observed
            self.cleanup_failed = report.error is not None
            if report.rollback_error is not None:
                # Even an entry failure must not disguise an unconfirmed
                # rollback as the original, safely reverted exception.
                self._outcome = "ROLLBACK_UNCONFIRMED"
                failure = RollbackNotConfirmed(rollback_error=report.rollback_error)
                failure.close_error = report.close_error
                failure.close_observation_error = report.close_observation_error
                raise failure from exc
            if _close_failed(report):
                self._outcome = "ROLLED_BACK_CLOSE_UNCONFIRMED"
                raise _close_not_confirmed(report) from exc
            raise

    def __exit__(self, exc_type: Any, exc: Any, tb: Any) -> None:
        # Do not use Psycopg connection context: it COMMITs on normal exit.
        conn, self._conn = self._conn, None
        self._finished = True
        if conn is not None:
            pending = self._outcome == "PENDING"
            report = _dispose_connection(conn, rollback=pending, primary=exc)
            self._connection_closed_observed = report.closed_observed
            self.cleanup_failed = self.cleanup_failed or report.error is not None
            if pending:
                if report.rollback_error is not None:
                    self._outcome = "ROLLBACK_UNCONFIRMED"
                    # SA-11: any failure to reverse a pre-COMMIT transaction
                    # must be typed, including when a domain error already
                    # exists. __cause__ retains that original failure and the
                    # rollback/close errors remain separate restricted data.
                    failure = RollbackNotConfirmed(rollback_error=report.rollback_error)
                    failure.close_error = report.close_error
                    failure.close_observation_error = report.close_observation_error
                    if exc is not None:
                        raise failure from exc
                    raise failure from report.rollback_error
                self._outcome = (
                    "ROLLED_BACK_CLOSE_UNCONFIRMED" if _close_failed(report)
                    else "ROLLED_BACK"
                )
            if isinstance(exc, RollbackNotConfirmed):
                # Preserve both diagnostic channels without logging raw driver
                # exception text (which may contain sensitive context).
                exc.close_error = report.close_error
                exc.close_observation_error = report.close_observation_error
            if self._outcome == "OUTCOME_UNKNOWN" and isinstance(exc, CommitOutcomeUnknown):
                # SA-06: report cleanup independently of the unknown COMMIT.
                # Neither a successful close nor a failed close resolves the
                # transaction's server-side outcome. Never retry automatically.
                exc.close_error = report.close_error
                exc.close_observation_error = report.close_observation_error
                exc.connection_closed_observed = report.closed_observed
            # COMMIT already returned normally; closure cannot undo or
            # reclassify it. Expose failed cleanup as a distinct, no-retry
            # infrastructure outcome rather than returning apparent success.
            if report.error is not None and self._outcome == "COMMITTED":
                if exc is None:
                    raise CommitConfirmedCleanupFailed(
                        scenario_id=self.scenario_id,
                        request_id=self.request_id,
                        close_error=report.close_error,
                        close_observation_error=report.close_observation_error,
                    ) from None
                # Preserve a pre-existing post-COMMIT exception. The note is
                # constant, contains no raw driver error or sensitive data,
                # and identifies that the confirmation must not be retried.
                if hasattr(exc, "add_note"):
                    exc.add_note(
                        "A2-G4: COMMIT returned successfully but connection "
                        "cleanup failed; retry prohibited"
                    )
            # SA-12: if rollback returned normally (either here or earlier),
            # never let failed closure be disguised as an ordinary domain/SQL
            # exception or as successful context exit. Preserve prior error in
            # __cause__; SQLSTATE on the outer typed exception is absent.
            if (_close_failed(report) and self._outcome in {
                    "ROLLED_BACK_CLOSE_UNCONFIRMED", "ROLLED_BACK",
                    "ROLLED_BACK_AFTER_WRITE_FAILURE"}):
                raise _close_not_confirmed(report) from (
                    exc if exc is not None else _close_failure_cause(report))

    def _check(self) -> Any:
        if not self._entered or self._finished or self._conn is None:
            raise RepositoryConflict("unit of work is not active")
        return self._conn

    def find_receipt(self) -> Receipt | None:
        conn = self._check()
        self._ensure_integrity()
        if self._prior is None:
            return None  # Missing scenario has no receipt under the known FK.
        row = conn.execute(
            "SELECT fingerprint, response, revision FROM oes_t2a2_proto.receipt "
            "WHERE scenario_id = %s AND request_id = %s",
            (self.scenario_id, self.request_id),
        ).fetchone()
        if row is None:
            return None
        if row[0] != self.fingerprint:
            raise RepositoryConflict("request reused with different payload")
        return Receipt(str(row[0]), deepcopy(row[1]), int(row[2]))

    def read_scenario(self) -> ScenarioState | None:
        self._check()
        self._ensure_integrity()
        return deepcopy(self._prior)

    def list_events(self) -> list[dict]:
        self._check()
        self._ensure_integrity()
        return deepcopy(self._loaded_events)

    def _ensure_integrity(self) -> None:
        """Check historical revision/event/receipt invariants before any write.

        The row lock is acquired in __enter__ before these dependent reads.
        This structural check does not prove fingerprint/event semantics.
        """
        if self._validated:
            return
        if self._prior is None:
            # In READ COMMITTED, a concurrent create can commit after our
            # no-row SELECT FOR UPDATE. A later event/receipt SELECT could
            # then see that valid new scenario's children but not its parent
            # in _prior, producing a false corruption alarm. We cannot lock a
            # missing row. The scenario PK collision at INSERT is handled by
            # the bridge using rollback and a new protected transaction.
            # Existing FKs prohibit committed orphan child rows.
            self._loaded_events = []
            self._validated = True
            return
        conn = self._check()
        events = _load_events(conn, self.scenario_id)
        receipts = _load_receipts(conn, self.scenario_id)
        _validate_loaded(self._prior, events, receipts)
        self._loaded_events = events
        self._validated = True

    def stage_scenario(self, state: dict, expected_revision: int) -> None:
        self._check()
        actual = self._prior.revision if self._prior else 0
        if "state" in self._staged or expected_revision != actual:
            raise RepositoryConflict("duplicate stage or stale revision")
        normalized = jsonb_value(state)
        if not isinstance(normalized, dict) or normalized.get("synthetic") is not True:
            raise RepositoryConflict("synthetic scenario required")
        self._staged["state"] = normalized

    def append_event(self, kind: str, data: dict, sequence: int) -> None:
        self._check()
        if "event" in self._staged or not isinstance(kind, str) or not kind:
            raise RepositoryConflict("invalid or duplicate event")
        payload = jsonb_value(data)
        if not isinstance(payload, dict) or sequence != (self._prior.revision if self._prior else 0) + 1:
            raise RepositoryConflict("invalid event sequence or payload")
        self._staged["event"] = StoredEvent(sequence, kind, payload)

    def stage_receipt(self, response: Any) -> None:
        self._check()
        if "receipt" in self._staged:
            raise RepositoryConflict("duplicate receipt stage")
        self._staged["receipt"] = jsonb_value(response)

    def commit(self) -> int:
        conn = self._check()
        self._ensure_integrity()
        if set(self._staged) != {"state", "event", "receipt"}:
            raise RepositoryConflict("state, event and receipt must commit together")
        revision = (self._prior.revision if self._prior else 0) + 1
        event: StoredEvent = self._staged["event"]
        if event.sequence != revision:
            raise RepositoryConflict("event sequence differs from revision")
        try:
            if self._prior is None:
                conn.execute(
                    "INSERT INTO oes_t2a2_proto.scenario (scenario_id, revision, state, synthetic) "
                    "VALUES (%s, %s, %s, TRUE)",
                    (self.scenario_id, revision, psycopg_jsonb(self._staged["state"])),
                )
            else:
                row = conn.execute(
                    "UPDATE oes_t2a2_proto.scenario SET revision = %s, state = %s "
                    "WHERE scenario_id = %s AND revision = %s RETURNING revision",
                    (revision, psycopg_jsonb(self._staged["state"]),
                     self.scenario_id, self._prior.revision),
                ).fetchone()
                if row is None:
                    raise RepositoryConflict("stale scenario revision")
            conn.execute(
                "INSERT INTO oes_t2a2_proto.event "
                "(scenario_id, sequence, kind, payload) VALUES (%s, %s, %s, %s)",
                (self.scenario_id, event.sequence, event.kind, psycopg_jsonb(event.data)),
            )
            conn.execute(
                "INSERT INTO oes_t2a2_proto.receipt "
                "(scenario_id, request_id, fingerprint, response, revision) "
                "VALUES (%s, %s, %s, %s, %s)",
                (self.scenario_id, self.request_id, self.fingerprint,
                 psycopg_jsonb(self._staged["receipt"]), revision),
            )
        except BaseException as exc:
            # Before COMMIT: retry is permitted only after rollback actually
            # succeeds. Preserving SQLSTATE alone must not authorize retry.
            self._finished = True
            cleanup = _rollback_preserving_error(conn, exc)
            if cleanup is not None:
                self._outcome = "ROLLBACK_UNCONFIRMED"
                self.cleanup_failed = True
                # Preserve the original write error as the cause; the bridge
                # must not mistake its SQLSTATE for a safe unique collision.
                raise RollbackNotConfirmed(rollback_error=cleanup) from exc
            self._outcome = "ROLLED_BACK_AFTER_WRITE_FAILURE"
            raise
        try:
            conn.commit()  # The only explicit confirmation of a write transaction.
        except BaseException as exc:
            self._finished = True
            self._outcome = "OUTCOME_UNKNOWN"
            # Conservative: distinguish uncertain COMMIT from known pre-COMMIT failure.
            raise CommitOutcomeUnknown(scenario_id=self.scenario_id,
                                       request_id=self.request_id) from exc
        self._outcome = "COMMITTED"
        self._finished = True
        return revision

    def rollback(self) -> None:
        conn = self._check()
        self._finished = True
        try:
            conn.rollback()
        except BaseException as exc:
            self._outcome = "ROLLBACK_UNCONFIRMED"
            self.cleanup_failed = True
            # Explicit rollback follows the same no-retry contract as the
            # pre-COMMIT context exit; __exit__ will only attempt to close.
            raise RollbackNotConfirmed(rollback_error=exc) from exc
        self._outcome = "ROLLED_BACK"


def _rollback_preserving_error(conn: Any, primary: BaseException) -> BaseException | None:
    """Preserve original SQLSTATE/constraint diagnostics on pre-COMMIT errors."""
    try:
        conn.rollback()
    except BaseException as cleanup:
        if hasattr(primary, "add_note"):
            primary.add_note("A2-G4: rollback also failed; original error retained")
        return cleanup
    return None


@dataclass(frozen=True)
class _DisposalReport:
    rollback_error: BaseException | None
    close_error: BaseException | None
    close_observation_error: BaseException | None
    closed_observed: bool

    @property
    def error(self) -> BaseException | None:
        # A successful close call is not proof that the client-side handle
        # actually reports closed. Fail safely if the state is unavailable.
        return (self.rollback_error or self.close_error
                or self.close_observation_error)


def _close_failed(report: _DisposalReport) -> bool:
    return (report.close_error is not None
            or report.close_observation_error is not None)


def _close_failure_cause(report: _DisposalReport) -> BaseException:
    # Only call after _close_failed(report), so at least one is non-None.
    cause = report.close_error if report.close_error is not None else report.close_observation_error
    assert cause is not None
    return cause


def _close_not_confirmed(report: _DisposalReport) -> ConnectionCloseNotConfirmed:
    return ConnectionCloseNotConfirmed(
        close_error=report.close_error,
        close_observation_error=report.close_observation_error)


def _require_clean_owned_connection(conn: Any) -> None:
    """Inspect a freshly supplied connection without issuing network queries.

    Preconditions on the factory: genuinely new, exclusively owned, never
    returned from a pool or shared with any concurrent or previous UoW.
    These passive checks only reject obviously unsafe states; they cannot
    establish factory provenance, role, database, TLS, or exclusivity.
    """
    try:
        if conn.closed is not False:
            raise AdapterInfrastructureError("connection must be open and owned")
        if conn.autocommit is not False:
            raise AdapterInfrastructureError("connection must have autocommit disabled")
        if getattr(conn.info.status, "name", None) != "OK":
            raise AdapterInfrastructureError("connection status is not OK")
        if getattr(conn.info.transaction_status, "name", None) != "IDLE":
            raise AdapterInfrastructureError("connection must have no existing transaction")
    except AdapterInfrastructureError:
        raise
    except BaseException as error:
        raise AdapterInfrastructureError("connection state inspection failed") from error


def _dispose_connection(conn: Any, *, rollback: bool,
                        primary: BaseException | None) -> _DisposalReport:
    """Attempt rollback and close exactly once, without hiding a primary error.

    An observed client-side close does NOT prove server-side rollback or
    exclusive ownership. Both are separate conditions for safe retry.
    """
    rollback_error: BaseException | None = None
    close_error: BaseException | None = None
    close_observation_error: BaseException | None = None
    if rollback:
        try:
            conn.rollback()
        except BaseException as error:
            rollback_error = error
    try:
        conn.close()
    except BaseException as error:
        close_error = error
    closed_observed = False
    try:
        closed_observed = conn.closed is True
    except BaseException as error:
        close_observation_error = error
    if not closed_observed and close_observation_error is None:
        close_observation_error = AdapterInfrastructureError(
            "client-side connection close not confirmed")
    report = _DisposalReport(rollback_error, close_error,
                             close_observation_error, closed_observed and close_error is None)
    if report.error is not None and primary is not None and hasattr(primary, "add_note"):
        primary.add_note("A2-G4: transaction cleanup/closure not confirmed; primary error retained")
    return report


def _load_events(conn: Any, scenario_id: str) -> list[dict]:
    rows = conn.execute(
        "SELECT sequence, kind, payload FROM oes_t2a2_proto.event "
        "WHERE scenario_id = %s ORDER BY sequence", (scenario_id,),
    ).fetchall()
    return [{"sequence": int(seq), "kind": kind, "data": deepcopy(payload)}
            for seq, kind, payload in rows]


def _load_receipts(conn: Any, scenario_id: str) -> list[Receipt]:
    rows = conn.execute(
        "SELECT fingerprint, response, revision FROM oes_t2a2_proto.receipt "
        "WHERE scenario_id = %s ORDER BY revision, request_id", (scenario_id,),
    ).fetchall()
    return [Receipt(str(fp), deepcopy(response), int(revision))
            for fp, response, revision in rows]


def _validate_loaded(scenario: ScenarioState | None, events: list[dict],
                     receipts: list[Receipt]) -> None:
    if scenario is None:
        if events or receipts:
            raise PersistenceIntegrityError("orphan events or receipts")
        return
    r = scenario.revision
    if not isinstance(scenario.data, dict) or scenario.data.get("synthetic") is not True:
        raise PersistenceIntegrityError("invalid synthetic state")
    if len(events) != r or len(receipts) != r:
        raise PersistenceIntegrityError("revision/event/receipt counts disagree")
    if [e["sequence"] for e in events] != list(range(1, r + 1)):
        raise PersistenceIntegrityError("event sequence gap")
    if sorted(receipt.revision for receipt in receipts) != list(range(1, r + 1)):
        raise PersistenceIntegrityError("receipt revision gap or duplication")
    if scenario.data.get("events") != events:
        raise PersistenceIntegrityError("state events diverge from event table")
