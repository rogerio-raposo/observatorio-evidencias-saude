-- OES Fase 3 — Overview of Reviews formal synthetic fixture
-- Requires baseline + migrations 002–019.
-- SYNTHETIC ONLY: all human actors and scientific records are fictional.

BEGIN;

-- ---------------------------------------------------------------------------
-- ARTIFACTS
-- ---------------------------------------------------------------------------

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,
    mime_type,original_filename,source_uri,created_at,created_by,status
) VALUES
('f9900000-0000-0000-0000-000000000001','protocol','fixtures/overview/protocol-v1.md','synthetic-overview-protocol-sha256','sha256','text/markdown','protocol-v1.md',NULL,TIMESTAMPTZ '2026-10-06 08:00:00-03','overview-fixture','active'),
('f9900000-0000-0000-0000-000000000011','search_export','fixtures/overview/pubmed.ris','synthetic-overview-pubmed-export','sha256','application/x-research-info-systems','pubmed.ris',NULL,TIMESTAMPTZ '2026-10-06 08:30:00-03','overview-fixture','active'),
('f9900000-0000-0000-0000-000000000012','search_export','fixtures/overview/epistemonikos.ris','synthetic-overview-epistemonikos-export','sha256','application/x-research-info-systems','epistemonikos.ris',NULL,TIMESTAMPTZ '2026-10-06 08:31:00-03','overview-fixture','active');

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f9000000-0000-0000-0000-000000000001','OES-Q-2026-001501','Question','overview-fixture'),
('f9000000-0000-0000-0000-000000000002','OES-I-2026-001501','Investigation','overview-fixture'),
('f9000000-0000-0000-0000-000000000020','OES-P-2026-001501','Product','overview-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f9100000-0000-0000-0000-000000000001','f9000000-0000-0000-0000-000000000001',1,'current','overview-fixture','initial','Synthetic Overview question'),
('f9100000-0000-0000-0000-000000000002','f9000000-0000-0000-0000-000000000002',1,'current','overview-fixture','initial','Synthetic formal Overview Investigation'),
('f9100000-0000-0000-0000-000000000020','f9000000-0000-0000-0000-000000000020',1,'current','overview-fixture','initial','Synthetic formal Overview Product');

INSERT INTO investigation.question(entity_uuid)
VALUES ('f9000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload,time_horizon_payload
) VALUES (
    'f9100000-0000-0000-0000-000000000001',
    'f9000000-0000-0000-0000-000000000001',
    'O que mostram três revisões sistemáticas sintéticas sobre a intervenção X?',
    'O que mostram as revisões sistemáticas sintéticas elegíveis sobre intervenção X versus controle para o outcome Y, considerando overlap, ROBIS, atualidade e certeza?',
    'effectiveness','PICO',
    '{"population":"synthetic adults","intervention":"X","comparator":"control","outcome":"Y","review_level":true}'::jsonb,
    '{"evidence_cutoff":"2026-10-06"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('f9000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'f9100000-0000-0000-0000-000000000002',
    'f9000000-0000-0000-0000-000000000002',
    'f9000000-0000-0000-0000-000000000001',
    'overview_of_reviews','N4','M0',
    'Validate the OES Overview of Reviews v0.1 contract with known overlap and formal synthetic human controls.',
    'f9900000-0000-0000-0000-000000000001',
    DATE '2026-10-06',DATE '2026-10-06','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'f9100000-0000-0000-0000-000000000002',
    'f9100000-0000-0000-0000-000000000001','primary',1
);

INSERT INTO artifact.entity_link(artifact_uuid,entity_version_uuid,role,sequence_no)
VALUES (
    'f9900000-0000-0000-0000-000000000001',
    'f9100000-0000-0000-0000-000000000002',
    'protocol',1
);

-- ---------------------------------------------------------------------------
-- METHOD POLICIES
-- ---------------------------------------------------------------------------

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,decision_type,stage,
    decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
    impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES
('f9200000-0000-0000-0000-000000000001','f9100000-0000-0000-0000-000000000002','other','screening','overview_systematic_review_definition',true,'Synthetic formal definition requires explicit systematic methods.',NULL,NULL,'{"required_study_type":"systematic_review"}'::jsonb,'accepted','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:05:00-03','active'),
('f9200000-0000-0000-0000-000000000002','f9100000-0000-0000-0000-000000000002','other','search','overview_search_coverage_policy',true,'Two bibliographic review sources are required in the fixture.',NULL,NULL,'{"minimum_bibliographic_sources":2,"required_source_names":["PubMed/MEDLINE","Epistemonikos"],"required_source_classes":["bibliographic_database"],"search_export_required":true,"grey_literature_required":false}'::jsonb,'accepted','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:06:00-03','active'),
('f9200000-0000-0000-0000-000000000003','f9100000-0000-0000-0000-000000000002','other','cross_cutting','overview_overlap_policy',true,'Use Study-level membership and prioritize one review in overlapping cluster.',NULL,NULL,'{"strategy":"prioritize_review","criteria":["question_fit","ROBIS","currentness","coverage"]}'::jsonb,'accepted','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:07:00-03','active'),
('f9200000-0000-0000-0000-000000000004','f9100000-0000-0000-0000-000000000002','other','cross_cutting','overview_currentness_policy',true,'Synthetic currentness uses review last-search date and protocol thresholds.',NULL,NULL,'{"current_after":"2024-01-01","possibly_outdated_after":"2022-01-01"}'::jsonb,'accepted','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:08:00-03','active'),
('f9200000-0000-0000-0000-000000000005','f9100000-0000-0000-0000-000000000002','other','certainty','overview_certainty_policy',true,'Collect review-reported certainty where available; do not create global Overview certainty.',NULL,NULL,'{"global_overview_certainty":false}'::jsonb,'accepted','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:09:00-03','active'),
('f9200000-0000-0000-0000-000000000006','f9100000-0000-0000-0000-000000000002','other','synthesis','overview_reanalysis_policy',true,'No new quantitative reanalysis in formal fixture.',NULL,NULL,'{"new_meta_analysis":false,"review_level_estimates":"separate"}'::jsonb,'accepted','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:10:00-03','active'),
('f9200000-0000-0000-0000-000000000007','f9100000-0000-0000-0000-000000000002','protocol_deviation','search','synthetic_resolved_search_deviation',false,'Synthetic non-material deviation retained to validate render-time audit projection.','{"risk":"fixture-only"}'::jsonb,'{"mitigation":"resolved before final synthesis"}'::jsonb,'{"material_effect":false}'::jsonb,'resolved','SYN_OV_LEAD',TIMESTAMPTZ '2026-10-06 08:11:00-03','active');

-- ---------------------------------------------------------------------------
-- QUALIFIED HUMAN ASSIGNMENTS / CONTROLS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.reviewer_assignment(
    reviewer_assignment_uuid,investigation_version_uuid,stage,
    actor,actor_type,role,qualification_payload,independent_flag,
    scope_payload,conflict_payload,assigned_at,record_status
) VALUES
('f9210000-0000-0000-0000-000000000001','f9100000-0000-0000-0000-000000000002','search','SYN_OV_SEARCH','human_expert','search_peer_reviewer','{"qualified":true,"basis":"synthetic information-retrieval qualification"}'::jsonb,true,'{"scope":"all review searches"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active'),
('f9210000-0000-0000-0000-000000000002','f9100000-0000-0000-0000-000000000002','screening','SYN_OV_R1','human_reviewer','primary_reviewer','{"qualified":true,"basis":"synthetic systematic-review screening qualification"}'::jsonb,true,'{"scope":"all records"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active'),
('f9210000-0000-0000-0000-000000000003','f9100000-0000-0000-0000-000000000002','screening','SYN_OV_R2','human_reviewer','secondary_reviewer','{"qualified":true,"basis":"synthetic systematic-review screening qualification"}'::jsonb,true,'{"scope":"all records"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active'),
('f9210000-0000-0000-0000-000000000004','f9100000-0000-0000-0000-000000000002','extraction','SYN_OV_EXTRACTOR','human_reviewer','data_extractor','{"qualified":true,"basis":"synthetic review-level extraction qualification"}'::jsonb,true,'{"scope":"all Overview extraction"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active'),
('f9210000-0000-0000-0000-000000000005','f9100000-0000-0000-0000-000000000002','extraction','SYN_OV_DATA_VERIFIER','human_reviewer','data_verifier','{"qualified":true,"basis":"synthetic overlap verification qualification"}'::jsonb,true,'{"scope":"membership and overlap"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active'),
('f9210000-0000-0000-0000-000000000006','f9100000-0000-0000-0000-000000000002','appraisal','SYN_OV_APPRAISER','human_expert','appraisal_reviewer','{"qualified":true,"basis":"synthetic ROBIS qualification"}'::jsonb,true,'{"scope":"all included reviews"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active'),
('f9210000-0000-0000-0000-000000000007','f9100000-0000-0000-0000-000000000002','cross_cutting','SYN_OV_EXPERT','human_expert','expert_independent_reviewer','{"qualified":true,"basis":"synthetic Overview methodology qualification"}'::jsonb,true,'{"scope":"final Overview"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:15:00-03','active');

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,performed_at,notes,record_status
) VALUES
('f9220000-0000-0000-0000-000000000001','f9100000-0000-0000-0000-000000000002','search','search_strategy_peer_review','SYN_OV_SEARCH','human_expert','{"qualified":true,"basis":"synthetic information-retrieval qualification"}'::jsonb,true,'passed','{"control_code":"overview_search_peer_review","scope":"all searches"}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','Synthetic search peer review.','active'),
('f9220000-0000-0000-0000-000000000002','f9100000-0000-0000-0000-000000000002','screening','screening_secondary_verification','SYN_OV_R2','human_reviewer','{"qualified":true,"basis":"synthetic systematic-review screening qualification"}'::jsonb,true,'passed','{"control_code":"overview_screening_verification","scope":"all records"}'::jsonb,TIMESTAMPTZ '2026-10-06 10:30:00-03','Synthetic independent screening verification.','active'),
('f9220000-0000-0000-0000-000000000003','f9100000-0000-0000-0000-000000000002','appraisal','risk_of_bias_verification','SYN_OV_APPRAISER','human_expert','{"qualified":true,"basis":"synthetic ROBIS qualification"}'::jsonb,true,'passed','{"control_code":"overview_robis_verification","scope":"Reviews A/B/C"}'::jsonb,TIMESTAMPTZ '2026-10-06 12:00:00-03','Synthetic independent ROBIS verification.','active'),
('f9220000-0000-0000-0000-000000000004','f9100000-0000-0000-0000-000000000002','extraction','other','SYN_OV_DATA_VERIFIER','human_reviewer','{"qualified":true,"basis":"synthetic overlap verification qualification"}'::jsonb,true,'passed','{"control_code":"overview_overlap_verification","scope":"9 memberships and cluster"}'::jsonb,TIMESTAMPTZ '2026-10-06 12:10:00-03','Synthetic independent membership/overlap verification.','active');

-- ---------------------------------------------------------------------------
-- REVIEW STUDIES / PRIMARY STUDIES / OUTCOME
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f9300000-0000-0000-0000-000000000101','OES-ST-2026-001501','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000102','OES-ST-2026-001502','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000103','OES-ST-2026-001503','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000201','OES-ST-2026-001511','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000202','OES-ST-2026-001512','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000203','OES-ST-2026-001513','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000204','OES-ST-2026-001514','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000205','OES-ST-2026-001515','Study','overview-fixture'),
('f9300000-0000-0000-0000-000000000301','OES-O-2026-001501','Outcome','overview-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f9310000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000101',1,'current','overview-fixture','initial','Synthetic Review A'),
('f9310000-0000-0000-0000-000000000102','f9300000-0000-0000-0000-000000000102',1,'current','overview-fixture','initial','Synthetic Review B'),
('f9310000-0000-0000-0000-000000000103','f9300000-0000-0000-0000-000000000103',1,'current','overview-fixture','initial','Synthetic Review C'),
('f9310000-0000-0000-0000-000000000201','f9300000-0000-0000-0000-000000000201',1,'current','overview-fixture','initial','Primary Study 1'),
('f9310000-0000-0000-0000-000000000202','f9300000-0000-0000-0000-000000000202',1,'current','overview-fixture','initial','Primary Study 2'),
('f9310000-0000-0000-0000-000000000203','f9300000-0000-0000-0000-000000000203',1,'current','overview-fixture','initial','Primary Study 3'),
('f9310000-0000-0000-0000-000000000204','f9300000-0000-0000-0000-000000000204',1,'current','overview-fixture','initial','Primary Study 4'),
('f9310000-0000-0000-0000-000000000205','f9300000-0000-0000-0000-000000000205',1,'current','overview-fixture','initial','Primary Study 5'),
('f9310000-0000-0000-0000-000000000301','f9300000-0000-0000-0000-000000000301',1,'current','overview-fixture','initial','Outcome Y');

INSERT INTO evidence.study(entity_uuid)
VALUES
('f9300000-0000-0000-0000-000000000101'),
('f9300000-0000-0000-0000-000000000102'),
('f9300000-0000-0000-0000-000000000103'),
('f9300000-0000-0000-0000-000000000201'),
('f9300000-0000-0000-0000-000000000202'),
('f9300000-0000-0000-0000-000000000203'),
('f9300000-0000-0000-0000-000000000204'),
('f9300000-0000-0000-0000-000000000205');

INSERT INTO evidence.study_version(
    version_uuid,entity_uuid,study_type,design,title_or_label,
    sample_size,status
) VALUES
('f9310000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000101','systematic_review','systematic review with meta-analysis','Synthetic Review A',3000,'active'),
('f9310000-0000-0000-0000-000000000102','f9300000-0000-0000-0000-000000000102','systematic_review','systematic review with meta-analysis','Synthetic Review B',4200,'active'),
('f9310000-0000-0000-0000-000000000103','f9300000-0000-0000-0000-000000000103','systematic_review','systematic review with meta-analysis','Synthetic Review C',2800,'active'),
('f9310000-0000-0000-0000-000000000201','f9300000-0000-0000-0000-000000000201','randomized_trial','parallel RCT','Primary Study 1',500,'active'),
('f9310000-0000-0000-0000-000000000202','f9300000-0000-0000-0000-000000000202','randomized_trial','parallel RCT','Primary Study 2',600,'active'),
('f9310000-0000-0000-0000-000000000203','f9300000-0000-0000-0000-000000000203','randomized_trial','parallel RCT','Primary Study 3',700,'active'),
('f9310000-0000-0000-0000-000000000204','f9300000-0000-0000-0000-000000000204','randomized_trial','parallel RCT','Primary Study 4',800,'active'),
('f9310000-0000-0000-0000-000000000205','f9300000-0000-0000-0000-000000000205','randomized_trial','parallel RCT','Primary Study 5',900,'active');

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('f9300000-0000-0000-0000-000000000301');

INSERT INTO evidence.outcome_version(
    version_uuid,entity_uuid,preferred_name,definition,domain,
    direction_of_benefit,unit_family,status
) VALUES (
    'f9310000-0000-0000-0000-000000000301',
    'f9300000-0000-0000-0000-000000000301',
    'Outcome Y','Synthetic critical outcome','clinical','lower','relative_effect','active'
);

-- ---------------------------------------------------------------------------
-- REVIEW REPORTS, INCLUDING UPDATE RELATION FOR REVIEW A
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f9300000-0000-0000-0000-000000000401','OES-R-2026-001501','Report','overview-fixture'),
('f9300000-0000-0000-0000-000000000402','OES-R-2026-001502','Report','overview-fixture'),
('f9300000-0000-0000-0000-000000000403','OES-R-2026-001503','Report','overview-fixture'),
('f9300000-0000-0000-0000-000000000404','OES-R-2026-001504','Report','overview-fixture'),
('f9300000-0000-0000-0000-000000000405','OES-R-2026-001505','Report','overview-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f9310000-0000-0000-0000-000000000401','f9300000-0000-0000-0000-000000000401',1,'current','overview-fixture','initial','Review A original report'),
('f9310000-0000-0000-0000-000000000402','f9300000-0000-0000-0000-000000000402',1,'current','overview-fixture','initial','Review A update report'),
('f9310000-0000-0000-0000-000000000403','f9300000-0000-0000-0000-000000000403',1,'current','overview-fixture','initial','Review B report'),
('f9310000-0000-0000-0000-000000000404','f9300000-0000-0000-0000-000000000404',1,'current','overview-fixture','initial','Review C report'),
('f9310000-0000-0000-0000-000000000405','f9300000-0000-0000-0000-000000000405',1,'current','overview-fixture','initial','Excluded candidate review report');

INSERT INTO evidence.report(entity_uuid)
VALUES
('f9300000-0000-0000-0000-000000000401'),
('f9300000-0000-0000-0000-000000000402'),
('f9300000-0000-0000-0000-000000000403'),
('f9300000-0000-0000-0000-000000000404'),
('f9300000-0000-0000-0000-000000000405');

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES
('f9310000-0000-0000-0000-000000000401','f9300000-0000-0000-0000-000000000401','journal_article','Synthetic Review A — original',DATE '2021-01-01','Synthetic Journal','en','published','available','{"doi":"10.synthetic/ova0"}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000402','f9300000-0000-0000-0000-000000000402','journal_article','Synthetic Review A — update',DATE '2025-01-01','Synthetic Journal','en','published','available','{"doi":"10.synthetic/ova1"}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000403','f9300000-0000-0000-0000-000000000403','journal_article','Synthetic Review B',DATE '2026-01-15','Synthetic Journal','en','published','available','{"doi":"10.synthetic/ovb"}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000404','f9300000-0000-0000-0000-000000000404','journal_article','Synthetic Review C',DATE '2023-01-15','Synthetic Journal','en','published','available','{"doi":"10.synthetic/ovc"}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000405','f9300000-0000-0000-0000-000000000405','journal_article','Synthetic narrative candidate',DATE '2024-01-15','Synthetic Journal','en','published','available','{"doi":"10.synthetic/ovx"}'::jsonb,'active');

INSERT INTO evidence.study_report_link(
    link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
    confidence,evidence_note,reviewer,decision_date,status
) VALUES
('f9320000-0000-0000-0000-000000000401','f9300000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000401','primary','high','Original publication','SYN_OV_R1',DATE '2026-10-06','active'),
('f9320000-0000-0000-0000-000000000402','f9300000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000402','update','high','Update publication','SYN_OV_R1',DATE '2026-10-06','active'),
('f9320000-0000-0000-0000-000000000403','f9300000-0000-0000-0000-000000000102','f9300000-0000-0000-0000-000000000403','primary','high','Primary review publication','SYN_OV_R1',DATE '2026-10-06','active'),
('f9320000-0000-0000-0000-000000000404','f9300000-0000-0000-0000-000000000103','f9300000-0000-0000-0000-000000000404','primary','high','Primary review publication','SYN_OV_R1',DATE '2026-10-06','active');

INSERT INTO evidence.report_relation(
    relation_uuid,source_report_entity_uuid,target_report_entity_uuid,
    relation_type,relation_date,notes,status
) VALUES (
    'f9330000-0000-0000-0000-000000000001',
    'f9300000-0000-0000-0000-000000000402',
    'f9300000-0000-0000-0000-000000000401',
    'update_of',DATE '2025-01-01','Synthetic update relation','active'
);

-- ---------------------------------------------------------------------------
-- SEARCH / SCREENING
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,executed_at,
    result_count,strategy_version,operator,export_artifact_uuid,status
) VALUES
('f9400000-0000-0000-0000-000000000001','OES-SRCH-2026-001501','f9100000-0000-0000-0000-000000000002','PubMed/MEDLINE','PubMed','synthetic systematic review filter query','{"source_class":"bibliographic_database"}'::jsonb,TIMESTAMPTZ '2026-10-06 09:00:00-03',4,'overview-v1','SYN_OV_R1','f9900000-0000-0000-0000-000000000011','completed'),
('f9400000-0000-0000-0000-000000000002','OES-SRCH-2026-001502','f9100000-0000-0000-0000-000000000002','Epistemonikos','Epistemonikos','synthetic systematic review filter query','{"source_class":"bibliographic_database"}'::jsonb,TIMESTAMPTZ '2026-10-06 09:05:00-03',4,'overview-v1','SYN_OV_R1','f9900000-0000-0000-0000-000000000012','completed');

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
    source_record_id,raw_payload,raw_title,raw_year,raw_identifier,
    source_rank,resolution_status
) VALUES
('f9410000-0000-0000-0000-000000000001','OES-HIT-2026-001501','f9400000-0000-0000-0000-000000000001','f9300000-0000-0000-0000-000000000402','PM-A','{}'::jsonb,'Synthetic Review A update',2025,'10.synthetic/ova1',1,'linked'),
('f9410000-0000-0000-0000-000000000002','OES-HIT-2026-001502','f9400000-0000-0000-0000-000000000001','f9300000-0000-0000-0000-000000000403','PM-B','{}'::jsonb,'Synthetic Review B',2026,'10.synthetic/ovb',2,'linked'),
('f9410000-0000-0000-0000-000000000003','OES-HIT-2026-001503','f9400000-0000-0000-0000-000000000001','f9300000-0000-0000-0000-000000000404','PM-C','{}'::jsonb,'Synthetic Review C',2023,'10.synthetic/ovc',3,'linked'),
('f9410000-0000-0000-0000-000000000004','OES-HIT-2026-001504','f9400000-0000-0000-0000-000000000001','f9300000-0000-0000-0000-000000000405','PM-X','{}'::jsonb,'Synthetic narrative candidate',2024,'10.synthetic/ovx',4,'linked'),
('f9410000-0000-0000-0000-000000000005','OES-HIT-2026-001505','f9400000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000402','EP-A','{}'::jsonb,'Synthetic Review A update',2025,'10.synthetic/ova1',1,'linked'),
('f9410000-0000-0000-0000-000000000006','OES-HIT-2026-001506','f9400000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000403','EP-B','{}'::jsonb,'Synthetic Review B',2026,'10.synthetic/ovb',2,'linked'),
('f9410000-0000-0000-0000-000000000007','OES-HIT-2026-001507','f9400000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000404','EP-C','{}'::jsonb,'Synthetic Review C',2023,'10.synthetic/ovc',3,'linked'),
('f9410000-0000-0000-0000-000000000008','OES-HIT-2026-001508','f9400000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000405','EP-X','{}'::jsonb,'Synthetic narrative candidate',2024,'10.synthetic/ovx',4,'linked');

INSERT INTO investigation.screening_decision(
    screening_uuid,oes_screening_id,investigation_version_uuid,
    target_entity_uuid,stage,reviewer,decision,exclusion_reason,
    decided_at,adjudication_flag
) VALUES
('f9420000-0000-0000-0000-000000000001','OES-SCR-2026-001501','f9100000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000402','full_text','SYN_OV_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:00-03',false),
('f9420000-0000-0000-0000-000000000002','OES-SCR-2026-001502','f9100000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000403','full_text','SYN_OV_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:01:00-03',false),
('f9420000-0000-0000-0000-000000000003','OES-SCR-2026-001503','f9100000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000404','full_text','SYN_OV_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:02:00-03',false),
('f9420000-0000-0000-0000-000000000004','OES-SCR-2026-001504','f9100000-0000-0000-0000-000000000002','f9300000-0000-0000-0000-000000000405','full_text','SYN_OV_R1','exclude','Not a systematic review',TIMESTAMPTZ '2026-10-06 10:03:00-03',false);

-- ---------------------------------------------------------------------------
-- REVIEW ITEMS / MEMBERSHIP / CLUSTER / RESOLUTION
-- ---------------------------------------------------------------------------

INSERT INTO overview.review_item(
    review_item_uuid,investigation_version_uuid,review_study_version_uuid,
    item_role,eligibility_basis_payload,last_search_date,
    membership_completeness,currentness_status,currentness_rationale,
    included_at,status
) VALUES
('f9500000-0000-0000-0000-000000000101','f9100000-0000-0000-0000-000000000002','f9310000-0000-0000-0000-000000000101','supporting','{"basis":"eligible systematic review A"}'::jsonb,DATE '2024-12-01','complete','current',NULL,TIMESTAMPTZ '2026-10-06 11:00:00-03','active'),
('f9500000-0000-0000-0000-000000000102','f9100000-0000-0000-0000-000000000002','f9310000-0000-0000-0000-000000000102','primary','{"basis":"eligible systematic review B; best protocol-specified fit"}'::jsonb,DATE '2026-01-01','complete','current',NULL,TIMESTAMPTZ '2026-10-06 11:01:00-03','active'),
('f9500000-0000-0000-0000-000000000103','f9100000-0000-0000-0000-000000000002','f9310000-0000-0000-0000-000000000103','supporting','{"basis":"eligible systematic review C"}'::jsonb,DATE '2022-03-01','complete','outdated','Last search predates synthetic currentness threshold.',TIMESTAMPTZ '2026-10-06 11:02:00-03','active');

INSERT INTO overview.primary_study_membership(
    membership_uuid,review_item_uuid,primary_study_entity_uuid,
    source_report_version_uuid,source_location,identity_confidence,
    verification_status,verified_by,verifier_actor_type,verified_at,
    context_payload,status
) VALUES
('f9510000-0000-0000-0000-000000000001','f9500000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000201','f9310000-0000-0000-0000-000000000402','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:20:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000002','f9500000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000202','f9310000-0000-0000-0000-000000000402','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:20:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000003','f9500000-0000-0000-0000-000000000101','f9300000-0000-0000-0000-000000000203','f9310000-0000-0000-0000-000000000402','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:20:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000004','f9500000-0000-0000-0000-000000000102','f9300000-0000-0000-0000-000000000202','f9310000-0000-0000-0000-000000000403','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:21:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000005','f9500000-0000-0000-0000-000000000102','f9300000-0000-0000-0000-000000000203','f9310000-0000-0000-0000-000000000403','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:21:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000006','f9500000-0000-0000-0000-000000000102','f9300000-0000-0000-0000-000000000204','f9310000-0000-0000-0000-000000000403','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:21:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000007','f9500000-0000-0000-0000-000000000103','f9300000-0000-0000-0000-000000000203','f9310000-0000-0000-0000-000000000404','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:22:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000008','f9500000-0000-0000-0000-000000000103','f9300000-0000-0000-0000-000000000204','f9310000-0000-0000-0000-000000000404','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:22:00-03','{}'::jsonb,'active'),
('f9510000-0000-0000-0000-000000000009','f9500000-0000-0000-0000-000000000103','f9300000-0000-0000-0000-000000000205','f9310000-0000-0000-0000-000000000404','Included studies table','high','human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 11:22:00-03','{}'::jsonb,'active');

INSERT INTO overview.review_cluster(
    cluster_uuid,investigation_version_uuid,cluster_code,label,
    scope_payload,status
) VALUES (
    'f9520000-0000-0000-0000-000000000001',
    'f9100000-0000-0000-0000-000000000002',
    'X_vs_control_Y',
    'Intervention X versus control — Outcome Y',
    '{"population":"synthetic adults","intervention":"X","comparator":"control","outcome":"Y"}'::jsonb,
    'active'
);

INSERT INTO overview.cluster_membership(
    cluster_uuid,review_item_uuid,analysis_disposition,rationale,sequence_no,status
) VALUES
('f9520000-0000-0000-0000-000000000001','f9500000-0000-0000-0000-000000000101','excluded_overlap','Eligible but not prioritized after protocol-specified overlap criteria.',1,'active'),
('f9520000-0000-0000-0000-000000000001','f9500000-0000-0000-0000-000000000102','prioritized','Best question fit, low ROBIS, most current and broadest relevant coverage.',2,'active'),
('f9520000-0000-0000-0000-000000000001','f9500000-0000-0000-0000-000000000103','excluded_overlap','Eligible but outdated and high ROBIS; retained for concordance context only.',3,'active');

INSERT INTO overview.overlap_resolution(
    overlap_resolution_uuid,cluster_uuid,strategy,decision_payload,rationale,
    decided_by,actor_type,verification_status,verified_by,
    verifier_actor_type,verified_at,decided_at,status
) VALUES (
    'f9530000-0000-0000-0000-000000000001',
    'f9520000-0000-0000-0000-000000000001',
    'prioritize_review',
    '{"criteria":["question_fit","ROBIS","currentness","coverage"],"prioritized_review_item_uuid":"f9500000-0000-0000-0000-000000000102"}'::jsonb,
    'Protocol-specified prioritization avoids double counting among highly overlapping reviews.',
    'SYN_OV_R1','human_reviewer','human_consensus',
    'SYN_OV_DATA_VERIFIER','human_reviewer',
    TIMESTAMPTZ '2026-10-06 12:15:00-03',
    TIMESTAMPTZ '2026-10-06 12:14:00-03','active'
);

-- ---------------------------------------------------------------------------
-- REVIEW-LEVEL RESULTS / CERTAINTY
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f9300000-0000-0000-0000-000000000501','OES-RSLT-2026-001501','Result','overview-fixture'),
('f9300000-0000-0000-0000-000000000502','OES-RSLT-2026-001502','Result','overview-fixture'),
('f9300000-0000-0000-0000-000000000503','OES-RSLT-2026-001503','Result','overview-fixture'),
('f9300000-0000-0000-0000-000000000601','OES-CA-2026-001501','CertaintyAssessment','overview-fixture'),
('f9300000-0000-0000-0000-000000000602','OES-CA-2026-001502','CertaintyAssessment','overview-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f9310000-0000-0000-0000-000000000501','f9300000-0000-0000-0000-000000000501',1,'current','overview-fixture','initial','Review A effect estimate'),
('f9310000-0000-0000-0000-000000000502','f9300000-0000-0000-0000-000000000502',1,'current','overview-fixture','initial','Review B effect estimate'),
('f9310000-0000-0000-0000-000000000503','f9300000-0000-0000-0000-000000000503',1,'current','overview-fixture','initial','Review C effect estimate'),
('f9310000-0000-0000-0000-000000000601','f9300000-0000-0000-0000-000000000601',1,'current','overview-fixture','initial','Review A reported certainty'),
('f9310000-0000-0000-0000-000000000602','f9300000-0000-0000-0000-000000000602',1,'current','overview-fixture','initial','Review B reported certainty');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid)
VALUES
('f9300000-0000-0000-0000-000000000501','f9300000-0000-0000-0000-000000000101'),
('f9300000-0000-0000-0000-000000000502','f9300000-0000-0000-0000-000000000102'),
('f9300000-0000-0000-0000-000000000503','f9300000-0000-0000-0000-000000000103');

INSERT INTO evidence.result_version(
    version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,
    timepoint_label,estimand,measure,reported_value,ci_lower,ci_upper,
    unit,adjusted_flag,analysis_population,missing_data_state,
    method_payload,status
) VALUES
('f9310000-0000-0000-0000-000000000501','f9300000-0000-0000-0000-000000000501','f9300000-0000-0000-0000-000000000301','{"population":"synthetic adults"}'::jsonb,'longest follow-up','relative effect','risk_ratio','{"value":0.82}'::jsonb,0.70,0.96,'ratio',false,'review pooled','not_reported','{"I2":25}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000502','f9300000-0000-0000-0000-000000000502','f9300000-0000-0000-0000-000000000301','{"population":"synthetic adults"}'::jsonb,'longest follow-up','relative effect','risk_ratio','{"value":0.78}'::jsonb,0.68,0.90,'ratio',false,'review pooled','not_reported','{"I2":20}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000503','f9300000-0000-0000-0000-000000000503','f9300000-0000-0000-0000-000000000301','{"population":"synthetic adults"}'::jsonb,'longest follow-up','relative effect','risk_ratio','{"value":0.92}'::jsonb,0.74,1.14,'ratio',false,'review pooled','not_reported','{"I2":60}'::jsonb,'active');

INSERT INTO evidence.result_source(
    result_version_uuid,report_version_uuid,source_location,source_type,
    original_text_or_value,extraction_method,is_primary_source,
    extractor,extracted_at
) VALUES
('f9310000-0000-0000-0000-000000000501','f9310000-0000-0000-0000-000000000402','Main meta-analysis','review_report','{"RR":0.82,"CI":[0.70,0.96]}'::jsonb,'manual',true,'SYN_OV_EXTRACTOR',TIMESTAMPTZ '2026-10-06 11:40:00-03'),
('f9310000-0000-0000-0000-000000000502','f9310000-0000-0000-0000-000000000403','Main meta-analysis','review_report','{"RR":0.78,"CI":[0.68,0.90]}'::jsonb,'manual',true,'SYN_OV_EXTRACTOR',TIMESTAMPTZ '2026-10-06 11:41:00-03'),
('f9310000-0000-0000-0000-000000000503','f9310000-0000-0000-0000-000000000404','Main meta-analysis','review_report','{"RR":0.92,"CI":[0.74,1.14]}'::jsonb,'manual',true,'SYN_OV_EXTRACTOR',TIMESTAMPTZ '2026-10-06 11:42:00-03');

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES
('f9300000-0000-0000-0000-000000000601'),
('f9300000-0000-0000-0000-000000000602');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    synthesis_version_uuid,outcome_entity_uuid,framework,framework_version,
    initial_level,final_level,evidence_state,assessment_date,status
) VALUES
('f9310000-0000-0000-0000-000000000601','f9300000-0000-0000-0000-000000000601','f9100000-0000-0000-0000-000000000002',NULL,'f9300000-0000-0000-0000-000000000301','GRADE','review-reported','high','moderate','evidence_available',DATE '2026-10-06','active'),
('f9310000-0000-0000-0000-000000000602','f9300000-0000-0000-0000-000000000602','f9100000-0000-0000-0000-000000000002',NULL,'f9300000-0000-0000-0000-000000000301','GRADE','review-reported','high','high','evidence_available',DATE '2026-10-06','active');

INSERT INTO overview.outcome_evidence(
    outcome_evidence_uuid,review_item_uuid,result_version_uuid,
    synthesis_version_uuid,certainty_assessment_version_uuid,
    outcome_entity_uuid,comparison_payload,timepoint_payload,
    analysis_role,primary_study_set_status,extraction_payload,
    verification_status,verified_by,verifier_actor_type,verified_at,status
) VALUES
('f9540000-0000-0000-0000-000000000001','f9500000-0000-0000-0000-000000000101','f9310000-0000-0000-0000-000000000501',NULL,'f9310000-0000-0000-0000-000000000601','f9300000-0000-0000-0000-000000000301','{"intervention":"X","comparator":"control"}'::jsonb,'{"label":"longest follow-up"}'::jsonb,'excluded_overlap','complete','{"reported_studies":3,"reported_participants":3000}'::jsonb,'human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 12:20:00-03','active'),
('f9540000-0000-0000-0000-000000000002','f9500000-0000-0000-0000-000000000102','f9310000-0000-0000-0000-000000000502',NULL,'f9310000-0000-0000-0000-000000000602','f9300000-0000-0000-0000-000000000301','{"intervention":"X","comparator":"control"}'::jsonb,'{"label":"longest follow-up"}'::jsonb,'primary_estimate','complete','{"reported_studies":3,"reported_participants":4200}'::jsonb,'human_consensus','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 12:21:00-03','active'),
('f9540000-0000-0000-0000-000000000003','f9500000-0000-0000-0000-000000000103','f9310000-0000-0000-0000-000000000503',NULL,NULL,'f9300000-0000-0000-0000-000000000301','{"intervention":"X","comparator":"control"}'::jsonb,'{"label":"longest follow-up"}'::jsonb,'excluded_overlap','complete','{"reported_studies":3,"reported_participants":2800}'::jsonb,'human_verified','SYN_OV_DATA_VERIFIER','human_reviewer',TIMESTAMPTZ '2026-10-06 12:22:00-03','active');

-- ---------------------------------------------------------------------------
-- ROBIS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f9300000-0000-0000-0000-000000000701','OES-RA-2026-001501','RiskAssessment','overview-fixture'),
('f9300000-0000-0000-0000-000000000702','OES-RA-2026-001502','RiskAssessment','overview-fixture'),
('f9300000-0000-0000-0000-000000000703','OES-RA-2026-001503','RiskAssessment','overview-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f9310000-0000-0000-0000-000000000701','f9300000-0000-0000-0000-000000000701',1,'current','overview-fixture','initial','ROBIS Review A'),
('f9310000-0000-0000-0000-000000000702','f9300000-0000-0000-0000-000000000702',1,'current','overview-fixture','initial','ROBIS Review B'),
('f9310000-0000-0000-0000-000000000703','f9300000-0000-0000-0000-000000000703',1,'current','overview-fixture','initial','ROBIS Review C');

INSERT INTO appraisal.risk_assessment(entity_uuid)
VALUES
('f9300000-0000-0000-0000-000000000701'),
('f9300000-0000-0000-0000-000000000702'),
('f9300000-0000-0000-0000-000000000703');

INSERT INTO appraisal.risk_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,framework,
    framework_version,target_entity_uuid,outcome_entity_uuid,
    overall_judgement,assessor,assessment_date,verification_status,
    instrument_payload,status
) VALUES
('f9310000-0000-0000-0000-000000000701','f9300000-0000-0000-0000-000000000701','f9100000-0000-0000-0000-000000000002','ROBIS','1','f9300000-0000-0000-0000-000000000101',NULL,'low','SYN_OV_APPRAISER',DATE '2026-10-06','human_verified','{"synthetic":true}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000702','f9300000-0000-0000-0000-000000000702','f9100000-0000-0000-0000-000000000002','ROBIS','1','f9300000-0000-0000-0000-000000000102',NULL,'low','SYN_OV_APPRAISER',DATE '2026-10-06','human_verified','{"synthetic":true}'::jsonb,'active'),
('f9310000-0000-0000-0000-000000000703','f9300000-0000-0000-0000-000000000703','f9100000-0000-0000-0000-000000000002','ROBIS','1','f9300000-0000-0000-0000-000000000103',NULL,'high','SYN_OV_APPRAISER',DATE '2026-10-06','human_consensus','{"synthetic":true}'::jsonb,'active');

INSERT INTO appraisal.risk_assessment_domain(
    risk_assessment_version_uuid,domain_code,judgement,rationale,
    sequence_no,domain_payload
) VALUES
('f9310000-0000-0000-0000-000000000701','study_eligibility','low','Synthetic low concern.',1,'{}'::jsonb),
('f9310000-0000-0000-0000-000000000702','study_eligibility','low','Synthetic low concern.',1,'{}'::jsonb),
('f9310000-0000-0000-0000-000000000703','study_eligibility','high','Synthetic concern to exercise warning.',1,'{}'::jsonb);

-- ---------------------------------------------------------------------------
-- CONCORDANCE
-- ---------------------------------------------------------------------------

INSERT INTO overview.concordance_assessment(
    concordance_uuid,cluster_uuid,outcome_entity_uuid,
    comparison_payload,timepoint_payload,concordance_state,
    dimensions_payload,rationale,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    assessed_at,status
) VALUES (
    'f9550000-0000-0000-0000-000000000001',
    'f9520000-0000-0000-0000-000000000001',
    'f9300000-0000-0000-0000-000000000301',
    '{"intervention":"X","comparator":"control"}'::jsonb,
    '{"label":"longest follow-up"}'::jsonb,
    'magnitude_discordant',
    '{"direction":"mostly concordant benefit","magnitude":"Review C attenuated","certainty":"A/B reported, C absent"}'::jsonb,
    'Review-level estimates point in a similar direction, but Review C shows materially attenuated magnitude and lacks linked certainty.',
    'SYN_OV_R1','human_reviewer','human_consensus',
    'SYN_OV_DATA_VERIFIER','human_reviewer',
    TIMESTAMPTZ '2026-10-06 12:25:00-03',
    TIMESTAMPTZ '2026-10-06 12:24:00-03','active'
);

-- ---------------------------------------------------------------------------
-- DEPENDENCY LINEAGE FOR RENDERING AUDIT
-- ---------------------------------------------------------------------------

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,
    derivation_rule,status
) VALUES
('f9310000-0000-0000-0000-000000000101','f9100000-0000-0000-0000-000000000020','review_evidence_informs_overview','Synthetic Review A informs Overview','active'),
('f9310000-0000-0000-0000-000000000102','f9100000-0000-0000-0000-000000000020','review_evidence_informs_overview','Synthetic Review B informs Overview','active'),
('f9310000-0000-0000-0000-000000000103','f9100000-0000-0000-0000-000000000020','review_evidence_informs_overview','Synthetic Review C informs Overview','active'),
('f9310000-0000-0000-0000-000000000501','f9100000-0000-0000-0000-000000000020','outcome_evidence_informs_overview','Review A Result informs Overview','active'),
('f9310000-0000-0000-0000-000000000502','f9100000-0000-0000-0000-000000000020','outcome_evidence_informs_overview','Review B Result informs Overview','active'),
('f9310000-0000-0000-0000-000000000503','f9100000-0000-0000-0000-000000000020','outcome_evidence_informs_overview','Review C Result informs Overview','active');

-- ---------------------------------------------------------------------------
-- PRODUCT / ASSURANCE
-- ---------------------------------------------------------------------------

INSERT INTO product.product(entity_uuid)
VALUES ('f9000000-0000-0000-0000-000000000020');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'f9100000-0000-0000-0000-000000000020',
    'f9000000-0000-0000-0000-000000000020',
    'overview_of_reviews',
    'Synthetic Formal Overview of Reviews',
    'architecture_validation',
    DATE '2026-10-06',DATE '2026-10-06','published',
    'In the synthetic fixture, Review B is prioritized within one overlapping cluster; review-level estimates are directionally similar but differ in magnitude. Overlap is substantial and explicitly controlled rather than double counted.',
    'Synthetic contract-validation artifact only; no clinical applicability.',
    'Synthetic fixture with fictional studies, reviews, reviewers, ROBIS judgements and certainty ratings. It exists solely to validate architecture, overlap mathematics, gates and projection.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'f9100000-0000-0000-0000-000000000020',
    'f9100000-0000-0000-0000-000000000002',
    'primary',1
);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'f9800000-0000-0000-0000-000000000001',
    'f9100000-0000-0000-0000-000000000020',
    'current',TIMESTAMPTZ '2026-10-06 12:30:00-03','SYN_OV_LEAD',
    'Synthetic review searches current to fixture cutoff.','active'
);

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES
('f9800000-0000-0000-0000-000000000011','f9100000-0000-0000-0000-000000000020','ai_methodological_verification','SYN_OV_AI','ai_system',false,'passed',TIMESTAMPTZ '2026-10-06 12:31:00-03','Synthetic AI methodological verification.','{"fixture":true}'::jsonb,'active'),
('f9800000-0000-0000-0000-000000000012','f9100000-0000-0000-0000-000000000020','owner_governance_approval','SYN_OV_OWNER','owner',false,'approved',TIMESTAMPTZ '2026-10-06 12:32:00-03','Synthetic owner approval.','{"fixture":true}'::jsonb,'active'),
('f9800000-0000-0000-0000-000000000013','f9100000-0000-0000-0000-000000000020','expert_independent_review','SYN_OV_EXPERT','human_expert',true,'approved',TIMESTAMPTZ '2026-10-06 12:33:00-03','Synthetic expert review.','{"fixture":true}'::jsonb,'active');

COMMIT;
