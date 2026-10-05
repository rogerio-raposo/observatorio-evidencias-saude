-- OES Fase 3 — Real N1 Case 01 tests: initial A0 / under_review state

-- RN1-T01 — identity, routing and editorial state.
DO $t01$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  IF v#>>'{identity,product_id}' <> 'OES-P-2026-000501'
     OR v#>>'{identity,product_type}' <> 'evidence_response'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{routing,depth_level}' <> 'N1'
     OR v#>>'{routing,maintenance_level}' <> 'M1' THEN
    RAISE EXCEPTION 'RN1-T01 FAIL: identity/routing state mismatch';
  END IF;
  RAISE NOTICE 'RN1-T01 PASS — real case identity N1/M1 under_review';
END
$t01$;

-- RN1-T02 — initial assurance is A0 and product is not publishable.
DO $t02$
BEGIN
  IF product.evidence_response_assurance_level('a1000000-0000-0000-0000-000000000701') <> 'A0' THEN
    RAISE EXCEPTION 'RN1-T02 FAIL: expected A0';
  END IF;
  IF product.evidence_response_is_publishable('a1000000-0000-0000-0000-000000000701') THEN
    RAISE EXCEPTION 'RN1-T02 FAIL: A0 real case unexpectedly publishable';
  END IF;
  RAISE NOTICE 'RN1-T02 PASS — A0 is blocked';
END
$t02$;

-- RN1-T03 — expected publication blockers are explicit.
DO $t03$
DECLARE missing integer;
BEGIN
  SELECT count(*) INTO missing
  FROM (VALUES
    ('MISSING_PUBLICATION_DATE'),
    ('MISSING_AI_METHODOLOGICAL_VERIFICATION'),
    ('MISSING_OWNER_APPROVAL')
  ) expected(code)
  WHERE NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000701') i
    WHERE i.issue_code=expected.code AND i.severity='error'
  );
  IF missing <> 0 THEN
    RAISE EXCEPTION 'RN1-T03 FAIL: expected publication blocker missing';
  END IF;
  RAISE NOTICE 'RN1-T03 PASS — publication blockers explicit';
END
$t03$;

-- RN1-T04 — expected transparency warnings are explicit.
DO $t04$
DECLARE missing integer;
BEGIN
  SELECT count(*) INTO missing
  FROM (VALUES
    ('NO_EXPERT_INDEPENDENT_REVIEW'),
    ('NO_FORMAL_CERTAINTY'),
    ('SINGLE_SEARCH_SOURCE')
  ) expected(code)
  WHERE NOT EXISTS (
    SELECT 1 FROM product.evidence_response_publication_issues('a1000000-0000-0000-0000-000000000701') i
    WHERE i.issue_code=expected.code AND i.severity='warning'
  );
  IF missing <> 0 THEN
    RAISE EXCEPTION 'RN1-T04 FAIL: expected warning missing';
  END IF;
  RAISE NOTICE 'RN1-T04 PASS — N1 transparency warnings explicit';
END
$t04$;

-- RN1-T05 — seven selected reports are provenance-aware references.
DO $t05$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n FROM product.evidence_response_reference_reports('a1000000-0000-0000-0000-000000000701');
  IF n <> 7 THEN
    RAISE EXCEPTION 'RN1-T05 FAIL: expected 7 traceable reports, got %', n;
  END IF;
  RAISE NOTICE 'RN1-T05 PASS — seven traceable reports';
END
$t05$;

-- RN1-T06 — decisive source has formal ROBIS appraisal and high-risk judgement.
DO $t06$
DECLARE v jsonb; n integer;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  SELECT count(*) INTO n
    FROM appraisal.risk_assessment_version rav
   WHERE rav.investigation_version_uuid='a1000000-0000-0000-0000-000000000002'
     AND rav.target_entity_uuid='a0000000-0000-0000-0000-000000000201'
     AND rav.framework='ROBIS'
     AND rav.overall_judgement='high_risk';
  IF n <> 1 THEN
    RAISE EXCEPTION 'RN1-T06 FAIL: decisive ROBIS missing';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_sources') x
    WHERE x->>'report_id'='OES-RP-2026-000501'
      AND (x->>'formal_appraisal_count')::integer = 1
      AND x->'roles' ? 'decisive'
  ) THEN
    RAISE EXCEPTION 'RN1-T06 FAIL: Stoop source appraisal/role not projected';
  END IF;
  RAISE NOTICE 'RN1-T06 PASS — decisive source appraised and projected';
END
$t06$;

-- RN1-T07 — direct key results are projected without Synthesis.
DO $t07$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  IF EXISTS (SELECT 1 FROM product.synthesis_link WHERE product_version_uuid='a1000000-0000-0000-0000-000000000701') THEN
    RAISE EXCEPTION 'RN1-T07 FAIL: real N1 unexpectedly has Synthesis link';
  END IF;
  IF jsonb_array_length(v->'key_results') <> 3 THEN
    RAISE EXCEPTION 'RN1-T07 FAIL: expected 3 key results';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_results') x
    WHERE x->>'field_path'='key_results.0.effect_estimate'
      AND (x#>>'{source_value,estimate}')::numeric = -0.73
  ) THEN
    RAISE EXCEPTION 'RN1-T07 FAIL: decisive SMD missing';
  END IF;
  RAISE NOTICE 'RN1-T07 PASS — direct key results projected without Synthesis';
END
$t07$;

-- RN1-T08 — no formal CertaintyAssessment is fabricated.
DO $t08$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  IF EXISTS (SELECT 1 FROM product.certainty_link WHERE product_version_uuid='a1000000-0000-0000-0000-000000000701') THEN
    RAISE EXCEPTION 'RN1-T08 FAIL: real N1 unexpectedly has Certainty link';
  END IF;
  IF v#>>'{certainty,formal_assessment}' <> 'false' THEN
    RAISE EXCEPTION 'RN1-T08 FAIL: formal certainty incorrectly projected';
  END IF;
  RAISE NOTICE 'RN1-T08 PASS — formal certainty not fabricated';
END
$t08$;

-- RN1-T09 — transformed NNT remains explicitly non-direct.
DO $t09$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_results') x
    WHERE x->>'field_path'='key_results.2.transformed_nnt'
      AND x#>>'{source_value,type}'='transformed_from_continuous_effect'
      AND x#>>'{source_value,direct_binary_event_nnt}'='false'
  ) THEN
    RAISE EXCEPTION 'RN1-T09 FAIL: transformed NNT semantics lost';
  END IF;
  RAISE NOTICE 'RN1-T09 PASS — transformed NNT semantics preserved';
END
$t09$;

-- RN1-T10 — no owner approval or expert review is inferred.
DO $t10$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.assurance_record ar
    WHERE ar.product_version_uuid='a1000000-0000-0000-0000-000000000701'
      AND ar.assurance_type IN ('owner_governance_approval','expert_independent_review')
  ) THEN
    RAISE EXCEPTION 'RN1-T10 FAIL: governance/expert approval was inferred';
  END IF;
  RAISE NOTICE 'RN1-T10 PASS — no approval inferred';
END
$t10$;

-- RN1-T11 — update evidence remains supporting, not silently pooled.
DO $t11$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'key_sources') x
    WHERE x->>'report_id'='OES-RP-2026-000505' AND x->'roles' ? 'supporting'
  ) THEN
    RAISE EXCEPTION 'RN1-T11 FAIL: post-cutoff RCT not projected as supporting';
  END IF;
  IF jsonb_array_length(v->'key_results') <> 3 THEN
    RAISE EXCEPTION 'RN1-T11 FAIL: post-cutoff RCT was silently converted into pooled key result';
  END IF;
  RAISE NOTICE 'RN1-T11 PASS — update evidence is supporting, not silently pooled';
END
$t11$;

-- RN1-T12 — evidence cutoff and current currency state are coherent.
DO $t12$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_response_view('a1000000-0000-0000-0000-000000000701') INTO v;
  IF v#>>'{identity,evidence_cutoff_date}' <> '2026-10-05'
     OR v#>>'{routing,evidence_cutoff_date}' <> '2026-10-05'
     OR v#>>'{identity,currency_status}' <> 'current' THEN
    RAISE EXCEPTION 'RN1-T12 FAIL: cutoff/currency mismatch';
  END IF;
  RAISE NOTICE 'RN1-T12 PASS — cutoff/current state coherent';
END
$t12$;
