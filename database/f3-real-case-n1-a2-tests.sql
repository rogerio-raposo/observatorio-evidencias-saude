-- OES Fase 3 — Real N1-01 A2 publication tests

-- RN1-A2-T01 — assurance derives A2.
DO $t01$
BEGIN
  IF product.evidence_response_assurance_level('a1000000-0000-0000-0000-000000000702') <> 'A2' THEN
    RAISE EXCEPTION 'RN1-A2-T01 FAIL: expected A2';
  END IF;
  RAISE NOTICE 'RN1-A2-T01 PASS — assurance derives A2';
END
$t01$;

-- RN1-A2-T02 — product is published and publishable.
DO $t02$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;

  IF v#>>'{identity,editorial_status}' <> 'published'
     OR v#>>'{identity,publication_date}' <> '2026-10-05'
     OR v#>>'{audit,publishable}' <> 'true'
     OR v#>>'{audit,assurance_level}' <> 'A2'
  THEN
    RAISE EXCEPTION 'RN1-A2-T02 FAIL: published/A2/publishable state mismatch';
  END IF;

  RAISE NOTICE 'RN1-A2-T02 PASS — published A2 view is publishable';
END
$t02$;

-- RN1-A2-T03 — no blocking publication errors remain.
DO $t03$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE severity='error'
  ) THEN
    RAISE EXCEPTION 'RN1-A2-T03 FAIL: blocking publication issue remains';
  END IF;

  RAISE NOTICE 'RN1-A2-T03 PASS — no blocking publication errors';
END
$t03$;

-- RN1-A2-T04 — no-expert warning remains explicit.
DO $t04$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW'
      AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'RN1-A2-T04 FAIL: no-expert warning missing';
  END IF;

  RAISE NOTICE 'RN1-A2-T04 PASS — no-expert warning remains explicit';
END
$t04$;

-- RN1-A2-T05 — owner approval record is active and not independent.
DO $t05$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='a1000000-0000-0000-0000-000000000702'
      AND assurance_type='owner_governance_approval'
      AND actor_type='owner'
      AND independent_flag=false
      AND decision='approved'
      AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN1-A2-T05 FAIL: owner approval record missing or malformed';
  END IF;

  RAISE NOTICE 'RN1-A2-T05 PASS — explicit owner governance approval persisted';
END
$t05$;

-- RN1-A2-T06 — expert review remains absent; A2 must not become A3.
DO $t06$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='a1000000-0000-0000-0000-000000000702'
      AND assurance_type='expert_independent_review'
      AND status='active'
      AND decision='approved'
  ) THEN
    RAISE EXCEPTION 'RN1-A2-T06 FAIL: expert review was fabricated';
  END IF;

  IF product.evidence_response_assurance_level('a1000000-0000-0000-0000-000000000702') = 'A3' THEN
    RAISE EXCEPTION 'RN1-A2-T06 FAIL: A2 incorrectly elevated to A3';
  END IF;

  RAISE NOTICE 'RN1-A2-T06 PASS — no expert review fabricated; A2 is not A3';
END
$t06$;

-- RN1-A2-T07 — scientific content/version remains unchanged by owner approval.
DO $t07$
DECLARE c text;
BEGIN
  SELECT conclusion_text INTO c
  FROM product.product_version
  WHERE version_uuid='a1000000-0000-0000-0000-000000000702';

  IF position('Stoop et al. 2026' in c)=0
     OR position('Yu et al.' in c)=0
     OR position('checagem seletiva OES' in c)=0
  THEN
    RAISE EXCEPTION 'RN1-A2-T07 FAIL: scientific conclusion unexpectedly changed';
  END IF;

  RAISE NOTICE 'RN1-A2-T07 PASS — owner approval did not alter scientific content';
END
$t07$;

-- RN1-A2-T08 — rendered audit discloses A2 and no expert review.
DO $t08$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;

  IF v#>>'{audit,expert_independent_reviewed}' <> 'false' THEN
    RAISE EXCEPTION 'RN1-A2-T08 FAIL: expert review flag incorrect';
  END IF;

  IF position('revisão especializada independente não realizada' in lower(v#>>'{audit,assurance_disclosure}'))=0 THEN
    RAISE EXCEPTION 'RN1-A2-T08 FAIL: A2 no-expert disclosure missing';
  END IF;

  RAISE NOTICE 'RN1-A2-T08 PASS — A2 disclosure preserves no-expert status';
END
$t08$;
