"""Manual-only integrated SQLite auth + PG synthetic reader smoke.

Never dispatched by this module. No PostgreSQL migrations or writes.
Requires separate approval and temporary PG reader credential.
"""
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
if os.getenv("OES_AUTH_PG_SMOKE_APPROVED") != "ONE_READ_ONLY_SYNTHETIC":
    sys.exit("NOT_RUN: integrated connected trial is not approved")
if (os.getenv("OES_AUTH_SANDBOX_PG_READER") != "1"
        or not os.getenv("OES_AUTH_SANDBOX_PG_PASSWORD")):
    sys.exit("NOT_RUN: synthetic PostgreSQL reader is disabled")
if os.getenv("DJANGO_SETTINGS_MODULE", "config.settings_auth_sandbox") != "config.settings_auth_sandbox":
    sys.exit("NOT_RUN: isolated authentication settings required")
os.environ["DJANGO_SETTINGS_MODULE"] = "config.settings_auth_sandbox"

import django
django.setup()
from django.conf import settings
from django.core.management import call_command
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.db import connections
from django.test import Client
from django.urls import reverse
from evidence.synthetic_pg_reader import list_synthetic_study_report_links

def main():
    if (settings.DATABASES["default"]["ENGINE"] != "django.db.backends.sqlite3"
            or settings.DATABASES["default"]["NAME"] != ":memory:"
            or settings.DATABASES["oes_scientific_hold"]["ENGINE"] != "django.db.backends.dummy"):
        raise RuntimeError("unexpected authentication or scientific configuration")
    scientific = connections["oes_synthetic_reader"]
    if (scientific.settings_dict["USER"] != "oes_pg_a4_reader"
            or scientific.settings_dict["NAME"] != "oes_sandbox"
            or scientific.settings_dict["OPTIONS"].get("options") != "-c default_transaction_read_only=on"):
        raise RuntimeError("unexpected PostgreSQL reader configuration")
    # Migrations target ONLY ephemeral default SQLite; never PostgreSQL.
    call_command("migrate", database="default", interactive=False, verbosity=0)
    user = get_user_model().objects.create_user(
        username="oes_connected_synthetic_preparer",
        password="synthetic-ephemeral-session-only",
    )
    content_type = ContentType.objects.get(app_label="evidence", model="oesquestion")
    permission, _ = Permission.objects.get_or_create(
        content_type=content_type, codename="prepare_question",
        defaults={"name": "Prepare question (ephemeral integrated test)"},
    )
    user.user_permissions.add(permission)
    client = Client()
    if not client.login(username=user.username, password="synthetic-ephemeral-session-only"):
        raise RuntimeError("ephemeral Django login failed")
    access = client.get(reverse("q0-access-status"))
    if (access.status_code != 200
            or access.json() != {"status": "AUTHORIZED_SYNTHETIC_SCOPE_ONLY",
                                 "q0_write_enabled": False}):
        raise RuntimeError("unexpected authorization status")
    if client.post(reverse("q0-access-status")).status_code != 404:
        raise RuntimeError("HTTP write gate not closed")
    with scientific.cursor() as cursor:
        cursor.execute(
            "SELECT current_user, session_user, current_database(), "
            "current_setting('transaction_read_only')"
        )
        if cursor.fetchone() != ("oes_pg_a4_reader", "oes_pg_a4_reader", "oes_sandbox", "on"):
            raise RuntimeError("reader identity or read-only mode mismatch")
    records = list_synthetic_study_report_links()
    if len(records) != 3 or any(x.evidence_boundary != "SYNTHETIC_TECHNICAL_ONLY" for x in records):
        raise RuntimeError("synthetic PostgreSQL projection mismatch")
    response = client.get(reverse("synthetic-pg-links"))
    if response.status_code != 200:
        raise RuntimeError("integrated synthetic GET failed")
    html = response.content.decode("utf-8")
    if not all(str(row.study_entity_uuid) in html for row in records):
        raise RuntimeError("synthetic result missing in HTML")
    print("PASS SQLITE_AUTH_PG_READ_ONLY_SYNTHETIC_THREE_LINKS_Q0_WRITE_BLOCKED")

try:
    main()
except BaseException as exc:
    sys.exit("INCONCLUSIVE_INTEGRATED_READ_ONLY: " + type(exc).__name__)
finally:
    connections.close_all()
