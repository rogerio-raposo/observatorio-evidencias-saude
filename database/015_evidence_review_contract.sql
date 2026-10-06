-- OES-DBM-2026-0015
-- Fase 3 — Evidence Review N4 contract
-- Depends on: baseline + migrations 002–014
-- Status: N4 product contract candidate
-- Date: 2026-10-06

BEGIN;

-- ---------------------------------------------------------------------------
-- REVIEWER ASSIGNMENT
-- ---------------------------------------------------------------------------

CREATE TABLE investigation.reviewer_assignment (
    reviewer_assignment_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    stage text NOT NULL CHECK (
        stage IN (
            'search','screening','extraction','appraisal',
            'synthesis','certainty','reporting','cross_cutting'
        )
    ),
    actor text NOT NULL CHECK (length(btrim(actor)) > 0),
    actor_type text NOT NULL CHECK (
        actor_type IN ('human_reviewer','human_expert')
    ),
    role text NOT NULL CHECK (
        role IN (
            'review_lead',
            'search_peer_reviewer',
            'primary_reviewer',
            'secondary_reviewer',
            'data_extractor',
            'data_verifier',
            'appraisal_reviewer',
            'certainty_reviewer',
            'statistical_reviewer',
            'adjudicator',
            'reporting_reviewer',
            'expert_independent_reviewer',
            'other'
        )
    ),
    qualification_payload jsonb NOT NULL CHECK (
        qualification_payload <> '{}'::jsonb
        AND lower(COALESCE(qualification_payload->>'qualified','false')) = 'true'
        AND length(btrim(COALESCE(qualification_payload->>'basis',''))) > 0
    ),
    independent_flag boolean NOT NULL DEFAULT false,
    scope_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    conflict_payload jsonb NOT NULL DEFAULT '{"declared":false}'::jsonb,
    assigned_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at timestamptz,
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_reviewer_assignment_uuid uuid,
    UNIQUE (reviewer_assignment_uuid, investigation_version_uuid),
    FOREIGN KEY (
        supersedes_reviewer_assignment_uuid,
        investigation_version_uuid
    ) REFERENCES investigation.reviewer_assignment(
        reviewer_assignment_uuid,
        investigation_version_uuid
    ),
    CHECK (
        ended_at IS NULL OR ended_at >= assigned_at
    ),
    CHECK (
        supersedes_reviewer_assignment_uuid IS NULL
        OR supersedes_reviewer_assignment_uuid <> reviewer_assignment_uuid
    ),
    CHECK (
        NOT (
            lower(COALESCE(conflict_payload->>'declared','false')) = 'true'
            AND lower(COALESCE(conflict_payload->>'managed','false')) <> 'true'
        )
    )
);

CREATE INDEX ix_reviewer_assignment_investigation
    ON investigation.reviewer_assignment(
        investigation_version_uuid, stage, role, actor
    );

CREATE INDEX ix_reviewer_assignment_active
    ON investigation.reviewer_assignment(
        investigation_version_uuid, stage, role
    )
    WHERE record_status='active';

CREATE OR REPLACE FUNCTION investigation.guard_reviewer_assignment_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'ReviewerAssignment records are append-preserving and cannot be deleted';
    END IF;

    IF OLD.record_status = 'active'
       AND NEW.record_status = 'superseded'
       AND NEW.reviewer_assignment_uuid = OLD.reviewer_assignment_uuid
       AND NEW.investigation_version_uuid = OLD.investigation_version_uuid
       AND NEW.stage = OLD.stage
       AND NEW.actor = OLD.actor
       AND NEW.actor_type = OLD.actor_type
       AND NEW.role = OLD.role
       AND NEW.qualification_payload = OLD.qualification_payload
       AND NEW.independent_flag = OLD.independent_flag
       AND NEW.scope_payload = OLD.scope_payload
       AND NEW.conflict_payload = OLD.conflict_payload
       AND NEW.assigned_at = OLD.assigned_at
       AND NEW.ended_at IS NOT DISTINCT FROM OLD.ended_at
       AND NEW.supersedes_reviewer_assignment_uuid
           IS NOT DISTINCT FROM OLD.supersedes_reviewer_assignment_uuid
    THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'ReviewerAssignment material fields are immutable; supersede and append a new assignment';
END;
$guard$;

CREATE TRIGGER tr_reviewer_assignment_append_preserving
BEFORE UPDATE OR DELETE ON investigation.reviewer_assignment
FOR EACH ROW EXECUTE FUNCTION investigation.guard_reviewer_assignment_mutation();

-- ---------------------------------------------------------------------------
-- REVIEWER / CONTROL HELPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION investigation.has_valid_reviewer_assignment(
    p_investigation_version_uuid uuid,
    p_actor text,
    p_stage text,
    p_role text,
    p_at timestamptz DEFAULT NULL,
    p_require_independent boolean DEFAULT true
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $assignment$
    SELECT EXISTS (
        SELECT 1
          FROM investigation.reviewer_assignment ra
         WHERE ra.investigation_version_uuid = p_investigation_version_uuid
           AND ra.record_status = 'active'
           AND ra.actor = p_actor
           AND ra.stage = p_stage
           AND ra.role = p_role
           AND lower(COALESCE(
                ra.qualification_payload->>'qualified','false'
           )) = 'true'
           AND length(btrim(COALESCE(
                ra.qualification_payload->>'basis',''
           ))) > 0
           AND (
                NOT p_require_independent
                OR ra.independent_flag = true
           )
           AND (
                p_at IS NULL
                OR (
                    ra.assigned_at <= p_at
                    AND (ra.ended_at IS NULL OR ra.ended_at >= p_at)
                )
           )
           AND NOT (
                lower(COALESCE(
                    ra.conflict_payload->>'declared','false'
                )) = 'true'
                AND lower(COALESCE(
                    ra.conflict_payload->>'managed','false'
                )) <> 'true'
           )
    );
$assignment$;


CREATE OR REPLACE FUNCTION investigation.has_n4_control_with_assignment(
    p_investigation_version_uuid uuid,
    p_control_type text,
    p_stage text,
    p_role text
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $control$
    SELECT EXISTS (
        SELECT 1
          FROM investigation.quality_control_record q
         WHERE q.investigation_version_uuid = p_investigation_version_uuid
           AND q.record_status = 'active'
           AND q.control_type = p_control_type
           AND q.stage = p_stage
           AND q.actor_type IN ('human_reviewer','human_expert')
           AND q.qualification_payload IS NOT NULL
           AND q.qualification_payload <> '{}'::jsonb
           AND q.independent_flag = true
           AND q.decision = 'passed'
           AND investigation.has_valid_reviewer_assignment(
                p_investigation_version_uuid,
                q.actor,
                p_stage,
                p_role,
                q.performed_at,
                true
           )
    );
$control$;

-- ---------------------------------------------------------------------------
-- N4 WRAPPERS
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_review_assurance_level(
    p_product_version_uuid uuid
)
RETURNS text
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT product.assurance_level(p_product_version_uuid);
$wrapper$;


CREATE OR REPLACE FUNCTION product.evidence_review_reference_reports(
    p_product_version_uuid uuid
)
RETURNS TABLE (
    report_id text,
    report_entity_uuid uuid,
    report_version_uuid uuid,
    title text,
    publication_date date,
    publication_status text,
    source_locations jsonb
)
LANGUAGE sql
STABLE
AS $wrapper$
    SELECT *
      FROM product.product_reference_reports(p_product_version_uuid);
$wrapper$;

-- ---------------------------------------------------------------------------
-- N4 PUBLICATION GATE
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_review_publication_issues(
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
    inv_type text;
    inv_cutoff date;
    inv_status text;
    protocol_uuid uuid;
    protocol_created timestamptz;
    first_search timestamptz;
    biblio_sources integer := 0;
    readiness_state text;
    needs_statistical_review boolean := false;
    needs_rob_me boolean := false;
    reference_count integer := 0;
BEGIN
    SELECT *
      INTO pv
      FROM product.product_version
     WHERE version_uuid = p_product_version_uuid;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'MISSING_PRODUCT_VERSION','error','ProductVersion does not exist';
        RETURN;
    END IF;

    IF pv.product_type <> 'evidence_review' THEN
        RETURN QUERY SELECT
            'WRONG_PRODUCT_TYPE','error',
            format(
                'Expected product_type=evidence_review, found %s',
                pv.product_type
            );
    END IF;

    SELECT count(*)
      INTO primary_count
      FROM product.investigation_link
     WHERE product_version_uuid = p_product_version_uuid
       AND role = 'primary';

    IF primary_count = 0 THEN
        RETURN QUERY SELECT
            'MISSING_PRIMARY_INVESTIGATION','error',
            'Evidence Review requires one primary Investigation';
        RETURN;
    ELSIF primary_count > 1 THEN
        RETURN QUERY SELECT
            'MULTIPLE_PRIMARY_INVESTIGATIONS','error',
            'Evidence Review has more than one primary Investigation';
        RETURN;
    END IF;

    SELECT il.investigation_version_uuid,
           iv.depth_level,
           iv.investigation_type,
           iv.evidence_cutoff_date,
           ev.version_status,
           iv.protocol_artifact_uuid
      INTO inv_uuid,
           inv_depth,
           inv_type,
           inv_cutoff,
           inv_status,
           protocol_uuid
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid = il.investigation_version_uuid
      JOIN core.entity_version ev
        ON ev.version_uuid = iv.version_uuid
     WHERE il.product_version_uuid = p_product_version_uuid
       AND il.role = 'primary';

    IF inv_depth <> 'N4' THEN
        RETURN QUERY SELECT
            'PRIMARY_INVESTIGATION_NOT_N4','error',
            format('Primary Investigation depth is %s, expected N4', inv_depth);
    END IF;

    IF inv_type IS NULL OR length(btrim(inv_type)) = 0 THEN
        RETURN QUERY SELECT
            'MISSING_N4_SUBTYPE','error',
            'N4 Investigation requires an explicit investigation_type/subtype';
    END IF;

    IF inv_cutoff IS DISTINCT FROM pv.evidence_cutoff_date THEN
        RETURN QUERY SELECT
            'CUTOFF_DATE_MISMATCH','error',
            format(
                'Product cutoff %s differs from Investigation cutoff %s',
                pv.evidence_cutoff_date,
                inv_cutoff
            );
    END IF;

    IF inv_status <> 'current' THEN
        RETURN QUERY SELECT
            'PRIMARY_INVESTIGATION_NOT_CURRENT','error',
            format('Primary Investigation version_status is %s', inv_status);
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM investigation.investigation_question iq
         WHERE iq.investigation_version_uuid = inv_uuid
           AND iq.role = 'primary'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_QUESTION','error',
            'Primary N4 Investigation has no primary QuestionVersion link';
    END IF;

    IF protocol_uuid IS NULL
       OR NOT EXISTS (
            SELECT 1
              FROM artifact.artifact a
             WHERE a.artifact_uuid = protocol_uuid
               AND a.status = 'active'
       )
    THEN
        RETURN QUERY SELECT
            'MISSING_PROTOCOL','error',
            'A traceable active prospective protocol artifact is required';
    ELSE
        SELECT a.created_at
          INTO protocol_created
          FROM artifact.artifact a
         WHERE a.artifact_uuid = protocol_uuid;

        SELECT min(s.executed_at)
          INTO first_search
          FROM investigation.search s
         WHERE s.investigation_version_uuid = inv_uuid
           AND s.status = 'completed';

        IF first_search IS NOT NULL
           AND protocol_created > first_search
        THEN
            RETURN QUERY SELECT
                'PROTOCOL_NOT_PROSPECTIVE','error',
                'Protocol artifact was created after the first completed search';
        END IF;
    END IF;

    SELECT md.impact_payload->>'state'
      INTO readiness_state
      FROM investigation.method_decision md
     WHERE md.investigation_version_uuid = inv_uuid
       AND md.record_status = 'active'
       AND md.decision_code = 'N4_INFRASTRUCTURE_READINESS'
     ORDER BY md.decided_at DESC
     LIMIT 1;

    IF readiness_state IS DISTINCT FROM 'ready' THEN
        RETURN QUERY SELECT
            'INFRASTRUCTURE_NOT_READY','error',
            format(
                'N4 infrastructure readiness must be ready for publication; found %s',
                COALESCE(readiness_state,'missing')
            );
    END IF;

    SELECT count(DISTINCT s.source_name)
      INTO biblio_sources
      FROM investigation.search s
     WHERE s.investigation_version_uuid = inv_uuid
       AND s.status = 'completed'
       AND s.filters_payload->>'source_class' = 'bibliographic_database';

    IF biblio_sources < 2 THEN
        RETURN QUERY SELECT
            'INSUFFICIENT_BIBLIOGRAPHIC_COVERAGE','error',
            format(
                'N4 requires at least two completed bibliographic databases; found %s',
                biblio_sources
            );
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.search s
         WHERE s.investigation_version_uuid = inv_uuid
           AND s.status = 'completed'
           AND s.filters_payload->>'source_class' = 'bibliographic_database'
           AND s.export_artifact_uuid IS NULL
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_EXPORT','error',
            'Every completed N4 bibliographic database Search requires a traceable export artifact';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,
        'search_strategy_peer_review',
        'search',
        'search_peer_reviewer'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SEARCH_PEER_REVIEW','error',
            'No passed qualified independent search peer review with a valid reviewer assignment is recorded';
    END IF;

    IF EXISTS (
        WITH targets AS (
            SELECT DISTINCT sh.report_entity_uuid AS target_entity_uuid
              FROM investigation.search_hit sh
              JOIN investigation.search s
                ON s.search_uuid = sh.search_uuid
             WHERE s.investigation_version_uuid = inv_uuid
               AND sh.report_entity_uuid IS NOT NULL
        )
        SELECT 1
          FROM targets t
         WHERE (
            SELECT count(DISTINCT sd.reviewer)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid = inv_uuid
               AND sd.target_entity_uuid = t.target_entity_uuid
               AND lower(sd.stage) IN (
                   'title_abstract','title/abstract','abstract'
               )
               AND sd.adjudication_flag = false
               AND (
                   investigation.has_valid_reviewer_assignment(
                       inv_uuid,sd.reviewer,'screening',
                       'primary_reviewer',sd.decided_at,true
                   )
                   OR
                   investigation.has_valid_reviewer_assignment(
                       inv_uuid,sd.reviewer,'screening',
                       'secondary_reviewer',sd.decided_at,true
                   )
               )
         ) < 2
         OR NOT EXISTS (
            SELECT 1
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid = inv_uuid
               AND sd.target_entity_uuid = t.target_entity_uuid
               AND lower(sd.stage) IN (
                   'title_abstract','title/abstract','abstract'
               )
               AND sd.adjudication_flag = false
               AND investigation.has_valid_reviewer_assignment(
                   inv_uuid,sd.reviewer,'screening',
                   'primary_reviewer',sd.decided_at,true
               )
         )
         OR NOT EXISTS (
            SELECT 1
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid = inv_uuid
               AND sd.target_entity_uuid = t.target_entity_uuid
               AND lower(sd.stage) IN (
                   'title_abstract','title/abstract','abstract'
               )
               AND sd.adjudication_flag = false
               AND investigation.has_valid_reviewer_assignment(
                   inv_uuid,sd.reviewer,'screening',
                   'secondary_reviewer',sd.decided_at,true
               )
         )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_DUPLICATE_TITLE_ABSTRACT_SCREENING','error',
            'At least two qualified independent title/abstract screening decisions are required for every materialized report target';
    END IF;

    IF EXISTS (
        WITH ft_targets AS (
            SELECT DISTINCT sd.target_entity_uuid
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid = inv_uuid
               AND lower(sd.stage) IN (
                   'title_abstract','title/abstract','abstract'
               )
               AND sd.decision = 'include'
        )
        SELECT 1
          FROM ft_targets t
         WHERE (
            SELECT count(DISTINCT sd.reviewer)
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid = inv_uuid
               AND sd.target_entity_uuid = t.target_entity_uuid
               AND lower(sd.stage) IN ('full_text','full text')
               AND sd.adjudication_flag = false
               AND (
                   investigation.has_valid_reviewer_assignment(
                       inv_uuid,sd.reviewer,'screening',
                       'primary_reviewer',sd.decided_at,true
                   )
                   OR
                   investigation.has_valid_reviewer_assignment(
                       inv_uuid,sd.reviewer,'screening',
                       'secondary_reviewer',sd.decided_at,true
                   )
               )
         ) < 2
    ) THEN
        RETURN QUERY SELECT
            'MISSING_DUPLICATE_FULL_TEXT_SCREENING','error',
            'At least two qualified independent full-text screening decisions are required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM (
            SELECT sd.target_entity_uuid, lower(sd.stage) AS stage_key
              FROM investigation.screening_decision sd
             WHERE sd.investigation_version_uuid = inv_uuid
               AND sd.adjudication_flag = false
             GROUP BY sd.target_entity_uuid, lower(sd.stage)
            HAVING count(DISTINCT sd.decision) > 1
          ) d
         WHERE NOT EXISTS (
            SELECT 1
              FROM investigation.screening_decision a
             WHERE a.investigation_version_uuid = inv_uuid
               AND a.target_entity_uuid = d.target_entity_uuid
               AND lower(a.stage) = d.stage_key
               AND a.adjudication_flag = true
         )
    ) THEN
        RETURN QUERY SELECT
            'UNRESOLVED_SCREENING_DISAGREEMENT','error',
            'A screening disagreement lacks a recorded adjudication decision';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.screening_decision sd
         WHERE sd.investigation_version_uuid = inv_uuid
           AND lower(sd.stage) IN ('full_text','full text')
           AND sd.decision = 'exclude'
           AND (sd.exclusion_reason IS NULL OR length(btrim(sd.exclusion_reason))=0)
    ) THEN
        RETURN QUERY SELECT
            'MISSING_FULLTEXT_EXCLUSION_REASON','error',
            'Every full-text exclusion requires an explicit reason';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,
        'screening_pilot',
        'screening',
        'secondary_reviewer'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SCREENING_PILOT','error',
            'No passed qualified independent N4 screening pilot/calibration is recorded';
    END IF;

    IF EXISTS (
        WITH critical_results AS (
            SELECT DISTINCT sc.result_version_uuid
              FROM product.synthesis_link sl
              JOIN synthesis.contribution sc
                ON sc.synthesis_version_uuid = sl.synthesis_version_uuid
             WHERE sl.product_version_uuid = p_product_version_uuid
               AND sl.role IN ('primary','critical')
               AND sc.included_main_analysis = true
        )
        SELECT 1
          FROM critical_results cr
         WHERE (
            SELECT count(DISTINCT pr.actor)
              FROM provenance.record pr
             WHERE pr.target_version_uuid = cr.result_version_uuid
               AND pr.status = 'active'
               AND pr.process_type = 'n4_independent_extraction'
               AND investigation.has_valid_reviewer_assignment(
                   inv_uuid,pr.actor,'extraction',
                   'data_extractor',pr.created_at,true
               )
         ) < 2
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CRITICAL_RESULT_DUPLICATE_EXTRACTION','error',
            'Each critical Result requires two qualified independent extraction records';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,
        'critical_data_verification',
        'extraction',
        'data_verifier'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_QUALIFIED_DATA_VERIFICATION','error',
            'No passed qualified critical-data verification is recorded';
    END IF;

    IF EXISTS (
        WITH contributing_studies AS (
            SELECT DISTINCT r.study_entity_uuid
              FROM product.synthesis_link sl
              JOIN synthesis.contribution sc
                ON sc.synthesis_version_uuid = sl.synthesis_version_uuid
              JOIN evidence.result_version rv
                ON rv.version_uuid = sc.result_version_uuid
              JOIN evidence.result r
                ON r.entity_uuid = rv.entity_uuid
             WHERE sl.product_version_uuid = p_product_version_uuid
               AND sl.role IN ('primary','critical')
        )
        SELECT 1
          FROM contributing_studies cs
         WHERE NOT EXISTS (
            SELECT 1
              FROM appraisal.risk_assessment_version rav
             WHERE rav.investigation_version_uuid = inv_uuid
               AND rav.target_entity_uuid = cs.study_entity_uuid
               AND rav.status = 'active'
         )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_RISK_ASSESSMENT','error',
            'Every contributing Study requires an active N4 RiskAssessment';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM appraisal.risk_assessment_version rav
         WHERE rav.investigation_version_uuid = inv_uuid
           AND rav.status = 'active'
           AND (
                SELECT count(DISTINCT pr.actor)
                  FROM provenance.record pr
                 WHERE pr.target_version_uuid = rav.version_uuid
                   AND pr.status = 'active'
                   AND pr.process_type =
                       'n4_independent_appraisal_judgement'
                   AND investigation.has_valid_reviewer_assignment(
                       inv_uuid,pr.actor,'appraisal',
                       'appraisal_reviewer',pr.created_at,true
                   )
           ) < 2
    ) THEN
        RETURN QUERY SELECT
            'MISSING_DUPLICATE_RISK_OF_BIAS_ASSESSMENT','error',
            'Each material N4 RiskAssessment requires two qualified independent appraisal judgements';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,
        'risk_of_bias_verification',
        'appraisal',
        'appraisal_reviewer'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION','error',
            'No passed qualified N4 risk-of-bias verification is recorded';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
         WHERE sl.product_version_uuid = p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_SYNTHESIS','error',
            'N4 requires at least one linked SynthesisVersion';
    END IF;

    SELECT EXISTS (
        SELECT 1
          FROM product.synthesis_link sl
          JOIN synthesis.synthesis_version sv
            ON sv.version_uuid = sl.synthesis_version_uuid
         WHERE sl.product_version_uuid = p_product_version_uuid
           AND lower(sv.synthesis_type) LIKE '%meta%'
    )
      INTO needs_statistical_review;

    IF needs_statistical_review THEN
        IF EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid = sl.synthesis_version_uuid
             WHERE sl.product_version_uuid = p_product_version_uuid
               AND lower(sv.synthesis_type) LIKE '%meta%'
               AND (
                    sv.code_artifact_uuid IS NULL
                    OR sv.analysis_dataset_artifact_uuid IS NULL
               )
        ) THEN
            RETURN QUERY SELECT
                'MISSING_REPRODUCIBLE_ANALYSIS_ARTIFACT','error',
                'Meta-analytic N4 synthesis requires code and analysis dataset artifacts';
        END IF;

        IF NOT investigation.has_n4_control_with_assignment(
            inv_uuid,
            'synthesis_statistical_review',
            'synthesis',
            'statistical_reviewer'
        ) THEN
            RETURN QUERY SELECT
                'MISSING_STATISTICAL_REVIEW','error',
                'Meta-analytic N4 synthesis requires passed qualified statistical review';
        END IF;

        SELECT EXISTS (
            SELECT 1
              FROM product.synthesis_link sl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid = sl.synthesis_version_uuid
             WHERE sl.product_version_uuid = p_product_version_uuid
               AND lower(sv.synthesis_type) LIKE '%meta%'
               AND NOT EXISTS (
                    SELECT 1
                      FROM appraisal.risk_assessment_version rav
                     WHERE rav.investigation_version_uuid = inv_uuid
                       AND upper(rav.framework) = 'ROB-ME'
                       AND rav.target_entity_uuid = sv.entity_uuid
                       AND rav.status = 'active'
               )
        )
          INTO needs_rob_me;

        IF needs_rob_me THEN
            RETURN QUERY SELECT
                'MISSING_MISSING_EVIDENCE_ASSESSMENT','error',
                'Meta-analytic N4 synthesis requires a synthesis-level ROB-ME assessment in this contract';
        END IF;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.certainty_link cl
         WHERE cl.product_version_uuid = p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CERTAINTY_ASSESSMENT','error',
            'N4 intervention review requires linked CertaintyAssessment';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM product.certainty_link cl
          JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid = cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid = p_product_version_uuid
           AND (
                SELECT count(DISTINCT pr.actor)
                  FROM provenance.record pr
                 WHERE pr.target_version_uuid = cav.version_uuid
                   AND pr.status = 'active'
                   AND pr.process_type =
                       'n4_independent_certainty_judgement'
                   AND investigation.has_valid_reviewer_assignment(
                       inv_uuid,pr.actor,'certainty',
                       'certainty_reviewer',pr.created_at,true
                   )
           ) < 2
    ) THEN
        RETURN QUERY SELECT
            'MISSING_DUPLICATE_CERTAINTY_ASSESSMENT','error',
            'Each material CertaintyAssessment requires two qualified independent certainty judgements';
    END IF;

    IF NOT investigation.has_n4_control_with_assignment(
        inv_uuid,
        'certainty_verification',
        'certainty',
        'certainty_reviewer'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_QUALIFIED_CERTAINTY_VERIFICATION','error',
            'No passed qualified N4 certainty verification is recorded';
    END IF;

    IF inv_type = 'systematic_review_intervention'
       AND NOT EXISTS (
            SELECT 1
              FROM artifact.entity_link ael
             WHERE ael.entity_version_uuid = p_product_version_uuid
               AND ael.role = 'summary_of_findings'
       )
    THEN
        RETURN QUERY SELECT
            'MISSING_SUMMARY_OF_FINDINGS','error',
            'Systematic intervention N4 requires a traceable Summary of Findings artifact';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.method_decision md
         WHERE md.investigation_version_uuid = inv_uuid
           AND md.record_status = 'active'
           AND md.decision_type = 'protocol_deviation'
           AND md.resolution_status = 'open'
    ) THEN
        RETURN QUERY SELECT
            'OPEN_PROTOCOL_DEVIATION','error',
            'An active open protocol deviation blocks N4 publication';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM investigation.quality_control_record q
         WHERE q.investigation_version_uuid = inv_uuid
           AND q.record_status = 'active'
           AND q.decision IN ('revise','failed')
    ) THEN
        RETURN QUERY SELECT
            'ACTIVE_REVISE_OR_FAILED_CONTROL','error',
            'An active revise/failed methodological quality control blocks publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.current_currency_state ccs
         WHERE ccs.product_version_uuid = p_product_version_uuid
    ) THEN
        RETURN QUERY SELECT
            'MISSING_CURRENCY_STATE','error',
            'N4 ProductVersion requires an active CurrencyState';
    END IF;

    SELECT count(*)
      INTO reference_count
      FROM product.product_reference_reports(p_product_version_uuid);

    IF reference_count = 0 THEN
        RETURN QUERY SELECT
            'MISSING_TRACEABLE_SOURCE','error',
            'N4 ProductVersion has no traceable source Report';
    END IF;

    IF pv.conclusion_text IS NULL
       OR length(btrim(pv.conclusion_text)) = 0
    THEN
        RETURN QUERY SELECT
            'MISSING_CONCLUSION','error',
            'N4 ProductVersion requires conclusion_text';
    END IF;

    IF pv.limitations_summary IS NULL
       OR length(btrim(pv.limitations_summary)) = 0
    THEN
        RETURN QUERY SELECT
            'MISSING_LIMITATIONS','error',
            'N4 ProductVersion requires limitations_summary';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'ai_methodological_verification'
           AND ar.decision = 'passed'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_AI_METHODOLOGICAL_VERIFICATION','error',
            'N4 requires passed AI methodological verification before publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'owner_governance_approval'
           AND ar.decision = 'approved'
    ) THEN
        RETURN QUERY SELECT
            'MISSING_OWNER_APPROVAL','error',
            'N4 requires explicit owner governance approval';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM product.assurance_record ar
         WHERE ar.product_version_uuid = p_product_version_uuid
           AND ar.status = 'active'
           AND ar.assurance_type = 'expert_independent_review'
           AND ar.decision = 'approved'
           AND investigation.has_valid_reviewer_assignment(
               inv_uuid,ar.actor,'cross_cutting',
               'expert_independent_reviewer',
               ar.performed_at,true
           )
    ) THEN
        RETURN QUERY SELECT
            'MISSING_EXPERT_INDEPENDENT_REVIEW','error',
            'N4 requires approved expert independent review backed by a qualified reviewer assignment';
    END IF;

    IF product.assurance_level(p_product_version_uuid) <> 'A3' THEN
        RETURN QUERY SELECT
            'ASSURANCE_BELOW_A3','error',
            format(
                'N4 formal publication requires A3; derived level is %s',
                product.assurance_level(p_product_version_uuid)
            );
    END IF;

    IF pv.publication_date IS NULL THEN
        RETURN QUERY SELECT
            'MISSING_PUBLICATION_DATE','error',
            'Published N4 requires publication_date';
    END IF;

    IF pv.status <> 'published' THEN
        RETURN QUERY SELECT
            'PRODUCT_NOT_PUBLISHED','error',
            format(
                'Formal N4 ProductVersion status must be published; found %s',
                pv.status
            );
    END IF;

    IF EXISTS (
        WITH RECURSIVE deps(version_uuid, path) AS (
            SELECT p_product_version_uuid,
                   ARRAY[p_product_version_uuid]::uuid[]
            UNION ALL
            SELECT de.source_version_uuid,
                   d.path || de.source_version_uuid
              FROM deps d
              JOIN provenance.dependency_edge de
                ON de.target_version_uuid = d.version_uuid
             WHERE de.status = 'active'
               AND cardinality(d.path) < 64
               AND NOT de.source_version_uuid = ANY(d.path)
        )
        SELECT 1
          FROM deps d
          JOIN provenance.record pr
            ON pr.target_version_uuid = d.version_uuid
         WHERE pr.status = 'invalidated'
    ) THEN
        RETURN QUERY SELECT
            'INVALIDATED_DEPENDENCY','error',
            'An invalidated upstream provenance record blocks N4 publication';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM artifact.entity_link ael
         WHERE ael.entity_version_uuid = p_product_version_uuid
           AND ael.role = 'protocol_registration'
    ) THEN
        RETURN QUERY SELECT
            'PROTOCOL_NOT_EXTERNALLY_REGISTERED','warning',
            'No external/public protocol registration artifact is linked';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM investigation.search s
         WHERE s.investigation_version_uuid = inv_uuid
           AND s.filters_payload->>'source_class' = 'grey_literature'
           AND s.status = 'completed'
    ) THEN
        RETURN QUERY SELECT
            'GREY_LITERATURE_LIMITED','warning',
            'No completed grey-literature Search is recorded';
    END IF;

    IF NOT needs_statistical_review THEN
        RETURN QUERY SELECT
            'NO_META_ANALYSIS','warning',
            'No meta-analysis is linked; this is acceptable when synthesis without pooling is methodologically justified';
    END IF;

    RETURN;
END;
$gate$;


CREATE OR REPLACE FUNCTION product.evidence_review_is_publishable(
    p_product_version_uuid uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
AS $publishable$
    SELECT NOT EXISTS (
        SELECT 1
          FROM product.evidence_review_publication_issues(
              p_product_version_uuid
          )
         WHERE severity = 'error'
    );
$publishable$;

-- ---------------------------------------------------------------------------
-- EVIDENCE REVIEW VIEW
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION product.evidence_review_view(
    p_product_version_uuid uuid
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $view$
WITH
primary_inv AS (
    SELECT
        i.oes_investigation_id AS investigation_id,
        iv.entity_uuid AS investigation_entity_uuid,
        iv.version_uuid AS investigation_version_uuid,
        iv.investigation_type,
        iv.depth_level,
        iv.maintenance_level,
        iv.objective,
        iv.protocol_artifact_uuid,
        iv.start_date,
        iv.evidence_cutoff_date
      FROM product.investigation_link il
      JOIN investigation.investigation_version iv
        ON iv.version_uuid = il.investigation_version_uuid
      JOIN investigation.investigation i
        ON i.entity_uuid = iv.entity_uuid
     WHERE il.product_version_uuid = p_product_version_uuid
       AND il.role = 'primary'
     LIMIT 1
),
primary_q AS (
    SELECT
        q.oes_question_id AS question_id,
        qv.entity_uuid AS question_entity_uuid,
        qv.version_uuid AS question_version_uuid,
        qv.original_text,
        qv.normalized_text,
        qv.question_type,
        qv.structure_type,
        qv.context_payload,
        qv.time_horizon_payload
      FROM primary_inv pi
      JOIN investigation.investigation_question iq
        ON iq.investigation_version_uuid = pi.investigation_version_uuid
       AND iq.role = 'primary'
      JOIN investigation.question_version qv
        ON qv.version_uuid = iq.question_version_uuid
      JOIN investigation.question q
        ON q.entity_uuid = qv.entity_uuid
     LIMIT 1
),
refs AS (
    SELECT *
      FROM product.product_reference_reports(p_product_version_uuid)
),
issues AS (
    SELECT *
      FROM product.evidence_review_publication_issues(
          p_product_version_uuid
      )
)
SELECT jsonb_build_object(
    'schema_version','oes.evidence_review_view/0.1',

    'identity', (
        SELECT jsonb_build_object(
            'product_id', pe.oes_id,
            'product_entity_uuid', pv.entity_uuid,
            'product_version_uuid', pv.version_uuid,
            'version_no', ev.version_no,
            'product_type', pv.product_type,
            'title', pv.title,
            'intended_audience', pv.intended_audience,
            'editorial_status', pv.status,
            'entity_version_status', ev.version_status,
            'publication_date', pv.publication_date,
            'evidence_cutoff_date', pv.evidence_cutoff_date,
            'currency_status', ccs.currency_status
        )
          FROM product.product_version pv
          JOIN core.entity_version ev
            ON ev.version_uuid = pv.version_uuid
          JOIN core.entity pe
            ON pe.entity_uuid = pv.entity_uuid
          LEFT JOIN product.current_currency_state ccs
            ON ccs.product_version_uuid = pv.version_uuid
         WHERE pv.version_uuid = p_product_version_uuid
    ),

    'question', (
        SELECT jsonb_build_object(
            'question_id', pq.question_id,
            'question_entity_uuid', pq.question_entity_uuid,
            'question_version_uuid', pq.question_version_uuid,
            'original_text', pq.original_text,
            'normalized_text', pq.normalized_text,
            'question_type', pq.question_type,
            'structure_type', pq.structure_type,
            'context', pq.context_payload,
            'time_horizon', pq.time_horizon_payload
        ) FROM primary_q pq
    ),

    'investigation', (
        SELECT jsonb_build_object(
            'investigation_id', pi.investigation_id,
            'investigation_entity_uuid', pi.investigation_entity_uuid,
            'investigation_version_uuid', pi.investigation_version_uuid,
            'investigation_type', pi.investigation_type,
            'depth_level', pi.depth_level,
            'maintenance_level', pi.maintenance_level,
            'objective', pi.objective,
            'start_date', pi.start_date,
            'evidence_cutoff_date', pi.evidence_cutoff_date
        ) FROM primary_inv pi
    ),

    'subtype', (SELECT pi.investigation_type FROM primary_inv pi),

    'infrastructure_readiness', (
        SELECT COALESCE(
            jsonb_build_object(
                'decision_uuid', md.method_decision_uuid,
                'state', md.impact_payload->>'state',
                'domains', md.impact_payload->'domains',
                'required_sources',
                    md.impact_payload->'required_source_names',
                'rationale', md.rationale,
                'resolution_status', md.resolution_status,
                'decided_at', md.decided_at
            ),
            '{}'::jsonb
        )
          FROM primary_inv pi
          LEFT JOIN LATERAL (
              SELECT md.*
                FROM investigation.method_decision md
               WHERE md.investigation_version_uuid =
                     pi.investigation_version_uuid
                 AND md.record_status='active'
                 AND md.decision_code='N4_INFRASTRUCTURE_READINESS'
               ORDER BY md.decided_at DESC
               LIMIT 1
          ) md ON true
    ),

    'protocol', (
        SELECT CASE
            WHEN a.artifact_uuid IS NULL THEN NULL
            ELSE jsonb_build_object(
                'artifact_uuid',a.artifact_uuid,
                'artifact_type',a.artifact_type,
                'storage_key',a.storage_key,
                'content_hash',a.content_hash,
                'created_at',a.created_at,
                'status',a.status
            )
        END
          FROM primary_inv pi
          LEFT JOIN artifact.artifact a
            ON a.artifact_uuid = pi.protocol_artifact_uuid
    ),

    'registration', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'artifact_uuid',a.artifact_uuid,
                'source_uri',a.source_uri,
                'storage_key',a.storage_key,
                'content_hash',a.content_hash
            )
            ORDER BY a.created_at,a.artifact_uuid
        )
          FROM artifact.entity_link ael
          JOIN artifact.artifact a
            ON a.artifact_uuid=ael.artifact_uuid
         WHERE ael.entity_version_uuid=p_product_version_uuid
           AND ael.role='protocol_registration'
    ),'[]'::jsonb),

    'amendments_and_deviations', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'decision_uuid',md.method_decision_uuid,
                'decision_type',md.decision_type,
                'stage',md.stage,
                'code',md.decision_code,
                'planned',md.planned_flag,
                'rationale',md.rationale,
                'risk',md.risk_payload,
                'mitigation',md.mitigation_payload,
                'impact',md.impact_payload,
                'resolution_status',md.resolution_status,
                'decided_at',md.decided_at
            )
            ORDER BY md.decided_at,md.method_decision_uuid
        )
          FROM investigation.method_decision md
          JOIN primary_inv pi
            ON pi.investigation_version_uuid=md.investigation_version_uuid
         WHERE md.record_status='active'
           AND md.decision_type IN ('method_change','protocol_deviation')
    ),'[]'::jsonb),

    'reviewer_assignments', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'assignment_uuid',ra.reviewer_assignment_uuid,
                'stage',ra.stage,
                'actor',ra.actor,
                'actor_type',ra.actor_type,
                'role',ra.role,
                'qualification',ra.qualification_payload,
                'independent',ra.independent_flag,
                'scope',ra.scope_payload,
                'conflict',ra.conflict_payload,
                'assigned_at',ra.assigned_at,
                'ended_at',ra.ended_at
            )
            ORDER BY ra.stage,ra.role,ra.actor
        )
          FROM investigation.reviewer_assignment ra
          JOIN primary_inv pi
            ON pi.investigation_version_uuid=ra.investigation_version_uuid
         WHERE ra.record_status='active'
    ),'[]'::jsonb),

    'searches', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'search_id',s.oes_search_id,
                'source_name',s.source_name,
                'platform',s.platform,
                'source_class',s.filters_payload->>'source_class',
                'exact_strategy',s.exact_strategy,
                'filters',s.filters_payload,
                'executed_at',s.executed_at,
                'result_count',s.result_count,
                'strategy_version',s.strategy_version,
                'export_artifact_uuid',s.export_artifact_uuid,
                'status',s.status,
                'materialized_hit_count',(
                    SELECT count(*)
                      FROM investigation.search_hit sh
                     WHERE sh.search_uuid=s.search_uuid
                )
            )
            ORDER BY s.executed_at,s.search_uuid
        )
          FROM investigation.search s
          JOIN primary_inv pi
            ON pi.investigation_version_uuid=s.investigation_version_uuid
    ),'[]'::jsonb),

    'selection_flow', (
        SELECT jsonb_build_object(
            'search_hits_materialized',(
                SELECT count(*)
                  FROM investigation.search_hit sh
                  JOIN investigation.search s
                    ON s.search_uuid=sh.search_uuid
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       s.investigation_version_uuid
            ),
            'unique_report_targets',(
                SELECT count(DISTINCT sh.report_entity_uuid)
                  FROM investigation.search_hit sh
                  JOIN investigation.search s
                    ON s.search_uuid=sh.search_uuid
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       s.investigation_version_uuid
                 WHERE sh.report_entity_uuid IS NOT NULL
            ),
            'screening_decisions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       sd.investigation_version_uuid
            ),
            'title_abstract_decisions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       sd.investigation_version_uuid
                 WHERE lower(sd.stage) IN (
                    'title_abstract','title/abstract','abstract'
                 )
            ),
            'full_text_decisions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       sd.investigation_version_uuid
                 WHERE lower(sd.stage) IN ('full_text','full text')
            ),
            'adjudications',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       sd.investigation_version_uuid
                 WHERE sd.adjudication_flag=true
            ),
            'full_text_exclusions',(
                SELECT count(*)
                  FROM investigation.screening_decision sd
                  JOIN primary_inv pi
                    ON pi.investigation_version_uuid=
                       sd.investigation_version_uuid
                 WHERE lower(sd.stage) IN ('full_text','full text')
                   AND sd.decision='exclude'
            )
        )
    ),

    'risk_of_bias', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'risk_assessment_version_uuid',rav.version_uuid,
                'framework',rav.framework,
                'framework_version',rav.framework_version,
                'target_entity_uuid',rav.target_entity_uuid,
                'outcome_entity_uuid',rav.outcome_entity_uuid,
                'overall_judgement',rav.overall_judgement,
                'assessor',rav.assessor,
                'verification_status',rav.verification_status,
                'assessment_date',rav.assessment_date
            )
            ORDER BY rav.assessment_date,rav.version_uuid
        )
          FROM appraisal.risk_assessment_version rav
          JOIN primary_inv pi
            ON pi.investigation_version_uuid=rav.investigation_version_uuid
         WHERE rav.status='active'
           AND upper(rav.framework) <> 'ROB-ME'
    ),'[]'::jsonb),

    'results', COALESCE((
        SELECT jsonb_agg(DISTINCT jsonb_build_object(
            'result_version_uuid',rv.version_uuid,
            'result_entity_uuid',rv.entity_uuid,
            'outcome_entity_uuid',rv.outcome_entity_uuid,
            'measure',rv.measure,
            'reported_value',rv.reported_value,
            'derived_value',rv.derived_value,
            'variance_or_se',rv.variance_or_se,
            'ci_lower',rv.ci_lower,
            'ci_upper',rv.ci_upper,
            'unit',rv.unit,
            'status',rv.status
        ))
          FROM product.synthesis_link sl
          JOIN synthesis.contribution sc
            ON sc.synthesis_version_uuid=sl.synthesis_version_uuid
          JOIN evidence.result_version rv
            ON rv.version_uuid=sc.result_version_uuid
         WHERE sl.product_version_uuid=p_product_version_uuid
    ),'[]'::jsonb),

    'syntheses', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'synthesis_id',se.oes_id,
                'synthesis_entity_uuid',sv.entity_uuid,
                'synthesis_version_uuid',sv.version_uuid,
                'outcome_entity_uuid',sv.outcome_entity_uuid,
                'synthesis_type',sv.synthesis_type,
                'synthesis_origin',sv.synthesis_origin,
                'method',sv.method,
                'model',sv.model,
                'software',sv.software,
                'software_version',sv.software_version,
                'code_artifact_uuid',sv.code_artifact_uuid,
                'analysis_dataset_artifact_uuid',
                    sv.analysis_dataset_artifact_uuid,
                'result_summary',sv.result_summary,
                'status',sv.status,
                'executed_at',sv.executed_at,
                'role',sl.role
            )
            ORDER BY sl.sequence_no NULLS LAST,sv.version_uuid
        )
          FROM product.synthesis_link sl
          JOIN synthesis.synthesis_version sv
            ON sv.version_uuid=sl.synthesis_version_uuid
          JOIN core.entity se
            ON se.entity_uuid=sv.entity_uuid
         WHERE sl.product_version_uuid=p_product_version_uuid
    ),'[]'::jsonb),

    'missing_evidence', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'risk_assessment_version_uuid',rav.version_uuid,
                'framework',rav.framework,
                'target_entity_uuid',rav.target_entity_uuid,
                'overall_judgement',rav.overall_judgement,
                'assessor',rav.assessor,
                'verification_status',rav.verification_status,
                'instrument',rav.instrument_payload
            )
            ORDER BY rav.version_uuid
        )
          FROM appraisal.risk_assessment_version rav
          JOIN primary_inv pi
            ON pi.investigation_version_uuid=rav.investigation_version_uuid
         WHERE rav.status='active'
           AND upper(rav.framework)='ROB-ME'
    ),'[]'::jsonb),

    'certainty', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'certainty_assessment_version_uuid',cav.version_uuid,
                'framework',cav.framework,
                'framework_version',cav.framework_version,
                'outcome_entity_uuid',cav.outcome_entity_uuid,
                'initial_level',cav.initial_level,
                'final_level',cav.final_level,
                'evidence_state',cav.evidence_state,
                'assessment_date',cav.assessment_date,
                'role',cl.role
            )
            ORDER BY cl.sequence_no NULLS LAST,cav.version_uuid
        )
          FROM product.certainty_link cl
          JOIN appraisal.certainty_assessment_version cav
            ON cav.version_uuid=cl.certainty_assessment_version_uuid
         WHERE cl.product_version_uuid=p_product_version_uuid
    ),'[]'::jsonb),

    'summary_of_findings', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'artifact_uuid',a.artifact_uuid,
                'storage_key',a.storage_key,
                'content_hash',a.content_hash,
                'mime_type',a.mime_type
            )
            ORDER BY a.created_at,a.artifact_uuid
        )
          FROM artifact.entity_link ael
          JOIN artifact.artifact a
            ON a.artifact_uuid=ael.artifact_uuid
         WHERE ael.entity_version_uuid=p_product_version_uuid
           AND ael.role='summary_of_findings'
    ),'[]'::jsonb),

    'conclusion', (
        SELECT jsonb_build_object(
            'text',pv.conclusion_text
        )
          FROM product.product_version pv
         WHERE pv.version_uuid=p_product_version_uuid
    ),

    'applicability', (
        SELECT jsonb_build_object(
            'summary',pv.applicability_summary
        )
          FROM product.product_version pv
         WHERE pv.version_uuid=p_product_version_uuid
    ),

    'limitations', (
        SELECT jsonb_build_object(
            'summary',pv.limitations_summary
        )
          FROM product.product_version pv
         WHERE pv.version_uuid=p_product_version_uuid
    ),

    'references', COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'report_id',r.report_id,
                'report_entity_uuid',r.report_entity_uuid,
                'report_version_uuid',r.report_version_uuid,
                'title',r.title,
                'publication_date',r.publication_date,
                'publication_status',r.publication_status,
                'source_locations',r.source_locations
            )
            ORDER BY r.publication_date NULLS LAST,r.report_id
        )
          FROM refs r
    ),'[]'::jsonb),

    'audit', jsonb_build_object(
        'assurance_level',
            product.assurance_level(p_product_version_uuid),
        'publishable',
            product.evidence_review_is_publishable(
                p_product_version_uuid
            ),
        'readiness_state', (
            SELECT md.impact_payload->>'state'
              FROM investigation.method_decision md
              JOIN primary_inv pi
                ON pi.investigation_version_uuid=
                   md.investigation_version_uuid
             WHERE md.record_status='active'
               AND md.decision_code='N4_INFRASTRUCTURE_READINESS'
             ORDER BY md.decided_at DESC
             LIMIT 1
        ),
        'reviewer_assignment_count', (
            SELECT count(*)
              FROM investigation.reviewer_assignment ra
              JOIN primary_inv pi
                ON pi.investigation_version_uuid=
                   ra.investigation_version_uuid
             WHERE ra.record_status='active'
        ),
        'protocol_deviations_open', EXISTS (
            SELECT 1
              FROM investigation.method_decision md
              JOIN primary_inv pi
                ON pi.investigation_version_uuid=
                   md.investigation_version_uuid
             WHERE md.record_status='active'
               AND md.decision_type='protocol_deviation'
               AND md.resolution_status='open'
        ),
        'expert_independent_reviewed', EXISTS (
            SELECT 1
              FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
               AND ar.status='active'
               AND ar.assurance_type='expert_independent_review'
               AND ar.decision='approved'
        ),
        'publication_issues', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'issue_code',i.issue_code,
                    'severity',i.severity,
                    'message',i.message
                )
                ORDER BY
                    CASE i.severity
                        WHEN 'error' THEN 1
                        WHEN 'warning' THEN 2
                        ELSE 3
                    END,
                    i.issue_code
            )
              FROM issues i
        ),'[]'::jsonb),
        'assurance_records', COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'assurance_type',ar.assurance_type,
                    'actor',ar.actor,
                    'actor_type',ar.actor_type,
                    'independent',ar.independent_flag,
                    'decision',ar.decision,
                    'performed_at',ar.performed_at,
                    'status',ar.status
                )
                ORDER BY ar.performed_at,ar.assurance_uuid
            )
              FROM product.assurance_record ar
             WHERE ar.product_version_uuid=p_product_version_uuid
        ),'[]'::jsonb)
    )
);
$view$;

COMMIT;
