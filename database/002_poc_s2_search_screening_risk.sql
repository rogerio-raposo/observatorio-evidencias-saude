-- OES-DBM-2026-0002
-- PoC-S2 — Search / Screening / Risk Assessment extension
-- Depends on: database/poc-s1.sql
-- Status: experimental, non-production
-- Reference dialect: PostgreSQL
-- Date: 2026-10-03

BEGIN;

-- ---------------------------------------------------------------------------
-- SEARCH
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.search (
    search_uuid uuid PRIMARY KEY,
    oes_search_id text NOT NULL UNIQUE,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    source_name text NOT NULL,
    platform text,
    exact_strategy text NOT NULL,
    filters_payload jsonb,
    executed_at timestamptz NOT NULL,
    result_count integer CHECK (result_count IS NULL OR result_count >= 0),
    strategy_version text,
    operator text,
    export_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    status text NOT NULL,
    CHECK (length(trim(oes_search_id)) > 0)
);

CREATE INDEX ix_search_investigation
    ON investigation.search(investigation_version_uuid);

-- ---------------------------------------------------------------------------
-- DEDUPLICATION
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.dedup_cluster (
    dedup_cluster_uuid uuid PRIMARY KEY,
    oes_dedup_id text NOT NULL UNIQUE,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    canonical_report_entity_uuid uuid REFERENCES evidence.report(entity_uuid),
    status text NOT NULL,
    confidence text,
    method text,
    reviewer text,
    decision_date date,
    CHECK (length(trim(oes_dedup_id)) > 0)
);

CREATE INDEX ix_dedup_investigation
    ON investigation.dedup_cluster(investigation_version_uuid);

-- ---------------------------------------------------------------------------
-- SEARCH HIT
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.search_hit (
    search_hit_uuid uuid PRIMARY KEY,
    oes_search_hit_id text NOT NULL UNIQUE,
    search_uuid uuid NOT NULL REFERENCES investigation.search(search_uuid),
    report_entity_uuid uuid REFERENCES evidence.report(entity_uuid),
    source_record_id text,
    raw_payload jsonb,
    raw_title text,
    raw_authors text,
    raw_year integer,
    raw_identifier text,
    source_rank integer CHECK (source_rank IS NULL OR source_rank > 0),
    imported_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dedup_cluster_uuid uuid REFERENCES investigation.dedup_cluster(dedup_cluster_uuid),
    resolution_status text NOT NULL,
    CHECK (length(trim(oes_search_hit_id)) > 0)
);

CREATE INDEX ix_search_hit_search
    ON investigation.search_hit(search_uuid);
CREATE INDEX ix_search_hit_report
    ON investigation.search_hit(report_entity_uuid);
CREATE INDEX ix_search_hit_dedup
    ON investigation.search_hit(dedup_cluster_uuid);

-- ---------------------------------------------------------------------------
-- SCREENING TARGET TYPE INTEGRITY
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION investigation.assert_screening_target_type()
RETURNS trigger
LANGUAGE plpgsql
AS $screen$
DECLARE
    actual_type text;
BEGIN
    SELECT e.entity_type
      INTO actual_type
      FROM core.entity e
     WHERE e.entity_uuid = NEW.target_entity_uuid;

    IF actual_type IS NULL THEN
        RAISE EXCEPTION
            'Screening target % does not exist',
            NEW.target_entity_uuid;
    END IF;

    IF actual_type NOT IN ('Report','Study') THEN
        RAISE EXCEPTION
            'Screening target % has invalid type %',
            NEW.target_entity_uuid, actual_type;
    END IF;

    RETURN NEW;
END;
$screen$;

CREATE TABLE investigation.screening_decision (
    screening_uuid uuid PRIMARY KEY,
    oes_screening_id text NOT NULL UNIQUE,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    target_entity_uuid uuid NOT NULL REFERENCES core.entity(entity_uuid),
    stage text NOT NULL,
    reviewer text NOT NULL,
    decision text NOT NULL,
    exclusion_reason text,
    decided_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    parent_decision_uuid uuid
        REFERENCES investigation.screening_decision(screening_uuid),
    adjudication_flag boolean NOT NULL DEFAULT false,
    CHECK (length(trim(oes_screening_id)) > 0),
    CHECK (
        decision <> 'exclude'
        OR exclusion_reason IS NOT NULL
    ),
    CHECK (
        parent_decision_uuid IS NULL
        OR parent_decision_uuid <> screening_uuid
    )
);

CREATE TRIGGER tr_screening_target_type
BEFORE INSERT OR UPDATE OF target_entity_uuid
ON investigation.screening_decision
FOR EACH ROW
EXECUTE FUNCTION investigation.assert_screening_target_type();

CREATE INDEX ix_screening_investigation
    ON investigation.screening_decision(investigation_version_uuid);
CREATE INDEX ix_screening_target
    ON investigation.screening_decision(target_entity_uuid);

-- ---------------------------------------------------------------------------
-- RISK ASSESSMENT IDENTITY
-- ---------------------------------------------------------------------------

CREATE TABLE appraisal.risk_assessment (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TRIGGER tr_risk_assessment_entity_type
BEFORE INSERT OR UPDATE OF entity_uuid
ON appraisal.risk_assessment
FOR EACH ROW
EXECUTE FUNCTION core.assert_entity_type('RiskAssessment');

CREATE OR REPLACE FUNCTION appraisal.assert_risk_target_type()
RETURNS trigger
LANGUAGE plpgsql
AS $risk$
DECLARE
    actual_type text;
BEGIN
    SELECT e.entity_type
      INTO actual_type
      FROM core.entity e
     WHERE e.entity_uuid = NEW.target_entity_uuid;

    IF actual_type IS NULL THEN
        RAISE EXCEPTION
            'Risk assessment target % does not exist',
            NEW.target_entity_uuid;
    END IF;

    IF actual_type NOT IN ('Study','Result','Report') THEN
        RAISE EXCEPTION
            'Risk assessment target % has invalid type %',
            NEW.target_entity_uuid, actual_type;
    END IF;

    RETURN NEW;
END;
$risk$;

CREATE TABLE appraisal.risk_assessment_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL
        REFERENCES appraisal.risk_assessment(entity_uuid),
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    framework text NOT NULL,
    framework_version text,
    target_entity_uuid uuid NOT NULL REFERENCES core.entity(entity_uuid),
    outcome_entity_uuid uuid REFERENCES evidence.outcome(entity_uuid),
    overall_judgement text,
    assessor text NOT NULL,
    assessment_date date NOT NULL,
    verification_status text,
    instrument_payload jsonb,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TRIGGER tr_risk_target_type
BEFORE INSERT OR UPDATE OF target_entity_uuid
ON appraisal.risk_assessment_version
FOR EACH ROW
EXECUTE FUNCTION appraisal.assert_risk_target_type();

CREATE INDEX ix_risk_investigation
    ON appraisal.risk_assessment_version(investigation_version_uuid);
CREATE INDEX ix_risk_target
    ON appraisal.risk_assessment_version(target_entity_uuid);
CREATE INDEX ix_risk_outcome
    ON appraisal.risk_assessment_version(outcome_entity_uuid);

CREATE TABLE appraisal.risk_assessment_domain (
    risk_assessment_version_uuid uuid NOT NULL
        REFERENCES appraisal.risk_assessment_version(version_uuid),
    domain_code text NOT NULL,
    judgement text,
    rationale text NOT NULL,
    supporting_reference text,
    sequence_no integer,
    domain_payload jsonb,
    PRIMARY KEY (risk_assessment_version_uuid, domain_code)
);

COMMIT;
