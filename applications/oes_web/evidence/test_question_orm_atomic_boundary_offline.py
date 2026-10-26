"""Offline atomic-boundary integration; mocks only, no Django DB."""
from contextlib import contextmanager
from unittest.mock import Mock

from django.test import SimpleTestCase
from evidence.question_orm_atomic_boundary_offline import OfflineDjangoAtomicPort
from evidence.question_uow_offline import OfflineQuestionUnitOfWork
from evidence.question_preparation import QuestionCommand, PreparationHold


class OfflineAtomicBoundaryTests(SimpleTestCase):
    def setUp(self):
        self.events = []
        self.tx = Mock()
        self.tx.find_receipt.return_value = None
        self.tx.current_question.return_value = None
        self.command = QuestionCommand("req-synthetic", "OES-Q-SYN", 0, "Pergunta?")

        @contextmanager
        def atomic_fake():
            self.events.append("atomic_enter")
            try:
                yield
            except BaseException:
                self.events.append("atomic_rollback")
                raise
            else:
                self.events.append("atomic_commit")

        @contextmanager
        def transaction_fake():
            self.events.append("tx_enter")
            try:
                yield self.tx
            finally:
                self.events.append("tx_exit")

        self.port = OfflineDjangoAtomicPort(
            atomic_factory=atomic_fake, transaction_factory=transaction_fake)

    def execute(self):
        return OfflineQuestionUnitOfWork(self.port).execute(
            command=self.command, actor_id="actor", fingerprint="f" * 64)

    def test_no_default_writer_factory_fail_closed(self):
        with self.assertRaisesRegex(PreparationHold, "unavailable"):
            OfflineDjangoAtomicPort()

    def test_q0_receipt_and_atomic_success(self):
        receipt = self.execute()
        self.assertEqual(receipt["version"], 1)
        self.tx.register_q0.assert_called_once()
        self.tx.save_receipt.assert_called_once()
        self.assertEqual(self.events, [
            "atomic_enter", "tx_enter", "tx_exit", "atomic_commit"])

    def test_receipt_failure_rolls_back(self):
        self.tx.save_receipt.side_effect = RuntimeError("synthetic failure")
        with self.assertRaisesRegex(RuntimeError, "synthetic failure"):
            self.execute()
        self.assertEqual(self.events, [
            "atomic_enter", "tx_enter", "tx_exit", "atomic_rollback"])

    def test_existing_receipt_replay_no_write(self):
        prior = Mock(actor_id="actor", request_id="req-synthetic",
                     fingerprint="f" * 64, question_id="OES-Q-SYN", version=1)
        self.tx.find_receipt.return_value = prior
        self.tx.can_access_question.return_value = True
        result = self.execute()
        self.assertEqual(result["version"], 1)
        self.tx.register_q0.assert_not_called()
        self.tx.save_receipt.assert_not_called()
        self.assertEqual(self.events[-1], "atomic_commit")
