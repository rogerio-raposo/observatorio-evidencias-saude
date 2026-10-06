-- OES Fase 3 — Real Case MAP-01 initial A0 tests
-- Requires N3-01 base + revision 01, migrations 016–018 and MAP-01 persistence.

-- MAP01-T01 — identity, configuration and A0 state.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('c8100000-0000-0000-0000-000000000020');

    IF v#>>'{identity,product_id}'<>'OES-P-2026-001401'
       OR v#>>'{mapping_method,mapping_subtype}'<>'descriptive_mapping_review'
       OR v#>>'{mapping_method,coverage_claim}'<>'structured_non_exhaustive'
       OR v#>>'{mapping_method,gap_claim_mode}'<>'apparent_only'
       OR v#>>'{mapping_method,counting_unit_policy}'<>'study'
       OR v#>>'{audit,assurance_level}'<>'A0'
       OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
    THEN
        RAISE EXCEPTION 'MAP01-T01 FAIL — identity/config/A0 state unexpected: %',v->'audit';
    END IF;
END;
$test$;

-- MAP01-T02 — mapping question is the MAP question, not the inherited causal N3 question.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('c8100000-0000-0000-0000-000000000020');
    IF v#>>'{question,normalized_text}' <>
       'Como as unidades de evidência recuperadas no corpus N3-01 sobre ambient AI scribes se distribuem por papel da evidência e domínio de outcome?'
    THEN
        RAISE EXCEPTION 'MAP01-T02 FAIL — wrong primary MAP question';
    END IF;

    IF jsonb_array_length(v->'source_investigations')<>1
       OR v#>>'{source_investigations,0,investigation_id}'<>'OES-I-2026-000701'
       OR v#>>'{source_investigations,0,product_role}'<>'source_corpus'
    THEN
        RAISE EXCEPTION 'MAP01-T02 FAIL — source corpus linkage missing';
    END IF;
END;
$test$;

-- MAP01-T03 — inherited Search/Screening are projected, not duplicated.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('c8100000-0000-0000-0000-000000000020');

    IF jsonb_array_length(v->'searches')<>3
       OR (v#>>'{selection_flow,search_hits}')::integer<>20
       OR (v#>>'{selection_flow,screening_decisions}')::integer<>34
       OR (v#>>'{selection_flow,source_investigation_count}')::integer<>1
    THEN
        RAISE EXCEPTION 'MAP01-T03 FAIL — inherited search/selection flow unexpected: %',v->'selection_flow';
    END IF;

    IF EXISTS (
        SELECT 1 FROM investigation.search
         WHERE investigation_version_uuid='c8100000-0000-0000-0000-000000000002'
    ) OR EXISTS (
        SELECT 1 FROM investigation.screening_decision
         WHERE investigation_version_uuid='c8100000-0000-0000-0000-000000000002'
    ) THEN
        RAISE EXCEPTION 'MAP01-T03 FAIL — Search/Screening were duplicated into MAP Investigation';
    END IF;
END;
$test$;

-- MAP01-T04 — inventory is exactly 5 Studies + 8 Reports + 4 Syntheses.
DO $test$
DECLARE s integer; r integer; y integer; total integer;
BEGIN
    SELECT
        count(*) FILTER (WHERE e.entity_type='Study'),
        count(*) FILTER (WHERE e.entity_type='Report'),
        count(*) FILTER (WHERE e.entity_type='Synthesis'),
        count(*)
      INTO s,r,y,total
      FROM mapping.map_item mi
      JOIN core.entity_version ev ON ev.version_uuid=mi.target_version_uuid
      JOIN core.entity e ON e.entity_uuid=ev.entity_uuid
     WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
       AND mi.status='active';

    IF s<>5 OR r<>8 OR y<>4 OR total<>17 THEN
        RAISE EXCEPTION 'MAP01-T04 FAIL — inventory S/R/Y/total = %/%/%/%',s,r,y,total;
    END IF;
END;
$test$;

-- MAP01-T05 — excluded/duplicate reports and Study-linked reports 201–205 are not MapItems.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM mapping.map_item mi
         WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
           AND mi.target_version_uuid IN (
             'e1000000-0000-0000-0000-000000000201',
             'e1000000-0000-0000-0000-000000000202',
             'e1000000-0000-0000-0000-000000000203',
             'e1000000-0000-0000-0000-000000000204',
             'e1000000-0000-0000-0000-000000000205',
             'e1000000-0000-0000-0000-000000000207',
             'e1000000-0000-0000-0000-000000000208',
             'e1000000-0000-0000-0000-000000000209',
             'e1000000-0000-0000-0000-000000000210',
             'e1000000-0000-0000-0000-000000000218',
             'e1000000-0000-0000-0000-000000000219',
             'e1000000-0000-0000-0000-000000000220'
           )
    ) THEN
        RAISE EXCEPTION 'MAP01-T05 FAIL — excluded/duplicate/study-linked Report entered MapItems';
    END IF;
END;
$test$;

-- MAP01-T06 — 67 final AI/unverified assignments; no human verification fabricated.
DO $test$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
      FROM mapping.assignment a
      JOIN mapping.map_item mi ON mi.map_item_uuid=a.map_item_uuid
     WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
       AND a.status='active';

    IF n<>67 THEN
        RAISE EXCEPTION 'MAP01-T06 FAIL — expected 67 assignments, found %',n;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM mapping.assignment a
          JOIN mapping.map_item mi ON mi.map_item_uuid=a.map_item_uuid
         WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
           AND (
                a.decision_state<>'final'
                OR a.actor_type<>'ai_system'
                OR a.verification_status<>'unverified'
                OR a.verified_by IS NOT NULL
                OR a.verifier_actor_type IS NOT NULL
                OR a.verified_at IS NOT NULL
           )
    ) THEN
        RAISE EXCEPTION 'MAP01-T06 FAIL — assignment state implies non-AI or fabricated verification';
    END IF;
END;
$test$;

-- MAP01-T07 — every MapItem has exactly one evidence_role and >=1 outcome_domain.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM mapping.map_item mi
         WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
           AND mi.status='active'
           AND (
               (SELECT count(*)
                  FROM mapping.assignment a
                  JOIN mapping.category c ON c.category_uuid=a.category_uuid
                  JOIN mapping.dimension d ON d.dimension_uuid=c.dimension_uuid
                 WHERE a.map_item_uuid=mi.map_item_uuid
                   AND a.status='active' AND a.decision_state='final'
                   AND d.dimension_code='evidence_role') <> 1
               OR
               (SELECT count(*)
                  FROM mapping.assignment a
                  JOIN mapping.category c ON c.category_uuid=a.category_uuid
                  JOIN mapping.dimension d ON d.dimension_uuid=c.dimension_uuid
                 WHERE a.map_item_uuid=mi.map_item_uuid
                   AND a.status='active' AND a.decision_state='final'
                   AND d.dimension_code='outcome_domain') < 1
           )
    ) THEN
        RAISE EXCEPTION 'MAP01-T07 FAIL — required final classifications incomplete';
    END IF;
END;
$test$;

-- MAP01-T08 — CellScope = 20, with 18 in scope, 1 excluded, 1 not applicable.
DO $test$
DECLARE total integer; ins integer; exc integer; na integer;
BEGIN
    SELECT count(*),
           count(*) FILTER (WHERE scope_status='in_scope'),
           count(*) FILTER (WHERE scope_status='excluded_by_framework'),
           count(*) FILTER (WHERE scope_status='not_applicable')
      INTO total,ins,exc,na
      FROM mapping.cell_scope
     WHERE framework_version_uuid='c8100000-0000-0000-0000-000000000010';

    IF total<>20 OR ins<>18 OR exc<>1 OR na<>1 THEN
        RAISE EXCEPTION 'MAP01-T08 FAIL — CellScope total/in/excluded/NA = %/%/%/%',total,ins,exc,na;
    END IF;
END;
$test$;

-- MAP01-T09 — randomized Study row counts and Study counting semantics.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('c8100000-0000-0000-0000-000000000010')
     WHERE row_category_code='comparative_randomized_study'
       AND column_category_code='documentation_time';

    IF c.study_count<>3 OR c.report_count<>0 OR c.synthesis_count<>0
       OR c.counted_unit_count<>3 OR c.apparent_gap OR c.primary_evidence_gap
    THEN
        RAISE EXCEPTION 'MAP01-T09 FAIL — randomized/documentation cell unexpected: %',row_to_json(c);
    END IF;
END;
$test$;

-- MAP01-T10 — contextual Reports do not inflate Study count.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('c8100000-0000-0000-0000-000000000010')
     WHERE row_category_code='contextual_secondary_report'
       AND column_category_code='broader_implementation_context';

    IF c.study_count<>0 OR c.report_count<>8 OR c.counted_unit_count<>0
       OR NOT c.apparent_gap OR NOT c.primary_evidence_gap
    THEN
        RAISE EXCEPTION 'MAP01-T10 FAIL — contextual-report/broader cell unexpected: %',row_to_json(c);
    END IF;
END;
$test$;

-- MAP01-T11 — Syntheses are visible but do not count as Studies.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('c8100000-0000-0000-0000-000000000010')
     WHERE row_category_code='synthesis'
       AND column_category_code='documentation_time';

    IF c.study_count<>0 OR c.synthesis_count<>1 OR c.counted_unit_count<>0
       OR NOT c.apparent_gap OR NOT c.primary_evidence_gap
    THEN
        RAISE EXCEPTION 'MAP01-T11 FAIL — synthesis/documentation cell unexpected: %',row_to_json(c);
    END IF;
END;
$test$;

-- MAP01-T12 — only apparent gaps; no formal empty-cell gaps anywhere.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM mapping.evidence_map_cells('c8100000-0000-0000-0000-000000000010')
         WHERE empty_cell_gap
    ) THEN
        RAISE EXCEPTION 'MAP01-T12 FAIL — formal empty-cell gap appeared in apparent-only MAP-01';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM mapping.evidence_map_cells('c8100000-0000-0000-0000-000000000010')
         WHERE apparent_gap
    ) THEN
        RAISE EXCEPTION 'MAP01-T12 FAIL — no apparent gap derived';
    END IF;
END;
$test$;

-- MAP01-T13 — source references reconcile to 13 included/contextual Reports.
DO $test$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n
      FROM product.evidence_map_reference_reports('c8100000-0000-0000-0000-000000000020');

    IF n<>13 THEN
        RAISE EXCEPTION 'MAP01-T13 FAIL — expected 13 distinct references, found %',n;
    END IF;
END;
$test$;

-- MAP01-T14 — A0 has no assurance record and remains internal/non-publishable.
DO $test$
BEGIN
    IF EXISTS (
        SELECT 1 FROM product.assurance_record
         WHERE product_version_uuid='c8100000-0000-0000-0000-000000000020'
           AND status='active'
    ) THEN
        RAISE EXCEPTION 'MAP01-T14 FAIL — assurance was granted before verification';
    END IF;

    IF product.assurance_level('c8100000-0000-0000-0000-000000000020')<>'A0'
       OR product.evidence_map_is_publishable('c8100000-0000-0000-0000-000000000020')
    THEN
        RAISE EXCEPTION 'MAP01-T14 FAIL — initial product must remain A0 and non-publishable';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='PRODUCT_NOT_PUBLISHED' AND severity='error'
    ) OR NOT EXISTS (
        SELECT 1 FROM product.evidence_map_publication_issues('c8100000-0000-0000-0000-000000000020')
         WHERE issue_code='MISSING_AI_METHODOLOGICAL_VERIFICATION' AND severity='error'
    ) THEN
        RAISE EXCEPTION 'MAP01-T14 FAIL — expected internal A0 blockers absent';
    END IF;
END;
$test$;

-- MAP01-T15 — N3-01 current product remains version 2/A0/under_review and unchanged.
DO $test$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM product.product_version pv
          JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
         WHERE pv.entity_uuid='e0000000-0000-0000-0000-000000000701'
           AND pv.version_uuid='e1000000-0000-0000-0000-000000000702'
           AND ev.version_status='current'
           AND pv.status='under_review'
    ) THEN
        RAISE EXCEPTION 'MAP01-T15 FAIL — N3-01 current ProductVersion changed';
    END IF;

    IF product.assurance_level('e1000000-0000-0000-0000-000000000702')<>'A0' THEN
        RAISE EXCEPTION 'MAP01-T15 FAIL — N3-01 assurance changed';
    END IF;
END;
$test$;

SELECT 'MAP01-T01–T15 PASS — real exploratory Evidence Map persisted at A0 with source-corpus inheritance'
AS map01_initial_status;
