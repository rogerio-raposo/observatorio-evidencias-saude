"""PF-I02-P2: in-memory transactional cursor simulation; never connects to SQL."""
import unittest
from contextlib import contextmanager
from copy import deepcopy

from .question_preparation import QuestionCommand, PreparationHold
from .question_sql_port_offline import InjectedQuestionSQLPort
from .question_uow_offline import Receipt


class SimulatedDatabase:
    def __init__(self):
        self.rows = {}
        self.commits = 0
        self.rollbacks = 0
        self.fail_table = None

    @contextmanager
    def factory(self):
        pending = deepcopy(self.rows)
        cursor = TransactionCursor(pending, self.fail_table)
        try:
            yield cursor
        except Exception:
            self.rollbacks += 1
            raise
        else:
            self.rows = pending
            self.commits += 1


class TransactionCursor:
    def __init__(self, rows, fail_table):
        self.rows = rows
        self.fail_table = fail_table
        self.calls = []

    def execute(self, sql, params=()):
        self.calls.append((sql, params))
        if sql.startswith("SELECT pg_advisory_xact_lock"):
            return
        if not sql.startswith("INSERT INTO "):
            raise AssertionError("unmodeled SQL, fail closed")
        table = sql.split("INSERT INTO ", 1)[1].split(" ", 1)[0]
        if table not in ("core.entity", "investigation.question",
                         "core.entity_version", "investigation.question_version",
                         "investigation.question_command_receipt"):
            raise AssertionError("unmodeled table")
        if table == self.fail_table:
            raise RuntimeError("simulated write failure")
        if table == "core.entity":
            # Unique global question ID, independent of the actor.
            if any(t == table and r[1] == params[1] for (t, _), r in self.rows.items()):
                raise ValueError("simulated unique oes_id conflict")
        key = (table, params[0] if table != "investigation.question_command_receipt"
               else (params[0], params[1]))
        if key in self.rows:
            raise ValueError("simulated primary-key conflict")
        self.rows[key] = params


def write_q0(db, actor="actor", request="req", qid="Q"):
    port = InjectedQuestionSQLPort(db.factory)
    with port.begin() as tx:
        tx.lock_request(actor, request)
        tx.register_q0(QuestionCommand(request, qid, 0, "Original"), actor)
        tx.save_receipt(Receipt(actor, request, "a" * 64, qid, 1, "REGISTER_Q0"))


class SimulatedAtomicityTests(unittest.TestCase):
    def test_success_commits_all_five_records(self):
        db = SimulatedDatabase()
        write_q0(db)
        self.assertEqual(db.commits, 1)
        self.assertEqual(db.rollbacks, 0)
        self.assertEqual(len(db.rows), 5)
        self.assertEqual({t for t, _ in db.rows}, {
            "core.entity", "investigation.question", "core.entity_version",
            "investigation.question_version", "investigation.question_command_receipt"})

    def test_each_insert_failure_rolls_back_every_record(self):
        for table in ("core.entity", "investigation.question",
                      "core.entity_version", "investigation.question_version",
                      "investigation.question_command_receipt"):
            with self.subTest(table=table):
                db = SimulatedDatabase()
                db.fail_table = table
                with self.assertRaises(RuntimeError):
                    write_q0(db)
                self.assertEqual(db.rows, {})
                self.assertEqual(db.commits, 0)
                self.assertEqual(db.rollbacks, 1)

    def test_missing_receipt_aborts_entire_transaction(self):
        db = SimulatedDatabase()
        port = InjectedQuestionSQLPort(db.factory)
        with self.assertRaises(PreparationHold):
            with port.begin() as tx:
                tx.lock_request("actor", "req")
                tx.register_q0(QuestionCommand("req", "Q", 0, "Original"), "actor")
        self.assertEqual(db.rows, {})
        self.assertEqual((db.commits, db.rollbacks), (0, 1))

    def test_cross_actor_duplicate_identity_fails_without_partial_state(self):
        db = SimulatedDatabase()
        write_q0(db, "actor-a", "req-a", "Q")
        original = deepcopy(db.rows)
        with self.assertRaises(ValueError):
            write_q0(db, "actor-b", "req-b", "Q")
        self.assertEqual(db.rows, original)
        self.assertEqual((db.commits, db.rollbacks), (1, 1))

    def test_repeated_q0_insert_fails_without_duplicate(self):
        # No replay acceptance is implied: the real UoW must first read receipt.
        db = SimulatedDatabase()
        write_q0(db)
        original = deepcopy(db.rows)
        with self.assertRaises(ValueError):
            write_q0(db)
        self.assertEqual(db.rows, original)
        self.assertEqual((db.commits, db.rollbacks), (1, 1))


if __name__ == "__main__":
    unittest.main()
