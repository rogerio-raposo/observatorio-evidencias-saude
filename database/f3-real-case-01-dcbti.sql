-- OES Fase 3 — Real Case 01: fully automated dCBT-I
-- Purpose: end-to-end scientific/product validation of an N2 Evidence Sheet.
-- Evidence cutoff: 2026-10-04
-- This dataset models an adopted external meta-analysis plus an OES narrative update.
-- It does NOT claim that OES recalculated the published meta-analysis.

BEGIN;

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION / OUTCOME
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000001','OES-Q-2026-000401','Question','real-case-01'),
('80000000-0000-0000-0000-000000000002','OES-I-2026-000401','Investigation','real-case-01'),
('80000000-0000-0000-0000-000000000003','OES-O-2026-000401','Outcome','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001',1,'current','real-case-01','initial','Real case 01 question'),
('81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000002',1,'current','real-case-01','initial','Real case 01 N2 investigation'),
('81000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000003',1,'current','real-case-01','initial','Insomnia severity outcome');

INSERT INTO investigation.question(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,question_type,structure_type,
 context_payload,time_horizon_payload
) VALUES (
 '81000000-0000-0000-0000-000000000001',
 '80000000-0000-0000-0000-000000000001',
 'Em adultos com insônia, a dCBT-I totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia ao final do tratamento?',
 'Em adultos com insônia, dCBT-I multicomponente totalmente automatizada, comparada à educação digital sobre sono ou higiene do sono, reduz a gravidade da insônia no primeiro pós-tratamento completo?',
 'intervention',
 'PICO',
 '{"population":"adults with insomnia","intervention":"fully automated multicomponent dCBT-I","comparator":"digital sleep education or sleep hygiene education","primary_outcome":"insomnia severity"}'::jsonb,
 '{"primary_window":"approximately 6-12 weeks after baseline","follow_up":"separate"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
 version_uuid,entity_uuid,primary_question_entity_uuid,investigation_type,
 depth_level,maintenance_level,objective,start_date,evidence_cutoff_date,status
) VALUES (
 '81000000-0000-0000-0000-000000000002',
 '80000000-0000-0000-0000-000000000002',
 '80000000-0000-0000-0000-000000000001',
 'evidence_sheet',
 'N2','M1',
 'Validate the complete OES Evidence Sheet pipeline with a real intervention question',
 DATE '2026-10-04',
 DATE '2026-10-04',
 'active'
);

INSERT INTO investigation.investigation_question(
 investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
 '81000000-0000-0000-0000-000000000002',
 '81000000-0000-0000-0000-000000000001',
 'primary',1
);

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000003');

INSERT INTO evidence.outcome_version(
 version_uuid,entity_uuid,preferred_name,definition,direction_of_benefit,unit_family,status
) VALUES (
 '81000000-0000-0000-0000-000000000003',
 '80000000-0000-0000-0000-000000000003',
 'Gravidade da insônia no pós-tratamento',
 'Insomnia severity measured with the ISI or another validated insomnia-severity instrument at the first complete post-treatment assessment.',
 'lower',
 'scale_score',
 'active'
);

-- ---------------------------------------------------------------------------
-- SEARCH RECORDS
-- result_count remains NULL where the execution environment did not expose
-- a trustworthy raw database hit count. This is intentional.
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,source_name,platform,
 exact_strategy,filters_payload,executed_at,result_count,strategy_version,operator,status
) VALUES
(
 '82000000-0000-0000-0000-000000000001','OES-S-2026-000401',
 '81000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(insomnia[Title/Abstract]) AND ("digital cognitive behavioral therapy"[Title/Abstract] OR "digital cognitive behavioural therapy"[Title/Abstract] OR "internet cognitive behavioral therapy"[Title/Abstract] OR "internet cognitive behavioural therapy"[Title/Abstract] OR dCBT-I[Title/Abstract] OR "fully automated"[Title/Abstract]) AND (systematic review[Publication Type] OR meta-analysis[Publication Type] OR systematic review[Title/Abstract] OR meta-analysis[Title/Abstract])',
 '{"purpose":"systematic reviews and meta-analyses","language_restriction":null}'::jsonb,
 TIMESTAMPTZ '2026-10-04 12:07:00-03',NULL,'1','OES','completed'
),
(
 '82000000-0000-0000-0000-000000000002','OES-S-2026-000402',
 '81000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(insomnia[Title/Abstract]) AND ("digital cognitive behavioral therapy"[Title/Abstract] OR "digital cognitive behavioural therapy"[Title/Abstract] OR "internet cognitive behavioral therapy"[Title/Abstract] OR "internet cognitive behavioural therapy"[Title/Abstract] OR dCBT-I[Title/Abstract] OR "fully automated"[Title/Abstract]) AND (randomized controlled trial[Publication Type] OR randomized[Title/Abstract] OR randomised[Title/Abstract])',
 '{"purpose":"RCT update","comparator_applied_at_eligibility":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 12:07:00-03',NULL,'1','OES','completed'
),
(
 '82000000-0000-0000-0000-000000000003','OES-S-2026-000403',
 '81000000-0000-0000-0000-000000000002',
 'BVS/LILACS','BVS',
 'insomnia AND (digital CBT-I OR terapia cognitivo-comportamental digital OR terapia cognitivo comportamental online)',
 '{"purpose":"regional/Brazilian evidence"}'::jsonb,
 TIMESTAMPTZ '2026-10-04 12:07:00-03',NULL,'1','OES','completed'
),
(
 '82000000-0000-0000-0000-000000000004','OES-S-2026-000404',
 '81000000-0000-0000-0000-000000000002',
 'ClinicalTrials.gov','ClinicalTrials.gov',
 'insomnia AND (digital CBT OR digital CBT-I OR internet CBT-I)',
 '{"purpose":"trial identity and unpublished/ongoing studies"}'::jsonb,
 TIMESTAMPTZ '2026-10-04 12:07:00-03',NULL,'1','OES','completed'
);

-- ---------------------------------------------------------------------------
-- STUDIES / REPORTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000101','OES-ST-2026-000411','Study','real-case-01'),
('80000000-0000-0000-0000-000000000102','OES-ST-2026-000412','Study','real-case-01'),
('80000000-0000-0000-0000-000000000103','OES-ST-2026-000413','Study','real-case-01'),
('80000000-0000-0000-0000-000000000104','OES-ST-2026-000414','Study','real-case-01'),
('80000000-0000-0000-0000-000000000105','OES-ST-2026-000415','Study','real-case-01'),
('80000000-0000-0000-0000-000000000106','OES-ST-2026-000416','Study','real-case-01'),
('80000000-0000-0000-0000-000000000201','OES-RP-2026-000411','Report','real-case-01'),
('80000000-0000-0000-0000-000000000202','OES-RP-2026-000412','Report','real-case-01'),
('80000000-0000-0000-0000-000000000203','OES-RP-2026-000413','Report','real-case-01'),
('80000000-0000-0000-0000-000000000204','OES-RP-2026-000414','Report','real-case-01'),
('80000000-0000-0000-0000-000000000205','OES-RP-2026-000415','Report','real-case-01'),
('80000000-0000-0000-0000-000000000206','OES-RP-2026-000416','Report','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000101','80000000-0000-0000-0000-000000000101',1,'current','real-case-01','initial','Hwang systematic review'),
('81000000-0000-0000-0000-000000000102','80000000-0000-0000-0000-000000000102',1,'current','real-case-01','initial','Gao systematic review'),
('81000000-0000-0000-0000-000000000103','80000000-0000-0000-0000-000000000103',1,'current','real-case-01','initial','Sweetman RCT'),
('81000000-0000-0000-0000-000000000104','80000000-0000-0000-0000-000000000104',1,'current','real-case-01','initial','SleepioRx RCT'),
('81000000-0000-0000-0000-000000000105','80000000-0000-0000-0000-000000000105',1,'current','real-case-01','initial','SHUTi OASIS RCT'),
('81000000-0000-0000-0000-000000000106','80000000-0000-0000-0000-000000000106',1,'current','real-case-01','initial','Somzz RCT'),
('81000000-0000-0000-0000-000000000201','80000000-0000-0000-0000-000000000201',1,'current','real-case-01','initial','Hwang report'),
('81000000-0000-0000-0000-000000000202','80000000-0000-0000-0000-000000000202',1,'current','real-case-01','initial','Gao report'),
('81000000-0000-0000-0000-000000000203','80000000-0000-0000-0000-000000000203',1,'current','real-case-01','initial','Sweetman report'),
('81000000-0000-0000-0000-000000000204','80000000-0000-0000-0000-000000000204',1,'current','real-case-01','initial','SleepioRx report'),
('81000000-0000-0000-0000-000000000205','80000000-0000-0000-0000-000000000205',1,'current','real-case-01','initial','SHUTi OASIS report'),
('81000000-0000-0000-0000-000000000206','80000000-0000-0000-0000-000000000206',1,'current','real-case-01','initial','Somzz report');

INSERT INTO evidence.study(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000101'),
('80000000-0000-0000-0000-000000000102'),
('80000000-0000-0000-0000-000000000103'),
('80000000-0000-0000-0000-000000000104'),
('80000000-0000-0000-0000-000000000105'),
('80000000-0000-0000-0000-000000000106');

INSERT INTO evidence.study_version(
 version_uuid,entity_uuid,study_type,design,title_or_label,sample_size,status
) VALUES
('81000000-0000-0000-0000-000000000101','80000000-0000-0000-0000-000000000101','systematic_review','systematic_review_meta_analysis','Hwang et al. 2025 — fully automated dCBT-I',9475,'active'),
('81000000-0000-0000-0000-000000000102','80000000-0000-0000-0000-000000000102','systematic_review','systematic_review_meta_analysis','Gao et al. 2026 — fully automated dCBT-I',3507,'active'),
('81000000-0000-0000-0000-000000000103','80000000-0000-0000-0000-000000000103','primary_study','randomized_trial','Sweetman et al. 2024',62,'active'),
('81000000-0000-0000-0000-000000000104','80000000-0000-0000-0000-000000000104','primary_study','randomized_trial','SleepioRx / CrEDIT 2025',336,'active'),
('81000000-0000-0000-0000-000000000105','80000000-0000-0000-0000-000000000105','primary_study','randomized_trial','SHUTi OASIS 2025',311,'active'),
('81000000-0000-0000-0000-000000000106','80000000-0000-0000-0000-000000000106','primary_study','randomized_trial','Somzz 2024',98,'active');

INSERT INTO evidence.report(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000201'),
('80000000-0000-0000-0000-000000000202'),
('80000000-0000-0000-0000-000000000203'),
('80000000-0000-0000-0000-000000000204'),
('80000000-0000-0000-0000-000000000205'),
('80000000-0000-0000-0000-000000000206');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,language,
 publication_status,full_text_status,bibliographic_payload,status
) VALUES
(
 '81000000-0000-0000-0000-000000000201','80000000-0000-0000-0000-000000000201',
 'journal_article',
 'Systematic review and meta-analysis on fully automated digital cognitive behavioral therapy for insomnia',
 DATE '2025-03-12','npj Digital Medicine','en','published','available',
 '{"pmid":"40075149","pmcid":"PMC11903857","doi":"10.1038/s41746-025-01514-4","prospero":"CRD42024526617"}'::jsonb,'active'
),
(
 '81000000-0000-0000-0000-000000000202','80000000-0000-0000-0000-000000000202',
 'journal_article',
 'Efficacy of fully automated digital cognitive behavioral therapy for insomnia in adults: a systematic review and meta-analysis',
 NULL,'Sleep and Breathing','en','published','available',
 '{"pmid":"42240717","doi":"10.1007/s11325-026-03723-x","year":2026}'::jsonb,'active'
),
(
 '81000000-0000-0000-0000-000000000203','80000000-0000-0000-0000-000000000203',
 'journal_article',
 'Digital cognitive behavioural therapy for insomnia versus digital sleep education control in an Australian community-based sample: a randomised controlled trial',
 DATE '2024-09-11','Internal Medicine Journal','en','published','available',
 '{"pmid":"39257295","doi":"10.1111/imj.16521"}'::jsonb,'active'
),
(
 '81000000-0000-0000-0000-000000000204','80000000-0000-0000-0000-000000000204',
 'journal_article',
 'The Effectiveness of Digital Cognitive Behavioral Therapy to Treat Insomnia Disorder in US Adults: Nationwide Decentralized Randomized Controlled Trial',
 NULL,'JMIR Mental Health','en','published','available',
 '{"pmid":"41343796","doi":"10.2196/84323","clinicaltrials":"NCT05541055","year":2025}'::jsonb,'active'
),
(
 '81000000-0000-0000-0000-000000000205','80000000-0000-0000-0000-000000000205',
 'journal_article',
 'A randomized controlled trial of a digital cognitive behavioral therapy for insomnia for older adults',
 DATE '2025-07-19','npj Digital Medicine','en','published','available',
 '{"pmid":"40681664","pmcid":"PMC12274496","doi":"10.1038/s41746-025-01847-0","clinicaltrials":"NCT03213132"}'::jsonb,'active'
),
(
 '81000000-0000-0000-0000-000000000206','80000000-0000-0000-0000-000000000206',
 'journal_article',
 'Efficacy of Mobile App-Based Cognitive Behavioral Therapy for Insomnia: Multicenter, Single-Blind Randomized Clinical Trial',
 DATE '2024-07-26','Journal of Medical Internet Research','en','published','available',
 '{"pmid":"39058549","pmcid":"PMC11316165","doi":"10.2196/50555","trial_registration":"KCT0007292"}'::jsonb,'active'
);

INSERT INTO evidence.study_report_link(
 link_uuid,study_entity_uuid,report_entity_uuid,relation_type,confidence,reviewer,status
) VALUES
('82100000-0000-0000-0000-000000000201','80000000-0000-0000-0000-000000000101','80000000-0000-0000-0000-000000000201','primary_report','confirmed','OES','active'),
('82100000-0000-0000-0000-000000000202','80000000-0000-0000-0000-000000000102','80000000-0000-0000-0000-000000000202','primary_report','confirmed','OES','active'),
('82100000-0000-0000-0000-000000000203','80000000-0000-0000-0000-000000000103','80000000-0000-0000-0000-000000000203','primary_report','confirmed','OES','active'),
('82100000-0000-0000-0000-000000000204','80000000-0000-0000-0000-000000000104','80000000-0000-0000-0000-000000000204','primary_report','confirmed','OES','active'),
('82100000-0000-0000-0000-000000000205','80000000-0000-0000-0000-000000000105','80000000-0000-0000-0000-000000000205','primary_report','confirmed','OES','active'),
('82100000-0000-0000-0000-000000000206','80000000-0000-0000-0000-000000000106','80000000-0000-0000-0000-000000000206','primary_report','confirmed','OES','active');

-- Captured search hits. These are the material records used by the N2 case,
-- not a claim that this is the complete raw PubMed export.

INSERT INTO investigation.search_hit(
 search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,source_record_id,
 raw_title,raw_year,raw_identifier,resolution_status
) VALUES
('82200000-0000-0000-0000-000000000201','OES-SH-2026-000411','82000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000201','40075149','Systematic review and meta-analysis on fully automated digital cognitive behavioral therapy for insomnia',2025,'PMID:40075149','resolved'),
('82200000-0000-0000-0000-000000000202','OES-SH-2026-000412','82000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000202','42240717','Efficacy of fully automated digital cognitive behavioral therapy for insomnia in adults',2026,'PMID:42240717','resolved'),
('82200000-0000-0000-0000-000000000203','OES-SH-2026-000413','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000203','39257295','Digital cognitive behavioural therapy for insomnia versus digital sleep education control',2024,'PMID:39257295','resolved'),
('82200000-0000-0000-0000-000000000204','OES-SH-2026-000414','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000204','41343796','The Effectiveness of Digital Cognitive Behavioral Therapy to Treat Insomnia Disorder in US Adults',2025,'PMID:41343796','resolved'),
('82200000-0000-0000-0000-000000000205','OES-SH-2026-000415','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000205','40681664','A randomized controlled trial of a digital cognitive behavioral therapy for insomnia for older adults',2025,'PMID:40681664','resolved'),
('82200000-0000-0000-0000-000000000206','OES-SH-2026-000416','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000206','39058549','Efficacy of Mobile App-Based Cognitive Behavioral Therapy for Insomnia',2024,'PMID:39058549','resolved');

INSERT INTO investigation.screening_decision(
 screening_uuid,oes_screening_id,investigation_version_uuid,target_entity_uuid,
 stage,reviewer,decision,decided_at
) VALUES
('82300000-0000-0000-0000-000000000201','OES-SC-2026-000411','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000201','full_text','OES','include',TIMESTAMPTZ '2026-10-04 12:07:00-03'),
('82300000-0000-0000-0000-000000000202','OES-SC-2026-000412','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000202','full_text','OES','include',TIMESTAMPTZ '2026-10-04 12:07:00-03'),
('82300000-0000-0000-0000-000000000203','OES-SC-2026-000413','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000203','full_text','OES','include',TIMESTAMPTZ '2026-10-04 12:07:00-03'),
('82300000-0000-0000-0000-000000000204','OES-SC-2026-000414','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000204','full_text','OES','include',TIMESTAMPTZ '2026-10-04 12:07:00-03'),
('82300000-0000-0000-0000-000000000205','OES-SC-2026-000415','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000205','full_text','OES','include',TIMESTAMPTZ '2026-10-04 12:07:00-03'),
('82300000-0000-0000-0000-000000000206','OES-SC-2026-000416','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000206','full_text','OES','include',TIMESTAMPTZ '2026-10-04 12:07:00-03');

-- ---------------------------------------------------------------------------
-- RESULTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000301','OES-RS-2026-000411','Result','real-case-01'),
('80000000-0000-0000-0000-000000000302','OES-RS-2026-000412','Result','real-case-01'),
('80000000-0000-0000-0000-000000000303','OES-RS-2026-000413','Result','real-case-01'),
('80000000-0000-0000-0000-000000000304','OES-RS-2026-000414','Result','real-case-01'),
('80000000-0000-0000-0000-000000000305','OES-RS-2026-000415','Result','real-case-01'),
('80000000-0000-0000-0000-000000000306','OES-RS-2026-000416','Result','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000301','80000000-0000-0000-0000-000000000301',1,'current','real-case-01','initial','Hwang subgroup effect'),
('81000000-0000-0000-0000-000000000302','80000000-0000-0000-0000-000000000302',1,'current','real-case-01','initial','Gao overall effect'),
('81000000-0000-0000-0000-000000000303','80000000-0000-0000-0000-000000000303',1,'current','real-case-01','initial','Sweetman post-treatment result'),
('81000000-0000-0000-0000-000000000304','80000000-0000-0000-0000-000000000304',1,'current','real-case-01','initial','SleepioRx post-treatment result'),
('81000000-0000-0000-0000-000000000305','80000000-0000-0000-0000-000000000305',1,'current','real-case-01','initial','OASIS post-treatment response result'),
('81000000-0000-0000-0000-000000000306','80000000-0000-0000-0000-000000000306',1,'current','real-case-01','initial','Somzz post-treatment ISI result');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid) VALUES
('80000000-0000-0000-0000-000000000301','80000000-0000-0000-0000-000000000101'),
('80000000-0000-0000-0000-000000000302','80000000-0000-0000-0000-000000000102'),
('80000000-0000-0000-0000-000000000303','80000000-0000-0000-0000-000000000103'),
('80000000-0000-0000-0000-000000000304','80000000-0000-0000-0000-000000000104'),
('80000000-0000-0000-0000-000000000305','80000000-0000-0000-0000-000000000105'),
('80000000-0000-0000-0000-000000000306','80000000-0000-0000-0000-000000000106');

INSERT INTO evidence.result_version(
 version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,timepoint_label,
 estimand,measure,reported_value,ci_lower,ci_upper,unit,adjusted_flag,
 analysis_population,method_payload,status
) VALUES
(
 '81000000-0000-0000-0000-000000000301','80000000-0000-0000-0000-000000000301',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults in RCTs included in the online-education subgroup"}'::jsonb,
 'post-treatment',
 'effect_of_assignment',
 'standardized_mean_difference',
 '{"value":-0.93,"reported_study_count":10,"heterogeneity_i2":68}'::jsonb,
 -1.07,-0.79,'SD units',true,'meta-analysis',
 '{"source":"published meta-analysis","recalculated_by_oes":false,"comparator":"online education about sleep"}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000302','80000000-0000-0000-0000-000000000302',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"general adult populations"}'::jsonb,
 'post-treatment',
 'effect_of_assignment',
 'standardized_mean_difference',
 '{"value":-0.82,"reported_trial_count":15}'::jsonb,
 NULL,NULL,'SD units',true,'meta-analysis',
 '{"source":"published meta-analysis","recalculated_by_oes":false,"role":"corroborative"}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000303','80000000-0000-0000-0000-000000000303',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"Australian community adults with insomnia symptoms"}'::jsonb,
 '8 weeks',
 'effect_of_assignment',
 'adjusted_mean_difference_isi',
 '{"value":7.32,"contrast":"control_minus_intervention","cohen_d":1.64}'::jsonb,
 5.0,9.6,'ISI points',true,'intention_to_treat',
 '{"direction":"favors_intervention","model":"mixed models"}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000304','80000000-0000-0000-0000-000000000304',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"US adults with DSM-5 insomnia disorder"}'::jsonb,
 '10 weeks',
 'effect_of_assignment',
 'cohen_d',
 '{"value":0.60,"adjusted_mean_difference":-2.37,"adjusted_ci_99":[-3.81,-0.92]}'::jsonb,
 NULL,NULL,'standardized effect',true,'intention_to_treat',
 '{"direction":"favors_intervention","multiple_testing_adjusted":true}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000305','80000000-0000-0000-0000-000000000305',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults aged 55-95 years with insomnia"}'::jsonb,
 'post-treatment',
 'effect_of_assignment',
 'isi_response_rate',
 '{"intervention_n":38,"intervention_denominator":100,"control_n":5,"control_denominator":97,"response_definition":"ISI reduction >7 points"}'::jsonb,
 NULL,NULL,'proportion',true,'available_case',
 '{"direction":"favors_intervention","note":"severity also significantly improved; response used here as structured post-treatment update signal"}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000306','80000000-0000-0000-0000-000000000306',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults with chronic insomnia recruited from three university hospitals"}'::jsonb,
 'post-intervention',
 'effect_of_assignment',
 'mean_isi_by_group',
 '{"intervention_mean":9.0,"control_mean":12.8,"effect_size_range":"Cohen d -0.62 to -1.35 across post/follow-up"}'::jsonb,
 NULL,NULL,'ISI points',true,'intention_to_treat',
 '{"direction":"favors_intervention","missing_data_method":"LOCF"}'::jsonb,
 'active'
);

INSERT INTO evidence.result_source(
 result_version_uuid,report_version_uuid,source_location,source_type,
 original_text_or_value,is_primary_source,extractor
) VALUES
('81000000-0000-0000-0000-000000000301','81000000-0000-0000-0000-000000000201','Figure 4 / subgroup online education about sleep','figure','{"smd":-0.93,"ci95":[-1.07,-0.79],"i2":68,"k":10}'::jsonb,true,'OES'),
('81000000-0000-0000-0000-000000000302','81000000-0000-0000-0000-000000000202','Abstract results','abstract','{"smd":-0.82,"trials":15,"n":3507}'::jsonb,true,'OES'),
('81000000-0000-0000-0000-000000000303','81000000-0000-0000-0000-000000000203','Abstract results','abstract','{"diff_adj":7.32,"ci95":[5.0,9.6],"d":1.64}'::jsonb,true,'OES'),
('81000000-0000-0000-0000-000000000304','81000000-0000-0000-0000-000000000204','Table 2 / week 10 ISI','table','{"d":0.60,"adjusted_difference":-2.37,"ci99":[-3.81,-0.92]}'::jsonb,true,'OES'),
('81000000-0000-0000-0000-000000000305','81000000-0000-0000-0000-000000000205','Table 2 / post-treatment ISI responders','table','{"intervention":"38/100","control":"5/97"}'::jsonb,true,'OES'),
('81000000-0000-0000-0000-000000000306','81000000-0000-0000-0000-000000000206','Abstract results / post-intervention ISI','abstract','{"intervention_mean":9.0,"control_mean":12.8}'::jsonb,true,'OES');

-- ---------------------------------------------------------------------------
-- RISK ASSESSMENT
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000401','OES-RA-2026-000411','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000402','OES-RA-2026-000412','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000403','OES-RA-2026-000413','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000404','OES-RA-2026-000414','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000405','OES-RA-2026-000415','RiskAssessment','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000401','80000000-0000-0000-0000-000000000401',1,'current','real-case-01','initial','ROBIS Hwang'),
('81000000-0000-0000-0000-000000000402','80000000-0000-0000-0000-000000000402',1,'current','real-case-01','initial','RoB2 Sweetman'),
('81000000-0000-0000-0000-000000000403','80000000-0000-0000-0000-000000000403',1,'current','real-case-01','initial','RoB2 SleepioRx'),
('81000000-0000-0000-0000-000000000404','80000000-0000-0000-0000-000000000404',1,'current','real-case-01','initial','RoB2 OASIS'),
('81000000-0000-0000-0000-000000000405','80000000-0000-0000-0000-000000000405',1,'current','real-case-01','initial','RoB2 Somzz');

INSERT INTO appraisal.risk_assessment(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000401'),
('80000000-0000-0000-0000-000000000402'),
('80000000-0000-0000-0000-000000000403'),
('80000000-0000-0000-0000-000000000404'),
('80000000-0000-0000-0000-000000000405');

INSERT INTO appraisal.risk_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,framework,framework_version,
 target_entity_uuid,outcome_entity_uuid,overall_judgement,assessor,assessment_date,
 verification_status,instrument_payload,status
) VALUES
(
 '81000000-0000-0000-0000-000000000401','80000000-0000-0000-0000-000000000401',
 '81000000-0000-0000-0000-000000000002','ROBIS','2016',
 '80000000-0000-0000-0000-000000000101','80000000-0000-0000-0000-000000000003',
 'unclear','OES AI-assisted draft',DATE '2026-10-04','ai_methodologically_verified',
 '{"key_issue":"declared search cutoff is inconsistent with a later-published study cited by the review"}'::jsonb,'draft'
),
(
 '81000000-0000-0000-0000-000000000402','80000000-0000-0000-0000-000000000402',
 '81000000-0000-0000-0000-000000000002','RoB 2','current',
 '80000000-0000-0000-0000-000000000103','80000000-0000-0000-0000-000000000003',
 'some_concerns','OES AI-assisted draft',DATE '2026-10-04','ai_methodologically_verified',
 '{"key_issues":["allocation concealment insufficiently described","missing outcome data","self-reported outcome in open-label trial"]}'::jsonb,'draft'
),
(
 '81000000-0000-0000-0000-000000000403','80000000-0000-0000-0000-000000000403',
 '81000000-0000-0000-0000-000000000002','RoB 2','current',
 '80000000-0000-0000-0000-000000000104','80000000-0000-0000-0000-000000000003',
 'some_concerns','OES AI-assisted draft',DATE '2026-10-04','ai_methodologically_verified',
 '{"key_issue":"slightly differential missing outcome data"}'::jsonb,'draft'
),
(
 '81000000-0000-0000-0000-000000000404','80000000-0000-0000-0000-000000000404',
 '81000000-0000-0000-0000-000000000002','RoB 2','current',
 '80000000-0000-0000-0000-000000000105','80000000-0000-0000-0000-000000000003',
 'some_concerns','OES AI-assisted draft',DATE '2026-10-04','ai_methodologically_verified',
 '{"key_issue":"allocation concealment description leaves residual uncertainty"}'::jsonb,'draft'
),
(
 '81000000-0000-0000-0000-000000000405','80000000-0000-0000-0000-000000000405',
 '81000000-0000-0000-0000-000000000002','RoB 2','current',
 '80000000-0000-0000-0000-000000000106','80000000-0000-0000-0000-000000000003',
 'some_concerns','OES AI-assisted draft',DATE '2026-10-04','ai_methodologically_verified',
 '{"key_issue":"LOCF used for missing outcome data"}'::jsonb,'draft'
);

INSERT INTO appraisal.risk_assessment_domain(
 risk_assessment_version_uuid,domain_code,judgement,rationale,sequence_no
) VALUES
('81000000-0000-0000-0000-000000000401','eligibility','low_concern','Eligibility criteria are explicit and relevant to the OES question.',1),
('81000000-0000-0000-0000-000000000401','identification_selection','unclear_concern','Four major databases including CENTRAL and dual screening were used. Trial registries, broader grey literature/citation chasing and language policy are not clearly documented in the main report. Shin/Somzz is cited but not listed among the 29 included studies, so the prior post-cutoff inclusion concern is withdrawn.',2),
('81000000-0000-0000-0000-000000000401','data_collection_appraisal','unclear_concern','Dual extraction and RoB 2 were used, but the impact of exclusions for unavailable data is insufficiently clear.',3),
('81000000-0000-0000-0000-000000000401','synthesis_findings','unclear_concern','Comparator-specific synthesis is useful but retains I2=68% and lacks formal certainty assessment.',4),

('81000000-0000-0000-0000-000000000402','randomization','some_concerns','Computer randomization described; allocation concealment not sufficiently demonstrated.',1),
('81000000-0000-0000-0000-000000000402','deviations','low_risk','Digital interventions standardized; ITT mixed-model analysis.',2),
('81000000-0000-0000-0000-000000000402','missing_outcome_data','some_concerns','Approximately 14.5% missing at 8 weeks without a strong MNAR sensitivity analysis.',3),
('81000000-0000-0000-0000-000000000402','outcome_measurement','some_concerns','Validated self-reported ISI in an open-label comparison.',4),
('81000000-0000-0000-0000-000000000402','reported_result_selection','low_risk','Primary ISI outcome and trial registration are identifiable.',5),

('81000000-0000-0000-0000-000000000403','randomization','low_risk','Central electronic randomization with blocked sequence and no team access to sequence.',1),
('81000000-0000-0000-0000-000000000403','deviations','low_risk','Both arms were digital sleep programs and the primary analysis followed ITT.',2),
('81000000-0000-0000-0000-000000000403','missing_outcome_data','some_concerns','Dropout was somewhat greater in the intervention arm; MAR models and sensitivity analyses reduce but do not eliminate concern.',3),
('81000000-0000-0000-0000-000000000403','outcome_measurement','low_risk','Validated ISI; participants were masked to study hypotheses and staff were blinded.',4),
('81000000-0000-0000-0000-000000000403','reported_result_selection','low_risk','Prospective registration and explicit primary endpoints.',5),

('81000000-0000-0000-0000-000000000404','randomization','some_concerns','Randomization was stratified, but the operational description of concealment leaves residual uncertainty.',1),
('81000000-0000-0000-0000-000000000404','deviations','low_risk','The focal arm was fully automated; technical support did not provide clinical guidance.',2),
('81000000-0000-0000-0000-000000000404','missing_outcome_data','low_risk','Post-treatment outcome availability was high in the focal comparison.',3),
('81000000-0000-0000-0000-000000000404','outcome_measurement','low_risk','Validated ISI with the same measurement process across groups.',4),
('81000000-0000-0000-0000-000000000404','reported_result_selection','low_risk','Trial registration and primary sleep outcome are explicit.',5),

('81000000-0000-0000-0000-000000000405','randomization','low_risk','Web response system and stratified block randomization.',1),
('81000000-0000-0000-0000-000000000405','deviations','low_risk','Single-blind digital comparison and ITT framework.',2),
('81000000-0000-0000-0000-000000000405','missing_outcome_data','some_concerns','LOCF was used for missing outcome data.',3),
('81000000-0000-0000-0000-000000000405','outcome_measurement','low_risk','Validated ISI with participant masking to allocation.',4),
('81000000-0000-0000-0000-000000000405','reported_result_selection','low_risk','Registered trial with explicit primary ISI endpoint.',5);

-- ---------------------------------------------------------------------------
-- SYNTHESES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000501','OES-SY-2026-000411','Synthesis','real-case-01'),
('80000000-0000-0000-0000-000000000502','OES-SY-2026-000412','Synthesis','real-case-01'),
('80000000-0000-0000-0000-000000000503','OES-SY-2026-000413','Synthesis','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000501','80000000-0000-0000-0000-000000000501',1,'current','real-case-01','initial','Adopted Hwang comparator-specific meta-analysis'),
('81000000-0000-0000-0000-000000000502','80000000-0000-0000-0000-000000000502',1,'current','real-case-01','initial','Gao corroborative meta-analysis'),
('81000000-0000-0000-0000-000000000503','80000000-0000-0000-0000-000000000503',1,'current','real-case-01','initial','OES narrative update through 2026-10-04');

INSERT INTO synthesis.synthesis(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000501'),
('80000000-0000-0000-0000-000000000502'),
('80000000-0000-0000-0000-000000000503');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 population_descriptor,comparison_payload,timepoint_payload,estimand,
 synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES
(
 '81000000-0000-0000-0000-000000000501','80000000-0000-0000-0000-000000000501',
 '81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000003',
 '{"population":"adults represented in Hwang online-education subgroup"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"online education about sleep"}'::jsonb,
 '{"label":"post-treatment"}'::jsonb,
 'effect_of_assignment',
 'meta_analysis','adopted_external',
 'Published random-effects comparator-specific meta-analysis from Hwang et al. 2025; adopted critically by OES without recalculation.',
 'published_random_effects',
 '{"summary_type":"adopted_quantitative_estimate","effect_measure":"SMD","effect_value":-0.93,"ci_lower":-1.07,"ci_upper":-0.79,"reported_study_count":10,"heterogeneity_i2":68,"effect_display":"SMD -0,93 (IC95% -1,07 a -0,79)","interpretation":"Efeito favorável à dCBT-I; magnitude grande na síntese publicada, com heterogeneidade relevante.","recalculated_by_oes":false,"analysis_note":"Meta-análise publicada adotada criticamente; não recalculada pelo OES."}'::jsonb,
 'active',NULL
),
(
 '81000000-0000-0000-0000-000000000502','80000000-0000-0000-0000-000000000502',
 '81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000003',
 '{"population":"general adult populations"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"multiple control types"}'::jsonb,
 '{"label":"post-treatment"}'::jsonb,
 'effect_of_assignment',
 'meta_analysis','corroborative_external',
 'Published meta-analysis from Gao et al. 2026 used as external triangulation; not recalculated by OES.',
 'published_random_effects',
 '{"summary_type":"corroborative_quantitative_estimate","effect_measure":"SMD","effect_value":-0.82,"reported_study_count":15,"effect_display":"SMD -0,82 (15 trials)","interpretation":"Corrobora direção favorável; o abstract recuperado não isola o comparador educação digital.","recalculated_by_oes":false,"analysis_note":"Síntese corroborativa externa; não substitui a estimativa comparador-específica de Hwang."}'::jsonb,
 'active',NULL
),
(
 '81000000-0000-0000-0000-000000000503','80000000-0000-0000-0000-000000000503',
 '81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia; update RCTs include general adults and older adults"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"digital sleep education or sleep hygiene education"}'::jsonb,
 '{"label":"approximately 6-12 weeks"}'::jsonb,
 'direction_and_magnitude_update',
 'narrative_update','oes_update',
 'Directed narrative update of the adopted synthesis using newly identified RCTs; no new statistical pooling.',
 NULL,
 '{"summary_type":"narrative_update","direction":"favors_intervention","newly_modelled_studies":4,"pooled_by_oes":false,"summary_text":"Os RCTs recentes mantêm direção favorável à dCBT-I, com magnitude variável; nenhum estudo diretamente aderente identificado reverteu a direção do efeito.","interpretation":"Maior confiança na direção do benefício do que na magnitude exata.","analysis_note":"Atualização narrativa OES; nenhum novo pooling foi calculado. Somzz é tratado como RCT pós-cutoff e evidência incremental narrativa; não aparece na Tabela 1 dos 29 estudos incluídos por Hwang."}'::jsonb,
 'active',TIMESTAMPTZ '2026-10-04 12:07:00-03'
);

INSERT INTO synthesis.contribution(
 synthesis_version_uuid,result_version_uuid,contribution_role,
 included_main_analysis,included_sensitivity,notes
) VALUES
('81000000-0000-0000-0000-000000000501','81000000-0000-0000-0000-000000000301','adopted_external_estimate',true,false,'Published quantitative anchor; not recalculated by OES.'),
('81000000-0000-0000-0000-000000000502','81000000-0000-0000-0000-000000000302','corroborative_external_estimate',true,false,'External corroborative synthesis.'),
('81000000-0000-0000-0000-000000000503','81000000-0000-0000-0000-000000000303','update_evidence',false,false,'New RCT used for directional/magnitude update only.'),
('81000000-0000-0000-0000-000000000503','81000000-0000-0000-0000-000000000304','update_evidence',false,false,'New RCT used for directional/magnitude update only.'),
('81000000-0000-0000-0000-000000000503','81000000-0000-0000-0000-000000000305','update_evidence',false,false,'Older-adult RCT used as direct but population-specific update evidence.'),
('81000000-0000-0000-0000-000000000503','81000000-0000-0000-0000-000000000306','update_evidence',false,false,'Post-cutoff RCT used as independent narrative update evidence; no OES repooling performed.');

-- ---------------------------------------------------------------------------
-- CERTAINTY
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('80000000-0000-0000-0000-000000000601','OES-CE-2026-000411','CertaintyAssessment','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '81000000-0000-0000-0000-000000000601',
 '80000000-0000-0000-0000-000000000601',
 1,'current','real-case-01','initial',
 'Provisional GRADE assessment pending human review'
);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000601');

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
 outcome_entity_uuid,framework,framework_version,initial_level,final_level,
 evidence_state,assessment_date,status
) VALUES (
 '81000000-0000-0000-0000-000000000601',
 '80000000-0000-0000-0000-000000000601',
 '81000000-0000-0000-0000-000000000002',
 '81000000-0000-0000-0000-000000000503',
 '80000000-0000-0000-0000-000000000003',
 'GRADE','OES intervention framework',
 'high','moderate','evidence_available',
 DATE '2026-10-04','under_review'
);

INSERT INTO appraisal.certainty_domain(
 certainty_assessment_version_uuid,domain_code,concern_level,
 downgrade_steps,upgrade_steps,rationale,reviewer,sequence_no
) VALUES
('81000000-0000-0000-0000-000000000601','risk_of_bias','serious',1,0,'The evidence base is not dominated by unequivocally low-risk studies; recent decisive RCTs were judged some concerns and the source review has ROBIS concerns.','OES AI-assisted draft',1),
('81000000-0000-0000-0000-000000000601','inconsistency','not_serious',0,0,'I2 is 68% for the focal published subgroup, but all directly adherent decisive sources favor dCBT-I; heterogeneity mainly affects magnitude rather than direction.','OES AI-assisted draft',2),
('81000000-0000-0000-0000-000000000601','indirectness','not_serious',0,0,'Population, intervention, comparator, outcome and post-treatment timepoint directly represent the OES question.','OES AI-assisted draft',3),
('81000000-0000-0000-0000-000000000601','imprecision','not_serious',0,0,'The published focal CI is entirely on the benefit side and accumulated information is substantial for the directional conclusion.','OES AI-assisted draft',4),
('81000000-0000-0000-0000-000000000601','publication_bias','undetected',0,0,'Publication bias was not demonstrated, although residual uncertainty remains and no formal ROB-ME was performed.','OES AI-assisted draft',5);

-- ---------------------------------------------------------------------------
-- PRODUCT
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('80000000-0000-0000-0000-000000000701','OES-P-2026-000401','Product','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '81000000-0000-0000-0000-000000000701',
 '80000000-0000-0000-0000-000000000701',
 1,'current','real-case-01','initial',
 'Real case 01 Evidence Sheet under human review'
);

INSERT INTO product.product(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000701');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,publication_date,status,conclusion_text,
 applicability_summary,limitations_summary
) VALUES (
 '81000000-0000-0000-0000-000000000701',
 '80000000-0000-0000-0000-000000000701',
 'evidence_sheet',
 'dCBT-I totalmente automatizada versus educação digital sobre sono para redução da gravidade da insônia em adultos',
 'technical_and_evidence_users',
 DATE '2026-10-04',
 NULL,
 'under_review',
 'A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos.',
 'A evidência é diretamente aplicável a adultos com insônia em contextos digitais. Para o Brasil, a transferência do efeito é plausível, mas disponibilidade, idioma, regulação, integração assistencial, acesso digital e implementação no SUS não foram formalmente avaliados.',
 'A síntese-base apresenta preocupação ROBIS; o subgrupo focal tem I2=68%; a magnitude varia entre estudos; não houve nova meta-análise OES; a busca é N2 e não reivindica exaustividade N4; segurança é menos sistematicamente caracterizada; não foi identificado RCT brasileiro diretamente aderente.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 '81000000-0000-0000-0000-000000000701',
 '81000000-0000-0000-0000-000000000002',
 'primary',1
);

INSERT INTO product.synthesis_link(
 product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES
('81000000-0000-0000-0000-000000000701','81000000-0000-0000-0000-000000000501','source',1),
('81000000-0000-0000-0000-000000000701','81000000-0000-0000-0000-000000000503','primary',2),
('81000000-0000-0000-0000-000000000701','81000000-0000-0000-0000-000000000502','corroborative',3);

INSERT INTO product.certainty_link(
 product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
 '81000000-0000-0000-0000-000000000701',
 '81000000-0000-0000-0000-000000000601',
 'primary',1
);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,
 assessed_at,assessed_by,rationale,record_status
) VALUES (
 '82400000-0000-0000-0000-000000000701',
 '81000000-0000-0000-0000-000000000701',
 'current',
 TIMESTAMPTZ '2026-10-04 12:07:00-03',
 'OES',
 'Search update completed through the evidence cutoff; scientific judgments remain under OES methodological verification.',
 'active'
);

-- Assurance history: first adversarial pass required revision; second pass passed.
INSERT INTO product.assurance_record(
    assurance_uuid, product_version_uuid, assurance_type,
    actor, actor_type, independent_flag, decision,
    performed_at, notes, evidence_payload, status
) VALUES
(
    '83000000-0000-0000-0000-000000000701',
    '81000000-0000-0000-0000-000000000701',
    'ai_methodological_verification',
    'OES_AI_METHOD_VERIFICATION_PASS_1',
    'ai_system',
    false,
    'revise',
    TIMESTAMPTZ '2026-10-04 15:00:00-03',
    'First adversarial verification identified an incorrect ROBIS premise regarding Somzz/Hwang inclusion.',
    '{"document":"63-caso-real-01-verificacao-metodologica-adversarial-01.md","material_issue":"Somzz cited but not included in Hwang Table 1","result":"revise"}'::jsonb,
    'superseded'
),
(
    '83000000-0000-0000-0000-000000000702',
    '81000000-0000-0000-0000-000000000701',
    'ai_methodological_verification',
    'OES_AI_METHOD_VERIFICATION_PASS_2',
    'ai_system',
    false,
    'passed',
    TIMESTAMPTZ '2026-10-04 15:30:00-03',
    'Second adversarial verification passed after correcting ROBIS and Somzz update status.',
    '{"document":"64-caso-real-01-verificacao-metodologica-adversarial-02.md","result":"passed","independent_review":false,"expert_review":false}'::jsonb,
    'active'
);

-- Deliberately no owner_governance_approval, no approved expert review,
-- no approved product.review_record, and no publication_date.
-- The publication gate must therefore block external publication.

-- ---------------------------------------------------------------------------
-- PROVENANCE AND DEPENDENCIES
-- ---------------------------------------------------------------------------

INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,transformation,actor,status
) VALUES
(
 '82500000-0000-0000-0000-000000000501',
 '81000000-0000-0000-0000-000000000501',
 'result_summary',
 '81000000-0000-0000-0000-000000000201',
 'Figure 4 / online education about sleep subgroup',
 '{"smd":-0.93,"ci95":[-1.07,-0.79],"i2":68,"k":10}'::jsonb,
 'adopt_external_synthesis',
 '{"recalculated_by_oes":false}'::jsonb,
 'OES','active'
),
(
 '82500000-0000-0000-0000-000000000502',
 '81000000-0000-0000-0000-000000000502',
 'result_summary',
 '81000000-0000-0000-0000-000000000202',
 'Abstract',
 '{"smd":-0.82,"trials":15}'::jsonb,
 'external_triangulation',
 '{"recalculated_by_oes":false}'::jsonb,
 'OES','active'
),
(
 '82500000-0000-0000-0000-000000000503',
 '81000000-0000-0000-0000-000000000503',
 'result_summary.update_evidence.sweetman',
 '81000000-0000-0000-0000-000000000203',
 'Abstract',
 '{"diff_adj":7.32,"ci95":[5.0,9.6],"d":1.64}'::jsonb,
 'narrative_update',
 '{"pooled_by_oes":false}'::jsonb,
 'OES','active'
),
(
 '82500000-0000-0000-0000-000000000504',
 '81000000-0000-0000-0000-000000000503',
 'result_summary.update_evidence.sleepiorx',
 '81000000-0000-0000-0000-000000000204',
 'Table 2',
 '{"d":0.60,"adjusted_difference":-2.37,"ci99":[-3.81,-0.92]}'::jsonb,
 'narrative_update',
 '{"pooled_by_oes":false}'::jsonb,
 'OES','active'
),
(
 '82500000-0000-0000-0000-000000000505',
 '81000000-0000-0000-0000-000000000503',
 'result_summary.update_evidence.oasis',
 '81000000-0000-0000-0000-000000000205',
 'Table 2',
 '{"response_intervention":"38/100","response_control":"5/97"}'::jsonb,
 'narrative_update',
 '{"pooled_by_oes":false}'::jsonb,
 'OES','active'
),
(
 '82500000-0000-0000-0000-000000000506',
 '81000000-0000-0000-0000-000000000503',
 'result_summary.update_evidence.somzz',
 '81000000-0000-0000-0000-000000000206',
 'Abstract',
 '{"isi_intervention":9.0,"isi_control":12.8}'::jsonb,
 'narrative_update',
 '{"pooled_by_oes":false,"included_in_hwang_table1":false,"update_status":"post_cutoff_incremental"}'::jsonb,
 'OES','active'
);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('81000000-0000-0000-0000-000000000201','81000000-0000-0000-0000-000000000301','report_supports_result','evidence.result_source'),
('81000000-0000-0000-0000-000000000202','81000000-0000-0000-0000-000000000302','report_supports_result','evidence.result_source'),
('81000000-0000-0000-0000-000000000203','81000000-0000-0000-0000-000000000303','report_supports_result','evidence.result_source'),
('81000000-0000-0000-0000-000000000204','81000000-0000-0000-0000-000000000304','report_supports_result','evidence.result_source'),
('81000000-0000-0000-0000-000000000205','81000000-0000-0000-0000-000000000305','report_supports_result','evidence.result_source'),
('81000000-0000-0000-0000-000000000206','81000000-0000-0000-0000-000000000306','report_supports_result','evidence.result_source'),

('81000000-0000-0000-0000-000000000301','81000000-0000-0000-0000-000000000501','result_informs_adopted_synthesis','synthesis.contribution'),
('81000000-0000-0000-0000-000000000302','81000000-0000-0000-0000-000000000502','result_informs_corroborative_synthesis','synthesis.contribution'),
('81000000-0000-0000-0000-000000000303','81000000-0000-0000-0000-000000000503','result_informs_update','synthesis.contribution'),
('81000000-0000-0000-0000-000000000304','81000000-0000-0000-0000-000000000503','result_informs_update','synthesis.contribution'),
('81000000-0000-0000-0000-000000000305','81000000-0000-0000-0000-000000000503','result_informs_update','synthesis.contribution'),
('81000000-0000-0000-0000-000000000306','81000000-0000-0000-0000-000000000503','result_informs_update','synthesis.contribution'),

('81000000-0000-0000-0000-000000000501','81000000-0000-0000-0000-000000000503','adopted_synthesis_informs_update','methodological_integration'),
('81000000-0000-0000-0000-000000000502','81000000-0000-0000-0000-000000000503','corroborative_synthesis_informs_update','triangulation'),

('81000000-0000-0000-0000-000000000401','81000000-0000-0000-0000-000000000601','risk_assessment_informs_certainty','GRADE'),
('81000000-0000-0000-0000-000000000402','81000000-0000-0000-0000-000000000601','risk_assessment_informs_certainty','GRADE'),
('81000000-0000-0000-0000-000000000403','81000000-0000-0000-0000-000000000601','risk_assessment_informs_certainty','GRADE'),
('81000000-0000-0000-0000-000000000404','81000000-0000-0000-0000-000000000601','risk_assessment_informs_certainty','GRADE'),
('81000000-0000-0000-0000-000000000405','81000000-0000-0000-0000-000000000601','risk_assessment_informs_certainty','GRADE'),
('81000000-0000-0000-0000-000000000503','81000000-0000-0000-0000-000000000601','updated_synthesis_informs_certainty','GRADE'),

('81000000-0000-0000-0000-000000000501','81000000-0000-0000-0000-000000000701','source_synthesis_informs_product','product.synthesis_link'),
('81000000-0000-0000-0000-000000000502','81000000-0000-0000-0000-000000000701','corroborative_synthesis_informs_product','product.synthesis_link'),
('81000000-0000-0000-0000-000000000503','81000000-0000-0000-0000-000000000701','primary_synthesis_informs_product','product.synthesis_link'),
('81000000-0000-0000-0000-000000000601','81000000-0000-0000-0000-000000000701','certainty_informs_product','product.certainty_link');

COMMIT;
