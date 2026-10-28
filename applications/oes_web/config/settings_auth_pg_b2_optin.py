"""Opt-in Django migration configuration: authorization is external and mandatory.

Loading this settings module never connects to Neon. No HTTP writer is enabled.
"""
import os
from .settings_auth_pg_design import *  # noqa: F401,F403

if os.environ.get("OES_AUTH_B2_EXPLICIT_OPT_IN") != "1":
    raise RuntimeError("HOLD: B2 PostgreSQL migration configuration not authorized")
host = os.environ.get("OES_AUTH_B2_HOST", "")
password = os.environ.get("OES_AUTH_B2_PASSWORD", "")
allowed = {"ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"}
if host not in allowed or not password:
    raise RuntimeError("HOLD: approved Neon endpoint and ephemeral credential required")
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_auth_migrator",
        "PASSWORD": password,
        "HOST": host,
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require", "options": "-c search_path=django_auth"},
        "CONN_MAX_AGE": 0,
    },
    "oes_scientific_hold": {"ENGINE": "django.db.backends.dummy"},
}
