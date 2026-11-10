"""Single-app native password/CSRF/session tests; SQLite and scientific fakes only."""
from unittest.mock import patch
from datetime import timedelta
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.contrib.sessions.models import Session
from django.db import connection
from django.test import TestCase,Client
from django.test.utils import CaptureQueriesContext
from django.utils import timezone
from preparer_identity.models import PreparerIdentity
from evidence.question_preparation import PreparationHold



class MBSessionTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        ct,_=ContentType.objects.get_or_create(app_label='evidence',model='oesquestion')
        permission,_=Permission.objects.get_or_create(content_type=ct,codename='prepare_question')
        cls.user=get_user_model().objects.create_user(username='mb-offline-preparer',password='offline-only-test-password')
        cls.user.user_permissions.add(permission); PreparerIdentity.objects.create(user=cls.user)

    def setUp(self):
        self.release=self.enterContext(patch('config.mb_oc1._require_release'))
        self.client=Client(enforce_csrf_checks=True)

    def login(self,password='offline-only-test-password'):
        response=self.client.get('/accounts/login/',secure=True)
        token=response.cookies['csrftoken'].value
        return self.client.post('/accounts/login/',{'username':self.user.username,'password':password,
            'csrfmiddlewaretoken':token},secure=True,HTTP_ORIGIN='https://testserver')

    def no_dml(self,queries):
        for q in queries: self.assertFalse(q['sql'].lstrip().upper().startswith(('INSERT','UPDATE','DELETE','REPLACE')),q['sql'])

    def test_password_csrf_and_logout(self):
        self.assertEqual(self.login('incorrect').status_code,200); self.assertFalse(Session.objects.exists())
        self.assertEqual(self.login().status_code,302); self.assertTrue(Session.objects.exists())
        self.assertEqual(self.client.post('/accounts/logout/',secure=True).status_code,403)
        token=self.client.cookies['csrftoken'].value
        self.assertEqual(self.client.post('/accounts/logout/',{'csrfmiddlewaretoken':token},secure=True,HTTP_ORIGIN='https://testserver').status_code,302)
        self.assertFalse(Session.objects.exists())

    def test_nonadmin_permission_and_binding(self):
        for field,value in (('is_active',False),('is_staff',True),('is_superuser',True)):
            setattr(self.user,field,value); self.user.save()
            self.assertEqual(self.login().status_code,200); self.assertFalse(Session.objects.exists())
            setattr(self.user,field,not value); self.user.save()
        self.user.user_permissions.clear()
        self.assertEqual(self.login().status_code,200); self.assertFalse(Session.objects.exists())
        self.user.user_permissions.add(Permission.objects.get(codename='prepare_question'))
        PreparerIdentity.objects.filter(user=self.user).delete()
        self.assertEqual(self.login().status_code,200); self.assertFalse(Session.objects.exists())

    def test_native_session_reaches_register_and_review_on_the_same_origin(self):
        self.assertEqual(self.login().status_code,302)
        for path in ('/questions/q0/register/','/questions/q0/review/'):
            with CaptureQueriesContext(connection) as queries:
                response=self.client.get(path,secure=True)
            self.assertEqual(response.status_code,200)
            self.assertTrue(queries.captured_queries)
            self.no_dml(queries)  # An unchanged ordinary GET need not save Auth.
        self.assertEqual(self.client.get('/accounts/login/',secure=True).status_code,200)

    def test_expiry_and_password_revocation_apply_to_new_requests(self):
        self.assertEqual(self.login().status_code,302)
        Session.objects.update(expire_date=timezone.now()-timedelta(seconds=1))
        self.assertEqual(self.client.get('/questions/q0/review/',secure=True).status_code,403)
        self.assertEqual(self.login().status_code,302)
        self.user.set_unusable_password(); self.user.save(update_fields=['password'])
        self.assertEqual(self.client.get('/questions/q0/review/',secure=True).status_code,403)
        # Native Auth may DELETE its invalid session; only scientific recovery is READ ONLY.
        self.assertFalse(Session.objects.filter(expire_date__gt=timezone.now()).exists())

    def test_source_release_remains_closed(self):
        self.release.side_effect=PreparationHold('HOLD')
        self.assertEqual(self.client.get('/accounts/login/',secure=True).status_code,423)

    def test_prepared_q0_post_uses_authenticated_user_and_reference_not_original_in_url(self):
        self.assertEqual(self.login().status_code,302)
        self.client.get('/questions/q0/register/',secure=True)
        token=self.client.cookies['csrftoken'].value
        from evidence.forms import Q0RegistrationForm,Q0_MESSAGES
        data={'request_id':'mb-request','question_id':'MB-SYNTH-Q0','original_text':'Synthetic question?'}
        with patch('evidence.forms.prepare_q0_submission',return_value=(503,{'form':Q0RegistrationForm(data),'messages':Q0_MESSAGES})) as prepare:
            response=self.client.post('/questions/q0/register/',{**data,'csrfmiddlewaretoken':token},secure=True,HTTP_ORIGIN='https://testserver')
        self.assertEqual(response.status_code,503); self.assertEqual(prepare.call_args.kwargs['user'].pk,self.user.pk)
        self.assertEqual(prepare.call_args.kwargs['data']['request_id'],'mb-request')
        self.assertIn('/questions/q0/review/?',response.content.decode()); self.assertNotIn('original_text=',response.content.decode())

    def test_permission_revocation_applies_to_new_reader_request(self):
        self.assertEqual(self.login().status_code,302)
        self.user.user_permissions.clear()
        self.assertEqual(self.client.get('/questions/q0/review/',secure=True).status_code,403)

    def test_real_session_to_form_uow_canonical_orm_and_d3_simulated(self):
        self.assertEqual(self.login().status_code,302)
        self.client.get('/questions/q0/register/',secure=True)
        token=self.client.cookies['csrftoken'].value
        real_using=PreparerIdentity.objects.using
        from evidence.test_q0_f1_offline import Q0F1Tests
        from uuid import UUID
        fixture=Q0F1Tests(); fixture.setUp(); self.addCleanup(fixture.doCleanups)
        # Real SQLite binding must be the same actor as the reused scientific
        # fixture. Scientific sessions/models remain fake; no PG evidence claim.
        identity=real_using('default').get(user_id=self.user.pk)
        identity.actor_uuid=UUID(fixture.f.actor.removeprefix('oes:actor:'))
        identity.save(using='default',update_fields=['actor_uuid'])
        with patch('preparer_identity.resolver.PreparerIdentity.objects.using',side_effect=real_using):
            response=self.client.post('/questions/q0/register/',{**fixture.data,'csrfmiddlewaretoken':token},secure=True,HTTP_ORIGIN='https://testserver')
        self.assertEqual(response.status_code,200,response.content.decode())
        for model in fixture.f.models.values():
            model.objects.using.return_value.create.assert_called_once()
        receipt=fixture.f.models['OesQuestionCommandReceipt'].objects.using.return_value.create.call_args.kwargs
        self.assertEqual(receipt['actor_id'],'oes:actor:'+str(identity.actor_uuid))
        self.assertEqual(receipt['question_id'],fixture.data['question_id'])
        self.assertIn('Registro Q0 íntegro',response.content.decode())
        fixture.f.models['OesQuestion'].objects.using.return_value.filter.return_value.exists.return_value=True
        fixture.f.models['OesQuestionVersion'].objects.using.return_value.filter.return_value.values.return_value.first.return_value={
            'original_text':fixture.f.command.original_text,'normalized_text':None,'preparation_stage':'q0_draft'}
        fixture.f.writer.reset_mock(); fixture.f.atomic.reset_mock()
        from evidence.question_preparation import command_fingerprint
        reference={'request_id':fixture.f.command.request_id,'question_id':fixture.f.command.question_id,
                   'fingerprint':command_fingerprint(fixture.f.command)}
        with patch('preparer_identity.resolver.PreparerIdentity.objects.using',side_effect=real_using):
            response=self.client.get('/questions/q0/review/',reference,secure=True)
            self.assertEqual(response.status_code,200,response.content.decode())
            fixture.f.record.actor_id='oes:actor:other'
            denied=self.client.get('/questions/q0/review/',reference,secure=True)
            self.assertEqual(denied.status_code,503)
            self.assertNotIn(fixture.f.command.original_text.strip(),denied.content.decode())
        fixture.f.writer.cursor.assert_not_called(); fixture.f.writer.close.assert_not_called()
        self.assertTrue(all(c.kwargs['using']=='oes_synthetic_reader' for c in fixture.f.atomic.call_args_list))
        for model in fixture.f.models.values():
            model.objects.using.return_value.create.assert_called_once()


    def test_private_routes_do_not_expose_historical_reader_or_q1_q2(self):
        from django.urls import resolve,Resolver404
        for path in ('/synthetic-pg-links/','/questions/q1/propose/','/questions/q2/routing/'):
            with self.assertRaises(Resolver404): resolve(path)
        for path in ('/accounts/login/','/accounts/logout/','/questions/q0/register/','/questions/q0/review/'):
            self.assertTrue(callable(resolve(path).func))
