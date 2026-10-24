"""Offline G2-I1 diagnostic classification tests. No PostgreSQL connection."""
import importlib.util
import os
import pathlib
import sys
import types
import unittest
from unittest.mock import patch

MODULE_PATH = pathlib.Path(__file__).resolve().parents[1] / "e6_g2_login_preflight.py"
SPEC = importlib.util.spec_from_file_location("e6_g2_login_preflight", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class FakeDbError(Exception):
    def __init__(self, code):
        super().__init__("SENSITIVE_DO_NOT_LOG")
        self.sqlstate = code


class G2I1DiagnosticTests(unittest.TestCase):
    def test_authentication_codes(self):
        for code in ("28P01", "28000"):
            self.assertEqual(MODULE.sanitized_failure(FakeDbError(code), "connect"), "AUTHENTICATION")

    def test_privilege_code(self):
        self.assertEqual(MODULE.sanitized_failure(FakeDbError("42501"), "role"), "PRIVILEGE")

    def test_role_missing_code(self):
        self.assertEqual(MODULE.sanitized_failure(FakeDbError("42704"), "role"), "ROLE_MISSING")

    def test_connect_fallback(self):
        self.assertEqual(MODULE.sanitized_failure(FakeDbError(None), "connect"), "CONNECTION_OR_TLS")

    def test_metadata_fallback(self):
        self.assertEqual(MODULE.sanitized_failure(FakeDbError(None), "metadata"), "ROLE_OR_METADATA")

    def test_no_secrets_fails_before_driver(self):
        with patch.dict(os.environ, {}, clear=True):
            self.assertEqual(MODULE.run(), "MISSING_CONFIGURATION")

    def test_bad_host_fails_before_driver(self):
        env = {"OES_G2_HOST": "postgresql://user:secret@ep.example.neon.tech/db",
               "OES_G2_WRITER_PASSWORD": "dummy", "OES_G2_VERIFIER_PASSWORD": "dummy"}
        with patch.dict(os.environ, env, clear=True):
            self.assertEqual(MODULE.run(), "INVALID_HOST_CONFIGURATION")

    def test_auth_failure_and_tls_parameters(self):
        def reject(**kwargs):
            self.assertEqual(kwargs["sslmode"], "verify-full")
            self.assertEqual(kwargs["channel_binding"], "require")
            self.assertEqual(kwargs["user"], "oes_e6_g2_writer_tmp")
            raise FakeDbError("28P01")
        env = {"OES_G2_HOST": "ep-test.neon.tech",
               "OES_G2_WRITER_PASSWORD": "dummy", "OES_G2_VERIFIER_PASSWORD": "dummy"}
        fake_driver = types.SimpleNamespace(connect=reject)
        with patch.dict(os.environ, env, clear=True), patch.dict(sys.modules, {"psycopg": fake_driver}):
            self.assertEqual(MODULE.run(), "AUTHENTICATION")
