import json
from pathlib import Path
from .domain import from_record

FIXTURE = Path(__file__).resolve().parent / "fixtures" / "signals.json"

def get_signal(nct):
    records = json.loads(FIXTURE.read_text(encoding="utf-8"))
    for entry in records:
        if entry["nct"] == nct:
            return from_record(entry)
    return None
