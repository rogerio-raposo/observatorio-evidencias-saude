-- OES Fase 3 — EvidenceMapView rendering-readiness rebuild check
-- EMV-T10: zero rebuild preserves the additive rendering projection.

DO $test$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('b4100000-0000-0000-0000-000000000020');

    IF v->>'schema_version'<>'oes.evidence_map_view/0.1' THEN
        RAISE EXCEPTION 'EMV-T10 FAIL — schema version changed on rebuild';
    END IF;

    IF COALESCE((v#>>'{audit,synthetic_fixture}')::boolean,false)<>true
       OR COALESCE((v#>>'{audit,lineage_available}')::boolean,false)<>true
       OR COALESCE((v#>>'{audit,publishable}')::boolean,false)<>true
    THEN
        RAISE EXCEPTION 'EMV-T10 FAIL — audit projection changed on rebuild: %',v->'audit';
    END IF;

    IF jsonb_array_length(v->'cells')<>4
       OR jsonb_array_length(v->'reviewer_assignments')<>6
       OR jsonb_array_length(v->'method_controls')<>3
       OR jsonb_array_length(v->'lineage')<>5
    THEN
        RAISE EXCEPTION 'EMV-T10 FAIL — projected collections changed on rebuild';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'references') x
         WHERE x->>'report_id'='OES-RP-2026-001102'
    ) THEN
        RAISE EXCEPTION 'EMV-T10 FAIL — Study-linked Report B missing after rebuild';
    END IF;
END;
$test$;

SELECT 'EMV-T10 PASS — rendering-readiness projection preserved by rebuild'
AS evidence_map_view_rebuild_status;
