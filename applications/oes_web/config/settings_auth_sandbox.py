"""Ephemeral SQLite-only authentication test settings; never connected to Neon."""
from .settings import *  # noqa: F401,F403

DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}
