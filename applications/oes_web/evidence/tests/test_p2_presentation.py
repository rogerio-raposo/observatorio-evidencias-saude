import hashlib
import json
from unittest.mock import patch

from django.test import SimpleTestCase
from django.urls import reverse

from evidence.p2_presentation import (
    EXPECTED, SyntheticPresentationHold, load_example, validate_receipt,
)


class P2PresentationTests(SimpleTestCase):
    def test_01_sample_has_explicit_synthetic_boundary(self):
        self.assertEqual(load_example()["evidence_boundary"], "SYNTHETIC_TECHNICAL_ONLY")

    def test_02_scientific_decision_not_performed(self):
        self.assertEqual(load_example()["scientific_decision"], "NOT_PERFORMED")

    def test_03_no_raw_payload_field(self):
        self.assertEqual(set(load_example()), set(EXPECTED))
        self.assertNotIn("raw_payload", load_example())

    def test_04_no_raw_or_secrets_in_page(self):
        page = self.client.get(reverse("synthetic-path")).content.decode()
        self.assertNotIn('{"synthetic":true,"component":"p1-a3"}', page)
        self.assertNotIn("SECRET_NOT_FOR_OUTPUT", page)

    def test_05_explicit_association_only(self):
        with self.assertRaises(SyntheticPresentationHold):
            validate_receipt({**EXPECTED, "signal_id": "derived-from-nct"})

    def test_06_reject_invented_documentary_nct(self):
        with self.assertRaises(SyntheticPresentationHold):
            validate_receipt({**EXPECTED, "documentary_nct": "NCT00000000"})

    def test_07_example_fingerprint(self):
        raw = b'{"synthetic":true,"component":"p1-a3"}'
        self.assertEqual(hashlib.sha256(raw).hexdigest(), load_example()["sha256"])
        self.assertEqual(len(raw), load_example()["payload_bytes"])

    def test_08_example_provenance_is_not_historical_receipt(self):
        self.assertContains(self.client.get(reverse("synthetic-path")), "não é recibo recuperado")

    def test_09_invalid_digest_holds(self):
        with self.assertRaisesRegex(SyntheticPresentationHold, "^HOLD:"):
            validate_receipt({**EXPECTED, "sha256": "0" * 64})

    def test_10_invalid_identity_holds(self):
        with self.assertRaises(SyntheticPresentationHold):
            validate_receipt({**EXPECTED, "identity_state": "KNOWN_NEW"})

    def test_11_get_and_post_routes(self):
        path = reverse("synthetic-path")
        self.assertEqual(self.client.get(path).status_code, 200)
        self.assertEqual(self.client.post(path).status_code, 404)

    def test_12_unrecognized_route(self):
        self.assertEqual(self.client.get("/synthetic-path/not-a-page/").status_code, 404)

    def test_13_catalog_unaffected(self):
        self.assertContains(self.client.get("/"), "NCT01438697")

    def test_14_documentary_detail_unaffected(self):
        self.assertContains(self.client.get("/signals/NCT01438697/"), "Ritterband 2017")
        self.assertContains(self.client.get("/signals/NCT07836491/"), "Não reconciliado")

    def test_15_no_orchestrator_or_network_for_p2(self):
        with patch("evidence.p2_presentation.get_signal", side_effect=RuntimeError("SECRET_NOT_FOR_OUTPUT")):
            response = self.client.get(reverse("synthetic-path"))
        self.assertEqual(response.status_code, 503)
        self.assertNotIn(b"SECRET_NOT_FOR_OUTPUT", response.content)
        self.assertNotIn(b"SYNTHETIC_PATH_VERIFIED_OFFLINE", response.content)

    def test_16_semantic_sections_and_navigation(self):
        response = self.client.get(reverse("synthetic-path"))
        self.assertContains(response, 'lang="pt-BR"')
        self.assertContains(response, 'aria-labelledby="path-title"')
        self.assertContains(response, 'aria-label="Navegação documental"')
        self.assertContains(response, "Retornar ao catálogo")
