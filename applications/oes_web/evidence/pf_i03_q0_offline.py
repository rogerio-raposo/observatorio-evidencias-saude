"""PF-I03-A1: offline-only Q0 preparation presenter; no HTTP or database setup.

Caller injects an authorized user and an offline unit of work. This function
does not create users, sessions, database connections, or persistent state.
"""
from .question_preparation import QuestionCommand, PreparationHold, submit_question_command


def present_synthetic_q0(*, user, command, unit_of_work=None):
    """Return a minimal, strictly preparatory readback of an injected Q0 result."""
    if (type(command) is not QuestionCommand
            or command.expected_version != 0
            or command.normalized_text is not None
            or not isinstance(command.question_id, str)
            or not command.question_id.startswith("OES-SYNTH-Q0-")):
        raise PreparationHold("HOLD: PF-I03 accepts synthetic Q0 only")
    # Auth and transaction invariants are owned by the existing command service.
    receipt = submit_question_command(
        user=user, command=command, unit_of_work=unit_of_work
    )
    if (set(receipt) != {"status", "question_id", "version"}
            or receipt["status"] != "PREPARATORY_ONLY"
            or receipt["question_id"] != command.question_id
            or receipt["version"] != 1):
        raise PreparationHold("HOLD: invalid Q0 presentation receipt")
    return {
        "question_id": receipt["question_id"],
        "version": receipt["version"],
        "state": "PREPARATORY_ONLY",
        "scientific_review": "NOT_PERFORMED",
        "e9": "BLOCKED",
    }
