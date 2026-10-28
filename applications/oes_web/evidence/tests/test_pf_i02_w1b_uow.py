"""W1B: transactional fake validates adapter protocol without SQL or Neon."""
from copy import deepcopy
from unittest.mock import Mock
from django.test import SimpleTestCase
from evidence.question_preparation import QuestionCommand, PreparationConflict, PreparationHold, submit_question_command
from evidence.question_uow_offline import OfflineQuestionUnitOfWork

class FakePort:
    def __init__(self):
        self.questions={}; self.receipts={}; self.fail_commit=False
    def begin(self):
        return FakeTransaction(self)
class FakeTransaction:
    def __init__(self,port): self.port=port
    def __enter__(self):
        self.questions=deepcopy(self.port.questions)
        self.receipts=deepcopy(self.port.receipts)
        return self
    def __exit__(self,t,v,tb):
        if t is None:
            if self.port.fail_commit:
                raise TimeoutError("simulated uncertain commit")
            self.port.questions=self.questions
            self.port.receipts=self.receipts
        return False
    def lock_request(self,actor,req): pass
    def find_receipt(self,actor,req): return self.receipts.get((actor,req))
    def current_question(self,qid,actor,lock):
        state=self.questions.get(qid)
        return deepcopy(state) if state and state["actor"]==actor else None
    def can_access_question(self,qid,actor):
        state=self.questions.get(qid)
        return bool(state and state["actor"]==actor)
    def register_q0(self,c,actor):
        self.questions[c.question_id]={"actor":actor,"version":1,"original_text":c.original_text,"normalized_text":None}
    def propose_q1(self,c,actor):
        self.questions[c.question_id].update(version=c.expected_version+1,normalized_text=c.normalized_text)
    def save_receipt(self,r): self.receipts[(r.actor_id,r.request_id)]=r

class OfflineUnitOfWorkTests(SimpleTestCase):
    def setUp(self):
        self.port=FakePort()
        self.backend=OfflineQuestionUnitOfWork(self.port)
        self.user=Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=5)
        self.user.has_perm.return_value=True
        self.q0=QuestionCommand("request-a","OES-Q-SYN",0,"Pergunta sintética?")
    def send(self,c,who=None):
        return submit_question_command(user=who or self.user,command=c,unit_of_work=self.backend)
    def test_q0_q1_and_original_preserved(self):
        self.assertEqual(self.send(self.q0)["version"],1)
        q1=QuestionCommand("request-b","OES-Q-SYN",1,"Pergunta sintética?","Pergunta sintética normalizada","justificativa")
        self.assertEqual(self.send(q1)["version"],2)
        self.assertEqual(self.port.questions["OES-Q-SYN"]["original_text"],self.q0.original_text)
        self.assertEqual(len(self.port.receipts),2)
        receipt=self.port.receipts[("5","request-b")]
        self.assertEqual(receipt.command_kind,"PROPOSE_Q1")
        self.assertEqual(receipt.justification,"justificativa")
    def test_replay_returns_same_receipt(self):
        first=self.send(self.q0)
        self.assertEqual(self.send(self.q0),first)
        self.assertEqual(len(self.port.receipts),1)
    def test_request_key_reuse_with_different_payload_denied(self):
        self.send(self.q0)
        altered=QuestionCommand("request-a","OES-Q-SYN",0,"Texto diferente")
        with self.assertRaises(PreparationConflict):self.send(altered)
        self.assertEqual(len(self.port.receipts),1)
    def test_stale_version_rejected(self):
        self.send(self.q0)
        stale=QuestionCommand("request-b","OES-Q-SYN",3,"Pergunta sintética?","Q1","motivo")
        with self.assertRaises(PreparationConflict):self.send(stale)
        self.assertEqual(self.port.questions["OES-Q-SYN"]["version"],1)
    def test_cross_actor_denied(self):
        self.send(self.q0)
        stranger=Mock(is_authenticated=True, is_active=True, is_staff=False, is_superuser=False, pk=6)
        stranger.has_perm.return_value=True
        q1=QuestionCommand("request-c","OES-Q-SYN",1,"Pergunta sintética?","Q1","motivo")
        with self.assertRaises(PreparationConflict): self.send(q1,who=stranger)
    def test_atomic_rollback_on_commit_failure(self):
        self.port.fail_commit=True
        with self.assertRaisesRegex(PreparationHold,"outcome uncertain"): self.send(self.q0)
        self.assertEqual(self.port.questions,{})
        self.assertEqual(self.port.receipts,{})
    def test_q0_rejects_nonzero_revision(self):
        c=QuestionCommand("request-x","OES-Q-SYN",1,"Pergunta sintética?")
        with self.assertRaises(PreparationHold):self.send(c)
    def test_anonymous_denied_before_transaction(self):
        anonymous=Mock(is_authenticated=False,pk=None)
        from django.core.exceptions import PermissionDenied
        with self.assertRaises(PermissionDenied):self.send(self.q0,who=anonymous)
        self.assertEqual(self.port.questions,{})

    def test_replay_denied_after_scope_revoked(self):
        self.send(self.q0)
        self.port.questions["OES-Q-SYN"]["actor"]="different"
        with self.assertRaises(PreparationConflict): self.send(self.q0)

    def test_replay_old_request_after_q1(self):
        self.send(self.q0)
        self.send(QuestionCommand("request-b","OES-Q-SYN",1,"Pergunta sintética?","Q1","motivo"))
        self.assertEqual(self.send(self.q0)["version"],1)

    def test_question_request_id_length_rejected(self):
        with self.assertRaises(PreparationHold):
            self.send(QuestionCommand("x"*129,"OES-Q-SYN",0,"Pergunta sintética?"))


class StablePreparerIdentityContractTests(SimpleTestCase):
    def test_explicit_uuid_is_stable_across_user_reloads(self):
        from uuid import UUID
        from evidence.preparer_actor_identity import preparer_actor_id
        first = Mock(pk=1, username="initial", oes_actor_uuid=UUID("f1234567-89ab-4cde-8fab-123456789abc"))
        reloaded = Mock(pk=987, username="renamed", oes_actor_uuid=first.oes_actor_uuid)
        self.assertEqual(preparer_actor_id(first), preparer_actor_id(reloaded))
        self.assertEqual(preparer_actor_id(first), "oes:actor:f1234567-89ab-4cde-8fab-123456789abc")

    def test_missing_invalid_or_transient_identity_fails_closed(self):
        from uuid import UUID
        from evidence.preparer_actor_identity import preparer_actor_id
        for value in (None, "f1234567-89ab-4cde-8fab-123456789abc", 5, UUID(int=0), UUID("00000000-0000-1000-8000-000000000001")):
            with self.subTest(value=value), self.assertRaises(PreparationHold):
                preparer_actor_id(Mock(pk=42, oes_actor_uuid=value))

    def test_distinct_uuid_yields_distinct_actors(self):
        from uuid import UUID
        from evidence.preparer_actor_identity import preparer_actor_id
        a = preparer_actor_id(Mock(oes_actor_uuid=UUID("f1234567-89ab-4cde-8fab-123456789abc")))
        b = preparer_actor_id(Mock(oes_actor_uuid=UUID("a1234567-89ab-4cde-8fab-123456789abc")))
        self.assertNotEqual(a, b)


class AuthenticatedQ0HttpBoundaryTests(SimpleTestCase):
    """Guard against accidentally exposing the historical user.pk path in HTTP."""
    def test_no_http_route_exposes_q0_service_or_writer(self):
        from django.urls import get_resolver
        from evidence.question_preparation import (
            submit_question_command, submit_authenticated_question_command,
        )
        from evidence.question_orm_q0_dormant import DormantQ0OrmPort
        from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
        patterns = get_resolver().url_patterns
        callbacks = []
        def walk(items):
            for item in items:
                if hasattr(item, "url_patterns"):
                    walk(item.url_patterns)
                else:
                    callbacks.append(item.callback)
        walk(patterns)
        forbidden = {
            submit_question_command,
            submit_authenticated_question_command,
            DormantQ0OrmPort,
            DjangoQ0Repository,
        }
        self.assertTrue(callbacks)
        self.assertTrue(forbidden.isdisjoint(callbacks))
        # No route imports the legacy command service or dormant writer.
        import inspect
        for view in callbacks:
            module = inspect.getmodule(view)
            if module is not None and module.__name__.startswith("evidence."):
                namespace = vars(module)
                for name in ("submit_question_command", "submit_authenticated_question_command",
                             "DjangoQ0Repository", "DormantQ0OrmPort"):
                    self.assertNotIn(name, namespace, module.__name__)

    def test_strict_authenticated_service_requires_injected_backend(self):
        from unittest.mock import Mock
        from evidence.question_preparation import (
            QuestionCommand, PreparationHold, submit_authenticated_question_command,
        )
        user = Mock(is_authenticated=True, is_active=True, is_staff=False,
                    is_superuser=False, pk=1)
        user.has_perm.return_value = True
        with self.assertRaisesRegex(PreparationHold, "persistence unavailable"):
            submit_authenticated_question_command(
                user=user,
                command=QuestionCommand("boundary", "OES-SYNTH-BOUNDARY", 0, "Pergunta?"),
            )


class AuthPostgresDesignBoundaryTests(SimpleTestCase):
    def test_single_database_auth_design_never_connects_or_enables_sql(self):
        from django.conf import settings
        from importlib import import_module
        design = import_module("config.settings_auth_pg_design")
        self.assertEqual(design.AUTH_SCHEMA, "django_auth")
        self.assertEqual(design.DATABASES["default"]["ENGINE"], "django.db.backends.dummy")
        self.assertEqual(design.DATABASES["oes_scientific_hold"]["ENGINE"], "django.db.backends.dummy")
        self.assertNotIn("oes_synthetic_reader", design.DATABASES)
        self.assertIn("preparer_identity", design.INSTALLED_APPS)
        self.assertIn("config.auth_sandbox_router.AuthSandboxRouter", design.DATABASE_ROUTERS)
        self.assertNotIn("preparer_identity", settings.INSTALLED_APPS)


class PostgresAuthMigrationSqlOfflineTests(SimpleTestCase):
    def test_preparer_identity_postgres_ddl_compiles_without_connecting(self):
        from django.db.backends.postgresql.base import DatabaseWrapper
        from preparer_identity.migrations import __path__ as migration_path
        from django.db.migrations.loader import MigrationLoader
        from unittest.mock import patch
        from django.conf import settings
        self.assertTrue(migration_path)
        # Migration graph is read from local Python files only; never a DB.
        with self.settings(INSTALLED_APPS=[*settings.INSTALLED_APPS, "preparer_identity"]):
            from preparer_identity.models import PreparerIdentity
            graph = MigrationLoader(None).graph
            self.assertIn(("preparer_identity", "0001_initial"), graph.nodes)
            wrapper = DatabaseWrapper({
                "ENGINE": "django.db.backends.postgresql",
                "NAME": "offline_no_connection",
                "USER": "", "PASSWORD": "", "HOST": "", "PORT": "",
                "OPTIONS": {}, "TIME_ZONE": None, "CONN_MAX_AGE": 0,
                "CONN_HEALTH_CHECKS": False, "AUTOCOMMIT": True,
                "ATOMIC_REQUESTS": False, "TEST": {},
            }, alias="offline_ddl_only")
            with patch.object(wrapper, "ensure_connection", side_effect=AssertionError("network prohibited")):
                with wrapper.schema_editor(collect_sql=True, atomic=False) as editor:
                    editor.create_model(PreparerIdentity)
                ddl = "\n".join(editor.collected_sql)
            self.assertIn('"preparer_identity_prepareridentity"', ddl)
            self.assertIn('"actor_uuid"', ddl)
            self.assertIn("UNIQUE", ddl.upper())
            self.assertIn("REFERENCES", ddl.upper())
            self.assertNotIn("CREATE SCHEMA", ddl.upper())


class NativeDjangoPostgresSchemaPlanTests(SimpleTestCase):
    def test_native_auth_session_and_identity_models_generate_postgres_ddl_offline(self):
        from django.contrib.auth import get_user_model
        from django.contrib.auth.models import Group, Permission
        from django.contrib.contenttypes.models import ContentType
        from django.contrib.sessions.models import Session
        from django.db.backends.postgresql.base import DatabaseWrapper
        from unittest.mock import patch
        from preparer_identity.models import PreparerIdentity

        wrapper = DatabaseWrapper({
            "ENGINE": "django.db.backends.postgresql",
            "NAME": "offline_no_connection",
            "USER": "", "PASSWORD": "", "HOST": "", "PORT": "",
            "OPTIONS": {}, "TIME_ZONE": None, "CONN_MAX_AGE": 0,
            "CONN_HEALTH_CHECKS": False, "AUTOCOMMIT": True,
            "ATOMIC_REQUESTS": False, "TEST": {},
        }, alias="offline_auth_schema_ddl")
        with patch.object(wrapper, "ensure_connection", side_effect=AssertionError("network prohibited")):
            with wrapper.schema_editor(collect_sql=True, atomic=False) as editor:
                for model in (ContentType, Permission, Group, get_user_model(), Session, PreparerIdentity):
                    editor.create_model(model)
            ddl = "\n".join(editor.collected_sql)
        for table in ("django_content_type", "auth_permission", "auth_group",
                      "auth_user", "django_session", "preparer_identity_prepareridentity"):
            self.assertIn('"' + table + '"', ddl)
        self.assertIn("REFERENCES", ddl.upper())
        self.assertIn("CREATE INDEX", ddl.upper())
        self.assertNotIn("CREATE SCHEMA", ddl.upper())
        self.assertNotIn("oes_sandbox.", ddl)
        # Unqualified DDL depends on search_path; schema setup needs a separate gate.
        self.assertNotIn('"django_auth".', ddl)
