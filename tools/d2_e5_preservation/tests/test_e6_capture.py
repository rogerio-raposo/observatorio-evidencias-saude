"""E6-A2 integration is exercised with synthetic bytes, never HTTP."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import e6_capture


class E6IntegrationTests(unittest.TestCase):
    def test_e3_parameters_retained(self):
        self.assertEqual([k for k, _ in e6_capture.PARAMS],
            ["query.cond", "query.term", "sort", "pageSize", "countTotal", "format"])
        self.assertIn("pageSize=20", e6_capture.URL)

    def test_synthetic_end_to_end_package_and_preflight(self):
        raw = json.dumps({"studies": [
            {"protocolSection": {"identificationModule": {"nctId": "NCT00000001"}}}],
            "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            plan = e6_capture.build_package(
                raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                "application/json", folder, 42, 1, "a" * 40, "synthetic-e6-integration")
            self.assertEqual((folder / "response.raw.json").read_bytes(), raw)
            self.assertEqual(plan["files"][0]["sha256"], hashlib.sha256(raw).hexdigest())
            self.assertEqual(plan["github_publication"], "NOT_PERFORMED")
            self.assertEqual(json.loads((folder / "manifest.json").read_text())["github_run_id"], 42)

    def test_connected_runner_denied_by_default(self):
        with patch("sys.argv", ["e6_capture.py", "--connected"]), patch.dict("os.environ", {}, clear=True):
            with self.assertRaises(SystemExit):
                e6_capture.main()

    def test_failed_json_does_not_leave_package(self):
        with tempfile.TemporaryDirectory() as td:
            folder = Path(td) / "evidence"
            with self.assertRaises(ValueError):
                e6_capture.build_package(b"not-json", "2026-10-24T05:00:00+00:00",
                    "2026-10-24T05:00:01+00:00", "application/json",
                    folder, 42, 1, "a" * 40, "synthetic-e6-integration")
            self.assertFalse(folder.exists())

    def test_structure_gate_accepts_synthetic_known_sections(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {
                "identificationModule": {"nctId": "NCT00000001"},
                "statusModule": {"overallStatus": "RECRUITING"},
                "designModule": {"studyType": "INTERVENTIONAL"},
            },
            "derivedSection": {},
            "hasResults": False,
        }], "totalCount": 1}).encode()
        self.assertIsNone(e6_capture.preupload_structure_gate(raw))

    def test_structure_gate_holds_unexpected_top_level_field(self):
        raw = json.dumps({"studies": [], "unreviewedData": {"x": 1}}).encode()
        with self.assertRaisesRegex(ValueError, "^HOLD: unexpected top-level fields"):
            e6_capture.preupload_structure_gate(raw)

    def test_structure_gate_holds_unexpected_study_field(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
            "privatePayload": "synthetic-secret",
        }]}).encode()
        with self.assertRaisesRegex(ValueError, "^HOLD: unexpected study fields") as caught:
            e6_capture.preupload_structure_gate(raw)
        self.assertNotIn("synthetic-secret", str(caught.exception))

    def test_structure_gate_holds_unexpected_protocol_section(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {
                "identificationModule": {"nctId": "NCT00000001"},
                "unreviewedModule": {},
            },
        }]}).encode()
        with self.assertRaisesRegex(ValueError, "^HOLD: unexpected protocol sections"):
            e6_capture.preupload_structure_gate(raw)

    def test_structure_hold_prevents_package_creation(self):
        raw = json.dumps({"studies": [{
            "protocolSection": {"identificationModule": {"nctId": "NCT00000001"}},
            "unreviewedPayload": True,
        }], "totalCount": 1}).encode()
        with tempfile.TemporaryDirectory() as td:
            destination = Path(td) / "evidence"
            with self.assertRaisesRegex(ValueError, "^HOLD:"):
                e6_capture.build_package(
                    raw, "2026-10-24T05:00:00+00:00", "2026-10-24T05:00:01+00:00",
                    "application/json", destination, 42, 1, "a" * 40,
                    "synthetic-e6-hold",
                )
            self.assertFalse(destination.exists())
