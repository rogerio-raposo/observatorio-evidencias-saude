-- OES Fase 3 — Real N3-01 tests, part A
-- Requires migration 014 + f3-real-case-n3-ambient-ai-scribes.sql.

-- RN3-T01 — identity is N3/M1 under review at A0.
DO $t01$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF v#>>'{identity,product_id}' <> 'OES-P-2026-000701'
     OR v#>>'{identity,product_type}' <> 'rapid_evidence_synthesis'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{investigation,depth_level}' <> 'N3'
     OR v#>>'{investigation,maintenance_level}' <> 'M1'
     OR v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
  THEN
    RAISE EXCEPTION 'RN3-T01 FAIL: identity/N3/A0 state mismatch';
  END IF;
  RAISE NOTICE 'RN3-T01 PASS — real N3 is M1/A0/under_review/non-publishable';
END
$t01$;

-- RN3-T02 — scientific/methodological core is structurally complete.
DO $t02$
DECLARE bad_count integer;
BEGIN
  SELECT count(*) INTO bad_count
  FROM product.rapid_evidence_synthesis_publication_issues(
    'e1000000-0000-0000-0000-000000000701'
  )
  WHERE issue_code IN (
    'MISSING_PROTOCOL','MISSING_SEARCH_RECORD',
    'INSUFFICIENT_SEARCH_SOURCE_COVERAGE','MISSING_RAPID_METHOD_RESTRICTION',
    'OPEN_PROTOCOL_DEVIATION','MISSING_SELECTION_FLOW',
    'MISSING_RISK_ASSESSMENT','MISSING_SYNTHESIS',
    'MISSING_CERTAINTY_ASSESSMENT','MISSING_TRACEABLE_SOURCE',
    'MISSING_LIMITATIONS','MISSING_CURRENCY_STATE',
    'MISSING_SUMMARY_OF_FINDINGS_DECISION'
  );
  IF bad_count <> 0 THEN
    RAISE EXCEPTION 'RN3-T02 FAIL: scientific-core blockers remain: %', bad_count;
  END IF;
  RAISE NOTICE 'RN3-T02 PASS — protocol/search/selection/appraisal/synthesis/certainty/SoF core complete';
END
$t02$;

-- RN3-T03 — six qualified-human control gaps remain explicit.
DO $t03$
DECLARE expected text[] := ARRAY[
  'MISSING_SEARCH_STRATEGY_VERIFICATION',
  'MISSING_SCREENING_PILOT',
  'MISSING_QUALIFIED_SCREENING_VERIFICATION',
  'MISSING_QUALIFIED_DATA_VERIFICATION',
  'MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION',
  'MISSING_QUALIFIED_CERTAINTY_VERIFICATION'
];
DECLARE code text;
DECLARE n integer;
BEGIN
  FOREACH code IN ARRAY expected LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM product.rapid_evidence_synthesis_missing_controls(
        'e1000000-0000-0000-0000-000000000701'
      )
      WHERE control_code=code
    ) THEN
      RAISE EXCEPTION 'RN3-T03 FAIL: expected missing control % absent', code;
    END IF;
  END LOOP;
  SELECT count(*) INTO n
  FROM product.rapid_evidence_synthesis_missing_controls(
    'e1000000-0000-0000-0000-000000000701'
  );
  IF n <> 6 THEN
    RAISE EXCEPTION 'RN3-T03 FAIL: expected exactly six missing qualified controls, found %', n;
  END IF;
  IF EXISTS (
    SELECT 1
    FROM product.rapid_evidence_synthesis_missing_controls(
      'e1000000-0000-0000-0000-000000000701'
    )
    WHERE control_code='MISSING_REQUIRED_STATISTICAL_REVIEW'
  ) THEN
    RAISE EXCEPTION 'RN3-T03 FAIL: narrative synthesis incorrectly requires statistical review';
  END IF;
  RAISE NOTICE 'RN3-T03 PASS — six qualified-human controls missing; no false statistical-review requirement';
END
$t03$;

-- RN3-T04 — A0 governance blockers are explicit.
DO $t04$
DECLARE expected text[] := ARRAY[
  'MISSING_AI_METHODOLOGICAL_VERIFICATION',
  'MISSING_OWNER_APPROVAL',
  'MISSING_EXPERT_INDEPENDENT_REVIEW',
  'ASSURANCE_BELOW_A3',
  'MISSING_PUBLICATION_DATE'
];
DECLARE code text;
BEGIN
  FOREACH code IN ARRAY expected LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'e1000000-0000-0000-0000-000000000701'
      )
      WHERE issue_code=code AND severity='error'
    ) THEN
      RAISE EXCEPTION 'RN3-T04 FAIL: governance blocker % absent', code;
    END IF;
  END LOOP;
  RAISE NOTICE 'RN3-T04 PASS — A0/owner/expert/A3/publication blockers explicit';
END
$t04$;

-- RN3-T05 — Europe PMC deviation is visible and mitigated.
DO $t05$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF v#>>'{audit,protocol_deviations_open}' <> 'false'
     OR jsonb_array_length(v#>'{rapid_method,deviations}') <> 1
  THEN
    RAISE EXCEPTION 'RN3-T05 FAIL: protocol-deviation state mismatch';
  END IF;
  IF NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(v#>'{rapid_method,deviations}') d
    WHERE d->>'code'='EUROPE_PMC_RUNTIME_ACCESS_FAILURE'
      AND d->>'resolution_status'='mitigated'
  ) THEN
    RAISE EXCEPTION 'RN3-T05 FAIL: Europe PMC deviation not projected as mitigated';
  END IF;
  RAISE NOTICE 'RN3-T05 PASS — Europe PMC runtime deviation remains visible and mitigated';
END
$t05$;

-- RN3-T06 — restrictions/searches/selection are explicit; no fake hit counts.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF jsonb_array_length(v#>'{rapid_method,restrictions}') <> 5
     OR jsonb_array_length(v->'searches') <> 2
     OR (v#>>'{selection_flow,search_hits_materialized}')::int <> 10
     OR (v#>>'{selection_flow,screening_decisions}')::int <> 17
  THEN
    RAISE EXCEPTION 'RN3-T06 FAIL: restrictions/search/selection counts mismatch';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'searches') s
    WHERE s->'result_count' <> 'null'::jsonb
  ) THEN
    RAISE EXCEPTION 'RN3-T06 FAIL: unavailable result_count was fabricated';
  END IF;
  RAISE NOTICE 'RN3-T06 PASS — five restrictions, two searches, 10 hits, 17 decisions; result counts NULL';
END
$t06$;

-- RN3-T07 — six used/contextual reports reachable; excluded records do not leak.
DO $t07$
DECLARE v jsonb;
DECLARE n integer;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  SELECT count(*) INTO n
  FROM product.rapid_evidence_synthesis_reference_reports(
    'e1000000-0000-0000-0000-000000000701'
  );
  IF n <> 6 OR jsonb_array_length(v->'references') <> 6
     OR jsonb_array_length(v->'included_evidence') <> 6
  THEN
    RAISE EXCEPTION 'RN3-T07 FAIL: expected six used/contextual reports, found %', n;
  END IF;
  IF EXISTS (
    SELECT 1
    FROM product.rapid_evidence_synthesis_reference_reports(
      'e1000000-0000-0000-0000-000000000701'
    )
    WHERE report_id IN (
      'OES-RP-2026-000707','OES-RP-2026-000708',
      'OES-RP-2026-000709','OES-RP-2026-000710'
    )
  ) THEN
    RAISE EXCEPTION 'RN3-T07 FAIL: excluded report leaked into product references';
  END IF;
  RAISE NOTICE 'RN3-T07 PASS — six used reports traceable; excluded records remain outside references';
END
$t07$;

-- RN3-T08 — heterogeneous units/comparators are preserved.
DO $t08$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000701'
  ) INTO v;
  IF jsonb_array_length(v->'results') <> 11 THEN
    RAISE EXCEPTION 'RN3-T08 FAIL: expected 11 structured Results';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v->'results') r WHERE r->>'unit'='percent')
     OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v->'results') r WHERE r->>'unit'='hours/day')
     OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v->'results') r WHERE r->>'unit'='minutes/day')
  THEN
    RAISE EXCEPTION 'RN3-T08 FAIL: heterogeneous units not preserved';
  END IF;
  RAISE NOTICE 'RN3-T08 PASS — 11 Results preserve study-specific units';
END
$t08$;
