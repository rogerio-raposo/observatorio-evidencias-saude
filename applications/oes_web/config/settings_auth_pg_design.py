"""NON-CONNECTING PostgreSQL auth schema design; never use as runtime settings.

Intentionally contains no DATABASES connection credentials or enabled database.
Review PostgreSQL-specific migration/search_path behavior before authorizing DDL.
"""
from .settings import *  # noqa: F401,F403

INSTALLED_APPS = [*INSTALLED_APPS, "preparer_identity"]
DATABASE_ROUTERS = ["config.auth_sandbox_router.AuthSandboxRouter"]
DATABASES = {
    "default": {"ENGINE": "django.db.backends.dummy"},
    "oes_scientific_hold": {"ENGINE": "django.db.backends.dummy"},
}
AUTH_SCHEMA = "django_auth"
# PostgreSQL connection design only (NOT active):
# NAME=oes_sandbox, OPTIONS={"sslmode":"require",
#   "options":"-c search_path=django_auth"}
# The eventual connection must be approved and fail closed if schema/role
# privileges are absent. No auto-creation of schema or HTTP writing.
