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
        self.user = Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=12)
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


class AuthenticatedQ2R1Tests(SimpleTestCase):
    """Authenticated integration only; reuse Q1-F1's port/identity fixture."""
    def setUp(self):
        from evidence.tests.test_pf_i03_q1_offline import AuthenticatedQ1F1Tests
        from evidence.question_preparation import QuestionCommand, submit_authenticated_question_command
        from evidence.pf_i03_q1_offline import present_authenticated_q1
        self.f=AuthenticatedQ1F1Tests()
        self.f.setUp()
        self.addCleanup(self.f.doCleanups)
        self.user=self.f.user
        self.port=self.f.port
        self.uow=self.f.uow
        self.q0=QuestionCommand('q2-r1-q0','OES-SYNTH-Q0-Q2-R1',0,'  Original sintético Q0?\n')
        submit_authenticated_question_command(user=self.user,command=self.q0,unit_of_work=self.uow)
        self.q1=QuestionCommand('q2-r1-q1',self.q0.question_id,1,self.q0.original_text,'  Texto Q1 sintético?\n','  Justificativa Q1 literal. ')
        self.q1_presentation=present_authenticated_q1(user=self.user,command=self.q1,unit_of_work=self.uow)
        self.data={'request_id':self.q1.request_id,'question_id':self.q1.question_id,'q1_version':'2',
                   'original_text':self.q1.original_text,'normalized_text':self.q1.normalized_text,'justification':self.q1.justification,
                   'operational_question':'Pergunta operacional sintética?', 'population':'População sintética',
                   'exposure_or_intervention':'Intervenção fictícia','comparator':'Controle fictício',
                   'outcomes':'Desfecho sintético A\nDesfecho sintético B','methodological_class':'INT',
                   'depth':'N2','maintenance':'M1','routing_justification':'Proposta técnica sintética, sem avaliação científica.'}

    def prepare(self,data=None,user=None,backend=True):
        from evidence.forms import prepare_q2_routing
        return prepare_q2_routing(user=self.user if user is None else user,data=self.data if data is None else data,
                                  unit_of_work=self.uow if backend else None)

    def test_q0_q1_q2_routing_preserves_texts_provenance_without_persistence_or_replay(self):
        from copy import deepcopy
        from unittest.mock import patch
        from evidence.question_preparation import command_fingerprint
        before=(deepcopy(self.port.questions),deepcopy(self.port.receipts))
        with patch.object(self.uow,'execute',side_effect=AssertionError('Q1 resubmitted')) as execute:
            status,context=self.prepare()
            self.assertEqual(status,200)
            execute.assert_not_called()
        result=context['proposal']
        self.assertEqual(result['original_text'],self.q0.original_text)
        self.assertEqual(result['normalized_text'],self.q1.normalized_text)
        self.assertEqual(result['based_on_q1_version'],2)
        self.assertEqual(result['outcomes'],('Desfecho sintético A','Desfecho sintético B'))
        self.assertEqual(result['provenance'],{'source':'OFFLINE_Q1_RECEIPT_VERIFIED','actor_id':self.f.actor,
            'request_id':self.q1.request_id,'question_id':self.q1.question_id,'q1_version':2,
            'fingerprint':command_fingerprint(self.q1),'command_kind':'PROPOSE_Q1'})
        for key,value in (('state','PROPOSED_OFFLINE_ONLY'),('admissibility','NOT_DECIDED'),
                          ('scientific_review','NOT_PERFORMED'),('investigation','NOT_OPENED'),
                          ('e9','BLOCKED'),('certainty','NOT_ASSESSED')):
            self.assertEqual(result[key],value)
        self.assertEqual(before,(self.port.questions,self.port.receipts))
        self.assertEqual(self.port.questions[self.q1.question_id]['version'],2)

    def test_q1_f1_adaptation_is_verified_internally_not_dictionary_trimming(self):
        from evidence.forms import Q2RoutingForm
        from evidence.pf_i03_q2_routing_offline import present_authenticated_q2_routing
        proposal=Q2RoutingForm(self.data).to_proposal()
        # Q1-F1 adds boundary/evidence fields; legacy accepts exactly its older shape.
        self.assertIn('technical_evidence',self.q1_presentation)
        with self.assertRaises(PreparationHold):
            present_q2_routing_proposal(user=self.user,q1_readback=self.q1_presentation,proposal=proposal)
        result=present_authenticated_q2_routing(user=self.user,q1_command=self.q1,proposal=proposal,unit_of_work=self.uow)
        self.assertEqual(result['provenance']['source'],'OFFLINE_Q1_RECEIPT_VERIFIED')
        del self.port.receipts[(self.f.actor,self.q1.request_id)]
        self.assertEqual(self.prepare()[0],503)
        # A presentation dict or a claimed actor supplied by the client cannot replace it.
        for key in ('q1_readback','actor_id','provenance'):
            self.assertEqual(self.prepare({**self.data,key:'forged'})[0],400)

    def test_reference_version_identifier_original_and_q1_payload_must_match(self):
        for change in ({'q1_version':'3'},{'question_id':'OES-SYNTH-Q0-OTHER'},
                       {'request_id':'missing-q1'}, {'original_text':'Original adulterado'},
                       {'normalized_text':'Q1 adulterado'}, {'justification':'Justificativa alterada'}):
            data={**self.data,**change}
            status,context=self.prepare(data)
            self.assertEqual(status,503)
            self.assertEqual(context['form'].data,data)
            self.assertNotIn('proposal',context)

    def test_other_owner_is_denied_and_cannot_read_existing_receipt(self):
        from types import SimpleNamespace
        from uuid import UUID
        other=Mock(pk=42,is_authenticated=True,is_active=True,is_staff=False,is_superuser=False)
        other.has_perm.return_value=True
        binding=self.f.lookup.return_value.get.return_value
        def lookup(*,user_id):
            return binding if user_id==41 else SimpleNamespace(actor_uuid=UUID('a1234567-89ab-4cde-8fab-123456789abc'))
        self.f.lookup.return_value.get.side_effect=lookup
        status,context=self.prepare(user=other)
        self.assertEqual(status,503)
        self.assertNotIn('proposal',context)
        self.assertNotIn(self.f.actor,context['result_message'])
        self.assertEqual(self.prepare()[0],200)

    def test_permission_and_persisted_actor_are_mandatory(self):
        from preparer_identity.models import PreparerIdentity
        for field,value in (('is_authenticated',False),('is_active',False),('is_staff',True),('is_superuser',True)):
            old=getattr(self.user,field)
            setattr(self.user,field,value)
            self.assertEqual(self.prepare()[0],403)
            setattr(self.user,field,old)
        self.user.has_perm.return_value=False
        self.assertEqual(self.prepare()[0],403)
        self.user.has_perm.return_value=True
        self.f.lookup.return_value.get.side_effect=PreparerIdentity.DoesNotExist
        self.assertEqual(self.prepare()[0],503)

    def test_form_methodological_choices_and_incomplete_content_fail_before_backend(self):
        from unittest.mock import patch
        for change in ({'depth':'N5'},{'maintenance':'M4'},{'methodological_class':'OTHER'},
                       {'operational_question':' '},{'population':''},{'exposure_or_intervention':' '},
                       {'comparator':''},{'outcomes':'one\n\nthree'}, {'outcomes':' '},
                       {'routing_justification':''},{'q1_version':'1'},{'question_id':'F1-Q1-question'}):
            with patch.object(self.port,'begin',side_effect=AssertionError('invalid form accessed port')):
                self.assertEqual(self.prepare({**self.data,**change})[0],400)

    def test_missing_or_unavailable_provenance_is_fail_closed_without_new_records(self):
        from copy import deepcopy
        from unittest.mock import patch
        before=deepcopy(self.port.receipts)
        self.assertEqual(self.prepare(backend=False)[0],503)
        with patch.object(self.port,'begin',side_effect=TimeoutError('offline unavailable')):
            status,context=self.prepare()
            self.assertEqual(status,503)
            self.assertNotIn('proposal',context)
        self.assertEqual(self.port.receipts,before)

    def test_tampered_receipt_or_current_q1_text_is_not_provenance(self):
        key=(self.f.actor,self.q1.request_id)
        receipt=self.port.receipts[key]
        for change in ({'actor_id':'other'},{'command_kind':'REGISTER_Q0'},{'version':3},{'fingerprint':'0'*64}):
            self.port.receipts[key]=replace(receipt,**change)
            self.assertEqual(self.prepare()[0],503)
        self.port.receipts[key]=receipt
        self.port.questions[self.q1.question_id]['normalized_text']='contradictory stored Q1'
        self.assertEqual(self.prepare()[0],503)

    def test_latest_and_historical_q1_versions_have_explicit_receipt_provenance(self):
        from dataclasses import replace
        from evidence.pf_i03_q1_offline import present_authenticated_q1
        newer=replace(self.q1,request_id='q2-r1-later-q1',expected_version=2,normalized_text='Proposta Q1 posterior')
        present_authenticated_q1(user=self.user,command=newer,unit_of_work=self.uow)
        status,context=self.prepare()
        self.assertEqual(status,200)
        self.assertEqual(context['proposal']['based_on_q1_version'],2)
        self.assertEqual(context['proposal']['normalized_text'],self.q1.normalized_text)
        self.assertEqual(self.port.questions[self.q1.question_id]['version'],3)

    def test_http_mutations_stop_before_request_data_or_backend(self):
        from unittest.mock import patch
        from evidence.views import q2_routing
        class ForbiddenRequest:
            def __init__(self,method): self.method=method
            def __getattr__(self,name): raise AssertionError(name)
        for method in ('POST','PUT','PATCH','DELETE'):
            with patch('evidence.forms.prepare_q2_routing',side_effect=AssertionError('adapter invoked')):
                self.assertEqual(q2_routing(ForbiddenRequest(method)).status_code,423)
        self.assertEqual(resolve('/questions/q2/routing/').func,q2_routing)

    def test_get_form_and_preparatory_template_expose_limits_with_escaped_text(self):
        from django.test import RequestFactory
        from django.template.loader import render_to_string
        from evidence.views import q2_routing
        request=RequestFactory().get('/questions/q2/routing/')
        request.user=self.user
        response=q2_routing(request)
        self.assertEqual(response.status_code,200)
        self.assertIn('disabled',response.content.decode())
        status,context=self.prepare({**self.data,'operational_question':'<script>synthetic</script>'})
        self.assertEqual(status,200)
        html=render_to_string('evidence/q2_routing.html',context)
        for marker in ('PROPOSED_OFFLINE_ONLY','NOT_DECIDED','NOT_PERFORMED','NOT_OPENED','BLOCKED',
                       'NOT_ASSESSED','OFFLINE_Q1_RECEIPT_VERIFIED','não determinam'):
            # The explanatory text starts its sentence with a capital letter.
            self.assertIn(marker.lower(),html.lower())
        self.assertIn('&lt;script&gt;',html)
        self.assertNotIn('<script>',html)

    def test_actor_change_during_reference_lookup_cannot_return_proposal(self):
        from types import SimpleNamespace
        from uuid import UUID
        binding=self.f.lookup.return_value.get.return_value
        other=SimpleNamespace(actor_uuid=UUID('a1234567-89ab-4cde-8fab-123456789abc'))
        self.f.lookup.return_value.get.side_effect=[binding,other]
        status,context=self.prepare()
        self.assertEqual(status,503)
        self.assertNotIn('proposal',context)
