"""PF-I03-A3: offline Q2 and routing proposal controls."""
from dataclasses import replace
from unittest.mock import Mock
from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from django.urls import resolve, Resolver404
from evidence.pf_i03_q2_routing_offline import Q2RoutingProposal, present_q2_routing_proposal
from evidence.question_preparation import PreparationHold


class PFI03Q2RoutingTests(SimpleTestCase):
    def setUp(self):
        self.user = Mock(is_authenticated=True, pk=12)
        self.user.has_perm.return_value = True
        self.q1 = {
            "question_id": "OES-SYNTH-Q0-PFI03-A3", "version": 2,
            "original_text": "Pergunta original?", "proposed_normalized_text": "Pergunta Q1?",
            "justification": "Normalização", "state": "PREPARATORY_ONLY",
            "scientific_review": "NOT_PERFORMED", "q2": "NOT_EXECUTED",
            "routing": "NOT_AUTHORIZED", "e9": "BLOCKED",
        }
        self.proposal = Q2RoutingProposal(
            self.q1["question_id"], 2, "Intervenção funciona?", "Adultos",
            "Intervenção sintética", "Controle", ("Resultado sintético",),
            "INT", "N2", "M1", "Profundidade provisória por escopo de intervenção",
        )

    def present(self, proposal=None, q1=None, user=None):
        return present_q2_routing_proposal(
            user=self.user if user is None else user,
            q1_readback=self.q1 if q1 is None else q1,
            proposal=self.proposal if proposal is None else proposal,
        )

    def test_projection_preserves_q0_q1_and_blocked_states(self):
        result = self.present()
        self.assertEqual(result["based_on_q1_version"], 2)
        self.assertEqual(result["original_text"], self.q1["original_text"])
        self.assertEqual(result["normalized_text"], self.q1["proposed_normalized_text"])
        self.assertEqual(result["methodological_class"], "INT")
        self.assertEqual(result["state"], "PROPOSED_OFFLINE_ONLY")
        self.assertEqual(result["admissibility"], "NOT_DECIDED")
        self.assertEqual(result["investigation"], "NOT_OPENED")
        self.assertEqual(result["e9"], "BLOCKED")

    def test_unauthorized_denied(self):
        for authenticated, allowed in ((False, False), (True, False)):
            with self.subTest(authenticated=authenticated):
                user = Mock(is_authenticated=authenticated)
                user.has_perm.return_value = allowed
                with self.assertRaises(PermissionDenied):
                    self.present(user=user)

    def test_version_mismatch_rejected(self):
        with self.assertRaises(PreparationHold):
            self.present(proposal=replace(self.proposal, q1_version=3))

    def test_identity_mismatch_and_nonsynthetic_rejected(self):
        for identity in ("OES-SYNTH-Q0-OTHER", "OES-Q-REAL"):
            with self.subTest(identity=identity), self.assertRaises(PreparationHold):
                self.present(proposal=replace(self.proposal, question_id=identity))

    def test_untrusted_q1_boundary_rejected(self):
        for key, value in (("e9", "OPEN"), ("state", "APPROVED"),
                           ("scientific_review", "PERFORMED")):
            with self.subTest(key=key), self.assertRaises(PreparationHold):
                self.present(q1={**self.q1, key: value})

    def test_invalid_routing_choices_rejected(self):
        for field, value in (("methodological_class", "OTHER"), ("depth", "N5"),
                             ("maintenance", "M4")):
            with self.subTest(field=field), self.assertRaises(PreparationHold):
                self.present(proposal=replace(self.proposal, **{field: value}))

    def test_incomplete_methodological_content_rejected(self):
        for field, value in (("operational_question", " "), ("outcomes", ()),
                             ("routing_justification", "")):
            with self.subTest(field=field), self.assertRaises(PreparationHold):
                self.present(proposal=replace(self.proposal, **{field: value}))

    def test_no_mutating_routes(self):
        for path in ("/questions/new/", "/questions/", "/investigations/open/"):
            with self.subTest(path=path), self.assertRaises(Resolver404):
                resolve(path)
