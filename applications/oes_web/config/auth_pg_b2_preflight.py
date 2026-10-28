"""One-shot B2 PostgreSQL connection preflight: SELECT only, never migrations.

Requires independently approved connected read and the existing opt-in settings.
"""
from django.db import connections

QUERY = """
SELECT current_database(), session_user, current_user,
       current_setting('search_path'), current_schema(),
       current_schemas(false)::text,
       has_schema_privilege(current_user, 'django_auth', 'USAGE'),
       has_schema_privilege(current_user, 'django_auth', 'CREATE'),
       (SELECT count(*) FROM pg_catalog.pg_class
        WHERE relnamespace = 'django_auth'::regnamespace)
"""

def read_only_preflight(connection=None):
    conn = connection if connection is not None else connections["default"]
    config = conn.settings_dict
    if (config.get("ENGINE") != "django.db.backends.postgresql"
            or config.get("NAME") != "oes_sandbox"
            or config.get("USER") != "oes_auth_migrator"
            or config.get("OPTIONS", {}).get("options") != "-c search_path=django_auth"):
        raise RuntimeError("HOLD: unauthorized B2 Django connection configuration")
    with conn.cursor() as cursor:
        cursor.execute(QUERY)
        result = cursor.fetchone()
    if (len(result) != 9
            or result[0:3] != ("oes_sandbox", "oes_auth_migrator", "oes_auth_migrator")
            or result[3] != "django_auth"
            or result[4] != "django_auth"
            or result[5] != "{django_auth}"
            or result[6:8] != (True, True)
            or result[8] != 0):
        raise RuntimeError("HOLD: B2 PostgreSQL search_path or grants not verified")
    return {"status": "PASS_READ_ONLY_DJANGO_AUTH_SCHEMA", "schema": "django_auth"}
