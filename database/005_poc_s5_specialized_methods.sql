-- OES-DBM-2026-0005
-- PoC-S5 — Specialized methods: NMA, PredictionModel, Qualitative/CERQual
-- Depends on: baseline + migrations 002, 003 and 004
-- Status: experimental, non-production
-- Date: 2026-10-04

BEGIN;

-- ---------------------------------------------------------------------------
-- STUDY GROUPS — required for NMA node mapping
-- ---------------------------------------------------------------------------

CREATE TABLE evidence.study_group (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid),
    study_entity_uuid uuid NOT NULL REFERENCES evidence.study(entity_uuid)
);

CREATE TRIGGER tr_study_group_entity_type
BEFORE INSERT OR UPDATE OF entity_uuid ON evidence.study_group
FOR EACH ROW EXECUTE FUNCTION core.assert_entity_type('StudyGroup');

CREATE TABLE evidence.study_group_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES evidence.study_group(entity_uuid),
    label text NOT NULL,
    group_type text,
    n_planned integer CHECK (n_planned IS NULL OR n_planned >= 0),
    n_analyzed integer CHECK (n_analyzed IS NULL OR n_analyzed >= 0),
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE INDEX ix_study_group_study
    ON evidence.study_group(study_entity_uuid);

CREATE TABLE evidence.group_component (
    component_uuid uuid PRIMARY KEY,
    study_group_version_uuid uuid NOT NULL
        REFERENCES evidence.study_group_version(version_uuid),
    component_type text NOT NULL,
    label text NOT NULL,
    dose_or_intensity jsonb,
    duration jsonb,
    notes text
);

ALTER TABLE evidence.result_version
    ADD COLUMN group_a_entity_uuid uuid
        REFERENCES evidence.study_group(entity_uuid),
    ADD COLUMN group_b_entity_uuid uuid
        REFERENCES evidence.study_group(entity_uuid),
    ADD CONSTRAINT ck_result_distinct_groups
        CHECK (
            group_a_entity_uuid IS NULL
            OR group_b_entity_uuid IS NULL
            OR group_a_entity_uuid <> group_b_entity_uuid
        );

CREATE OR REPLACE FUNCTION evidence.assert_result_group_study()
RETURNS trigger
LANGUAGE plpgsql
AS $result_group$
DECLARE
    result_study uuid;
    group_study uuid;
BEGIN
    SELECT r.study_entity_uuid
      INTO result_study
      FROM evidence.result r
     WHERE r.entity_uuid = NEW.entity_uuid;

    IF result_study IS NULL THEN
        RAISE EXCEPTION 'Result entity % does not exist', NEW.entity_uuid;
    END IF;

    IF NEW.group_a_entity_uuid IS NOT NULL THEN
        SELECT sg.study_entity_uuid
          INTO group_study
          FROM evidence.study_group sg
         WHERE sg.entity_uuid = NEW.group_a_entity_uuid;

        IF group_study IS DISTINCT FROM result_study THEN
            RAISE EXCEPTION
                'Result % belongs to Study %, but group A % belongs to Study %',
                NEW.entity_uuid, result_study, NEW.group_a_entity_uuid, group_study;
        END IF;
    END IF;

    IF NEW.group_b_entity_uuid IS NOT NULL THEN
        SELECT sg.study_entity_uuid
          INTO group_study
          FROM evidence.study_group sg
         WHERE sg.entity_uuid = NEW.group_b_entity_uuid;

        IF group_study IS DISTINCT FROM result_study THEN
            RAISE EXCEPTION
                'Result % belongs to Study %, but group B % belongs to Study %',
                NEW.entity_uuid, result_study, NEW.group_b_entity_uuid, group_study;
        END IF;
    END IF;

    RETURN NEW;
END;
$result_group$;

CREATE TRIGGER tr_result_group_study
BEFORE INSERT OR UPDATE OF entity_uuid, group_a_entity_uuid, group_b_entity_uuid
ON evidence.result_version
FOR EACH ROW EXECUTE FUNCTION evidence.assert_result_group_study();

-- ---------------------------------------------------------------------------
-- PREDICTION MODEL
-- ---------------------------------------------------------------------------

CREATE TABLE evidence.prediction_model (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid)
);

CREATE TRIGGER tr_prediction_model_entity_type
BEFORE INSERT OR UPDATE OF entity_uuid ON evidence.prediction_model
FOR EACH ROW EXECUTE FUNCTION core.assert_entity_type('PredictionModel');

CREATE TABLE evidence.prediction_model_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES evidence.prediction_model(entity_uuid),
    name_or_label text NOT NULL,
    target_outcome_entity_uuid uuid REFERENCES evidence.outcome(entity_uuid),
    intended_use text,
    model_type text,
    development_study_entity_uuid uuid REFERENCES evidence.study(entity_uuid),
    specification_payload jsonb,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE evidence.prediction_model_identifier (
    prediction_model_entity_uuid uuid NOT NULL
        REFERENCES evidence.prediction_model(entity_uuid),
    namespace text NOT NULL,
    value text NOT NULL,
    normalized_value text NOT NULL,
    verified_at timestamptz,
    PRIMARY KEY (
        prediction_model_entity_uuid,
        namespace,
        normalized_value
    )
);

CREATE TABLE evidence.prediction_model_study_role (
    prediction_model_entity_uuid uuid NOT NULL
        REFERENCES evidence.prediction_model(entity_uuid),
    study_entity_uuid uuid NOT NULL REFERENCES evidence.study(entity_uuid),
    role text NOT NULL CHECK (
        role IN (
            'development',
            'internal_validation',
            'external_validation',
            'updating',
            'impact_evaluation'
        )
    ),
    notes text,
    PRIMARY KEY (
        prediction_model_entity_uuid,
        study_entity_uuid,
        role
    )
);

ALTER TABLE evidence.result
    ADD COLUMN prediction_model_entity_uuid uuid
        REFERENCES evidence.prediction_model(entity_uuid);

CREATE INDEX ix_result_prediction_model
    ON evidence.result(prediction_model_entity_uuid);

-- ---------------------------------------------------------------------------
-- NMA STRUCTURE
-- ---------------------------------------------------------------------------

CREATE TABLE synthesis.node (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid),
    synthesis_entity_uuid uuid NOT NULL
        REFERENCES synthesis.synthesis(entity_uuid)
);

CREATE TRIGGER tr_synthesis_node_entity_type
BEFORE INSERT OR UPDATE OF entity_uuid ON synthesis.node
FOR EACH ROW EXECUTE FUNCTION core.assert_entity_type('SynthesisNode');

CREATE TABLE synthesis.node_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES synthesis.node(entity_uuid),
    label text NOT NULL,
    node_definition jsonb,
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE synthesis.node_mapping (
    synthesis_node_version_uuid uuid NOT NULL
        REFERENCES synthesis.node_version(version_uuid),
    study_group_version_uuid uuid NOT NULL
        REFERENCES evidence.study_group_version(version_uuid),
    mapping_rationale text,
    reviewer text,
    status text NOT NULL DEFAULT 'active',
    PRIMARY KEY (
        synthesis_node_version_uuid,
        study_group_version_uuid
    )
);

CREATE TABLE synthesis.contrast (
    contrast_uuid uuid PRIMARY KEY,
    synthesis_version_uuid uuid NOT NULL
        REFERENCES synthesis.synthesis_version(version_uuid),
    node_a_version_uuid uuid NOT NULL
        REFERENCES synthesis.node_version(version_uuid),
    node_b_version_uuid uuid NOT NULL
        REFERENCES synthesis.node_version(version_uuid),
    contrast_type text NOT NULL,
    status text NOT NULL DEFAULT 'active',
    CHECK (node_a_version_uuid <> node_b_version_uuid),
    UNIQUE (
        synthesis_version_uuid,
        node_a_version_uuid,
        node_b_version_uuid,
        contrast_type
    )
);

CREATE OR REPLACE FUNCTION synthesis.assert_contrast_nodes_same_synthesis()
RETURNS trigger
LANGUAGE plpgsql
AS $contrast$
DECLARE
    synthesis_entity uuid;
    node_a_synthesis uuid;
    node_b_synthesis uuid;
BEGIN
    SELECT sv.entity_uuid
      INTO synthesis_entity
      FROM synthesis.synthesis_version sv
     WHERE sv.version_uuid = NEW.synthesis_version_uuid;

    SELECT n.synthesis_entity_uuid
      INTO node_a_synthesis
      FROM synthesis.node_version nv
      JOIN synthesis.node n ON n.entity_uuid = nv.entity_uuid
     WHERE nv.version_uuid = NEW.node_a_version_uuid;

    SELECT n.synthesis_entity_uuid
      INTO node_b_synthesis
      FROM synthesis.node_version nv
      JOIN synthesis.node n ON n.entity_uuid = nv.entity_uuid
     WHERE nv.version_uuid = NEW.node_b_version_uuid;

    IF node_a_synthesis IS DISTINCT FROM synthesis_entity
       OR node_b_synthesis IS DISTINCT FROM synthesis_entity THEN
        RAISE EXCEPTION
            'Contrast nodes must belong to synthesis entity %; got node syntheses % and %',
            synthesis_entity, node_a_synthesis, node_b_synthesis;
    END IF;

    RETURN NEW;
END;
$contrast$;

CREATE TRIGGER tr_contrast_nodes_same_synthesis
BEFORE INSERT OR UPDATE OF synthesis_version_uuid, node_a_version_uuid, node_b_version_uuid
ON synthesis.contrast
FOR EACH ROW EXECUTE FUNCTION synthesis.assert_contrast_nodes_same_synthesis();

-- ---------------------------------------------------------------------------
-- QUALITATIVE SYNTHESIS / CERQUAL
-- ---------------------------------------------------------------------------

CREATE TABLE synthesis.review_finding (
    entity_uuid uuid PRIMARY KEY REFERENCES core.entity(entity_uuid),
    synthesis_entity_uuid uuid NOT NULL
        REFERENCES synthesis.synthesis(entity_uuid)
);

CREATE TRIGGER tr_review_finding_entity_type
BEFORE INSERT OR UPDATE OF entity_uuid ON synthesis.review_finding
FOR EACH ROW EXECUTE FUNCTION core.assert_entity_type('ReviewFinding');

CREATE TABLE synthesis.review_finding_version (
    version_uuid uuid PRIMARY KEY,
    entity_uuid uuid NOT NULL REFERENCES synthesis.review_finding(entity_uuid),
    finding_text text NOT NULL,
    phenomenon text,
    supporting_study_count integer CHECK (
        supporting_study_count IS NULL OR supporting_study_count >= 0
    ),
    status text NOT NULL,
    FOREIGN KEY (version_uuid, entity_uuid)
        REFERENCES core.entity_version(version_uuid, entity_uuid)
);

CREATE TABLE synthesis.finding_contribution (
    review_finding_version_uuid uuid NOT NULL
        REFERENCES synthesis.review_finding_version(version_uuid),
    study_entity_uuid uuid NOT NULL REFERENCES evidence.study(entity_uuid),
    report_entity_uuid uuid REFERENCES evidence.report(entity_uuid),
    contribution_role text NOT NULL,
    relevance_note text,
    adequacy_note text,
    notes text,
    PRIMARY KEY (
        review_finding_version_uuid,
        study_entity_uuid,
        contribution_role
    )
);

ALTER TABLE appraisal.certainty_assessment_version
    ADD COLUMN review_finding_version_uuid uuid
        REFERENCES synthesis.review_finding_version(version_uuid),
    ADD CONSTRAINT ck_cerqual_requires_review_finding
        CHECK (
            lower(framework) NOT LIKE '%cerqual%'
            OR review_finding_version_uuid IS NOT NULL
        );

CREATE INDEX ix_certainty_review_finding
    ON appraisal.certainty_assessment_version(review_finding_version_uuid);

COMMIT;
