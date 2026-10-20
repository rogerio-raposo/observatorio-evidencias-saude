#!/usr/bin/env python3
"""CP178: disposable PostgreSQL 18 role-path and audit-completeness adversarial test.

Strictly allowlisted GitHub Actions PostgreSQL service. No Neon, no external
service, no operational role, no real credentials. All receipts and anchor
remain in the SAME runner, outside PostgreSQL transactions only.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

DB = "oes_f4_cp178_synthetic"
OUT = Path("f4-pg18-cp178-evidence")
OWNER = "oes_ci178_guard_owner"
TABLE = "maintenance.temporal_observation_epoch"
TRIGGER = "tr_temporal_epoch_activation_chronology"
MANIFEST = "database/f4-neon-sandbox-schema-migration-manifest.txt"
PSQL = ["psql", "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1",
        "-h", "127.0.0.1", "-p", "5432", "-d", DB]
LOGINS = {
    "postgres": "synthetic_ci_only",
    "oes_ci178_via_set": "synthetic_via_set_only",
    "oes_ci178_set_blocked": "synthetic_set_blocked_only",
    "oes_ci178_via_inherit": "synthetic_inherit_only",
    OWNER: "synthetic_owner_nologin",
}
receipts = []

def check(label, predicate):
    if not predicate:
        print(label + "\tFAIL", flush=True)
        with (OUT / "checks.tsv").open("a", encoding="utf8") as f:
            f.write(label + "\tFAIL\n")
        raise AssertionError("CHECK_FAILED: " + label)
    print(label + "\tPASS", flush=True)
    with (OUT / "checks.tsv").open("a", encoding="utf8") as f:
        f.write(label + "\tPASS\n")

def invoke(username, sql=None, file=None):
    if username not in LOGINS or (sql is None) == (file is None):
        raise AssertionError("invalid local SQL input")
    env = os.environ.copy()
    for forbidden in ("DATABASE_URL", "PGSERVICE", "PGSERVICEFILE"):
        env.pop(forbidden, None)
    env["PGPASSWORD"] = LOGINS[username]
    args = PSQL + ["-U", username]
    args += ["-c", sql] if sql is not None else ["-f", file]
    return subprocess.run(args, env=env, capture_output=True, text=True, timeout=90)

def exec_sql(username, sql):
    p = invoke(username, sql=sql)
    if p.returncode:
        raise AssertionError("SQL expected success: " + p.stderr[-600:])
    return p.stdout.strip()

def admin_sql(sql):
    return exec_sql("postgres", sql)

def denied(label, username, sql):
    p = invoke(username, sql=sql)
    check(label, p.returncode != 0 and bool(p.stderr.strip()))
    return p

def guard():
    return admin_sql("SELECT tgenabled FROM pg_trigger WHERE "
                     "tgrelid='" + TABLE + "'::regclass AND tgname='" + TRIGGER + "';")

def digest(x):
    encoded = json.dumps(x, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
    return hashlib.sha256(encoded.encode("utf8")).hexdigest()

def append(action, phase, who, operation, outcome):
    prev = receipts[-1]["hash"] if receipts else "0" * 64
    row = dict(seq=len(receipts)+1, prev_hash=prev, action_id=action,
               phase=phase, actor=who, operation=operation, outcome=outcome,
               commit=os.environ["GITHUB_SHA"])
    row["hash"] = digest(row)
    receipts.append(row)
    with (OUT / "receipt-runner-only.jsonl").open("a", encoding="utf8") as fp:
        fp.write(json.dumps(row, sort_keys=True) + "\n")

def anchor_for(events):
    return dict(count=len(events), final_hash=events[-1]["hash"] if events else "0"*64,
                scope="SAME_RUNNER_NOT_INDEPENDENT_NOT_IMMUTABLE")

def verify(events, anchor):
    if len(events) != anchor["count"]:
        raise ValueError("missing event or invalid count")
    previous = "0" * 64
    pending = set()
    for expected, event in enumerate(events, 1):
        if event.get("seq") != expected or event.get("prev_hash") != previous:
            raise ValueError("gap or order")
        if event.get("hash") != digest({k:v for k,v in event.items() if k != "hash"}):
            raise ValueError("invalid hash")
        key = event.get("action_id")
        if event.get("phase") == "attempt":
            if key in pending:
                raise ValueError("duplicate attempt")
            pending.add(key)
        elif event.get("phase") == "result":
            if key not in pending:
                raise ValueError("orphan result")
            pending.remove(key)
        else:
            raise ValueError("unrecognized phase")
        previous = event["hash"]
    if pending:
        raise ValueError("attempt with no result")
    if previous != anchor["final_hash"]:
        raise ValueError("anchor hash mismatch")
    return True

def must_reject(events, anchor):
    try:
        verify(events, anchor)
        return False
    except ValueError:
        return True

def recorded(action, username, operation, sql):
    append(action, "attempt", username, operation, "PENDING")
    p = invoke(username, sql=sql)
    append(action, "result", username, operation,
           "CONFIRMED" if p.returncode == 0 else "DENIED_OR_FAILED")
    return p

def role_property(actor, property):
    return admin_sql("SELECT pg_has_role('" + actor + "', '" + OWNER + "', '" +
                     property + "')::text;") == "true"

def main():
    required = {
        "GITHUB_ACTIONS": "true",
        "GITHUB_REPOSITORY": "rogerio-raposo/observatorio-evidencias-saude",
        "PGHOST": "127.0.0.1", "PGPORT": "5432",
        "PGUSER": "postgres", "PGDATABASE": DB,
    }
    if any(os.getenv(k) != v for k, v in required.items()) or any(
            os.getenv(k) for k in ("DATABASE_URL", "PGSERVICE", "PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: only ephemeral allowlisted PG18 GitHub Actions")
    sha = os.environ.get("GITHUB_SHA", "")
    if re.fullmatch("[0-9a-f]{40}", sha) is None:
        raise RuntimeError("BLOCKED: missing fixed GitHub commit")
    OUT.mkdir(exist_ok=True)
    (OUT / "checks.tsv").write_text("check\tresult\n", encoding="utf8")
    (OUT / "commit.txt").write_text(sha + "\n")
    check("pg18_service", admin_sql("SHOW server_version_num;").startswith("18"))
    check("github_commit_pinned", True)
    names = [line.strip() for line in Path(MANIFEST).read_text().splitlines()
             if line.strip() and not line.lstrip().startswith("#")]
    check("manifest_36_unique", len(names) == 36 and len(set(names)) == 36)
    for path in names:
        p = invoke("postgres", file=path)
        if p.returncode:
            raise AssertionError("baseline migration failed: " + path + ": " + p.stderr[-600:])
    check("pg18_ephemeral_migrations_001_to_036", True)
    check("guard_034_initially_enabled", guard() == "O")

    admin_sql("""
    CREATE ROLE oes_ci178_guard_owner NOLOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB;
    CREATE ROLE oes_ci178_mid_set NOLOGIN NOSUPERUSER NOCREATEROLE;
    CREATE ROLE oes_ci178_mid_block NOLOGIN NOSUPERUSER NOCREATEROLE;
    CREATE ROLE oes_ci178_mid_inherit NOLOGIN NOSUPERUSER NOCREATEROLE;
    CREATE ROLE oes_ci178_grant_target NOLOGIN NOSUPERUSER NOCREATEROLE;
    CREATE ROLE oes_ci178_via_set LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB
       PASSWORD 'synthetic_via_set_only';
    CREATE ROLE oes_ci178_set_blocked LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB
       PASSWORD 'synthetic_set_blocked_only';
    CREATE ROLE oes_ci178_via_inherit LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB
       PASSWORD 'synthetic_inherit_only';
    GRANT USAGE ON SCHEMA maintenance TO
       oes_ci178_guard_owner, oes_ci178_mid_set, oes_ci178_mid_block,
       oes_ci178_mid_inherit, oes_ci178_via_set, oes_ci178_set_blocked,
       oes_ci178_via_inherit;
    GRANT oes_ci178_guard_owner TO oes_ci178_mid_set
       WITH ADMIN FALSE, INHERIT FALSE, SET TRUE;
    GRANT oes_ci178_mid_set TO oes_ci178_via_set
       WITH ADMIN FALSE, INHERIT FALSE, SET TRUE;
    GRANT oes_ci178_guard_owner TO oes_ci178_mid_block
       WITH ADMIN FALSE, INHERIT FALSE, SET FALSE;
    GRANT oes_ci178_mid_block TO oes_ci178_set_blocked
       WITH ADMIN FALSE, INHERIT FALSE, SET TRUE;
    GRANT oes_ci178_guard_owner TO oes_ci178_mid_inherit
       WITH ADMIN FALSE, INHERIT TRUE, SET FALSE;
    GRANT oes_ci178_mid_inherit TO oes_ci178_via_inherit
       WITH ADMIN FALSE, INHERIT TRUE, SET FALSE;
    ALTER TABLE maintenance.temporal_observation_epoch OWNER TO oes_ci178_guard_owner;
    """)
    check("owner_is_nologin", admin_sql(
        "SELECT rolcanlogin::text FROM pg_roles WHERE rolname='" + OWNER + "';") == "false")
    denied("owner_direct_authentication_denied", OWNER, "SELECT current_user;")
    check("three_distinct_logins", all(
        exec_sql(user, "SELECT session_user || ':' || current_user;") == user + ":" + user
        for user in ("oes_ci178_via_set", "oes_ci178_set_blocked", "oes_ci178_via_inherit")))
    # Assert the explicit PostgreSQL 18 membership options are actually installed.
    membership = admin_sql("""
    SELECT member.rolname || '->' || parent.rolname || ':' ||
           m.admin_option::text || ',' || m.inherit_option::text || ',' ||
           m.set_option::text
      FROM pg_auth_members m
      JOIN pg_roles member ON member.oid=m.member
      JOIN pg_roles parent ON parent.oid=m.roleid
     WHERE member.rolname LIKE 'oes_ci178_%'
       AND parent.rolname LIKE 'oes_ci178_%'
     ORDER BY member.rolname, parent.rolname;
    """).splitlines()
    (OUT / "membership-options.txt").write_text("\n".join(membership) + "\n")
    check("six_membership_edges_documented", len(membership) == 6)
    check("all_six_memberships_admin_false",
          all(line.split(":")[1].split(",")[0] == "false" for line in membership))
    check("transitive_set_path_available", role_property("oes_ci178_via_set", "SET"))
    check("transitive_set_path_not_inherited", not role_property("oes_ci178_via_set", "USAGE"))
    check("set_false_edge_blocks_path", not role_property("oes_ci178_set_blocked", "SET"))
    check("inherit_false_blocks_blocked_path",
          not role_property("oes_ci178_set_blocked", "USAGE"))
    check("inherit_true_transitive_path_available",
          role_property("oes_ci178_via_inherit", "USAGE"))
    check("inherit_path_cannot_set", not role_property("oes_ci178_via_inherit", "SET"))

    denied("admin_false_direct_grant_owner_denied", "oes_ci178_via_set",
           "GRANT " + OWNER + " TO oes_ci178_grant_target;")
    denied("admin_false_direct_grant_mid_denied", "oes_ci178_via_set",
           "GRANT oes_ci178_mid_set TO oes_ci178_grant_target;")
    denied("admin_false_transitive_grant_denied", "oes_ci178_set_blocked",
           "GRANT " + OWNER + " TO oes_ci178_grant_target;")
    check("failed_grants_have_no_target_membership", admin_sql(
        "SELECT count(*) FROM pg_auth_members WHERE member="
        "'oes_ci178_grant_target'::regrole;") == "0")
    denied("blocked_actor_cannot_set_owner", "oes_ci178_set_blocked",
           "SET ROLE " + OWNER + ";")
    denied("blocked_actor_cannot_disable_guard", "oes_ci178_set_blocked",
           "ALTER TABLE " + TABLE + " DISABLE TRIGGER " + TRIGGER + ";")
    denied("set_actor_ddl_before_set_denied", "oes_ci178_via_set",
           "ALTER TABLE " + TABLE + " DISABLE TRIGGER " + TRIGGER + ";")

    # Exercise the two independent indirect owner-authority paths on the actual
    # 034 guard. SQL is rolled back; these are disposable CI-only roles.
    set_sql = ("SET ROLE " + OWNER + "; BEGIN; ALTER TABLE " + TABLE +
               " DISABLE TRIGGER " + TRIGGER + "; ROLLBACK;")
    check("transitive_set_role_can_disable_guard_in_transaction",
          invoke("oes_ci178_via_set", sql=set_sql).returncode == 0)
    check("guard_preserved_after_set_path_rollback", guard() == "O")
    inherit_sql = ("BEGIN; ALTER TABLE " + TABLE + " DISABLE TRIGGER " +
                   TRIGGER + "; ROLLBACK;")
    inherit_result = invoke("oes_ci178_via_inherit", sql=inherit_sql)
    check("transitive_inherit_allows_owner_ddl_without_set",
          inherit_result.returncode == 0)
    check("guard_preserved_after_inherit_path_rollback", guard() == "O")

    # ADMIN FALSE is not a substitute for suppressing access to the owner role.
    # Whether self-GRANT after SET ROLE succeeds is recorded observationally;
    # no authorization to Neon or any external system is implied.
    self_grant = invoke("oes_ci178_via_set", sql=(
        "SET ROLE " + OWNER + "; GRANT " + OWNER + " TO oes_ci178_grant_target;"))
    self_grant_succeeded = self_grant.returncode == 0
    target_count = int(admin_sql(
        "SELECT count(*) FROM pg_auth_members WHERE member="
        "'oes_ci178_grant_target'::regrole AND roleid='" + OWNER + "'::regrole;"))
    check("self_grant_result_matches_catalog", (target_count == 1) == self_grant_succeeded)
    if target_count:
        admin_sql("REVOKE " + OWNER + " FROM oes_ci178_grant_target;")
    check("role_delegation_test_target_clean", admin_sql(
        "SELECT count(*) FROM pg_auth_members WHERE member="
        "'oes_ci178_grant_target'::regrole;") == "0")

    # Wrapper-managed receipts: outside transaction, but inside SAME runner.
    p = recorded("A1", "oes_ci178_via_set", "ROLLBACK_GUARD", set_sql)
    check("wrapped_valid_ddl_and_rollback", p.returncode == 0 and guard() == "O")
    p = recorded("A2", "oes_ci178_set_blocked", "DENIED_SET_ROLE",
                 "SET ROLE " + OWNER + ";")
    check("wrapped_denied_sql", p.returncode != 0)
    good_anchor = anchor_for(receipts)
    (OUT / "audit-anchor.json").write_text(json.dumps(good_anchor, indent=2) + "\n")
    check("intact_chain_verifies", verify(receipts, good_anchor))
    check("runner_receipts_are_four_events", len(receipts) == 4)

    # Controller interrupted after writing attempt: cannot establish whether
    # SQL ran or failed because there is no matched result receipt.
    crash_before_sql = copy.deepcopy(receipts)
    next_attempt = dict(seq=5, prev_hash=receipts[-1]["hash"], action_id="CRASH",
                        phase="attempt", actor="oes_ci178_via_set",
                        operation="UNKNOWN_EXECUTION", outcome="PENDING", commit=sha)
    next_attempt["hash"] = digest(next_attempt)
    crash_before_sql.append(next_attempt)
    check("controller_failure_detects_unpaired_attempt",
          must_reject(crash_before_sql, anchor_for(crash_before_sql)))
    # The exact same incomplete trail can represent executed SQL followed by
    # a crash before result, so reconciliation needs an independent oracle.
    check("incomplete_receipt_not_execution_proof", guard() == "O")

    # A direct session bypasses the wrapper entirely; a valid chain cannot
    # detect it, even though an actual protected database guard changes state.
    original_count = len(receipts)
    direct_off = invoke("oes_ci178_via_set", sql=(
        "SET ROLE " + OWNER + "; ALTER TABLE " + TABLE + " DISABLE TRIGGER " + TRIGGER + ";"))
    check("direct_sql_outside_wrapper_disables_guard", direct_off.returncode == 0 and guard() == "D")
    check("valid_receipts_still_miss_direct_ddl",
          len(receipts) == original_count and verify(receipts, good_anchor))
    direct_on = invoke("oes_ci178_via_set", sql=(
        "SET ROLE " + OWNER + "; ALTER TABLE " + TABLE + " ENABLE TRIGGER " + TRIGGER + ";"))
    check("direct_sql_restores_guard_without_receipt", direct_on.returncode == 0 and guard() == "O"
          and len(receipts) == original_count)

    # Insider can rewrite all receipt hashes AND anchor in the same trust
    # domain. The local checker accepts forged history (known limitation).
    forged = copy.deepcopy(receipts)
    forged[1]["outcome"] = "FORGED_CONFIRMED"
    prior = "0" * 64
    for row in forged:
        row["prev_hash"] = prior
        row["hash"] = digest({k:v for k,v in row.items() if k != "hash"})
        prior = row["hash"]
    forged_anchor = anchor_for(forged)
    check("isolated_event_change_detected",
          must_reject([dict(receipts[0]),dict(receipts[1],outcome="FORGED_CONFIRMED")] +
                      copy.deepcopy(receipts[2:]), good_anchor))
    check("joint_log_and_anchor_forgery_undetected",
          verify(forged, forged_anchor) and forged_anchor["final_hash"] != good_anchor["final_hash"])
    (OUT / "forgery-demonstration.json").write_text(json.dumps({
        "original_anchor": good_anchor,
        "forged_anchor": forged_anchor,
        "forged_outcome": forged[1]["outcome"],
        "forgery_passed_local_verifier": True}, indent=2) + "\n")

    result = {
        "state": "PG18_CP178_SYNTHETIC_ROLE_TRANSITIVITY_AND_AUDIT_FAILURES_ONLY",
        "source_commit": sha,
        "pg18_disposable_only": True,
        "neon_accessed": False,
        "neon_sql_executed": False,
        "neon_branch_created": False,
        "paid_services_activated": False,
        "role_delegation_direct_admin_false_blocked": True,
        "role_membership_set_path_can_assume_owner": True,
        "role_membership_inherit_path_can_modify_owner_guard": True,
        "set_owner_can_self_grant_role_observed": self_grant_succeeded,
        "receipt_events": len(receipts),
        "controller_crash_detects_unpaired_attempt": True,
        "controller_crash_proves_execution": False,
        "direct_unwrapped_sql_is_captured": False,
        "joint_anchor_and_chain_forgery_is_detected": False,
        "external_independent_audit_configured": False,
        "audit_immutability_proven": False,
        "operational_brg_promoted": False,
        "reconciliation_postconditions_approved": 0
    }
    (OUT / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    (OUT / "result.txt").write_text("CP178_PG18_SYNTHETIC_LIMITED_PASS\n")
    print("CP178_PG18_SYNTHETIC_LIMITED_PASS", flush=True)

if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print("BLOCKED: " + type(exc).__name__ + ": " + str(exc), file=sys.stderr)
        raise SystemExit(1)
