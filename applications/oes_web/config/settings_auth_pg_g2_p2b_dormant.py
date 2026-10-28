"""G2-P2-B administrative PostgreSQL settings template — permanently HOLD.

Django First: derive app/router configuration from the existing auth design.
This module must NOT expose a usable database connection before a distinct,
explicitly approved implementation and review. Never place secrets here.
"""
from .settings_auth_pg_design import *  # noqa: F401,F403

# Deliberate irreversible-in-this-module fail-closed gate.
# No environment variable or runtime argument can bypass this HOLD.
raise RuntimeError(
    "HOLD: G2-P2-B connected provisioning settings not authorized; "
    "no PostgreSQL connection or DML entry point"
)
