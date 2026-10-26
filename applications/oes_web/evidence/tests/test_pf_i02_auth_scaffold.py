"""PF-I02-I01-A: offline tests; no user DB, sessions persisted, or login."""
from unittest.mock import Mock
from django.core.exceptions import PermissionDenied
from django.test import SimpleTestCase
from django.conf import settings
from django.urls import resolve, Resolver404
from evidence.preparation_auth import require_question_preparer, PREPARE_QUESTION_PERMISSION

class PreparationAuthorizationTests(SimpleTestCase):
    def test_auth_stack_declared(self):
        self.assertIn("django.contrib.auth", settings.INSTALLED_APPS)
        self.assertIn("django.contrib.sessions", settings.INSTALLED_APPS)
        self.assertIn("django.middleware.csrf.CsrfViewMiddleware", settings.MIDDLEWARE)
        self.assertIn("django.contrib.auth.middleware.AuthenticationMiddleware", settings.MIDDLEWARE)
        self.assertEqual(settings.DATABASES['default']['ENGINE'], 'django.db.backends.dummy')

    def test_anonymous_denied(self):
        user = Mock(is_authenticated=False)
        with self.assertRaises(PermissionDenied):
            require_question_preparer(user)
        user.has_perm.assert_not_called()

    def test_authenticated_unprivileged_denied(self):
        user = Mock(is_authenticated=True)
        user.has_perm.return_value = False
        with self.assertRaises(PermissionDenied):
            require_question_preparer(user)
        user.has_perm.assert_called_once_with(PREPARE_QUESTION_PERMISSION)

    def test_explicit_preparer_permission(self):
        user = Mock(is_authenticated=True)
        user.has_perm.return_value = True
        self.assertTrue(require_question_preparer(user))

    def test_no_preparatory_write_route_or_e9(self):
        for path in ("/questions/", "/questions/new/", "/investigations/open/"):
            with self.subTest(path=path):
                with self.assertRaises(Resolver404):
                    resolve(path)

    def test_no_existing_route_mutation(self):
        for path in ("/", "/signals/NCT01438697/", "/synthetic-path/",
                     "/evidence-sheets/OES-P-2026-000401/"):
            with self.subTest(path=path):
                self.assertEqual(self.client.get(path).status_code, 200)
