#!/usr/bin/env python3
"""Reference renderer for OES Evidence Map.

This wrapper reuses the neutral OES template engine. It does not query the
database, mutate the payload, recalculate cells/counts, create gaps, create
scientific conclusions, or change assurance.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from render_evidence_sheet_reference import render


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--template", required=True)
    parser.add_argument("--input", required=True)
    parser.add_argument("--presentation-map", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    template = Path(args.template).read_text(encoding="utf-8")
    payload = json.loads(Path(args.input).read_text(encoding="utf-8"))
    presentation = json.loads(
        Path(args.presentation_map).read_text(encoding="utf-8")
    )

    rendered = render(template, payload, presentation)

    if "{{" in rendered or "}}" in rendered:
        raise RuntimeError("Unresolved template token found after rendering")

    Path(args.output).write_text(rendered, encoding="utf-8")


if __name__ == "__main__":
    main()
