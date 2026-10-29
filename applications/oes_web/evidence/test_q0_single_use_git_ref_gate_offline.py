"""No API calls; exercise dormant Git ref gate only."""
from unittest.mock import patch
from django.test import SimpleTestCase
from scripts.q0_single_use_git_ref_gate import (
    REF, SingleUseHold, classify_creation, consume,
)


class SingleUseGitRefGateOfflineTests(SimpleTestCase):
    def test_only_exact_creation_is_accepted(self):
        self.assertEqual(classify_creation(201, REF, REF), "ATTEMPT_CONSUMED")
        for status, ref in ((200, REF), (409, REF), (422, REF),
                            (201, "refs/tags/other"), (500, REF)):
            with self.subTest(status=status, ref=ref), self.assertRaises(SingleUseHold):
                classify_creation(status, REF, ref)

    def test_inert_without_nominal_flag(self):
        with patch.dict("os.environ", {}, clear=True), patch(
                "scripts.q0_single_use_git_ref_gate.urlopen") as remote:
            with self.assertRaises(SingleUseHold):
                consume()
            remote.assert_not_called()

    def test_inert_with_invalid_provenance(self):
        env = {"OES_SINGLE_USE_CONSUME": "APPROVED_ONCE",
               "GITHUB_TOKEN": "offline-fixture", "GITHUB_REPOSITORY": "other/repo",
               "GITHUB_REF": "refs/heads/main", "GITHUB_SHA": "a" * 40}
        with patch.dict("os.environ", env, clear=True), patch(
                "scripts.q0_single_use_git_ref_gate.urlopen") as remote:
            with self.assertRaises(SingleUseHold):
                consume()
            remote.assert_not_called()
