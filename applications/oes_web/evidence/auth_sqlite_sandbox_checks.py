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
