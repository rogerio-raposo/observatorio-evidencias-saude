"""PF-I03 Q0: offline-reviewable scientific Django alias, HARD HOLD.

No password, network endpoint, migrations, grants or connected writer.
A separately reviewed connected settings module and nominal DML gate would
be necessary before any Q0 rollback trial.
"""
from .settings_auth_pg_design import *  # noqa: F401,F403

PF_I03_SCIENTIFIC_ALIAS = "oes_qprep_trial"
PF_I03_EXPECTED_DATABASE = "oes_sandbox"
PF_I03_EXPECTED_ROLE = "oes_qprep_login"
PF_I03_EXPECTED_TABLE_SCHEMAS = ("core", "investigation")
PF_I03_ROLLBACK_REQUIRED = True

# Keep BOTH aliases disconnected regardless of ambient environment variables.
DATABASES = {
    "default": {"ENGINE": "django.db.backends.dummy"},
    PF_I03_SCIENTIFIC_ALIAS: {"ENGINE": "django.db.backends.dummy"},
    "oes_scientific_hold": {"ENGINE": "django.db.backends.dummy"},
}

# Prevent incidental auth/scientific ORM writes from being routed to a real DB.
DATABASE_ROUTERS = ["config.auth_sandbox_router.AuthSandboxRouter"]
