"""Single end-to-end offline composition of existing PF-I03 A1→A2→A3 modules.

No network, database, HTTP mutation, real users, or scientific endorsement.
"""
from unittest.mock import Mock

from django.test import SimpleTestCase

from evidence.pf_i03_q0_offline import present_synthetic_q0
from evidence.pf_i03_q1_offline import present_synthetic_q1
from evidence.pf_i03_q2_routing_offline import Q2RoutingProposal, present_q2_routing_proposal
from evidence.question_preparation import QuestionCommand
from evidence.question_uow_offline import OfflineQuestionUnitOfWork
from evidence.tests.test_pf_i02_w1b_uow import FakePort


class PFI03ComposedOfflineFlowTests(SimpleTestCase):
    def test_real_composition_q0_q1_q2_routing_without_database(self):
        port = FakePort()
        uow = OfflineQuestionUnitOfWork(port)
        actor = Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=81)
        actor.has_perm.return_value = True
        question_id = "OES-SYNTH-Q0-COMPOSED"
        original = "Qual o efeito da intervenção sintética?"
        q0 = present_synthetic_q0(
            user=actor,
            command=QuestionCommand("compose-q0", question_id, 0, original),
            unit_of_work=uow,
        )
        self.assertEqual(q0["version"], 1)
        q1 = present_synthetic_q1(
            user=actor,
            command=QuestionCommand(
                "compose-q1", question_id, q0["version"], original,
                "Qual o efeito da intervenção sintética em adultos?",
                "Delimitar população sem substituir pergunta original.",
            ),
            unit_of_work=uow,
        )
        result = present_q2_routing_proposal(
            user=actor, q1_readback=q1,
            proposal=Q2RoutingProposal(
                question_id=question_id,
                q1_version=q1["version"],
                operational_question="Intervenção sintética modifica o desfecho?",
                population="Adultos sintéticos",
                exposure_or_intervention="Intervenção sintética",
                comparator="Controle sintético",
                outcomes=("Desfecho sintético",),
                methodological_class="INT",
                depth="N2",
                maintenance="M1",
                routing_justification="Proposta técnica sintética, sujeita a revisão.",
            ),
        )
        self.assertEqual(result["based_on_q1_version"], 2)
        self.assertEqual(result["original_text"], original)
        self.assertEqual(port.questions[question_id]["original_text"], original)
        self.assertEqual(port.questions[question_id]["version"], 2)
        self.assertEqual(len(port.receipts), 2)
        self.assertEqual(result["state"], "PROPOSED_OFFLINE_ONLY")
        self.assertEqual(result["scientific_review"], "NOT_PERFORMED")
        self.assertEqual(result["admissibility"], "NOT_DECIDED")
        self.assertEqual(result["investigation"], "NOT_OPENED")
        self.assertEqual(result["e9"], "BLOCKED")


class PFI03AuthenticatedQ0CompositionTests(SimpleTestCase):
    def test_authenticated_actor_id_reaches_transaction_receipt(self):
        from unittest.mock import patch
        from evidence.pf_i03_q0_offline import present_authenticated_synthetic_q0
        actor = Mock(is_authenticated=True, is_active=True, is_staff=False,
                     is_superuser=False, pk=81)
        actor.has_perm.return_value = True
        port = FakePort()
        command = QuestionCommand("auth-q0-1", "OES-SYNTH-Q0-AUTH", 0, "Pergunta Q0 sintética")
        with patch("preparer_identity.resolver.persisted_preparer_actor_id",
                   return_value="synthetic-stable-actor") as resolver:
            result = present_authenticated_synthetic_q0(
                user=actor, command=command, unit_of_work=OfflineQuestionUnitOfWork(port),
            )
        resolver.assert_called_once_with(actor)
        self.assertEqual(result["version"], 1)
        self.assertEqual(result["e9"], "BLOCKED")
        self.assertIn(("synthetic-stable-actor", "auth-q0-1"), port.receipts)

    def test_denied_user_never_resolves_identity_or_writes(self):
        from unittest.mock import patch
        from django.core.exceptions import PermissionDenied
        from evidence.pf_i03_q0_offline import present_authenticated_synthetic_q0
        actor = Mock(is_authenticated=True, is_active=True, is_staff=False,
                     is_superuser=False, pk=81)
        actor.has_perm.return_value = False
        port = FakePort()
        with patch("preparer_identity.resolver.persisted_preparer_actor_id") as resolver:
            with self.assertRaises(PermissionDenied):
                present_authenticated_synthetic_q0(
                    user=actor,
                    command=QuestionCommand("auth-denied", "OES-SYNTH-Q0-DENIED", 0, "Q0"),
                    unit_of_work=OfflineQuestionUnitOfWork(port),
                )
        resolver.assert_not_called()
        self.assertFalse(port.receipts)
