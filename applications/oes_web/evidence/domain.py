from dataclasses import dataclass

ALLOWED_EVENTS = {"SOURCE_RETRIEVAL", "DOCUMENTARY_CROSSWALK", "DOCUMENTED_REPORT_LINK"}
DOCUMENTED_LINK_SOURCE = "docs/products/154-reconciliacao-listas-artigos-clusters-reports-ovr01-dcbti.md"

@dataclass(frozen=True)
class SourceReference:
    document_path: str
    locator: str
    category: str = "documentary_reference"

@dataclass(frozen=True)
class StudyReference:
    label: str

@dataclass(frozen=True)
class ReportReference:
    label: str

@dataclass(frozen=True)
class StudyReportReference:
    report: ReportReference
    source: SourceReference

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
    study_reference: StudyReference | None = None
    report_links: tuple[StudyReportReference, ...] = ()

def _documentary_identity(record, state, reports):
    identity = record.get("documentary_identity")
    if identity is None:
        # Legacy synthetic inputs remain valid; they do not gain typed assertions.
        return None, ()
    study_row = identity.get("study")
    links = identity.get("links", [])
    if state != "KNOWN_DOCUMENTED" and (study_row is not None or links):
        raise ValueError("Unreconciled identity cannot have typed Study/Report links")
    if study_row is None:
        if links:
            raise ValueError("Report links require a documented Study")
        return None, ()
    if state != "KNOWN_DOCUMENTED" or not isinstance(study_row, dict):
        raise ValueError("Study reference must be documented")
    label = study_row.get("label")
    if not isinstance(label, str) or not label.strip() or label != record["study_label"]:
        raise ValueError("Study reference must match documented label")
    if len(links) != len(reports):
        raise ValueError("Typed report links must match legacy reports")
    seen = set()
    typed = []
    for entry in links:
        report_label = entry.get("report_label")
        src = entry.get("source", {})
        if report_label not in reports or report_label in seen:
            raise ValueError("Missing, duplicate or invented Report link")
        if src.get("document_path") != DOCUMENTED_LINK_SOURCE or src.get("locator") != "seção 5.5":
            raise ValueError("Unsupported documentary link provenance")
        if src.get("category", "documentary_reference") != "documentary_reference":
            raise ValueError("Unsupported provenance category")
        typed.append(StudyReportReference(
            report=ReportReference(label=report_label),
            source=SourceReference(document_path=src["document_path"], locator=src["locator"])))
        seen.add(report_label)
    return StudyReference(label=label), tuple(typed)

def from_record(record):
    state = record["identity_state"]
    if state not in {"KNOWN_DOCUMENTED", "NOT_IDENTIFIED_IN_SCOPED_INVENTORY"}:
        raise ValueError("Unrecognized identity state")
    reports = tuple(record["reports"])
    if state != "KNOWN_DOCUMENTED" and (reports or record["study_label"]):
        raise ValueError("Unreconciled identity cannot assert Study/Report")
    if not record["provenance"] or not record["limitation"]:
        raise ValueError("Provenance and limits are required")
    study_reference, report_links = _documentary_identity(record, state, reports)
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
                  milestones=tuple(milestones), study_reference=study_reference,
                  report_links=report_links)
