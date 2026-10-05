-- OES Fase 3 — Real Case N0-01
-- GenAI/LLM mental-health chatbots — exploratory Evidence Scan
-- Evidence cutoff: 2026-10-05
-- Initial assurance state: A0 / under_review / non-publishable

BEGIN;

-- ---------------------------------------------------------------------------
-- QUESTION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000001','OES-Q-2026-000601','Question','oes-real-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'c1000000-0000-0000-0000-000000000001',
 'c0000000-0000-0000-0000-000000000001',
 1,'current','oes-real-n0','initial',
 'Real N0 question — GenAI/LLM chatbots and adult mental health support'
);

INSERT INTO investigation.question(entity_uuid)
VALUES ('c0000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,question_type,structure_type,
 context_payload,time_horizon_payload
) VALUES (
 'c1000000-0000-0000-0000-000000000001',
 'c0000000-0000-0000-0000-000000000001',
 'Que evidência existe sobre o uso de chatbots baseados em inteligência artificial generativa e grandes modelos de linguagem para apoio à saúde mental de adultos?',
 'Como está estruturado o campo de chatbots GenAI/LLM para apoio à saúde mental de adultos, que sínteses existem, quais incertezas permanecem e qual investigação deve ocorrer a seguir?',
 'mapping','PCC',
 '{"population":"adultos/populações gerais relevantes à saúde mental","concept":"chatbots GenAI/LLM para apoio/intervenção em saúde mental","context":"digital mental health","case":"real-n0-01"}'::jsonb,
 '{"evidence_cutoff":"2026-10-05"}'::jsonb
);

-- ---------------------------------------------------------------------------
-- INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000002','OES-I-2026-000601','Investigation','oes-real-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'c1000000-0000-0000-0000-000000000002',
 'c0000000-0000-0000-0000-000000000002',
 1,'current','oes-real-n0','initial',
 'Real N0 Evidence Scan investigation'
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('c0000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
 version_uuid,entity_uuid,primary_question_entity_uuid,investigation_type,
 depth_level,maintenance_level,objective,start_date,evidence_cutoff_date,status
) VALUES (
 'c1000000-0000-0000-0000-000000000002',
 'c0000000-0000-0000-0000-000000000002',
 'c0000000-0000-0000-0000-000000000001',
 'evidence_scan','N0','M0',
 'Map terminology, syntheses, maturity, apparent controversies and gaps in GenAI/LLM mental-health chatbots and determine the proportional next OES investigation.',
 DATE '2026-10-05',DATE '2026-10-05','completed'
);

INSERT INTO investigation.investigation_question(
 investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
 'c1000000-0000-0000-0000-000000000002',
 'c1000000-0000-0000-0000-000000000001',
 'primary',1
);

-- ---------------------------------------------------------------------------
-- EXPLORATORY SEARCHES
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,source_name,platform,
 exact_strategy,filters_payload,executed_at,result_count,strategy_version,operator,status
) VALUES
(
 'c2000000-0000-0000-0000-000000000001',
 'OES-SRCH-2026-000601',
 'c1000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(generative AI OR large language model OR LLM) AND (chatbot OR conversational agent) AND (mental health OR psychiatry) AND (systematic review OR meta-analysis OR scoping review)',
 '{"non_exhaustive":true,"purpose":"secondary evidence discovery","executed_via":"web retrieval of PubMed records"}'::jsonb,
 TIMESTAMPTZ '2026-10-05 18:20:00-03',
 NULL,'real-n0-v1','OES','completed'
),
(
 'c2000000-0000-0000-0000-000000000002',
 'OES-SRCH-2026-000602',
 'c1000000-0000-0000-0000-000000000002',
 'Targeted secondary-evidence search','Web/PubMed/Publisher',
 '(GenAI mental health chatbot) AND (safety OR harms OR user experience OR intervention design)',
 '{"non_exhaustive":true,"purpose":"safety UX harms and architecture boundary"}'::jsonb,
 TIMESTAMPTZ '2026-10-05 18:28:00-03',
 NULL,'real-n0-v1','OES','completed'
);

-- ---------------------------------------------------------------------------
-- CENTRAL REPORTS
-- ---------------------------------------------------------------------------

-- R1 Zhang 2025
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000201','OES-RP-2026-000601','Report','oes-real-n0');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('c1000000-0000-0000-0000-000000000201','c0000000-0000-0000-0000-000000000201',1,'current','oes-real-n0','initial','Zhang 2025 GenAI chatbot SR/MA');
INSERT INTO evidence.report(entity_uuid) VALUES ('c0000000-0000-0000-0000-000000000201');
INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'c1000000-0000-0000-0000-000000000201',
 'c0000000-0000-0000-0000-000000000201',
 'systematic_review_meta_analysis',
 'Generative AI Mental Health Chatbots as Therapeutic Tools: Systematic Review and Meta-Analysis of Their Role in Reducing Mental Health Issues',
 DATE '2025-12-16','Journal of Medical Internet Research','en','published','available',
 '{"pmid":"41401240","pmcid":"PMC12707440","doi":"10.2196/78238","studies_narrative":26,"rcts_meta_analysis":14,"n_meta_analysis":6314}'::jsonb,
 'active'
);

-- R2 Olisaeloka safety 2026
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000202','OES-RP-2026-000602','Report','oes-real-n0');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('c1000000-0000-0000-0000-000000000202','c0000000-0000-0000-0000-000000000202',1,'current','oes-real-n0','initial','Olisaeloka 2026 safety scoping review');
INSERT INTO evidence.report(entity_uuid) VALUES ('c0000000-0000-0000-0000-000000000202');
INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'c1000000-0000-0000-0000-000000000202',
 'c0000000-0000-0000-0000-000000000202',
 'scoping_review',
 'Safety Mechanisms and Risk Mitigation in Generative AI Mental Health Chatbots: A Systematic Scoping Review',
 DATE '2026-05-20','Healthcare (Basel)','en','published','available',
 '{"pmid":"42194487","pmcid":"PMC13205439","doi":"10.3390/healthcare14101395","included_studies":21,"countries":11}'::jsonb,
 'active'
);

-- R3 Olisaeloka UX/design 2026
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000203','OES-RP-2026-000603','Report','oes-real-n0');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('c1000000-0000-0000-0000-000000000203','c0000000-0000-0000-0000-000000000203',1,'current','oes-real-n0','initial','Olisaeloka 2026 design and UX scoping review');
INSERT INTO evidence.report(entity_uuid) VALUES ('c0000000-0000-0000-0000-000000000203');
INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'c1000000-0000-0000-0000-000000000203',
 'c0000000-0000-0000-0000-000000000203',
 'scoping_review',
 'Generative AI mental health chatbots: a scoping review of intervention design and user experience',
 DATE '2026-07-23','npj Digital Medicine','en','published','available',
 '{"doi":"10.1038/s41746-026-02972-0","included_studies":21,"countries":11,"publication_years":"2023-2025"}'::jsonb,
 'active'
);

-- R4 Diel harms 2026
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000204','OES-RP-2026-000604','Report','oes-real-n0');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('c1000000-0000-0000-0000-000000000204','c0000000-0000-0000-0000-000000000204',1,'current','oes-real-n0','initial','Diel 2026 LLM chatbot harms scoping review');
INSERT INTO evidence.report(entity_uuid) VALUES ('c0000000-0000-0000-0000-000000000204');
INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'c1000000-0000-0000-0000-000000000204',
 'c0000000-0000-0000-0000-000000000204',
 'scoping_review',
 'A scoping review on the mental health harms of LLM-based chatbots',
 DATE '2026-08-20','npj Digital Medicine','en','published','available',
 '{"doi":"10.1038/s41746-026-03054-x","identified_records":3137,"included_articles":119,"publisher_correction":"2026-09-14"}'::jsonb,
 'active'
);

-- R5 Guo 2024 broad LLM review
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000205','OES-RP-2026-000605','Report','oes-real-n0');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('c1000000-0000-0000-0000-000000000205','c0000000-0000-0000-0000-000000000205',1,'current','oes-real-n0','initial','Guo 2024 LLM mental health systematic review');
INSERT INTO evidence.report(entity_uuid) VALUES ('c0000000-0000-0000-0000-000000000205');
INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'c1000000-0000-0000-0000-000000000205',
 'c0000000-0000-0000-0000-000000000205',
 'systematic_review',
 'Large Language Models for Mental Health Applications: Systematic Review',
 DATE '2024-10-18','JMIR Mental Health','en','published','available',
 '{"pmid":"39423368","pmcid":"PMC11530718","doi":"10.2196/57400","included_articles":40,"conversational_agent_articles":7}'::jsonb,
 'active'
);

-- R6 Gong 2026 CBT chatbot contextual boundary
INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000206','OES-RP-2026-000606','Report','oes-real-n0');
INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('c1000000-0000-0000-0000-000000000206','c0000000-0000-0000-0000-000000000206',1,'current','oes-real-n0','initial','Gong 2026 CBT chatbot contextual meta-analysis');
INSERT INTO evidence.report(entity_uuid) VALUES ('c0000000-0000-0000-0000-000000000206');
INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES (
 'c1000000-0000-0000-0000-000000000206',
 'c0000000-0000-0000-0000-000000000206',
 'systematic_review_meta_analysis',
 'Efficacy, User Engagement, and Acceptability of Cognitive Behavioral Therapy-Oriented Psychological Chatbots for Adults With Depressive and/or Anxiety Symptoms',
 DATE '2026-05-08','Journal of Medical Internet Research','en','published','available',
 '{"pmid":"42101333","pmcid":"PMC13154727","doi":"10.2196/82677","rcts":29,"certainty_reported_by_source":"very low to low","scope_note":"not GenAI-specific"}'::jsonb,
 'active'
);

-- SearchHit records
INSERT INTO investigation.search_hit(
 search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,source_record_id,
 raw_title,raw_authors,raw_year,raw_identifier,source_rank,resolution_status
) VALUES
('c2500000-0000-0000-0000-000000000201','OES-HIT-2026-000601','c2000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000201','PMID:41401240','Generative AI Mental Health Chatbots as Therapeutic Tools','Zhang et al.',2025,'PMID:41401240',1,'resolved'),
('c2500000-0000-0000-0000-000000000202','OES-HIT-2026-000602','c2000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000202','PMID:42194487','Safety Mechanisms and Risk Mitigation in Generative AI Mental Health Chatbots','Olisaeloka et al.',2026,'PMID:42194487',1,'resolved'),
('c2500000-0000-0000-0000-000000000203','OES-HIT-2026-000603','c2000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000203','DOI:10.1038/s41746-026-02972-0','Generative AI mental health chatbots: a scoping review of intervention design and user experience','Olisaeloka et al.',2026,'DOI:10.1038/s41746-026-02972-0',2,'resolved'),
('c2500000-0000-0000-0000-000000000204','OES-HIT-2026-000604','c2000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000204','DOI:10.1038/s41746-026-03054-x','A scoping review on the mental health harms of LLM-based chatbots','Diel et al.',2026,'DOI:10.1038/s41746-026-03054-x',3,'resolved'),
('c2500000-0000-0000-0000-000000000205','OES-HIT-2026-000605','c2000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000205','PMID:39423368','Large Language Models for Mental Health Applications: Systematic Review','Guo et al.',2024,'PMID:39423368',2,'resolved'),
('c2500000-0000-0000-0000-000000000206','OES-HIT-2026-000606','c2000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000206','PMID:42101333','Efficacy, User Engagement, and Acceptability of CBT-Oriented Psychological Chatbots','Gong et al.',2026,'PMID:42101333',3,'resolved');

-- ---------------------------------------------------------------------------
-- PRODUCT
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES ('c0000000-0000-0000-0000-000000000301','OES-P-2026-000601','Product','oes-real-n0');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 'c1000000-0000-0000-0000-000000000301',
 'c0000000-0000-0000-0000-000000000301',
 1,'current','oes-real-n0','initial',
 'Initial real Evidence Scan N0 — GenAI/LLM mental-health chatbots'
);

INSERT INTO product.product(entity_uuid)
VALUES ('c0000000-0000-0000-0000-000000000301');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,evidence_cutoff_date,
 publication_date,status,conclusion_text,applicability_summary,limitations_summary
) VALUES (
 'c1000000-0000-0000-0000-000000000301',
 'c0000000-0000-0000-0000-000000000301',
 'evidence_scan',
 'Evidence Scan — Chatbots GenAI/LLM para apoio à saúde mental',
 'OES internal methodological validation',
 DATE '2026-10-05',
 NULL,
 'under_review',
 'O campo de chatbots GenAI/LLM para saúde mental possui múltiplas sínteses recentes, mas permanece apenas parcialmente sintetizado porque eficácia, segurança, experiência do usuário e danos são estudados em escopos tecnológicos e clínicos diferentes. A pergunta ampla deve ser reformulada antes de investigação focal; a rota recomendada é uma Ficha de Evidência N2 monitorável centrada em chatbots purpose-built para adultos, mantendo eficácia e segurança como eixos distintos.',
 'Aplicabilidade a contextos específicos não foi avaliada formalmente neste Evidence Scan.',
 'Busca exploratória e não exaustiva; foco em sínteses recentes; provável sobreposição de estudos entre revisões; escopos tecnológicos heterogêneos; rápida evolução do campo; ausência de avaliação formal de certeza pelo OES.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 'c1000000-0000-0000-0000-000000000301',
 'c1000000-0000-0000-0000-000000000002',
 'primary',1
);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,assessed_at,assessed_by,rationale,record_status
) VALUES (
 'c3000000-0000-0000-0000-000000000301',
 'c1000000-0000-0000-0000-000000000301',
 'current',TIMESTAMPTZ '2026-10-05 18:45:00-03','OES',
 'Exploratory evidence scan current through cutoff 2026-10-05.','active'
);

-- ---------------------------------------------------------------------------
-- SCAN COMPONENTS / PROVENANCE
-- ---------------------------------------------------------------------------

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,
 source_value,process_type,process_record_uuid,transformation,actor,status
) VALUES
(
 'c5000000-0000-0000-0000-000000000301',
 'c1000000-0000-0000-0000-000000000301',
 'scan.field_description',
 'c1000000-0000-0000-0000-000000000201',
 'Abstract + cross-review exploratory synthesis',
 '{"text":"O campo contém chatbots rule-based/retrieval-based, sistemas NLP/ML, chatbots GenAI/LLM purpose-built e LLM chatbots gerais/companions; revisões recentes usam escopos tecnológicos parcialmente sobrepostos.","scope_qualifier":"exploratory_non_exhaustive"}'::jsonb,
 'oes_exploratory_judgement','c2000000-0000-0000-0000-000000000001',
 '{"documents":["93","94","95"],"rationale":"Cross-review field description."}'::jsonb,
 'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000302',
 'c1000000-0000-0000-0000-000000000301',
 'scan.terminology.0',
 'c1000000-0000-0000-0000-000000000201',
 'Keywords',
 '{"term":"generative AI chatbot","normalized_label":"GenAI mental health chatbot","role":"preferred","context":"purpose-built or hybrid generative interventions"}'::jsonb,
 'terminology_discovery',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000303',
 'c1000000-0000-0000-0000-000000000301',
 'scan.terminology.1',
 'c1000000-0000-0000-0000-000000000205',
 'Abstract / terminology',
 '{"term":"large language model chatbot","normalized_label":"LLM-based chatbot","role":"preferred","context":"broader LLM conversational-agent literature"}'::jsonb,
 'terminology_discovery',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000304',
 'c1000000-0000-0000-0000-000000000301',
 'scan.terminology.2',
 'c1000000-0000-0000-0000-000000000206',
 'Title / scope',
 '{"term":"AI chatbot","normalized_label":"AI chatbot","role":"ambiguous","context":"may include non-generative CBT/rule-based systems"}'::jsonb,
 'terminology_discovery',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000305',
 'c1000000-0000-0000-0000-000000000301',
 'scan.volume_signals.0',
 'c1000000-0000-0000-0000-000000000201',
 'Abstract',
 '{"signal_type":"reported_study_count","value":26,"qualifier":"reported_by_source","context":"GenAI therapeutic systematic review narrative synthesis"}'::jsonb,
 'direct_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000306',
 'c1000000-0000-0000-0000-000000000301',
 'scan.volume_signals.1',
 'c1000000-0000-0000-0000-000000000202',
 'Abstract',
 '{"signal_type":"reported_study_count","value":21,"qualifier":"reported_by_source","context":"GenAI safety scoping review"}'::jsonb,
 'direct_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000307',
 'c1000000-0000-0000-0000-000000000301',
 'scan.volume_signals.2',
 'c1000000-0000-0000-0000-000000000204',
 'Abstract',
 '{"signal_type":"reported_review_count","value":119,"qualifier":"reported_by_source","context":"articles included in LLM-chatbot harms scoping review; not directly comparable with intervention-study counts"}'::jsonb,
 'direct_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000308',
 'c1000000-0000-0000-0000-000000000301',
 'scan.evidence_types.0',
 'c1000000-0000-0000-0000-000000000201',
 'Publication type',
 '{"evidence_type":"meta_analysis","signal":"multiple","count":null,"qualifier":"specific GenAI efficacy synthesis exists"}'::jsonb,
 'evidence_type_classification',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000309',
 'c1000000-0000-0000-0000-000000000301',
 'scan.evidence_types.1',
 'c1000000-0000-0000-0000-000000000202',
 'Publication type',
 '{"evidence_type":"scoping_review","signal":"multiple","count":null,"qualifier":"safety/UX/harms syntheses exist"}'::jsonb,
 'evidence_type_classification',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000310',
 'c1000000-0000-0000-0000-000000000301',
 'scan.central_sources.0','c1000000-0000-0000-0000-000000000201','Whole report',
 '{"role":"recent_synthesis","reason":"Specific systematic review/meta-analysis of GenAI mental-health chatbot interventions."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000311',
 'c1000000-0000-0000-0000-000000000301',
 'scan.central_sources.1','c1000000-0000-0000-0000-000000000202','Whole report',
 '{"role":"field_overview","reason":"Specific synthesis of safety mechanisms and risk mitigation."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000312',
 'c1000000-0000-0000-0000-000000000301',
 'scan.central_sources.2','c1000000-0000-0000-0000-000000000203','Whole report',
 '{"role":"field_overview","reason":"Specific mapping of intervention design and user experience."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000313',
 'c1000000-0000-0000-0000-000000000301',
 'scan.central_sources.3','c1000000-0000-0000-0000-000000000204','Whole report',
 '{"role":"field_overview","reason":"Recent synthesis of potential and observed harms of LLM chatbots."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000314',
 'c1000000-0000-0000-0000-000000000301',
 'scan.central_sources.4','c1000000-0000-0000-0000-000000000205','Whole report',
 '{"role":"contextual","reason":"Broad LLM mental-health review clarifying that conversational support is only one application class."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000315',
 'c1000000-0000-0000-0000-000000000301',
 'scan.central_sources.5','c1000000-0000-0000-0000-000000000206','Whole report',
 '{"role":"contextual","reason":"CBT-chatbot meta-analysis defines the boundary between chatbot evidence generally and GenAI-specific evidence."}'::jsonb,
 'contextual_extraction',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000316',
 'c1000000-0000-0000-0000-000000000301',
 'scan.maturity',NULL,'OES exploratory judgement',
 '{"category":"partially_synthesized","rationale":"Multiple recent syntheses exist for efficacy, safety, UX and harms, but technology classes, intervention purposes and populations remain heterogeneous and only partially overlapping.","confidence_qualifier":"preliminary"}'::jsonb,
 'oes_exploratory_judgement','c2000000-0000-0000-0000-000000000001',
 '{"documents":["94","95"],"inputs":["efficacy synthesis","safety review","UX/design review","harms review","broad LLM review"]}'::jsonb,
 'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000317',
 'c1000000-0000-0000-0000-000000000301',
 'scan.controversies.0',NULL,'OES exploratory judgement',
 '{"statement":"Average symptom benefit reported in recent syntheses coexists with wide uncertainty, heterogeneity and nonuniform effects.","type":"methodological_difference","status":"unresolved","rationale":"Effect estimates cannot be generalized across all chatbot architectures or populations."}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000318',
 'c1000000-0000-0000-0000-000000000301',
 'scan.controversies.1',NULL,'OES exploratory judgement',
 '{"statement":"Evidence of efficacy does not establish safety; safeguards, crisis protocols and adverse-event monitoring are evaluated in a separate evidence stream.","type":"outcome_difference","status":"unresolved","rationale":"Safety and efficacy require distinct focal questions/outcomes."}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000319',
 'c1000000-0000-0000-0000-000000000301',
 'scan.controversies.2',NULL,'OES exploratory judgement',
 '{"statement":"Purpose-built GenAI mental-health chatbots and general-purpose LLM chatbots/companions are not interchangeable intervention classes.","type":"intervention_difference","status":"explained_preliminarily","rationale":"They differ in intended use, safeguards and evaluation pathways."}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000320',
 'c1000000-0000-0000-0000-000000000301',
 'scan.gaps.0',NULL,'OES exploratory judgement',
 '{"statement":"Standardized safety outcome measurement and systematic adverse-event monitoring remain limited.","scope":"safety outcomes","qualifier":"apparent_in_exploratory_search","limitation":"Not a definitive absence statement."}'::jsonb,
 'oes_exploratory_judgement','c2000000-0000-0000-0000-000000000002',NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000321',
 'c1000000-0000-0000-0000-000000000301',
 'scan.gaps.1',NULL,'OES exploratory judgement',
 '{"statement":"Long-term outcomes and dependence-related effects appear less mature than short-term efficacy evidence.","scope":"long-term outcomes","qualifier":"apparent_in_exploratory_search","limitation":"Based on recent syntheses, not exhaustive primary-study mapping."}'::jsonb,
 'oes_exploratory_judgement','c2000000-0000-0000-0000-000000000002',NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000322',
 'c1000000-0000-0000-0000-000000000301',
 'scan.gaps.2',NULL,'OES exploratory judgement',
 '{"statement":"Direct evidence separating GenAI-specific effects from traditional chatbot effects remains limited.","scope":"architecture comparison","qualifier":"apparent_in_exploratory_search","limitation":"Requires focused comparative assessment."}'::jsonb,
 'oes_exploratory_judgement','c2000000-0000-0000-0000-000000000001',NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000323',
 'c1000000-0000-0000-0000-000000000301',
 'scan.subquestions.0',NULL,'OES exploratory judgement',
 '{"text":"Em adultos com sintomas depressivos e/ou ansiosos, chatbots purpose-built baseados em GenAI/LLMs reduzem sintomas em comparação ao cuidado usual, lista de espera ou intervenção digital não generativa?","priority":"high","suggested_question_class":"intervention"}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000324',
 'c1000000-0000-0000-0000-000000000301',
 'scan.subquestions.1',NULL,'OES exploratory judgement',
 '{"text":"Em adultos que utilizam chatbots purpose-built GenAI/LLM para apoio à saúde mental, quais eventos adversos, falhas de segurança e mecanismos de mitigação foram documentados?","priority":"high","suggested_question_class":"safety"}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000325',
 'c1000000-0000-0000-0000-000000000301',
 'scan.subquestions.2',NULL,'OES exploratory judgement',
 '{"text":"Quais danos psicológicos ou padrões de dependência estão associados ao uso de LLM chatbots gerais ou companions para apoio emocional?","priority":"medium","suggested_question_class":"harm"}'::jsonb,
 'oes_exploratory_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000326',
 'c1000000-0000-0000-0000-000000000301',
 'scan.routing.recommendation',NULL,'OES routing judgement',
 '{"target":"N2","status":"recommended","requires_question_reformulation":true}'::jsonb,
 'routing_judgement',NULL,NULL,'OES','active'
),
(
 'c5000000-0000-0000-0000-000000000327',
 'c1000000-0000-0000-0000-000000000301',
 'scan.routing.rationale',NULL,'OES routing judgement',
 '{"text":"O campo é rápido, parcialmente sintetizado e multidimensional; uma Ficha N2 monitorável oferece unidade focal persistente, desde que a pergunta seja estreitada para chatbots purpose-built e mantenha eficácia e segurança como eixos explícitos.","routing_dimensions":["maturity","technology_heterogeneity","safety","maintenance_need"]}'::jsonb,
 'routing_judgement',NULL,NULL,'OES','active'
);

-- Dependency edges for central reports
INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
)
SELECT v,
       'c1000000-0000-0000-0000-000000000301'::uuid,
       'central_report_informs_evidence_scan',
       'provenance.record',
       'active'
FROM (VALUES
 ('c1000000-0000-0000-0000-000000000201'::uuid),
 ('c1000000-0000-0000-0000-000000000202'::uuid),
 ('c1000000-0000-0000-0000-000000000203'::uuid),
 ('c1000000-0000-0000-0000-000000000204'::uuid),
 ('c1000000-0000-0000-0000-000000000205'::uuid),
 ('c1000000-0000-0000-0000-000000000206'::uuid)
) t(v);

COMMIT;
