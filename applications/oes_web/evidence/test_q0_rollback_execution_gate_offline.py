"""Review-only unit tests; never open PostgreSQL connections."""
from dataclasses import replace
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from evidence.q0_rollback_execution_gate_offline import (
    RollbackTrialBoundary, execute_connected_rollback_trial,
)


class RollbackTrialBoundaryTests(SimpleTestCase):
    def test_exact_rollback_only_boundary(self):
        boundary = RollbackTrialBoundary(
            writer_alias="oes_q0_writer", reader_alias="oes_synthetic_reader",
            operation_count=5, rollback_required=True, synthetic_only=True,
            authenticated_actor_bound=True, independent_readback_required=True,
        )
        self.assertTrue(boundary.review())
        for mutation in (
            dict(writer_alias="default"), dict(reader_alias="oes_q0_writer"),
            dict(operation_count=4), dict(operation_count=True),
            dict(rollback_required=False), dict(synthetic_only=False),
            dict(authenticated_actor_bound=False),
            dict(independent_readback_required=False),
        ):
            with self.subTest(mutation=mutation), self.assertRaises(PreparationHold):
                replace(boundary, **mutation).review()

    def test_connected_entrypoint_always_holds(self):
        with self.assertRaisesRegex(PreparationHold, "separate nominal gate"):
            execute_connected_rollback_trial()

    def test_persisted_actor_must_match_trial_and_canonical_writer(self):
        from uuid import uuid4
        from dataclasses import replace
        from scripts.q0_rollback_trial_preflight_offline import prepare_pf_i03_q0_trial
        from evidence.q0_rollback_execution_gate_offline import validate_persisted_actor_trial
        actor = "oes:actor:" + str(uuid4())
        trial = prepare_pf_i03_q0_trial(
            actor_id=actor, request_id="rollback-bound-request",
            question_id="OES-SYNTH-Q0-bound", original_text="Synthetic offline text")
        trial = replace(trial, target_alias="oes_q0_writer")
        self.assertTrue(validate_persisted_actor_trial(authenticated_actor_id=actor, trial=trial))
        for case in (
            dict(authenticated_actor_id="oes:actor:" + str(uuid4()), trial=trial),
            dict(authenticated_actor_id=actor, trial=replace(trial, target_alias="default")),
            dict(authenticated_actor_id=actor, trial=replace(trial, rollback_required=False)),
            dict(authenticated_actor_id=actor, trial=replace(trial, expected_insert_count=4)),
            dict(authenticated_actor_id="not-an-actor", trial=trial),
        ):
            with self.subTest(case=case), self.assertRaises(PreparationHold):
                validate_persisted_actor_trial(**case)

    def test_isolated_runner_requires_exact_actor_and_stays_closed(self):
        from uuid import uuid4
        from dataclasses import replace
        from scripts.q0_rollback_trial_preflight_offline import prepare_pf_i03_q0_trial
        from scripts.q0_rollback_isolated_review import review_candidate, run_connected
        actor = "oes:actor:" + str(uuid4())
        trial = replace(prepare_pf_i03_q0_trial(
            actor_id=actor, request_id="review-only",
            question_id="OES-SYNTH-Q0-review-only",
            original_text="Pergunta inteiramente sintetica"),
            target_alias="oes_q0_writer")
        self.assertEqual(review_candidate(authenticated_actor_id=actor, trial=trial),
                         "REVIEW_READY_CONNECTED_HOLD")
        with self.assertRaises(PreparationHold):
            review_candidate(authenticated_actor_id="oes:actor:" + str(uuid4()), trial=trial)
        with self.assertRaises(PreparationHold):
            run_connected()
