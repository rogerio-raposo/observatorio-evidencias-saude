-- OES-DBM-2026-0004
-- PoC-S4 — ReportRelation and derived report impact traversal
-- Depends on: poc-s1.sql + 002 + 003
-- Status: experimental, non-production
-- Date: 2026-10-04

BEGIN;

CREATE TABLE evidence.report_relation (
    relation_uuid uuid PRIMARY KEY,
    source_report_entity_uuid uuid NOT NULL
        REFERENCES evidence.report(entity_uuid),
    target_report_entity_uuid uuid NOT NULL
        REFERENCES evidence.report(entity_uuid),
    relation_type text NOT NULL CHECK (
        relation_type IN (
            'correction_of',
            'retraction_of',
            'expression_of_concern_for',
            'update_of',
            'supplement_to'
        )
    ),
    relation_date date,
    notes text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded','invalidated')
    ),
    UNIQUE (
        source_report_entity_uuid,
        target_report_entity_uuid,
        relation_type
    ),
    CHECK (source_report_entity_uuid <> target_report_entity_uuid)
);

CREATE INDEX ix_report_relation_source
    ON evidence.report_relation(source_report_entity_uuid);

CREATE INDEX ix_report_relation_target
    ON evidence.report_relation(target_report_entity_uuid);

CREATE INDEX ix_report_relation_type
    ON evidence.report_relation(relation_type);

CREATE OR REPLACE FUNCTION provenance.report_impact(
    p_report_entity_uuid uuid
)
RETURNS TABLE (
    origin_report_version_uuid uuid,
    impacted_version_uuid uuid,
    depth integer,
    dependency_type text,
    path uuid[]
)
LANGUAGE sql
STABLE
AS $impact$
WITH RECURSIVE walk AS (
    SELECT
        ev.version_uuid AS origin_report_version_uuid,
        de.target_version_uuid AS impacted_version_uuid,
        1 AS depth,
        de.dependency_type,
        ARRAY[ev.version_uuid, de.target_version_uuid]::uuid[] AS path
    FROM core.entity_version ev
    JOIN evidence.report r
      ON r.entity_uuid = ev.entity_uuid
    JOIN provenance.dependency_edge de
      ON de.source_version_uuid = ev.version_uuid
     AND de.status = 'active'
    WHERE ev.entity_uuid = p_report_entity_uuid

    UNION ALL

    SELECT
        w.origin_report_version_uuid,
        de.target_version_uuid,
        w.depth + 1,
        de.dependency_type,
        w.path || de.target_version_uuid
    FROM walk w
    JOIN provenance.dependency_edge de
      ON de.source_version_uuid = w.impacted_version_uuid
     AND de.status = 'active'
    WHERE w.depth < 32
      AND NOT de.target_version_uuid = ANY(w.path)
)
SELECT
    origin_report_version_uuid,
    impacted_version_uuid,
    depth,
    dependency_type,
    path
FROM walk;
$impact$;

COMMIT;
