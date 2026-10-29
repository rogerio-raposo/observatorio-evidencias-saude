"""Single-trial Django Q0 integration review, deliberately non-executable.

No connection, SQL, ORM write, credential or bypass of the general Q0 HOLD.
The connected implementation requires source review and separate CI.
"""
from evidence.question_preparation import PreparationHold
from evidence.q0_rollback_execution_gate_offline import (
    RollbackTrialBoundary, validate_persisted_actor_trial,
)


def review_candidate(*, authenticated_actor_id, trial):
    boundary = RollbackTrialBoundary(
        writer_alias="oes_q0_writer",
        reader_alias="oes_synthetic_reader",
        operation_count=5,
        rollback_required=True,
        synthetic_only=True,
        authenticated_actor_bound=True,
        independent_readback_required=True,
    )
    boundary.review()
    validate_persisted_actor_trial(
        authenticated_actor_id=authenticated_actor_id, trial=trial,
    )
    return "REVIEW_READY_CONNECTED_HOLD"


def run_connected(*args, **kwargs):
    raise PreparationHold("HOLD: isolated Q0 connected rollback runner not validated")


if __name__ == "__main__":
    raise SystemExit("HOLD: review-only; no connected execution")
