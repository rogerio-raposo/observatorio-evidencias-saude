-- OES Real Case 01 — dCBT-I Evidence Sheet runtime tests
BEGIN;

-- RC01-T01 — scientific identity and routing.
DO $t01$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM investigation.investigation_version
        WHERE version_uuid='81000000-0000-0000-0000-000000000002'
          AND depth_level='N2'
          AND maintenance_level='M1'
          AND evidence_cutoff_date=DATE '2026-10-04'
    ) THEN
        RAISE EXCEPTION 'RC01-T01 FAIL: Investigation routing/cutoff incorrect';
    END IF;
    RAISE NOTICE 'RC01-T01 PASS — N2/M1 routing and cutoff preserved';
END
$t01$;

-- RC01-T02 — Hwang is a systematic-review Study; update RCTs are primary Studies.
DO $t02$
DECLARE sr integer; prim integer;
BEGIN
    SELECT count(*) INTO sr
    FROM evidence.study_version
    WHERE version_uuid IN (
      '81000000-0000-0000-0000-000000000010',
      '81000000-0000-0000-0000-000000000011',
      '81000000-0000-0000-0000-000000000012',
      '81000000-0000-0000-0000-000000000013',
      '81000000-0000-0000-0000-000000000014'
    )
      AND study_type='systematic_review';

    SELECT count(*) INTO prim
    FROM evidence.study_version
    WHERE version_uuid IN (
      '81000000-0000-0000-0000-000000000010',
      '81000000-0000-0000-0000-000000000011',
      '81000000-0000-0000-0000-000000000012',
      '81000000-0000-0000-0000-000000000013',
      '81000000-0000-0000-0000-000000000014'
    )
      AND study_type='primary_study';

    IF sr<>1 OR prim<>4 THEN
      RAISE EXCEPTION 'RC01-T02 FAIL: systematic reviews %, primary studies %',sr,prim;
    END IF;
    RAISE NOTICE 'RC01-T02 PASS — 1 systematic review + 4 primary Studies';
END
$t02$;

-- RC01-T03 — adopted external synthesis and OES update remain distinct.
DO $t03$
BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM synthesis.synthesis_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000050'
        AND synthesis_origin='adopted_external'
        AND result_summary->>'recalculated_by_oes'='false'
    ) OR NOT EXISTS (
      SELECT 1 FROM synthesis.synthesis_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000051'
        AND synthesis_origin='oes_update'
        AND model='no_new_pooling'
        AND result_summary->>'pooled_by_oes'='false'
    ) THEN
      RAISE EXCEPTION 'RC01-T03 FAIL: adopted/update synthesis semantics invalid';
    END IF;
    RAISE NOTICE 'RC01-T03 PASS — adopted external synthesis separated from OES update';
END
$t03$;

-- RC01-T04 — only OES update is directly linked as Product priority synthesis.
DO $t04$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
    FROM product.synthesis_link
    WHERE product_version_uuid='81000000-0000-0000-0000-000000000070';

    IF n<>1 OR NOT EXISTS (
      SELECT 1 FROM product.synthesis_link
      WHERE product_version_uuid='81000000-0000-0000-0000-000000000070'
        AND synthesis_version_uuid='81000000-0000-0000-0000-000000000051'
        AND role='primary'
    ) THEN
      RAISE EXCEPTION 'RC01-T04 FAIL: Product synthesis linkage invalid';
    END IF;
    RAISE NOTICE 'RC01-T04 PASS — only OES update is Product priority synthesis';
END
$t04$;

-- RC01-T05 — provisional GRADE = moderate with one downgrade for risk of bias.
DO $t05$
BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM appraisal.certainty_assessment_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000060'
        AND framework='GRADE'
        AND initial_level='high'
        AND final_level='moderate'
        AND status='draft'
    ) OR NOT EXISTS (
      SELECT 1 FROM appraisal.certainty_domain
      WHERE certainty_assessment_version_uuid='81000000-0000-0000-0000-000000000060'
        AND domain_code='risk_of_bias'
        AND downgrade_steps=1
    ) THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: provisional GRADE invalid';
    END IF;
    RAISE NOTICE 'RC01-T05 PASS — provisional GRADE moderate, pending human review';
END
$t05$;

-- RC01-T06 — five risk assessments are present and all await human verification.
DO $t06$
DECLARE n integer; pending integer;
BEGIN
    SELECT count(*),count(*) FILTER(WHERE verification_status='pending_human_review')
      INTO n,pending
    FROM appraisal.risk_assessment_version
    WHERE investigation_version_uuid='81000000-0000-0000-0000-000000000002';

    IF n<>5 OR pending<>5 THEN
      RAISE EXCEPTION 'RC01-T06 FAIL: assessments %, pending %',n,pending;
    END IF;
    RAISE NOTICE 'RC01-T06 PASS — ROBIS/RoB2 appraisals explicitly pending human review';
END
$t06$;

-- RC01-T07 — EvidenceSheetView has 5 evidence units split 4+1.
DO $t07$
DECLARE v jsonb; prim integer; sr integer;
BEGIN
    SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000070'
    ) INTO v;

    SELECT COALESCE((x->>'count')::integer,0) INTO prim
    FROM jsonb_array_elements(v#>'{evidence_base,study_type_counts}') x
    WHERE x->>'study_type'='primary_study';

    SELECT COALESCE((x->>'count')::integer,0) INTO sr
    FROM jsonb_array_elements(v#>'{evidence_base,study_type_counts}') x
    WHERE x->>'study_type'='systematic_review';

    IF (v#>>'{evidence_base,study_count}')::integer<>5
       OR prim<>4 OR sr<>1 THEN
      RAISE EXCEPTION 'RC01-T07 FAIL: evidence units %, primary %, review %',
        v#>>'{evidence_base,study_count}',prim,sr;
    END IF;
    RAISE NOTICE 'RC01-T07 PASS — EvidenceSheetView exposes 5 units: 4 primary + 1 review';
END
$t07$;

-- RC01-T08 — provenance-aware references include five contributing reports plus Gao.
DO $t08$
DECLARE v jsonb; n integer;
BEGIN
    SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000070'
    ) INTO v;

    SELECT jsonb_array_length(v->'references') INTO n;

    IF n<>6 THEN
      RAISE EXCEPTION 'RC01-T08 FAIL: expected 6 references, got %',n;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v->'references') r
      WHERE r->>'report_id'='OES-RP-2026-000115'
    ) THEN
      RAISE EXCEPTION 'RC01-T08 FAIL: Gao provenance-only reference missing';
    END IF;

    RAISE NOTICE 'RC01-T08 PASS — six references include Gao via provenance';
END
$t08$;

-- RC01-T09 — priority result is OES update, not external adopted synthesis.
DO $t09$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000070'
    ) INTO v;

    IF jsonb_array_length(v->'priority_results')<>1
       OR v#>>'{priority_results,0,synthesis,synthesis_id}'<>'OES-SY-2026-000111'
       OR v#>>'{priority_results,0,synthesis,synthesis_origin}'<>'oes_update'
       OR v#>>'{priority_results,0,synthesis,result_summary,pooled_by_oes}'<>'false'
       OR v#>>'{priority_results,0,synthesis,result_summary,reported_study_count}'<>'10'
    THEN
      RAISE EXCEPTION 'RC01-T09 FAIL: priority result semantics invalid %',v->'priority_results';
    END IF;

    RAISE NOTICE 'RC01-T09 PASS — OES narrative update is sole priority result; no pooling claimed';
END
$t09$;

-- RC01-T10 — certainty is visible as provisional moderate.
DO $t10$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000070'
    ) INTO v;

    IF v#>>'{priority_results,0,certainty,framework}'<>'GRADE'
       OR v#>>'{priority_results,0,certainty,final_level}'<>'moderate'
    THEN
      RAISE EXCEPTION 'RC01-T10 FAIL: certainty projection invalid';
    END IF;

    RAISE NOTICE 'RC01-T10 PASS — provisional moderate GRADE projected';
END
$t10$;

-- RC01-T11 — Product remains under review and deliberately non-publishable.
DO $t11$
DECLARE v jsonb; errors integer;
BEGIN
    SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000070'
    ) INTO v;

    SELECT count(*) INTO errors
    FROM product.evidence_sheet_publication_issues(
      '81000000-0000-0000-0000-000000000070'
    )
    WHERE severity='error';

    IF v#>>'{identity,editorial_status}'<>'under_review'
       OR v#>>'{audit,publishable}'<>'false'
       OR errors<2 THEN
      RAISE EXCEPTION 'RC01-T11 FAIL: review/gate state invalid; errors %',errors;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM product.evidence_sheet_publication_issues(
        '81000000-0000-0000-0000-000000000070'
      )
      WHERE issue_code='MISSING_APPROVED_REVIEW'
    ) THEN
      RAISE EXCEPTION 'RC01-T11 FAIL: MISSING_APPROVED_REVIEW not exposed';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM product.evidence_sheet_publication_issues(
        '81000000-0000-0000-0000-000000000070'
      )
      WHERE issue_code='MISSING_PUBLICATION_DATE'
    ) THEN
      RAISE EXCEPTION 'RC01-T11 FAIL: MISSING_PUBLICATION_DATE not exposed';
    END IF;

    RAISE NOTICE 'RC01-T11 PASS — under_review product correctly blocked by publication gate';
END
$t11$;

-- RC01-T12 — no fabricated human approval exists.
DO $t12$
BEGIN
    IF EXISTS (
      SELECT 1 FROM product.review_record
      WHERE product_version_uuid='81000000-0000-0000-0000-000000000070'
        AND status='active'
        AND decision='approved'
    ) THEN
      RAISE EXCEPTION 'RC01-T12 FAIL: fabricated approved human review found';
    END IF;

    RAISE NOTICE 'RC01-T12 PASS — no approved human review fabricated';
END
$t12$;

-- RC01-T13 — lineage reaches Product through update/certainty.
DO $t13$
DECLARE n integer;
BEGIN
  WITH RECURSIVE c AS (
    SELECT target_version_uuid,1 depth,ARRAY[source_version_uuid,target_version_uuid]::uuid[] path
    FROM provenance.dependency_edge
    WHERE source_version_uuid='81000000-0000-0000-0000-000000000050'
      AND status='active'
    UNION ALL
    SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
    FROM c JOIN provenance.dependency_edge d ON d.source_version_uuid=c.target_version_uuid
    WHERE d.status='active' AND c.depth<16 AND NOT d.target_version_uuid=ANY(c.path)
  )
  SELECT count(*) INTO n FROM c
  WHERE target_version_uuid='81000000-0000-0000-0000-000000000070';

  IF n<1 THEN
    RAISE EXCEPTION 'RC01-T13 FAIL: adopted synthesis lineage does not reach Product';
  END IF;

  RAISE NOTICE 'RC01-T13 PASS — adopted synthesis lineage reaches Product via OES update/certainty';
END
$t13$;

ROLLBACK;
