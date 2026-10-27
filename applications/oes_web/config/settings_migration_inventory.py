"""Disposable CI PostgreSQL only; never use with Neon or deployment."""
import os
from .settings import *  # noqa: F401,F403

if os.environ.get("OES_LOCAL_SQL_INVENTORY") != "1":
    raise RuntimeError("Offline migration inventory gate is disabled")
DATABASES = {"default": {
    "ENGINE": "django.db.backends.postgresql",
    "NAME": "oes_local_inventory",
    "USER": "oes_local",
    "PASSWORD": "local-disposable-only",
    "HOST": "127.0.0.1",
    "PORT": "5432",
    "OPTIONS": {"options": "-c search_path=oes_app"},
    "CONN_MAX_AGE": 0,
}}
