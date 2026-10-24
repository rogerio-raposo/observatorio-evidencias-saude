"""PG-A4 synthetic-only read projection; not a scientific identity reconciliation."""
from dataclasses import dataclass
from uuid import UUID
from django.conf import settings
from django.db import connections

ALIAS = "oes_synthetic_reader"

@dataclass(frozen=True)
class SyntheticStudyReportLink:
    study_entity_uuid: UUID
    study_version_uuid: UUID
    report_entity_uuid: UUID
    report_version_uuid: UUID
    relation_type: str
    provenance_uuid: UUID | None
    provenance_field_path: str | None
    evidence_boundary: str = "SYNTHETIC_TECHNICAL_ONLY"

# Provenance is joined only when its target is the current Study version.
# A record without provenance does not imply absence of scientific evidence.
QUERY = """
SELECT s.entity_uuid, sv.version_uuid, r.entity_uuid, rv.version_uuid,
       l.relation_type, p.provenance_uuid, p.field_path
FROM evidence.study_report_link l
JOIN evidence.study s ON s.entity_uuid = l.study_entity_uuid
JOIN evidence.report r ON r.entity_uuid = l.report_entity_uuid
JOIN core.entity_version sev ON sev.entity_uuid = s.entity_uuid
    AND sev.version_status = 'current'
JOIN evidence.study_version sv ON sv.version_uuid = sev.version_uuid
JOIN core.entity_version rev ON rev.entity_uuid = r.entity_uuid
    AND rev.version_status = 'current'
JOIN evidence.report_version rv ON rv.version_uuid = rev.version_uuid
LEFT JOIN provenance.record p ON p.target_version_uuid = sv.version_uuid
    AND p.status = 'active'
WHERE l.status = %s
ORDER BY s.entity_uuid, r.entity_uuid, p.provenance_uuid
"""

def list_synthetic_study_report_links():
    if ALIAS not in settings.DATABASES:
        raise RuntimeError("PG-A4 synthetic reader is disabled")
    with connections[ALIAS].cursor() as cursor:
        cursor.execute(QUERY, ["active"])
        rows = cursor.fetchall()
    return tuple(SyntheticStudyReportLink(*row) for row in rows)
