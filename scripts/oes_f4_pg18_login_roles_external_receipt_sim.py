#!/usr/bin/env python3
"""Synthetic-only PG18 LOGIN/SET/INHERIT test + filesystem audit receipt simulator.

Executes against the allowlisted ephemeral GitHub Actions postgres:18 service.
Files on the same CI runner are OUTSIDE database transactions, but NOT an
independent, immutable, production audit service. Never accesses Neon.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

DB = "oes_f4_cp177_synthetic"
OUT = Path("f4-pg18-cp177-evidence")
PSQL = ["psql", "-X", "-q", "-A", "-t", "-v", "ON_ERROR_STOP=1",
        "-h", "127.0.0.1", "-p", "5432", "-d", DB]
USERS = {
    "postgres":"synthetic_ci_only",
    "oes_ci_runtime_login":"ci_runtime_synthetic_only",
    "oes_ci_migrator_login":"ci_migrator_synthetic_only",
    "oes_ci_elevated_login":"ci_elevated_synthetic_only",
    "oes_ci_guard_owner":"synthetic_ci_only",
}
OWNER="oes_ci_guard_owner"
TABLE="maintenance.temporal_observation_epoch"
TRIGGER="tr_temporal_epoch_activation_chronology"
MANIFEST="database/f4-neon-sandbox-schema-migration-manifest.txt"
EVENTS=[]

def check(tag,condition):
    if not condition: raise AssertionError("CHECK_FAILED "+tag)
    print(tag+"\tPASS",flush=True)
    with (OUT/"checks.tsv").open("a",encoding="utf8") as f:
        f.write(tag+"\tPASS\n")

def canonical(data):
    return json.dumps(data,sort_keys=True,separators=(",",":"),ensure_ascii=True).encode()

def hash_obj(data):
    return hashlib.sha256(canonical(data)).hexdigest()

def invoke(user, statement=None, path=None):
    if user not in USERS:raise AssertionError("Unsafe credential")
    if (statement is None)==(path is None):raise AssertionError("SQL argument ambiguity")
    env=os.environ.copy()
    env["PGPASSWORD"]=USERS[user]
    for name in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE"):
        env.pop(name,None)
    command=PSQL+["-U",user]+(["-c",statement] if statement is not None
                               else ["-f",str(path)])
    return subprocess.run(command,env=env,capture_output=True,text=True,timeout=80)

def execute(user,sql):
    p=invoke(user,statement=sql)
    if p.returncode:raise AssertionError("SQL failure: "+p.stderr[-700:])
    return p.stdout.strip()

def scalar(q):
    return execute("postgres",q)

def denied(label,user,sql):
    p=invoke(user,statement=sql)
    check(label,p.returncode != 0)
    return p

def trigger_state():
    return scalar(f"""SELECT tgenabled FROM pg_trigger WHERE
         tgrelid='{TABLE}'::regclass AND tgname='{TRIGGER}';""")

def append_event(action_id,phase,actor,operation,outcome):
    check("audit_event_label_valid_"+str(len(EVENTS)+1),
          phase in ("attempt","result") and operation in
          ("DISABLE_GUARD","ENABLE_GUARD","ROLLBACK_GUARD","SET_OWNER_ROLE"))
    prior=EVENTS[-1]["hash"] if EVENTS else "0"*64
    body={
        "seq":len(EVENTS)+1,"prev_hash":prior,"action_id":action_id,
        "phase":phase,"actor":actor,"operation":operation,"outcome":outcome,
        "commit":os.environ["GITHUB_SHA"],
    }
    body["hash"]=hash_obj(body)
    EVENTS.append(body)
    # An external-to-DB file, written BEFORE the SQL attempt or AFTER response.
    # Not external to runner, and never claimed tamperproof.
    with (OUT/"simulated-outside-db.jsonl").open("a",encoding="utf8") as f:
        f.write(json.dumps(body,sort_keys=True)+"\n")

def verify_receipts(rows,anchor):
    if not isinstance(rows,list) or len(rows)!=anchor.get("count"):
        raise ValueError("missing receipts")
    prior="0"*64
    pending={}
    for seq,row in enumerate(rows,1):
        if row.get("seq")!=seq or row.get("prev_hash")!=prior:
            raise ValueError("receipt gap/order")
        payload={k:v for k,v in row.items() if k!="hash"}
        if row.get("hash")!=hash_obj(payload):
            raise ValueError("altered receipt")
        prior=row["hash"]
        ident=row.get("action_id")
        if row.get("phase")=="attempt":
            if ident in pending:raise ValueError("duplicate attempt")
            pending[ident]=(row.get("actor"),row.get("operation"))
        elif row.get("phase")=="result":
            if ident not in pending:raise ValueError("result without attempt")
            if pending.pop(ident)!=(row.get("actor"),row.get("operation")):
                raise ValueError("result not matching attempt")
        else: raise ValueError("invalid receipt phase")
    if pending:raise ValueError("attempt missing result")
    if prior!=anchor.get("final_hash"):raise ValueError("anchor mismatch")
    return True

def attempted(action_id,actor,operation,sql,should_succeed):
    append_event(action_id,"attempt",actor,operation,"PENDING")
    p=invoke(actor,statement=sql)
    outcome=("CONFIRMED" if p.returncode==0 else "DENIED_OR_FAILED")
    append_event(action_id,"result",actor,operation,outcome)
    check(action_id+"_outcome", (p.returncode==0)==should_succeed)
    return p

def main():
    required={
      "GITHUB_ACTIONS":"true",
      "GITHUB_REPOSITORY":"rogerio-raposo/observatorio-evidencias-saude",
      "PGHOST":"127.0.0.1","PGPORT":"5432",
      "PGUSER":"postgres","PGDATABASE":DB,
    }
    if any(os.getenv(k)!=v for k,v in required.items()) or any(
        os.getenv(k) for k in ("DATABASE_URL","PGSERVICE","PGSERVICEFILE")):
        raise RuntimeError("BLOCKED: CI-only ephemeral PG18")
    OUT.mkdir(exist_ok=True)
    (OUT/"checks.tsv").write_text("check\tresult\n",encoding="utf8")
    check("pg18_server",scalar("SHOW server_version_num;").startswith("18"))
    sha=os.environ.get("GITHUB_SHA","")
    check("git_sha_pinned",re.fullmatch(r"[0-9a-f]{40}",sha) is not None)
    (OUT/"commit.txt").write_text(sha+"\n",encoding="utf8")

    files=[line.strip() for line in Path(MANIFEST).read_text().splitlines()
           if line.strip() and not line.lstrip().startswith("#")]
    check("manifest_36_unique",len(files)==36 and len(set(files))==36)
    for path in files:
        p=invoke("postgres",path=path)
        if p.returncode:raise AssertionError("migration baseline install: "+p.stderr[-700:])
    check("pg18_disposable_schema_36_installed",True)
    check("034_guard_initially_enabled",trigger_state()=="O")

    execute("postgres",r"""
    CREATE ROLE oes_ci_guard_owner NOLOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB;
    CREATE ROLE oes_ci_runtime_login LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB
       PASSWORD 'ci_runtime_synthetic_only';
    CREATE ROLE oes_ci_migrator_login LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB
       PASSWORD 'ci_migrator_synthetic_only';
    CREATE ROLE oes_ci_elevated_login LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB
       PASSWORD 'ci_elevated_synthetic_only';
    GRANT USAGE ON SCHEMA maintenance
       TO oes_ci_runtime_login,oes_ci_migrator_login,oes_ci_elevated_login,oes_ci_guard_owner;
    GRANT SELECT ON maintenance.temporal_observation_epoch
       TO oes_ci_runtime_login,oes_ci_migrator_login;
    GRANT oes_ci_guard_owner TO oes_ci_migrator_login
       WITH INHERIT FALSE, SET FALSE, ADMIN FALSE;
    GRANT oes_ci_guard_owner TO oes_ci_elevated_login
       WITH INHERIT FALSE, SET TRUE, ADMIN FALSE;
    ALTER TABLE maintenance.temporal_observation_epoch OWNER TO oes_ci_guard_owner;
    """)
    check("role_owner_nologin",
          scalar(f"SELECT rolcanlogin::text FROM pg_roles WHERE rolname='{OWNER}';")=="false")
    check("runtime_no_owner_membership",
          scalar(f"SELECT pg_has_role('oes_ci_runtime_login','{OWNER}','MEMBER')::text;")=="false")
    check("migrator_is_member_but_cannot_set",
          scalar(f"SELECT pg_has_role('oes_ci_migrator_login','{OWNER}','MEMBER')::text||','||"
                 f"pg_has_role('oes_ci_migrator_login','{OWNER}','SET')::text;")=="true,false")
    check("migrator_cannot_inherit_owner",
          scalar(f"SELECT pg_has_role('oes_ci_migrator_login','{OWNER}','USAGE')::text;")=="false")
    check("elevated_member_can_set_but_not_inherit",
          scalar(f"SELECT pg_has_role('oes_ci_elevated_login','{OWNER}','SET')::text||','||"
                 f"pg_has_role('oes_ci_elevated_login','{OWNER}','USAGE')::text;")=="true,false")
    check("login_credentials_are_distinct",
          all(execute(u,"SELECT session_user||':'||current_user;")==u+":"+u for u in
              ("oes_ci_runtime_login","oes_ci_migrator_login","oes_ci_elevated_login")))
    denied("owner_nologin_rejected","oes_ci_guard_owner",
           "SELECT current_user;")
    denied("runtime_set_owner_denied","oes_ci_runtime_login",
           f"SET ROLE {OWNER};")
    denied("migrator_set_owner_denied","oes_ci_migrator_login",
           f"SET ROLE {OWNER};")
    denied("migrator_disable_actual_guard_denied","oes_ci_migrator_login",
           f"ALTER TABLE {TABLE} DISABLE TRIGGER {TRIGGER};")
    denied("runtime_disable_actual_guard_denied","oes_ci_runtime_login",
           f"ALTER TABLE {TABLE} DISABLE TRIGGER {TRIGGER};")
    check("034_guard_after_denials",trigger_state()=="O")
    check("elevated_login_without_set_lacks_owner",
          invoke("oes_ci_elevated_login",statement=
                 f"ALTER TABLE {TABLE} DISABLE TRIGGER {TRIGGER};").returncode!=0)

    # Elevated actor with SET privilege demonstrates the actual ownership
    # conflict on a genuine migrated guard in disposable PG18.
    attempted("elevated_disable","oes_ci_elevated_login","DISABLE_GUARD",
              f"SET ROLE {OWNER}; ALTER TABLE {TABLE} DISABLE TRIGGER {TRIGGER};",True)
    check("elevated_actor_bypasses_guard_on_owned_table",trigger_state()=="D")
    attempted("elevated_enable","oes_ci_elevated_login","ENABLE_GUARD",
              f"SET ROLE {OWNER}; ALTER TABLE {TABLE} ENABLE TRIGGER {TRIGGER};",True)
    check("trigger_reenabled_after_elevation",trigger_state()=="O")

    # SQL is rolled back; the audit file outside PostgreSQL transaction
    # retains attempted and response records in runner filesystem.
    attempted("elevated_rolled_back","oes_ci_elevated_login","ROLLBACK_GUARD",
              f"SET ROLE {OWNER}; BEGIN; ALTER TABLE {TABLE} DISABLE TRIGGER {TRIGGER}; ROLLBACK;",True)
    check("rolled_back_guard_is_enabled",trigger_state()=="O")
    denied_p=attempted("migrator_unapproved_set","oes_ci_migrator_login","SET_OWNER_ROLE",
                       f"SET ROLE {OWNER};",False)
    check("denied_attempt_has_message",bool(denied_p.stderr.strip()))

    anchor={
       "count":len(EVENTS),"final_hash":EVENTS[-1]["hash"],
       "commit":sha,
       "scope":"CI_RUNNER_FILE_ONLY_NOT_INDEPENDENT_OR_IMMUTABLE_AUDIT",
    }
    (OUT/"audit-anchor.json").write_text(json.dumps(anchor,indent=2,sort_keys=True)+"\n")
    check("receipt_chain_complete",verify_receipts(EVENTS,anchor))
    check("rolled_back_ddl_still_has_outside_db_receipts",
          any(e["action_id"]=="elevated_rolled_back" and e["phase"]=="result" for e in EVENTS))
    mutated=copy.deepcopy(EVENTS)
    mutated[3]["outcome"]="FORGED_APPROVAL"
    for name, bad, anc in [
        ("receipt_tamper_detected", mutated,anchor),
        ("receipt_missing_middle_event_detected",EVENTS[:2]+EVENTS[3:],anchor),
        ("receipt_truncation_detected",EVENTS[:-1],anchor),
        ("receipt_reorder_detected",EVENTS[::-1],anchor),
        ("receipt_forged_anchor_detected",EVENTS,{**anchor,"final_hash":"0"*64}),
    ]:
        try:verify_receipts(bad,anc)
        except ValueError:check(name,True)
        else:check(name,False)

    result={
      "state":"DISPOSABLE_PG18_LOGIN_MEMBERSHIP_AND_SIMULATED_OUTSIDE_DB_RECEIPTS_ONLY",
      "source_commit":sha,
      "roles_with_separate_login":3,
      "protected_owner_nologin":True,
      "migrator_membership_set_false_confirmed":True,
      "elevated_actor_membership_set_true_confirmed":True,
      "privileged_actor_could_disable_034_guard":True,
      "rollback_receipt_recorded_in_ci_runner_file":True,
      "receipt_count":len(EVENTS),
      "external_persistent_collector_configured":False,
      "audit_file_outside_db_transaction":True,
      "audit_file_independent_of_ci_runner":False,
      "audit_immutability_proven":False,
      "unknown_direct_admin_sql_covered":False,
      "neon_accessed":False,
      "neon_write_authorized":False,
      "operational_roles_created":False,
      "reconciliation_postconditions_approved":0,
      "paid_services_activated":False,
    }
    (OUT/"result.json").write_text(json.dumps(result,indent=2,sort_keys=True))
    (OUT/"result.txt").write_text("PG18_LOGIN_AUDIT_RECEIPTS_SYNTHETIC_LIMITED_PASS\n")
    print("PG18_LOGIN_AUDIT_RECEIPTS_SYNTHETIC_LIMITED_PASS",flush=True)

if __name__=="__main__":
    try:main()
    except Exception as e:
        print(f"BLOCKED: {type(e).__name__}: {e}",file=sys.stderr)
        raise SystemExit(1)
