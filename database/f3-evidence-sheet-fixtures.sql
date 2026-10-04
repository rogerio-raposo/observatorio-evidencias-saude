-- OES Fase 3 — Evidence Sheet deterministic fixture
-- Requires baseline + migrations 002–006 and database/f2b-fixtures.sql.

BEGIN;

-- Secondary source Investigation (N3) to validate reuse without mislabeling depth.
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES (
    '70000000-0000-0000-0000-000000000050',
    'OES-I-2026-000350',
    'Investigation',
    'f3'
);

INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES (
    '71000000-0000-0000-0000-000000000050',
    '70000000-0000-0000-0000-000000000050',
    1, 'current',
    'f3', 'initial', 'Source N3 investigation for Evidence Sheet fixture'
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('70000000-0000-0000-0000-000000000050');

INSERT INTO investigation.investigation_version(
    version_uuid, entity_uuid, primary_question_entity_uuid,
    investigation_type, depth_level, maintenance_level,
    objective, start_date, evidence_cutoff_date, status
) VALUES (
    '71000000-0000-0000-0000-000000000050',
    '70000000-0000-0000-0000-000000000050',
    '00000000-0000-0000-0000-000000000001',
    'rapid_evidence_synthesis',
    'N3','M0',
    'Source investigation reused by Evidence Sheet fixture',
    DATE '2026-10-04',
    DATE '2026-10-04',
    'active'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid, question_version_uuid, role, sequence_no
) VALUES (
    '71000000-0000-0000-0000-000000000050',
    '10000000-0000-0000-0000-000000000001',
    'primary',
    1
);

-- Evidence Sheet product.
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES (
    '70000000-0000-0000-0000-000000000001',
    'OES-P-2026-000301',
    'Product',
    'f3'
);

INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES (
    '71000000-0000-0000-0000-000000000001',
    '70000000-0000-0000-0000-000000000001',
    1, 'current',
    'f3', 'initial',
    'Initial Evidence Sheet fixture'
);

INSERT INTO product.product(entity_uuid)
VALUES ('70000000-0000-0000-0000-000000000001');

INSERT INTO product.product_version(
    version_uuid, entity_uuid, product_type, title,
    intended_audience, evidence_cutoff_date, publication_date,
    status, conclusion_text, applicability_summary,
    limitations_summary
) VALUES (
    '71000000-0000-0000-0000-000000000001',
    '70000000-0000-0000-0000-000000000001',
    'evidence_sheet',
    'Ficha de Evidência — fixture de validação',
    'architecture_validation',
    DATE '2026-10-04',
    DATE '2026-10-04',
    'under_review',
    'A evidência do fixture sugere efeito favorável, com certeza moderada.',
    'Aplicabilidade descritiva suficiente para validação estrutural.',
    'Fixture de validação; não representa conclusão clínica real.'
);

INSERT INTO product.investigation_link(
    product_version_uuid, investigation_version_uuid, role, sequence_no
) VALUES
(
    '71000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002',
    'primary',
    1
),
(
    '71000000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000050',
    'source',
    2
);

INSERT INTO product.synthesis_link(
    product_version_uuid, synthesis_version_uuid, role, sequence_no
) VALUES (
    '71000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000007',
    'primary',
    1
);

INSERT INTO product.certainty_link(
    product_version_uuid, certainty_assessment_version_uuid, role, sequence_no
) VALUES (
    '71000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000008',
    'primary',
    1
);

INSERT INTO product.currency_state(
    currency_state_uuid, product_version_uuid, currency_status,
    assessed_by, rationale, record_status
) VALUES (
    '72000000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000001',
    'current',
    'f3',
    'Initial currency assessment for publication gate fixture',
    'active'
);

INSERT INTO product.version_change_class(
    product_version_uuid, change_class, rationale, sequence_no
) VALUES
(
    '71000000-0000-0000-0000-000000000001',
    'new_evidence',
    'Fixture validates multiple semantic change classes',
    1
),
(
    '71000000-0000-0000-0000-000000000001',
    'certainty_change',
    'Fixture validates multiple semantic change classes',
    2
);

INSERT INTO product.review_record(
    review_uuid, product_version_uuid, reviewer, role,
    independent_flag, decision, notes, status
) VALUES (
    '73000000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000001',
    'f3-reviewer',
    'scientific_reviewer',
    true,
    'approved',
    'Fixture review approval',
    'active'
);

-- Assurance model fixture: A2 without expert independent review.
INSERT INTO product.assurance_record(
    assurance_uuid, product_version_uuid, assurance_type,
    actor, actor_type, independent_flag, decision,
    performed_at, notes, evidence_payload, status
) VALUES
(
    '73100000-0000-0000-0000-000000000001',
    '71000000-0000-0000-0000-000000000001',
    'ai_methodological_verification',
    'TEST_AI_VERIFIER',
    'ai_system',
    false,
    'passed',
    TIMESTAMPTZ '2026-10-04 12:00:00-03',
    'Synthetic fixture AI methodological verification',
    '{"test_fixture":true,"independent_review":false}'::jsonb,
    'active'
),
(
    '73100000-0000-0000-0000-000000000002',
    '71000000-0000-0000-0000-000000000001',
    'owner_governance_approval',
    'TEST_OWNER',
    'owner',
    false,
    'approved',
    TIMESTAMPTZ '2026-10-04 12:01:00-03',
    'Synthetic fixture owner governance approval',
    '{"test_fixture":true,"methodological_review":false}'::jsonb,
    'active'
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid, target_version_uuid,
    dependency_type, derivation_rule
) VALUES (
    '10000000-0000-0000-0000-000000000008',
    '71000000-0000-0000-0000-000000000001',
    'certainty_informs_evidence_sheet',
    'product.certainty_link'
);

COMMIT;
