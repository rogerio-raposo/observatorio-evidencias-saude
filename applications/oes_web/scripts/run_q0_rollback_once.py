"""One-shot, manually triggered synthetic Q0 Django ORM trial.

AUTHORIZED SCOPE: five INSERTs in a single transaction, mandatory rollback,
read-only residue verification, restricted role. No migrations, DDL, persistent
writer, HTTP or owner credentials. Never log connection exceptions or secrets.
"""
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
if os.getenv("OES_Q0_TRIAL_EXPLICIT_APPROVAL") != "G2-P2B-FIVE-INSERT-ROLLBACK-ONLY":
    sys.exit("NOT_RUN: explicit trial approval gate absent")
password = os.getenv("OES_QPREP_LOGIN_PASSWORD")
if not password:
    sys.exit("NOT_RUN: temporary password secret absent")
if os.getenv("DJANGO_SETTINGS_MODULE", "config.settings") != "config.settings":
    sys.exit("NOT_RUN: unexpected settings")
os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings"

from django.conf import settings
if settings.DATABASES:
    sys.exit("NOT_RUN: application database configuration must remain absent")

ALIAS = "oes_qprep_trial"
settings.DATABASES = {
    "default": {"ENGINE": "django.db.backends.dummy"},
    ALIAS: {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_qprep_login",
        "PASSWORD": password,
        "HOST": "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech",
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require", "connect_timeout": 10,
                    "options": "-c default_transaction_read_only=off"},
        "CONN_MAX_AGE": 0,
    },
}
import django
django.setup()
from django.db import connections
from evidence.question_orm_q0_connected_recipe_dormant import (
    prepare_q0_trial_review, _rollback_recipe,
)
from evidence.question_orm_q0_repository_dormant import DjangoQ0Repository
from scripts.q0_connected_trial_gate_offline import review_q0_trial

# Only this one-shot script can construct the restricted trial adapter.
# DjangoQ0Repository.__init__ and public connected route remain blocked.
class _OneShotTrialRepository(DjangoQ0Repository):
    def __init__(self, alias):
        if alias != ALIAS:
            raise RuntimeError("unexpected trial alias")
        self.alias = alias


STAGE = "SETUP"


def stage(label):
    global STAGE
    STAGE = label
    print("Q0_TRIAL_STAGE: " + label, flush=True)


def main():
    from uuid import uuid4
    suffix = uuid4().hex
    trial = prepare_q0_trial_review(
        actor_id="oes_synthetic_q0",
        request_id="trial_" + suffix,
        question_id="OES-SYNTH-Q0-" + suffix,
        original_text="Synthetic Q0 rollback transaction: no factual research data.",
    )
    review = review_q0_trial(trial)
    if (review.permits_commit or not review.requires_explicit_rollback
            or not review.requires_zero_residues or review.insert_count != 5
            or review.target_role != "oes_qprep_login"
            or review.target_database != "oes_sandbox"):
        raise RuntimeError("trial contract mismatch")
    stage("CONNECT_AND_AUTHENTICATE")
    conn = connections[ALIAS]
    try:
        with conn.cursor() as cur:
            stage("VERIFY_IDENTITY_AND_PRIVILEGES")
            cur.execute(
                "SELECT session_user, current_user, current_database(), "
                "current_setting('transaction_read_only'), "
                "current_setting('default_transaction_read_only')"
            )
            if cur.fetchone() != (
                "oes_qprep_login", "oes_qprep_login", "oes_sandbox", "off", "off"
            ):
                raise RuntimeError("role/database/transaction mode mismatch")
            cur.execute(
                "SELECT rolcanlogin, rolinherit, rolsuper, rolcreatedb, "
                "rolcreaterole, rolreplication, rolbypassrls "
                "FROM pg_roles WHERE rolname = current_user"
            )
            if cur.fetchone() != (True, True, False, False, False, False, False):
                raise RuntimeError("unexpected role flags")
            cur.execute(
                "SELECT pg_has_role(current_user, 'oes_qprep_writer', 'USAGE'), "
                "COALESCE((SELECT pg_has_role(current_user, r.oid, 'MEMBER') "
                "FROM pg_roles r WHERE r.rolname = 'neon_superuser'), false)"
            )
            if cur.fetchone() != (True, False):
                raise RuntimeError("unexpected role inheritance")
            cur.execute(
                "SELECT m.inherit_option, m.set_option "
                "FROM pg_auth_members m "
                "JOIN pg_roles member ON member.oid=m.member "
                "JOIN pg_roles granted ON granted.oid=m.roleid "
                "WHERE member.rolname=current_user "
                "AND granted.rolname='oes_qprep_writer'"
            )
            if cur.fetchall() != [(True, False)]:
                raise RuntimeError("unexpected membership options")
        if conn.in_atomic_block or not conn.get_autocommit():
            raise RuntimeError("non-independent boundary")
        stage("TRANSACTION_START")
        result = _rollback_recipe(
            alias=ALIAS, actor_id=trial.actor_id, request_id=trial.request_id,
            question_id=trial.question_id, original_text=trial.original_text,
            fingerprint=trial.fingerprint, trial=trial,
            _trial_repository=_OneShotTrialRepository(ALIAS),
            _phase=stage,
        )
        stage("VERIFY_ROLLBACK_EVIDENCE")
        if result != {"status": "ROLLED_BACK_ONLY", "verified_zero_residues": True}:
            raise RuntimeError("unexpected rollback evidence")
        print("PASS_ROLLED_BACK_ZERO_RESIDUES: five ORM INSERTs checked inside "
              "transaction; rollback and zero residual rows verified")
    finally:
        conn.close()


try:
    main()
except BaseException as exc:
    # Never expose exception text, SQL params, host URLs, or the secret.
    sys.exit("INCONCLUSIVE_Q0_TRIAL at " + STAGE + ": " + type(exc).__name__)
