-- OES Fase 3 — EvidenceSheetView rebuild assertion
DO $viewrebuild$
DECLARE v jsonb;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    IF v IS NULL
       OR v->>'schema_version' <> 'oes.evidence_sheet_view/0.1'
       OR v#>>'{audit,publishable}' <> 'true'
       OR v#>>'{routing,depth_level}' <> 'N2'
       OR jsonb_array_length(v->'priority_results') <> 1
    THEN
        RAISE EXCEPTION 'F3-VIEW-T16 FAIL: rebuilt view contract invalid';
    END IF;

    RAISE NOTICE 'F3-VIEW-T16 PASS — rebuild produced valid EvidenceSheetView';
END
$viewrebuild$;
