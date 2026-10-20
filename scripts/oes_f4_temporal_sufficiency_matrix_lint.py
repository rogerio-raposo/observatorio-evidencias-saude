#!/usr/bin/env python3
"""Read-only, fail-closed sanity checks for an UNSATISFIED OES evidence matrix.

This utility is not a SQL parser, runtime reconciler or deployment approval.
No DB connection; accepted output ALWAYS means 'draft documentation only'.
"""
import hashlib
import json
from pathlib import Path
import sys

MATRIX_PATH = "docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json"
MANIFEST_PATH = "database/f4-neon-sandbox-schema-migration-manifest.txt"
CATALOG_PATH = "database/f4-reconciliation-postconditions-draft.json"

GLOBAL_IDS = {
    "source_identity", "transaction_record", "catalog_dependency",
    "historical_integrity", "privilege_separation", "ddl_audit",
    "restore_provenance", "independent_review",
}
LOCAL_IDS = {
    34: {"activation_function", "activation_trigger", "epoch_history", "interrupted_replay"},
    35: {"preflight_functions", "readonly_semantics", "mixed_function_versions", "dependent_status"},
    36: {"novelty_function", "first_event_trigger", "event_history", "interrupted_replay"},
}
KINDS = {"file", "ledger", "catalog", "data", "security", "audit", "recovery",
         "governance", "function", "trigger", "fault", "behavior"}

class Blocked(ValueError):
    pass

def must(cond, message):
    if not cond:
        raise Blocked(message)

def check(matrix, manifest, catalog):
    must(isinstance(matrix, dict) and isinstance(catalog, dict), "roots must be objects")
    lines = [s.strip() for s in manifest.decode("utf8").splitlines()
             if s.strip() and not s.lstrip().startswith("#")]
    must(len(lines) == 36 and len(set(lines)) == 36, "manifest must have 36 unique migrations")
    primary = catalog.get("entries")
    must(isinstance(primary, list) and len(primary) == 36, "primary catalog shape drift")
    for pos, row in enumerate(primary):
        must(isinstance(row, dict) and row.get("entrypoint") == lines[pos]
             and row.get("review_state") == "UNREVIEWED"
             and row.get("postconditions") == []
             and all(row.get(k) is False for k in
                     ("automated_reconciliation_allowed",
                      "automatic_replay_allowed", "migration_execution_allowed")),
             "primary catalog no longer all blocked")

    exact = {
        "schema_version": "oes.f4.temporal-evidence-sufficiency.draft.v1",
        "status": "DRAFT_ONLY_ALL_GATES_BLOCKED",
        "source_checkpoint": "CP173",
        "canonical_manifest": MANIFEST_PATH,
        "canonical_postcondition_catalog": CATALOG_PATH,
        "governance_only": True,
        "neon_accessed": False,
        "neon_write_authorized": False,
        "reviewed_migrations": 0,
        "approved_postconditions": 0,
        "automatic_reconciliation_allowed": False,
        "automatic_replay_allowed": False,
        "operational_runner_authorized": False,
    }
    for key, expected in exact.items():
        got = matrix.get(key)
        must(got == expected and type(got) is type(expected), f"root flag mismatch {key}")
    policy = matrix.get("evaluation_policy")
    must(isinstance(policy, dict), "evaluation policy absent")
    for key, expected in {
        "decision":"BLOCKED_REQUIRES_HUMAN_REVIEW",
        "insufficient_or_missing_evidence":"uncertain_requires_reconciliation",
        "unresolved_drift":"partial_or_drift_requires_manual_decision",
        "unknown_commit":"never_infer_applied_never_auto_retry",
        "trigger_reenabled":"never_treat_as_retroactive_validation",
        "privileged_ddl_without_audit":"BLOCKED",
        "human_review_required":True,
        "backup_restore_required":True,
    }.items():
        must(policy.get(key) == expected and type(policy.get(key)) is type(expected),
             f"policy drift {key}")

    rows = matrix.get("migrations")
    must(isinstance(rows,list) and len(rows) == 3, "expected exactly 3 rows")
    for idx,row in enumerate(rows):
        ordinal = idx+34
        must(isinstance(row,dict) and type(row.get("ordinal")) is int
             and row["ordinal"] == ordinal, "migration ordinal mismatch")
        must(row.get("entrypoint") == lines[ordinal-1], "manifest identity drift")
        must(row.get("review_status") == "UNREVIEWED", "false review approval")
        for flag in ("fully_applied_verified", "automatic_reconciliation_allowed",
                     "automatic_replay_allowed"):
            must(row.get(flag) is False, "unsafe activation "+flag)
        evidence = row.get("required_evidence")
        must(isinstance(evidence,list) and len(evidence)==12, "required evidence count drift")
        expected_ids = GLOBAL_IDS | LOCAL_IDS[ordinal]
        ids = [e.get("id") if isinstance(e,dict) else None for e in evidence]
        must(set(ids) == expected_ids and len(ids)==len(set(ids)), "missing, duplicate or unknown control")
        for entry in evidence:
            must(entry.get("kind") in KINDS, "invalid control kind")
            must(isinstance(entry.get("need"), str)
                 and len(entry["need"]) >= 45, "underspecified control")
            must(entry.get("verification") == "NOT_COLLECTED", "claimed unreviewed verification")
            for key in ("independent_reviewer", "evidence_artifact", "reviewed_sha256"):
                must(key in entry and entry[key] is None, "unapproved evidence supplied")
    return {
       "status":"STATIC_DRAFT_MATRIX_BLOCKED_ONLY",
       "migrations":3,
       "requirements":sum(len(row["required_evidence"]) for row in rows),
       "operational_postconditions_validated":0,
       "independent_reviews_performed":0,
       "sql_executed":False,
       "neon_accessed":False,
       "neon_write_authorized":False,
       "matrix_sha256":hashlib.sha256(json.dumps(matrix,sort_keys=True).encode()).hexdigest(),
       "manifest_sha256":hashlib.sha256(manifest).hexdigest(),
    }

def main():
    try:
        matrix=json.loads(Path(MATRIX_PATH).read_text(encoding="utf8"))
        manifest=Path(MANIFEST_PATH).read_bytes()
        catalog=json.loads(Path(CATALOG_PATH).read_text(encoding="utf8"))
        print(json.dumps(check(matrix,manifest,catalog),indent=2,sort_keys=True))
    except (Blocked,OSError,ValueError,UnicodeError) as exc:
        print(f"BLOCKED: {exc}",file=sys.stderr)
        return 2
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
