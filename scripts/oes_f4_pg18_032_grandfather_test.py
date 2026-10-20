#!/usr/bin/env python3
"""CI-only synthetic 032 grandfathering fixture and injected rollback evidence.

No Neon, clinical data, scheduling policy, migration runner, or replay capability.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd()
OUT = ROOT / "f4-pg18-032-evidence"
MANIFEST = ROOT / "database/f4-neon-sandbox-schema-migration-manifest.txt"
FIXTURE = ROOT / "tests/fixtures/f4-grandfathering-032/seed.sql"
ADMIN = "oes_f4_032_synthetic"
DBS = {"base":"oes171base","success":"oes171success",
       "rollback":"oes171rollback","preseed":"oes171preseed"}
UUIDS = {
    "update_policy": "33333333-3333-4333-8333-000000000171",
    "sla_rule": "55555555-5555-4555-8555-000000000171",
    "sla_calendar_version": "44444444-4444-4444-8444-000000000171",
}
PSQL = ["psql","-X","-q","-A","-t","-v","ON_ERROR_STOP=1"]


def require(cond, name):
    if not cond:
        raise AssertionError("CHECK_FAILED " + name)
    print(name + "\tPASS", flush=True)
    with (OUT / "checks.tsv").open("a",encoding="utf8") as f:
        f.write(name + "\tPASS\n")


def psql(db, *, command=None, path=None, check=True):
    if db not in (ADMIN,*DBS.values()):
        raise AssertionError("unsafe db destination")
    if (command is None) == (path is None):
        raise AssertionError("ambiguous psql invocation")
    args = PSQL + ["-d",db] + (["-c",command] if command is not None else ["-f",str(path)])
    proc = subprocess.run(args,capture_output=True,text=True,timeout=65,check=False)
    if check and proc.returncode != 0:
        raise AssertionError(f"psql {db}: {proc.stderr[-800:]}")
    return proc


def scalar(db,cmd):
    return psql(db,command=cmd).stdout.strip()


def make_db(target, template):
    if target not in DBS.values() or template not in (ADMIN,*DBS.values()):
        raise AssertionError("invalid CREATE DATABASE template")
    psql(ADMIN,command=f"CREATE DATABASE {target} TEMPLATE {template};")


def fixture_ids(db):
    query="""SELECT object_type || ':' || object_uuid::text FROM (
    SELECT 'update_policy' object_type, update_policy_uuid object_uuid FROM maintenance.update_policy
    UNION ALL SELECT 'sla_rule', sla_rule_uuid FROM maintenance.sla_rule
    UNION ALL SELECT 'sla_calendar_version',sla_calendar_version_uuid FROM maintenance.sla_calendar_version
    ) x ORDER BY object_type,object_uuid;"""
    return psql(db,command=query).stdout.strip().splitlines()


def fixture_data(db):
    # Whitelist columns that predate migration 032; later additional fields are irrelevant.
    query="""SELECT jsonb_agg(jsonb_build_object('kind',kind,'uid',uid,'payload',payload)
         ORDER BY kind,uid)::text FROM (
    SELECT 'update_policy' kind,update_policy_uuid::text uid,
      jsonb_build_object('target',target_product_version_uuid,'level',effective_maintenance_level,
                         'mode',cadence_mode,'effective_at',effective_at,'rationale',rationale) payload
      FROM maintenance.update_policy
    UNION ALL SELECT 'sla_rule',sla_rule_uuid::text,
      jsonb_build_object('policy',update_policy_uuid,'clock',clock_code,
                         'duration',target_duration::text,'endpoint',endpoint_type)
      FROM maintenance.sla_rule
    UNION ALL SELECT 'sla_calendar_version',sla_calendar_version_uuid::text,
      jsonb_build_object('key',calendar_key,'version',version_no,
                         'weekly',weekly_schedule_payload,'timezone',timezone_name)
      FROM maintenance.sla_calendar_version
    ) z;"""
    return json.loads(scalar(db,query))


def schema_fingerprint(db):
    query="""WITH defs AS (
    SELECT 'column' kind, n.nspname||'.'||c.relname||'.'||a.attname key,
      concat_ws('|',a.attnum::text,format_type(a.atttypid,a.atttypmod),
         a.attnotnull::text,coalesce(pg_get_expr(d.adbin,d.adrelid),'')) def
    FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
    JOIN pg_namespace n ON n.oid=c.relnamespace
    LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
    WHERE n.nspname='maintenance' AND a.attnum>0 AND NOT a.attisdropped
    UNION ALL
    SELECT 'relation',n.nspname||'.'||c.relname,c.relkind::text
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='maintenance'
    UNION ALL
    SELECT 'constraint',co.conname||':'||co.conrelid::regclass::text,
      co.convalidated::text||'|'||pg_get_constraintdef(co.oid,true)
    FROM pg_constraint co JOIN pg_class c ON c.oid=co.conrelid
    JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='maintenance'
    UNION ALL
    SELECT 'index',i.indexrelid::regclass::text,
      i.indisvalid::text||'|'||pg_get_indexdef(i.indexrelid)
    FROM pg_index i JOIN pg_class c ON c.oid=i.indrelid
    JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='maintenance'
    UNION ALL
    SELECT 'trigger',c.relname||'.'||t.tgname,
      t.tgenabled::text||'|'||pg_get_triggerdef(t.oid,true)
    FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid
    JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='maintenance' AND NOT t.tgisinternal
    UNION ALL
    SELECT 'function',p.proname||'('||pg_get_function_identity_arguments(p.oid)||')',
      pg_get_functiondef(p.oid)
    FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='maintenance'
    )
    SELECT coalesce(jsonb_agg(jsonb_build_object('kind',kind,'key',key,'hash',md5(def))
                         ORDER BY kind,key),'[]'::jsonb)::text FROM defs;"""
    return json.loads(scalar(db,query))


def records(db):
    query="""SELECT object_type||':'||object_uuid::text||':'||migration_id||':'||reason_code
    FROM maintenance.temporal_contract_grandfathered_object
    ORDER BY object_type,object_uuid;"""
    return psql(db,command=query).stdout.strip().splitlines()


def main():
    controls = {"GITHUB_ACTIONS":"true",
                "GITHUB_REPOSITORY":"rogerio-raposo/observatorio-evidencias-saude",
                "PGHOST":"127.0.0.1","PGPORT":"5432","PGUSER":"postgres",
                "PGDATABASE":ADMIN}
    if any(os.getenv(k)!=v for k,v in controls.items()):
        raise RuntimeError("BLOCKED: exclusively disposable OES GitHub Actions service")
    if any(os.getenv(k) for k in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: externally supplied database")
    OUT.mkdir(exist_ok=True)
    (OUT/"checks.tsv").write_text("check\tresult\n",encoding="utf8")
    require(scalar(ADMIN,"SHOW server_version_num;").startswith("18"),"server_pg18")
    manifest=[s.strip() for s in MANIFEST.read_text(encoding="utf8").splitlines()
              if s.strip() and not s.lstrip().startswith("#")]
    require(len(manifest)==36 and len(set(manifest))==36,"manifest_36_unique")
    require(manifest[31]=="database/032_temporal_calibration_prerequisites.sql",
            "migration_032_entrypoint_pinned")
    sha=os.getenv("GITHUB_SHA","")
    require(re.fullmatch(r"[0-9a-f]{40}",sha) is not None,"pinned_commit")
    (OUT/"commit.txt").write_text(sha+"\n",encoding="utf8")
    (OUT/"fixture-sha256.txt").write_text(
        hashlib.sha256(FIXTURE.read_bytes()).hexdigest()+"\n",encoding="utf8")

    for path in manifest[:31]:
        psql(ADMIN,path=path)
    require(scalar(ADMIN,"SELECT to_regclass('maintenance.temporal_contract_grandfathered_object') IS NULL;")=="t",
            "grandfather_table_absent_before_032")
    psql(ADMIN,path=FIXTURE)
    expected={k+":"+v for k,v in UUIDS.items()}
    original=fixture_ids(ADMIN)
    require(set(original)==expected and len(original)==3,"three_existing_constraint_valid_rows")
    source_before=fixture_data(ADMIN)
    baseline_fingerprint=schema_fingerprint(ADMIN)
    (OUT/"baseline-source.json").write_text(json.dumps(source_before,indent=2),encoding="utf8")
    for name in ("base","success","rollback","preseed"):
        make_db(DBS[name],ADMIN)

    # Normal first-install path: 3 old rows should be carried into registry exactly.
    psql(DBS["success"],path=manifest[31])
    after=fixture_ids(DBS["success"])
    require(after==original,"preexisting_3_ids_preserved_on_032")
    require(fixture_data(DBS["success"])==source_before,
            "preexisting_3_source_values_preserved")
    rg=records(DBS["success"])
    wanted={k+":"+v+":032:pre_v01_existing_row" for k,v in UUIDS.items()}
    require(set(rg)==wanted and len(rg)==3,
            "grandfather_registry_3_exact_type_uuid_reason")
    require(scalar(DBS["success"],"""SELECT count(*) FROM
        maintenance.temporal_contract_grandfathered_object
        WHERE grandfathered_at IS NOT NULL
        AND migration_id='032' AND reason_code='pre_v01_existing_row';""")=="3",
            "grandfather_provenance_fields_populated")
    require(scalar(DBS["success"],"""SELECT count(*) FROM maintenance.contract_epoch
        WHERE contract_code='TEMPORAL_CALIBRATION_V01' AND schema_version='0.1'
          AND migration_id='032';""")=="1","032_structural_epoch_receipt_present")

    # Deliberate failure before internal COMMIT, using a copy of a seeded baseline.
    wrapper=Path(manifest[31]).read_text(encoding="utf8")
    require(len(re.findall(r"(?im)^\s*COMMIT\s*;\s*$",wrapper))==1,
            "032_internal_commit_boundary_present")
    sql=re.sub(r"(?im)^\s*COMMIT\s*;\s*$",
               "SELECT 1/0;\nCOMMIT;",wrapper,count=1)
    failure_file=ROOT / "database/.oes_ci_032_grandfather_abort.sql"
    failure_file.write_text(sql,encoding="utf8")
    result=psql(DBS["rollback"],path=failure_file,check=False)
    require(result.returncode!=0 and "division by zero" in result.stderr,
            "032_forced_precommit_error_seen")
    require(scalar(DBS["rollback"],"SELECT to_regclass('maintenance.temporal_contract_grandfathered_object') IS NULL;")=="t",
            "032_registry_creation_rolled_back")
    require(scalar(DBS["rollback"],"""SELECT count(*) FROM maintenance.contract_epoch
        WHERE contract_code='TEMPORAL_CALIBRATION_V01';""")=="0",
            "032_structural_epoch_rolled_back")
    require(fixture_data(DBS["rollback"])==source_before,
            "032_source_rows_preserved_through_rollback")
    require(schema_fingerprint(DBS["rollback"])==baseline_fingerprint,
            "032_rollback_schema_matches_preinstall")

    # Negative control: historical contract marker exists but no 032 registry.
    # The migration's 'first_install' logic MUST NOT invent grandfather rows.
    psql(DBS["preseed"],command="""INSERT INTO maintenance.contract_epoch
        (contract_code,schema_version,migration_id,effective_at)
        VALUES('TEMPORAL_CALIBRATION_V01','0.1','032',CURRENT_TIMESTAMP);""")
    psql(DBS["preseed"],path=manifest[31])
    require(scalar(DBS["preseed"],"""SELECT count(*) FROM
       maintenance.temporal_contract_grandfathered_object;""")=="0",
       "preexisting_epoch_marker_suppresses_grandfathering")
    require(fixture_data(DBS["preseed"])==source_before,
            "marker_negative_control_preserves_source_rows")

    summary={
      "status":"SYNTHETIC_032_GRANDFATHERING_BEHAVIOR_TESTED_ONLY",
      "source_commit":sha,
      "test_purpose":"grandfather mapping and transactional rollback in disposable PG18",
      "preexisting_fixture_rows":3,
      "registered_rows_on_first_install":len(rg),
      "registered_rows_when_epoch_marker_preexists":0,
      "precommit_failure_rolled_back":True,
      "source_rows_preserved_on_success_and_failure":True,
      "full_postconditions_approved":False,
      "main_catalog_reviewed_entries":0,
      "sql_executed_disposable_pg18":True,
      "sql_executed_neon":False,
      "neon_write_authorized":False,
      "scientific_data_used":False,
    }
    (OUT/"result.json").write_text(json.dumps(summary,indent=2),encoding="utf8")
    (OUT/"grandfather-rows.txt").write_text("\n".join(rg)+"\n",encoding="utf8")
    (OUT/"result.txt").write_text("SYNTHETIC_032_GRANDFATHERING_PASS_LIMITED\n",encoding="utf8")
    print("SYNTHETIC_032_GRANDFATHERING_PASS_LIMITED",flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"BLOCKED: {type(e).__name__}: {e}",file=sys.stderr)
        raise SystemExit(1)
