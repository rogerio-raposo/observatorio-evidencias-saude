-- OES Fase 3 — Rapid Evidence Synthesis N3 rebuild assertion
DO $rsrebuild$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
           'd1000000-0000-0000-0000-000000000601'
         )
    INTO v;

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-001101'
     OR v#>>'{identity,product_type}' <> 'rapid_evidence_synthesis'
     OR v#>>'{investigation,depth_level}' <> 'N3'
     OR v#>>'{audit,assurance_level}' <> 'A2'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{audit,qualified_controls_satisfied}' <> 'false'
     OR jsonb_array_length(v#>'{audit,missing_controls}') <> 6
     OR jsonb_array_length(v#>'{rapid_method,restrictions}') <> 3
     OR jsonb_array_length(v->'included_evidence') <> 2
     OR jsonb_array_length(v->'risk_of_bias') <> 2
     OR jsonb_array_length(v->'syntheses') <> 1
     OR jsonb_array_length(v->'certainty') <> 1
  THEN
    RAISE EXCEPTION 'RS-T15 FAIL: rebuilt N3 experimental view invalid';
  END IF;

  IF product.rapid_evidence_synthesis_is_publishable(
       'd1000000-0000-0000-0000-000000000601'
     )
  THEN
    RAISE EXCEPTION 'RS-T15 FAIL: rebuilt A2 experimental N3 became publishable';
  END IF;

  RAISE NOTICE 'RS-T15 PASS — rebuild preserves complete-but-blocked A2 N3 experimental state';
END
$rsrebuild$;
