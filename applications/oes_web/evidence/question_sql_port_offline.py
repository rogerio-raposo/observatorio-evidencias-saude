"""PF-I02-P2: bounded, offline-only PostgreSQL cursor port.

SQL is emitted only to an injected DB-API-like cursor. This module never
opens a connection, reads credentials, commits, or enables HTTP write access.
Incomplete authorization/write semantics fail closed until a separate gate.
"""
from contextlib import contextmanager
from uuid import uuid4

from .question_preparation import PreparationHold
from .question_uow_offline import Receipt


class InjectedQuestionSQLPort:
    """Accept a transaction factory supplied by the caller.

    factory() must return a context manager yielding a cursor with execute()
    and fetchone(); its owner handles commit/rollback. Never supply a live
    connection to this experimental port without a separate authorization.
    """

    def __init__(self, transaction_factory):
        if not callable(transaction_factory):
            raise TypeError("transaction_factory must be callable")
        self._factory = transaction_factory

    @contextmanager
    def begin(self):
        with self._factory() as cursor:
            if not callable(getattr(cursor, "execute", None)):
                raise PreparationHold("HOLD: invalid cursor")
            tx = _QuestionSQLTransaction(cursor)
            yield tx
            if tx._pending_q0 is not None or tx._pending_q1 is not None:
                raise PreparationHold("HOLD: question command missing receipt; abort transaction")


class _QuestionSQLTransaction:
    def __init__(self, cursor):
        self.cursor = cursor
        self._locked = False
        self._lock_identity = None
        self._pending_q0 = None
        self._pending_q1 = None

    def lock_request(self, actor_id, request_id):
        if not isinstance(actor_id, str) or not actor_id or not isinstance(request_id, str) or not request_id:
            raise PreparationHold("HOLD: invalid lock identity")
        # Stable transaction-level lock; collision is safe (only serializes more).
        self.cursor.execute(
            "SELECT pg_advisory_xact_lock(hashtextextended(%s, 0))",
            (str(len(actor_id)) + ":" + actor_id + ":" + str(len(request_id)) + ":" + request_id,)
        )
        self._locked = True
        self._lock_identity = (actor_id, request_id)

    def find_receipt(self, actor_id, request_id):
        if not self._locked:
            raise PreparationHold("HOLD: request not locked")
        self.cursor.execute(
            "SELECT actor_id, request_id, fingerprint_sha256, question_id, "
            "resulting_version_no, command_kind, justification "
            "FROM investigation.question_command_receipt "
            "WHERE actor_id = %s AND request_id = %s",
            (actor_id, request_id)
        )
        row = self.cursor.fetchone()
        if row is None:
            return None
        if not isinstance(row, (tuple, list)) or len(row) != 7:
            raise PreparationHold("HOLD: malformed receipt")
        if row[0] != actor_id or row[1] != request_id:
            raise PreparationHold("HOLD: receipt key mismatch")
        if not isinstance(row[2], str) or len(row[2]) != 64 or any(ch not in "0123456789abcdef" for ch in row[2]):
            raise PreparationHold("HOLD: malformed fingerprint")
        return Receipt(*row)

    def current_question(self, question_id, actor_id, lock=False):
        """Actor-scoped latest question; SQL-only sketch using injected cursor.

        Lock q before reading its versions. Revocation must acquire a conflicting
        q row lock in a future separately approved implementation.
        """
        if not self._locked:
            raise PreparationHold("HOLD: request not locked")
        if (not isinstance(question_id, str) or not question_id
                or not isinstance(actor_id, str) or not actor_id
                or not isinstance(lock, bool)):
            raise PreparationHold("HOLD: invalid question lookup")
        self.cursor.execute(
            "SELECT ev.version_no, qv.original_text, qv.normalized_text "
            "FROM investigation.question AS q "
            "JOIN core.entity AS e ON e.entity_uuid = q.entity_uuid "
            "JOIN core.entity_version AS ev ON ev.entity_uuid = q.entity_uuid "
            "JOIN investigation.question_version AS qv "
            "ON qv.entity_uuid = ev.entity_uuid AND qv.version_uuid = ev.version_uuid "
            "WHERE e.oes_id = %s AND q.responsible_actor_id = %s "
            "AND ev.valid_to IS NULL "
            "ORDER BY ev.version_no DESC LIMIT 1 "
            + ("FOR UPDATE OF q" if lock else "FOR SHARE OF q"),
            (question_id, actor_id),
        )
        row = self.cursor.fetchone()
        if row is None:
            return None
        if (not isinstance(row, (list, tuple)) or len(row) != 3
                or type(row[0]) is not int or row[0] < 1
                or not isinstance(row[1], str) or not row[1]
                or (row[2] is not None and not isinstance(row[2], str))):
            raise PreparationHold("HOLD: malformed question state")
        return {"version": row[0], "original_text": row[1],
                "normalized_text": row[2]}

    def can_access_question(self, question_id, actor_id):
        """Offline SQL sketch only: lock the matched responsibility row.

        The caller must already have passed Django's preparer permission gate.
        A transaction manager must hold the row lock through commit; this
        adapter cannot establish that property without connected validation.
        """
        if not self._locked:
            raise PreparationHold("HOLD: request not locked")
        if (not isinstance(question_id, str) or not question_id
                or not isinstance(actor_id, str) or not actor_id):
            raise PreparationHold("HOLD: invalid access identity")
        self.cursor.execute(
            "SELECT 1 FROM investigation.question AS q "
            "JOIN core.entity AS e ON e.entity_uuid = q.entity_uuid "
            "WHERE e.oes_id = %s AND q.responsible_actor_id = %s "
            "FOR SHARE OF q",
            (question_id, actor_id),
        )
        row = self.cursor.fetchone()
        if row is None:
            return False
        if row != (1,) and row != [1]:
            raise PreparationHold("HOLD: malformed access result")
        return True

    def register_q0(self, command, actor_id):
        if (not self._locked or self._pending_q0 is not None
                or self._lock_identity[0] != actor_id):
            raise PreparationHold("HOLD: Q0 transaction unavailable")
        if (not isinstance(actor_id, str) or not 1 <= len(actor_id) <= 128
                or not isinstance(command.question_id, str) or not command.question_id
                or not isinstance(command.original_text, str) or not command.original_text
                or command.expected_version != 0 or command.normalized_text is not None
                or command.justification):
            raise PreparationHold("HOLD: invalid Q0")
        entity_id, version_id = uuid4(), uuid4()
        self.cursor.execute(
            "INSERT INTO core.entity (entity_uuid, oes_id, entity_type, created_by) "
            "VALUES (%s, %s, %s, %s)",
            (entity_id, command.question_id, "Question", actor_id))
        self.cursor.execute(
            "INSERT INTO investigation.question (entity_uuid, responsible_actor_id) "
            "VALUES (%s, %s)", (entity_id, actor_id))
        self.cursor.execute(
            "INSERT INTO core.entity_version "
            "(version_uuid, entity_uuid, version_no, version_status, created_by, change_type) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (version_id, entity_id, 1, "current", actor_id, "initial"))
        self.cursor.execute(
            "INSERT INTO investigation.question_version "
            "(version_uuid, entity_uuid, original_text, normalized_text, preparation_stage) "
            "VALUES (%s, %s, %s, %s, %s)",
            (version_id, entity_id, command.original_text, None, "q0_draft"))
        self._pending_q0 = (command.question_id, actor_id, entity_id, version_id)

    def propose_q1(self, command, actor_id):
        if (not self._locked or self._lock_identity[0] != actor_id
                or self._pending_q0 is not None or self._pending_q1 is not None):
            raise PreparationHold("HOLD: Q1 transaction unavailable")
        if (not isinstance(command.question_id, str) or not command.question_id
                or type(command.expected_version) is not int or command.expected_version < 1
                or not isinstance(command.original_text, str) or not command.original_text
                or not isinstance(command.normalized_text, str) or not command.normalized_text
                or not isinstance(command.justification, str) or not command.justification.strip()):
            raise PreparationHold("HOLD: invalid Q1")
        # Scope and row locking are mandatory and rechecked in this statement.
        self.cursor.execute(
            "SELECT q.entity_uuid, ev.version_uuid, ev.version_no, qv.original_text "
            "FROM investigation.question q "
            "JOIN core.entity e ON e.entity_uuid = q.entity_uuid "
            "JOIN core.entity_version ev ON ev.entity_uuid = q.entity_uuid "
            "JOIN investigation.question_version qv "
            "ON qv.entity_uuid = ev.entity_uuid AND qv.version_uuid = ev.version_uuid "
            "WHERE e.oes_id = %s AND q.responsible_actor_id = %s "
            "AND ev.version_status = 'current' AND ev.valid_to IS NULL "
            "FOR UPDATE OF q, ev",
            (command.question_id, actor_id))
        row = self.cursor.fetchone()
        if (not isinstance(row, (tuple, list)) or len(row) != 4
                or type(row[2]) is not int or row[2] != command.expected_version
                or row[3] != command.original_text or row[0] is None or row[1] is None):
            raise PreparationHold("HOLD: Q1 stale or inaccessible")
        entity_id, previous_version_id = row[0], row[1]
        next_version_id = uuid4()
        self.cursor.execute(
            "UPDATE core.entity_version SET version_status = %s, valid_to = CURRENT_TIMESTAMP "
            "WHERE version_uuid = %s AND entity_uuid = %s "
            "AND version_no = %s AND version_status = %s AND valid_to IS NULL",
            ("superseded", previous_version_id, entity_id, command.expected_version, "current"))
        if self.cursor.rowcount != 1:
            raise PreparationHold("HOLD: Q1 version update conflict")
        self.cursor.execute(
            "INSERT INTO core.entity_version "
            "(version_uuid, entity_uuid, version_no, version_status, supersedes_version_uuid, "
            "created_by, change_type) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (next_version_id, entity_id, command.expected_version + 1, "current",
             previous_version_id, actor_id, "normalization_proposed"))
        self.cursor.execute(
            "INSERT INTO investigation.question_version "
            "(version_uuid, entity_uuid, original_text, normalized_text, preparation_stage) "
            "VALUES (%s, %s, %s, %s, %s)",
            (next_version_id, entity_id, command.original_text,
             command.normalized_text, "q1_proposed"))
        self._pending_q1 = (command.question_id, actor_id, entity_id,
                            next_version_id, command.expected_version + 1,
                            command.justification)


    def save_receipt(self, receipt):
        if not self._locked:
            raise PreparationHold("HOLD: no locked command")
        pending = self._pending_q0 or self._pending_q1
        if pending is None:
            raise PreparationHold("HOLD: no pending command")
        if self._pending_q0 is not None:
            question_id, actor_id, entity_id, version_id = self._pending_q0
            expected_version, kind, justification = 1, "REGISTER_Q0", ""
        else:
            question_id, actor_id, entity_id, version_id, expected_version, justification = self._pending_q1
            kind = "PROPOSE_Q1"
        if (not isinstance(receipt, Receipt) or receipt.question_id != question_id
                or receipt.actor_id != actor_id or receipt.command_kind != kind
                or (receipt.actor_id, receipt.request_id) != self._lock_identity
                or receipt.version != expected_version or receipt.justification != justification
                or not isinstance(receipt.request_id, str) or not 1 <= len(receipt.request_id) <= 128
                or not isinstance(receipt.fingerprint, str) or len(receipt.fingerprint) != 64
                or any(ch not in "0123456789abcdef" for ch in receipt.fingerprint)):
            raise PreparationHold("HOLD: invalid command receipt")
        self.cursor.execute(
            "INSERT INTO investigation.question_command_receipt "
            "(actor_id, request_id, fingerprint_sha256, question_entity_uuid, question_id, "
            "resulting_version_uuid, resulting_version_no, command_kind, justification) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (actor_id, receipt.request_id, receipt.fingerprint, entity_id, question_id,
             version_id, expected_version, kind, justification))
        self._pending_q0 = None
        self._pending_q1 = None
