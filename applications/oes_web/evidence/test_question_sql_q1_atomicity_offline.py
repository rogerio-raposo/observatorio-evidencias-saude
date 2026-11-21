"""Q1 atomicity contract using a synthetic transactional cursor; no database access."""
import unittest
from contextlib import contextmanager
from copy import deepcopy
from dataclasses import replace
from types import SimpleNamespace
from unittest.mock import Mock, patch
from uuid import UUID

from .question_preparation import (
    QuestionCommand, PreparationConflict, PreparationHold, command_fingerprint,
    propose_authenticated_q1, review_authenticated_q1_offline,
)
from .question_sql_port_offline import InjectedQuestionSQLPort
from .question_uow_offline import OfflineQuestionUnitOfWork, Receipt

ENTITY = UUID(int=11)
V1 = UUID(int=12)
COMMAND = QuestionCommand("q1-a", "Q", 1, "Original", "Normalized", "reason")


class Q1Database:
    def __init__(self):
        self.state = {"current": 1, "version_uuid": V1, "actor": "owner",
                      "original": "Original", "versions": {1: ("Original", None)},
                      "receipts": [], "stage": "q0_draft", "closed": {}}
        self.fail_at = None
        self.commits = 0
        self.rollbacks = 0
        self.attempts = 0

    @contextmanager
    def factory(self):
        self.attempts += 1
        if self.fail_at == "begin":
            raise RuntimeError("simulated transaction start failure")
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
            if self.fail_at == "commit_ack":
                raise RuntimeError("simulated lost commit acknowledgement")


class Q1Cursor:
    def __init__(self, state, fail_at):
        self.state = state
        self.fail_at = fail_at
        self.rowcount = 0
        self.result = None

    def execute(self, sql, params=()):
        if sql.startswith("SELECT pg_advisory_xact_lock"):
            return
        if sql.startswith("SELECT actor_id, request_id"):
            self.result = next((row for row in self.state["receipts"] if row[:2] == params), None)
            return
        if sql.startswith(("SELECT ev.version_no", "SELECT 1 FROM investigation.question")):
            question, actor = params
            current = self.state["current"]
            self.result = None
            if question == "Q" and actor == self.state["actor"] and current is not None:
                self.result = (1,) if sql.startswith("SELECT 1") else (
                    current, *self.state["versions"][current])
            return
        if sql.startswith("SELECT q.entity_uuid"):
            qid, actor = params
            if "qv.preparation_stage = 'q0_draft'" not in sql or "qv.normalized_text IS NULL" not in sql:
                raise AssertionError("Q1 must select a current Q0 draft")
            if (actor == self.state["actor"] and qid == "Q" and self.state["current"]
                    and self.state["stage"] == "q0_draft"):
                self.result = (ENTITY, self.state["version_uuid"],
                               self.state["current"], self.state["original"])
            else:
                self.result = None
            return
        if sql.startswith("UPDATE core.entity_version SET"):
            if self.fail_at == "update":
                raise RuntimeError("simulated Q1 update failure")
            status, version, entity, expected, _ = params
            self.rowcount = int(entity == ENTITY and version == self.state["version_uuid"]
                                and expected == self.state["current"])
            if self.rowcount:
                if status != "superseded" or "valid_to = CURRENT_TIMESTAMP" not in sql:
                    raise AssertionError("expected closure of prior version")
                self.state["closed"][expected] = (version, status)
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
            self.state["stage"] = stage
            return
        if sql.startswith("INSERT INTO investigation.question_command_receipt"):
            if self.fail_at == "receipt":
                raise RuntimeError("simulated receipt failure")
            actor, request, fingerprint, entity, qid, version, number, kind, justification = params
            if (actor != "owner" or entity != ENTITY or qid != "Q"
                    or version != self.state["next_uuid"] or number != self.state["next_no"]
                    or kind != "PROPOSE_Q1" or not justification):
                raise AssertionError("invalid ledger receipt")
            self.state["receipts"].append((actor, request, fingerprint, qid, number, kind, justification))
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
        self.assertEqual(db.state["closed"], {1: (V1, "superseded")})
        self.assertEqual(db.state["stage"], "q1_proposed")
        self.assertEqual(db.state["receipts"], [("owner", "q1-a", "b" * 64, "Q", 2, "PROPOSE_Q1", "reason")])
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

    def test_q1_requires_lock_for_the_same_request(self):
        db = Q1Database()
        before = deepcopy(db.state)
        with self.assertRaisesRegex(PreparationHold, "transaction unavailable"):
            with InjectedQuestionSQLPort(db.factory).begin() as tx:
                tx.lock_request("owner", "different-request")
                tx.propose_q1(COMMAND, "owner")
        self.assertEqual(db.state, before)

    def test_authenticated_submission_replay_conflict_and_readback_use_existing_uow(self):
        db = Q1Database()
        uow = OfflineQuestionUnitOfWork(InjectedQuestionSQLPort(db.factory))
        user = self.authorized_user()
        with self.persisted_owner() as resolve:
            result = propose_authenticated_q1(user=user, command=COMMAND, unit_of_work=uow)
            self.assertEqual(result, {"status": "PREPARATORY_ONLY", "question_id": "Q", "version": 2})
            resolve.assert_called_with(user)
            committed = deepcopy(db.state)
            self.assertEqual(propose_authenticated_q1(user=user, command=COMMAND, unit_of_work=uow), result)
            with self.assertRaises(PreparationConflict):
                propose_authenticated_q1(user=user, command=replace(COMMAND, justification="changed"),
                                         unit_of_work=uow)
        self.assertEqual(db.state, committed)

    def test_stale_missing_foreign_and_non_q0_versions_do_not_write(self):
        for command, owner, stage in (
            (replace(COMMAND, expected_version=2), "owner", "q0_draft"),
            (replace(COMMAND, question_id="missing"), "owner", "q0_draft"),
            (COMMAND, "other-owner", "q0_draft"),
            (COMMAND, "owner", "legacy_complete"),
            (COMMAND, "owner", "q1_proposed"),
            (replace(COMMAND, original_text="Edited"), "owner", "q0_draft"),
        ):
            with self.subTest(command=command, owner=owner, stage=stage):
                db = Q1Database()
                db.state.update(actor=owner, stage=stage)
                before = deepcopy(db.state)
                uow = OfflineQuestionUnitOfWork(InjectedQuestionSQLPort(db.factory))
                user = self.authorized_user()
                with self.persisted_owner(), self.assertRaises(PreparationConflict):
                    propose_authenticated_q1(user=user, command=command, unit_of_work=uow)
                self.assertEqual(db.state, before)

    def test_failure_before_transaction_or_after_commit_does_not_retry(self):
        for failure in ("begin", "commit_ack"):
            with self.subTest(failure=failure):
                db = Q1Database()
                before = deepcopy(db.state)
                db.fail_at = failure
                uow = OfflineQuestionUnitOfWork(InjectedQuestionSQLPort(db.factory))
                user = self.authorized_user()
                with self.persisted_owner():
                    with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
                        propose_authenticated_q1(user=user, command=COMMAND, unit_of_work=uow)
                    self.assertEqual(db.attempts, 1)
                    if failure == "begin":
                        self.assertEqual(db.state, before)
                        continue
                    committed = deepcopy(db.state)
                    db.fail_at = None
                    receipt = review_authenticated_q1_offline(user=user, command=COMMAND, unit_of_work=uow)
                    self.assertEqual(receipt, Receipt("owner", "q1-a", command_fingerprint(COMMAND),
                                                      "Q", 2, "PROPOSE_Q1", "reason"))
                    self.assertEqual(db.attempts, 2)
                    self.assertEqual(db.state, committed)

    @staticmethod
    def authorized_user():
        return SimpleNamespace(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False,
                               has_perm=Mock(return_value=True))

    @staticmethod
    def persisted_owner():
        return patch("preparer_identity.resolver.persisted_preparer_actor_id", return_value="owner")


if __name__ == "__main__":
    unittest.main()
