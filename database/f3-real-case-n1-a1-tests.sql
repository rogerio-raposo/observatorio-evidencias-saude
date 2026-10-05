-- OES Fase 3 — Real N1-01 A1 tests after second adversarial verification

-- RN1-A1-T01 — current ProductVersion derives A1.
DO $t01$
BEGIN
  IF product.evidence_response_assurance_level('a1000000-0000-0000-0000-000000000702') <> 'A1' THEN
    RAISE EXCEPTION 'RN1-A1-T01 FAIL: expected A1 after passed AI verification';
  END IF;
  RAISE NOTICE 'RN1-A1-T01 PASS — current ProductVersion derives A1';
END
$t01$;

-- RN1-A1-T02 — AI verification blocker is removed, owner/publication blockers remain.
DO $t02$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T02 FAIL: AI verification blocker remained active';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_OWNER_APPROVAL'
      AND severity='error'
  ) OR NOT EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_PUBLICATION_DATE'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T02 FAIL: owner/publication blockers missing';
  END IF;

  RAISE NOTICE 'RN1-A1-T02 PASS — AI blocker cleared; owner/publication blockers preserved';
END
$t02$;

-- RN1-A1-T03 — product remains non-publishable.
DO $t03$
BEGIN
  IF product.evidence_response_is_publishable('a1000000-0000-0000-0000-000000000702') THEN
    RAISE EXCEPTION 'RN1-A1-T03 FAIL: A1 product unexpectedly publishable';
  END IF;
  RAISE NOTICE 'RN1-A1-T03 PASS — A1 remains non-publishable';
END
$t03$;

-- RN1-A1-T04 — expert review warning remains explicit.
DO $t04$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW'
      AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T04 FAIL: no-expert warning missing';
  END IF;
  RAISE NOTICE 'RN1-A1-T04 PASS — no-expert warning remains explicit';
END
$t04$;

-- RN1-A1-T05 — no owner approval is inferred.
DO $t05$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='a1000000-0000-0000-0000-000000000702'
      AND assurance_type='owner_governance_approval'
      AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T05 FAIL: owner approval was inferred';
  END IF;
  RAISE NOTICE 'RN1-A1-T05 PASS — owner approval remains absent';
END
$t05$;

-- RN1-A1-T06 — prior revise remains historically attached to ProductVersion 1.
DO $t06$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='a1000000-0000-0000-0000-000000000701'
      AND assurance_type='ai_methodological_verification'
      AND decision='revise'
      AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T06 FAIL: first revise history missing';
  END IF;
  RAISE NOTICE 'RN1-A1-T06 PASS — first revise history preserved';
END
$t06$;

-- RN1-A1-T07 — ROBIS verification lifecycle reflects second pass.
DO $t07$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM appraisal.risk_assessment_version
    WHERE version_uuid='a1000000-0000-0000-0000-000000000401'
      AND verification_status='ai_verified_passed'
      AND overall_judgement='high_risk'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T07 FAIL: ROBIS verification lifecycle mismatch';
  END IF;
  RAISE NOTICE 'RN1-A1-T07 PASS — ROBIS judgement preserved and verification passed';
END
$t07$;

-- RN1-A1-T08 — rendered view exposes A1 and blocked preview state.
DO $t08$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;

  IF v#>>'{audit,assurance_level}' <> 'A1'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
  THEN
    RAISE EXCEPTION 'RN1-A1-T08 FAIL: EvidenceResponseView A1 state mismatch';
  END IF;

  RAISE NOTICE 'RN1-A1-T08 PASS — EvidenceResponseView exposes correct A1 preview state';
END
$t08$;
