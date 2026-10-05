-- OES Fase 3 — Evidence Scan N0 contract tests
-- Requires f3-evidence-scan-fixtures.sql loaded after migration 013.
-- Integrated with validate-s5.yml after migration 013.

-- ES-T01 — formal N0 fixture is A2 and publishable.
DO $t01$
BEGIN
  IF product.evidence_scan_assurance_level('b1000000-0000-0000-0000-000000000301') <> 'A2' THEN
    RAISE EXCEPTION 'ES-T01 FAIL: expected A2';
  END IF;
  IF NOT product.evidence_scan_is_publishable('b1000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ES-T01 FAIL: formal N0 fixture is not publishable';
  END IF;
  RAISE NOTICE 'ES-T01 PASS — formal N0 fixture is A2 and publishable';
END
$t01$;

-- ES-T02 — N0 does not require Synthesis, Certainty or formal RiskAssessment.
DO $t02$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.synthesis_link
    WHERE product_version_uuid='b1000000-0000-0000-0000-000000000301'
  ) THEN
    RAISE EXCEPTION 'ES-T02 FAIL: fixture unexpectedly has Synthesis';
  END IF;

  IF EXISTS (
    SELECT 1 FROM product.certainty_link
    WHERE product_version_uuid='b1000000-0000-0000-0000-000000000301'
  ) THEN
    RAISE EXCEPTION 'ES-T02 FAIL: fixture unexpectedly has Certainty';
  END IF;

  IF EXISTS (
    SELECT 1 FROM appraisal.risk_assessment_version
    WHERE investigation_version_uuid='b1000000-0000-0000-0000-000000000002'
  ) THEN
    RAISE EXCEPTION 'ES-T02 FAIL: fixture unexpectedly requires RiskAssessment';
  END IF;

  RAISE NOTICE 'ES-T02 PASS — N0 remains valid without Synthesis/Certainty/RiskAssessment';
END
$t02$;

-- ES-T03 — view exposes N0 identity, original question and non-exhaustive method.
DO $t03$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF v#>>'{identity,product_type}' <> 'evidence_scan'
     OR v#>>'{investigation,depth_level}' <> 'N0'
     OR v#>>'{method,non_exhaustive}' <> 'true'
     OR v#>>'{question,original_text}' <> 'O que existe de evidência sobre a área sintética X?'
  THEN
    RAISE EXCEPTION 'ES-T03 FAIL: core EvidenceScanView projection mismatch';
  END IF;

  RAISE NOTICE 'ES-T03 PASS — EvidenceScanView preserves N0 identity/question/method';
END
$t03$;

-- ES-T04 — maturity and routing recommendation are structured.
DO $t04$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF v#>>'{maturity,category}' <> 'well_synthesized'
     OR v#>>'{routing_recommendation,recommendation,target}' <> 'N1'
     OR btrim(coalesce(v#>>'{routing_recommendation,rationale,text}','')) = ''
  THEN
    RAISE EXCEPTION 'ES-T04 FAIL: maturity/routing projection mismatch';
  END IF;

  RAISE NOTICE 'ES-T04 PASS — maturity and N1 routing are explicit';
END
$t04$;

-- ES-T05 — two traceable central Reports are projected.
DO $t05$
DECLARE v jsonb; n integer;
BEGIN
  SELECT count(*) INTO n
  FROM product.evidence_scan_reference_reports('b1000000-0000-0000-0000-000000000301');

  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF n <> 2
     OR jsonb_array_length(v->'central_sources') <> 2
     OR jsonb_array_length(v->'references') <> 2
  THEN
    RAISE EXCEPTION 'ES-T05 FAIL: expected two traceable central sources';
  END IF;

  RAISE NOTICE 'ES-T05 PASS — central sources and references are traceable';
END
$t05$;

-- ES-T06 — search signals are execution-specific and two searches are exposed.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF jsonb_array_length(v#>'{method,searches}') <> 2
     OR jsonb_array_length(v->'volume_signals') <> 2
     OR position('not the total size' in v#>>'{method,count_disclaimer}') = 0
  THEN
    RAISE EXCEPTION 'ES-T06 FAIL: search/volume disclaimer contract mismatch';
  END IF;

  RAISE NOTICE 'ES-T06 PASS — exploratory search counts remain qualified';
END
$t06$;

-- ES-T07 — removing owner approval yields A1 and blocks formal publication.
BEGIN;
UPDATE product.assurance_record
   SET decision='revise'
 WHERE product_version_uuid='b1000000-0000-0000-0000-000000000301'
   AND assurance_type='owner_governance_approval'
   AND status='active';

DO $t07$
BEGIN
  IF product.evidence_scan_assurance_level('b1000000-0000-0000-0000-000000000301') <> 'A1' THEN
    RAISE EXCEPTION 'ES-T07 FAIL: expected A1 without approved owner governance';
  END IF;

  IF product.evidence_scan_is_publishable('b1000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ES-T07 FAIL: formal A1 Evidence Scan unexpectedly publishable';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_OWNER_APPROVAL' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T07 FAIL: missing owner approval blocker absent';
  END IF;

  RAISE NOTICE 'ES-T07 PASS — A1 may support internal scan but not formal publication';
END
$t07$;
ROLLBACK;

-- ES-T08 — wrong depth blocks.
BEGIN;
UPDATE investigation.investigation_version
   SET depth_level='N1'
 WHERE version_uuid='b1000000-0000-0000-0000-000000000002';

DO $t08$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='PRIMARY_INVESTIGATION_NOT_N0' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T08 FAIL: wrong depth did not block';
  END IF;
  RAISE NOTICE 'ES-T08 PASS — primary Investigation must remain N0';
END
$t08$;
ROLLBACK;

-- ES-T09 — missing completed Search blocks.
BEGIN;
UPDATE investigation.search
   SET status='archived'
 WHERE investigation_version_uuid='b1000000-0000-0000-0000-000000000002';

DO $t09$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_SEARCH_RECORD' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T09 FAIL: missing Search did not block';
  END IF;
  RAISE NOTICE 'ES-T09 PASS — completed exploratory Search is required';
END
$t09$;
ROLLBACK;

-- ES-T10 — missing maturity judgement blocks.
BEGIN;
UPDATE provenance.record
   SET status='superseded'
 WHERE target_version_uuid='b1000000-0000-0000-0000-000000000301'
   AND field_path='scan.maturity';

DO $t10$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_MATURITY_JUDGEMENT' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T10 FAIL: missing maturity did not block';
  END IF;
  RAISE NOTICE 'ES-T10 PASS — maturity judgement is required';
END
$t10$;
ROLLBACK;

-- ES-T11 — invalidated central ReportVersion blocks.
BEGIN;
UPDATE core.entity_version
   SET version_status='invalidated'
 WHERE version_uuid='b1000000-0000-0000-0000-000000000201';

DO $t11$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code IN ('INVALIDATED_DEPENDENCY','INVALIDATED_UPSTREAM_DEPENDENCY')
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T11 FAIL: invalidated source did not block';
  END IF;
  RAISE NOTICE 'ES-T11 PASS — invalidated evidence dependency blocks publication';
END
$t11$;
ROLLBACK;

-- ES-T12 — search-only insufficient-field exception is valid.
BEGIN;

-- Provenance is append-preserving: supersede source-bearing rows instead of mutating them.
UPDATE provenance.record
   SET status='superseded'
 WHERE target_version_uuid='b1000000-0000-0000-0000-000000000301'
   AND source_report_version_uuid IS NOT NULL
   AND status='active';

UPDATE provenance.record
   SET status='superseded'
 WHERE target_version_uuid='b1000000-0000-0000-0000-000000000301'
   AND field_path='scan.maturity'
   AND status='active';

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,
 source_value,process_type,process_record_uuid,transformation,actor,
 supersedes_provenance_uuid,status
) VALUES
(
 'b5000000-0000-0000-0000-000000000321',
 'b1000000-0000-0000-0000-000000000301',
 'scan.field_description',
 NULL,
 'Recorded exploratory searches',
 '{"text":"No central ReportVersion was located in the recorded exploratory searches.","scope_qualifier":"exploratory_non_exhaustive"}'::jsonb,
 'search_signal',
 'b2000000-0000-0000-0000-000000000001',
 '{"rationale":"Search-only field description for the controlled insufficient-field exception."}'::jsonb,
 'OES',
 'b5000000-0000-0000-0000-000000000301',
 'active'
),
(
 'b5000000-0000-0000-0000-000000000322',
 'b1000000-0000-0000-0000-000000000301',
 'scan.maturity',
 NULL,
 'OES exploratory judgement from recorded searches',
 '{"category":"insufficient","rationale":"No central report was located in the recorded exploratory searches.","confidence_qualifier":"preliminary"}'::jsonb,
 'oes_exploratory_judgement',
 'b2000000-0000-0000-0000-000000000001',
 '{"inputs":["recorded exploratory searches"],"limitation":"Does not establish definitive absence of evidence."}'::jsonb,
 'OES',
 'b5000000-0000-0000-0000-000000000310',
 'active'
);

DO $t12$
DECLARE v jsonb;
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_TRACEABLE_BASIS' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T12 FAIL: valid search-only insufficient exception was blocked';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='NO_TRACEABLE_CENTRAL_REPORTS' AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'ES-T12 FAIL: search-only exception warning missing';
  END IF;

  IF NOT product.evidence_scan_is_publishable('b1000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'ES-T12 FAIL: valid search-only insufficient scan should remain publishable';
  END IF;

  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF v#>>'{audit,traceable_basis_type}' <> 'search_only_insufficient' THEN
    RAISE EXCEPTION 'ES-T12 FAIL: search-only basis type not projected';
  END IF;

  RAISE NOTICE 'ES-T12 PASS — insufficient field may be supported by recorded Searches without a central Report';
END
$t12$;
ROLLBACK;

-- ES-T13 — zero Reports without insufficient maturity is invalid.
BEGIN;

-- Again preserve history: source-bearing provenance is superseded and a new
-- search-based field description is appended. The original well_synthesized
-- maturity judgement remains active, so the insufficient exception must fail.
UPDATE provenance.record
   SET status='superseded'
 WHERE target_version_uuid='b1000000-0000-0000-0000-000000000301'
   AND source_report_version_uuid IS NOT NULL
   AND status='active';

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,
 source_value,process_type,process_record_uuid,transformation,actor,
 supersedes_provenance_uuid,status
) VALUES (
 'b5000000-0000-0000-0000-000000000331',
 'b1000000-0000-0000-0000-000000000301',
 'scan.field_description',
 NULL,
 'Recorded exploratory searches',
 '{"text":"Search-only field description used to test invalid use of the insufficient exception.","scope_qualifier":"exploratory_non_exhaustive"}'::jsonb,
 'search_signal',
 'b2000000-0000-0000-0000-000000000001',
 '{"rationale":"No central ReportVersion remains active, while maturity is still well_synthesized."}'::jsonb,
 'OES',
 'b5000000-0000-0000-0000-000000000301',
 'active'
);

DO $t13$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('b1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_TRACEABLE_BASIS' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'ES-T13 FAIL: zero Reports with well-synthesized maturity was not blocked';
  END IF;
  RAISE NOTICE 'ES-T13 PASS — search-only exception cannot be used outside insufficient maturity';
END
$t13$;
ROLLBACK;

-- ES-T14 — audit exposes A2, no-expert warning and mixed traceable basis.
DO $t14$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('b1000000-0000-0000-0000-000000000301') INTO v;

  IF v#>>'{audit,assurance_level}' <> 'A2'
     OR v#>>'{audit,publishable}' <> 'true'
     OR v#>>'{audit,expert_independent_reviewed}' <> 'false'
     OR v#>>'{audit,traceable_basis_type}' <> 'mixed'
  THEN
    RAISE EXCEPTION 'ES-T14 FAIL: audit state mismatch';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='NO_EXPERT_INDEPENDENT_REVIEW'
  ) THEN
    RAISE EXCEPTION 'ES-T14 FAIL: no-expert warning absent';
  END IF;

  RAISE NOTICE 'ES-T14 PASS — A2 audit and mixed provenance basis projected';
END
$t14$;
