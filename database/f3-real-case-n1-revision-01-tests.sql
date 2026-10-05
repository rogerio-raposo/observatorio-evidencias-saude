-- OES Fase 3 — Real N1-01 revision 01 tests: corrected ProductVersion 2, still A0

-- RN1-R1-T01 — version history is preserved.
DO $t01$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM core.entity_version
    WHERE version_uuid='a1000000-0000-0000-0000-000000000701'
      AND version_no=1 AND version_status='superseded'
  ) OR NOT EXISTS (
    SELECT 1 FROM core.entity_version
    WHERE version_uuid='a1000000-0000-0000-0000-000000000702'
      AND version_no=2 AND version_status='current'
      AND supersedes_version_uuid='a1000000-0000-0000-0000-000000000701'
  ) THEN
    RAISE EXCEPTION 'RN1-R1-T01 FAIL: ProductVersion history not preserved';
  END IF;
  RAISE NOTICE 'RN1-R1-T01 PASS — ProductVersion 2 supersedes version 1';
END
$t01$;

-- RN1-R1-T02 — first adversarial decision is preserved as revise on version 1.
DO $t02$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='a1000000-0000-0000-0000-000000000701'
      AND assurance_type='ai_methodological_verification'
      AND decision='revise' AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN1-R1-T02 FAIL: first revise decision missing';
  END IF;
  RAISE NOTICE 'RN1-R1-T02 PASS — first adversarial revise preserved';
END
$t02$;

-- RN1-R1-T03 — corrected version remains A0/non-publishable before second pass.
DO $t03$
BEGIN
  IF product.evidence_response_assurance_level('a1000000-0000-0000-0000-000000000702') <> 'A0' THEN
    RAISE EXCEPTION 'RN1-R1-T03 FAIL: corrected version should remain A0';
  END IF;
  IF product.evidence_response_is_publishable('a1000000-0000-0000-0000-000000000702') THEN
    RAISE EXCEPTION 'RN1-R1-T03 FAIL: corrected version unexpectedly publishable';
  END IF;
  RAISE NOTICE 'RN1-R1-T03 PASS — corrected version remains A0/blocked';
END
$t03$;

-- RN1-R1-T04 — corrected conclusion separates Stoop and Yu estimates.
DO $t04$
DECLARE c text;
BEGIN
  SELECT conclusion_text INTO c FROM product.product_version
  WHERE version_uuid='a1000000-0000-0000-0000-000000000702';
  IF position('Stoop et al. 2026' in c)=0
     OR position('Yu et al.' in c)=0
     OR position('uma única faixa' in c)=0
     OR position('SMD aproximadamente -0,73' in c)=0
     OR position('SMD -0,50' in c)=0 THEN
    RAISE EXCEPTION 'RN1-R1-T04 FAIL: corrected separate-estimate wording missing';
  END IF;
  RAISE NOTICE 'RN1-R1-T04 PASS — estimates are presented separately';
END
$t04$;

-- RN1-R1-T05 — post-cutoff statement is explicitly selective/non-exhaustive.
DO $t05$
DECLARE c text;
BEGIN
  SELECT conclusion_text INTO c FROM product.product_version
  WHERE version_uuid='a1000000-0000-0000-0000-000000000702';
  IF position('checagem seletiva OES' in c)=0
     OR position('não pretende completude' in c)=0 THEN
    RAISE EXCEPTION 'RN1-R1-T05 FAIL: selective update qualification missing';
  END IF;
  RAISE NOTICE 'RN1-R1-T05 PASS — post-cutoff claim correctly qualified';
END
$t05$;

-- RN1-R1-T06 — key results remain separate and provenance-aware.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;
  IF jsonb_array_length(v->'key_results') <> 3 THEN
    RAISE EXCEPTION 'RN1-R1-T06 FAIL: expected 3 key results';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_results') x
    WHERE x->>'field_path'='key_results.0.effect_estimate'
      AND (x#>>'{source_value,estimate}')::numeric=-0.73
  ) OR NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_results') x
    WHERE x->>'field_path'='key_results.1.effect_estimate'
      AND (x#>>'{source_value,estimate}')::numeric=-0.50
  ) THEN
    RAISE EXCEPTION 'RN1-R1-T06 FAIL: source-specific estimates missing';
  END IF;
  RAISE NOTICE 'RN1-R1-T06 PASS — source-specific key results preserved';
END
$t06$;

-- RN1-R1-T07 — current view references seven reports and formal ROBIS.
DO $t07$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000702') INTO v;
  IF jsonb_array_length(v->'key_sources') <> 7
     OR jsonb_array_length(v->'references') <> 7 THEN
    RAISE EXCEPTION 'RN1-R1-T07 FAIL: traceable report count changed';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_sources') x
    WHERE x->>'report_id'='OES-RP-2026-000501'
      AND (x->>'formal_appraisal_count')::integer=1
  ) THEN
    RAISE EXCEPTION 'RN1-R1-T07 FAIL: decisive ROBIS not projected';
  END IF;
  RAISE NOTICE 'RN1-R1-T07 PASS — references and ROBIS preserved';
END
$t07$;

-- RN1-R1-T08 — publication blockers remain correct.
DO $t08$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION' AND severity='error'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_OWNER_APPROVAL' AND severity='error'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000702')
    WHERE issue_code='MISSING_PUBLICATION_DATE' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN1-R1-T08 FAIL: corrected A0 gate blockers missing';
  END IF;
  RAISE NOTICE 'RN1-R1-T08 PASS — A0 gate blockers preserved';
END
$t08$;
