-- OES Fase 3 — Evidence Review N4 contract tests, part B
-- Requires part A prerequisites and formal synthetic N4 fixture.

-- ER4-T13 — every material appraisal needs two independent judgements.
BEGIN;
UPDATE provenance.record
   SET status='superseded'
 WHERE provenance_uuid='f5000000-0000-0000-0000-000000000402';
DO $t13$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_DUPLICATE_RISK_OF_BIAS_ASSESSMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T13 FAIL: missing second appraisal judgement not detected';
  END IF;
  RAISE NOTICE 'ER4-T13 PASS — duplicate appraisal enforced';
END
$t13$;
ROLLBACK;

-- ER4-T14 — conflicting appraisal judgements require consensus.
BEGIN;
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor,created_at,status
) VALUES (
 'f5000000-0000-0000-0000-000000009914',
 'f1000000-0000-0000-0000-000000000401',
 'n4.appraisal.synthetic_disagreement',
 'd1000000-0000-0000-0000-000000000201',
 'Methods/Results',
 '{"judgement":"some_concerns"}'::jsonb,
 'n4_independent_appraisal_judgement','SYN_N4_R2',
 TIMESTAMPTZ '2026-10-06 15:10:00-03','active'
);
DO $t14$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='UNRESOLVED_APPRAISAL_DISAGREEMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T14 FAIL: conflicting appraisal lacks consensus but gate stayed open';
  END IF;
  RAISE NOTICE 'ER4-T14 PASS — appraisal disagreement requires consensus';
END
$t14$;
ROLLBACK;

-- ER4-T15 — meta-analysis requires code and dataset artifacts.
BEGIN;
UPDATE synthesis.synthesis_version
   SET code_artifact_uuid=NULL
 WHERE version_uuid='f1000000-0000-0000-0000-000000000501';
DO $t15$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_REPRODUCIBLE_ANALYSIS_ARTIFACT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T15 FAIL: missing analysis code artifact not detected';
  END IF;
  RAISE NOTICE 'ER4-T15 PASS — meta-analysis code/dataset reproducibility enforced';
END
$t15$;
ROLLBACK;

-- ER4-T16 — meta-analysis requires qualified statistical review.
BEGIN;
UPDATE investigation.quality_control_record
   SET record_status='superseded'
 WHERE quality_control_uuid='f6500000-0000-0000-0000-000000000005';
DO $t16$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_STATISTICAL_REVIEW'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T16 FAIL: missing statistical review not detected';
  END IF;
  RAISE NOTICE 'ER4-T16 PASS — qualified statistical review enforced';
END
$t16$;
ROLLBACK;

-- ER4-T17 — meta-analysis requires active ROB-ME in this intervention contract.
BEGIN;
UPDATE appraisal.risk_assessment_version
   SET status='superseded'
 WHERE version_uuid='f1000000-0000-0000-0000-000000000403';
DO $t17$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_MISSING_EVIDENCE_ASSESSMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T17 FAIL: missing ROB-ME not detected';
  END IF;
  RAISE NOTICE 'ER4-T17 PASS — synthesis-level missing-evidence assessment enforced';
END
$t17$;
ROLLBACK;

-- ER4-T18 — certainty requires two independent judgements.
BEGIN;
UPDATE provenance.record
   SET status='superseded'
 WHERE provenance_uuid='f5000000-0000-0000-0000-000000000602';
DO $t18$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_DUPLICATE_CERTAINTY_ASSESSMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T18 FAIL: missing second certainty judgement not detected';
  END IF;
  RAISE NOTICE 'ER4-T18 PASS — duplicate certainty assessment enforced';
END
$t18$;
ROLLBACK;

-- ER4-T19 — conflicting certainty judgements require consensus.
BEGIN;
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_value,
 process_type,actor,created_at,status
) VALUES (
 'f5000000-0000-0000-0000-000000009919',
 'f1000000-0000-0000-0000-000000000601',
 'n4.certainty.synthetic_disagreement',
 '{"final_level":"low"}'::jsonb,
 'n4_independent_certainty_judgement','SYN_N4_R2',
 TIMESTAMPTZ '2026-10-06 15:15:00-03','active'
);
DO $t19$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='UNRESOLVED_CERTAINTY_DISAGREEMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T19 FAIL: conflicting certainty lacks consensus but gate stayed open';
  END IF;
  RAISE NOTICE 'ER4-T19 PASS — certainty disagreement requires consensus';
END
$t19$;
ROLLBACK;

-- ER4-T20 — intervention review requires Summary of Findings.
BEGIN;
DELETE FROM artifact.entity_link
 WHERE artifact_uuid='f9000000-0000-0000-0000-000000000022'
   AND entity_version_uuid='f1000000-0000-0000-0000-000000000701'
   AND role='summary_of_findings';
DO $t20$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_SUMMARY_OF_FINDINGS'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T20 FAIL: missing Summary of Findings not detected';
  END IF;
  RAISE NOTICE 'ER4-T20 PASS — Summary of Findings enforced';
END
$t20$;
ROLLBACK;

-- ER4-T21 — expert review/A3 remain mandatory after all stage controls pass.
BEGIN;
UPDATE product.assurance_record
   SET status='superseded'
 WHERE assurance_uuid='f8000000-0000-0000-0000-000000000703';
DO $t21$
BEGIN
  IF product.evidence_review_assurance_level(
       'f1000000-0000-0000-0000-000000000701'
     ) <> 'A2'
     OR NOT EXISTS (
       SELECT 1 FROM product.evidence_review_publication_issues(
         'f1000000-0000-0000-0000-000000000701'
       )
       WHERE issue_code='MISSING_EXPERT_INDEPENDENT_REVIEW'
         AND severity='error'
     )
     OR NOT EXISTS (
       SELECT 1 FROM product.evidence_review_publication_issues(
         'f1000000-0000-0000-0000-000000000701'
       )
       WHERE issue_code='ASSURANCE_BELOW_A3'
         AND severity='error'
     )
  THEN
    RAISE EXCEPTION 'ER4-T21 FAIL: missing expert review/A3 not enforced';
  END IF;
  RAISE NOTICE 'ER4-T21 PASS — expert independent review and A3 remain mandatory';
END
$t21$;
ROLLBACK;

-- ER4-T22 — invalidated upstream provenance blocks publication.
BEGIN;
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_value,
 process_type,actor,created_at,status,invalidated_at,invalidation_reason
) VALUES (
 'f5000000-0000-0000-0000-000000009922',
 'f1000000-0000-0000-0000-000000000501',
 'n4.synthetic.invalidated_upstream',
 '{"test":true}'::jsonb,'synthetic_test','N4_TEST',
 TIMESTAMPTZ '2026-10-06 15:20:00-03',
 'invalidated',TIMESTAMPTZ '2026-10-06 15:21:00-03',
 'Synthetic invalidation for gate testing'
);
DO $t22$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='INVALIDATED_DEPENDENCY'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T22 FAIL: invalidated upstream dependency not detected';
  END IF;
  RAISE NOTICE 'ER4-T22 PASS — invalidated upstream provenance blocks N4';
END
$t22$;
ROLLBACK;

-- ER4-T23 — ReviewerAssignment is append-preserving and cannot be AI.
DO $t23$
DECLARE immutable_rejected boolean := false;
DECLARE ai_rejected boolean := false;
BEGIN
  BEGIN
    UPDATE investigation.reviewer_assignment
       SET actor='MUTATED_SYNTHETIC_ACTOR'
     WHERE reviewer_assignment_uuid='f6100000-0000-0000-0000-000000000002';
  EXCEPTION WHEN OTHERS THEN
    IF position('material fields are immutable' in SQLERRM) > 0 THEN
      immutable_rejected := true;
    ELSE
      RAISE;
    END IF;
  END;

  BEGIN
    INSERT INTO investigation.reviewer_assignment(
      reviewer_assignment_uuid,investigation_version_uuid,stage,
      actor,actor_type,role,qualification_payload,independent_flag,
      scope_payload,conflict_payload,assigned_at,record_status
    ) VALUES (
      'f6100000-0000-0000-0000-000000009923',
      'f1000000-0000-0000-0000-000000000002',
      'screening','SYN_N4_AI_IMPERSONATOR','ai_system',
      'secondary_reviewer',
      '{"qualified":true,"basis":"invalid synthetic AI assignment"}'::jsonb,
      true,'{}'::jsonb,'{"declared":false}'::jsonb,
      TIMESTAMPTZ '2026-10-06 15:25:00-03','active'
    );
  EXCEPTION WHEN check_violation THEN
    ai_rejected := true;
  END;

  IF NOT immutable_rejected OR NOT ai_rejected THEN
    RAISE EXCEPTION 'ER4-T23 FAIL: immutable=% ai_rejected=%',
      immutable_rejected, ai_rejected;
  END IF;

  RAISE NOTICE 'ER4-T23 PASS — assignments are immutable and AI cannot impersonate human reviewer';
END
$t23$;

-- ER4-T24 — completed bibliographic searches require export artifacts.
BEGIN;
UPDATE investigation.search
   SET export_artifact_uuid=NULL
 WHERE search_uuid='f2000000-0000-0000-0000-000000000002';
DO $t24$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_SEARCH_EXPORT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T24 FAIL: missing search export not detected';
  END IF;
  RAISE NOTICE 'ER4-T24 PASS — bibliographic search export artifact enforced';
END
$t24$;
ROLLBACK;

-- ER4-T25 — protocol must predate definitive searches.
BEGIN;
UPDATE artifact.artifact
   SET created_at=TIMESTAMPTZ '2026-10-06 09:30:00-03'
 WHERE artifact_uuid='f9000000-0000-0000-0000-000000000001';
DO $t25$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='PROTOCOL_NOT_PROSPECTIVE'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T25 FAIL: post-search protocol was not detected';
  END IF;
  RAISE NOTICE 'ER4-T25 PASS — prospective protocol enforced';
END
$t25$;
ROLLBACK;
