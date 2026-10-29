"""Synthetic Django test-client session and permission matrix, SQLite only."""
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.core.exceptions import PermissionDenied
from django.http import HttpResponse
from django.test import TestCase, override_settings
from django.urls import path
from evidence.preparation_auth import require_question_preparer


def probe(request):
    try:
        require_question_preparer(request.user)
    except PermissionDenied:
        return HttpResponse(status=403)
    return HttpResponse("ALLOWED", status=200)


urlpatterns = [path("_offline_preparer_probe/", probe)]


@override_settings(ROOT_URLCONF=__name__)
class PreparerSessionMatrixTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        ct, _ = ContentType.objects.get_or_create(app_label="evidence", model="oesquestion")
        cls.permission, _ = Permission.objects.get_or_create(
            content_type=ct, codename="prepare_question",
            defaults={"name": "Can prepare an OES question"})
        cls.users = {}
        User = get_user_model()
        for label, flags in (
            ("allowed", {}),
            ("no_permission", {}),
            ("inactive", {"is_active": False}),
            ("staff", {"is_staff": True}),
            ("superuser", {"is_superuser": True}),
        ):
            u = User.objects.create(username="oes_offline_"+label, **flags)
            u.set_unusable_password()
            u.save(update_fields=["password"])
            if label != "no_permission":
                u.user_permissions.add(cls.permission)
            cls.users[label] = u

    def test_anonymous_denied(self):
        self.assertEqual(self.client.get("/_offline_preparer_probe/").status_code, 403)

    def test_session_permission_matrix(self):
        for label, expected in (
            ("allowed", 200),
            ("no_permission", 403),
            ("inactive", 403),
            ("staff", 403),
            ("superuser", 403),
        ):
            with self.subTest(label=label):
                self.client.logout()
                self.client.force_login(self.users[label])
                self.assertEqual(self.client.get("/_offline_preparer_probe/").status_code, expected)

    def test_unusable_password_never_authenticates(self):
        from django.contrib.auth import authenticate
        self.assertFalse(self.users["allowed"].has_usable_password())
        self.assertIsNone(authenticate(username="oes_offline_allowed", password="not-a-real-secret"))

    def test_persisted_actor_binding_is_derived_from_authenticated_user(self):
        from uuid import uuid4
        from preparer_identity.models import PreparerIdentity
        from preparer_identity.resolver import persisted_preparer_actor_id
        user = self.users["allowed"]
        actor = uuid4()
        PreparerIdentity.objects.create(user=user, actor_uuid=actor)
        self.assertEqual(persisted_preparer_actor_id(user), "oes:actor:" + str(actor))
        # Caller attributes are not trusted as an alternative identity.
        user.oes_actor_uuid = uuid4()
        self.assertEqual(persisted_preparer_actor_id(user), "oes:actor:" + str(actor))

    def test_persisted_actor_binding_rejects_missing_or_foreign_identity(self):
        from uuid import uuid4
        from preparer_identity.models import PreparerIdentity
        from preparer_identity.resolver import persisted_preparer_actor_id
        from evidence.question_preparation import PreparationHold
        user = self.users["allowed"]
        other = self.users["no_permission"]
        PreparerIdentity.objects.create(user=other, actor_uuid=uuid4())
        with self.assertRaises(PreparationHold):
            persisted_preparer_actor_id(user)
        with self.assertRaises(PreparationHold):
            persisted_preparer_actor_id(type("Anonymous", (), {"is_authenticated": False, "pk": None})())
