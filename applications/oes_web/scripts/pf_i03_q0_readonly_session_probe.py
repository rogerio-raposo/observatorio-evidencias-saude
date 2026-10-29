"""One Django PostgreSQL session. SELECT-only; never import the Q0 writer."""
import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings_pf_i03_q0_readonly_trial")

import django
django.setup()

from django.conf import settings
from django.db import connections
from config.pf_i03_q0_session_contract import TABLES, verify_observed_readonly_session

alias = settings.PF_I03_SCIENTIFIC_ALIAS
connection = connections[alias]
try:
    if connection.vendor != "postgresql":
        raise RuntimeError("HOLD: unexpected backend")
    with connection.cursor() as cursor:
        cursor.execute(
            "SELECT current_database(), session_user, current_user, "
            "current_setting('search_path'), current_setting('transaction_read_only')"
        )
        database, session_user, current_user, search_path, readonly = cursor.fetchone()
        cursor.execute(
            "SELECT n.nspname || '.' || c.relname, "
            "has_schema_privilege(current_user,n.oid,'USAGE') "
            "AND has_table_privilege(current_user,c.oid,'SELECT') "
            "FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace "
            "WHERE n.nspname IN ('core','investigation') AND c.relkind IN ('r','p')"
        )
        inventory = dict(cursor.fetchall())
    observed = dict(alias=alias, vendor=connection.vendor, database=database,
                    session_user=session_user, current_user=current_user,
                    search_path=search_path, transaction_read_only=readonly)
    result = verify_observed_readonly_session(
        observed, {name: inventory.get(name, False) for name in TABLES}
    )
    print(result)  # No secrets or row-level data.
finally:
    connection.close()
