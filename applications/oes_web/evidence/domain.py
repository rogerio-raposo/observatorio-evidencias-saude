from dataclasses import dataclass

@dataclass(frozen=True)
class Signal:
    nct: str
    identity_state: str
    study_label: str | None
    reports: tuple[str, ...]
    provenance: str
    limitation: str

def from_record(record):
    state = record["identity_state"]
    if state not in {"KNOWN_DOCUMENTED", "NOT_IDENTIFIED_IN_SCOPED_INVENTORY"}:
        raise ValueError("Unrecognized identity state")
    reports = tuple(record["reports"])
    if state != "KNOWN_DOCUMENTED" and (reports or record["study_label"]):
        raise ValueError("Unreconciled identity cannot assert Study/Report")
    if not record["provenance"] or not record["limitation"]:
        raise ValueError("Provenance and limits are required")
    return Signal(nct=record["nct"], identity_state=state,
                  study_label=record["study_label"], reports=reports,
                  provenance=record["provenance"], limitation=record["limitation"])
