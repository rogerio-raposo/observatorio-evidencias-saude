"""Offline UoW + injected SQL replay integration; no connection or credentials."""
import unittest
from contextlib import contextmanager

from .question_preparation import QuestionCommand, PreparationConflict, command_fingerprint
from .question_sql_port_offline import InjectedQuestionSQLPort
from .question_uow_offline import OfflineQuestionUnitOfWork


class ReplayCursor:
    def __init__(self, *, actor, request, question, version, fingerprint, kind, justification="", scope=True):
        self.actor, self.request, self.question = actor, request, question
        self.version, self.fingerprint, self.kind = version, fingerprint, kind
        self.justification, self.scope = justification, scope
        self.calls = []
        self.reads = 0

    def execute(self, sql, params=()):
        self.calls.append((sql, params))
        if sql.startswith("INSERT ") or sql.startswith("UPDATE ") or sql.startswith("DELETE "):
            raise AssertionError("replay cannot write")

    def fetchone(self):
        sql, args = self.calls[-1]
        if "FROM investigation.question_command_receipt" in sql:
            self.reads += 1
            assert args == (self.actor, self.request)
            return (self.actor, self.request, self.fingerprint,
                    self.question, self.version, self.kind, self.justification)
        if "SELECT 1 FROM investigation.question AS q" in sql:
            assert args == (self.question, self.actor)
            return (1,) if self.scope else None
        raise AssertionError("unexpected replay read")


class ReplayOfflineIntegrationTests(unittest.TestCase):
    def submit(self, command, *, actor="actor", existing_fingerprint=None, scope=True):
        fingerprint = command_fingerprint(command)
        cursor = ReplayCursor(
            actor=actor, request=command.request_id, question=command.question_id,
            version=command.expected_version + 1,
            fingerprint=existing_fingerprint if existing_fingerprint is not None else fingerprint,
            kind="REGISTER_Q0" if command.expected_version == 0 else "PROPOSE_Q1",
            justification=command.justification if command.expected_version else "",
            scope=scope,
        )
        @contextmanager
        def factory():
            yield cursor
        port = InjectedQuestionSQLPort(factory)
        result = OfflineQuestionUnitOfWork(port).execute(
            command=command, actor_id=actor, fingerprint=fingerprint)
        return result, cursor

    def test_identical_q0_replay_reads_receipt_and_scope_without_writes(self):
        cmd = QuestionCommand("req0", "Q", 0, "Original")
        result, cursor = self.submit(cmd)
        self.assertEqual(result, {"status": "PREPARATORY_ONLY", "question_id": "Q", "version": 1})
        self.assertEqual(cursor.reads, 1)
        self.assertEqual(len(cursor.calls), 4)
        self.assertNotIn("FOR SHARE OF q", cursor.calls[-1][0])

    def test_identical_q1_replay_reads_receipt_and_scope_without_writes(self):
        cmd = QuestionCommand("req1", "Q", 1, "Original", "Normalized", "reason")
        result, cursor = self.submit(cmd)
        self.assertEqual(result["version"], 2)
        self.assertEqual(len(cursor.calls), 4)

    def test_reused_request_with_different_payload_conflicts_before_scope(self):
        cmd = QuestionCommand("req1", "Q", 1, "Original", "New", "reason")
        with self.assertRaises(PreparationConflict):
            self.submit(cmd, existing_fingerprint="f" * 64)

    def test_revoked_responsibility_blocks_q0_replay(self):
        cmd = QuestionCommand("req0", "Q", 0, "Original")
        with self.assertRaises(PreparationConflict):
            self.submit(cmd, scope=False)

    def test_revoked_responsibility_blocks_q1_replay(self):
        cmd = QuestionCommand("req1", "Q", 1, "Original", "Normalized", "reason")
        with self.assertRaises(PreparationConflict):
            self.submit(cmd, scope=False)


if __name__ == "__main__":
    unittest.main()
