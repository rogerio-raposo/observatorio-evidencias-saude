"""Pure review gate for a future single Q0 rollback trial.

Never opens a connection or enables the dormant ORM repository.
"""
from dataclasses import dataclass
from .question_preparation import PreparationHold


@dataclass(frozen=True)
class RollbackTrialBoundary:
    writer_alias: str
    reader_alias: str
    operation_count: int
    rollback_required: bool
    synthetic_only: bool
    authenticated_actor_bound: bool
    independent_readback_required: bool

    def review(self):
        if (self.writer_alias != "oes_q0_writer"
                or self.reader_alias != "oes_synthetic_reader"
                or type(self.operation_count) is not int
                or self.operation_count != 5
                or self.rollback_required is not True
                or self.synthetic_only is not True
                or self.authenticated_actor_bound is not True
                or self.independent_readback_required is not True):
            raise PreparationHold("HOLD: rollback-only boundary mismatch")
        return True


def execute_connected_rollback_trial(*args, **kwargs):
    raise PreparationHold("HOLD: connected Q0 rollback trial requires separate nominal gate")


def validate_persisted_actor_trial(*, authenticated_actor_id, trial):
    """Pure identity binding: never accept actor selected independently by caller."""
    from scripts.q0_rollback_trial_preflight_offline import (
        SyntheticQ0Trial, validate_pf_i03_actor_format,
    )
    if type(trial) is not SyntheticQ0Trial:
        raise PreparationHold("HOLD: invalid trial type")
    try:
        validate_pf_i03_actor_format(authenticated_actor_id)
    except (ValueError, TypeError):
        raise PreparationHold("HOLD: invalid authenticated actor") from None
    if (trial.actor_id != authenticated_actor_id
            or trial.rollback_required is not True
            or trial.expected_insert_count != 5
            or trial.target_alias != "oes_q0_writer"
            or not trial.question_id.startswith("OES-SYNTH-Q0-")):
        raise PreparationHold("HOLD: trial actor or rollback identity mismatch")
    return True
