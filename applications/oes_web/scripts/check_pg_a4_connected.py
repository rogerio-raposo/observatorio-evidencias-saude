"""Explicit PG-A4-G2-A Django connection smoke test; synthetic branch only.

Run from applications/oes_web after setting OES_PG_A4_ENABLED=1,
OES_PG_A4_HOST, OES_PG_A4_PASSWORD in a private environment.
Never copy environment credentials into workflow, shell history or logs.
"""
import os
import sys

if os.getenv("OES_PG_A4_ENABLED") != "1":
    sys.exit("NOT_RUN: opt-in PG-A4 connection is disabled")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

import django

django.setup()

from django.db import connections
from evidence.synthetic_pg_reader import ALIAS, list_synthetic_study_report_links

with connections[ALIAS].cursor() as cursor:
    cursor.execute("SELECT current_user, session_user, current_database(), current_setting('transaction_read_only')")
    user, session_user, database, read_only = cursor.fetchone()
    if (user, session_user, database, read_only) != (
        "oes_pg_a4_reader", "oes_pg_a4_reader", "oes_sandbox", "on"
    ):
        sys.exit("FAIL: unexpected identity, database, or write-mode")
records = list_synthetic_study_report_links()
if records:
    sys.exit("FAIL: synthetic PG-A4-G2-A expected zero links")
print("PASS PG_A4_G2_A_DJANGO_CONNECTED_READ_ONLY_EMPTY")
