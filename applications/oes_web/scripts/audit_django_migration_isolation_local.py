"""PF-I04/P1 disposable PostgreSQL isolation audit; refuses unapproved targets."""
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings_migration_inventory")
if os.getenv("OES_LOCAL_SQL_INVENTORY") != "1":
    raise SystemExit("HOLD: disposable audit flag absent")
import django
django.setup()
from django.conf import settings
from django.core.management import call_command
from django.db import connection

cfg = settings.DATABASES["default"]
if (cfg.get("NAME") != "oes_local_inventory" or cfg.get("HOST") != "127.0.0.1"
        or cfg.get("USER") != "oes_local"
        or "search_path=oes_app" not in cfg.get("OPTIONS", {}).get("options", "")):
    raise SystemExit("HOLD: not the approved disposable local PostgreSQL")
with connection.cursor() as cursor:
    cursor.execute("SELECT current_database(), current_schema(), current_user")
    ident = cursor.fetchone()
    if ident != ("oes_local_inventory", "oes_app", "oes_local"):
        raise SystemExit(f"HOLD: unexpected local target {ident}")
call_command("migrate", interactive=False, verbosity=1)
with connection.cursor() as cursor:
    cursor.execute("""
        SELECT n.nspname, c.relname, c.relkind
        FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname IN ('oes_app','public')
          AND c.relkind IN ('r','p','S','v','m','f')
        ORDER BY n.nspname, c.relname
    """)
    objects = cursor.fetchall()
    cursor.execute("SELECT app, name FROM oes_app.django_migrations ORDER BY app, name")
    applied = cursor.fetchall()
    cursor.execute("SELECT COUNT(*) FROM oes_app.auth_permission")
    permissions = cursor.fetchone()[0]
required = {"auth_user", "auth_group", "auth_permission", "django_content_type",
            "django_session", "django_migrations"}
app_tables = {name for schema, name, kind in objects if schema == "oes_app" and kind in ("r", "p")}
public_objects = [(schema, name, kind) for schema, name, kind in objects if schema == "public"]
if not required.issubset(app_tables) or public_objects:
    raise SystemExit(f"HOLD: schema isolation violated; missing={sorted(required-app_tables)}; public={public_objects}")
if len(applied) != 15:
    raise SystemExit(f"HOLD: expected 15 administrative migrations, got {len(applied)}")
print("ISOLATION PASS: postgres disposable only; schema oes_app")
print("APPLIED:", len(applied), "PERMISSIONS:", permissions)
for schema, name, kind in objects:
    print("OBJECT", schema, name, kind)
