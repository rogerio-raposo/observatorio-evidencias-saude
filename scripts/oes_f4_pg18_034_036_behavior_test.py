#!/usr/bin/env python3
"""Only synthetic behavioral assertions for OES temporal SQL 034-036 on disposable PG18.

NOT a migration runner or an authorization for live chronology, measurement, or Neon.
"""
import json
import os
from pathlib import Path
import re
import subprocess
import sys

OUT=Path("f4-pg18-temporal-behavior-evidence")
DB="oes_f4_temporal_synthetic"
PSQL=["psql","-X","-q","-A","-t","-v","ON_ERROR_STOP=1"]
EP="dddddddd-dddd-4ddd-8ddd-000000000172"
OP1="11111111-0000-4111-8111-000000000172"
OP2="22222222-0000-4222-8222-000000000172"


def check(name, condition):
    if not condition: raise AssertionError("CHECK_FAILED "+name)
    with (OUT/"checks.tsv").open("a",encoding="utf8") as f:
        f.write(name+"\tPASS\n")
    print(name+"\tPASS",flush=True)


def db(command=None, *, sqlfile=None, expected=True):
    if (command is None)==(sqlfile is None):
        raise AssertionError("ambiguous psql invocation")
    argv=PSQL+(["-c",command] if command is not None else ["-f",str(sqlfile)])
    p=subprocess.run(argv,capture_output=True,text=True,timeout=85)
    if expected and p.returncode!=0:
        raise AssertionError("unexpected SQL failure "+p.stderr[-1000:])
    return p


def value(s): return db(s).stdout.strip()


def reject(name,statement,diagnostic):
    p=db(statement,expected=False)
    check(name,p.returncode!=0 and diagnostic in p.stderr)
    with (OUT/"negative-controls.log").open("a",encoding="utf8") as f:
        f.write(name+"\n"+p.stderr[-600:]+"\n")


def trigger(name,relation,func,events):
    q=f"""SELECT (t.tgenabled='O' AND t.tgfoid::regprocedure::text LIKE 'maintenance.{func}(%'
              AND position('{events}' in pg_get_triggerdef(t.oid))>0)::text
      FROM pg_trigger t WHERE t.tgrelid='maintenance.{relation}'::regclass
      AND t.tgname='{name}' AND NOT t.tgisinternal;"""
    return value(q)=="true"


def preflight(at):
    q=f"""SELECT jsonb_object_agg(check_code,check_status)::text
      FROM maintenance.temporal_activation_preflight('{EP}','{at}'::timestamptz);"""
    return json.loads(value(q))


def event(uid,opp,novelty,new_count,failure="not_applicable"):
    count="NULL" if new_count is None else str(new_count)
    sql=f"""INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,
      execution_status,execution_started_at,execution_completed_at,
      novelty_state,raw_result_count_status,new_identifier_count,
      failure_attribution,operator,actor_type
    ) VALUES (
      '{uid}','{opp}',1,'completed',
      '2030-01-02T01:00:00Z','2030-01-02T01:05:00Z',
      '{novelty}','not_applicable',{count},'{failure}',
      'SYNTHETIC CI ONLY','ai_system'
    );"""
    return sql


def main():
    required={
        "GITHUB_ACTIONS":"true",
        "GITHUB_REPOSITORY":"rogerio-raposo/observatorio-evidencias-saude",
        "PGHOST":"127.0.0.1","PGPORT":"5432","PGUSER":"postgres",
        "PGDATABASE":DB
    }
    if any(os.getenv(k)!=v for k,v in required.items()):
        raise RuntimeError("BLOCKED: fixed disposable PG18 Actions destination only")
    if any(os.getenv(k) for k in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: external DB configuration")
    OUT.mkdir(exist_ok=True)
    (OUT/"checks.tsv").write_text("check\tresult\n",encoding="utf8")
    check("server_pg18",value("SHOW server_version_num;").startswith("18"))
    sha=os.getenv("GITHUB_SHA","")
    check("commit_pinned",re.fullmatch("[0-9a-f]{40}",sha) is not None)
    (OUT/"commit.txt").write_text(sha+"\n",encoding="utf8")
    manifest=[line.strip() for line in Path("database/f4-neon-sandbox-schema-migration-manifest.txt").read_text().splitlines()
              if line.strip() and not line.lstrip().startswith("#")]
    check("migration_manifest_36",len(manifest)==36 and len(set(manifest))==36)
    check("target_migrations_034_035_036",
          all(manifest[i-1].startswith(f"database/{i:03d}_") for i in (34,35,36)))
    for mig in manifest: db(sqlfile=mig)
    check("36_schema_migrations_installed_disposable",True)
    db(sqlfile="tests/fixtures/f4-temporal-034-036/seed.sql")
    check("synthetic_plan_epoch_two_opportunities",
          value(f"""SELECT (SELECT count(*) FROM maintenance.temporal_measurement_opportunity o
             JOIN maintenance.temporal_observation_epoch_source es USING(epoch_source_uuid)
             WHERE es.observation_epoch_uuid='{EP}')::text""")=="2")

    check("034_enabled_trigger_bound_to_function",
          trigger("tr_temporal_epoch_activation_chronology","temporal_observation_epoch",
                  "assert_temporal_epoch_activation_chronology","BEFORE UPDATE"))
    check("036_enabled_trigger_bound_to_function",
          trigger("tr_temporal_event_first_measurement_semantics","temporal_measurement_event",
                  "assert_temporal_first_measurement_semantics","BEFORE INSERT"))
    check("035_preflight_two_functions_installed",
          value("""SELECT count(*)::text FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
            WHERE n.nspname='maintenance' AND p.proname IN (
              'temporal_activation_preflight','temporal_activation_preflight_state');""")=="2")

    missing="99999999-9999-4999-8999-000000000172"
    check("035_missing_epoch_is_fail",
          value(f"SELECT maintenance.temporal_activation_preflight_state('{missing}');")=="FAIL")
    check("035_missing_epoch_code",preflight_missing(missing))
    check("035_draft_epoch_is_fail",
          value(f"SELECT maintenance.temporal_activation_preflight_state('{EP}','2030-01-01T12:00:00Z');")=="FAIL")

    # The seeded fake authority record is not human approval of this project.
    db(f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='authorized_non_normative' WHERE observation_epoch_uuid='{EP}';")
    check("epoch_authorized_with_fake_ci_record_only",
          value(f"SELECT epoch_status FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='{EP}';")=="authorized_non_normative")
    st_wait=preflight("2029-12-31T12:00:00Z")
    st_pass=preflight("2030-01-01T12:00:00Z")
    st_fail=preflight("2030-01-02T00:00:00Z")
    (OUT/"preflight.json").write_text(json.dumps(
        {"wait":st_wait,"pass":st_pass,"fail":st_fail},indent=2,sort_keys=True),encoding="utf8")
    check("035_before_window_is_wait",
          st_wait.get("ACTIVATION_WINDOW")=="WAIT"
          and value(f"SELECT maintenance.temporal_activation_preflight_state('{EP}','2029-12-31T12:00:00Z');")=="WAIT")
    check("035_inside_window_is_pass",
          st_pass.get("ACTIVATION_WINDOW")=="PASS" and
          all(v not in ("WAIT","FAIL") for v in st_pass.values()) and
          value(f"SELECT maintenance.temporal_activation_preflight_state('{EP}','2030-01-01T12:00:00Z');")=="PASS")
    check("035_at_first_opportunity_is_fail",
          st_fail.get("ACTIVATION_WINDOW")=="FAIL" and
          value(f"SELECT maintenance.temporal_activation_preflight_state('{EP}','2030-01-02T00:00:00Z');")=="FAIL")
    check("035_read_only_no_event_created",
          value("SELECT count(*) FROM maintenance.temporal_measurement_event;")=="0")

    reject("034_missing_started_at_blocks_activation",
           f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='active' WHERE observation_epoch_uuid='{EP}';",
           "active epoch requires started_at")
    reject("034_started_at_not_before_first_opportunity",
           f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='active',started_at='2030-01-02T00:00:00Z' WHERE observation_epoch_uuid='{EP}';",
           "must precede first opportunity")
    check("034_negative_controls_leave_epoch_authorized",
          value(f"SELECT epoch_status FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='{EP}';")=="authorized_non_normative")
    # A material deviation in a transaction should block activation; the
    # failed transaction rolls back so the later positive path remains isolated.
    reject("034_material_deviation_blocks_activation",
           f"""BEGIN;
               INSERT INTO maintenance.temporal_observation_deviation(
                 deviation_uuid,observation_epoch_uuid,deviation_type,materiality,description,recorded_by,recorded_at)
               VALUES('88888888-8888-4888-8888-000000000172','{EP}',
                 'authority_change','invalidating','SYNTHETIC CI ONLY','ci_only','2026-07-01T00:00:00Z');
               UPDATE maintenance.temporal_observation_epoch SET epoch_status='active',
                 started_at='2030-01-01T12:00:00Z' WHERE observation_epoch_uuid='{EP}';
               COMMIT;""",
           "material deviation blocks epoch activation")
    check("034_failed_transaction_did_not_leave_deviation",
          value("SELECT count(*) FROM maintenance.temporal_observation_deviation;")=="0")

    db(f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='active',started_at='2030-01-01T12:00:00Z' WHERE observation_epoch_uuid='{EP}';")
    check("034_valid_synthetic_chronology_allows_activation",
          value(f"SELECT epoch_status FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='{EP}';")=="active")

    reject("036_first_completed_rejects_zero_new",
           event("33333333-0000-4333-8333-000000000172",OP1,"zero_new",0),
           "first completed event for epoch source requires novelty_state=not_applicable")
    reject("036_first_completed_rejects_nonnull_new_count",
           event("44444444-0000-4444-8444-000000000172",OP1,"not_applicable",0),
           "first completed event for epoch source requires new_identifier_count NULL")
    db(event("55555555-0000-4555-8555-000000000172",OP1,"not_applicable",None))
    check("036_first_completed_correct_fields_allowed",
          value("SELECT count(*) FROM maintenance.temporal_measurement_event;")=="1")
    reject("036_second_completed_rejects_not_applicable",
           event("66666666-0000-4666-8666-000000000172",OP2,"not_applicable",None),
           "subsequent completed event for epoch source cannot use novelty_state=not_applicable")
    reject("036_completed_requires_not_applicable_failure_attribution",
           event("77777777-0000-4777-8777-000000000172",OP2,"zero_new",0,"unknown"),
           "completed event requires failure_attribution=not_applicable")
    db(event("88888888-0000-4888-8888-000000000173",OP2,"zero_new",0))
    check("036_second_completed_zero_new_allowed",
          value("SELECT count(*) FROM maintenance.temporal_measurement_event;")=="2")
    check("036_correct_outcomes_in_source_order",
          value("SELECT string_agg(novelty_state,',' ORDER BY execution_started_at,measurement_event_uuid) FROM maintenance.temporal_measurement_event;") in
          ("not_applicable,zero_new","zero_new,not_applicable"))
    # No real facts were inserted: all IDs and sources are artificial.
    report={"status":"SYNTHETIC_TEMPORAL_034_036_BEHAVIOR_PASS_LIMITED",
      "commit":sha,"schema_migrations_applied_in_disposable_ci":36,
      "sample_epoch_count":1,"sample_opportunity_count":2,
      "sample_completed_event_count":2,"synthetic_fake_authority_not_human_approval":True,
      "postconditions_validated":0,"ledger_operational":False,
      "migration_replay_authorized":False,"neon_accessed":False,"scientific_data_used":False}
    (OUT/"report.json").write_text(json.dumps(report,indent=2),encoding="utf8")
    (OUT/"result.txt").write_text("SYNTHETIC_TEMPORAL_034_036_BEHAVIOR_PASS_LIMITED\n",encoding="utf8")
    print("SYNTHETIC_TEMPORAL_034_036_BEHAVIOR_PASS_LIMITED",flush=True)


def preflight_missing(epoch):
    d=value(f"""SELECT string_agg(check_code||':'||check_status,',' ORDER BY check_code)
          FROM maintenance.temporal_activation_preflight('{epoch}');""")
    return d=="EPOCH_EXISTS:FAIL"


if __name__=="__main__":
    try: main()
    except Exception as e:
        print(f"BLOCKED: {type(e).__name__}: {e}",file=sys.stderr)
        sys.exit(1)
