"""Dormant Q0 path integration tests: repository fake, no DB."""
from contextlib import contextmanager
from unittest.mock import Mock
from django.test import SimpleTestCase
from django.core.exceptions import PermissionDenied

from evidence.question_orm_q0_dormant import DormantQ0OrmPort
from evidence.question_preparation import PreparationHold, PreparationConflict, QuestionCommand, submit_question_command, command_fingerprint
from evidence.question_uow_offline import OfflineQuestionUnitOfWork, Receipt


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
        candidate = self.port.last_completed_q0
        self.assertEqual(candidate["actor_id"], "actor")
        self.assertEqual(candidate["request_id"], "r1")
        self.assertEqual(candidate["question_id"], "OES-Q-SYN")
        self.assertEqual(candidate["fingerprint"], "a" * 64)
        self.assertEqual(candidate["original_text"], "Pergunta sintética?")
        self.assertNotEqual(candidate["entity_uuid"], candidate["version_uuid"])
        args = self.port.readback_arguments(
            writer_alias="synthetic_writer", read_alias="synthetic_reader")
        self.assertEqual(args["entity_uuid"], candidate["entity_uuid"])
        self.assertEqual(args["request_id"], "r1")
        self.assertEqual(args["read_alias"], "synthetic_reader")
        with self.assertRaisesRegex(PreparationHold, "independent aliases"):
            self.port.readback_arguments(
                writer_alias="same", read_alias="same")

    def test_injected_readback_runs_after_boundary_and_fails_closed(self):
        def verifier(**kwargs):
            self.assertEqual(self.events, ["enter", "commit"])
            self.assertEqual(kwargs["writer_alias"], "writer")
            self.assertEqual(kwargs["read_alias"], "reader")
            return {"readback_verified": True}
        self.port.readback_verifier = verifier
        self.port.writer_alias = "writer"
        self.port.read_alias = "reader"
        self.run_q0()
        self.assertIsNotNone(self.port.last_completed_q0)

        self.port.readback_verifier = lambda **kwargs: {"readback_verified": False}
        with self.assertRaisesRegex(PreparationHold, "readback not verified"):
            self.run_q0()
        self.assertIsNone(self.port.last_completed_q0)

    def test_injected_readback_not_called_on_ledger_failure(self):
        verifier = Mock()
        self.port.readback_verifier = verifier
        self.port.writer_alias = "writer"
        self.port.read_alias = "reader"
        self.repo.insert_receipt.side_effect = RuntimeError("synthetic failure")
        with self.assertRaises(RuntimeError):
            self.run_q0()
        verifier.assert_not_called()

    def test_ledger_failure_rolls_back(self):
        self.repo.insert_receipt.side_effect = RuntimeError("synthetic receipt error")
        with self.assertRaises(RuntimeError):
            self.run_q0()
        self.assertEqual(self.events, ["enter", "rollback"])
        self.assertIsNone(self.port.last_completed_q0)
        with self.assertRaisesRegex(PreparationHold, "no new Q0 candidate"):
            self.port.readback_arguments(
                writer_alias="synthetic_writer", read_alias="synthetic_reader")

    def test_q1_remains_explicitly_blocked(self):
        with self.assertRaisesRegex(PreparationHold, "Q1 backend not implemented"):
            with self.port.begin() as tx:
                tx.lock_request("actor", "r1")
                tx.propose_q1(QuestionCommand("r1", "Q", 1, "Q0", "Q1", "because"), "actor")
        self.repo.insert_entity.assert_not_called()

    def test_idempotent_replay_uses_receipt_without_second_insert(self):
        self.repo.find_receipt.return_value = Receipt(
            "actor", "r1", "a" * 64, "OES-Q-SYN", 1, "REGISTER_Q0")
        self.repo.can_access_question.return_value = True
        result = self.run_q0()
        self.assertEqual(result, {"status": "PREPARATORY_ONLY",
                                  "question_id": "OES-Q-SYN", "version": 1})
        self.assertEqual(self.events, ["enter", "commit"])
        self.assertIsNone(self.port.last_completed_q0)
        for name in ("insert_entity", "insert_question", "insert_entity_version",
                     "insert_question_version", "insert_receipt"):
            getattr(self.repo, name).assert_not_called()

    def test_replay_with_conflicting_fingerprint_rolls_back(self):
        self.repo.find_receipt.return_value = Receipt(
            "actor", "r1", "b" * 64, "OES-Q-SYN", 1, "REGISTER_Q0")
        with self.assertRaises(PreparationConflict):
            self.run_q0()
        self.assertEqual(self.events, ["enter", "rollback"])
        self.repo.insert_entity.assert_not_called()

    def test_replay_without_current_access_rolls_back(self):
        self.repo.find_receipt.return_value = Receipt(
            "actor", "r1", "a" * 64, "OES-Q-SYN", 1, "REGISTER_Q0")
        self.repo.can_access_question.return_value = False
        with self.assertRaises(PreparationConflict):
            self.run_q0()
        self.assertEqual(self.events, ["enter", "rollback"])
        self.repo.insert_receipt.assert_not_called()

    def test_application_service_authorized_q0_invokes_single_transaction(self):
        user = Mock(is_authenticated=True, is_active=True, is_staff=False,
                    is_superuser=False, pk="synthetic-actor")
        user.has_perm.return_value = True
        command = QuestionCommand("app-r1", "OES-SYNTH-Q0-app", 0, "Pergunta sintética?")
        result = submit_question_command(
            user=user, command=command, unit_of_work=OfflineQuestionUnitOfWork(self.port))
        self.assertEqual(result, {"status": "PREPARATORY_ONLY",
                                  "question_id": command.question_id, "version": 1})
        user.has_perm.assert_called_with("evidence.prepare_question")
        self.repo.lock_request.assert_called_once_with("synthetic-actor", "app-r1")
        receipt = self.repo.insert_receipt.call_args.args[0]
        self.assertEqual(receipt.fingerprint, command_fingerprint(command))
        self.assertEqual(receipt.actor_id, "synthetic-actor")
        self.assertEqual(self.events, ["enter", "commit"])

    def test_application_service_denied_without_permission_before_transaction(self):
        user = Mock(is_authenticated=True, is_active=True, is_staff=False,
                    is_superuser=False, pk="synthetic-actor")
        user.has_perm.return_value = False
        command = QuestionCommand("app-r2", "OES-SYNTH-Q0-app", 0, "Pergunta sintética?")
        with self.assertRaises(PermissionDenied):
            submit_question_command(
                user=user, command=command, unit_of_work=OfflineQuestionUnitOfWork(self.port))
        self.assertEqual(self.events, [])
        self.repo.insert_entity.assert_not_called()

    def test_application_service_ledger_error_is_fail_closed(self):
        user = Mock(is_authenticated=True, is_active=True, is_staff=False,
                    is_superuser=False, pk="synthetic-actor")
        user.has_perm.return_value = True
        self.repo.insert_receipt.side_effect = RuntimeError("synthetic failure")
        command = QuestionCommand("app-r3", "OES-SYNTH-Q0-app", 0, "Pergunta sintética?")
        with self.assertRaisesRegex(PreparationHold, "outcome uncertain"):
            submit_question_command(
                user=user, command=command, unit_of_work=OfflineQuestionUnitOfWork(self.port))
        self.assertEqual(self.events, ["enter", "rollback"])
