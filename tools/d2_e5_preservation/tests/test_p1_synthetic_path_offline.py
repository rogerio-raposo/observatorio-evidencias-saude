"""P1-A3 isolated integration with real E6, D1 bridge and documentary domain."""
import hashlib
import json
import sys
import unittest
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "prototypes" / "d1_t2" / "a1"))
sys.path.insert(0, str(ROOT / "applications" / "oes_web"))
from bridge import SyntheticCommandBridge
from evidence.domain import from_record
from p1_synthetic_path_offline import compose_synthetic_path
from e6_private_pg_offline import PersistenceHold

FIXTURE = ROOT / "applications" / "oes_web" / "evidence" / "fixtures" / "signals.json"
RAW = b'{"synthetic":true,"component":"p1-a3"}'


def provenance():
    t = datetime(2026, 10, 25, tzinfo=timezone.utc)
    return dict(observation_id="P1-OBS", activity_id="OES/P1-SYNTHETIC",
                repository_commit_sha="a" * 40, github_run_id=1, run_attempt=1,
                source_name="ClinicalTrials.gov API v2",
                requested_url_exact="https://example.invalid/p1-synthetic",
                started_at_utc=t, completed_at_utc=t, source_http_status=200,
                response_content_type="application/json")


def resolver(nct):
    return next((from_record(row) for row in json.loads(FIXTURE.read_text())
                 if row["nct"] == nct), None)


def association(nct="NCT01438697"):
    return {"observation_id": "P1-OBS", "signal_id": "SYNTH-SIGNAL-P1",
            "scenario_id": "P1-SCENARIO", "documentary_nct": nct}


def invoke(**changes):
    args = dict(raw=RAW, provenance=provenance(), association=association(),
                bridge=SyntheticCommandBridge(), documentary_resolver=resolver)
    args.update(changes)
    return compose_synthetic_path(**args)


class P1SyntheticPathTests(unittest.TestCase):
    def test_documented_identity_and_integrity(self):
        result = invoke()
        self.assertEqual(result["status"], "SYNTHETIC_PATH_VERIFIED_OFFLINE")
        self.assertEqual(result["sha256"], hashlib.sha256(RAW).hexdigest())
        self.assertEqual(result["payload_bytes"], len(RAW))
        self.assertEqual(result["identity_state"], "KNOWN_DOCUMENTED")
        self.assertEqual(result["scientific_decision"], "NOT_PERFORMED")
        self.assertNotIn(RAW, result.values())
        self.assertEqual(set(result), {"status", "observation_id", "sha256",
            "payload_bytes", "signal_id", "documentary_nct", "identity_state",
            "evidence_boundary", "scientific_decision"})

    def test_unknown_identity_remains_unknown(self):
        result = invoke(association=association("NCT07836491"))
        self.assertEqual(result["identity_state"], "NOT_IDENTIFIED_IN_SCOPED_INVENTORY")

    def test_optional_documentary_link_absent(self):
        result = invoke(association=association(None))
        self.assertIsNone(result["identity_state"])
        self.assertIsNone(result["documentary_nct"])

    def test_unknown_documentary_nct_fails_closed(self):
        with self.assertRaisesRegex(PersistenceHold, "^HOLD:"):
            invoke(association=association("NCT00000000"))

    def test_observation_mismatch_fails_closed(self):
        bad = association()
        bad["observation_id"] = "DIFFERENT"
        with self.assertRaises(PersistenceHold):
            invoke(association=bad)

    def test_bad_payload_fails_closed(self):
        with self.assertRaises(PersistenceHold):
            invoke(raw=b"")

    def test_d1_failure_sanitized(self):
        class RejectingBridge:
            def create_scenario(self, **kwargs):
                raise RuntimeError("SECRET_NOT_FOR_OUTPUT")
        with self.assertRaises(PersistenceHold) as error:
            invoke(bridge=RejectingBridge())
        self.assertNotIn("SECRET", str(error.exception))

    def test_explicit_association_required(self):
        with self.assertRaises(PersistenceHold):
            invoke(association={})


if __name__ == "__main__":
    unittest.main()
