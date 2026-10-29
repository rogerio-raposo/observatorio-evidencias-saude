"""Offline validation of dormant manual entrypoint, no network or Django writes."""
from unittest.mock import patch
from django.test import SimpleTestCase
from scripts.q0_manual_rollback_trial import check_manual_boundary, REQUIRED


class Q0ManualTrialOfflineTests(SimpleTestCase):
    def valid_environment(self):
        return {
            **REQUIRED,
            "GITHUB_SHA": "a" * 40,
            "OES_Q0_APPROVED_SHA": "a" * 40,
            "OES_PG_A4_PASSWORD": "offline-reader",
            "OES_Q0_AUTH_PASSWORD": "offline-auth",
            "OES_Q0_WRITER_PASSWORD": "offline-writer",
            "OES_PG_A4_HOST": "offline-host",
            "OES_PG_A4_ENABLED": "1",
            "OES_Q0_MULTI_ALIAS_ENABLED": "1",
        }

    def test_exact_boundary_is_only_eligible_configuration(self):
        self.assertTrue(check_manual_boundary(self.valid_environment()))

    def test_rejects_reruns_sha_drift_and_missing_secrets(self):
        for name, bad in (
            ("GITHUB_RUN_ATTEMPT", "2"),
            ("GITHUB_EVENT_NAME", "push"),
            ("OES_Q0_APPROVED_SHA", "b" * 40),
            ("OES_Q0_WRITER_PASSWORD", ""),
            ("OES_Q0_MULTI_ALIAS_ENABLED", "0"),
            ("OES_Q0_MANUAL_ROLLBACK_ONLY", ""),
        ):
            env = {**self.valid_environment(), name: bad}
            with self.subTest(name=name), self.assertRaises(RuntimeError):
                check_manual_boundary(env)
