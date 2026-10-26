"""Contract checks for the injected SQL port; no database or network access."""
import unittest
from contextlib import contextmanager

from .question_preparation import PreparationHold
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

    def test_all_unsupported_semantics_hold(self):
        with self.make_port(FakeCursor()).begin() as tx:
            for name, args in (
                ("current_question", ("q", "actor")),
                ("register_q0", (object(), "actor")),
                ("propose_q1", (object(), "actor")),
                ("save_receipt", (object(),)),
            ):
                with self.subTest(name=name), self.assertRaises(PreparationHold):
                    getattr(tx, name)(*args)


if __name__ == "__main__":
    unittest.main()
