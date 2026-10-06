-- OES Fase 3 — Overview of Reviews adversarial tests B2
-- OV-T23–T26, OV-T28, OV-T30.

BEGIN;
UPDATE overview.overlap_resolution
   SET status='superseded'
 WHERE overlap_resolution_uuid='f9530000-0000-0000-0000-000000000001';
INSERT INTO overview.overlap_resolution(
    overlap_resolution_uuid,cluster_uuid,strategy,decision_payload,
    rationale,decided_by,actor_type,verification_status,
    verified_by,verifier_actor_type,verified_at,decided_at,status
) VALUES (
    'f9530000-0000-0000-0000-000000001023',
    'f9520000-0000-0000-0000-000000000001',
    'include_all_deduplicate_outcomes','{}'::jsonb,
    'Unsupported formal v0.1 strategy test.',
    'SYN_OV_R1','human_reviewer','human_verified',
    'SYN_OV_DATA_VERIFIER','human_reviewer',
    TIMESTAMPTZ '2026-10-06 13:05:00-03',
    TIMESTAMPTZ '2026-10-06 13:04:00-03','active'
);
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='OUTCOME_DEDUP_STRATEGY_UNSUPPORTED_V01'
          AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T23 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
UPDATE investigation.quality_control_record
   SET record_status='superseded'
 WHERE quality_control_uuid='f9220000-0000-0000-0000-000000000004';
DO $test$
BEGIN
    IF product.assurance_level(
        'f9100000-0000-0000-0000-000000000020'
    )<>'A3' THEN
        RAISE EXCEPTION 'OV-T24 setup FAIL';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='MISSING_OVERLAP_CONTROL' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T24 FAIL — A3 bypassed missing control';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
UPDATE overview.outcome_evidence
   SET verification_status='unverified',
       verified_by=NULL,
       verifier_actor_type=NULL,
       verified_at=NULL
 WHERE outcome_evidence_uuid='f9540000-0000-0000-0000-000000000002';
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='UNVERIFIED_OUTCOME_EVIDENCE' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T25 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

BEGIN;
INSERT INTO product.certainty_link(
    product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
    'f9100000-0000-0000-0000-000000000020',
    'f9310000-0000-0000-0000-000000000601',
    'global',1
);
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='GLOBAL_OVERVIEW_CERTAINTY_NOT_ALLOWED'
          AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T26 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='OUTDATED_INCLUDED_REVIEW' AND severity='warning'
    ) THEN
        RAISE EXCEPTION 'OV-T28 FAIL — outdated disclosure absent';
    END IF;
END;
$test$;

BEGIN;
INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,
    source_report_version_uuid,source_location,source_value,
    process_type,transformation,actor,status,
    invalidated_at,invalidation_reason
) VALUES (
    'f9700000-0000-0000-0000-000000000030',
    'f9100000-0000-0000-0000-000000000020',
    'test.invalidated_dependency',
    NULL,'synthetic test location',
    '{"test":"OV-T30"}'::jsonb,
    'test','{}'::jsonb,
    'OVERVIEW_TEST','invalidated',
    TIMESTAMPTZ '2026-10-06 13:30:00-03',
    'Synthetic invalidation for OV-T30'
);
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM product.overview_of_reviews_publication_issues(
            'f9100000-0000-0000-0000-000000000020'
        )
        WHERE issue_code='INVALIDATED_DEPENDENCY' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'OV-T30 FAIL';
    END IF;
END;
$test$;
ROLLBACK;

SELECT 'OV-T23–T26 + OV-T28 + OV-T30 PASS' AS overview_tests_b2_status;
