"""Offline safety checks for the proposed Q0 rollback trial. No DB."""
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from evidence.question_orm_q0_rollback_plan_offline import (
    q0_rollback_plan, execute_q0_rollback_trial,
)


class OfflineQ0RollbackPlanTests(SimpleTestCase):
    def test_five_writes_and_rollback_required(self):
        plan = q0_rollback_plan()
        self.assertEqual(plan.expected_writes, 5)
        self.assertTrue(plan.requires_same_alias)
        self.assertTrue(plan.requires_explicit_rollback)
        self.assertFalse(plan.permits_commit)
        self.assertEqual(plan.stages[-2:], (
            "mark_rollback", "verify_no_residual_records"))

    def test_no_unapproved_connected_entrypoint(self):
        with self.assertRaisesRegex(PreparationHold, "G2-P2B NO-GO"):
            execute_q0_rollback_trial()

    def test_plan_contains_no_connected_operations(self):
        plan = q0_rollback_plan()
        self.assertEqual(plan.stages.count("insert_receipt"), 1)
        self.assertNotIn("commit", plan.stages)
        self.assertNotIn("set_role", plan.stages)
