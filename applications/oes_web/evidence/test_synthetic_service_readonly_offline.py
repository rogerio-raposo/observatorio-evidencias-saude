"""Pure tests; neither database nor network is opened."""
from types import SimpleNamespace
from uuid import uuid4
from unittest.mock import patch
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from preparer_identity.synthetic_service_readonly import (
    classify_synthetic_identity, attest_synthetic_identity_readonly,
    RESERVED_USERNAME, EXPECTED_PERMISSION,
)


class SyntheticServiceReadOnlyTests(SimpleTestCase):
    def facts(self):
        user = SimpleNamespace(
            pk=17, username=RESERVED_USERNAME, is_active=True, is_staff=False,
            is_superuser=False, password="!unusable")
        identity = SimpleNamespace(user_id=17, actor_uuid=uuid4())
        return dict(users=[user], identities=[identity],
                    permissions=[EXPECTED_PERMISSION], groups=[])

    def test_exact_link_and_permission_pass(self):
        data = self.facts()
        self.assertEqual(classify_synthetic_identity(**data),
                         "oes:actor:" + str(data["identities"][0].actor_uuid))

    def test_missing_extra_permissions_and_groups_hold(self):
        for changes in (
            {"users": []}, {"identities": []}, {"groups": [3]},
            {"permissions": []}, {"permissions": [EXPECTED_PERMISSION, EXPECTED_PERMISSION]},
            {"permissions": [("auth", "user", "change_user")]},
        ):
            with self.subTest(changes=changes), self.assertRaises(PreparationHold):
                classify_synthetic_identity(**(self.facts() | changes))

    def test_foreign_link_privileged_and_usable_password_hold(self):
        for field, value in (
            ("user_id", 99), ("is_staff", True), ("is_superuser", True),
            ("is_active", False), ("password", "pbkdf2_usable"),
            ("username", "some_other_name"),
        ):
            data = self.facts()
            obj = data["identities"][0] if field == "user_id" else data["users"][0]
            setattr(obj, field, value)
            with self.subTest(field=field), self.assertRaises(PreparationHold):
                classify_synthetic_identity(**data)

    def test_attestation_denies_unconfigured_database_before_cursor(self):
        from unittest.mock import MagicMock
        fake = MagicMock()
        fake.vendor = "dummy"
        with patch("preparer_identity.synthetic_service_readonly.connections") as connections:
            connections.__getitem__.return_value = fake
            with self.assertRaises(PreparationHold):
                attest_synthetic_identity_readonly()
            fake.cursor.assert_not_called()

    def test_attestation_uses_dedicated_auth_reader_alias(self):
        from unittest.mock import MagicMock
        conn = MagicMock()
        conn.vendor = "dummy"
        with patch("preparer_identity.synthetic_service_readonly.connections") as connections:
            connections.__getitem__.return_value = conn
            with self.assertRaises(PreparationHold):
                attest_synthetic_identity_readonly()
            connections.__getitem__.assert_called_once_with("oes_auth_readonly")
