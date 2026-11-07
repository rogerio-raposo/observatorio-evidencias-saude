"""Offline CLI/workflow boundary checks. No operational gate patching."""
import ast
from contextlib import redirect_stdout
from io import StringIO
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from unittest.mock import patch

from django.test import SimpleTestCase
from evidence.question_preparation import QuestionCommand, command_fingerprint, PreparationHold
from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
from evidence.question_orm_q0_connected_recipe_dormant import execute_connected_q0
from scripts import q0_single_persistent_trial as trial
from preparer_identity.synthetic_service_readonly import RESERVED_USERNAME

ROOT = Path(__file__).resolve().parents[3]
APP = ROOT / "applications/oes_web"
WORKFLOW = ROOT / ".github/workflows/oes-q0-synthetic-commit-manual.yml"


class SinglePersistentTrialPrepTests(SimpleTestCase):
    def setUp(self):
        self.sha = "a" * 40
        self.nonce = "12345678123442348234123456789abc"
        self.env = {
            **trial.WORKFLOW_CONTEXT, "GITHUB_SHA": self.sha, "GITHUB_RUN_ID": "12345",
            "OES_Q0_PERSIST_MODE": trial.SINGLE,
            "OES_Q0_PERSIST_REQUESTED_SHA": self.sha,
            "OES_Q0_PERSIST_APPROVED_SHA": self.sha,
            "OES_Q0_PERSIST_APPROVED_RUN_ID": "12345",
            "OES_Q0_PERSIST_TRIAL_ID": self.nonce,
            "OES_Q0_PERSIST_OPERATIONAL_AUTHORIZATION": f"APPROVED_SINGLE_SYNTHETIC_Q0_COMMIT:{self.sha}:12345:{self.nonce}",
            "DJANGO_SETTINGS_MODULE": "config.settings", "OES_PG_A4_ENABLED": "1",
            "OES_Q0_MULTI_ALIAS_ENABLED": "1", "OES_PG_A4_HOST": trial.HOST,
            "OES_PG_A4_PASSWORD": "offline-reader-sentinel", "OES_Q0_AUTH_PASSWORD": "offline-auth-sentinel",
            "OES_Q0_WRITER_PASSWORD": "offline-writer-sentinel",
        }

    def plan(self):
        return trial.review_boundary(self.env, self.sha)

    def test_default_cli_is_review_only_without_django_or_site_packages(self):
        env = {"PATH": os.environ.get("PATH", ""), "PYTHONDONTWRITEBYTECODE": "1"}
        result = subprocess.run([sys.executable, "-S", "-m", "scripts.q0_single_persistent_trial"],
            cwd=APP, env=env, capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "REVIEW_ONLY_Q0_PERSISTENT_TRIAL_SOURCE_HOLD")

    def test_valid_reserved_plan_is_deterministic_not_a_connection(self):
        plan = self.plan()
        self.assertEqual(plan, self.plan())
        self.assertEqual(plan.request_id, "q0-single-persistent-" + self.nonce)
        self.assertEqual(plan.question_id, "OES-SYNTH-Q0-PERSIST-" + self.nonce)
        self.assertEqual(trial.USERNAME, RESERVED_USERNAME)
        self.assertEqual(QuestionCommand(plan.request_id, plan.question_id, 0, trial.TEXT).expected_version, 0)

    def test_missing_short_invalid_or_mismatched_sha_rejected(self):
        for key in ("GITHUB_SHA", "OES_Q0_PERSIST_REQUESTED_SHA", "OES_Q0_PERSIST_APPROVED_SHA"):
            for value in ("", "a" * 7, "b" * 40, "z" * 40):
                env = {**self.env, key: value}
                with self.subTest(key=key, value=value), self.assertRaises(RuntimeError):
                    trial.review_boundary(env, self.sha)
        with self.assertRaises(RuntimeError):
            trial.review_boundary(self.env, "b" * 40)

    def test_authorization_missing_wrong_sha_run_or_trial_rejected(self):
        for key, value in (("OES_Q0_PERSIST_OPERATIONAL_AUTHORIZATION", ""),
                ("OES_Q0_PERSIST_OPERATIONAL_AUTHORIZATION", f"APPROVED_SINGLE_SYNTHETIC_Q0_COMMIT:{'b'*40}:12345:{self.nonce}"),
                ("OES_Q0_PERSIST_APPROVED_RUN_ID", "12346"), ("GITHUB_RUN_ID", "12346"),
                ("OES_Q0_PERSIST_TRIAL_ID", "22345678123442348234123456789abc")):
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                trial.review_boundary({**self.env, key: value}, self.sha)

    def test_rerun_and_other_workflow_context_rejected(self):
        for key, value in (("GITHUB_RUN_ATTEMPT", "2"), ("GITHUB_EVENT_NAME", "push"),
                ("GITHUB_REF", "refs/heads/other"), ("GITHUB_REPOSITORY", "other/repo")):
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                trial.review_boundary({**self.env, key: value}, self.sha)

    def test_consumption_flags_cannot_authorize_or_claim_unused_state(self):
        for state in ("UNUSED", "CONSUMED", "True", "0"):
            with self.subTest(state=state), self.assertRaises(RuntimeError):
                trial.review_boundary({**self.env, "OES_Q0_PERSIST_AUTHORIZATION_STATE": state}, self.sha)

    def test_repeated_same_run_also_source_holds_without_consumption_backend(self):
        plan = self.plan()
        with patch("django.setup") as setup:
            for _ in range(2):
                with self.assertRaisesRegex(RuntimeError, "durable one-use"):
                    trial._invoke_canonical_trial(plan)
            setup.assert_not_called()

    def test_credentials_missing_equal_or_configuration_wrong_rejected(self):
        trial.review_credentials(self.env)
        for key in ("OES_PG_A4_PASSWORD", "OES_Q0_AUTH_PASSWORD", "OES_Q0_WRITER_PASSWORD"):
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                trial.review_credentials({**self.env, key: ""})
        for key, value in (("OES_Q0_WRITER_PASSWORD", self.env["OES_Q0_AUTH_PASSWORD"]),
                ("OES_PG_A4_HOST", "arbitrary-host"), ("DJANGO_SETTINGS_MODULE", "other"),
                ("OES_Q0_MULTI_ALIAS_ENABLED", "0")):
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                trial.review_credentials({**self.env, key: value})

    def test_incompatible_identity_q1_q2_or_arbitrary_text_rejected(self):
        for key, value in (("OES_Q0_PERSIST_USERNAME", "real-user"), ("OES_Q0_PERSIST_COMMAND", "PROPOSE_Q1"),
                ("OES_Q0_PERSIST_COMMAND", "Q2"), ("OES_Q0_PERSIST_ORIGINAL_TEXT", "factual"),
                ("OES_Q0_PERSIST_QUESTION_ID", "arbitrary"), ("OES_Q0_PERSIST_REQUEST_ID", "other")):
            with self.subTest(key=key), self.assertRaises(RuntimeError):
                trial.review_boundary({**self.env, key: value}, self.sha)

    def test_missing_non_uuid4_or_malicious_identifier_rejected(self):
        for nonce in ("", "../secret", "a" * 32, self.nonce.upper(), "12345678123412348234123456789abc"):
            with self.subTest(nonce=nonce), self.assertRaises(RuntimeError):
                trial.review_boundary({**self.env, "OES_Q0_PERSIST_TRIAL_ID": nonce}, self.sha)

    def test_prepared_review_plan_never_loads_settings_even_with_reserved_mode(self):
        with patch.dict(os.environ, self.env, clear=True), patch.object(trial, "checked_out_sha", return_value=self.sha), patch("django.setup") as setup:
            output = StringIO()
            with redirect_stdout(output):
                trial.main(["--review-workflow"])
            self.assertEqual(json.loads(output.getvalue())["phase"], "PREPARED_SOURCE_HOLD")
            setup.assert_not_called()

    def test_single_mode_stops_before_setup_with_complete_inputs_and_credentials(self):
        with patch.dict(os.environ, self.env, clear=True), patch.object(trial, "checked_out_sha", return_value=self.sha), patch("django.setup") as setup:
            with redirect_stdout(StringIO()), self.assertRaisesRegex(RuntimeError, "source activation"):
                trial.main([])
            setup.assert_not_called()

    def test_review_mode_workflow_validates_actual_sha_without_credentials(self):
        env = {**trial.WORKFLOW_CONTEXT, "GITHUB_SHA": self.sha}
        self.assertIsNone(trial.review_boundary(env, self.sha))
        with self.assertRaises(RuntimeError):
            trial.review_boundary(env, "b" * 40)

    def test_review_only_can_preserve_reserved_identifiers_without_authorization(self):
        env = {**trial.WORKFLOW_CONTEXT, "GITHUB_SHA": self.sha, "GITHUB_RUN_ID": "12345",
               "OES_Q0_PERSIST_TRIAL_ID": self.nonce}
        plan = trial.review_boundary(env, self.sha)
        self.assertEqual(plan.request_id, self.plan().request_id)
        self.assertEqual(plan.question_id, self.plan().question_id)

    def test_entrypoint_does_not_log_exception_or_credential_sentinels(self):
        with patch.object(trial, "main", side_effect=RuntimeError(self.env["OES_Q0_AUTH_PASSWORD"])):
            with self.assertRaises(SystemExit) as raised:
                trial.entrypoint()
            self.assertEqual(str(raised.exception), "HOLD_Q0_PERSISTENT_TRIAL_INCONCLUSIVE_NO_RETRY")

    def test_sanitized_result_accepts_only_fixed_ids_outcomes_and_fingerprint(self):
        plan = self.plan()
        fingerprint = command_fingerprint(QuestionCommand(plan.request_id, plan.question_id, 0, trial.TEXT))
        output = StringIO()
        with redirect_stdout(output):
            trial._emit(plan, "RESULT", "INDETERMINATE", "Q0_RECORDS", fingerprint)
        data = json.loads(output.getvalue())
        self.assertEqual(data["request_id"], plan.request_id)
        self.assertEqual(data["fingerprint"], fingerprint)
        self.assertIs(data["automatic_retry"], False)
        for password in (self.env["OES_PG_A4_PASSWORD"], self.env["OES_Q0_AUTH_PASSWORD"], self.env["OES_Q0_WRITER_PASSWORD"]):
            self.assertNotIn(password, output.getvalue())
        for outcome in ("COMMIT_SUCCESS", "RETRY", "password"):
            with self.subTest(outcome=outcome), self.assertRaises(RuntimeError):
                trial._emit(plan, "RESULT", outcome)
        with self.assertRaises(RuntimeError):
            trial._emit(trial.TrialPlan("password", "1", self.nonce), "RESULT")

    def test_source_hold_precedes_every_import_and_one_canonical_call_only(self):
        source = Path(trial.__file__).read_text()
        tree = ast.parse(source)
        invoke = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "_invoke_canonical_trial")
        body = invoke.body[1:]  # docstring
        self.assertIsInstance(body[0], ast.Raise)
        calls = [n for n in ast.walk(invoke) if isinstance(n, ast.Call) and isinstance(n.func, ast.Name)]
        self.assertEqual(sum(n.func.id == "_review_q0_persistence_d1" for n in calls), 1)
        self.assertNotIn("run_q0_synthetic_commit_candidate", source)
        self.assertFalse(any(isinstance(n, ast.ClassDef) and n.bases for n in ast.walk(tree)))
        self.assertFalse(any(isinstance(n, ast.Assign) and any(isinstance(t, ast.Attribute) and t.attr == "alias" for t in n.targets) for n in ast.walk(tree)))
        self.assertFalse(any(isinstance(n, (ast.For, ast.While)) for n in ast.walk(invoke)))

    def test_general_repository_and_executor_stay_hold(self):
        with self.assertRaises(PreparationHold):
            DjangoQ0Repository(alias="oes_q0_writer")
        with self.assertRaises(PreparationHold):
            execute_connected_q0()


class PersistentTrialWorkflowTests(SimpleTestCase):
    def setUp(self):
        self.source = WORKFLOW.read_text()

    def test_only_manual_dispatch_no_automatic_or_reusable_trigger(self):
        events = self.source.split("on:\n", 1)[1].split("\npermissions:", 1)[0]
        self.assertEqual(re.findall(r"^  ([a-z_]+):", events, re.M), ["workflow_dispatch"])
        self.assertIn("default: REVIEW_ONLY", events)
        self.assertIn("SINGLE_SYNTHETIC_COMMIT", events)
        self.assertNotIn("confirm:", events)

    def test_reserved_job_explicitly_false_and_read_job_has_no_secrets(self):
        review, reserved = self.source.split("  single-persistent-trial:\n", 1)
        self.assertNotIn("secrets.", review)
        self.assertIn("if: ${{ false }}", reserved)
        self.assertIn("contents: read", review)
        self.assertNotIn("contents: write", self.source)
        self.assertNotIn("actions: write", self.source)

    def test_secrets_only_in_final_step_checkout_immutable_and_no_historical_cli(self):
        before, final = self.source.split("      - name: Reserved canonical single attempt", 1)
        self.assertNotIn("secrets.", before)
        self.assertEqual(final.count("secrets."), 3)
        self.assertEqual(self.source.count("ref: ${{ github.sha }}"), 2)
        self.assertEqual(self.source.count("persist-credentials: false"), 2)
        self.assertNotIn("run_q0_synthetic_commit_candidate.py", self.source)
        self.assertNotIn("q0_manual_rollback_trial", self.source)
        self.assertNotIn("continue-on-error", self.source)
        self.assertNotIn("retry", final)

    def test_nominal_approval_bound_to_sha_run_and_trial_and_no_branch_selector(self):
        for value in ("vars.OES_Q0_PERSIST_APPROVED_SHA", "vars.OES_Q0_PERSIST_APPROVED_RUN_ID",
                      "vars.OES_Q0_PERSIST_OPERATIONAL_AUTHORIZATION", "inputs.trial_id"):
            self.assertIn(value, self.source)
        self.assertNotIn("inputs.branch", self.source)
        self.assertNotIn("inputs.database", self.source)
        self.assertIn("cancel-in-progress: false", self.source)
