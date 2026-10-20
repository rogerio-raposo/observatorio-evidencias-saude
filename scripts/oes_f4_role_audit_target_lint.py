#!/usr/bin/env python3
"""Fail-closed STATIC-only validation of an unapproved OES RBAC/DDL model.

No database, no external API and no Neon access. A PASS explicitly means the
design is still unapproved and its requirements have NOT been verified.
"""
import hashlib
import json
from pathlib import Path
import sys

PATH = "docs/governance/security/f4-target-roles-external-audit-draft.json"
CATALOG = "database/f4-reconciliation-postconditions-draft.json"
MATRIX = "docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json"

ROLE_IDS = {
    "schema_owner","runtime","migration_executor","audit_reader",
    "backup_operator","break_glass_admin"
}
CONTROL_IDS = {
    "no_runtime_owner_path","migration_owner_conflict","bounded_elevation",
    "external_log_non_transactional","external_log_ownership",
    "external_log_integrity","audit_coverage_gap",
    "neon_plan_and_billing","control_plane_vs_db",
    "tls_secrets_rotation","backup_independence","human_specialist_review"
}
AUDIT_IDS = {"native_neon_log_export","git_actions_commit_and_artifacts",
             "database_event_trigger","external_collector_independent"}
CRITICAL_DISTINCTIONS = {
    "POSTGRESQL_OBJECT_OWNER_IS_NOT_REVOKABLE_DDL_BOUNDARY",
    "NEON_CONTROL_PLANE_PERMISSIONS_ARE_DISTINCT_FROM_POSTGRESQL_SQL_ROLES",
    "AUDIT_INSIDE_TRANSACTION_IS_NOT_EXTERNAL_IMMUTABLE_PROOF",
    "MIGRATOR_OWNERSHIP_REQUIRES_PRIVILEGED_TIMEBOXED_GATE_AND_EXTERNAL_AUDIT"
}
FLAGS = {
    "database_roles_created":False,
    "neon_accessed":False,
    "neon_write_authorized":False,
    "paid_service_approved":False,
    "external_ddl_audit_enabled":False,
    "migration_runner_operational":False,
    "backup_restore_independent":False,
    "catalog_postconditions_approved":0,
    "automatic_replay_allowed":False,
    "operational_readiness":False,
}
ROLE_NOT_ALLOWED = {
    "runtime":{"object_ownership","alter_table","disable_trigger",
               "set_role_schema_owner","set_role_migration_elevation","superuser"},
    "migration_executor":{"persistent_owner_membership","arbitrary_alter_schema_without_gate",
                          "disable_triggers_outside_approved_change","unreviewed_replay"},
    "audit_reader":{"modify_audit_records","control_producer_admin_settings"},
    "break_glass_admin":{"delegation_to_ci_by_default","shared_long_lived_tokens"},
}
AUDIT_CLASS = {
    "native_neon_log_export":"CONDITIONAL_NOT_SELECTED",
    "git_actions_commit_and_artifacts":"SYNTHETIC_CI_EVIDENCE_ONLY",
    "database_event_trigger":"SUPPLEMENTAL_TRANSACTION_BOUND_ONLY",
    "external_collector_independent":"REQUIRED_BUT_UNSELECTED",
}

class Blocked(ValueError): pass

def must(ok, why):
    if not ok: raise Blocked(why)

def unique_records(rows, ids, kind):
    must(isinstance(rows,list) and len(rows)==len(ids), f"{kind} count mismatch")
    must(all(isinstance(x,dict) and isinstance(x.get("id"),str) for x in rows),
         f"{kind} invalid item")
    names=[x["id"] for x in rows]
    must(set(names)==ids and len(set(names))==len(names), f"{kind} IDs missing/duplicated")
    return {x["id"]:x for x in rows}

def check(model, catalog, matrix):
    must(isinstance(model,dict) and isinstance(catalog,dict) and isinstance(matrix,dict),
         "invalid input root")
    must(model.get("schema_version")=="oes.f4.role-audit-target.draft.v1"
         and model.get("source_checkpoint")=="CP175"
         and model.get("status")=="DRAFT_ONLY_FAIL_CLOSED_NO_OPERATIONAL_AUTHORIZATION"
         and model.get("permissions_semantics")=="DENY_UNLESS_EXPLICITLY_APPROVED_AND_PROVEN",
         "draft identity or policy modified")
    for name,expected in FLAGS.items():
        actual=model.get(name)
        must(actual==expected and type(actual)==type(expected), f"flag violation: {name}")
    must(model.get("decision")=="HOLD_NEON_WRITES_UNTIL_GATES_APPROVED",
         "gate has been opened")
    must(set(model.get("mandatory_distinctions",[]))==CRITICAL_DISTINCTIONS,
         "required separation/risk distinction missing")
    roles=unique_records(model.get("roles"),ROLE_IDS,"roles")
    for name,row in roles.items():
        must(row.get("plane") in ("database","control_plane","external"),"invalid plane")
        must(isinstance(row.get("purpose"),str) and len(row["purpose"])>35,
             "role purpose too vague")
        must(isinstance(row.get("allowed"),list) and row["allowed"],"role allowed undefined")
        must(isinstance(row.get("prohibited"),list) and row["prohibited"],"role prohibitions empty")
        must(isinstance(row.get("elevation"),str),"role elevation must be explicit")
    for name,forbidden in ROLE_NOT_ALLOWED.items():
        must(forbidden.issubset(set(roles[name]["prohibited"])),
             f"role {name} lost critical prohibition")
        must(not (forbidden & set(roles[name]["allowed"])),
             f"role {name} enables critical forbidden operation")
    must(roles["schema_owner"].get("credential")=="NOLOGIN",
         "schema owner cannot be an ordinary LOGIN")
    must(roles["runtime"].get("elevation")=="NEVER",
         "runtime cannot acquire owner/elevation")
    must(roles["migration_executor"].get("elevation")==
         "REQUIRES_SEPARATE_EXPLICIT_OWNER_APPROVAL_AND_EXTERNAL_EVIDENCE",
         "migration privilege elevation must be gated")
    must(roles["audit_reader"].get("plane")=="external" and
         roles["backup_operator"].get("plane")=="external",
         "audit and restore must be separated from database")

    controls=unique_records(model.get("mandatory_controls"),CONTROL_IDS,"controls")
    for name,row in controls.items():
        must(row.get("required") is True,"disabled mandatory control")
        must(row.get("state") not in
             ("VERIFIED","APPROVED","PASS","SATISFIED","IMPLEMENTED"),
             "unverified control presented as passed")
        must(row.get("state") in
             ("NOT_TESTED_NEON","UNRESOLVED_DESIGN","NOT_IMPLEMENTED",
              "NOT_CONFIGURED","NOT_VERIFIED","OWNER_CONFIRMATION_PENDING",
              "NOT_REVIEWED"),"control has unknown state")
        must(isinstance(row.get("evidence"),str) and len(row["evidence"])>=55,
             "insufficient evidence requirement")
    must(controls["migration_owner_conflict"]["state"]=="UNRESOLVED_DESIGN",
         "ownership conflict cannot be considered resolved")
    must(controls["external_log_non_transactional"]["state"]=="NOT_CONFIGURED",
         "external independent logs not deployed")
    must(controls["neon_plan_and_billing"]["state"]=="OWNER_CONFIRMATION_PENDING",
         "cost and feature use need owner review")

    audit=unique_records(model.get("audit_options"),AUDIT_IDS,"audit options")
    for name,expect in AUDIT_CLASS.items():
        must(audit[name].get("classification")==expect,
             "audit mechanism must remain clearly classified")
        must(isinstance(audit[name].get("risks"),list) and audit[name]["risks"],
             "audit risks must not be omitted")
    must("NOT_ASSUMED_FREE" in audit["native_neon_log_export"]["risks"],
         "Neon provider export must not be treated as free")
    must("NOT_COMPLETE_DB_DDL_AUDIT" in audit["git_actions_commit_and_artifacts"]["risks"],
         "GitHub actions artifacts cannot certify all DB DDL")
    must("NOT_INDEPENDENT" in audit["database_event_trigger"]["risks"],
         "in-DB transactional audit is not independent")
    must("COST_APPROVAL_PENDING" in audit["external_collector_independent"]["risks"],
         "unselected collector cannot be considered free or approved")

    rows=catalog.get("entries")
    must(isinstance(rows,list) and len(rows)==36,"canonical migration catalog drift")
    must(all(isinstance(x,dict) and x.get("review_state")=="UNREVIEWED"
             and x.get("postconditions")==[]
             and x.get("automated_reconciliation_allowed") is False
             and x.get("automatic_replay_allowed") is False
             and x.get("migration_execution_allowed") is False for x in rows),
         "catalog activation detected")
    must(matrix.get("status")=="DRAFT_ONLY_ALL_GATES_BLOCKED",
         "sufficiency matrix promoted")
    migrations=matrix.get("migrations")
    must(isinstance(migrations,list) and len(migrations)==3,"matrix count changed")
    evidence=[e for m in migrations for e in m.get("required_evidence",[])]
    must(len(evidence)==36 and all(e.get("verification")=="NOT_COLLECTED" for e in evidence),
         "sufficiency evidence has been promoted")
    return {
        "state":"STATIC_ROLE_AUDIT_TARGET_FAIL_CLOSED_DRAFT_ONLY",
        "roles":len(roles),"required_controls":len(controls),"audit_options":len(audit),
        "blocked_migrations":len(rows),
        "uncollected_evidence_items":len(evidence),
        "external_collector_enabled":False,
        "neon_accessed":False,
        "neon_write_authorized":False,
        "paid_services_approved":False,
        "sql_executed":False,
        "model_sha256":hashlib.sha256(json.dumps(model,sort_keys=True).encode()).hexdigest(),
    }

def main():
    try:
        model=json.loads(Path(PATH).read_text(encoding="utf8"))
        catalog=json.loads(Path(CATALOG).read_text(encoding="utf8"))
        matrix=json.loads(Path(MATRIX).read_text(encoding="utf8"))
        print(json.dumps(check(model,catalog,matrix),indent=2,sort_keys=True))
        return 0
    except (Blocked, ValueError, TypeError, OSError) as exc:
        print(f"BLOCKED: {exc}",file=sys.stderr)
        return 2

if __name__=="__main__":
    sys.exit(main())
