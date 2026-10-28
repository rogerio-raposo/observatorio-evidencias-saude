#!/usr/bin/env python3
"""OES P4-A40: disposable PostgreSQL 18 fixture, NEVER connect to Neon.

No production SQL or credentials. Canonical scripts are read-only originals.
Only the historical OID 155649 is substituted in temporary *copies* for
the isolated fixture's dynamically allocated membership OID.
"""
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
A37 = ROOT / "archive/handoffs/oes/artifacts/P4-A38"
A39 = ROOT / "archive/handoffs/oes/artifacts/P4-A39"
SOURCES = {
    "setup": (A39 / "OES_P4_A39_SETUP_V2_SYNTHETIC_TARGET_HOLD.sql",
              "236ab6ae232bc6080453345957f6a5e7711911ed50471078a5e53e94ff8f6daa"),
    "trial": (A37 / "OES_P4_A37_TRIAL_SYNTHETIC_ROLLBACK_ONLY_CANDIDATO_HOLD.sql",
              "0ade6935a8d4a368c660f2c94de6a34b4a7d27f768aa87b8d5c8edf964c71b35"),
    "postflight": (A39 / "OES_P4_A39_POSTFLIGHT_V2_CATALOG_READ_ONLY_HOLD.sql",
                   "fac7b3146f56e9f69375cc2f6330d335cc29c961d87ca5c3d02243e0d75fca5d"),
    "lockdown": (A39 / "OES_P4_A39_CREDENTIAL_LOCKDOWN_HOLD.sql",
                 "ff9782bfbc2bdec1503187d69f0b12b1c10a53d7cc08176a79ab15ef7a11baa7"),
    "cleanup": (A39 / "OES_P4_A39_CLEANUP_V2_SYNTHETIC_TARGET_HOLD.sql",
                "83d76fabcf489ba4ac49151f19c799dadade3a956f9f5113da1a3b8ec843954c"),
}
PASSWORD = "a40_disposable_ci_only_not_neon"
DB = "oes_sandbox"
REPORT_DIR = ROOT / "p4-a40-results"
ALLOWED_HOSTS = {"127.0.0.1", "localhost"}
OID_RE = re.compile(r"\boid\s*=\s*155649\b")
REPORT = {"experiment": "OES P4-A40 PG18 isolated synthetic fixture",
          "canonical_sources_unchanged": True, "neon_contacted": False,
          "outcomes": {}, "materialized_sql": {}}


def emit(label, result):
    REPORT["outcomes"][label] = result
    print(f"{label}: {result}", flush=True)


def psql(role="postgres", database=DB, sql=None, script=None, allow_failure=False):
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"),
           "HOME": os.environ.get("HOME", "/tmp"),
           "PGHOST": "127.0.0.1", "PGPORT": "5432",
           "PGDATABASE": database, "PGUSER": role, "PGPASSWORD": PASSWORD,
           "PGSSLMODE": "disable", "PGCONNECT_TIMEOUT": "5",
           "PGOPTIONS": "-c application_name=oes_p4_a40_disposable"}
    cmd = ["psql", "-X", "-v", "ON_ERROR_STOP=on",
           "-v", "ON_ERROR_ROLLBACK=off", "-A", "-t",
           "-F", "|", "-P", "pager=off"]
    if (sql is None) == (script is None):
        raise ValueError("Exactly one of sql/script")
    cmd += ["-c", sql] if sql is not None else ["-f", str(script)]
    p = subprocess.run(cmd, capture_output=True, text=True, env=env, timeout=40)
    if (p.returncode != 0) and not allow_failure:
        raise AssertionError(
            f"psql {role} failed, rc={p.returncode}: "
            + p.stderr[-1100:] + " STDOUT: " + p.stdout[-700:])
    return p


def expect(name, cond):
    emit(name, "PASS" if cond else "FAIL")
    if not cond:
        raise AssertionError(name)


def parse_postflight(stdout):
    rows = [s.strip().split("|") for s in stdout.splitlines() if "|" in s]
    summary = [r for r in rows if len(r) == 5 and r[1] == "SUMMARY"]
    if len(summary) != 1:
        raise AssertionError("Postflight missing unique SUMMARY")
    s = summary[0]
    checks = [r for r in rows if len(r) == 5 and r[0] == "1"]
    if len(checks) != 26 or s[3] != "26":
        raise AssertionError(f"Incomplete postflight: rows={len(checks)}, summary={s}")
    return s, {r[1]: r[2] for r in checks}


def fixture():
    psql(database="postgres", sql="CREATE DATABASE oes_sandbox")
    fixture_sql = """
CREATE ROLE cloud_admin NOLOGIN CREATEROLE;
CREATE ROLE oes_sandbox_owner LOGIN CREATEROLE PASSWORD 'a40_disposable_ci_only_not_neon';
CREATE ROLE oes_django_migrator NOLOGIN NOINHERIT;
CREATE ROLE oes_runtime LOGIN NOINHERIT PASSWORD 'a40_disposable_ci_only_not_neon';
CREATE ROLE oes_p4_trial_login LOGIN NOINHERIT CONNECTION LIMIT 1
  PASSWORD 'a40_disposable_ci_only_not_neon';
GRANT oes_django_migrator TO cloud_admin WITH ADMIN TRUE, INHERIT FALSE, SET TRUE;
SET ROLE cloud_admin;
GRANT oes_django_migrator TO oes_sandbox_owner
  WITH ADMIN TRUE, INHERIT FALSE, SET FALSE GRANTED BY cloud_admin;
RESET ROLE;
"""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".sql") as f:
        f.write(fixture_sql)
        f.flush()
        psql(script=f.name)
    oid = psql(sql="""SELECT oid FROM pg_catalog.pg_auth_members
                WHERE roleid='oes_django_migrator'::regrole
                  AND member='oes_sandbox_owner'::regrole
                  AND grantor='cloud_admin'::regrole
                  AND admin_option AND NOT inherit_option AND NOT set_option""").stdout.strip()
    if not oid.isdigit():
        raise AssertionError("Fixture original grant OID missing")
    expect("fixture_unique_original_grant", psql(sql="""
        SELECT count(*) FROM pg_catalog.pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole""").stdout.strip() == "1")
    REPORT["fixture_original_grant_oid"] = oid
    return oid


def build_copies(tmp, oid):
    copies = {}
    for key, (source, expected_hash) in SOURCES.items():
        data = source.read_bytes()
        actual = hashlib.sha256(data).hexdigest()
        expect("sha_" + key, actual == expected_hash)
        text = data.decode("utf-8")
        rewritten, replacements = OID_RE.subn("oid=" + oid, text)
        # The original A29/A37 historical membership must be substituted
        # ONLY on disposable copies. Other roles/schema names stay unchanged.
        expected_substitutions = {"setup": 1, "trial": 1, "postflight": 1,
                                  "lockdown": 0, "cleanup": 2}
        if replacements != expected_substitutions[key]:
            raise AssertionError(
                f"Unexpected OID replacement count {key}={replacements}, "
                f"expected={expected_substitutions[key]}")
        out = tmp / (key + "_fixture.sql")
        out.write_text(rewritten, encoding="utf-8")
        REPORT["materialized_sql"][key] = {
            "source_sha256": expected_hash, "replace_oid_155649_count": replacements,
            "fixture_sha256": hashlib.sha256(out.read_bytes()).hexdigest()
        }
        copies[key] = out
    return copies


def trial_evidence(stdout):
    lines = [x.strip() for x in stdout.splitlines() if x.strip()]
    rows = [x.split("|") for x in lines if x.startswith("A37_")]
    expected = [
        ("A37_PRE", "oes_p4_trial_login", 1),
        ("A37_TEMP_GRANT", "oes_p4_trial_login", 2),
        ("A37_TARGET", "oes_p4_trial_target", 2),
        ("A37_CLEAN", "oes_p4_trial_login", 1),
    ]
    if len(rows) != 4:
        raise AssertionError("Trial markers missing: " + str(rows))
    pids = set()
    for r, (phase, current, count) in zip(rows, expected):
        if len(r) != 5 or r[0] != phase or r[2] != "oes_p4_trial_login":
            raise AssertionError("Trial identity or marker mismatch: " + str(r))
        if r[3] != current or r[4] != str(count):
            raise AssertionError("Trial membership/current role mismatch: " + str(r))
        pids.add(r[1])
    if len(pids) != 1 or not next(iter(pids)).isdigit():
        raise AssertionError("Trial changed PostgreSQL backend")
    if lines[-1] != "ROLLBACK":
        raise AssertionError("Trial missing terminal ROLLBACK acknowledgment")
    return {"phases": [r[0] for r in rows], "membership_counts": [int(r[4]) for r in rows],
            "one_backend": True, "rollback_acknowledged": True}


def main():
    REPORT_DIR.mkdir(exist_ok=True)
    if os.environ.get("OES_A40_OFFLINE") != "1":
        raise AssertionError("OES_A40_OFFLINE=1 is mandatory")
    if os.environ.get("PGHOST", "127.0.0.1") not in ALLOWED_HOSTS:
        raise AssertionError("Remote PGHOST forbidden")
    psql(database="postgres", sql="SELECT 1")
    version = psql(database="postgres", sql="SHOW server_version_num").stdout.strip()
    expect("postgresql_18", version.isdigit() and 180000 <= int(version) < 190000)
    server_ip = psql(database="postgres", sql="SELECT host(inet_server_addr())").stdout.strip()
    # Docker publishes 127.0.0.1:5432 on the runner, but the backend
    # legitimately reports its own RFC1918 bridge address (not 127.0.0.1).
    ip = ipaddress.ip_address(server_ip)
    expect("local_only_endpoint", ip.is_private or ip.is_loopback)
    oid = fixture()
    with tempfile.TemporaryDirectory(prefix="oes-p4-a40-") as td:
        files = build_copies(Path(td), oid)
        setup = psql(role="oes_sandbox_owner", script=files["setup"])
        emit("setup_pg18_exec", "PASS")
        trial = psql(role="oes_p4_trial_login", script=files["trial"])
        REPORT["trial"] = trial_evidence(trial.stdout)
        emit("trial_grant_set_revoke_rollback", "PASS")
        post = psql(role="oes_sandbox_owner", script=files["postflight"])
        summary, checks = parse_postflight(post.stdout)
        expect("postflight_26_check_pass", summary[2] == "t" and summary[4] == "0"
               and all(v == "t" for v in checks.values()))
        psql(sql="CREATE ROLE oes_p4_a40_third NOLOGIN")
        psql(role="oes_sandbox_owner", sql="""GRANT oes_p4_trial_target TO oes_p4_a40_third
             WITH ADMIN FALSE, INHERIT FALSE, SET FALSE GRANTED BY oes_sandbox_owner""")
        negative = psql(role="oes_sandbox_owner", script=files["postflight"])
        bad_summary, bad_checks = parse_postflight(negative.stdout)
        expect("postflight_detects_third_party",
               bad_summary[2] == "f" and int(bad_summary[4]) > 0
               and bad_checks["target_grants_to_only_trial"] == "f")
        denied = psql(role="oes_sandbox_owner", script=files["cleanup"], allow_failure=True)
        expect("cleanup_rejects_third_party", denied.returncode != 0
               and "HOLD A39 cleanup" in denied.stderr)
        psql(role="oes_sandbox_owner", sql="""REVOKE oes_p4_trial_target FROM oes_p4_a40_third
             GRANTED BY oes_sandbox_owner RESTRICT""")
        restored = psql(role="oes_sandbox_owner", script=files["postflight"])
        summary, _ = parse_postflight(restored.stdout)
        expect("postflight_restored", summary[2] == "t" and summary[4] == "0")
        psql(role="oes_sandbox_owner", script=files["lockdown"])
        emit("independent_credential_lockdown_commit", "PASS")
        psql(role="oes_sandbox_owner", script=files["cleanup"])
        emit("cleanup_after_lockdown_commit", "PASS")
        finish = psql(sql="""SELECT
          (SELECT count(*)=0 FROM pg_roles WHERE rolname='oes_p4_trial_target')
          AND (SELECT count(*)=1 FROM pg_roles
               WHERE rolname='oes_p4_trial_login' AND NOT rolcanlogin)
          AND (SELECT count(*)=0 FROM pg_auth_members
               WHERE member='oes_p4_trial_login'::regrole
                  OR roleid='oes_p4_trial_login'::regrole)
          AND (SELECT count(*)=1 FROM pg_auth_members
               WHERE roleid='oes_django_migrator'::regrole
               AND member='oes_sandbox_owner'::regrole)
        """).stdout.strip()
        expect("final_cleanup_catalog_state", finish == "t")
        emit("no_neon_connection", "PASS")
        REPORT["status"] = "PASS"
    return 0


if __name__ == "__main__":
    try:
        status = main()
    except Exception as exc:
        REPORT["status"] = "HOLD"
        REPORT["error"] = str(exc)[:1300]
        print(f"A40_HOLD: {exc}", file=sys.stderr)
        status = 1
    REPORT_DIR.mkdir(exist_ok=True)
    (REPORT_DIR / "summary.json").write_text(
        json.dumps(REPORT, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    sys.exit(status)
