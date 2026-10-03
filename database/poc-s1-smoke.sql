-- OES PoC-S1 — Smoke test
-- Experimental. Intended to be run after database/poc-s1.sql.
-- Uses fixed UUIDs for reproducibility.
-- The transaction is rolled back at the end.

BEGIN;

-- ---------------------------------------------------------------------------
-- GLOBAL ENTITIES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity (entity_uuid, oes_id, entity_type, created_by) VALUES
('00000000-0000-0000-0000-000000000001','OES-Q-2026-000001','Question','poc'),
('00000000-0000-0000-0000-000000000002','OES-I-2026-000001','Investigation','poc'),
('00000000-0000-0000-0000-000000000003','OES-ST-2026-000001','Study','poc'),
('00000000-0000-0000-0000-000000000004','OES-RP-2026-000001','Report','poc'),
('00000000-0000-0000-0000-000000000005','OES-O-2026-000001','Outcome','poc'),
('00000000-0000-0000-0000-000000000006','OES-RS-2026-000001','Result','poc'),
('00000000-0000-0000-0000-000000000007','OES-SY-2026-000001','Synthesis','poc'),
('00000000-0000-0000-0000-000000000008','OES-CE-2026-000001','CertaintyAssessment','poc'),
('00000000-0000-0000-0000-000000000009','OES-P-2026-000001','Product','poc');

INSERT INTO core.entity_version (
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES
('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000004','00000000-0000-0000-0000-000000000004',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000005',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000006','00000000-0000-0000-0000-000000000006',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000007','00000000-0000-0000-0000-000000000007',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000008','00000000-0000-0000-0000-000000000008',1,'current','poc','initial','smoke'),
('10000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000009',1,'current','poc','initial','smoke');

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO investigation.question(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid, entity_uuid, original_text, normalized_text,
    question_type, structure_type
) VALUES (
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Pergunta PoC',
    'Pergunta clínica estruturada para smoke test',
    'intervention',
    'PICO'
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid, entity_uuid, primary_question_entity_uuid,
    investigation_type, depth_level, maintenance_level,
    objective, evidence_cutoff_date, status
) VALUES (
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000001',
    'evidence_synthesis',
    'N2',
    'M1',
    'Validar lineage da PoC-S1',
    DATE '2026-10-03',
    'active'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid, question_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    'primary',
    1
);

-- ---------------------------------------------------------------------------
-- STUDY / REPORT
-- ---------------------------------------------------------------------------

INSERT INTO evidence.study(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000003');

INSERT INTO evidence.study_version(
    version_uuid, entity_uuid, study_type, design,
    title_or_label, sample_size, status
) VALUES (
    '10000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000003',
    'primary_study',
    'randomized_trial',
    'Study PoC',
    200,
    'active'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000004');

INSERT INTO evidence.report_version(
    version_uuid, entity_uuid, report_type, title,
    publication_date, publication_status, full_text_status, status
) VALUES (
    '10000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000004',
    'journal_article',
    'Report PoC',
    DATE '2026-01-01',
    'published',
    'available',
    'active'
);

INSERT INTO evidence.study_report_link(
    link_uuid, study_entity_uuid, report_entity_uuid,
    relation_type, confidence, reviewer, status
) VALUES (
    '20000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000004',
    'primary_report',
    'confirmed',
    'poc',
    'active'
);

-- ---------------------------------------------------------------------------
-- OUTCOME / RESULT / SOURCE
-- ---------------------------------------------------------------------------

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000005');

INSERT INTO evidence.outcome_version(
    version_uuid, entity_uuid, preferred_name, definition,
    direction_of_benefit, status
) VALUES (
    '10000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000005',
    'Desfecho PoC',
    'Desfecho binário para validação',
    'lower',
    'active'
);

INSERT INTO evidence.result(entity_uuid, study_entity_uuid)
VALUES (
    '00000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000003'
);

INSERT INTO evidence.result_version(
    version_uuid, entity_uuid, outcome_entity_uuid,
    timepoint_value, timepoint_unit, estimand, measure,
    reported_value, ci_lower, ci_upper, status
) VALUES (
    '10000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000005',
    30,
    'day',
    'treatment_effect',
    'risk_ratio',
    '{"value":0.80}'::jsonb,
    0.65,
    0.99,
    'active'
);

INSERT INTO evidence.result_source(
    result_version_uuid, report_version_uuid, source_location,
    source_type, original_text_or_value, is_primary_source, extractor
) VALUES (
    '10000000-0000-0000-0000-000000000006',
    '10000000-0000-0000-0000-000000000004',
    'Table 2',
    'table',
    '{"risk_ratio":0.80,"ci":[0.65,0.99]}'::jsonb,
    true,
    'poc'
);

INSERT INTO provenance.record(
    provenance_uuid, target_version_uuid, field_path,
    source_report_version_uuid, source_location,
    source_value, process_type, actor
) VALUES (
    '30000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000006',
    '$.reported_value',
    '10000000-0000-0000-0000-000000000004',
    'Table 2',
    '{"value":0.80}'::jsonb,
    'manual_extraction',
    'poc'
);

-- ---------------------------------------------------------------------------
-- SYNTHESIS
-- ---------------------------------------------------------------------------

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000007');

INSERT INTO synthesis.synthesis_version(
    version_uuid, entity_uuid, investigation_version_uuid,
    outcome_entity_uuid, estimand, synthesis_type,
    synthesis_origin, method, model, result_summary, status, executed_at
) VALUES (
    '10000000-0000-0000-0000-000000000007',
    '00000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000005',
    'treatment_effect',
    'pairwise_meta_analysis',
    'new_calculation',
    'inverse_variance',
    'random_effects',
    '{"effect":0.80,"lower":0.65,"upper":0.99}'::jsonb,
    'active',
    CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid, result_version_uuid,
    contribution_role, included_main_analysis
) VALUES (
    '10000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000006',
    'main',
    true
);

-- ---------------------------------------------------------------------------
-- CERTAINTY
-- ---------------------------------------------------------------------------

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000008');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid, entity_uuid, investigation_version_uuid,
    synthesis_version_uuid, outcome_entity_uuid,
    framework, framework_version, initial_level,
    final_level, evidence_state, assessment_date, status
) VALUES (
    '10000000-0000-0000-0000-000000000008',
    '00000000-0000-0000-0000-000000000008',
    '10000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000007',
    '00000000-0000-0000-0000-000000000005',
    'GRADE',
    'poc',
    'high',
    'moderate',
    'evidence_available',
    DATE '2026-10-03',
    'active'
);

INSERT INTO appraisal.certainty_domain(
    certainty_assessment_version_uuid, domain_code,
    concern_level, downgrade_steps, rationale, reviewer, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000008',
    'imprecision',
    'some_concern',
    1,
    'PoC only: illustrative downgrade.',
    'poc',
    1
);

-- ---------------------------------------------------------------------------
-- PRODUCT
-- ---------------------------------------------------------------------------

INSERT INTO product.product(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000009');

INSERT INTO product.product_version(
    version_uuid, entity_uuid, product_type, title,
    intended_audience, evidence_cutoff_date, status, conclusion_text
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '00000000-0000-0000-0000-000000000009',
    'evidence_sheet',
    'Ficha PoC-S1',
    'internal_validation',
    DATE '2026-10-03',
    'draft',
    'Conclusão apenas para teste estrutural.'
);

INSERT INTO product.investigation_link(
    product_version_uuid, investigation_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000002',
    'primary',
    1
);

INSERT INTO product.synthesis_link(
    product_version_uuid, synthesis_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000007',
    'primary',
    1
);

INSERT INTO product.certainty_link(
    product_version_uuid, certainty_assessment_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000008',
    'primary',
    1
);

-- ---------------------------------------------------------------------------
-- DEPENDENCY PROJECTION
-- ---------------------------------------------------------------------------

INSERT INTO provenance.dependency_edge(
    source_version_uuid, target_version_uuid, dependency_type, derivation_rule
) VALUES
(
    '10000000-0000-0000-0000-000000000004',
    '10000000-0000-0000-0000-000000000006',
    'report_supports_result',
    'result_source'
),
(
    '10000000-0000-0000-0000-000000000006',
    '10000000-0000-0000-0000-000000000007',
    'result_contributes_to_synthesis',
    'synthesis.contribution'
),
(
    '10000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000008',
    'synthesis_informs_certainty',
    'certainty.synthesis_version_uuid'
),
(
    '10000000-0000-0000-0000-000000000008',
    '10000000-0000-0000-0000-000000000009',
    'certainty_informs_product',
    'product.certainty_link'
);

-- ---------------------------------------------------------------------------
-- SMOKE ASSERTION QUERIES
-- ---------------------------------------------------------------------------

-- A. Current versions must exist for all nine entities.
SELECT count(*) AS current_entity_count
FROM core.current_entity_version
WHERE entity_uuid IN (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000007',
    '00000000-0000-0000-0000-000000000008',
    '00000000-0000-0000-0000-000000000009'
);

-- Expected: 9.

-- B. Reconstruct canonical lineage without dependency_edge.
SELECT
    p_ent.oes_id  AS product_id,
    c_ent.oes_id  AS certainty_id,
    s_ent.oes_id  AS synthesis_id,
    r_ent.oes_id  AS result_id,
    st_ent.oes_id AS study_id,
    rp_ent.oes_id AS report_id
FROM product.product_version pv
JOIN core.entity p_ent
  ON p_ent.entity_uuid = pv.entity_uuid
JOIN product.certainty_link pcl
  ON pcl.product_version_uuid = pv.version_uuid
JOIN appraisal.certainty_assessment_version cav
  ON cav.version_uuid = pcl.certainty_assessment_version_uuid
JOIN core.entity c_ent
  ON c_ent.entity_uuid = cav.entity_uuid
JOIN synthesis.synthesis_version sv
  ON sv.version_uuid = cav.synthesis_version_uuid
JOIN core.entity s_ent
  ON s_ent.entity_uuid = sv.entity_uuid
JOIN synthesis.contribution sc
  ON sc.synthesis_version_uuid = sv.version_uuid
JOIN evidence.result_version rv
  ON rv.version_uuid = sc.result_version_uuid
JOIN core.entity r_ent
  ON r_ent.entity_uuid = rv.entity_uuid
JOIN evidence.result r
  ON r.entity_uuid = rv.entity_uuid
JOIN core.entity st_ent
  ON st_ent.entity_uuid = r.study_entity_uuid
JOIN evidence.result_source rs
  ON rs.result_version_uuid = rv.version_uuid
JOIN evidence.report_version rpv
  ON rpv.version_uuid = rs.report_version_uuid
JOIN core.entity rp_ent
  ON rp_ent.entity_uuid = rpv.entity_uuid
WHERE pv.version_uuid = '10000000-0000-0000-0000-000000000009';

-- Expected one row:
-- OES-P-2026-000001
-- OES-CE-2026-000001
-- OES-SY-2026-000001
-- OES-RS-2026-000001
-- OES-ST-2026-000001
-- OES-RP-2026-000001

-- C. Dependency projection must reproduce a four-edge chain.
WITH RECURSIVE impact AS (
    SELECT
        source_version_uuid,
        target_version_uuid,
        dependency_type,
        1 AS depth
    FROM provenance.dependency_edge
    WHERE source_version_uuid =
      '10000000-0000-0000-0000-000000000004'

    UNION ALL

    SELECT
        d.source_version_uuid,
        d.target_version_uuid,
        d.dependency_type,
        i.depth + 1
    FROM provenance.dependency_edge d
    JOIN impact i
      ON d.source_version_uuid = i.target_version_uuid
    WHERE i.depth < 10
)
SELECT depth, dependency_type, target_version_uuid
FROM impact
ORDER BY depth;

-- Expected: depths 1 through 4 ending at Product version.

-- D. Provenance for the Result must resolve to the Report version.
SELECT
    target.oes_id AS target_entity,
    pr.field_path,
    source.oes_id AS source_report,
    pr.source_location
FROM provenance.record pr
JOIN core.entity_version tev
  ON tev.version_uuid = pr.target_version_uuid
JOIN core.entity target
  ON target.entity_uuid = tev.entity_uuid
JOIN evidence.report_version srv
  ON srv.version_uuid = pr.source_report_version_uuid
JOIN core.entity source
  ON source.entity_uuid = srv.entity_uuid
WHERE pr.target_version_uuid =
  '10000000-0000-0000-0000-000000000006';

-- Expected target OES-RS-2026-000001 and source OES-RP-2026-000001.

ROLLBACK;
