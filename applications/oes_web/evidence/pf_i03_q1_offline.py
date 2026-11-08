"""PF-I03-A2: strictly offline presentation of an authorized synthetic Q1 proposal.

No HTTP endpoint, database connection, routing decision, Q2 or E9 execution.
The injected Unit of Work owns version checks, replay, scope and original match.
"""
from .question_preparation import QuestionCommand, PreparationHold, submit_question_command


def present_synthetic_q1(*, user, command, unit_of_work=None):
    if (type(command) is not QuestionCommand
            or not isinstance(command.question_id, str)
            or not command.question_id.startswith("OES-SYNTH-Q0-")
            or type(command.expected_version) is not int
            or command.expected_version < 1
            or not isinstance(command.normalized_text, str)
            or not command.normalized_text.strip()
            or not isinstance(command.justification, str)
            or not command.justification.strip()):
        raise PreparationHold("HOLD: PF-I03-A2 accepts a justified synthetic Q1 only")
    receipt = submit_question_command(user=user, command=command, unit_of_work=unit_of_work)
    return _present_q1_receipt(command, receipt)


def _present_q1_receipt(command, receipt):
    if (set(receipt) != {"status", "question_id", "version"}
            or receipt["status"] != "PREPARATORY_ONLY"
            or receipt["question_id"] != command.question_id
            or receipt["version"] != command.expected_version + 1):
        raise PreparationHold("HOLD: invalid Q1 presentation receipt")
    return {
        "question_id": receipt["question_id"],
        "version": receipt["version"],
        "original_text": command.original_text,
        "proposed_normalized_text": command.normalized_text,
        "justification": command.justification,
        "state": "PREPARATORY_ONLY",
        "scientific_review": "NOT_PERFORMED",
        "q2": "NOT_EXECUTED",
        "routing": "NOT_AUTHORIZED",
        "e9": "BLOCKED",
    }


def present_authenticated_q1(*, user, command, unit_of_work=None):
    """Authenticated general proposal; no scientific or connected assurance."""
    from .question_preparation import propose_authenticated_q1
    receipt = propose_authenticated_q1(user=user, command=command, unit_of_work=unit_of_work)
    result = _present_q1_receipt(command, receipt)
    result.update(admissibility="NOT_DECIDED", investigation="NOT_OPENED",
                  technical_evidence="OFFLINE_RECEIPT_VERIFIED")
    return result
