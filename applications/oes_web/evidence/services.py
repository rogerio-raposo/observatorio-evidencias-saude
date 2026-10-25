import json
from pathlib import Path
from .domain import from_record

FIXTURE = Path(__file__).resolve().parent / "fixtures" / "signals.json"

def list_signals():
    records = json.loads(FIXTURE.read_text(encoding="utf-8"))
    return tuple(from_record(entry) for entry in records)

def get_signal(nct):
    return next((signal for signal in list_signals() if signal.nct == nct), None)


class SyntheticReadHold(RuntimeError):
    """Sanitized denial; never exposes SQL, credentials or connection details."""


def get_synthetic_study_report_links(*, enabled=False, reader=None):
    """Internal opt-in synthetic projection, never a scientific NCT crosswalk.

    The documentary Signal catalog is intentionally unaffected. The optional
    reader injection is for offline tests; production use requires its own gate.
    """
    if enabled is not True:
        raise SyntheticReadHold("HOLD: synthetic source not explicitly enabled")
    if reader is None:
        from .synthetic_pg_reader import list_synthetic_study_report_links
        reader = list_synthetic_study_report_links
    try:
        links = reader()
        if not isinstance(links, tuple):
            raise ValueError("invalid result")
        from .synthetic_pg_reader import SyntheticStudyReportLink
        if any(type(link) is not SyntheticStudyReportLink
               or link.evidence_boundary != "SYNTHETIC_TECHNICAL_ONLY"
               for link in links):
            raise ValueError("invalid synthetic boundary")
        return links
    except Exception:
        raise SyntheticReadHold("HOLD: synthetic projection unavailable") from None



class SyntheticRoundtripHold(RuntimeError):
    """Sanitized HOLD; persistence may have committed before failure."""


def run_synthetic_private_roundtrip(*, enabled=False, raw=None, provenance=None,
                                    writer_connection=None, verifier_connection=None,
                                    orchestrator=None):
    """Offline integration seam. The injected orchestrator owns all DB operations.

    No connection creation, role switching, routing or factual capture.
    A caller must supply the already tested identity-gated E6 orchestrator;
    no fallback or automatic retry is performed.
    """
    if enabled is not True:
        raise SyntheticRoundtripHold("HOLD: synthetic roundtrip not explicitly enabled")
    if (orchestrator is None or not callable(orchestrator)
            or writer_connection is None or verifier_connection is None
            or writer_connection is verifier_connection):
        raise SyntheticRoundtripHold("HOLD: independent injected sessions required")
    if not isinstance(raw, bytes) or not raw or not isinstance(provenance, dict):
        raise SyntheticRoundtripHold("HOLD: invalid synthetic input")
    try:
        result = orchestrator(raw, provenance, writer_connection, verifier_connection)
        if (not isinstance(result, dict)
                or result.get("status") != "PRIVATE_SYNTHETIC_VERIFIED_OFFLINE"
                or not isinstance(result.get("observation_id"), str)
                or not isinstance(result.get("sha256"), str)
                or type(result.get("payload_bytes")) is not int
                or result["payload_bytes"] != len(raw)
                or set(result) != {"status", "observation_id", "sha256", "payload_bytes"}):
            raise ValueError("invalid result")
        return dict(result)
    except Exception:
        # The writer may already have committed. Never retry or imply rollback.
        raise SyntheticRoundtripHold(
            "HOLD: synthetic operation failed; write may be committed"
        ) from None
