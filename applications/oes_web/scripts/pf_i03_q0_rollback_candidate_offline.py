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


def execute_candidate(*args, **kwargs):
    """Permanent HOLD; do not use injection to bypass repository constructor."""
    raise PreparationHold("HOLD: PF-I03 connected ORM rollback requires separate DML gate")


if __name__ == "__main__":
    trial = build_review_candidate()
    assert trial.rollback_required and trial.expected_insert_count == 5
    print("PF_I03_Q0_CANDIDATE_OFFLINE_PASS_CONNECTED_HOLD")
