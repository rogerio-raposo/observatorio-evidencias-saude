-- OES Fase 3 — Real N3-01 second adversarial REVISE tests

DO $a2r1$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='e1000000-0000-0000-0000-000000000702'
      AND assurance_type='ai_methodological_verification'
      AND actor='OES_AI_METHOD_VERIFICATION_N3_PASS_2'
      AND actor_type='ai_system'
      AND independent_flag=false
      AND decision='revise'
      AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN3-ADV2-T01 FAIL: second REVISE not materialized on ProductVersion 2';
  END IF;
  RAISE NOTICE 'RN3-ADV2-T01 PASS — second adversarial REVISE materialized on v2';
END
$a2r1$;

DO $a2r2$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n
  FROM product.assurance_record
  WHERE assurance_type='ai_methodological_verification'
    AND decision='revise'
    AND product_version_uuid IN (
      'e1000000-0000-0000-0000-000000000701',
      'e1000000-0000-0000-0000-000000000702'
    )
    AND status='active';

  IF n <> 2 THEN
    RAISE EXCEPTION 'RN3-ADV2-T02 FAIL: expected two preserved REVISE records, found %', n;
  END IF;
  RAISE NOTICE 'RN3-ADV2-T02 PASS — both adversarial REVISE decisions preserved';
END
$a2r2$;

DO $a2r3$
BEGIN
  IF product.rapid_evidence_synthesis_assurance_level(
       'e1000000-0000-0000-0000-000000000702'
     ) <> 'A0'
  THEN
    RAISE EXCEPTION 'RN3-ADV2-T03 FAIL: revise incorrectly elevated assurance';
  END IF;

  IF product.rapid_evidence_synthesis_is_publishable(
       'e1000000-0000-0000-0000-000000000702'
     )
  THEN
    RAISE EXCEPTION 'RN3-ADV2-T03 FAIL: revised N3 incorrectly became publishable';
  END IF;

  RAISE NOTICE 'RN3-ADV2-T03 PASS — v2 remains A0 and non-publishable';
END
$a2r3$;

DO $a2r4$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;

  IF jsonb_array_length(v->'results') <> 11
     OR jsonb_array_length(v->'risk_of_bias') <> 10
     OR jsonb_array_length(v->'syntheses') <> 4
     OR jsonb_array_length(v->'certainty') <> 4
     OR jsonb_array_length(v->'references') <> 13
  THEN
    RAISE EXCEPTION 'RN3-ADV2-T04 FAIL: second adversarial review altered scientific content';
  END IF;

  RAISE NOTICE 'RN3-ADV2-T04 PASS — scientific content unchanged by governance review';
END
$a2r4$;

DO $a2r5$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM product.rapid_evidence_synthesis_publication_issues(
      'e1000000-0000-0000-0000-000000000702'
    )
    WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN3-ADV2-T05 FAIL: AI verification blocker disappeared after REVISE';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM product.rapid_evidence_synthesis_publication_issues(
      'e1000000-0000-0000-0000-000000000702'
    )
    WHERE issue_code='ASSURANCE_BELOW_A3'
      AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN3-ADV2-T05 FAIL: A3 blocker missing';
  END IF;

  RAISE NOTICE 'RN3-ADV2-T05 PASS — AI-verification and A3 blockers remain explicit';
END
$a2r5$;
