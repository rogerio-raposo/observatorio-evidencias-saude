"""Synthetic, offline-only tests; never open a network connection."""
import hashlib
from dataclasses import replace
import unittest
from datetime import datetime, timezone

from e6_private_pg_offline import (
    INSERT_SQL, PersistenceHold, prepare_observation, persist_observation,
)


def provenance():
    return dict(
        observation_id="SYNTH-LOCAL-1", activity_id="OES/SYNTHETIC",
        repository_commit_sha="a" * 40, github_run_id=1, run_attempt=1,
        source_name="ClinicalTrials.gov API v2",
        requested_url_exact="https://example.invalid/synthetic",
        started_at_utc=datetime.now(timezone.utc),
        completed_at_utc=datetime.now(timezone.utc),
        source_http_status=200, response_content_type="application/json",
    )


class Cursor:
    def __init__(self, fail=False):
        self.fail = fail
        self.calls = []

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql, params):
        self.calls.append((sql, params))
        if self.fail:
            raise RuntimeError("SENSITIVE RAW CONTENT")
        

class Connection:
    def __init__(self, fail=False, autocommit=False):
        self.autocommit = autocommit
        self.cur = Cursor(fail)
        self.commits = 0
        self.rollbacks = 0

    def cursor(self):
        return self.cur

    def commit(self):
        self.commits += 1

    def rollback(self):
        self.rollbacks += 1


class OfflineTests(unittest.TestCase):
    def test_bytes_and_parameterization(self):
        raw = b'{"synthetic":true}'
        p = prepare_observation(raw, provenance())
        self.assertEqual(p.statement, INSERT_SQL)
        self.assertEqual(p.parameters[-1], raw)
        self.assertEqual(p.parameters[-2], len(raw))
        self.assertEqual(p.sha256, hashlib.sha256(raw).hexdigest())
        self.assertNotIn(raw.decode(), p.statement)
        c = Connection()
        result = persist_observation(c, p)
        self.assertEqual((c.commits, c.rollbacks), (1, 0))
        self.assertEqual(c.cur.calls[0][1][-1], raw)
        self.assertNotIn("raw_payload", str(result))

    def test_missing_provenance(self):
        with self.assertRaises(PersistenceHold):
            prepare_observation(b"{}", {})

    def test_oversize(self):
        with self.assertRaises(PersistenceHold):
            prepare_observation(b"x" * 2_000_001, provenance())

    def test_empty(self):
        with self.assertRaises(PersistenceHold):
            prepare_observation(b"", provenance())

    def test_type(self):
        with self.assertRaises(PersistenceHold):
            prepare_observation('{"synthetic":true}', provenance())

    def test_failure_rolls_back_and_sanitizes(self):
        p = prepare_observation(b'{"synthetic":true}', provenance())
        c = Connection(fail=True)
        with self.assertRaisesRegex(PersistenceHold, "HOLD: private persistence failed") as ctx:
            persist_observation(c, p)
        self.assertNotIn("SENSITIVE", str(ctx.exception))
        self.assertEqual((c.commits, c.rollbacks), (0, 1))

    def test_autocommit_denied(self):
        c = Connection(autocommit=True)
        with self.assertRaises(PersistenceHold):
            persist_observation(c, prepare_observation(b"{}", provenance()))
        self.assertEqual((c.commits, c.rollbacks), (0, 1))
        self.assertEqual(c.cur.calls, [])

    def test_invalid_status(self):
        meta = provenance()
        meta["source_http_status"] = 201
        with self.assertRaises(PersistenceHold):
            prepare_observation(b"{}", meta)

    def test_duplicate_insert_rolls_back_without_leak(self):
        p = prepare_observation(b"{}", provenance())
        c = Connection(fail=True)
        with self.assertRaises(PersistenceHold) as caught:
            persist_observation(c, p)
        self.assertNotIn("SENSITIVE", str(caught.exception))
        self.assertEqual((c.commits, c.rollbacks), (0, 1))

    def test_tampered_sha_prepared_rejected_before_db(self):
        p = prepare_observation(b"{}", provenance())
        altered = replace(p, sha256="0" * 64)
        c = Connection()
        with self.assertRaisesRegex(PersistenceHold, "integrity mismatch"):
            persist_observation(c, altered)
        self.assertEqual(c.cur.calls, [])

    def test_tampered_payload_prepared_rejected_before_db(self):
        p = prepare_observation(b"{}", provenance())
        altered = replace(p, parameters=p.parameters[:-1] + (b"[]",))
        c = Connection()
        with self.assertRaisesRegex(PersistenceHold, "integrity mismatch"):
            persist_observation(c, altered)
        self.assertEqual(c.cur.calls, [])

    def test_boundary_exact_cap(self):
        p = prepare_observation(b"x" * 2_000_000, provenance())
        self.assertEqual(p.byte_count, 2_000_000)

    def test_no_credentials_used(self):
        c = Connection()
        p = prepare_observation(b"{}", provenance())
        persist_observation(c, p)
        self.assertEqual(len(c.cur.calls), 1)


if __name__ == "__main__":
    unittest.main()
