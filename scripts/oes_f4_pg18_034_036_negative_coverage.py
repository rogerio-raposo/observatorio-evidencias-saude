#!/usr/bin/env python3
"""Negative temporal behavior tests, solely on disposable PG18 CI databases.

All users, authorities, plans and measurement rows are fabricated.
This script is NOT a migration runner, reconciler, or authorization for Neon.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

OUT=Path("f4-pg18-temporal-negative-evidence")
ADMIN="oes_f4_temporal_neg_synthetic"
TEMPLATE="oes173schema"
CASES={
    "missing":"oes173missing",
    "conflict":"oes173conflict",
    "connectivity":"oes173connect",
    "opportunity":"oes173missingop",
    "guard034":"oes173guard034",
    "guard036":"oes173guard036",
    "late":"oes173late",
}
EP="dddddddd-dddd-4ddd-8ddd-000000000172"
OP="11111111-0000-4111-8111-000000000172"
SQL=["psql","-X","-q","-A","-t","-v","ON_ERROR_STOP=1"]
FIX=Path("tests/fixtures/f4-temporal-034-036/seed.sql")
MAN=Path("database/f4-neon-sandbox-schema-migration-manifest.txt")
AUTH_MARK="-- Artificial authority record to exercise logic; no person made an approval."

def assert_check(label,cond):
    if not cond: raise AssertionError("CHECK_FAILED "+label)
    with (OUT/"checks.tsv").open("a",encoding="utf8") as f:f.write(f"{label}\tPASS\n")
    print(f"{label}\tPASS",flush=True)

def invoke(db,*,statement=None,path=None,success=True):
    if db not in (ADMIN,TEMPLATE,*CASES.values()):
        raise AssertionError("BLOCKED: database outside synthetic allowlist")
    if (statement is None)==(path is None):
        raise AssertionError("ambiguous SQL invocation")
    args=SQL+["-d",db]+(["-c",statement] if statement is not None else ["-f",str(path)])
    p=subprocess.run(args,capture_output=True,text=True,timeout=85)
    if success and p.returncode!=0:
        raise AssertionError(f"SQL failure: {db}: {p.stderr[-1000:]}")
    return p

def value(db,statement):
    return invoke(db,statement=statement).stdout.strip()

def expect_error(name,db,stmt,substring):
    p=invoke(db,statement=stmt,success=False)
    assert_check(name,p.returncode!=0 and substring in p.stderr)
    with (OUT/"expected-errors.log").open("a",encoding="utf8") as f:
        f.write(name+"\n"+p.stderr[-500:]+"\n")

def make(db):
    invoke(ADMIN,statement=f"CREATE DATABASE {db} TEMPLATE {TEMPLATE};")

def fixture_variant(name,content):
    p=Path("tests/fixtures/f4-temporal-034-036")/(".oes_ci_"+name+".sql")
    p.write_text(content,encoding="utf8")
    return p

def preflight(db,instant="2030-01-01T12:00:00Z"):
    q=f"""SELECT jsonb_object_agg(check_code,check_status)::text FROM
    maintenance.temporal_activation_preflight('{EP}','{instant}'::timestamptz);"""
    return json.loads(value(db,q))

def status(db,instant="2030-01-01T12:00:00Z"):
    return value(db,f"SELECT maintenance.temporal_activation_preflight_state('{EP}','{instant}'::timestamptz);")

def authorize(db):
    invoke(db,statement=f"""UPDATE maintenance.temporal_observation_epoch
    SET epoch_status='authorized_non_normative'
    WHERE observation_epoch_uuid='{EP}';""")

def activate(db,started="2030-01-01T12:00:00Z"):
    invoke(db,statement=f"""UPDATE maintenance.temporal_observation_epoch
    SET epoch_status='active',started_at='{started}'
    WHERE observation_epoch_uuid='{EP}';""")

def trigger_state(db,rel,trigger):
    return value(db,f"""SELECT coalesce((SELECT t.tgenabled::text FROM pg_trigger t
    WHERE t.tgrelid='maintenance.{rel}'::regclass AND t.tgname='{trigger}'
      AND NOT t.tgisinternal),'ABSENT');""")

def main():
    required={"GITHUB_ACTIONS":"true",
        "GITHUB_REPOSITORY":"rogerio-raposo/observatorio-evidencias-saude",
        "PGHOST":"127.0.0.1","PGPORT":"5432",
        "PGUSER":"postgres","PGDATABASE":ADMIN}
    if any(os.environ.get(k)!=v for k,v in required.items()):
        raise RuntimeError("BLOCKED: CI-only PG18 destination required")
    if any(os.environ.get(k) for k in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: external connection settings")
    OUT.mkdir(exist_ok=True)
    (OUT/"checks.tsv").write_text("check\tresult\n",encoding="utf8")
    assert_check("server_postgresql18",value(ADMIN,"SHOW server_version_num;").startswith("18"))
    sha=os.environ.get("GITHUB_SHA","")
    assert_check("pinned_commit",re.fullmatch("[0-9a-f]{40}",sha) is not None)
    (OUT/"commit.txt").write_text(sha+"\n",encoding="utf8")
    files=[s.strip() for s in MAN.read_text().splitlines()
           if s.strip() and not s.lstrip().startswith("#")]
    assert_check("manifest_36_unique",len(files)==36 and len(set(files))==36)
    for script in files:invoke(ADMIN,path=script)
    assert_check("disposable_schema_001_to_036_installed",True)
    invoke(ADMIN,statement=f"CREATE DATABASE {TEMPLATE} TEMPLATE {ADMIN};")
    source=FIX.read_text(encoding="utf8")
    assert_check("known_authority_fixture_separator",
                 source.count(AUTH_MARK)==1 and source.strip().endswith("COMMIT;"))
    (OUT/"fixture-sha256.txt").write_text(hashlib.sha256(source.encode()).hexdigest()+"\n")
    for db in CASES.values():make(db)

    # Authority missing: never manufacture human authority; no synthetic row.
    without=source.split(AUTH_MARK)[0]+"\nCOMMIT;\n"
    invoke(CASES["missing"],path=fixture_variant("missing_authority",without))
    miss=preflight(CASES["missing"])
    assert_check("035_absent_authority_is_fail",
                 miss.get("AUTHORITY_STATE")=="FAIL" and status(CASES["missing"])=="FAIL")
    expect_error("033_authorization_rejects_missing_authority",
                 CASES["missing"],
                 f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='authorized_non_normative' WHERE observation_epoch_uuid='{EP}';",
                 "operational execution authority state is missing")

    # Conflicting decisions with equal decided_at: conflict rather than arbitrary winner.
    invoke(CASES["conflict"],path=fixture_variant("conflict_authority_base",source))
    second="""INSERT INTO maintenance.temporal_observation_authority(
        observation_authority_uuid,observation_plan_uuid,observation_epoch_uuid,
        authority_domain,decision,actor,actor_type,decision_artifact_uuid,decided_at)
        VALUES('abababab-abab-4bab-8bab-000000000173',
        'bbbbbbbb-bbbb-4bbb-8bbb-000000000172',
        'dddddddd-dddd-4ddd-8ddd-000000000172',
        'operational_execution','rejected','SYNTHETIC CONTRADICTORY NON-HUMAN',
        'human_reviewer','aaaaaaaa-aaaa-4aaa-8aaa-000000000172',
        '2026-06-01T00:00:00Z');"""
    invoke(CASES["conflict"],statement=second)
    assert_check("033_conflicting_authority_state_detected",
                 value(CASES["conflict"],
                       f"SELECT maintenance.temporal_observation_authority_state('{EP}','operational_execution','2030-01-01T12:00:00Z');")=="conflict")
    con=preflight(CASES["conflict"])
    assert_check("035_conflicting_authority_is_fail",
                 con.get("AUTHORITY_STATE")=="FAIL" and status(CASES["conflict"])=="FAIL")
    expect_error("033_authorization_rejects_conflicting_authority",
                 CASES["conflict"],
                 f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='authorized_non_normative' WHERE observation_epoch_uuid='{EP}';",
                 "operational execution authority state is conflict")

    # Required connectivity with frozen 'blocked' status: consistent at insertion.
    required_source="'included','manual',false,"
    required_status="'unverified','2026-01-01T00:00:00Z'"
    assert_check("fixture_has_connection_switches",
                 source.count(required_source)==1 and source.count(required_status)==1)
    blocked=source.replace(required_source,"'included','manual',true,").replace(
        required_status,"'blocked','2026-01-01T00:00:00Z'")
    invoke(CASES["connectivity"],path=fixture_variant("blocked_connection",blocked))
    bc=preflight(CASES["connectivity"])
    assert_check("035_blocked_required_connection_is_fail",
                 bc.get("RUNTIME_CONNECTIVITY")=="FAIL" and status(CASES["connectivity"])=="FAIL")
    expect_error("033_authorization_rejects_required_connection_blocked",
                 CASES["connectivity"],
                 f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='authorized_non_normative' WHERE observation_epoch_uuid='{EP}';",
                 "required runtime connectivity is not verified")

    # Incomplete materialization: remove the second opportunity from the fixture,
    # never bypass immutability to delete already frozen opportunities.
    begin=source.index("INSERT INTO maintenance.temporal_measurement_opportunity(")
    idx=source.index("'22222222-0000-4222-8222-000000000172'",begin)
    comma=source.rfind(",\n",begin,idx)
    end=source.index(");",idx)+2
    if comma<begin:raise AssertionError("unexpected opportunity fixture layout")
    truncated=source[:comma]+";"+source[end:]
    assert_check("second_opportunity_removed_from_fixture",
                 truncated.count("'22222222-0000-4222-8222-000000000172'")==0)
    invoke(CASES["opportunity"],path=fixture_variant("one_opportunity",truncated))
    incomplete=preflight(CASES["opportunity"])
    assert_check("035_incomplete_opportunity_set_is_fail",
                 incomplete.get("OPPORTUNITY_SET")=="FAIL" and status(CASES["opportunity"])=="FAIL")
    expect_error("033_authorization_rejects_unmaterialized_opportunity",
                 CASES["opportunity"],
                 f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='authorized_non_normative' WHERE observation_epoch_uuid='{EP}';",
                 "frozen opportunity set is not fully materialized")

    # Existing guard can be disabled by a privileged operator. This negative
    # control must not be interpreted as a permitted administrative workaround.
    invoke(CASES["guard034"],path=fixture_variant("disabled_034",source))
    authorize(CASES["guard034"])
    guard034="tr_temporal_epoch_activation_chronology"
    rel034="temporal_observation_epoch"
    assert_check("034_trigger_enabled_before_negative_control",
                 trigger_state(CASES["guard034"],rel034,guard034)=="O")
    bad_start="2030-01-02T00:00:00Z" # equal to first opportunity
    expect_error("034_enabled_guard_rejects_equal_first_opportunity",
                 CASES["guard034"],
                 f"UPDATE maintenance.temporal_observation_epoch SET epoch_status='active',started_at='{bad_start}' WHERE observation_epoch_uuid='{EP}';",
                 "must precede first opportunity")
    invoke(CASES["guard034"],statement=
           f"ALTER TABLE maintenance.{rel034} DISABLE TRIGGER {guard034};")
    assert_check("034_trigger_disabled_in_disposable_negative_control",
                 trigger_state(CASES["guard034"],rel034,guard034)=="D")
    activate(CASES["guard034"],bad_start)
    assert_check("034_unsafe_activation_possible_if_guard_disabled",
                 value(CASES["guard034"],
                       f"SELECT epoch_status FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='{EP}';")=="active")
    invoke(CASES["guard034"],statement=
           f"ALTER TABLE maintenance.{rel034} ENABLE TRIGGER {guard034};")
    assert_check("034_guard_reenabled_does_not_retroactively_validate_unsafe_epoch",
                 trigger_state(CASES["guard034"],rel034,guard034)=="O" and
                 value(CASES["guard034"],f"SELECT epoch_status FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='{EP}';")=="active")

    invoke(CASES["guard036"],path=fixture_variant("disabled_036",source))
    authorize(CASES["guard036"]);activate(CASES["guard036"])
    event="""INSERT INTO maintenance.temporal_measurement_event(
      measurement_event_uuid,measurement_opportunity_uuid,attempt_no,
      execution_status,execution_started_at,execution_completed_at,
      novelty_state,raw_result_count_status,new_identifier_count,
      failure_attribution,operator,actor_type
    ) VALUES(
      'edededed-eded-4ded-8ded-000000000173',
      '11111111-0000-4111-8111-000000000172',1,'completed',
      '2030-01-02T01:00:00Z','2030-01-02T01:05:00Z',
      'zero_new','not_applicable',0,'not_applicable',
      'SYNTHETIC TEST ONLY','ai_system');"""
    trig036="tr_temporal_event_first_measurement_semantics"
    rel036="temporal_measurement_event"
    assert_check("036_trigger_enabled_before_negative_control",
                 trigger_state(CASES["guard036"],rel036,trig036)=="O")
    expect_error("036_enabled_guard_rejects_first_zero_new",
                 CASES["guard036"],event,
                 "first completed event for epoch source requires novelty_state=not_applicable")
    invoke(CASES["guard036"],statement=
           f"ALTER TABLE maintenance.{rel036} DISABLE TRIGGER {trig036};")
    assert_check("036_trigger_disabled_in_disposable_negative_control",
                 trigger_state(CASES["guard036"],rel036,trig036)=="D")
    invoke(CASES["guard036"],statement=event)
    assert_check("036_unsafe_first_event_possible_if_guard_disabled",
                 value(CASES["guard036"],
                       "SELECT count(*) FROM maintenance.temporal_measurement_event;")=="1")
    invoke(CASES["guard036"],statement=
           f"ALTER TABLE maintenance.{rel036} ENABLE TRIGGER {trig036};")
    assert_check("036_reenabled_guard_cannot_repair_committed_invalid_event",
                 trigger_state(CASES["guard036"],rel036,trig036)=="O" and
                 value(CASES["guard036"],
                       "SELECT novelty_state FROM maintenance.temporal_measurement_event;")=="zero_new")

    # A deviation recorded after started_at is not an activation-time blocker
    # under current 034 chronology. Future authority/operational meaning is NOT implied.
    invoke(CASES["late"],path=fixture_variant("later_deviation",source))
    authorize(CASES["late"])
    invoke(CASES["late"],statement=f"""INSERT INTO maintenance.temporal_observation_deviation(
      deviation_uuid,observation_epoch_uuid,deviation_type,materiality,description,
      recorded_by,recorded_at) VALUES(
      'cbcbcbcb-cbcb-4bcb-8bcb-000000000173','{EP}',
      'authority_change','invalidating','Synthetic late deviation','CI',
      '2030-01-01T13:00:00Z');""")
    activate(CASES["late"])
    assert_check("034_later_deviation_not_blocking_activation_at_started_at",
                 value(CASES["late"],f"SELECT epoch_status FROM maintenance.temporal_observation_epoch WHERE observation_epoch_uuid='{EP}';")=="active")

    report={
        "state":"SYNTHETIC_NEGATIVE_COVERAGE_ONLY",
        "commit":sha,
        "scenario_names":list(CASES.keys()),
        "preflight_missing_authority":miss,
        "preflight_conflicting_authority":con,
        "preflight_blocked_connection":bc,
        "preflight_incomplete_opportunity_set":incomplete,
        "privileged_trigger_disable_can_bypass_guards":True,
        "late_deviation_behavior_observed":True,
        "human_authority_received":False,
        "migrations_tested_in_pg18_disposable":36,
        "neon_accessed":False,
        "catalog_postconditions_approved":0,
        "operational_runner_approved":False,
        "automatic_reconciliation_allowed":False,
    }
    (OUT/"report.json").write_text(json.dumps(report,indent=2,sort_keys=True),encoding="utf8")
    (OUT/"result.txt").write_text("PG18_TEMPORAL_NEGATIVE_COVERAGE_ONLY\n",encoding="utf8")
    print("PG18_TEMPORAL_NEGATIVE_COVERAGE_ONLY",flush=True)

if __name__=="__main__":
    try:main()
    except Exception as e:
        print(f"BLOCKED: {type(e).__name__}: {e}",file=sys.stderr)
        raise SystemExit(1)
