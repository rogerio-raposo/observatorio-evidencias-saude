"""Disposable auth SQLite plus optional approved synthetic PostgreSQL READ ONLY.

Default scientific alias is dummy. No credentials, no migrations on PG.
"""
import os
from .settings import *  # noqa: F401,F403

DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}
DATABASES["oes_scientific_hold"] = {"ENGINE": "django.db.backends.dummy"}

if os.getenv("OES_AUTH_SANDBOX_PG_READER") == "1":
    host = os.getenv("OES_AUTH_SANDBOX_PG_HOST")
    password = os.getenv("OES_AUTH_SANDBOX_PG_PASSWORD")
    approved_hosts = (
        "ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech",
        "ep-wispy-dream-b6021bw0-pooler.c-2.sa-east-1.aws.neon.tech",
    )
    if host not in approved_hosts or not password:
        raise RuntimeError("HOLD: approved synthetic reader host and credential required")
    DATABASES["oes_synthetic_reader"] = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "oes_sandbox",
        "USER": "oes_pg_a4_reader",
        "PASSWORD": password,
        "HOST": host,
        "PORT": "5432",
        "OPTIONS": {"sslmode": "require", "options": "-c default_transaction_read_only=on"},
        "CONN_MAX_AGE": 0,
    }
