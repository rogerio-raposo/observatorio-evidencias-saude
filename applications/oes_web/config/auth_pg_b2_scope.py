"""Fail closed if Django's installed migration graph exceeds the approved B2-M1 apps."""
from django.db.migrations.loader import MigrationLoader

ALLOWED = frozenset({"auth", "contenttypes", "sessions", "preparer_identity"})

def assert_approved_migration_scope(loader=None):
    loader = loader if loader is not None else MigrationLoader(None)
    present = {app for app, name in loader.disk_migrations}
    unexpected = present - ALLOWED
    missing = ALLOWED - present
    if unexpected or missing:
        raise RuntimeError(
            "HOLD: B2-M1 migration graph out of scope; "
            f"unexpected={sorted(unexpected)} missing={sorted(missing)}"
        )
    return "B2_M1_APPROVED_MIGRATION_GRAPH"
