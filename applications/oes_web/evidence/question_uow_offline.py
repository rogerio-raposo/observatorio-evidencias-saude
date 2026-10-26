"""PF-I02-W1B: offline-only transactional protocol; no DB driver or SQL."""
from dataclasses import dataclass
from .question_preparation import PreparationConflict, PreparationHold

@dataclass(frozen=True)
class Receipt:
    actor_id: str
    request_id: str
    fingerprint: str
    question_id: str
    version: int
    command_kind: str
    justification: str = ""

class OfflineQuestionUnitOfWork:
    """Adapter for a supplied transactional port. Never owns a connection.

    Port.begin() returns context manager with lock_request, find_receipt,
    current_question, can_access_question, register_q0, propose_q1, save_receipt methods.
    The port must guarantee atomicity and lock semantics in a future backend.
    """
    def __init__(self, port):
        self.port = port

    def execute(self, *, command, actor_id, fingerprint):
        if not actor_id or not fingerprint:
            raise PreparationHold("HOLD: invalid command identity")
        is_q0 = command.normalized_text is None
        if is_q0 != (command.expected_version == 0):
            raise PreparationHold("HOLD: invalid command transition")
        with self.port.begin() as tx:
            tx.lock_request(actor_id, command.request_id)
            previous = tx.find_receipt(actor_id, command.request_id)
            if previous is not None:
                if (previous.fingerprint != fingerprint or previous.question_id != command.question_id
                        or previous.actor_id != actor_id):
                    raise PreparationConflict("HOLD: request fingerprint conflict")
                # A receipt is never an authorization token: verify current scope again.\n                if not tx.can_access_question(previous.question_id, actor_id):\n                    raise PreparationConflict("HOLD: stale or inaccessible question")\n                return {"status": "PREPARATORY_ONLY", "question_id": previous.question_id,
                        "version": previous.version}
            current = tx.current_question(command.question_id, actor_id, lock=not is_q0)
            if is_q0:
                if current is not None:
                    raise PreparationConflict("HOLD: question already exists")
                tx.register_q0(command, actor_id)
            else:
                if current is None or current["version"] != command.expected_version:
                    raise PreparationConflict("HOLD: stale or inaccessible question")
                if current["original_text"] != command.original_text:
                    raise PreparationConflict("HOLD: original question mismatch")
                tx.propose_q1(command, actor_id)
            version = command.expected_version + 1
            tx.save_receipt(Receipt(actor_id, command.request_id, fingerprint,
                                    command.question_id, version, "REGISTER_Q0" if is_q0 else "PROPOSE_Q1",\n                                    command.justification if not is_q0 else ""))
        return {"status": "PREPARATORY_ONLY", "question_id": command.question_id,
                "version": version}
