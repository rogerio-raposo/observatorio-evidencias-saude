-- OES Fase 3 — Evidence Scan N0 deterministic fixture
-- Requires baseline + migrations 002–013.
-- Purpose: validate a formal persistent N0 Evidence Scan without mandatory Synthesis/Certainty/RiskAssessment.

BEGIN;

-- Question
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('b0000000-0000-0000-0000-000000000001','OES-Q-2026-001001','Question','f3-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'b1000000-0000-0000-0000-000000000001',
 'b0000000-0000-0000-0000-000000000001',
 1,'current','f3-n0','initial','N0 Evidence Scan fixture question'
);

INSERT INTO investigation.question(entity_uuid)
VALUES ('b0000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,question_type,structure_type,context_payload
) VALUES (
 'b1000000-0000-0000-0000-000000000001',
 'b0000000-0000-0000-0000-000000000001',
 'O que existe de evidência sobre a área sintética X?',
 'Como o campo sintético X está estruturado, que sínteses existem e qual investigação deve ocorrer a seguir?',
 'mapping','PCC',
 '{"fixture":true,"population":"synthetic population","concept":"field X","context":"general"}'::jsonb
);

-- N0 Investigation
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('b0000000-0000-0000-0000-000000000002','OES-I-2026-001001','Investigation','f3-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'b1000000-0000-0000-0000-000000000002',
 'b0000000-0000-0000-0000-000000000002',
 1,'current','f3-n0','initial','N0 Evidence Scan fixture investigation'
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('b0000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
 version_uuid,entity_uuid,primary_question_entity_uuid,investigation_type,
 depth_level,maintenance_level,objective,start_date,evidence_cutoff_date,status
) VALUES (
 'b1000000-0000-0000-0000-000000000002',
 'b0000000-0000-0000-0000-000000000002',
 'b0000000-0000-0000-0000-000000000001',
 'evidence_scan','N0','M0',
 'Explore the synthetic field, identify recent syntheses and determine the proportional next investigation.',
 DATE '2026-10-05',DATE '2026-10-05','completed'
);

INSERT INTO investigation.investigation_question(
 investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
 'b1000000-0000-0000-0000-000000000002',
 'b1000000-0000-0000-0000-000000000001',
 'primary',1
);

-- Two exploratory Search executions
INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,source_name,platform,
 exact_strategy,filters_payload,executed_at,result_count,strategy_version,operator,status
) VALUES
(
 'b2000000-0000-0000-0000-000000000001',
 'OES-SRCH-2026-001001',
 'b1000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(synthetic field X) AND (systematic review OR meta-analysis)',
 '{"fixture":true,"purpose":"discover syntheses","non_exhaustive":true}'::jsonb,
 TIMESTAMPTZ '2026-10-05 17:00:00-03',42,'n0-fixture-v1','OES','completed'
),
(
 'b2000000-0000-0000-0000-000000000002',
 'OES-SRCH-2026-001002',
 'b1000000-0000-0000-0000-000000000002',
 'Synthetic Evidence Index','Synthetic Index',
 'synthetic field X',
 '{"fixture":true,"purpose":"secondary evidence discovery","non_exhaustive":true}'::jsonb,
 TIMESTAMPTZ '2026-10-05 17:05:00-03',7,'n0-fixture-v1','OES','completed'
);

-- Central Report 1
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('b0000000-0000-0000-0000-000000000201','OES-R-2026-001001','Report','f3-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'b1000000-0000-0000-0000-000000000201',
 'b0000000-0000-0000-0000-000000000201',
 1,'current','f3-n0','initial','Synthetic recent systematic review for N0 fixture'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('b0000000-0000-0000-0000-000000000201');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'b1000000-0000-0000-0000-000000000201',
 'b0000000-0000-0000-0000-000000000201',
 'systematic_review',
 'Synthetic recent systematic review mapping field X',
 DATE '2026-02-01','Synthetic Journal A','en','published','available',
 '{"fixture":true,"identifier":"SYNTH-N0-001","reported_study_count":18}'::jsonb,'active'
);

-- Central Report 2
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('b0000000-0000-0000-0000-000000000202','OES-R-2026-001002','Report','f3-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'b1000000-0000-0000-0000-000000000202',
 'b0000000-0000-0000-0000-000000000202',
 1,'current','f3-n0','initial','Synthetic evidence map for N0 fixture'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('b0000000-0000-0000-0000-000000000202');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'b1000000-0000-0000-0000-000000000202',
 'b0000000-0000-0000-0000-000000000202',
 'evidence_map',
 'Synthetic evidence map of field X',
 DATE '2025-11-15','Synthetic Journal B','en','published','available',
 '{"fixture":true,"identifier":"SYNTH-N0-002","reported_review_count":5}'::jsonb,'active'
);

INSERT INTO investigation.search_hit(
 search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,source_record_id,
 raw_title,raw_authors,raw_year,raw_identifier,source_rank,resolution_status
) VALUES
(
 'b2500000-0000-0000-0000-000000000001',
 'OES-HIT-2026-001001',
 'b2000000-0000-0000-0000-000000000001',
 'b0000000-0000-0000-0000-000000000201',
 'SYNTH-N0-001','Synthetic recent systematic review mapping field X',
 'Fixture Author A',2026,'SYNTH-N0-001',1,'resolved'
),
(
 'b2500000-0000-0000-0000-000000000002',
 'OES-HIT-2026-001002',
 'b2000000-0000-0000-0000-000000000002',
 'b0000000-0000-0000-0000-000000000202',
 'SYNTH-N0-002','Synthetic evidence map of field X',
 'Fixture Author B',2025,'SYNTH-N0-002',1,'resolved'
);

-- Formal persistent Evidence Scan Product
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('b0000000-0000-0000-0000-000000000301','OES-P-2026-001001','Product','f3-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'b1000000-0000-0000-0000-000000000301',
 'b0000000-0000-0000-0000-000000000301',
 1,'current','f3-n0','initial','Initial formal Evidence Scan N0 fixture'
);

INSERT INTO product.product(entity_uuid)
VALUES ('b0000000-0000-0000-0000-000000000301');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,evidence_cutoff_date,
 publication_date,status,conclusion_text,applicability_summary,limitations_summary
) VALUES (
 'b1000000-0000-0000-0000-000000000301',
 'b0000000-0000-0000-0000-000000000301',
 'evidence_scan',
 'Evidence Scan N0 — fixture de validação',
 'architecture_validation',
 DATE '2026-10-05',DATE '2026-10-05','published',
 'O campo sintético X parece bem sintetizado, com sínteses recentes suficientes para formular uma pergunta focal; uma Resposta de Evidência N1 é a próxima rota proporcional.',
 'Aplicabilidade não é avaliada formalmente neste scan sintético.',
 'Busca exploratória e não exaustiva; contagens são sinais operacionais específicos das buscas; fixture sem finalidade clínica.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 'b1000000-0000-0000-0000-000000000301',
 'b1000000-0000-0000-0000-000000000002',
 'primary',1
);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,assessed_at,assessed_by,rationale,record_status
) VALUES (
 'b3000000-0000-0000-0000-000000000301',
 'b1000000-0000-0000-0000-000000000301',
 'current',TIMESTAMPTZ '2026-10-05 17:10:00-03','OES',
 'N0 fixture searches are current through the evidence cutoff.','active'
);

INSERT INTO product.assurance_record(
 assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,independent_flag,
 decision,performed_at,notes,evidence_payload,status
) VALUES
(
 'b4000000-0000-0000-0000-000000000301',
 'b1000000-0000-0000-0000-000000000301',
 'ai_methodological_verification','N0_TEST_AI','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-05 17:12:00-03','Synthetic N0 methodological verification',
 '{"fixture":true,"result":"passed"}'::jsonb,'active'
),
(
 'b4000000-0000-0000-0000-000000000302',
 'b1000000-0000-0000-0000-000000000301',
 'owner_governance_approval','N0_TEST_OWNER','owner',false,'approved',
 TIMESTAMPTZ '2026-10-05 17:13:00-03','Synthetic N0 owner approval',
 '{"fixture":true,"result":"approved","expert_review":false}'::jsonb,'active'
);

-- N0 product components via controlled provenance
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,
 source_value,process_type,process_record_uuid,transformation,actor,status
) VALUES
(
 'b5000000-0000-0000-0000-000000000301',
 'b1000000-0000-0000-0000-000000000301',
 'scan.field_description',
 'b1000000-0000-0000-0000-000000000201',
 'Abstract / scope',
 '{"text":"Campo sintético com múltiplas sínteses recentes e literatura primária organizada em subtemas.","scope_qualifier":"exploratory_non_exhaustive"}'::jsonb,
 'oes_exploratory_judgement','b2000000-0000-0000-0000-000000000001',
 '{"rationale":"Description triangulates exploratory search and recent synthesis."}'::jsonb,
 'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000302',
 'b1000000-0000-0000-0000-000000000301',
 'scan.terminology.0',
 'b1000000-0000-0000-0000-000000000201',
 'Title / keywords',
 '{"term":"field X","normalized_label":"field X","role":"preferred","context":"synthetic fixture"}'::jsonb,
 'terminology_discovery',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000303',
 'b1000000-0000-0000-0000-000000000301',
 'scan.terminology.1',
 'b1000000-0000-0000-0000-000000000202',
 'Title / scope',
 '{"term":"X evidence domain","normalized_label":"field X","role":"synonym","context":"synthetic fixture"}'::jsonb,
 'terminology_discovery',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000304',
 'b1000000-0000-0000-0000-000000000301',
 'scan.volume_signals.0',
 NULL,
 'PubMed search execution',
 '{"signal_type":"search_hit_count","value":42,"qualifier":"search_specific","context":"PubMed query 1"}'::jsonb,
 'search_signal','b2000000-0000-0000-0000-000000000001',NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000305',
 'b1000000-0000-0000-0000-000000000301',
 'scan.volume_signals.1',
 'b1000000-0000-0000-0000-000000000201',
 'Abstract',
 '{"signal_type":"reported_study_count","value":18,"qualifier":"reported_by_source","context":"systematic review"}'::jsonb,
 'direct_extraction',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000306',
 'b1000000-0000-0000-0000-000000000301',
 'scan.evidence_types.0',
 'b1000000-0000-0000-0000-000000000201',
 'Report type',
 '{"evidence_type":"systematic_review","signal":"multiple","count":null,"qualifier":"exploratory"}'::jsonb,
 'evidence_type_classification',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000307',
 'b1000000-0000-0000-0000-000000000301',
 'scan.evidence_types.1',
 'b1000000-0000-0000-0000-000000000202',
 'Report type',
 '{"evidence_type":"other","signal":"few","count":null,"qualifier":"evidence_map"}'::jsonb,
 'evidence_type_classification',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000308',
 'b1000000-0000-0000-0000-000000000301',
 'scan.central_sources.0',
 'b1000000-0000-0000-0000-000000000201',
 'Whole report',
 '{"role":"recent_synthesis","reason":"Recent systematic review defining field structure."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000309',
 'b1000000-0000-0000-0000-000000000301',
 'scan.central_sources.1',
 'b1000000-0000-0000-0000-000000000202',
 'Whole report',
 '{"role":"map","reason":"Evidence map corroborates breadth and subfield distribution."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000310',
 'b1000000-0000-0000-0000-000000000301',
 'scan.maturity',
 NULL,
 'OES exploratory judgement',
 '{"category":"well_synthesized","rationale":"Multiple recent secondary syntheses were located and the field structure is sufficiently clear for a focal follow-up.","confidence_qualifier":"preliminary"}'::jsonb,
 'oes_exploratory_judgement','b2000000-0000-0000-0000-000000000001',
 '{"inputs":["recent systematic review","evidence map","two exploratory searches"]}'::jsonb,
 'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000311',
 'b1000000-0000-0000-0000-000000000301',
 'scan.subquestions.0',
 NULL,
 'OES exploratory judgement',
 '{"text":"Qual é o efeito da intervenção sintética principal no desfecho Y?","priority":"high","suggested_question_class":"intervention"}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000312',
 'b1000000-0000-0000-0000-000000000301',
 'scan.routing.recommendation',
 NULL,
 'OES routing judgement',
 '{"target":"N1","status":"recommended","requires_question_reformulation":false}'::jsonb,
 'routing_judgement',NULL,NULL,'OES','active'
),
(
 'b5000000-0000-0000-0000-000000000313',
 'b1000000-0000-0000-0000-000000000301',
 'scan.routing.rationale',
 NULL,
 'OES routing judgement',
 '{"text":"The field is well synthesized and a focal question can be answered proportionally with a selective N1 investigation.","routing_dimensions":["maturity","completeness_need","complexity"]}'::jsonb,
 'routing_judgement',NULL,NULL,'OES','active'
);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
(
 'b1000000-0000-0000-0000-000000000201',
 'b1000000-0000-0000-0000-000000000301',
 'central_report_informs_evidence_scan',
 'provenance.record','active'
),
(
 'b1000000-0000-0000-0000-000000000202',
 'b1000000-0000-0000-0000-000000000301',
 'central_report_informs_evidence_scan',
 'provenance.record','active'
);

COMMIT;
