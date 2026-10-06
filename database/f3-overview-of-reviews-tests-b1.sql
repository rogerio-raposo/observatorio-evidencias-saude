-- OES Fase 3 — Overview of Reviews adversarial tests B1
-- OV-T14–T22.

DO $test$
DECLARE item_count integer; report_count integer;
BEGIN
    SELECT count(*) INTO item_count
      FROM overview.review_item ri
      JOIN evidence.study_version sv
        ON sv.version_uuid=ri.review_study_version_uuid
     WHERE sv.entity_uuid='f9300000-0000-0000-0000-000000000101'
       AND ri.status='active';
    SELECT count(*) INTO report_count
      FROM evidence.study_report_link
     WHERE study_entity_uuid='f9300000-0000-0000-0000-000000000101'
       AND status='active';
    IF item_count<>1 OR report_count<>2 THEN
        RAISE EXCEPTION 'OV-T14 FAIL — items=% reports=%',item_count,report_count;
    END IF;
END;
$test$;

BEGIN;
INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
    'f9310000-0000-0000-0000-000000001101',
    'f9300000-0000-0000-0000-000000000101',
    2,'superseded','overview-test','correction',
    'Alternate historical Review A version'
);
INSERT INTO evidence.study_version(
    version_uuid,entity_uuid,study_type,design,title_or_label,
    sample_size,status
) VALUES (
    'f9310000-0000-0000-0000-000000001101',
    'f9300000-0000-0000-0000-000000000101',
    'systematic_review','systematic review with meta-analysis',
    'Synthetic Review A alternate historical version',3100,'active'
);
DO $test$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO overview.review_item(
            review_item_uuid,investigation_version_uuid,
            review_study_version_uuid,item_role,
            eligibility_basis_payload,last_search_date,
            membership_completeness,currentness_status,
            currentness_rationale,status
        ) VALUES (
            'f9500000-0000-0000-0000-000000001101',
            'f9100000-0000-0000-0000-000000000002',
            'f9310000-0000-0000-0000-000000001101',
            'supporting',
            '{"historical_version_selected":true}'::jsonb,
            DATE '2024-01-01','complete','current',NULL,'active'
        );
    EXCEPTION WHEN OTHERS THEN
        caught := true;
    END;
    IF NOT caught THEN
        RAISE EXCEPTION 'OV-T15 FAIL — second active version accepted';
    END IF;
END;
$test$;
ROLLBACK;

DO $test$
DECLARE r integer; n integer;
BEGIN
    SELECT unique_primary_study_count,study_occurrence_count
      INTO r,n
      FROM overview.overlap_metrics(
          'f9100000-0000-0000-0000-000000000002',
          'f9520000-0000-0000-0000-000000000001'
      );
    IF r<>5 OR n<>9 THEN
        RAISE EXCEPTION 'OV-T16 FAIL — r=% N=%',r,n;
    END IF;
END;
$test$;

BEGIN;
UPDATE overview.review_item
   SET membership_completeness='partial'
 WHERE review_item_uuid='f9500000-0000-0000-0000-000000000103';
DO $test$
DECLARE c numeric; calc boolean; completeness text;
BEGIN
    SELECT cca,cca_calculable,membership_completeness
      INTO c,calc,completeness
      FROM overview.overlap_metrics(
          'f9100000-0000-0000-0000-000000000002',
          'f9520000-0000-0000-0000-000000000001'
      );
    IF c IS NOT NULL OR calc OR completeness<>'partial' THEN
        RAISE EXCEPTION 'OV-T17 FAIL — CCA=% calc=% completeness=%',c,calc,completeness;
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
UPDATE overview.primary_study_membership
   SET identity_confidence='low'
 WHERE membership_uuid='f9510000-0000-0000-0000-000000000001';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='LOW_CONFIDENCE_STUDY_IDENTITY' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T18 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
DO $test$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        UPDATE overview.primary_study_membership
           SET verifier_actor_type='ai_system'
         WHERE membership_uuid='f9510000-0000-0000-0000-000000000001';
    EXCEPTION WHEN check_violation THEN
        caught := true;
    END;
    IF NOT caught THEN
        RAISE EXCEPTION 'OV-T19 FAIL — AI accepted as human verifier';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
UPDATE appraisal.risk_assessment_version
   SET status='superseded'
 WHERE version_uuid='f9310000-0000-0000-0000-000000000702';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='MISSING_REVIEW_ROBIS' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T20 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
DO $test$
DECLARE caught boolean := false;
BEGIN
    BEGIN
        INSERT INTO overview.outcome_evidence(
            outcome_evidence_uuid,review_item_uuid,result_version_uuid,
            outcome_entity_uuid,analysis_role,primary_study_set_status,
            extraction_payload,verification_status,
            verified_by,verifier_actor_type,verified_at,status
        ) VALUES (
            'f9540000-0000-0000-0000-000000001021',
            'f9500000-0000-0000-0000-000000000102',
            'f9310000-0000-0000-0000-000000000501',
            'f9300000-0000-0000-0000-000000000301',
            'supporting_estimate','complete','{}'::jsonb,
            'human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',
            TIMESTAMPTZ '2026-10-06 13:00:00-03','active'
        );
    EXCEPTION WHEN OTHERS THEN
        caught := true;
    END;
    IF NOT caught THEN
        RAISE EXCEPTION 'OV-T21 FAIL — wrong-review Result accepted';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
UPDATE overview.overlap_resolution
   SET status='superseded'
 WHERE overlap_resolution_uuid='f9530000-0000-0000-0000-000000000001';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='MISSING_OVERLAP_RESOLUTION' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T22 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

SELECT 'OV-T14–T22 PASS' AS overview_tests_b1_status;
