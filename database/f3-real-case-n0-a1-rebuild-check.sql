-- OES Fase 3 — Real N0-01 A1 rebuild assertion
DO $rn0a1rebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000601'
     OR v#>>'{audit,assurance_level}' <> 'A1'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{identity,publication_date}' IS NOT NULL
     OR v#>>'{maturity,category}' <> 'partially_synthesized'
     OR v#>>'{routing_recommendation,recommendation,target}' <> 'N2'
     OR v#>>'{routing_recommendation,recommendation,requires_question_reformulation}' <> 'true'
  THEN
    RAISE EXCEPTION 'RN0-A1-T08 FAIL: rebuilt A1 EvidenceScanView invalid';
  END IF;

  IF EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION'
  ) THEN
    RAISE EXCEPTION 'RN0-A1-T08 FAIL: rebuilt A1 view still has AI blocker';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_OWNER_APPROVAL' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN0-A1-T08 FAIL: rebuilt A1 view missing owner blocker';
  END IF;

  RAISE NOTICE 'RN0-A1-T08 PASS — rebuild preserves internal A1 state and N2 routing';
END
$rn0a1rebuild$;
