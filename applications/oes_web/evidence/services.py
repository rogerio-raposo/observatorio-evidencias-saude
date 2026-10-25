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
