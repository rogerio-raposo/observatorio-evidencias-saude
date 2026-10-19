#!/usr/bin/env python3
"""Offline fail-closed lint for an UNREVIEWED OES postcondition catalog draft.

Checks documentary consistency ONLY. Not a migration runner, and never accesses SQL
servers, Neon, credentials, or external services.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

MANIFEST = "database/f4-neon-sandbox-schema-migration-manifest.txt"
CATALOG = "database/f4-reconciliation-postconditions-draft.json"
SAFE_PATH = re.compile(r"^database/[A-Za-z0-9_.-]+\.sql$")
EXPECTED_BOUNDARIES = {
    31: "INTERNAL_BEGIN_COMMIT_OBSERVED",
    32: "INTERNAL_BEGIN_COMMIT_OBSERVED",
    33: "INTERNAL_BEGIN_COMMIT_OBSERVED",
    34: "NO_WRAPPER_BEGIN_COMMIT_OBSERVED",
    35: "NO_WRAPPER_BEGIN_COMMIT_OBSERVED",
    36: "NO_WRAPPER_BEGIN_COMMIT_OBSERVED",
}


class CatalogBlocked(ValueError):
    pass


def verify(manifest_bytes: bytes, catalog_bytes: bytes) -> dict:
    try:
        manifest_text = manifest_bytes.decode("utf-8")
        catalog = json.loads(catalog_bytes.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CatalogBlocked("invalid UTF8 or JSON") from exc
    if not isinstance(catalog, dict):
        raise CatalogBlocked("catalog root must be an object")
    expected = [line.strip() for line in manifest_text.splitlines()
                if line.strip() and not line.lstrip().startswith("#")]
    if len(expected) != 36 or len(set(expected)) != 36:
        raise CatalogBlocked("manifest must contain 36 unique entries")
    if not all(SAFE_PATH.fullmatch(s) for s in expected):
        raise CatalogBlocked("manifest contains unsafe file paths")
    required = {
        "schema_version": "oes.f4.reconciliation-catalog.draft.v1",
        "status": "DRAFT_ALL_ENTRIES_UNREVIEWED",
        "governance_only": True,
        "synthetic_only": True,
        "canonical_manifest": MANIFEST,
    }
    for key, value in required.items():
        if catalog.get(key) != value or type(catalog.get(key)) is not type(value):
            raise CatalogBlocked(f"catalog {key} differs from draft contract")
    origin = catalog.get("source_head_when_created")
    if not isinstance(origin, str) or not re.fullmatch(r"[0-9a-f]{40}", origin):
        raise CatalogBlocked("source HEAD must be an informational SHA-1")
    rows = catalog.get("entries")
    if not isinstance(rows, list) or len(rows) != 36:
        raise CatalogBlocked("catalog must contain exactly 36 entries")
    for index, (row, path) in enumerate(zip(rows, expected), 1):
        if not isinstance(row, dict):
            raise CatalogBlocked("entry must be an object")
        if type(row.get("ordinal")) is not int or row["ordinal"] != index:
            raise CatalogBlocked(f"ordinal mismatch at {index}")
        if row.get("entrypoint") != path:
            raise CatalogBlocked(f"migration identity/order mismatch at {index}")
        if row.get("transaction_boundary") != EXPECTED_BOUNDARIES.get(index, "UNREVIEWED"):
            raise CatalogBlocked(f"unreviewed transaction classification mismatch at {index}")
        if row.get("review_state") != "UNREVIEWED":
            raise CatalogBlocked(f"review promotion requires separate governance at {index}")
        if row.get("postconditions") != [] or row.get("review_evidence") != []:
            raise CatalogBlocked(f"unverified postconditions are forbidden in draft at {index}")
        for flag in ("automated_reconciliation_allowed", "automatic_replay_allowed",
                     "migration_execution_allowed"):
            if row.get(flag) is not False:
                raise CatalogBlocked(f"dangerous draft activation flag {flag} at {index}")
    return {
        "status": "DRAFT_STATIC_CONSISTENCY_ONLY",
        "migration_entries": len(rows),
        "reviewed_entries": 0,
        "postconditions_validated": 0,
        "sql_executed": False,
        "neon_accessed": False,
        "neon_write_authorized": False,
        "manifest_sha256": hashlib.sha256(manifest_bytes).hexdigest(),
        "catalog_sha256": hashlib.sha256(catalog_bytes).hexdigest(),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default=MANIFEST)
    parser.add_argument("--catalog", default=CATALOG)
    args = parser.parse_args()
    try:
        result = verify(Path(args.manifest).read_bytes(), Path(args.catalog).read_bytes())
    except (OSError, CatalogBlocked) as exc:
        print(f"BLOCKED: {exc}", file=sys.stderr)
        return 2
    print(json.dumps(result, sort_keys=True, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
