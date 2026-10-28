"""G2-P0: fail-closed, isolated Django auth trial settings; never a web-write enablement.

Importing this module does not open a database connection. Connected use requires
separate explicit approval and an ephemeral secret; no scientific database alias.
"""
import os
from .settings_auth_pg_design import *  # noqa: F401,F403

if os.environ.get("OES_AUTH_G2_EXPLICIT_OPT_IN") != "1":
    raise RuntimeError("HOLD: G2 runtime connected trial not authorized")
host = os.environ.get("OES_AUTH_G2_HOST", "")
password = os.environ.get("OES_AUTH_G2_PASSWORD", "")
allowed = {"ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"}
if host not in allowed or not password:
    raise RuntimeError("HOLD: dedicated G2 endpoint and ephemeral credential required")
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_auth_trial_login",
        "PASSWORD": password,
        "HOST": host,
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require", "options": "-c search_path=django_auth"},
        "CONN_MAX_AGE": 0,
    },
    "oes_scientific_hold": {"ENGINE": "django.db.backends.dummy"},
}
