#!/usr/bin/env python3
"""Synthetic-only CI guardian prototype. NEVER use against a Neon connection."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

DB_NAME = "oes_f4_guardian_synthetic"
LOCK_ID = 419164
DIR = Path("f4-pg18-guardian-artifacts")
BOOTSTRAP = Path("tests/fixtures/f4-ledger-synthetic/bootstrap.sql")
PSQL = ["psql", "-X", "-A", "-t", "-v", "ON_ERROR_STOP=1"]

def check(condition, label):
    if not condition:
        raise AssertionError(label)
    print(f"{label}\tPASS", flush=True)
    with (DIR / "checks.tsv").open("a", encoding="utf-8") as f:
        f.write(f"{label}\tPASS\n")

def query(sql, expected_success=True, env=None):
    p = subprocess.run(PSQL + ["-c", sql], text=True, capture_output=True,
                       timeout=20, env=env, check=False)
    if expected_success and p.returncode != 0:
        raise AssertionError(f"psql unexpectedly failed: {p.stderr[-700:]}")
    return p

def scalar(sql):
    return query(sql).stdout.strip()

def require_error(sql, expected, label):
    p = query(sql, expected_success=False)
    check(p.returncode != 0 and expected in p.stderr, label)

def event(mig_id, digest, kind, evidence):
    query("INSERT INTO ops.schema_migration_event"
          "(migration_id,content_sha256,event_type,evidence)"
          f" VALUES ('{mig_id}','{digest}','{kind}','{evidence}');")

def table_count(name):
    return scalar("SELECT count(*) FROM information_schema.tables WHERE "
                  f"table_schema='oes_ci' AND table_name='{name}';")

def await_condition(fn, secs=8):
    deadline = time.monotonic() + secs
    while time.monotonic() < deadline:
        if fn():
            return True
        time.sleep(0.12)
    return False

def main():
    # All four assertions are mandatory; never accept an externally supplied DB URL.
    allow = {
        "GITHUB_ACTIONS": "true",
        "GITHUB_REPOSITORY": "rogerio-raposo/observatorio-evidencias-saude",
        "PGHOST": "127.0.0.1",
        "PGPORT": "5432",
        "PGDATABASE": DB_NAME,
        "PGUSER": "postgres",
    }
    if any(os.environ.get(k) != v for k, v in allow.items()) or os.environ.get("DATABASE_URL"):
        print("BLOCKED: disposable PG18 GitHub Actions destination required", file=sys.stderr)
        return 20
    DIR.mkdir(exist_ok=True)
    (DIR / "checks.tsv").write_text("check\tresult\n", encoding="utf-8")
    check(scalar("SHOW server_version_num;").startswith("18"), "pg18_server")
    source = BOOTSTRAP.read_bytes()
    digest = hashlib.sha256(source).hexdigest()
    bootstrap = subprocess.run(PSQL + ["-f", str(BOOTSTRAP)], text=True,
                               capture_output=True, timeout=20, check=False)
    if bootstrap.returncode != 0:
        raise AssertionError(f"synthetic bootstrap: {bootstrap.stderr[-500:]}")
    check(table_count("never_exists") == "0", "synthetic_fixture_installed")

    # A dedicated, long-lived PostgreSQL connection owns a session-level lock.
    # Its lifetime overlaps *multiple independent subprocesses*.
    with (DIR / "guardian.log").open("w", encoding="utf-8") as guardian_log:
        guardian = subprocess.Popen(
            PSQL + ["-c", f"SELECT pg_advisory_lock({LOCK_ID}); SELECT pg_sleep(60);"],
            stdout=guardian_log, stderr=subprocess.STDOUT, text=True,
        )
        try:
            check(await_condition(
                lambda: scalar(f"SELECT pg_try_advisory_lock({LOCK_ID});") == "f"
            ), "persistent_guard_acquired")

            mig = "guardian_commit_gap"
            query(f"SELECT ops.assert_can_start('{mig}','{digest}');")
            event(mig, digest, "prepared", "synthetic intent before child SQL")
            check(scalar("SELECT count(*) FROM ops.schema_migration_event "
                         "WHERE migration_id='guardian_commit_gap' AND event_type='prepared';") == "1",
                  "prepared_before_child_sql")

            # Each SQL command gets its own session; the guardian must stay alive.
            query("CREATE TABLE oes_ci.guard_child_one (id integer PRIMARY KEY);")
            check(guardian.poll() is None and table_count("guard_child_one") == "1",
                  "guard_held_during_first_psql_subprocess")
            check(scalar(f"SELECT pg_try_advisory_lock({LOCK_ID});") == "f",
                  "contender_denied_between_subprocesses")
            query("CREATE TABLE oes_ci.guard_child_two (id integer PRIMARY KEY);")
            check(guardian.poll() is None and table_count("guard_child_two") == "1",
                  "guard_held_during_second_psql_subprocess")

            # Deliberately demonstrate residual risk: if guardian dies while a
            # child is already executing, server-side SQL is not automatically
            # cancelled by loss of the guardian's separate connection.
            env = dict(os.environ)
            env["PGAPPNAME"] = "oes_synthetic_inflight_child"
            child = subprocess.Popen(
                PSQL + ["-c",
                    "SELECT pg_sleep(2); CREATE TABLE oes_ci.inflight_after_guard_loss "
                    "(id integer PRIMARY KEY);"],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env
            )
            check(await_condition(
                lambda: scalar("SELECT count(*) FROM pg_stat_activity "
                   "WHERE application_name='oes_synthetic_inflight_child' "
                   "AND state='active';") == "1",
                secs=5
            ), "child_confirmed_running_before_guard_kill")

            guardian.kill()  # SIGKILL simulated guardian crash; not the child.
            guardian.wait(timeout=5)
            check(await_condition(
                lambda: scalar(f"SELECT pg_try_advisory_lock({LOCK_ID});") == "t"
            ), "session_lock_released_after_guard_kill")

            output, errors = child.communicate(timeout=10)
            check(child.returncode == 0 and table_count("inflight_after_guard_loss") == "1",
                  "inflight_child_can_commit_after_guard_crash_NEGATIVE_CONTROL")
            (DIR / "child-exit.json").write_text(
                json.dumps({"returncode": child.returncode, "child_stderr": errors[-300:]}),
                encoding="utf-8"
            )
            check(scalar("SELECT count(*) FROM ops.schema_migration_event WHERE "
                         "migration_id='guardian_commit_gap' AND event_type='applied';") == "0",
                  "no_false_applied_receipt_after_guard_crash")
            require_error(f"SELECT ops.assert_can_start('{mig}','{digest}');",
                          "RETRY_BLOCKED", "durable_intent_blocks_replay_after_guard_loss")
            event(mig, digest, "uncertain_requires_reconciliation",
                  "guard died mid-child; child committed; must reconcile")
            check(scalar("SELECT event_type FROM ops.schema_migration_event "
                  "WHERE migration_id='guardian_commit_gap' ORDER BY event_id DESC LIMIT 1;")
                  == "uncertain_requires_reconciliation",
                  "uncertain_event_persisted")

            # A newly started session can reacquire the lock but still cannot
            # retry the migration because a prior durable intent exists.
            check(scalar(f"SELECT pg_try_advisory_lock({LOCK_ID});") == "t",
                  "new_session_can_acquire_lock_after_crash")
            require_error(f"SELECT ops.assert_can_start('{mig}','{digest}');",
                          "RETRY_BLOCKED", "new_session_still_cannot_replay")
        finally:
            if guardian.poll() is None:
                guardian.kill()
                guardian.wait(timeout=5)
    print("SYNTHETIC_GUARDIAN_MODEL_PASS", flush=True)
    (DIR / "result.txt").write_text("SYNTHETIC_GUARDIAN_MODEL_PASS\n", encoding="utf-8")
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"BLOCKED: {type(exc).__name__}: {exc}", file=sys.stderr)
        raise SystemExit(1)
