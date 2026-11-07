"""Sanitized auth-only diagnostics with mocked connections; no SQL is executed."""
import copy
import importlib
import os
from types import SimpleNamespace
from unittest.mock import MagicMock, patch
from uuid import uuid4

from django.db import OperationalError, ProgrammingError
from django.test import SimpleTestCase, override_settings
from evidence.question_preparation import PreparationHold
from preparer_identity import synthetic_service_readonly as service
from scripts import diagnose_synthetic_q0_auth_readonly as command

PREFIX = "Q0_AUTH_DIAG_"
SENTINEL = "OFFLINE_SENSITIVE_SENTINEL"


def database_fixture():
    with patch.dict(os.environ, {"OES_AUTH_ATTEST_ONLY": "1", "OES_Q0_AUTH_PASSWORD": "offline-fixture"}, clear=True):
        module = importlib.reload(importlib.import_module("config.settings_q0_auth_attestation"))
    return copy.deepcopy(module.DATABASES)


def structure_error(state):
    cause = RuntimeError(SENTINEL)
    cause.sqlstate = state
    error = ProgrammingError(SENTINEL)
    error.__cause__ = cause
    return error


class SyntheticAuthDiagnosticTests(SimpleTestCase):
    def facts(self):
        user = SimpleNamespace(
            pk=17, username=service.RESERVED_USERNAME, is_active=True,
            is_staff=False, is_superuser=False, password="!offline-unusable",
            user_permissions=MagicMock(), groups=MagicMock(),
        )
        user.user_permissions.using.return_value.values_list.return_value = [service.EXPECTED_PERMISSION]
        user.groups.using.return_value.values_list.return_value = []
        return user, SimpleNamespace(user_id=17, actor_uuid=uuid4())

    def diagnose(self, scenario="success"):
        user, identity = self.facts()
        users, identities = [user], [identity]
        conn = MagicMock(vendor="postgresql", in_atomic_block=False)
        conn.get_autocommit.return_value = True
        cursor = conn.cursor.return_value.__enter__.return_value
        cursor.fetchone.return_value = ("oes_auth_trial_login", "oes_sandbox", "django_auth", "on")
        if scenario == "connection":
            conn.get_autocommit.side_effect = OperationalError(SENTINEL)
        elif scenario == "session":
            cursor.fetchone.return_value = ("other", "oes_sandbox", "django_auth", "on")
        elif scenario == "readwrite":
            cursor.fetchone.return_value = ("oes_auth_trial_login", "oes_sandbox", "django_auth", "off")
        elif scenario == "schema":
            cursor.fetchone.return_value = ("oes_auth_trial_login", "oes_sandbox", "public", "on")
        elif scenario == "missing_user":
            users = []
        elif scenario == "extra_user":
            users = [user, user]
        elif scenario == "missing_binding":
            identities = []
        elif scenario == "foreign_binding":
            identity.user_id = 99
        elif scenario == "invalid_actor":
            identity.actor_uuid = "not-a-uuid"
        elif scenario == "flags":
            user.is_staff = True
        elif scenario == "permissions":
            user.user_permissions.using.return_value.values_list.return_value = []
        elif scenario == "groups":
            user.groups.using.return_value.values_list.return_value = [3]
        elif scenario == "unexpected":
            cursor.execute.side_effect = RuntimeError(SENTINEL)
        elif scenario == "close":
            conn.close.side_effect = RuntimeError(SENTINEL)
        user_model = MagicMock()
        user_model.objects.using.return_value.filter.return_value = users
        if scenario == "table":
            user_model.objects.using.return_value.filter.side_effect = structure_error("42P01")
        with override_settings(SETTINGS_MODULE="config.settings_q0_auth_attestation", DATABASES=database_fixture()), patch.object(
            service, "connections"
        ) as connections, patch.object(service, "get_user_model", return_value=user_model), patch.object(
            service.PreparerIdentity.objects, "using"
        ) as bindings:
            connections.__getitem__.return_value = conn
            bindings.return_value.filter.return_value = identities
            code = service.diagnose_synthetic_identity_readonly()
            self.assertTrue(all(c.args == ("oes_auth_readonly",) for c in connections.__getitem__.call_args_list))
            conn.close.assert_called()
        return code

    def test_real_attestation_path_reports_static_result_for_each_failure(self):
        cases = {
            "success": "PASS_READ_ONLY_SYNTHETIC_IDENTITY",
            "connection": "HOLD_CONNECTION_OR_AUTHENTICATION",
            "session": "HOLD_SESSION_MISMATCH", "readwrite": "HOLD_SESSION_MISMATCH",
            "schema": "HOLD_STRUCTURES_UNAVAILABLE", "table": "HOLD_STRUCTURES_UNAVAILABLE",
            "missing_user": "HOLD_SYNTHETIC_USER_CARDINALITY", "extra_user": "HOLD_SYNTHETIC_USER_CARDINALITY",
            "missing_binding": "HOLD_IDENTITY_BINDING", "foreign_binding": "HOLD_IDENTITY_BINDING",
            "invalid_actor": "HOLD_IDENTITY_BINDING", "flags": "HOLD_IDENTITY_FLAGS",
            "permissions": "HOLD_PERMISSIONS_OR_GROUPS", "groups": "HOLD_PERMISSIONS_OR_GROUPS",
            "unexpected": "HOLD_INCONCLUSIVE", "close": "HOLD_INCONCLUSIVE",
        }
        for scenario, expected in cases.items():
            with self.subTest(scenario=scenario):
                code = self.diagnose(scenario)
                self.assertEqual(code, PREFIX + expected)
                self.assertNotIn(SENTINEL, code)

    def test_classification_metadata_preserves_original_exception_contract(self):
        user, identity = self.facts()
        user.is_staff = True
        with self.assertRaises(PreparationHold) as raised:
            service.classify_synthetic_identity(users=[user], identities=[identity], permissions=[service.EXPECTED_PERMISSION], groups=[])
        self.assertIs(type(raised.exception), PreparationHold)
        self.assertEqual(str(raised.exception), "HOLD: synthetic identity flags or binding")
        self.assertEqual(raised.exception.diagnostic_code, PREFIX + "HOLD_IDENTITY_FLAGS")

    def test_sqlstate_mapping_does_not_inspect_exception_text(self):
        for state in ("3F000", "42P01", "42703", "42501"):
            self.assertEqual(service.diagnostic_failure_code(structure_error(state)), PREFIX + "HOLD_STRUCTURES_UNAVAILABLE")
        for state in ("08006", "28P01"):
            self.assertEqual(service.diagnostic_failure_code(structure_error(state)), PREFIX + "HOLD_CONNECTION_OR_AUTHENTICATION")
        self.assertEqual(service.diagnostic_failure_code(RuntimeError("password authentication failed")), PREFIX + "HOLD_INCONCLUSIVE")
        error = RuntimeError(SENTINEL)
        error.diagnostic_code = PREFIX + "PASS_READ_ONLY_SYNTHETIC_IDENTITY"
        self.assertEqual(service.diagnostic_failure_code(error), PREFIX + "HOLD_INCONCLUSIVE")

    def test_incompatible_settings_never_reach_any_connection(self):
        cfg = database_fixture()
        alternatives = [
            ("config.settings", cfg),
            ("config.settings_q0_auth_attestation", {**cfg, "oes_q0_writer": {}}),
            ("config.settings_q0_auth_attestation", {**cfg, "default": {"ENGINE": "django.db.backends.postgresql"}}),
        ]
        for key, value in (("HOST", "other.invalid"), ("USER", "other"), ("NAME", "production"),
                           ("OPTIONS", {"sslmode": "require", "options": "-c default_transaction_read_only=off"})):
            bad = copy.deepcopy(cfg)
            bad["oes_auth_readonly"][key] = value
            alternatives.append(("config.settings_q0_auth_attestation", bad))
        for module, databases in alternatives:
            with self.subTest(module=module), override_settings(SETTINGS_MODULE=module, DATABASES=databases), patch.object(service, "connections") as connections:
                self.assertEqual(service.diagnose_synthetic_identity_readonly(), PREFIX + "HOLD_LOCAL_CONFIGURATION")
                connections.__getitem__.assert_not_called()


class DiagnosticCommandTests(SimpleTestCase):
    def environment(self):
        return {"OES_AUTH_DIAGNOSTIC_ONLY": "READ_ONLY_SYNTHETIC_IDENTITY", "OES_AUTH_ATTEST_ONLY": "1",
                "DJANGO_SETTINGS_MODULE": "config.settings_q0_auth_attestation", "OES_Q0_AUTH_PASSWORD": "offline-fixture"}

    def test_opt_in_and_auth_only_configuration_are_required_before_setup(self):
        env = self.environment()
        cases = [{k: v for k, v in env.items() if k != absent} for absent in env]
        cases += [{**env, **mutation} for mutation in (
            {"DJANGO_SETTINGS_MODULE": "config.settings"}, {"OES_Q0_MULTI_ALIAS_ENABLED": "1"},
            {"OES_PG_A4_ENABLED": "1"}, {"OES_Q0_WRITER_PASSWORD": "offline-fixture"},
            {"OES_PG_A4_PASSWORD": "offline-fixture"},
        )]
        for case in cases:
            with self.subTest(case=case), patch("django.setup") as setup:
                self.assertEqual(command.diagnostic_result(case), command.LOCAL_CONFIGURATION)
                setup.assert_not_called()

    def test_command_outputs_only_allowlisted_code_and_returns_failure_status(self):
        for code in service.DIAGNOSTIC_CODES | {SENTINEL, None}:
            with self.subTest(code=code), patch.dict(os.environ, self.environment(), clear=True), patch("django.setup"), patch.object(
                service, "diagnose_synthetic_identity_readonly", return_value=code
            ), patch("builtins.print") as output:
                status = command.main()
                expected = code if code in service.DIAGNOSTIC_CODES else command.INCONCLUSIVE
                output.assert_called_once_with(expected)
                self.assertEqual(status, 0 if expected == PREFIX + "PASS_READ_ONLY_SYNTHETIC_IDENTITY" else 1)

    def test_setup_and_unexpected_failure_are_sanitized(self):
        with patch.dict(os.environ, self.environment(), clear=True), patch("django.setup", side_effect=RuntimeError(SENTINEL)), patch("builtins.print") as output:
            self.assertEqual(command.main(), 1)
            output.assert_called_once_with(command.LOCAL_CONFIGURATION)
        with patch.dict(os.environ, self.environment(), clear=True), patch("django.setup"), patch.object(
            service, "diagnose_synthetic_identity_readonly", side_effect=RuntimeError(SENTINEL)
        ), patch("builtins.print") as output:
            self.assertEqual(command.main(), 1)
            output.assert_called_once_with(command.INCONCLUSIVE)

    def test_import_has_no_effect_and_process_without_opt_in_stops_before_setup(self):
        import runpy
        import sys
        module_name = "scripts.diagnose_synthetic_q0_auth_readonly"
        with patch.dict(os.environ, {}, clear=True), patch("django.setup") as setup, patch.object(service, "connections") as connections, patch.dict(sys.modules):
            sys.modules.pop(module_name, None)
            with patch("builtins.print") as output:
                runpy.run_module(module_name, run_name="diagnostic_import_only")
                output.assert_not_called()
                with self.assertRaises(SystemExit) as raised:
                    runpy.run_module(module_name, run_name="__main__")
                self.assertEqual(raised.exception.code, 1)
                output.assert_called_once_with(command.LOCAL_CONFIGURATION)
            with patch("builtins.print", side_effect=OSError(SENTINEL)):
                with self.assertRaises(SystemExit) as raised:
                    runpy.run_module(module_name, run_name="__main__")
                self.assertEqual(raised.exception.code, command.INCONCLUSIVE)
            setup.assert_not_called()
            connections.__getitem__.assert_not_called()
