#!/usr/bin/env python3
"""Structural validation for OES Evidence Response N1 reference renders."""

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
        "template_version: oes.evidence_response.template/0.1" in template,
        "Evidence Response template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_response_view/0.1",
        "Unexpected EvidenceResponseView schema version",
    )

    identity = payload["identity"]
    question = payload["question"]
    answer = payload["answer"]
    limitations = payload["limitations"]
    audit = payload["audit"]

    for value in [
        identity["title"],
        identity["product_id"],
        question["normalized_text"],
        answer["text"],
        limitations["summary"],
    ]:
        require(
            value and value in rendered,
            f"Required rendered value missing: {value!r}",
        )

    require(
        "Busca estruturada e seletiva" in rendered,
        "N1 non-exhaustive search disclosure missing",
    )
    require(
        "não pretende demonstrar identificação exaustiva" in rendered,
        "N1 non-exhaustive limitation missing",
    )
    require(
        "## Fontes-chave" in rendered,
        "Key sources section missing",
    )
    require(
        "## Garantia metodológica e auditoria" in rendered,
        "Assurance/audit section missing",
    )
    require(
        "## Principais limitações" in rendered,
        "Limitations section missing",
    )

    for item in payload.get("key_sources", []):
        require(
            item["report_id"] in rendered,
            f"Key source ID missing: {item['report_id']}",
        )

    for item in payload.get("references", []):
        require(
            item["report_id"] in rendered,
            f"Reference ID missing: {item['report_id']}",
        )

    for item in payload.get("key_results", []):
        require(
            item["source_report_id"] in rendered,
            f"Key result source missing: {item['source_report_id']}",
        )
        require(
            item["field_path"] in rendered,
            f"Key result provenance path missing: {item['field_path']}",
        )

    certainty = payload.get("certainty") or {}
    if certainty.get("formal_assessment"):
        for item in certainty.get("assessments", []):
            require(
                item.get("framework") in rendered,
                "Formal certainty framework missing",
            )
    else:
        require(
            "Certeza/confiança: não avaliada formalmente pelo OES nesta Resposta de Evidência."
            in rendered,
            "Absent formal certainty disclosure missing",
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
            "Publishable N1 product must show approved gate",
        )
        require(
            "PREVIEW — NÃO PUBLICÁVEL" not in rendered,
            "Publishable N1 product incorrectly marked as preview",
        )
    else:
        require(
            "PREVIEW — NÃO PUBLICÁVEL" in rendered,
            "Non-publishable N1 product must show preview warning",
        )


def validate_preview_behavior(
    template: str,
    payload: dict,
    presentation: dict,
) -> None:
    preview = copy.deepcopy(payload)
    preview.setdefault("audit", {})["publishable"] = False
    preview["audit"]["publication_issues"] = [
        {
            "issue_code": "SYNTHETIC_BLOCK",
            "severity": "error",
            "message": "Synthetic validation block",
        }
    ]
    rendered = render(template, preview, presentation)

    require(
        "PREVIEW — NÃO PUBLICÁVEL" in rendered,
        "Preview marker not rendered for publishable=false",
    )
    require(
        "SYNTHETIC_BLOCK" in rendered,
        "Blocking issue not rendered in preview",
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
    validate_preview_behavior(template, payload, presentation)

    print("F3-EVIDENCE-RESPONSE-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
