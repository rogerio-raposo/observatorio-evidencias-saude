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


def _provision_transaction(*, password, using="default", inject_failure=False,
                           expected_baseline=None):
    """Internal ORM unit of work; callers must establish their own authorization.

    Not an operational entry point. Never invoke directly against Neon.
    """
    if not isinstance(password, str) or not password:
        raise ProvisioningHold("HOLD: synthetic password required")
    User = get_user_model()
    with transaction.atomic(using=using):
        # Preflight is inside the same transaction as all writes.
        before = _baseline(using)
        if expected_baseline is not None and before != expected_baseline:
            raise ProvisioningHold("HOLD: exact baseline mismatch before writes")
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


# Pure contract checks only: these functions never open a database connection.
# Connected execution remains unimplemented and requires a separate gate.
CONNECTED_BASELINE = {
    "users": 0, "permissions": 44, "links": 0,
    "identities": 0, "sessions": 0,
}
CONNECTED_POSTFLIGHT = {
    "users": 1, "permissions": 45, "links": 1,
    "identities": 1, "sessions": 0,
}


def validate_connected_contract(*, approved, role, database, schema,
                                baseline, postflight=None):
    """Validate non-secret administrative evidence; never authorize execution.

    Approval is a required external fact, not something this function grants.
    This is a documentary/offline validation contract, not a connected runner.
    """
    if approved is not True:
        raise ProvisioningHold("HOLD: explicit connected authorization required")
    if (role, database, schema) != (
        "oes_auth_migrator", "oes_sandbox", "django_auth"
    ):
        raise ProvisioningHold("HOLD: administrative connection identity drift")
    if type(baseline) is not dict or baseline != CONNECTED_BASELINE:
        raise ProvisioningHold("HOLD: connected baseline drift")
    if postflight is not None and (
        type(postflight) is not dict or postflight != CONNECTED_POSTFLIGHT
    ):
        raise ProvisioningHold("HOLD: connected postflight drift")
    return "CONTRACT_VALIDATED_OFFLINE_NOT_AUTHORIZED_TO_EXECUTE"


def classify_post_commit(*, before, after, commit_confirmed):
    """Pure conservative assessment, never a database read or retry instruction.

    Post-commit evidence must be collected independently by an authorized
    read-only connection. An unknown commit cannot be declared rolled back.
    """
    if commit_confirmed is not True:
        return "INDETERMINATE_HOLD"
    if type(before) is not dict or before != CONNECTED_BASELINE:
        return "INDETERMINATE_HOLD"
    if type(after) is not dict or after != CONNECTED_POSTFLIGHT:
        return "INDETERMINATE_HOLD"
    return "PASS_POST_COMMIT"


def verify_synthetic_relations_offline(*, using="default"):
    """Read-only relationship reconciliation in disposable SQLite only.

    This is not independent PostgreSQL post-commit evidence. A connected
    verifier must use a newly established authorized read-only session.
    """
    _offline_guard(using)
    from django.db import transaction
    User = get_user_model()
    with transaction.atomic(using=using):
        counts = {
            "users": User.objects.using(using).count(),
            "permissions": Permission.objects.using(using).count(),
            "links": User.user_permissions.through.objects.using(using).count(),
            "identities": PreparerIdentity.objects.using(using).count(),
            "sessions": Session.objects.using(using).count(),
        }
        users = User.objects.using(using).filter(
            username=USERNAME, is_active=True, is_staff=False, is_superuser=False
        )
        permissions = Permission.objects.using(using).filter(
            content_type__app_label="evidence",
            content_type__model="oesquestion", codename=PERMISSION,
        )
        if users.count() != 1 or permissions.count() != 1:
            raise ProvisioningHold("HOLD: synthetic user or permission missing")
        user, permission = users.get(), permissions.get()
        if not user.has_usable_password():
            raise ProvisioningHold("HOLD: synthetic password unusable")
        if not User.user_permissions.through.objects.using(using).filter(
            user_id=user.pk, permission_id=permission.pk
        ).exists():
            raise ProvisioningHold("HOLD: synthetic permission link missing")
        identities = PreparerIdentity.objects.using(using).filter(user_id=user.pk)
        if identities.count() != 1 or identities.get().actor_uuid.version != 4:
            raise ProvisioningHold("HOLD: synthetic identity missing or invalid")
        if any(counts[k] != 1 for k in ("users", "links", "identities")) or counts["sessions"] != 0:
            raise ProvisioningHold("HOLD: synthetic relation counts drift")
        return "PASS_OFFLINE_RELATION_RECONCILIATION"
