"""Synthetic source-text negative tests. No Postgres, SQL execution or Neon."""
import copy
import json
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from oes_f4_031_036_source_review import Blocked, verify

ROOT = Path(__file__).resolve().parents[1]


def setup():
    catalog = json.loads((ROOT / "docs/governance/reconciliation/f4-031-036-source-candidates.json").read_text())
    canonical = (ROOT / "database/f4-reconciliation-postconditions-draft.json").read_bytes()
    manifest = (ROOT / "database/f4-neon-sandbox-schema-migration-manifest.txt").read_bytes()
    contents = {}
    for row in catalog["candidates"]:
        wrapper = []
        if row["ordinal"] <= 33:
            wrapper.append("BEGIN;")
        wrapper += row["source_markers"]  # harmless inert source text: no DB connection
        for frag in row["includes"]:
            wrapper.append(r"\ir " + frag)
            contents["database/" + frag] = b"-- synthetic fixture\n"
        if row["ordinal"] <= 33:
            wrapper.append("COMMIT;")
        contents[row["entrypoint"]] = ("\n".join(wrapper) + "\n").encode("utf8")
    # Markers may be in fragments in real SQL; synthetic fixture duplicates them
    # in wrapper solely to test source-check logic.
    return catalog, manifest, canonical, contents


def run(c, m, p, d):
    return verify(c, m, p, lambda name: d[name])


class TestSourceDraftFailClosed(unittest.TestCase):
    def test_synthetic_positive_still_unreviewed(self):
        c, m, p, d = setup()
        out = run(c, m, p, d)
        self.assertEqual(out["source_files_checked"], 20)
        self.assertEqual(out["migrations_scanned"], 6)
        self.assertEqual(out["fragments_scanned"], 14)
        self.assertEqual(out["postconditions_validated"], 0)
        self.assertFalse(out["neon_write_authorized"])
        self.assertFalse(out["sql_executed"])

    def test_missing_marker_blocked(self):
        c, m, p, d = setup()
        path = c["candidates"][0]["entrypoint"]
        d[path] = d[path].replace(c["candidates"][0]["source_markers"][0].encode(), b"")
        with self.assertRaises(Blocked):
            run(c, m, p, d)

    def test_include_order_drift_blocked(self):
        c, m, p, d = setup()
        row = c["candidates"][0]
        path = row["entrypoint"]
        s = d[path].decode()
        first, second = row["includes"][:2]
        d[path] = s.replace(first, "__marker__", 1).replace(second, first, 1).replace("__marker__", second, 1).encode()
        with self.assertRaises(Blocked):
            run(c, m, p, d)

    def test_nested_fragment_include_blocked(self):
        c, m, p, d = setup()
        d["database/" + c["candidates"][0]["includes"][0]] += b"\\ir unexpected.sql\n"
        with self.assertRaises(Blocked):
            run(c, m, p, d)

    def test_internal_transaction_fragment_blocked(self):
        c, m, p, d = setup()
        d["database/" + c["candidates"][1]["includes"][0]] += b"COMMIT;\n"
        with self.assertRaises(Blocked):
            run(c, m, p, d)

    def test_unsafe_execution_flag_blocked(self):
        c, m, p, d = setup()
        c["neon_write_authorized"] = True
        with self.assertRaises(Blocked):
            run(c, m, p, d)

    def test_candidate_path_and_order_drift_blocked(self):
        c, m, p, d = setup()
        c["candidates"][1]["entrypoint"] = c["candidates"][0]["entrypoint"]
        with self.assertRaises(Blocked):
            run(c, m, p, d)

    def test_canonical_promotion_blocked(self):
        c, m, p, d = setup()
        primary = json.loads(p)
        primary["entries"][30]["review_state"] = "REVIEWED"
        with self.assertRaises(ValueError):
            run(c, m, json.dumps(primary).encode(), d)


if __name__ == "__main__":
    unittest.main()
