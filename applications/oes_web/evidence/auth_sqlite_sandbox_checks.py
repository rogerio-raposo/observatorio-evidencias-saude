"""Native Django auth/session integration in disposable SQLite, no Neon."""
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.core.exceptions import PermissionDenied
from django.test import TestCase

from evidence.preparation_auth import require_question_preparer


class AuthSQLiteSandboxTests(TestCase):
    def setUp(self):
        user_model = get_user_model()
        self.user = user_model.objects.create_user(
            username="oes_synthetic_preparer", password="synthetic-only-not-a-secret"
        )
        content_type = ContentType.objects.get(
            app_label="evidence", model="oesquestion"
        )
        self.permission = Permission.objects.create(
            content_type=content_type, codename="prepare_question",
            name="Prepare a question (sandbox only)"
        )

    def test_login_and_explicit_permission(self):
        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer",
            password="synthetic-only-not-a-secret"
        ))
        with self.assertRaises(PermissionDenied):
            require_question_preparer(self.user)
        self.user.user_permissions.add(self.permission)
        self.user = get_user_model().objects.get(pk=self.user.pk)
        self.assertTrue(require_question_preparer(self.user))
        self.assertEqual(str(self.user.pk), str(self.client.session["_auth_user_id"]))

    def test_staff_role_denied_even_with_permission(self):
        self.user.user_permissions.add(self.permission)
        self.user.is_staff = True
        self.user.save(update_fields=["is_staff"])
        with self.assertRaises(PermissionDenied):
            require_question_preparer(self.user)

    def test_anonymous_denied(self):
        with self.assertRaises(PermissionDenied):
            require_question_preparer(self.client.get("/synthetic-q0-preview/").wsgi_request.user)

    def test_authenticated_preparer_executes_q0_with_fake_uow_and_replays(self):
        from evidence.question_preparation import QuestionCommand, submit_question_command
        from evidence.question_uow_offline import OfflineQuestionUnitOfWork
        from evidence.tests.test_pf_i02_w1b_uow import FakePort

        self.user.user_permissions.add(self.permission)
        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer",
            password="synthetic-only-not-a-secret",
        ))
        authenticated_user = get_user_model().objects.get(
            pk=self.client.session["_auth_user_id"]
        )
        command = QuestionCommand(
            "sqlite-auth-q0-1", "OES-SYNTH-Q0-SQLITE-AUTH", 0,
            "Pergunta fictícia para validar autorização e transação simulada?",
        )
        fake_port = FakePort()
        uow = OfflineQuestionUnitOfWork(fake_port)
        first = submit_question_command(
            user=authenticated_user, command=command, unit_of_work=uow,
        )
        replay = submit_question_command(
            user=authenticated_user, command=command, unit_of_work=uow,
        )
        self.assertEqual(first, replay)
        self.assertEqual(first["version"], 1)
        self.assertEqual(len(fake_port.questions), 1)
        self.assertEqual(len(fake_port.receipts), 1)
        self.assertEqual(
            fake_port.receipts[(str(authenticated_user.pk), command.request_id)].actor_id,
            str(authenticated_user.pk),
        )

    def test_authenticated_without_permission_cannot_start_fake_uow(self):
        from evidence.question_preparation import QuestionCommand, submit_question_command
        from evidence.question_uow_offline import OfflineQuestionUnitOfWork
        from evidence.tests.test_pf_i02_w1b_uow import FakePort

        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer",
            password="synthetic-only-not-a-secret",
        ))
        authenticated_user = get_user_model().objects.get(
            pk=self.client.session["_auth_user_id"]
        )
        fake_port = FakePort()
        with self.assertRaises(PermissionDenied):
            submit_question_command(
                user=authenticated_user,
                command=QuestionCommand(
                    "sqlite-auth-q0-denied", "OES-SYNTH-Q0-DENIED", 0,
                    "Pergunta fictícia não autorizada?",
                ),
                unit_of_work=OfflineQuestionUnitOfWork(fake_port),
            )
        self.assertEqual(fake_port.questions, {})
        self.assertEqual(fake_port.receipts, {})

    def test_q0_http_access_anonymous_and_post_are_blocked(self):
        from django.urls import reverse
        endpoint = reverse("q0-access-status")
        response = self.client.get(endpoint)
        self.assertEqual(response.status_code, 403)
        self.assertEqual(response.json(), {"status": "HOLD", "q0_write_enabled": False})
        self.assertEqual(self.client.post(endpoint).status_code, 404)

    def test_q0_http_access_requires_explicit_permission(self):
        from django.urls import reverse
        endpoint = reverse("q0-access-status")
        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer", password="synthetic-only-not-a-secret"))
        self.assertEqual(self.client.get(endpoint).status_code, 403)
        self.user.user_permissions.add(self.permission)
        response = self.client.get(endpoint)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {
            "status": "AUTHORIZED_SYNTHETIC_SCOPE_ONLY", "q0_write_enabled": False,
        })

    def test_http_request_to_authorized_q0_service_with_fake_transaction(self):
        """Real Django request auth; command execution remains an injected offline fake."""
        from django.test import RequestFactory
        from django.contrib.auth.middleware import AuthenticationMiddleware
        from django.contrib.sessions.middleware import SessionMiddleware
        from django.http import JsonResponse
        from evidence.question_preparation import QuestionCommand, submit_question_command
        from evidence.question_uow_offline import OfflineQuestionUnitOfWork
        from evidence.tests.test_pf_i02_w1b_uow import FakePort

        self.user.user_permissions.add(self.permission)
        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer",
            password="synthetic-only-not-a-secret",
        ))
        fake = FakePort()
        command = QuestionCommand(
            "request-http-synthetic", "OES-SYNTH-Q0-HTTP-FAKE", 0,
            "Pergunta sintética da requisição de teste?",
        )

        def test_only_view(request):
            outcome = submit_question_command(
                user=request.user, command=command,
                unit_of_work=OfflineQuestionUnitOfWork(fake),
            )
            return JsonResponse(outcome)

        request = RequestFactory().get("/test-only/q0-injection/")
        request.COOKIES.update({name: morsel.value for name, morsel in self.client.cookies.items()})
        SessionMiddleware(lambda req: None).process_request(request)
        AuthenticationMiddleware(lambda req: None).process_request(request)
        response = test_only_view(request)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(__import__("json").loads(response.content)["version"], 1)
        self.assertEqual(len(fake.questions), 1)
        self.assertEqual(len(fake.receipts), 1)
        self.assertNotIn("/test-only/q0-injection/", [
            "/synthetic-q0-access/", "/synthetic-q0-preview/",
        ])

    def test_auth_and_scientific_aliases_are_isolated(self):
        from django.db import connections
        self.assertEqual(connections["default"].vendor, "sqlite")
        self.assertEqual(connections["oes_scientific_hold"].vendor, "unknown")
        self.assertIsNone(connections["oes_scientific_hold"].connection)
        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer",
            password="synthetic-only-not-a-secret",
        ))
        self.assertIsNone(connections["oes_scientific_hold"].connection)

    def test_optional_scientific_reader_disabled_without_credentials(self):
        from django.conf import settings
        from django.db import connections
        self.assertNotIn("oes_synthetic_reader", settings.DATABASES)
        self.assertEqual(connections["oes_scientific_hold"].vendor, "unknown")
        self.assertIsNone(connections["oes_scientific_hold"].connection)

    def test_authenticated_session_and_synthetic_scientific_read_same_app(self):
        """Full Django GET through SQLite session and mocked PG read only."""
        from unittest.mock import patch
        from uuid import UUID
        from django.urls import reverse
        from django.db import connections
        from evidence.synthetic_pg_reader import SyntheticStudyReportLink

        self.user.user_permissions.add(self.permission)
        self.assertTrue(self.client.login(
            username="oes_synthetic_preparer",
            password="synthetic-only-not-a-secret",
        ))
        self.assertEqual(self.client.get(reverse("q0-access-status")).status_code, 200)
        link = SyntheticStudyReportLink(
            UUID(int=1), UUID(int=2), UUID(int=3), UUID(int=4),
            "reports", UUID(int=5), "title",
        )
        with patch(
            "evidence.synthetic_pg_presentation.list_synthetic_study_report_links",
            return_value=(link,),
        ) as reader:
            response = self.client.get(reverse("synthetic-pg-links"))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, str(UUID(int=1)))
        reader.assert_called_once_with()
        self.assertIsNone(connections["oes_scientific_hold"].connection)
        self.assertNotIn("oes_synthetic_reader", connections.databases)
        self.assertEqual(self.client.post(reverse("q0-access-status")).status_code, 404)

    def test_persisted_actor_id_survives_user_rename_and_reload(self):
        from preparer_identity.models import PreparerIdentity
        from preparer_identity.resolver import persisted_preparer_actor_id
        identity = PreparerIdentity.objects.create(user=self.user)
        original = persisted_preparer_actor_id(self.user)
        self.assertEqual(original, "oes:actor:" + str(identity.actor_uuid))
        self.user.username = "renamed_synthetic_preparer"
        self.user.save(update_fields=["username"])
        reloaded = get_user_model().objects.get(pk=self.user.pk)
        self.assertEqual(persisted_preparer_actor_id(reloaded), original)

    def test_persisted_actor_missing_and_duplicate_user_are_rejected(self):
        from django.db import IntegrityError, transaction
        from evidence.question_preparation import PreparationHold
        from preparer_identity.models import PreparerIdentity
        from preparer_identity.resolver import persisted_preparer_actor_id
        with self.assertRaises(PreparationHold):
            persisted_preparer_actor_id(self.user)
        PreparerIdentity.objects.create(user=self.user)
        with self.assertRaises(IntegrityError):
            with transaction.atomic():
                PreparerIdentity.objects.create(user=self.user)
        self.assertTrue(persisted_preparer_actor_id(self.user).startswith("oes:actor:"))

    def test_persisted_identity_reaches_q0_receipt_and_replays(self):
        from evidence.question_preparation import QuestionCommand, submit_question_command
        from evidence.question_uow_offline import OfflineQuestionUnitOfWork
        from evidence.tests.test_pf_i02_w1b_uow import FakePort
        from preparer_identity.models import PreparerIdentity
        from preparer_identity.resolver import persisted_preparer_actor_id

        self.user.user_permissions.add(self.permission)
        identity = PreparerIdentity.objects.create(user=self.user)
        command = QuestionCommand(
            "stable-actor-request", "OES-SYNTH-STABLE-ACTOR", 0,
            "Pergunta sintética com identidade estável?",
        )
        port = FakePort()
        backend = OfflineQuestionUnitOfWork(port)
        def send():
            return submit_question_command(
                user=self.user, command=command, unit_of_work=backend,
                actor_id_resolver=persisted_preparer_actor_id,
            )
        original = send()
        self.user.username = "renamed_preparer"
        self.user.save(update_fields=["username"])
        self.user = get_user_model().objects.get(pk=self.user.pk)
        self.assertEqual(send(), original)
        stable = "oes:actor:" + str(identity.actor_uuid)
        self.assertIn((stable, command.request_id), port.receipts)
        self.assertNotIn((str(self.user.pk), command.request_id), port.receipts)
        self.assertEqual(len(port.questions), 1)

    def test_persisted_identity_missing_blocks_q0_before_transaction(self):
        from evidence.question_preparation import QuestionCommand, PreparationHold, submit_question_command
        from evidence.question_uow_offline import OfflineQuestionUnitOfWork
        from evidence.tests.test_pf_i02_w1b_uow import FakePort
        from preparer_identity.resolver import persisted_preparer_actor_id

        self.user.user_permissions.add(self.permission)
        port = FakePort()
        with self.assertRaisesRegex(PreparationHold, "persistent preparer identity"):
            submit_question_command(
                user=self.user,
                command=QuestionCommand("missing-actor", "OES-SYNTH-MISSING", 0, "Pergunta sintética?"),
                unit_of_work=OfflineQuestionUnitOfWork(port),
                actor_id_resolver=persisted_preparer_actor_id,
            )
        self.assertFalse(port.questions)
        self.assertFalse(port.receipts)

    def test_strict_authenticated_q0_requires_persisted_actor(self):
        from evidence.question_preparation import (
            QuestionCommand, PreparationHold, submit_authenticated_question_command,
        )
        from evidence.question_uow_offline import OfflineQuestionUnitOfWork
        from evidence.tests.test_pf_i02_w1b_uow import FakePort
        from preparer_identity.models import PreparerIdentity

        self.user.user_permissions.add(self.permission)
        command = QuestionCommand("strict-request", "OES-SYNTH-STRICT", 0, "Pergunta sintética?")
        port = FakePort()
        uow = OfflineQuestionUnitOfWork(port)
        with self.assertRaisesRegex(PreparationHold, "persistent preparer identity"):
            submit_authenticated_question_command(user=self.user, command=command, unit_of_work=uow)
        self.assertFalse(port.questions)
        self.assertFalse(port.receipts)

        identity = PreparerIdentity.objects.create(user=self.user)
        result = submit_authenticated_question_command(user=self.user, command=command, unit_of_work=uow)
        self.assertEqual(result["version"], 1)
        self.assertIn(("oes:actor:" + str(identity.actor_uuid), command.request_id), port.receipts)
        self.assertNotIn((str(self.user.pk), command.request_id), port.receipts)
        self.assertEqual(
            submit_authenticated_question_command(user=self.user, command=command, unit_of_work=uow),
            result,
        )

    def test_auth_router_blocks_migrations_on_scientific_aliases(self):
        from django.db import router
        from django.contrib.auth import get_user_model
        from preparer_identity.models import PreparerIdentity
        from evidence.models import OesQuestion
        for alias in ("oes_scientific_hold", "oes_synthetic_reader"):
            for label in ("auth", "contenttypes", "sessions", "preparer_identity", "evidence"):
                self.assertFalse(router.allow_migrate(alias, label))
        self.assertTrue(router.allow_migrate("default", "preparer_identity"))
        self.assertFalse(router.allow_migrate("default", "evidence"))
        self.assertEqual(router.db_for_write(PreparerIdentity), "default")
        self.assertEqual(router.db_for_read(get_user_model()), "default")
        self.assertEqual(router.db_for_write(OesQuestion), "oes_scientific_hold")

    def test_combined_auth_migration_graph_and_post_migrate_permissions(self):
        from django.db.migrations.loader import MigrationLoader
        from django.contrib.auth.models import Permission
        from django.contrib.contenttypes.models import ContentType
        from django.db import router
        from preparer_identity.models import PreparerIdentity

        loader = MigrationLoader(None)
        apps = {"auth", "contenttypes", "sessions", "preparer_identity"}
        leaves = [node for node in loader.graph.leaf_nodes() if node[0] in apps]
        self.assertEqual({node[0] for node in leaves}, apps)
        combined = set()
        for leaf in leaves:
            combined.update(loader.graph.forwards_plan(leaf))
        self.assertEqual({node[0] for node in combined}, apps)
        self.assertIn(("preparer_identity", "0001_initial"), combined)
        self.assertTrue(any(node[0] == "auth" for node in combined))
        self.assertTrue(router.allow_migrate("default", "preparer_identity"))
        self.assertFalse(router.allow_migrate("oes_scientific_hold", "preparer_identity"))

        # Django test setup runs migrate and post_migrate on disposable SQLite.
        self.assertTrue(PreparerIdentity._meta.managed)
        self.assertTrue(PreparerIdentity._meta.db_table.startswith("preparer_identity_"))
        self.assertTrue(ContentType.objects.filter(
            app_label="preparer_identity", model="prepareridentity").exists())
        self.assertTrue(Permission.objects.filter(
            content_type__app_label="preparer_identity",
            codename="add_prepareridentity").exists())
        self.assertTrue(ContentType.objects.filter(
            app_label="evidence", model="oesquestion").exists())

    def test_native_login_updates_only_last_login_column(self):
        """Capture the actual SQL, not an assumption about Django signals."""
        import re
        from django.db import connection
        from django.test.utils import CaptureQueriesContext

        with CaptureQueriesContext(connection) as captured:
            authenticated = self.client.login(
                username="oes_synthetic_preparer",
                password="synthetic-only-not-a-secret",
            )
        self.assertTrue(authenticated)
        updates = [item["sql"] for item in captured.captured_queries
                   if re.search(r'UPDATE\s+["`]?auth_user["`]?\s+SET\s', item["sql"], re.I)]
        self.assertEqual(len(updates), 1, f"Expected exactly one auth_user UPDATE; got {updates}")
        update = updates[0]
        assignments = re.search(r'\bSET\s+(.*?)\s+WHERE\b', update, re.I | re.S)
        self.assertIsNotNone(assignments, update)
        self.assertRegex(assignments.group(1), r'^\s*["`]?last_login["`]?\s*=')
        self.assertNotIn(",", assignments.group(1),
                         "Native login unexpectedly updates multiple auth_user columns")
        self.user.refresh_from_db()
        self.assertIsNotNone(self.user.last_login)


class G2TrialSettingsOfflineTests(TestCase):
    """Only inspect Django settings construction; never connect to Neon."""

    def test_g2_trial_settings_default_and_incomplete_opt_in_hold(self):
        import runpy
        from unittest.mock import patch
        module = "config.settings_auth_pg_g2_trial_optin"
        with patch.dict("os.environ", {}, clear=True):
            with self.assertRaisesRegex(RuntimeError, "HOLD"):
                runpy.run_module(module, run_name="__g2_default__")
        with patch.dict("os.environ", {"OES_AUTH_G2_EXPLICIT_OPT_IN": "1"}, clear=True):
            with self.assertRaisesRegex(RuntimeError, "HOLD"):
                runpy.run_module(module, run_name="__g2_missing__")
        with patch.dict("os.environ", {
            "OES_AUTH_G2_EXPLICIT_OPT_IN": "1",
            "OES_AUTH_G2_HOST": "example.invalid",
            "OES_AUTH_G2_PASSWORD": "offline-placeholder",
        }, clear=True):
            with self.assertRaisesRegex(RuntimeError, "HOLD"):
                runpy.run_module(module, run_name="__g2_wrong_host__")

    def test_g2_trial_settings_isolate_role_schema_and_database(self):
        import runpy
        from unittest.mock import patch
        with patch.dict("os.environ", {
            "OES_AUTH_G2_EXPLICIT_OPT_IN": "1",
            "OES_AUTH_G2_HOST": "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech",
            "OES_AUTH_G2_PASSWORD": "offline-placeholder-not-a-secret",
        }, clear=True):
            cfg = runpy.run_module("config.settings_auth_pg_g2_trial_optin", run_name="__g2_offline__")
        default = cfg["DATABASES"]["default"]
        self.assertEqual(default["USER"], "oes_auth_trial_login")
        self.assertEqual(default["NAME"], "oes_sandbox")
        self.assertEqual(default["OPTIONS"]["options"], "-c search_path=django_auth")
        self.assertEqual(default["CONN_MAX_AGE"], 0)
        self.assertEqual(cfg["DATABASES"]["oes_scientific_hold"]["ENGINE"], "django.db.backends.dummy")
        self.assertEqual(set(cfg["DATABASES"]), {"default", "oes_scientific_hold"})
        self.assertEqual(cfg["DATABASE_ROUTERS"], ["config.auth_sandbox_router.AuthSandboxRouter"])


class G2CatalogueOfflineTests(TestCase):
    def test_g2_exact_acl_and_sequence_drift(self):
        from config.auth_pg_g2_p1_preflight import TABLES, assert_g2_catalogue
        identity = ("oes_sandbox","oes_auth_trial_login","oes_auth_trial_login","django_auth","django_auth",True,False)
        tables = [(name,*rights) for name,rights in TABLES.items()]
        columns = [("id",False),("last_login",True),("password",False)]
        self.assertEqual(assert_g2_catalogue(identity,tables,columns,(9,False)),
                         "PASS_G2_P1_CONNECTED_READ_ONLY")
        with self.assertRaisesRegex(RuntimeError,"HOLD"):
            assert_g2_catalogue(identity,tables,columns,(9,True))
        with self.assertRaisesRegex(RuntimeError,"HOLD"):
            assert_g2_catalogue(identity,tables[:-1],columns,(9,False))


class G2ProvisioningOfflineTests(TestCase):
    """Disposable SQLite rehearsal only; never executed against Neon."""

    def test_single_atomic_provisioning_and_ordered_cleanup(self):
        from django.db import transaction
        from django.db.models.deletion import ProtectedError
        from preparer_identity.models import PreparerIdentity

        baseline = Permission.objects.count()
        with transaction.atomic(using="default"):
            ct = ContentType.objects.get(app_label="evidence", model="oesquestion")
            permission = Permission.objects.create(
                content_type=ct, codename="prepare_question",
                name="Synthetic preparation permission",
            )
            user = get_user_model().objects.create_user(
                username="oes_g2_trial_fixture", password="disposable-test-only",
                is_active=True, is_staff=False, is_superuser=False,
            )
            user.user_permissions.add(permission)
            identity = PreparerIdentity.objects.create(user=user)
        self.assertEqual(Permission.objects.count(), baseline + 1)
        self.assertTrue(user.check_password("disposable-test-only"))
        self.assertNotEqual(user.password, "disposable-test-only")
        self.assertEqual(user.user_permissions.filter(pk=permission.pk).count(), 1)
        self.assertEqual(PreparerIdentity.objects.get(user=user).actor_uuid, identity.actor_uuid)
        with self.assertRaises(ProtectedError):
            user.delete()
        identity.delete()
        user.user_permissions.remove(permission)
        user.delete()
        permission.delete()
        self.assertEqual(Permission.objects.count(), baseline)
        self.assertFalse(get_user_model().objects.filter(username="oes_g2_trial_fixture").exists())
        self.assertFalse(PreparerIdentity.objects.exists())

    def test_atomic_failure_rolls_back_every_synthetic_record(self):
        from django.db import transaction
        from preparer_identity.models import PreparerIdentity

        baseline = Permission.objects.count()
        with self.assertRaisesRegex(RuntimeError, "synthetic failure"):
            with transaction.atomic(using="default"):
                ct = ContentType.objects.get(app_label="evidence", model="oesquestion")
                permission = Permission.objects.create(
                    content_type=ct, codename="prepare_question",
                    name="Synthetic preparation permission",
                )
                user = get_user_model().objects.create_user(
                    username="oes_g2_failure_fixture", password="disposable-test-only",
                )
                user.user_permissions.add(permission)
                PreparerIdentity.objects.create(user=user)
                raise RuntimeError("synthetic failure")
        self.assertEqual(Permission.objects.count(), baseline)
        self.assertFalse(get_user_model().objects.filter(username="oes_g2_failure_fixture").exists())
        self.assertFalse(Permission.objects.filter(codename="prepare_question", content_type__app_label="evidence").exists())
        self.assertFalse(PreparerIdentity.objects.exists())


class G2P2BExecutorOfflineTests(TestCase):
    """Connected adapters must remain absent; only disposable SQLite may mutate."""

    def test_offline_executor_and_postflight(self):
        from config.auth_pg_g2_p2b_offline import provision_offline
        result = provision_offline(password="test-password-only")
        self.assertEqual(result["status"], "PASS_OFFLINE_ONLY")
        self.assertEqual(result["after"]["permissions"], result["before"]["permissions"] + 1)
        self.assertEqual(result["after"]["users"], 1)
        self.assertEqual(result["after"]["identities"], 1)

    def test_offline_executor_rolls_back_on_failure(self):
        from config.auth_pg_g2_p2b_offline import provision_offline, ProvisioningHold
        from preparer_identity.models import PreparerIdentity
        before = (Permission.objects.count(), get_user_model().objects.count())
        with self.assertRaises(ProvisioningHold):
            provision_offline(password="test-password-only", inject_failure=True)
        self.assertEqual((Permission.objects.count(), get_user_model().objects.count()), before)
        self.assertFalse(PreparerIdentity.objects.exists())

    def test_offline_executor_rejects_non_disposable_connection(self):
        from unittest.mock import patch
        from config.auth_pg_g2_p2b_offline import provision_offline, ProvisioningHold
        with patch("config.auth_pg_g2_p2b_offline._offline_guard",
                   side_effect=ProvisioningHold("HOLD: connected forbidden")):
            with self.assertRaises(ProvisioningHold):
                provision_offline(password="test-password-only")

    def test_offline_executor_holds_when_session_baseline_is_not_empty(self):
        from django.contrib.sessions.models import Session
        from datetime import timedelta
        from django.utils import timezone
        from config.auth_pg_g2_p2b_offline import provision_offline, ProvisioningHold
        Session.objects.create(
            session_key="oes_g2_fixture_session",
            session_data="synthetic",
            expire_date=timezone.now() + timedelta(hours=1),
        )
        with self.assertRaisesRegex(ProvisioningHold, "baseline"):
            provision_offline(password="test-password-only")
        self.assertFalse(get_user_model().objects.filter(username="oes_g2_trial_fixture").exists())

    def test_offline_executor_preflight_is_inside_atomic(self):
        from unittest.mock import patch
        from django.db import connections
        from config.auth_pg_g2_p2b_offline import _baseline, provision_offline
        real_baseline = _baseline

        def assert_atomic(using):
            self.assertTrue(connections[using].in_atomic_block)
            return real_baseline(using)

        with patch("config.auth_pg_g2_p2b_offline._baseline", side_effect=assert_atomic):
            result = provision_offline(password="test-password-only")
        self.assertEqual(result["status"], "PASS_OFFLINE_ONLY")

    def test_connected_contract_is_pure_and_rejects_unapproved_scope(self):
        from config.auth_pg_g2_p2b_offline import (
            CONNECTED_BASELINE, ProvisioningHold, validate_connected_contract
        )
        kwargs = dict(
            role="oes_auth_migrator", database="oes_sandbox",
            schema="django_auth", baseline=dict(CONNECTED_BASELINE)
        )
        with self.assertRaisesRegex(ProvisioningHold, "authorization"):
            validate_connected_contract(approved=False, **kwargs)
        with self.assertRaisesRegex(ProvisioningHold, "identity"):
            validate_connected_contract(approved=True, **{**kwargs, "role": "postgres"})
        with self.assertRaisesRegex(ProvisioningHold, "baseline"):
            validate_connected_contract(approved=True, **{
                **kwargs, "baseline": {**CONNECTED_BASELINE, "permissions": 43}
            })
        self.assertEqual(
            validate_connected_contract(approved=True, **kwargs),
            "CONTRACT_VALIDATED_OFFLINE_NOT_AUTHORIZED_TO_EXECUTE",
        )

    def test_connected_contract_postflight_is_exact(self):
        from config.auth_pg_g2_p2b_offline import (
            CONNECTED_BASELINE, CONNECTED_POSTFLIGHT,
            ProvisioningHold, validate_connected_contract
        )
        kwargs = dict(
            approved=True, role="oes_auth_migrator", database="oes_sandbox",
            schema="django_auth", baseline=dict(CONNECTED_BASELINE)
        )
        with self.assertRaisesRegex(ProvisioningHold, "postflight"):
            validate_connected_contract(
                **kwargs, postflight={**CONNECTED_POSTFLIGHT, "sessions": 1}
            )
        self.assertEqual(
            validate_connected_contract(**kwargs, postflight=dict(CONNECTED_POSTFLIGHT)),
            "CONTRACT_VALIDATED_OFFLINE_NOT_AUTHORIZED_TO_EXECUTE",
        )

    def test_g2_p2b_admin_settings_cannot_be_enabled_by_environment(self):
        from importlib import import_module
        from unittest.mock import patch
        with patch.dict("os.environ", {
            "OES_AUTH_G2_P2B_EXPLICIT_OPT_IN": "1",
            "OES_AUTH_B2_EXPLICIT_OPT_IN": "1",
        }):
            with self.assertRaisesRegex(RuntimeError, "HOLD: G2-P2-B"):
                import_module("config.settings_auth_pg_g2_p2b_dormant")
