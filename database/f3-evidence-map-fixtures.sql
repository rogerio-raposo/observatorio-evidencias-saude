-- OES Fase 3 — Evidence Map formal synthetic fixture
-- Requires baseline + migrations 002–016 and f3-rapid-evidence-synthesis-fixtures.sql.
-- SYNTHETIC ONLY: all named human reviewers/expert are fictional actors for contract validation.

BEGIN;

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,
    mime_type,original_filename,source_uri,created_at,created_by,status
) VALUES
('b4900000-0000-0000-0000-000000000001','protocol','fixtures/map/protocol-v1.md','synthetic-map-protocol-sha256','sha256','text/markdown','protocol-v1.md',NULL,TIMESTAMPTZ '2026-10-06 08:00:00-03','map-fixture','active'),
('b4900000-0000-0000-0000-000000000002','codebook','fixtures/map/codebook-v1.md','synthetic-map-codebook-sha256','sha256','text/markdown','codebook-v1.md',NULL,TIMESTAMPTZ '2026-10-06 08:05:00-03','map-fixture','active'),
('b4900000-0000-0000-0000-000000000011','search_export','fixtures/map/pubmed-export.ris','synthetic-map-pubmed-export','sha256','application/x-research-info-systems','pubmed-export.ris',NULL,TIMESTAMPTZ '2026-10-06 09:05:00-03','map-fixture','active'),
('b4900000-0000-0000-0000-000000000012','search_export','fixtures/map/central-export.ris','synthetic-map-central-export','sha256','application/x-research-info-systems','central-export.ris',NULL,TIMESTAMPTZ '2026-10-06 09:06:00-03','map-fixture','active'),
('b4900000-0000-0000-0000-000000000013','search_peer_review','fixtures/map/search-peer-review.md','synthetic-map-search-peer-review','sha256','text/markdown','search-peer-review.md',NULL,TIMESTAMPTZ '2026-10-06 08:45:00-03','map-fixture','active'),
('b4900000-0000-0000-0000-000000000014','classification_qc','fixtures/map/classification-qc.md','synthetic-map-classification-qc','sha256','text/markdown','classification-qc.md',NULL,TIMESTAMPTZ '2026-10-06 12:00:00-03','map-fixture','active');

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('b4000000-0000-0000-0000-000000000001','OES-Q-2026-001301','Question','map-fixture'),
('b4000000-0000-0000-0000-000000000002','OES-I-2026-001301','Investigation','map-fixture'),
('b4000000-0000-0000-0000-000000000010','OES-MF-2026-001301','MapFramework','map-fixture'),
('b4000000-0000-0000-0000-000000000020','OES-P-2026-001301','Product','map-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('b4100000-0000-0000-0000-000000000001','b4000000-0000-0000-0000-000000000001',1,'current','map-fixture','initial','Synthetic Evidence Map question'),
('b4100000-0000-0000-0000-000000000002','b4000000-0000-0000-0000-000000000002',1,'current','map-fixture','initial','Synthetic Evidence Map investigation'),
('b4100000-0000-0000-0000-000000000010','b4000000-0000-0000-0000-000000000010',1,'current','map-fixture','initial','Synthetic Evidence Map framework'),
('b4100000-0000-0000-0000-000000000020','b4000000-0000-0000-0000-000000000020',1,'current','map-fixture','initial','Synthetic formal evidence gap map product');

INSERT INTO investigation.question(entity_uuid)
VALUES ('b4000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload
) VALUES (
    'b4100000-0000-0000-0000-000000000001',
    'b4000000-0000-0000-0000-000000000001',
    'Como a evidência sintética se distribui entre intervenções e desfechos?',
    'Quais estudos e sínteses elegíveis ocupam as células intervenção × desfecho no escopo sintético definido?',
    'mapping','PCC',
    '{"population":"synthetic adults","concept":"interventions and outcomes","context":"formal synthetic map"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('b4000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'b4100000-0000-0000-0000-000000000002',
    'b4000000-0000-0000-0000-000000000002',
    'b4000000-0000-0000-0000-000000000001',
    'systematic_evidence_mapping','N3','M0',
    'Validate the OES Evidence Map v0.1 contract with a formal synthetic evidence gap map.',
    'b4900000-0000-0000-0000-000000000001',
    DATE '2026-10-06',DATE '2026-10-06','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'b4100000-0000-0000-0000-000000000002',
    'b4100000-0000-0000-0000-000000000001','primary',1
);

INSERT INTO artifact.entity_link(artifact_uuid,entity_version_uuid,role,sequence_no)
VALUES
('b4900000-0000-0000-0000-000000000001','b4100000-0000-0000-0000-000000000002','protocol',1),
('b4900000-0000-0000-0000-000000000002','b4100000-0000-0000-0000-000000000010','codebook',1);

INSERT INTO investigation.reviewer_assignment(
    reviewer_assignment_uuid,investigation_version_uuid,stage,
    actor,actor_type,role,qualification_payload,independent_flag,
    scope_payload,conflict_payload,assigned_at,record_status
) VALUES
('b4610000-0000-0000-0000-000000000001','b4100000-0000-0000-0000-000000000002','search','SYN_MAP_SEARCH_EXPERT','human_expert','search_peer_reviewer','{"qualified":true,"basis":"synthetic fixture qualification","domain":"information retrieval"}'::jsonb,true,'{"scope":"all map searches"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','active'),
('b4610000-0000-0000-0000-000000000002','b4100000-0000-0000-0000-000000000002','screening','SYN_MAP_R1','human_reviewer','primary_reviewer','{"qualified":true,"basis":"synthetic fixture qualification","domain":"systematic map screening"}'::jsonb,true,'{"scope":"all records"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','active'),
('b4610000-0000-0000-0000-000000000003','b4100000-0000-0000-0000-000000000002','screening','SYN_MAP_R2','human_reviewer','secondary_reviewer','{"qualified":true,"basis":"synthetic fixture qualification","domain":"systematic map screening"}'::jsonb,true,'{"scope":"all records"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','active'),
('b4610000-0000-0000-0000-000000000004','b4100000-0000-0000-0000-000000000002','extraction','SYN_MAP_R1','human_reviewer','data_extractor','{"qualified":true,"basis":"synthetic fixture qualification","domain":"map coding"}'::jsonb,true,'{"scope":"all required map dimensions"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','active'),
('b4610000-0000-0000-0000-000000000005','b4100000-0000-0000-0000-000000000002','extraction','SYN_MAP_R2','human_reviewer','data_verifier','{"qualified":true,"basis":"synthetic fixture qualification","domain":"map coding verification"}'::jsonb,true,'{"scope":"all required map dimensions"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','active'),
('b4610000-0000-0000-0000-000000000006','b4100000-0000-0000-0000-000000000002','cross_cutting','SYN_MAP_EXPERT','human_expert','expert_independent_reviewer','{"qualified":true,"basis":"synthetic fixture qualification","domain":"evidence mapping"}'::jsonb,true,'{"scope":"final synthetic map"}'::jsonb,'{"declared":false}'::jsonb,TIMESTAMPTZ '2026-10-06 08:20:00-03','active');

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,executed_at,
    result_count,strategy_version,operator,export_artifact_uuid,status
) VALUES
('b4200000-0000-0000-0000-000000000001','OES-SRCH-2026-001301','b4100000-0000-0000-0000-000000000002','PubMed/MEDLINE','PubMed','synthetic evidence mapping query','{"source_class":"bibliographic_database","fixture":true}'::jsonb,TIMESTAMPTZ '2026-10-06 09:00:00-03',2,'map-v1','MAP_FIXTURE','b4900000-0000-0000-0000-000000000011','completed'),
('b4200000-0000-0000-0000-000000000002','OES-SRCH-2026-001302','b4100000-0000-0000-0000-000000000002','CENTRAL','Cochrane Library','synthetic evidence mapping query','{"source_class":"bibliographic_database","fixture":true}'::jsonb,TIMESTAMPTZ '2026-10-06 09:01:00-03',2,'map-v1','MAP_FIXTURE','b4900000-0000-0000-0000-000000000012','completed');

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
    source_record_id,raw_payload,raw_title,raw_year,raw_identifier,
    source_rank,resolution_status
) VALUES
('b4250000-0000-0000-0000-000000000001','OES-HIT-2026-001301','b4200000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000201','PM-A','{"fixture":true}'::jsonb,'Synthetic randomized trial A',2025,'10.synthetic/n3a',1,'linked'),
('b4250000-0000-0000-0000-000000000002','OES-HIT-2026-001302','b4200000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000202','PM-B','{"fixture":true}'::jsonb,'Synthetic randomized trial B',2026,'10.synthetic/n3b',2,'linked'),
('b4250000-0000-0000-0000-000000000003','OES-HIT-2026-001303','b4200000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','CT-A','{"fixture":true}'::jsonb,'Synthetic randomized trial A',2025,'10.synthetic/n3a',1,'linked'),
('b4250000-0000-0000-0000-000000000004','OES-HIT-2026-001304','b4200000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','CT-B','{"fixture":true}'::jsonb,'Synthetic randomized trial B',2026,'10.synthetic/n3b',2,'linked');

INSERT INTO investigation.screening_decision(
    screening_uuid,oes_screening_id,investigation_version_uuid,
    target_entity_uuid,stage,reviewer,decision,exclusion_reason,
    decided_at,adjudication_flag
) VALUES
('b4350000-0000-0000-0000-000000000001','OES-SCR-2026-001301','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','title_abstract','SYN_MAP_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:00-03',false),
('b4350000-0000-0000-0000-000000000002','OES-SCR-2026-001302','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','title_abstract','SYN_MAP_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:02:00-03',false),
('b4350000-0000-0000-0000-000000000003','OES-SCR-2026-001303','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','full_text','SYN_MAP_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:04:00-03',false),
('b4350000-0000-0000-0000-000000000004','OES-SCR-2026-001304','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','full_text','SYN_MAP_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:06:00-03',false),
('b4350000-0000-0000-0000-000000000005','OES-SCR-2026-001305','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','title_abstract','SYN_MAP_R1','include',NULL,TIMESTAMPTZ '2026-10-06 11:00:00-03',false),
('b4350000-0000-0000-0000-000000000006','OES-SCR-2026-001306','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','title_abstract','SYN_MAP_R2','include',NULL,TIMESTAMPTZ '2026-10-06 11:02:00-03',false),
('b4350000-0000-0000-0000-000000000007','OES-SCR-2026-001307','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','full_text','SYN_MAP_R1','include',NULL,TIMESTAMPTZ '2026-10-06 11:04:00-03',false),
('b4350000-0000-0000-0000-000000000008','OES-SCR-2026-001308','b4100000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','full_text','SYN_MAP_R2','include',NULL,TIMESTAMPTZ '2026-10-06 11:06:00-03',false);

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,performed_at,evidence_artifact_uuid,notes,record_status
) VALUES
('b4620000-0000-0000-0000-000000000001','b4100000-0000-0000-0000-000000000002','search','search_strategy_peer_review','SYN_MAP_SEARCH_EXPERT','human_expert','{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,true,'passed','{"control_code":"map_search_peer_review","scope":"all strategies"}'::jsonb,TIMESTAMPTZ '2026-10-06 08:50:00-03','b4900000-0000-0000-0000-000000000013','Synthetic PRESS-style validation.','active'),
('b4620000-0000-0000-0000-000000000002','b4100000-0000-0000-0000-000000000002','screening','screening_secondary_verification','SYN_MAP_R2','human_reviewer','{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,true,'passed','{"control_code":"map_screening_verification","scope":"all screened reports"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:00:00-03',NULL,'Synthetic duplicate screening verified.','active'),
('b4620000-0000-0000-0000-000000000003','b4100000-0000-0000-0000-000000000002','extraction','other','SYN_MAP_R2','human_reviewer','{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,true,'passed','{"control_code":"map_classification_verification","scope":"framework b410...0010; all required dimensions and items"}'::jsonb,TIMESTAMPTZ '2026-10-06 12:05:00-03','b4900000-0000-0000-0000-000000000014','Synthetic independent map classification verification.','active');

INSERT INTO mapping.framework(entity_uuid)
VALUES ('b4000000-0000-0000-0000-000000000010');

INSERT INTO mapping.framework_version(
    version_uuid,entity_uuid,investigation_version_uuid,mapping_subtype,
    coverage_claim,gap_claim_mode,counting_unit_policy,codebook_artifact_uuid,
    primary_row_dimension_code,primary_column_dimension_code,
    classification_policy_payload,coverage_policy_payload,gap_rules_payload,
    visualization_payload,stakeholder_payload,status
) VALUES (
    'b4100000-0000-0000-0000-000000000010',
    'b4000000-0000-0000-0000-000000000010',
    'b4100000-0000-0000-0000-000000000002',
    'evidence_gap_map','systematic_comprehensive','formal_within_scope','study',
    'b4900000-0000-0000-0000-000000000002',
    'intervention','outcome',
    '{"independent_coding":true,"consensus_required_on_disagreement":true}'::jsonb,
    '{"minimum_bibliographic_sources":2,"required_source_names":["PubMed/MEDLINE","CENTRAL"],"required_source_classes":["bibliographic_database"],"search_export_required":true,"grey_literature_required":false}'::jsonb,
    '{"derive_synthesis_gap":true}'::jsonb,
    '{"default":"matrix","display_counts_by_type":true}'::jsonb,
    '{"engaged":false,"reason":"synthetic contract fixture"}'::jsonb,
    'active'
);

INSERT INTO mapping.dimension(
    dimension_uuid,framework_version_uuid,dimension_code,label,description,
    dimension_role,multi_valued,required_flag,sequence_no,metadata_payload,status
) VALUES
('b4400000-0000-0000-0000-000000000001','b4100000-0000-0000-0000-000000000010','intervention','Intervention','Synthetic intervention axis','row_axis',false,true,1,'{}'::jsonb,'active'),
('b4400000-0000-0000-0000-000000000002','b4100000-0000-0000-0000-000000000010','outcome','Outcome','Synthetic outcome axis','column_axis',false,true,2,'{}'::jsonb,'active'),
('b4400000-0000-0000-0000-000000000003','b4100000-0000-0000-0000-000000000010','geography','Geography','Synthetic geography filter','filter',false,true,3,'{}'::jsonb,'active');

INSERT INTO mapping.category(
    category_uuid,dimension_uuid,parent_category_uuid,category_code,label,
    definition,sequence_no,metadata_payload,status
) VALUES
('b4410000-0000-0000-0000-000000000001','b4400000-0000-0000-0000-000000000001',NULL,'A','Intervention A','Synthetic intervention A',1,'{}'::jsonb,'active'),
('b4410000-0000-0000-0000-000000000002','b4400000-0000-0000-0000-000000000001',NULL,'B','Intervention B','Synthetic intervention B',2,'{}'::jsonb,'active'),
('b4410000-0000-0000-0000-000000000011','b4400000-0000-0000-0000-000000000002',NULL,'Y','Outcome Y','Synthetic outcome Y',1,'{}'::jsonb,'active'),
('b4410000-0000-0000-0000-000000000012','b4400000-0000-0000-0000-000000000002',NULL,'Z','Outcome Z','Synthetic outcome Z',2,'{}'::jsonb,'active'),
('b4410000-0000-0000-0000-000000000021','b4400000-0000-0000-0000-000000000003',NULL,'BR','Brazil','Synthetic geography filter',1,'{}'::jsonb,'active');

INSERT INTO mapping.map_item(
    map_item_uuid,framework_version_uuid,target_version_uuid,item_role,
    inclusion_basis_payload,included_at,status
) VALUES
('b4500000-0000-0000-0000-000000000101','b4100000-0000-0000-0000-000000000010','d1000000-0000-0000-0000-000000000101','primary_evidence','{"basis":"eligible synthetic Study A"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:30:00-03','active'),
('b4500000-0000-0000-0000-000000000102','b4100000-0000-0000-0000-000000000010','d1000000-0000-0000-0000-000000000102','primary_evidence','{"basis":"eligible synthetic Study B"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:30:00-03','active'),
('b4500000-0000-0000-0000-000000000201','b4100000-0000-0000-0000-000000000010','d1000000-0000-0000-0000-000000000201','contextual','{"basis":"Report for Study A; included to test count semantics"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:30:00-03','active'),
('b4500000-0000-0000-0000-000000000501','b4100000-0000-0000-0000-000000000010','d1000000-0000-0000-0000-000000000501','synthesis','{"basis":"eligible synthetic synthesis"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:30:00-03','active');

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
('d1000000-0000-0000-0000-000000000101','b4100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MapItem inclusion','active'),
('d1000000-0000-0000-0000-000000000102','b4100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MapItem inclusion','active'),
('d1000000-0000-0000-0000-000000000201','b4100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MapItem inclusion','active'),
('d1000000-0000-0000-0000-000000000501','b4100000-0000-0000-0000-000000000010','mapped_evidence_informs_framework','MapItem inclusion','active');

INSERT INTO mapping.assignment(
    assignment_uuid,map_item_uuid,category_uuid,decision_state,
    assigned_by,actor_type,assignment_method,verification_status,
    verified_by,verifier_actor_type,verified_at,rationale_payload,assigned_at,status
) VALUES
('b4600000-0000-0000-0000-000000000001','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:31:01-03','active'),
('b4600000-0000-0000-0000-000000000002','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:31:02-03','active'),
('b4600000-0000-0000-0000-000000000003','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000001','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:41:03-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:41:03-03','active'),
('b4600000-0000-0000-0000-000000000004','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:31:04-03','active'),
('b4600000-0000-0000-0000-000000000005','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:31:05-03','active'),
('b4600000-0000-0000-0000-000000000006','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000011','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:41:06-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:41:06-03','active'),
('b4600000-0000-0000-0000-000000000007','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:31:07-03','active'),
('b4600000-0000-0000-0000-000000000008','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:31:08-03','active'),
('b4600000-0000-0000-0000-000000000009','b4500000-0000-0000-0000-000000000101','b4410000-0000-0000-0000-000000000021','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:41:09-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:41:09-03','active'),
('b4600000-0000-0000-0000-000000000010','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000002','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:32:10-03','active'),
('b4600000-0000-0000-0000-000000000011','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:32:11-03','active'),
('b4600000-0000-0000-0000-000000000012','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000002','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:42:12-03','{"resolution":"consensus after disagreement"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:42:12-03','active'),
('b4600000-0000-0000-0000-000000000013','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:32:13-03','active'),
('b4600000-0000-0000-0000-000000000014','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:32:14-03','active'),
('b4600000-0000-0000-0000-000000000015','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000011','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:42:15-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:42:15-03','active'),
('b4600000-0000-0000-0000-000000000016','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:32:16-03','active'),
('b4600000-0000-0000-0000-000000000017','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:32:17-03','active'),
('b4600000-0000-0000-0000-000000000018','b4500000-0000-0000-0000-000000000102','b4410000-0000-0000-0000-000000000021','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:42:18-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:42:18-03','active'),
('b4600000-0000-0000-0000-000000000019','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:33:19-03','active'),
('b4600000-0000-0000-0000-000000000020','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:33:20-03','active'),
('b4600000-0000-0000-0000-000000000021','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000001','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:43:21-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:43:21-03','active'),
('b4600000-0000-0000-0000-000000000022','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:33:22-03','active'),
('b4600000-0000-0000-0000-000000000023','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:33:23-03','active'),
('b4600000-0000-0000-0000-000000000024','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000011','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:43:24-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:43:24-03','active'),
('b4600000-0000-0000-0000-000000000025','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:33:25-03','active'),
('b4600000-0000-0000-0000-000000000026','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:33:26-03','active'),
('b4600000-0000-0000-0000-000000000027','b4500000-0000-0000-0000-000000000201','b4410000-0000-0000-0000-000000000021','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:43:27-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:43:27-03','active'),
('b4600000-0000-0000-0000-000000000028','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:34:28-03','active'),
('b4600000-0000-0000-0000-000000000029','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000001','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:34:29-03','active'),
('b4600000-0000-0000-0000-000000000030','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000001','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:44:30-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:44:30-03','active'),
('b4600000-0000-0000-0000-000000000031','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:34:31-03','active'),
('b4600000-0000-0000-0000-000000000032','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000011','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:34:32-03','active'),
('b4600000-0000-0000-0000-000000000033','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000011','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:44:33-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:44:33-03','active'),
('b4600000-0000-0000-0000-000000000034','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R1','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:34:34-03','active'),
('b4600000-0000-0000-0000-000000000035','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000021','candidate','SYN_MAP_R2','human_reviewer','manual','unverified',NULL,NULL,NULL,'{"independent_coding":true}'::jsonb,TIMESTAMPTZ '2026-10-06 11:34:35-03','active'),
('b4600000-0000-0000-0000-000000000036','b4500000-0000-0000-0000-000000000501','b4410000-0000-0000-0000-000000000021','final','SYN_MAP_R1','human_reviewer','consensus','human_consensus','SYN_MAP_R2','human_reviewer',TIMESTAMPTZ '2026-10-06 11:44:36-03','{"resolution":"consensus confirmed concordant coding"}'::jsonb,TIMESTAMPTZ '2026-10-06 11:44:36-03','active');

INSERT INTO mapping.cell_scope(
    cell_scope_uuid,framework_version_uuid,row_category_uuid,column_category_uuid,
    scope_status,gap_eligible,rationale,metadata_payload
) VALUES
('b4700000-0000-0000-0000-000000000001','b4100000-0000-0000-0000-000000000010','b4410000-0000-0000-0000-000000000001','b4410000-0000-0000-0000-000000000011','in_scope',true,'A × Y is in scope and populated.','{}'::jsonb),
('b4700000-0000-0000-0000-000000000002','b4100000-0000-0000-0000-000000000010','b4410000-0000-0000-0000-000000000002','b4410000-0000-0000-0000-000000000011','in_scope',true,'B × Y is in scope and populated.','{}'::jsonb),
('b4700000-0000-0000-0000-000000000003','b4100000-0000-0000-0000-000000000010','b4410000-0000-0000-0000-000000000001','b4410000-0000-0000-0000-000000000012','in_scope',true,'A × Z is a deliberately empty formal-gap cell.','{}'::jsonb),
('b4700000-0000-0000-0000-000000000004','b4100000-0000-0000-0000-000000000010','b4410000-0000-0000-0000-000000000002','b4410000-0000-0000-0000-000000000012','not_applicable',false,'B × Z is structurally not applicable and must not become a gap.','{}'::jsonb);

INSERT INTO product.product(entity_uuid)
VALUES ('b4000000-0000-0000-0000-000000000020');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'b4100000-0000-0000-0000-000000000020',
    'b4000000-0000-0000-0000-000000000020',
    'evidence_map','Synthetic Formal Evidence Gap Map',
    'architecture_validation',DATE '2026-10-06',DATE '2026-10-06','published',
    'Synthetic evidence is distributed across two populated cells; A × Z is a formal within-scope empty-cell gap in this fixture.',
    'Synthetic contract-validation artifact only; no real-world clinical applicability.',
    'Synthetic fixture with fictional reviewers and deliberately small evidence set. Counts and gaps validate architecture only.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'b4100000-0000-0000-0000-000000000020',
    'b4100000-0000-0000-0000-000000000002','primary',1
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
    'b4100000-0000-0000-0000-000000000010',
    'b4100000-0000-0000-0000-000000000020',
    'map_framework_informs_product','Exact FrameworkVersion used by Evidence Map product','active'
);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'b4800000-0000-0000-0000-000000000001',
    'b4100000-0000-0000-0000-000000000020','current',
    TIMESTAMPTZ '2026-10-06 12:30:00-03','MAP_FIXTURE',
    'Synthetic searches are current through the fixture cutoff.','active'
);

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES
('b4800000-0000-0000-0000-000000000011','b4100000-0000-0000-0000-000000000020','ai_methodological_verification','MAP_FIXTURE_AI','ai_system',false,'passed',TIMESTAMPTZ '2026-10-06 12:31:00-03','Synthetic AI methodological verification.','{"fixture":true}'::jsonb,'active'),
('b4800000-0000-0000-0000-000000000012','b4100000-0000-0000-0000-000000000020','owner_governance_approval','MAP_FIXTURE_OWNER','owner',false,'approved',TIMESTAMPTZ '2026-10-06 12:32:00-03','Synthetic owner approval.','{"fixture":true}'::jsonb,'active'),
('b4800000-0000-0000-0000-000000000013','b4100000-0000-0000-0000-000000000020','expert_independent_review','SYN_MAP_EXPERT','human_expert',true,'approved',TIMESTAMPTZ '2026-10-06 12:33:00-03','Synthetic independent expert review.','{"fixture":true}'::jsonb,'active');

COMMIT;
