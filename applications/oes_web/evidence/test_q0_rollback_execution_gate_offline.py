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
