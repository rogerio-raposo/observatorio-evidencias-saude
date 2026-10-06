#!/usr/bin/env python3
"""Validate the rendered OES Real N3-01 experimental A0 product.

This validator is intentionally separate from the synthetic N3 fixture validator.
It proves that the real-case RapidEvidenceSynthesisView renders its true A0,
non-publishable, human-control-blocked state without altering scientific content.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--rendered", required=True)
    args = parser.parse_args()

    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    rendered = Path(args.rendered).read_text(encoding="utf-8")

    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        payload.get("schema_version") == "oes.rapid_evidence_synthesis_view/0.1",
        "Unexpected RapidEvidenceSynthesisView schema version",
    )

    identity = payload["identity"]
    investigation = payload["investigation"]
    audit = payload["audit"]

    require(identity["product_id"] == "OES-P-2026-000701", "Wrong real N3 product")
    require(identity["editorial_status"] == "under_review", "Real N3 must remain under review")
    require(investigation["depth_level"] == "N3", "Real case must remain N3")
    require(investigation["maintenance_level"] == "M1", "Real case must remain M1")
    require(audit["assurance_level"] == "A0", "Real N3 must remain A0 before adversarial verification")
    require(audit["publishable"] is False, "Real N3 A0 must remain non-publishable")
    require(
        audit["qualified_controls_satisfied"] is False,
        "Real N3 must not satisfy qualified human controls",
    )
    require(
        audit["expert_independent_reviewed"] is False,
        "Real N3 must not fabricate expert independent review",
    )
    require(
        audit["protocol_deviations_open"] is False,
        "Mitigated Europe PMC deviation must not remain open",
    )

    require(len(payload["rapid_method"]["restrictions"]) == 5, "Expected five rapid restrictions")
    require(len(payload["rapid_method"]["deviations"]) == 1, "Expected one protocol deviation")
    require(len(payload["searches"]) == 3, "Expected three recorded search channels after correction")
    require(payload["selection_flow"]["search_hits_materialized"] == 20, "Expected 20 materialized hits after correction")
    require(payload["selection_flow"]["screening_decisions"] == 34, "Expected 34 screening decisions after correction")
    require(len(payload["included_evidence"]) == 13, "Expected 13 used/contextual reports after correction")
    require(len(payload["references"]) == 13, "Expected 13 references after correction")
    require(len(payload["results"]) == 11, "Expected 11 structured results")
    require(len(payload["risk_of_bias"]) == 10, "Expected 10 appraisal records")
    require(len(payload["syntheses"]) == 4, "Expected four narrative syntheses")
    require(len(payload["certainty"]) == 4, "Expected four experimental GRADE assessments")
    require(len(payload["quality_controls"]) == 6, "Expected six AI quality controls")
    require(len(audit["missing_controls"]) == 6, "Expected six missing qualified controls")

    for qc in payload["quality_controls"]:
        require(qc["actor_type"] == "ai_system", "Real N3 QC must remain AI")
        require(qc["qualified"] is False, "AI QC must not be marked qualified")
        require(qc["independent"] is False, "AI QC must not impersonate independent human review")

    levels = sorted(item["final_level"] for item in payload["certainty"])
    require(levels == ["low", "low", "low", "very_low"], "Unexpected GRADE pattern")

    issue_codes = {item["issue_code"] for item in audit["publication_issues"]}
    required_issues = {
        "MISSING_AI_METHODOLOGICAL_VERIFICATION",
        "MISSING_OWNER_APPROVAL",
        "MISSING_EXPERT_INDEPENDENT_REVIEW",
        "ASSURANCE_BELOW_A3",
        "MISSING_PUBLICATION_DATE",
        "MISSING_SEARCH_STRATEGY_VERIFICATION",
        "MISSING_SCREENING_PILOT",
        "MISSING_QUALIFIED_SCREENING_VERIFICATION",
        "MISSING_QUALIFIED_DATA_VERIFICATION",
        "MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION",
        "MISSING_QUALIFIED_CERTAINTY_VERIFICATION",
    }
    require(required_issues.issubset(issue_codes), "Expected real N3 gate blockers are incomplete")

    required_rendered = [
        "EXPERIMENTAL — NÃO PUBLICÁVEL COMO N3 FORMAL",
        "PREVIEW — GATE DE PUBLICAÇÃO NÃO APROVADO",
        "A0 — não verificada",
        "Controles qualificados ainda ausentes",
        "A2 ou nível inferior não autoriza publicação N3 formal",
        "EUROPE_PMC_RUNTIME_ACCESS_FAILURE",
        "Real-World Evidence Synthesis of Digital Scribes",
        "MISSING_AI_METHODOLOGICAL_VERIFICATION",
        "MISSING_OWNER_APPROVAL",
        "MISSING_EXPERT_INDEPENDENT_REVIEW",
        "ASSURANCE_BELOW_A3",
        "MISSING_SEARCH_STRATEGY_VERIFICATION",
        "MISSING_SCREENING_PILOT",
        "MISSING_QUALIFIED_SCREENING_VERIFICATION",
        "MISSING_QUALIFIED_DATA_VERIFICATION",
        "MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION",
        "MISSING_QUALIFIED_CERTAINTY_VERIFICATION",
        "Ambient AI scribes podem reduzir",
        "segurança",
    ]
    for text in required_rendered:
        require(text in rendered, f"Required real-N3 rendered disclosure missing: {text}")

    require(
        "**Gate de publicação N3:** aprovado" not in rendered,
        "A0 real N3 render incorrectly shows approved publication gate",
    )
    require(
        "A3 + controles qualificados satisfeitos" not in rendered,
        "A0 real N3 render incorrectly claims A3/qualified controls",
    )

    print("RN3-TEMPLATE-A0 validation PASS")


if __name__ == "__main__":
    main()
