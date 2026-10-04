-- OES PoC-S5 deterministic fixtures
-- Requires baseline + migrations 002,003,004,005
-- and f2b-fixtures.sql + s4-fixtures.sql.

BEGIN;

-- ===========================================================================
-- S5-A — NMA
-- ===========================================================================

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('60000000-0000-0000-0000-000000000001','OES-SG-2026-000101','StudyGroup','s5'),
('60000000-0000-0000-0000-000000000002','OES-SG-2026-000102','StudyGroup','s5'),
('60000000-0000-0000-0000-000000000003','OES-SG-2026-000103','StudyGroup','s5'),
('60000000-0000-0000-0000-000000000004','OES-SG-2026-000104','StudyGroup','s5'),
('60000000-0000-0000-0000-000000000005','OES-RP-2026-000201','Report','s5'),
('60000000-0000-0000-0000-000000000006','OES-RP-2026-000202','Report','s5'),
('60000000-0000-0000-0000-000000000007','OES-RS-2026-000201','Result','s5'),
('60000000-0000-0000-0000-000000000008','OES-RS-2026-000202','Result','s5'),
('60000000-0000-0000-0000-000000000009','OES-SY-2026-000201','Synthesis','s5'),
('60000000-0000-0000-0000-000000000010','OES-SN-2026-000201','SynthesisNode','s5'),
('60000000-0000-0000-0000-000000000011','OES-SN-2026-000202','SynthesisNode','s5'),
('60000000-0000-0000-0000-000000000012','OES-SN-2026-000203','SynthesisNode','s5'),
('60000000-0000-0000-0000-000000000013','OES-CE-2026-000201','CertaintyAssessment','s5'),
('60000000-0000-0000-0000-000000000014','OES-P-2026-000201','Product','s5');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('61000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001',1,'current','s5','initial','Study A Treatment A'),
('61000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000002',1,'current','s5','initial','Study A Control'),
('61000000-0000-0000-0000-000000000003','60000000-0000-0000-0000-000000000003',1,'current','s5','initial','Study B Treatment A'),
('61000000-0000-0000-0000-000000000004','60000000-0000-0000-0000-000000000004',1,'current','s5','initial','Study B Treatment B'),
('61000000-0000-0000-0000-000000000005','60000000-0000-0000-0000-000000000005',1,'current','s5','initial','NMA Study A report'),
('61000000-0000-0000-0000-000000000006','60000000-0000-0000-0000-000000000006',1,'current','s5','initial','NMA Study B report'),
('61000000-0000-0000-0000-000000000007','60000000-0000-0000-0000-000000000007',1,'current','s5','initial','NMA Result A'),
('61000000-0000-0000-0000-000000000008','60000000-0000-0000-0000-000000000008',1,'current','s5','initial','NMA Result B'),
('61000000-0000-0000-0000-000000000009','60000000-0000-0000-0000-000000000009',1,'current','s5','initial','NMA Synthesis'),
('61000000-0000-0000-0000-000000000010','60000000-0000-0000-0000-000000000010',1,'current','s5','initial','Node Treatment A'),
('61000000-0000-0000-0000-000000000011','60000000-0000-0000-0000-000000000011',1,'current','s5','initial','Node Control'),
('61000000-0000-0000-0000-000000000012','60000000-0000-0000-0000-000000000012',1,'current','s5','initial','Node Treatment B'),
('61000000-0000-0000-0000-000000000013','60000000-0000-0000-0000-000000000013',1,'current','s5','initial','NMA certainty'),
('61000000-0000-0000-0000-000000000014','60000000-0000-0000-0000-000000000014',1,'current','s5','initial','NMA product');

INSERT INTO evidence.study_group(entity_uuid,study_entity_uuid) VALUES
('60000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001'),
('60000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000001'),
('60000000-0000-0000-0000-000000000003','50000000-0000-0000-0000-000000000002'),
('60000000-0000-0000-0000-000000000004','50000000-0000-0000-0000-000000000002');

INSERT INTO evidence.study_group_version(
 version_uuid,entity_uuid,label,group_type,n_analyzed,status
) VALUES
('61000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','Treatment A','intervention',90,'active'),
('61000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000002','Control','control',90,'active'),
('61000000-0000-0000-0000-000000000003','60000000-0000-0000-0000-000000000003','Treatment A','intervention',110,'active'),
('61000000-0000-0000-0000-000000000004','60000000-0000-0000-0000-000000000004','Treatment B','intervention',110,'active');

INSERT INTO evidence.group_component(
 component_uuid,study_group_version_uuid,component_type,label
) VALUES
('61100000-0000-0000-0000-000000000001','61000000-0000-0000-0000-000000000001','intervention','Treatment A'),
('61100000-0000-0000-0000-000000000002','61000000-0000-0000-0000-000000000002','comparator','Control'),
('61100000-0000-0000-0000-000000000003','61000000-0000-0000-0000-000000000003','intervention','Treatment A'),
('61100000-0000-0000-0000-000000000004','61000000-0000-0000-0000-000000000004','intervention','Treatment B');

INSERT INTO evidence.report(entity_uuid) VALUES
('60000000-0000-0000-0000-000000000005'),
('60000000-0000-0000-0000-000000000006');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,
 publication_status,full_text_status,status
) VALUES
('61000000-0000-0000-0000-000000000005','60000000-0000-0000-0000-000000000005',
 'journal_article','S5 NMA Study A report',DATE '2026-02-01','published','available','active'),
('61000000-0000-0000-0000-000000000006','60000000-0000-0000-0000-000000000006',
 'journal_article','S5 NMA Study B report',DATE '2026-02-15','published','available','active');

INSERT INTO evidence.study_report_link(
 link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
 confidence,reviewer,decision_date,status
) VALUES
('61200000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',
 '60000000-0000-0000-0000-000000000005','primary_report','confirmed','s5',DATE '2026-10-04','active'),
('61200000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002',
 '60000000-0000-0000-0000-000000000006','primary_report','confirmed','s5',DATE '2026-10-04','active');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid) VALUES
('60000000-0000-0000-0000-000000000007','50000000-0000-0000-0000-000000000001'),
('60000000-0000-0000-0000-000000000008','50000000-0000-0000-0000-000000000002');

INSERT INTO evidence.result_version(
 version_uuid,entity_uuid,outcome_entity_uuid,group_a_entity_uuid,group_b_entity_uuid,
 timepoint_value,timepoint_unit,estimand,measure,reported_value,ci_lower,ci_upper,status
) VALUES
('61000000-0000-0000-0000-000000000007','60000000-0000-0000-0000-000000000007',
 '00000000-0000-0000-0000-000000000005',
 '60000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000002',
 30,'day','treatment_effect','risk_ratio','{"value":0.75}'::jsonb,0.60,0.94,'active'),
('61000000-0000-0000-0000-000000000008','60000000-0000-0000-0000-000000000008',
 '00000000-0000-0000-0000-000000000005',
 '60000000-0000-0000-0000-000000000003','60000000-0000-0000-0000-000000000004',
 30,'day','treatment_effect','risk_ratio','{"value":0.88}'::jsonb,0.70,1.10,'active');

INSERT INTO evidence.result_source(
 result_version_uuid,report_version_uuid,source_location,source_type,
 original_text_or_value,is_primary_source,extractor
) VALUES
('61000000-0000-0000-0000-000000000007','61000000-0000-0000-0000-000000000005',
 'Table 2','table','{"risk_ratio":0.75}'::jsonb,true,'s5'),
('61000000-0000-0000-0000-000000000008','61000000-0000-0000-0000-000000000006',
 'Table 3','table','{"risk_ratio":0.88}'::jsonb,true,'s5');

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor
) VALUES
('61300000-0000-0000-0000-000000000001','61000000-0000-0000-0000-000000000007',
 '/reported_value','61000000-0000-0000-0000-000000000005','Table 2',
 '{"value":0.75}'::jsonb,'manual_extraction','s5'),
('61300000-0000-0000-0000-000000000002','61000000-0000-0000-0000-000000000008',
 '/reported_value','61000000-0000-0000-0000-000000000006','Table 3',
 '{"value":0.88}'::jsonb,'manual_extraction','s5');

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000009');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 estimand,synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES (
 '61000000-0000-0000-0000-000000000009',
 '60000000-0000-0000-0000-000000000009',
 '10000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000005',
 'treatment_effect','network_meta_analysis','structural_fixture',
 'network_meta_analysis','random_effects',
 '{"fixture":true,"nodes":3,"direct_edges":2,"indirect_contrast":"Treatment B vs Control"}'::jsonb,
 'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
 synthesis_version_uuid,result_version_uuid,contribution_role,included_main_analysis
) VALUES
('61000000-0000-0000-0000-000000000009','61000000-0000-0000-0000-000000000007','direct_evidence',true),
('61000000-0000-0000-0000-000000000009','61000000-0000-0000-0000-000000000008','direct_evidence',true);

INSERT INTO synthesis.node(entity_uuid,synthesis_entity_uuid) VALUES
('60000000-0000-0000-0000-000000000010','60000000-0000-0000-0000-000000000009'),
('60000000-0000-0000-0000-000000000011','60000000-0000-0000-0000-000000000009'),
('60000000-0000-0000-0000-000000000012','60000000-0000-0000-0000-000000000009');

INSERT INTO synthesis.node_version(version_uuid,entity_uuid,label,node_definition,status) VALUES
('61000000-0000-0000-0000-000000000010','60000000-0000-0000-0000-000000000010','Treatment A','{"treatment":"A"}'::jsonb,'active'),
('61000000-0000-0000-0000-000000000011','60000000-0000-0000-0000-000000000011','Control','{"treatment":"control"}'::jsonb,'active'),
('61000000-0000-0000-0000-000000000012','60000000-0000-0000-0000-000000000012','Treatment B','{"treatment":"B"}'::jsonb,'active');

INSERT INTO synthesis.node_mapping(
 synthesis_node_version_uuid,study_group_version_uuid,mapping_rationale,reviewer,status
) VALUES
('61000000-0000-0000-0000-000000000010','61000000-0000-0000-0000-000000000001','Study A arm maps to A','s5','active'),
('61000000-0000-0000-0000-000000000011','61000000-0000-0000-0000-000000000002','Study A control maps to Control','s5','active'),
('61000000-0000-0000-0000-000000000010','61000000-0000-0000-0000-000000000003','Study B arm maps to A','s5','active'),
('61000000-0000-0000-0000-000000000012','61000000-0000-0000-0000-000000000004','Study B arm maps to B','s5','active');

INSERT INTO synthesis.contrast(
 contrast_uuid,synthesis_version_uuid,node_a_version_uuid,node_b_version_uuid,contrast_type,status
) VALUES
('61400000-0000-0000-0000-000000000001','61000000-0000-0000-0000-000000000009',
 '61000000-0000-0000-0000-000000000010','61000000-0000-0000-0000-000000000011','direct','active'),
('61400000-0000-0000-0000-000000000002','61000000-0000-0000-0000-000000000009',
 '61000000-0000-0000-0000-000000000010','61000000-0000-0000-0000-000000000012','direct','active'),
('61400000-0000-0000-0000-000000000003','61000000-0000-0000-0000-000000000009',
 '61000000-0000-0000-0000-000000000012','61000000-0000-0000-0000-000000000011','indirect','active');

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000013');

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
 outcome_entity_uuid,framework,framework_version,initial_level,final_level,
 evidence_state,assessment_date,status
) VALUES (
 '61000000-0000-0000-0000-000000000013',
 '60000000-0000-0000-0000-000000000013',
 '10000000-0000-0000-0000-000000000002',
 '61000000-0000-0000-0000-000000000009',
 '00000000-0000-0000-0000-000000000005',
 'CINeMA','structural-fixture',NULL,'moderate',
 'evidence_available',DATE '2026-10-04','active'
);

INSERT INTO product.product(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000014');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,status,conclusion_text
) VALUES (
 '61000000-0000-0000-0000-000000000014',
 '60000000-0000-0000-0000-000000000014',
 'evidence_sheet','S5 NMA structural product','architecture_validation',
 DATE '2026-10-04','draft','Structural NMA fixture; not a clinical estimate.'
);

INSERT INTO product.investigation_link VALUES
('61000000-0000-0000-0000-000000000014','10000000-0000-0000-0000-000000000002','primary',1);
INSERT INTO product.synthesis_link VALUES
('61000000-0000-0000-0000-000000000014','61000000-0000-0000-0000-000000000009','primary',1);
INSERT INTO product.certainty_link VALUES
('61000000-0000-0000-0000-000000000014','61000000-0000-0000-0000-000000000013','primary',1);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('61000000-0000-0000-0000-000000000005','61000000-0000-0000-0000-000000000007','report_supports_result','result_source'),
('61000000-0000-0000-0000-000000000006','61000000-0000-0000-0000-000000000008','report_supports_result','result_source'),
('61000000-0000-0000-0000-000000000007','61000000-0000-0000-0000-000000000009','result_contributes_to_nma','synthesis.contribution'),
('61000000-0000-0000-0000-000000000008','61000000-0000-0000-0000-000000000009','result_contributes_to_nma','synthesis.contribution'),
('61000000-0000-0000-0000-000000000009','61000000-0000-0000-0000-000000000013','nma_informs_certainty','certainty.synthesis_version_uuid'),
('61000000-0000-0000-0000-000000000013','61000000-0000-0000-0000-000000000014','certainty_informs_product','product.certainty_link');

-- ===========================================================================
-- S5-B — PredictionModel
-- ===========================================================================

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('60000000-0000-0000-0000-000000000020','OES-ST-2026-000220','Study','s5'),
('60000000-0000-0000-0000-000000000021','OES-ST-2026-000221','Study','s5'),
('60000000-0000-0000-0000-000000000022','OES-RP-2026-000220','Report','s5'),
('60000000-0000-0000-0000-000000000023','OES-RP-2026-000221','Report','s5'),
('60000000-0000-0000-0000-000000000024','OES-PM-2026-000201','PredictionModel','s5'),
('60000000-0000-0000-0000-000000000025','OES-RS-2026-000220','Result','s5'),
('60000000-0000-0000-0000-000000000026','OES-RS-2026-000221','Result','s5'),
('60000000-0000-0000-0000-000000000027','OES-O-2026-000220','Outcome','s5'),
('60000000-0000-0000-0000-000000000028','OES-SY-2026-000220','Synthesis','s5'),
('60000000-0000-0000-0000-000000000029','OES-CE-2026-000220','CertaintyAssessment','s5'),
('60000000-0000-0000-0000-000000000030','OES-P-2026-000220','Product','s5');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('61000000-0000-0000-0000-000000000020','60000000-0000-0000-0000-000000000020',1,'current','s5','initial','Prediction development study'),
('61000000-0000-0000-0000-000000000021','60000000-0000-0000-0000-000000000021',1,'current','s5','initial','Prediction validation study'),
('61000000-0000-0000-0000-000000000022','60000000-0000-0000-0000-000000000022',1,'current','s5','initial','Development report'),
('61000000-0000-0000-0000-000000000023','60000000-0000-0000-0000-000000000023',1,'current','s5','initial','Validation report'),
('61000000-0000-0000-0000-000000000024','60000000-0000-0000-0000-000000000024',1,'current','s5','initial','Prediction model v1'),
('61000000-0000-0000-0000-000000000025','60000000-0000-0000-0000-000000000025',1,'current','s5','initial','Development performance'),
('61000000-0000-0000-0000-000000000026','60000000-0000-0000-0000-000000000026',1,'current','s5','initial','External performance'),
('61000000-0000-0000-0000-000000000027','60000000-0000-0000-0000-000000000027',1,'current','s5','initial','Prediction target outcome'),
('61000000-0000-0000-0000-000000000028','60000000-0000-0000-0000-000000000028',1,'current','s5','initial','Prediction synthesis'),
('61000000-0000-0000-0000-000000000029','60000000-0000-0000-0000-000000000029',1,'current','s5','initial','Prediction confidence'),
('61000000-0000-0000-0000-000000000030','60000000-0000-0000-0000-000000000030',1,'current','s5','initial','Prediction product');

INSERT INTO evidence.study(entity_uuid) VALUES
('60000000-0000-0000-0000-000000000020'),
('60000000-0000-0000-0000-000000000021');

INSERT INTO evidence.study_version(
 version_uuid,entity_uuid,study_type,design,title_or_label,sample_size,status
) VALUES
('61000000-0000-0000-0000-000000000020','60000000-0000-0000-0000-000000000020',
 'prediction_study','model_development','Prediction development study',600,'active'),
('61000000-0000-0000-0000-000000000021','60000000-0000-0000-0000-000000000021',
 'prediction_study','external_validation','Prediction external validation',450,'active');

INSERT INTO evidence.report(entity_uuid) VALUES
('60000000-0000-0000-0000-000000000022'),
('60000000-0000-0000-0000-000000000023');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,
 publication_status,full_text_status,status
) VALUES
('61000000-0000-0000-0000-000000000022','60000000-0000-0000-0000-000000000022',
 'journal_article','Prediction development report',DATE '2026-03-01','published','available','active'),
('61000000-0000-0000-0000-000000000023','60000000-0000-0000-0000-000000000023',
 'journal_article','Prediction validation report',DATE '2026-04-01','published','available','active');

INSERT INTO evidence.study_report_link(
 link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
 confidence,reviewer,decision_date,status
) VALUES
('61200000-0000-0000-0000-000000000020','60000000-0000-0000-0000-000000000020',
 '60000000-0000-0000-0000-000000000022','primary_report','confirmed','s5',DATE '2026-10-04','active'),
('61200000-0000-0000-0000-000000000021','60000000-0000-0000-0000-000000000021',
 '60000000-0000-0000-0000-000000000023','primary_report','confirmed','s5',DATE '2026-10-04','active');

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000027');

INSERT INTO evidence.outcome_version(
 version_uuid,entity_uuid,preferred_name,definition,direction_of_benefit,status
) VALUES (
 '61000000-0000-0000-0000-000000000027',
 '60000000-0000-0000-0000-000000000027',
 '30-day readmission','Binary prediction target','lower','active'
);

INSERT INTO evidence.prediction_model(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000024');

INSERT INTO evidence.prediction_model_version(
 version_uuid,entity_uuid,name_or_label,target_outcome_entity_uuid,
 intended_use,model_type,development_study_entity_uuid,specification_payload,status
) VALUES (
 '61000000-0000-0000-0000-000000000024',
 '60000000-0000-0000-0000-000000000024',
 'S5 Readmission Model',
 '60000000-0000-0000-0000-000000000027',
 'risk_prediction','logistic_regression',
 '60000000-0000-0000-0000-000000000020',
 '{"version":"1","predictors":5}'::jsonb,'active'
);

UPDATE core.entity_version
SET version_status='superseded',valid_to=CURRENT_TIMESTAMP
WHERE version_uuid='61000000-0000-0000-0000-000000000024';

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,supersedes_version_uuid,
 created_by,change_type,change_note
) VALUES (
 '62000000-0000-0000-0000-000000000024',
 '60000000-0000-0000-0000-000000000024',
 2,'current','61000000-0000-0000-0000-000000000024',
 's5','update','Specification updated after external validation'
);

INSERT INTO evidence.prediction_model_version(
 version_uuid,entity_uuid,name_or_label,target_outcome_entity_uuid,
 intended_use,model_type,development_study_entity_uuid,specification_payload,status
) VALUES (
 '62000000-0000-0000-0000-000000000024',
 '60000000-0000-0000-0000-000000000024',
 'S5 Readmission Model',
 '60000000-0000-0000-0000-000000000027',
 'risk_prediction','logistic_regression',
 '60000000-0000-0000-0000-000000000020',
 '{"version":"2","predictors":5,"external_validation_reviewed":true}'::jsonb,'active'
);

INSERT INTO evidence.prediction_model_identifier(
 prediction_model_entity_uuid,namespace,value,normalized_value,verified_at
) VALUES (
 '60000000-0000-0000-0000-000000000024',
 'oes-model-registry','S5-RM-001','s5-rm-001',CURRENT_TIMESTAMP
);

INSERT INTO evidence.prediction_model_study_role(
 prediction_model_entity_uuid,study_entity_uuid,role,notes
) VALUES
('60000000-0000-0000-0000-000000000024','60000000-0000-0000-0000-000000000020','development','Development cohort'),
('60000000-0000-0000-0000-000000000024','60000000-0000-0000-0000-000000000021','external_validation','Independent validation');

INSERT INTO evidence.result(
 entity_uuid,study_entity_uuid,prediction_model_entity_uuid
) VALUES
('60000000-0000-0000-0000-000000000025','60000000-0000-0000-0000-000000000020','60000000-0000-0000-0000-000000000024'),
('60000000-0000-0000-0000-000000000026','60000000-0000-0000-0000-000000000021','60000000-0000-0000-0000-000000000024');

INSERT INTO evidence.result_version(
 version_uuid,entity_uuid,outcome_entity_uuid,estimand,measure,
 reported_value,ci_lower,ci_upper,status
) VALUES
('61000000-0000-0000-0000-000000000025','60000000-0000-0000-0000-000000000025',
 '60000000-0000-0000-0000-000000000027','discrimination','c_statistic',
 '{"value":0.82}'::jsonb,0.79,0.85,'active'),
('61000000-0000-0000-0000-000000000026','60000000-0000-0000-0000-000000000026',
 '60000000-0000-0000-0000-000000000027','discrimination','c_statistic',
 '{"value":0.79}'::jsonb,0.75,0.83,'active');

INSERT INTO evidence.result_source(
 result_version_uuid,report_version_uuid,source_location,source_type,
 original_text_or_value,is_primary_source,extractor
) VALUES
('61000000-0000-0000-0000-000000000025','61000000-0000-0000-0000-000000000022',
 'Performance table','table','{"c_statistic":0.82}'::jsonb,true,'s5'),
('61000000-0000-0000-0000-000000000026','61000000-0000-0000-0000-000000000023',
 'Validation table','table','{"c_statistic":0.79}'::jsonb,true,'s5');

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor
) VALUES
('61300000-0000-0000-0000-000000000020','61000000-0000-0000-0000-000000000025',
 '/reported_value','61000000-0000-0000-0000-000000000022','Performance table',
 '{"value":0.82}'::jsonb,'manual_extraction','s5'),
('61300000-0000-0000-0000-000000000021','61000000-0000-0000-0000-000000000026',
 '/reported_value','61000000-0000-0000-0000-000000000023','Validation table',
 '{"value":0.79}'::jsonb,'manual_extraction','s5');

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000028');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 estimand,synthesis_type,synthesis_origin,method,result_summary,status,executed_at
) VALUES (
 '61000000-0000-0000-0000-000000000028',
 '60000000-0000-0000-0000-000000000028',
 '10000000-0000-0000-0000-000000000002',
 '60000000-0000-0000-0000-000000000027',
 'discrimination','prediction_performance_summary','structural_fixture',
 'structured_summary','{"development_c":0.82,"external_c":0.79}'::jsonb,
 'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.contribution(
 synthesis_version_uuid,result_version_uuid,contribution_role,included_main_analysis
) VALUES
('61000000-0000-0000-0000-000000000028','61000000-0000-0000-0000-000000000025','development_performance',true),
('61000000-0000-0000-0000-000000000028','61000000-0000-0000-0000-000000000026','external_validation_performance',true);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000029');

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
 outcome_entity_uuid,framework,framework_version,evidence_state,assessment_date,status
) VALUES (
 '61000000-0000-0000-0000-000000000029',
 '60000000-0000-0000-0000-000000000029',
 '10000000-0000-0000-0000-000000000002',
 '61000000-0000-0000-0000-000000000028',
 '60000000-0000-0000-0000-000000000027',
 'OES-PREDICTION-PILOT','s5-structural',
 'evidence_available',DATE '2026-10-04','active'
);

INSERT INTO product.product(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000030');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,status,conclusion_text
) VALUES (
 '61000000-0000-0000-0000-000000000030',
 '60000000-0000-0000-0000-000000000030',
 'evidence_sheet','S5 Prediction structural product','architecture_validation',
 DATE '2026-10-04','draft','Structural prediction-model fixture.'
);

INSERT INTO product.investigation_link VALUES
('61000000-0000-0000-0000-000000000030','10000000-0000-0000-0000-000000000002','primary',1);
INSERT INTO product.synthesis_link VALUES
('61000000-0000-0000-0000-000000000030','61000000-0000-0000-0000-000000000028','primary',1);
INSERT INTO product.certainty_link VALUES
('61000000-0000-0000-0000-000000000030','61000000-0000-0000-0000-000000000029','primary',1);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('61000000-0000-0000-0000-000000000022','61000000-0000-0000-0000-000000000025','report_supports_prediction_result','result_source'),
('61000000-0000-0000-0000-000000000023','61000000-0000-0000-0000-000000000026','report_supports_prediction_result','result_source'),
('61000000-0000-0000-0000-000000000025','61000000-0000-0000-0000-000000000028','prediction_result_informs_synthesis','synthesis.contribution'),
('61000000-0000-0000-0000-000000000026','61000000-0000-0000-0000-000000000028','prediction_result_informs_synthesis','synthesis.contribution'),
('61000000-0000-0000-0000-000000000028','61000000-0000-0000-0000-000000000029','prediction_synthesis_informs_confidence','certainty.synthesis_version_uuid'),
('61000000-0000-0000-0000-000000000029','61000000-0000-0000-0000-000000000030','certainty_informs_product','product.certainty_link');

-- ===========================================================================
-- S5-C — Qualitative synthesis / CERQual
-- ===========================================================================

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('60000000-0000-0000-0000-000000000040','OES-ST-2026-000240','Study','s5'),
('60000000-0000-0000-0000-000000000041','OES-ST-2026-000241','Study','s5'),
('60000000-0000-0000-0000-000000000042','OES-RP-2026-000240','Report','s5'),
('60000000-0000-0000-0000-000000000043','OES-RP-2026-000241','Report','s5'),
('60000000-0000-0000-0000-000000000044','OES-SY-2026-000240','Synthesis','s5'),
('60000000-0000-0000-0000-000000000045','OES-RF-2026-000201','ReviewFinding','s5'),
('60000000-0000-0000-0000-000000000046','OES-CE-2026-000240','CertaintyAssessment','s5'),
('60000000-0000-0000-0000-000000000047','OES-P-2026-000240','Product','s5');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('61000000-0000-0000-0000-000000000040','60000000-0000-0000-0000-000000000040',1,'current','s5','initial','Qualitative Study 1'),
('61000000-0000-0000-0000-000000000041','60000000-0000-0000-0000-000000000041',1,'current','s5','initial','Qualitative Study 2'),
('61000000-0000-0000-0000-000000000042','60000000-0000-0000-0000-000000000042',1,'current','s5','initial','Qualitative Report 1'),
('61000000-0000-0000-0000-000000000043','60000000-0000-0000-0000-000000000043',1,'current','s5','initial','Qualitative Report 2'),
('61000000-0000-0000-0000-000000000044','60000000-0000-0000-0000-000000000044',1,'current','s5','initial','Qualitative synthesis'),
('61000000-0000-0000-0000-000000000045','60000000-0000-0000-0000-000000000045',1,'current','s5','initial','Review finding'),
('61000000-0000-0000-0000-000000000046','60000000-0000-0000-0000-000000000046',1,'current','s5','initial','CERQual confidence'),
('61000000-0000-0000-0000-000000000047','60000000-0000-0000-0000-000000000047',1,'current','s5','initial','Qualitative product');

INSERT INTO evidence.study(entity_uuid) VALUES
('60000000-0000-0000-0000-000000000040'),
('60000000-0000-0000-0000-000000000041');

INSERT INTO evidence.study_version(
 version_uuid,entity_uuid,study_type,design,title_or_label,sample_size,status
) VALUES
('61000000-0000-0000-0000-000000000040','60000000-0000-0000-0000-000000000040',
 'qualitative_study','interviews','Qualitative Study 1',24,'active'),
('61000000-0000-0000-0000-000000000041','60000000-0000-0000-0000-000000000041',
 'qualitative_study','focus_groups','Qualitative Study 2',32,'active');

INSERT INTO evidence.report(entity_uuid) VALUES
('60000000-0000-0000-0000-000000000042'),
('60000000-0000-0000-0000-000000000043');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,
 publication_status,full_text_status,status
) VALUES
('61000000-0000-0000-0000-000000000042','60000000-0000-0000-0000-000000000042',
 'journal_article','Qualitative Report 1',DATE '2026-02-10','published','available','active'),
('61000000-0000-0000-0000-000000000043','60000000-0000-0000-0000-000000000043',
 'journal_article','Qualitative Report 2',DATE '2026-02-20','published','available','active');

INSERT INTO evidence.study_report_link(
 link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
 confidence,reviewer,decision_date,status
) VALUES
('61200000-0000-0000-0000-000000000040','60000000-0000-0000-0000-000000000040',
 '60000000-0000-0000-0000-000000000042','primary_report','confirmed','s5',DATE '2026-10-04','active'),
('61200000-0000-0000-0000-000000000041','60000000-0000-0000-0000-000000000041',
 '60000000-0000-0000-0000-000000000043','primary_report','confirmed','s5',DATE '2026-10-04','active');

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000044');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_type,
 synthesis_origin,method,result_summary,status,executed_at
) VALUES (
 '61000000-0000-0000-0000-000000000044',
 '60000000-0000-0000-0000-000000000044',
 '10000000-0000-0000-0000-000000000002',
 'qualitative_synthesis','new_calculation','thematic_synthesis',
 '{"fixture":true,"finding_count":1}'::jsonb,'active',CURRENT_TIMESTAMP
);

INSERT INTO synthesis.review_finding(entity_uuid,synthesis_entity_uuid)
VALUES (
 '60000000-0000-0000-0000-000000000045',
 '60000000-0000-0000-0000-000000000044'
);

INSERT INTO synthesis.review_finding_version(
 version_uuid,entity_uuid,finding_text,phenomenon,supporting_study_count,status
) VALUES (
 '61000000-0000-0000-0000-000000000045',
 '60000000-0000-0000-0000-000000000045',
 'Participants value clear explanations and continuity of care.',
 'care_experience',2,'active'
);

INSERT INTO synthesis.finding_contribution(
 review_finding_version_uuid,study_entity_uuid,report_entity_uuid,
 contribution_role,relevance_note,adequacy_note,notes
) VALUES
('61000000-0000-0000-0000-000000000045','60000000-0000-0000-0000-000000000040',
 '60000000-0000-0000-0000-000000000042','supporting','directly relevant','adequate','fixture'),
('61000000-0000-0000-0000-000000000045','60000000-0000-0000-0000-000000000041',
 '60000000-0000-0000-0000-000000000043','supporting','directly relevant','adequate','fixture');

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor
) VALUES
('61300000-0000-0000-0000-000000000040','61000000-0000-0000-0000-000000000045',
 '/finding_text','61000000-0000-0000-0000-000000000042','Results themes',
 '{"support":"clear explanations"}'::jsonb,'qualitative_synthesis','s5'),
('61300000-0000-0000-0000-000000000041','61000000-0000-0000-0000-000000000045',
 '/finding_text','61000000-0000-0000-0000-000000000043','Results themes',
 '{"support":"continuity of care"}'::jsonb,'qualitative_synthesis','s5');

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000046');

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
 review_finding_version_uuid,framework,framework_version,
 final_level,evidence_state,assessment_date,status
) VALUES (
 '61000000-0000-0000-0000-000000000046',
 '60000000-0000-0000-0000-000000000046',
 '10000000-0000-0000-0000-000000000002',
 '61000000-0000-0000-0000-000000000044',
 '61000000-0000-0000-0000-000000000045',
 'GRADE-CERQual','structural-fixture',
 'moderate','evidence_available',DATE '2026-10-04','active'
);

INSERT INTO appraisal.certainty_domain(
 certainty_assessment_version_uuid,domain_code,concern_level,
 rationale,reviewer,sequence_no
) VALUES
('61000000-0000-0000-0000-000000000046','methodological_limitations','minor',
 'Minor methodological limitations in fixture','s5',1),
('61000000-0000-0000-0000-000000000046','coherence','minor',
 'Finding coherent across both studies','s5',2),
('61000000-0000-0000-0000-000000000046','adequacy','minor',
 'Two contributing studies provide adequate fixture data','s5',3),
('61000000-0000-0000-0000-000000000046','relevance','minor',
 'Direct relevance to the fixture question','s5',4);

INSERT INTO product.product(entity_uuid)
VALUES ('60000000-0000-0000-0000-000000000047');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,status,conclusion_text
) VALUES (
 '61000000-0000-0000-0000-000000000047',
 '60000000-0000-0000-0000-000000000047',
 'evidence_sheet','S5 Qualitative CERQual structural product','architecture_validation',
 DATE '2026-10-04','draft','Structural qualitative/CERQual fixture.'
);

INSERT INTO product.investigation_link VALUES
('61000000-0000-0000-0000-000000000047','10000000-0000-0000-0000-000000000002','primary',1);
INSERT INTO product.synthesis_link VALUES
('61000000-0000-0000-0000-000000000047','61000000-0000-0000-0000-000000000044','primary',1);
INSERT INTO product.certainty_link VALUES
('61000000-0000-0000-0000-000000000047','61000000-0000-0000-0000-000000000046','primary',1);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('61000000-0000-0000-0000-000000000042','61000000-0000-0000-0000-000000000045','report_supports_review_finding','finding_contribution'),
('61000000-0000-0000-0000-000000000043','61000000-0000-0000-0000-000000000045','report_supports_review_finding','finding_contribution'),
('61000000-0000-0000-0000-000000000044','61000000-0000-0000-0000-000000000045','synthesis_contains_review_finding','review_finding'),
('61000000-0000-0000-0000-000000000045','61000000-0000-0000-0000-000000000046','review_finding_informs_cerqual','certainty.review_finding_version_uuid'),
('61000000-0000-0000-0000-000000000046','61000000-0000-0000-0000-000000000047','certainty_informs_product','product.certainty_link');

COMMIT;
