-- OES Fase 3 — Real N0-01 contract tests
-- Requires f3-real-case-n0-genai-mental-health.sql.

-- RN0-T01 — identity/routing state is real N0 under review.
DO $t01$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{identity,product_id}' <> 'OES-P-2026-000601'
     OR v#>>'{identity,editorial_status}' <> 'under_review'
     OR v#>>'{investigation,depth_level}' <> 'N0'
     OR v#>>'{investigation,maintenance_level}' <> 'M0'
  THEN
    RAISE EXCEPTION 'RN0-T01 FAIL: identity/routing mismatch';
  END IF;
  RAISE NOTICE 'RN0-T01 PASS — real N0 identity and routing preserved';
END
$t01$;

-- RN0-T02 — real case remains A0 and non-publishable.
DO $t02$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{audit,assurance_level}' <> 'A0'
     OR v#>>'{audit,publishable}' <> 'false'
  THEN
    RAISE EXCEPTION 'RN0-T02 FAIL: expected A0/non-publishable';
  END IF;
  RAISE NOTICE 'RN0-T02 PASS — real N0 remains A0/non-publishable';
END
$t02$;

-- RN0-T03 — expected A0 blockers are explicit.
DO $t03$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION' AND severity='error'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_OWNER_APPROVAL' AND severity='error'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='MISSING_PUBLICATION_DATE' AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RN0-T03 FAIL: expected A0 blockers missing';
  END IF;
  RAISE NOTICE 'RN0-T03 PASS — AI/owner/publication blockers explicit';
END
$t03$;

-- RN0-T04 — transparency warnings are explicit.
DO $t04$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW' AND severity='warning'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='FIELD_TERMINOLOGY_UNSTABLE' AND severity='warning'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='APPARENT_EVIDENCE_GAP' AND severity='warning'
  ) OR NOT EXISTS (
    SELECT 1 FROM product.evidence_scan_publication_issues('c1000000-0000-0000-0000-000000000301')
    WHERE issue_code='ROUTING_REQUIRES_REFORMULATION' AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'RN0-T04 FAIL: expected transparency warnings missing';
  END IF;
  RAISE NOTICE 'RN0-T04 PASS — no-expert/terminology/gap/reformulation warnings explicit';
END
$t04$;

-- RN0-T05 — six central sources are traceable.
DO $t05$
DECLARE v jsonb; n integer;
BEGIN
  SELECT count(*) INTO n
  FROM product.evidence_scan_reference_reports('c1000000-0000-0000-0000-000000000301');

  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;

  IF n <> 6
     OR jsonb_array_length(v->'central_sources') <> 6
     OR jsonb_array_length(v->'references') <> 6
  THEN
    RAISE EXCEPTION 'RN0-T05 FAIL: expected six central reports';
  END IF;
  RAISE NOTICE 'RN0-T05 PASS — six central reports projected and traceable';
END
$t05$;

-- RN0-T06 — maturity is partially_synthesized and explicitly preliminary.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{maturity,category}' <> 'partially_synthesized'
     OR v#>>'{maturity,confidence_qualifier}' <> 'preliminary'
  THEN
    RAISE EXCEPTION 'RN0-T06 FAIL: maturity mismatch';
  END IF;
  RAISE NOTICE 'RN0-T06 PASS — maturity projected as partially_synthesized/preliminary';
END
$t06$;

-- RN0-T07 — routing recommends N2 and requires reformulation.
DO $t07$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{routing_recommendation,recommendation,target}' <> 'N2'
     OR v#>>'{routing_recommendation,recommendation,requires_question_reformulation}' <> 'true'
     OR btrim(coalesce(v#>>'{routing_recommendation,rationale,text}','')) = ''
  THEN
    RAISE EXCEPTION 'RN0-T07 FAIL: N2/reformulation routing mismatch';
  END IF;
  RAISE NOTICE 'RN0-T07 PASS — N2 routing with question reformulation is explicit';
END
$t07$;

-- RN0-T08 — exploratory searches and materialized hits are projected.
DO $t08$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF jsonb_array_length(v#>'{method,searches}') <> 2 THEN
    RAISE EXCEPTION 'RN0-T08 FAIL: expected two searches';
  END IF;
  IF NOT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(v#>'{method,searches}') s
    WHERE (s->>'materialized_hit_count')::int >= 3
  ) THEN
    RAISE EXCEPTION 'RN0-T08 FAIL: resolved search hits not projected';
  END IF;
  RAISE NOTICE 'RN0-T08 PASS — two exploratory searches and resolved hits projected';
END
$t08$;

-- RN0-T09 — controversies, gaps and candidate questions are preserved.
DO $t09$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF jsonb_array_length(v->'controversies') <> 3
     OR jsonb_array_length(v->'gaps') <> 3
     OR jsonb_array_length(v->'candidate_questions') <> 3
  THEN
    RAISE EXCEPTION 'RN0-T09 FAIL: exploratory components mismatch';
  END IF;
  RAISE NOTICE 'RN0-T09 PASS — controversies/gaps/candidate questions projected';
END
$t09$;

-- RN0-T10 — N0 does not fabricate deeper scientific objects.
DO $t10$
BEGIN
  IF EXISTS (
    SELECT 1 FROM product.synthesis_link
    WHERE product_version_uuid='c1000000-0000-0000-0000-000000000301'
  ) THEN
    RAISE EXCEPTION 'RN0-T10 FAIL: unexpected Synthesis';
  END IF;
  IF EXISTS (
    SELECT 1 FROM product.certainty_link
    WHERE product_version_uuid='c1000000-0000-0000-0000-000000000301'
  ) THEN
    RAISE EXCEPTION 'RN0-T10 FAIL: unexpected CertaintyAssessment';
  END IF;
  IF EXISTS (
    SELECT 1 FROM appraisal.risk_assessment_version
    WHERE investigation_version_uuid='c1000000-0000-0000-0000-000000000002'
  ) THEN
    RAISE EXCEPTION 'RN0-T10 FAIL: unexpected formal RiskAssessment';
  END IF;
  RAISE NOTICE 'RN0-T10 PASS — no Synthesis/Certainty/RiskAssessment fabricated';
END
$t10$;

-- RN0-T11 — scope boundary distinguishes GenAI-specific and contextual chatbot evidence.
DO $t11$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(v->'central_sources') s
    WHERE s->>'report_id'='OES-RP-2026-000606'
      AND s#>>'{component,role}'='contextual'
  ) THEN
    RAISE EXCEPTION 'RN0-T11 FAIL: CBT chatbot boundary source not contextual';
  END IF;
  RAISE NOTICE 'RN0-T11 PASS — broader CBT chatbot evidence remains contextual, not GenAI-equivalent';
END
$t11$;

-- RN0-T12 — conclusion/cutoff and mixed traceable basis are coherent.
DO $t12$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_scan_view('c1000000-0000-0000-0000-000000000301') INTO v;
  IF v#>>'{identity,evidence_cutoff_date}' <> '2026-10-05'
     OR v#>>'{audit,traceable_basis_type}' <> 'mixed'
     OR position('parcialmente sintetizado' in lower(v#>>'{conclusion,text}'))=0
  THEN
    RAISE EXCEPTION 'RN0-T12 FAIL: cutoff/conclusion/traceable basis mismatch';
  END IF;
  RAISE NOTICE 'RN0-T12 PASS — cutoff, exploratory conclusion and mixed provenance basis coherent';
END
$t12$;
