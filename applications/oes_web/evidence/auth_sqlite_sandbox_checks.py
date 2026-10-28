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
