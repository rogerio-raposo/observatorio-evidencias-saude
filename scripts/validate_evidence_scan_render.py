#!/usr/bin/env python3
"""Structural validation for OES Evidence Scan N0 reference renders."""

from __future__ import annotations

import argparse
import copy
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def validate_render(template: str, payload: dict, rendered: str) -> None:
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.evidence_scan.template/0.1" in template,
        "Evidence Scan template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_scan_view/0.1",
        "Unexpected EvidenceScanView schema version",
    )

    identity = payload["identity"]
    question = payload["question"]
    investigation = payload["investigation"]
    field_description = payload["field_description"]
    maturity = payload["maturity"]
    routing = payload["routing_recommendation"]
    conclusion = payload["conclusion"]
    limitations = payload["limitations"]
    audit = payload["audit"]

    required_values = [
        identity["title"],
        identity["product_id"],
        question["original_text"],
        investigation["objective"],
        field_description["text"],
        maturity["rationale"],
        routing["rationale"]["text"],
        conclusion["text"],
        limitations["summary"],
    ]

    for value in required_values:
        require(
            value and value in rendered,
            f"Required rendered value missing: {value!r}",
        )

    require(
        "Busca exploratória e não exaustiva" in rendered,
        "N0 non-exhaustive search disclosure missing",
    )
    require(
        "não pretende demonstrar identificação completa" in rendered,
        "N0 non-exhaustive limitation missing",
    )
    require(
        "julgamento operacional para roteamento" in rendered,
        "Maturity operational-judgement disclosure missing",
    )
    require(
        "## Próxima rota metodológica sugerida" in rendered,
        "Routing section missing",
    )
    require(
        "## Garantia metodológica e auditoria" in rendered,
        "Assurance/audit section missing",
    )
    require(
        "## Limitações" in rendered,
        "Limitations section missing",
    )

    for item in payload.get("central_sources", []):
        require(
            item["report_id"] in rendered,
            f"Central source ID missing: {item['report_id']}",
        )

    for item in payload.get("references", []):
        require(
            item["report_id"] in rendered,
            f"Reference ID missing: {item['report_id']}",
        )

    assurance_level = audit.get("assurance_level")
    require(
        assurance_level in {"A0", "A1", "A2", "A3"},
        f"Invalid assurance level: {assurance_level!r}",
    )
    require(
        audit.get("assurance_disclosure") in rendered,
        "Assurance disclosure missing from render",
    )

    if assurance_level == "A2":
        require(
            "revisão especializada independente não realizada" in rendered.lower(),
            "A2 render must disclose absence of expert review",
        )

    if audit.get("publishable"):
        require(
            "**Gate de publicação:** aprovado" in rendered,
            "Publishable N0 product must show approved gate",
        )
        require(
            "PREVIEW — NÃO PUBLICÁVEL" not in rendered,
            "Publishable N0 product incorrectly marked as preview",
        )
    else:
        require(
            "PREVIEW — NÃO PUBLICÁVEL" in rendered,
            "Non-publishable N0 product must show preview warning",
        )


def validate_a1_preview(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    preview = copy.deepcopy(payload)
    preview["identity"]["editorial_status"] = "under_review"
    preview["identity"]["publication_date"] = None
    preview["audit"]["assurance_level"] = "A1"
    preview["audit"]["publishable"] = False
    preview["audit"]["assurance_disclosure"] = (
        "Verificação metodológica assistida por IA registrada; "
        "aprovação de governança ainda não registrada; "
        "revisão especializada independente não realizada."
    )
    preview["audit"]["publication_issues"] = [
        {
            "issue_code": "MISSING_OWNER_APPROVAL",
            "severity": "error",
            "message": "Synthetic A1 validation block",
        },
        {
            "issue_code": "NO_EXPERT_INDEPENDENT_REVIEW",
            "severity": "warning",
            "message": "No expert independent review",
        },
    ]

    rendered = render(template, preview, presentation)

    require(
        "PREVIEW — NÃO PUBLICÁVEL" in rendered,
        "A1 preview marker missing",
    )
    require(
        "MISSING_OWNER_APPROVAL" in rendered,
        "A1 owner approval blocker missing",
    )
    require(
        "aprovação de governança ainda não registrada" in rendered,
        "A1 assurance disclosure missing",
    )


def validate_insufficient_without_report(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    insufficient = copy.deepcopy(payload)
    insufficient["central_sources"] = []
    insufficient["references"] = []
    insufficient["field_description"] = {
        "text": (
            "Nenhuma fonte central foi localizada nas buscas exploratórias "
            "registradas."
        ),
        "scope_qualifier": "exploratory_non_exhaustive",
    }
    insufficient["maturity"] = {
        "category": "insufficient",
        "rationale": (
            "A busca exploratória registrada não localizou fonte central "
            "adequada para caracterizar o campo."
        ),
        "confidence_qualifier": "preliminary",
    }
    insufficient["audit"]["traceable_basis_type"] = "search_only_insufficient"
    insufficient["audit"]["publishable"] = True
    insufficient["audit"]["publication_issues"] = [
        {
            "issue_code": "NO_TRACEABLE_CENTRAL_REPORTS",
            "severity": "warning",
            "message": (
                "No central ReportVersion was identified; the judgement is "
                "based on recorded exploratory Searches."
            ),
        },
        {
            "issue_code": "NO_EXPERT_INDEPENDENT_REVIEW",
            "severity": "warning",
            "message": "No expert independent review is recorded.",
        },
    ]

    rendered = render(template, insufficient, presentation)

    require(
        "Nenhuma fonte central rastreável foi projetada" in rendered,
        "Insufficient-state no-central-source message missing",
    )
    require(
        "não demonstra ausência definitiva de evidência" in rendered,
        "Insufficient-state anti-overclaim disclosure missing",
    )
    require(
        "NO_TRACEABLE_CENTRAL_REPORTS" in rendered,
        "Insufficient-state warning missing",
    )
    require(
        "PREVIEW — NÃO PUBLICÁVEL" not in rendered,
        "Valid insufficient A2 state incorrectly marked as preview",
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

    validate_render(template, payload, rendered)
    validate_a1_preview(template, payload, presentation)
    validate_insufficient_without_report(template, payload, presentation)

    print("F3-EVIDENCE-SCAN-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
