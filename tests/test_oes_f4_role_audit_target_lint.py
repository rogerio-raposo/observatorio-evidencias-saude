"""Static negative tests: proposed roles and independent audit remain UNAPPROVED."""
import copy
import json
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"scripts"))
from oes_f4_role_audit_target_lint import Blocked,check

def fixture():
    a=json.loads((ROOT/"docs/governance/security/f4-target-roles-external-audit-draft.json").read_text(encoding="utf8"))
    b=json.loads((ROOT/"database/f4-reconciliation-postconditions-draft.json").read_text(encoding="utf8"))
    c=json.loads((ROOT/"docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json").read_text(encoding="utf8"))
    return a,b,c

def role(m,id):
    return next(x for x in m["roles"] if x["id"]==id)

def ctl(m,id):
    return next(x for x in m["mandatory_controls"] if x["id"]==id)

def aud(m,id):
    return next(x for x in m["audit_options"] if x["id"]==id)

class TestFailClosedSecurityTarget(unittest.TestCase):
    def test_valid_draft_is_not_approved(self):
        m,c,x=fixture()
        result=check(m,c,x)
        self.assertEqual(result["roles"],6)
        self.assertEqual(result["required_controls"],12)
        self.assertEqual(result["audit_options"],4)
        self.assertEqual(result["blocked_migrations"],36)
        self.assertEqual(result["uncollected_evidence_items"],36)
        self.assertFalse(result["neon_write_authorized"])
        self.assertFalse(result["external_collector_enabled"])
        self.assertFalse(result["paid_services_approved"])

    def test_cannot_enable_neon(self):
        m,c,x=fixture();m["neon_write_authorized"]=True
        with self.assertRaises(Blocked):check(m,c,x)

    def test_cannot_mark_external_audit_ready(self):
        m,c,x=fixture();m["external_ddl_audit_enabled"]=True
        with self.assertRaises(Blocked):check(m,c,x)

    def test_cannot_authorize_cost(self):
        m,c,x=fixture();m["paid_service_approved"]=True
        with self.assertRaises(Blocked):check(m,c,x)

    def test_runtime_cannot_assume_owner(self):
        m,c,x=fixture();role(m,"runtime")["allowed"].append("set_role_schema_owner")
        with self.assertRaises(Blocked):check(m,c,x)

    def test_migrator_cannot_gain_unreviewed_owner_membership(self):
        m,c,x=fixture();role(m,"migration_executor")["prohibited"].remove("persistent_owner_membership")
        with self.assertRaises(Blocked):check(m,c,x)

    def test_ownership_conflict_cannot_be_approved(self):
        m,c,x=fixture();ctl(m,"migration_owner_conflict")["state"]="VERIFIED"
        with self.assertRaises(Blocked):check(m,c,x)

    def test_github_artifacts_cannot_be_claimed_complete(self):
        m,c,x=fixture();aud(m,"git_actions_commit_and_artifacts")["risks"].remove("NOT_COMPLETE_DB_DDL_AUDIT")
        with self.assertRaises(Blocked):check(m,c,x)

    def test_in_db_event_trigger_not_independent(self):
        m,c,x=fixture();aud(m,"database_event_trigger")["risks"].remove("NOT_INDEPENDENT")
        with self.assertRaises(Blocked):check(m,c,x)

    def test_paid_export_not_assumed_free(self):
        m,c,x=fixture();aud(m,"native_neon_log_export")["risks"].remove("NOT_ASSUMED_FREE")
        with self.assertRaises(Blocked):check(m,c,x)

    def test_external_collector_not_provisioned(self):
        m,c,x=fixture();aud(m,"external_collector_independent")["classification"]="SELECTED"
        with self.assertRaises(Blocked):check(m,c,x)

    def test_missing_ddlaudit_requirement_fails(self):
        m,c,x=fixture();m["mandatory_controls"]=[d for d in m["mandatory_controls"] if d["id"]!="external_log_non_transactional"]
        with self.assertRaises(Blocked):check(m,c,x)

    def test_primary_catalog_promotion_blocked(self):
        m,c,x=fixture();c["entries"][33]["review_state"]="REVIEWED"
        with self.assertRaises(Blocked):check(m,c,x)

    def test_formal_evidence_not_collected(self):
        m,c,x=fixture();x["migrations"][0]["required_evidence"][0]["verification"]="PASS"
        with self.assertRaises(Blocked):check(m,c,x)

    def test_runtime_no_elevation(self):
        m,c,x=fixture();role(m,"runtime")["elevation"]="ADMIN"
        with self.assertRaises(Blocked):check(m,c,x)

    def test_owner_must_remain_nologin(self):
        m,c,x=fixture();role(m,"schema_owner")["credential"]="LOGIN"
        with self.assertRaises(Blocked):check(m,c,x)

if __name__=="__main__":
    unittest.main()
