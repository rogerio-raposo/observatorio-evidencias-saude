-- OES Fase 3 — Real N3-01 second adversarial REVISE rebuild assertion
DO $rn3adv2$
DECLARE v jsonb;
DECLARE revise_n integer;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;

  SELECT count(*) INTO revise_n
  FROM product.assurance_record
  WHERE assurance_type='ai_methodological_verification'
    AND decision='revise'
    AND product_version_uuid IN (
      'e1000000-0000-0000-0000-000000000701',
      'e1000000-0000-0000-0000-000000000702'
    )
    AND status='active';

  IF v IS NULL
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR jsonb_array_length(v->'references') <> 13
     OR jsonb_array_length(v->'results') <> 11
     OR jsonb_array_length(v->'certainty') <> 4
     OR revise_n <> 2
  THEN
    RAISE EXCEPTION 'RN3-ADV2-T06 FAIL: rebuild lost revised A0 state or history';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(v#>'{audit,publication_issues}') i
    WHERE i->>'issue_code'='MISSING_AI_METHODOLOGICAL_VERIFICATION'
  ) THEN
    RAISE EXCEPTION 'RN3-ADV2-T06 FAIL: AI verification blocker missing after rebuild';
  END IF;

  RAISE NOTICE 'RN3-ADV2-T06 PASS — rebuild preserves v2 A0 and both adversarial REVISE decisions';
END
$rn3adv2$;
