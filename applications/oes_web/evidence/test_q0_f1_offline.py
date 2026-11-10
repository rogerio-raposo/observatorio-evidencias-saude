"""F1 functional boundaries, reusing D3 session/model fakes, never PostgreSQL."""
from dataclasses import replace
from types import SimpleNamespace
from unittest.mock import patch
from django.test import SimpleTestCase, RequestFactory
from django.core.exceptions import PermissionDenied
from evidence import test_q0_persistence_d3_offline as d3
from evidence import question_orm_q0_repository_dormant as repo
from evidence.forms import prepare_q0_submission, prepare_q0_recovery, Q0RegistrationForm
from evidence.question_preparation import PreparationHold, PreparationConflict, command_fingerprint
from evidence.views import q0_registration, _prepare_q0_registration_response
from preparer_identity.models import PreparerIdentity

R='evidence.question_orm_q0_repository_dormant.'
E=d3.E
C=d3.C

class Q0F1Tests(SimpleTestCase):
    def setUp(self):
        self.f=d3.EvidenceD3Tests()
        self.f.setUp()
        self.addCleanup(self.f.doCleanups)
        self.data={'request_id':'f1-request-one','question_id':'F1-question-one','original_text':'  Synthetic original?\n'}
        self.write_gate=repo._require_q0_application_write_activation
        self.activate=self.enterContext(patch(R+'_require_q0_application_write_activation'))
        self.enterContext(patch('django.db.connections',self.f.connections))
        for name,model in self.f.models.items():
            self.enterContext(patch(R+name,model))
        self.enterContext(patch.object(repo.DjangoQ0Repository,'find_receipt',side_effect=self.f.repo.find_receipt))
        self.enterContext(patch.object(repo.DjangoQ0Repository,'current_question',side_effect=self.f.repo.current_question))
        self.enterContext(patch.object(repo.DjangoQ0Repository,'can_access_question',return_value=True))
        original=repo.DjangoQ0Repository.insert_receipt
        def save(instance,receipt,e,v):
            self.f.record.question_entity_uuid=e
            self.f.record.resulting_version_uuid=v
            return original(instance,receipt,e,v)
        self.enterContext(patch.object(repo.DjangoQ0Repository,'insert_receipt',autospec=True,side_effect=save))
        self.configure(self.data)

    def configure(self,data):
        self.f.command=Q0RegistrationForm(data).to_command()
        from evidence.question_orm_q0_evidence_dormant import _expected_receipt
        self.f.expected=_expected_receipt(self.f.command,self.f.actor)
        self.f.record.request_id=self.f.command.request_id
        self.f.record.question_id=self.f.command.question_id
        self.f.record.fingerprint_sha256=command_fingerprint(self.f.command)

    def test_two_distinct_commands_traverse_real_uow_repository_and_d3(self):
        for data in (self.data,{**self.data,'request_id':'f1-request-two','question_id':'F1-question-two','original_text':'Outro texto sintético.'}):
            self.configure(data)
            status,context=prepare_q0_submission(user=self.f.user,data=data)
            self.assertEqual(status,200,context.get('result_message'))
            self.assertEqual(context['form'].to_command(),self.f.command)
            self.assertIsNone(repo._trial_scope.get())
            calls=self.f.models['OesQuestionVersion'].objects.using.return_value.create.call_args
            self.assertEqual(calls.kwargs['original_text'],data['original_text'])
            self.assertEqual(calls.kwargs['preparation_stage'],'q0_draft')
            self.assertEqual(self.f.lookup_receipt.call_args.kwargs,{'actor_id':self.f.actor,'request_id':data['request_id']})
        for model in self.f.models.values():
            self.assertEqual(model.objects.using.return_value.create.call_count,2)
        sql=[sql for alias,sql in self.f.events if alias=='oes_q0_writer']
        self.assertTrue(any('pg_current_xact_id' in text for text in sql))

    def test_replay_and_proven_preinsert_conflicts(self):
        self.f.repo.find_receipt.return_value=self.f.expected
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],200)
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_not_called()
        self.f.repo.find_receipt.return_value=replace(self.f.expected,fingerprint='0'*64)
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],409)
        self.f.repo.find_receipt.return_value=None
        self.f.repo.current_question.return_value={'version':1,'original_text':'existing'}
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],409)
        for model in self.f.models.values():
            model.objects.using.return_value.create.assert_not_called()

    def test_permission_identity_and_browser_actor_rejected(self):
        self.f.user.has_perm.return_value=False
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],403)
        self.f.user.has_perm.return_value=True
        self.f.identity_lookup.return_value.get.side_effect=PreparerIdentity.DoesNotExist
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],503)
        self.assertEqual(prepare_q0_submission(user=self.f.user,data={**self.data,'actor_id':'forged'})[0],400)
        self.f.writer.cursor.assert_not_called()

    def test_invalid_input_and_bound_form_preserve_fields(self):
        data={**self.data,'original_text':'   '}
        status,context=prepare_q0_submission(user=self.f.user,data=data)
        self.assertEqual(status,400)
        self.assertEqual(dict(context['form'].data),data)
        self.f.writer.cursor.assert_not_called()

    def test_uncertain_commit_or_readback_never_retries(self):
        self.f.reader_unavailable=True
        status,context=prepare_q0_submission(user=self.f.user,data=self.data)
        self.assertEqual(status,503)
        self.assertNotIn('confirmed_question_id',context)
        self.assertEqual(context['form'].data,self.data)
        self.assertIsNone(repo._trial_scope.get())
        self.assertLessEqual(self.f.models['OesEntity'].objects.using.return_value.create.call_count,1)

    def test_preparatory_only_or_exception_observation_cannot_present_success(self):
        result={'status':'PREPARATORY_ONLY','question_id':self.data['question_id'],'version':1}
        with patch('evidence.question_preparation.register_authenticated_q0',return_value=result):
            self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],503)
        error=PreparationHold('offline')
        error.q0_observation={'outcome':'PERSISTED','scope':'Q0_RECORDS','automatic_retry':False}
        with patch('evidence.question_preparation.register_authenticated_q0',side_effect=error):
            self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],503)
        self.assertIsNone(repo._trial_scope.get())

    def test_application_scope_expires_on_exception_and_identity_cannot_change(self):
        with self.assertRaises(ValueError):
            with repo._application_q0_scope(user=self.f.user,command=self.f.command) as scope:
                with self.assertRaises(PreparationHold):
                    repo._require_restricted_q0_construction(user=self.f.user,command=replace(self.f.command,request_id='other'))
                raise ValueError('offline')
        self.assertFalse(scope.active)
        self.assertIsNone(repo._trial_scope.get())

    def test_real_http_stays_423_and_prepared_response_renders_preserved_values(self):
        request=RequestFactory().post('/questions/q0/register/',self.data)
        request.user=self.f.user
        with patch('evidence.forms.prepare_q0_submission',side_effect=AssertionError('POST entered adapter')):
            self.assertEqual(q0_registration(request).status_code,423)
        response=_prepare_q0_registration_response(request)
        self.assertEqual(response.status_code,200)
        self.assertIn(self.data['question_id'],response.content.decode())
        self.assertIn('disabled',response.content.decode())

    def test_read_recovery_scoped_to_actor_no_writer_and_inconclusive_on_foreign_receipt(self):
        self.enterContext(patch(E+'_require_q0_application_recovery_activation'))
        def only_reader(alias):
            self.assertEqual(alias,'oes_synthetic_reader')
            return self.f.reader
        self.f.connections.__getitem__.side_effect=only_reader
        self.assertEqual(prepare_q0_recovery(user=self.f.user,data=self.data)[0],200)
        self.f.record.actor_id='oes:actor:someone-else'
        self.assertEqual(prepare_q0_recovery(user=self.f.user,data=self.data)[0],503)
        self.f.writer.cursor.assert_not_called()
        self.f.lookup_receipt.assert_called_with(actor_id=self.f.actor,request_id=self.data['request_id'])
        self.assertIsNone(repo._trial_scope.get())

    def test_general_source_gates_stay_hold_even_with_application_flags(self):
        self.activate.side_effect=PreparationHold('HOLD application')
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],503)
        self.assertEqual(prepare_q0_recovery(user=self.f.user,data=self.data)[0],503)
        self.f.writer.cursor.assert_not_called()
        self.f.reader.cursor.assert_not_called()
        with self.assertRaises(PreparationHold):
            repo.DjangoQ0Repository()

    def test_source_gate_cannot_be_opened_by_environment_and_anonymous_denied(self):
        with patch.dict('os.environ',{'OES_Q0_APPLICATION_ENABLED':'1'}):
            with self.assertRaises(PreparationHold):
                self.write_gate()
        self.f.user.is_authenticated=False
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],403)
        self.assertEqual(prepare_q0_recovery(user=self.f.user,data=self.data)[0],403)
        self.f.writer.cursor.assert_not_called()

    def test_recovery_absence_keeps_scope_without_success_or_retry(self):
        with patch('evidence.question_preparation.review_registered_q0',return_value={
                'outcome':'ABSENT','scope':'Q0_RECORDS','automatic_retry':False}):
            status,context=prepare_q0_recovery(user=self.f.user,data=self.data)
        self.assertEqual(status,503)
        self.assertEqual(context['recovery_outcome'],'ABSENT')
        self.assertEqual(context['recovery_scope'],'Q0_RECORDS')
        self.assertNotIn('confirmed_question_id',context)
        self.f.writer.cursor.assert_not_called()

    def test_insert_failure_and_commit_ack_loss_are_never_reported_as_success(self):
        self.f.models['OesQuestion'].objects.using.return_value.create.side_effect=RuntimeError('offline insert failure')
        self.assertEqual(prepare_q0_submission(user=self.f.user,data=self.data)[0],503)
        self.assertIsNone(repo._trial_scope.get())
        self.assertEqual(self.f.models['OesEntity'].objects.using.return_value.create.call_count,1)
        self.f.models['OesQuestion'].objects.using.return_value.create.side_effect=None
        self.f.writer_exit_failure=True
        status,context=prepare_q0_submission(user=self.f.user,data=self.data)
        self.assertEqual(status,503)
        self.assertNotIn('confirmed_question_id',context)
        self.assertIsNone(repo._trial_scope.get())
