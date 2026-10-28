"""B2-M1 read-only structural inventory; excludes auth schema and table data."""
import hashlib
import json
from pathlib import Path
from django.db import connections

SQL = """
SELECT n.nspname, c.relname, c.relkind, pg_get_userbyid(c.relowner),
       a.attnum, a.attname, a.atttypid::text, a.atttypmod,
       a.attnotnull, c.relpersistence
FROM pg_catalog.pg_class AS c
JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
LEFT JOIN pg_catalog.pg_attribute AS a
  ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
WHERE n.nspname IN ('core', 'investigation', 'evidence',
                    'oes_app', 'provenance')
ORDER BY n.nspname, c.relname, c.relkind, a.attnum
"""

def snapshot(connection=None):
    conn = connection if connection is not None else connections["default"]
    with conn.cursor() as cursor:
        cursor.execute(SQL)
        records = cursor.fetchall()
    payload = json.dumps(records, ensure_ascii=True, default=str, separators=(",", ":"))
    return {"count": len(records), "sha256": hashlib.sha256(payload.encode()).hexdigest()}

def write_baseline(path):
    observed = snapshot()
    Path(path).write_text(json.dumps(observed), encoding="utf-8")
    print("B2_M1_SCIENTIFIC_BASELINE", observed, flush=True)

def compare_baseline(path):
    observed = snapshot()
    baseline_file = Path(path)
    if not baseline_file.is_file():
        raise RuntimeError("HOLD: scientific baseline missing; cannot certify unchanged")
    expected = json.loads(baseline_file.read_text(encoding="utf-8"))
    print("B2_M1_SCIENTIFIC_POSTFLIGHT", observed, flush=True)
    if observed != expected:
        raise RuntimeError("HOLD: scientific structural inventory changed")
    print("B2_M1_SCIENTIFIC_STRUCTURE_UNCHANGED", flush=True)
