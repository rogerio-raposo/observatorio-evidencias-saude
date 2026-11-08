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


class AuthenticatedQ1F1Tests(SimpleTestCase):
    """Same existing FakePort/UoW, now bound to persistent actor identity."""
    def setUp(self):
        from types import SimpleNamespace
        from uuid import UUID
        from unittest.mock import patch
        from evidence.question_preparation import submit_authenticated_question_command
        self.port = FakePort()
        self.uow = OfflineQuestionUnitOfWork(self.port)
        self.user = Mock(pk=41,is_authenticated=True,is_active=True,is_staff=False,is_superuser=False)
        self.user.has_perm.return_value = True
        self.actor = 'oes:actor:f1234567-89ab-4cde-8fab-123456789abc'
        self.lookup = self.enterContext(patch('preparer_identity.resolver.PreparerIdentity.objects.using'))
        self.lookup.return_value.get.return_value=SimpleNamespace(actor_uuid=UUID(self.actor.removeprefix('oes:actor:')))
        self.original = '  Original sintético imutável?\n'
        self.q0 = QuestionCommand('f1-q0','F1-Q1-question',0,self.original)
        submit_authenticated_question_command(user=self.user,command=self.q0,unit_of_work=self.uow)
        self.data = {'request_id':'f1-q1','question_id':self.q0.question_id,'expected_version':'1',
                     'original_text':self.original,'normalized_text':'  Proposta normalizada?\n','justification':'  Motivo sintético. '}

    def prepare(self,data=None,user=None,backend=True):
        from evidence.forms import prepare_q1_proposal
        return prepare_q1_proposal(user=self.user if user is None else user,data=self.data if data is None else data,
                                   unit_of_work=self.uow if backend else None)

    def test_end_to_end_persisted_actor_q1_receipt_and_preparatory_presentation(self):
        from evidence.forms import Q1ProposalForm
        from evidence.question_preparation import command_fingerprint
        status, context=self.prepare()
        self.assertEqual(status,200)
        proposal=context['proposal']
        self.assertEqual(proposal['version'],2)
        self.assertEqual(proposal['original_text'],self.original)
        self.assertEqual(proposal['proposed_normalized_text'],self.data['normalized_text'])
        self.assertEqual(proposal['justification'],self.data['justification'])
        self.assertEqual(proposal['state'],'PREPARATORY_ONLY')
        self.assertEqual(proposal['technical_evidence'],'OFFLINE_RECEIPT_VERIFIED')
        for key,value in (('scientific_review','NOT_PERFORMED'),('admissibility','NOT_DECIDED'),
                          ('investigation','NOT_OPENED'),('e9','BLOCKED'),('q2','NOT_EXECUTED'),('routing','NOT_AUTHORIZED')):
            self.assertEqual(proposal[key],value)
        receipt=self.port.receipts[(self.actor,self.data['request_id'])]
        self.assertEqual(receipt.command_kind,'PROPOSE_Q1')
        self.assertEqual(receipt.fingerprint,command_fingerprint(Q1ProposalForm(self.data).to_command()))
        self.assertEqual(receipt.justification,self.data['justification'])
        self.assertEqual(self.port.questions[self.q0.question_id]['original_text'],self.original)
        self.assertNotIn(('41',self.data['request_id']),self.port.receipts)
        self.lookup.return_value.get.assert_called_with(user_id=41)

    def test_replay_after_later_version_retains_original_receipt(self):
        first=self.prepare()
        self.assertEqual(first[0],200)
        second={**self.data,'request_id':'next-q1','expected_version':'2','normalized_text':'Segunda proposta'}
        self.assertEqual(self.prepare(second)[0],200)
        replay=self.prepare()
        self.assertEqual(replay[0],200)
        self.assertEqual(replay[1]['proposal'],first[1]['proposal'])
        self.assertEqual(len(self.port.receipts),3)
        self.assertEqual(self.port.questions[self.q0.question_id]['version'],3)

    def test_stale_original_and_fingerprint_conflicts_preserve_data(self):
        self.assertEqual(self.prepare()[0],200)
        for change in ({'normalized_text':'payload alterado'},
                       {'request_id':'stale-q1'},
                       {'request_id':'changed-original','expected_version':'2','original_text':'Original substituído'}):
            data={**self.data,**change}
            status,context=self.prepare(data)
            self.assertEqual(status,409)
            self.assertEqual(context['form'].data,data)
            self.assertNotIn('proposal',context)
        self.assertEqual(len(self.port.receipts),2)
        self.assertEqual(self.port.questions[self.q0.question_id]['original_text'],self.original)

    def test_other_actor_and_missing_question_are_denied_without_writes(self):
        from types import SimpleNamespace
        from uuid import UUID
        self.lookup.return_value.get.return_value=SimpleNamespace(actor_uuid=UUID('a1234567-89ab-4cde-8fab-123456789abc'))
        self.assertEqual(self.prepare()[0],409)
        self.assertEqual(self.prepare({**self.data,'question_id':'missing'})[0],409)
        self.assertEqual(len(self.port.receipts),1)
        self.assertEqual(self.port.questions[self.q0.question_id]['version'],1)

    def test_unauthorized_and_persistent_identity_missing(self):
        from preparer_identity.models import PreparerIdentity
        for field,value in (('is_authenticated',False),('is_active',False),('is_staff',True),('is_superuser',True)):
            old=getattr(self.user,field)
            setattr(self.user,field,value)
            self.assertEqual(self.prepare()[0],403)
            setattr(self.user,field,old)
        self.user.has_perm.return_value=False
        self.assertEqual(self.prepare()[0],403)
        self.user.has_perm.return_value=True
        self.lookup.return_value.get.side_effect=PreparerIdentity.DoesNotExist
        self.assertEqual(self.prepare()[0],503)
        self.assertEqual(len(self.port.receipts),1)

    def test_validation_rejects_q0_invalid_version_justification_and_forged_actor(self):
        from dataclasses import replace
        from evidence.forms import Q1ProposalForm
        from evidence.question_preparation import validate_propose_q1
        command=Q1ProposalForm(self.data).to_command()
        for change in ({'expected_version':'0'},{'expected_version':'-1'},{'expected_version':'1.5'},
                       {'justification':'   '},{'normalized_text':'\n'}, {'normalized_text':'a\x00b'},
                       {'original_text':' '},{'actor_id':'forged'},{'user_id':'42'},{'command_kind':'REGISTER_Q0'}):
            self.assertEqual(self.prepare({**self.data,**change})[0],400)
        for version in (False,True,0,-1,1.5,'1'):
            with self.assertRaises(PreparationHold):
                validate_propose_q1(replace(command,expected_version=version))
        with self.assertRaises(PreparationHold):
            validate_propose_q1(self.q0)
        self.assertEqual(len(self.port.receipts),1)

    def test_commit_failure_or_missing_backend_never_succeeds_or_retries(self):
        from unittest.mock import patch
        self.port.fail_commit=True
        with patch.object(self.uow,'execute',wraps=self.uow.execute) as execute:
            status,context=self.prepare()
            self.assertEqual(status,503)
            execute.assert_called_once()
            self.assertNotIn('proposal',context)
            self.assertEqual(context['form'].data,self.data)
        self.assertEqual(len(self.port.receipts),1)
        unavailable=self.prepare(backend=False)
        self.assertEqual(unavailable[0],503)
        self.assertEqual(unavailable[1]['outcome'],'UNAVAILABLE')
        self.assertEqual(context['outcome'],'INDETERMINATE')

    def test_preparatory_only_without_saved_receipt_does_not_prove_success(self):
        from unittest.mock import patch
        with patch.object(self.uow,'execute',return_value={'status':'PREPARATORY_ONLY','question_id':self.q0.question_id,'version':2}):
            status,context=self.prepare()
        self.assertEqual(status,503)
        self.assertNotIn('proposal',context)
        self.assertEqual(len(self.port.receipts),1)

    def test_receipt_tampering_and_readback_failure_fail_closed(self):
        from dataclasses import replace
        from unittest.mock import patch
        from evidence.question_preparation import propose_authenticated_q1
        from evidence.forms import Q1ProposalForm
        self.assertEqual(self.prepare()[0],200)
        key=(self.actor,self.data['request_id'])
        self.port.receipts[key]=replace(self.port.receipts[key],command_kind='REGISTER_Q0')
        self.assertEqual(self.prepare()[0],503)
        self.port.receipts[key]=replace(self.port.receipts[key],command_kind='PROPOSE_Q1')
        original_begin=self.port.begin
        calls=0
        def begin():
            nonlocal calls
            calls+=1
            if calls==2:
                raise TimeoutError('offline readback unavailable')
            return original_begin()
        with patch.object(self.port,'begin',side_effect=begin),patch.object(self.uow,'execute',wraps=self.uow.execute) as execute:
            self.assertEqual(self.prepare()[0],503)
            execute.assert_called_once()

    def test_http_mutations_423_before_body_user_or_backend(self):
        from unittest.mock import patch
        from evidence.views import q1_proposal
        class ForbiddenRequest:
            def __init__(self,method): self.method=method
            def __getattr__(self,name): raise AssertionError(name)
        for method in ('POST','PUT','PATCH','DELETE'):
            with patch('evidence.forms.prepare_q1_proposal',side_effect=AssertionError('adapter invoked')):
                self.assertEqual(q1_proposal(ForbiddenRequest(method)).status_code,423)
        self.assertEqual(resolve('/questions/q1/propose/').func,q1_proposal)

    def test_get_authenticated_form_disabled_and_offline_result_escaped(self):
        from django.test import RequestFactory
        from django.template.loader import render_to_string
        from evidence.views import q1_proposal
        request=RequestFactory().get('/questions/q1/propose/')
        request.user=self.user
        response=q1_proposal(request)
        self.assertEqual(response.status_code,200)
        self.assertIn('disabled',response.content.decode())
        status,context=self.prepare({**self.data,'normalized_text':'<script>offline</script>'})
        self.assertEqual(status,200)
        html=render_to_string('evidence/q1_proposal.html',context)
        self.assertIn('&lt;script&gt;',html)
        self.assertNotIn('<script>',html)
        self.assertIn('NOT_DECIDED',html)
        self.assertIn('Envio operacional bloqueado',html)

    def test_conflict_after_submission_and_receipt_readback_is_uncertain(self):
        from unittest.mock import patch
        from evidence.tests.test_pf_i02_w1b_uow import FakeTransaction
        calls=0
        original=FakeTransaction.find_receipt
        def lookup(tx,actor,request):
            nonlocal calls
            calls+=1
            if calls==2:
                raise PreparationConflict('offline conflicting readback')
            return original(tx,actor,request)
        with patch.object(FakeTransaction,'find_receipt',lookup):
            status,context=self.prepare()
        self.assertEqual(status,503)
        self.assertNotIn('proposal',context)
        self.assertEqual(len(self.port.receipts),2)

    def test_stored_identity_changed_during_attempt_does_not_present_success(self):
        from types import SimpleNamespace
        from uuid import UUID
        original=self.lookup.return_value.get.return_value
        changed=SimpleNamespace(actor_uuid=UUID('a1234567-89ab-4cde-8fab-123456789abc'))
        self.lookup.return_value.get.side_effect=[original,original,changed]
        self.assertEqual(self.prepare()[0],503)
        self.assertEqual(len(self.port.receipts),2)
