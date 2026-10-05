-- OES Fase 3 — Real N0-01 A1 tests
-- Requires real N0 materialization + AI methodological verification.

-- RN0-A1-T01 — current ProductVersion derives A1.
DO $t01$
BEGIN
  IF product.evidence_scan_assurance_level('c1000000-0000-0000-0000-000000000301') <> 'A1' THEN
    RAISE EXCEPTION 'RN0-A1-T01 FAIL: expected A1';
  END IF;
  RAISE NOTICE 'RN0-A1-T01 PASS — current ProductVersion derives A1';
END
$t01$;

-- RN0-A1-T02 — AI blocker cleared; owner/publication blockers remain.
DO $t02$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION'
  ) THEN
    RAISE EXCEPTION 'RN0-A1-T02 FAIL: AI blocker still present';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_OWNER_APPROVAL' AND severity='error'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_PUBLICATION_DATE' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN0-A1-T02 FAIL: owner/publication blockers missing';
  END IF;

  RAISE NOTICE 'RN0-A1-T02 PASS — AI blocker cleared; owner/publication blockers preserved';
END
$t02$;

-- RN0-A1-T03 — A1 internal scan remains non-publishable.
DO $t03$
BEGIN
  IF product.evidence_scan_is_publishable('c1000000-0000-0000-0000-000000000301') THEN
    RAISE EXCEPTION 'RN0-A1-T03 FAIL: A1 formal Product unexpectedly publishable';
  END IF;
  RAISE NOTICE 'RN0-A1-T03 PASS — A1 internal scan remains non-publishable';
END
$t03$;

-- RN0-A1-T04 — no expert review warning remains explicit.
DO $t04$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW' AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'RN0-A1-T04 FAIL: no-expert warning missing';
  END IF;
  RAISE NOTICE 'RN0-A1-T04 PASS — no-expert warning remains explicit';
END
$t04$;

-- RN0-A1-T05 — owner approval remains absent.
DO $t05$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='c1000000-0000-0000-0000-000000000301'
      AND assurance_type='owner_governance_approval'
      AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN0-A1-T05 FAIL: owner approval was inferred';
  END IF;
  RAISE NOTICE 'RN0-A1-T05 PASS — owner approval remains absent';
END
$t05$;

-- RN0-A1-T06 — scientific scan content/routing is unchanged.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;

  IF v#>>'{maturity,category}' <> 'partially_synthesized'
     OR v#>>'{routing_recommendation,recommendation,target}' <> 'N2'
     OR v#>>'{routing_recommendation,recommendation,requires_question_reformulation}' <> 'true'
     OR jsonb_array_length(v->'central_sources') <> 6
  THEN
    RAISE EXCEPTION 'RN0-A1-T06 FAIL: scientific content/routing changed during assurance transition';
  END IF;

  RAISE NOTICE 'RN0-A1-T06 PASS — A1 did not alter maturity, sources or routing';
END
$t06$;

-- RN0-A1-T07 — EvidenceScanView exposes correct internal A1 preview state.
DO $t07$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;

  IF v#>>'{audit,assurance_level}' <> 'A1'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{identity,publication_date}' IS NOT NULL
     OR v#>>'{audit,expert_independent_reviewed}' <> 'false'
  THEN
    RAISE EXCEPTION 'RN0-A1-T07 FAIL: A1 EvidenceScanView state mismatch';
  END IF;

  RAISE NOTICE 'RN0-A1-T07 PASS — EvidenceScanView exposes correct A1 internal preview state';
END
$t07$;
