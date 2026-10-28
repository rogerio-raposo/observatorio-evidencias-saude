"""Read-only B2-M1 postflight; inspection failure never skips fingerprint check."""
from pathlib import Path
from django.db import connections
from django.db.migrations.loader import MigrationLoader
from config.auth_pg_b2_inventory import compare_baseline

APPS = frozenset({"auth", "contenttypes", "sessions", "preparer_identity"})

def inspect_migration_state(connection):
    # MigrationLoader checks the actual migration recorder using SELECT only.
    loader = MigrationLoader(connection)
    expected = {key for key in loader.disk_migrations if key[0] in APPS}
    actual = set(loader.applied_migrations)
    print("B2_M1_EXPECTED_MIGRATION_COUNT", len(expected), flush=True)
    print("B2_M1_RECORDED_MIGRATION_COUNT", len(actual), flush=True)
    if not expected or expected != actual:
        print("B2_M1_MISSING_MIGRATIONS", sorted(expected - actual), flush=True)
        print("B2_M1_UNEXPECTED_MIGRATIONS", sorted(actual - expected), flush=True)
        raise RuntimeError("HOLD: migration recorder differs from complete disk plan")
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT current_user, current_schema(),
                   (SELECT count(*) FROM pg_catalog.pg_class
                    WHERE relnamespace='django_auth'::regnamespace)
        """)
        identity = cursor.fetchone()
        print("B2_M1_POSTFLIGHT_ROLE_SCHEMA_OBJECTS", identity, flush=True)
        if identity[0:2] != ("oes_auth_migrator", "django_auth"):
            raise RuntimeError("HOLD: postflight connection identity or schema differs")
        cursor.execute("""
            SELECT app_label, model, count(*)
            FROM django_auth.django_content_type
            GROUP BY app_label, model ORDER BY app_label, model
        """)
        print("B2_M1_CONTENT_TYPE_METADATA", cursor.fetchall(), flush=True)
        cursor.execute("""
            SELECT ct.app_label, count(*)
            FROM django_auth.auth_permission AS p
            JOIN django_auth.django_content_type AS ct
              ON ct.id = p.content_type_id
            GROUP BY ct.app_label ORDER BY ct.app_label
        """)
        print("B2_M1_PERMISSION_COUNTS", cursor.fetchall(), flush=True)
    print("B2_M1_MIGRATION_STATE_PASS", flush=True)

def postflight(path, connection=None):
    conn = connection if connection is not None else connections["default"]
    inspection_error = None
    try:
        inspect_migration_state(conn)
    except Exception as error:
        inspection_error = error
        print("B2_M1_MIGRATION_INSPECTION_HOLD", type(error).__name__, flush=True)
    fingerprint_error = None
    try:
        compare_baseline(Path(path))
    except Exception as error:
        fingerprint_error = error
        print("B2_M1_STRUCTURE_INSPECTION_HOLD", type(error).__name__, flush=True)
    if inspection_error or fingerprint_error:
        raise RuntimeError("HOLD: B2-M1 postflight incomplete or divergent") from (inspection_error or fingerprint_error)
    return "B2_M1_POSTFLIGHT_PASS"
