"""D2-I-B offline Django orchestration seam contract tests; no connected SQL."""
from datetime import datetime, timezone
from unittest.mock import Mock, patch
from django.test import SimpleTestCase
from evidence.services import (SyntheticRoundtripHold, run_synthetic_private_roundtrip,
                               list_signals)

RAW = b'{"synthetic":true}'
PROV = {"synthetic": True}
RESULT = {"status": "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE",
          "observation_id": "SYNTH-LOCAL", "sha256": "a" * 64,
          "payload_bytes": len(RAW)}


class SyntheticRoundtripServiceTests(SimpleTestCase):
    def test_disabled_never_invokes_orchestrator(self):
        runner = Mock()
        with self.assertRaises(SyntheticRoundtripHold):
            run_synthetic_private_roundtrip(raw=RAW, provenance=PROV,
                                            writer_connection=object(), verifier_connection=object(),
                                            orchestrator=runner)
        runner.assert_not_called()

    def test_nonboolean_optin_rejected(self):
        runner = Mock()
        for enabled in (1, "true", None, False):
            with self.subTest(enabled=enabled):
                with self.assertRaises(SyntheticRoundtripHold):
                    run_synthetic_private_roundtrip(enabled=enabled, raw=RAW, provenance=PROV,
                                                    writer_connection=object(), verifier_connection=object(),
                                                    orchestrator=runner)
        runner.assert_not_called()

    def test_independent_connections_required(self):
        runner = Mock()
        shared = object()
        with self.assertRaises(SyntheticRoundtripHold):
            run_synthetic_private_roundtrip(enabled=True, raw=RAW, provenance=PROV,
                                            writer_connection=shared, verifier_connection=shared,
                                            orchestrator=runner)
        runner.assert_not_called()

    def test_result_sanitized_and_orchestrator_called_once(self):
        writer, verifier = object(), object()
        runner = Mock(return_value=RESULT)
        output = run_synthetic_private_roundtrip(enabled=True, raw=RAW, provenance=PROV,
                                                  writer_connection=writer, verifier_connection=verifier,
                                                  orchestrator=runner)
        self.assertEqual(output, RESULT)
        self.assertIsNot(output, RESULT)
        runner.assert_called_once_with(RAW, PROV, writer, verifier)

    def test_post_commit_error_never_retries_and_fails_closed(self):
        runner = Mock(side_effect=ValueError("PRIVATE_PASSWORD_AND_PAYLOAD"))
        with self.assertRaises(SyntheticRoundtripHold) as cm:
            run_synthetic_private_roundtrip(enabled=True, raw=RAW, provenance=PROV,
                                            writer_connection=object(), verifier_connection=object(),
                                            orchestrator=runner)
        self.assertIn("may be committed", str(cm.exception))
        self.assertNotIn("PRIVATE", str(cm.exception))
        self.assertIsNone(cm.exception.__cause__)
        runner.assert_called_once()

    def test_rejects_payload_in_return_contract(self):
        runner = Mock(return_value={**RESULT, "raw_payload": RAW})
        with self.assertRaises(SyntheticRoundtripHold):
            run_synthetic_private_roundtrip(enabled=True, raw=RAW, provenance=PROV,
                                            writer_connection=object(), verifier_connection=object(),
                                            orchestrator=runner)

    def test_documentary_catalog_unchanged(self):
        self.assertEqual(tuple(x.nct for x in list_signals()), ("NCT01438697", "NCT07836491"))
