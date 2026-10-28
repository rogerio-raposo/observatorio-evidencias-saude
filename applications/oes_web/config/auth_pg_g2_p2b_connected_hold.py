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
    classify_connected_reconciliation,
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
                cursor.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
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
    """Internal review placeholder. No operational write path exists."""
    raise ProvisioningHold(
        "HOLD: internal connected candidate unavailable until named DML gate"
    )


def run_connected_trial(*, password=None, exclusive_window_confirmed=False):
    """Permanent public HOLD pending independent nominal DML gate."""
    raise ProvisioningHold(
        "HOLD: G2-P2-B connected DML runner not authorized or enabled"
    )


def _classify_trial_outcome(*, phase, error=None, postcommit=None):
    """Pure fail-closed state machine; never authorizes retry or DML."""
    if phase == "PRECOMMIT_ROLLBACK_CONFIRMED" and error is not None:
        return "FAIL_ROLLED_BACK"
    if phase == "COMMIT_CONFIRMED" and error is None:
        return "PASS_POST_COMMIT" if postcommit == "PASS_POST_COMMIT" else "INDETERMINATE_HOLD"
    return "INDETERMINATE_HOLD"


def _offline_integration_probe(*, password, inject_failure=False):
    """SQLite-only rehearsal of atomic write and relational readback.

    Does NOT prove separate PostgreSQL connection semantics or enable DML.
    """
    from config.auth_pg_g2_p2b_offline import (
        _offline_guard, _provision_transaction,
        collect_relation_snapshot_offline,
    )
    _offline_guard("default")
    try:
        before_and_after = _provision_transaction(
            password=password, using="default", inject_failure=inject_failure,
        )
    except ProvisioningHold as exc:
        if not inject_failure:
            raise
        return _classify_trial_outcome(
            phase="PRECOMMIT_ROLLBACK_CONFIRMED", error=exc,
        )
    snapshot = collect_relation_snapshot_offline()
    expected = {
        "fixture_users": 1,
        "fixture_active_nonstaff_nonsuperuser": True,
        "fixture_password_usable": True,
        "fixture_permission_count": 1,
        "fixture_permission_links": 1,
        "fixture_identities": 1,
        "fixture_uuid4": True,
    }
    valid = all(snapshot.get(key) == value for key, value in expected.items())
    valid = valid and snapshot["counts"] == before_and_after["after"]
    return _classify_trial_outcome(
        phase="COMMIT_CONFIRMED",
        postcommit="PASS_POST_COMMIT" if valid else "INDETERMINATE_HOLD",
    )
