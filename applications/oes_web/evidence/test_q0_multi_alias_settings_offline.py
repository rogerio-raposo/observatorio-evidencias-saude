"""Offline-only checks of dormant multialias settings; no database connections."""
import importlib.util
import os
from pathlib import Path
from unittest.mock import patch

from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from evidence.question_orm_q0_connected_recipe_dormant import execute_connected_q0


SETTINGS_FILE = Path(__file__).resolve().parents[1] / "config" / "settings.py"
HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"


def load_settings(environment):
    spec = importlib.util.spec_from_file_location("oes_multi_alias_offline_review", SETTINGS_FILE)
    module = importlib.util.module_from_spec(spec)
    with patch.dict(os.environ, environment, clear=True):
        spec.loader.exec_module(module)
    return module.DATABASES


class MultiAliasOfflineTests(SimpleTestCase):
    def test_default_without_gate_has_no_writer(self):
        self.assertNotIn("oes_q0_writer", load_settings({}))
        self.assertFalse(load_settings({}))

    def test_reader_only_preserved(self):
        cfg = load_settings({
            "OES_PG_A4_ENABLED": "1", "OES_PG_A4_HOST": HOST,
            "OES_PG_A4_PASSWORD": "reader-fixture",
        })
        self.assertEqual(cfg["default"]["ENGINE"], "django.db.backends.dummy")
        self.assertEqual(cfg["oes_synthetic_reader"]["USER"], "oes_pg_a4_reader")
        self.assertNotIn("oes_q0_writer", cfg)

    def test_opt_in_requires_three_isolated_aliases(self):
        cfg = load_settings({
            "OES_Q0_MULTI_ALIAS_ENABLED": "1",
            "OES_PG_A4_ENABLED": "1", "OES_PG_A4_HOST": HOST,
            "OES_PG_A4_PASSWORD": "reader-fixture",
            "OES_Q0_AUTH_PASSWORD": "auth-fixture",
            "OES_Q0_WRITER_PASSWORD": "writer-fixture",
        })
        self.assertEqual(set(cfg), {"default", "oes_auth_readonly", "oes_q0_writer", "oes_synthetic_reader"})
        self.assertEqual([cfg[name]["USER"] for name in ("default", "oes_q0_writer", "oes_synthetic_reader")],
                         ["oes_auth_trial_login", "oes_qprep_login", "oes_pg_a4_reader"])
        self.assertTrue(all(cfg[name]["CONN_MAX_AGE"] == 0 for name in cfg))
        for alias, connection in cfg.items():
            with self.subTest(alias=alias):
                self.assertEqual(connection["HOST"], HOST)
                self.assertEqual(connection["NAME"], "oes_sandbox")
                self.assertEqual(connection["PORT"], "5432")
                self.assertEqual(connection["OPTIONS"]["sslmode"], "require")
        self.assertEqual(cfg["default"]["OPTIONS"]["options"],
                         "-c search_path=django_auth,public")
        self.assertEqual(cfg["oes_auth_readonly"]["USER"], "oes_auth_trial_login")
        self.assertEqual(cfg["oes_auth_readonly"]["OPTIONS"]["options"],
                         "-c search_path=django_auth,public -c default_transaction_read_only=on")
        self.assertEqual(cfg["oes_auth_readonly"]["CONN_MAX_AGE"], 0)
        self.assertEqual(cfg["oes_synthetic_reader"]["OPTIONS"]["options"],
                         "-c default_transaction_read_only=on")
        with self.assertRaises(PreparationHold):
            execute_connected_q0()

    def test_missing_or_shared_credentials_hold(self):
        env = {
            "OES_Q0_MULTI_ALIAS_ENABLED": "1",
            "OES_PG_A4_ENABLED": "1", "OES_PG_A4_HOST": HOST,
            "OES_PG_A4_PASSWORD": "reader-fixture",
            "OES_Q0_AUTH_PASSWORD": "auth-fixture",
        }
        with self.assertRaisesRegex(RuntimeError, "credentials required"):
            load_settings(env)
        with self.assertRaisesRegex(RuntimeError, "distinct credentials"):
            load_settings({**env, "OES_Q0_WRITER_PASSWORD": "reader-fixture"})
        with self.assertRaisesRegex(RuntimeError, "direct same-branch endpoint"):
            load_settings({**env, "OES_Q0_WRITER_PASSWORD": "writer-fixture",
                           "OES_PG_A4_HOST": "ep-wispy-dream-b6021bw0-pooler.c-2.sa-east-1.aws.neon.tech"})

    def test_foreign_destination_missing_reader_and_other_shared_credentials_hold(self):
        env = {
            "OES_Q0_MULTI_ALIAS_ENABLED": "1", "OES_PG_A4_ENABLED": "1",
            "OES_PG_A4_HOST": HOST, "OES_PG_A4_PASSWORD": "offline-reader",
            "OES_Q0_AUTH_PASSWORD": "offline-auth",
            "OES_Q0_WRITER_PASSWORD": "offline-writer",
        }
        for mutation in (
            {"OES_PG_A4_HOST": "unapproved.invalid"},
            {"OES_PG_A4_ENABLED": "0"},
            {"OES_Q0_AUTH_PASSWORD": "offline-reader"},
            {"OES_Q0_AUTH_PASSWORD": "offline-writer"},
        ):
            with self.subTest(mutation=mutation), self.assertRaises(RuntimeError):
                load_settings({**env, **mutation})


class CanonicalAuthMetadataOfflineTests(SimpleTestCase):
    def test_identity_app_registered_and_permission_declared(self):
        from django.conf import settings
        from django.apps import apps
        from evidence.models import OesQuestion
        self.assertIn("preparer_identity", settings.INSTALLED_APPS)
        self.assertIsNotNone(apps.get_model("preparer_identity", "PreparerIdentity"))
        self.assertIn(("prepare_question", "Can prepare an OES question"),
                      OesQuestion._meta.permissions)
        self.assertFalse(OesQuestion._meta.managed)
