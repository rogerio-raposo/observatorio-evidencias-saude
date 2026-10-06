-- OES Fase 3 — OVR-01 real developmental A0 tests
-- Requires database/f3-real-case-01-dcbti.sql + database/f3-real-case-ovr01-dcbti.sql.

-- OVR01-T01 — identity, developmental route and A0.
DO $test$
DECLARE v jsonb;
BEGIN
  v:=product.overview_of_reviews_view('d9100000-0000-0000-0000-000000000020');
  IF v->>'schema_version'<>'oes.overview_of_reviews_view/0.1'
     OR v#>>'{identity,product_id}'<>'OES-P-2026-001601'
     OR v#>>'{identity,editorial_status}'<>'under_review'
     OR v#>>'{investigation,depth_level}'<>'N3'
     OR v#>>'{audit,assurance_level}'<>'A0'
     OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
  THEN
    RAISE EXCEPTION 'OVR01-T01 FAIL — identity/A0 state unexpected: %',v->'audit';
  END IF;
END;
$test$;

-- OVR01-T02 — exactly three analytic ReviewItems.
DO $test$
DECLARE n integer;
BEGIN
  SELECT count(*) INTO n FROM overview.review_item
   WHERE investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
     AND status='active' AND item_role='primary';
  IF n<>3 THEN RAISE EXCEPTION 'OVR01-T02 FAIL — expected 3 analytic ReviewItems, found %',n; END IF;
END;
$test$;

-- OVR01-T03 — canonical membership counts 27/15/44; 86 occurrences, 59 Studies.
DO $test$
DECLARE h integer; g integer; n integer; total integer; uniq integer;
BEGIN
  SELECT count(*) INTO h FROM overview.primary_study_membership WHERE review_item_uuid='d9500000-0000-0000-0000-000000000101' AND status='active';
  SELECT count(*) INTO g FROM overview.primary_study_membership WHERE review_item_uuid='d9500000-0000-0000-0000-000000000102' AND status='active';
  SELECT count(*) INTO n FROM overview.primary_study_membership WHERE review_item_uuid='d9500000-0000-0000-0000-000000000103' AND status='active';
  SELECT count(*),count(DISTINCT psm.primary_study_entity_uuid) INTO total,uniq
    FROM overview.primary_study_membership psm
    JOIN overview.review_item ri ON ri.review_item_uuid=psm.review_item_uuid
   WHERE ri.investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
     AND psm.status='active';
  IF h<>27 OR g<>15 OR n<>44 OR total<>86 OR uniq<>59 THEN
    RAISE EXCEPTION 'OVR01-T03 FAIL — H/G/N/total/unique = %/%/%/%/%',h,g,n,total,uniq;
  END IF;
END;
$test$;

-- OVR01-T04 — overlap metrics and CCA come from the database, never a persisted/manual value.
DO $test$
DECLARE m record;
BEGIN
  SELECT * INTO m FROM overview.overlap_metrics(
    'd9100000-0000-0000-0000-000000000002',
    'd9520000-0000-0000-0000-000000000001'
  );
  IF m.review_count<>3 OR m.study_occurrence_count<>86
     OR m.unique_primary_study_count<>59 OR m.redundant_occurrence_count<>27
     OR m.membership_completeness<>'complete'
     OR NOT m.cca_calculable OR m.cca IS NULL
  THEN RAISE EXCEPTION 'OVR01-T04 FAIL — database-derived overlap metrics unexpected: %',row_to_json(m); END IF;
END;
$test$;

-- OVR01-T05 — pairwise shared-study counts match the canonical matrix.
DO $test$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM overview.pairwise_overlap('d9520000-0000-0000-0000-000000000001')
                 WHERE review_item_a='d9500000-0000-0000-0000-000000000101' AND review_item_b='d9500000-0000-0000-0000-000000000102' AND shared_studies=6 AND calculable)
     OR NOT EXISTS (SELECT 1 FROM overview.pairwise_overlap('d9520000-0000-0000-0000-000000000001')
                 WHERE review_item_a='d9500000-0000-0000-0000-000000000101' AND review_item_b='d9500000-0000-0000-0000-000000000103' AND shared_studies=17 AND calculable)
     OR NOT EXISTS (SELECT 1 FROM overview.pairwise_overlap('d9520000-0000-0000-0000-000000000001')
                 WHERE review_item_a='d9500000-0000-0000-0000-000000000102' AND review_item_b='d9500000-0000-0000-0000-000000000103' AND shared_studies=9 AND calculable)
  THEN RAISE EXCEPTION 'OVR01-T05 FAIL — pairwise overlap mismatch'; END IF;
END;
$test$;

-- OVR01-T06 — Gao exact last-search date remains unknown and blocks publication.
DO $test$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM overview.review_item
     WHERE review_item_uuid='d9500000-0000-0000-0000-000000000102'
       AND last_search_date IS NULL AND currentness_status='unclear'
       AND currentness_rationale ILIKE '%no date is inferred%'
  ) THEN RAISE EXCEPTION 'OVR01-T06 FAIL — Gao currentness state changed'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM product.overview_of_reviews_publication_issues('d9100000-0000-0000-0000-000000000020')
     WHERE issue_code='MISSING_LAST_SEARCH_DATE' AND severity='error'
  ) THEN RAISE EXCEPTION 'OVR01-T06 FAIL — MISSING_LAST_SEARCH_DATE absent'; END IF;
END;
$test$;

-- OVR01-T07 — comparator families remain distinct and certainty is not fabricated/reused.
DO $test$
BEGIN
  IF (SELECT comparison_payload->>'family' FROM overview.outcome_evidence WHERE outcome_evidence_uuid='d9540000-0000-0000-0000-000000000001')<>'digital_sleep_education_or_hygiene'
     OR (SELECT comparison_payload->>'family' FROM overview.outcome_evidence WHERE outcome_evidence_uuid='d9540000-0000-0000-0000-000000000002')<>'mixed_multiple_controls'
     OR (SELECT comparison_payload->>'family' FROM overview.outcome_evidence WHERE outcome_evidence_uuid='d9540000-0000-0000-0000-000000000003')<>'mixed_multiple_controls'
     OR EXISTS (
       SELECT 1 FROM overview.outcome_evidence oe
       JOIN overview.review_item ri ON ri.review_item_uuid=oe.review_item_uuid
       WHERE ri.investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
         AND oe.certainty_assessment_version_uuid IS NOT NULL
     )
  THEN RAISE EXCEPTION 'OVR01-T07 FAIL — comparator/certainty policy violated'; END IF;
END;
$test$;

-- OVR01-T08 — every developmental control remains AI-only/unverified; no human control is fabricated.
DO $test$
BEGIN
  IF EXISTS (
    SELECT 1 FROM overview.primary_study_membership psm
    JOIN overview.review_item ri ON ri.review_item_uuid=psm.review_item_uuid
    WHERE ri.investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
      AND (psm.verification_status<>'unverified' OR psm.verified_by IS NOT NULL OR psm.verifier_actor_type IS NOT NULL OR psm.verified_at IS NOT NULL)
  ) OR EXISTS (
    SELECT 1 FROM investigation.reviewer_assignment WHERE investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
  ) OR EXISTS (
    SELECT 1 FROM investigation.quality_control_record WHERE investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
  ) THEN RAISE EXCEPTION 'OVR01-T08 FAIL — fabricated verification/control detected'; END IF;
END;
$test$;

-- OVR01-T09 — OVR-scoped ROBIS is active but unverified: Hwang unclear, Gao unclear, Nazari high.
DO $test$
BEGIN
  IF (SELECT overall_judgement FROM appraisal.risk_assessment_version WHERE version_uuid='d9310000-0000-0000-0000-000000000701')<>'unclear'
     OR (SELECT overall_judgement FROM appraisal.risk_assessment_version WHERE version_uuid='d9310000-0000-0000-0000-000000000702')<>'unclear'
     OR (SELECT overall_judgement FROM appraisal.risk_assessment_version WHERE version_uuid='d9310000-0000-0000-0000-000000000703')<>'high'
     OR EXISTS (
       SELECT 1 FROM appraisal.risk_assessment_version
        WHERE version_uuid IN ('d9310000-0000-0000-0000-000000000701','d9310000-0000-0000-0000-000000000702','d9310000-0000-0000-0000-000000000703')
          AND (status<>'active' OR verification_status<>'unverified')
     )
  THEN RAISE EXCEPTION 'OVR01-T09 FAIL — ROBIS state mismatch'; END IF;
END;
$test$;

-- OVR01-T10 — expected formal publication blockers remain open.
DO $test$
DECLARE code text;
BEGIN
  FOREACH code IN ARRAY ARRAY[
    'MISSING_LAST_SEARCH_DATE',
    'MISSING_APPRAISAL_CONTROL',
    'UNVERIFIED_REVIEW_APPRAISAL',
    'UNVERIFIED_MEMBERSHIP',
    'MISSING_OVERLAP_CONTROL',
    'UNVERIFIED_OUTCOME_EVIDENCE'
  ]
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM product.overview_of_reviews_publication_issues('d9100000-0000-0000-0000-000000000020')
       WHERE issue_code=code AND severity='error'
    ) THEN RAISE EXCEPTION 'OVR01-T10 FAIL — expected blocker % absent',code; END IF;
  END LOOP;

  IF product.assurance_level('d9100000-0000-0000-0000-000000000020')<>'A0'
     OR product.overview_of_reviews_is_publishable('d9100000-0000-0000-0000-000000000020')
     OR EXISTS (SELECT 1 FROM product.assurance_record WHERE product_version_uuid='d9100000-0000-0000-0000-000000000020' AND status='active')
  THEN RAISE EXCEPTION 'OVR01-T10 FAIL — A0/non-publishable boundary violated'; END IF;
END;
$test$;

-- OVR01-T11 — no OES-generated meta-analysis; prohibited N2 narrative synthesis 503 is not used.
DO $test$
BEGIN
  IF EXISTS (
    SELECT 1 FROM overview.outcome_evidence oe
    JOIN overview.review_item ri ON ri.review_item_uuid=oe.review_item_uuid
    WHERE ri.investigation_version_uuid='d9100000-0000-0000-0000-000000000002'
      AND oe.synthesis_version_uuid='81000000-0000-0000-0000-000000000503'
  ) OR EXISTS (
    SELECT 1 FROM product.synthesis_link psl
    JOIN synthesis.synthesis_version sv ON sv.version_uuid=psl.synthesis_version_uuid
    WHERE psl.product_version_uuid='d9100000-0000-0000-0000-000000000020'
      AND sv.synthesis_origin='oes_generated'
  ) THEN RAISE EXCEPTION 'OVR01-T11 FAIL — prohibited/new synthesis entered Overview'; END IF;
END;
$test$;

-- OVR01-T12 — Sweetman 2024 reuses the existing Study identity; no duplicate Study was created for it.
DO $test$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM overview.primary_study_membership
     WHERE review_item_uuid='d9500000-0000-0000-0000-000000000103'
       AND primary_study_entity_uuid='80000000-0000-0000-0000-000000000103'
       AND status='active'
  ) THEN
    RAISE EXCEPTION 'OVR01-T12 FAIL — existing Sweetman Study identity was not reused';
  END IF;
  -- Explicit duplicate check by title, excluding the existing Sweetman entity.
  IF EXISTS (
    SELECT 1 FROM evidence.study_version
     WHERE title_or_label='Sweetman-2024'
       AND entity_uuid<>'80000000-0000-0000-0000-000000000103'
  ) THEN RAISE EXCEPTION 'OVR01-T12 FAIL — Sweetman duplicate Study created'; END IF;
END;
$test$;

-- OVR01-T13 — View projects the real A0 corpus without hiding its unresolved audit state.
DO $test$
DECLARE v jsonb;
BEGIN
  v:=product.overview_of_reviews_view('d9100000-0000-0000-0000-000000000020');
  IF jsonb_array_length(v->'review_items')<>3
     OR jsonb_array_length(v->'primary_study_membership')<>86
     OR jsonb_array_length(v#>'{overlap,clusters}')<>1
     OR (v#>>'{audit,review_count}')::integer<>3
     OR COALESCE((v#>>'{audit,membership_complete}')::boolean,true)<>false
     OR COALESCE((v#>>'{audit,overlap_assessed}')::boolean,true)<>false
     OR COALESCE((v#>>'{audit,appraisal_complete}')::boolean,true)<>false
  THEN RAISE EXCEPTION 'OVR01-T13 FAIL — View projection/audit mismatch: %',v->'audit'; END IF;
END;
$test$;

-- OVR01-T14 — Nazari is materialized traceably and remains a published external estimate, not OES reanalysis.
DO $test$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM evidence.result_version rv
    JOIN evidence.result r ON r.entity_uuid=rv.entity_uuid
    WHERE rv.version_uuid='d9310000-0000-0000-0000-000000000501'
      AND r.study_entity_uuid='d9300000-0000-0000-0000-000000000101'
      AND rv.measure='weighted_mean_difference'
      AND (rv.reported_value->>'value')::numeric=-3.42
      AND rv.method_payload->>'recalculated_by_oes'='false'
  ) OR NOT EXISTS (
    SELECT 1 FROM evidence.result_source
     WHERE result_version_uuid='d9310000-0000-0000-0000-000000000501'
       AND report_version_uuid='d9310000-0000-0000-0000-000000000401'
  ) THEN RAISE EXCEPTION 'OVR01-T14 FAIL — Nazari result/provenance missing'; END IF;
END;
$test$;

SELECT 'OVR01-T01–T14 PASS — real developmental Overview persisted at A0; overlap/CCA database-derived; formal blockers preserved'
AS ovr01_initial_status;
