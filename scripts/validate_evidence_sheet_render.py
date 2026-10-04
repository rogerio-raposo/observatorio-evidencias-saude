#!/usr/bin/env python3
"""Structural validation for an OES Evidence Sheet reference render."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--rendered", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    rendered = Path(args.rendered).read_text(encoding="utf-8")

    require("display." not in template, "Forbidden display.* placeholder remains")
    require("{{#unless" not in template, "Engine-specific unless helper remains")
    require("{{" not in rendered and "}}" not in rendered, "Unresolved token remains")
    require(
        "template_version: oes.evidence_sheet.template/0.1" in template,
        "Template version header missing",
    )
    require(
        payload.get("schema_version") == "oes.evidence_sheet_view/0.1",
        "Unexpected EvidenceSheetView schema version",
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
        require(value and value in rendered, f"Required rendered value missing: {value!r}")

    for item in payload.get("references", []):
        require(item["report_id"] in rendered, f"Reference ID missing: {item['report_id']}")

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

    print("F3-TEMPLATE validation PASS")


if __name__ == "__main__":
    main()
