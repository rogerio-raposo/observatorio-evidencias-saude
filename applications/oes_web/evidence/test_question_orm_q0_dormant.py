"""Dormant Q0 path integration tests: repository fake, no DB."""
from contextlib import contextmanager
from unittest.mock import Mock
from django.test import SimpleTestCase

from evidence.question_orm_q0_dormant import DormantQ0OrmPort
from evidence.question_preparation import PreparationHold, QuestionCommand
from evidence.question_uow_offline import OfflineQuestionUnitOfWork


class DormantQ0Tests(SimpleTestCase):
    def setUp(self):
        self.repo = Mock()
        self.repo.find_receipt.return_value = None
        self.repo.current_question.return_value = None
        self.events = []

        @contextmanager
        def fake_atomic():
            self.events.append("enter")
            try:
                yield
            except BaseException:
                self.events.append("rollback")
                raise
            else:
                self.events.append("commit")

        @contextmanager
        def fake_repository():
            yield self.repo

        self.port = DormantQ0OrmPort(
            atomic_factory=fake_atomic, repository_factory=fake_repository)

    def run_q0(self):
        return OfflineQuestionUnitOfWork(self.port).execute(
            command=QuestionCommand("r1", "OES-Q-SYN", 0, "Pergunta sintética?"),
            actor_id="actor", fingerprint="a" * 64)

    def test_missing_configuration_fail_closed(self):
        with self.assertRaises(PreparationHold):
            DormantQ0OrmPort()

    def test_q0_four_writes_plus_receipt_single_boundary(self):
        result = self.run_q0()
        self.assertEqual(result["version"], 1)
        for name in ("insert_entity", "insert_question", "insert_entity_version",
                     "insert_question_version", "insert_receipt"):
            getattr(self.repo, name).assert_called_once()
        self.assertEqual(self.events, ["enter", "commit"])

    def test_ledger_failure_rolls_back(self):
        self.repo.insert_receipt.side_effect = RuntimeError("synthetic receipt error")
        with self.assertRaises(RuntimeError):
            self.run_q0()
        self.assertEqual(self.events, ["enter", "rollback"])

    def test_q1_remains_explicitly_blocked(self):
        with self.assertRaisesRegex(PreparationHold, "Q1 backend not implemented"):
            with self.port.begin() as tx:
                tx.lock_request("actor", "r1")
                tx.propose_q1(QuestionCommand("r1", "Q", 1, "Q0", "Q1", "because"), "actor")
        self.repo.insert_entity.assert_not_called()
