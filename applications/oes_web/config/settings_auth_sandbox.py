"""Ephemeral SQLite-only authentication test settings; never connected to Neon."""
from .settings import *  # noqa: F401,F403

DATABASES = {"default": {"ENGINE": "django.db.backends.sqlite3", "NAME": ":memory:"}}

# Reserved scientific alias deliberately has no driver or connection in this test.
# Auth migrations and sessions use only the disposable default SQLite database.
DATABASES["oes_scientific_hold"] = {"ENGINE": "django.db.backends.dummy"}
