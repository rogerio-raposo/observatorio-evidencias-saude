"""First fixed Q0 trial preparation. No source gate is bypassed in these tests."""
import ast
from contextlib import redirect_stdout, redirect_stderr
from io import StringIO
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from types import SimpleNamespace
from unittest.mock import MagicMock, Mock, patch
from uuid import UUID

from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold, command_fingerprint
from preparer_identity.models import PreparerIdentity
from preparer_identity.synthetic_service_readonly import RESERVED_USERNAME
from scripts import q0_general_first_commit as trial

APP = Path(__file__).resolve().parents[1]
ROOT = APP.parents[1]
WORKFLOW = ROOT / '.github/workflows/oes-q0-general-first-persistent-commit.yml'


class FirstCommitPrepTests(SimpleTestCase):
    def env(self, mode=trial.COMMIT):
        sha = 'a' * 40
        prefix = 'APPROVED_FIRST_CANONICAL_Q0_COMMIT' if mode==trial.COMMIT else 'APPROVED_FIRST_Q0_READ_ONLY_RECONCILIATION'
        env = {**trial.WORKFLOW_CONTEXT, 'GITHUB_SHA':sha, 'OES_Q0_FIRST_MODE':mode,
            'GITHUB_WORKFLOW_REF':'rogerio-raposo/observatorio-evidencias-saude/.github/workflows/oes-q0-general-first-persistent-commit.yml@refs/heads/main',
            'GITHUB_WORKFLOW_SHA':sha, 'OES_Q0_FIRST_REQUESTED_SHA':sha, 'OES_Q0_FIRST_APPROVED_SHA':sha,
            'OES_Q0_FIRST_AUTHORIZATION':f'{prefix}:{sha}:{trial.REQUEST_ID}',
            'DJANGO_SETTINGS_MODULE':'config.settings', 'OES_PG_A4_ENABLED':'1',
            'OES_PG_A4_HOST':trial.HOST, 'OES_Q0_AUTH_PASSWORD':'offline-auth', 'OES_PG_A4_PASSWORD':'offline-reader'}
        if mode==trial.COMMIT:
            env.update(OES_Q0_MULTI_ALIAS_ENABLED='1', OES_Q0_WRITER_PASSWORD='offline-writer')
        else:
            env['OES_Q0_RECOVERY_READONLY_ENABLED']='1'
        return env

    def test_fixed_command_no_operator_data_identity_or_new_id_generation(self):
        command = trial.reserved_command()
        self.assertEqual(command, trial.reserved_command())
        self.assertEqual(command.request_id, trial.REQUEST_ID)
        self.assertEqual(command.question_id, trial.QUESTION_ID)
        self.assertEqual(command.expected_version, 0)
        self.assertIsNone(command.normalized_text)
        self.assertEqual(command.justification,'')
        self.assertEqual(trial.USERNAME, RESERVED_USERNAME)
        self.assertEqual(command_fingerprint(command), trial.FINGERPRINT)
        self.assertEqual(trial.FINGERPRINT, '5331c6337bb7fe19c29a43b659722844b8591c100a56d3e7333b3c853a2ae667')

    def test_default_review_and_import_work_without_django(self):
        env = {'PATH':os.environ.get('PATH',''), 'PYTHONDONTWRITEBYTECODE':'1'}
        for args in (['-m','scripts.q0_general_first_commit'], ['-c','import scripts.q0_general_first_commit']):
            result = subprocess.run([sys.executable,'-S',*args],cwd=APP,env=env,capture_output=True,text=True,timeout=10)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertIn(result.stdout.strip(),('',trial.REVIEW_CODE))

    def test_sha_approval_scope_and_rerun_rejected(self):
        env=self.env()
        self.assertEqual(trial.check_boundary(env,'a'*40),trial.COMMIT)
        for key,value in (('GITHUB_SHA',''),('GITHUB_WORKFLOW_REF','other'),('GITHUB_WORKFLOW_SHA','b'*40),('OES_Q0_FIRST_REQUESTED_SHA','b'*40),
            ('OES_Q0_FIRST_APPROVED_SHA','b'*40),('OES_Q0_FIRST_AUTHORIZATION','present'),
            ('GITHUB_RUN_ATTEMPT','2'),('GITHUB_REF','refs/heads/other'),('GITHUB_EVENT_NAME','push')):
            with self.subTest(key=key), self.assertRaises(trial._Hold):
                trial.check_boundary({**env,key:value},'a'*40)
        with self.assertRaises(trial._Hold):
            trial.check_boundary(env,'b'*40)

    def test_operator_cannot_change_manifest_or_claim_authorization_unused(self):
        env=self.env()
        for key in ('OES_Q0_FIRST_USER','OES_Q0_FIRST_ACTOR','OES_Q0_FIRST_REQUEST_ID',
                'OES_Q0_FIRST_QUESTION_ID','OES_Q0_FIRST_TEXT','OES_Q0_FIRST_COMMAND',
                'OES_Q0_FIRST_CONSUMED','OES_Q0_FIRST_UNUSED'):
            with self.subTest(key=key), self.assertRaises(trial._Hold):
                trial.check_boundary({**env,key:'forged'},'a'*40)

    def test_distinct_recovery_approval_cannot_reopen_write_mode(self):
        read_env=self.env(trial.RECOVER)
        self.assertEqual(trial.check_boundary(read_env,'a'*40),trial.RECOVER)
        for change in ({'OES_Q0_FIRST_MODE':trial.COMMIT},
                       {'OES_Q0_FIRST_AUTHORIZATION':self.env()['OES_Q0_FIRST_AUTHORIZATION']}):
            with self.assertRaises(trial._Hold):
                trial.check_boundary({**read_env,**change},'a'*40)

    def test_profiles_reject_missing_shared_foreign_or_writer_in_recovery(self):
        for mode in (trial.COMMIT,trial.RECOVER):
            trial.check_profile(mode,self.env(mode))
        for changes in ({'OES_Q0_AUTH_PASSWORD':''},{'OES_PG_A4_HOST':'other'},
                {'OES_Q0_WRITER_PASSWORD':'offline-auth'}, {'DJANGO_SETTINGS_MODULE':'other'}):
            with self.assertRaises(trial._Hold):
                trial.check_profile(trial.COMMIT,{**self.env(),**changes})
        with self.assertRaises(trial._Hold):
            trial.check_profile(trial.RECOVER,{**self.env(trial.RECOVER),'OES_Q0_WRITER_PASSWORD':''})

    def test_wrappers_require_internal_context_before_setup_even_with_approval(self):
        for mode, wrapper in ((trial.COMMIT,trial._execute_first_commit),(trial.RECOVER,trial._reconcile_first_commit)):
            with patch.dict(os.environ,self.env(mode),clear=True), patch.object(trial,'checked_out_sha',return_value='a'*40), patch('django.setup') as setup:
                with self.assertRaises(trial._Hold):
                    wrapper('a'*40)
                setup.assert_not_called()

    def test_synthetic_preparer_uses_authorization_unusable_password_and_stored_binding(self):
        user=Mock(pk=42,username=trial.USERNAME,is_authenticated=True,is_active=True,is_staff=False,is_superuser=False)
        user.has_perm.return_value=True
        user.has_usable_password.return_value=False
        uuid=UUID('12345678-1234-4234-8234-123456789abc')
        with patch('preparer_identity.resolver.PreparerIdentity.objects.using') as lookup:
            lookup.return_value.get.return_value=SimpleNamespace(actor_uuid=uuid)
            self.assertEqual(trial._validate_reserved_user(user),'oes:actor:'+str(uuid))
            lookup.return_value.get.assert_called_once_with(user_id=42)
            lookup.return_value.get.side_effect=PreparerIdentity.DoesNotExist
            with self.assertRaises(PreparationHold):
                trial._validate_reserved_user(user)
        user.has_perm.return_value=False
        with self.assertRaises(PermissionDenied):
            trial._validate_reserved_user(user)
        user.has_perm.return_value=True
        user.username='arbitrary-user'
        with self.assertRaises(trial._Hold):
            trial._validate_reserved_user(user)

    def test_commit_user_loader_matches_existing_attestation_to_persisted_actor(self):
        user=Mock(pk=42,username=trial.USERNAME,is_authenticated=True,is_active=True,is_staff=False,is_superuser=False)
        user.has_perm.return_value=True
        user.has_usable_password.return_value=False
        uuid=UUID('12345678-1234-4234-8234-123456789abc')
        manager=Mock()
        manager.using.return_value.get.return_value=user
        with patch('django.contrib.auth.get_user_model',return_value=SimpleNamespace(objects=manager)), patch('preparer_identity.synthetic_service_readonly.attest_synthetic_identity_readonly',return_value='oes:actor:'+str(uuid)) as attest, patch('preparer_identity.resolver.PreparerIdentity.objects.using') as identity:
            identity.return_value.get.return_value=SimpleNamespace(actor_uuid=uuid)
            self.assertIs(trial._load_reserved_user(trial.COMMIT),user)
            manager.using.return_value.get.assert_called_once_with(username=trial.USERNAME)
            attest.assert_called_once()
            attest.return_value='oes:actor:other'
            with self.assertRaises(trial._Hold):
                trial._load_reserved_user(trial.COMMIT)

    def test_read_loader_uses_only_readonly_default_and_existing_synthetic_classifier(self):
        user=Mock(pk=42,username=trial.USERNAME,password='!unusable',is_authenticated=True,
                  is_active=True,is_staff=False,is_superuser=False)
        user.has_perm.return_value=True
        user.has_usable_password.return_value=False
        user.user_permissions.using.return_value.values_list.return_value=[('evidence','oesquestion','prepare_question')]
        user.groups.using.return_value.values_list.return_value=[]
        uuid=UUID('12345678-1234-4234-8234-123456789abc')
        identity=SimpleNamespace(user_id=42,actor_uuid=uuid)
        manager=Mock()
        manager.using.return_value.filter.return_value=[user]
        connection=MagicMock(alias='default',vendor='postgresql',in_atomic_block=False)
        connection.get_autocommit.return_value=True
        connection.cursor.return_value.__enter__.return_value.fetchone.return_value=(
            'oes_auth_trial_login','oes_auth_trial_login','oes_sandbox','on','django_auth,public',['django_auth','public'])
        with patch('django.contrib.auth.get_user_model',return_value=SimpleNamespace(objects=manager)), patch('preparer_identity.models.PreparerIdentity.objects.using') as bindings, patch('django.db.connections',{'default':connection}):
            bindings.return_value.filter.return_value=[identity]
            bindings.return_value.get.return_value=identity
            self.assertIs(trial._load_reserved_user(trial.RECOVER),user)
            manager.using.assert_called_with('default')
            bindings.return_value.get.assert_called_once_with(user_id=42)
        connection.close.assert_called_once()

    def test_unreachable_bridges_call_public_application_once_no_alternate_repository(self):
        source=Path(trial.__file__).read_text()
        tree=ast.parse(source)
        for name,call in (('_execute_first_commit','register_authenticated_q0'),('_reconcile_first_commit','review_registered_q0')):
            function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name==name)
            self.assertEqual(function.body[1].value.func.id, '_require_operation')
            calls=[n.func.id for n in ast.walk(function) if isinstance(n,ast.Call) and isinstance(n.func,ast.Name)]
            self.assertEqual(calls.count(call),1)
            self.assertFalse(any(isinstance(n,(ast.For,ast.While)) for n in ast.walk(function)))
        self.assertNotIn('run_q0_synthetic_commit_candidate',source)
        self.assertNotIn('q0_single_persistent_trial',source)
        self.assertNotIn('DjangoQ0Repository(',source)
        self.assertNotIn('OfflineQuestionUnitOfWork(',source)
        self.assertFalse(any(isinstance(n,ast.ClassDef) and n.name!='_Hold' for n in tree.body))

    def test_outcome_presentation_keeps_three_classes_and_never_retries_or_leaks(self):
        fingerprint=command_fingerprint(trial.reserved_command())
        for outcome,scope in (('PERSISTED','Q0_RECORDS'),('ABSENT','THIS_ATTEMPT'),('INDETERMINATE','Q0_RECORDS')):
            output=StringIO()
            with redirect_stdout(output):
                trial._emit_observation('a'*40,{'outcome':outcome,'scope':scope,'automatic_retry':False,'password':'SECRET'},fingerprint)
            value=json.loads(output.getvalue())
            self.assertEqual(value['outcome'],outcome)
            self.assertIs(value['automatic_retry'],False)
            self.assertNotIn('SECRET',output.getvalue())
        with redirect_stdout(StringIO()) as output:
            trial._emit_observation('a'*40,{'outcome':'SUCCESS'},fingerprint)
        self.assertEqual(json.loads(output.getvalue())['outcome'],'INDETERMINATE')

    def test_unexpected_arguments_and_exceptions_are_sanitized(self):
        output,error=StringIO(),StringIO()
        with patch.object(sys,'argv',['trial','SECRET_ARGUMENT']), redirect_stdout(output), redirect_stderr(error):
            self.assertEqual(trial.entrypoint(),1)
        self.assertEqual(output.getvalue().strip(),trial.BOUNDARY)
        self.assertEqual(error.getvalue(),'')
        with patch.object(trial,'main',side_effect=RuntimeError('SECRET')):
            with redirect_stdout(StringIO()) as output:
                self.assertEqual(trial.entrypoint(),1)
            self.assertEqual(output.getvalue().strip(),trial.INCONCLUSIVE)

    def test_new_workflow_manual_fixed_sha_and_both_connected_jobs_false(self):
        source=WORKFLOW.read_text()
        events=source.split('on:\n',1)[1].split('\npermissions:',1)[0]
        self.assertEqual(re.findall(r'^  ([a-z_]+):',events,re.M),['workflow_dispatch'])
        self.assertIn('default: REVIEW_ONLY',events)
        self.assertNotIn('trial_id:',events)
        self.assertNotIn('question_id:',events)
        self.assertNotIn('if: ${{ false }}',source)
        for mode in (trial.COMMIT,trial.RECOVER):
            self.assertIn("inputs.mode == '"+mode+"'",source)
        self.assertEqual(source.count('vars.OES_Q0_FIRST_APPROVED_SHA == github.sha'),2)
        self.assertEqual(source.count("github.run_attempt == 1"),2)
        self.assertEqual(source.count('ref: ${{ github.sha }}'),3)
        self.assertIn('contents: read',source)
        review,other=source.split('  first-commit:\n',1)
        self.assertNotIn('secrets.',review)
        write,read=other.split('  independent-reconciliation:\n',1)
        self.assertIn('needs: review-only',read)
        self.assertNotIn('needs: first-commit',read)
        self.assertNotIn('OES_Q0_WRITER_PASSWORD',read)
        self.assertNotIn('OES_Q0_MULTI_ALIAS_ENABLED',read)
        self.assertEqual(write.count('secrets.'),3)
        self.assertEqual(read.count('secrets.'),2)

    def test_manifest_drift_rejected_before_submission(self):
        with patch.object(trial, 'TEXT', 'changed synthetic scope'):
            with self.assertRaises(trial._Hold):
                trial.reserved_command()

    def test_administrative_approval_does_not_activate_canonical_construction_or_recovery(self):
        from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
        from evidence.question_orm_q0_evidence_dormant import _require_q0_read_recovery_source_activation
        for mode in (trial.COMMIT, trial.RECOVER):
            with patch.dict(os.environ, self.env(mode), clear=True), patch('django.db.connections') as connections:
                self.assertEqual(trial.check_boundary(os.environ, 'a'*40), mode)
                for construct in (lambda: DjangoQ0Repository(),
                                  lambda: DjangoQ0Repository._from_preflighted_writer(writer=Mock()),
                                  _require_q0_read_recovery_source_activation):
                    with self.assertRaises(PreparationHold):
                        construct()
                connections.__getitem__.assert_not_called()


class RestrictedTrialScopeTests(SimpleTestCase):
    env = FirstCommitPrepTests.env
    # Exercise scope lifecycle with synthetic identity/session observations.
    # Only the issuance source gate is patched in unit tests, never operationally.
    def scope(self):
        from contextlib import ExitStack
        from evidence import question_orm_q0_repository_dormant as repo
        stack = ExitStack()
        self.addCleanup(stack.close)
        user = Mock()
        actor = 'oes:actor:offline'
        stack.enter_context(patch.dict(os.environ, self.env(), clear=True))
        stack.enter_context(patch.object(trial, 'checked_out_sha', return_value='a'*40))
        stack.enter_context(patch.object(trial, '_validate_reserved_user', return_value=actor))
        stack.enter_context(patch.object(repo, '_require_first_trial_source_activation'))
        stack.enter_context(patch('evidence.preparation_auth.require_question_preparer'))
        stack.enter_context(patch('preparer_identity.resolver.persisted_preparer_actor_id', return_value=actor))
        return repo, user, actor

    def test_issuance_source_gate_rejects_artificial_arguments_even_with_env(self):
        from evidence import question_orm_q0_repository_dormant as repo
        with patch.dict(os.environ, self.env(), clear=True):
            with self.assertRaises(PreparationHold):
                with repo._first_trial_scope(sha='a'*40, user=Mock(), command=trial.reserved_command()):
                    self.fail('source gate opened')
        self.assertIsNone(repo._trial_scope.get())

    def test_scope_command_actor_and_lifetime(self):
        from dataclasses import replace
        repo, user, actor = self.scope()
        command = trial.reserved_command()
        for fail in (False, True):
            try:
                with repo._first_trial_scope(sha='a'*40, user=user, command=command):
                    scope = repo._require_restricted_q0_construction(user=user, command=command)
                    for other_user, other in ((Mock(),command), (user,replace(command,request_id='different')),
                            (user,replace(command,original_text='different'))):
                        with self.assertRaises(PreparationHold):
                            repo._require_restricted_q0_construction(user=other_user,command=other)
                    scope.fingerprint = 'b'*64
                    with self.assertRaises(PreparationHold):
                        repo._require_restricted_q0_construction(user=user,command=command)
                    if fail:
                        raise ValueError('offline interruption')
            except ValueError:
                pass
            self.assertFalse(scope.active)
            self.assertIsNone(scope.binding)
            with self.assertRaises(PreparationHold):
                repo._require_restricted_q0_construction()

    def test_binding_rejects_other_connection_transaction_xid_and_expiration(self):
        from evidence.question_orm_q0_evidence_dormant import _WriterTrace, _expected_receipt
        repo,user,actor = self.scope()
        writer = MagicMock(in_atomic_block=True)
        writer.get_autocommit.return_value=False
        writer.atomic_blocks=[object()]
        writer.connection=object()
        cursor=writer.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value=('17',)
        trace=_WriterTrace(_expected_receipt(trial.reserved_command(),actor),atomic_entered=True,
            xid='17',writer_identity=('oes_qprep_login','oes_sandbox','off'),writer_privileges=('verified',))
        with repo._first_trial_scope(sha='a'*40,user=user,command=trial.reserved_command()):
            with self.assertRaises(PreparationHold):
                repo._check_trial_binding(writer)
            with repo._bind_trial_transaction(writer,trace):
                binding=repo._check_trial_binding(writer)
                with self.assertRaises(PreparationHold):
                    repo._check_trial_binding(MagicMock())
                for attribute,value in (('atomic_blocks',[object()]),('connection',object()),('in_atomic_block',False)):
                    old=getattr(writer,attribute)
                    setattr(writer,attribute,value)
                    with self.assertRaises(PreparationHold):
                        repo._check_trial_binding(writer,binding)
                    setattr(writer,attribute,old)
                trace.xid='18'
                with self.assertRaises(PreparationHold):
                    repo._check_trial_binding(writer,binding)
                trace.xid='17'
                cursor.fetchone.return_value=('18',)
                with self.assertRaises(PreparationHold):
                    repo._check_trial_binding(writer,binding)
            with self.assertRaises(PreparationHold):
                repo._check_trial_binding(writer,binding)

    def test_binding_invalidated_on_exception_and_missing_preflight_rejected(self):
        from evidence.question_orm_q0_evidence_dormant import _WriterTrace, _expected_receipt
        repo,user,actor=self.scope()
        writer=MagicMock(in_atomic_block=True,atomic_blocks=[object()],connection=object())
        writer.get_autocommit.return_value=False
        trace=_WriterTrace(_expected_receipt(trial.reserved_command(),actor))
        with repo._first_trial_scope(sha='a'*40,user=user,command=trial.reserved_command()):
            with self.assertRaises(PreparationHold):
                with repo._bind_trial_transaction(writer,trace):
                    self.fail('missing preflight accepted')
            trace.atomic_entered=True
            trace.xid='17'
            trace.writer_identity=('oes_qprep_login','oes_sandbox','off')
            trace.writer_privileges=('verified',)
            with self.assertRaises(ValueError):
                with repo._bind_trial_transaction(writer,trace):
                    raise ValueError('offline failure')
            self.assertIsNone(repo._trial_scope.get().binding)

    def test_all_mutations_check_live_binding_before_orm_or_lock(self):
        from evidence import question_orm_q0_repository_dormant as repo
        tree=ast.parse(Path(repo.__file__).read_text())
        cls=next(n for n in tree.body if isinstance(n,ast.ClassDef) and n.name=='DjangoQ0Repository')
        for name in ('insert_entity','insert_question','insert_entity_version','insert_question_version','insert_receipt','_advisory_lock'):
            method=next(n for n in cls.body if isinstance(n,ast.FunctionDef) and n.name==name)
            self.assertIsInstance(method.body[0],ast.ImportFrom)
            self.assertEqual(method.body[1].value.func.id,'_check_trial_binding')

    def test_general_service_and_read_recovery_do_not_issue_scope(self):
        from evidence import question_orm_q0_repository_dormant as repo
        from evidence.question_preparation import register_authenticated_q0
        user=Mock(is_authenticated=True,is_active=True,is_staff=False,is_superuser=False)
        user.has_perm.return_value=True
        with patch('django.db.connections') as connections:
            with self.assertRaises(PreparationHold):
                register_authenticated_q0(user=user,command=trial.reserved_command())
            connections.__getitem__.assert_not_called()
        self.assertIsNone(repo._trial_scope.get())
        for file in ('question_preparation.py','question_orm_q0_evidence_dormant.py'):
            self.assertNotIn('_first_trial_scope', (APP/'evidence'/file).read_text())

    def test_real_canonical_constructor_requires_bound_scope_and_expires(self):
        from evidence.question_orm_q0_evidence_dormant import _WriterTrace, _expected_receipt
        repo,user,actor=self.scope()
        writer=MagicMock(alias='oes_q0_writer',vendor='postgresql',in_atomic_block=True,
                         atomic_blocks=[object()],connection=object())
        writer.get_autocommit.return_value=False
        writer.cursor.return_value.__enter__.return_value.fetchone.side_effect=[
            ('oes_qprep_login','oes_sandbox','off'),('17',)]
        trace=_WriterTrace(_expected_receipt(trial.reserved_command(),actor),atomic_entered=True,
            xid='17',writer_identity=('oes_qprep_login','oes_sandbox','off'),writer_privileges=('verified',))
        with patch('django.db.connections',{'oes_q0_writer':writer}), patch('evidence.question_orm_q0_evidence_dormant._review_q0_privileges'):
            with repo._first_trial_scope(sha='a'*40,user=user,command=trial.reserved_command()):
                with repo._bind_trial_transaction(writer,trace):
                    repository=repo.DjangoQ0Repository._from_preflighted_writer(writer=writer)
                    self.assertIs(type(repository),repo.DjangoQ0Repository)
                with self.assertRaises(PreparationHold):
                    with repo._bind_trial_transaction(writer,trace):
                        self.fail('second transaction accepted')
            with patch.object(repo.OesEntity.objects,'using') as orm:
                with self.assertRaises(PreparationHold):
                    repository.insert_entity('offline-id',trial.QUESTION_ID,actor)
                orm.assert_not_called()


class OperationalActivationTests(SimpleTestCase):
    env = FirstCommitPrepTests.env

    def test_main_context_is_mode_bound_and_invalidated_on_success_and_exception(self):
        for mode, target in ((trial.COMMIT,'_execute_first_commit'),(trial.RECOVER,'_reconcile_first_commit')):
            for fail in (False,True):
                def operation(sha):
                    self.assertEqual(trial._require_operation(mode,sha),sha)
                    with self.assertRaises(trial._Hold):
                        trial._require_operation(trial.RECOVER if mode==trial.COMMIT else trial.COMMIT,sha)
                    if fail:
                        raise ValueError('offline exception')
                with patch.dict(os.environ,self.env(mode),clear=True), patch.object(trial,'checked_out_sha',return_value='a'*40), patch.object(trial,target,side_effect=operation) as call, redirect_stdout(StringIO()):
                    if fail:
                        with self.assertRaises(ValueError):
                            trial.main([])
                    else:
                        self.assertEqual(trial.main([]),0)
                    call.assert_called_once_with('a'*40)
                    self.assertIsNone(trial._operation.get())
                    with self.assertRaises(trial._Hold):
                        trial._require_operation(mode)

    def test_retired_cp348_issuer_prevents_resubmission_even_with_old_approval(self):
        from evidence import question_orm_q0_repository_dormant as repo
        user=Mock()
        def submit(**kwargs):
            scope=repo._require_restricted_q0_construction()
            self.assertIs(scope.user,user)
            self.assertEqual(scope.command,trial.reserved_command())
            raise PreparationHold('offline uncertain')
        with patch.dict(os.environ,self.env(),clear=True), patch.object(trial,'checked_out_sha',return_value='a'*40), patch('django.setup'), patch('evidence.question_orm_q0_connected_recipe_dormant._review_q0_database_configuration'), patch.object(trial,'_load_reserved_user',return_value=user), patch.object(trial,'_validate_reserved_user',return_value='oes:actor:offline'), patch('evidence.question_preparation.register_authenticated_q0',side_effect=submit) as service, redirect_stdout(StringIO()) as output:
            with self.assertRaisesRegex(trial._Hold,trial.INCONCLUSIVE):
                trial.main([])
            service.assert_not_called()
            self.assertIsNone(repo._trial_scope.get())
            self.assertIsNone(trial._operation.get())
            self.assertIn('INDETERMINATE',output.getvalue())

    def test_retired_recovery_approval_cannot_open_application_reader(self):
        from evidence import question_orm_q0_repository_dormant as repo
        from evidence.question_orm_q0_evidence_dormant import _require_q0_read_recovery_source_activation as gate
        def recover(sha):
            with self.assertRaises(PreparationHold):
                gate(user=Mock(),command=trial.reserved_command())
            with self.assertRaises(PreparationHold):
                gate(user=Mock(),command=None)
            with self.assertRaises(PreparationHold):
                with repo._first_trial_scope(sha=sha,user=Mock(),command=trial.reserved_command()):
                    self.fail('reader issued writer scope')
            self.assertIsNone(repo._trial_scope.get())
        with patch.dict(os.environ,self.env(trial.RECOVER),clear=True), patch.object(trial,'checked_out_sha',return_value='a'*40), patch.object(trial,'_validate_reserved_user',return_value='oes:actor:offline'), patch.object(trial,'_reconcile_first_commit',side_effect=recover), redirect_stdout(StringIO()):
            trial.main([])

    def test_workflow_job_predicates_mutually_exclusive_and_fail_closed(self):
        expressions=re.findall(r'    if: \$\{\{ (.*?) \}\}',WORKFLOW.read_text())
        self.assertEqual(len(expressions),2)
        def eligible(expression,env):
            values={'github.event_name':env['GITHUB_EVENT_NAME'],'github.repository':env['GITHUB_REPOSITORY'],
                'github.ref':env['GITHUB_REF'],'github.run_attempt':int(env['GITHUB_RUN_ATTEMPT']),
                'github.sha':env['GITHUB_SHA'],'inputs.mode':env['OES_Q0_FIRST_MODE'],
                'inputs.approved_sha':env['OES_Q0_FIRST_REQUESTED_SHA'],
                'vars.OES_Q0_FIRST_APPROVED_SHA':env['OES_Q0_FIRST_APPROVED_SHA'],
                'vars.OES_Q0_FIRST_AUTHORIZATION':env['OES_Q0_FIRST_AUTHORIZATION']}
            expression=expression.replace('&&',' and ')
            for key in sorted(values,key=len,reverse=True):
                expression=expression.replace(key,repr(values[key]))
            return eval(expression,{'__builtins__':{},'format':lambda template,arg:template.format(arg)})
        for mode,expected in ((trial.COMMIT,[True,False]),(trial.RECOVER,[False,True])):
            env=self.env(mode)
            self.assertEqual([eligible(e,env) for e in expressions],expected)
            for key,value in (('GITHUB_RUN_ATTEMPT','2'),('GITHUB_EVENT_NAME','push'),('GITHUB_REF','refs/heads/other'),('GITHUB_REPOSITORY','other/repo'),('OES_Q0_FIRST_REQUESTED_SHA','b'*40),('OES_Q0_FIRST_APPROVED_SHA','b'*40),('OES_Q0_FIRST_AUTHORIZATION','invalid'),('OES_Q0_FIRST_MODE',trial.REVIEW)):
                self.assertEqual([eligible(e,{**env,key:value}) for e in expressions],[False,False])

    def test_module_execution_uses_same_canonical_context_owner(self):
        import runpy
        with patch.object(trial,'entrypoint',return_value=0) as entry:
            with self.assertRaises(SystemExit) as exit:
                runpy.run_module('scripts.q0_general_first_commit',run_name='__main__')
            self.assertEqual(exit.exception.code,0)
            entry.assert_called_once()

    def test_old_readonly_mode_cannot_replace_mb_oc1_release(self):
        from evidence import question_orm_q0_repository_dormant as repo
        user=Mock(username=trial.USERNAME,is_authenticated=True,is_active=True,is_staff=False,is_superuser=False)
        user.has_perm.return_value=True
        user.has_usable_password.return_value=False
        with patch.dict(os.environ,self.env(trial.RECOVER),clear=True), patch.object(trial,'checked_out_sha',return_value='a'*40), patch('django.setup'), patch('django.conf.settings.DATABASES',{'default':{},'oes_synthetic_reader':{}}), patch('evidence.question_orm_q0_connected_recipe_dormant._review_q0_reader_configuration'), patch.object(trial,'_load_reserved_user',return_value=user), patch('preparer_identity.resolver.persisted_preparer_actor_id',return_value='oes:actor:offline'), patch('evidence.question_orm_q0_evidence_dormant._collect_q0_commit_evidence',return_value={'outcome':'INDETERMINATE','scope':'Q0_RECORDS','automatic_retry':False}) as collect, patch('evidence.question_preparation.register_authenticated_q0',side_effect=AssertionError('writer invoked')) as submit, redirect_stdout(StringIO()) as output:
            with self.assertRaises(PreparationHold):
                trial.main([])
            collect.assert_not_called()
            submit.assert_not_called()
            self.assertIsNone(repo._trial_scope.get())
            self.assertIsNone(trial._operation.get())
