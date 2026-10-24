"""G2-P3 offline identity checks: all sessions are synthetic mocks."""
import unittest
from datetime import datetime, timezone

from e6_private_pg_offline import PersistenceHold
from e6_g2_identity_gate_offline import (
    IDENTITY_SQL, validate_injected_identities, synthetic_g2_preflight_roundtrip,
)

RAW = b'{"synthetic":true}'


def provenance():
    t = datetime(2026, 10, 24, tzinfo=timezone.utc)
    return dict(observation_id="SYNTH-G2-P3", activity_id="OES/SYNTHETIC",
        repository_commit_sha="a"*40, github_run_id=1, run_attempt=1,
        source_name="ClinicalTrials.gov API v2", requested_url_exact="https://example.invalid/synthetic",
        started_at_utc=t, completed_at_utc=t, source_http_status=200,
        response_content_type="application/json")


class Cursor:
    def __init__(self, c):
        self.c = c
    def __enter__(self):
        return self
    def __exit__(self, *args):
        return False
    def execute(self, sql, params=None):
        if sql == IDENTITY_SQL:
            if self.c.fail:
                raise RuntimeError("SENSITIVE_IDENTITY_ERROR")
            self.c.identity_reads += 1
        elif self.c.kind == "writer":
            self.c.pending = (params[0], params[-3], params[-2], params[-1])
        else:
            self.c.read_queries += 1
    def fetchone(self):
        if self.c.identity_reads > self.c.identity_consumed:
            self.c.identity_consumed += 1
            return self.c.row
        return self.c.writer.committed


class Connection:
    autocommit = False
    def __init__(self, kind, row, writer=None, fail=False):
        self.kind, self.row, self.writer, self.fail = kind, row, writer, fail
        self.identity_reads = self.identity_consumed = self.read_queries = 0
        self.pending = self.committed = None
        self.commits = 0
    def cursor(self):
        return Cursor(self)
    def commit(self):
        self.committed = self.pending
        self.commits += 1
    def rollback(self):
        self.pending = None


def pair():
    w = Connection("writer", ("oes_sandbox", "app_writer_tmp", "oes_e6_writer", True, True, False))
    v = Connection("verifier", ("oes_sandbox", "app_verifier_tmp", "oes_e6_verifier", True, False, True), writer=w)
    return w, v


class IdentityGateTests(unittest.TestCase):
    def test_identity_gate_passes_two_separate_mocks(self):
        w, v = pair()
        self.assertIsNone(validate_injected_identities(w, v))
        self.assertEqual(w.commits, 0)

    def test_synthetic_integrated_flow(self):
        w, v = pair()
        out = synthetic_g2_preflight_roundtrip(RAW, provenance(), w, v)
        self.assertEqual(out["status"], "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE")
        self.assertEqual(w.commits, 1)
        self.assertEqual(v.read_queries, 1)
        self.assertNotIn("synthetic", str(out))

    def test_reject_shared_object_before_write(self):
        w, _ = pair()
        with self.assertRaises(PersistenceHold):
            synthetic_g2_preflight_roundtrip(RAW, provenance(), w, w)
        self.assertEqual(w.commits, 0)

    def test_reject_shared_login_before_write(self):
        w, v = pair()
        v.row = ("oes_sandbox", "app_writer_tmp", "oes_e6_verifier", True, False, True)
        with self.assertRaises(PersistenceHold):
            synthetic_g2_preflight_roundtrip(RAW, provenance(), w, v)
        self.assertEqual(w.commits, 0)

    def test_reject_cross_grant_before_write(self):
        w, v = pair()
        w.row = ("oes_sandbox", "app_writer_tmp", "oes_e6_writer", True, True, True)
        with self.assertRaises(PersistenceHold):
            synthetic_g2_preflight_roundtrip(RAW, provenance(), w, v)
        self.assertEqual(w.commits, 0)

    def test_reject_owner_login(self):
        w, v = pair()
        w.row = ("oes_sandbox", "oes_sandbox_owner", "oes_e6_writer", True, True, False)
        with self.assertRaises(PersistenceHold):
            validate_injected_identities(w, v)

    def test_reject_malformed_identity(self):
        w, v = pair()
        v.row = ("oes_sandbox", "app_verifier_tmp")
        with self.assertRaises(PersistenceHold):
            validate_injected_identities(w, v)

    def test_sanitize_exception(self):
        w, v = pair()
        v.fail = True
        with self.assertRaises(PersistenceHold) as e:
            validate_injected_identities(w, v)
        self.assertNotIn("SENSITIVE", str(e.exception))


if __name__ == "__main__":
    unittest.main()
