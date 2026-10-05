-- OES Fase 3 — Real N1-01 A2 rebuild assertion
DO $rn1a2rebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;

  IF v IS NULL
     OR v#>>'{identity,version_no}' <> '2'
     OR v#>>'{identity,editorial_status}' <> 'published'
     OR v#>>'{identity,publication_date}' <> '2026-10-05'
     OR v#>>'{audit,assurance_level}' <> 'A2'
     OR v#>>'{audit,publishable}' <> 'true'
     OR v#>>'{audit,expert_independent_reviewed}' <> 'false'
  THEN
    RAISE EXCEPTION 'RN1-A2-T09 FAIL: rebuilt A2 EvidenceResponseView invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW'
      AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'RN1-A2-T09 FAIL: rebuilt A2 view missing no-expert warning';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE severity='error'
  ) THEN
    RAISE EXCEPTION 'RN1-A2-T09 FAIL: rebuilt A2 view retains blocking error';
  END IF;

  RAISE NOTICE 'RN1-A2-T09 PASS — rebuild preserves published A2 state with no-expert warning';
END
$rn1a2rebuild$;
