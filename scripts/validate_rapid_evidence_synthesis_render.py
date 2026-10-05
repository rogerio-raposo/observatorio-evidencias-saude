#!/usr/bin/env python3
"""Structural validation for OES Rapid Evidence Synthesis N3 renders."""

from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def validate_experimental(
    template: str,
    payload: dict,
    rendered: str,
) -> None:
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.rapid_evidence_synthesis.template/0.1" in template,
        "N3 template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.rapid_evidence_synthesis_view/0.1",
        "Unexpected RapidEvidenceSynthesisView schema version",
    )

    identity = payload["identity"]
    question = payload["question"]
    investigation = payload["investigation"]
    audit = payload["audit"]

    for value in [
        identity["title"],
        identity["product_id"],
        question["normalized_text"],
        payload["decision_context"]["objective"],
        payload["conclusion"]["text"],
        payload["rapid_method_limitations"]["summary"],
    ]:
        require(value and value in rendered, f"Required rendered value missing: {value!r}")

    require(investigation["depth_level"] == "N3", "Fixture must remain N3")
    require(audit["assurance_level"] == "A2", "Experimental fixture must derive A2")
    require(audit["publishable"] is False, "Experimental fixture must remain non-publishable")
    require(
        audit["qualified_controls_satisfied"] is False,
        "Experimental fixture must lack qualified human controls",
    )
    require(
        audit["expert_independent_reviewed"] is False,
        "Experimental fixture must not fabricate expert review",
    )

    restrictions = payload["rapid_method"]["restrictions"]
    require(len(restrictions) == 3, "Expected three rapid restrictions")
    for item in restrictions:
        require(item["code"] in rendered, f"Rapid restriction missing: {item['code']}")

    require(
        len(payload["quality_controls"]) == 6,
        "Expected six transparent AI quality controls",
    )
    for qc in payload["quality_controls"]:
        require(qc["actor_type"] == "ai_system", "Persistent fixture QC must be AI")
        require(qc["qualified"] is False, "AI QC must not be marked qualified")

    missing = audit["missing_controls"]
    require(len(missing) == 6, "Expected six missing qualified controls")
    for item in missing:
        require(
            item["control_code"] in rendered,
            f"Missing-control blocker absent from render: {item['control_code']}",
        )

    require(
        "EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL" in rendered,
        "Experimental N3 warning missing",
    )
    require(
        "PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO" in rendered,
        "N3 gate preview warning missing",
    )
    require(
        "Controles qualificados ainda ausentes" in rendered,
        "Missing-controls section missing",
    )
    require(
        "A2 ou nível inferior não autoriza publicação N3 formal" in rendered,
        "A2 non-publication disclosure missing",
    )

    issue_codes = {
        item["issue_code"] for item in audit["publication_issues"]
    }
    for code in [
        "MISSING_EXPERT_INDEPENDENT_REVIEW",
        "ASSURANCE_BELOW_A3",
        "MISSING_SEARCH_STRATEGY_VERIFICATION",
        "MISSING_SCREENING_PILOT",
        "MISSING_QUALIFIED_SCREENING_VERIFICATION",
        "MISSING_QUALIFIED_DATA_VERIFICATION",
        "MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION",
        "MISSING_QUALIFIED_CERTAINTY_VERIFICATION",
    ]:
        require(code in issue_codes, f"Expected publication issue absent: {code}")
        require(code in rendered, f"Publication issue not rendered: {code}")

    require(
        len(payload["included_evidence"]) == 2,
        "Expected two included evidence reports",
    )
    require(len(payload["risk_of_bias"]) == 2, "Expected two risk assessments")
    require(len(payload["syntheses"]) == 1, "Expected one synthesis")
    require(len(payload["certainty"]) == 1, "Expected one certainty assessment")
    require(
        payload["certainty"][0]["final_level"] == "moderate",
        "Expected synthetic moderate certainty",
    )


def validate_formal_presentation(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    formal = copy.deepcopy(payload)
    formal["identity"]["editorial_status"] = "published"
    formal["audit"]["publishable"] = True
    formal["audit"]["assurance_level"] = "A3"
    formal["audit"]["expert_independent_reviewed"] = True
    formal["audit"]["qualified_controls_satisfied"] = True
    formal["audit"]["missing_controls"] = []
    formal["audit"]["publication_issues"] = [
        {
            "issue_code": "RAPID_METHOD_RESTRICTIONS_PRESENT",
            "severity": "warning",
            "message": "Rapid-method restrictions remain visible.",
        }
    ]

    for qc in formal["quality_controls"]:
        qc["actor"] = "SYNTHETIC_QUALIFIED_REVIEWER"
        qc["actor_type"] = "human_expert"
        qc["qualified"] = True
        qc["independent"] = True

    formal["audit"]["assurance_records"] = list(
        formal["audit"].get("assurance_records", [])
    ) + [
        {
            "assurance_type": "expert_independent_review",
            "actor": "SYNTHETIC_QUALIFIED_REVIEWER",
            "actor_type": "human_expert",
            "independent": True,
            "decision": "approved",
            "performed_at": "2026-10-05T20:07:00-03:00",
            "status": "active",
        }
    ]

    rendered = render(template, formal, presentation)

    require(
        "EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL" not in rendered,
        "Formal A3 presentation incorrectly marked experimental",
    )
    require(
        "PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO" not in rendered,
        "Formal A3 presentation incorrectly marked preview",
    )
    require(
        "**Gate de publicação N3:** aprovado" in rendered,
        "Formal A3 presentation missing approved gate",
    )
    require(
        "A3 + controles qualificados satisfeitos" in rendered,
        "Formal A3 qualified-control disclosure missing",
    )
    require(
        "Controles qualificados ainda ausentes" not in rendered,
        "Formal A3 presentation still shows missing-controls section",
    )
    require(
        "revisão especializada independente" in rendered.lower(),
        "Formal A3 presentation should expose expert assurance record",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--rendered", required=True)
    parser.add_argument("--presentation-map", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    rendered = Path(args.rendered).read_text(encoding="utf-8")
    presentation = json.loads(
        Path(args.presentation_map).read_text(encoding="utf-8")
    )

    validate_experimental(template, payload, rendered)
    validate_formal_presentation(template, payload, presentation)

    print("F3-RS-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
