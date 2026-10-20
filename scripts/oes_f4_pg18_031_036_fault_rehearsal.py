#!/usr/bin/env python3
"""Disposable PG18 proof-of-observation only: 031..036 installation and fault points.

NEVER call against Neon. No ledger or operational migration runner.
This is a CI-only, fixed-database test with explicit synthetic guards.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

OUT = Path("f4-pg18-fault-evidence")
MANIFEST = Path("database/f4-neon-sandbox-schema-migration-manifest.txt")
ADMIN = "oes_f4_fault_synthetic"
BASE = "oes170base"
LIVE = "oes170live"
PSQL = ["psql", "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1"]
SCHEMA_SNAPSHOT = r"""
WITH objects AS (
  SELECT 'relation' kind, n.nspname||'.'||c.relname key,
    concat_ws('|',c.relkind::text,c.relpersistence::text,c.relispartition::text,
      CASE WHEN c.relkind IN ('v','m') THEN pg_get_viewdef(c.oid,true) ELSE '' END) definition
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname NOT IN ('information_schema','public')
  UNION ALL
  SELECT 'column',n.nspname||'.'||c.relname||'.'||a.attname,
    concat_ws('|',a.attnum::text,format_type(a.atttypid,a.atttypmod),
      a.attnotnull::text,coalesce(pg_get_expr(d.adbin,d.adrelid),''))
  FROM pg_attribute a
  JOIN pg_class c ON c.oid=a.attrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
  LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
  WHERE a.attnum>0 AND NOT a.attisdropped
    AND n.nspname NOT LIKE 'pg_%' AND n.nspname NOT IN ('information_schema','public')
  UNION ALL
  SELECT 'constraint',n.nspname||'.'||c.relname||'.'||co.conname,
    concat_ws('|',co.contype::text,co.convalidated::text,pg_get_constraintdef(co.oid,true))
  FROM pg_constraint co JOIN pg_class c ON c.oid=co.conrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname NOT IN ('information_schema','public')
  UNION ALL
  SELECT 'index',n.nspname||'.'||c.relname||'.'||i.indexrelid::regclass::text,
    concat_ws('|',i.indisvalid::text,i.indisready::text,pg_get_indexdef(i.indexrelid))
  FROM pg_index i JOIN pg_class c ON c.oid=i.indrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE n.nspname NOT LIKE 'pg_%' AND n.nspname NOT IN ('information_schema','public')
  UNION ALL
  SELECT 'trigger',n.nspname||'.'||c.relname||'.'||t.tgname,
    concat_ws('|',t.tgenabled::text,pg_get_triggerdef(t.oid,true))
  FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid
  JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE NOT t.tgisinternal
    AND n.nspname NOT LIKE 'pg_%' AND n.nspname NOT IN ('information_schema','public')
  UNION ALL
  SELECT 'function',n.nspname||'.'||p.proname||'('||pg_get_function_identity_arguments(p.oid)||')',
    pg_get_functiondef(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE p.prokind IN ('f','p')
    AND n.nspname NOT LIKE 'pg_%' AND n.nspname NOT IN ('information_schema','public')
  UNION ALL
  SELECT 'seed','maintenance.contract_epoch.'||contract_code,
    concat_ws('|',contract_code,schema_version,migration_id)
  FROM maintenance.contract_epoch
)
SELECT coalesce(jsonb_agg(jsonb_build_object(
   'kind',kind,'key',key,'sha256',md5(definition))
   ORDER BY kind,key), '[]'::jsonb)
FROM objects;
"""


def check(name, condition):
    if not condition:
        raise AssertionError("CHECK_FAILED " + name)
    (OUT / "checks.tsv").open("a",encoding="utf8").write(f"{name}\tPASS\n")
    print(name + "\tPASS",flush=True)


def run(db, *, sql=None, path=None, expected=True):
    if not re.fullmatch(r"oes170(?:base|live|fault\d{3})|oes_f4_fault_synthetic", db):
        raise AssertionError("unsafe DB name")
    argv = PSQL + ["-d", db] + (["-f",str(path)] if path else ["-c",sql])
    p = subprocess.run(argv, capture_output=True, text=True, timeout=80)
    if expected and p.returncode != 0:
        raise AssertionError(f"SQL failure {db}: {p.stderr[-1300:]}")
    return p


def value(db,statement):
    return run(db,sql=statement).stdout.strip()


def create_db(name, template):
    if not re.fullmatch(r"oes170(?:base|live|fault\d{3})", name):
        raise AssertionError("invalid new name")
    if template not in (ADMIN,BASE,LIVE):
        raise AssertionError("invalid template")
    run(ADMIN,sql=f"CREATE DATABASE {name} TEMPLATE {template};")


def snapshot(db,label):
    obj = json.loads(value(db,SCHEMA_SNAPSHOT))
    records = {x["kind"]+":"+x["key"]:x["sha256"] for x in obj}
    if len(records)!=len(obj):
        raise AssertionError("duplicate catalog object keys")
    (OUT / f"{label}.json").write_text(json.dumps(records,sort_keys=True,indent=2),encoding="utf8")
    return records


def changed(before,after):
    return sorted(k for k in before.keys()|after.keys() if before.get(k)!=after.get(k))


def exists_trigger(db,table,trigger):
    q = f"""SELECT coalesce((SELECT t.tgenabled::text FROM pg_trigger t
JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='maintenance' AND c.relname='{table}' AND t.tgname='{trigger}'
AND NOT t.tgisinternal),'ABSENT');"""
    return value(db,q)


def write_fault(name,sql):
    path=Path("database") / (".oes_ci_" + name + ".sql")
    # The wrapper must be in database/ for its relative psql \ir includes.
    path.write_text(sql,encoding="utf8")
    return path


def main():
    required={"GITHUB_ACTIONS":"true",
              "GITHUB_REPOSITORY":"rogerio-raposo/observatorio-evidencias-saude",
              "PGHOST":"127.0.0.1","PGPORT":"5432","PGUSER":"postgres",
              "PGDATABASE":ADMIN}
    if any(os.getenv(k)!=v for k,v in required.items()):
        raise RuntimeError("BLOCKED: only disposable GitHub Actions PG18")
    if any(os.getenv(k) for k in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: external database configuration")
    if not value(ADMIN,"SHOW server_version_num;").startswith("18"):
        raise RuntimeError("BLOCKED: PostgreSQL 18 required")
    OUT.mkdir(exist_ok=True)
    (OUT/"checks.tsv").write_text("check\tresult\n",encoding="utf8")
    manifest=[x.strip() for x in MANIFEST.read_text(encoding="utf8").splitlines()
              if x.strip() and not x.lstrip().startswith("#")]
    check("manifest_has_exactly_36_paths",len(manifest)==36 and len(set(manifest))==36)
    check("manifest_tail_031_to_036",all(re.match(fr"^database/{i:03d}_.*\.sql$",manifest[i-1])
                                               for i in range(31,37)))
    commit=os.getenv("GITHUB_SHA")
    check("fixed_commit_available",bool(commit and re.fullmatch(r"[0-9a-f]{40}",commit)))
    (OUT/"commit.txt").write_text(commit+"\n",encoding="utf8")
    (OUT/"pg-version.txt").write_text(value(ADMIN,"SHOW server_version;")+"\n",encoding="utf8")

    # Complete baseline 001-030. All SQL is only applied to a disposable CI service.
    for n,path in enumerate(manifest[:30],1):
        run(ADMIN,path=path)
    check("baseline_001_to_030_installed_in_disposable_pg18",True)
    create_db(BASE,ADMIN)
    create_db(LIVE,BASE)

    report=[]
    for n in range(31,37):
        migration=manifest[n-1]
        before=snapshot(LIVE,f"{n:03d}-before")
        fault_db=f"oes170fault{n:03d}"
        if n<=33:
            create_db(fault_db,LIVE)
        run(LIVE,path=migration)
        after=snapshot(LIVE,f"{n:03d}-after")
        delta=changed(before,after)
        check(f"{n:03d}_catalog_delta_detected",len(delta)>0)
        summary={"ordinal":n,"entrypoint":migration,"changed_object_count":len(delta),
                 "added":sum(k not in before for k in delta),
                 "deleted":sum(k not in after for k in delta),
                 "modified":sum(k in before and k in after for k in delta),
                 "catalog_diff_evidence":"SCHEMA_SNAPSHOT_OBSERVED_NOT_A_POSTCONDITION_PROOF"}
        if n<=33:
            text=Path(migration).read_text(encoding="utf8")
            if len(re.findall(r"(?im)^\s*COMMIT\s*;\s*$",text))!=1:
                raise AssertionError("transaction boundary drift")
            injected=re.sub(r"(?im)^\s*COMMIT\s*;\s*$",
                            "SELECT 1/0;\\nCOMMIT;",text,count=1)
            bad=run(fault_db,path=write_fault(f"fail{n:03d}",injected),expected=False)
            check(f"{n:03d}_injected_error_detected",bad.returncode!=0 and "division by zero" in bad.stderr)
            rolled=snapshot(fault_db,f"{n:03d}-forced-rollback")
            check(f"{n:03d}_wrapper_rollback_matches_before",rolled==before)
            summary["fault_kind"]="BEFORE_INTERNAL_COMMIT"
            summary["fault_state"]="ROLLED_BACK_SAME_CATALOG_IN_TEST"
        elif n in (34,36):
            # Retry-like interruption over a database already containing the guard:
            # dropping an enabled trigger can commit before recreation.
            create_db(fault_db,LIVE)
            text=Path(migration).read_text(encoding="utf8")
            cut=re.search(r"(?im)^\s*CREATE\s+TRIGGER\s+",text)
            if not cut or len(re.findall(r"(?im)^\s*DROP\s+TRIGGER\s+",text))!=1:
                raise AssertionError("expected DROP/CREATE shape absent")
            table,trigger=(
                ("temporal_observation_epoch","tr_temporal_epoch_activation_chronology")
                if n==34 else
                ("temporal_measurement_event","tr_temporal_event_first_measurement_semantics")
            )
            check(f"{n:03d}_enabled_trigger_pre_fault",
                  exists_trigger(fault_db,table,trigger) in ("O","A","R"))
            p=write_fault(f"fail{n:03d}",text[:cut.start()]+"SELECT 1/0;\n")
            bad=run(fault_db,path=p,expected=False)
            check(f"{n:03d}_injected_error_detected",bad.returncode!=0 and "division by zero" in bad.stderr)
            check(f"{n:03d}_trigger_missing_after_partial_retry",
                  exists_trigger(fault_db,table,trigger)=="ABSENT")
            summary["fault_kind"]="DROP_TRIGGER_BEFORE_CREATE_ON_INSTALLED_DB"
            summary["fault_state"]="PARTIAL_OR_DRIFT_CONFIRMED"
        else: # 035: first CREATE OR REPLACE FUNCTION can commit before second.
            text=Path(migration).read_text(encoding="utf8")
            cut=re.search(r"(?im)^\s*CREATE\s+OR\s+REPLACE\s+FUNCTION\s+maintenance\.temporal_activation_preflight_state\s*\(",text)
            if not cut:raise AssertionError("second function boundary absent")
            p=write_fault("fail035",text[:cut.start()]+"SELECT 1/0;\n")
            # Clone the baseline, then replay 031-034 as a clean pre-035 state.
            # A separate disposable 031-034 prefix avoids mutating LIVE.
            predb="oes170fault035"
            create_db(predb,BASE)
            for prior in manifest[30:34]:
                run(predb,path=prior)
            check("035_pre_fault_prefix_matches_before",snapshot(predb,"035-recreated-before")==before)
            bad=run(predb,path=p,expected=False)
            check("035_injected_error_detected",bad.returncode!=0 and "division by zero" in bad.stderr)
            partial=snapshot(predb,"035-partial")
            check("035_first_function_committed_before_second",
                  partial!=before and any("temporal_activation_preflight(" in k
                                          for k in changed(before,partial)))
            second="SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='maintenance' AND p.proname='temporal_activation_preflight_state';"
            check("035_second_function_not_installed",value(predb,second)=="0")
            summary["fault_kind"]="FIRST_FUNCTION_BEFORE_SECOND"
            summary["fault_state"]="PARTIAL_OR_DRIFT_CONFIRMED"
        report.append(summary)
        print(f"STAGE {n:03d} {summary['fault_state']}",flush=True)

    seed=value(LIVE,"SELECT string_agg(contract_code||':'||migration_id, ',' ORDER BY contract_code) FROM maintenance.contract_epoch;")
    check("031_032_structural_seed_receipts_present",
          "PROPAGATION_REBASELINE_V01:031" in seed and "TEMPORAL_CALIBRATION_V01:032" in seed)
    check("034_final_trigger_enabled",
          exists_trigger(LIVE,"temporal_observation_epoch","tr_temporal_epoch_activation_chronology") in ("O","A","R"))
    check("036_final_trigger_enabled",
          exists_trigger(LIVE,"temporal_measurement_event","tr_temporal_event_first_measurement_semantics") in ("O","A","R"))
    (OUT/"stage-report.json").write_text(json.dumps({
        "commit":commit, "server_pg18":True, "stages":report,
        "source_vs_database":"catalog fingerprints and forced failure states observed",
        "reconciliation_approved":False,"postconditions_validated":0,
        "grandfathering_populated_fixture_tested":False,
        "ledger_operational":False,"neon_accessed":False,"neon_write_authorized":False
    },indent=2),encoding="utf8")
    (OUT/"result.txt").write_text("PG18_031_036_FAULT_OBSERVATIONS_ONLY\n",encoding="utf8")
    print("PG18_031_036_FAULT_OBSERVATIONS_ONLY",flush=True)


if __name__=="__main__":
    try: main()
    except Exception as e:
        print(f"BLOCKED: {type(e).__name__}: {e}",file=sys.stderr)
        sys.exit(1)
