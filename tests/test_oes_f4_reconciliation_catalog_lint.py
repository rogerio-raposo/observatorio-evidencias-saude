"""Entirely synthetic tests for draft-only reconciliation catalog lint."""
import json
import unittest

from scripts.oes_f4_reconciliation_catalog_lint import CatalogBlocked, verify


def fixture():
    names = ["database/poc-s1.sql"] + [
        f"database/{i:03d}_synthetic.sql" for i in range(2, 37)
    ]
    boundaries = {
        31: "INTERNAL_BEGIN_COMMIT_OBSERVED",
        32: "INTERNAL_BEGIN_COMMIT_OBSERVED",
        33: "INTERNAL_BEGIN_COMMIT_OBSERVED",
        34: "NO_WRAPPER_BEGIN_COMMIT_OBSERVED",
        35: "NO_WRAPPER_BEGIN_COMMIT_OBSERVED",
        36: "NO_WRAPPER_BEGIN_COMMIT_OBSERVED",
    }
    catalog = {
        "schema_version": "oes.f4.reconciliation-catalog.draft.v1",
        "status": "DRAFT_ALL_ENTRIES_UNREVIEWED",
        "governance_only": True,
        "synthetic_only": True,
        "canonical_manifest": "database/f4-neon-sandbox-schema-migration-manifest.txt",
        "source_head_when_created": "a" * 40,
        "entries": [{
            "ordinal": i,
            "entrypoint": name,
            "transaction_boundary": boundaries.get(i, "UNREVIEWED"),
            "review_state": "UNREVIEWED",
            "postconditions": [],
            "review_evidence": [],
            "automated_reconciliation_allowed": False,
            "automatic_replay_allowed": False,
            "migration_execution_allowed": False,
        } for i, name in enumerate(names, 1)],
    }
    return names, catalog


def run(names, catalog):
    return verify(("\n".join(names) + "\n").encode(),
                  json.dumps(catalog).encode())


class TestFailClosedDraft(unittest.TestCase):
    def test_valid_synthetic_catalog_does_not_claim_readiness(self):
        names, catalog = fixture()
        result = run(names, catalog)
        self.assertEqual(result["migration_entries"], 36)
        self.assertEqual(result["reviewed_entries"], 0)
        self.assertEqual(result["postconditions_validated"], 0)
        self.assertFalse(result["sql_executed"])
        self.assertFalse(result["neon_write_authorized"])

    def test_reordered_migration_blocks(self):
        names, c = fixture()
        c["entries"][0], c["entries"][1] = c["entries"][1], c["entries"][0]
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_missing_migration_blocks(self):
        names, c = fixture()
        c["entries"].pop()
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_unsafe_manifest_path_blocks(self):
        names, c = fixture()
        names[2] = "../neon-production.sql"
        c["entries"][2]["entrypoint"] = names[2]
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_unreviewed_automatic_replay_blocks(self):
        names, c = fixture()
        c["entries"][4]["automatic_replay_allowed"] = True
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_unreviewed_execution_blocks(self):
        names, c = fixture()
        c["entries"][4]["migration_execution_allowed"] = True
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_unreviewed_auto_reconciliation_blocks(self):
        names, c = fixture()
        c["entries"][4]["automated_reconciliation_allowed"] = True
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_proposed_postconditions_not_validated_blocks(self):
        names, c = fixture()
        c["entries"][33]["postconditions"] = [{"type": "relation_exists"}]
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_pretend_reviewed_blocks(self):
        names, c = fixture()
        c["entries"][11]["review_state"] = "REVIEWED"
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_invalid_transaction_boundary_blocks(self):
        names, c = fixture()
        c["entries"][30]["transaction_boundary"] = "ATOMIC_LEDGER"
        with self.assertRaises(CatalogBlocked):
            run(names, c)

    def test_forged_boolean_and_identity_blocks(self):
        names, c = fixture()
        c["entries"][0]["ordinal"] = True
        with self.assertRaises(CatalogBlocked):
            run(names, c)


if __name__ == "__main__":
    unittest.main()
