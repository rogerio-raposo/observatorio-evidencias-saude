"""G2-P2-B single-trial Django integration candidate. HARD HOLD; never run connected.

This module is offline-reviewable. The only public entry point is permanently
blocked until a separate nominal DML authorization and code review. It does not
provide CLI, secrets, settings, network setup or a workflow trigger.
"""
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.sessions.models import Session
from django.db import connections, transaction
from preparer_identity.models import PreparerIdentity

from config.auth_pg_g2_p2b_offline import (
    USERNAME, PERMISSION, CONNECTED_BASELINE, ProvisioningHold,
    _provision_transaction, classify_connected_reconciliation,
)

EXPECTED_IDENTITY = (
    "oes_sandbox", "oes_auth_migrator", "oes_auth_migrator",
    "django_auth", "django_auth",
)


def _require_admin_session(conn):
    """Check an already-open authorized Django connection, not a grant."""
    settings = conn.settings_dict
    if (conn.vendor != "postgresql"
            or settings.get("NAME") != "oes_sandbox"
            or settings.get("USER") != "oes_auth_migrator"
            or settings.get("OPTIONS", {}).get("options") != "-c search_path=django_auth"
            or settings.get("CONN_MAX_AGE") != 0):
        raise ProvisioningHold("HOLD: administrative Django connection mismatch")
    with conn.cursor() as cursor:
        cursor.execute(
            "SELECT current_database(), session_user, current_user, "
            "current_schema(), current_setting('search_path')"
        )
        if tuple(cursor.fetchone()) != EXPECTED_IDENTITY:
            raise ProvisioningHold("HOLD: actual PostgreSQL identity drift")


def _snapshot_using_existing_readonly_connection(conn):
    """ORM SELECT only; caller guarantees fresh connection and READ ONLY txn."""
    alias = conn.alias
    User = get_user_model()
    counts = {
        "users": User.objects.using(alias).count(),
        "permissions": Permission.objects.using(alias).count(),
        "links": User.user_permissions.through.objects.using(alias).count(),
        "identities": PreparerIdentity.objects.using(alias).count(),
        "sessions": Session.objects.using(alias).count(),
    }
    users = User.objects.using(alias).filter(username=USERNAME)
    valid = users.filter(is_active=True, is_staff=False, is_superuser=False)
    permissions = Permission.objects.using(alias).filter(
        content_type__app_label="evidence",
        content_type__model="oesquestion", codename=PERMISSION,
    )
    user = users.first()
    permission = permissions.first()
    identity_qs = (
        PreparerIdentity.objects.using(alias).filter(user_id=user.pk)
        if user is not None else PreparerIdentity.objects.using(alias).none()
    )
    links = (
        User.user_permissions.through.objects.using(alias).filter(
            user_id=user.pk, permission_id=permission.pk,
        ).count()
        if user is not None and permission is not None else 0
    )
    return {
        "counts": counts,
        "fixture_users": users.count(),
        "fixture_active_nonstaff_nonsuperuser": valid.count() == 1,
        "fixture_password_usable": bool(user and user.has_usable_password()),
        "fixture_permission_count": permissions.count(),
        "fixture_permission_links": links,
        "fixture_identities": identity_qs.count(),
        "fixture_uuid4": (
            identity_qs.count() == 1 and identity_qs.first().actor_uuid.version == 4
        ),
    }


def _independent_readonly_reconciliation(*, baseline, commit_confirmed, using="default"):
    """Candidate: reopen connection after commit; fail closed on any error.

    Never retry automatically, never mark indeterminate execution as rollback.
    """
    conn = connections[using]
    conn.close()
    try:
        with transaction.atomic(using=using):
            with conn.cursor() as cursor:
                cursor.execute("SET TRANSACTION READ ONLY")
            _require_admin_session(conn)
            snapshot = _snapshot_using_existing_readonly_connection(conn)
        return classify_connected_reconciliation(
            commit_confirmed=commit_confirmed,
            baseline=baseline, snapshot=snapshot,
        )
    except Exception:
        return "INDETERMINATE_HOLD"
    finally:
        conn.close()


def _trial_candidate(*, password, exclusive_window_confirmed, using="default"):
    """Internal proposal, NOT an execution entry point or authorization.

    A separate authorization must explicitly approve unlocking and the complete
    operational workflow; this function MUST NOT be called meanwhile.
    """
    raise ProvisioningHold("HOLD: internal connected candidate unavailable until named DML gate")
    if exclusive_window_confirmed is not True:
        raise ProvisioningHold("HOLD: external writers not excluded")
    conn = connections[using]
    _require_admin_session(conn)
    # Core code owns the atomic transaction, baseline and ORM write checks.
    try:
        outcome = _provision_transaction(
            password=password, using=using, expected_baseline=CONNECTED_BASELINE,
        )
    except Exception:
        # Commit status cannot be inferred from every exception.
        return "INDETERMINATE_HOLD"
    return _independent_readonly_reconciliation(
        baseline=outcome["before"], commit_confirmed=True, using=using,
    )


def run_connected_trial(*, password=None, exclusive_window_confirmed=False):
    """Permanent public HOLD pending independent nominal DML gate."""
    raise ProvisioningHold(
        "HOLD: G2-P2-B connected DML runner not authorized or enabled"
    )
