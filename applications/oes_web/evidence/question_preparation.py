"""W1 offline command contract: injected unit of work, no database connection."""
from dataclasses import dataclass
from hashlib import sha256
import json
import re
from django.core.exceptions import PermissionDenied
from .preparation_auth import require_question_preparer

class PreparationHold(RuntimeError): pass
class PreparationConflict(PreparationHold): pass

@dataclass(frozen=True)
class QuestionCommand:
    request_id: str
    question_id: str
    expected_version: int
    original_text: str
    normalized_text: str | None = None
    justification: str = ""

def command_fingerprint(command):
    return sha256(json.dumps(command.__dict__,sort_keys=True,ensure_ascii=False).encode()).hexdigest()

def submit_question_command(*, user, command, unit_of_work=None, actor_id_resolver=None):
    """Requires separately authorized injected transactional backend; never creates one."""
    require_question_preparer(user)
    if unit_of_work is None:
        raise PreparationHold("HOLD: persistence unavailable")
    if not isinstance(command,QuestionCommand) or not isinstance(command.request_id,str) or not (1 <= len(command.request_id) <= 128) or not isinstance(command.question_id,str) or not command.question_id:
        raise PreparationHold("HOLD: invalid request")
    if type(command.expected_version) is not int or command.expected_version < 0:
        raise PreparationHold("HOLD: invalid version")
    if not isinstance(command.original_text,str) or not command.original_text or len(command.original_text)>10000:
        raise PreparationHold("HOLD: invalid Q0")
    if command.normalized_text is not None and (not isinstance(command.normalized_text,str) or not command.normalized_text or not isinstance(command.justification,str) or not command.justification.strip()):
        raise PreparationHold("HOLD: invalid Q1")
    try:
        actor_id = str(user.pk) if actor_id_resolver is None else actor_id_resolver(user)
        if not isinstance(actor_id, str) or not actor_id.strip():
            raise PreparationHold("HOLD: invalid actor identity")
        result=unit_of_work.execute(command=command,actor_id=actor_id,fingerprint=command_fingerprint(command))
        if (not isinstance(result,dict) or result.get("status")!="PREPARATORY_ONLY"
                or result.get("question_id")!=command.question_id
                or type(result.get("version")) is not int
                or result["version"] != command.expected_version+1):
            raise PreparationHold("HOLD: invalid transaction receipt")
        return dict(result)
    except PreparationHold: raise
    except Exception:
        raise PreparationHold("HOLD: outcome uncertain; do not retry automatically") from None


def submit_authenticated_question_command(*, user, command, unit_of_work=None):
    """Strict Django auth-store entry point; no fallback to user.pk.

    Historical submit_question_command is retained for isolated offline fixtures.
    No HTTP route, DB factory or PostgreSQL writer is wired here.
    """
    require_question_preparer(user)
    if unit_of_work is None:
        raise PreparationHold("HOLD: persistence unavailable")
    from preparer_identity.resolver import persisted_preparer_actor_id
    return submit_question_command(
        user=user, command=command, unit_of_work=unit_of_work,
        actor_id_resolver=persisted_preparer_actor_id,
    )


Q0_IDENTIFIER_PATTERN = r"[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}"


def validate_register_q0(command):
    """REGISTER_Q0 application boundary; preserve original text and request key.

    Stricter than the historical generic command API, which stays unchanged.
    No actor, Q1/Q2 payload, generated identifier, backend or connection here.
    """
    if (type(command) is not QuestionCommand
            or type(command.expected_version) is not int or command.expected_version != 0
            or command.normalized_text is not None or command.justification != ""):
        raise PreparationHold("HOLD: REGISTER_Q0 command required")
    for value in (command.request_id, command.question_id):
        if not isinstance(value, str) or re.fullmatch(Q0_IDENTIFIER_PATTERN, value) is None:
            raise PreparationHold("HOLD: invalid Q0 identifier")
    if (not isinstance(command.original_text, str) or not command.original_text.strip()
            or len(command.original_text) > 10000 or "\x00" in command.original_text):
        raise PreparationHold("HOLD: original Q0 text required")
    return command


def register_authenticated_q0(*, user, command):
    """Functional Q0 entry; same authenticated D1/D2/D3 path, still source HOLD.

    No injected backend or caller-supplied actor. The canonical service resolves
    the persisted actor and owns UoW/ORM/receipt/readback. Never retry a HOLD.
    """
    require_question_preparer(user)
    validate_register_q0(command)
    from .question_orm_q0_connected_recipe_dormant import _review_q0_persistence_d1
    return _review_q0_persistence_d1(user=user, command=command)


def review_registered_q0(*, user, command):
    """Separate read-recovery blueprint, not a submission or retry operation.

    Classification remains separate from PREPARATORY_ONLY. D3's existing source
    gate remains effective; no HTTP wiring or new persistence is introduced.
    """
    require_question_preparer(user)
    validate_register_q0(command)
    from .question_orm_q0_evidence_dormant import _recover_q0_commit_evidence
    return _recover_q0_commit_evidence(user=user, command=command)
