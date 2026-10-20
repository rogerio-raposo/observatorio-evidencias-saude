#!/usr/bin/env python3
"""Disposable GitHub CI-only PG18 privilege and transactional DDL audit probe.

Never a Neon migrator or production DDL auditor. No connections other than the
fixed local synthetic PostgreSQL service; all roles and objects are artificial.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd()
OUT = ROOT / "f4-pg18-acl-ddl-evidence"
DB = "oes_f4_acl_ddl_synthetic"
PSQL = ["psql", "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1"]
MANIFEST = ROOT / "database/f4-neon-sandbox-schema-migration-manifest.txt"

def require(ok, label):
    if not ok:
        raise AssertionError("CHECK_FAILED " + label)
    print(label + "\tPASS",flush=True)
    with (OUT/"checks.tsv").open("a",encoding="utf8") as f:
        f.write(label + "\tPASS\n")

def sql(text, success=True):
    p = subprocess.run(PSQL + ["-c",text],capture_output=True,text=True,timeout=30)
    if success and p.returncode:
        raise AssertionError("Unexpected SQL failure: " + p.stderr[-700:])
    return p

def file_sql(path):
    p=subprocess.run(PSQL+["-f",str(path)],capture_output=True,text=True,timeout=80)
    if p.returncode:
        raise AssertionError("Migration install failure: " + p.stderr[-700:])

def val(text):
    return sql(text).stdout.strip()

def deny(label,statement):
    result=sql(statement,False)
    require(result.returncode!=0 and bool(result.stderr.strip()),label)
    with (OUT/"expected-denials.log").open("a",encoding="utf8") as f:
        f.write(label+"\n"+result.stderr[-600:]+"\n")

def trigger_state(tablename,trigger):
    return val("SELECT tgenabled::text FROM pg_trigger "
      f"WHERE tgrelid='maintenance.{tablename}'::regclass AND tgname='{trigger}';")

def function_sha(function_name):
    definition=val(f"SELECT pg_get_functiondef('{function_name}'::regprocedure);")
    return hashlib.sha256(definition.encode()).hexdigest()

def audit_count():
    return int(val("SELECT count(*) FROM oes_ci_ddl_audit.ddl_events;"))

def main():
    allow={
       "GITHUB_ACTIONS":"true",
       "GITHUB_REPOSITORY":"rogerio-raposo/observatorio-evidencias-saude",
       "PGHOST":"127.0.0.1","PGPORT":"5432","PGUSER":"postgres","PGDATABASE":DB,
    }
    if any(os.environ.get(k)!=v for k,v in allow.items()) or any(
        os.environ.get(k) for k in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: disposable OES PG18 CI destination only")
    OUT.mkdir(exist_ok=True)
    (OUT/"checks.tsv").write_text("check\tresult\n",encoding="utf8")
    require(val("SHOW server_version_num;").startswith("18"),"server_pg18")
    commit=os.environ.get("GITHUB_SHA","")
    require(bool(re.fullmatch(r"[0-9a-f]{40}",commit)),"fixed_commit")
    (OUT/"commit.txt").write_text(commit+"\n",encoding="utf8")
    lines=[s.strip() for s in MANIFEST.read_text(encoding="utf8").splitlines()
           if s.strip() and not s.lstrip().startswith("#")]
    require(len(lines)==36 and len(set(lines))==36,"manifest_36_unique")
    for f in lines: file_sql(ROOT/f)
    require(trigger_state("temporal_observation_epoch",
                          "tr_temporal_epoch_activation_chronology")=="O",
            "034_trigger_enabled_after_disposable_install")
    require(trigger_state("temporal_measurement_event",
                          "tr_temporal_event_first_measurement_semantics")=="O",
            "036_trigger_enabled_after_disposable_install")
    fun34="maintenance.assert_temporal_epoch_activation_chronology()"
    fun35="maintenance.temporal_activation_preflight(uuid,timestamp with time zone)"
    fun36="maintenance.assert_temporal_first_measurement_semantics()"
    # Before privilege tests: persist fingerprints of functions that must not change.
    before={key:function_sha(key) for key in (fun34,fun35,fun36)}
    require(len(before)==3 and all(before.values()),"original_guard_function_fingerprints")

    sql("""
    CREATE ROLE oes_ci_schema_owner NOLOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB NOREPLICATION;
    CREATE ROLE oes_ci_runtime NOLOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB NOREPLICATION;
    CREATE ROLE oes_ci_migrator NOLOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB NOREPLICATION;
    CREATE SCHEMA oes_ci_role_test AUTHORIZATION oes_ci_schema_owner;
    CREATE TABLE oes_ci_role_test.probe (id integer PRIMARY KEY,label text NOT NULL);
    ALTER TABLE oes_ci_role_test.probe OWNER TO oes_ci_schema_owner;
    GRANT USAGE ON SCHEMA oes_ci_role_test TO oes_ci_runtime,oes_ci_migrator;
    GRANT SELECT,INSERT ON oes_ci_role_test.probe TO oes_ci_runtime;
    GRANT SELECT ON oes_ci_role_test.probe TO oes_ci_migrator;
    GRANT USAGE ON SCHEMA maintenance TO oes_ci_runtime,oes_ci_migrator;
    GRANT SELECT ON maintenance.temporal_observation_epoch,
                    maintenance.temporal_measurement_event
             TO oes_ci_runtime,oes_ci_migrator;
    """)
    require(val("""SELECT count(*) FROM pg_roles WHERE rolname IN
              ('oes_ci_schema_owner','oes_ci_runtime','oes_ci_migrator')
              AND NOT rolcanlogin AND NOT rolsuper AND NOT rolcreaterole AND NOT rolcreatedb;""")=="3",
            "all_three_roles_nonlogin_nonsuperuser")
    require(val("""SELECT pg_has_role('oes_ci_runtime','oes_ci_schema_owner','MEMBER')::text
               ||','||pg_has_role('oes_ci_migrator','oes_ci_schema_owner','MEMBER')::text;""")=="false,false",
            "runtime_and_migrator_not_schema_owner_members")
    require(val("""SELECT has_schema_privilege('oes_ci_runtime','maintenance','CREATE')::text
      ||','||has_schema_privilege('oes_ci_migrator','maintenance','CREATE')::text;""")=="false,false",
            "no_create_in_maintenance_schema")
    require(val("""SELECT has_table_privilege('oes_ci_runtime',
      'maintenance.temporal_observation_epoch','SELECT')::text;""")=="true",
            "explicit_read_only_grant_for_runtime")
    require(val("""SELECT has_table_privilege('oes_ci_migrator',
      'maintenance.temporal_measurement_event','SELECT')::text;""")=="true",
            "explicit_read_only_grant_for_migrator")
    require(val("""SET ROLE oes_ci_runtime;
      SELECT current_user||':'||count(*) FROM maintenance.temporal_observation_epoch;""")
      =="oes_ci_runtime:0","runtime_can_read_without_owner_capabilities")
    sql("""SET ROLE oes_ci_runtime;
      INSERT INTO oes_ci_role_test.probe(id,label) VALUES(1,'synthetic runtime insert');""")
    require(val("""SET ROLE oes_ci_migrator;
      SELECT label FROM oes_ci_role_test.probe WHERE id=1;""")
      =="synthetic runtime insert","grant_scoped_runtime_insert_and_migrator_select")

    # Strong negative controls on *actual* temporal schema objects.
    deny("runtime_cannot_disable_actual_034_trigger",
         """SET ROLE oes_ci_runtime;
           ALTER TABLE maintenance.temporal_observation_epoch
           DISABLE TRIGGER tr_temporal_epoch_activation_chronology;""")
    deny("migrator_cannot_disable_actual_036_trigger",
         """SET ROLE oes_ci_migrator;
           ALTER TABLE maintenance.temporal_measurement_event
           DISABLE TRIGGER tr_temporal_event_first_measurement_semantics;""")
    deny("schema_owner_of_sandbox_cannot_disable_actual_034",
         """SET ROLE oes_ci_schema_owner;
           ALTER TABLE maintenance.temporal_observation_epoch
           DISABLE TRIGGER tr_temporal_epoch_activation_chronology;""")
    deny("runtime_cannot_own_or_replace_034_function",
         """SET ROLE oes_ci_runtime;
           CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_activation_chronology()
           RETURNS trigger LANGUAGE plpgsql AS $ci$BEGIN RETURN NEW; END;$ci$;""")
    deny("migrator_cannot_reassign_035_function_owner",
         """SET ROLE oes_ci_migrator;
           ALTER FUNCTION maintenance.temporal_activation_preflight(uuid,timestamptz)
           OWNER TO oes_ci_migrator;""")
    deny("runtime_cannot_disable_synthetic_owner_table_trigger",
         """SET ROLE oes_ci_runtime;
           ALTER TABLE oes_ci_role_test.probe DISABLE TRIGGER ALL;""")
    deny("migrator_cannot_create_in_maintenance_schema",
         """SET ROLE oes_ci_migrator;
           CREATE TABLE maintenance.synthetic_forbidden_ci_only (id integer);""")
    require(val("SELECT (to_regclass('maintenance.synthetic_forbidden_ci_only') IS NULL)::text;")=="true",
            "forbidden_maintenance_table_not_created")
    require(trigger_state("temporal_observation_epoch",
                          "tr_temporal_epoch_activation_chronology")=="O",
            "034_trigger_still_enabled_after_denials")
    require(trigger_state("temporal_measurement_event",
                          "tr_temporal_event_first_measurement_semantics")=="O",
            "036_trigger_still_enabled_after_denials")
    require(before=={key:function_sha(key) for key in before},
            "actual_034_035_036_functions_unchanged_after_denials")

    # A privileged role can alter an OWNED table. The ownership boundary is
    # the real control; the schema owner needs *less* power than postgres.
    sql("""SET ROLE oes_ci_schema_owner;
      ALTER TABLE oes_ci_role_test.probe ADD COLUMN owner_marker text;""")
    require(val("""SELECT count(*) FROM information_schema.columns WHERE
      table_schema='oes_ci_role_test' AND table_name='probe'
      AND column_name='owner_marker';""")=="1","owner_can_alter_its_own_synthetic_table")
    deny("runtime_cannot_change_ownertable",
         """SET ROLE oes_ci_runtime;
            ALTER TABLE oes_ci_role_test.probe ADD COLUMN unauthorized_ci integer;""")

    # Transaction-bound audit prototype. It is NOT independent or immutable:
    # a superuser can disable/drop it, and rolled-back DDL has no durable row.
    sql("""
    CREATE SCHEMA oes_ci_ddl_audit;
    REVOKE ALL ON SCHEMA oes_ci_ddl_audit FROM PUBLIC;
    CREATE TABLE oes_ci_ddl_audit.ddl_events(
      event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
      event_at timestamptz NOT NULL DEFAULT clock_timestamp(),
      command_tag text NOT NULL,
      schema_name text,
      object_identity text,
      session_actor text NOT NULL,
      role_setting text
    );
    REVOKE ALL ON oes_ci_ddl_audit.ddl_events FROM PUBLIC;
    CREATE OR REPLACE FUNCTION oes_ci_ddl_audit.record_ddl_ci()
    RETURNS event_trigger LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, oes_ci_ddl_audit
    AS $ci$
    BEGIN
      INSERT INTO oes_ci_ddl_audit.ddl_events(
         command_tag,schema_name,object_identity,session_actor,role_setting)
      SELECT command_tag,schema_name,object_identity,session_user,
             current_setting('role',true)
      FROM pg_event_trigger_ddl_commands()
      WHERE command_tag='ALTER TABLE';
    END;
    $ci$;
    CREATE EVENT TRIGGER oes_ci_ddl_observer
      ON ddl_command_end WHEN TAG IN ('ALTER TABLE')
      EXECUTE FUNCTION oes_ci_ddl_audit.record_ddl_ci();
    """)
    require(audit_count()==0,"new_transaction_bound_audit_starts_empty")
    require(val("""SELECT has_table_privilege('oes_ci_runtime',
          'oes_ci_ddl_audit.ddl_events','SELECT')::text
        ||','||has_table_privilege('oes_ci_migrator',
          'oes_ci_ddl_audit.ddl_events','INSERT')::text;""")=="false,false",
            "no_runtime_or_migrator_access_to_audit_table")
    # Privileged action on genuine 034 guard, on synthetic disposable CI DB.
    sql("""ALTER TABLE maintenance.temporal_observation_epoch
        DISABLE TRIGGER tr_temporal_epoch_activation_chronology;""")
    require(trigger_state("temporal_observation_epoch",
                          "tr_temporal_epoch_activation_chronology")=="D",
            "privileged_superuser_can_disable_actual_034_guard")
    require(audit_count()==1,"in_database_audit_records_committed_disable_ddl")
    sql("""ALTER TABLE maintenance.temporal_observation_epoch
        ENABLE TRIGGER tr_temporal_epoch_activation_chronology;""")
    require(trigger_state("temporal_observation_epoch",
                          "tr_temporal_epoch_activation_chronology")=="O",
            "privileged_superuser_reenables_actual_034_guard")
    require(audit_count()==2,"in_database_audit_records_committed_enable_ddl")
    require(val("""SELECT count(*) FROM oes_ci_ddl_audit.ddl_events
      WHERE object_identity='maintenance.temporal_observation_epoch'
        AND command_tag='ALTER TABLE';""")=="2",
            "audit_identifies_actual_034_table")

    # Demonstrate critical limit: audit rows are part of same transaction as
    # DDL; ROLLBACK erases both. Do not claim this is a durable external trail.
    sql("""BEGIN;
        ALTER TABLE maintenance.temporal_observation_epoch
        DISABLE TRIGGER tr_temporal_epoch_activation_chronology;
        ROLLBACK;""")
    require(trigger_state("temporal_observation_epoch",
                          "tr_temporal_epoch_activation_chronology")=="O",
            "rollback_restores_trigger_state")
    require(audit_count()==2,"in_database_audit_not_durable_across_rollback")
    deny("runtime_cannot_disable_event_trigger",
         """SET ROLE oes_ci_runtime;
           ALTER EVENT TRIGGER oes_ci_ddl_observer DISABLE;""")
    deny("migrator_cannot_drop_event_trigger",
         """SET ROLE oes_ci_migrator;
           DROP EVENT TRIGGER oes_ci_ddl_observer;""")
    require(val("""SELECT evtenabled::text FROM pg_event_trigger
      WHERE evtname='oes_ci_ddl_observer';""")=="O",
            "audit_event_trigger_remains_enabled")
    audit_rows=sql("""SELECT row_to_json(x) FROM (
       SELECT event_id,command_tag,schema_name,object_identity,session_actor,role_setting
       FROM oes_ci_ddl_audit.ddl_events ORDER BY event_id) x;""").stdout.splitlines()
    (OUT/"audit-events.json").write_text(json.dumps(
        [json.loads(x) for x in audit_rows],indent=2),encoding="utf8")
    (OUT/"function-fingerprints.json").write_text(
        json.dumps({"before":before,"after":{k:function_sha(k) for k in before}},
                   indent=2,sort_keys=True),encoding="utf8")
    result={
      "status":"PG18_SYNTHETIC_ROLE_DENIAL_AND_INDB_AUDIT_PROOF_ONLY",
      "source_sha":commit,"server_version":val("SHOW server_version;"),
      "role_count":3,"audit_committed_ddl_count":audit_count(),
      "in_db_audit_is_transactional_not_external":True,
      "audit_cannot_prove_superuser_unobservability_absent":True,
      "least_privilege_neon_verified":False,"tls_neon_verified":False,
      "external_immutable_ddl_audit_configured":False,
      "backup_restore_independent":False,
      "catalog_postconditions_approved":0,
      "neon_accessed":False,"neon_write_authorized":False,
      "operational_roles_or_ddl_audit_authorized":False
    }
    (OUT/"result.json").write_text(json.dumps(result,indent=2,sort_keys=True),encoding="utf8")
    (OUT/"result.txt").write_text("PG18_ACL_DDL_AUDIT_SYNTHETIC_PASS_LIMITED\n",encoding="utf8")
    print("PG18_ACL_DDL_AUDIT_SYNTHETIC_PASS_LIMITED",flush=True)

if __name__=="__main__":
    try:main()
    except Exception as exc:
        print(f"BLOCKED: {type(exc).__name__}: {exc}",file=sys.stderr)
        sys.exit(1)
