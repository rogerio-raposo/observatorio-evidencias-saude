-- OES Fase 3 — Real N1-01 A1 rebuild assertion
DO $rn1a1rebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;

  IF v IS NULL
     OR v#>>'{identity,version_no}' <> '2'
     OR v#>>'{audit,assurance_level}' <> 'A1'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
  THEN
    RAISE EXCEPTION 'RN1-A1-T09 FAIL: rebuilt A1 EvidenceResponseView invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_OWNER_APPROVAL'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN1-A1-T09 FAIL: rebuilt A1 view missing owner-approval blocker';
  END IF;

  RAISE NOTICE 'RN1-A1-T09 PASS — rebuild preserves A1/non-publishable state';
END
$rn1a1rebuild$;
