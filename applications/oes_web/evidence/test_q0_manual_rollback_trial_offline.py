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

    def test_uncovered_context_and_missing_configuration_are_rejected(self):
        for name, bad in (
            ("GITHUB_REPOSITORY", "other/repository"),
            ("GITHUB_REF", "refs/heads/other"),
            ("DJANGO_SETTINGS_MODULE", "config.other_settings"),
            ("OES_PG_A4_ENABLED", "0"),
        ):
            with self.subTest(name=name), self.assertRaises(RuntimeError):
                check_manual_boundary({**self.valid_environment(), name: bad})
        for name in self.valid_environment():
            env = self.valid_environment()
            del env[name]
            with self.subTest(missing=name), self.assertRaises(RuntimeError):
                check_manual_boundary(env)

    def test_malformed_sha_is_rejected_even_when_approved_value_matches(self):
        for sha in ("", "a" * 39, "a" * 41, "g" * 40, "A" * 40):
            with self.subTest(sha=sha), self.assertRaises(RuntimeError):
                check_manual_boundary({**self.valid_environment(),
                                       "GITHUB_SHA": sha, "OES_Q0_APPROVED_SHA": sha})

    def test_rejected_boundary_stops_before_django_setup_or_recipe(self):
        from scripts.q0_manual_rollback_trial import main
        with patch.dict("os.environ", {}, clear=True), patch("django.setup") as setup, patch(
            "scripts.q0_rollback_transaction_candidate.review_and_execute_isolated_trial"
        ) as recipe:
            with self.assertRaises(RuntimeError):
                main()
            setup.assert_not_called()
            recipe.assert_not_called()

    def test_main_only_accepts_exact_pass_and_never_retries(self):
        from scripts.q0_manual_rollback_trial import main
        for status in ("PASS_ROLLBACK_ZERO_RESIDUES", "HOLD", None):
            with self.subTest(status=status), patch.dict(
                "os.environ", self.valid_environment(), clear=True
            ), patch("django.setup") as setup, patch(
                "scripts.q0_rollback_transaction_candidate.review_and_execute_isolated_trial",
                return_value=status,
            ) as recipe, patch("builtins.print") as output:
                if status == "PASS_ROLLBACK_ZERO_RESIDUES":
                    main()
                    output.assert_called_once_with(status)
                else:
                    with self.assertRaisesRegex(RuntimeError, "unexpected rollback classification"):
                        main()
                    output.assert_not_called()
                setup.assert_called_once_with()
                recipe.assert_called_once_with()

    def test_process_entrypoint_sanitizes_recipe_failure_without_retry(self):
        import runpy
        import sys
        with patch.dict("os.environ", self.valid_environment(), clear=True), patch(
            "django.setup"
        ), patch(
            "scripts.q0_rollback_transaction_candidate.review_and_execute_isolated_trial",
            side_effect=RuntimeError("OFFLINE_SENSITIVE_MARKER"),
        ) as recipe, patch("builtins.print") as output:
            with patch.dict(sys.modules):
                sys.modules.pop("scripts.q0_manual_rollback_trial", None)
                with self.assertRaises(SystemExit) as raised:
                    runpy.run_module("scripts.q0_manual_rollback_trial", run_name="__main__")
            self.assertEqual(str(raised.exception), "HOLD_Q0_MANUAL_ROLLBACK_INCONCLUSIVE")
            recipe.assert_called_once_with()
            output.assert_not_called()
