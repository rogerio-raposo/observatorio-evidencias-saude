-- OES Fase 3 — Real N3-01 revision 01 after adversarial methodological REVISE
-- Preserves ProductVersion 1, records first AI verification as revise,
-- expands search coverage, and creates ProductVersion 2.
-- Requires f3-real-case-n3-ambient-ai-scribes.sql.

BEGIN;

-- ---------------------------------------------------------------------------
-- FIRST ADVERSARIAL REVIEW AGAINST PRODUCT VERSION 1
-- ---------------------------------------------------------------------------

INSERT INTO product.assurance_record(
 assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
 independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES (
 'e3000000-0000-0000-0000-000000000701',
 'e1000000-0000-0000-0000-000000000701',
 'ai_methodological_verification',
 'OES_AI_METHOD_VERIFICATION_N3_PASS_1',
 'ai_system',false,'revise',
 TIMESTAMPTZ '2026-10-06 01:20:00-03',
 'First adversarial N3 verification identified incomplete non-duplication/search coverage after the Europe PMC runtime failure. Scientific effect synthesis remained otherwise defensible.',
 '{"document":"111-caso-real-n3-verificacao-metodologica-adversarial-01.md","result":"revise","issues":["missing_kanaparthy_rapid_review","supplementary_search_insufficiently_sensitive","eligible_contextual_2026_studies_missed"],"effect_set_changed":false,"grade_changed":false,"independent_review":false,"expert_review":false}'::jsonb,
 'active'
);

-- ---------------------------------------------------------------------------
-- SUPPLEMENTARY SEARCH WITH EXPANDED TERMINOLOGY
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,
 source_name,platform,exact_strategy,filters_payload,executed_at,
 result_count,strategy_version,operator,status
) VALUES (
 'e2000000-0000-0000-0000-000000000003',
 'OES-SRCH-2026-000703',
 'e1000000-0000-0000-0000-000000000002',
 'Corrective expanded PubMed + targeted citation discovery',
 'PubMed/Publisher/DOI/Citation',
 '("ambient AI" OR "ambient artificial intelligence" OR "ambient scribe" OR "AI scribe" OR "ambient listening" OR "digital scribe" OR "AI-powered documentation" OR "AI documentation" OR "generative AI documentation" OR "ambient documentation") AND (clinician OR physician OR provider OR trainee) AND (documentation OR note OR EHR OR burden OR burnout OR workload OR quality OR safety)',
 '{"date_from":"2025-01-01","date_to":"2026-10-05","language_focus":["English","Portuguese"],"result_count_unavailable":true,"corrective_search":true,"trigger":"adversarial_REVISE_document_111","europe_pmc_still_unavailable":true}'::jsonb,
 TIMESTAMPTZ '2026-10-06 01:25:00-03',
 NULL,'real-n3-v2-corrective','OES_REAL_N3_AI','completed'
);

-- ---------------------------------------------------------------------------
-- SUPPLEMENTARY REPORTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('e0000000-0000-0000-0000-000000000211','OES-RP-2026-000711','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000212','OES-RP-2026-000712','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000213','OES-RP-2026-000713','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000214','OES-RP-2026-000714','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000215','OES-RP-2026-000715','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000216','OES-RP-2026-000716','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000217','OES-RP-2026-000717','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000218','OES-RP-2026-000718','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000219','OES-RP-2026-000719','Report','oes-real-n3'),
('e0000000-0000-0000-0000-000000000220','OES-RP-2026-000720','Report','oes-real-n3');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
)
SELECT
 ('e1000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
 ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid,
 1,'current','oes-real-n3','initial','Corrective N3 supplementary report'
FROM generate_series(211,220) AS g(n);

INSERT INTO evidence.report(entity_uuid)
SELECT ('e0000000-0000-0000-0000-' || lpad(n::text,12,'0'))::uuid
FROM generate_series(211,220) AS g(n);

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,
 journal_or_source,language,publication_status,full_text_status,
 bibliographic_payload,status
) VALUES
(
 'e1000000-0000-0000-0000-000000000211','e0000000-0000-0000-0000-000000000211',
 'rapid_review',
 'Real-World Evidence Synthesis of Digital Scribes Using Ambient Listening and Generative Artificial Intelligence for Clinician Documentation Workflows: Rapid Review',
 DATE '2025-10-10','JMIR AI','en','published','available',
 '{"pmid":"41071988","pmcid":"PMC12513689","doi":"10.2196/76743","identified_records":1450,"included_studies":6,"coverage":"2014-2024","role":"context_nonduplication_citation_chasing"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000212','e0000000-0000-0000-0000-000000000212',
 'primary_report',
 'Ambient scribe in general practice: a multi-perspective before-after longitudinal mixed-methods study',
 DATE '2026-03-02','npj Digital Medicine','en','published','available',
 '{"pmid":"41772212","pmcid":"PMC13065737","doi":"10.1038/s41746-026-02454-3","participants":"12 GPs/GP trainees","consultations":535,"role":"contextual_prospective_implementation"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000213','e0000000-0000-0000-0000-000000000213',
 'primary_report',
 'Ambient AI Scribe Implementation in an Ambulatory Setting in a Single Medical Group: Prospective Study',
 DATE '2026-06-23','JMIR Medical Informatics','en','published','available',
 '{"pmid":"42337645","pmcid":"PMC13289844","doi":"10.2196/84104","providers":80,"notes_over":25000,"specialties":23,"role":"contextual_prospective_implementation"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000214','e0000000-0000-0000-0000-000000000214',
 'primary_report',
 'Performance, acceptability, and impact of ambient listening scribe technology in an outpatient context: a mixed methods trial evaluation',
 DATE '2026-01-08','BMC Health Services Research','en','published','available',
 '{"pmid":"41507920","pmcid":"PMC12882620","doi":"10.1186/s12913-025-13954-5","role":"contextual_mixed_methods_implementation"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000215','e0000000-0000-0000-0000-000000000215',
 'primary_report',
 'Ambient Documentation Technology in Clinician Experience of Documentation Burden and Burnout',
 DATE '2025-08-01','JAMA Network Open','en','published','available',
 '{"pmid":"40839265","pmcid":"PMC12371510","doi":"10.1001/jamanetworkopen.2025.28056","clinicians_enrolled":1430,"role":"contextual_observational_experience"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000216','e0000000-0000-0000-0000-000000000216',
 'primary_report',
 'The Effect of Ambient Artificial Intelligence Scribes on Trainee Documentation Burden',
 DATE '2025-07-02','Applied Clinical Informatics','en','published','available',
 '{"pmid":"40602775","pmcid":"PMC12367366","doi":"10.1055/a-2647-1142","participants":47,"role":"contextual_trainee_population"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000217','e0000000-0000-0000-0000-000000000217',
 'primary_report',
 'Ambient Listening in Clinical Practice: Evaluating EPIC Signal Data Before and After Implementation and Its Impact on Physician Workload',
 DATE '2025-08-07','Studies in Health Technology and Informatics','en','published','available',
 '{"pmid":"40775939","pmcid":"PMC13039322","doi":"10.3233/SHTI250921","role":"contextual_before_after"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000218','e0000000-0000-0000-0000-000000000218',
 'primary_report',
 'Evaluating the Quality and Safety of Ambient Digital Scribe Platforms Using Simulated Ambulatory Encounters',
 NULL,'Mayo Clinic Proceedings: Digital Health','en','published','available',
 '{"pmid":"41234546","pmcid":"PMC12605248","doi":"10.1016/j.mcpdig.2025.100292","exclusion_reason":"simulated_encounters"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000219','e0000000-0000-0000-0000-000000000219',
 'primary_report',
 'Comparative evaluation of ambient digital scribe systems in clinical documentation',
 DATE '2026-09-23','JAMIA','en','published','available',
 '{"pmid":"42776572","doi":"10.1093/jamia/ocag157","exclusion_reason":"simulated_encounters"}'::jsonb,'active'
),
(
 'e1000000-0000-0000-0000-000000000220','e0000000-0000-0000-0000-000000000220',
 'narrative_review',
 'Transforming clinical documentation with ambient artificial intelligence (AI) scribes: a narrative review of technology, impact, and implementation',
 DATE '2026-02-28','Cardiovascular Diagnosis and Therapy','en','published','available',
 '{"pmid":"41815573","pmcid":"PMC12973079","doi":"10.21037/cdt-2025-454","exclusion_reason":"narrative_secondary_review_not_update_unit"}'::jsonb,'active'
);

-- ---------------------------------------------------------------------------
-- SUPPLEMENTARY SEARCH HITS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search_hit(
 search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
 source_record_id,raw_payload,raw_title,raw_year,raw_identifier,
 source_rank,resolution_status
) VALUES
('e2500000-0000-0000-0000-000000000211','OES-HIT-2026-000711','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000211','PMID:41071988','{"corrective_search":true}'::jsonb,'Real-World Evidence Synthesis of Digital Scribes Using Ambient Listening and Generative Artificial Intelligence for Clinician Documentation Workflows: Rapid Review',2025,'PMID:41071988',1,'linked'),
('e2500000-0000-0000-0000-000000000212','OES-HIT-2026-000712','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000212','PMID:41772212','{"corrective_search":true}'::jsonb,'Ambient scribe in general practice: a multi-perspective before-after longitudinal mixed-methods study',2026,'PMID:41772212',2,'linked'),
('e2500000-0000-0000-0000-000000000213','OES-HIT-2026-000713','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000213','PMID:42337645','{"corrective_search":true}'::jsonb,'Ambient AI Scribe Implementation in an Ambulatory Setting in a Single Medical Group: Prospective Study',2026,'PMID:42337645',3,'linked'),
('e2500000-0000-0000-0000-000000000214','OES-HIT-2026-000714','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000214','PMID:41507920','{"corrective_search":true}'::jsonb,'Performance, acceptability, and impact of ambient listening scribe technology in an outpatient context',2026,'PMID:41507920',4,'linked'),
('e2500000-0000-0000-0000-000000000215','OES-HIT-2026-000715','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000215','PMID:40839265','{"corrective_search":true}'::jsonb,'Ambient Documentation Technology in Clinician Experience of Documentation Burden and Burnout',2025,'PMID:40839265',5,'linked'),
('e2500000-0000-0000-0000-000000000216','OES-HIT-2026-000716','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000216','PMID:40602775','{"corrective_search":true}'::jsonb,'The Effect of Ambient Artificial Intelligence Scribes on Trainee Documentation Burden',2025,'PMID:40602775',6,'linked'),
('e2500000-0000-0000-0000-000000000217','OES-HIT-2026-000717','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000217','PMID:40775939','{"corrective_search":true}'::jsonb,'Ambient Listening in Clinical Practice: Evaluating EPIC Signal Data Before and After Implementation and Its Impact on Physician Workload',2025,'PMID:40775939',7,'linked'),
('e2500000-0000-0000-0000-000000000218','OES-HIT-2026-000718','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000218','PMID:41234546','{"corrective_search":true}'::jsonb,'Evaluating the Quality and Safety of Ambient Digital Scribe Platforms Using Simulated Ambulatory Encounters',2025,'PMID:41234546',8,'linked'),
('e2500000-0000-0000-0000-000000000219','OES-HIT-2026-000719','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000219','PMID:42776572','{"corrective_search":true}'::jsonb,'Comparative evaluation of ambient digital scribe systems in clinical documentation',2026,'PMID:42776572',9,'linked'),
('e2500000-0000-0000-0000-000000000220','OES-HIT-2026-000720','e2000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000220','PMID:41815573','{"corrective_search":true}'::jsonb,'Transforming clinical documentation with ambient artificial intelligence scribes: a narrative review',2026,'PMID:41815573',10,'linked');

-- ---------------------------------------------------------------------------
-- SUPPLEMENTARY SCREENING
-- ---------------------------------------------------------------------------

INSERT INTO investigation.screening_decision(
 screening_uuid,oes_screening_id,investigation_version_uuid,
 target_entity_uuid,stage,reviewer,decision,exclusion_reason,
 decided_at,parent_decision_uuid,adjudication_flag
) VALUES
('e3500000-0000-0000-0000-000000000211','OES-SCR-2026-000721','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000211','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:30:00-03',NULL,false),
('e3500000-0000-0000-0000-000000000212','OES-SCR-2026-000722','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000212','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:30:10-03',NULL,false),
('e3500000-0000-0000-0000-000000000213','OES-SCR-2026-000723','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000213','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:30:20-03',NULL,false),
('e3500000-0000-0000-0000-000000000214','OES-SCR-2026-000724','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000214','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:30:30-03',NULL,false),
('e3500000-0000-0000-0000-000000000215','OES-SCR-2026-000725','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000215','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:30:40-03',NULL,false),
('e3500000-0000-0000-0000-000000000216','OES-SCR-2026-000726','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000216','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:30:50-03',NULL,false),
('e3500000-0000-0000-0000-000000000217','OES-SCR-2026-000727','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000217','title_abstract','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:31:00-03',NULL,false),
('e3500000-0000-0000-0000-000000000218','OES-SCR-2026-000728','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000218','title_abstract','OES_REAL_N3_AI','exclude','simulated_encounters',TIMESTAMPTZ '2026-10-06 01:31:10-03',NULL,false),
('e3500000-0000-0000-0000-000000000219','OES-SCR-2026-000729','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000219','title_abstract','OES_REAL_N3_AI','exclude','simulated_encounters',TIMESTAMPTZ '2026-10-06 01:31:20-03',NULL,false),
('e3500000-0000-0000-0000-000000000220','OES-SCR-2026-000730','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000220','title_abstract','OES_REAL_N3_AI','exclude','narrative_secondary_review_not_update_unit',TIMESTAMPTZ '2026-10-06 01:31:30-03',NULL,false),

('e3500000-0000-0000-0000-000000000311','OES-SCR-2026-000731','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000211','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:32:00-03','e3500000-0000-0000-0000-000000000211',false),
('e3500000-0000-0000-0000-000000000312','OES-SCR-2026-000732','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000212','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:32:10-03','e3500000-0000-0000-0000-000000000212',false),
('e3500000-0000-0000-0000-000000000313','OES-SCR-2026-000733','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000213','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:32:20-03','e3500000-0000-0000-0000-000000000213',false),
('e3500000-0000-0000-0000-000000000314','OES-SCR-2026-000734','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000214','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:32:30-03','e3500000-0000-0000-0000-000000000214',false),
('e3500000-0000-0000-0000-000000000315','OES-SCR-2026-000735','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000215','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:32:40-03','e3500000-0000-0000-0000-000000000215',false),
('e3500000-0000-0000-0000-000000000316','OES-SCR-2026-000736','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000216','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:32:50-03','e3500000-0000-0000-0000-000000000216',false),
('e3500000-0000-0000-0000-000000000317','OES-SCR-2026-000737','e1000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000217','full_text','OES_REAL_N3_AI','include',NULL,TIMESTAMPTZ '2026-10-06 01:33:00-03','e3500000-0000-0000-0000-000000000217',false);

-- ---------------------------------------------------------------------------
-- SUPERSEDE PRODUCT VERSION 1
-- ---------------------------------------------------------------------------

UPDATE product.product_version
   SET status='superseded'
 WHERE version_uuid='e1000000-0000-0000-0000-000000000701';

UPDATE core.entity_version
   SET version_status='superseded',
       valid_to=CURRENT_TIMESTAMP
 WHERE version_uuid='e1000000-0000-0000-0000-000000000701';

-- ---------------------------------------------------------------------------
-- PRODUCT VERSION 2 — SEARCH COVERAGE CORRECTION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,valid_from,
 supersedes_version_uuid,created_by,change_type,change_note
) VALUES (
 'e1000000-0000-0000-0000-000000000702',
 'e0000000-0000-0000-0000-000000000701',
 2,'current',CURRENT_TIMESTAMP,
 'e1000000-0000-0000-0000-000000000701',
 'oes-real-n3','scientific_correction',
 'Expands search terminology and contextual coverage after adversarial REVISE; effect set, syntheses and experimental GRADE remain unchanged.'
);

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,publication_date,status,conclusion_text,
 applicability_summary,limitations_summary
) VALUES (
 'e1000000-0000-0000-0000-000000000702',
 'e0000000-0000-0000-0000-000000000701',
 'rapid_evidence_synthesis',
 'Síntese Rápida Experimental — Ambient AI Scribes e Carga de Documentação Clínica',
 'OES internal methodological validation',
 DATE '2026-10-05',
 NULL,
 'under_review',
 'Ambient AI scribes podem reduzir o tempo de documentação e alguns componentes de carga/exaustão entre clínicos ambulatoriais, mas o tamanho do benefício varia por produto e contexto. A evidência sobre segurança é muito mais incerta: estudos não demonstram degradação média consistente da qualidade, porém inaccuracies, omissões e erros potencialmente graves foram observados. O corpo atual não sustenta tratar todas as ferramentas como equivalentes nem assumir que ganhos de eficiência implicam segurança equivalente.',
 'A evidência deriva predominantemente de sistemas de saúde e early adopters, com integrações EHR específicas e versões de produtos em rápida evolução. A busca corretiva acrescentou contextos dos Estados Unidos, Países Baixos e Austrália, mas aplicabilidade formal não foi avaliada.',
 'Rapid-method limitations: Europe PMC could not be executed reproducibly. After adversarial REVISE, an expanded PubMed/targeted search added digital-scribe and AI-documentation terminology plus citation chasing, recovering additional contextual studies and a dedicated rapid review. Result counts remain unavailable; Embase/Scopus/CINAHL were not searched by OES; English/Portuguese focus remains; screening, extraction, appraisal and certainty were AI-assisted; qualified human controls and expert review are absent; no new meta-analysis was performed.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 'e1000000-0000-0000-0000-000000000702',
 'e1000000-0000-0000-0000-000000000002',
 'primary',1
);

INSERT INTO product.synthesis_link(
 product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000501','primary',1),
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000502','critical',2),
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000503','critical',3),
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000504','critical',4);

INSERT INTO product.certainty_link(
 product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000601','primary',1),
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000602','critical',2),
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000603','critical',3),
('e1000000-0000-0000-0000-000000000702','e1000000-0000-0000-0000-000000000604','critical',4);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,
 assessed_at,assessed_by,rationale,record_status
) VALUES (
 'e7000000-0000-0000-0000-000000000702',
 'e1000000-0000-0000-0000-000000000702',
 'current',TIMESTAMPTZ '2026-10-06 01:40:00-03',
 'OES_REAL_N3_AI',
 'Evidence cutoff remains 2026-10-05; corrective search improved retrieval coverage without changing the comparative effect set.',
 'active'
);

INSERT INTO product.version_change_class(
 product_version_uuid,change_class,rationale,sequence_no
) VALUES
(
 'e1000000-0000-0000-0000-000000000702',
 'scientific_correction',
 'Corrects insufficient supplementary search sensitivity identified by adversarial verification.',
 1
),
(
 'e1000000-0000-0000-0000-000000000702',
 'new_evidence',
 'Adds seven contextual reports and a dedicated rapid review recovered by expanded terminology.',
 2
);

-- ---------------------------------------------------------------------------
-- CONTEXTUAL PROVENANCE FOR VERSION 2
-- ---------------------------------------------------------------------------

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,transformation,actor,status
) VALUES
(
 'e5000000-0000-0000-0000-000000000711',
 'e1000000-0000-0000-0000-000000000702',
 'context.implementation_study.stults',
 'e1000000-0000-0000-0000-000000000204',
 'Whole report',
 '{"role":"contextual implementation evidence","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',
 '{"reason":"before-after/QI evidence supports implementation context but does not enter randomized causal synthesis"}'::jsonb,
 'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000712',
 'e1000000-0000-0000-0000-000000000702',
 'context.baseline_review.bracken',
 'e1000000-0000-0000-0000-000000000206',
 'Whole report',
 '{"role":"context/non-duplication/citation chasing","adopted_as_effect_source":false}'::jsonb,
 'contextual_reference',
 '{"reason":"systematic review provides broad historical context but predates key peer-reviewed randomized evidence"}'::jsonb,
 'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000713',
 'e1000000-0000-0000-0000-000000000702',
 'context.baseline_review.kanaparthy',
 'e1000000-0000-0000-0000-000000000211',
 'Whole report',
 '{"role":"context/non-duplication/citation chasing","adopted_as_effect_source":false,"coverage":"2014-2024"}'::jsonb,
 'contextual_reference',
 '{"reason":"dedicated rapid review of ambient/digital scribes confirms sparse pre-RCT real-world evidence and supports need for update"}'::jsonb,
 'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000714',
 'e1000000-0000-0000-0000-000000000702',
 'context.corrective_search.van_linschoten',
 'e1000000-0000-0000-0000-000000000212',
 'Whole report',
 '{"role":"contextual prospective implementation","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',NULL,'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000715',
 'e1000000-0000-0000-0000-000000000702',
 'context.corrective_search.harvey',
 'e1000000-0000-0000-0000-000000000213',
 'Whole report',
 '{"role":"contextual prospective implementation","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',NULL,'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000716',
 'e1000000-0000-0000-0000-000000000702',
 'context.corrective_search.memon',
 'e1000000-0000-0000-0000-000000000214',
 'Whole report',
 '{"role":"contextual mixed-methods implementation","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',NULL,'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000717',
 'e1000000-0000-0000-0000-000000000702',
 'context.corrective_search.you',
 'e1000000-0000-0000-0000-000000000215',
 'Whole report',
 '{"role":"contextual observational clinician experience","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',NULL,'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000718',
 'e1000000-0000-0000-0000-000000000702',
 'context.corrective_search.wright',
 'e1000000-0000-0000-0000-000000000216',
 'Whole report',
 '{"role":"contextual trainee population","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',NULL,'OES_REAL_N3_AI','active'
),
(
 'e5000000-0000-0000-0000-000000000719',
 'e1000000-0000-0000-0000-000000000702',
 'context.corrective_search.guo',
 'e1000000-0000-0000-0000-000000000217',
 'Whole report',
 '{"role":"contextual before-after implementation","adopted_as_causal_effect_source":false}'::jsonb,
 'contextual_reference',NULL,'OES_REAL_N3_AI','active'
);

-- Dependency edges to corrected ProductVersion 2.
INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
('e1000000-0000-0000-0000-000000000601','e1000000-0000-0000-0000-000000000702','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000602','e1000000-0000-0000-0000-000000000702','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000603','e1000000-0000-0000-0000-000000000702','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000604','e1000000-0000-0000-0000-000000000702','certainty_informs_product','product.certainty_link','active'),
('e1000000-0000-0000-0000-000000000204','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000206','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000211','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000212','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000213','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000214','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000215','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000216','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active'),
('e1000000-0000-0000-0000-000000000217','e1000000-0000-0000-0000-000000000702','contextual_report_informs_product','provenance.record','active');

COMMIT;
