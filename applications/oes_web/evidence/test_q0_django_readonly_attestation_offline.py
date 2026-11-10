"""Metadata-only attestation with fake sessions; never PostgreSQL."""
from contextlib import contextmanager, redirect_stdout, redirect_stderr
from copy import deepcopy
import importlib.util
from io import StringIO
import os
from pathlib import Path
import re
import subprocess
import sys
from tempfile import TemporaryDirectory
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from django.test import SimpleTestCase
from scripts import q0_django_readonly_attestation as diag

APP = Path(__file__).resolve().parents[1]
ROOT = APP.parents[1]
SETTINGS_FILE = APP / "config/settings_q0_readonly_attestation.py"
WORKFLOW = ROOT / ".github/workflows/oes-q0-django-readonly-attestation.yml"


def profile_env():
    return {"OES_Q0_DJANGO_RO_PROFILE":"AUTH_AND_Q0_METADATA_ONLY",
            "OES_Q0_AUTH_PASSWORD":"offline-auth-SENTINEL", "OES_PG_A4_PASSWORD":"offline-reader-SENTINEL"}


def load_config(env):
    spec = importlib.util.spec_from_file_location("config.offline_attestation_settings", SETTINGS_FILE)
    module = importlib.util.module_from_spec(spec)
    with patch.dict(os.environ, env, clear=True):
        spec.loader.exec_module(module)
    return module


def boundary_env():
    sha = "a" * 40
    return {**diag.WORKFLOW_CONTEXT, "GITHUB_SHA":sha,
        "OES_Q0_DJANGO_RO_MODE":diag.MODE, "OES_Q0_DJANGO_RO_REQUESTED_SHA":sha,
        "OES_Q0_DJANGO_RO_APPROVED_SHA":sha,
        "OES_Q0_DJANGO_RO_AUTHORIZATION":"APPROVED_SINGLE_DJANGO_Q0_READ_ONLY_ATTESTATION:"+sha}


class AttestationConfigTests(SimpleTestCase):
    def test_two_isolated_readonly_aliases_no_writer_nonpersistent_ssl(self):
        from django.conf import settings
        original = deepcopy(settings.DATABASES)
        module = load_config(profile_env())
        self.assertEqual(set(module.DATABASES), {"default", "oes_synthetic_reader"})
        self.assertEqual(module.DATABASES["default"]["USER"], "oes_auth_trial_login")
        self.assertEqual(module.DATABASES["oes_synthetic_reader"]["USER"], "oes_pg_a4_reader")
        for config in module.DATABASES.values():
            self.assertEqual(config["HOST"], diag.HOST)
            self.assertEqual(config["NAME"], "oes_sandbox")
            self.assertEqual(config["CONN_MAX_AGE"], 0)
            self.assertEqual(config["OPTIONS"]["sslmode"], "require")
            self.assertIn("default_transaction_read_only=on", config["OPTIONS"]["options"])
        self.assertEqual(original, settings.DATABASES)

    def test_missing_shared_or_writer_credentials_and_mixed_profile_rejected(self):
        for mutation in ({"OES_Q0_AUTH_PASSWORD":""}, {"OES_PG_A4_PASSWORD":""},
                {"OES_Q0_AUTH_PASSWORD":profile_env()["OES_PG_A4_PASSWORD"]},
                {"OES_Q0_WRITER_PASSWORD":"offline-writer"}, {"OES_QPREP_LOGIN_PASSWORD":""},
                {"OES_Q0_MULTI_ALIAS_ENABLED":"1"}, {"OES_PG_A4_ENABLED":"1"},
                {"OES_Q0_RECOVERY_READONLY_ENABLED":"1"}, {"OES_AUTH_ATTEST_ONLY":"1"},
                {"OES_Q0_DJANGO_RO_PROFILE":""}):
            with self.subTest(mutation=list(mutation)), self.assertRaises(RuntimeError):
                load_config({**profile_env(), **mutation})


class MetadataAttestationTests(SimpleTestCase):
    def setUp(self):
        module = load_config(profile_env())
        self.settings = SimpleNamespace(SETTINGS_MODULE=diag.SETTINGS, DEBUG=False, DATABASES=module.DATABASES)
        self.enterContext(patch("django.conf.settings", self.settings))
        self.enterContext(patch.dict(os.environ, boundary_env(), clear=True))
        self.enterContext(patch.object(diag, "checked_out_sha", return_value="a"*40))
        self.queries = []
        self.bad_alias = None
        self.readonly = "on"
        self.database = "oes_sandbox"
        self.auth_schema = ["django_auth", "public"]
        self.raw_path = "django_auth,public"
        self.select = True
        self.write = False
        self.other_writes = False
        self.column_insert = False
        self.column_update = False
        self.function_oid = 42
        self.function_execute = True
        self.writer_function_execute = False  # not required for the reader
        self.primary = True
        self.isolation = "repeatable read"
        self.snapshot_token = "100:105:"
        self.second_snapshot = self.snapshot_token
        self.version = "180000"
        self.failure = False
        self.exit_failure = False
        self.connections = {}
        for alias, role in (("default", "oes_auth_trial_login"), ("oes_synthetic_reader", "oes_pg_a4_reader")):
            connection = MagicMock(alias=alias, vendor="postgresql", in_atomic_block=False)
            connection.get_autocommit.side_effect = lambda c=connection: not c.in_atomic_block
            cursor = connection.cursor.return_value.__enter__.return_value
            def execute(sql, params=None, alias=alias, role=role, cursor=cursor):
                self.queries.append((alias, sql, params))
                if self.failure:
                    raise RuntimeError("offline-password person@example.test SECRET_SENTINEL")
                if "session_user" in sql:
                    row = (role, "owner" if self.bad_alias==alias else role, self.database, self.readonly,
                           self.raw_path if alias=="default" else '"$user", public',
                           self.auth_schema if alias=="default" else ["public"])
                elif "has_schema_privilege" in sql:
                    row = (self.select,)
                elif "to_regclass" in sql:
                    row = (params[0], self.select)
                elif "has_table_privilege" in sql:
                    row = (self.select, self.write, self.other_writes, self.column_insert, self.column_update)
                elif "server_version_num" in sql:
                    row = (self.version,)
                elif "to_regprocedure" in sql:
                    row = (self.function_oid, self.writer_function_execute if 'pg_current_xact_id()' in params[0] else self.function_execute)
                elif "transaction_isolation" in sql:
                    row = (self.readonly, self.isolation, not self.primary, self.snapshot_token)
                elif sql=="SELECT pg_current_snapshot()::text":
                    row = (self.second_snapshot,)
                else:
                    self.assertEqual(sql, "SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
                    row = None
                cursor.fetchone.return_value = row
            cursor.execute.side_effect = execute
            self.connections[alias] = connection
        self.registry = MagicMock()
        self.registry.__getitem__.side_effect = self.connections.__getitem__
        self.enterContext(patch("django.db.connections", self.registry))
        self.atomic_calls = []
        @contextmanager
        def atomic(*, using, savepoint):
            self.atomic_calls.append(using)
            self.assertEqual(using, "oes_synthetic_reader")
            self.assertIs(savepoint, False)
            c = self.connections[using]
            c.in_atomic_block = True
            try:
                yield
            finally:
                c.in_atomic_block = False
            if self.exit_failure:
                raise RuntimeError("SECRET_SENTINEL transaction exit")
        self.enterContext(patch("django.db.transaction.atomic", side_effect=atomic))

    def test_positive_metadata_only_uses_two_aliases_and_closes_both(self):
        self.assertEqual(diag.attest_metadata(), diag.PASS)
        self.assertEqual(self.atomic_calls, ["oes_synthetic_reader"])
        for c in self.connections.values():
            self.assertEqual(c.close.call_count, 2)
        self.assertEqual({call.args[0] for call in self.registry.__getitem__.call_args_list}, {"default", "oes_synthetic_reader"})

    def test_sql_allowlist_has_no_user_or_question_content_no_xid_allocation(self):
        self.assertEqual(diag.attest_metadata(), diag.PASS)
        for alias, sql, params in self.queries:
            self.assertTrue(sql.startswith("SELECT ") or sql=="SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY")
            self.assertNotRegex(sql, r"(?i)\bFROM\s+(django_auth|core|investigation)\.")
            self.assertNotIn("SELECT pg_current_xact_id()", sql)
            self.assertNotIn("SELECT pg_xact_status(", sql)
        auth_names = {params[0] for alias,sql,params in self.queries if "to_regclass" in sql}
        self.assertEqual(auth_names, {"django_auth."+name for name in diag.AUTH_TABLES})

    def test_wrong_identity_or_readwrite_session_rejected(self):
        for alias in self.connections:
            self.bad_alias = alias
            self.assertEqual(diag.attest_metadata(), diag.SESSION)
        self.bad_alias = None
        self.readonly = "off"
        self.assertEqual(diag.attest_metadata(), diag.SESSION)
        self.readonly = "on"
        self.database = "other"
        self.assertEqual(diag.attest_metadata(), diag.SESSION)

    def test_auth_effective_search_path_missing_shadowed_or_incompatible_rejected(self):
        for path, schemas in (("public,django_auth", ["public","django_auth"]),
                              ("django_auth,public", ["public"]), ("django_auth,other", ["django_auth","other"])):
            self.raw_path, self.auth_schema = path, schemas
            self.assertEqual(diag.attest_metadata(), diag.SESSION)

    def test_missing_select_or_reader_write_privilege_rejected(self):
        self.select = False
        self.assertEqual(diag.attest_metadata(), diag.PRIVILEGES)
        self.select = True
        self.write = True
        self.assertEqual(diag.attest_metadata(), diag.PRIVILEGES)
        self.write = False
        self.other_writes = True
        self.assertEqual(diag.attest_metadata(), diag.PRIVILEGES)
        self.other_writes = False
        self.column_insert = True
        self.assertEqual(diag.attest_metadata(), diag.PRIVILEGES)
        self.column_insert = False
        self.column_update = True
        self.assertEqual(diag.attest_metadata(), diag.PRIVILEGES)

    def test_missing_function_or_reader_execute_or_old_version_rejected(self):
        self.function_oid = None
        self.assertEqual(diag.attest_metadata(), diag.FUNCTION)
        self.function_oid = 42
        self.function_execute = False
        self.assertEqual(diag.attest_metadata(), diag.FUNCTION)
        self.function_execute = True
        self.version = "130000"
        self.assertEqual(diag.attest_metadata(), diag.FUNCTION)

    def test_replica_wrong_isolation_or_changing_snapshot_rejected(self):
        self.primary = False
        self.assertEqual(diag.attest_metadata(), diag.SNAPSHOT)
        self.primary = True
        self.isolation = "read committed"
        self.assertEqual(diag.attest_metadata(), diag.SNAPSHOT)
        self.isolation = "repeatable read"
        self.second_snapshot = "101:110:"
        self.assertEqual(diag.attest_metadata(), diag.SNAPSHOT)

    def test_external_transaction_is_not_taken_over(self):
        self.connections["default"].in_atomic_block = True
        self.assertEqual(diag.attest_metadata(), diag.SESSION)
        self.connections["default"].close.assert_not_called()
        self.assertEqual(self.queries, [])

    def test_configuration_writer_or_persistent_connection_rejected_before_access(self):
        self.settings.DATABASES["oes_q0_writer"] = {}
        self.assertEqual(diag.attest_metadata(), diag.CONFIG)
        del self.settings.DATABASES["oes_q0_writer"]
        self.settings.DATABASES["default"]["CONN_MAX_AGE"] = 60
        self.assertEqual(diag.attest_metadata(), diag.CONFIG)
        self.registry.__getitem__.assert_not_called()

    def test_direct_invocation_also_requires_full_nominal_approval(self):
        with patch.dict(os.environ, profile_env(), clear=True):
            self.assertEqual(diag.attest_metadata(), diag.BOUNDARY)
        self.registry.__getitem__.assert_not_called()

    def test_errors_and_close_failure_remain_static_inconclusive(self):
        self.failure = True
        code = diag.attest_metadata()
        self.assertEqual(code, diag.INCONCLUSIVE)
        self.assertNotIn("SENTINEL", code)
        self.failure = False
        self.connections["default"].close.side_effect = [None, RuntimeError("SECRET_SENTINEL")]
        self.assertEqual(diag.attest_metadata(), diag.INCONCLUSIVE)

    def test_read_transaction_exit_failure_does_not_retry_or_report_pass(self):
        self.exit_failure = True
        self.assertEqual(diag.attest_metadata(), diag.INCONCLUSIVE)
        self.assertEqual(self.atomic_calls, ["oes_synthetic_reader"])


class AttestationBoundaryWorkflowTests(SimpleTestCase):
    def test_sha_context_and_nominal_authorization_reject_mismatches_or_rerun(self):
        env = boundary_env()
        self.assertTrue(diag.check_boundary(env,"a"*40))
        for key, value in (("GITHUB_SHA",""), ("OES_Q0_DJANGO_RO_REQUESTED_SHA","b"*40),
            ("OES_Q0_DJANGO_RO_APPROVED_SHA","b"*40), ("OES_Q0_DJANGO_RO_AUTHORIZATION","present-but-not-approved"),
            ("GITHUB_RUN_ATTEMPT","2"), ("GITHUB_EVENT_NAME","push"), ("GITHUB_REF","refs/heads/other")):
            with self.subTest(key=key), self.assertRaises(diag._Hold):
                diag.check_boundary({**env,key:value},"a"*40)
        with self.assertRaises(diag._Hold):
            diag.check_boundary(env,"b"*40)

    def test_review_only_and_import_are_connection_free_without_django_installed(self):
        env = {"PATH":os.environ.get("PATH",""), "PYTHONDONTWRITEBYTECODE":"1"}
        for args in (["-m","scripts.q0_django_readonly_attestation"],
                     ["-c","import scripts.q0_django_readonly_attestation"]):
            result = subprocess.run([sys.executable,"-S",*args], cwd=APP, env=env,
                capture_output=True,text=True,timeout=10)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertIn(result.stdout.strip(), ("",diag.REVIEW))

    def test_unauthorized_cli_never_reaches_django_setup_and_sanitizes(self):
        with patch.dict(os.environ,{**profile_env(), "OES_Q0_DJANGO_RO_MODE":diag.MODE},clear=True), patch.object(diag,"checked_out_sha",return_value="a"*40), patch("django.setup") as setup:
            output=StringIO()
            with redirect_stdout(output), patch.object(sys,"argv",["diagnostic"]):
                code=diag.entrypoint()
            self.assertEqual(code,1)
            self.assertEqual(output.getvalue().strip(),diag.BOUNDARY)
            setup.assert_not_called()

    def test_workflow_review_outputs_approval_only_after_full_gate_without_credentials(self):
        with TemporaryDirectory() as directory:
            output_file = Path(directory) / "github-output"
            env = {**boundary_env(), "GITHUB_OUTPUT":str(output_file)}
            with patch.dict(os.environ,env,clear=True), patch.object(diag,"checked_out_sha",return_value="a"*40), patch("django.setup") as setup:
                output = StringIO()
                with redirect_stdout(output):
                    self.assertEqual(diag.main(["--review-workflow"]),0)
                self.assertEqual(output_file.read_text(),"approved=true\n")
                self.assertEqual(output.getvalue().strip(),diag.PREFLIGHT)
                os.environ["OES_Q0_DJANGO_RO_MODE"] = "REVIEW_ONLY"
                with redirect_stdout(StringIO()):
                    self.assertEqual(diag.main(["--review-workflow"]),0)
                self.assertTrue(output_file.read_text().endswith("approved=false\n"))
                setup.assert_not_called()

    def test_sanitized_output_does_not_expose_setup_exception(self):
        env={**boundary_env(),**profile_env(),"DJANGO_SETTINGS_MODULE":diag.SETTINGS}
        with patch.dict(os.environ,env,clear=True), patch.object(diag,"checked_out_sha",return_value="a"*40), patch("django.setup",side_effect=RuntimeError("SECRET_SENTINEL")):
            output=StringIO()
            with redirect_stdout(output):
                code=diag.main([])
            self.assertEqual(code,1)
            self.assertEqual(output.getvalue().strip(),diag.INCONCLUSIVE)

    def test_unexpected_cli_arguments_never_echo_sensitive_values(self):
        output, error = StringIO(), StringIO()
        with patch.object(sys,"argv",["diagnostic","SECRET_ARGUMENT"]), redirect_stdout(output), redirect_stderr(error):
            self.assertEqual(diag.entrypoint(),1)
        self.assertEqual(output.getvalue().strip(),diag.BOUNDARY)
        self.assertEqual(error.getvalue(),"")

    def test_workflow_manual_review_default_sha_gates_secrets_only_connected_final_step(self):
        source=WORKFLOW.read_text()
        events=source.split("on:\n",1)[1].split("\npermissions:",1)[0]
        self.assertEqual(re.findall(r"^  ([a-z_]+):",events,re.M),["workflow_dispatch"])
        self.assertIn("default: REVIEW_ONLY",events)
        before,connected=source.split("  readonly-attestation:\n",1)
        self.assertNotIn("secrets.",before)
        before_final,final=connected.split("      - name: Single metadata-only attestation",1)
        self.assertNotIn("secrets.",before_final)
        self.assertEqual(final.count("secrets."),2)
        for required in ("github.run_attempt == '1'", "inputs.approved_sha == github.sha",
                "vars.OES_Q0_DJANGO_RO_APPROVED_SHA == github.sha", "needs.preflight.outputs.approved == 'true'"):
            self.assertIn(required,connected)
        self.assertEqual(source.count("ref: ${{ github.sha }}"),2)
        self.assertIn("contents: read",source)
        self.assertNotIn("OES_Q0_WRITER_PASSWORD",source)
        self.assertNotIn("oes_q0_writer",source)
        self.assertNotIn("continue-on-error",source)
