"""One-shot G2-P2-B synthetic cleanup. Only invoke under named authorization.

No automatic retry. Never use with real users. Independent readback required.
"""
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.contrib.sessions.models import Session
from django.db import connections, transaction
from preparer_identity.models import PreparerIdentity
from config.auth_pg_g2_p2b_connected_hold import _require_admin_session
from config.auth_pg_g2_p2b_offline import USERNAME, PERMISSION, ProvisioningHold, CONNECTED_BASELINE, CONNECTED_POSTFLIGHT


def _counts():
    User = get_user_model()
    return {
        "users": User.objects.count(), "permissions": Permission.objects.count(),
        "links": User.user_permissions.through.objects.count(),
        "identities": PreparerIdentity.objects.count(),
        "sessions": Session.objects.count(),
    }


def _exact_fixture():
    User = get_user_model()
    ct = ContentType.objects.get(app_label="evidence", model="oesquestion")
    u = User.objects.get(username=USERNAME, is_active=True, is_staff=False, is_superuser=False)
    p = Permission.objects.get(content_type=ct, codename=PERMISSION)
    ident = PreparerIdentity.objects.get(user=u)
    if ident.actor_uuid.version != 4 or not u.has_usable_password():
        raise ProvisioningHold("HOLD: synthetic identity or credential invariant")
    if User.user_permissions.through.objects.filter(user=u, permission=p).count() != 1:
        raise ProvisioningHold("HOLD: synthetic link mismatch")
    if (u.groups.count() or u.user_permissions.count() != 1
            or p.group_set.count() or p.user_set.count() != 1):
        raise ProvisioningHold("HOLD: additional authorization links")
    return u, p, ident


def _delete_exact_fixture(*, before, after):
    """Internal transactional unit, with caller-owned atomic transaction."""
    if not connections["default"].in_atomic_block:
        raise ProvisioningHold("HOLD: cleanup requires caller-owned atomic transaction")
    if _counts() != before:
        raise ProvisioningHold("HOLD: connected pre-cleanup counts drift")
    u, p, ident = _exact_fixture()
    ident.delete()
    get_user_model().user_permissions.through.objects.filter(user=u, permission=p).delete()
    u.delete()
    p.delete()
    if _counts() != after:
        raise ProvisioningHold("HOLD: baseline restoration failed")


def cleanup_once(*, authorized=False, exclusive_window=False):
    """Four scoped Django ORM effects; return state, never retry."""
    if authorized is not True or exclusive_window is not True:
        raise ProvisioningHold("HOLD: nominal approval and exclusive window required")
    conn = connections["default"]
    if conn.in_atomic_block:
        raise ProvisioningHold("HOLD: external transaction")
    _require_admin_session(conn)
    try:
        with transaction.atomic(using="default"):
            _delete_exact_fixture(before=CONNECTED_POSTFLIGHT, after=CONNECTED_BASELINE)
    except Exception:
        # A failed commit is not proof of rollback.
        return "INDETERMINATE_HOLD"
    finally:
        conn.close()
    try:
        # A NEW connection and READ ONLY repeatable-read transaction.
        with transaction.atomic(using="default"):
            with conn.cursor() as cursor:
                cursor.execute("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY")
            _require_admin_session(conn)
            if _counts() != CONNECTED_BASELINE:
                return "INDETERMINATE_HOLD"
            User = get_user_model()
            if (User.objects.filter(username=USERNAME).exists()
                    or Permission.objects.filter(
                        content_type__app_label="evidence",
                        content_type__model="oesquestion", codename=PERMISSION,
                    ).exists()):
                return "INDETERMINATE_HOLD"
        return "PASS_CLEANUP_POST_COMMIT"
    except Exception:
        return "INDETERMINATE_HOLD"
    finally:
        conn.close()
