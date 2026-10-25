"""D2-I-B composed Django/E6 offline test; never opens real DB connections.

Only test-scoped sys.path insertion to resolve legacy E6 sibling imports.
"""
import sys
from pathlib import Path
from contextlib import contextmanager
from datetime import datetime, timezone
from hashlib import sha256
from django.test import SimpleTestCase
from evidence.services import run_synthetic_private_roundtrip, SyntheticRoundtripHold


@contextmanager
def legacy_e6_path():
    root = Path(__file__).resolve().parents[4] / "tools" / "d2_e5_preservation"
    if not (root / "e6_g2_identity_gate_offline.py").is_file():
        raise AssertionError("E6 source unavailable")
    sys.path.insert(0, str(root))
    try:
        from e6_g2_identity_gate_offline import synthetic_g2_preflight_roundtrip, IDENTITY_SQL
        yield synthetic_g2_preflight_roundtrip, IDENTITY_SQL
    finally:
        sys.path.remove(str(root))


RAW = b'{"synthetic":true}'
T = datetime(2026, 10, 25, tzinfo=timezone.utc)


def provenance():
    return {
        "observation_id": "SYNTH-D2-I-B", "activity_id": "OES/SYNTHETIC",
        "repository_commit_sha": "a" * 40, "github_run_id": 1, "run_attempt": 1,
        "source_name": "ClinicalTrials.gov API v2",
        "requested_url_exact": "https://example.invalid/synthetic",
        "started_at_utc": T, "completed_at_utc": T, "source_http_status": 200,
        "response_content_type": "application/json",
    }


class MockConnection:
    autocommit = False

    def __init__(self, role, writer=None):
        self.role = role
        self.writer = writer
        self.pending = self.committed = None
        self.commits = self.reads = self.inserts = 0
        self.corrupt = False
        self.identity = ("oes_sandbox", "mock_" + role, "oes_e6_" + role,
                         True, role == "writer", role == "verifier")

    def cursor(self):
        return MockCursor(self)

    def commit(self):
        self.committed = self.pending
        self.commits += 1

    def rollback(self):
        self.pending = None


class MockCursor:
    def __init__(self, conn):
        self.c = conn
        self.row = None

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql, params=None):
        if sql.startswith("SELECT current_database()"):
            self.row = self.c.identity
        elif sql.startswith("INSERT INTO oes_raw_private.source_observation"):
            self.c.inserts += 1
            self.c.pending = (params[0], params[-3], params[-2], params[-1])
        elif sql.startswith("SELECT observation_id, payload_sha256, payload_bytes, raw_payload"):
            self.c.reads += 1
            value = self.c.writer.committed
            self.row = (value[0], value[1], value[2], b"tampered" if self.c.corrupt else value[3])
        else:
            raise AssertionError("unexpected query")

    def fetchone(self):
        return self.row


def connections():
    w = MockConnection("writer")
    return w, MockConnection("verifier", writer=w)


class E6DjangoCompositionTests(SimpleTestCase):
    def call_service(self, orchestrator, w, v):
        return run_synthetic_private_roundtrip(
            enabled=True, raw=RAW, provenance=provenance(),
            writer_connection=w, verifier_connection=v, orchestrator=orchestrator)

    def test_real_e6_adapter_sequence_synthetic_success(self):
        with legacy_e6_path() as (orchestrator, _):
            w, v = connections()
            result = self.call_service(orchestrator, w, v)
        self.assertEqual(result["status"], "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE")
        self.assertEqual(result["sha256"], sha256(RAW).hexdigest())
        self.assertEqual(result["payload_bytes"], len(RAW))
        self.assertEqual(w.commits, 1)
        self.assertEqual(w.inserts, 1)
        self.assertEqual(v.reads, 1)
        self.assertNotIn("raw_payload", result)

    def test_identity_acl_failure_prevents_commit(self):
        with legacy_e6_path() as (orchestrator, _):
            w, v = connections()
            v.identity = ("oes_sandbox", "mock_verifier", "oes_e6_verifier",
                          True, True, True)
            with self.assertRaises(SyntheticRoundtripHold):
                self.call_service(orchestrator, w, v)
        self.assertEqual(w.commits, 0)
        self.assertEqual(w.inserts, 0)

    def test_post_commit_corrupt_readback_holds_without_retry(self):
        with legacy_e6_path() as (orchestrator, _):
            w, v = connections()
            v.corrupt = True
            with self.assertRaisesRegex(SyntheticRoundtripHold, "may be committed") as error:
                self.call_service(orchestrator, w, v)
        self.assertEqual(w.commits, 1)
        self.assertEqual(w.inserts, 1)
        self.assertEqual(v.reads, 1)
        self.assertIsNone(error.exception.__cause__)

    def test_same_connection_blocked_before_sql(self):
        with legacy_e6_path() as (orchestrator, _):
            w, _ = connections()
            with self.assertRaises(SyntheticRoundtripHold):
                self.call_service(orchestrator, w, w)
        self.assertEqual(w.commits, 0)
        self.assertEqual(w.inserts, 0)
