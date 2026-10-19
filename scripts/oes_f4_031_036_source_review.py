#!/usr/bin/env python3
"""Source-only review of candidate postconditions 031-036. No SQL execution.

This is NOT a SQL parser, migration runner, or validated reconciliation catalog.
"""
import hashlib
import json
from pathlib import Path
import re
import sys

from oes_f4_reconciliation_catalog_lint import verify as verify_primary_catalog

CANDIDATES = "docs/governance/reconciliation/f4-031-036-source-candidates.json"
PRIMARY = "database/f4-reconciliation-postconditions-draft.json"
MANIFEST = "database/f4-neon-sandbox-schema-migration-manifest.txt"
STRICT_SCRIPT = re.compile(r"^database/(?:03[1-6]_[a-z0-9_]+)\.sql$")
INCLUDE = re.compile(r"^\s*\\ir\s+([A-Za-z0-9_]+\.sql)\s*$", re.M)
CONTROL = re.compile(r"^\s*(BEGIN|COMMIT)\s*;\s*$", re.M | re.I)
MARKER_PFX = r"^\s*"


class Blocked(ValueError):
    pass


def verify(candidates: dict, manifest: bytes, primary: bytes, load):
    base = verify_primary_catalog(manifest, primary)
    if base["reviewed_entries"] != 0 or base["postconditions_validated"] != 0:
        raise Blocked("canonical catalog has been promoted")
    if not isinstance(candidates, dict):
        raise Blocked("candidate catalog must be object")
    required = {
        "schema_version": "oes.f4.031-036-source-candidates.v1",
        "status": "SOURCE_REVIEW_CANDIDATES_UNVALIDATED",
        "executable": False, "review_approved": False,
        "automatic_replay_allowed": False,
        "automated_reconciliation_allowed": False,
        "neon_write_authorized": False,
        "primary_catalog": PRIMARY,
    }
    for key, v in required.items():
        if candidates.get(key) != v or type(candidates.get(key)) is not type(v):
            raise Blocked(f"candidate field not fail-closed: {key}")
    rows = candidates.get("candidates")
    if not isinstance(rows, list) or len(rows) != 6:
        raise Blocked("expected exactly 6 candidate records")
    primary_rows = json.loads(primary)["entries"][30:]
    if len(primary_rows) != 6:
        raise Blocked("canonical tail missing")

    paths = []
    inventory = []
    for index, row in enumerate(rows):
        ordinal = index + 31
        if not isinstance(row, dict) or type(row.get("ordinal")) is not int or row["ordinal"] != ordinal:
            raise Blocked("candidate ordinal drift")
        entry = row.get("entrypoint")
        if (not isinstance(entry, str) or not STRICT_SCRIPT.fullmatch(entry)
                or entry != primary_rows[index]["entrypoint"]):
            raise Blocked(f"candidate path drift at {ordinal}")
        include_expected = row.get("includes")
        if (not isinstance(include_expected, list)
                or not all(isinstance(s, str) and re.fullmatch(r"03[1-3][a-z]_[a-z0-9_]+\.sql", s) for s in include_expected)
                or len(set(include_expected)) != len(include_expected)):
            raise Blocked("invalid fragment list")
        raw = load(entry)
        try:
            source = raw.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise Blocked("non-UTF8 SQL") from exc
        includes = INCLUDE.findall(source)
        if includes != include_expected:
            raise Blocked(f"fragment order mismatch in {entry}")
        if re.search(r"^\s*\\i(?:\s|r\s)", source, re.M) and len(includes) != len(re.findall(r"^\s*\\i", source, re.M)):
            raise Blocked("unlisted SQL include detected")
        bounds = [b.upper() for b in CONTROL.findall(source)]
        want_internal = ordinal <= 33
        if want_internal and bounds != ["BEGIN", "COMMIT"]:
            raise Blocked(f"wrapper transaction boundary mismatch {ordinal}")
        if not want_internal and bounds:
            raise Blocked(f"unexpected wrapper transaction {ordinal}")
        if row.get("boundary") != ("INTERNAL_BEGIN_COMMIT_OBSERVED" if want_internal else "NO_WRAPPER_BEGIN_COMMIT_OBSERVED"):
            raise Blocked("candidate boundary mismatch")
        if row.get("review_candidates") is None or row.get("limitations") is None:
            raise Blocked("empty documentary assessment")
        if not isinstance(row["review_candidates"], list) or not row["review_candidates"] or not row["limitations"]:
            raise Blocked("empty candidate checks/limitations")
        if not all(isinstance(v, str) and v.strip() for v in row["review_candidates"] + row["limitations"]):
            raise Blocked("blank review item")
        combined = source
        srcs = [(entry, raw)]
        for frag in includes:
            path = "database/" + frag
            if path in paths:
                raise Blocked("duplicate SQL fragment")
            fragbytes = load(path)
            fragtext = fragbytes.decode("utf-8")
            if INCLUDE.search(fragtext) or re.search(r"^\s*\\i\s+", fragtext, re.M):
                raise Blocked(f"nested include forbidden: {path}")
            if CONTROL.search(fragtext):
                raise Blocked(f"unexpected internal transaction fragment: {path}")
            combined += "\n" + fragtext
            srcs.append((path, fragbytes))
        markers = row.get("source_markers")
        if not isinstance(markers, list) or len(markers) < 2 or len(markers) != len(set(markers)):
            raise Blocked(f"invalid source markers {ordinal}")
        for marker in markers:
            if not isinstance(marker, str) or not re.fullmatch(r"[A-Za-z0-9_. (),]+", marker):
                raise Blocked("unsafe/invalid marker")
            if not re.search(MARKER_PFX + re.escape(marker), combined, re.M):
                raise Blocked(f"source marker absent for {ordinal}: {marker}")
        paths.extend(p for p, b in srcs)
        inventory.append({
            "ordinal": ordinal,
            "entrypoint": entry,
            "boundary": row["boundary"],
            "fragment_count": len(includes),
            "marker_count": len(markers),
            "source_files": [{"path": p, "sha256": hashlib.sha256(b).hexdigest()} for p, b in srcs],
            "review_state": "UNREVIEWED",
            "validated_postconditions": 0,
            "automated_reconciliation_allowed": False,
        })
    if len(paths) != 20:
        raise Blocked("expected exactly 6 wrappers and 14 fragments")
    return {
        "status": "SOURCE_MARKERS_PRESENT_POSTCONDITIONS_UNVALIDATED",
        "source_files_checked": len(paths),
        "migrations_scanned": 6,
        "fragments_scanned": 14,
        "reviewed_migrations": 0,
        "postconditions_validated": 0,
        "sql_executed": False,
        "neon_accessed": False,
        "neon_write_authorized": False,
        "candidate_catalog_sha256": hashlib.sha256(json.dumps(candidates, sort_keys=True).encode()).hexdigest(),
        "inventory": inventory,
    }


def main() -> int:
    try:
        manifest = Path(MANIFEST).read_bytes()
        primary = Path(PRIMARY).read_bytes()
        catalog = json.loads(Path(CANDIDATES).read_text(encoding="utf8"))
        report = verify(catalog, manifest, primary, lambda p: Path(p).read_bytes())
        print(json.dumps(report, sort_keys=True, indent=2))
        return 0
    except (Blocked, OSError, ValueError) as exc:
        print(f"BLOCKED: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
