"""Resolve stable actor ID from persisted auth database, never from request fields."""
from evidence.preparer_actor_identity import preparer_actor_id
from evidence.question_preparation import PreparationHold
from .models import PreparerIdentity

def persisted_preparer_actor_id(user):
    if getattr(user, "is_authenticated", False) is not True or getattr(user, "pk", None) is None:
        raise PreparationHold("HOLD: authenticated preparer required")
    try:
        identity = PreparerIdentity.objects.using("default").get(user_id=user.pk)
    except PreparerIdentity.DoesNotExist:
        raise PreparationHold("HOLD: persistent preparer identity not established") from None
    class BoundIdentity:
        oes_actor_uuid = identity.actor_uuid
    return preparer_actor_id(BoundIdentity())
