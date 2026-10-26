"""PF-I02-P2: bounded, offline-only PostgreSQL cursor port.

SQL is emitted only to an injected DB-API-like cursor. This module never
opens a connection, reads credentials, commits, or enables HTTP write access.
Incomplete authorization/write semantics fail closed until a separate gate.
"""
from contextlib import contextmanager

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
            yield _QuestionSQLTransaction(cursor)


class _QuestionSQLTransaction:
    def __init__(self, cursor):
        self.cursor = cursor
        self._locked = False

    def lock_request(self, actor_id, request_id):
        if not isinstance(actor_id, str) or not actor_id or not isinstance(request_id, str) or not request_id:
            raise PreparationHold("HOLD: invalid lock identity")
        # Stable transaction-level lock; collision is safe (only serializes more).
        self.cursor.execute(
            "SELECT pg_advisory_xact_lock(hashtextextended(%s, 0))",
            (str(len(actor_id)) + ":" + actor_id + ":" + str(len(request_id)) + ":" + request_id,)
        )
        self._locked = True

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
        raise PreparationHold("HOLD: SQL actor-scoped question policy not implemented")

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
        raise PreparationHold("HOLD: SQL Q0 mapping not implemented")

    def propose_q1(self, command, actor_id):
        raise PreparationHold("HOLD: SQL Q1 mapping not implemented")

    def save_receipt(self, receipt):
        raise PreparationHold("HOLD: receipt write not implemented")
