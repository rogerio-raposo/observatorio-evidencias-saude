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
