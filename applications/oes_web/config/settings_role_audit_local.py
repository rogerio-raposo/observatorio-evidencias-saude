"""Disposable separate-role migration verification, not deployable settings."""
import os
from .settings import *  # noqa: F401,F403
if os.getenv("OES_LOCAL_ROLE_AUDIT") != "1":
    raise RuntimeError("HOLD: disposable role audit disabled")
DATABASES = {"default": {
    "ENGINE": "django.db.backends.postgresql",
    "NAME": "oes_local_inventory",
    "USER": "oes_migrator",
    "PASSWORD": "local-migrator-only",
    "HOST": "127.0.0.1",
    "PORT": "5432",
    "OPTIONS": {"options": "-c search_path=oes_app"},
    "CONN_MAX_AGE": 0,
}}
