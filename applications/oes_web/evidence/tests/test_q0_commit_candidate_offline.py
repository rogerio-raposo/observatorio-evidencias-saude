"""Offline safety checks for the dormant one-shot Q0 commit candidate.

Subprocess checks terminate before Django setup or any connection. No Neon access.
"""
import ast
import os
import subprocess
import sys
from pathlib import Path

from django.test import SimpleTestCase


SCRIPT = Path(__file__).resolve().parents[2] / "scripts" / "run_q0_synthetic_commit_candidate.py"


class Q0CommitCandidateOfflineTests(SimpleTestCase):
    def run_without_credentials(self, overrides):
        env = os.environ.copy()
        for name in ("OES_Q0_COMMIT_EXPLICIT_APPROVAL", "OES_QPREP_LOGIN_PASSWORD"):
            env.pop(name, None)
        env.update(overrides)
        return subprocess.run(
            [sys.executable, str(SCRIPT)],
            env=env, capture_output=True, text=True, timeout=10, check=False,
        )

    def test_gate_blocks_without_explicit_approval(self):
        result = self.run_without_credentials({})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("NOT_RUN: synthetic commit gate disabled", result.stderr)

    def test_missing_secret_blocks_after_explicit_gate(self):
        result = self.run_without_credentials({
            "OES_Q0_COMMIT_EXPLICIT_APPROVAL": "ONE_SYNTHETIC_Q0_COMMIT",
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("NOT_RUN: temporary Q0 login credential unavailable", result.stderr)

    def test_source_uses_existing_uow_and_no_http_entrypoint(self):
        source = SCRIPT.read_text(encoding="utf-8")
        tree = ast.parse(source)
        self.assertTrue(any(isinstance(node, ast.FunctionDef) and node.name == "main"
                            for node in tree.body))
        self.assertIn("OfflineQuestionUnitOfWork(port).execute(", source)
        self.assertIn("transaction.atomic(using=ALIAS)", source)
        self.assertIn("DjangoQ0Repository", source)
        self.assertIn('"USER": "oes_qprep_login"', source)
        self.assertIn("INCONCLUSIVE_Q0_COMMIT", source)
        self.assertNotIn("runserver", source)
