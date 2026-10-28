"""G2-P1: allowlisted catalogue-only assertions, no factual rows or DML."""
from django.db import connections

TABLES = {
    "auth_user": (True, False, False, False),
    "auth_group": (True, False, False, False),
    "auth_permission": (True, False, False, False),
    "django_content_type": (True, False, False, False),
    "auth_user_groups": (True, False, False, False),
    "auth_user_user_permissions": (True, False, False, False),
    "auth_group_permissions": (True, False, False, False),
    "preparer_identity_prepareridentity": (True, False, False, False),
    "django_session": (True, True, True, True),
    "django_migrations": (False, False, False, False),
}
QUERY = """
SELECT current_database(), session_user, current_user, current_schema(),
       current_setting('search_path'),
       has_schema_privilege(current_user,'django_auth','USAGE'),
       has_schema_privilege(current_user,'django_auth','CREATE')
"""
TABLE_QUERY = """
SELECT c.relname,
       has_table_privilege(current_user,c.oid,'SELECT'),
       has_table_privilege(current_user,c.oid,'INSERT'),
       has_table_privilege(current_user,c.oid,'UPDATE'),
       has_table_privilege(current_user,c.oid,'DELETE')
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='django_auth' AND c.relkind='r'
ORDER BY c.relname
"""
COLUMN_QUERY = """
SELECT a.attname, has_column_privilege(current_user,c.oid,a.attname,'UPDATE')
FROM pg_catalog.pg_attribute a
JOIN pg_catalog.pg_class c ON c.oid=a.attrelid
JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='django_auth' AND c.relname='auth_user'
  AND a.attnum>0 AND NOT a.attisdropped
ORDER BY a.attnum
"""
SEQUENCE_QUERY = """
SELECT count(*),
       coalesce(bool_or(has_sequence_privilege(current_user,c.oid,'USAGE')
        OR has_sequence_privilege(current_user,c.oid,'SELECT')
        OR has_sequence_privilege(current_user,c.oid,'UPDATE')),false)
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='django_auth' AND c.relkind='S'
"""

def assert_g2_catalogue(identity, tables, columns, sequences):
    if tuple(identity) != ("oes_sandbox","oes_auth_trial_login","oes_auth_trial_login",
                           "django_auth","django_auth",True,False):
        raise RuntimeError("HOLD: G2 identity/schema mismatch")
    actual = {r[0]: tuple(r[1:]) for r in tables}
    if actual != TABLES:
        raise RuntimeError("HOLD: G2 table ACL mismatch")
    if not columns or {name for name, _ in columns if name == "last_login"} != {"last_login"}:
        raise RuntimeError("HOLD: G2 column catalogue incomplete")
    if any(bool(permitted) != (name == "last_login") for name, permitted in columns):
        raise RuntimeError("HOLD: G2 column UPDATE mismatch")
    if tuple(sequences) != (9, False):
        raise RuntimeError("HOLD: G2 sequence ACL mismatch")
    return "PASS_G2_P1_CONNECTED_READ_ONLY"

def verify_g2_read_only(connection=None):
    conn = connection if connection is not None else connections["default"]
    cfg = conn.settings_dict
    if (cfg.get("ENGINE") != "django.db.backends.postgresql"
            or cfg.get("USER") != "oes_auth_trial_login"
            or cfg.get("NAME") != "oes_sandbox"
            or cfg.get("OPTIONS", {}).get("options") != "-c search_path=django_auth"):
        raise RuntimeError("HOLD: unexpected G2 connection")
    with conn.cursor() as cursor:
        cursor.execute(QUERY)
        identity = cursor.fetchone()
        cursor.execute(TABLE_QUERY)
        tables = cursor.fetchall()
        cursor.execute(COLUMN_QUERY)
        columns = cursor.fetchall()
        cursor.execute(SEQUENCE_QUERY)
        sequences = cursor.fetchone()
    return assert_g2_catalogue(identity, tables, columns, sequences)
