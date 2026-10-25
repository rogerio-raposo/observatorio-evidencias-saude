"""D2-I-A strictly offline service tests; no database credentials or network."""
from unittest.mock import Mock, patch
from uuid import UUID
from django.test import SimpleTestCase
from evidence.services import (SyntheticReadHold, get_synthetic_study_report_links,
                               get_signal, list_signals)
from evidence.synthetic_pg_reader import SyntheticStudyReportLink


class SyntheticIntegrationContractTests(SimpleTestCase):
    def test_default_fails_without_invoking_reader(self):
        reader = Mock()
        with self.assertRaisesRegex(SyntheticReadHold, "not explicitly enabled"):
            get_synthetic_study_report_links(reader=reader)
        reader.assert_not_called()

    def test_false_or_truthy_nonboolean_cannot_enable(self):
        reader = Mock()
        for enabled in (False, None, 1, "true"):
            with self.subTest(enabled=enabled):
                with self.assertRaises(SyntheticReadHold):
                    get_synthetic_study_report_links(enabled=enabled, reader=reader)
        reader.assert_not_called()

    def test_valid_injected_projection(self):
        ids = [UUID(f"10000000-0000-4000-8000-{n:012d}") for n in range(1, 6)]
        record = SyntheticStudyReportLink(*ids[:4], "reports", ids[4], "title")
        reader = Mock(return_value=(record,))
        self.assertEqual(get_synthetic_study_report_links(enabled=True, reader=reader), (record,))
        reader.assert_called_once_with()

    def test_pg_errors_are_sanitized(self):
        reader = Mock(side_effect=RuntimeError("PRIVATE HOST AND PASSWORD"))
        with self.assertRaises(SyntheticReadHold) as ctx:
            get_synthetic_study_report_links(enabled=True, reader=reader)
        self.assertNotIn("PRIVATE", str(ctx.exception))
        self.assertIsNone(ctx.exception.__cause__)

    def test_rejects_invalid_result_and_boundary(self):
        for result in ([], ("untrusted",), (Mock(evidence_boundary="SYNTHETIC_TECHNICAL_ONLY"),)):
            with self.subTest(result_type=type(result)):
                with self.assertRaisesRegex(SyntheticReadHold, "unavailable"):
                    get_synthetic_study_report_links(enabled=True, reader=lambda: result)

    def test_documentary_catalog_unchanged_and_pg_not_called(self):
        with patch("evidence.synthetic_pg_reader.list_synthetic_study_report_links") as pg:
            self.assertEqual(tuple(x.nct for x in list_signals()), ("NCT01438697", "NCT07836491"))
            self.assertEqual(get_signal("NCT01438697").nct, "NCT01438697")
            self.assertIsNone(get_signal("NCT00000000"))
            pg.assert_not_called()
