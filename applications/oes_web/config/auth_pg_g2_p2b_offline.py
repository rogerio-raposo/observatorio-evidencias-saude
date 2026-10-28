"""G2-P2-B administrative provisioning core. OFFLINE ONLY until separate approval.

No CLI, workflow, network connection or credential integration is provided.
Do not use this module to authorize a connected operation.
"""
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.db import connections, transaction
from django.contrib.sessions.models import Session
from preparer_identity.models import PreparerIdentity

USERNAME = "oes_g2_trial_fixture"
PERMISSION = "prepare_question"


class ProvisioningHold(RuntimeError):
    pass


def _offline_guard(using):
    conn = connections[using]
    if using != "default" or conn.vendor != "sqlite":
        raise ProvisioningHold("HOLD: G2-P2-B connected provisioning is not authorized")
    name = str(conn.settings_dict.get("NAME", ""))
    test_uri = f"file:memorydb_{using}?mode=memory&cache=shared"
    if name not in (":memory:", test_uri):
        raise ProvisioningHold("HOLD: only disposable in-memory SQLite is permitted")


def _baseline(using):
    User = get_user_model()
    counts = {
        "users": User.objects.using(using).count(),
        "permissions": Permission.objects.using(using).count(),
        "links": User.user_permissions.through.objects.using(using).count(),
        "identities": PreparerIdentity.objects.using(using).count(),
        "sessions": Session.objects.using(using).count(),
    }
    ct = ContentType.objects.using(using).filter(app_label="evidence", model="oesquestion")
    custom = Permission.objects.using(using).filter(
        content_type__app_label="evidence", content_type__model="oesquestion",
        codename=PERMISSION,
    )
    if any(counts[key] != 0 for key in ("users", "links", "identities", "sessions")):
        raise ProvisioningHold("HOLD: nonempty identity or authorization baseline")
    if ct.count() != 1 or custom.exists():
        raise ProvisioningHold("HOLD: content type or permission baseline drift")
    return counts


def _provision_transaction(*, password, using="default", inject_failure=False):
    """Internal ORM unit of work; callers must establish their own authorization.

    Not an operational entry point. Never invoke directly against Neon.
    """
    if not isinstance(password, str) or not password:
        raise ProvisioningHold("HOLD: synthetic password required")
    User = get_user_model()
    with transaction.atomic(using=using):
        # Preflight is inside the same transaction as all writes.
        before = _baseline(using)
        # The connected baseline (44 permissions) is a separate, unapproved gate;
        # SQLite migrations populate a different permission inventory.
        ct = ContentType.objects.using(using).get(app_label="evidence", model="oesquestion")
        permission = Permission.objects.using(using).create(
            content_type=ct, codename=PERMISSION, name="Synthetic preparation permission"
        )
        user = User.objects.db_manager(using).create_user(
            username=USERNAME, password=password,
            is_active=True, is_staff=False, is_superuser=False
        )
        if user._state.db != using or permission._state.db != using:
            raise ProvisioningHold("HOLD: ORM instance database alias mismatch")
        user.user_permissions.add(permission)
        identity = PreparerIdentity.objects.using(using).create(user_id=user.pk)
        if inject_failure:
            raise ProvisioningHold("HOLD: injected precommit failure")
        observed = {
            "users": User.objects.using(using).count(),
            "permissions": Permission.objects.using(using).count(),
            "links": User.user_permissions.through.objects.using(using).count(),
            "identities": PreparerIdentity.objects.using(using).count(),
            "sessions": Session.objects.using(using).count(),
        }
        expected = {**before, "users": 1, "permissions": before["permissions"] + 1,
                    "links": 1, "identities": 1, "sessions": 0}
        if observed != expected:
            raise ProvisioningHold("HOLD: postflight count mismatch")
        if identity.actor_uuid.version != 4:
            raise ProvisioningHold("HOLD: invalid synthetic UUID")
    return {"before": before, "after": observed}


def provision_offline(*, password, using="default", inject_failure=False):
    """Only public entry point: disposable SQLite, fail closed before any ORM read."""
    _offline_guard(using)
    result = _provision_transaction(password=password, using=using,
                                    inject_failure=inject_failure)
    return {"status": "PASS_OFFLINE_ONLY", **result}
