"""PF-I03-A1: integrated offline presentation, using the existing fake UoW."""
from unittest.mock import Mock
from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from django.urls import resolve, Resolver404
from evidence.question_preparation import QuestionCommand, PreparationHold, PreparationConflict
from evidence.question_uow_offline import OfflineQuestionUnitOfWork
from evidence.tests.test_pf_i02_w1b_uow import FakePort
from evidence.pf_i03_q0_offline import present_synthetic_q0


class PFI03OfflineFlowTests(SimpleTestCase):
    def setUp(self):
        self.port = FakePort()
        self.uow = OfflineQuestionUnitOfWork(self.port)
        self.user = Mock(is_authenticated=True, pk=33)
        self.user.has_perm.return_value = True
        self.command = QuestionCommand(
            "req-pfi03", "OES-SYNTH-Q0-PFI03", 0, "Pergunta sintética interna?"
        )

    def run_flow(self, user=None, command=None, unit_of_work=None):
        return present_synthetic_q0(
            user=user if user is not None else self.user,
            command=command if command is not None else self.command,
            unit_of_work=self.uow if unit_of_work is None else unit_of_work,
        )

    def test_q0_receipt_and_readback_are_preparatory_only(self):
        result = self.run_flow()
        self.assertEqual(result, {
            "question_id": self.command.question_id, "version": 1,
            "state": "PREPARATORY_ONLY", "scientific_review": "NOT_PERFORMED",
            "e9": "BLOCKED",
        })
        self.assertEqual(len(self.port.questions), 1)
        self.assertEqual(len(self.port.receipts), 1)

    def test_replay_is_idempotent_without_additional_receipt(self):
        self.assertEqual(self.run_flow(), self.run_flow())
        self.assertEqual(len(self.port.receipts), 1)

    def test_anonymous_and_unprivileged_are_denied(self):
        for authenticated, allowed in ((False, False), (True, False)):
            with self.subTest(authenticated=authenticated):
                self.user.is_authenticated = authenticated
                self.user.has_perm.return_value = allowed
                with self.assertRaises(PermissionDenied):
                    self.run_flow()
        self.assertFalse(self.port.questions)

    def test_invalid_or_non_synthetic_input_holds_without_writes(self):
        cases = (
            QuestionCommand("a", "OES-Q-REAL", 0, "Question"),
            QuestionCommand("a", "OES-SYNTH-Q0-X", 1, "Question"),
            QuestionCommand("a", "OES-SYNTH-Q0-X", 0, "Question", "normalized", "why"),
        )
        for command in cases:
            with self.subTest(command=command), self.assertRaises(PreparationHold):
                self.run_flow(command=command)
        self.assertFalse(self.port.questions)

    def test_request_collision_does_not_overwrite(self):
        self.run_flow()
        other = QuestionCommand(self.command.request_id, self.command.question_id, 0, "Changed")
        with self.assertRaises(PreparationConflict):
            self.run_flow(command=other)
        self.assertEqual(len(self.port.receipts), 1)

    def test_no_backend_fails_closed(self):
        with self.assertRaisesRegex(PreparationHold, "persistence unavailable"):
            present_synthetic_q0(user=self.user, command=self.command)

    def test_no_write_http_routes_or_e9(self):
        for path in ("/questions/", "/questions/new/", "/investigations/open/"):
            with self.subTest(path=path), self.assertRaises(Resolver404):
                resolve(path)
