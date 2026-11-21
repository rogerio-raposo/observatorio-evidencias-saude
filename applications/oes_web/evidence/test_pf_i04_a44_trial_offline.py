"""Offline admission tests for the private Q0 → Q1 CLI."""
from dataclasses import replace
from types import SimpleNamespace
from unittest.mock import patch
from uuid import UUID

from django.test import RequestFactory, SimpleTestCase, override_settings

from scripts import pf_i04_a44_trial as trial

from . import question_orm_q0_evidence_dormant as evidence
from . import question_orm_q0_repository_dormant as repo
from .question_preparation import PreparationHold
from .views import q0_registration


class TrialAdmissionTests(SimpleTestCase):
    run_id = "af0d0d21-285b-42be-a5da-0f3b25bc8173"
    sha = "a" * 40
    actor = "offline-actor"

    def setUp(self):
        self.user = SimpleNamespace(pk=42)
        self.q0, self.q1 = trial._commands(UUID(self.run_id))
        self.env = {
            "OES_PF_I04_A44_TRIAL": self.run_id,
            "OES_PF_I04_A44_APPROVED_SHA": self.sha,
            "DJANGO_SETTINGS_MODULE": "config.settings_mb_oc1",
            "OES_MB_OC1_RELEASE_MODE": "HOLD",
            "OES_CODESPACES_CSRF_LOCALHOST_ORIGIN": "0",
        }
        self.setup = self.enterContext(patch("django.setup"))
        self.checkout = self.enterContext(patch.object(trial, "checked_out_sha", return_value=self.sha))
        self.enterContext(patch("builtins.print"))

    def cli(self, phase, *, pk=42, actor=None, env=None):
        with patch.dict("os.environ", {**self.env, **(env or {})}):
            return trial.main([phase, "--run-id", self.run_id, "--user-id", str(pk),
                               "--actor", actor or self.actor])

    def test_source_hold_and_checkout_or_fixture_mismatch_stop_before_setup(self):
        self.assertEqual(self.cli("register"), 1)
        with patch.object(trial, "_APPROVED_FIXTURE", (self.run_id, 42, self.actor)):
            self.assertEqual(self.cli("register", pk=43), 1)
            self.assertEqual(self.cli("register", actor="another-actor"), 1)
            for env in (
                {"OES_PF_I04_A44_APPROVED_SHA": ""},
                {"OES_PF_I04_A44_APPROVED_SHA": "b" * 40},
                {"OES_MB_OC1_RELEASE_MODE": "PRIVATE_SYNTHETIC_Q0"},
                {"OES_CODESPACES_CSRF_LOCALHOST_ORIGIN": "1"},
            ):
                with self.subTest(env=env):
                    self.assertEqual(self.cli("register", env=env), 1)
        self.setup.assert_not_called()

    @override_settings(MB_OC1_RELEASE_MODE="HOLD")
    def test_bound_registration_does_not_open_http_and_scope_is_cleared(self):
        def register():
            self.assertEqual(trial._require_window()[0], self.sha)
            with repo._application_q0_scope(user=self.user, command=self.q0) as scope:
                self.assertEqual(scope.actor, self.actor)
                response = q0_registration(RequestFactory().post("/questions/q0/register/"))
                self.assertEqual(response.status_code, 423)
            self.assertFalse(scope.active)
            with self.assertRaises(PreparationHold):
                with repo._application_q0_scope(user=self.user, command=replace(self.q0, original_text="Outro")):
                    self.fail("arbitrary command")
            raise RuntimeError("lost acknowledgement")

        with patch.object(trial, "_APPROVED_FIXTURE", (self.run_id, 42, self.actor)),                 patch.object(trial, "_run", side_effect=register) as run,                 patch("evidence.preparation_auth.require_question_preparer"),                 patch("preparer_identity.resolver.persisted_preparer_actor_id", return_value=self.actor):
            self.assertEqual(self.cli("register"), 1)
            run.assert_called_once_with()
            self.assertIsNone(trial._window.get())

    @override_settings(MB_OC1_RELEASE_MODE="HOLD")
    def test_recovery_phase_cannot_enter_either_writer(self):
        def recover():
            self.assertEqual(evidence._recover_q0_commit_evidence(user=self.user, command=self.q0),
                             {"outcome": "INDETERMINATE"})
            with self.assertRaises(PreparationHold):
                with repo._application_q0_scope(user=self.user, command=self.q0):
                    self.fail("Q0 writer opened")
            with self.assertRaises(PreparationHold):
                with repo._supervised_q1_trial(user=self.user, command=self.q1, actor=self.actor, write=True):
                    self.fail("Q1 writer opened")
            return "OFFLINE"

        with patch.object(trial, "_APPROVED_FIXTURE", (self.run_id, 42, self.actor)),                 patch.object(trial, "_run", side_effect=recover),                 patch("evidence.preparation_auth.require_question_preparer"),                 patch("preparer_identity.resolver.persisted_preparer_actor_id", return_value=self.actor),                 patch("evidence.question_orm_q0_connected_recipe_dormant._review_q0_reader_configuration"),                 patch.object(evidence, "_collect_q0_commit_evidence", return_value={"outcome": "INDETERMINATE"}) as read:
            self.assertEqual(self.cli("review-q0"), 0)
            read.assert_called_once_with(command=self.q0, actor_id=self.actor)
            self.assertIsNone(trial._window.get())

    def test_conflict_phase_only_admits_the_reserved_divergent_command_for_write(self):
        def conflict():
            with repo._supervised_q1_trial(user=self.user, command=self.q1, actor=self.actor, write=False):
                self.assertEqual(repo._require_q1_source_activation(user=self.user, command=self.q1), self.actor)
            with self.assertRaises(PreparationHold):
                with repo._supervised_q1_trial(user=self.user, command=self.q1, actor=self.actor, write=True):
                    self.fail("ordinary proposal opened")
            divergent = trial._divergent(self.q1)
            with repo._supervised_q1_trial(user=self.user, command=divergent, actor=self.actor, write=True):
                self.assertEqual(repo._require_q1_source_activation(user=self.user, command=divergent, write=True),
                                 self.actor)
            return "OFFLINE"

        with patch.object(trial, "_APPROVED_FIXTURE", (self.run_id, 42, self.actor)),                 patch.object(trial, "_run", side_effect=conflict):
            self.assertEqual(self.cli("conflict"), 0)
            self.assertIsNone(trial._window.get())

    @override_settings(MB_OC1_RELEASE_MODE="PRIVATE_SYNTHETIC_Q0")
    def test_loaded_http_release_setting_stops_before_auth_lookup(self):
        with patch.object(trial, "_APPROVED_FIXTURE", (self.run_id, 42, self.actor)),                 patch("config.mb_oc1._require_private_profile"),                 patch("django.contrib.auth.get_user_model") as users:
            self.assertEqual(self.cli("propose"), 1)
            users.assert_not_called()

    @override_settings(MB_OC1_RELEASE_MODE="HOLD")
    def test_different_persisted_actor_stops_before_writer_scope(self):
        with patch.object(trial, "_APPROVED_FIXTURE", (self.run_id, 42, self.actor)), \
                patch("config.mb_oc1._require_private_profile"), \
                patch("evidence.question_orm_q0_connected_recipe_dormant._review_q0_database_configuration") as config, \
                patch("django.contrib.auth.get_user_model") as users, \
                patch("evidence.preparation_auth.require_question_preparer") as authorize, \
                patch("preparer_identity.resolver.persisted_preparer_actor_id", return_value="other-actor"), \
                patch.object(repo, "_application_q0_scope") as writer:
            users.return_value.objects.using.return_value.get.return_value = self.user
            self.assertEqual(self.cli("register"), 1)
            config.assert_called_once()
            users.return_value.objects.using.assert_called_once_with("default")
            users.return_value.objects.using.return_value.get.assert_called_once_with(pk=42)
            authorize.assert_called_once_with(self.user)
            writer.assert_not_called()
