-- OES-DBM-2026-0019
-- Fase 3 — Overview of Reviews contract v0.1
-- Depends on: baseline + migrations 002–018
-- Date: 2026-10-06
-- Contract source: docs/products/140-contrato-dados-overview-revisoes.md
-- One-shot migration. No renderer/template is introduced here.

BEGIN;

CREATE SCHEMA overview;

-- ---------------------------------------------------------------------------
-- GENERIC VERIFICATION SEMANTICS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION overview.verification_semantics_valid(
    p_status text,
    p_verified_by text,
    p_verifier_actor_type text,
    p_verified_at timestamptz
)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
AS $verify$
    SELECT CASE
        WHEN p_status='unverified' THEN
            p_verified_by IS NULL
            AND p_verifier_actor_type IS NULL
            AND p_verified_at IS NULL
        WHEN p_status='ai_verified' THEN
            p_verified_by IS NOT NULL
            AND p_verifier_actor_type='ai_system'
            AND p_verified_at IS NOT NULL
        WHEN p_status IN ('human_verified','human_consensus') THEN
            p_verified_by IS NOT NULL
            AND p_verifier_actor_type IN ('human_reviewer','human_expert')
            AND p_verified_at IS NOT NULL
        ELSE false
    END;
$verify$;

-- ---------------------------------------------------------------------------
-- 1. REVIEW ITEM
-- ---------------------------------------------------------------------------

CREATE TABLE overview.review_item (
    review_item_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    review_study_version_uuid uuid NOT NULL
        REFERENCES evidence.study_version(version_uuid),
    item_role text NOT NULL CHECK (
        item_role IN ('primary','supporting','contextual')
    ),
    eligibility_basis_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    last_search_date date,
    membership_completeness text NOT NULL CHECK (
        membership_completeness IN ('complete','partial','unknown')
    ),
    currentness_status text NOT NULL CHECK (
        currentness_status IN (
            'current','possibly_outdated','outdated','unclear'
        )
    ),
    currentness_rationale text,
    included_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded','excluded')
    ),
    UNIQUE (investigation_version_uuid,review_study_version_uuid),
    CHECK (
        currentness_status='current'
        OR length(btrim(COALESCE(currentness_rationale,'')))>0
    )
);

CREATE INDEX ix_overview_review_item_investigation
    ON overview.review_item(investigation_version_uuid,status);

CREATE INDEX ix_overview_review_item_version
    ON overview.review_item(review_study_version_uuid);

CREATE OR REPLACE FUNCTION overview.assert_review_item_target()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    v_study_type text;
    v_study_entity uuid;
    v_version_status text;
BEGIN
    SELECT sv.study_type,sv.entity_uuid,ev.version_status
      INTO v_study_type,v_study_entity,v_version_status
      FROM evidence.study_version sv
      JOIN core.entity_version ev
        ON ev.version_uuid=sv.version_uuid
     WHERE sv.version_uuid=NEW.review_study_version_uuid;

    IF v_study_entity IS NULL THEN
        RAISE EXCEPTION 'Overview ReviewItem target StudyVersion % does not exist',
            NEW.review_study_version_uuid;
    END IF;

    IF v_study_type<>'systematic_review' THEN
        RAISE EXCEPTION
            'Overview v0.1 ReviewItem requires study_type=systematic_review; found %',
            v_study_type;
    END IF;

    IF v_version_status<>'current'
       AND lower(COALESCE(
            NEW.eligibility_basis_payload->>'historical_version_selected',
            'false'
       ))<>'true'
    THEN
        RAISE EXCEPTION
            'Historical Review StudyVersion requires explicit historical_version_selected=true';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM provenance.record pr
         WHERE pr.target_version_uuid=NEW.review_study_version_uuid
           AND pr.status='invalidated'
    ) THEN
        RAISE EXCEPTION
            'Invalidated Review StudyVersion cannot be an active Overview ReviewItem';
    END IF;

    IF NEW.status='active' AND EXISTS (
        SELECT 1
          FROM overview.review_item ri
          JOIN evidence.study_version existing_sv
            ON existing_sv.version_uuid=ri.review_study_version_uuid
         WHERE ri.investigation_version_uuid=NEW.investigation_version_uuid
           AND ri.status='active'
           AND existing_sv.entity_uuid=v_study_entity
           AND ri.review_item_uuid<>NEW.review_item_uuid
    ) THEN
        RAISE EXCEPTION
            'Only one active ReviewItem per Review Study entity is allowed within an InvestigationVersion';
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_review_item_target
BEFORE INSERT OR UPDATE OF
    review_study_version_uuid,investigation_version_uuid,
    eligibility_basis_payload,status
ON overview.review_item
FOR EACH ROW EXECUTE FUNCTION overview.assert_review_item_target();

-- ---------------------------------------------------------------------------
-- 2. PRIMARY-STUDY MEMBERSHIP
-- ---------------------------------------------------------------------------

CREATE TABLE overview.primary_study_membership (
    membership_uuid uuid PRIMARY KEY,
    review_item_uuid uuid NOT NULL
        REFERENCES overview.review_item(review_item_uuid),
    primary_study_entity_uuid uuid NOT NULL
        REFERENCES evidence.study(entity_uuid),
    source_report_version_uuid uuid
        REFERENCES evidence.report_version(version_uuid),
    source_location text,
    identity_confidence text NOT NULL CHECK (
        identity_confidence IN ('high','medium','low')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IS NULL
        OR verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    context_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    UNIQUE (review_item_uuid,primary_study_entity_uuid),
    CHECK (
        overview.verification_semantics_valid(
            verification_status,
            verified_by,
            verifier_actor_type,
            verified_at
        )
    )
);

CREATE INDEX ix_overview_membership_review
    ON overview.primary_study_membership(review_item_uuid,status);

CREATE INDEX ix_overview_membership_primary_study
    ON overview.primary_study_membership(primary_study_entity_uuid);

CREATE OR REPLACE FUNCTION overview.assert_primary_study_membership()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    review_study_entity uuid;
    report_entity uuid;
BEGIN
    SELECT sv.entity_uuid
      INTO review_study_entity
      FROM overview.review_item ri
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
     WHERE ri.review_item_uuid=NEW.review_item_uuid;

    IF review_study_entity IS NULL THEN
        RAISE EXCEPTION 'ReviewItem % does not exist',NEW.review_item_uuid;
    END IF;

    IF NEW.primary_study_entity_uuid=review_study_entity THEN
        RAISE EXCEPTION 'Review Study cannot be its own primary-study membership';
    END IF;

    IF NEW.source_report_version_uuid IS NOT NULL THEN
        SELECT rv.entity_uuid
          INTO report_entity
          FROM evidence.report_version rv
         WHERE rv.version_uuid=NEW.source_report_version_uuid;

        IF NOT EXISTS (
            SELECT 1
              FROM evidence.study_report_link srl
             WHERE srl.study_entity_uuid=review_study_entity
               AND srl.report_entity_uuid=report_entity
               AND srl.status='active'
        ) THEN
            RAISE EXCEPTION
                'Membership source Report must belong to the Review Study';
        END IF;
    END IF;

    IF NEW.identity_confidence='low'
       AND NEW.verification_status='human_consensus'
       AND length(btrim(COALESCE(
            NEW.context_payload->>'identity_rationale',''
       )))=0
    THEN
        RAISE EXCEPTION
            'Low-confidence human-consensus membership requires identity_rationale';
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_primary_study_membership
BEFORE INSERT OR UPDATE OF
    review_item_uuid,primary_study_entity_uuid,source_report_version_uuid,
    identity_confidence,verification_status,verified_by,
    verifier_actor_type,verified_at,context_payload
ON overview.primary_study_membership
FOR EACH ROW EXECUTE FUNCTION overview.assert_primary_study_membership();

-- ---------------------------------------------------------------------------
-- 3. REVIEW CLUSTER
-- ---------------------------------------------------------------------------

CREATE TABLE overview.review_cluster (
    cluster_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    cluster_code text NOT NULL CHECK (
        length(btrim(cluster_code))>0
    ),
    label text NOT NULL CHECK (
        length(btrim(label))>0
    ),
    scope_payload jsonb NOT NULL,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    UNIQUE (investigation_version_uuid,cluster_code)
);

CREATE INDEX ix_overview_cluster_investigation
    ON overview.review_cluster(investigation_version_uuid,status);

-- ---------------------------------------------------------------------------
-- 4. CLUSTER MEMBERSHIP
-- ---------------------------------------------------------------------------

CREATE TABLE overview.cluster_membership (
    cluster_uuid uuid NOT NULL
        REFERENCES overview.review_cluster(cluster_uuid),
    review_item_uuid uuid NOT NULL
        REFERENCES overview.review_item(review_item_uuid),
    analysis_disposition text NOT NULL CHECK (
        analysis_disposition IN (
            'retained','prioritized','excluded_overlap','contextual_only'
        )
    ),
    rationale text NOT NULL CHECK (
        length(btrim(rationale))>0
    ),
    sequence_no integer CHECK (
        sequence_no IS NULL OR sequence_no>0
    ),
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    PRIMARY KEY (cluster_uuid,review_item_uuid)
);

CREATE INDEX ix_overview_cluster_membership_review
    ON overview.cluster_membership(review_item_uuid,status);

CREATE OR REPLACE FUNCTION overview.assert_cluster_membership_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    cluster_inv uuid;
    cluster_status text;
    review_inv uuid;
    review_status text;
    review_role text;
BEGIN
    SELECT investigation_version_uuid,status
      INTO cluster_inv,cluster_status
      FROM overview.review_cluster
     WHERE cluster_uuid=NEW.cluster_uuid;

    SELECT investigation_version_uuid,status,item_role
      INTO review_inv,review_status,review_role
      FROM overview.review_item
     WHERE review_item_uuid=NEW.review_item_uuid;

    IF cluster_inv IS DISTINCT FROM review_inv THEN
        RAISE EXCEPTION
            'Cluster and ReviewItem must belong to the same InvestigationVersion';
    END IF;

    IF NEW.status='active'
       AND (cluster_status<>'active' OR review_status<>'active')
    THEN
        RAISE EXCEPTION
            'Active ClusterMembership requires active Cluster and ReviewItem';
    END IF;

    IF review_role='contextual'
       AND NEW.analysis_disposition NOT IN ('contextual_only','retained')
    THEN
        RAISE EXCEPTION
            'Contextual ReviewItem may only be contextual_only or retained';
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_cluster_membership_consistency
BEFORE INSERT OR UPDATE OF
    cluster_uuid,review_item_uuid,analysis_disposition,status
ON overview.cluster_membership
FOR EACH ROW EXECUTE FUNCTION overview.assert_cluster_membership_consistency();

-- ---------------------------------------------------------------------------
-- 5. OVERLAP RESOLUTION
-- ---------------------------------------------------------------------------

CREATE TABLE overview.overlap_resolution (
    overlap_resolution_uuid uuid PRIMARY KEY,
    cluster_uuid uuid NOT NULL
        REFERENCES overview.review_cluster(cluster_uuid),
    strategy text NOT NULL CHECK (
        strategy IN (
            'include_all_deduplicate_outcomes',
            'prioritize_review',
            'include_all_separate_estimates'
        )
    ),
    decision_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text NOT NULL CHECK (
        length(btrim(rationale))>0
    ),
    decided_by text NOT NULL CHECK (
        length(btrim(decided_by))>0
    ),
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IS NULL
        OR verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    decided_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    CHECK (
        overview.verification_semantics_valid(
            verification_status,
            verified_by,
            verifier_actor_type,
            verified_at
        )
    )
);

CREATE UNIQUE INDEX ux_overview_one_active_overlap_resolution
    ON overview.overlap_resolution(cluster_uuid)
    WHERE status='active';

CREATE OR REPLACE FUNCTION overview.assert_overlap_resolution_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    cluster_status text;
    prioritized_count integer;
    excluded_count integer;
BEGIN
    SELECT status
      INTO cluster_status
      FROM overview.review_cluster
     WHERE cluster_uuid=NEW.cluster_uuid;

    IF cluster_status IS NULL OR cluster_status<>'active' THEN
        RAISE EXCEPTION 'OverlapResolution requires an active ReviewCluster';
    END IF;

    SELECT count(*)
      INTO prioritized_count
      FROM overview.cluster_membership cm
     WHERE cm.cluster_uuid=NEW.cluster_uuid
       AND cm.status='active'
       AND cm.analysis_disposition='prioritized';

    IF NEW.strategy='prioritize_review'
       AND prioritized_count<>1
    THEN
        RAISE EXCEPTION
            'prioritize_review requires exactly one active prioritized ReviewItem';
    END IF;

    SELECT count(*)
      INTO excluded_count
      FROM overview.cluster_membership cm
     WHERE cm.cluster_uuid=NEW.cluster_uuid
       AND cm.status='active'
       AND cm.analysis_disposition='excluded_overlap';

    IF NEW.strategy='include_all_separate_estimates'
       AND excluded_count>0
       AND length(btrim(COALESCE(
            NEW.decision_payload->>'excluded_overlap_exception_rationale',''
       )))=0
    THEN
        RAISE EXCEPTION
            'include_all_separate_estimates with excluded_overlap requires explicit exception rationale';
    END IF;

    IF NEW.strategy='include_all_deduplicate_outcomes' THEN
        NEW.decision_payload :=
            NEW.decision_payload ||
            '{"formal_v01_supported":false}'::jsonb;
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_overlap_resolution_consistency
BEFORE INSERT OR UPDATE OF
    cluster_uuid,strategy,decision_payload,
    verification_status,verified_by,verifier_actor_type,verified_at,status
ON overview.overlap_resolution
FOR EACH ROW EXECUTE FUNCTION overview.assert_overlap_resolution_consistency();

-- ---------------------------------------------------------------------------
-- 6. OUTCOME EVIDENCE
-- ---------------------------------------------------------------------------

CREATE TABLE overview.outcome_evidence (
    outcome_evidence_uuid uuid PRIMARY KEY,
    review_item_uuid uuid NOT NULL
        REFERENCES overview.review_item(review_item_uuid),
    result_version_uuid uuid
        REFERENCES evidence.result_version(version_uuid),
    synthesis_version_uuid uuid
        REFERENCES synthesis.synthesis_version(version_uuid),
    certainty_assessment_version_uuid uuid
        REFERENCES appraisal.certainty_assessment_version(version_uuid),
    outcome_entity_uuid uuid
        REFERENCES evidence.outcome(entity_uuid),
    comparison_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    timepoint_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    analysis_role text NOT NULL CHECK (
        analysis_role IN (
            'primary_estimate','supporting_estimate',
            'narrative_only','excluded_overlap','excluded_scope'
        )
    ),
    primary_study_set_status text NOT NULL CHECK (
        primary_study_set_status IN (
            'complete','partial','unknown','not_applicable'
        )
    ),
    extraction_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IS NULL
        OR verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    CHECK (
        result_version_uuid IS NOT NULL
        OR synthesis_version_uuid IS NOT NULL
    ),
    CHECK (
        overview.verification_semantics_valid(
            verification_status,
            verified_by,
            verifier_actor_type,
            verified_at
        )
    )
);

CREATE INDEX ix_overview_outcome_evidence_review
    ON overview.outcome_evidence(review_item_uuid,status);

CREATE INDEX ix_overview_outcome_evidence_result
    ON overview.outcome_evidence(result_version_uuid);

CREATE INDEX ix_overview_outcome_evidence_synthesis
    ON overview.outcome_evidence(synthesis_version_uuid);

CREATE OR REPLACE FUNCTION overview.assert_outcome_evidence_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    review_study_version uuid;
    review_study_entity uuid;
    result_study_entity uuid;
    result_outcome uuid;
    synthesis_outcome uuid;
    certainty_outcome uuid;
BEGIN
    SELECT ri.review_study_version_uuid,sv.entity_uuid
      INTO review_study_version,review_study_entity
      FROM overview.review_item ri
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
     WHERE ri.review_item_uuid=NEW.review_item_uuid;

    IF NEW.result_version_uuid IS NOT NULL THEN
        SELECT r.study_entity_uuid,rv.outcome_entity_uuid
          INTO result_study_entity,result_outcome
          FROM evidence.result_version rv
          JOIN evidence.result r
            ON r.entity_uuid=rv.entity_uuid
         WHERE rv.version_uuid=NEW.result_version_uuid;

        IF result_study_entity IS DISTINCT FROM review_study_entity THEN
            RAISE EXCEPTION
                'OutcomeEvidence Result must belong to the Review Study';
        END IF;
    END IF;

    IF NEW.synthesis_version_uuid IS NOT NULL THEN
        SELECT sv.outcome_entity_uuid
          INTO synthesis_outcome
          FROM synthesis.synthesis_version sv
         WHERE sv.version_uuid=NEW.synthesis_version_uuid;

        IF NOT EXISTS (
            SELECT 1
              FROM provenance.dependency_edge de
             WHERE de.status='active'
               AND de.target_version_uuid=NEW.synthesis_version_uuid
               AND (
                    de.source_version_uuid=review_study_version
                    OR de.source_version_uuid=NEW.result_version_uuid
               )
        )
        AND NOT EXISTS (
            SELECT 1
              FROM synthesis.synthesis_version sv
             WHERE sv.version_uuid=NEW.synthesis_version_uuid
               AND sv.synthesis_origin IN (
                    'adopted_external','updated_external'
               )
               AND (
                    sv.result_summary->>'source_review_study_version_uuid'
                )=review_study_version::text
        )
        THEN
            RAISE EXCEPTION
                'OutcomeEvidence Synthesis lacks traceable linkage to the Review Study';
        END IF;
    END IF;

    IF NEW.outcome_entity_uuid IS NOT NULL
       AND result_outcome IS NOT NULL
       AND NEW.outcome_entity_uuid IS DISTINCT FROM result_outcome
    THEN
        RAISE EXCEPTION
            'OutcomeEvidence outcome does not match Result outcome';
    END IF;

    IF NEW.outcome_entity_uuid IS NOT NULL
       AND synthesis_outcome IS NOT NULL
       AND NEW.outcome_entity_uuid IS DISTINCT FROM synthesis_outcome
    THEN
        RAISE EXCEPTION
            'OutcomeEvidence outcome does not match Synthesis outcome';
    END IF;

    IF NEW.certainty_assessment_version_uuid IS NOT NULL THEN
        SELECT cav.outcome_entity_uuid
          INTO certainty_outcome
          FROM appraisal.certainty_assessment_version cav
         WHERE cav.version_uuid=NEW.certainty_assessment_version_uuid;

        IF NEW.outcome_entity_uuid IS NOT NULL
           AND certainty_outcome IS NOT NULL
           AND NEW.outcome_entity_uuid IS DISTINCT FROM certainty_outcome
        THEN
            RAISE EXCEPTION
                'OutcomeEvidence certainty outcome mismatch';
        END IF;
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_outcome_evidence_consistency
BEFORE INSERT OR UPDATE OF
    review_item_uuid,result_version_uuid,synthesis_version_uuid,
    certainty_assessment_version_uuid,outcome_entity_uuid,
    verification_status,verified_by,verifier_actor_type,verified_at
ON overview.outcome_evidence
FOR EACH ROW EXECUTE FUNCTION overview.assert_outcome_evidence_consistency();

-- ---------------------------------------------------------------------------
-- 7. CONCORDANCE ASSESSMENT
-- ---------------------------------------------------------------------------

CREATE TABLE overview.concordance_assessment (
    concordance_uuid uuid PRIMARY KEY,
    cluster_uuid uuid NOT NULL
        REFERENCES overview.review_cluster(cluster_uuid),
    outcome_entity_uuid uuid
        REFERENCES evidence.outcome(entity_uuid),
    comparison_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    timepoint_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    concordance_state text NOT NULL CHECK (
        concordance_state IN (
            'concordant',
            'directionally_discordant',
            'magnitude_discordant',
            'certainty_discordant',
            'not_comparable'
        )
    ),
    dimensions_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text NOT NULL CHECK (
        length(btrim(rationale))>0
    ),
    assessed_by text NOT NULL CHECK (
        length(btrim(assessed_by))>0
    ),
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IS NULL
        OR verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    assessed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    CHECK (
        overview.verification_semantics_valid(
            verification_status,
            verified_by,
            verifier_actor_type,
            verified_at
        )
    )
);

CREATE INDEX ix_overview_concordance_cluster
    ON overview.concordance_assessment(cluster_uuid,status);

CREATE OR REPLACE FUNCTION overview.assert_concordance_consistency()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
DECLARE
    member_count integer;
BEGIN
    SELECT count(*)
      INTO member_count
      FROM overview.cluster_membership cm
      JOIN overview.review_item ri
        ON ri.review_item_uuid=cm.review_item_uuid
     WHERE cm.cluster_uuid=NEW.cluster_uuid
       AND cm.status='active'
       AND ri.status='active'
       AND cm.analysis_disposition<>'contextual_only';

    IF member_count<2 THEN
        RAISE EXCEPTION
            'ConcordanceAssessment requires at least two active analytic ReviewItems';
    END IF;

    IF NEW.concordance_state='not_comparable'
       AND length(btrim(COALESCE(NEW.rationale,'')))=0
    THEN
        RAISE EXCEPTION
            'not_comparable concordance requires rationale';
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_concordance_consistency
BEFORE INSERT OR UPDATE OF
    cluster_uuid,concordance_state,rationale,
    verification_status,verified_by,verifier_actor_type,verified_at
ON overview.concordance_assessment
FOR EACH ROW EXECUTE FUNCTION overview.assert_concordance_consistency();

-- ---------------------------------------------------------------------------
-- APPEND-PRESERVING JUDGEMENT GUARDS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION overview.guard_judgement_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP='DELETE' THEN
        RAISE EXCEPTION
            'Overview judgement rows are append-preserving; supersede instead of delete';
    END IF;

    IF OLD.status='active' AND NEW.status='superseded' THEN
        RETURN NEW;
    END IF;

    IF OLD IS DISTINCT FROM NEW THEN
        RAISE EXCEPTION
            'Overview judgement rows are append-preserving; create a new row and supersede the prior judgement';
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_overview_overlap_resolution_append
BEFORE UPDATE OR DELETE ON overview.overlap_resolution
FOR EACH ROW EXECUTE FUNCTION overview.guard_judgement_mutation();

CREATE TRIGGER tr_overview_concordance_append
BEFORE UPDATE OR DELETE ON overview.concordance_assessment
FOR EACH ROW EXECUTE FUNCTION overview.guard_judgement_mutation();

-- ---------------------------------------------------------------------------
-- OVERLAP METRICS — DERIVED, NEVER PERSISTED
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION overview.overlap_metrics(
    p_investigation_version_uuid uuid,
    p_cluster_uuid uuid DEFAULT NULL
)
RETURNS TABLE (
    cluster_uuid uuid,
    review_count integer,
    study_occurrence_count integer,
    unique_primary_study_count integer,
    redundant_occurrence_count integer,
    membership_completeness text,
    cca numeric,
    cca_calculable boolean
)
LANGUAGE sql
STABLE
AS $metrics$
WITH clusters AS (
    SELECT rc.cluster_uuid
      FROM overview.review_cluster rc
     WHERE rc.investigation_version_uuid=p_investigation_version_uuid
       AND rc.status='active'
       AND (p_cluster_uuid IS NULL OR rc.cluster_uuid=p_cluster_uuid)
),
analytic_reviews AS (
    SELECT
        c.cluster_uuid,
        ri.review_item_uuid,
        ri.membership_completeness
      FROM clusters c
      JOIN overview.cluster_membership cm
        ON cm.cluster_uuid=c.cluster_uuid
       AND cm.status='active'
       AND cm.analysis_disposition<>'contextual_only'
      JOIN overview.review_item ri
        ON ri.review_item_uuid=cm.review_item_uuid
       AND ri.status='active'
),
agg AS (
    SELECT
        ar.cluster_uuid,
        count(DISTINCT ar.review_item_uuid)::integer AS c,
        count(psm.membership_uuid) FILTER (
            WHERE psm.status='active'
        )::integer AS n,
        count(DISTINCT psm.primary_study_entity_uuid) FILTER (
            WHERE psm.status='active'
        )::integer AS r,
        CASE
            WHEN bool_or(ar.membership_completeness='unknown') THEN 'unknown'
            WHEN bool_or(ar.membership_completeness='partial') THEN 'partial'
            ELSE 'complete'
        END AS completeness
      FROM analytic_reviews ar
      LEFT JOIN overview.primary_study_membership psm
        ON psm.review_item_uuid=ar.review_item_uuid
       AND psm.status='active'
     GROUP BY ar.cluster_uuid
)
SELECT
    a.cluster_uuid,
    a.c AS review_count,
    COALESCE(a.n,0) AS study_occurrence_count,
    COALESCE(a.r,0) AS unique_primary_study_count,
    GREATEST(COALESCE(a.n,0)-COALESCE(a.r,0),0)::integer
        AS redundant_occurrence_count,
    a.completeness AS membership_completeness,
    CASE
        WHEN a.completeness='complete'
         AND a.c>=2
         AND a.r>0
         AND (a.r*a.c-a.r)>0
        THEN (a.n-a.r)::numeric/(a.r*a.c-a.r)::numeric
        ELSE NULL
    END AS cca,
    (
        a.completeness='complete'
        AND a.c>=2
        AND a.r>0
        AND (a.r*a.c-a.r)>0
    ) AS cca_calculable
  FROM agg a
 ORDER BY a.cluster_uuid;
$metrics$;

CREATE OR REPLACE FUNCTION overview.pairwise_overlap(
    p_cluster_uuid uuid
)
RETURNS TABLE (
    review_item_a uuid,
    review_item_b uuid,
    studies_a integer,
    studies_b integer,
    shared_studies integer,
    union_studies integer,
    jaccard numeric,
    proportion_a_shared numeric,
    proportion_b_shared numeric,
    calculable boolean,
    completeness text
)
LANGUAGE sql
STABLE
AS $pairwise$
WITH analytic AS (
    SELECT
        ri.review_item_uuid,
        ri.membership_completeness
      FROM overview.cluster_membership cm
      JOIN overview.review_item ri
        ON ri.review_item_uuid=cm.review_item_uuid
     WHERE cm.cluster_uuid=p_cluster_uuid
       AND cm.status='active'
       AND ri.status='active'
       AND cm.analysis_disposition<>'contextual_only'
),
pairs AS (
    SELECT
        a.review_item_uuid AS a,
        b.review_item_uuid AS b,
        CASE
            WHEN a.membership_completeness='unknown'
              OR b.membership_completeness='unknown'
            THEN 'unknown'
            WHEN a.membership_completeness='partial'
              OR b.membership_completeness='partial'
            THEN 'partial'
            ELSE 'complete'
        END AS completeness
      FROM analytic a
      JOIN analytic b
        ON a.review_item_uuid<b.review_item_uuid
),
counts AS (
    SELECT
        p.*,
        (
            SELECT count(*)::integer
              FROM overview.primary_study_membership m
             WHERE m.review_item_uuid=p.a
               AND m.status='active'
        ) AS ca,
        (
            SELECT count(*)::integer
              FROM overview.primary_study_membership m
             WHERE m.review_item_uuid=p.b
               AND m.status='active'
        ) AS cb,
        (
            SELECT count(*)::integer
              FROM overview.primary_study_membership ma
              JOIN overview.primary_study_membership mb
                ON mb.primary_study_entity_uuid=ma.primary_study_entity_uuid
               AND mb.review_item_uuid=p.b
               AND mb.status='active'
             WHERE ma.review_item_uuid=p.a
               AND ma.status='active'
        ) AS shared
      FROM pairs p
)
SELECT
    c.a,
    c.b,
    c.ca,
    c.cb,
    c.shared,
    (c.ca+c.cb-c.shared)::integer AS union_studies,
    CASE
        WHEN c.completeness='complete'
         AND (c.ca+c.cb-c.shared)>0
        THEN c.shared::numeric/(c.ca+c.cb-c.shared)::numeric
        ELSE NULL
    END AS jaccard,
    CASE
        WHEN c.completeness='complete' AND c.ca>0
        THEN c.shared::numeric/c.ca::numeric
        ELSE NULL
    END AS proportion_a_shared,
    CASE
        WHEN c.completeness='complete' AND c.cb>0
        THEN c.shared::numeric/c.cb::numeric
        ELSE NULL
    END AS proportion_b_shared,
    (
        c.completeness='complete'
        AND c.ca>0
        AND c.cb>0
    ) AS calculable,
    c.completeness
  FROM counts c
 ORDER BY c.a,c.b;
$pairwise$;

-- ---------------------------------------------------------------------------
-- REFERENCES
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.overview_reference_reports(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    report_id text,
    report_entity_uuid uuid,
    report_version_uuid uuid,
    review_study_id text,
    review_study_version_uuid uuid,
    relation_type text,
    title text,
    publication_date date,
    publication_status text
)
LANGUAGE sql
STABLE
AS $refs$
WITH inv AS (
    SELECT il.investigation_version_uuid
      FROM product.investigation_link il
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='primary'
     LIMIT 1
),
review_units AS (
    SELECT
        ri.review_study_version_uuid,
        sv.entity_uuid AS review_study_entity_uuid,
        se.oes_id AS review_study_id
      FROM inv
      JOIN overview.review_item ri
        ON ri.investigation_version_uuid=inv.investigation_version_uuid
       AND ri.status='active'
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
      JOIN core.entity se
        ON se.entity_uuid=sv.entity_uuid
),
report_versions AS (
    SELECT DISTINCT ON (ru.review_study_version_uuid,re.entity_uuid)
        ru.review_study_id,
        ru.review_study_version_uuid,
        srl.relation_type,
        re.oes_id AS report_id,
        rv.entity_uuid AS report_entity_uuid,
        rv.version_uuid AS report_version_uuid,
        rv.title,
        rv.publication_date,
        rv.publication_status,
        ev.version_no
      FROM review_units ru
      JOIN evidence.study_report_link srl
        ON srl.study_entity_uuid=ru.review_study_entity_uuid
       AND srl.status='active'
      JOIN core.entity re
        ON re.entity_uuid=srl.report_entity_uuid
      JOIN evidence.report_version rv
        ON rv.entity_uuid=re.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=rv.version_uuid
     WHERE ev.version_status='current'
     ORDER BY
        ru.review_study_version_uuid,
        re.entity_uuid,
        ev.version_no DESC
)
SELECT
    report_id,
    report_entity_uuid,
    report_version_uuid,
    review_study_id,
    review_study_version_uuid,
    relation_type,
    title,
    publication_date,
    publication_status
  FROM report_versions
 ORDER BY publication_date NULLS LAST,report_id;
$refs$;

-- ---------------------------------------------------------------------------
-- PUBLICATION GATE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.overview_of_reviews_publication_issues(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    issue_code text,
    severity text,
    message text
)
LANGUAGE plpgsql
STABLE
AS $gate$
DECLARE
    pv product.product_version%ROWTYPE;
    primary_count integer := 0;
    inv_uuid uuid;
    inv_depth text;
    inv_cutoff date;
    inv_version_status text;
    protocol_uuid uuid;
    protocol_created timestamptz;
    first_search timestamptz;
    search_policy jsonb := '{}'::jsonb;
    min_biblio integer := 0;
    actual_biblio integer := 0;
    analytic_review_count integer := 0;
    needs_reanalysis boolean := false;
BEGIN
    SELECT *
      INTO pv
      FROM product.product_version
     WHERE version_uuid=p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_PRODUCT_VERSION','error','ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type<>'overview_of_reviews' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format(
                'Expected product_type=overview_of_reviews, found %s',
                pv.product_type
            );
        RETURN;
    END IF;

    SELECT count(*)
      INTO primary_count
      FROM product.investigation_link
     WHERE product_version_uuid=p_product_version_uuid
       AND role='primary';

    IF primary_count=0 THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_INVESTIGATION','error',
            'Formal Overview requires one primary Investigation';
        RETURN;
    ELSIF primary_count>1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_INVESTIGATIONS','error',
            'Overview has more than one primary Investigation';
        RETURN;
    END IF;

    SELECT
        il.investigation_version_uuid,
        iv.depth_level,
        iv.evidence_cutoff_date,
        ev.version_status,
        iv.protocol_artifact_uuid
      INTO
        inv_uuid,
        inv_depth,
        inv_cutoff,
        inv_version_status,
        protocol_uuid
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='primary';

    IF inv_depth<>'N4' THEN
        RETURN QUERY SELECT
            'PRIMARY_INVESTIGATION_NOT_N4','error',
            format(
                'Formal Overview requires N4 primary Investigation; found %s',
                inv_depth
            );
    END IF;

    IF inv_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
        RETURN QUERY SELECT
            'CUTOFF_DATE_MISMATCH','error',
            'Product and primary Investigation cutoff dates differ';
    END IF;

    IF inv_version_status<>'current' THEN
        RETURN QUERY SELECT
            'PRIMARY_INVESTIGATION_NOT_CURRENT','error',
            'Primary Overview InvestigationVersion must be current';
    END IF;

    IF protocol_uuid IS NULL
       OR NOT EXISTS (
            SELECT 1
              FROM artifact.artifact a
             WHERE a.artifact_uuid=protocol_uuid
               AND a.status='active'
               AND length(btrim(COALESCE(a.content_hash,'')))>0
       )
    THEN
        RETURN QUERY SELECT
            'MISSING_PROTOCOL','error',
            'Formal Overview requires an active hashed protocol artifact';
    ELSE
        SELECT created_at
          INTO protocol_created
          FROM artifact.artifact
         WHERE artifact_uuid=protocol_uuid;
    END IF;

    SELECT min(s.executed_at)
      INTO first_search
      FROM investigation.search s
     WHERE s.investigation_version_uuid=inv_uuid
       AND s.status='completed';

    IF first_search IS NOT NULL
       AND protocol_created IS NOT NULL
       AND protocol_created>first_search
    THEN
        RETURN QUERY SELECT
            'PROTOCOL_NOT_PROSPECTIVE','error',
            'Protocol artifact was created after the first completed Search';
    END IF;

    -- Mandatory protocol/method policies.
    IF NOT EXISTS (
        SELECT 1 FROM investigation.method_decision md
         WHERE md.investigation_version_uuid=inv_uuid
           AND md.record_status='active'
           AND md.decision_code='overview_systematic_review_definition'
           AND md.planned_flag=true
           AND md.resolution_status IN ('accepted','mitigated','resolved')
    ) THEN
        RETURN QUERY SELECT
            'MISSING_REVIEW_DEFINITION_POLICY','error',
            'Prospective systematic-review definition policy is required';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM investigation.method_decision md
         WHERE md.investigation_version_uuid=inv_uuid
           AND md.record_status='active'
           AND md.decision_code='overview_search_coverage_policy'
           AND md.planned_flag=true
           AND md.resolution_status IN ('accepted','mitigated','resolved')
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_COVERAGE_POLICY','error',
            'Prospective search coverage policy is required';
    ELSE
        SELECT COALESCE(md.impact_payload,'{}'::jsonb)
          INTO search_policy
          FROM investigation.method_decision md
         WHERE md.investigation_version_uuid=inv_uuid
           AND md.record_status='active'
           AND md.decision_code='overview_search_coverage_policy'
           AND md.planned_flag=true
           AND md.resolution_status IN ('accepted','mitigated','resolved')
         ORDER BY md.decided_at DESC
         LIMIT 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM investigation.method_decision md
         WHERE md.investigation_version_uuid=inv_uuid
           AND md.record_status='active'
           AND md.decision_code='overview_overlap_policy'
           AND md.planned_flag=true
           AND md.resolution_status IN ('accepted','mitigated','resolved')
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OVERLAP_POLICY','error',
            'Prospective overlap policy is required';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM investigation.method_decision md
         WHERE md.investigation_version_uuid=inv_uuid
           AND md.record_status='active'
           AND md.decision_code='overview_currentness_policy'
           AND md.planned_flag=true
           AND md.resolution_status IN ('accepted','mitigated','resolved')
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CURRENTNESS_POLICY','error',
            'Prospective currentness policy is required';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM investigation.search s
         WHERE s.investigation_version_uuid=inv_uuid
           AND s.status='completed'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_RECORD','error',
            'Formal Overview requires completed Search records in the primary Investigation';
    END IF;

    min_biblio := COALESCE(
        NULLIF(search_policy->>'minimum_bibliographic_sources','')::integer,
        0
    );

    SELECT count(DISTINCT s.source_name)
      INTO actual_biblio
      FROM investigation.search s
     WHERE s.investigation_version_uuid=inv_uuid
       AND s.status='completed'
       AND COALESCE(s.filters_payload->>'source_class','')='bibliographic_database';

    IF actual_biblio<min_biblio THEN
        RETURN QUERY SELECT
            'INSUFFICIENT_DECLARED_COVERAGE','error',
            format(
                'Completed bibliographic sources %s are below declared minimum %s',
                actual_biblio,min_biblio
            );
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements_text(
               COALESCE(
                   search_policy->'required_source_names',
                   '[]'::jsonb
               )
          ) required(source_name)
         WHERE NOT EXISTS (
            SELECT 1
              FROM investigation.search s
             WHERE s.investigation_version_uuid=inv_uuid
               AND s.status='completed'
               AND s.source_name=required.source_name
         )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_REQUIRED_SEARCH_SOURCE','error',
            'At least one protocol-required Search source is missing';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements_text(
               COALESCE(
                   search_policy->'required_source_classes',
                   '[]'::jsonb
               )
          ) required(source_class)
         WHERE NOT EXISTS (
            SELECT 1
              FROM investigation.search s
             WHERE s.investigation_version_uuid=inv_uuid
               AND s.status='completed'
               AND s.filters_payload->>'source_class'=required.source_class
         )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_REQUIRED_SEARCH_SOURCE_CLASS','error',
            'At least one protocol-required Search source class is missing';
    END IF;

    IF lower(COALESCE(
        search_policy->>'search_export_required','false'
    ))='true'
       AND EXISTS (
            SELECT 1
              FROM investigation.search s
             WHERE s.investigation_version_uuid=inv_uuid
               AND s.status='completed'
               AND (
                    s.export_artifact_uuid IS NULL
                    OR NOT EXISTS (
                        SELECT 1 FROM artifact.artifact a
                         WHERE a.artifact_uuid=s.export_artifact_uuid
                           AND a.status='active'
                           AND length(btrim(COALESCE(a.content_hash,'')))>0
                    )
               )
       )
    THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_EXPORT','error',
            'A completed Search lacks the required active hashed export artifact';
    END IF;

    IF NOT (
        investigation.has_n4_control_with_assignment(
            inv_uuid,'search_strategy_peer_review',
            'search','search_peer_reviewer'
        )
        OR investigation.has_n4_control_with_assignment(
            inv_uuid,'search_strategy_verification',
            'search','search_peer_reviewer'
        )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_PEER_REVIEW','error',
            'Qualified independent search peer review/verification is required';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,'screening_secondary_verification',
        'screening','secondary_reviewer'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SCREENING_CONTROL','error',
            'Qualified independent secondary screening verification is required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.search_hit sh
          JOIN investigation.search s
            ON s.search_uuid=sh.search_uuid
         WHERE s.investigation_version_uuid=inv_uuid
           AND sh.report_entity_uuid IS NOT NULL
           AND NOT EXISTS (
                SELECT 1
                  FROM investigation.screening_decision sd
                 WHERE sd.investigation_version_uuid=inv_uuid
                   AND sd.target_entity_uuid=sh.report_entity_uuid
                   AND sd.stage='full_text'
           )
    ) THEN
        RETURN QUERY SELECT
            'INCOMPLETE_SCREENING','error',
            'At least one resolved SearchHit lacks a full-text ScreeningDecision';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.screening_decision sd
         WHERE sd.investigation_version_uuid=inv_uuid
           AND sd.stage='full_text'
           AND sd.decision='exclude'
           AND length(btrim(COALESCE(sd.exclusion_reason,'')))=0
    ) THEN
        RETURN QUERY SELECT
            'MISSING_FULLTEXT_EXCLUSION_REASON','error',
            'A full-text exclusion lacks an explicit reason';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.screening_decision sd
         WHERE sd.investigation_version_uuid=inv_uuid
         GROUP BY sd.target_entity_uuid,sd.stage
        HAVING bool_or(sd.decision='include')
           AND bool_or(sd.decision='exclude')
           AND NOT bool_or(sd.adjudication_flag)
    ) THEN
        RETURN QUERY SELECT
            'UNRESOLVED_SCREENING_DISAGREEMENT','error',
            'Conflicting screening decisions lack adjudication';
    END IF;

    SELECT count(*)
      INTO analytic_review_count
      FROM overview.review_item ri
     WHERE ri.investigation_version_uuid=inv_uuid
       AND ri.status='active'
       AND ri.item_role IN ('primary','supporting');

    IF analytic_review_count<2 THEN
        RETURN QUERY SELECT
            'TOO_FEW_INCLUDED_REVIEWS','error',
            'Formal Overview requires at least two analytic systematic reviews';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND sv.study_type<>'systematic_review'
    ) THEN
        RETURN QUERY SELECT
            'NON_SYSTEMATIC_REVIEW_ITEM','error',
            'An active ReviewItem is not a systematic review';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
         GROUP BY sv.entity_uuid
        HAVING count(*)>1
    ) THEN
        RETURN QUERY SELECT
            'MULTIPLE_ACTIVE_VERSIONS_SAME_REVIEW','error',
            'More than one active StudyVersion of the same Review is included';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.last_search_date IS NULL
    ) THEN
        RETURN QUERY SELECT
            'MISSING_LAST_SEARCH_DATE','error',
            'An active ReviewItem lacks last_search_date';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.currentness_status IS NULL
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CURRENTNESS_ASSESSMENT','error',
            'An active ReviewItem lacks currentness assessment';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND NOT EXISTS (
                SELECT 1
                  FROM investigation.screening_decision sd
                  JOIN evidence.study_version rsv
                    ON rsv.version_uuid=ri.review_study_version_uuid
                 WHERE sd.investigation_version_uuid=inv_uuid
                   AND sd.stage='full_text'
                   AND sd.decision='include'
                   AND (
                        sd.target_entity_uuid=rsv.entity_uuid
                        OR EXISTS (
                            SELECT 1
                              FROM evidence.study_report_link srl
                             WHERE srl.study_entity_uuid=rsv.entity_uuid
                               AND srl.report_entity_uuid=sd.target_entity_uuid
                               AND srl.status='active'
                        )
                   )
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_INCLUDED_REVIEW_SCREENING_DECISION','error',
            'An active ReviewItem lacks an explicit full-text inclusion decision';
    END IF;

    -- Review-level ROBIS.
    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.item_role IN ('primary','supporting')
           AND NOT EXISTS (
                SELECT 1
                  FROM appraisal.risk_assessment_version rav
                 WHERE rav.investigation_version_uuid=inv_uuid
                   AND rav.target_entity_uuid=sv.entity_uuid
                   AND lower(rav.framework)='robis'
                   AND rav.status='active'
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_REVIEW_ROBIS','error',
            'Every analytic ReviewItem requires an active ROBIS assessment';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,'risk_of_bias_verification',
        'appraisal','appraisal_reviewer'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_APPRAISAL_CONTROL','error',
            'Qualified independent ROBIS verification is required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN appraisal.risk_assessment_version rav
            ON rav.investigation_version_uuid=inv_uuid
           AND rav.target_entity_uuid=sv.entity_uuid
           AND lower(rav.framework)='robis'
           AND rav.status='active'
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.item_role IN ('primary','supporting')
           AND COALESCE(rav.verification_status,'unverified')
               NOT IN ('human_verified','human_consensus')
    ) THEN
        RETURN QUERY SELECT
            'UNVERIFIED_REVIEW_APPRAISAL','error',
            'Formal Overview requires human-verified ROBIS assessments';
    END IF;

    -- Primary-study membership and overlap control.
    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.item_role IN ('primary','supporting')
           AND NOT EXISTS (
                SELECT 1
                  FROM overview.primary_study_membership psm
                 WHERE psm.review_item_uuid=ri.review_item_uuid
                   AND psm.status='active'
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_STUDY_MEMBERSHIP','error',
            'An analytic ReviewItem has no primary-study membership rows';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.item_role IN ('primary','supporting')
           AND ri.membership_completeness<>'complete'
    ) THEN
        RETURN QUERY SELECT
            'INCOMPLETE_MEMBERSHIP','error',
            'Formal Overview requires complete membership for analytic ReviewItems';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.primary_study_membership psm
          JOIN overview.review_item ri
            ON ri.review_item_uuid=psm.review_item_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND psm.status='active'
           AND psm.identity_confidence='low'
    ) THEN
        RETURN QUERY SELECT
            'LOW_CONFIDENCE_STUDY_IDENTITY','error',
            'Low-confidence primary-study identity blocks formal Overview publication';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.primary_study_membership psm
          JOIN overview.review_item ri
            ON ri.review_item_uuid=psm.review_item_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND psm.status='active'
           AND psm.verification_status
               NOT IN ('human_verified','human_consensus')
    ) THEN
        RETURN QUERY SELECT
            'UNVERIFIED_MEMBERSHIP','error',
            'Formal Overview requires human-verified primary-study membership';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM investigation.quality_control_record q
         WHERE q.investigation_version_uuid=inv_uuid
           AND q.record_status='active'
           AND q.stage='extraction'
           AND q.control_type='other'
           AND q.scope_payload->>'control_code'='overview_overlap_verification'
           AND q.actor_type IN ('human_reviewer','human_expert')
           AND q.independent_flag=true
           AND q.decision='passed'
           AND investigation.has_valid_reviewer_assignment(
                inv_uuid,q.actor,'extraction','data_verifier',
                q.performed_at,true
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OVERLAP_CONTROL','error',
            'Qualified independent overlap/membership verification is required';
    END IF;

    -- Cluster coverage and overlap resolution.
    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.item_role IN ('primary','supporting')
           AND NOT EXISTS (
                SELECT 1
                  FROM overview.cluster_membership cm
                  JOIN overview.review_cluster rc
                    ON rc.cluster_uuid=cm.cluster_uuid
                 WHERE cm.review_item_uuid=ri.review_item_uuid
                   AND cm.status='active'
                   AND rc.status='active'
                   AND rc.investigation_version_uuid=inv_uuid
           )
    ) THEN
        RETURN QUERY SELECT
            'UNCLUSTERED_ANALYTIC_REVIEW','error',
            'Every analytic ReviewItem must belong to an active ReviewCluster';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_cluster rc
         WHERE rc.investigation_version_uuid=inv_uuid
           AND rc.status='active'
           AND (
                SELECT count(*)
                  FROM overview.cluster_membership cm
                 WHERE cm.cluster_uuid=rc.cluster_uuid
                   AND cm.status='active'
                   AND cm.analysis_disposition<>'contextual_only'
           )>1
           AND NOT EXISTS (
                SELECT 1
                  FROM overview.overlap_resolution ores
                 WHERE ores.cluster_uuid=rc.cluster_uuid
                   AND ores.status='active'
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OVERLAP_RESOLUTION','error',
            'A multi-review cluster lacks active overlap resolution';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.overlap_resolution ores
          JOIN overview.review_cluster rc
            ON rc.cluster_uuid=ores.cluster_uuid
         WHERE rc.investigation_version_uuid=inv_uuid
           AND rc.status='active'
           AND ores.status='active'
           AND ores.strategy='include_all_deduplicate_outcomes'
    ) THEN
        RETURN QUERY SELECT
            'OUTCOME_DEDUP_STRATEGY_UNSUPPORTED_V01','error',
            'Outcome-level de-duplication is not formally supported in Overview v0.1';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.overlap_resolution ores
          JOIN overview.review_cluster rc
            ON rc.cluster_uuid=ores.cluster_uuid
         WHERE rc.investigation_version_uuid=inv_uuid
           AND rc.status='active'
           AND ores.status='active'
           AND ores.strategy='prioritize_review'
           AND (
                SELECT count(*)
                  FROM overview.cluster_membership cm
                 WHERE cm.cluster_uuid=rc.cluster_uuid
                   AND cm.status='active'
                   AND cm.analysis_disposition='prioritized'
           )<>1
    ) THEN
        RETURN QUERY SELECT
            'MISSING_PRIORITIZED_REVIEW','error',
            'prioritize_review requires exactly one active prioritized ReviewItem';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.overlap_resolution ores
          JOIN overview.review_cluster rc
            ON rc.cluster_uuid=ores.cluster_uuid
         WHERE rc.investigation_version_uuid=inv_uuid
           AND rc.status='active'
           AND ores.status='active'
           AND ores.strategy='prioritize_review'
           AND jsonb_array_length(
                COALESCE(
                    ores.decision_payload->'criteria',
                    '[]'::jsonb
                )
           )=0
    ) THEN
        RETURN QUERY SELECT
            'PRIORITIZATION_WITHOUT_CRITERIA','error',
            'Review prioritization requires explicit pre-specified criteria';
    END IF;

    -- Outcome evidence.
    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND (
                ri.item_role='primary'
                OR EXISTS (
                    SELECT 1
                      FROM overview.cluster_membership cm
                     WHERE cm.review_item_uuid=ri.review_item_uuid
                       AND cm.status='active'
                       AND cm.analysis_disposition='prioritized'
                )
           )
           AND NOT EXISTS (
                SELECT 1
                  FROM overview.outcome_evidence oe
                 WHERE oe.review_item_uuid=ri.review_item_uuid
                   AND oe.status='active'
                   AND oe.analysis_role IN (
                        'primary_estimate','narrative_only'
                   )
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OUTCOME_EVIDENCE','error',
            'A primary/prioritized ReviewItem lacks active OutcomeEvidence';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.outcome_evidence oe
          JOIN overview.review_item ri
            ON ri.review_item_uuid=oe.review_item_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND oe.status='active'
           AND oe.analysis_role NOT IN ('excluded_overlap','excluded_scope')
           AND oe.verification_status
               NOT IN ('human_verified','human_consensus')
    ) THEN
        RETURN QUERY SELECT
            'UNVERIFIED_OUTCOME_EVIDENCE','error',
            'Formal Overview requires human-verified OutcomeEvidence';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.outcome_evidence oe
          JOIN overview.review_item ri
            ON ri.review_item_uuid=oe.review_item_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND oe.status='active'
           AND oe.primary_study_set_status IN ('partial','unknown')
           AND oe.analysis_role NOT IN ('excluded_overlap','excluded_scope')
    ) THEN
        RETURN QUERY SELECT
            'INCOMPLETE_OUTCOME_EXTRACTION','error',
            'Material OutcomeEvidence has incomplete/unknown primary-study set status';
    END IF;

    -- Concordance.
    IF EXISTS (
        SELECT 1
          FROM overview.review_cluster rc
         WHERE rc.investigation_version_uuid=inv_uuid
           AND rc.status='active'
           AND (
                SELECT count(*)
                  FROM overview.cluster_membership cm
                 WHERE cm.cluster_uuid=rc.cluster_uuid
                   AND cm.status='active'
                   AND cm.analysis_disposition<>'contextual_only'
           )>1
           AND NOT EXISTS (
                SELECT 1
                  FROM overview.concordance_assessment ca
                 WHERE ca.cluster_uuid=rc.cluster_uuid
                   AND ca.status='active'
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CONCORDANCE_ASSESSMENT','error',
            'A multi-review cluster lacks concordance/not-comparable assessment';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.concordance_assessment ca
          JOIN overview.review_cluster rc
            ON rc.cluster_uuid=ca.cluster_uuid
         WHERE rc.investigation_version_uuid=inv_uuid
           AND ca.status='active'
           AND ca.verification_status
               NOT IN ('human_verified','human_consensus')
    ) THEN
        RETURN QUERY SELECT
            'UNVERIFIED_CONCORDANCE','error',
            'Formal Overview requires human-verified concordance assessments';
    END IF;

    -- No global certainty for the Overview itself.
    IF EXISTS (
        SELECT 1
          FROM product.certainty_link cl
         WHERE cl.product_version_uuid=p_product_version_uuid
           AND lower(cl.role) IN (
                'global','overview_global','global_overview'
           )
    ) THEN
        RETURN QUERY SELECT
            'GLOBAL_OVERVIEW_CERTAINTY_NOT_ALLOWED','error',
            'Overview v0.1 does not permit a global certainty rating';
    END IF;

    -- Reanalysis / supplemental primary-study protection.
    SELECT EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
          JOIN synthesis.synthesis_version sv
            ON sv.version_uuid=sl.synthesis_version_uuid
         WHERE sl.product_version_uuid=p_product_version_uuid
           AND sv.synthesis_origin NOT IN (
                'adopted_external','updated_external'
           )
    ) INTO needs_reanalysis;

    IF needs_reanalysis THEN
        IF NOT EXISTS (
            SELECT 1 FROM investigation.method_decision md
             WHERE md.investigation_version_uuid=inv_uuid
               AND md.record_status='active'
               AND md.decision_code='overview_reanalysis_policy'
               AND md.planned_flag=true
               AND md.resolution_status IN (
                    'accepted','mitigated','resolved'
               )
        ) THEN
            RETURN QUERY SELECT
                'REANALYSIS_WITHOUT_POLICY','error',
                'New Overview quantitative synthesis requires a prospective reanalysis policy';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid=sl.synthesis_version_uuid
             WHERE sl.product_version_uuid=p_product_version_uuid
               AND sv.synthesis_origin NOT IN (
                    'adopted_external','updated_external'
               )
               AND sv.code_artifact_uuid IS NULL
        ) THEN
            RETURN QUERY SELECT
                'REANALYSIS_WITHOUT_CODE','error',
                'New Overview quantitative synthesis lacks code artifact';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid=sl.synthesis_version_uuid
             WHERE sl.product_version_uuid=p_product_version_uuid
               AND sv.synthesis_origin NOT IN (
                    'adopted_external','updated_external'
               )
               AND sv.analysis_dataset_artifact_uuid IS NULL
        ) THEN
            RETURN QUERY SELECT
                'REANALYSIS_WITHOUT_DATASET','error',
                'New Overview quantitative synthesis lacks analysis dataset artifact';
        END IF;

        IF NOT investigation.has_n4_control_with_assignment(
            inv_uuid,'synthesis_statistical_review',
            'synthesis','statistical_reviewer'
        ) THEN
            RETURN QUERY SELECT
                'REANALYSIS_WITHOUT_STATISTICAL_REVIEW','error',
                'New Overview quantitative synthesis requires qualified independent statistical review';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.contribution sc
                ON sc.synthesis_version_uuid=sl.synthesis_version_uuid
              JOIN evidence.result_version rv
                ON rv.version_uuid=sc.result_version_uuid
              JOIN evidence.result r
                ON r.entity_uuid=rv.entity_uuid
             WHERE sl.product_version_uuid=p_product_version_uuid
               AND NOT EXISTS (
                    SELECT 1
                      FROM overview.review_item ri
                      JOIN evidence.study_version rsv
                        ON rsv.version_uuid=ri.review_study_version_uuid
                     WHERE ri.investigation_version_uuid=inv_uuid
                       AND ri.status='active'
                       AND rsv.entity_uuid=r.study_entity_uuid
               )
        ) THEN
            RETURN QUERY SELECT
                'SUPPLEMENTAL_PRIMARY_STUDY_NOT_SUPPORTED_V01','error',
                'Overview v0.1 cannot synthesize primary-study Results outside ReviewItems';
        END IF;
    END IF;

    -- Assurance.
    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='ai_methodological_verification'
           AND ar.decision='passed'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_AI_METHODOLOGICAL_VERIFICATION','error',
            'Formal Overview requires passed AI methodological verification';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='owner_governance_approval'
           AND ar.decision='approved'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OWNER_APPROVAL','error',
            'Formal Overview requires owner governance approval';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.assurance_record ar
         WHERE ar.product_version_uuid=p_product_version_uuid
           AND ar.status='active'
           AND ar.assurance_type='expert_independent_review'
           AND ar.decision='approved'
           AND investigation.has_valid_reviewer_assignment(
                inv_uuid,ar.actor,'cross_cutting',
                'expert_independent_reviewer',
                ar.performed_at,true
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_EXPERT_INDEPENDENT_REVIEW','error',
            'Formal Overview requires approved qualified independent expert review';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM investigation.reviewer_assignment ra
         WHERE ra.investigation_version_uuid=inv_uuid
           AND ra.record_status='active'
           AND ra.role='expert_independent_reviewer'
           AND ra.actor_type='human_expert'
           AND ra.independent_flag=true
    ) THEN
        RETURN QUERY SELECT
            'MISSING_EXPERT_REVIEWER_ASSIGNMENT','error',
            'Formal A3 Overview requires independent expert reviewer assignment';
    END IF;

    IF product.assurance_level(p_product_version_uuid)<>'A3' THEN
        RETURN QUERY SELECT
            'ASSURANCE_BELOW_REQUIRED_LEVEL','error',
            format(
                'Formal Overview requires A3; current assurance is %s',
                product.assurance_level(p_product_version_uuid)
            );
    END IF;

    -- Publication/currency/currentness.
    IF NOT EXISTS (
        SELECT 1
          FROM core.entity_version ev
         WHERE ev.version_uuid=p_product_version_uuid
           AND ev.version_status='current'
    ) THEN
        RETURN QUERY SELECT
            'NOT_CURRENT_ENTITY_VERSION','error',
            'ProductVersion must be current for formal publication';
    END IF;

    IF pv.status<>'published' THEN
        RETURN QUERY SELECT
            'PRODUCT_NOT_PUBLISHED','error',
            'Formal Overview ProductVersion status must be published';
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE','error',
            'Formal Overview requires publication_date';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.currency_state cs
         WHERE cs.product_version_uuid=p_product_version_uuid
           AND cs.record_status='active'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CURRENCY_STATE','error',
            'Formal Overview requires active currency state';
    END IF;

    IF btrim(COALESCE(pv.limitations_summary,''))='' THEN
        RETURN QUERY SELECT
            'MISSING_LIMITATIONS','error',
            'Formal Overview limitations must be explicit';
    END IF;

    IF EXISTS (
        WITH RECURSIVE deps(version_uuid,path) AS (
            SELECT
                p_product_version_uuid,
                ARRAY[p_product_version_uuid]::uuid[]
            UNION ALL
            SELECT
                de.source_version_uuid,
                d.path||de.source_version_uuid
              FROM deps d
              JOIN provenance.dependency_edge de
                ON de.target_version_uuid=d.version_uuid
               AND de.status='active'
             WHERE cardinality(d.path)<64
               AND NOT de.source_version_uuid=ANY(d.path)
        )
        SELECT 1
          FROM deps d
          JOIN provenance.record pr
            ON pr.target_version_uuid=d.version_uuid
         WHERE pr.status='invalidated'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_DEPENDENCY','error',
            'An invalidated upstream provenance record blocks formal Overview publication';
    END IF;

    -- Warnings.
    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.currentness_status='outdated'
    ) THEN
        RETURN QUERY SELECT
            'OUTDATED_INCLUDED_REVIEW','warning',
            'At least one included Review is classified as outdated';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND ri.currentness_status='possibly_outdated'
    ) THEN
        RETURN QUERY SELECT
            'POSSIBLY_OUTDATED_INCLUDED_REVIEW','warning',
            'At least one included Review may be outdated';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.review_item ri
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN appraisal.risk_assessment_version rav
            ON rav.investigation_version_uuid=inv_uuid
           AND rav.target_entity_uuid=sv.entity_uuid
           AND lower(rav.framework)='robis'
           AND rav.status='active'
         WHERE ri.investigation_version_uuid=inv_uuid
           AND ri.status='active'
           AND lower(COALESCE(rav.overall_judgement,'')) IN (
                'high','high risk','high_risk'
           )
    ) THEN
        RETURN QUERY SELECT
            'HIGH_RISK_REVIEW_INCLUDED','warning',
            'At least one included Review has high ROBIS risk';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.outcome_evidence oe
          JOIN overview.review_item ri
            ON ri.review_item_uuid=oe.review_item_uuid
         WHERE ri.investigation_version_uuid=inv_uuid
           AND oe.status='active'
           AND oe.certainty_assessment_version_uuid IS NULL
           AND oe.analysis_role NOT IN ('excluded_overlap','excluded_scope')
    ) THEN
        RETURN QUERY SELECT
            'CERTAINTY_NOT_REPORTED_BY_REVIEW','warning',
            'At least one material OutcomeEvidence item has no linked certainty assessment';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM overview.overlap_resolution ores
          JOIN overview.review_cluster rc
            ON rc.cluster_uuid=ores.cluster_uuid
         WHERE rc.investigation_version_uuid=inv_uuid
           AND ores.status='active'
           AND ores.actor_type='ai_system'
    )
    OR EXISTS (
        SELECT 1
          FROM overview.concordance_assessment ca
          JOIN overview.review_cluster rc
            ON rc.cluster_uuid=ca.cluster_uuid
         WHERE rc.investigation_version_uuid=inv_uuid
           AND ca.status='active'
           AND ca.actor_type='ai_system'
    ) THEN
        RETURN QUERY SELECT
            'AI_ASSISTANCE_USED','warning',
            'AI assistance was used in at least one Overview methodological judgement';
    END IF;

    IF NOT needs_reanalysis THEN
        RETURN QUERY SELECT
            'NO_QUANTITATIVE_REANALYSIS','warning',
            'No new quantitative reanalysis is linked; review-level estimates remain separate/adopted';
    END IF;

    RETURN;
END;
$gate$;

CREATE OR REPLACE FUNCTION product.overview_of_reviews_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $publishable$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.overview_of_reviews_publication_issues(
              p_product_version_uuid
          )
         WHERE severity='error'
    );
$publishable$;

-- ---------------------------------------------------------------------------
-- OVERVIEW OF REVIEWS VIEW
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.overview_of_reviews_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $view$
WITH
pv AS (
    SELECT
        pv.*,
        pe.oes_id AS product_id,
        ev.version_no,
        ev.version_status,
        cs.currency_status,
        cs.assessed_at AS currency_assessed_at,
        cs.assessed_by AS currency_assessed_by,
        cs.rationale AS currency_rationale
      FROM product.product_version pv
      JOIN core.entity pe
        ON pe.entity_uuid=pv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=pv.version_uuid
      LEFT JOIN LATERAL (
          SELECT *
            FROM product.currency_state cs
           WHERE cs.product_version_uuid=pv.version_uuid
             AND cs.record_status='active'
           ORDER BY cs.assessed_at DESC
           LIMIT 1
      ) cs ON true
     WHERE pv.version_uuid=p_product_version_uuid
),
inv AS (
    SELECT
        iv.*,
        ie.oes_id AS investigation_id,
        ev.version_status
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid=il.investigation_version_uuid
      JOIN core.entity ie
        ON ie.entity_uuid=iv.entity_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid=iv.version_uuid
     WHERE il.product_version_uuid=p_product_version_uuid
       AND il.role='primary'
     LIMIT 1
),
q AS (
    SELECT
        qv.*,
        qe.oes_id AS question_id
      FROM inv
      JOIN investigation.investigation_question iq
        ON iq.investigation_version_uuid=inv.version_uuid
       AND iq.role='primary'
      JOIN investigation.question_version qv
        ON qv.version_uuid=iq.question_version_uuid
      JOIN core.entity qe
        ON qe.entity_uuid=qv.entity_uuid
     LIMIT 1
),
issues AS (
    SELECT *
      FROM product.overview_of_reviews_publication_issues(
          p_product_version_uuid
      )
)
SELECT jsonb_build_object(
    'schema_version','oes.overview_of_reviews_view/0.1',

    'identity',COALESCE((
        SELECT jsonb_build_object(
            'product_id',product_id,
            'product_entity_uuid',entity_uuid,
            'product_version_uuid',version_uuid,
            'version_no',version_no,
            'version_status',version_status,
            'product_type',product_type,
            'title',title,
            'intended_audience',intended_audience,
            'editorial_status',status,
            'publication_date',publication_date,
            'evidence_cutoff_date',evidence_cutoff_date,
            'currency_status',currency_status
        ) FROM pv
    ),'{}'::jsonb),

    'question',COALESCE((
        SELECT jsonb_build_object(
            'question_id',question_id,
            'question_entity_uuid',entity_uuid,
            'question_version_uuid',version_uuid,
            'original_text',original_text,
            'normalized_text',normalized_text,
            'question_type',question_type,
            'structure_type',structure_type,
            'context',context_payload,
            'time_horizon',time_horizon_payload
        ) FROM q
    ),'{}'::jsonb),

    'investigation',COALESCE((
        SELECT jsonb_build_object(
            'investigation_id',investigation_id,
            'investigation_entity_uuid',entity_uuid,
            'investigation_version_uuid',version_uuid,
            'investigation_type',investigation_type,
            'depth_level',depth_level,
            'maintenance_level',maintenance_level,
            'objective',objective,
            'protocol_artifact_uuid',protocol_artifact_uuid,
            'start_date',start_date,
            'evidence_cutoff_date',evidence_cutoff_date,
            'status',status,
            'version_status',version_status
        ) FROM inv
    ),'{}'::jsonb),

    'protocol',COALESCE((
        SELECT jsonb_build_object(
            'artifact_uuid',a.artifact_uuid,
            'artifact_type',a.artifact_type,
            'storage_key',a.storage_key,
            'content_hash',a.content_hash,
            'hash_algorithm',a.hash_algorithm,
            'created_at',a.created_at,
            'status',a.status
        )
          FROM inv
          JOIN artifact.artifact a
            ON a.artifact_uuid=inv.protocol_artifact_uuid
    ),'{}'::jsonb),

    'method',jsonb_build_object(
        'policies',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'decision_code',md.decision_code,
                    'stage',md.stage,
                    'planned',md.planned_flag,
                    'rationale',md.rationale,
                    'impact',md.impact_payload,
                    'resolution_status',md.resolution_status,
                    'decided_at',md.decided_at
                )
                ORDER BY md.decided_at,md.decision_code
            )
              FROM inv
              JOIN investigation.method_decision md
                ON md.investigation_version_uuid=inv.version_uuid
               AND md.record_status='active'
               AND md.decision_code LIKE 'overview_%'
        ),'[]'::jsonb),
        'reviewer_assignments',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'stage',ra.stage,
                    'actor',ra.actor,
                    'actor_type',ra.actor_type,
                    'role',ra.role,
                    'qualification',ra.qualification_payload,
                    'independent',ra.independent_flag,
                    'scope',ra.scope_payload
                )
                ORDER BY ra.stage,ra.role,ra.actor
            )
              FROM inv
              JOIN investigation.reviewer_assignment ra
                ON ra.investigation_version_uuid=inv.version_uuid
               AND ra.record_status='active'
        ),'[]'::jsonb),
        'quality_controls',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'stage',qc.stage,
                    'control_type',qc.control_type,
                    'control_code',qc.scope_payload->>'control_code',
                    'actor',qc.actor,
                    'actor_type',qc.actor_type,
                    'independent',qc.independent_flag,
                    'decision',qc.decision,
                    'performed_at',qc.performed_at
                )
                ORDER BY qc.stage,qc.control_type,qc.performed_at
            )
              FROM inv
              JOIN investigation.quality_control_record qc
                ON qc.investigation_version_uuid=inv.version_uuid
               AND qc.record_status='active'
        ),'[]'::jsonb)
    ),

    'searches',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'search_uuid',s.search_uuid,
                'oes_search_id',s.oes_search_id,
                'source_name',s.source_name,
                'platform',s.platform,
                'source_class',s.filters_payload->>'source_class',
                'executed_at',s.executed_at,
                'result_count',s.result_count,
                'strategy_version',s.strategy_version,
                'export_artifact_uuid',s.export_artifact_uuid,
                'status',s.status
            )
            ORDER BY s.executed_at,s.oes_search_id
        )
          FROM inv
          JOIN investigation.search s
            ON s.investigation_version_uuid=inv.version_uuid
    ),'[]'::jsonb),

    'selection_flow',jsonb_build_object(
        'search_hits',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.search s
                ON s.investigation_version_uuid=inv.version_uuid
              JOIN investigation.search_hit sh
                ON sh.search_uuid=s.search_uuid
        ),0),
        'screening_decisions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
        ),0),
        'full_text_decisions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
             WHERE sd.stage='full_text'
        ),0),
        'full_text_exclusions',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN investigation.screening_decision sd
                ON sd.investigation_version_uuid=inv.version_uuid
             WHERE sd.stage='full_text'
               AND sd.decision='exclude'
        ),0),
        'included_review_items',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN overview.review_item ri
                ON ri.investigation_version_uuid=inv.version_uuid
             WHERE ri.status='active'
        ),0)
    ),

    'review_items',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'review_item_uuid',ri.review_item_uuid,
                'review_study_id',se.oes_id,
                'review_study_entity_uuid',sv.entity_uuid,
                'review_study_version_uuid',ri.review_study_version_uuid,
                'study_type',sv.study_type,
                'title',sv.title_or_label,
                'item_role',ri.item_role,
                'eligibility_basis',ri.eligibility_basis_payload,
                'last_search_date',ri.last_search_date,
                'membership_completeness',ri.membership_completeness,
                'currentness_status',ri.currentness_status,
                'currentness_rationale',ri.currentness_rationale,
                'robis',COALESCE((
                    SELECT jsonb_build_object(
                        'risk_assessment_version_uuid',rav.version_uuid,
                        'overall_judgement',rav.overall_judgement,
                        'assessor',rav.assessor,
                        'assessment_date',rav.assessment_date,
                        'verification_status',rav.verification_status
                    )
                      FROM appraisal.risk_assessment_version rav
                     WHERE rav.investigation_version_uuid=ri.investigation_version_uuid
                       AND rav.target_entity_uuid=sv.entity_uuid
                       AND lower(rav.framework)='robis'
                       AND rav.status='active'
                     ORDER BY rav.assessment_date DESC
                     LIMIT 1
                ),'{}'::jsonb),
                'reports',COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'report_id',re.oes_id,
                            'report_version_uuid',rv.version_uuid,
                            'relation_type',srl.relation_type,
                            'title',rv.title,
                            'publication_date',rv.publication_date
                        )
                        ORDER BY rv.publication_date,re.oes_id
                    )
                      FROM evidence.study_report_link srl
                      JOIN core.entity re
                        ON re.entity_uuid=srl.report_entity_uuid
                      JOIN evidence.report_version rv
                        ON rv.entity_uuid=re.entity_uuid
                      JOIN core.entity_version rev
                        ON rev.version_uuid=rv.version_uuid
                       AND rev.version_status='current'
                     WHERE srl.study_entity_uuid=sv.entity_uuid
                       AND srl.status='active'
                ),'[]'::jsonb)
            )
            ORDER BY ri.included_at,ri.review_item_uuid
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
           AND ri.status='active'
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN core.entity se
            ON se.entity_uuid=sv.entity_uuid
    ),'[]'::jsonb),

    'primary_study_membership',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'membership_uuid',psm.membership_uuid,
                'review_item_uuid',psm.review_item_uuid,
                'primary_study_id',pse.oes_id,
                'primary_study_entity_uuid',psm.primary_study_entity_uuid,
                'source_report_version_uuid',psm.source_report_version_uuid,
                'source_location',psm.source_location,
                'identity_confidence',psm.identity_confidence,
                'verification_status',psm.verification_status,
                'context',psm.context_payload
            )
            ORDER BY psm.review_item_uuid,pse.oes_id
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
          JOIN overview.primary_study_membership psm
            ON psm.review_item_uuid=ri.review_item_uuid
           AND psm.status='active'
          JOIN core.entity pse
            ON pse.entity_uuid=psm.primary_study_entity_uuid
         WHERE ri.status='active'
    ),'[]'::jsonb),

    'overlap',jsonb_build_object(
        'clusters',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'cluster_uuid',rc.cluster_uuid,
                    'cluster_code',rc.cluster_code,
                    'label',rc.label,
                    'scope',rc.scope_payload,
                    'metrics',to_jsonb(om),
                    'resolution',COALESCE((
                        SELECT jsonb_build_object(
                            'strategy',ores.strategy,
                            'decision',ores.decision_payload,
                            'rationale',ores.rationale,
                            'decided_by',ores.decided_by,
                            'actor_type',ores.actor_type,
                            'verification_status',ores.verification_status,
                            'decided_at',ores.decided_at
                        )
                          FROM overview.overlap_resolution ores
                         WHERE ores.cluster_uuid=rc.cluster_uuid
                           AND ores.status='active'
                         LIMIT 1
                    ),'{}'::jsonb),
                    'members',COALESCE((
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'review_item_uuid',cm.review_item_uuid,
                                'analysis_disposition',cm.analysis_disposition,
                                'rationale',cm.rationale,
                                'sequence_no',cm.sequence_no
                            )
                            ORDER BY cm.sequence_no,cm.review_item_uuid
                        )
                          FROM overview.cluster_membership cm
                         WHERE cm.cluster_uuid=rc.cluster_uuid
                           AND cm.status='active'
                    ),'[]'::jsonb),
                    'pairwise',COALESCE((
                        SELECT jsonb_agg(to_jsonb(po) ORDER BY po.review_item_a,po.review_item_b)
                          FROM overview.pairwise_overlap(rc.cluster_uuid) po
                    ),'[]'::jsonb)
                )
                ORDER BY rc.cluster_code
            )
              FROM inv
              JOIN overview.review_cluster rc
                ON rc.investigation_version_uuid=inv.version_uuid
               AND rc.status='active'
              LEFT JOIN LATERAL overview.overlap_metrics(
                    inv.version_uuid,rc.cluster_uuid
              ) om ON true
        ),'[]'::jsonb)
    ),

    'outcome_evidence',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'outcome_evidence_uuid',oe.outcome_evidence_uuid,
                'review_item_uuid',oe.review_item_uuid,
                'result_version_uuid',oe.result_version_uuid,
                'synthesis_version_uuid',oe.synthesis_version_uuid,
                'certainty_assessment_version_uuid',
                    oe.certainty_assessment_version_uuid,
                'outcome_id',oeo.oes_id,
                'outcome_entity_uuid',oe.outcome_entity_uuid,
                'comparison',oe.comparison_payload,
                'timepoint',oe.timepoint_payload,
                'analysis_role',oe.analysis_role,
                'primary_study_set_status',oe.primary_study_set_status,
                'extraction',oe.extraction_payload,
                'verification_status',oe.verification_status,
                'result',CASE
                    WHEN rv.version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'measure',rv.measure,
                        'reported_value',rv.reported_value,
                        'derived_value',rv.derived_value,
                        'ci_lower',rv.ci_lower,
                        'ci_upper',rv.ci_upper,
                        'unit',rv.unit,
                        'estimand',rv.estimand,
                        'method',rv.method_payload
                    )
                END,
                'synthesis',CASE
                    WHEN sy.version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'synthesis_type',sy.synthesis_type,
                        'synthesis_origin',sy.synthesis_origin,
                        'method',sy.method,
                        'model',sy.model,
                        'result_summary',sy.result_summary
                    )
                END,
                'certainty',CASE
                    WHEN cav.version_uuid IS NULL THEN NULL
                    ELSE jsonb_build_object(
                        'framework',cav.framework,
                        'initial_level',cav.initial_level,
                        'final_level',cav.final_level,
                        'evidence_state',cav.evidence_state,
                        'assessment_date',cav.assessment_date
                    )
                END
            )
            ORDER BY oe.review_item_uuid,oe.outcome_evidence_uuid
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
          JOIN overview.outcome_evidence oe
            ON oe.review_item_uuid=ri.review_item_uuid
           AND oe.status='active'
          LEFT JOIN evidence.result_version rv
            ON rv.version_uuid=oe.result_version_uuid
          LEFT JOIN synthesis.synthesis_version sy
            ON sy.version_uuid=oe.synthesis_version_uuid
          LEFT JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid=oe.certainty_assessment_version_uuid
          LEFT JOIN core.entity oeo
            ON oeo.entity_uuid=oe.outcome_entity_uuid
         WHERE ri.status='active'
    ),'[]'::jsonb),

    'appraisal',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'review_item_uuid',ri.review_item_uuid,
                'risk_assessment_version_uuid',rav.version_uuid,
                'framework',rav.framework,
                'overall_judgement',rav.overall_judgement,
                'assessor',rav.assessor,
                'assessment_date',rav.assessment_date,
                'verification_status',rav.verification_status,
                'domains',COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'domain_code',rad.domain_code,
                            'judgement',rad.judgement,
                            'rationale',rad.rationale,
                            'sequence_no',rad.sequence_no
                        )
                        ORDER BY rad.sequence_no,rad.domain_code
                    )
                      FROM appraisal.risk_assessment_domain rad
                     WHERE rad.risk_assessment_version_uuid=rav.version_uuid
                ),'[]'::jsonb)
            )
            ORDER BY ri.review_item_uuid
        )
          FROM inv
          JOIN overview.review_item ri
            ON ri.investigation_version_uuid=inv.version_uuid
           AND ri.status='active'
          JOIN evidence.study_version sv
            ON sv.version_uuid=ri.review_study_version_uuid
          JOIN appraisal.risk_assessment_version rav
            ON rav.investigation_version_uuid=inv.version_uuid
           AND rav.target_entity_uuid=sv.entity_uuid
           AND lower(rav.framework)='robis'
           AND rav.status='active'
    ),'[]'::jsonb),

    'concordance',COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'concordance_uuid',ca.concordance_uuid,
                'cluster_uuid',ca.cluster_uuid,
                'outcome_id',oe.oes_id,
                'outcome_entity_uuid',ca.outcome_entity_uuid,
                'comparison',ca.comparison_payload,
                'timepoint',ca.timepoint_payload,
                'state',ca.concordance_state,
                'dimensions',ca.dimensions_payload,
                'rationale',ca.rationale,
                'assessed_by',ca.assessed_by,
                'actor_type',ca.actor_type,
                'verification_status',ca.verification_status,
                'assessed_at',ca.assessed_at
            )
            ORDER BY ca.cluster_uuid,ca.assessed_at
        )
          FROM inv
          JOIN overview.review_cluster rc
            ON rc.investigation_version_uuid=inv.version_uuid
           AND rc.status='active'
          JOIN overview.concordance_assessment ca
            ON ca.cluster_uuid=rc.cluster_uuid
           AND ca.status='active'
          LEFT JOIN core.entity oe
            ON oe.entity_uuid=ca.outcome_entity_uuid
    ),'[]'::jsonb),

    'conclusion',COALESCE((
        SELECT jsonb_build_object(
            'text',conclusion_text,
            'applicability_summary',applicability_summary
        ) FROM pv
    ),'{}'::jsonb),

    'limitations',COALESCE((
        SELECT jsonb_build_object(
            'summary',limitations_summary
        ) FROM pv
    ),'{}'::jsonb),

    'references',COALESCE((
        SELECT jsonb_agg(to_jsonb(r) ORDER BY r.publication_date NULLS LAST,r.report_id)
          FROM product.overview_reference_reports(
              p_product_version_uuid
          ) r
    ),'[]'::jsonb),

    'update_state',COALESCE((
        SELECT jsonb_build_object(
            'currency_status',currency_status,
            'assessed_at',currency_assessed_at,
            'assessed_by',currency_assessed_by,
            'rationale',currency_rationale
        ) FROM pv
    ),'{}'::jsonb),

    'audit',jsonb_build_object(
        'synthetic_fixture',COALESCE((
            SELECT intended_audience='architecture_validation'
              FROM pv
        ),false),
        'assurance_level',
            product.assurance_level(p_product_version_uuid),
        'required_assurance_level','A3',
        'publishable',
            product.overview_of_reviews_is_publishable(
                p_product_version_uuid
            ),
        'review_count',COALESCE((
            SELECT count(*)
              FROM inv
              JOIN overview.review_item ri
                ON ri.investigation_version_uuid=inv.version_uuid
             WHERE ri.status='active'
               AND ri.item_role IN ('primary','supporting')
        ),0),
        'membership_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_PRIMARY_STUDY_MEMBERSHIP',
                'INCOMPLETE_MEMBERSHIP',
                'LOW_CONFIDENCE_STUDY_IDENTITY',
                'UNVERIFIED_MEMBERSHIP'
             )
               AND severity='error'
        ),
        'overlap_assessed',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'UNCLUSTERED_ANALYTIC_REVIEW',
                'MISSING_OVERLAP_RESOLUTION',
                'MISSING_OVERLAP_CONTROL',
                'OUTCOME_DEDUP_STRATEGY_UNSUPPORTED_V01'
             )
               AND severity='error'
        ),
        'appraisal_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_REVIEW_ROBIS',
                'MISSING_APPRAISAL_CONTROL',
                'UNVERIFIED_REVIEW_APPRAISAL'
             )
               AND severity='error'
        ),
        'extraction_complete',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_OUTCOME_EVIDENCE',
                'INCOMPLETE_OUTCOME_EXTRACTION',
                'UNVERIFIED_OUTCOME_EVIDENCE'
             )
               AND severity='error'
        ),
        'human_controls_satisfied',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'MISSING_SEARCH_PEER_REVIEW',
                'MISSING_SCREENING_CONTROL',
                'MISSING_APPRAISAL_CONTROL',
                'MISSING_OVERLAP_CONTROL',
                'UNVERIFIED_MEMBERSHIP',
                'UNVERIFIED_OUTCOME_EVIDENCE',
                'UNVERIFIED_CONCORDANCE'
             )
               AND severity='error'
        ),
        'reanalysis_present',EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid=sl.synthesis_version_uuid
             WHERE sl.product_version_uuid=p_product_version_uuid
               AND sv.synthesis_origin NOT IN (
                    'adopted_external','updated_external'
               )
        ),
        'statistical_controls_satisfied',NOT EXISTS (
            SELECT 1
              FROM issues
             WHERE issue_code IN (
                'REANALYSIS_WITHOUT_POLICY',
                'REANALYSIS_WITHOUT_CODE',
                'REANALYSIS_WITHOUT_DATASET',
                'REANALYSIS_WITHOUT_STATISTICAL_REVIEW'
             )
               AND severity='error'
        ),
        'invalidated_dependencies',EXISTS (
            SELECT 1 FROM issues
             WHERE issue_code IN (
                'INVALIDATED_DEPENDENCY',
                'INVALIDATED_REVIEW_VERSION',
                'INVALIDATED_OUTCOME_DEPENDENCY'
             )
               AND severity='error'
        ),
        'publication_issues',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code',issue_code,
                    'severity',severity,
                    'message',message
                )
                ORDER BY severity,issue_code
            )
              FROM issues
        ),'[]'::jsonb),
        'assurance_records',COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'assurance_type',ar.assurance_type,
                    'actor',ar.actor,
                    'actor_type',ar.actor_type,
                    'independent',ar.independent_flag,
                    'decision',ar.decision,
                    'performed_at',ar.performed_at
                )
                ORDER BY ar.performed_at
            )
              FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
               AND ar.status='active'
        ),'[]'::jsonb)
    )
);
$view$;

COMMIT;
