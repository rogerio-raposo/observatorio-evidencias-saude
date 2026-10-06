-- OES Fase 3 — Evidence Review N4 contract tests, part A
-- Requires migration 015 + N3 fixture + f3-evidence-review-fixtures.sql.

-- ER4-T01 — formal synthetic N4 is A3 and publishable.
DO $t01$
DECLARE err_n integer;
BEGIN
  SELECT count(*) INTO err_n
  FROM product.evidence_review_publication_issues(
    'f1000000-0000-0000-0000-000000000701'
  )
  WHERE severity='error';

  IF product.evidence_review_assurance_level(
       'f1000000-0000-0000-0000-000000000701'
     ) <> 'A3'
     OR NOT product.evidence_review_is_publishable(
       'f1000000-0000-0000-0000-000000000701'
     )
     OR err_n <> 0
  THEN
    RAISE EXCEPTION 'ER4-T01 FAIL: formal synthetic N4 is not A3/publishable or has % errors', err_n;
  END IF;

  RAISE NOTICE 'ER4-T01 PASS — formal synthetic N4 derives A3 and is publishable';
END
$t01$;

-- ER4-T02 — EvidenceReviewView projects the full N4 contract.
DO $t02$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_review_view(
    'f1000000-0000-0000-0000-000000000701'
  ) INTO v;

  IF v->>'schema_version' <> 'oes.evidence_review_view/0.1'
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-001201'
     OR v#>>'{identity,product_type}' <> 'evidence_review'
     OR v#>>'{investigation,depth_level}' <> 'N4'
     OR v->>'subtype' <> 'systematic_review_intervention'
     OR v#>>'{infrastructure_readiness,state}' <> 'ready'
     OR v#>>'{audit,assurance_level}' <> 'A3'
     OR v#>>'{audit,publishable}' <> 'true'
     OR v#>>'{audit,qualified_stage_controls_satisfied}' <> 'true'
     OR v#>>'{audit,lineage_available}' <> 'true'
  THEN
    RAISE EXCEPTION 'ER4-T02 FAIL: EvidenceReviewView identity/audit mismatch';
  END IF;

  IF jsonb_array_length(v->'searches') <> 3
     OR jsonb_array_length(v->'reviewer_assignments') <> 12
     OR jsonb_array_length(v->'search_peer_review') <> 1
     OR jsonb_array_length(v->'study_characteristics') <> 2
     OR jsonb_array_length(v->'risk_of_bias') <> 2
     OR jsonb_array_length(v->'results') <> 2
     OR jsonb_array_length(v->'syntheses') <> 1
     OR jsonb_array_length(v->'missing_evidence') <> 1
     OR jsonb_array_length(v->'certainty') <> 1
     OR jsonb_array_length(v->'summary_of_findings') <> 1
     OR jsonb_array_length(v->'heterogeneity') <> 1
     OR jsonb_array_length(v->'sensitivity_analyses') <> 2
     OR jsonb_array_length(v->'references') <> 2
  THEN
    RAISE EXCEPTION 'ER4-T02 FAIL: EvidenceReviewView section counts mismatch';
  END IF;

  RAISE NOTICE 'ER4-T02 PASS — EvidenceReviewView projects complete formal N4 fixture';
END
$t02$;

-- ER4-T03 — warnings do not close the gate.
DO $t03$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='GREY_LITERATURE_LIMITED'
      AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'ER4-T03 FAIL: expected grey-literature warning absent';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='PROTOCOL_NOT_EXTERNALLY_REGISTERED'
  ) THEN
    RAISE EXCEPTION 'ER4-T03 FAIL: protocol registration warning should be cleared';
  END IF;

  IF NOT product.evidence_review_is_publishable(
    'f1000000-0000-0000-0000-000000000701'
  ) THEN
    RAISE EXCEPTION 'ER4-T03 FAIL: non-blocking warning closed publication gate';
  END IF;

  RAISE NOTICE 'ER4-T03 PASS — warnings remain transparent and non-blocking';
END
$t03$;

-- ER4-T04 — readiness not_ready blocks despite A3.
BEGIN;
INSERT INTO investigation.method_decision(
 method_decision_uuid,investigation_version_uuid,decision_type,stage,
 decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
 impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES (
 'f6000000-0000-0000-0000-000000000099',
 'f1000000-0000-0000-0000-000000000002',
 'other','cross_cutting','N4_INFRASTRUCTURE_READINESS',true,
 'Synthetic negative test: infrastructure becomes unavailable.',
 '{"test":true}'::jsonb,'{"test":true}'::jsonb,
 '{"state":"not_ready","domains":{"bibliographic_coverage":"not_ready"}}'::jsonb,
 'accepted','N4_TEST',TIMESTAMPTZ '2026-10-06 15:00:00-03','active'
);
DO $t04$
BEGIN
  IF product.evidence_review_assurance_level(
       'f1000000-0000-0000-0000-000000000701'
     ) <> 'A3'
     OR NOT EXISTS (
       SELECT 1 FROM product.evidence_review_publication_issues(
         'f1000000-0000-0000-0000-000000000701'
       )
       WHERE issue_code='INFRASTRUCTURE_NOT_READY' AND severity='error'
     )
     OR product.evidence_review_is_publishable(
       'f1000000-0000-0000-0000-000000000701'
     )
  THEN
    RAISE EXCEPTION 'ER4-T04 FAIL: readiness did not override otherwise-complete A3 state';
  END IF;
  RAISE NOTICE 'ER4-T04 PASS — not_ready blocks A3 publication';
END
$t04$;
ROLLBACK;

-- ER4-T05 — one bibliographic database is insufficient.
BEGIN;
UPDATE investigation.search
   SET filters_payload = jsonb_set(
       filters_payload,'{source_class}','"citation_chasing"'::jsonb
   )
 WHERE search_uuid IN (
   'f2000000-0000-0000-0000-000000000002',
   'f2000000-0000-0000-0000-000000000003'
 );
DO $t05$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='INSUFFICIENT_BIBLIOGRAPHIC_COVERAGE'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T05 FAIL: single-database state did not block publication';
  END IF;
  RAISE NOTICE 'ER4-T05 PASS — single bibliographic database blocks N4';
END
$t05$;
ROLLBACK;

-- ER4-T06 — a readiness-required source must actually execute.
BEGIN;
UPDATE investigation.search
   SET status='not_executed'
 WHERE search_uuid='f2000000-0000-0000-0000-000000000003';
DO $t06$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_REQUIRED_SEARCH_SOURCE'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T06 FAIL: missing readiness-required source was not detected';
  END IF;
  RAISE NOTICE 'ER4-T06 PASS — missing required source blocks N4';
END
$t06$;
ROLLBACK;

-- ER4-T07 — A3 cannot bypass missing search peer review.
BEGIN;
UPDATE investigation.quality_control_record
   SET record_status='superseded'
 WHERE quality_control_uuid='f6500000-0000-0000-0000-000000000001';
DO $t07$
BEGIN
  IF product.evidence_review_assurance_level(
       'f1000000-0000-0000-0000-000000000701'
     ) <> 'A3'
     OR NOT EXISTS (
       SELECT 1 FROM product.evidence_review_publication_issues(
         'f1000000-0000-0000-0000-000000000701'
       )
       WHERE issue_code='MISSING_SEARCH_PEER_REVIEW'
         AND severity='error'
     )
     OR product.evidence_review_is_publishable(
       'f1000000-0000-0000-0000-000000000701'
     )
  THEN
    RAISE EXCEPTION 'ER4-T07 FAIL: A3 bypassed search peer-review control';
  END IF;
  RAISE NOTICE 'ER4-T07 PASS — A3 does not bypass search peer review';
END
$t07$;
ROLLBACK;

-- ER4-T08 — duplicate title/abstract screening is required.
BEGIN;
UPDATE investigation.screening_decision
   SET stage='title_abstract_removed_for_test'
 WHERE screening_uuid='f3500000-0000-0000-0000-000000000212';
DO $t08$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_DUPLICATE_TITLE_ABSTRACT_SCREENING'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T08 FAIL: missing second title/abstract reviewer not detected';
  END IF;
  RAISE NOTICE 'ER4-T08 PASS — duplicate title/abstract screening enforced';
END
$t08$;
ROLLBACK;

-- ER4-T09 — duplicate full-text screening is mandatory.
BEGIN;
UPDATE investigation.screening_decision
   SET stage='full_text_removed_for_test'
 WHERE screening_uuid='f3500000-0000-0000-0000-000000000222';
DO $t09$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_DUPLICATE_FULL_TEXT_SCREENING'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T09 FAIL: missing second full-text reviewer not detected';
  END IF;
  RAISE NOTICE 'ER4-T09 PASS — duplicate full-text screening enforced';
END
$t09$;
ROLLBACK;

-- ER4-T10 — screening disagreement requires adjudication.
BEGIN;
UPDATE investigation.screening_decision
   SET decision='exclude',
       exclusion_reason='synthetic disagreement'
 WHERE screening_uuid='f3500000-0000-0000-0000-000000000222';
DO $t10$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='UNRESOLVED_SCREENING_DISAGREEMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T10 FAIL: unresolved screening disagreement not detected';
  END IF;
  RAISE NOTICE 'ER4-T10 PASS — screening disagreement requires adjudication';
END
$t10$;
ROLLBACK;

-- ER4-T11 — each critical Result needs two independent extractions.
BEGIN;
UPDATE provenance.record
   SET status='superseded'
 WHERE provenance_uuid='f5000000-0000-0000-0000-000000000302';
DO $t11$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='MISSING_CRITICAL_RESULT_DUPLICATE_EXTRACTION'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T11 FAIL: missing independent extraction not detected';
  END IF;
  RAISE NOTICE 'ER4-T11 PASS — duplicate critical extraction enforced';
END
$t11$;
ROLLBACK;

-- ER4-T12 — conflicting extractions require explicit consensus.
BEGIN;
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor,created_at,status
) VALUES (
 'f5000000-0000-0000-0000-000000009912',
 'd1000000-0000-0000-0000-000000000301',
 'n4.extraction.synthetic_disagreement',
 'd1000000-0000-0000-0000-000000000201',
 'Table 2',
 '{"md":-2.2,"ci":[-3.50,-0.70]}'::jsonb,
 'n4_independent_extraction','SYN_N4_R2',
 TIMESTAMPTZ '2026-10-06 15:05:00-03','active'
);
DO $t12$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_review_publication_issues(
      'f1000000-0000-0000-0000-000000000701'
    )
    WHERE issue_code='UNRESOLVED_EXTRACTION_DISAGREEMENT'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ER4-T12 FAIL: conflicting extraction lacks consensus but gate stayed open';
  END IF;
  RAISE NOTICE 'ER4-T12 PASS — extraction disagreement requires consensus';
END
$t12$;
ROLLBACK;
