"""Dedicated auth + scientific reader metadata attestation; never a writer."""
import os

# Reject mixed profiles BEFORE importing the operational defaults. No environment
# mutation and no writer password needed, read, copied or made available here.
if (os.environ.get("OES_Q0_DJANGO_RO_PROFILE") != "AUTH_AND_Q0_METADATA_ONLY"
        or any(os.environ.get(k) not in (None, "", "0") for k in (
            "OES_PG_A4_ENABLED", "OES_Q0_MULTI_ALIAS_ENABLED",
            "OES_Q0_RECOVERY_READONLY_ENABLED", "OES_AUTH_ATTEST_ONLY"))
        or any(k in os.environ for k in ("OES_Q0_WRITER_PASSWORD", "OES_QPREP_LOGIN_PASSWORD"))):
    raise RuntimeError("HOLD: isolated readonly attestation profile required")
if (not os.environ.get("OES_Q0_AUTH_PASSWORD") or not os.environ.get("OES_PG_A4_PASSWORD")
        or os.environ["OES_Q0_AUTH_PASSWORD"] == os.environ["OES_PG_A4_PASSWORD"]):
    raise RuntimeError("HOLD: distinct auth and reader credentials required")

from .settings import *  # noqa: F401,F403,E402
from .settings import _q0_auth_store  # noqa: E402

DEBUG = False
HOST = "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"
DATABASES = {
    "default": _q0_auth_store(HOST, os.environ["OES_Q0_AUTH_PASSWORD"], readonly=True),
    "oes_synthetic_reader": {
        "ENGINE": "django.db.backends.postgresql", "NAME": "oes_sandbox",
        "USER": "oes_pg_a4_reader", "PASSWORD": os.environ["OES_PG_A4_PASSWORD"],
        "HOST": HOST, "PORT": "5432", "CONN_MAX_AGE": 0,
        "OPTIONS": {"sslmode": "require", "options": "-c default_transaction_read_only=on"},
    },
}
for _config in DATABASES.values():
    _config["OPTIONS"]["connect_timeout"] = 12
    _config["CONN_HEALTH_CHECKS"] = False
