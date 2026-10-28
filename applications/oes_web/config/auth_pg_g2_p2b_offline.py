"""G2-P2-B administrative provisioning core. OFFLINE ONLY until separate approval.

No CLI, workflow, network connection or credential integration is provided.
Do not use this module to authorize a connected operation.
"""
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.db import connections, transaction
from preparer_identity.models import PreparerIdentity

USERNAME = "oes_g2_trial_fixture"
PERMISSION = "prepare_question"


class ProvisioningHold(RuntimeError):
    pass


def _offline_guard(using):
    conn = connections[using]
    if using != "default" or conn.vendor != "sqlite":
        raise ProvisioningHold("HOLD: G2-P2-B connected provisioning is not authorized")
    if conn.settings_dict.get("NAME") != ":memory:":
        raise ProvisioningHold("HOLD: only disposable in-memory SQLite is permitted")


def _baseline(using):
    _offline_guard(using)
    User = get_user_model()
    counts = {
        "users": User.objects.using(using).count(),
        "permissions": Permission.objects.using(using).count(),
        "links": User.user_permissions.through.objects.using(using).count(),
        "identities": PreparerIdentity.objects.using(using).count(),
    }
    ct = ContentType.objects.using(using).filter(app_label="evidence", model="oesquestion")
    custom = Permission.objects.using(using).filter(
        content_type__app_label="evidence", content_type__model="oesquestion",
        codename=PERMISSION,
    )
    if counts["users"] != 0 or counts["links"] != 0 or counts["identities"] != 0:
        raise ProvisioningHold("HOLD: nonempty identity or authorization baseline")
    if ct.count() != 1 or custom.exists():
        raise ProvisioningHold("HOLD: content type or permission baseline drift")
    return counts


def provision_offline(*, password, using="default", inject_failure=False):
    """Atomically create one synthetic fixture; return non-secret verification only.

    This deliberately cannot run on PostgreSQL. A future connected adapter must
    be separately implemented, reviewed, authorized and revalidated.
    """
    _offline_guard(using)
    if not isinstance(password, str) or not password:
        raise ProvisioningHold("HOLD: synthetic password required")
    before = _baseline(using)
    User = get_user_model()
    with transaction.atomic(using=using):
        # Revalidate inside the transaction; the in-memory sandbox has no writers
        # outside this test process.
        if _baseline(using) != before:
            raise ProvisioningHold("HOLD: baseline changed")
        ct = ContentType.objects.using(using).get(app_label="evidence", model="oesquestion")
        permission = Permission.objects.using(using).create(
            content_type=ct, codename=PERMISSION, name="Synthetic preparation permission"
        )
        user = User.objects.db_manager(using).create_user(
            username=USERNAME, password=password,
            is_active=True, is_staff=False, is_superuser=False
        )
        User.user_permissions.through.objects.using(using).create(
            user_id=user.pk, permission_id=permission.pk
        )
        identity = PreparerIdentity.objects.using(using).create(user_id=user.pk)
        if inject_failure:
            raise ProvisioningHold("HOLD: injected precommit failure")
        observed = {
            "users": User.objects.using(using).count(),
            "permissions": Permission.objects.using(using).count(),
            "links": User.user_permissions.through.objects.using(using).count(),
            "identities": PreparerIdentity.objects.using(using).count(),
        }
        expected = {**before, "users": 1, "permissions": before["permissions"] + 1,
                    "links": 1, "identities": 1}
        if observed != expected:
            raise ProvisioningHold("HOLD: postflight count mismatch")
        if identity.actor_uuid.version != 4:
            raise ProvisioningHold("HOLD: invalid synthetic UUID")
    return {"status": "PASS_OFFLINE_ONLY", "before": before, "after": observed}
