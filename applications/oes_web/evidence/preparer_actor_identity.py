"""Preparatory actor identity contract; no model, database or HTTP wiring.

An application-owned stable UUID must be bound to a Django user in the
future auth store. Never derive a scientific actor identity from username
or an ephemeral Django primary key.
"""
from uuid import UUID
from .question_preparation import PreparationHold


def preparer_actor_id(user):
    """Resolve an explicitly bound immutable identity; fail closed otherwise."""
    raw = getattr(user, "oes_actor_uuid", None)
    if type(raw) is not UUID or raw.version != 4 or raw.int == 0:
        raise PreparationHold("HOLD: persistent preparer identity not established")
    return "oes:actor:" + str(raw)
