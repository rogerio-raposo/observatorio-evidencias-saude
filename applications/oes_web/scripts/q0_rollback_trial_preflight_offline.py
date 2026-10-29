"""Offline-only preflight for a future, separately authorized Django Q0 rollback trial.

Never connects, configures a database, or enables the dormant ORM repository.
No executable connected trial is exposed by this module.
"""
from dataclasses import dataclass
from hashlib import sha256
from uuid import UUID, uuid4


class TrialHold(ValueError):
    """Fail-closed trial preflight rejection."""


@dataclass(frozen=True)
class SyntheticQ0Trial:
    actor_id: str
    request_id: str
    question_id: str
    original_text: str
    fingerprint: str
    entity_uuid: UUID
    version_uuid: UUID
    target_alias: str = "oes_qprep_trial"
    expected_insert_count: int = 5
    rollback_required: bool = True


def prepare_synthetic_q0_trial(*, actor_id: str, request_id: str,
                               question_id: str, original_text: str) -> SyntheticQ0Trial:
    """Validate prospective identifiers offline; create no DB connection."""
    for label, value in (("actor_id", actor_id), ("request_id", request_id)):
        if not isinstance(value, str) or not (1 <= len(value) <= 128) or not value.strip():
            raise TrialHold(f"HOLD: invalid {label}")
    for label, value in (("question_id", question_id), ("original_text", original_text)):
        if not isinstance(value, str) or not value.strip():
            raise TrialHold(f"HOLD: invalid {label}")
    if not question_id.startswith("OES-SYNTH-Q0-"):
        raise TrialHold("HOLD: only synthetic question identifiers")
    payload = "\x1f".join((actor_id, request_id, question_id, original_text))
    fingerprint = sha256(payload.encode("utf-8")).hexdigest()
    return SyntheticQ0Trial(actor_id, request_id, question_id, original_text,
                            fingerprint, uuid4(), uuid4())


def execute_connected_q0_rollback_trial(*args, **kwargs):
    """Intentionally blocked: G2-P2B is NO-GO; no database entrypoint."""
    raise TrialHold("HOLD: connected Django Q0 rollback trial not authorized; G2-P2B NO-GO")


def validate_pf_i03_actor_format(actor_id: str) -> None:
    """Structural check only; does NOT establish persisted Django identity."""
    if not isinstance(actor_id, str) or not actor_id.startswith("oes:actor:"):
        raise TrialHold("HOLD: PF-I03 actor must use persisted identity format")
    try:
        identity = UUID(actor_id[len("oes:actor:"):])
    except (ValueError, AttributeError):
        raise TrialHold("HOLD: PF-I03 actor UUID invalid") from None
    if identity.version != 4 or str(identity) != actor_id[len("oes:actor:"):]:
        raise TrialHold("HOLD: PF-I03 actor must be canonical UUID4")


def prepare_pf_i03_q0_trial(*, actor_id: str, request_id: str,
                            question_id: str, original_text: str) -> SyntheticQ0Trial:
    """Offline proposal; actor provenance must be separately proven before DML."""
    validate_pf_i03_actor_format(actor_id)
    return prepare_synthetic_q0_trial(
        actor_id=actor_id, request_id=request_id,
        question_id=question_id, original_text=original_text,
    )
