"""Read-only synthetic-service identity attestation for the isolated Q0 trial.

Not authentication, not HTTP authorization, and never a DML gate.
"""
from uuid import UUID
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.db import connections
from evidence.question_preparation import PreparationHold
from .models import PreparerIdentity

RESERVED_USERNAME = "oes_synth_preparer_marco_b_trial_20261029"
EXPECTED_PERMISSION = ("evidence", "oesquestion", "prepare_question")


def classify_synthetic_identity(*, users, identities, permissions, groups):
    """Pure fail-closed classifier; callers supply complete query results."""
    if len(users) != 1 or len(identities) != 1:
        raise PreparationHold("HOLD: synthetic identity cardinality")
    user, identity = users[0], identities[0]
    if (user.username != RESERVED_USERNAME or user.pk != identity.user_id
            or user.is_active is not True or user.is_staff is not False
            or user.is_superuser is not False
            or not isinstance(user.password, str)
            or not user.password.startswith("!")):
        raise PreparationHold("HOLD: synthetic identity flags or binding")
    actor = identity.actor_uuid
    if type(actor) is not UUID or actor.version != 4 or str(actor) != str(UUID(str(actor))):
        raise PreparationHold("HOLD: invalid persisted synthetic actor")
    if list(permissions) != [EXPECTED_PERMISSION] or list(groups):
        raise PreparationHold("HOLD: synthetic permission or group mismatch")
    return "oes:actor:" + str(actor)


def attest_synthetic_identity_readonly():
    """One read-only alias; returns actor only to the offline isolated review.

    Requires an already configured independent auth-store alias and never
    fabricates is_authenticated or calls login/force_login.
    """
    conn = connections["default"]
    if conn.vendor != "postgresql" or conn.in_atomic_block or not conn.get_autocommit():
        raise PreparationHold("HOLD: auth-store connection boundary")
    try:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT current_user,current_database(),current_schema(),"
                "current_setting('transaction_read_only')"
            )
            if cursor.fetchone() != ("oes_auth_trial_login", "oes_sandbox",
                                     "django_auth", "on"):
                raise PreparationHold("HOLD: auth-store readonly identity")
        users = list(get_user_model().objects.using("default").filter(
            username=RESERVED_USERNAME))
        identities = (list(PreparerIdentity.objects.using("default").filter(
            user_id=users[0].pk)) if len(users) == 1 else [])
        permissions = (list(Permission.objects.using("default").filter(
            user__pk=users[0].pk).values_list(
                "content_type__app_label", "content_type__model", "codename"))
            if len(users) == 1 else [])
        groups = (list(users[0].groups.using("default").values_list("pk", flat=True))
                  if len(users) == 1 else [])
        return classify_synthetic_identity(
            users=users, identities=identities, permissions=permissions, groups=groups)
    except PreparationHold:
        raise
    except Exception as exc:
        raise PreparationHold("HOLD: synthetic auth readback unavailable") from exc
    finally:
        conn.close()
