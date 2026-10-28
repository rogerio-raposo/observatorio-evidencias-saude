"""Explicit opt-in Django administrator session smoke; no migrations or writers."""
import os
from .settings_auth_pg_design import *  # noqa: F401,F403

if os.environ.get("OES_AUTH_G2_P2B_SMOKE_OPT_IN") != "1":
    raise RuntimeError("HOLD: G2-P2-B admin Django smoke requires explicit opt-in")
host = os.environ.get("OES_AUTH_G2_P2B_SMOKE_HOST", "")
password = os.environ.get("OES_AUTH_G2_P2B_SMOKE_PASSWORD", "")
if host != "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech" or not password:
    raise RuntimeError("HOLD: approved endpoint and disposable secret required")

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
