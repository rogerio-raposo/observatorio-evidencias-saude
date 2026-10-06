-- OES Fase 3 — Real N3-01 revision 01 rebuild assertion
DO $rn3r1$
DECLARE v jsonb;
DECLARE missing_n integer;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;

  SELECT count(*) INTO missing_n
  FROM product.rapid_evidence_synthesis_missing_controls(
    'e1000000-0000-0000-0000-000000000702'
  );

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-000701'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{investigation,depth_level}' <> 'N3'
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR jsonb_array_length(v->'searches') <> 3
     OR (v#>>'{selection_flow,search_hits_materialized}')::int <> 20
     OR (v#>>'{selection_flow,screening_decisions}')::int <> 34
     OR jsonb_array_length(v->'references') <> 13
     OR jsonb_array_length(v->'results') <> 11
     OR jsonb_array_length(v->'risk_of_bias') <> 10
     OR jsonb_array_length(v->'syntheses') <> 4
     OR jsonb_array_length(v->'certainty') <> 4
     OR jsonb_array_length(v->'quality_controls') <> 6
     OR missing_n <> 6
  THEN
    RAISE EXCEPTION 'RN3-R1-T10 FAIL: rebuilt corrected N3 ProductVersion 2 invalid';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='e1000000-0000-0000-0000-000000000701'
      AND decision='revise'
  ) THEN
    RAISE EXCEPTION 'RN3-R1-T10 FAIL: first adversarial REVISE history lost';
  END IF;

  RAISE NOTICE 'RN3-R1-T10 PASS — rebuild preserves corrected v2 and v1 REVISE history';
END
$rn3r1$;
