from dataclasses import dataclass

ALLOWED_EVENTS = {"SOURCE_RETRIEVAL", "DOCUMENTARY_CROSSWALK", "DOCUMENTED_REPORT_LINK"}

@dataclass(frozen=True)
class DocumentaryMilestone:
    event_type: str
    source_ref: str
    description: str
    event_date: str | None
    certainty_boundary: str

@dataclass(frozen=True)
class Signal:
    nct: str
    identity_state: str
    study_label: str | None
    reports: tuple[str, ...]
    provenance: str
    limitation: str
    milestones: tuple[DocumentaryMilestone, ...] = ()

def from_record(record):
    state = record["identity_state"]
    if state not in {"KNOWN_DOCUMENTED", "NOT_IDENTIFIED_IN_SCOPED_INVENTORY"}:
        raise ValueError("Unrecognized identity state")
    reports = tuple(record["reports"])
    if state != "KNOWN_DOCUMENTED" and (reports or record["study_label"]):
        raise ValueError("Unreconciled identity cannot assert Study/Report")
    if not record["provenance"] or not record["limitation"]:
        raise ValueError("Provenance and limits are required")
    milestones = []
    for row in record.get("milestones", []):
        if row["event_type"] not in ALLOWED_EVENTS:
            raise ValueError("Unsupported documentary milestone")
        if not row["source_ref"].strip() or not row["description"].strip() or not row["certainty_boundary"].strip():
            raise ValueError("Documentary milestone requires source, description and scientific boundary")
        if row.get("event_date") is not None:
            raise ValueError("Dated milestones not supported without additional source verification")
        if state != "KNOWN_DOCUMENTED" and row["event_type"] == "DOCUMENTED_REPORT_LINK":
            raise ValueError("Unreconciled identity cannot assert a Report link")
        milestones.append(DocumentaryMilestone(event_type=row["event_type"],
            source_ref=row["source_ref"], description=row["description"],
            event_date=None, certainty_boundary=row["certainty_boundary"]))
    if [m.event_type for m in milestones] != sorted(
        [m.event_type for m in milestones],
        key=lambda x: {"SOURCE_RETRIEVAL": 0, "DOCUMENTARY_CROSSWALK": 1, "DOCUMENTED_REPORT_LINK": 2}[x]
    ):
        raise ValueError("Documentary milestones must follow source, crosswalk, report-link order")
    return Signal(nct=record["nct"], identity_state=state,
                  study_label=record["study_label"], reports=reports,
                  provenance=record["provenance"], limitation=record["limitation"],
                  milestones=tuple(milestones))
