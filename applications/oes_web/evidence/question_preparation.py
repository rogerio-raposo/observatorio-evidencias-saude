"""W1 offline command contract: injected unit of work, no database connection."""
from dataclasses import dataclass
from hashlib import sha256
import json
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
    from preparer_identity.resolver import persisted_preparer_actor_id
    return submit_question_command(
        user=user, command=command, unit_of_work=unit_of_work,
        actor_id_resolver=persisted_preparer_actor_id,
    )
