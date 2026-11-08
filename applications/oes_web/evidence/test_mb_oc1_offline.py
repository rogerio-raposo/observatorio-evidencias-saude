"""Pure private-profile and fake D3 reference tests; no connections."""
from unittest.mock import Mock, patch
from django.test import SimpleTestCase, override_settings
from config.mb_oc1 import private_configuration, require_mb_oc1
from evidence.question_preparation import PreparationHold, PreparationConflict, review_authenticated_q0_reference
from evidence import test_q0_persistence_d3_offline as d3


class PrivateProfileTests(SimpleTestCase):
    def env(self, role='A'):
        e={'OES_MB_OC1_SECRET_KEY':'offline-test-key-'*5,'OES_MB_OC1_HOST':'oes.private.test',
           'OES_MB_OC1_ORIGIN':'https://oes.private.test','OES_MB_OC1_SESSION_SECONDS':'900',
           'OES_MB_OC1_TLS_TERMINATION':'wsgi','OES_MB_OC1_PG_HOST':'ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech',
           'OES_MB_OC1_AUTH_PASSWORD':'offline-auth','OES_MB_OC1_READER_PASSWORD':'offline-reader'}
        if role=='A': e['OES_MB_OC1_WRITER_PASSWORD']='offline-writer'
        return e

    def test_secure_profiles_and_source_hold(self):
        a=private_configuration('A',self.env()); b=private_configuration('B',self.env('B'))
        for p in (a,b):
            self.assertFalse(p['DEBUG']); self.assertTrue(p['SESSION_COOKIE_SECURE'])
            self.assertTrue(p['CSRF_COOKIE_SECURE']); self.assertFalse(p['SESSION_SAVE_EVERY_REQUEST'])
            self.assertEqual(p['ALLOWED_HOSTS'],['oes.private.test'])
            self.assertEqual(p['CSRF_TRUSTED_ORIGINS'],['https://oes.private.test'])
            self.assertTrue(p['SECURE_SSL_REDIRECT']); self.assertIsNone(p['SECURE_PROXY_SSL_HEADER'])
        self.assertEqual(a['SESSION_COOKIE_NAME'],b['SESSION_COOKIE_NAME'])
        self.assertEqual(set(a['DATABASES']),{'default','oes_q0_writer','oes_synthetic_reader'})
        self.assertEqual(set(b['DATABASES']),{'default','oes_synthetic_reader'})
        self.assertIn('transaction_read_only=on',b['DATABASES']['default']['OPTIONS']['options'])
        with override_settings(**a),self.assertRaises(PreparationHold): require_mb_oc1('A')

    def test_incomplete_incompatible_or_inherited_writer_configuration_rejected(self):
        for key in self.env():
            env=self.env(); del env[key]
            with self.subTest(key=key),self.assertRaises(RuntimeError): private_configuration('A',env)
        for change in ({'OES_MB_OC1_HOST':'*'},{'OES_MB_OC1_ORIGIN':'http://oes.private.test'},
                       {'OES_MB_OC1_ORIGIN':'https://other.test'},{'OES_MB_OC1_SECRET_KEY':'development-only'},
                       {'OES_MB_OC1_SESSION_SECONDS':'0'},{'OES_MB_OC1_PG_HOST':'other'},
                       {'OES_MB_OC1_WRITER_PASSWORD':'offline-auth'},{'OES_Q0_MULTI_ALIAS_ENABLED':'1'}):
            with self.assertRaises(RuntimeError): private_configuration('A',{**self.env(),**change})
        for key in ('OES_MB_OC1_WRITER_PASSWORD','OES_Q0_WRITER_PASSWORD','OES_QPREP_LOGIN_PASSWORD','DATABASE_URL','PGPASSFILE','OES_AUTH_G2_P2B_SMOKE_PASSWORD'):
            with self.subTest(key=key),self.assertRaises(RuntimeError): private_configuration('B',{**self.env('B'),key:''})

    def test_default_http_and_retired_cp348_gates(self):
        from evidence.views import q0_registration,q0_reference,MBLoginView,MBLogoutView
        from evidence.question_orm_q0_repository_dormant import _require_first_trial_source_activation
        class Request:
            method='POST'
            def __getattr__(self,name): raise AssertionError(name)
        for view in (q0_registration,q0_reference,MBLoginView.as_view(),MBLogoutView.as_view()):
            self.assertEqual(view(Request()).status_code,423)
        with patch.dict('os.environ',{'OES_Q0_FIRST_AUTHORIZATION':'approved','OES_MB_OC1_ENABLED':'1'}),self.assertRaises(PreparationHold):
            _require_first_trial_source_activation()

    def test_profile_modules_import_without_connections_and_incompatible_roles_hold(self):
        import importlib.util
        import os
        from pathlib import Path
        for role,name in (('A','settings_mb_oc1'),('B','settings_mb_oc1_reader')):
            spec=importlib.util.spec_from_file_location('config.'+name+'_isolated',Path(__file__).parents[1]/'config'/(name+'.py'))
            module=importlib.util.module_from_spec(spec)
            with patch.dict(os.environ,self.env(role),clear=True),patch('django.db.backends.postgresql.base.DatabaseWrapper.get_new_connection',side_effect=AssertionError('connection')):
                spec.loader.exec_module(module)
            self.assertEqual(module.MB_OC1_ROLE,role)
            self.assertEqual(module.DATABASES,private_configuration(role,self.env(role))['DATABASES'])
        with patch('config.mb_oc1._require_release'),override_settings(MB_OC1_ROLE='A',MB_OC1_CONFIGURED=True,DEBUG=False):
            with self.assertRaises(PreparationHold): require_mb_oc1('B')


class ReferenceRecoveryTests(SimpleTestCase):
    def setUp(self):
        self.f=d3.EvidenceD3Tests(); self.f.setUp(); self.addCleanup(self.f.doCleanups)
        self.enterContext(patch(d3.E+'_require_q0_application_recovery_activation'))
        self.enterContext(patch('scripts.q0_django_readonly_attestation._session'))
        self.f.configs.pop('oes_q0_writer'); self.auth=Mock(in_atomic_block=False)
        self.f.connections.__getitem__.side_effect={'default':self.auth,'oes_synthetic_reader':self.f.reader}.__getitem__
        self.f.models['OesQuestion'].objects.using.return_value.filter.return_value.exists.return_value=True
        self.f.models['OesQuestionVersion'].objects.using.return_value.filter.return_value.values.return_value.first.return_value={
            'original_text':self.f.command.original_text,'normalized_text':None,'preparation_stage':'q0_draft'}
        self.data={'request_id':self.f.command.request_id,'question_id':self.f.command.question_id,'fingerprint':self.f.expected.fingerprint}

    def review(self, **change):
        return review_authenticated_q0_reference(user=self.f.user,**{**self.data,**change})

    def test_discovery_then_actual_d3_verifier_without_writer_or_submit(self):
        with patch('evidence.question_preparation.register_authenticated_q0',side_effect=AssertionError('submit')) as submit:
            result=self.review()
        self.assertEqual(result['outcome'],'PERSISTED')
        self.assertEqual(result['original_text'],self.f.command.original_text)
        self.assertEqual(self.f.lookup_receipt.call_count,2)
        self.f.lookup_receipt.assert_called_with(actor_id=self.f.actor,request_id=self.f.command.request_id)
        self.f.writer.cursor.assert_not_called(); submit.assert_not_called()
        self.assertTrue(any('REPEATABLE READ READ ONLY' in sql for alias,sql in self.f.events))

    def test_owned_conflicts_and_foreign_actor(self):
        for change in ({'question_id':'different'},{'fingerprint':'0'*64}):
            with self.assertRaises(PreparationConflict): self.review(**change)
        self.f.record.actor_id='other'
        result=self.review(); self.assertEqual(result['outcome'],'INDETERMINATE'); self.assertNotIn('original_text',result)

    def test_discovery_is_not_success_and_missing_receipt_not_absence(self):
        self.f.bad_reader_identity=True
        self.assertEqual(self.review()['outcome'],'INDETERMINATE'); self.f.bad_reader_identity=False
        with patch(d3.E+'_collect_q0_commit_evidence',return_value={'outcome':'INDETERMINATE','scope':'Q0_RECORDS','automatic_retry':False}):
            result=self.review(); self.assertEqual(result['outcome'],'INDETERMINATE'); self.assertNotIn('original_text',result)
        self.f.has_receipt=False
        self.assertEqual(self.review()['outcome'],'INDETERMINATE')

    def test_changed_between_reads_and_invalid_client_reference(self):
        original=self.f.lookup_receipt.return_value.using.return_value.first.side_effect
        calls=0
        def lookup():
            nonlocal calls
            calls+=1; record=original()
            if calls==2: record.fingerprint_sha256='0'*64
            return record
        self.f.lookup_receipt.return_value.using.return_value.first.side_effect=lookup
        with self.assertRaises(PreparationConflict): self.review()
        for change in ({'request_id':'invalid id'},{'fingerprint':'not-a-fingerprint'}):
            with self.assertRaises(PreparationHold): self.review(**change)

    def test_http_reference_statuses_and_client_fields(self):
        from django.test import RequestFactory
        from evidence.views import q0_reference
        def request(data):
            r=RequestFactory().get('/questions/q0/review/',data); r.user=self.f.user; return r
        # Route profile boundary is isolated here; its actual default-close and
        # profile checks are covered above. The service/collector are real fakes.
        with patch('config.mb_oc1.require_mb_oc1') as gate:
            self.assertEqual(q0_reference(request(self.data)).status_code,200)
            gate.assert_called_with('B')
            self.assertEqual(q0_reference(request({**self.data,'fingerprint':'0'*64})).status_code,409)
            self.assertEqual(q0_reference(request({**self.data,'actor_id':'forged'})).status_code,400)
            self.f.has_receipt=False
            response=q0_reference(request(self.data))
            self.assertEqual(response.status_code,503)
            self.assertIn('INDETERMINATE',response.content.decode())
            self.assertEqual(response['Cache-Control'],'no-store')
            self.f.user.has_perm.return_value=False
            self.assertEqual(q0_reference(request(self.data)).status_code,403)

    def test_changed_actor_binding_cannot_expose_reference_content(self):
        from types import SimpleNamespace
        from uuid import UUID
        current=self.f.identity_lookup.return_value.get.return_value
        other=SimpleNamespace(actor_uuid=UUID('a1234567-89ab-4cde-8fab-123456789abc'))
        self.f.identity_lookup.return_value.get.side_effect=[current,other]
        result=self.review()
        self.assertEqual(result['outcome'],'INDETERMINATE')
        self.assertNotIn('original_text',result)
