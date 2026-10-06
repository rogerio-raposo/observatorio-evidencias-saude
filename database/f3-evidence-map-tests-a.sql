-- OES Fase 3 — Evidence Map contract tests A
-- Positive derivation + structural guards. Requires formal synthetic fixture.

-- EM-T01 — formal fixture is publishable with A3 + qualified controls.
DO $test$
BEGIN
    IF NOT product.evidence_map_is_publishable('b4100000-0000-0000-0000-000000000020') THEN
        RAISE EXCEPTION 'EM-T01 FAIL — formal synthetic Evidence Map is not publishable: %',
            (SELECT jsonb_agg(to_jsonb(x)) FROM product.evidence_map_publication_issues('b4100000-0000-0000-0000-000000000020') x WHERE severity='error');
    END IF;
    IF product.assurance_level('b4100000-0000-0000-0000-000000000020') <> 'A3' THEN
        RAISE EXCEPTION 'EM-T01 FAIL — expected A3';
    END IF;
END;
$test$;

-- EM-T02 — derived cell counts preserve entity-type semantics.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='A' AND column_category_code='Y';
    IF c.study_count<>1 OR c.report_count<>1 OR c.synthesis_count<>1
       OR c.total_count<>3 OR c.counted_unit_count<>1 THEN
        RAISE EXCEPTION 'EM-T02 FAIL — A/Y counts unexpected: %',to_jsonb(c);
    END IF;

    SELECT * INTO c
      FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='B' AND column_category_code='Y';
    IF c.study_count<>1 OR c.report_count<>0 OR c.synthesis_count<>0
       OR c.total_count<>1 OR c.counted_unit_count<>1 THEN
        RAISE EXCEPTION 'EM-T02 FAIL — B/Y counts unexpected: %',to_jsonb(c);
    END IF;
END;
$test$;

-- EM-T03 — drill-down identifiers reconcile exactly with total_count.
DO $test$
DECLARE bad_count integer;
BEGIN
    SELECT count(*) INTO bad_count
      FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010') c
     WHERE cardinality(c.map_item_uuids)<>c.total_count;
    IF bad_count<>0 THEN
        RAISE EXCEPTION 'EM-T03 FAIL — % cells have drill-down/count mismatch',bad_count;
    END IF;
END;
$test$;

-- EM-T04 — empty in-scope A/Z is a formal gap.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='A' AND column_category_code='Z';
    IF c.scope_status<>'in_scope' OR NOT c.gap_eligible OR c.counted_unit_count<>0 OR NOT c.empty_cell_gap THEN
        RAISE EXCEPTION 'EM-T04 FAIL — A/Z is not derived as a formal empty-cell gap: %',to_jsonb(c);
    END IF;
END;
$test$;

-- EM-T05 — empty not_applicable B/Z is never a gap.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='B' AND column_category_code='Z';
    IF c.scope_status<>'not_applicable' OR c.gap_eligible OR c.empty_cell_gap OR c.apparent_gap OR c.primary_evidence_gap OR c.synthesis_gap THEN
        RAISE EXCEPTION 'EM-T05 FAIL — B/Z incorrectly generates a gap: %',to_jsonb(c);
    END IF;
END;
$test$;

-- EM-T06 — Report for Study A does not inflate study counting policy.
DO $test$
DECLARE c record;
BEGIN
    SELECT * INTO c
      FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='A' AND column_category_code='Y';
    IF c.report_count<>1 OR c.study_count<>1 OR c.counted_unit_count<>1 THEN
        RAISE EXCEPTION 'EM-T06 FAIL — Report inflated Study count: %',to_jsonb(c);
    END IF;
END;
$test$;

-- EM-T10 — cross-framework assignment is rejected.
DO $test$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
        VALUES ('b4f00000-0000-0000-0000-000000000001','OES-MF-2026-TEST-X','MapFramework','map-test');
        INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
        VALUES ('b4f10000-0000-0000-0000-000000000001','b4f00000-0000-0000-0000-000000000001',1,'current','map-test','initial','Cross-framework test');
        INSERT INTO mapping.framework(entity_uuid) VALUES ('b4f00000-0000-0000-0000-000000000001');
        INSERT INTO mapping.framework_version(
            version_uuid,entity_uuid,investigation_version_uuid,mapping_subtype,
            coverage_claim,gap_claim_mode,counting_unit_policy,codebook_artifact_uuid,
            classification_policy_payload,coverage_policy_payload,gap_rules_payload,
            visualization_payload,stakeholder_payload,status
        ) VALUES (
            'b4f10000-0000-0000-0000-000000000001','b4f00000-0000-0000-0000-000000000001',
            'b4100000-0000-0000-0000-000000000002','other_evidence_map','exploratory','none','study',
            'b4900000-0000-0000-0000-000000000002','{}','{}','{}','{}','{}','active'
        );
        INSERT INTO mapping.dimension(dimension_uuid,framework_version_uuid,dimension_code,label,dimension_role,multi_valued,required_flag,sequence_no,status)
        VALUES ('b4f40000-0000-0000-0000-000000000001','b4f10000-0000-0000-0000-000000000001','x','X','filter',false,false,1,'active');
        INSERT INTO mapping.category(category_uuid,dimension_uuid,category_code,label,sequence_no,status)
        VALUES ('b4f41000-0000-0000-0000-000000000001','b4f40000-0000-0000-0000-000000000001','x1','X1',1,'active');
        INSERT INTO mapping.assignment(
            assignment_uuid,map_item_uuid,category_uuid,decision_state,assigned_by,
            actor_type,assignment_method,verification_status,rationale_payload,status
        ) VALUES (
            'b4f60000-0000-0000-0000-000000000001','b4500000-0000-0000-0000-000000000101',
            'b4f41000-0000-0000-0000-000000000001','candidate','MAP_TEST','system','rule_based','unverified','{}','active'
        );
    EXCEPTION WHEN others THEN
        blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'EM-T10 FAIL — cross-framework Assignment was accepted';
    END IF;
END;
$test$;

-- EM-T11 — a second active final category in a single-valued dimension is rejected.
DO $test$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO mapping.assignment(
            assignment_uuid,map_item_uuid,category_uuid,decision_state,assigned_by,
            actor_type,assignment_method,verification_status,verified_by,
            verifier_actor_type,verified_at,rationale_payload,status
        ) VALUES (
            'b4f60000-0000-0000-0000-000000000011','b4500000-0000-0000-0000-000000000101',
            'b4410000-0000-0000-0000-000000000002','final','MAP_TEST','human_reviewer','consensus','human_consensus',
            'MAP_TEST_2','human_reviewer',CURRENT_TIMESTAMP,'{}','active'
        );
    EXCEPTION WHEN others THEN
        blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'EM-T11 FAIL — second final category was accepted in single-valued dimension';
    END IF;
END;
$test$;

-- EM-T14 — AI cannot be recorded as a human verifier.
DO $test$
DECLARE blocked boolean:=false;
BEGIN
    BEGIN
        INSERT INTO mapping.assignment(
            assignment_uuid,map_item_uuid,category_uuid,decision_state,assigned_by,
            actor_type,assignment_method,verification_status,verified_by,
            verifier_actor_type,verified_at,rationale_payload,status
        ) VALUES (
            'b4f60000-0000-0000-0000-000000000014','b4500000-0000-0000-0000-000000000101',
            'b4410000-0000-0000-0000-000000000001','candidate','MAP_AI','ai_system','ai_assisted','human_verified',
            'MAP_AI','ai_system',CURRENT_TIMESTAMP,'{}','active'
        );
    EXCEPTION WHEN others THEN
        blocked:=true;
    END;
    IF NOT blocked THEN
        RAISE EXCEPTION 'EM-T14 FAIL — AI was accepted as human verifier';
    END IF;
END;
$test$;

-- EM-T19 — framework Dimension/Category children are immutable.
DO $test$
DECLARE blocked_dimension boolean:=false; blocked_category boolean:=false;
BEGIN
    BEGIN
        UPDATE mapping.dimension
           SET label='Mutated label'
         WHERE dimension_uuid='b4400000-0000-0000-0000-000000000001';
    EXCEPTION WHEN others THEN blocked_dimension:=true;
    END;
    BEGIN
        UPDATE mapping.category
           SET label='Mutated category'
         WHERE category_uuid='b4410000-0000-0000-0000-000000000001';
    EXCEPTION WHEN others THEN blocked_category:=true;
    END;
    IF NOT blocked_dimension OR NOT blocked_category THEN
        RAISE EXCEPTION 'EM-T19 FAIL — framework child mutation was not blocked';
    END IF;
END;
$test$;

-- EvidenceMapView structural smoke check.
DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');
    IF v->>'schema_version'<>'oes.evidence_map_view/0.1'
       OR jsonb_array_length(v->'cells')<>4
       OR COALESCE((v#>>'{audit,publishable}')::boolean,false)<>true
    THEN
        RAISE EXCEPTION 'EvidenceMapView smoke check failed: %',v;
    END IF;
END;
$test$;

SELECT 'EM-T01–T06/T10/T11/T14/T19 PASS' AS evidence_map_tests_a_status;
