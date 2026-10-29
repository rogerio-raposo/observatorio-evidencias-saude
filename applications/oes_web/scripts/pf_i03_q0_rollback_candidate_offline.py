"""PF-I03 Q0 offline-only candidate for a SINGLE rollback trial.

This entrypoint cannot connect or write. A separately reviewed executable,
credentials and nominal DML authorization are required for a real trial.
"""
from uuid import uuid4

from evidence.question_preparation import PreparationHold
from scripts.q0_rollback_trial_preflight_offline import prepare_pf_i03_q0_trial


def build_review_candidate():
    """Pure synthetic metadata, not a persisted preparer identity."""
    token = uuid4()
    return prepare_pf_i03_q0_trial(
        actor_id="oes:actor:" + str(uuid4()),
        request_id="pf-i03-q0-review-" + token.hex,
        question_id="OES-SYNTH-Q0-PF-I03-" + token.hex,
        original_text="Pergunta Q0 ficticia para revisao offline de rollback?",
    )



def review_rollback_contract(trial):
    """Offline-only check; cannot attest persisted Django identity or enable DML."""
    from scripts.q0_rollback_trial_preflight_offline import (
        SyntheticQ0Trial, validate_pf_i03_actor_format,
    )
    from evidence.question_orm_q0_rollback_plan_offline import q0_rollback_plan
    if type(trial) is not SyntheticQ0Trial:
        raise PreparationHold("HOLD: unexpected trial type")
    validate_pf_i03_actor_format(trial.actor_id)
    plan = q0_rollback_plan()
    if (trial.target_alias != "oes_qprep_trial"
            or not trial.question_id.startswith("OES-SYNTH-Q0-PF-I03-")
            or trial.expected_insert_count != plan.expected_writes
            or trial.rollback_required is not True
            or plan.permits_commit is not False
            or plan.requires_same_alias is not True
            or plan.requires_explicit_rollback is not True):
        raise PreparationHold("HOLD: rollback-only contract mismatch")
    return "PF_I03_Q0_ROLLBACK_REVIEW_PASS_CONNECTED_HOLD"


def _review_only_orm_wiring(trial):
    """Exact wiring planned for a future nominally authorized transaction.

    The underlying repository constructor remains HARD HOLD, so this method
    never provides a connection or a working DML executor. No bypass objects,
    repository injection, settings mutation, or credentials are accepted.
    """
    review_rollback_contract(trial)
    from evidence.question_orm_q0_connected_recipe_dormant import _rollback_recipe
    return _rollback_recipe(
        alias=trial.target_alias, actor_id=trial.actor_id,
        request_id=trial.request_id, question_id=trial.question_id,
        original_text=trial.original_text, fingerprint=trial.fingerprint,
        trial=trial,
    )


def execute_candidate(*args, **kwargs):
    """Permanent HOLD; do not use injection to bypass repository constructor."""
    raise PreparationHold("HOLD: PF-I03 connected ORM rollback requires separate DML gate")


if __name__ == "__main__":
    trial = build_review_candidate()
    assert review_rollback_contract(trial) == "PF_I03_Q0_ROLLBACK_REVIEW_PASS_CONNECTED_HOLD"
    print("PF_I03_Q0_CANDIDATE_OFFLINE_PASS_CONNECTED_HOLD")
