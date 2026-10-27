"""PF-I03-A2: offline Q0→Q1 integration and deny-by-default checks."""
from unittest.mock import Mock
from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from django.urls import Resolver404, resolve

from evidence.pf_i03_q0_offline import present_synthetic_q0
from evidence.pf_i03_q1_offline import present_synthetic_q1
from evidence.question_preparation import QuestionCommand, PreparationHold, PreparationConflict
from evidence.question_uow_offline import OfflineQuestionUnitOfWork
from evidence.tests.test_pf_i02_w1b_uow import FakePort


class PFI03Q1OfflineTests(SimpleTestCase):
    def setUp(self):
        self.port = FakePort()
        self.uow = OfflineQuestionUnitOfWork(self.port)
        self.user = Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=41)
        self.user.has_perm.return_value = True
        self.q0 = QuestionCommand("a1", "OES-SYNTH-Q0-PFI03-A2", 0, "Original sintético?")
        self.q1 = QuestionCommand(
            "a2", self.q0.question_id, 1, self.q0.original_text,
            "Pergunta proposta normalizada?", "Justificativa sintética",
        )

    def prepare(self):
        return present_synthetic_q0(user=self.user, command=self.q0, unit_of_work=self.uow)

    def propose(self, command=None, user=None):
        return present_synthetic_q1(
            user=self.user if user is None else user,
            command=self.q1 if command is None else command, unit_of_work=self.uow,
        )

    def test_version_two_original_preserved_and_boundaries_visible(self):
        self.prepare()
        result = self.propose()
        self.assertEqual(result["version"], 2)
        self.assertEqual(result["original_text"], self.q0.original_text)
        self.assertEqual(result["proposed_normalized_text"], self.q1.normalized_text)
        self.assertEqual(result["justification"], self.q1.justification)
        self.assertEqual(result["state"], "PREPARATORY_ONLY")
        self.assertEqual(result["q2"], "NOT_EXECUTED")
        self.assertEqual(result["routing"], "NOT_AUTHORIZED")
        self.assertEqual(result["e9"], "BLOCKED")
        self.assertEqual(self.port.questions[self.q0.question_id]["original_text"], self.q0.original_text)
        self.assertEqual(self.port.questions[self.q0.question_id]["version"], 2)
        self.assertEqual(len(self.port.receipts), 2)

    def test_q1_without_q0_holds(self):
        with self.assertRaises(PreparationConflict):
            self.propose()
        self.assertFalse(self.port.questions)

    def test_replay_keeps_same_version_and_receipt(self):
        self.prepare()
        self.assertEqual(self.propose(), self.propose())
        self.assertEqual(len(self.port.receipts), 2)

    def test_stale_version_conflicts(self):
        self.prepare()
        self.propose()
        stale = QuestionCommand("a3", self.q0.question_id, 1, self.q0.original_text,
                                "Outra normalização", "Justificativa")
        with self.assertRaises(PreparationConflict):
            self.propose(command=stale)

    def test_changed_original_conflicts(self):
        self.prepare()
        altered = QuestionCommand("a3", self.q0.question_id, 1, "Original alterado",
                                  "Nova versão", "Justificativa")
        with self.assertRaises(PreparationConflict):
            self.propose(command=altered)

    def test_anonymous_unprivileged_and_wrong_owner_denied(self):
        self.prepare()
        anonymous = Mock(is_authenticated=False, pk=None)
        other = Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=42)
        other.has_perm.return_value = True
        with self.assertRaises(PermissionDenied):
            self.propose(user=anonymous)
        self.user.has_perm.return_value = False
        with self.assertRaises(PermissionDenied):
            self.propose()
        self.user.has_perm.return_value = True
        with self.assertRaises(PreparationConflict):
            self.propose(user=other)

    def test_missing_justification_non_synthetic_and_no_backend_hold(self):
        self.prepare()
        for c in (
            QuestionCommand("a3", self.q0.question_id, 1, self.q0.original_text, "Q1", ""),
            QuestionCommand("a3", "OES-REAL", 1, self.q0.original_text, "Q1", "Why"),
            QuestionCommand("a3", self.q0.question_id, 0, self.q0.original_text, "Q1", "Why"),
        ):
            with self.subTest(c=c), self.assertRaises(PreparationHold):
                self.propose(command=c)
        with self.assertRaisesRegex(PreparationHold, "persistence unavailable"):
            present_synthetic_q1(user=self.user, command=self.q1)
        self.assertEqual(len(self.port.receipts), 1)

    def test_no_mutating_http_route(self):
        for path in ("/questions/new/", "/questions/", "/investigations/open/"):
            with self.subTest(path=path), self.assertRaises(Resolver404):
                resolve(path)
