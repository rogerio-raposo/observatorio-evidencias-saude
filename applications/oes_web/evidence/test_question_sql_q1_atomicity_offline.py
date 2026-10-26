"""Q1 atomicity contract using a synthetic transactional cursor; no database access."""
import unittest
from contextlib import contextmanager
from copy import deepcopy
from uuid import UUID

from .question_preparation import QuestionCommand, PreparationHold
from .question_sql_port_offline import InjectedQuestionSQLPort
from .question_uow_offline import Receipt

ENTITY = UUID(int=11)
V1 = UUID(int=12)


class Q1Database:
    def __init__(self):
        self.state = {"current": 1, "version_uuid": V1, "actor": "owner",
                      "original": "Original", "versions": {1: ("Original", None)},
                      "receipts": []}
        self.fail_at = None
        self.commits = 0
        self.rollbacks = 0

    @contextmanager
    def factory(self):
        staged = deepcopy(self.state)
        cursor = Q1Cursor(staged, self.fail_at)
        try:
            yield cursor
        except Exception:
            self.rollbacks += 1
            raise
        else:
            self.state = staged
            self.commits += 1


class Q1Cursor:
    def __init__(self, state, fail_at):
        self.state = state
        self.fail_at = fail_at
        self.rowcount = 0
        self.result = None

    def execute(self, sql, params=()):
        if sql.startswith("SELECT pg_advisory_xact_lock"):
            return
        if sql.startswith("SELECT q.entity_uuid"):
            qid, actor = params
            if actor == self.state["actor"] and qid == "Q" and self.state["current"]:
                self.result = (ENTITY, self.state["version_uuid"],
                               self.state["current"], self.state["original"])
            else:
                self.result = None
            return
        if sql.startswith("UPDATE core.entity_version SET"):
            if self.fail_at == "update":
                raise RuntimeError("simulated Q1 update failure")
            _, version, entity, expected, _ = params
            self.rowcount = int(entity == ENTITY and version == self.state["version_uuid"]
                                and expected == self.state["current"])
            if self.rowcount:
                self.state["current"] = None
            return
        if sql.startswith("INSERT INTO core.entity_version"):
            if self.fail_at == "entity_version":
                raise RuntimeError("simulated version insert failure")
            version, entity, number, status, previous, actor, _ = params
            if entity != ENTITY or status != "current" or previous != self.state["version_uuid"]:
                raise AssertionError("invalid version relationship")
            self.state["next_uuid"] = version
            self.state["next_no"] = number
            return
        if sql.startswith("INSERT INTO investigation.question_version"):
            if self.fail_at == "question_version":
                raise RuntimeError("simulated Question version failure")
            version, entity, original, normalized, stage = params
            if (entity != ENTITY or version != self.state["next_uuid"]
                    or original != self.state["original"] or stage != "q1_proposed"):
                raise AssertionError("invalid Q1 relationship")
            self.state["versions"][self.state["next_no"]] = (original, normalized)
            return
        if sql.startswith("INSERT INTO investigation.question_command_receipt"):
            if self.fail_at == "receipt":
                raise RuntimeError("simulated receipt failure")
            actor, request, _, entity, qid, version, number, kind, justification = params
            if (actor != "owner" or entity != ENTITY or qid != "Q"
                    or version != self.state["next_uuid"] or number != self.state["next_no"]
                    or kind != "PROPOSE_Q1" or not justification):
                raise AssertionError("invalid ledger receipt")
            self.state["receipts"].append((actor, request, number))
            self.state["version_uuid"] = version
            self.state["current"] = number
            return
        raise AssertionError("unmodelled SQL must fail closed")

    def fetchone(self):
        return self.result


def submit_q1(db, request="q1-a", actor="owner", expected=1, save=True):
    cmd = QuestionCommand(request, "Q", expected, "Original", "Normalized", "reason")
    with InjectedQuestionSQLPort(db.factory).begin() as tx:
        tx.lock_request(actor, request)
        tx.propose_q1(cmd, actor)
        if save:
            tx.save_receipt(Receipt(actor, request, "b" * 64, "Q",
                                    expected + 1, "PROPOSE_Q1", "reason"))


class Q1AtomicityOfflineTests(unittest.TestCase):
    def test_q1_commits_new_version_and_ledger_once(self):
        db = Q1Database()
        submit_q1(db)
        self.assertEqual(db.state["current"], 2)
        self.assertEqual(db.state["versions"][1], ("Original", None))
        self.assertEqual(db.state["versions"][2], ("Original", "Normalized"))
        self.assertEqual(db.state["receipts"], [("owner", "q1-a", 2)])
        self.assertEqual((db.commits, db.rollbacks), (1, 0))

    def test_q1_failure_at_each_write_rolls_back_entire_transaction(self):
        for stage in ("update", "entity_version", "question_version", "receipt"):
            with self.subTest(stage=stage):
                db = Q1Database()
                before = deepcopy(db.state)
                db.fail_at = stage
                with self.assertRaises(RuntimeError):
                    submit_q1(db)
                self.assertEqual(db.state, before)
                self.assertEqual((db.commits, db.rollbacks), (0, 1))

    def test_q1_without_receipt_rolls_back(self):
        db = Q1Database()
        before = deepcopy(db.state)
        with self.assertRaisesRegex(PreparationHold, "missing receipt"):
            submit_q1(db, save=False)
        self.assertEqual(db.state, before)
        self.assertEqual((db.commits, db.rollbacks), (0, 1))

    def test_second_q1_against_stale_version_rolls_back(self):
        db = Q1Database()
        submit_q1(db)
        before = deepcopy(db.state)
        with self.assertRaisesRegex(PreparationHold, "stale or inaccessible"):
            submit_q1(db, request="q1-b", expected=1)
        self.assertEqual(db.state, before)
        self.assertEqual((db.commits, db.rollbacks), (1, 1))

    def test_other_actor_cannot_propose_q1(self):
        db = Q1Database()
        before = deepcopy(db.state)
        with self.assertRaises(PreparationHold):
            submit_q1(db, request="other", actor="stranger")
        self.assertEqual(db.state, before)


if __name__ == "__main__":
    unittest.main()
