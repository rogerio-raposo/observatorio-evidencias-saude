"""PF-I01: locked historical N2 snapshot, no network/database or scientific inference."""
import hashlib
import html
import re
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "artifacts/pf-i01/rc01-evidence-sheet-view.json"
EXPECTED_SHA256 = "82a828e98b97dd5b6fe392135ed172d8c896f562e698353922b23cc419cc22d9"
PRODUCT_ID = "OES-P-2026-000401"

class N2Hold(RuntimeError):
    pass

def load_historical_n2():
    try:
        raw = SOURCE.read_bytes()
        if hashlib.sha256(raw).hexdigest() != EXPECTED_SHA256:
            raise ValueError("snapshot digest mismatch")
        data = json.loads(raw)
        if (data["question"]["question_id"] != "OES-Q-2026-000401"
                or data["question"]["question_version_uuid"] != "81000000-0000-0000-0000-000000000001"
                or data["routing"]["investigation_version_uuid"] != "81000000-0000-0000-0000-000000000002"
                or data["identity"]["product_version_uuid"] != "81000000-0000-0000-0000-000000000701"
                or data["audit"]["linked_investigations"] != [{"role": "primary", "sequence_no": 1, "investigation_id": "OES-I-2026-000401", "investigation_version_uuid": "81000000-0000-0000-0000-000000000002"}]
                or not data["audit"].get("lineage_available")
                or data["identity"]["product_id"] != PRODUCT_ID
                or data["routing"]["investigation_id"] != "OES-I-2026-000401"
                or data["routing"]["depth_level"] != "N2"
                or data["audit"]["assurance_level"] != "A2"
                or data["audit"].get("reviews") != []):
            raise ValueError("historical identity or assurance mismatch")
        template = (ROOT / "templates/evidence-sheet.md").read_text(encoding="utf-8")
        presentation = json.loads((ROOT / "templates/evidence-sheet-presentation-map.json").read_text(encoding="utf-8"))
        sys.path.insert(0, str(ROOT / "scripts"))
        from render_evidence_sheet_reference import render
        body = render(template, data, presentation)
        if not body or "{{" in body or "}}" in body:
            raise ValueError("invalid rendered sheet")
        return body
    except Exception:
        raise N2Hold("HOLD: historical evidence sheet unavailable") from None

def present_markdown(markdown):
    """Escape all input; display bounded Markdown structure without raw HTML."""
    parts = []
    rows = []
    def flush_table():
        nonlocal rows
        if rows:
            parts.append("<table>" + "".join(
                "<tr>" + "".join(
                    ("<th>" if n == 0 else "<td>") + html.escape(cell.strip()) +
                    ("</th>" if n == 0 else "</td>") for cell in row
                ) + "</tr>" for n, row in enumerate(rows)
            ) + "</table>")
            rows = []
    for line in markdown.splitlines():
        stripped = line.strip()
        if stripped.startswith("|") and stripped.endswith("|"):
            cells = [cell.strip() for cell in stripped[1:-1].split("|")]
            if all(re.fullmatch(r":?-{3,}:?", c) for c in cells):
                continue
            rows.append(cells)
            continue
        flush_table()
        if not stripped:
            continue
        match = re.match(r"^(#{1,6})\\s+(.+)$", stripped)
        if match:
            level = len(match.group(1))
            parts.append(f"<h{level}>" + html.escape(match.group(2)) + f"</h{level}>")
        elif re.match(r"^[-*]\\s+", stripped):
            parts.append("<p>• " + html.escape(stripped[2:]) + "</p>")
        else:
            parts.append("<p>" + html.escape(stripped) + "</p>")
    flush_table()
    return "\\n".join(parts)
