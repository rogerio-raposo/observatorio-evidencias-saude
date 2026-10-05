#!/usr/bin/env python3
"""Structural validation for OES Evidence Sheet reference renders."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def validate_render(template: str, payload: dict, rendered: str) -> None:
    require("display." not in template, "Forbidden display.* placeholder remains")
    require("{{#unless" not in template, "Engine-specific unless helper remains")
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.evidence_sheet.template/0.2" in template,
        "Assurance-aware template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_sheet_view/0.1",
        "Unexpected EvidenceSheetView schema version",
    )

    audit = payload.get("audit") or {}
    assurance_level = audit.get("assurance_level")
    require(
        assurance_level in {"A0", "A1", "A2", "A3"},
        f"Invalid or missing assurance level: {assurance_level!r}",
    )
    require(
        audit.get("assurance_disclosure"),
        "Assurance disclosure missing from EvidenceSheetView",
    )

    identity = payload["identity"]
    question = payload["question"]
    conclusion = payload["conclusion"]
    limitations = payload["limitations"]
    applicability = payload["applicability"]
    audit = payload["audit"]

    required_texts = [
        identity["title"],
        identity["product_id"],
        question["normalized_text"],
        conclusion["text"],
        limitations["summary"],
        applicability["summary"],
    ]

    for value in required_texts:
        require(
            value and value in rendered,
            f"Required rendered value missing: {value!r}",
        )

    for item in payload.get("references", []):
        require(
            item["report_id"] in rendered,
            f"Reference ID missing: {item['report_id']}",
        )

    for item in payload.get("priority_results", []):
        synthesis = item["synthesis"]
        require(
            synthesis["synthesis_id"] in rendered,
            f"Synthesis ID missing from audit/render: {synthesis['synthesis_id']}",
        )
        certainty = item.get("certainty") or {}
        if certainty.get("formal_assessment"):
            require(
                certainty.get("framework") in rendered,
                "Formal certainty framework missing from render",
            )

    require(
        "Nível de garantia:" in rendered,
        "Rendered Evidence Sheet must expose assurance level",
    )
    require(
        audit.get("assurance_disclosure") in rendered,
        "Rendered Evidence Sheet must expose assurance disclosure verbatim",
    )

    if assurance_level == "A2":
        require(
            "revisão especializada independente não realizada" in rendered.lower(),
            "A2 render must disclose absence of expert independent review",
        )

    if assurance_level == "A3":
        require(
            audit.get("expert_independent_reviewed") is True,
            "A3 requires expert_independent_reviewed=true",
        )

    if audit.get("publishable"):
        require(
            "**Gate de publicação:** aprovado" in rendered,
            "Publishable product must show approved gate",
        )
        require(
            "PREVIEW — NÃO PUBLICÁVEL" not in rendered,
            "Publishable product incorrectly marked as preview",
        )
    else:
        require(
            "PREVIEW — NÃO PUBLICÁVEL" in rendered,
            "Non-publishable product must be marked as preview",
        )

    study_type_counts = payload.get("evidence_base", {}).get(
        "study_type_counts", []
    )
    require(study_type_counts, "EvidenceSheetView study_type_counts missing")
    require(
        "Tipos de Study:" in rendered,
        "Study type breakdown missing from rendered evidence base",
    )

    require(
        "## Auditoria e rastreabilidade" in rendered,
        "Audit section missing",
    )
    require(
        "## Atualidade e histórico" in rendered,
        "Update-history section missing",
    )
    require(
        "## Principais limitações" in rendered,
        "Limitations section missing",
    )


def validate_real_case(
    template: str,
    presentation: dict,
    snapshot_path: Path,
) -> None:
    payload = json.loads(snapshot_path.read_text(encoding="utf-8"))
    rendered = render(template, payload, presentation)

    output_path = snapshot_path.with_name("real-case-01-preview.md")
    output_path.write_text(rendered, encoding="utf-8")

    validate_render(template, payload, rendered)

    require(
        payload["identity"]["product_id"] == "OES-P-2026-000401",
        "RC01 product identity mismatch",
    )
    require(
        payload["identity"]["editorial_status"] == "under_review",
        "RC01 must remain under_review",
    )
    require(
        payload["audit"]["publishable"] is False,
        "RC01 must not be publishable before human review",
    )

    issue_codes = {
        item["issue_code"]
        for item in payload["audit"].get("publication_issues", [])
        if item.get("severity") == "error"
    }
    require(
        "MISSING_APPROVED_REVIEW" in issue_codes,
        "RC01 missing expected human-review publication block",
    )
    require(
        "MISSING_PUBLICATION_DATE" in issue_codes,
        "RC01 missing expected publication-date block",
    )

    priority = payload.get("priority_results", [])
    require(len(priority) == 3, "RC01 must expose three synthesis roles")
    require(
        priority[0]["role"] == "source"
        and priority[1]["role"] == "primary"
        and priority[2]["role"] == "corroborative",
        "RC01 synthesis role ordering mismatch",
    )
    require(
        priority[0]["synthesis"]["result_summary"]["reported_study_count"] == 10,
        "RC01 adopted synthesis must preserve reported k=10",
    )
    require(
        priority[0]["synthesis"]["result_summary"]["recalculated_by_oes"] is False,
        "RC01 adopted meta-analysis must not be marked as recalculated",
    )
    require(
        priority[1]["certainty"]["formal_assessment"] is True
        and priority[1]["certainty"]["final_level"] == "moderate"
        and priority[1]["certainty"]["framework"] == "GRADE",
        "RC01 provisional GRADE projection mismatch",
    )

    type_counts = {
        item["study_type"]: item["count"]
        for item in payload["evidence_base"]["study_type_counts"]
    }
    require(
        type_counts.get("primary_study") == 4,
        f"RC01 expected 4 directly modelled primary studies, got {type_counts}",
    )
    require(
        type_counts.get("systematic_review") == 2,
        f"RC01 expected 2 directly modelled systematic reviews, got {type_counts}",
    )

    require(
        "**k reportado pela síntese-base:** 10" in rendered,
        "RC01 rendered adopted-synthesis k missing",
    )
    require(
        "Meta-análise publicada adotada criticamente; não recalculada pelo OES."
        in rendered,
        "RC01 rendered non-recalculation note missing",
    )
    require(
        "PREVIEW — NÃO PUBLICÁVEL" in rendered,
        "RC01 preview warning missing",
    )

    print("RC01-TEMPLATE validation PASS")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--rendered", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    rendered = Path(args.rendered).read_text(encoding="utf-8")

    validate_render(template, payload, rendered)
    print("F3-TEMPLATE validation PASS")

    real_case_snapshot = Path("s5-artifacts/real-case-01-view.json")
    if real_case_snapshot.exists():
        presentation = json.loads(
            Path("templates/evidence-sheet-presentation-map.json").read_text(
                encoding="utf-8"
            )
        )
        validate_real_case(template, presentation, real_case_snapshot)

    # Cross-product validation: the N1 fixture is loaded before this workflow
    # step. Validate its own template without coupling N1 to EvidenceSheetView.
    response_snapshot = Path("s5-artifacts/evidence-response-view.json")
    response_template_path = Path("templates/evidence-response.md")
    response_map_path = Path("templates/evidence-response-presentation-map.json")
    if response_snapshot.exists() and response_template_path.exists() and response_map_path.exists():
        from validate_evidence_response_render import (
            validate_preview_behavior as validate_response_preview,
            validate_render as validate_response_render,
        )

        response_payload = json.loads(
            response_snapshot.read_text(encoding="utf-8")
        )
        response_template = response_template_path.read_text(encoding="utf-8")
        response_presentation = json.loads(
            response_map_path.read_text(encoding="utf-8")
        )
        response_rendered = render(
            response_template,
            response_payload,
            response_presentation,
        )
        response_output = Path("s5-artifacts/evidence-response-fixture.md")
        response_output.write_text(response_rendered, encoding="utf-8")

        validate_response_render(
            response_template,
            response_payload,
            response_rendered,
        )
        validate_response_preview(
            response_template,
            response_payload,
            response_presentation,
        )
        print("F3-ER-TEMPLATE validation PASS")

    real_response_snapshot = Path("s5-artifacts/real-n1-01-view.json")
    if (
        real_response_snapshot.exists()
        and response_template_path.exists()
        and response_map_path.exists()
    ):
        from validate_evidence_response_render import (
            validate_render as validate_real_response_render,
        )

        real_response_payload = json.loads(
            real_response_snapshot.read_text(encoding="utf-8")
        )
        real_response_rendered = render(
            response_template,
            real_response_payload,
            response_presentation,
        )
        real_response_output = Path("s5-artifacts/real-n1-01-preview.md")
        real_response_output.write_text(
            real_response_rendered,
            encoding="utf-8",
        )

        validate_real_response_render(
            response_template,
            real_response_payload,
            real_response_rendered,
        )
        require(
            real_response_payload["audit"]["assurance_level"] == "A1",
            "Real N1-01 must be A1 after methodological verification and before owner approval",
        )
        require(
            real_response_payload["audit"]["publishable"] is False,
            "Real N1-01 must remain non-publishable before verification/owner approval",
        )
        require(
            "PREVIEW — NÃO PUBLICÁVEL" in real_response_rendered,
            "Real N1-01 preview marker missing",
        )
        require(
            "MISSING_OWNER_APPROVAL" in real_response_rendered,
            "Real N1-01 owner-approval block missing",
        )
        print("RN1-TEMPLATE-A1 validation PASS")


if __name__ == "__main__":
    main()
