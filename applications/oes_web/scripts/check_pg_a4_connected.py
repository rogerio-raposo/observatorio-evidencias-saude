"""Explicit PG-A4-G2-A Django connection smoke test; synthetic branch only.

Run from applications/oes_web after setting OES_PG_A4_ENABLED=1,
OES_PG_A4_HOST, OES_PG_A4_PASSWORD in a private environment.
Never copy environment credentials into workflow, shell history or logs.
"""
import os
import sys
from pathlib import Path

# Executed as scripts/check_pg_a4_connected.py: add Django project root.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

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
mode = os.getenv("OES_PG_A4_EXPECTED_MODE", "empty")
if mode == "empty":
    if records:
        sys.exit("FAIL: synthetic PG-A4-G2-A expected zero links")
    print("PASS PG_A4_G2_A_DJANGO_CONNECTED_READ_ONLY_EMPTY")
elif mode == "relational":
    # Exact artificial identifiers from database/fixtures/pg_a4_g2b_synthetic.sql.
    from uuid import UUID

    study_1 = UUID("a4000000-0000-4000-8000-000000000001")
    study_2 = UUID("a4000000-0000-4000-8000-000000000002")
    report_1 = UUID("a4000000-0000-4000-8000-000000000003")
    report_2 = UUID("a4000000-0000-4000-8000-000000000004")
    provenance_1 = UUID("a4300000-0000-4000-8000-000000000001")
    expected_pairs = {
        (study_1, report_1),
        (study_1, report_2),
        (study_2, report_1),
    }
    actual_pairs = {(row.study_entity_uuid, row.report_entity_uuid) for row in records}
    if len(records) != 3 or actual_pairs != expected_pairs:
        sys.exit("FAIL: expected exactly three distinct synthetic Study-Report links")
    expected_versions = {
        study_1: UUID("a4100000-0000-4000-8000-000000000001"),
        study_2: UUID("a4100000-0000-4000-8000-000000000002"),
        report_1: UUID("a4100000-0000-4000-8000-000000000003"),
        report_2: UUID("a4100000-0000-4000-8000-000000000004"),
    }
    for row in records:
        if (row.study_version_uuid != expected_versions[row.study_entity_uuid]
                or row.report_version_uuid != expected_versions[row.report_entity_uuid]
                or row.relation_type != "synthetic_report"
                or row.evidence_boundary != "SYNTHETIC_TECHNICAL_ONLY"):
            sys.exit("FAIL: unexpected synthetic version, relation type, or boundary")
        expected_provenance = (row.study_entity_uuid == study_1)
        if expected_provenance != (row.provenance_uuid == provenance_1):
            sys.exit("FAIL: unexpected Study-version provenance association")
        if expected_provenance and row.provenance_field_path != "title_or_label":
            sys.exit("FAIL: unexpected synthetic provenance field_path")
        if not expected_provenance and row.provenance_field_path is not None:
            sys.exit("FAIL: unexpected provenance for Study 2")
    print("PASS PG_A4_G2_B_DJANGO_CONNECTED_THREE_LINKS_ONE_PROVENANCE")
else:
    sys.exit("NOT_RUN: unknown PG-A4 expected mode")
