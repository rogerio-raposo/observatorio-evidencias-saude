-- OES PoC-S1 — Minimal schema proof of concept
-- Status: experimental, non-production
-- Reference dialect: PostgreSQL
-- Date: 2026-10-03
--
-- Purpose:
-- Validate OES-P1 identity, immutable versions, core evidence lineage,
-- provenance, and artifact metadata. This file intentionally excludes
-- search automation, monitoring, AI, specialized NMA/DTA/prediction tables,
-- and production security/operational configuration.

BEGIN;

CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS investigation;
CREATE SCHEMA IF NOT EXISTS evidence;
CREATE SCHEMA IF NOT EXISTS synthesis;
CREATE SCHEMA IF NOT EXISTS appraisal;
CREATE SCHEMA IF NOT EXISTS product;
CREATE SCHEMA IF NOT EXISTS provenance;
CREATE SCHEMA IF NOT EXISTS artifact;

-- ---------------------------------------------------------------------------
-- CORE REGISTRY
-- ---------------------------------------------------------------------------

CREATE TABLE core.entity (
    entity_uuid uuid PRIMARY KEY,
    oes_id text NOT NULL UNIQUE,
    entity_type text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    retired_at timestamptz,
    CHECK (length(trim(oes_id)) > 0),
    CHECK (length(trim(entity_type)) > 0)
);

CREATE TABLE core.entity_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES core.entity(entity_uuid),
    version_no integer NOT NULL CHECK (version_no > 0),
    version_status text NOT NULL CHECK (
        version_status IN ('draft','current','superseded','archived','invalidated')
    ),
    valid_from timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to timestamptz,
    supersedes_version_uuid uuid REFERENCES core.entity_version(version_uuid),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    change_type text NOT NULL,
    change_note text,
    UNIQUE (entity_uuid, version_no),
    UNIQUE (version_uuid, entity_uuid),
    CHECK (valid_to IS NULL OR valid_to >= valid_from),
    CHECK (supersedes_version_uuid IS NULL OR supersedes_version_uuid <> version_uuid)
);

CREATE UNIQUE INDEX ux_entity_version_current
    ON core.entity_version(entity_uuid)
    WHERE version_status = 'current';

CREATE INDEX ix_entity_type ON core.entity(entity_type);
CREATE INDEX ix_entity_version_entity ON core.entity_version(entity_uuid);

-- ---------------------------------------------------------------------------
-- ARTIFACT METADATA
-- ---------------------------------------------------------------------------

CREATE TABLE artifact.artifact (
    artifact_uuid uuid PRIMARY KEY,
    artifact_type text NOT NULL,
    storage_key text NOT NULL UNIQUE,
    content_hash text NOT NULL,
    hash_algorithm text NOT NULL DEFAULT 'sha256',
    mime_type text,
    byte_size bigint CHECK (byte_size IS NULL OR byte_size >= 0),
    original_filename text,
    source_uri text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    status text NOT NULL DEFAULT 'active'
);

CREATE TABLE artifact.entity_link (
    artifact_uuid uuid NOT NULL REFERENCES artifact.artifact(artifact_uuid),
    entity_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
    role text NOT NULL,
    sequence_no integer,
    PRIMARY KEY (artifact_uuid, entity_version_uuid, role)
);

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.question (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE investigation.question_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES investigation.question(entity_uuid),
    parent_question_entity_uuid uuid REFERENCES investigation.question(entity_uuid),
    original_text text NOT NULL,
    normalized_text text NOT NULL,
    question_type text,
    structure_type text,
    context_payload jsonb,
    time_horizon_payload jsonb,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE investigation.investigation (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE investigation.investigation_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES investigation.investigation(entity_uuid),
    primary_question_entity_uuid uuid NOT NULL REFERENCES investigation.question(entity_uuid),
    investigation_type text,
    depth_level text NOT NULL CHECK (depth_level IN ('N0','N1','N2','N3','N4')),
    maintenance_level text NOT NULL CHECK (maintenance_level IN ('M0','M1','M2','M3')),
    objective text,
    protocol_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    start_date date,
    evidence_cutoff_date date,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE investigation.investigation_question (
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    question_version_uuid uuid NOT NULL
        REFERENCES investigation.question_version(version_uuid),
    role text NOT NULL,
    sequence_no integer,
    PRIMARY KEY (investigation_version_uuid, question_version_uuid, role)
);

-- ---------------------------------------------------------------------------
-- STUDY / REPORT
-- ---------------------------------------------------------------------------

CREATE TABLE evidence.study (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE evidence.study_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES evidence.study(entity_uuid),
    study_type text NOT NULL,
    design text,
    title_or_label text,
    start_date date,
    end_date date,
    recruitment_context jsonb,
    sample_size integer CHECK (sample_size IS NULL OR sample_size >= 0),
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid),
    CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE evidence.report (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE evidence.report_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES evidence.report(entity_uuid),
    report_type text NOT NULL,
    title text,
    publication_date date,
    journal_or_source text,
    language text,
    publication_status text,
    full_text_status text,
    bibliographic_payload jsonb,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE evidence.study_report_link (
    link_uuid uuid PRIMARY KEY,
    study_entity_uuid uuid NOT NULL REFERENCES evidence.study(entity_uuid),
    report_entity_uuid uuid NOT NULL REFERENCES evidence.report(entity_uuid),
    relation_type text NOT NULL,
    confidence text,
    evidence_note text,
    reviewer text,
    decision_date date,
    valid_from timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to timestamptz,
    status text NOT NULL DEFAULT 'active',
    CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

CREATE INDEX ix_study_report_study
    ON evidence.study_report_link(study_entity_uuid);
CREATE INDEX ix_study_report_report
    ON evidence.study_report_link(report_entity_uuid);

-- ---------------------------------------------------------------------------
-- OUTCOME / RESULT
-- ---------------------------------------------------------------------------

CREATE TABLE evidence.outcome (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE evidence.outcome_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES evidence.outcome(entity_uuid),
    preferred_name text NOT NULL,
    definition text,
    domain text,
    direction_of_benefit text,
    unit_family text,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE evidence.result (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid),
    study_entity_uuid uuid NOT NULL REFERENCES evidence.study(entity_uuid)
);

CREATE TABLE evidence.result_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES evidence.result(entity_uuid),
    outcome_entity_uuid uuid REFERENCES evidence.outcome(entity_uuid),
    population_descriptor jsonb,
    timepoint_value numeric,
    timepoint_unit text,
    timepoint_label text,
    estimand text,
    measure text NOT NULL,
    reported_value jsonb,
    derived_value jsonb,
    variance_or_se jsonb,
    ci_lower numeric,
    ci_upper numeric,
    unit text,
    adjusted_flag boolean,
    analysis_population text,
    missing_data_state text,
    method_payload jsonb,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid),
    CHECK (
        ci_lower IS NULL OR ci_upper IS NULL OR ci_lower <= ci_upper
    ),
    CHECK (
        reported_value IS NOT NULL OR derived_value IS NOT NULL
    )
);

CREATE INDEX ix_result_study ON evidence.result(study_entity_uuid);
CREATE INDEX ix_result_version_outcome ON evidence.result_version(outcome_entity_uuid);

CREATE TABLE evidence.result_source (
    result_version_uuid uuid NOT NULL REFERENCES evidence.result_version(version_uuid),
    report_version_uuid uuid NOT NULL REFERENCES evidence.report_version(version_uuid),
    source_location text NOT NULL,
    source_type text,
    original_text_or_value jsonb,
    extraction_method text,
    is_primary_source boolean NOT NULL DEFAULT false,
    extractor text,
    extracted_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (result_version_uuid, report_version_uuid, source_location)
);

-- ---------------------------------------------------------------------------
-- SYNTHESIS
-- ---------------------------------------------------------------------------

CREATE TABLE synthesis.synthesis (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE synthesis.synthesis_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES synthesis.synthesis(entity_uuid),
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    outcome_entity_uuid uuid REFERENCES evidence.outcome(entity_uuid),
    population_descriptor jsonb,
    comparison_payload jsonb,
    timepoint_payload jsonb,
    estimand text,
    synthesis_type text NOT NULL,
    synthesis_origin text NOT NULL,
    method text,
    model text,
    software text,
    software_version text,
    code_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    analysis_dataset_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    result_summary jsonb,
    status text NOT NULL,
    executed_at timestamptz,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE synthesis.contribution (
    synthesis_version_uuid uuid NOT NULL
        REFERENCES synthesis.synthesis_version(version_uuid),
    result_version_uuid uuid NOT NULL
        REFERENCES evidence.result_version(version_uuid),
    contribution_role text NOT NULL,
    transformed_value jsonb,
    weight numeric,
    included_main_analysis boolean NOT NULL DEFAULT true,
    included_sensitivity boolean NOT NULL DEFAULT false,
    exclusion_reason text,
    notes text,
    PRIMARY KEY (synthesis_version_uuid, result_version_uuid)
);

CREATE INDEX ix_contribution_result
    ON synthesis.contribution(result_version_uuid);

-- ---------------------------------------------------------------------------
-- CERTAINTY
-- ---------------------------------------------------------------------------

CREATE TABLE appraisal.certainty_assessment (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE appraisal.certainty_assessment_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES appraisal.certainty_assessment(entity_uuid),
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    synthesis_version_uuid uuid REFERENCES synthesis.synthesis_version(version_uuid),
    outcome_entity_uuid uuid REFERENCES evidence.outcome(entity_uuid),
    framework text NOT NULL,
    framework_version text,
    initial_level text,
    final_level text,
    evidence_state text NOT NULL DEFAULT 'evidence_available',
    assessment_date date NOT NULL,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid),
    CHECK (
        evidence_state <> 'no_evidence'
        OR final_level IS NULL
    )
);

CREATE TABLE appraisal.certainty_domain (
    certainty_assessment_version_uuid uuid NOT NULL
        REFERENCES appraisal.certainty_assessment_version(version_uuid),
    domain_code text NOT NULL,
    concern_level text,
    downgrade_steps integer CHECK (downgrade_steps IS NULL OR downgrade_steps >= 0),
    upgrade_steps integer CHECK (upgrade_steps IS NULL OR upgrade_steps >= 0),
    rationale text NOT NULL,
    reviewer text,
    sequence_no integer,
    payload jsonb,
    PRIMARY KEY (certainty_assessment_version_uuid, domain_code)
);

-- ---------------------------------------------------------------------------
-- PRODUCT
-- ---------------------------------------------------------------------------

CREATE TABLE product.product (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TABLE product.product_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES product.product(entity_uuid),
    product_type text NOT NULL,
    title text NOT NULL,
    intended_audience text,
    evidence_cutoff_date date NOT NULL,
    publication_date date,
    status text NOT NULL,
    conclusion_text text,
    applicability_summary text,
    rendered_artifact_uuid uuid REFERENCES artifact.artifact(artifact_uuid),
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE product.investigation_link (
    product_version_uuid uuid NOT NULL REFERENCES product.product_version(version_uuid),
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    role text NOT NULL,
    sequence_no integer,
    PRIMARY KEY (product_version_uuid, investigation_version_uuid, role)
);

CREATE TABLE product.synthesis_link (
    product_version_uuid uuid NOT NULL REFERENCES product.product_version(version_uuid),
    synthesis_version_uuid uuid NOT NULL
        REFERENCES synthesis.synthesis_version(version_uuid),
    role text NOT NULL,
    sequence_no integer,
    PRIMARY KEY (product_version_uuid, synthesis_version_uuid, role)
);

CREATE TABLE product.certainty_link (
    product_version_uuid uuid NOT NULL REFERENCES product.product_version(version_uuid),
    certainty_assessment_version_uuid uuid NOT NULL
        REFERENCES appraisal.certainty_assessment_version(version_uuid),
    role text NOT NULL,
    sequence_no integer,
    PRIMARY KEY (
        product_version_uuid,
        certainty_assessment_version_uuid,
        role
    )
);

-- ---------------------------------------------------------------------------
-- PROVENANCE
-- ---------------------------------------------------------------------------

CREATE TABLE provenance.record (
    provenance_uuid uuid PRIMARY KEY,
    target_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
    field_path text NOT NULL,
    source_report_version_uuid uuid REFERENCES evidence.report_version(version_uuid),
    source_location text,
    source_value jsonb,
    process_type text,
    process_record_uuid uuid,
    transformation jsonb,
    actor text,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ix_provenance_target
    ON provenance.record(target_version_uuid);
CREATE INDEX ix_provenance_source_report
    ON provenance.record(source_report_version_uuid);

-- ---------------------------------------------------------------------------
-- DEPENDENCY PROJECTION
-- ---------------------------------------------------------------------------

CREATE TABLE provenance.dependency_edge (
    source_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
    target_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
    dependency_type text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    derivation_rule text NOT NULL,
    status text NOT NULL DEFAULT 'active',
    PRIMARY KEY (source_version_uuid, target_version_uuid, dependency_type),
    CHECK (source_version_uuid <> target_version_uuid)
);

CREATE INDEX ix_dependency_target
    ON provenance.dependency_edge(target_version_uuid);

-- ---------------------------------------------------------------------------
-- CURRENT-VERSION VIEWS
-- ---------------------------------------------------------------------------

CREATE VIEW core.current_entity_version AS
SELECT ev.*
FROM core.entity_version ev
WHERE ev.version_status = 'current';

CREATE VIEW evidence.current_result AS
SELECT r.entity_uuid,
       rv.*
FROM evidence.result r
JOIN evidence.result_version rv
  ON rv.entity_uuid = r.entity_uuid
JOIN core.entity_version ev
  ON ev.version_uuid = rv.version_uuid
WHERE ev.version_status = 'current';

CREATE VIEW synthesis.current_synthesis AS
SELECT s.entity_uuid,
       sv.*
FROM synthesis.synthesis s
JOIN synthesis.synthesis_version sv
  ON sv.entity_uuid = s.entity_uuid
JOIN core.entity_version ev
  ON ev.version_uuid = sv.version_uuid
WHERE ev.version_status = 'current';

CREATE VIEW appraisal.current_certainty AS
SELECT ca.entity_uuid,
       cav.*
FROM appraisal.certainty_assessment ca
JOIN appraisal.certainty_assessment_version cav
  ON cav.entity_uuid = ca.entity_uuid
JOIN core.entity_version ev
  ON ev.version_uuid = cav.version_uuid
WHERE ev.version_status = 'current';

CREATE VIEW product.current_product AS
SELECT p.entity_uuid,
       pv.*
FROM product.product p
JOIN product.product_version pv
  ON pv.entity_uuid = p.entity_uuid
JOIN core.entity_version ev
  ON ev.version_uuid = pv.version_uuid
WHERE ev.version_status = 'current';

COMMIT;
