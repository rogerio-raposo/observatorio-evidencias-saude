"""Pure private-profile and fake D3 reference tests; no connections."""
from unittest.mock import patch
from django.test import SimpleTestCase, override_settings
from config.mb_oc1 import private_configuration, require_mb_oc1
from evidence.question_preparation import PreparationHold, PreparationConflict, review_authenticated_q0_reference
from evidence import test_q0_persistence_d3_offline as d3


class PrivateProfileTests(SimpleTestCase):
    def env(self):
        return {'OES_MB_OC1_CONNECT_TIMEOUT_SECONDS':'3','OES_MB_OC1_STATEMENT_TIMEOUT_MS':'1000',
           'OES_MB_OC1_LOCK_TIMEOUT_MS':'200','OES_MB_OC1_SECRET_KEY':'offline-test-key-'*5,
           'OES_MB_OC1_HOST':'oes.private.test','OES_MB_OC1_ORIGIN':'https://oes.private.test',
           'OES_MB_OC1_SESSION_SECONDS':'900','OES_MB_OC1_TLS_TERMINATION':'wsgi',
           'OES_MB_OC1_PG_HOST':'ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech',
           'OES_MB_OC1_AUTH_PASSWORD':'offline-auth','OES_MB_OC1_READER_PASSWORD':'offline-reader',
           'OES_MB_OC1_WRITER_PASSWORD':'offline-writer'}

    def test_secure_application_and_source_hold(self):
        p=private_configuration(self.env())
        self.assertFalse(p['DEBUG']); self.assertTrue(p['SESSION_COOKIE_SECURE'])
        self.assertTrue(p['CSRF_COOKIE_SECURE']); self.assertFalse(p['SESSION_SAVE_EVERY_REQUEST'])
        self.assertEqual(p['ALLOWED_HOSTS'],['oes.private.test'])
        self.assertEqual(p['CSRF_TRUSTED_ORIGINS'],['https://oes.private.test'])
        self.assertTrue(p['SECURE_SSL_REDIRECT']); self.assertIsNone(p['SECURE_PROXY_SSL_HEADER'])
        self.assertEqual(set(p['DATABASES']),{'default','oes_q0_writer','oes_synthetic_reader'})
        self.assertEqual(p['SESSION_ENGINE'],'django.contrib.sessions.backends.db')
        self.assertEqual(p['ROOT_URLCONF'],'config.urls_mb_oc1')
        self.assertNotIn('MB_OC1_ROLE',p)
        with override_settings(**p),self.assertRaises(PreparationHold): require_mb_oc1()

    def test_incomplete_or_incompatible_configuration_rejected(self):
        for key in self.env():
            env=self.env(); del env[key]
            with self.subTest(key=key),self.assertRaises(RuntimeError): private_configuration(env)
        for change in ({'OES_MB_OC1_HOST':'*'},{'OES_MB_OC1_ORIGIN':'http://oes.private.test'},
                       {'OES_MB_OC1_ORIGIN':'https://other.test'},{'OES_MB_OC1_SECRET_KEY':'development-only'},
                       {'OES_MB_OC1_SESSION_SECONDS':'0'},{'OES_MB_OC1_PG_HOST':'other'},
                       {'OES_MB_OC1_WRITER_PASSWORD':'offline-auth'},{'OES_Q0_MULTI_ALIAS_ENABLED':'1'}):
            with self.assertRaises(RuntimeError): private_configuration({**self.env(),**change})

    def test_default_http_and_retired_cp348_gates(self):
        from evidence.views import q0_registration,q0_reference,MBLoginView,MBLogoutView
        from evidence.question_orm_q0_repository_dormant import _require_first_trial_source_activation
        class Request:
            method='POST'
            def __getattr__(self,name): raise AssertionError(name)
        with override_settings(MB_OC1_CONFIGURED=True):
            for method in ('GET','POST'):
                request=Request(); request.method=method
                for view in (q0_registration,q0_reference,MBLoginView.as_view(),MBLogoutView.as_view()):
                    self.assertEqual(view(request).status_code,423)
        with patch.dict('os.environ',{'OES_Q0_FIRST_AUTHORIZATION':'approved','OES_MB_OC1_ENABLED':'1'}),self.assertRaises(PreparationHold):
            _require_first_trial_source_activation()

    def test_single_settings_import_without_connection_and_old_profiles_cannot_bypass(self):
        import importlib.util
        import os
        from pathlib import Path
        spec=importlib.util.spec_from_file_location('config.settings_mb_oc1_isolated',Path(__file__).parents[1]/'config/settings_mb_oc1.py')
        module=importlib.util.module_from_spec(spec)
        with patch.dict(os.environ,self.env(),clear=True),patch('django.db.backends.postgresql.base.DatabaseWrapper.get_new_connection',side_effect=AssertionError('connection')):
            spec.loader.exec_module(module)
        self.assertEqual(module.DATABASES,private_configuration(self.env())['DATABASES'])
        for name in ('config.settings_mb_oc1_reader','config.urls_mb_oc1_reader','config.readonly_sessions'):
            self.assertIsNone(importlib.util.find_spec(name))
        for old_role in ('A','B'):
            with self.assertRaises(TypeError): private_configuration(old_role,self.env())
            with self.assertRaises(TypeError): require_mb_oc1(old_role)
        with patch('config.mb_oc1._require_release'),override_settings(**private_configuration(self.env())):
            require_mb_oc1()
            for old_role in ('A','B'):
                with override_settings(MB_OC1_ROLE=old_role),self.assertRaises(PreparationHold): require_mb_oc1()
            with override_settings(DATABASES={'default':{},'oes_synthetic_reader':{}}),self.assertRaises(PreparationHold):
                require_mb_oc1()


class ReferenceRecoveryTests(SimpleTestCase):
    def setUp(self):
        self.f=d3.EvidenceD3Tests(); self.f.setUp(); self.addCleanup(self.f.doCleanups)
        self.enterContext(patch(d3.E+'_require_q0_application_recovery_activation'))
        def only_reader(alias):
            self.assertEqual(alias,'oes_synthetic_reader','recovery touched another connection')
            return self.f.reader
        self.f.connections.__getitem__.side_effect=only_reader
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

    def test_recovery_does_not_touch_configured_writer_even_if_its_transaction_is_open(self):
        self.f.writer.in_atomic_block=True
        self.f.writer.cursor.side_effect=AssertionError('writer used by recovery')
        result=self.review()
        self.assertEqual(result['outcome'],'PERSISTED')
        self.assertTrue(self.f.writer.in_atomic_block)
        self.f.writer.close.assert_not_called()
        self.assertEqual([c.kwargs['using'] for c in self.f.atomic.call_args_list],['oes_synthetic_reader'])

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
            gate.assert_called_with()
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
