"""Entirely synthetic unit tests: zero DB connections and SQL execution."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "oes_neon_migration_preflight.py"
spec = importlib.util.spec_from_file_location("oes_preflight", SCRIPT)
preflight = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preflight)

class TestPreflight(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.entries = ["database/poc-s1.sql"] + [f"database/{i:03d}_synthetic.sql" for i in range(2, 36)] + ["database/036_temporal_first_measurement_semantics.sql"]
        (self.root / "database").mkdir()
        (self.root / ".github/workflows").mkdir(parents=True)
        self.make_files()

    def make_files(self):
        (self.root / preflight.MANIFEST).write_text("# fake test\n" + "\n".join(self.entries) + "\n")
        step = "      - name: Install baseline through migration 029\n        run: |\n" + "".join(f"          psql -v ON_ERROR_STOP=1 -f {f} 2>&1 | tee fake.log\n" for f in self.entries)
        (self.root / preflight.WORKFLOW).write_text(step + "      - name: next step\n")
        for f in self.entries:
            num = Path(f).name[:3]
            parts = preflight.EXPECTED_PARTS.get(num, [])
            (self.root / f).write_text("-- synthetic \n" + "".join(f"\\ir {part}\n" for part in parts))
            for part in parts:
                (self.root / "database" / part).write_text("-- synthetic content\n")

    def test_fifty_files_and_deterministic_digest(self):
        a = preflight.inspect(self.root, skip_git_check=True)
        b = preflight.inspect(self.root, skip_git_check=True)
        self.assertEqual((a["entry_count"], a["fragment_count"]), (36,14))
        self.assertEqual(a["inventory_sha256"], b["inventory_sha256"])
        self.assertFalse(a["sql_executed"])

    def test_reordered_manifest_fails_closed(self):
        self.entries[2], self.entries[3] = self.entries[3], self.entries[2]
        (self.root / preflight.MANIFEST).write_text("\n".join(self.entries))
        with self.assertRaisesRegex(preflight.PreflightFailure, "order differs"):
            preflight.inspect(self.root, skip_git_check=True)

    def test_missing_fragment_fails_closed(self):
        (self.root / "database" / preflight.EXPECTED_PARTS["031"][0]).unlink()
        with self.assertRaisesRegex(preflight.PreflightFailure, "missing/unsafe"):
            preflight.inspect(self.root, skip_git_check=True)

    def test_unexpected_include_fails_closed(self):
        p = self.root / self.entries[0]
        p.write_text("\\ir unexpected.sql\n")
        with self.assertRaisesRegex(preflight.PreflightFailure, "unexpected include"):
            preflight.inspect(self.root, skip_git_check=True)

    def test_nested_include_fails_closed(self):
        (self.root / "database" / preflight.EXPECTED_PARTS["031"][0]).write_text("\\ir recursive.sql\n")
        with self.assertRaisesRegex(preflight.PreflightFailure, "nested include"):
            preflight.inspect(self.root, skip_git_check=True)

    def test_modified_content_changes_digest(self):
        old = preflight.inspect(self.root, skip_git_check=True)["inventory_sha256"]
        (self.root / self.entries[1]).write_text("-- changed fake content\n")
        new = preflight.inspect(self.root, skip_git_check=True)["inventory_sha256"]
        self.assertNotEqual(old, new)

    def test_untracked_git_context_rejected(self):
        with self.assertRaisesRegex(preflight.PreflightFailure, "expected-head"):
            preflight.inspect(self.root)

if __name__ == "__main__":
    unittest.main()
