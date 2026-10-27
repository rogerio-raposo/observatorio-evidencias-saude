"""Offline review gate for the proposed single-transaction Q0 trial.

No Django database alias, password, connection, workflow dispatch, or DML.
Connected execution remains blocked in both the recipe and repository.
"""
from dataclasses import dataclass

from scripts.q0_rollback_trial_preflight_offline import (
    SyntheticQ0Trial, TrialHold,
)


@dataclass(frozen=True)
class Q0TrialReview:
    trial: SyntheticQ0Trial
    target_role: str = "oes_qprep_login"
    target_database: str = "oes_sandbox"
    target_branch: str = "br-gentle-hall-b6jaxehf"
    direct_host: str = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
    insert_count: int = 5
    requires_explicit_rollback: bool = True
    requires_zero_residues: bool = True
    permits_commit: bool = False


def review_q0_trial(trial: SyntheticQ0Trial) -> Q0TrialReview:
    """Validate the offline contract; do not configure a DB connection."""
    if (type(trial) is not SyntheticQ0Trial
            or trial.target_alias != "oes_qprep_trial"
            or trial.expected_insert_count != 5
            or trial.rollback_required is not True
            or trial.entity_uuid == trial.version_uuid):
        raise TrialHold("HOLD: invalid synthetic trial contract")
    return Q0TrialReview(trial)


def execute_q0_trial(*args, **kwargs):
    """Cannot execute until a distinct nominal G2-P2B approval and code review."""
    raise TrialHold("HOLD: G2-P2B connected Q0 INSERT trial not authorized")
