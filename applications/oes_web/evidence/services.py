import json
from pathlib import Path
from .domain import from_record

FIXTURE = Path(__file__).resolve().parent / "fixtures" / "signals.json"

def list_signals():
    records = json.loads(FIXTURE.read_text(encoding="utf-8"))
    return tuple(from_record(entry) for entry in records)

def get_signal(nct):
    return next((signal for signal in list_signals() if signal.nct == nct), None)
