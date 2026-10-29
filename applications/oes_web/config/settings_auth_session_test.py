"""Isolated SQLite-only settings for Django session contract tests; no Neon."""
from .settings import *  # noqa: F401,F403
DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}
PASSWORD_HASHERS = ["django.contrib.auth.hashers.MD5PasswordHasher"]
SESSION_ENGINE = "django.contrib.sessions.backends.db"
