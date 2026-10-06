-- OES Fase 3 — Real N3-01 rebuild assertion
DO $rn3rebuild$
DECLARE v jsonb;
DECLARE missing_n integer;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;

  SELECT count(*) INTO missing_n
  FROM product.rapid_evidence_synthesis_missing_controls(
    'e1000000-0000-0000-0000-000000000701'
  );

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000701'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{investigation,depth_level}' <> 'N3'
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{audit,qualified_controls_satisfied}' <> 'false'
     OR jsonb_array_length(v->'references') <> 6
     OR jsonb_array_length(v->'results') <> 11
     OR jsonb_array_length(v->'risk_of_bias') <> 10
     OR jsonb_array_length(v->'syntheses') <> 4
     OR jsonb_array_length(v->'certainty') <> 4
     OR jsonb_array_length(v->'quality_controls') <> 6
     OR missing_n <> 6
  THEN
    RAISE EXCEPTION 'RN3-T16 FAIL: rebuilt real N3 experimental state invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='MISSING_EXPERT_INDEPENDENT_REVIEW'
  ) OR NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='ASSURANCE_BELOW_A3'
  ) THEN
    RAISE EXCEPTION 'RN3-T16 FAIL: formal N3 governance blockers missing after rebuild';
  END IF;

  RAISE NOTICE 'RN3-T16 PASS — rebuild preserves complete experimental A0 N3 with qualified-human/A3 blockers';
END
$rn3rebuild$;
