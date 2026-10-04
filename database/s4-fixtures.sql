-- OES PoC-S4 deterministic fixtures
-- Requires baseline + migrations 002, 003 and 004.
-- Requires database/f2b-fixtures.sql to provide Investigation and Outcome.
-- Final committed state contains both historical and post-retraction chains.

BEGIN;

-- ---------------------------------------------------------------------------
-- S4 identities
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by) VALUES
('50000000-0000-0000-0000-000000000001','OES-ST-2026-000101','Study','s4'),
('50000000-0000-0000-0000-000000000002','OES-ST-2026-000102','Study','s4'),
('50000000-0000-0000-0000-000000000003','OES-RP-2026-000101','Report','s4'),
('50000000-0000-0000-0000-000000000004','OES-RP-2026-000102','Report','s4'),
('50000000-0000-0000-0000-000000000005','OES-RP-2026-000103','Report','s4'),
('50000000-0000-0000-0000-000000000006','OES-RP-2026-000104','Report','s4'),
('50000000-0000-0000-0000-000000000007','OES-RS-2026-000101','Result','s4'),
('50000000-0000-0000-0000-000000000008','OES-RS-2026-000102','Result','s4'),
('50000000-0000-0000-0000-000000000009','OES-SY-2026-000101','Synthesis','s4'),
('50000000-0000-0000-0000-000000000010','OES-CE-2026-000101','CertaintyAssessment','s4'),
('50000000-0000-0000-0000-000000000011','OES-P-2026-000101','Product','s4');

INSERT INTO core.entity_version(
    version_uuid, entity_uuid, version_no, version_status,
    created_by, change_type, change_note
) VALUES
('51000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',1,'current','s4','initial','Study A'),
('51000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002',1,'current','s4','initial','Study B'),
('51000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000003',1,'current','s4','initial','Report X original'),
('51000000-0000-0000-0000-000000000004','50000000-0000-0000-0000-000000000004',1,'current','s4','initial','Study A follow-up'),
('51000000-0000-0000-0000-000000000005','50000000-0000-0000-0000-000000000005',1,'current','s4','initial','Correction notice'),
('51000000-0000-0000-0000-000000000006','50000000-0000-0000-0000-000000000006',1,'current','s4','initial','Retraction notice'),
('51000000-0000-0000-0000-000000000007','50000000-0000-0000-0000-000000000007',1,'current','s4','initial','Result A pre-retraction'),
('51000000-0000-0000-0000-000000000008','50000000-0000-0000-0000-000000000008',1,'current','s4','initial','Result B pre-retraction'),
('51000000-0000-0000-0000-000000000009','50000000-0000-0000-0000-000000000009',1,'current','s4','initial','Synthesis pre-retraction'),
('51000000-0000-0000-0000-000000000010','50000000-0000-0000-0000-000000000010',1,'current','s4','initial','Certainty pre-retraction'),
('51000000-0000-0000-0000-000000000011','50000000-0000-0000-0000-000000000011',1,'current','s4','initial','Product pre-retraction');

-- ---------------------------------------------------------------------------
-- Study / Report identities and initial versions
-- ---------------------------------------------------------------------------

INSERT INTO evidence.study(entity_uuid) VALUES
('50000000-0000-0000-0000-000000000001'),
('50000000-0000-0000-0000-000000000002');

INSERT INTO evidence.study_version(
    version_uuid, entity_uuid, study_type, design,
    title_or_label, sample_size, status
) VALUES
('51000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',
 'primary_study','randomized_trial','S4 Study A',180,'active'),
('51000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002',
 'primary_study','randomized_trial','S4 Study B',220,'active');

INSERT INTO evidence.report(entity_uuid) VALUES
('50000000-0000-0000-0000-000000000003'),
('50000000-0000-0000-0000-000000000004'),
('50000000-0000-0000-0000-000000000005'),
('50000000-0000-0000-0000-000000000006');

INSERT INTO evidence.report_version(
    version_uuid, entity_uuid, report_type, title,
    publication_date, journal_or_source, language,
    publication_status, full_text_status, status
) VALUES
('51000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000003',
 'journal_article','S4 Report X — two studies',DATE '2026-01-15','S4 Journal','en',
 'published','available','active'),
('51000000-0000-0000-0000-000000000004','50000000-0000-0000-0000-000000000004',
 'follow_up','S4 Study A follow-up',DATE '2026-03-01','S4 Journal','en',
 'published','available','active'),
('51000000-0000-0000-0000-000000000005','50000000-0000-0000-0000-000000000005',
 'correction_notice','Correction to S4 Report X',DATE '2026-04-01','S4 Journal','en',
 'published','available','active'),
('51000000-0000-0000-0000-000000000006','50000000-0000-0000-0000-000000000006',
 'retraction_notice','Retraction of S4 Report X',DATE '2026-05-01','S4 Journal','en',
 'published','available','active');

INSERT INTO evidence.study_report_link(
    link_uuid, study_entity_uuid, report_entity_uuid,
    relation_type, confidence, evidence_note, reviewer,
    decision_date, status
) VALUES
('54000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',
 '50000000-0000-0000-0000-000000000003','multiple_studies_reported','confirmed',
 'Report X includes Study A','s4',DATE '2026-10-04','active'),
('54000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002',
 '50000000-0000-0000-0000-000000000003','multiple_studies_reported','confirmed',
 'Report X includes Study B','s4',DATE '2026-10-04','active'),
('54000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000001',
 '50000000-0000-0000-0000-000000000004','follow_up','confirmed',
 'Additional follow-up for Study A','s4',DATE '2026-10-04','active');

-- ---------------------------------------------------------------------------
-- Initial two-study result/synthesis/certainty/product chain
-- ---------------------------------------------------------------------------

INSERT INTO evidence.result(entity_uuid, study_entity_uuid) VALUES
('50000000-0000-0000-0000-000000000007','50000000-0000-0000-0000-000000000001'),
('50000000-0000-0000-0000-000000000008','50000000-0000-0000-0000-000000000002');

INSERT INTO evidence.result_version(
    version_uuid, entity_uuid, outcome_entity_uuid,
    timepoint_value, timepoint_unit, estimand, measure,
    reported_value, ci_lower, ci_upper, status
) VALUES
('51000000-0000-0000-0000-000000000007','50000000-0000-0000-0000-000000000007',
 '00000000-0000-0000-0000-000000000005',
 30,'day','treatment_effect','risk_ratio','{"value":0.80}'::jsonb,0.65,0.98,'active'),
('51000000-0000-0000-0000-000000000008','50000000-0000-0000-0000-000000000008',
 '00000000-0000-0000-0000-000000000005',
 30,'day','treatment_effect','risk_ratio','{"value":0.90}'::jsonb,0.72,1.08,'active');

INSERT INTO evidence.result_source(
    result_version_uuid, report_version_uuid, source_location,
    source_type, original_text_or_value, is_primary_source, extractor
) VALUES
('51000000-0000-0000-0000-000000000007','51000000-0000-0000-0000-000000000003',
 'Study A / Table 2','table','{"risk_ratio":0.80}'::jsonb,true,'s4'),
('51000000-0000-0000-0000-000000000008','51000000-0000-0000-0000-000000000003',
 'Study B / Table 4','table','{"risk_ratio":0.90}'::jsonb,true,'s4');

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('50000000-0000-0000-0000-000000000009');

INSERT INTO synthesis.synthesis_version(
    version_uuid, entity_uuid, investigation_version_uuid,
    outcome_entity_uuid, estimand, synthesis_type,
    synthesis_origin, method, model, result_summary, status, executed_at
) VALUES (
    '51000000-0000-0000-0000-000000000009',
    '50000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000005',
    'treatment_effect','pairwise_meta_analysis','new_calculation',
    'inverse_variance','random_effects',
    '{"effect":0.85,"lower":0.72,"upper":1.00,"study_count":2}'::jsonb,
    'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid,result_version_uuid,contribution_role,
    weight,included_main_analysis
) VALUES
('51000000-0000-0000-0000-000000000009','51000000-0000-0000-0000-000000000007','main',0.55,true),
('51000000-0000-0000-0000-000000000009','51000000-0000-0000-0000-000000000008','main',0.45,true);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('50000000-0000-0000-0000-000000000010');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    synthesis_version_uuid,outcome_entity_uuid,framework,framework_version,
    initial_level,final_level,evidence_state,assessment_date,status
) VALUES (
    '51000000-0000-0000-0000-000000000010',
    '50000000-0000-0000-0000-000000000010',
    '10000000-0000-0000-0000-000000000002',
    '51000000-0000-0000-0000-000000000009',
    '00000000-0000-0000-0000-000000000005',
    'GRADE','s4','high','moderate','evidence_available',DATE '2026-10-04','active'
);

INSERT INTO product.product(entity_uuid)
VALUES ('50000000-0000-0000-0000-000000000011');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,status,conclusion_text
) VALUES (
    '51000000-0000-0000-0000-000000000011',
    '50000000-0000-0000-0000-000000000011',
    'evidence_sheet','S4 Evidence Sheet v1','architecture_validation',
    DATE '2026-10-04','draft','Two-study synthesis before retraction.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    '51000000-0000-0000-0000-000000000011',
    '10000000-0000-0000-0000-000000000002','primary',1
);
INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
    '51000000-0000-0000-0000-000000000011',
    '51000000-0000-0000-0000-000000000009','primary',1
);
INSERT INTO product.certainty_link(
    product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
    '51000000-0000-0000-0000-000000000011',
    '51000000-0000-0000-0000-000000000010','primary',1
);

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,
    source_report_version_uuid,source_location,source_value,
    process_type,actor
) VALUES
('55000000-0000-0000-0000-000000000001','51000000-0000-0000-0000-000000000007',
 '/reported_value','51000000-0000-0000-0000-000000000003','Study A / Table 2',
 '{"value":0.80}'::jsonb,'manual_extraction','s4'),
('55000000-0000-0000-0000-000000000002','51000000-0000-0000-0000-000000000008',
 '/reported_value','51000000-0000-0000-0000-000000000003','Study B / Table 4',
 '{"value":0.90}'::jsonb,'manual_extraction','s4');

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('51000000-0000-0000-0000-000000000003','51000000-0000-0000-0000-000000000007',
 'report_supports_result','result_source'),
('51000000-0000-0000-0000-000000000003','51000000-0000-0000-0000-000000000008',
 'report_supports_result','result_source'),
('51000000-0000-0000-0000-000000000007','51000000-0000-0000-0000-000000000009',
 'result_contributes_to_synthesis','synthesis.contribution'),
('51000000-0000-0000-0000-000000000008','51000000-0000-0000-0000-000000000009',
 'result_contributes_to_synthesis','synthesis.contribution'),
('51000000-0000-0000-0000-000000000009','51000000-0000-0000-0000-000000000010',
 'synthesis_informs_certainty','certainty.synthesis_version_uuid'),
('51000000-0000-0000-0000-000000000010','51000000-0000-0000-0000-000000000011',
 'certainty_informs_product','product.certainty_link');

-- ---------------------------------------------------------------------------
-- Correction of Report X: v1 -> v2
-- ---------------------------------------------------------------------------

INSERT INTO evidence.report_relation(
    relation_uuid,source_report_entity_uuid,target_report_entity_uuid,
    relation_type,relation_date,notes
) VALUES (
    '56000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000005',
    '50000000-0000-0000-0000-000000000003',
    'correction_of',DATE '2026-04-01','Correction notice for Report X'
);

UPDATE core.entity_version
SET version_status='superseded', valid_to=CURRENT_TIMESTAMP
WHERE version_uuid='51000000-0000-0000-0000-000000000003';

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    supersedes_version_uuid,created_by,change_type,change_note
) VALUES (
    '52000000-0000-0000-0000-000000000003',
    '50000000-0000-0000-0000-000000000003',
    2,'current','51000000-0000-0000-0000-000000000003',
    's4','correction','Report X corrected'
);

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES (
    '52000000-0000-0000-0000-000000000003',
    '50000000-0000-0000-0000-000000000003',
    'journal_article','S4 Report X — corrected',DATE '2026-01-15',
    'S4 Journal','en','corrected','available',
    '{"correction_notice":"OES-RP-2026-000103"}'::jsonb,'active'
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES (
    '51000000-0000-0000-0000-000000000005',
    '52000000-0000-0000-0000-000000000003',
    'correction_notice_updates_report',
    'evidence.report_relation'
);

-- ---------------------------------------------------------------------------
-- Retraction of Report X: v2 -> v3
-- ---------------------------------------------------------------------------

INSERT INTO evidence.report_relation(
    relation_uuid,source_report_entity_uuid,target_report_entity_uuid,
    relation_type,relation_date,notes
) VALUES (
    '56000000-0000-0000-0000-000000000002',
    '50000000-0000-0000-0000-000000000006',
    '50000000-0000-0000-0000-000000000003',
    'retraction_of',DATE '2026-05-01','Retraction notice for Report X'
);

UPDATE core.entity_version
SET version_status='superseded', valid_to=CURRENT_TIMESTAMP
WHERE version_uuid='52000000-0000-0000-0000-000000000003';

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    supersedes_version_uuid,created_by,change_type,change_note
) VALUES (
    '53000000-0000-0000-0000-000000000003',
    '50000000-0000-0000-0000-000000000003',
    3,'current','52000000-0000-0000-0000-000000000003',
    's4','retraction','Report X retracted'
);

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES (
    '53000000-0000-0000-0000-000000000003',
    '50000000-0000-0000-0000-000000000003',
    'journal_article','S4 Report X — retracted',DATE '2026-01-15',
    'S4 Journal','en','retracted','available',
    '{"retraction_notice":"OES-RP-2026-000104"}'::jsonb,'invalidated'
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES (
    '51000000-0000-0000-0000-000000000006',
    '53000000-0000-0000-0000-000000000003',
    'retraction_notice_updates_report',
    'evidence.report_relation'
);

-- ---------------------------------------------------------------------------
-- Re-evaluation after retraction
-- ---------------------------------------------------------------------------

UPDATE core.entity_version
SET version_status='superseded', valid_to=CURRENT_TIMESTAMP
WHERE version_uuid IN (
    '51000000-0000-0000-0000-000000000007',
    '51000000-0000-0000-0000-000000000008',
    '51000000-0000-0000-0000-000000000009',
    '51000000-0000-0000-0000-000000000010',
    '51000000-0000-0000-0000-000000000011'
);

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    supersedes_version_uuid,created_by,change_type,change_note
) VALUES
('52000000-0000-0000-0000-000000000007','50000000-0000-0000-0000-000000000007',2,'current',
 '51000000-0000-0000-0000-000000000007','s4','retraction_impact','Source Report X retracted'),
('52000000-0000-0000-0000-000000000008','50000000-0000-0000-0000-000000000008',2,'current',
 '51000000-0000-0000-0000-000000000008','s4','retraction_impact','Source Report X retracted'),
('52000000-0000-0000-0000-000000000009','50000000-0000-0000-0000-000000000009',2,'current',
 '51000000-0000-0000-0000-000000000009','s4','reanalysis','Contributing Results invalidated'),
('52000000-0000-0000-0000-000000000010','50000000-0000-0000-0000-000000000010',2,'current',
 '51000000-0000-0000-0000-000000000010','s4','reassessment','No usable evidence remains'),
('52000000-0000-0000-0000-000000000011','50000000-0000-0000-0000-000000000011',2,'current',
 '51000000-0000-0000-0000-000000000011','s4','update','Product updated after retraction');

INSERT INTO evidence.result_version(
    version_uuid,entity_uuid,outcome_entity_uuid,timepoint_value,timepoint_unit,
    estimand,measure,reported_value,ci_lower,ci_upper,missing_data_state,status
) VALUES
('52000000-0000-0000-0000-000000000007','50000000-0000-0000-0000-000000000007',
 '00000000-0000-0000-0000-000000000005',30,'day','treatment_effect','risk_ratio',
 '{"value":0.80}'::jsonb,0.65,0.98,'source_invalidated','invalidated_due_to_retraction'),
('52000000-0000-0000-0000-000000000008','50000000-0000-0000-0000-000000000008',
 '00000000-0000-0000-0000-000000000005',30,'day','treatment_effect','risk_ratio',
 '{"value":0.90}'::jsonb,0.72,1.08,'source_invalidated','invalidated_due_to_retraction');

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,
    source_report_version_uuid,source_location,source_value,
    process_type,actor
) VALUES
('55000000-0000-0000-0000-000000000003','52000000-0000-0000-0000-000000000007',
 '/status','51000000-0000-0000-0000-000000000006','Retraction notice',
 '{"status":"invalidated_due_to_retraction"}'::jsonb,'impact_reassessment','s4'),
('55000000-0000-0000-0000-000000000004','52000000-0000-0000-0000-000000000008',
 '/status','51000000-0000-0000-0000-000000000006','Retraction notice',
 '{"status":"invalidated_due_to_retraction"}'::jsonb,'impact_reassessment','s4');

INSERT INTO synthesis.synthesis_version(
    version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
    estimand,synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES (
    '52000000-0000-0000-0000-000000000009',
    '50000000-0000-0000-0000-000000000009',
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000005',
    'treatment_effect','pairwise_meta_analysis','reanalysis',
    'inverse_variance','random_effects',
    '{"state":"no_usable_evidence","reason":"source_report_retracted"}'::jsonb,
    'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid,result_version_uuid,contribution_role,
    included_main_analysis,included_sensitivity,exclusion_reason,notes
) VALUES
('52000000-0000-0000-0000-000000000009','52000000-0000-0000-0000-000000000007',
 'excluded_after_retraction',false,false,'source_report_retracted','Study A result invalidated'),
('52000000-0000-0000-0000-000000000009','52000000-0000-0000-0000-000000000008',
 'excluded_after_retraction',false,false,'source_report_retracted','Study B result invalidated');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    synthesis_version_uuid,outcome_entity_uuid,framework,framework_version,
    initial_level,final_level,evidence_state,assessment_date,status
) VALUES (
    '52000000-0000-0000-0000-000000000010',
    '50000000-0000-0000-0000-000000000010',
    '10000000-0000-0000-0000-000000000002',
    '52000000-0000-0000-0000-000000000009',
    '00000000-0000-0000-0000-000000000005',
    'GRADE','s4',NULL,NULL,'no_evidence',DATE '2026-10-04','active'
);

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,status,conclusion_text
) VALUES (
    '52000000-0000-0000-0000-000000000011',
    '50000000-0000-0000-0000-000000000011',
    'evidence_sheet','S4 Evidence Sheet v2','architecture_validation',
    DATE '2026-10-04','draft',
    'No usable evidence remains after retraction of the shared source report.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    '52000000-0000-0000-0000-000000000011',
    '10000000-0000-0000-0000-000000000002','primary',1
);
INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
    '52000000-0000-0000-0000-000000000011',
    '52000000-0000-0000-0000-000000000009','primary',1
);
INSERT INTO product.certainty_link(
    product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
    '52000000-0000-0000-0000-000000000011',
    '52000000-0000-0000-0000-000000000010','primary',1
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('53000000-0000-0000-0000-000000000003','52000000-0000-0000-0000-000000000007',
 'report_retraction_invalidates_result','impact_reassessment'),
('53000000-0000-0000-0000-000000000003','52000000-0000-0000-0000-000000000008',
 'report_retraction_invalidates_result','impact_reassessment'),
('52000000-0000-0000-0000-000000000007','52000000-0000-0000-0000-000000000009',
 'invalidated_result_informs_reanalysis','synthesis.contribution'),
('52000000-0000-0000-0000-000000000008','52000000-0000-0000-0000-000000000009',
 'invalidated_result_informs_reanalysis','synthesis.contribution'),
('52000000-0000-0000-0000-000000000009','52000000-0000-0000-0000-000000000010',
 'reanalysis_informs_certainty','certainty.synthesis_version_uuid'),
('52000000-0000-0000-0000-000000000010','52000000-0000-0000-0000-000000000011',
 'certainty_informs_product','product.certainty_link');

COMMIT;
