#!/usr/bin/env python3
"""Synthetic-only PG18 CI supervisor model. NOT a Neon/OES migration runner."""
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import threading
import time

OUT = Path("f4-pg18-supervisor-artifacts")
BOOT = Path("tests/fixtures/f4-ledger-synthetic/bootstrap.sql")
CAT = Path("tests/fixtures/f4-supervisor-synthetic/postconditions.json")
PSQL = ["psql", "-X", "-q", "-At", "-v", "ON_ERROR_STOP=1"]
LOCK = 419166


def check(name, ok):
    if not ok:
        raise AssertionError(f"CHECK_FAILED:{name}")
    print(f"{name}\tPASS", flush=True)
    with (OUT / "checks.tsv").open("a", encoding="utf8") as f:
        f.write(f"{name}\tPASS\n")


def sql(query, *, expected=True, env=None, timeout=15):
    p = subprocess.run(PSQL + ["-c", query], env=env, capture_output=True,
                       text=True, timeout=timeout, check=False)
    if expected and p.returncode:
        raise AssertionError("Unexpected SQL failure: " + p.stderr[-400:])
    return p


def val(query):
    return sql(query).stdout.strip()


def eventually(fn, timeout=7):
    limit = time.monotonic() + timeout
    while time.monotonic() < limit:
        if fn():
            return True
        time.sleep(0.1)
    return False


def table(name):
    return val("SELECT EXISTS(SELECT 1 FROM pg_class c JOIN pg_namespace n "
               "ON n.oid=c.relnamespace WHERE n.nspname='oes_ci' "
               f"AND c.relname='{name}' AND c.relkind='r');") == "t"


def event(mid, sha, state, evidence):
    sql("INSERT INTO ops.schema_migration_event "
        "(migration_id,content_sha256,event_type,evidence) VALUES "
        f"('{mid}','{sha}','{state}','{evidence}');")


def retry_blocked(mid, sha):
    p = sql(f"SELECT ops.assert_can_start('{mid}','{sha}');", expected=False)
    return p.returncode != 0 and "RETRY_BLOCKED" in p.stderr


def claim(who, barrier, sha):
    barrier.wait(timeout=6)
    return bool(sql("INSERT INTO ops.schema_migration_event "
                    "(migration_id,content_sha256,event_type,evidence) "
                    f"VALUES ('simultaneous_claim','{sha}','prepared','{who}') "
                    "ON CONFLICT DO NOTHING RETURNING event_id;").stdout.strip())


def guarded_sql(guardian, statement):
    if guardian.poll() is not None:
        raise RuntimeError("GUARD_LOST: do not spawn another psql")
    return sql(statement)


def main():
    require = dict(GITHUB_ACTIONS="true",
                   GITHUB_REPOSITORY="rogerio-raposo/observatorio-evidencias-saude",
                   PGHOST="127.0.0.1", PGPORT="5432",
                   PGDATABASE="oes_f4_supervisor_synthetic", PGUSER="postgres")
    if any(os.getenv(k) != v for k, v in require.items()):
        raise RuntimeError("BLOCKED: synthetic CI destination mismatch")
    if any(os.getenv(k) for k in ("DATABASE_URL", "PGSERVICE", "PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: external connection configuration")
    OUT.mkdir(exist_ok=True)
    (OUT / "checks.tsv").write_text("check\tresult\n", encoding="utf8")
    check("server_pg18", val("SHOW server_version_num;").startswith("18"))
    sha = hashlib.sha256(BOOT.read_bytes()).hexdigest()
    proc = subprocess.run(PSQL + ["-f", str(BOOT)], capture_output=True,
                          text=True, timeout=20, check=False)
    check("bootstrap_fixture", proc.returncode == 0)
    # 'assert_can_start' alone is not a concurrency boundary. A unique
    # partial index is the atomic guard for synthetic durable 'prepared'.
    sql("CREATE UNIQUE INDEX one_prepared_per_migration_synthetic "
        "ON ops.schema_migration_event(migration_id) WHERE event_type='prepared';")
    barrier = threading.Barrier(2)
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
        futures = [ex.submit(claim, i, barrier, sha) for i in range(2)]
        wins = [f.result(timeout=10) for f in futures]
    check("two_contenders_one_durable_winner", wins.count(True) == 1)
    check("one_prepared_for_concurrent_claim",
          val("SELECT count(*) FROM ops.schema_migration_event "
              "WHERE migration_id='simultaneous_claim' AND event_type='prepared';") == "1")
    check("losing_controller_refuses_retry", retry_blocked("simultaneous_claim", sha))
    (OUT / "claim-results.json").write_text(json.dumps(wins), encoding="utf8")

    with (OUT / "guardian.log").open("w", encoding="utf8") as log:
        guard = subprocess.Popen(PSQL, stdin=subprocess.PIPE, stdout=log,
                                 stderr=subprocess.STDOUT, text=True, bufsize=1)
        child = None
        try:
            if guard.stdin is None:
                raise RuntimeError("stdin missing")
            guard.stdin.write(f"SELECT pg_advisory_lock({LOCK});\n")
            guard.stdin.flush()
            check("guardian_lock_acquired", eventually(
                lambda: val(f"SELECT pg_try_advisory_lock({LOCK});") == "f"))
            check("guard_idle_during_subprocesses", eventually(
                lambda: val("SELECT count(*) FROM pg_stat_activity WHERE "
                  "state='idle' AND pid IN (SELECT pid FROM pg_locks WHERE "
                  f"locktype='advisory' AND granted AND objid={LOCK});") == "1"))

            # A committed legacy SQL can have a missing receipt.
            old = "committed_receipt_missing"
            event(old, sha, "prepared", "durable claim before SQL")
            guarded_sql(guard, "CREATE TABLE oes_ci.commit_without_receipt(id integer);")
            check("legacy_commit_without_receipt_observed", table("commit_without_receipt"))
            check("legacy_commit_does_not_allow_replay", retry_blocked(old, sha))
            event(old, sha, "uncertain_requires_reconciliation",
                  "SQL committed but receipt absent")

            # Cancellation of an open transaction under guard loss.
            mid = "supervised_cancel"
            event(mid, sha, "prepared", "durable claim before inflight SQL")
            env = os.environ.copy()
            env["PGAPPNAME"] = "oes_supervisor_cancel_test"
            child = subprocess.Popen(PSQL + ["-c",
                "BEGIN; CREATE TABLE oes_ci.uncommitted_cancel (id integer); "
                "SELECT pg_sleep(20); COMMIT;"], env=env, text=True,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            check("child_running_before_guard_loss", eventually(lambda: val(
                "SELECT count(*) FROM pg_stat_activity WHERE "
                "application_name='oes_supervisor_cancel_test' AND state='active';") == "1"))
            check("uncommitted_table_invisible", not table("uncommitted_cancel"))
            guard.kill()
            guard.wait(timeout=6)
            check("guardian_loss_observed", guard.poll() is not None)
            check("guardian_lock_released", eventually(
                lambda: val(f"SELECT pg_try_advisory_lock({LOCK});") == "t"))
            # The supervisor acts on the known PGAPPNAME of the in-flight job.
            cancelled = val("SELECT bool_or(pg_cancel_backend(pid)) FROM pg_stat_activity "
                            "WHERE application_name='oes_supervisor_cancel_test' "
                            "AND state='active';")
            check("backend_cancel_requested", cancelled == "t")
            stdout, stderr = child.communicate(timeout=10)
            check("inflight_client_exit_is_failure", child.returncode != 0)
            check("inflight_transaction_rolled_back", not table("uncommitted_cancel"))
            check("cancelled_attempt_still_blocks_replay", retry_blocked(mid, sha))
            event(mid, sha, "uncertain_requires_reconciliation",
                  "cancel observed; do not presume universal rollback")
            check("no_auto_applied_receipts",
                  val("SELECT count(*) FROM ops.schema_migration_event "
                    "WHERE migration_id IN ('supervised_cancel','committed_receipt_missing') "
                    "AND event_type='applied';") == "0")
            try:
                guarded_sql(guard, "CREATE TABLE oes_ci.forbidden_after_guard_loss(id integer);")
                refused = False
            except RuntimeError as ex:
                refused = "GUARD_LOST" in str(ex)
            check("supervisor_refuses_new_child_after_loss", refused)
            check("no_forbidden_sql_executed", not table("forbidden_after_guard_loss"))
            (OUT / "child-result.json").write_text(json.dumps(
                {"exit_code": child.returncode, "stderr_tail": stderr[-240:]}),
                encoding="utf8")

            catalog = json.loads(CAT.read_text(encoding="utf8"))
            report = {}
            for name, rule in catalog.items():
                relation = rule["relation"]
                if relation not in ("oes_ci.uncommitted_cancel",
                                    "oes_ci.commit_without_receipt"):
                    raise AssertionError("Invalid synthetic catalog relation")
                observed = table(relation.split(".")[1])
                check("postcondition_" + name, observed == rule["expected_exists"])
                event_type = val("SELECT event_type FROM ops.schema_migration_event "
                  f"WHERE migration_id='{rule['migration_id']}' "
                  "ORDER BY event_id DESC LIMIT 1;")
                check("uncertain_event_" + name,
                      event_type == "uncertain_requires_reconciliation")
                report[name] = {"relation": relation, "observed_exists": observed,
                                "ledger_status": event_type,
                                "automatic_replay": False,
                                "automatic_applied_receipt": False}
            (OUT / "postconditions.json").write_text(
                json.dumps(report, indent=2), encoding="utf8")
            check("reconciliation_remains_manual", all(
                not v["automatic_replay"] and not v["automatic_applied_receipt"]
                for v in report.values()))
        finally:
            if child is not None and child.poll() is None:
                child.kill()
                child.communicate(timeout=5)
            if guard.poll() is None:
                guard.kill()
                guard.wait(timeout=5)
    (OUT / "result.txt").write_text(
        "SYNTHETIC_SUPERVISOR_PASS_WITH_LIMITATIONS\n", encoding="utf8")
    print("SYNTHETIC_SUPERVISOR_PASS_WITH_LIMITATIONS", flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"BLOCKED: {type(exc).__name__}: {exc}", file=sys.stderr)
        sys.exit(1)
