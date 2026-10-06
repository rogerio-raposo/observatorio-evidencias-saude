-- OES Fase 3 — OverviewOfReviewsView rendering-readiness tests
-- Requires migrations 019–020 + formal synthetic Overview fixture.

-- OVR-T01 — schema version remains additive-compatible.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );
    IF v->>'schema_version'<>'oes.overview_of_reviews_view/0.1' THEN
        RAISE EXCEPTION 'OVR-T01 FAIL — schema version changed: %',
            v->>'schema_version';
    END IF;
END;
$test$;

-- OVR-T02 — full method decisions include resolved non-overview protocol deviation.
DO $test$
DECLARE v jsonb; n integer;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    SELECT count(*) INTO n
      FROM jsonb_array_elements(v#>'{method,policies}') x;

    IF n<>7 THEN
        RAISE EXCEPTION 'OVR-T02 FAIL — expected 7 projected method decisions, found %',n;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v#>'{method,policies}') x
         WHERE x->>'decision_code'='synthetic_resolved_search_deviation'
           AND x->>'decision_type'='protocol_deviation'
           AND x->>'resolution_status'='resolved'
           AND x ? 'risk'
           AND x ? 'mitigation'
           AND x ? 'impact'
           AND x ? 'linked_artifact'
    ) THEN
        RAISE EXCEPTION 'OVR-T02 FAIL — protocol deviation audit fields absent';
    END IF;
END;
$test$;

-- OVR-T03 — reviewer conflict and assignment metadata projected.
DO $test$
DECLARE v jsonb; n integer;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    SELECT count(*) INTO n
      FROM jsonb_array_elements(v#>'{method,reviewer_assignments}') x;

    IF n<>7 THEN
        RAISE EXCEPTION 'OVR-T03 FAIL — expected 7 reviewer assignments, found %',n;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v#>'{method,reviewer_assignments}') x
         WHERE NOT (x ? 'conflict')
            OR NOT (x ? 'assigned_at')
            OR NOT (x ? 'ended_at')
    ) THEN
        RAISE EXCEPTION 'OVR-T03 FAIL — reviewer audit metadata missing';
    END IF;
END;
$test$;

-- OVR-T04 — quality controls retain full audit payload.
DO $test$
DECLARE v jsonb; n integer;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    SELECT count(*) INTO n
      FROM jsonb_array_elements(v#>'{method,quality_controls}') x;

    IF n<>4 THEN
        RAISE EXCEPTION 'OVR-T04 FAIL — expected 4 quality controls, found %',n;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v#>'{method,quality_controls}') x
         WHERE NOT (x ? 'qualification')
            OR NOT (x ? 'scope')
            OR NOT (x ? 'agreement')
            OR NOT (x ? 'discrepancy')
            OR NOT (x ? 'resolution')
            OR NOT (x ? 'evidence_artifact')
            OR NOT (x ? 'notes')
    ) THEN
        RAISE EXCEPTION 'OVR-T04 FAIL — quality-control audit fields missing';
    END IF;
END;
$test$;

-- OVR-T05 — search exports project storage/hash metadata.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF jsonb_array_length(v->'searches')<>2 THEN
        RAISE EXCEPTION 'OVR-T05 FAIL — expected 2 Searches';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'searches') x
         WHERE x->'export_artifact' IS NULL
            OR btrim(COALESCE(x#>>'{export_artifact,storage_key}',''))=''
            OR btrim(COALESCE(x#>>'{export_artifact,content_hash}',''))=''
            OR btrim(COALESCE(x#>>'{export_artifact,hash_algorithm}',''))=''
    ) THEN
        RAISE EXCEPTION 'OVR-T05 FAIL — search export metadata incomplete';
    END IF;
END;
$test$;

-- OVR-T06 — selection counts and full-text exclusion details projected.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF (v#>>'{selection_flow,search_hits}')::integer<>8
       OR (v#>>'{selection_flow,unique_report_targets}')::integer<>4
       OR (v#>>'{selection_flow,title_abstract_decisions}')::integer<>0
       OR (v#>>'{selection_flow,full_text_decisions}')::integer<>4
       OR (v#>>'{selection_flow,full_text_exclusions}')::integer<>1
       OR (v#>>'{selection_flow,adjudications}')::integer<>0
       OR (v#>>'{selection_flow,included_review_items}')::integer<>3
    THEN
        RAISE EXCEPTION 'OVR-T06 FAIL — selection flow mismatch: %',
            v->'selection_flow';
    END IF;

    IF jsonb_array_length(v->'excluded_full_text')<>1
       OR v#>>'{excluded_full_text,0,exclusion_reason}'<>'Not a systematic review'
       OR v#>>'{excluded_full_text,0,target_id}'<>'OES-R-2026-001505'
    THEN
        RAISE EXCEPTION 'OVR-T06 FAIL — full-text exclusion detail mismatch: %',
            v->'excluded_full_text';
    END IF;
END;
$test$;

-- OVR-T07 — Review A update lineage explicitly projected.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF jsonb_array_length(v->'report_lineage')<>1
       OR v#>>'{report_lineage,0,review_study_id}'<>'OES-ST-2026-001501'
       OR v#>>'{report_lineage,0,source_report_id}'<>'OES-R-2026-001502'
       OR v#>>'{report_lineage,0,target_report_id}'<>'OES-R-2026-001501'
       OR v#>>'{report_lineage,0,relation_type}'<>'update_of'
    THEN
        RAISE EXCEPTION 'OVR-T07 FAIL — Review update lineage mismatch: %',
            v->'report_lineage';
    END IF;
END;
$test$;

-- OVR-T08 — ResultSource and provenance are projected for all OutcomeEvidence.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF jsonb_array_length(v->'outcome_evidence')<>3 THEN
        RAISE EXCEPTION 'OVR-T08 FAIL — expected 3 OutcomeEvidence rows';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'outcome_evidence') x
         WHERE jsonb_array_length(COALESCE(x->'source_reports','[]'::jsonb))<>1
            OR jsonb_array_length(COALESCE(x->'provenance','[]'::jsonb))<>1
            OR btrim(COALESCE(x#>>'{source_reports,0,source_location}',''))=''
    ) THEN
        RAISE EXCEPTION 'OVR-T08 FAIL — OutcomeEvidence source/provenance missing';
    END IF;
END;
$test$;

-- OVR-T09 — dependency lineage and invalidation detail are auditable.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF jsonb_array_length(v->'lineage')<>6
       OR jsonb_array_length(v->'invalidated_dependencies_detail')<>0
       OR COALESCE((v#>>'{audit,lineage_available}')::boolean,false)<>true
    THEN
        RAISE EXCEPTION 'OVR-T09 FAIL — baseline lineage mismatch';
    END IF;
END;
$test$;

BEGIN;

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,
    source_report_version_uuid,source_location,source_value,
    process_type,transformation,actor,status,
    invalidated_at,invalidation_reason
) VALUES (
    'f9700000-0000-0000-0000-000000009009',
    'f9310000-0000-0000-0000-000000000101',
    'test.rendering_readiness_invalidation',
    'f9310000-0000-0000-0000-000000000402',
    'Synthetic update report',
    '{"test":"OVR-T09"}'::jsonb,
    'rendering_readiness_test','{}'::jsonb,
    'OVR_TEST','invalidated',
    TIMESTAMPTZ '2026-10-06 14:00:00-03',
    'Synthetic invalidation used to validate projected dependency detail'
);

DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    IF jsonb_array_length(v->'invalidated_dependencies_detail')<1
       OR COALESCE((v#>>'{audit,invalidated_dependencies}')::boolean,false)<>true
       OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
    THEN
        RAISE EXCEPTION 'OVR-T09 FAIL — invalidated dependency detail/gate mismatch';
    END IF;
END;
$test$;

ROLLBACK;

-- OVR-T10 — scientific, overlap, assurance and publication semantics unchanged.
DO $test$
DECLARE v jsonb;
DECLARE cca numeric;
BEGIN
    v:=product.overview_of_reviews_view(
        'f9100000-0000-0000-0000-000000000020'
    );

    SELECT (x#>>'{metrics,cca}')::numeric
      INTO cca
      FROM jsonb_array_elements(v#>'{overlap,clusters}') x
     LIMIT 1;

    IF abs(cca-0.4)>0.000001
       OR v#>>'{audit,assurance_level}'<>'A3'
       OR COALESCE((v#>>'{audit,publishable}')::boolean,false)<>true
       OR (v#>>'{audit,review_count}')::integer<>3
       OR jsonb_array_length(v->'references')<>4
    THEN
        RAISE EXCEPTION
            'OVR-T10 FAIL — projection migration changed contract semantics: audit=% cca=%',
            v->'audit',cca;
    END IF;
END;
$test$;

SELECT 'OVR-T01–T10 PASS — OverviewOfReviewsView rendering-readiness projection validated'
AS overview_rendering_readiness_status;
