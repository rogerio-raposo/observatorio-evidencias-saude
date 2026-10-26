"""Contract checks for the injected SQL port; no database or network access."""
import unittest
from contextlib import contextmanager

from .question_preparation import PreparationHold, QuestionCommand
from .question_uow_offline import Receipt
from .question_sql_port_offline import InjectedQuestionSQLPort


class FakeCursor:
    def __init__(self, row=None):
        self.row = row
        self.calls = []

    def execute(self, sql, params=()):
        self.calls.append((sql, params))

    def fetchone(self):
        return self.row


class InjectedSQLPortTests(unittest.TestCase):
    def make_port(self, cursor):
        @contextmanager
        def factory():
            yield cursor
        return InjectedQuestionSQLPort(factory)

    def test_rejects_missing_factory(self):
        with self.assertRaises(TypeError):
            InjectedQuestionSQLPort(None)

    def test_lock_uses_parameters_and_transaction_scoped_lock(self):
        cursor = FakeCursor()
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request")
        self.assertEqual(len(cursor.calls), 1)
        sql, params = cursor.calls[0]
        self.assertIn("pg_advisory_xact_lock", sql)
        self.assertIn("%s", sql)
        self.assertNotIn("actor", sql)
        self.assertEqual(len(params), 1)

    def test_replay_receipt_read_is_parameterized(self):
        row = ("actor", "request", "f" * 64, "Q01", 1, "REGISTER_Q0", "")
        cursor = FakeCursor(row)
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request")
            receipt = tx.find_receipt("actor", "request")
        self.assertEqual(receipt.version, 1)
        self.assertEqual(receipt.question_id, "Q01")
        self.assertEqual(cursor.calls[1][1], ("actor", "request"))

    def test_receipt_query_requires_lock(self):
        with self.make_port(FakeCursor()).begin() as tx:
            with self.assertRaises(PreparationHold):
                tx.find_receipt("actor", "request")

    def test_malformed_receipt_holds(self):
        with self.make_port(FakeCursor(("bad",))).begin() as tx:
            tx.lock_request("actor", "request")
            with self.assertRaises(PreparationHold):
                tx.find_receipt("actor", "request")

    def test_receipt_actor_mismatch_holds(self):
        row = ("other", "request", "f" * 64, "Q01", 1, "REGISTER_Q0", "")
        with self.make_port(FakeCursor(row)).begin() as tx:
            tx.lock_request("actor", "request")
            with self.assertRaises(PreparationHold):
                tx.find_receipt("actor", "request")

    def test_receipt_invalid_fingerprint_holds(self):
        row = ("actor", "request", "not-a-digest", "Q01", 1, "REGISTER_Q0", "")
        with self.make_port(FakeCursor(row)).begin() as tx:
            tx.lock_request("actor", "request")
            with self.assertRaises(PreparationHold):
                tx.find_receipt("actor", "request")

    def test_lock_key_disambiguates_actor_and_request(self):
        a, b = FakeCursor(), FakeCursor()
        with self.make_port(a).begin() as tx:
            tx.lock_request("x:1:y", "z")
        with self.make_port(b).begin() as tx:
            tx.lock_request("x", "y:1:z")
        self.assertNotEqual(a.calls[0][1], b.calls[0][1])

    def test_scope_allowed_with_parameterized_predicate_and_row_lock(self):
        cursor = FakeCursor((1,))
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request")
            self.assertTrue(tx.can_access_question("Q01", "actor"))
        sql, args = cursor.calls[1]
        self.assertIn("q.responsible_actor_id = %s", sql)
        self.assertIn("e.oes_id = %s", sql)
        self.assertIn("FOR SHARE OF q", sql)
        self.assertEqual(args, ("Q01", "actor"))
        self.assertNotIn("Q01", sql)

    def test_scope_missing_or_revoked_is_false(self):
        cursor = FakeCursor(None)
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request")
            self.assertFalse(tx.can_access_question("Q01", "actor"))

    def test_scope_requires_request_lock(self):
        with self.make_port(FakeCursor((1,))).begin() as tx:
            with self.assertRaises(PreparationHold):
                tx.can_access_question("Q01", "actor")

    def test_scope_malformed_row_holds(self):
        with self.make_port(FakeCursor(("unexpected",))).begin() as tx:
            tx.lock_request("actor", "request")
            with self.assertRaises(PreparationHold):
                tx.can_access_question("Q01", "actor")

    def test_current_question_scoped_locked_and_parameterized(self):
        cursor = FakeCursor((2, "Original", "Normalizada"))
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request")
            state = tx.current_question("Q01", "actor", lock=True)
        self.assertEqual(state["version"], 2)
        self.assertEqual(state["original_text"], "Original")
        sql, params = cursor.calls[1]
        self.assertIn("q.responsible_actor_id = %s", sql)
        self.assertIn("FOR UPDATE OF q", sql)
        self.assertIn("ev.version_status = 'current'", sql)
        self.assertEqual(params, ("Q01", "actor"))
        self.assertNotIn("Q01", sql)

    def test_current_question_absent_is_not_disclosed(self):
        cursor = FakeCursor(None)
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("other", "request")
            self.assertIsNone(tx.current_question("Q01", "other", lock=True))

    def test_current_question_read_mode_and_q0_draft(self):
        cursor = FakeCursor((1, "Original", None))
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request")
            state = tx.current_question("Q01", "actor")
        self.assertIsNone(state["normalized_text"])
        self.assertIn("FOR SHARE OF q", cursor.calls[1][0])

    def test_current_question_requires_lock_and_valid_state(self):
        cursor = FakeCursor(("bad", "Original", None))
        with self.make_port(cursor).begin() as tx:
            with self.assertRaises(PreparationHold):
                tx.current_question("Q01", "actor")
            tx.lock_request("actor", "request")
            with self.assertRaises(PreparationHold):
                tx.current_question("Q01", "actor", lock=True)

    def test_q0_and_receipt_parameterized_insert_order(self):
        cursor = FakeCursor()
        cmd = QuestionCommand("req", "OES-Q-SYN", 0, "Original")
        receipt = Receipt("actor", "req", "a" * 64, "OES-Q-SYN", 1, "REGISTER_Q0")
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "req")
            tx.register_q0(cmd, "actor")
            tx.save_receipt(receipt)
        calls = cursor.calls[1:]
        self.assertEqual(len(calls), 5)
        for (sql, params), table in zip(calls, (
            "core.entity ", "investigation.question ", "core.entity_version ",
            "investigation.question_version ", "investigation.question_command_receipt ")):
            self.assertIn("INSERT INTO " + table, sql)
            self.assertIn("%s", sql)
            self.assertNotIn("OES-Q-SYN", sql)
        entity_uuid = calls[0][1][0]
        version_uuid = calls[2][1][0]
        self.assertEqual(calls[1][1], (entity_uuid, "actor"))
        self.assertEqual(calls[3][1][0:2], (version_uuid, entity_uuid))
        self.assertEqual(calls[3][1][3:], (None, "q0_draft"))
        self.assertEqual(calls[4][1][3], entity_uuid)
        self.assertEqual(calls[4][1][5], version_uuid)

    def test_q0_requires_lock_and_rejects_invalid_command(self):
        cursor = FakeCursor()
        cmd = QuestionCommand("req", "Q", 0, "Original")
        with self.make_port(cursor).begin() as tx:
            with self.assertRaises(PreparationHold):
                tx.register_q0(cmd, "actor")
            tx.lock_request("actor", "req")
            with self.assertRaises(PreparationHold):
                tx.register_q0(QuestionCommand("req", "Q", 2, "Original"), "actor")
        self.assertEqual(len(cursor.calls), 1)

    def test_receipt_requires_matching_pending_q0(self):
        cursor = FakeCursor()
        receipt = Receipt("actor", "req", "a" * 64, "Q", 1, "REGISTER_Q0")
        with self.assertRaisesRegex(PreparationHold, "question command missing receipt"):
            with self.make_port(cursor).begin() as tx:
                tx.lock_request("actor", "req")
                with self.assertRaises(PreparationHold):
                    tx.save_receipt(receipt)
                tx.register_q0(QuestionCommand("req", "Q", 0, "Original"), "actor")
                with self.assertRaises(PreparationHold):
                    tx.save_receipt(Receipt("other", "req", "a" * 64, "Q", 1, "REGISTER_Q0"))
        self.assertEqual(len(cursor.calls), 5)

    def test_q0_cursor_failure_propagates_for_transaction_rollback(self):
        class FailingCursor(FakeCursor):
            def execute(self, sql, params=()):
                super().execute(sql, params)
                if "INSERT INTO investigation.question_version" in sql:
                    raise RuntimeError("simulated write failure")
        cursor = FailingCursor()
        with self.assertRaises(RuntimeError):
            with self.make_port(cursor).begin() as tx:
                tx.lock_request("actor", "req")
                tx.register_q0(QuestionCommand("req", "Q", 0, "Original"), "actor")
        # The injected factory, not the port, owns rollback in a real transaction.
        self.assertEqual(len(cursor.calls), 5)

    def test_q1_scoped_version_transition_and_receipt(self):
        from uuid import UUID
        class Q1Cursor(FakeCursor):
            rowcount = 1
            def fetchone(self):
                return (UUID(int=1), UUID(int=2), 1, "Original")
        cursor = Q1Cursor()
        cmd = QuestionCommand("request-q1", "Q", 1, "Original", "Normalizada", "justificativa")
        receipt = Receipt("actor", "request-q1", "b" * 64, "Q", 2, "PROPOSE_Q1", "justificativa")
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "request-q1")
            tx.propose_q1(cmd, "actor")
            tx.save_receipt(receipt)
        sqls = [x[0] for x in cursor.calls[1:]]
        self.assertEqual(len(sqls), 5)
        self.assertIn("FOR UPDATE OF q, ev", sqls[0])
        self.assertIn("responsible_actor_id = %s", sqls[0])
        self.assertIn("UPDATE core.entity_version", sqls[1])
        self.assertIn("INSERT INTO core.entity_version", sqls[2])
        self.assertIn("INSERT INTO investigation.question_version", sqls[3])
        self.assertIn("INSERT INTO investigation.question_command_receipt", sqls[4])
        self.assertEqual(cursor.calls[1][1], ("Q", "actor"))
        self.assertEqual(cursor.calls[4][1][2], "Original")
        self.assertEqual(cursor.calls[4][1][3], "Normalizada")
        self.assertEqual(cursor.calls[5][1][7:], ("PROPOSE_Q1", "justificativa"))

    def test_q1_denies_stale_version_without_writes(self):
        from uuid import UUID
        cursor = FakeCursor((UUID(int=1), UUID(int=2), 2, "Original"))
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "req")
            with self.assertRaises(PreparationHold):
                tx.propose_q1(QuestionCommand("req", "Q", 1, "Original", "Q1", "why"), "actor")
        self.assertEqual(len(cursor.calls), 2)

    def test_q1_missing_receipt_aborts_context(self):
        from uuid import UUID
        class Q1Cursor(FakeCursor):
            rowcount = 1
        cursor = Q1Cursor((UUID(int=1), UUID(int=2), 1, "Original"))
        with self.assertRaisesRegex(PreparationHold, "missing receipt"):
            with self.make_port(cursor).begin() as tx:
                tx.lock_request("actor", "req")
                tx.propose_q1(QuestionCommand("req", "Q", 1, "Original", "Q1", "why"), "actor")

    def test_q1_stale_update_count_fails_closed(self):
        from uuid import UUID
        class Q1Cursor(FakeCursor):
            rowcount = 0
        cursor = Q1Cursor((UUID(int=1), UUID(int=2), 1, "Original"))
        with self.make_port(cursor).begin() as tx:
            tx.lock_request("actor", "req")
            with self.assertRaisesRegex(PreparationHold, "version update conflict"):
                tx.propose_q1(QuestionCommand("req", "Q", 1, "Original", "Q1", "why"), "actor")

    def test_unsupported_q1_without_lock_holds(self):
        with self.make_port(FakeCursor()).begin() as tx:
            with self.assertRaises(PreparationHold):
                tx.propose_q1(object(), "actor")


if __name__ == "__main__":
    unittest.main()
