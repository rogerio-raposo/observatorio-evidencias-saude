-- OES Fase 3 — Evidence Review N4 formal synthetic fixture
-- Requires baseline + migrations 002–015 and f3-rapid-evidence-synthesis-fixtures.sql.
-- SYNTHETIC ONLY: human reviewers/expert are fictional actors for contract validation.

BEGIN;

-- ---------------------------------------------------------------------------
-- ARTIFACTS
-- ---------------------------------------------------------------------------

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,
    mime_type,original_filename,source_uri,created_at,created_by,status
) VALUES
(
 'f9000000-0000-0000-0000-000000000001','protocol',
 'fixtures/n4/systematic-review-protocol-v1.md',
 'synthetic-n4-protocol-sha256','sha256','text/markdown',
 'systematic-review-protocol-v1.md',NULL,
 TIMESTAMPTZ '2026-10-06 07:30:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000002','protocol_registration',
 'fixtures/n4/protocol-registration.txt',
 'synthetic-n4-registration-sha256','sha256','text/plain',
 'protocol-registration.txt','https://example.invalid/registry/N4-SYNTHETIC',
 TIMESTAMPTZ '2026-10-06 07:35:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000011','search_export',
 'fixtures/n4/pubmed-export.ris','synthetic-n4-pubmed-export',
 'sha256','application/x-research-info-systems','pubmed-export.ris',NULL,
 TIMESTAMPTZ '2026-10-06 09:05:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000012','search_export',
 'fixtures/n4/central-export.ris','synthetic-n4-central-export',
 'sha256','application/x-research-info-systems','central-export.ris',NULL,
 TIMESTAMPTZ '2026-10-06 09:10:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000013','search_export',
 'fixtures/n4/embase-export.ris','synthetic-n4-embase-export',
 'sha256','application/x-research-info-systems','embase-export.ris',NULL,
 TIMESTAMPTZ '2026-10-06 09:15:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000014','search_peer_review',
 'fixtures/n4/press-review.md','synthetic-n4-press-review',
 'sha256','text/markdown','press-review.md',NULL,
 TIMESTAMPTZ '2026-10-06 08:45:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000020','analysis_code',
 'fixtures/n4/meta-analysis.R','synthetic-n4-analysis-code',
 'sha256','text/plain','meta-analysis.R',NULL,
 TIMESTAMPTZ '2026-10-06 13:00:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000021','analysis_dataset',
 'fixtures/n4/meta-analysis.csv','synthetic-n4-analysis-dataset',
 'sha256','text/csv','meta-analysis.csv',NULL,
 TIMESTAMPTZ '2026-10-06 13:00:00-03','n4-fixture','active'
),
(
 'f9000000-0000-0000-0000-000000000022','summary_of_findings',
 'fixtures/n4/summary-of-findings.md','synthetic-n4-sof',
 'sha256','text/markdown','summary-of-findings.md',NULL,
 TIMESTAMPTZ '2026-10-06 14:00:00-03','n4-fixture','active'
);

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f0000000-0000-0000-0000-000000000001','OES-Q-2026-001201','Question','n4-fixture'),
('f0000000-0000-0000-0000-000000000002','OES-I-2026-001201','Investigation','n4-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
(
 'f1000000-0000-0000-0000-000000000001',
 'f0000000-0000-0000-0000-000000000001',
 1,'current','n4-fixture','initial','Synthetic N4 question'
),
(
 'f1000000-0000-0000-0000-000000000002',
 'f0000000-0000-0000-0000-000000000002',
 1,'current','n4-fixture','initial','Synthetic N4 systematic review investigation'
);

INSERT INTO investigation.question(entity_uuid)
VALUES ('f0000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload
) VALUES (
    'f1000000-0000-0000-0000-000000000001',
    'f0000000-0000-0000-0000-000000000001',
    'Em adultos com condição sintética X, a intervenção A melhora o desfecho Y?',
    'Em adultos com condição sintética X, qual é o efeito da intervenção A versus cuidado usual sobre o desfecho crítico Y?',
    'intervention','PICO',
    '{"population":"adults with synthetic condition X","intervention":"A","comparator":"usual care","outcome":"Y","fixture":true}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('f0000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'f1000000-0000-0000-0000-000000000002',
    'f0000000-0000-0000-0000-000000000002',
    'f0000000-0000-0000-0000-000000000001',
    'systematic_review_intervention','N4','M0',
    'Validate the full OES N4 systematic-review contract with synthetic qualified human controls.',
    'f9000000-0000-0000-0000-000000000001',
    DATE '2026-10-06',DATE '2026-10-06','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'f1000000-0000-0000-0000-000000000002',
    'f1000000-0000-0000-0000-000000000001',
    'primary',1
);

INSERT INTO artifact.entity_link(
    artifact_uuid,entity_version_uuid,role,sequence_no
) VALUES (
    'f9000000-0000-0000-0000-000000000001',
    'f1000000-0000-0000-0000-000000000002',
    'protocol',1
);

-- ---------------------------------------------------------------------------
-- INFRASTRUCTURE READINESS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,decision_type,stage,
    decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
    impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES (
    'f6000000-0000-0000-0000-000000000001',
    'f1000000-0000-0000-0000-000000000002',
    'other','cross_cutting','N4_INFRASTRUCTURE_READINESS',true,
    'Synthetic fixture explicitly supplies every infrastructure and human-control dependency required by the N4 contract.',
    '{"fixture_only":true}'::jsonb,
    '{"synthetic_humans":"must never be interpreted as real qualified reviewers"}'::jsonb,
    '{
       "state":"ready",
       "required_source_names":["PubMed/MEDLINE","CENTRAL","Embase"],
       "domains":{
         "bibliographic_coverage":"ready",
         "reviewer_availability":"ready",
         "search_expertise":"ready",
         "appraisal_expertise":"ready",
         "certainty_expertise":"ready",
         "statistical_expertise":"ready",
         "software_compute":"ready",
         "artifact_versioning":"ready",
         "a3_pathway":"ready",
         "conflicts_governance":"ready"
       }
     }'::jsonb,
    'accepted','N4_FIXTURE_METHOD',
    TIMESTAMPTZ '2026-10-06 08:00:00-03','active'
);

-- ---------------------------------------------------------------------------
-- SYNTHETIC HUMAN REVIEWER ASSIGNMENTS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.reviewer_assignment(
    reviewer_assignment_uuid,investigation_version_uuid,stage,
    actor,actor_type,role,qualification_payload,independent_flag,
    scope_payload,conflict_payload,assigned_at,record_status
) VALUES
(
 'f6100000-0000-0000-0000-000000000001',
 'f1000000-0000-0000-0000-000000000002','search',
 'SYN_N4_SEARCH_EXPERT','human_expert','search_peer_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"information retrieval / PRESS"}'::jsonb,
 true,'{"scope":"all N4 search strategies"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000002',
 'f1000000-0000-0000-0000-000000000002','screening',
 'SYN_N4_R1','human_reviewer','primary_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"systematic-review screening"}'::jsonb,
 true,'{"scope":"all records and full texts"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000003',
 'f1000000-0000-0000-0000-000000000002','screening',
 'SYN_N4_R2','human_reviewer','secondary_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"systematic-review screening"}'::jsonb,
 true,'{"scope":"all records and full texts"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000004',
 'f1000000-0000-0000-0000-000000000002','extraction',
 'SYN_N4_R1','human_reviewer','data_extractor',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"critical outcome extraction"}'::jsonb,
 true,'{"scope":"all critical results"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000005',
 'f1000000-0000-0000-0000-000000000002','extraction',
 'SYN_N4_R2','human_reviewer','data_extractor',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"critical outcome extraction"}'::jsonb,
 true,'{"scope":"all critical results"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000006',
 'f1000000-0000-0000-0000-000000000002','extraction',
 'SYN_N4_R2','human_reviewer','data_verifier',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"critical outcome verification"}'::jsonb,
 true,'{"scope":"all critical results"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000007',
 'f1000000-0000-0000-0000-000000000002','appraisal',
 'SYN_N4_R1','human_reviewer','appraisal_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"RoB 2 / ROB-ME"}'::jsonb,
 true,'{"scope":"all material appraisals"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000008',
 'f1000000-0000-0000-0000-000000000002','appraisal',
 'SYN_N4_R2','human_reviewer','appraisal_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"RoB 2 / ROB-ME"}'::jsonb,
 true,'{"scope":"all material appraisals"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000009',
 'f1000000-0000-0000-0000-000000000002','synthesis',
 'SYN_N4_STAT_EXPERT','human_expert','statistical_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"pairwise meta-analysis"}'::jsonb,
 true,'{"scope":"primary meta-analysis"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000010',
 'f1000000-0000-0000-0000-000000000002','certainty',
 'SYN_N4_R1','human_reviewer','certainty_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"GRADE"}'::jsonb,
 true,'{"scope":"all material certainty assessments"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000011',
 'f1000000-0000-0000-0000-000000000002','certainty',
 'SYN_N4_R2','human_reviewer','certainty_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"GRADE"}'::jsonb,
 true,'{"scope":"all material certainty assessments"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
),
(
 'f6100000-0000-0000-0000-000000000012',
 'f1000000-0000-0000-0000-000000000002','cross_cutting',
 'SYN_N4_EXPERT','human_expert','expert_independent_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification","domain":"independent expert review"}'::jsonb,
 true,'{"scope":"final N4 product"}'::jsonb,'{"declared":false}'::jsonb,
 TIMESTAMPTZ '2026-10-06 08:05:00-03','active'
);

-- ---------------------------------------------------------------------------
-- SEARCHES + EXPORTS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,executed_at,
    result_count,strategy_version,operator,export_artifact_uuid,status
) VALUES
(
 'f2000000-0000-0000-0000-000000000001','OES-SRCH-2026-001201',
 'f1000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 'synthetic condition X AND intervention A',
 '{"fixture":true,"source_class":"bibliographic_database"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 09:00:00-03',3,'n4-v1','N4_FIXTURE',
 'f9000000-0000-0000-0000-000000000011','completed'
),
(
 'f2000000-0000-0000-0000-000000000002','OES-SRCH-2026-001202',
 'f1000000-0000-0000-0000-000000000002',
 'CENTRAL','Cochrane Library',
 'synthetic condition X AND intervention A',
 '{"fixture":true,"source_class":"bibliographic_database"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 09:01:00-03',3,'n4-v1','N4_FIXTURE',
 'f9000000-0000-0000-0000-000000000012','completed'
),
(
 'f2000000-0000-0000-0000-000000000003','OES-SRCH-2026-001203',
 'f1000000-0000-0000-0000-000000000002',
 'Embase','Elsevier',
 'synthetic condition X AND intervention A',
 '{"fixture":true,"source_class":"bibliographic_database"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 09:02:00-03',3,'n4-v1','N4_FIXTURE',
 'f9000000-0000-0000-0000-000000000013','completed'
);

-- ---------------------------------------------------------------------------
-- THIRD, INELIGIBLE REPORT FOR FULL-TEXT EXCLUSION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES (
 'f0000000-0000-0000-0000-000000000203',
 'OES-RP-2026-001203','Report','n4-fixture'
);

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
 'f1000000-0000-0000-0000-000000000203',
 'f0000000-0000-0000-0000-000000000203',
 1,'current','n4-fixture','initial',
 'Synthetic ineligible report for N4 exclusion flow'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('f0000000-0000-0000-0000-000000000203');

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES (
 'f1000000-0000-0000-0000-000000000203',
 'f0000000-0000-0000-0000-000000000203',
 'primary_report','Synthetic observational ineligible report C',
 DATE '2025-08-01','Synthetic Journal C','en','published','available',
 '{"fixture":true,"doi":"10.synthetic/n4c","design":"observational"}'::jsonb,
 'active'
);

-- ---------------------------------------------------------------------------
-- SEARCH HITS — EACH DATABASE RETURNS A/B/C
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
    source_record_id,raw_payload,raw_title,raw_year,raw_identifier,
    source_rank,resolution_status
) VALUES
('f2500000-0000-0000-0000-000000000211','OES-HIT-2026-001211','f2000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000201','PM-A','{"fixture":true}'::jsonb,'Synthetic randomized trial A',2025,'10.synthetic/n3a',1,'linked'),
('f2500000-0000-0000-0000-000000000212','OES-HIT-2026-001212','f2000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000202','PM-B','{"fixture":true}'::jsonb,'Synthetic randomized trial B',2026,'10.synthetic/n3b',2,'linked'),
('f2500000-0000-0000-0000-000000000213','OES-HIT-2026-001213','f2000000-0000-0000-0000-000000000001','f0000000-0000-0000-0000-000000000203','PM-C','{"fixture":true}'::jsonb,'Synthetic observational ineligible report C',2025,'10.synthetic/n4c',3,'linked'),
('f2500000-0000-0000-0000-000000000221','OES-HIT-2026-001221','f2000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','CT-A','{"fixture":true}'::jsonb,'Synthetic randomized trial A',2025,'10.synthetic/n3a',1,'linked'),
('f2500000-0000-0000-0000-000000000222','OES-HIT-2026-001222','f2000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','CT-B','{"fixture":true}'::jsonb,'Synthetic randomized trial B',2026,'10.synthetic/n3b',2,'linked'),
('f2500000-0000-0000-0000-000000000223','OES-HIT-2026-001223','f2000000-0000-0000-0000-000000000002','f0000000-0000-0000-0000-000000000203','CT-C','{"fixture":true}'::jsonb,'Synthetic observational ineligible report C',2025,'10.synthetic/n4c',3,'linked'),
('f2500000-0000-0000-0000-000000000231','OES-HIT-2026-001231','f2000000-0000-0000-0000-000000000003','d0000000-0000-0000-0000-000000000201','EM-A','{"fixture":true}'::jsonb,'Synthetic randomized trial A',2025,'10.synthetic/n3a',1,'linked'),
('f2500000-0000-0000-0000-000000000232','OES-HIT-2026-001232','f2000000-0000-0000-0000-000000000003','d0000000-0000-0000-0000-000000000202','EM-B','{"fixture":true}'::jsonb,'Synthetic randomized trial B',2026,'10.synthetic/n3b',2,'linked'),
('f2500000-0000-0000-0000-000000000233','OES-HIT-2026-001233','f2000000-0000-0000-0000-000000000003','f0000000-0000-0000-0000-000000000203','EM-C','{"fixture":true}'::jsonb,'Synthetic observational ineligible report C',2025,'10.synthetic/n4c',3,'linked');

-- ---------------------------------------------------------------------------
-- DUPLICATE SCREENING
-- ---------------------------------------------------------------------------

INSERT INTO investigation.screening_decision(
    screening_uuid,oes_screening_id,investigation_version_uuid,
    target_entity_uuid,stage,reviewer,decision,exclusion_reason,
    decided_at,adjudication_flag
) VALUES
('f3500000-0000-0000-0000-000000000211','OES-SCR-2026-001211','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','title_abstract','SYN_N4_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:00-03',false),
('f3500000-0000-0000-0000-000000000212','OES-SCR-2026-001212','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','title_abstract','SYN_N4_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:05-03',false),
('f3500000-0000-0000-0000-000000000213','OES-SCR-2026-001213','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','title_abstract','SYN_N4_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:10-03',false),
('f3500000-0000-0000-0000-000000000214','OES-SCR-2026-001214','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','title_abstract','SYN_N4_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:15-03',false),
('f3500000-0000-0000-0000-000000000215','OES-SCR-2026-001215','f1000000-0000-0000-0000-000000000002','f0000000-0000-0000-0000-000000000203','title_abstract','SYN_N4_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:20-03',false),
('f3500000-0000-0000-0000-000000000216','OES-SCR-2026-001216','f1000000-0000-0000-0000-000000000002','f0000000-0000-0000-0000-000000000203','title_abstract','SYN_N4_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:00:25-03',false),
('f3500000-0000-0000-0000-000000000221','OES-SCR-2026-001221','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','full_text','SYN_N4_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:15:00-03',false),
('f3500000-0000-0000-0000-000000000222','OES-SCR-2026-001222','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000201','full_text','SYN_N4_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:15:05-03',false),
('f3500000-0000-0000-0000-000000000223','OES-SCR-2026-001223','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','full_text','SYN_N4_R1','include',NULL,TIMESTAMPTZ '2026-10-06 10:15:10-03',false),
('f3500000-0000-0000-0000-000000000224','OES-SCR-2026-001224','f1000000-0000-0000-0000-000000000002','d0000000-0000-0000-0000-000000000202','full_text','SYN_N4_R2','include',NULL,TIMESTAMPTZ '2026-10-06 10:15:15-03',false),
('f3500000-0000-0000-0000-000000000225','OES-SCR-2026-001225','f1000000-0000-0000-0000-000000000002','f0000000-0000-0000-0000-000000000203','full_text','SYN_N4_R1','exclude','wrong_study_design',TIMESTAMPTZ '2026-10-06 10:15:20-03',false),
('f3500000-0000-0000-0000-000000000226','OES-SCR-2026-001226','f1000000-0000-0000-0000-000000000002','f0000000-0000-0000-0000-000000000203','full_text','SYN_N4_R2','exclude','wrong_study_design',TIMESTAMPTZ '2026-10-06 10:15:25-03',false);

-- ---------------------------------------------------------------------------
-- DUPLICATE CRITICAL DATA EXTRACTION — REUSE N3 RESULT VERSIONS
-- ---------------------------------------------------------------------------

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
    source_location,source_value,process_type,actor,created_at,status
) VALUES
('f5000000-0000-0000-0000-000000000301','d1000000-0000-0000-0000-000000000301','n4.extraction.reviewer_a','d1000000-0000-0000-0000-000000000201','Table 2','{"md":-2.0,"ci":[-3.37,-0.63]}'::jsonb,'n4_independent_extraction','SYN_N4_R1',TIMESTAMPTZ '2026-10-06 11:00:00-03','active'),
('f5000000-0000-0000-0000-000000000302','d1000000-0000-0000-0000-000000000301','n4.extraction.reviewer_b','d1000000-0000-0000-0000-000000000201','Table 2','{"md":-2.0,"ci":[-3.37,-0.63]}'::jsonb,'n4_independent_extraction','SYN_N4_R2',TIMESTAMPTZ '2026-10-06 11:00:05-03','active'),
('f5000000-0000-0000-0000-000000000303','d1000000-0000-0000-0000-000000000302','n4.extraction.reviewer_a','d1000000-0000-0000-0000-000000000202','Table 3','{"md":-1.4,"ci":[-2.58,-0.22]}'::jsonb,'n4_independent_extraction','SYN_N4_R1',TIMESTAMPTZ '2026-10-06 11:01:00-03','active'),
('f5000000-0000-0000-0000-000000000304','d1000000-0000-0000-0000-000000000302','n4.extraction.reviewer_b','d1000000-0000-0000-0000-000000000202','Table 3','{"md":-1.4,"ci":[-2.58,-0.22]}'::jsonb,'n4_independent_extraction','SYN_N4_R2',TIMESTAMPTZ '2026-10-06 11:01:05-03','active');

-- ---------------------------------------------------------------------------
-- N4 RISK OF BIAS + ROB-ME
-- ---------------------------------------------------------------------------

-- Pre-create the synthesis entity/version identity so ROB-ME can target it.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES (
 'f0000000-0000-0000-0000-000000000501',
 'OES-SY-2026-001201','Synthesis','n4-fixture'
);

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
 'f1000000-0000-0000-0000-000000000501',
 'f0000000-0000-0000-0000-000000000501',
 1,'current','n4-fixture','initial','Synthetic N4 pairwise meta-analysis'
);

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('f0000000-0000-0000-0000-000000000401','OES-RA-2026-001201','RiskAssessment','n4-fixture'),
('f0000000-0000-0000-0000-000000000402','OES-RA-2026-001202','RiskAssessment','n4-fixture'),
('f0000000-0000-0000-0000-000000000403','OES-RA-2026-001203','RiskAssessment','n4-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('f1000000-0000-0000-0000-000000000401','f0000000-0000-0000-0000-000000000401',1,'current','n4-fixture','initial','Synthetic N4 RoB 2 study A'),
('f1000000-0000-0000-0000-000000000402','f0000000-0000-0000-0000-000000000402',1,'current','n4-fixture','initial','Synthetic N4 RoB 2 study B'),
('f1000000-0000-0000-0000-000000000403','f0000000-0000-0000-0000-000000000403',1,'current','n4-fixture','initial','Synthetic N4 ROB-ME');

INSERT INTO appraisal.risk_assessment(entity_uuid)
VALUES
('f0000000-0000-0000-0000-000000000401'),
('f0000000-0000-0000-0000-000000000402'),
('f0000000-0000-0000-0000-000000000403');

INSERT INTO appraisal.risk_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    framework,framework_version,target_entity_uuid,outcome_entity_uuid,
    overall_judgement,assessor,assessment_date,verification_status,
    instrument_payload,status
) VALUES
(
 'f1000000-0000-0000-0000-000000000401','f0000000-0000-0000-0000-000000000401',
 'f1000000-0000-0000-0000-000000000002','RoB 2','fixture',
 'd0000000-0000-0000-0000-000000000101','d0000000-0000-0000-0000-000000000010',
 'low','SYN_N4_R1',DATE '2026-10-06','human_consensus',
 '{"fixture":true,"two_independent_judgements":true}'::jsonb,'active'
),
(
 'f1000000-0000-0000-0000-000000000402','f0000000-0000-0000-0000-000000000402',
 'f1000000-0000-0000-0000-000000000002','RoB 2','fixture',
 'd0000000-0000-0000-0000-000000000102','d0000000-0000-0000-0000-000000000010',
 'some_concerns','SYN_N4_R1',DATE '2026-10-06','human_consensus',
 '{"fixture":true,"two_independent_judgements":true}'::jsonb,'active'
),
(
 'f1000000-0000-0000-0000-000000000403','f0000000-0000-0000-0000-000000000403',
 'f1000000-0000-0000-0000-000000000002','ROB-ME','fixture',
 'f0000000-0000-0000-0000-000000000501','d0000000-0000-0000-0000-000000000010',
 'low','SYN_N4_R1',DATE '2026-10-06','human_consensus',
 '{"fixture":true,"two_independent_judgements":true}'::jsonb,'active'
);

INSERT INTO appraisal.risk_assessment_domain(
    risk_assessment_version_uuid,domain_code,judgement,
    rationale,sequence_no
) VALUES
('f1000000-0000-0000-0000-000000000401','randomization','low','Synthetic N4 low-risk judgment',1),
('f1000000-0000-0000-0000-000000000402','randomization','some_concerns','Synthetic N4 some-concerns judgment',1),
('f1000000-0000-0000-0000-000000000403','missing_evidence','low','Synthetic N4 ROB-ME low concern',1);

-- ---------------------------------------------------------------------------
-- APPRAISAL INDEPENDENT JUDGEMENTS
-- ---------------------------------------------------------------------------

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
    source_location,source_value,process_type,actor,created_at,status
) VALUES
('f5000000-0000-0000-0000-000000000401','f1000000-0000-0000-0000-000000000401','n4.appraisal.reviewer_a','d1000000-0000-0000-0000-000000000201','Methods/Results','{"judgement":"low"}'::jsonb,'n4_independent_appraisal_judgement','SYN_N4_R1',TIMESTAMPTZ '2026-10-06 12:00:00-03','active'),
('f5000000-0000-0000-0000-000000000402','f1000000-0000-0000-0000-000000000401','n4.appraisal.reviewer_b','d1000000-0000-0000-0000-000000000201','Methods/Results','{"judgement":"low"}'::jsonb,'n4_independent_appraisal_judgement','SYN_N4_R2',TIMESTAMPTZ '2026-10-06 12:00:05-03','active'),
('f5000000-0000-0000-0000-000000000403','f1000000-0000-0000-0000-000000000402','n4.appraisal.reviewer_a','d1000000-0000-0000-0000-000000000202','Methods/Results','{"judgement":"some_concerns"}'::jsonb,'n4_independent_appraisal_judgement','SYN_N4_R1',TIMESTAMPTZ '2026-10-06 12:01:00-03','active'),
('f5000000-0000-0000-0000-000000000404','f1000000-0000-0000-0000-000000000402','n4.appraisal.reviewer_b','d1000000-0000-0000-0000-000000000202','Methods/Results','{"judgement":"some_concerns"}'::jsonb,'n4_independent_appraisal_judgement','SYN_N4_R2',TIMESTAMPTZ '2026-10-06 12:01:05-03','active'),
('f5000000-0000-0000-0000-000000000405','f1000000-0000-0000-0000-000000000403','n4.appraisal.reviewer_a',NULL,'ROB-ME worksheet','{"judgement":"low"}'::jsonb,'n4_independent_appraisal_judgement','SYN_N4_R1',TIMESTAMPTZ '2026-10-06 13:20:00-03','active'),
('f5000000-0000-0000-0000-000000000406','f1000000-0000-0000-0000-000000000403','n4.appraisal.reviewer_b',NULL,'ROB-ME worksheet','{"judgement":"low"}'::jsonb,'n4_independent_appraisal_judgement','SYN_N4_R2',TIMESTAMPTZ '2026-10-06 13:20:05-03','active');

-- ---------------------------------------------------------------------------
-- META-ANALYSIS SYNTHESIS — REUSE N3 RESULT VERSIONS
-- ---------------------------------------------------------------------------

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('f0000000-0000-0000-0000-000000000501');

INSERT INTO synthesis.synthesis_version(
    version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
    population_descriptor,comparison_payload,timepoint_payload,estimand,
    synthesis_type,synthesis_origin,method,model,software,software_version,
    code_artifact_uuid,analysis_dataset_artifact_uuid,result_summary,
    status,executed_at
) VALUES (
    'f1000000-0000-0000-0000-000000000501',
    'f0000000-0000-0000-0000-000000000501',
    'f1000000-0000-0000-0000-000000000002',
    'd0000000-0000-0000-0000-000000000010',
    '{"population":"synthetic adults"}'::jsonb,
    '{"intervention":"A","comparator":"usual care"}'::jsonb,
    '{"timepoint":"8 weeks"}'::jsonb,
    'mean_difference',
    'pairwise_meta_analysis','new_calculation',
    'Synthetic random-effects pairwise meta-analysis',
    'random-effects','R','4.5.0',
    'f9000000-0000-0000-0000-000000000020',
    'f9000000-0000-0000-0000-000000000021',
    '{"measure":"MD","estimate":-1.68,"ci_lower":-2.55,"ci_upper":-0.81,"tau2":0.05,"i2_percent":12,"prediction_interval":[-3.10,-0.26],"fixture":true}'::jsonb,
    'active',TIMESTAMPTZ '2026-10-06 13:10:00-03'
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid,result_version_uuid,contribution_role,
    transformed_value,weight,included_main_analysis,
    included_sensitivity,notes
) VALUES
(
 'f1000000-0000-0000-0000-000000000501',
 'd1000000-0000-0000-0000-000000000301',
 'main','{"md":-2.0}'::jsonb,0.45,true,true,'Synthetic Study A'
),
(
 'f1000000-0000-0000-0000-000000000501',
 'd1000000-0000-0000-0000-000000000302',
 'main','{"md":-1.4}'::jsonb,0.55,true,true,'Synthetic Study B'
);

-- ---------------------------------------------------------------------------
-- N4 CERTAINTY
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES (
 'f0000000-0000-0000-0000-000000000601',
 'OES-CA-2026-001201','CertaintyAssessment','n4-fixture'
);

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
 'f1000000-0000-0000-0000-000000000601',
 'f0000000-0000-0000-0000-000000000601',
 1,'current','n4-fixture','initial','Synthetic N4 GRADE assessment'
);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('f0000000-0000-0000-0000-000000000601');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    synthesis_version_uuid,outcome_entity_uuid,framework,framework_version,
    initial_level,final_level,evidence_state,assessment_date,status
) VALUES (
    'f1000000-0000-0000-0000-000000000601',
    'f0000000-0000-0000-0000-000000000601',
    'f1000000-0000-0000-0000-000000000002',
    'f1000000-0000-0000-0000-000000000501',
    'd0000000-0000-0000-0000-000000000010',
    'GRADE','fixture','high','moderate',
    'evidence_available',DATE '2026-10-06','active'
);

INSERT INTO appraisal.certainty_domain(
    certainty_assessment_version_uuid,domain_code,concern_level,
    downgrade_steps,rationale,reviewer,sequence_no
) VALUES (
    'f1000000-0000-0000-0000-000000000601',
    'risk_of_bias','some_concern',1,
    'One synthetic RCT has some concerns.','SYN_N4_CONSENSUS',1
);

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,source_value,
    process_type,actor,created_at,status
) VALUES
('f5000000-0000-0000-0000-000000000601','f1000000-0000-0000-0000-000000000601','n4.certainty.reviewer_a','{"final_level":"moderate"}'::jsonb,'n4_independent_certainty_judgement','SYN_N4_R1',TIMESTAMPTZ '2026-10-06 13:40:00-03','active'),
('f5000000-0000-0000-0000-000000000602','f1000000-0000-0000-0000-000000000601','n4.certainty.reviewer_b','{"final_level":"moderate"}'::jsonb,'n4_independent_certainty_judgement','SYN_N4_R2',TIMESTAMPTZ '2026-10-06 13:40:05-03','active');

-- ---------------------------------------------------------------------------
-- QUALITY CONTROLS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,agreement_payload,performed_at,
    evidence_artifact_uuid,notes,record_status
) VALUES
(
 'f6500000-0000-0000-0000-000000000001',
 'f1000000-0000-0000-0000-000000000002',
 'search','search_strategy_peer_review',
 'SYN_N4_SEARCH_EXPERT','human_expert',
 '{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,
 true,'passed',
 '{"search_ids":["OES-SRCH-2026-001201","OES-SRCH-2026-001202","OES-SRCH-2026-001203"],"coverage":"all_strategies"}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-06 08:50:00-03',
 'f9000000-0000-0000-0000-000000000014',
 'Synthetic PRESS-equivalent review.','active'
),
(
 'f6500000-0000-0000-0000-000000000002',
 'f1000000-0000-0000-0000-000000000002',
 'screening','screening_pilot',
 'SYN_N4_R2','human_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,
 true,'passed',
 '{"coverage":"pilot","records_sampled":3}'::jsonb,
 '{"agreement":"100% synthetic"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 09:45:00-03',
 NULL,'Synthetic screening calibration.','active'
),
(
 'f6500000-0000-0000-0000-000000000003',
 'f1000000-0000-0000-0000-000000000002',
 'extraction','critical_data_verification',
 'SYN_N4_R2','human_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,
 true,'passed',
 '{"coverage":"all_critical_results","mode":"independent_duplicate"}'::jsonb,
 '{"agreement":"complete"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 11:10:00-03',
 NULL,'Synthetic duplicate extraction closed without discrepancy.','active'
),
(
 'f6500000-0000-0000-0000-000000000004',
 'f1000000-0000-0000-0000-000000000002',
 'appraisal','risk_of_bias_verification',
 'SYN_N4_R2','human_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,
 true,'passed',
 '{"coverage":"all_assessments","mode":"independent_duplicate"}'::jsonb,
 '{"agreement":"complete"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 13:25:00-03',
 NULL,'Synthetic duplicate RoB/ROB-ME appraisal completed.','active'
),
(
 'f6500000-0000-0000-0000-000000000005',
 'f1000000-0000-0000-0000-000000000002',
 'synthesis','synthesis_statistical_review',
 'SYN_N4_STAT_EXPERT','human_expert',
 '{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,
 true,'passed',
 '{"coverage":"primary_meta_analysis","mode":"independent_verification"}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-06 13:30:00-03',
 NULL,'Synthetic independent statistical review.','active'
),
(
 'f6500000-0000-0000-0000-000000000006',
 'f1000000-0000-0000-0000-000000000002',
 'certainty','certainty_verification',
 'SYN_N4_R2','human_reviewer',
 '{"qualified":true,"basis":"synthetic fixture qualification"}'::jsonb,
 true,'passed',
 '{"coverage":"all_material_certainty_assessments","mode":"independent_duplicate"}'::jsonb,
 '{"agreement":"complete"}'::jsonb,
 TIMESTAMPTZ '2026-10-06 13:50:00-03',
 NULL,'Synthetic duplicate GRADE verification.','active'
);

-- ---------------------------------------------------------------------------
-- PRODUCT — SYNTHETIC FORMAL A3
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES (
 'f0000000-0000-0000-0000-000000000701',
 'OES-P-2026-001201','Product','n4-fixture'
);

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
 'f1000000-0000-0000-0000-000000000701',
 'f0000000-0000-0000-0000-000000000701',
 1,'current','n4-fixture','initial',
 'Synthetic formal N4 systematic review with fictional qualified controls'
);

INSERT INTO product.product(entity_uuid)
VALUES ('f0000000-0000-0000-0000-000000000701');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'f1000000-0000-0000-0000-000000000701',
    'f0000000-0000-0000-0000-000000000701',
    'evidence_review',
    'Synthetic Systematic Review N4 — Intervention A for Outcome Y',
    'architecture_validation',
    DATE '2026-10-06',DATE '2026-10-06','published',
    'Synthetic pairwise meta-analysis favours intervention A for outcome Y; certainty is moderate in this fixture.',
    'Synthetic fixture only; no real-world applicability claim.',
    'All reviewers, data and effects are synthetic. This ProductVersion exists solely to validate the N4 contract and must not be interpreted as a real systematic review.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'f1000000-0000-0000-0000-000000000701',
    'f1000000-0000-0000-0000-000000000002','primary',1
);

INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
    'f1000000-0000-0000-0000-000000000701',
    'f1000000-0000-0000-0000-000000000501','primary',1
);

INSERT INTO product.certainty_link(
    product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
    'f1000000-0000-0000-0000-000000000701',
    'f1000000-0000-0000-0000-000000000601','primary',1
);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'f7000000-0000-0000-0000-000000000701',
    'f1000000-0000-0000-0000-000000000701',
    'current',TIMESTAMPTZ '2026-10-06 14:05:00-03',
    'N4_FIXTURE',
    'Synthetic searches and review are current through fixture cutoff.',
    'active'
);

INSERT INTO artifact.entity_link(
    artifact_uuid,entity_version_uuid,role,sequence_no
) VALUES
(
 'f9000000-0000-0000-0000-000000000002',
 'f1000000-0000-0000-0000-000000000701',
 'protocol_registration',1
),
(
 'f9000000-0000-0000-0000-000000000022',
 'f1000000-0000-0000-0000-000000000701',
 'summary_of_findings',1
);

-- ---------------------------------------------------------------------------
-- ASSURANCE A3 — SYNTHETIC ONLY
-- ---------------------------------------------------------------------------

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES
(
 'f8000000-0000-0000-0000-000000000701',
 'f1000000-0000-0000-0000-000000000701',
 'ai_methodological_verification','SYN_N4_AI','ai_system',
 false,'passed',TIMESTAMPTZ '2026-10-06 14:10:00-03',
 'Synthetic AI verification for N4 contract validation.',
 '{"fixture":true,"synthetic":true}'::jsonb,'active'
),
(
 'f8000000-0000-0000-0000-000000000702',
 'f1000000-0000-0000-0000-000000000701',
 'owner_governance_approval','SYN_N4_OWNER','owner',
 false,'approved',TIMESTAMPTZ '2026-10-06 14:11:00-03',
 'Synthetic owner approval for N4 contract validation.',
 '{"fixture":true,"synthetic":true}'::jsonb,'active'
),
(
 'f8000000-0000-0000-0000-000000000703',
 'f1000000-0000-0000-0000-000000000701',
 'expert_independent_review','SYN_N4_EXPERT','human_expert',
 true,'approved',TIMESTAMPTZ '2026-10-06 14:12:00-03',
 'Synthetic expert independent review; fictional actor for contract testing only.',
 '{"fixture":true,"synthetic":true,"real_expert_review":false}'::jsonb,'active'
);

COMMIT;
