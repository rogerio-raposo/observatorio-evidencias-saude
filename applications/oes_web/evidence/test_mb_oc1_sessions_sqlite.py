"""Password/CSRF/shared-session tests on isolated SQLite, never PostgreSQL."""
from unittest.mock import patch
from datetime import timedelta
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.contrib.sessions.models import Session
from django.db import connection
from django.http import HttpResponse
from django.test import TestCase,Client,override_settings
from django.test.utils import CaptureQueriesContext
from django.urls import path
from django.utils import timezone
from preparer_identity.models import PreparerIdentity
from evidence.question_preparation import PreparationHold


def alter(request):
    request.session['unexpected']='value'
    return HttpResponse('must not appear')


def save(request):
    request.session.save()
    return HttpResponse('must not appear')


urlpatterns=[path('alter/',alter),path('save/',save)]


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

    def reader(self,**extra):
        s=dict(MB_OC1_ROLE='B',ROOT_URLCONF='config.urls_mb_oc1_reader',SESSION_ENGINE='config.readonly_sessions',
            MIDDLEWARE=['django.middleware.security.SecurityMiddleware','config.readonly_sessions.ReadOnlySessionMiddleware',
                'django.middleware.common.CommonMiddleware','django.middleware.csrf.CsrfViewMiddleware','django.contrib.auth.middleware.AuthenticationMiddleware'])
        s.update(extra); return override_settings(**s)

    def reader_client(self):
        c=Client(enforce_csrf_checks=True); c.cookies=self.client.cookies.copy(); return c

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

    def test_reader_accepts_session_from_a_with_select_only(self):
        self.assertEqual(self.login().status_code,302)
        with self.reader():
            c=self.reader_client()
            with CaptureQueriesContext(connection) as queries:
                response=c.get('/questions/q0/review/',secure=True)
            self.assertEqual(response.status_code,200); self.no_dml(queries); self.assertTrue(queries.captured_queries)
            self.assertEqual(c.get('/accounts/login/',secure=True).status_code,404)

    def test_expiry_and_password_revocation_no_reader_delete(self):
        self.assertEqual(self.login().status_code,302)
        Session.objects.update(expire_date=timezone.now()-timedelta(seconds=1))
        with self.reader(),CaptureQueriesContext(connection) as queries:
            self.assertEqual(self.reader_client().get('/questions/q0/review/',secure=True).status_code,403)
        self.no_dml(queries)
        self.assertEqual(self.login().status_code,302)
        self.user.set_unusable_password(); self.user.save(update_fields=['password'])
        with self.reader(),CaptureQueriesContext(connection) as queries:
            self.assertEqual(self.reader_client().get('/questions/q0/review/',secure=True).status_code,403)
        self.no_dml(queries)

    def test_modified_session_or_explicit_save_fail_before_dml(self):
        self.assertEqual(self.login().status_code,302)
        for url in ('/alter/','/save/'):
            with self.reader(ROOT_URLCONF=__name__),CaptureQueriesContext(connection) as queries:
                response=self.reader_client().get(url,secure=True)
                self.assertEqual(response.status_code,503); self.assertNotIn('must not',response.content.decode())
            self.no_dml(queries)

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
        with self.reader(),CaptureQueriesContext(connection) as queries:
            self.assertEqual(self.reader_client().get('/questions/q0/review/',secure=True).status_code,403)
        self.no_dml(queries)

    def test_readonly_store_denies_all_write_methods_without_queries(self):
        from config.readonly_sessions import SessionStore,ReadOnlySessionWrite
        from config.readonly_sessions import ReadOnlySessionMiddleware
        from django.core.exceptions import ImproperlyConfigured
        for name in ('create','save','delete','cycle_key','clear_expired'):
            with CaptureQueriesContext(connection) as queries,self.assertRaises(ReadOnlySessionWrite):
                getattr(SessionStore(),name)()
            self.assertFalse(queries.captured_queries)
        import asyncio
        for name in ("acreate", "asave", "adelete", "acycle_key", "aclear_expired"):
            with CaptureQueriesContext(connection) as queries,self.assertRaises(ReadOnlySessionWrite):
                asyncio.run(getattr(SessionStore(), name)())
            self.assertFalse(queries.captured_queries)
        with self.reader(SESSION_SAVE_EVERY_REQUEST=True),self.assertRaises(ImproperlyConfigured):
            ReadOnlySessionMiddleware(lambda request:HttpResponse())

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

    def test_private_routes_do_not_expose_historical_reader_or_q1_q2(self):
        from django.urls import resolve,Resolver404
        for path in ('/synthetic-pg-links/','/questions/q1/propose/','/questions/q2/routing/'):
            with self.assertRaises(Resolver404): resolve(path)
        with self.reader():
            for path in ('/accounts/login/','/accounts/logout/','/questions/q0/register/'):
                with self.assertRaises(Resolver404): resolve(path)
