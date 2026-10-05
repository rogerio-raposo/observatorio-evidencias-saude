-- OES Fase 3 — Real N1 Case 01 rebuild assertion: initial A0 state
DO $rn1rebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000501'
     OR v#>>'{routing,depth_level}' <> 'N1'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR jsonb_array_length(v->'key_sources') <> 7
     OR jsonb_array_length(v->'key_results') <> 3
  THEN
    RAISE EXCEPTION 'RN1-T13 FAIL: rebuilt real N1 A0 contract invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='MISSING_AI_METHODOLOGICAL_VERIFICATION'
      AND i->>'severity'='error'
  ) THEN
    RAISE EXCEPTION 'RN1-T13 FAIL: rebuilt view missing AI verification block';
  END IF;

  RAISE NOTICE 'RN1-T13 PASS — rebuild produced correct A0/under_review real N1 view';
END
$rn1rebuild$;
