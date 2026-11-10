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


def validate_propose_q1(command):
    """PROPOSE_Q1 uses the existing command, never a replacement for Q0."""
    if (type(command) is not QuestionCommand or type(command.expected_version) is not int
            or command.expected_version < 1):
        raise PreparationHold("HOLD: valid expected Q1 version required")
    validate_register_q0(QuestionCommand(command.request_id, command.question_id, 0, command.original_text))
    for value in (command.normalized_text, command.justification):
        if not isinstance(value, str) or not value.strip() or len(value) > 10000 or "\x00" in value:
            raise PreparationHold("HOLD: justified Q1 proposal required")
    return command


def propose_authenticated_q1(*, user, command, unit_of_work=None):
    """F1 offline seam: existing UoW only; no ORM factory or connected default.

    Normal completion includes a separate receipt lookup in the supplied test
    port. This is logical offline evidence, never PostgreSQL/D3 commit proof.
    """
    from .question_uow_offline import OfflineQuestionUnitOfWork
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    validate_propose_q1(command)
    if type(unit_of_work) is not OfflineQuestionUnitOfWork:
        raise PreparationHold("HOLD: Q1 persistence unavailable")
    actor = persisted_preparer_actor_id(user)
    result = submit_authenticated_question_command(user=user, command=command, unit_of_work=unit_of_work)
    review_authenticated_q1_offline(user=user, command=command, unit_of_work=unit_of_work, _expected_actor=actor)
    return result


def review_authenticated_q1_offline(*, user, command, unit_of_work=None, _expected_actor=None):
    """Read the existing test-port receipt; no submission, Q2 write or DB factory.

    The optional internal comparison preserves identity continuity after Q1.
    Caller input can never replace the identity resolved from PreparerIdentity.
    """
    from .question_uow_offline import OfflineQuestionUnitOfWork, Receipt
    from preparer_identity.resolver import persisted_preparer_actor_id
    require_question_preparer(user)
    validate_propose_q1(command)
    if type(unit_of_work) is not OfflineQuestionUnitOfWork:
        raise PreparationHold("HOLD: Q1 offline receipt unavailable")
    try:
        actor = persisted_preparer_actor_id(user)
        if _expected_actor is not None and actor != _expected_actor:
            raise PreparationHold("HOLD: Q1 actor binding changed")
        expected = Receipt(actor, command.request_id, command_fingerprint(command),
                           command.question_id, command.expected_version + 1, "PROPOSE_Q1", command.justification)
        with unit_of_work.port.begin() as tx:
            tx.lock_request(actor, command.request_id)
            observed = tx.find_receipt(actor, command.request_id)
            current = tx.current_question(command.question_id, actor, lock=False)
            if (type(observed) is not Receipt or observed != expected
                    or not tx.can_access_question(command.question_id, actor)
                    or not isinstance(current, dict) or current.get("original_text") != command.original_text
                    or type(current.get("version")) is not int or current["version"] < expected.version
                    or (current["version"] == expected.version and current.get("normalized_text") != command.normalized_text)):
                raise PreparationHold("HOLD: Q1 offline receipt not verified")
        require_question_preparer(user)
        if persisted_preparer_actor_id(user) != actor:
            raise PreparationHold("HOLD: Q1 actor binding changed during readback")
    except PreparationConflict:
        raise PreparationHold("HOLD: Q1 readback conflict after submission; no automatic retry") from None
    except (PreparationHold, PermissionDenied):
        raise
    except Exception:
        raise PreparationHold("HOLD: Q1 outcome uncertain; no automatic retry") from None
    return observed


def review_authenticated_q0_reference(*, user, request_id, question_id, fingerprint):
    """Authenticated reference only. No browser original or actor is accepted."""
    require_question_preparer(user)
    for value in (request_id, question_id):
        if not isinstance(value, str) or re.fullmatch(Q0_IDENTIFIER_PATTERN, value) is None:
            raise PreparationHold("HOLD: invalid Q0 reference")
    if not isinstance(fingerprint, str) or re.fullmatch(r"[0-9a-f]{64}", fingerprint) is None:
        raise PreparationHold("HOLD: invalid Q0 fingerprint reference")
    from .question_orm_q0_evidence_dormant import _recover_q0_reference
    return _recover_q0_reference(user=user, request_id=request_id, question_id=question_id, fingerprint=fingerprint)


def _q0_failure_evidence(error, *, phase, boundary, candidate_present):
    """Sanitized attempt facts, not a claim that all Q0 records are absent."""
    from django.db import DatabaseError
    cause = error.__cause__ if isinstance(error.__cause__, BaseException) else error
    state = getattr(cause, "sqlstate", None)
    diag = getattr(cause, "diag", None)
    constraint = (getattr(diag, "schema_name", None), getattr(diag, "table_name", None),
                  getattr(diag, "constraint_name", None))
    # Names follow the versioned DDL. Unknown/live schema differences fail closed.
    known = {("core", "entity", "entity_oes_id_key"): "GLOBAL_IDENTIFIER",
             ("investigation", "question_command_receipt", "question_command_receipt_pkey"): "REQUEST_KEY",
             ("core", "entity_version", "entity_version_entity_uuid_version_no_key"): "VERSION_KEY"}
    deterministic = isinstance(error, DatabaseError) and (state in ("23502", "23503", "23514", "22001", "22P02", "40001", "40P01", "55P03", "57014")
                          or (state == "23505" and constraint in known))
    if phase == "PREFLIGHT":
        kind, attempt = "BEFORE_TRANSACTION", "NOT_STARTED"
    elif boundary == "ROLLED_BACK":
        kind, attempt = ("DETERMINISTIC_ROLLBACK" if deterministic else "FAILURE_ROLLED_BACK"), "ROLLED_BACK"
    elif boundary == "COMMIT_ACKNOWLEDGED":
        kind, attempt = "POST_COMMIT_VERIFICATION_FAILED", "COMMIT_ACKNOWLEDGED"
    else:
        kind, attempt = "COMMIT_OR_TRANSACTION_UNCERTAIN", "UNKNOWN"
    if isinstance(error, PreparationConflict) and not candidate_present and phase == "IN_TRANSACTION":
        kind = "CONTRACT_CONFLICT"
    result = {"kind": kind, "attempt_outcome": attempt, "automatic_retry": False}
    if deterministic and boundary == "ROLLED_BACK":
        result["sqlstate"] = state
        if state == "23505": result["constraint_class"] = known[constraint]
    return result
