-- OES Fase 3 — EvidenceSheetView tests
BEGIN;

-- F3-VIEW-T01/T02 — valid JSON object and schema version.
DO $t01$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v IS NULL OR jsonb_typeof(v) <> 'object' THEN
        RAISE EXCEPTION 'F3-VIEW-T01 FAIL: view is null or not an object';
    END IF;

    IF v->>'schema_version' <> 'oes.evidence_sheet_view/0.1' THEN
        RAISE EXCEPTION
            'F3-VIEW-T02 FAIL: schema_version %',
            v->>'schema_version';
    END IF;

    RAISE NOTICE 'F3-VIEW-T01/T02 PASS — valid JSONB and schema version';
END
$t01$;

-- F3-VIEW-T03 — identity.
DO $t03$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v#>>'{identity,product_id}' <> 'OES-P-2026-000301'
       OR v#>>'{identity,version_no}' <> '1'
       OR v#>>'{identity,product_type}' <> 'evidence_sheet'
    THEN
        RAISE EXCEPTION 'F3-VIEW-T03 FAIL: identity mismatch %',v->'identity';
    END IF;

    RAISE NOTICE 'F3-VIEW-T03 PASS — product identity/version correct';
END
$t03$;

-- F3-VIEW-T04/T05 — primary Question/Investigation and N/M.
DO $t04$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v#>>'{question,question_id}' <> 'OES-Q-2026-000001'
       OR v#>>'{routing,investigation_id}' <> 'OES-I-2026-000001'
    THEN
        RAISE EXCEPTION 'F3-VIEW-T04 FAIL: primary question/investigation mismatch';
    END IF;

    IF v#>>'{routing,depth_level}' <> 'N2'
       OR v#>>'{routing,maintenance_level}' <> 'M1'
    THEN
        RAISE EXCEPTION 'F3-VIEW-T05 FAIL: N/M mismatch %',v->'routing';
    END IF;

    RAISE NOTICE 'F3-VIEW-T04/T05 PASS — Question, Investigation and N/M derived';
END
$t04$;

-- F3-VIEW-T06 — search summary.
DO $t06$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF jsonb_array_length(v#>'{method,searches}') <> 1
       OR v#>>'{method,searches,0,search_id}' <> 'OES-S-2026-000001'
       OR (v#>>'{method,searches,0,result_count}')::integer <> 2
    THEN
        RAISE EXCEPTION 'F3-VIEW-T06 FAIL: search projection incorrect %',v->'method';
    END IF;

    RAISE NOTICE 'F3-VIEW-T06 PASS — search summary correct';
END
$t06$;

-- F3-VIEW-T07 — Study/Report counts without publication double counting.
DO $t07$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF (v#>>'{evidence_base,study_count}')::integer <> 1
       OR (v#>>'{evidence_base,report_count}')::integer <> 1
       OR jsonb_array_length(v#>'{evidence_base,included_studies}') <> 1
       OR jsonb_array_length(v#>'{evidence_base,included_reports}') <> 1
    THEN
        RAISE EXCEPTION 'F3-VIEW-T07 FAIL: evidence base counts %',v->'evidence_base';
    END IF;

    RAISE NOTICE 'F3-VIEW-T07 PASS — Study/Report counts correct';
END
$t07$;

-- F3-VIEW-T08/T09 — priority result and certainty.
DO $t08$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF jsonb_array_length(v->'priority_results') <> 1
       OR v#>>'{priority_results,0,synthesis,synthesis_id}' <> 'OES-SY-2026-000001'
    THEN
        RAISE EXCEPTION 'F3-VIEW-T08 FAIL: priority synthesis incorrect %',v->'priority_results';
    END IF;

    IF v#>>'{priority_results,0,certainty,formal_assessment}' <> 'true'
       OR v#>>'{priority_results,0,certainty,framework}' <> 'GRADE'
       OR v#>>'{priority_results,0,certainty,final_level}' <> 'moderate'
    THEN
        RAISE EXCEPTION 'F3-VIEW-T09 FAIL: certainty incorrect %',
            v#>'{priority_results,0,certainty}';
    END IF;

    RAISE NOTICE 'F3-VIEW-T08/T09 PASS — priority Synthesis and certainty correct';
END
$t08$;

-- F3-VIEW-T10 — narrative product fields.
DO $t10$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v#>>'{limitations,present}' <> 'true'
       OR btrim(coalesce(v#>>'{limitations,summary}','')) = ''
       OR btrim(coalesce(v#>>'{applicability,summary}','')) = ''
       OR btrim(coalesce(v#>>'{conclusion,text}','')) = ''
    THEN
        RAISE EXCEPTION 'F3-VIEW-T10 FAIL: narrative fields incomplete';
    END IF;

    RAISE NOTICE 'F3-VIEW-T10 PASS — limitations/applicability/conclusion present';
END
$t10$;

-- F3-VIEW-T11 — current currency and history.
DO $t11$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v#>>'{identity,currency_status}' <> 'current'
       OR jsonb_array_length(v#>'{update_history,currency_history}') <> 1
       OR jsonb_array_length(v#>'{update_history,change_classes}') <> 2
    THEN
        RAISE EXCEPTION 'F3-VIEW-T11 FAIL: update/current state incorrect';
    END IF;

    RAISE NOTICE 'F3-VIEW-T11 PASS — currentity and change history correct';
END
$t11$;

-- F3-VIEW-T12 — audit/review/publishability.
DO $t12$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v#>>'{audit,publishable}' <> 'true'
       OR jsonb_array_length(v#>'{audit,reviews}') <> 1
       OR v#>>'{audit,lineage_available}' <> 'true'
    THEN
        RAISE EXCEPTION 'F3-VIEW-T12 FAIL: audit projection incorrect %',v->'audit';
    END IF;

    RAISE NOTICE 'F3-VIEW-T12 PASS — review, lineage and publishability exposed';
END
$t12$;

-- F3-VIEW-T13 — references from ResultSource.
DO $t13$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF jsonb_array_length(v->'references') <> 1
       OR v#>>'{references,0,report_id}' <> 'OES-RP-2026-000001'
       OR jsonb_array_length(v#>'{references,0,source_locations}') <> 1
    THEN
        RAISE EXCEPTION 'F3-VIEW-T13 FAIL: references projection incorrect %',v->'references';
    END IF;

    RAISE NOTICE 'F3-VIEW-T13 PASS — references derived from ResultSource';
END
$t13$;

-- F3-VIEW-T14 — deterministic output for unchanged state.
DO $t14$
DECLARE a jsonb; b jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO a;

    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO b;

    IF a IS DISTINCT FROM b THEN
        RAISE EXCEPTION 'F3-VIEW-T14 FAIL: repeated projection differs';
    END IF;

    RAISE NOTICE 'F3-VIEW-T14 PASS — projection deterministic';
END
$t14$;

-- Missing ProductVersion returns null rather than inventing a record.
DO $t15$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        'ffffffff-ffff-ffff-ffff-ffffffffffff'
    ) INTO v;

    IF v IS NOT NULL THEN
        RAISE EXCEPTION 'F3-VIEW missing-version FAIL: expected NULL';
    END IF;

    RAISE NOTICE 'F3-VIEW missing-version PASS — nonexistent ProductVersion returns NULL';
END
$t15$;

-- F3-VIEW-T17 — evidence units are broken down by Study type.
DO $t17$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF jsonb_array_length(v#>'{evidence_base,study_type_counts}') <> 1
       OR v#>>'{evidence_base,study_type_counts,0,study_type}' <> 'primary_study'
       OR (v#>>'{evidence_base,study_type_counts,0,count}')::integer <> 1
    THEN
        RAISE EXCEPTION
            'F3-VIEW-T17 FAIL: Study type counts incorrect %',
            v#>'{evidence_base,study_type_counts}';
    END IF;

    RAISE NOTICE 'F3-VIEW-T17 PASS — Study type counts exposed';
END
$t17$;

ROLLBACK;
