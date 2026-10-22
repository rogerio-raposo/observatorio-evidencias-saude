"""A2-G4 synthetic PostgreSQL adapter: infrastructure errors only.

Static source candidate. Not execution-validated or approved for database use.
DomainError and RepositoryConflict remain owned by their legacy modules.
"""

from __future__ import annotations


class AdapterInfrastructureError(RuntimeError):
    """An adapter/infrastructure failure, not a historical domain conflict."""


class ConnectionAcquisitionError(AdapterInfrastructureError):
    """Dedicated factory could not supply a minimally valid connection handle.

    No handle is available for this adapter to roll back or close. An opener
    that allocates then raises must release its own resources. Reuse or retry
    of an affected Unit of Work is prohibited. This says nothing about any
    server-side operation the opener might have performed before failing.
    Raw original exceptions, if any, remain in __cause__, not public text.
    """

    retry_allowed = False


class CommitOutcomeUnknown(AdapterInfrastructureError):
    """COMMIT result cannot safely be classified as committed or rolled back.

    Construction performs no I/O. Never interpret this exception as a signal
    to retry a command. Non-secret identifiers are retained; any later close
    diagnostics are restricted attributes, not included in the public message.
    None for connection_closed_observed means context cleanup has not reported.
    Raw driver exceptions may contain sensitive data: redact before logging.
    """

    def __init__(self, *, scenario_id: str, request_id: str) -> None:
        self.scenario_id = scenario_id
        self.request_id = request_id
        self.retry_allowed = False
        # Populated by the Unit of Work when its context exit disposes the
        # connection. These concern client cleanup, NOT COMMIT resolution.
        self.close_error: BaseException | None = None
        self.close_observation_error: BaseException | None = None
        self.connection_closed_observed: bool | None = None
        super().__init__("transaction outcome unknown; reconciliation required")


class CommitConfirmedCleanupFailed(AdapterInfrastructureError):
    """COMMIT returned normally, but connection cleanup could not be confirmed.

    Unlike CommitOutcomeUnknown, the client observed a successful commit call.
    The caller must never retry this command. Raw close diagnostics are retained
    only for restricted inspection; do not log/serialize them without redaction.
    Constructor has no connection or reconciliation side effects.
    """

    def __init__(self, *, scenario_id: str, request_id: str,
                 close_error: BaseException | None,
                 close_observation_error: BaseException | None) -> None:
        self.scenario_id = scenario_id
        self.request_id = request_id
        self.commit_confirmed = True  # conn.commit() returned normally.
        self.retry_allowed = False
        self.close_error = close_error
        self.close_observation_error = close_observation_error
        super().__init__("commit confirmed; connection cleanup failed; retry prohibited")


class RollbackNotConfirmed(AdapterInfrastructureError):
    """Pre-COMMIT rollback failed; no retry, regardless of original SQLSTATE.

    Covers failed rollback during commit preparation, context entry/exit and
    explicit rollback. A primary failure, if any, remains as __cause__; the
    rollback exception is retained separately as rollback_error. If rollback
    itself was the primary failure, both may reference that same exception.
    Never log/serialize raw diagnostics without a separate redaction policy.
    """

    def __init__(self, *, rollback_error: BaseException) -> None:
        self.rollback_error = rollback_error
        self.close_error: BaseException | None = None
        self.close_observation_error: BaseException | None = None
        super().__init__("pre-commit rollback unconfirmed; retry prohibited")


class ConnectionCloseNotConfirmed(AdapterInfrastructureError):
    """Rollback returned normally, but closing the connection was not confirmed.

    This is distinct from a failed rollback, uncertain COMMIT, or a confirmed
    COMMIT with failed cleanup. No retry is authorized. Any pre-existing error
    remains in __cause__, and raw close diagnostics are restricted to attributes
    requiring redaction before logging or serialization.
    """

    def __init__(self, *, close_error: BaseException | None,
                 close_observation_error: BaseException | None) -> None:
        if close_error is None and close_observation_error is None:
            raise ValueError("a failed close diagnosis is required")
        self.rollback_call_returned_normally = True
        self.retry_allowed = False
        self.close_error = close_error
        self.close_observation_error = close_observation_error
        super().__init__("rollback returned; connection close unconfirmed; retry prohibited")


class PersistenceIntegrityError(AdapterInfrastructureError):
    """Persisted scenario, event and receipt state disagree; do not repair."""


class JsonbCompatibilityError(AdapterInfrastructureError):
    """A value cannot safely be represented with the scoped JSONB contract."""
