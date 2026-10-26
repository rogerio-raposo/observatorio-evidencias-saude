"""Review-only gate tests: never touch an actual database."""
from unittest.mock import patch
from django.test import SimpleTestCase
from evidence.question_preparation import PreparationHold
from evidence.question_orm_q0_connected_recipe_dormant import (
    execute_connected_q0, _rollback_recipe,
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
