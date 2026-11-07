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

def _inline(text):
    """Only emphasis and code used by the historical sheet; never raw HTML."""
    tokens = re.split(r"(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*)", text)
    rendered = []
    for token in tokens:
        if token.startswith("**") and token.endswith("**"):
            rendered.append("<strong>" + html.escape(token[2:-2]) + "</strong>")
        elif token.startswith("`") and token.endswith("`"):
            rendered.append("<code>" + html.escape(token[1:-1]) + "</code>")
        elif token.startswith("*") and token.endswith("*"):
            rendered.append("<em>" + html.escape(token[1:-1]) + "</em>")
        else:
            rendered.append(html.escape(token))
    return "".join(rendered)


def present_markdown(markdown):
    """Bounded presentation of the unchanged historical Markdown.

    The page owns h1; the product starts at h2 and its sections at h3.
    Anchors are ordinal and independent of scientific identifiers/content.
    """
    parts, rows, sections = [], [], []
    major_section = False

    def back_to_index():
        return '<p class="sheet-return"><a href="#sheet-index">Retornar ao índice da ficha</a></p>'

    def flush_table():
        if rows:
            parts.append('<div class="sheet-table" role="region" aria-label="Tabela da ficha histórica" tabindex="0"><table>' + "".join(
                "<tr>" + "".join(
                    ("<th scope=\"col\">" if n == 0 else "<td>") + _inline(cell.strip()) +
                    ("</th>" if n == 0 else "</td>") for cell in row
                ) + "</tr>" for n, row in enumerate(rows)
            ) + "</table></div>")
            rows.clear()

    # Template comments are presentation metadata, not scientific sheet content.
    for line in re.sub(r"<!--.*?-->", "", markdown, flags=re.S).splitlines():
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
        match = re.match(r"^(#{1,6})\s+(.+)$", stripped)
        if match:
            source_level = len(match.group(1))
            level = min(source_level + 1, 6)
            anchor = ""
            if source_level == 2:
                if major_section:
                    parts.append(back_to_index())
                major_section = True
                anchor_id = f"sheet-section-{len(sections) + 1}"
                sections.append((anchor_id, match.group(2)))
                anchor = f' id="{anchor_id}" tabindex="-1"'
            parts.append(f"<h{level}{anchor}>" + _inline(match.group(2)) + f"</h{level}>")
        elif re.fullmatch(r"-{3,}", stripped):
            parts.append("<hr>")
        elif stripped.startswith("> "):
            parts.append("<blockquote><p>" + _inline(stripped[2:]) + "</p></blockquote>")
        elif re.match(r"^[-*]\s+", stripped):
            parts.append("<p>• " + _inline(stripped[2:]) + "</p>")
        else:
            parts.append("<p>" + _inline(stripped) + "</p>")
    flush_table()
    if major_section:
        parts.append(back_to_index())
    index = '<nav aria-label="Índice da ficha"><h2 id="sheet-index" tabindex="-1">Índice da ficha histórica</h2><ul>' + "".join(
        f'<li><a href="#{anchor}">' + _inline(title) + '</a></li>'
        for anchor, title in sections
    ) + '</ul></nav>'
    return index + "\n" + "\n".join(parts)
