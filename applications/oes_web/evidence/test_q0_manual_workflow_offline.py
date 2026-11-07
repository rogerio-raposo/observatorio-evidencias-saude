"""Manual workflow contract and preflight snippets; no Actions or DB execution."""
import os
from pathlib import Path
import re
from subprocess import CalledProcessError
from tempfile import TemporaryDirectory
import textwrap
from types import SimpleNamespace
from unittest.mock import patch

from django.test import SimpleTestCase
from scripts.q0_manual_rollback_trial import (
    check_workflow_boundary, checked_out_sha, WORKFLOW_CONTEXT,
)

ROOT = Path(__file__).resolve().parents[3]
WORKFLOW = ROOT / ".github/workflows/oes-django-q0-single-rollback-hold.yml"
SHA = "a" * 40


class ManualWorkflowOfflineTests(SimpleTestCase):
    def context(self, mode):
        return {
            **WORKFLOW_CONTEXT, "GITHUB_SHA": SHA, "OES_Q0_MODE": mode,
            "OES_Q0_APPROVED_SHA": SHA, "OES_Q0_REQUESTED_SHA": SHA,
            "OES_Q0_OPERATIONAL_AUTHORIZATION": "APPROVED_SINGLE_SYNTHETIC_ROLLBACK:" + SHA,
        }

    def test_review_needs_no_scientific_configuration_or_operational_approval(self):
        env = {**WORKFLOW_CONTEXT, "GITHUB_SHA": SHA, "OES_Q0_MODE": "REVIEW_ONLY"}
        self.assertEqual(check_workflow_boundary(env, SHA), "REVIEW_ONLY")

    def test_connected_selection_alone_does_not_authorize_trial(self):
        env = self.context("SINGLE_SYNTHETIC_ROLLBACK")
        self.assertEqual(check_workflow_boundary(env, SHA), "SINGLE_SYNTHETIC_ROLLBACK")
        for mutation in (
            {"OES_Q0_MODE": ""}, {"OES_Q0_MODE": "UNKNOWN"},
            {"OES_Q0_OPERATIONAL_AUTHORIZATION": ""},
            {"OES_Q0_OPERATIONAL_AUTHORIZATION": "APPROVED_SINGLE_SYNTHETIC_ROLLBACK:" + "b" * 40},
            {"OES_Q0_REQUESTED_SHA": "b" * 40},
            {"OES_Q0_APPROVED_SHA": "b" * 40},
        ):
            with self.subTest(mutation=mutation), self.assertRaises(RuntimeError):
                check_workflow_boundary({**env, **mutation}, SHA)

    def test_both_modes_reject_nonmanual_context_rerun_or_wrong_checkout(self):
        for mode in ("REVIEW_ONLY", "SINGLE_SYNTHETIC_ROLLBACK"):
            env = self.context(mode)
            for mutation in (
                {"GITHUB_EVENT_NAME": "push"}, {"GITHUB_EVENT_NAME": "pull_request"},
                {"GITHUB_RUN_ATTEMPT": "2"}, {"GITHUB_REF": "refs/heads/other"},
                {"GITHUB_REPOSITORY": "other/repository"},
            ):
                with self.subTest(mode=mode, mutation=mutation), self.assertRaises(RuntimeError):
                    check_workflow_boundary({**env, **mutation}, SHA)
            with self.assertRaises(RuntimeError):
                check_workflow_boundary(env, "b" * 40)

    def test_actual_checkout_is_read_and_modified_tracked_source_is_rejected(self):
        with patch("subprocess.run", return_value=SimpleNamespace(stdout=SHA + "\n")) as git:
            self.assertEqual(checked_out_sha(), SHA)
            self.assertEqual(git.call_args_list[0].args[0], ["git", "rev-parse", "--verify", "HEAD"])
            self.assertEqual(git.call_args_list[1].args[0], ["git", "diff", "--quiet", "HEAD", "--"])
            self.assertTrue(all(call.kwargs["check"] for call in git.call_args_list))
        with patch("subprocess.run", side_effect=[
            SimpleNamespace(stdout=SHA), CalledProcessError(1, "git")
        ]), self.assertRaises(CalledProcessError):
            checked_out_sha()

    def test_workflow_is_manual_and_secrets_are_only_in_final_cli_step(self):
        source = WORKFLOW.read_text()
        events = source.split("on:\n", 1)[1].split("permissions:\n", 1)[0]
        self.assertEqual(re.findall(r"^  ([a-z_]+):", events, re.M), ["workflow_dispatch"])
        review, connected = source.split("  connected-trial:\n", 1)
        self.assertNotIn("secrets.", review)
        setup, trial = connected.split("      - name: Single synthetic rollback", 1)
        self.assertNotIn("secrets.", setup)
        self.assertEqual(trial.count("secrets."), 3)
        self.assertIn("run: python -m scripts.q0_manual_rollback_trial", trial)
        self.assertIn("ref: ${{ github.sha }}", review)
        self.assertIn("ref: ${{ vars.OES_Q0_APPROVED_SHA }}", connected)
        self.assertIn("needs: preflight-review-only", connected)
        self.assertIn("needs.preflight-review-only.outputs.mode == 'SINGLE_SYNTHETIC_ROLLBACK'", connected)
        self.assertIn("vars.OES_Q0_OPERATIONAL_AUTHORIZATION == format(", connected)
        self.assertIn("vars.OES_Q0_APPROVED_SHA == github.sha", connected)
        self.assertIn("cancel-in-progress: false", source)
        self.assertNotIn("continue-on-error", source)
        self.assertNotIn("run_connected()", source)

    def test_embedded_preflight_reports_review_or_eligible_mode_and_sanitizes_failure(self):
        source = WORKFLOW.read_text()
        block = re.search(r"        run: \|\n((?:          .*\n|\n)+)", source).group(1)
        script = textwrap.dedent(block).split("\n", 1)[1].rsplit("\nPY", 1)[0]
        for mode in ("REVIEW_ONLY", "SINGLE_SYNTHETIC_ROLLBACK"):
            for actual_sha in (SHA, "b" * 40):
                with self.subTest(mode=mode, actual_sha=actual_sha), TemporaryDirectory() as td:
                    output_file = Path(td) / "output"
                    env = {**self.context(mode), "GITHUB_OUTPUT": str(output_file)}
                    if mode == "REVIEW_ONLY":
                        for key in ("OES_Q0_APPROVED_SHA", "OES_Q0_REQUESTED_SHA", "OES_Q0_OPERATIONAL_AUTHORIZATION"):
                            env.pop(key)
                    with patch.dict(os.environ, env, clear=True), patch(
                        "scripts.q0_manual_rollback_trial.checked_out_sha", return_value=actual_sha
                    ), patch("builtins.print") as log:
                        if actual_sha == SHA:
                            exec(compile(script, "workflow-preflight", "exec"), {})
                            self.assertEqual(output_file.read_text(), "mode=" + mode + "\n")
                            log.assert_called_once_with("REVIEW_ONLY_CONNECTED_HOLD_CONFIRMED" if mode == "REVIEW_ONLY"
                                                        else "ROLLBACK_BOUNDARY_REVIEWED_NOT_EXECUTED")
                        else:
                            with self.assertRaises(SystemExit) as raised:
                                exec(compile(script, "workflow-preflight", "exec"), {})
                            self.assertEqual(str(raised.exception), "HOLD_Q0_WORKFLOW_BOUNDARY")
                            self.assertFalse(output_file.exists())
                            log.assert_not_called()
