"""Offline static example projection. Never executes P1, SQL, HTTP or scientific inference."""
import json
import re
from pathlib import Path

from .services import get_signal

EXAMPLE_FILE = Path(__file__).resolve().parent / "fixtures" / "p2_synthetic_receipt.json"
EXPECTED = {
    "status": "SYNTHETIC_PATH_VERIFIED_OFFLINE",
    "observation_id": "P1-OBS",
    "sha256": "7294ef88cb7f01f8298f6264c1ac547e74a52b4a488c062858f8f10e26c1575b",
    "payload_bytes": 38,
    "signal_id": "SYNTH-SIGNAL-P1",
    "documentary_nct": "NCT01438697",
    "identity_state": "KNOWN_DOCUMENTED",
    "evidence_boundary": "SYNTHETIC_TECHNICAL_ONLY",
    "scientific_decision": "NOT_PERFORMED",
}


class SyntheticPresentationHold(ValueError):
    """Sanitized deny state, never includes fixture or exception contents."""


def validate_receipt(receipt, resolver=None):
    try:
        if resolver is None:
            resolver = get_signal
        if type(receipt) is not dict or set(receipt) != set(EXPECTED):
            raise ValueError("invalid schema")
        if any(type(receipt[k]) is not type(v) or receipt[k] != v
               for k, v in EXPECTED.items()):
            raise ValueError("mismatched demonstration")
        if re.fullmatch(r"[0-9a-f]{64}", receipt["sha256"]) is None:
            raise ValueError("invalid digest")
        if not callable(resolver):
            raise ValueError("missing resolver")
        nct = receipt["documentary_nct"]
        signal = resolver(nct)
        if signal is None or signal.nct != nct or signal.identity_state != receipt["identity_state"]:
            raise ValueError("invalid documentary reference")
        return dict(receipt)
    except Exception:
        raise SyntheticPresentationHold("HOLD: synthetic presentation unavailable") from None


def load_example():
    try:
        data = json.loads(EXAMPLE_FILE.read_text(encoding="utf-8"))
        return validate_receipt(data)
    except Exception:
        raise SyntheticPresentationHold("HOLD: synthetic presentation unavailable") from None
