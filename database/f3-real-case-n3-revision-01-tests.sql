-- OES Fase 3 — Real N3-01 revision 01 tests

DO $r1$
DECLARE v jsonb;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM core.entity_version
    WHERE version_uuid='e1000000-0000-0000-0000-000000000701'
      AND version_status='superseded'
  ) OR NOT EXISTS (
    SELECT 1 FROM core.entity_version
    WHERE version_uuid='e1000000-0000-0000-0000-000000000702'
      AND version_no=2 AND version_status='current'
      AND supersedes_version_uuid='e1000000-0000-0000-0000-000000000701'
  ) THEN
    RAISE EXCEPTION 'RN3-R1-T01 FAIL: version history invalid';
  END IF;
  RAISE NOTICE 'RN3-R1-T01 PASS — ProductVersion 2 supersedes version 1';
END
$r1$;

DO $r2$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='e1000000-0000-0000-0000-000000000701'
      AND assurance_type='ai_methodological_verification'
      AND decision='revise' AND status='active'
  ) THEN
    RAISE EXCEPTION 'RN3-R1-T02 FAIL: first adversarial REVISE not preserved';
  END IF;
  RAISE NOTICE 'RN3-R1-T02 PASS — first adversarial REVISE preserved';
END
$r2$;

DO $r3$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;
  IF v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
  THEN
    RAISE EXCEPTION 'RN3-R1-T03 FAIL: corrected version must remain A0/under_review/non-publishable';
  END IF;
  RAISE NOTICE 'RN3-R1-T03 PASS — corrected version remains A0/non-publishable';
END
$r3$;

DO $r4$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;
  IF jsonb_array_length(v->'searches') <> 3
     OR (v#>>'{selection_flow,search_hits_materialized}')::int <> 20
     OR (v#>>'{selection_flow,screening_decisions}')::int <> 34
     OR (v#>>'{selection_flow,title_abstract_decisions}')::int <> 20
     OR (v#>>'{selection_flow,full_text_decisions}')::int <> 14
  THEN
    RAISE EXCEPTION 'RN3-R1-T04 FAIL: corrected search/selection flow mismatch';
  END IF;
  RAISE NOTICE 'RN3-R1-T04 PASS — corrected flow is 3 searches / 20 hits / 34 decisions';
END
$r4$;

DO $r5$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;
  IF jsonb_array_length(v->'references') <> 13
     OR jsonb_array_length(v->'included_evidence') <> 13
  THEN
    RAISE EXCEPTION 'RN3-R1-T05 FAIL: expected 13 used/contextual references';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'references') r
    WHERE r->>'report_id'='OES-RP-2026-000711'
  ) OR NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'references') r
    WHERE r->>'report_id'='OES-RP-2026-000712'
  ) OR NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'references') r
    WHERE r->>'report_id'='OES-RP-2026-000713'
  ) THEN
    RAISE EXCEPTION 'RN3-R1-T05 FAIL: corrective contextual references missing';
  END IF;
  RAISE NOTICE 'RN3-R1-T05 PASS — 13 references include corrective review/prospective context';
END
$r5$;

DO $r6$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;
  IF jsonb_array_length(v->'results') <> 11
     OR jsonb_array_length(v->'risk_of_bias') <> 10
     OR jsonb_array_length(v->'syntheses') <> 4
     OR jsonb_array_length(v->'certainty') <> 4
  THEN
    RAISE EXCEPTION 'RN3-R1-T06 FAIL: causal/appraisal/synthesis/grade core changed unexpectedly';
  END IF;
  RAISE NOTICE 'RN3-R1-T06 PASS — effect/appraisal/synthesis/GRADE core unchanged';
END
$r6$;

DO $r7$
DECLARE v jsonb;
DECLARE low_n integer;
DECLARE very_low_n integer;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;
  SELECT count(*) INTO low_n FROM jsonb_array_elements(v->'certainty') c WHERE c->>'final_level'='low';
  SELECT count(*) INTO very_low_n FROM jsonb_array_elements(v->'certainty') c WHERE c->>'final_level'='very_low';
  IF low_n<>3 OR very_low_n<>1 THEN
    RAISE EXCEPTION 'RN3-R1-T07 FAIL: experimental GRADE changed unexpectedly';
  END IF;
  RAISE NOTICE 'RN3-R1-T07 PASS — GRADE remains 3 LOW + 1 VERY LOW';
END
$r7$;

DO $r8$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
    'e1000000-0000-0000-0000-000000000702'
  ) INTO v;
  IF position('expanded PubMed' in v#>>'{rapid_method_limitations,summary}')=0
     OR position('Europe PMC' in v#>>'{rapid_method_limitations,summary}')=0
  THEN
    RAISE EXCEPTION 'RN3-R1-T08 FAIL: corrected search limitation not visible';
  END IF;
  RAISE NOTICE 'RN3-R1-T08 PASS — corrected search coverage and residual limitation disclosed';
END
$r8$;

DO $r9$
BEGIN
  IF product.rapid_evidence_synthesis_assurance_level(
       'e1000000-0000-0000-0000-000000000702'
     ) <> 'A0'
  THEN
    RAISE EXCEPTION 'RN3-R1-T09 FAIL: corrected version received assurance prematurely';
  END IF;
  IF EXISTS (
    SELECT 1 FROM product.assurance_record
    WHERE product_version_uuid='e1000000-0000-0000-0000-000000000702'
  ) THEN
    RAISE EXCEPTION 'RN3-R1-T09 FAIL: assurance record fabricated for version 2';
  END IF;
  RAISE NOTICE 'RN3-R1-T09 PASS — ProductVersion 2 awaits second adversarial verification';
END
$r9$;
