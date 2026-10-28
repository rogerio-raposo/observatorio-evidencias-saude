"""Read-only checks for the dedicated G2 trial role. No DML."""
from django.db import connections

def verify_g2_read_only(connection=None):
    conn = connection or connections["default"]
    cfg = conn.settings_dict
    if (cfg.get("USER") != "oes_auth_trial_login"
            or cfg.get("NAME") != "oes_sandbox"
            or cfg.get("OPTIONS", {}).get("options") != "-c search_path=django_auth"):
        raise RuntimeError("HOLD: unexpected G2 connection")
    with conn.cursor() as cursor:
        cursor.execute("SELECT current_database(), current_user, current_schema(), has_schema_privilege(current_user, 'django_auth', 'USAGE'), has_schema_privilege(current_user, 'django_auth', 'CREATE')")
        result = cursor.fetchone()
    if tuple(result) != ("oes_sandbox", "oes_auth_trial_login", "django_auth", True, False):
        raise RuntimeError("HOLD: G2 access mismatch")
    return "PASS_G2_P1_READ_ONLY"
