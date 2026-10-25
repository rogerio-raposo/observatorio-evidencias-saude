"""PF-I01: locked historical N2 snapshot, no network/database or scientific inference."""
import hashlib
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
        if (data["identity"]["product_id"] != PRODUCT_ID
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
