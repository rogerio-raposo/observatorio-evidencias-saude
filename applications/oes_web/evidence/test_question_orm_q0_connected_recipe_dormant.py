"""Review-only gate tests: never touch an actual database."""
from dataclasses import replace
from unittest.mock import patch
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from evidence.question_orm_q0_connected_recipe_dormant import (
    execute_connected_q0, _rollback_recipe, prepare_q0_trial_review,
)


class Q0ConnectedRecipeDormantTests(SimpleTestCase):
    def test_public_entrypoint_fails_closed(self):
        with self.assertRaisesRegex(PreparationHold, "G2-P2B"):
            execute_connected_q0(alias="default")

    def test_invalid_input_fails_before_repository(self):
        with self.assertRaisesRegex(PreparationHold, "invalid fingerprint"):
            _rollback_recipe(alias="unused", actor_id="a", request_id="r",
                             question_id="q", original_text="synthetic",
                             fingerprint="invalid")

    def test_recipe_cannot_instantiate_dormant_writer(self):
        with patch(
            "evidence.question_orm_q0_connected_recipe_dormant.transaction.atomic",
            side_effect=AssertionError("unexpected database transaction"),
        ):
            with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
                _rollback_recipe(
                    alias="unused", actor_id="synthetic", request_id="r",
                    question_id="q", original_text="synthetic text",
                    fingerprint="a" * 64,
                )


    def test_synthetic_preflight_matches_recipe_and_stays_blocked(self):
        trial = prepare_q0_trial_review(
            actor_id="synthetic_actor", request_id="synthetic_request",
            question_id="OES-SYNTH-Q0-offline", original_text="Synthetic text",
        )
        self.assertNotEqual(trial.entity_uuid, trial.version_uuid)
        self.assertEqual(trial.expected_insert_count, 5)
        self.assertTrue(trial.rollback_required)
        with patch(
            "evidence.question_orm_q0_connected_recipe_dormant.transaction.atomic",
            side_effect=AssertionError("unexpected transaction"),
        ):
            with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
                _rollback_recipe(
                    alias=trial.target_alias, actor_id=trial.actor_id,
                    request_id=trial.request_id, question_id=trial.question_id,
                    original_text=trial.original_text, fingerprint=trial.fingerprint,
                    trial=trial,
                )

    def test_synthetic_trial_mismatches_hold_before_repository(self):
        trial = prepare_q0_trial_review(
            actor_id="synthetic_actor", request_id="synthetic_request",
            question_id="OES-SYNTH-Q0-offline", original_text="Synthetic text",
        )
        cases = (
            replace(trial, entity_uuid=trial.version_uuid),
            replace(trial, expected_insert_count=4),
            replace(trial, rollback_required=False),
            replace(trial, target_alias="other_alias"),
            replace(trial, fingerprint="b" * 64),
        )
        for mismatch in cases:
            with self.subTest(mismatch=mismatch):
                with patch(
                    "evidence.question_orm_q0_connected_recipe_dormant.DjangoQ0Repository",
                    side_effect=AssertionError("repository must not be reached"),
                ):
                    with self.assertRaisesRegex(PreparationHold, "identity mismatch"):
                        _rollback_recipe(
                            alias=trial.target_alias, actor_id=trial.actor_id,
                            request_id=trial.request_id, question_id=trial.question_id,
                            original_text=trial.original_text, fingerprint=trial.fingerprint,
                            trial=mismatch,
                        )

    def test_synthetic_preflight_rejects_non_synthetic_identifier(self):
        from scripts.q0_rollback_trial_preflight_offline import TrialHold
        with self.assertRaisesRegex(TrialHold, "only synthetic"):
            prepare_q0_trial_review(
                actor_id="synthetic_actor", request_id="synthetic_request",
                question_id="actual-question", original_text="Synthetic text",
            )

    def test_recipe_documents_independent_boundary_and_point_probes(self):
        import inspect
        from evidence.question_orm_q0_connected_recipe_dormant import _rollback_recipe
        source = inspect.getsource(_rollback_recipe)
        self.assertIn("connection.in_atomic_block", source)
        self.assertIn("connection.get_autocommit()", source)
        self.assertIn("transaction.set_rollback(True, using=alias)", source)
        self.assertIn("HOLD: residual Q0 records after rollback", source)
        self.assertIn('verified_zero_residues": True', source)


    def test_pf_i03_proposal_requires_canonical_uuid4_actor(self):
        from uuid import uuid4
        from scripts.q0_rollback_trial_preflight_offline import (
            prepare_pf_i03_q0_trial, TrialHold,
        )
        kwargs = dict(request_id="pf-i03-isolated-request",
                      question_id="OES-SYNTH-Q0-PF-I03-isolated",
                      original_text="Pergunta Q0 puramente sintetica")
        for actor in ("oes_synthetic_q0", "oes:actor:invalid", "oes:actor:123"):
            with self.subTest(actor=actor), self.assertRaises(TrialHold):
                prepare_pf_i03_q0_trial(actor_id=actor, **kwargs)
        actor = "oes:actor:" + str(uuid4())
        trial = prepare_pf_i03_q0_trial(actor_id=actor, **kwargs)
        self.assertEqual(trial.actor_id, actor)
        self.assertTrue(trial.rollback_required)


    def test_pf_i03_review_wiring_stays_blocked_before_connection(self):
        from scripts.pf_i03_q0_rollback_candidate_offline import (
            build_review_candidate, _review_only_orm_wiring,
        )
        trial = build_review_candidate()
        with patch(
            "evidence.question_orm_q0_connected_recipe_dormant.transaction.atomic",
            side_effect=AssertionError("unexpected connected transaction"),
        ):
            with self.assertRaisesRegex(PreparationHold, "writer gate G2"):
                _review_only_orm_wiring(trial)
