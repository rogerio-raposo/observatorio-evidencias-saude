"""Fail-closed P3b migration runner restricted to one synthetic branch endpoint."""
import os
if os.getenv("OES_P3B_APPROVED") != "1":
    raise SystemExit("HOLD: gate")
os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings_p3b_migrator"
import django
django.setup()
from django.db import connection
from django.core.management import call_command

def inspect():
    with connection.cursor() as cursor:
        cursor.execute("""SELECT current_database(), current_user, current_schema(),
            EXISTS(SELECT 1 FROM pg_namespace WHERE nspname='oes_app')""")
        identity=cursor.fetchone()
        if identity != ("oes_sandbox", "oes_sandbox_owner", "oes_app", True):
            raise RuntimeError(f"HOLD: unexpected SQL identity {identity}")
        cursor.execute("""SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
            WHERE n.nspname='oes_app'""")
        return int(cursor.fetchone()[0])

count=inspect()
if count != 0:
    raise SystemExit(f"HOLD: P3b expects empty oes_app, found {count} objects. Never resume automatically")
call_command("migrate", interactive=False, verbosity=1)
with connection.cursor() as cursor:
    cursor.execute("""SELECT COUNT(*) FROM oes_app.django_migrations""")
    migrations=int(cursor.fetchone()[0])
    cursor.execute("""SELECT COUNT(*) FROM oes_app.auth_permission""")
    permissions=int(cursor.fetchone()[0])
    cursor.execute("""SELECT n.nspname, c.relname, c.relkind
      FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE n.nspname IN ('oes_app','public') AND c.relname
      ~ '^(auth_|django_(session|content_type|migrations))'""")
    objects=cursor.fetchall()
if migrations != 15 or permissions != 40:
    raise RuntimeError(f"HOLD: unexpected administrative rows ({migrations}, {permissions})")
if any(schema == "public" for schema,_,_ in objects):
    raise RuntimeError("HOLD: Django administrative object in public")
print("P3B POSTFLIGHT PASS: migrations=15, permissions=40, isolated schema oes_app")
