-- OES Fase 3 — Real Case 01 validation tests
BEGIN;

-- RC01-T01 — adopted synthesis preserves external origin and no OES recalculation.
DO $t01$
DECLARE rs jsonb;
BEGIN
  SELECT result_summary INTO rs
  FROM synthesis.synthesis_version
  WHERE version_uuid='81000000-0000-0000-0000-000000000501';

  IF NOT EXISTS (
      SELECT 1
      FROM synthesis.synthesis_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000501'
        AND synthesis_origin='adopted_external'
        AND synthesis_type='meta_analysis'
  ) THEN
      RAISE EXCEPTION 'RC01-T01 FAIL: adopted synthesis semantics missing';
  END IF;

  IF rs#>>'{recalculated_by_oes}' <> 'false'
     OR (rs#>>'{reported_study_count}')::integer <> 10
     OR (rs#>>'{effect_value}')::numeric <> -0.93
  THEN
      RAISE EXCEPTION 'RC01-T01 FAIL: adopted result_summary incorrect %',rs;
  END IF;

  RAISE NOTICE 'RC01-T01 PASS — external meta-analysis remains explicitly adopted, not recalculated';
END
$t01$;

-- RC01-T02 — OES update is narrative and all new-study contributions are non-pooled.
DO $t02$
DECLARE n integer; pooled integer;
BEGIN
  SELECT count(*),
         count(*) FILTER (WHERE included_main_analysis)
    INTO n,pooled
  FROM synthesis.contribution
  WHERE synthesis_version_uuid='81000000-0000-0000-0000-000000000503';

  IF n<>4 OR pooled<>0 THEN
      RAISE EXCEPTION 'RC01-T02 FAIL: update contributions %, pooled %',n,pooled;
  END IF;

  IF NOT EXISTS (
      SELECT 1
      FROM synthesis.synthesis_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000503'
        AND synthesis_origin='oes_update'
        AND synthesis_type='narrative_update'
        AND result_summary#>>'{pooled_by_oes}'='false'
  ) THEN
      RAISE EXCEPTION 'RC01-T02 FAIL: narrative update semantics missing';
  END IF;

  RAISE NOTICE 'RC01-T02 PASS — RCT update is narrative and not statistically pooled';
END
$t02$;

-- RC01-T03 — direct model count differs from reported underlying k.
DO $t03$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000701'
  ) INTO v;

  IF (v#>>'{evidence_base,study_count}')::integer <> 6 THEN
      RAISE EXCEPTION 'RC01-T03 FAIL: directly modelled study count %',
          v#>>'{evidence_base,study_count}';
  END IF;

  IF v#>>'{priority_results,0,synthesis,result_summary,reported_study_count}' <> '10' THEN
      RAISE EXCEPTION 'RC01-T03 FAIL: reported underlying k missing';
  END IF;

  RAISE NOTICE 'RC01-T03 PASS — directly modelled Studies remain distinct from source meta-analysis k=10';
END
$t03$;

-- RC01-T04 — provisional GRADE is moderate and linked to OES update synthesis.
DO $t04$
BEGIN
  IF NOT EXISTS (
      SELECT 1
      FROM appraisal.certainty_assessment_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000601'
        AND framework='GRADE'
        AND initial_level='high'
        AND final_level='moderate'
        AND status='under_review'
        AND synthesis_version_uuid='81000000-0000-0000-0000-000000000503'
  ) THEN
      RAISE EXCEPTION 'RC01-T04 FAIL: provisional GRADE state incorrect';
  END IF;

  IF (
      SELECT count(*)
      FROM appraisal.certainty_domain
      WHERE certainty_assessment_version_uuid='81000000-0000-0000-0000-000000000601'
  ) <> 5 THEN
      RAISE EXCEPTION 'RC01-T04 FAIL: GRADE domains incomplete';
  END IF;

  RAISE NOTICE 'RC01-T04 PASS — provisional moderate GRADE attached to updated OES synthesis';
END
$t04$;

-- RC01-T05 — owner-approved real case reaches A2 and passes the N2 publication gate.
DO $t05$
BEGIN
  IF NOT product.evidence_sheet_is_publishable(
      '81000000-0000-0000-0000-000000000701'
  ) THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: A2 published product unexpectedly blocked';
  END IF;

  IF product.evidence_sheet_assurance_level(
      '81000000-0000-0000-0000-000000000701'
  ) <> 'A2' THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: expected A2 after owner governance approval';
  END IF;

  IF EXISTS (
      SELECT 1
      FROM product.evidence_sheet_publication_issues(
          '81000000-0000-0000-0000-000000000701'
      )
      WHERE severity='error'
  ) THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: A2 published product still has blocking publication issues';
  END IF;

  IF NOT EXISTS (
      SELECT 1
      FROM product.evidence_sheet_publication_issues(
          '81000000-0000-0000-0000-000000000701'
      )
      WHERE issue_code='NO_EXPERT_INDEPENDENT_REVIEW' AND severity='warning'
  ) THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: no-expert disclosure warning missing at A2';
  END IF;

  IF (SELECT status FROM product.product_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000701') <> 'published' THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: product editorial status is not published';
  END IF;

  IF (SELECT publication_date FROM product.product_version
      WHERE version_uuid='81000000-0000-0000-0000-000000000701') IS NULL THEN
      RAISE EXCEPTION 'RC01-T05 FAIL: publication_date missing';
  END IF;

  RAISE NOTICE 'RC01-T05 PASS — A2 established; publication gate passes with explicit no-expert warning';
END
$t05$;

-- RC01-T06 — view exposes three distinct synthesis roles.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.evidence_sheet_view(
      '81000000-0000-0000-0000-000000000701'
  ) INTO v;

  IF jsonb_array_length(v->'priority_results') <> 3 THEN
      RAISE EXCEPTION 'RC01-T06 FAIL: priority result count %',
          jsonb_array_length(v->'priority_results');
  END IF;

  IF v#>>'{priority_results,0,role}' <> 'source'
     OR v#>>'{priority_results,1,role}' <> 'primary'
     OR v#>>'{priority_results,2,role}' <> 'corroborative'
  THEN
      RAISE EXCEPTION 'RC01-T06 FAIL: synthesis role ordering incorrect %',
          v->'priority_results';
  END IF;

  RAISE NOTICE 'RC01-T06 PASS — source, primary update and corroborative syntheses remain distinct';
END
$t06$;

-- RC01-T07 — risk assessments are present and methodologically verified by the OES AI pass.
DO $t07$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n
  FROM appraisal.risk_assessment_version
  WHERE investigation_version_uuid='81000000-0000-0000-0000-000000000002';

  IF n<>5 THEN
      RAISE EXCEPTION 'RC01-T07 FAIL: risk assessment count %',n;
  END IF;

  IF EXISTS (
      SELECT 1
      FROM appraisal.risk_assessment_version
      WHERE investigation_version_uuid='81000000-0000-0000-0000-000000000002'
        AND verification_status <> 'ai_methodologically_verified'
  ) THEN
      RAISE EXCEPTION 'RC01-T07 FAIL: appraisal verification status is not ai_methodologically_verified';
  END IF;

  RAISE NOTICE 'RC01-T07 PASS — ROBIS/RoB2 appraisals represented and AI methodological verification status explicit';
END
$t07$;

-- RC01-T08 — lineage reaches Product from an original RCT report.
DO $t08$
DECLARE n integer;
BEGIN
  WITH RECURSIVE c AS (
      SELECT target_version_uuid,1 depth,
             ARRAY[source_version_uuid,target_version_uuid]::uuid[] path
      FROM provenance.dependency_edge
      WHERE source_version_uuid='81000000-0000-0000-0000-000000000204'
        AND status='active'
      UNION ALL
      SELECT d.target_version_uuid,c.depth+1,c.path||d.target_version_uuid
      FROM c
      JOIN provenance.dependency_edge d
        ON d.source_version_uuid=c.target_version_uuid
       AND d.status='active'
      WHERE c.depth<24
        AND NOT d.target_version_uuid=ANY(c.path)
  )
  SELECT count(*) INTO n
  FROM c
  WHERE target_version_uuid='81000000-0000-0000-0000-000000000701';

  IF n<1 THEN
      RAISE EXCEPTION 'RC01-T08 FAIL: SleepioRx report-to-product lineage missing';
  END IF;

  RAISE NOTICE 'RC01-T08 PASS — RCT Report → Result → update → certainty/product lineage reconstructible';
END
$t08$;

-- RC01-T09 — search hit counts are not invented.
DO $t09$
BEGIN
  IF EXISTS (
      SELECT 1
      FROM investigation.search
      WHERE investigation_version_uuid='81000000-0000-0000-0000-000000000002'
        AND result_count IS NOT NULL
  ) THEN
      RAISE EXCEPTION 'RC01-T09 FAIL: raw hit count was populated despite unavailable trustworthy count';
  END IF;

  IF (
      SELECT count(*)
      FROM investigation.search_hit sh
      JOIN investigation.search s ON s.search_uuid=sh.search_uuid
      WHERE s.investigation_version_uuid='81000000-0000-0000-0000-000000000002'
  ) <> 6 THEN
      RAISE EXCEPTION 'RC01-T09 FAIL: captured material records count incorrect';
  END IF;

  RAISE NOTICE 'RC01-T09 PASS — unavailable raw hit counts remain NULL; captured records are explicit';
END
$t09$;

ROLLBACK;
