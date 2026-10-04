-- OES Fase 3 — provenance-aware Evidence Sheet reference tests
-- Requires baseline + migrations 002–008 + F2-B fixtures + F3 Evidence Sheet fixture.

BEGIN;

-- External systematic-review report used as provenance for an adopted Synthesis.
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES (
    '74000000-0000-0000-0000-000000000001',
    'OES-RP-2026-000401',
    'Report',
    'f3-provenance-test'
);

INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES (
    '74100000-0000-0000-0000-000000000001',
    '74000000-0000-0000-0000-000000000001',
    1, 'current',
    'f3-provenance-test', 'initial',
    'External systematic review report used by adopted synthesis'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('74000000-0000-0000-0000-000000000001');

INSERT INTO evidence.report_version(
    version_uuid, entity_uuid, report_type, title,
    publication_date, journal_or_source, language,
    publication_status, full_text_status, bibliographic_payload, status
) VALUES (
    '74100000-0000-0000-0000-000000000001',
    '74000000-0000-0000-0000-000000000001',
    'systematic_review',
    'External systematic review used as quantitative anchor',
    DATE '2025-03-12',
    'npj Digital Medicine',
    'en',
    'published',
    'full_text_available',
    '{"pmid":"40075149","doi":"10.1038/s41746-025-01514-4"}'::jsonb,
    'active'
);

-- Adopted external synthesis represented as an OES SynthesisVersion.
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES (
    '74000000-0000-0000-0000-000000000002',
    'OES-SY-2026-000401',
    'Synthesis',
    'f3-provenance-test'
);

INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES (
    '74100000-0000-0000-0000-000000000002',
    '74000000-0000-0000-0000-000000000002',
    1, 'current',
    'f3-provenance-test', 'initial',
    'Adopted external meta-analysis'
);

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('74000000-0000-0000-0000-000000000002');

INSERT INTO synthesis.synthesis_version(
    version_uuid, entity_uuid, investigation_version_uuid,
    outcome_entity_uuid, estimand, synthesis_type,
    synthesis_origin, method, model, result_summary, status, executed_at
) VALUES (
    '74100000-0000-0000-0000-000000000002',
    '74000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000005',
    'treatment_effect',
    'pairwise_meta_analysis',
    'adopted_external',
    'published_meta_analysis',
    'random_effects',
    '{"effect":-0.93,"lower":-1.07,"upper":-0.79,"measure":"SMD","k":10}'::jsonb,
    'active',
    TIMESTAMPTZ '2026-10-04 12:00:00-03'
);

INSERT INTO provenance.record(
    provenance_uuid, target_version_uuid, field_path,
    source_report_version_uuid, source_location, source_value,
    process_type, actor
) VALUES (
    '74200000-0000-0000-0000-000000000001',
    '74100000-0000-0000-0000-000000000002',
    '/result_summary',
    '74100000-0000-0000-0000-000000000001',
    'Published subgroup meta-analysis',
    '{"effect":-0.93,"lower":-1.07,"upper":-0.79,"measure":"SMD","k":10}'::jsonb,
    'external_synthesis_adoption',
    'f3-provenance-test'
);

-- External synthesis informs the already linked OES synthesis,
-- but is deliberately NOT linked directly to the ProductVersion.
INSERT INTO provenance.dependency_edge(
    source_version_uuid, target_version_uuid,
    dependency_type, derivation_rule
) VALUES (
    '74100000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000007',
    'external_synthesis_informs_update',
    'dependency_edge preserves external quantitative anchor without making it a priority Product synthesis'
);

DO $t01$
DECLARE
    v jsonb;
    ref_count integer;
BEGIN
    SELECT product.evidence_sheet_view(
        '71000000-0000-0000-0000-000000000001'
    ) INTO v;

    SELECT count(*)
      INTO ref_count
      FROM product.evidence_sheet_reference_reports(
        '71000000-0000-0000-0000-000000000001'
      );

    IF NOT EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v->'references') r
         WHERE r->>'report_id' = 'OES-RP-2026-000401'
    ) THEN
        RAISE EXCEPTION
            'F3-PROV-T01 FAIL: provenance-only external report absent from references';
    END IF;

    IF jsonb_array_length(v->'priority_results') <> 1 THEN
        RAISE EXCEPTION
            'F3-PROV-T02 FAIL: external source synthesis leaked into priority_results';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM jsonb_array_elements(v#>'{audit,linked_syntheses}') s
         WHERE s->>'synthesis_id' = 'OES-SY-2026-000401'
    ) THEN
        RAISE EXCEPTION
            'F3-PROV-T03 FAIL: external source synthesis was directly linked to Product';
    END IF;

    IF v#>>'{audit,lineage_available}' <> 'true' THEN
        RAISE EXCEPTION
            'F3-PROV-T04 FAIL: lineage not exposed';
    END IF;

    IF ref_count < 2 THEN
        RAISE EXCEPTION
            'F3-PROV-T05 FAIL: expected original ResultSource plus provenance reference, got %',
            ref_count;
    END IF;

    RAISE NOTICE
        'F3-PROV-T01–T05 PASS — provenance reference included without priority-result duplication';
END
$t01$;

ROLLBACK;
