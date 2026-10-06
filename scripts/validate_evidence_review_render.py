#!/usr/bin/env python3
"""Structural and governance validation for OES Evidence Review N4 renders."""

from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def validate_formal_synthetic(
    template: str,
    payload: dict,
    rendered: str,
) -> None:
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.evidence_review.template/0.1" in template,
        "N4 template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_review_view/0.1",
        "Unexpected EvidenceReviewView schema version",
    )

    identity = payload["identity"]
    investigation = payload["investigation"]
    audit = payload["audit"]

    require(investigation["depth_level"] == "N4", "Fixture must remain N4")
    require(payload["subtype"] == "systematic_review_intervention", "Unexpected N4 subtype")
    require(audit["synthetic_fixture"] is True, "Formal fixture must be explicitly synthetic")
    require(audit["assurance_level"] == "A3", "Formal fixture must derive A3")
    require(audit["publishable"] is True, "Formal synthetic fixture must pass gate")
    require(
        audit["qualified_stage_controls_satisfied"] is True,
        "Formal synthetic fixture must satisfy qualified stage controls",
    )
    require(
        audit["expert_independent_reviewed"] is True,
        "Formal synthetic fixture must include synthetic expert review",
    )
    require(audit["readiness_state"] == "ready", "Formal fixture readiness must be ready")
    require(
        audit["invalidated_dependencies"] is False,
        "Formal fixture must not have invalidated dependencies",
    )

    for value in [
        identity["title"],
        identity["product_id"],
        payload["question"]["normalized_text"],
        payload["conclusion"]["text"],
        payload["limitations"]["summary"],
    ]:
        require(value and value in rendered, f"Required rendered value missing: {value!r}")

    require(
        "FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL" in rendered,
        "Synthetic-fixture banner missing",
    )
    require(
        "Revisores, expert review e A3 deste artefato são sintéticos" in rendered,
        "Synthetic reviewer/A3 disclosure missing",
    )
    require(
        "Gate de publicação N4: aprovado." in rendered,
        "Formal synthetic N4 gate approval missing",
    )
    require(
        "**Gate de publicação N4:** aprovado" in rendered,
        "Formal audit gate status missing",
    )
    require(
        "A3 + stage controls qualificados + gate N4 satisfeitos" in rendered,
        "Formal stage-control disclosure missing",
    )

    require(len(payload["reviewer_assignments"]) == 12, "Expected 12 reviewer assignments")
    require(len(payload["searches"]) == 3, "Expected three bibliographic searches")
    require(len(payload["search_peer_review"]) == 1, "Expected one search peer review")
    require(len(payload["study_characteristics"]) == 2, "Expected two contributing studies")
    require(len(payload["risk_of_bias"]) == 2, "Expected two study-level appraisals")
    require(len(payload["missing_evidence"]) == 1, "Expected one ROB-ME appraisal")
    require(len(payload["results"]) == 2, "Expected two structured results")
    require(len(payload["syntheses"]) == 1, "Expected one meta-analysis synthesis")
    require(len(payload["heterogeneity"]) == 1, "Expected heterogeneity projection")
    require(len(payload["sensitivity_analyses"]) == 2, "Expected two sensitivity contributions")
    require(len(payload["certainty"]) == 1, "Expected one certainty assessment")
    require(payload["certainty"][0]["final_level"] == "moderate", "Expected moderate certainty")
    require(len(payload["summary_of_findings"]) == 1, "Expected one Summary of Findings")
    require(len(payload["references"]) == 2, "Expected two source references")

    require(
        len(payload["extraction_controls"]["independent_extractions"]) == 4,
        "Expected four independent extraction records",
    )
    require(
        len(payload["extraction_controls"]["verification_controls"]) == 1,
        "Expected one critical-data verification control",
    )
    require(
        len(payload["method"]["quality_controls"]) == 6,
        "Expected six N4 stage quality controls",
    )

    for item in payload["reviewer_assignments"]:
        require(
            item["actor_type"] in {"human_reviewer", "human_expert"},
            "Reviewer assignment cannot be AI",
        )
        require(item["independent"] is True, "Fixture assignments must be independent")
        require("SYN_N4_" in item["actor"], "Fixture reviewer actor must be visibly synthetic")

    issue_codes = {item["issue_code"] for item in audit["publication_issues"]}
    require(
        "GREY_LITERATURE_LIMITED" in issue_codes,
        "Expected non-blocking grey-literature warning absent",
    )
    require(
        "GREY_LITERATURE_LIMITED" in rendered,
        "Expected warning not rendered",
    )

    require(
        any(
            item["assurance_type"] == "expert_independent_review"
            and item["actor"] == "SYN_N4_EXPERT"
            for item in audit["assurance_records"]
        ),
        "Synthetic expert assurance record missing",
    )
    require("SYN_N4_EXPERT" in rendered, "Synthetic expert actor not rendered")


def validate_a3_blocked_presentation(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    blocked = copy.deepcopy(payload)
    blocked["audit"]["publishable"] = False
    blocked["audit"]["assurance_level"] = "A3"
    blocked["audit"]["qualified_stage_controls_satisfied"] = False
    blocked["audit"]["publication_issues"] = list(
        blocked["audit"].get("publication_issues", [])
    ) + [
        {
            "issue_code": "MISSING_SEARCH_PEER_REVIEW",
            "severity": "error",
            "message": "Synthetic adversarial presentation blocker.",
        }
    ]

    rendered = render(template, blocked, presentation)

    require(
        "GATE DE PUBLICAÇÃO N4 NÃO APROVADO" in rendered,
        "A3-blocked presentation must show blocked gate banner",
    )
    require(
        "**Gate de publicação N4:** não aprovado" in rendered,
        "A3-blocked audit state must show gate not approved",
    )
    require(
        "A3 — revisão especializada independente" in rendered,
        "A3 must remain visible in blocked scenario",
    )
    require(
        "A3, quando presente, não substitui stage controls" in rendered,
        "A3 non-bypass disclosure missing",
    )
    require(
        "MISSING_SEARCH_PEER_REVIEW" in rendered,
        "Synthetic gate blocker not rendered",
    )
    require(
        "Gate de publicação N4: aprovado." not in rendered,
        "Blocked A3 scenario incorrectly displays approved top gate",
    )
    require(
        "A3 + stage controls qualificados + gate N4 satisfeitos" not in rendered,
        "Blocked A3 scenario incorrectly claims stage controls satisfied",
    )
    require(
        "FIXTURE SINTÉTICA — NÃO REPRESENTA REVISÃO HUMANA REAL" in rendered,
        "Synthetic disclosure must survive blocked scenario",
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

    validate_formal_synthetic(template, payload, rendered)
    validate_a3_blocked_presentation(template, payload, presentation)

    print("F3-ER4-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
