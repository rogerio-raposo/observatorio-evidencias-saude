-- OES Fase 3 — Evidence Map rebuild check
-- EM-T20: after a zero rebuild, counts/gaps/gate must reproduce exactly.

DO $test$
DECLARE ay record; az record; bz record;
BEGIN
    IF NOT product.evidence_map_is_publishable('b4100000-0000-0000-0000-000000000020') THEN
        RAISE EXCEPTION 'EM-T20 FAIL — rebuilt formal fixture is not publishable';
    END IF;

    SELECT * INTO ay FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='A' AND column_category_code='Y';
    SELECT * INTO az FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='A' AND column_category_code='Z';
    SELECT * INTO bz FROM mapping.evidence_map_cells('b4100000-0000-0000-0000-000000000010')
     WHERE row_category_code='B' AND column_category_code='Z';

    IF ay.study_count<>1 OR ay.report_count<>1 OR ay.synthesis_count<>1 OR ay.counted_unit_count<>1 THEN
        RAISE EXCEPTION 'EM-T20 FAIL — rebuilt A/Y counts changed: %',to_jsonb(ay);
    END IF;
    IF NOT az.empty_cell_gap OR az.counted_unit_count<>0 THEN
        RAISE EXCEPTION 'EM-T20 FAIL — rebuilt A/Z formal gap changed: %',to_jsonb(az);
    END IF;
    IF bz.empty_cell_gap OR bz.apparent_gap OR bz.primary_evidence_gap OR bz.synthesis_gap THEN
        RAISE EXCEPTION 'EM-T20 FAIL — rebuilt B/Z not_applicable semantics changed: %',to_jsonb(bz);
    END IF;

    IF jsonb_array_length(product.evidence_map_view('b4100000-0000-0000-0000-000000000020')->'cells')<>4 THEN
        RAISE EXCEPTION 'EM-T20 FAIL — rebuilt EvidenceMapView cell count changed';
    END IF;
END;
$test$;

SELECT 'EM-T20 PASS — Evidence Map rebuild preserves gate, counts and gaps' AS evidence_map_rebuild_status;
