-- OES Fase 3 — Real N0-01 rebuild assertion
DO $rn0rebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000601'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{investigation,depth_level}' <> 'N0'
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{maturity,category}' <> 'partially_synthesized'
     OR v#>>'{routing_recommendation,recommendation,target}' <> 'N2'
     OR v#>>'{routing_recommendation,recommendation,requires_question_reformulation}' <> 'true'
     OR jsonb_array_length(v->'central_sources') <> 6
     OR jsonb_array_length(v->'references') <> 6
  THEN
    RAISE EXCEPTION 'RN0-T13 FAIL: rebuilt real N0 EvidenceScanView invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='MISSING_AI_METHODOLOGICAL_VERIFICATION'
  ) THEN
    RAISE EXCEPTION 'RN0-T13 FAIL: rebuilt A0 view missing AI verification blocker';
  END IF;

  RAISE NOTICE 'RN0-T13 PASS — rebuild preserves real N0 A0 state, sources, maturity and N2 routing';
END
$rn0rebuild$;
