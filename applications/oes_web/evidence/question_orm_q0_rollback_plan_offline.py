"""Offline-only Q0 rollback harness specification; never executes connected SQL.

No implicit alias, factory or repository. A separate connected authorization
and reviewed implementation are prerequisites. This plan is immutable data.
"""
from dataclasses import dataclass
from .question_preparation import PreparationHold


@dataclass(frozen=True)
class Q0RollbackPlan:
    expected_writes: int = 5
    stages: tuple = (
        "verify_identity_and_transaction",
        "lock_request",
        "lock_question",
        "insert_entity",
        "insert_question",
        "insert_entity_version",
        "insert_question_version",
        "insert_receipt",
        "verify_five_synthetic_records",
        "mark_rollback",
        "verify_no_residual_records",
    )
    requires_same_alias: bool = True
    requires_explicit_rollback: bool = True
    permits_commit: bool = False


def q0_rollback_plan():
    return Q0RollbackPlan()


def execute_q0_rollback_trial(*args, **kwargs):
    """Deliberately non-activatable; no Django connection or SQL issued."""
    raise PreparationHold(
        "HOLD: connected Q0 rollback trial not authorized; G2-P2B NO-GO"
    )
