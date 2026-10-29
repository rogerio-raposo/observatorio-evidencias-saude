"""Isolated, manually invoked, auth-only attestation settings.

Never configure a scientific writer or the ordinary Django auth session.
"""
import os
from .settings import *  # noqa: F401,F403

HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
if os.environ.get("OES_AUTH_ATTEST_ONLY") != "1":
    raise RuntimeError("HOLD: explicit auth-only attestation gate required")
if not os.environ.get("OES_Q0_AUTH_PASSWORD"):
    raise RuntimeError("HOLD: auth reader credential missing")
DATABASES = {
    "default": {"ENGINE": "django.db.backends.dummy"},
    "oes_auth_readonly": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_auth_trial_login",
        "PASSWORD": os.environ["OES_Q0_AUTH_PASSWORD"],
        "HOST": HOST,
        "PORT": "5432",
        "OPTIONS": {
            "sslmode": "require",
            "connect_timeout": 12,
            "options": "-c search_path=django_auth,public -c default_transaction_read_only=on",
        },
        "CONN_MAX_AGE": 0,
    },
}
