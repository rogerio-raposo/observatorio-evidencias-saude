"""OES Marco B: exactly-one synthetic Django preparer, manual gated runner.

Only the separately approved manual GitHub Actions workflow may invoke this.
Never call Django migrations, Q0 executor, or provision a real user.
"""
import os
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from uuid import UUID, uuid4

import django
from django.contrib.auth.hashers import make_password
from psycopg import connect

from preparer_identity.provisioning_plan_offline import (
    Outcome, classify_readback, SyntheticIdentityPlan,
)

HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
DB = "oes_sandbox"
USERNAME = "oes_synth_preparer_marco_b_trial_20261029"
CONTENT_TYPE = ("evidence", "oesquestion")
PERMISSION = ("Can prepare an OES question", "prepare_question")
LOCK = 405171002917


def require(condition, reason):
    if not condition:
        raise RuntimeError("HOLD: " + reason)


def connection(role, secret, readonly=False):
    return connect(
        host=HOST, port=5432, dbname=DB, user=role,
        password=os.environ[secret], sslmode="require",
        options="-c search_path=django_auth,public"
                + (" -c default_transaction_read_only=on" if readonly else ""),
        connect_timeout=12,
    )


def check_identity(cur, role, readonly):
    cur.execute(
        "SELECT current_user, session_user, current_database(), "
        "current_schema(), current_setting('search_path'), "
        "current_setting('transaction_read_only')"
    )
    actual = cur.fetchone()
    require(actual[:5] == (role, role, DB, "django_auth", "django_auth,public"),
            "wrong connected identity or schema")
    require(actual[5] == ("on" if readonly else "off"), "wrong read-only mode")


def reconcile(actor_uuid):
    """Independent read-only session; never echoes synthetic identifiers."""
    try:
        with connection("oes_auth_trial_login", "OES_Q0_AUTH_PASSWORD", True) as reader:
            with reader.cursor() as cur:
                check_identity(cur, "oes_auth_trial_login", True)
                cur.execute("""
                    SELECT u.id, u.password, u.is_active, u.is_staff,
                           u.is_superuser, i.user_id, i.actor_uuid
                    FROM django_auth.auth_user u
                    LEFT JOIN django_auth.preparer_identity_prepareridentity i
                      ON i.user_id=u.id
                    WHERE u.username=%s
                """, (USERNAME,))
                records = cur.fetchall()
                require(len(records) <= 1, "duplicate synthetic username")
                if not records:
                    facts = dict(user_found=False, identity_found=False,
                                 permission_found=False, flags_valid=False,
                                 same_user_link=False, same_actor_uuid=False,
                                 no_extra_access=False, read_complete=True,
                                 independent_reader=True)
                else:
                    user_id, password, active, staff, superuser, linked, uuid = records[0]
                    cur.execute("""
                        SELECT p.codename, ct.app_label, ct.model
                        FROM django_auth.auth_user_user_permissions up
                        JOIN django_auth.auth_permission p ON up.permission_id=p.id
                        JOIN django_auth.django_content_type ct ON p.content_type_id=ct.id
                        WHERE up.user_id=%s
                    """, (user_id,))
                    permissions = cur.fetchall()
                    cur.execute(
                        "SELECT EXISTS(SELECT 1 FROM django_auth.auth_user_groups WHERE user_id=%s)",
                        (user_id,),
                    )
                    in_group = cur.fetchone()[0]
                    facts = dict(
                        user_found=True, identity_found=linked is not None,
                        permission_found=permissions == [("prepare_question", "evidence", "oesquestion")],
                        flags_valid=active is True and staff is False and superuser is False
                                    and isinstance(password, str) and password.startswith("!"),
                        same_user_link=linked == user_id,
                        same_actor_uuid=uuid == actor_uuid,
                        no_extra_access=not in_group and len(permissions) == 1,
                        read_complete=True, independent_reader=True,
                    )
                return classify_readback(**facts)
    except Exception:
        return Outcome.UNCERTAIN_OR_DIVERGENT


def run_once():
    require(os.getenv("OES_SINGLE_TRIAL_APPROVAL") == "APPROVED_20261029",
            "manual single-use approval absent")
    require(os.getenv("GITHUB_REF") == "refs/heads/main", "wrong GitHub branch")
    require(os.getenv("GITHUB_SHA") == os.getenv("OES_APPROVED_SHA"), "unreviewed revision")
    for name in ("OES_AUTH_MIGRATOR_PASSWORD", "OES_Q0_AUTH_PASSWORD"):
        require(bool(os.getenv(name)), "required secret unavailable")
    django.setup()
    plan = SyntheticIdentityPlan(USERNAME, uuid4())
    committed = False
    write_started = False
    try:
        with connection("oes_auth_migrator", "OES_AUTH_MIGRATOR_PASSWORD") as admin:
            with admin.cursor() as cur:
                check_identity(cur, "oes_auth_migrator", False)
                cur.execute("SELECT pg_advisory_xact_lock(%s)", (LOCK,))
                cur.execute("SELECT EXISTS(SELECT 1 FROM django_auth.auth_user)")
                require(cur.fetchone()[0] is False, "auth users already present")
                cur.execute("""
                    SELECT EXISTS(SELECT 1 FROM django_auth.auth_permission p
                    JOIN django_auth.django_content_type ct ON ct.id=p.content_type_id
                    WHERE p.codename='prepare_question' AND ct.app_label='evidence'
                      AND ct.model='oesquestion')
                """)
                require(cur.fetchone()[0] is False, "permission already exists; reconcile first")
                cur.execute("SELECT COUNT(*) FROM django_auth.preparer_identity_prepareridentity")
                require(cur.fetchone()[0] == 0, "preexisting OES identities")
                # Start writes only after complete preflight and advisory lock.
                write_started = True
                cur.execute("""
                    INSERT INTO django_auth.django_content_type(app_label,model)
                    VALUES (%s,%s) ON CONFLICT (app_label,model) DO NOTHING
                    RETURNING id
                """, CONTENT_TYPE)
                ct_row = cur.fetchone()
                if ct_row is None:
                    cur.execute("SELECT id FROM django_auth.django_content_type WHERE app_label=%s AND model=%s", CONTENT_TYPE)
                    ct_row = cur.fetchone()
                require(ct_row is not None, "content type unavailable")
                cur.execute("""
                    INSERT INTO django_auth.auth_permission(name,content_type_id,codename)
                    VALUES (%s,%s,%s) RETURNING id
                """, (PERMISSION[0],ct_row[0],PERMISSION[1]))
                permission_id = cur.fetchone()[0]
                cur.execute("""
                    INSERT INTO django_auth.auth_user
                    (password,last_login,is_superuser,username,first_name,last_name,email,
                     is_staff,is_active,date_joined)
                    VALUES (%s,NULL,FALSE,%s,'','','',FALSE,TRUE,NOW()) RETURNING id
                """, (make_password(None),plan.username))
                user_id = cur.fetchone()[0]
                cur.execute("""
                    INSERT INTO django_auth.preparer_identity_prepareridentity(actor_uuid,user_id)
                    VALUES (%s,%s)
                """, (plan.actor_uuid,user_id))
                cur.execute("""
                    INSERT INTO django_auth.auth_user_user_permissions(user_id,permission_id)
                    VALUES (%s,%s)
                """, (user_id,permission_id))
                cur.execute("""
                    SELECT count(*) FROM django_auth.auth_user_user_permissions
                    WHERE user_id=%s AND permission_id=%s
                """, (user_id,permission_id))
                require(cur.fetchone()[0] == 1, "permission link invariant failed")
            # Context manager commits ONCE; on errors psycopg rolls back.
        committed = True
    except Exception:
        outcome = reconcile(plan.actor_uuid) if write_started else Outcome.UNCERTAIN_OR_DIVERGENT
        print("HOLD: transaction failed; reconciliation=" + outcome.value)
        raise RuntimeError("HOLD: provisioning not certified; no retry") from None

    outcome = reconcile(plan.actor_uuid)
    if committed and outcome == Outcome.COMMITTED_VERIFIED:
        print("PASS_POST_COMMIT: one synthetic preparer and exact permission link verified")
    else:
        print("HOLD: post-commit reconciliation=" + outcome.value)
        raise RuntimeError("HOLD: post-commit evidence insufficient; no retry")


if __name__ == "__main__":
    run_once()
