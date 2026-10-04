-- OES F2-B deterministic fixtures
-- Requires: poc-s1.sql + 002_poc_s2_search_screening_risk.sql
--           + 003_poc_s3_provenance_guard.sql
-- Commits a minimal end-to-end chain for runtime gate tests.

BEGIN;

INSERT INTO core.entity (entity_uuid, oes_id, entity_type, created_by) VALUES
('00000000-0000-0000-0000-000000000001','OES-Q-2026-000001','Question','f2b'),
('00000000-0000-0000-0000-000000000002','OES-I-2026-000001','Investigation','f2b'),
('00000000-0000-0000-0000-000000000003','OES-ST-2026-000001','Study','f2b'),
('00000000-0000-0000-0000-000000000004','OES-RP-2026-000001','Report','f2b'),
('00000000-0000-0000-0000-000000000005','OES-O-2026-000001','Outcome','f2b'),
('00000000-0000-0000-0000-000000000006','OES-RS-2026-000001','Result','f2b'),
('00000000-0000-0000-0000-000000000007','OES-SY-2026-000001','Synthesis','f2b'),
('00000000-0000-0000-0000-000000000008','OES-CE-2026-000001','CertaintyAssessment','f2b'),
('00000000-0000-0000-0000-000000000009','OES-P-2026-000001','Product','f2b'),
('00000000-0000-0000-0000-000000000010','OES-RB-2026-000001','RiskAssessment','f2b');

INSERT INTO core.entity_version (
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES
('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000004','00000000-0000-0000-0000-000000000004',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000005',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000006','00000000-0000-0000-0000-000000000006',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000007','00000000-0000-0000-0000-000000000007',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000008','00000000-0000-0000-0000-000000000008',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000009',1,'current','f2b','initial','fixture'),
('10000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000010',1,'current','f2b','initial','fixture');

INSERT INTO investigation.question(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid, entity_uuid, original_text, normalized_text,
    question_type, structure_type
) VALUES (
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Pergunta F2-B',
    'Pergunta estruturada para validação F2-B',
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
    'evidence_synthesis','N2','M1',
    'Validar GATE F2-B',DATE '2026-10-04','active'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid, question_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    'primary',1
);

INSERT INTO evidence.study(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000003');

INSERT INTO evidence.study_version(
    version_uuid, entity_uuid, study_type, design,
    title_or_label, sample_size, status
) VALUES (
    '10000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000003',
    'primary_study','randomized_trial','Study F2-B',200,'active'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000004');

INSERT INTO evidence.report_version(
    version_uuid, entity_uuid, report_type, title,
    publication_date, publication_status, full_text_status, status
) VALUES (
    '10000000-0000-0000-0000-000000000004',
    '00000000-0000-0000-0000-000000000004',
    'journal_article','Report F2-B',DATE '2026-01-01',
    'published','available','active'
);

INSERT INTO evidence.study_report_link(
    link_uuid, study_entity_uuid, report_entity_uuid,
    relation_type, confidence, reviewer, status
) VALUES (
    '20000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000004',
    'primary_report','confirmed','f2b','active'
);

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000005');

INSERT INTO evidence.outcome_version(
    version_uuid, entity_uuid, preferred_name, definition,
    direction_of_benefit, status
) VALUES (
    '10000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000005',
    'Desfecho F2-B','Desfecho binário para gate','lower','active'
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
    30,'day','treatment_effect','risk_ratio',
    '{"value":0.80}'::jsonb,0.65,0.99,'active'
);

INSERT INTO evidence.result_source(
    result_version_uuid, report_version_uuid, source_location,
    source_type, original_text_or_value, is_primary_source, extractor
) VALUES (
    '10000000-0000-0000-0000-000000000006',
    '10000000-0000-0000-0000-000000000004',
    'Table 2','table',
    '{"risk_ratio":0.80,"ci":[0.65,0.99]}'::jsonb,
    true,'f2b'
);

INSERT INTO provenance.record(
    provenance_uuid, target_version_uuid, field_path,
    source_report_version_uuid, source_location,
    source_value, process_type, actor
) VALUES (
    '30000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000006',
    '/reported_value',
    '10000000-0000-0000-0000-000000000004',
    'Table 2','{"value":0.80}'::jsonb,
    'manual_extraction','f2b'
);

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
    'treatment_effect','pairwise_meta_analysis',
    'new_calculation','inverse_variance','random_effects',
    '{"effect":0.80,"lower":0.65,"upper":0.99}'::jsonb,
    'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid, result_version_uuid,
    contribution_role, included_main_analysis
) VALUES (
    '10000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000006',
    'main',true
);

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
    'GRADE','f2b','high','moderate',
    'evidence_available',DATE '2026-10-04','active'
);

INSERT INTO appraisal.certainty_domain(
    certainty_assessment_version_uuid, domain_code,
    concern_level, downgrade_steps, rationale, reviewer, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000008',
    'imprecision','some_concern',1,
    'Fixture F2-B','f2b',1
);

INSERT INTO product.product(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000009');

INSERT INTO product.product_version(
    version_uuid, entity_uuid, product_type, title,
    intended_audience, evidence_cutoff_date, status, conclusion_text
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '00000000-0000-0000-0000-000000000009',
    'evidence_sheet','Ficha F2-B','internal_validation',
    DATE '2026-10-04','draft','Conclusão apenas para teste estrutural.'
);

INSERT INTO product.investigation_link(
    product_version_uuid, investigation_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000002',
    'primary',1
);

INSERT INTO product.synthesis_link(
    product_version_uuid, synthesis_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000007',
    'primary',1
);

INSERT INTO product.certainty_link(
    product_version_uuid, certainty_assessment_version_uuid, role, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000008',
    'primary',1
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid, target_version_uuid, dependency_type, derivation_rule
) VALUES
('10000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000006','report_supports_result','result_source'),
('10000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000007','result_contributes_to_synthesis','synthesis.contribution'),
('10000000-0000-0000-0000-000000000007','10000000-0000-0000-0000-000000000008','synthesis_informs_certainty','certainty.synthesis_version_uuid'),
('10000000-0000-0000-0000-000000000008','10000000-0000-0000-0000-000000000009','certainty_informs_product','product.certainty_link');

-- Search / dedup / hits.
INSERT INTO investigation.search(
    search_uuid, oes_search_id, investigation_version_uuid,
    source_name, platform, exact_strategy, executed_at,
    result_count, strategy_version, operator, status
) VALUES (
    '40000000-0000-0000-0000-000000000001',
    'OES-S-2026-000001',
    '10000000-0000-0000-0000-000000000002',
    'PubMed','NCBI','("F2-B"[Title])',
    CURRENT_TIMESTAMP,2,'1','f2b','completed'
);

INSERT INTO investigation.dedup_cluster(
    dedup_cluster_uuid, oes_dedup_id, investigation_version_uuid,
    canonical_report_entity_uuid, status, confidence, method, reviewer
) VALUES (
    '41000000-0000-0000-0000-000000000001',
    'OES-DD-2026-000001',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000004',
    'resolved','high','deterministic_fixture','f2b'
);

INSERT INTO investigation.search_hit(
    search_hit_uuid, oes_search_hit_id, search_uuid,
    report_entity_uuid, source_record_id, raw_payload,
    raw_title, raw_year, raw_identifier, source_rank,
    dedup_cluster_uuid, resolution_status
) VALUES
(
    '42000000-0000-0000-0000-000000000001',
    'OES-SH-2026-000001',
    '40000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000004',
    'PMID-F2B-1','{"source":"pubmed","record":1}'::jsonb,
    'Report F2-B',2026,'doi:f2b',1,
    '41000000-0000-0000-0000-000000000001','linked'
),
(
    '42000000-0000-0000-0000-000000000002',
    'OES-SH-2026-000002',
    '40000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000004',
    'ALT-F2B-1','{"source":"alternate","record":1}'::jsonb,
    'Report F2-B duplicate',2026,'doi:f2b',2,
    '41000000-0000-0000-0000-000000000001','duplicate'
);

INSERT INTO investigation.screening_decision(
    screening_uuid, oes_screening_id, investigation_version_uuid,
    target_entity_uuid, stage, reviewer, decision
) VALUES
(
    '43000000-0000-0000-0000-000000000001',
    'OES-SCR-2026-000001',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000004',
    'full_text','f2b','include'
),
(
    '43000000-0000-0000-0000-000000000002',
    'OES-SCR-2026-000002',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000003',
    'study_level','f2b','include'
);

-- Risk assessment fixture.
INSERT INTO appraisal.risk_assessment(entity_uuid)
VALUES ('00000000-0000-0000-0000-000000000010');

INSERT INTO appraisal.risk_assessment_version(
    version_uuid, entity_uuid, investigation_version_uuid,
    framework, framework_version, target_entity_uuid,
    outcome_entity_uuid, overall_judgement, assessor,
    assessment_date, verification_status, status
) VALUES (
    '10000000-0000-0000-0000-000000000010',
    '00000000-0000-0000-0000-000000000010',
    '10000000-0000-0000-0000-000000000002',
    'RoB 2','fixture',
    '00000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000005',
    'some_concerns','f2b',DATE '2026-10-04',
    'verified','active'
);

INSERT INTO appraisal.risk_assessment_domain(
    risk_assessment_version_uuid, domain_code,
    judgement, rationale, sequence_no
) VALUES (
    '10000000-0000-0000-0000-000000000010',
    'randomization','low',
    'Fixture domain for F2-B',1
);

COMMIT;
