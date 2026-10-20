"""Offline negative tests for a deliberately UNAPPROVED evidence sufficiency matrix."""
import copy
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"scripts"))
from oes_f4_temporal_sufficiency_matrix_lint import Blocked,check

def fixtures():
    matrix=json.loads((ROOT/"docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json").read_text())
    manifest=(ROOT/"database/f4-neon-sandbox-schema-migration-manifest.txt").read_bytes()
    catalog=json.loads((ROOT/"database/f4-reconciliation-postconditions-draft.json").read_text())
    return matrix,manifest,catalog

class MatrixFailClosed(unittest.TestCase):
    def test_draft_pass_not_operational_approval(self):
        m,mf,c=fixtures()
        v=check(m,mf,c)
        self.assertEqual(v["requirements"],36)
        self.assertEqual(v["operational_postconditions_validated"],0)
        self.assertFalse(v["neon_accessed"])
        self.assertFalse(v["sql_executed"])

    def test_permuted_migration_order_blocked(self):
        m,mf,c=fixtures()
        m["migrations"].reverse()
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_missing_requirement_blocked(self):
        m,mf,c=fixtures()
        m["migrations"][0]["required_evidence"].pop()
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_fake_review_claim_blocked(self):
        m,mf,c=fixtures()
        m["migrations"][2]["review_status"]="APPROVED"
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_fake_receipt_and_approval_blocked(self):
        m,mf,c=fixtures()
        m["migrations"][1]["fully_applied_verified"]=True
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_administrative_bypass_claim_blocked(self):
        m,mf,c=fixtures()
        m["evaluation_policy"]["trigger_reenabled"]="retroactively_validated"
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_drift_and_unknown_commit_replay_blocked(self):
        m,mf,c=fixtures()
        m["evaluation_policy"]["unknown_commit"]="retry_automatically"
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_ddl_audit_evidence_must_not_be_forged(self):
        m,mf,c=fixtures()
        row=next(v for v in m["migrations"][0]["required_evidence"] if v["id"]=="ddl_audit")
        row["verification"]="PASS"
        row["evidence_artifact"]="fake.zip"
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_role_separation_evidence_must_not_be_forged(self):
        m,mf,c=fixtures()
        row=next(v for v in m["migrations"][0]["required_evidence"] if v["id"]=="privilege_separation")
        row["independent_reviewer"]="unverified_claim"
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_promoted_primary_catalog_blocks(self):
        m,mf,c=fixtures()
        c["entries"][33]["review_state"]="REVIEWED"
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_missing_independent_review_blocks(self):
        m,mf,c=fixtures()
        m["migrations"][2]["required_evidence"]=[
          x for x in m["migrations"][2]["required_evidence"] if x["id"]!="independent_review"
        ]
        with self.assertRaises(Blocked):check(m,mf,c)

    def test_neon_flag_must_remain_false(self):
        m,mf,c=fixtures()
        m["neon_write_authorized"]=True
        with self.assertRaises(Blocked):check(m,mf,c)

if __name__ == "__main__":
    unittest.main()
