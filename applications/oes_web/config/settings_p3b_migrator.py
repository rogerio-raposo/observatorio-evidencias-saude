"""PF-I04/P3b one-off administrative migrations; never configure runtime with this alias."""
import os
from .settings import *  # noqa: F401,F403

if os.getenv("OES_P3B_APPROVED") != "1":
    raise RuntimeError("P3b is not enabled")
host = os.getenv("OES_P3B_HOST", "")
allowed = {"ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech"}
if host not in allowed or os.getenv("OES_P3B_PASSWORD", "") == "":
    raise RuntimeError("HOLD: approved branch endpoint or one-time credential not provided")
DATABASES = {"default": {
    "ENGINE": "django.db.backends.postgresql",
    "NAME": "oes_sandbox", "USER": "oes_django_migrator",
    "PASSWORD": os.environ["OES_P3B_PASSWORD"],
    "HOST": host, "PORT": "5432",
    "OPTIONS": {"sslmode": "require", "options": "-c search_path=oes_app -c lock_timeout=2000 -c statement_timeout=15000"},
    "CONN_MAX_AGE": 0,
}}
