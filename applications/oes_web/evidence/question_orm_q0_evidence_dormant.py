"""Internal D3 evidence collector; no entrypoint, factory or writer activation.

Only the gated D1 composition may supply a live trace in a future authorized
execution. Tests replace DB boundaries with fakes. No boolean success inputs.
"""
from dataclasses import dataclass
from datetime import datetime
import re
from uuid import UUID

from django.db import connections, transaction

from .models import (OesEntity, OesQuestion, OesEntityVersion,
                     OesQuestionVersion, OesQuestionCommandReceipt)
from .question_preparation import (PreparationHold, PreparationConflict,
                                   QuestionCommand, command_fingerprint)
from .question_uow_offline import Receipt
from .question_orm_transaction_offline import request_receipt, postgres_session_identity

WRITER = "oes_q0_writer"
READER = "oes_synthetic_reader"
TABLES = ("core.entity", "investigation.question", "core.entity_version",
          "investigation.question_version", "investigation.question_command_receipt")


@dataclass
class _WriterTrace:
    """Volatile observations, not a ledger or a caller-supplied proof of success."""
    expected: Receipt
    atomic_entered: bool = False
    xid: str | None = None
    boundary: str = "UNKNOWN"
    local_closed: bool = False
    candidate: dict | None = None
    observation: dict | None = None
    writer_identity: tuple | None = None
    writer_privileges: tuple | None = None


def _expected_receipt(command, actor_id):
    if (not isinstance(command, QuestionCommand) or type(command.expected_version) is not int
            or command.expected_version != 0 or command.normalized_text is not None
            or command.justification != "" or not isinstance(command.request_id, str)
            or not 1 <= len(command.request_id) <= 128
            or not isinstance(command.question_id, str) or not command.question_id
            or not isinstance(command.original_text, str) or not 1 <= len(command.original_text) <= 10000
            or not isinstance(actor_id, str) or not actor_id):
        raise PreparationHold("HOLD: invalid D3 reconciliation command")
    return Receipt(actor_id, command.request_id, command_fingerprint(command),
                   command.question_id, 1, "REGISTER_Q0")


def _review_q0_privileges(connection):
    """Query effective table rights, not settings assertions or role membership."""
    if connection.alias not in (WRITER, READER):
        raise PreparationHold("HOLD: invalid D3 privilege alias")
    observed = []
    with connection.cursor() as cursor:
        for schema in ("core", "investigation"):
            cursor.execute("SELECT has_schema_privilege(current_user,%s,'USAGE')", [schema])
            row = cursor.fetchone()
            if not isinstance(row, tuple) or len(row) != 1 or row[0] is not True:
                raise PreparationHold("HOLD: D3 schema access mismatch")
            observed.append((schema, row))
        for table in TABLES:
            cursor.execute(
                "SELECT has_table_privilege(current_user,%s,'SELECT'), "
                "has_table_privilege(current_user,%s,'INSERT'), "
                "has_table_privilege(current_user,%s,'UPDATE,DELETE,TRUNCATE')",
                [table, table, table],
            )
            row = cursor.fetchone()
            expected = (True, True, False) if connection.alias == WRITER else (True, False, False)
            if (not isinstance(row, tuple) or len(row) != 3
                    or any(value is not wanted for value, wanted in zip(row, expected))):
                raise PreparationHold("HOLD: D3 effective privileges mismatch")
            observed.append((table, row))
    return tuple(observed)


def _capture_q0_writer_transaction(writer, trace):
    """Called inside atomic BEFORE any repository write; not a transaction runner."""
    if (writer.alias != WRITER or writer.vendor != "postgresql"
            or writer.in_atomic_block is not True or writer.get_autocommit() is not False):
        raise PreparationHold("HOLD: invalid D3 writer transaction")
    with writer.cursor() as cursor:
        identity = postgres_session_identity(cursor)
        if identity != ("oes_qprep_login", "oes_sandbox", "off"):
            raise PreparationHold("HOLD: D3 effective writer identity mismatch")
        trace.writer_identity = identity
        cursor.execute("SELECT pg_current_xact_id()::text")
        row = cursor.fetchone()
        if (not isinstance(row, tuple) or len(row) != 1 or not isinstance(row[0], str)
                or not row[0].isdigit() or int(row[0]) <= 0):
            raise PreparationHold("HOLD: D3 writer transaction identity unavailable")
        trace.xid = row[0]


def _indeterminate():
    return {"outcome": "INDETERMINATE", "scope": "Q0_RECORDS", "automatic_retry": False}


def _collect_q0_commit_evidence(*, command, actor_id, trace=None):
    """Dormant reader implementation. No caller success/absence/consistency flags.

    Receipt UUIDs recover the five records without process memory. ABSENT needs
    this attempt's server-observed xid, an ABORTED status and all residual probes;
    after loss of the trace an absent receipt always remains INDETERMINATE.
    Reader failures/unsupported xid history/close failure never produce success.
    """
    from .question_orm_q0_connected_recipe_dormant import (
        _review_q0_reader_configuration, _classify_q0_commit_observation,
        _verify_committed_q0_readback,
    )
    expected = _expected_receipt(command, actor_id)
    if trace is not None and (type(trace) is not _WriterTrace or trace.expected != expected):
        raise PreparationHold("HOLD: D3 transaction trace identity mismatch")
    if trace is not None and not trace.atomic_entered:
        return _classify_q0_commit_observation(expected_receipt=expected, boundary="NOT_STARTED")
    result = _indeterminate()
    reader = None
    try:
        _review_q0_reader_configuration(connections.databases)
        reader = connections[READER]
        # Never close or take ownership of an external transaction.
        if (reader.alias != READER or reader.vendor != "postgresql"
                or reader.in_atomic_block or reader.get_autocommit() is not True):
            reader = None
            return result
        reader.close()
        with reader.cursor() as cursor:
            if postgres_session_identity(cursor) != ("oes_pg_a4_reader", "oes_sandbox", "on"):
                raise PreparationHold("HOLD: D3 reader identity mismatch")
        reader_privileges = _review_q0_privileges(reader)
        status = None
        if trace is not None and trace.xid is not None:
            with reader.cursor() as cursor:
                cursor.execute("SELECT pg_xact_status(%s::xid8)", [trace.xid])
                row = cursor.fetchone()
                status = row[0] if isinstance(row, tuple) and len(row) == 1 else None
            if status not in ("committed", "aborted"):
                raise PreparationHold("HOLD: D3 server outcome unavailable")
            if status == "aborted" and trace.boundary == "COMMIT_ACKNOWLEDGED":
                raise PreparationHold("HOLD: D3 contradictory commit evidence")
        with transaction.atomic(using=READER, savepoint=False):
            with reader.cursor() as cursor:
                # This is the first statement in the reader transaction. It
                # establishes a single primary snapshot for receipt + 5 checks.
                cursor.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
                cursor.execute(
                    "SELECT current_user,current_database(),current_setting('transaction_read_only'),"
                    "current_setting('transaction_isolation'),pg_is_in_recovery(),"
                    "pg_current_snapshot()::text,transaction_timestamp(),statement_timestamp()"
                )
                snapshot = cursor.fetchone()
                if (not isinstance(snapshot, tuple) or len(snapshot) != 8
                        or snapshot[:4] != ("oes_pg_a4_reader", "oes_sandbox", "on", "repeatable read")
                        or snapshot[4] is not False
                        or not isinstance(snapshot[5], str)
                        or re.fullmatch(r"[0-9]+:[0-9]+:(?:[0-9]+(?:,[0-9]+)*)?", snapshot[5]) is None
                        or any(not isinstance(t, datetime) or t.tzinfo is None for t in snapshot[6:])
                        or snapshot[6] > snapshot[7]):
                    raise PreparationHold("HOLD: D3 consistent primary snapshot unavailable")
            record = request_receipt(actor_id=actor_id, request_id=command.request_id).using(READER).first()
            if record is not None:
                receipt = Receipt(record.actor_id, record.request_id, record.fingerprint_sha256,
                                  record.question_id, record.resulting_version_no,
                                  record.command_kind, record.justification)
                # A visible receipt in a primary snapshot is a committed MVCC
                # observation, even if the writer acknowledgement was lost.
                if (receipt.actor_id, receipt.request_id) != (expected.actor_id, expected.request_id):
                    raise PreparationHold("HOLD: D3 receipt lookup identity mismatch")
                if receipt.fingerprint != expected.fingerprint:
                    raise PreparationConflict("HOLD: request fingerprint conflict")
                if status == "aborted":
                    raise PreparationHold("HOLD: D3 receipt contradicts aborted attempt")
                if (receipt != expected or type(receipt.version) is not int
                        or type(record.question_entity_uuid) is not UUID
                        or type(record.resulting_version_uuid) is not UUID
                        or record.question_entity_uuid == record.resulting_version_uuid
                        or not isinstance(record.committed_at, datetime)
                        or record.committed_at.tzinfo is None or record.committed_at > snapshot[7]):
                    raise PreparationHold("HOLD: D3 persisted receipt mismatch")
                if trace is not None and trace.candidate is not None:
                    if any(trace.candidate.get(key) != value for key, value in (
                            ("entity_uuid", record.question_entity_uuid),
                            ("version_uuid", record.resulting_version_uuid),
                            ("actor_id", actor_id), ("request_id", command.request_id),
                            ("fingerprint", expected.fingerprint), ("question_id", command.question_id))):
                        raise PreparationHold("HOLD: D3 attempted/persisted identifiers diverge")
                # Reuse the existing invariant verifier INSIDE this owned
                # snapshot. It still queries all five records, not a success flag.
                _verify_committed_q0_readback(
                    writer_alias=WRITER, read_alias=READER, actor_id=actor_id,
                    request_id=command.request_id, question_id=command.question_id,
                    fingerprint=expected.fingerprint, entity_uuid=record.question_entity_uuid,
                    version_uuid=record.resulting_version_uuid, original_text=command.original_text,
                    _snapshot_reader=reader,
                )
                result = _classify_q0_commit_observation(expected_receipt=expected,
                    observed_receipt=receipt, boundary=trace.boundary if trace is not None else "UNKNOWN",
                    writer_finished=True,
                    consistent_read=True, readback_verified=True)
                result["entity_uuid"] = str(record.question_entity_uuid)
                result["version_uuid"] = str(record.resulting_version_uuid)
            elif status == "aborted" and trace is not None and isinstance(trace.candidate, dict):
                candidate = trace.candidate
                e, v = candidate.get("entity_uuid"), candidate.get("version_uuid")
                if (type(e) is not UUID or type(v) is not UUID or e == v
                        or any(candidate.get(k) != value for k, value in (
                            ("actor_id", actor_id), ("request_id", command.request_id),
                            ("question_id", command.question_id), ("fingerprint", expected.fingerprint)))):
                    raise PreparationHold("HOLD: D3 residual probe identity unavailable")
                residues = (
                    OesEntity.objects.using(READER).filter(pk=e).exists(),
                    OesEntity.objects.using(READER).filter(oes_id=command.question_id).exists(),
                    OesQuestion.objects.using(READER).filter(pk=e).exists(),
                    OesEntityVersion.objects.using(READER).filter(entity_uuid=e).exists(),
                    OesEntityVersion.objects.using(READER).filter(pk=v).exists(),
                    OesQuestionVersion.objects.using(READER).filter(entity_uuid=e).exists(),
                    OesQuestionVersion.objects.using(READER).filter(pk=v).exists(),
                    OesQuestionCommandReceipt.objects.using(READER).filter(
                        actor_id=actor_id, request_id=command.request_id).exists(),
                )
                if all(value is False for value in residues):
                    result = _classify_q0_commit_observation(expected_receipt=expected,
                        boundary="ROLLED_BACK", writer_finished=True,
                        consistent_read=True, all_records_absent=True)
            # Receipt absent with no server proof is deliberately indeterminate.
            result["snapshot"] = snapshot[5]
            result["observed_at"] = snapshot[7].isoformat()
            result["server_xact_status"] = status
            result["writer_boundary"] = trace.boundary if trace is not None else "UNKNOWN"
            result["writer_local_closed"] = trace.local_closed if trace is not None else None
            result["writer_identity"] = trace.writer_identity if trace is not None else None
            result["writer_privileges"] = trace.writer_privileges if trace is not None else None
            result["reader_identity"] = snapshot[:3]
            result["reader_privileges"] = reader_privileges
    except PreparationConflict:
        raise
    except Exception:
        result = _indeterminate()
    finally:
        if reader is not None:
            try:
                reader.close()
            except Exception:
                result = _indeterminate()
    return result


def _require_q0_read_recovery_source_activation():
    """Independent READ ONLY source gate; cannot authorize any writer path."""
    raise PreparationHold("HOLD: Q0 read-only recovery not authorized")


def _recover_q0_commit_evidence(*, user, command):
    """Independent reader recovery, including process loss, still SOURCE HOLD.

    No operational injection, alternate constructor or caller-provided trace.
    A future activation must authorize this reader path separately as needed.
    """
    from .preparation_auth import require_question_preparer
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    _require_q0_read_recovery_source_activation()
    actor = persisted_preparer_actor_id(user)
    _expected_receipt(command, actor)
    return _collect_q0_commit_evidence(command=command, actor_id=actor)
