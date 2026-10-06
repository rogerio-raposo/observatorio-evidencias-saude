-- OES Fase 3 — Evidence Review N4 rebuild assertion

DO $er4rebuild$
DECLARE v jsonb;
DECLARE err_n integer;
BEGIN
  SELECT product.evidence_review_view(
    'f1000000-0000-0000-0000-000000000701'
  ) INTO v;

  SELECT count(*) INTO err_n
  FROM product.evidence_review_publication_issues(
    'f1000000-0000-0000-0000-000000000701'
  )
  WHERE severity='error';

  IF v IS NULL
     OR v#>>'{identity,product_id}' <> 'OES-P-2026-001201'
     OR v#>>'{identity,product_type}' <> 'evidence_review'
     OR v#>>'{investigation,depth_level}' <> 'N4'
     OR v->>'subtype' <> 'systematic_review_intervention'
     OR v#>>'{infrastructure_readiness,state}' <> 'ready'
     OR v#>>'{audit,assurance_level}' <> 'A3'
     OR v#>>'{audit,publishable}' <> 'true'
     OR v#>>'{audit,qualified_stage_controls_satisfied}' <> 'true'
     OR jsonb_array_length(v->'searches') <> 3
     OR jsonb_array_length(v->'reviewer_assignments') <> 12
     OR jsonb_array_length(v->'risk_of_bias') <> 2
     OR jsonb_array_length(v->'results') <> 2
     OR jsonb_array_length(v->'syntheses') <> 1
     OR jsonb_array_length(v->'missing_evidence') <> 1
     OR jsonb_array_length(v->'certainty') <> 1
     OR jsonb_array_length(v->'summary_of_findings') <> 1
     OR jsonb_array_length(v->'references') <> 2
     OR err_n <> 0
  THEN
    RAISE EXCEPTION
      'ER4-T26 FAIL: rebuild did not preserve complete synthetic formal N4 state (errors=%)',
      err_n;
  END IF;

  RAISE NOTICE 'ER4-T26 PASS — rebuild preserves formal synthetic A3 N4 contract state';
END
$er4rebuild$;
