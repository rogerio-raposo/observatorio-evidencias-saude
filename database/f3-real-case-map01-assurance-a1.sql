-- OES Fase 3 — Real Case MAP-01 AI methodological verification
-- Execute only after MAP01-T01–T15 PASS.
-- This second-pass AI verification may establish A1 only.
-- It does not create owner approval, human verification or publication eligibility.

BEGIN;

DO $pre$
DECLARE v jsonb;
BEGIN
    v:=product.evidence_map_view('c8100000-0000-0000-0000-000000000020');

    IF v#>>'{audit,assurance_level}'<>'A0'
       OR COALESCE((v#>>'{audit,publishable}')::boolean,true)<>false
       OR v#>>'{mapping_method,coverage_claim}'<>'structured_non_exhaustive'
       OR v#>>'{mapping_method,gap_claim_mode}'<>'apparent_only'
       OR jsonb_array_length(v->'map_items')<>17
       OR jsonb_array_length(v->'cells')<>20
       OR jsonb_array_length(v->'source_investigations')<>1
    THEN
        RAISE EXCEPTION 'MAP01-A1 precondition FAIL — initial A0 state not validated';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM mapping.assignment a
          JOIN mapping.map_item mi ON mi.map_item_uuid=a.map_item_uuid
         WHERE mi.framework_version_uuid='c8100000-0000-0000-0000-000000000010'
           AND (
                a.actor_type<>'ai_system'
                OR a.verification_status<>'unverified'
                OR a.decision_state<>'final'
           )
    ) THEN
        RAISE EXCEPTION 'MAP01-A1 precondition FAIL — assignment actor/verification state changed';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM mapping.evidence_map_cells('c8100000-0000-0000-0000-000000000010')
         WHERE empty_cell_gap
    ) THEN
        RAISE EXCEPTION 'MAP01-A1 precondition FAIL — formal gap present in exploratory map';
    END IF;
END;
$pre$;

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,agreement_payload,discrepancy_payload,resolution_payload,
    performed_at,evidence_artifact_uuid,notes,record_status
) VALUES (
    'c8620000-0000-0000-0000-000000000001',
    'c8100000-0000-0000-0000-000000000002',
    'extraction','other',
    'OES_MAP01_AI_SECOND_PASS','ai_system',NULL,false,'passed',
    '{"control_code":"map01_ai_methodological_second_pass","scope":"17 MapItems, 67 assignments, 20 CellScope, source-corpus inheritance, apparent-gap semantics"}'::jsonb,
    '{"checks":["inventory_reconciliation","required_classifications","study_count_semantics","source_corpus_identity","gap_mode"]}'::jsonb,
    '{"material_discrepancies":[]}'::jsonb,
    '{"result":"passed_with_documented_non_exhaustive_limitations"}'::jsonb,
    TIMESTAMPTZ '2026-10-06 12:10:00-03',NULL,
    'AI-only second-pass methodological verification. It does not constitute human verification, independent expert review, owner approval or systematic-map readiness.',
    'active'
);

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES (
    'c8800000-0000-0000-0000-000000000011',
    'c8100000-0000-0000-0000-000000000020',
    'ai_methodological_verification',
    'OES_MAP01_AI_SECOND_PASS','ai_system',false,'passed',
    TIMESTAMPTZ '2026-10-06 12:11:00-03',
    'MAP-01 passed AI methodological verification for internal exploratory use only. Coverage remains structured non-exhaustive; gaps remain apparent; classifications remain unverified by humans.',
    '{"case":"MAP-01","validation_suite":"MAP01-T01-T15","map_items":17,"assignments":67,"cell_scope":20,"source_corpus":"OES-I-2026-000701","coverage_claim":"structured_non_exhaustive","gap_claim_mode":"apparent_only","publication_authorized":false,"human_verification":false}'::jsonb,
    'active'
);

COMMIT;
