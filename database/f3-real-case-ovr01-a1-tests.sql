-- OES Fase 3 — OVR-01 post-A1 validation tests
-- Requires f3-real-case-ovr01-dcbti.sql + f3-real-case-ovr01-assurance-a1.sql.

-- OVR01-A1-T01 — assurance rises exactly to A1 and remains non-publishable.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'd9100000-0000-0000-0000-000000000020'
    );

    IF v#>>'{audit,assurance_level}'<>'A1'
       OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
       OR v#>>'{identity,editorial_status}'<>'under_review'
       OR v#>>'{identity,publication_date}' IS NOT NULL
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T01 FAIL — expected internal blocked A1 state: %',
            v->'audit';
    END IF;
END;
$test$;

-- OVR01-A1-T02 — exactly one active AI methodological assurance exists.
DO $test$
BEGIN
    IF (
        SELECT count(*)
          FROM product.assurance_record
         WHERE product_version_uuid=
               'd9100000-0000-0000-0000-000000000020'
           AND status='active'
    )<>1
       OR NOT EXISTS (
            SELECT 1
              FROM product.assurance_record
             WHERE assurance_uuid=
                   'd9810000-0000-0000-0000-000000000001'
               AND product_version_uuid=
                   'd9100000-0000-0000-0000-000000000020'
               AND assurance_type='ai_methodological_verification'
               AND actor='OES_OVR01_AI_SECOND_PASS'
               AND actor_type='ai_system'
               AND independent_flag=false
               AND decision='passed'
               AND status='active'
       )
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T02 FAIL — AI assurance record mismatch';
    END IF;
END;
$test$;

-- OVR01-A1-T03 — second-pass QC is AI-only and no human control was fabricated.
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM investigation.quality_control_record
         WHERE quality_control_uuid=
               'd9820000-0000-0000-0000-000000000001'
           AND investigation_version_uuid=
               'd9100000-0000-0000-0000-000000000002'
           AND stage='cross_cutting'
           AND control_type='other'
           AND scope_payload->>'control_code'=
               'ovr01_ai_methodological_second_pass'
           AND actor='OES_OVR01_AI_SECOND_PASS'
           AND actor_type='ai_system'
           AND independent_flag=false
           AND decision='passed'
           AND record_status='active'
    ) OR EXISTS (
        SELECT 1
          FROM investigation.reviewer_assignment
         WHERE investigation_version_uuid=
               'd9100000-0000-0000-0000-000000000002'
           AND record_status='active'
    ) OR EXISTS (
        SELECT 1
          FROM investigation.quality_control_record
         WHERE investigation_version_uuid=
               'd9100000-0000-0000-0000-000000000002'
           AND record_status='active'
           AND actor_type IN ('human_reviewer','human_expert')
    ) OR EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE product_version_uuid=
               'd9100000-0000-0000-0000-000000000020'
           AND status='active'
           AND assurance_type IN (
                'owner_governance_approval',
                'expert_independent_review'
           )
    ) THEN
        RAISE EXCEPTION
            'OVR01-A1-T03 FAIL — false human/owner/expert control detected';
    END IF;
END;
$test$;

-- OVR01-A1-T04 — formal publication blockers remain explicit at A1.
DO $test$
DECLARE code text;
BEGIN
    FOREACH code IN ARRAY ARRAY[
        'MISSING_LAST_SEARCH_DATE',
        'MISSING_OWNER_APPROVAL',
        'MISSING_EXPERT_INDEPENDENT_REVIEW',
        'MISSING_EXPERT_REVIEWER_ASSIGNMENT',
        'ASSURANCE_BELOW_REQUIRED_LEVEL',
        'UNVERIFIED_REVIEW_APPRAISAL',
        'UNVERIFIED_MEMBERSHIP',
        'MISSING_OVERLAP_CONTROL',
        'UNVERIFIED_OUTCOME_EVIDENCE'
    ]
    LOOP
        IF NOT EXISTS (
            SELECT 1
              FROM product.overview_of_reviews_publication_issues(
                   'd9100000-0000-0000-0000-000000000020'
              )
             WHERE issue_code=code
               AND severity='error'
        ) THEN
            RAISE EXCEPTION
                'OVR01-A1-T04 FAIL — expected blocker % absent',code;
        END IF;
    END LOOP;

    IF EXISTS (
        SELECT 1
          FROM product.overview_of_reviews_publication_issues(
               'd9100000-0000-0000-0000-000000000020'
          )
         WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION'
    ) THEN
        RAISE EXCEPTION
            'OVR01-A1-T04 FAIL — passed AI verification still reported missing';
    END IF;
END;
$test$;

-- OVR01-A1-T05 — Gao/currentness and documentary-discovery corrections remain unchanged.
DO $test$
DECLARE p jsonb;
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM overview.review_item
         WHERE review_item_uuid=
               'd9500000-0000-0000-0000-000000000102'
           AND last_search_date IS NULL
           AND currentness_status='unclear'
           AND currentness_rationale ILIKE '%no date is inferred%'
    ) THEN
        RAISE EXCEPTION
            'OVR01-A1-T05 FAIL — Gao currentness changed';
    END IF;

    SELECT impact_payload INTO p
      FROM investigation.method_decision
     WHERE investigation_version_uuid=
           'd9100000-0000-0000-0000-000000000002'
       AND decision_code='overview_search_coverage_policy'
       AND record_status='active';

    IF p->>'search_execution_materialized'<>'false'
       OR p->>'coverage_claim'<>'structured_non_exhaustive'
       OR p ? 'minimum_bibliographic_sources'
       OR EXISTS (
            SELECT 1
              FROM investigation.search
             WHERE investigation_version_uuid=
                   'd9100000-0000-0000-0000-000000000002'
       )
       OR EXISTS (
            SELECT 1
              FROM investigation.screening_decision
             WHERE investigation_version_uuid=
                   'd9100000-0000-0000-0000-000000000002'
       )
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T05 FAIL — documentary discovery regressed';
    END IF;
END;
$test$;

-- OVR01-A1-T06 — membership/overlap state is unchanged; verification remains unverified.
DO $test$
DECLARE m record;
BEGIN
    SELECT * INTO m
      FROM overview.overlap_metrics(
        'd9100000-0000-0000-0000-000000000002',
        'd9520000-0000-0000-0000-000000000001'
      );

    IF m.review_count<>3
       OR m.study_occurrence_count<>86
       OR m.unique_primary_study_count<>59
       OR m.membership_completeness<>'complete'
       OR NOT m.cca_calculable
       OR m.cca IS NULL
       OR EXISTS (
            SELECT 1
              FROM overview.primary_study_membership psm
              JOIN overview.review_item ri
                ON ri.review_item_uuid=psm.review_item_uuid
             WHERE ri.investigation_version_uuid=
                   'd9100000-0000-0000-0000-000000000002'
               AND psm.status='active'
               AND (
                    psm.verification_status<>'unverified'
                    OR psm.verified_by IS NOT NULL
                    OR psm.verifier_actor_type IS NOT NULL
                    OR psm.verified_at IS NOT NULL
               )
       )
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T06 FAIL — overlap/membership state changed';
    END IF;
END;
$test$;

-- OVR01-A1-T07 — comparator, certainty, ROBIS and no-reanalysis rules remain intact.
DO $test$
BEGIN
    IF (SELECT comparison_payload->>'family'
          FROM overview.outcome_evidence
         WHERE outcome_evidence_uuid=
               'd9540000-0000-0000-0000-000000000001')
       <>'digital_sleep_education_or_hygiene'
       OR (SELECT comparison_payload->>'family'
             FROM overview.outcome_evidence
            WHERE outcome_evidence_uuid=
                  'd9540000-0000-0000-0000-000000000002')
          <>'mixed_multiple_controls'
       OR (SELECT comparison_payload->>'family'
             FROM overview.outcome_evidence
            WHERE outcome_evidence_uuid=
                  'd9540000-0000-0000-0000-000000000003')
          <>'mixed_multiple_controls'
       OR EXISTS (
            SELECT 1
              FROM overview.outcome_evidence oe
              JOIN overview.review_item ri
                ON ri.review_item_uuid=oe.review_item_uuid
             WHERE ri.investigation_version_uuid=
                   'd9100000-0000-0000-0000-000000000002'
               AND oe.certainty_assessment_version_uuid IS NOT NULL
       )
       OR EXISTS (
            SELECT 1
              FROM product.synthesis_link psl
              JOIN synthesis.synthesis_version sv
                ON sv.version_uuid=psl.synthesis_version_uuid
             WHERE psl.product_version_uuid=
                   'd9100000-0000-0000-0000-000000000020'
               AND sv.synthesis_origin='oes_generated'
       )
       OR (SELECT overall_judgement
             FROM appraisal.risk_assessment_version
            WHERE version_uuid=
                  'd9310000-0000-0000-0000-000000000701')<>'unclear'
       OR (SELECT overall_judgement
             FROM appraisal.risk_assessment_version
            WHERE version_uuid=
                  'd9310000-0000-0000-0000-000000000702')<>'unclear'
       OR (SELECT overall_judgement
             FROM appraisal.risk_assessment_version
            WHERE version_uuid=
                  'd9310000-0000-0000-0000-000000000703')<>'high'
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T07 FAIL — comparator/certainty/ROBIS/reanalysis drift';
    END IF;
END;
$test$;

-- OVR01-A1-T08 — View exposes the A1 assurance and AI QC without hiding blockers.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'd9100000-0000-0000-0000-000000000020'
    );

    IF v#>>'{audit,assurance_level}'<>'A1'
       OR jsonb_array_length(v#>'{audit,assurance_records}')<>1
       OR v#>>'{audit,assurance_records,0,assurance_type}'
          <>'ai_methodological_verification'
       OR v#>>'{audit,assurance_records,0,decision}'<>'passed'
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(
                   v#>'{methodology,quality_controls}'
              ) q
             WHERE q->>'control_code'=
                   'ovr01_ai_methodological_second_pass'
               AND q->>'actor_type'='ai_system'
               AND q->>'decision'='passed'
       )
       OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
       OR NOT EXISTS (
            SELECT 1
              FROM jsonb_array_elements(
                   v#>'{audit,publication_issues}'
              ) i
             WHERE i->>'code'='MISSING_LAST_SEARCH_DATE'
               AND i->>'severity'='error'
       )
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T08 FAIL — A1 audit/QC projection mismatch';
    END IF;
END;
$test$;

-- OVR01-A1-T09 — no new ProductVersion is created solely for assurance.
DO $test$
BEGIN
    IF (
        SELECT count(*)
          FROM core.entity_version
         WHERE entity_uuid=
               'd9000000-0000-0000-0000-000000000020'
    )<>1
       OR NOT EXISTS (
            SELECT 1
              FROM core.entity_version
             WHERE version_uuid=
                   'd9100000-0000-0000-0000-000000000020'
               AND version_status='current'
       )
    THEN
        RAISE EXCEPTION
            'OVR01-A1-T09 FAIL — ProductVersion mutated for assurance only';
    END IF;
END;
$test$;

SELECT 'OVR01-A1-T01–T09 PASS — OVR-01 internal A1 derives only from passed AI methodological verification; formal blockers and epistemic limits remain intact'
AS ovr01_a1_status;
