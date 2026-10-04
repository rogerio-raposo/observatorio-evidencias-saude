-- OES Real Case 01 — dCBT-I Evidence Sheet dataset
-- Status: under_review; scientific preview only.
-- Requires baseline + migrations 002–009.
-- Date/cutoff: 2026-10-04
--
-- Scientific intent:
-- - adopted external quantitative synthesis (Hwang 2025)
-- - separate OES narrative update with newer RCTs
-- - no new OES pooling
-- - provisional GRADE = moderate
-- - NO approved human review; publication gate must remain blocked

BEGIN;

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION / OUTCOME
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000001','OES-Q-2026-000101','Question','real-case-01'),
('80000000-0000-0000-0000-000000000002','OES-I-2026-000101','Investigation','real-case-01'),
('80000000-0000-0000-0000-000000000003','OES-O-2026-000101','Outcome','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001',1,'current','real-case-01','initial','Real Case 01 question'),
('81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000002',1,'current','real-case-01','initial','Real Case 01 N2 investigation'),
('81000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000003',1,'current','real-case-01','initial','Post-treatment insomnia severity outcome');

INSERT INTO investigation.question(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,question_type,structure_type,
 context_payload,time_horizon_payload
) VALUES (
 '81000000-0000-0000-0000-000000000001',
 '80000000-0000-0000-0000-000000000001',
 'Em adultos com insônia, a terapia cognitivo-comportamental digital para insônia totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia ao final do tratamento?',
 'Em adultos com insônia, dCBT-I totalmente automatizada versus educação digital sobre sono/higiene do sono reduz a gravidade da insônia no pós-tratamento?',
 'INT',
 'PICO',
 '{
   "population":"adultos com insônia clinicamente significativa",
   "intervention":"dCBT-I multicomponente totalmente automatizada/autoguiada",
   "comparator":"educação digital sobre sono/higiene do sono",
   "outcome":"gravidade da insônia"
 }'::jsonb,
 '{"primary_window":"aproximadamente 6–12 semanas após baseline"}'::jsonb
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
 'evidence_sheet_validation',
 'N2','M1',
 'Validar ponta a ponta a Ficha de Evidência com uma pergunta real sobre dCBT-I totalmente automatizada.',
 DATE '2026-10-04', DATE '2026-10-04','active'
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
 version_uuid,entity_uuid,preferred_name,definition,domain,direction_of_benefit,unit_family,status
) VALUES (
 '81000000-0000-0000-0000-000000000003',
 '80000000-0000-0000-0000-000000000003',
 'Gravidade da insônia no pós-tratamento',
 'Gravidade de sintomas de insônia ao final da intervenção, priorizando ISI quando disponível.',
 'sleep_insomnia','lower','scale_score','active'
);

-- ---------------------------------------------------------------------------
-- SEARCH RECORDS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,source_name,platform,
 exact_strategy,filters_payload,executed_at,result_count,strategy_version,operator,status
) VALUES
(
 '82000000-0000-0000-0000-000000000001','OES-S-2026-000101',
 '81000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 $q$(
   insomnia[Title/Abstract]
 )
 AND
 (
   "digital cognitive behavioral therapy"[Title/Abstract]
   OR "digital cognitive behavioural therapy"[Title/Abstract]
   OR "internet cognitive behavioral therapy"[Title/Abstract]
   OR "internet cognitive behavioural therapy"[Title/Abstract]
   OR dCBT-I[Title/Abstract]
   OR "fully automated"[Title/Abstract]
 )
 AND
 (
   systematic review[Publication Type]
   OR meta-analysis[Publication Type]
   OR systematic review[Title/Abstract]
   OR meta-analysis[Title/Abstract]
 )$q$,
 '{"purpose":"systematic reviews/meta-analyses","comparator_applied_at_eligibility":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 11:00:00-03',
 NULL,'v1','OES assisted search','completed'
),
(
 '82000000-0000-0000-0000-000000000002','OES-S-2026-000102',
 '81000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 $q$(
   insomnia[Title/Abstract]
 )
 AND
 (
   "digital cognitive behavioral therapy"[Title/Abstract]
   OR "digital cognitive behavioural therapy"[Title/Abstract]
   OR "internet cognitive behavioral therapy"[Title/Abstract]
   OR "internet cognitive behavioural therapy"[Title/Abstract]
   OR dCBT-I[Title/Abstract]
   OR "fully automated"[Title/Abstract]
 )
 AND
 (
   randomized controlled trial[Publication Type]
   OR randomized[Title/Abstract]
   OR randomised[Title/Abstract]
 )$q$,
 '{"purpose":"RCT update","comparator_applied_at_eligibility":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 11:05:00-03',
 NULL,'v1','OES assisted search','completed'
),
(
 '82000000-0000-0000-0000-000000000003','OES-S-2026-000103',
 '81000000-0000-0000-0000-000000000002',
 'BVS/LILACS','BVS',
 'insônia AND terapia cognitivo-comportamental digital OR CBT-I digital',
 '{"purpose":"regional/Brazilian evidence"}'::jsonb,
 TIMESTAMPTZ '2026-10-04 11:10:00-03',
 NULL,'v1','OES assisted search','completed'
),
(
 '82000000-0000-0000-0000-000000000004','OES-S-2026-000104',
 '81000000-0000-0000-0000-000000000002',
 'ClinicalTrials.gov','ClinicalTrials.gov',
 'insomnia AND digital cognitive behavioral therapy',
 '{"purpose":"trial identity/status and unpublished-result check"}'::jsonb,
 TIMESTAMPTZ '2026-10-04 11:15:00-03',
 NULL,'v1','OES assisted search','completed'
);

-- ---------------------------------------------------------------------------
-- STUDIES / REPORTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000010','OES-ST-2026-000110','Study','real-case-01'),
('80000000-0000-0000-0000-000000000011','OES-ST-2026-000111','Study','real-case-01'),
('80000000-0000-0000-0000-000000000012','OES-ST-2026-000112','Study','real-case-01'),
('80000000-0000-0000-0000-000000000013','OES-ST-2026-000113','Study','real-case-01'),
('80000000-0000-0000-0000-000000000014','OES-ST-2026-000114','Study','real-case-01'),
('80000000-0000-0000-0000-000000000020','OES-RP-2026-000110','Report','real-case-01'),
('80000000-0000-0000-0000-000000000021','OES-RP-2026-000111','Report','real-case-01'),
('80000000-0000-0000-0000-000000000022','OES-RP-2026-000112','Report','real-case-01'),
('80000000-0000-0000-0000-000000000023','OES-RP-2026-000113','Report','real-case-01'),
('80000000-0000-0000-0000-000000000024','OES-RP-2026-000114','Report','real-case-01'),
('80000000-0000-0000-0000-000000000025','OES-RP-2026-000115','Report','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000010',1,'current','real-case-01','initial','Hwang 2025 systematic review'),
('81000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000011',1,'current','real-case-01','initial','Sweetman 2024 RCT'),
('81000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000012',1,'current','real-case-01','initial','SleepioRx 2025 RCT'),
('81000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000013',1,'current','real-case-01','initial','SHUTi OASIS 2025 RCT'),
('81000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000014',1,'current','real-case-01','initial','Somzz 2024 RCT'),
('81000000-0000-0000-0000-000000000020','80000000-0000-0000-0000-000000000020',1,'current','real-case-01','initial','Hwang report'),
('81000000-0000-0000-0000-000000000021','80000000-0000-0000-0000-000000000021',1,'current','real-case-01','initial','Sweetman report'),
('81000000-0000-0000-0000-000000000022','80000000-0000-0000-0000-000000000022',1,'current','real-case-01','initial','SleepioRx report'),
('81000000-0000-0000-0000-000000000023','80000000-0000-0000-0000-000000000023',1,'current','real-case-01','initial','OASIS report'),
('81000000-0000-0000-0000-000000000024','80000000-0000-0000-0000-000000000024',1,'current','real-case-01','initial','Somzz report'),
('81000000-0000-0000-0000-000000000025','80000000-0000-0000-0000-000000000025',1,'current','real-case-01','initial','Gao 2026 corroborative systematic review report');

INSERT INTO evidence.study(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000010'),
('80000000-0000-0000-0000-000000000011'),
('80000000-0000-0000-0000-000000000012'),
('80000000-0000-0000-0000-000000000013'),
('80000000-0000-0000-0000-000000000014');

INSERT INTO evidence.study_version(
 version_uuid,entity_uuid,study_type,design,title_or_label,recruitment_context,sample_size,status
) VALUES
('81000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000010','systematic_review','systematic_review_meta_analysis','Hwang et al. 2025','{"scope":"fully automated dCBT-I"}'::jsonb,9475,'active'),
('81000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000011','primary_study','randomized_trial','Sweetman et al. 2024','{"country":"Australia","setting":"community"}'::jsonb,62,'active'),
('81000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000012','primary_study','randomized_trial','SleepioRx / CrEDIT 2025','{"country":"USA","setting":"nationwide decentralized"}'::jsonb,336,'active'),
('81000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000013','primary_study','randomized_trial','SHUTi OASIS 2025','{"population":"adults aged 55–95 years"}'::jsonb,311,'active'),
('81000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000014','primary_study','randomized_trial','Somzz 2024','{"country":"South Korea","setting":"multicenter"}'::jsonb,98,'active');

INSERT INTO evidence.report(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000020'),
('80000000-0000-0000-0000-000000000021'),
('80000000-0000-0000-0000-000000000022'),
('80000000-0000-0000-0000-000000000023'),
('80000000-0000-0000-0000-000000000024'),
('80000000-0000-0000-0000-000000000025');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,language,
 publication_status,full_text_status,bibliographic_payload,status
) VALUES
('81000000-0000-0000-0000-000000000020','80000000-0000-0000-0000-000000000020','systematic_review','Systematic review and meta-analysis on fully automated digital cognitive behavioral therapy for insomnia',DATE '2025-03-12','npj Digital Medicine','en','published','full_text_available','{"pmid":"40075149","pmcid":"PMC11903857","doi":"10.1038/s41746-025-01514-4","prospero":"CRD42024526617"}'::jsonb,'active'),
('81000000-0000-0000-0000-000000000021','80000000-0000-0000-0000-000000000021','journal_article','Digital cognitive behavioural therapy for insomnia versus digital sleep education control in an Australian community-based sample',NULL,'Internal Medicine Journal','en','published','abstract_or_full_text_available','{"pmid":"39257295","doi":"10.1111/imj.16521","trial_registry":"ACTRN12621001395820"}'::jsonb,'active'),
('81000000-0000-0000-0000-000000000022','80000000-0000-0000-0000-000000000022','journal_article','The Effectiveness of Digital Cognitive Behavioral Therapy to Treat Insomnia Disorder in US Adults',NULL,'JMIR Mental Health','en','published','full_text_available','{"pmid":"41343796","trial_registry":"NCT05541055"}'::jsonb,'active'),
('81000000-0000-0000-0000-000000000023','80000000-0000-0000-0000-000000000023','journal_article','A randomized controlled trial of a digital cognitive behavioral therapy for insomnia for older adults',NULL,'npj Digital Medicine','en','published','full_text_available','{"pmid":"40681664","pmcid":"PMC12274496","doi":"10.1038/s41746-025-01847-0","trial_registry":"NCT03213132"}'::jsonb,'active'),
('81000000-0000-0000-0000-000000000024','80000000-0000-0000-0000-000000000024','journal_article','Efficacy of Mobile App-Based Cognitive Behavioral Therapy for Insomnia',DATE '2024-07-26','Journal of Medical Internet Research','en','published','full_text_available','{"pmid":"39058549","pmcid":"PMC11316165","doi":"10.2196/50555","trial_registry":"KCT0007292"}'::jsonb,'active'),
('81000000-0000-0000-0000-000000000025','80000000-0000-0000-0000-000000000025','systematic_review','Efficacy of fully automated digital cognitive behavioral therapy for insomnia in adults',NULL,'Sleep and Breathing','en','published','abstract_available','{"pmid":"42240717","doi":"10.1007/s11325-026-03723-x"}'::jsonb,'active');

INSERT INTO evidence.study_report_link(
 link_uuid,study_entity_uuid,report_entity_uuid,relation_type,confidence,evidence_note,reviewer,decision_date,status
) VALUES
('83000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000020','primary_report','confirmed','Systematic review primary publication','OES',DATE '2026-10-04','active'),
('83000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000021','primary_report','confirmed','RCT primary publication','OES',DATE '2026-10-04','active'),
('83000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000022','primary_report','confirmed','RCT primary publication','OES',DATE '2026-10-04','active'),
('83000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000023','primary_report','confirmed','RCT primary publication','OES',DATE '2026-10-04','active'),
('83000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000024','primary_report','confirmed','RCT primary publication','OES',DATE '2026-10-04','active');

-- Search hits and screening for the principal captured evidence units.
INSERT INTO investigation.search_hit(
 search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,source_record_id,
 raw_title,raw_year,raw_identifier,source_rank,resolution_status
) VALUES
('82100000-0000-0000-0000-000000000001','OES-SH-2026-000101','82000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000020','40075149','Hwang systematic review',2025,'PMID:40075149',1,'resolved'),
('82100000-0000-0000-0000-000000000002','OES-SH-2026-000102','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000021','39257295','Sweetman RCT',2024,'PMID:39257295',1,'resolved'),
('82100000-0000-0000-0000-000000000003','OES-SH-2026-000103','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000022','41343796','SleepioRx RCT',2025,'PMID:41343796',2,'resolved'),
('82100000-0000-0000-0000-000000000004','OES-SH-2026-000104','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000023','40681664','SHUTi OASIS RCT',2025,'PMID:40681664',3,'resolved'),
('82100000-0000-0000-0000-000000000005','OES-SH-2026-000105','82000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000024','39058549','Somzz RCT',2024,'PMID:39058549',4,'resolved'),
('82100000-0000-0000-0000-000000000006','OES-SH-2026-000106','82000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000025','42240717','Gao systematic review',2026,'PMID:42240717',2,'resolved');

INSERT INTO investigation.screening_decision(
 screening_uuid,oes_screening_id,investigation_version_uuid,target_entity_uuid,
 stage,reviewer,decision,exclusion_reason,decided_at
) VALUES
('82200000-0000-0000-0000-000000000001','OES-SCR-2026-000101','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000020','full_text','OES','include',NULL,TIMESTAMPTZ '2026-10-04 11:30:00-03'),
('82200000-0000-0000-0000-000000000002','OES-SCR-2026-000102','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000021','full_text','OES','include',NULL,TIMESTAMPTZ '2026-10-04 11:31:00-03'),
('82200000-0000-0000-0000-000000000003','OES-SCR-2026-000103','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000022','full_text','OES','include',NULL,TIMESTAMPTZ '2026-10-04 11:32:00-03'),
('82200000-0000-0000-0000-000000000004','OES-SCR-2026-000104','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000023','full_text','OES','include',NULL,TIMESTAMPTZ '2026-10-04 11:33:00-03'),
('82200000-0000-0000-0000-000000000005','OES-SCR-2026-000105','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000024','full_text','OES','include_overlap_caution',NULL,TIMESTAMPTZ '2026-10-04 11:34:00-03'),
('82200000-0000-0000-0000-000000000006','OES-SCR-2026-000106','81000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000025','full_text','OES','include_contextual',NULL,TIMESTAMPTZ '2026-10-04 11:35:00-03');

-- ---------------------------------------------------------------------------
-- RESULTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000030','OES-RS-2026-000110','Result','real-case-01'),
('80000000-0000-0000-0000-000000000031','OES-RS-2026-000111','Result','real-case-01'),
('80000000-0000-0000-0000-000000000032','OES-RS-2026-000112','Result','real-case-01'),
('80000000-0000-0000-0000-000000000033','OES-RS-2026-000113','Result','real-case-01'),
('80000000-0000-0000-0000-000000000034','OES-RS-2026-000114','Result','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000030','80000000-0000-0000-0000-000000000030',1,'current','real-case-01','initial','Hwang comparator-specific published estimate'),
('81000000-0000-0000-0000-000000000031','80000000-0000-0000-0000-000000000031',1,'current','real-case-01','initial','Sweetman post-treatment effect'),
('81000000-0000-0000-0000-000000000032','80000000-0000-0000-0000-000000000032',1,'current','real-case-01','initial','SleepioRx post-treatment effect'),
('81000000-0000-0000-0000-000000000033','80000000-0000-0000-0000-000000000033',1,'current','real-case-01','initial','OASIS post-treatment directional effect'),
('81000000-0000-0000-0000-000000000034','80000000-0000-0000-0000-000000000034',1,'current','real-case-01','initial','Somzz post-treatment effect');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid) VALUES
('80000000-0000-0000-0000-000000000030','80000000-0000-0000-0000-000000000010'),
('80000000-0000-0000-0000-000000000031','80000000-0000-0000-0000-000000000011'),
('80000000-0000-0000-0000-000000000032','80000000-0000-0000-0000-000000000012'),
('80000000-0000-0000-0000-000000000033','80000000-0000-0000-0000-000000000013'),
('80000000-0000-0000-0000-000000000034','80000000-0000-0000-0000-000000000014');

INSERT INTO evidence.result_version(
 version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,
 timepoint_value,timepoint_unit,timepoint_label,estimand,measure,
 reported_value,derived_value,ci_lower,ci_upper,unit,adjusted_flag,
 analysis_population,missing_data_state,method_payload,status
) VALUES
(
 '81000000-0000-0000-0000-000000000030','80000000-0000-0000-0000-000000000030',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults","comparison":"fully automated dCBT-I vs online education about sleep"}'::jsonb,
 NULL,NULL,'post-treatment','treatment_effect','standardized_mean_difference',
 '{"value":-0.93}'::jsonb,NULL,-1.07,-0.79,'SD',false,
 'meta-analysis subgroup','not_applicable',
 '{"published_meta_analysis":true,"reported_study_count":10,"heterogeneity_i2":68,"recalculated_by_oes":false}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000031','80000000-0000-0000-0000-000000000031',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"Australian community adults"}'::jsonb,
 8,'week','8 weeks','treatment_effect','mean_difference_isi',
 '{"value":-7.32,"orientation":"intervention_minus_control"}'::jsonb,NULL,-9.6,-5.0,'ISI points',true,
 'intention_to_treat','mixed_model_assumption',
 '{"cohen_d":1.64,"direction":"favors_intervention"}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000032','80000000-0000-0000-0000-000000000032',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"US adults with DSM-5 insomnia disorder"}'::jsonb,
 10,'week','10 weeks','treatment_effect','cohen_d',
 '{"value":0.60,"direction":"favors_intervention"}'::jsonb,NULL,NULL,NULL,'standardized',true,
 'intention_to_treat','mixed_model_missing_at_random',
 '{"followup_d_16w":0.65,"followup_d_24w":0.77}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000033','80000000-0000-0000-0000-000000000033',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults aged 55–95 years"}'::jsonb,
 NULL,NULL,'post-treatment','treatment_effect','directional_response_remission',
 '{"response_intervention":0.38,"response_control":0.05,"remission_intervention":0.30,"remission_control":0.02,"direction":"favors_intervention"}'::jsonb,
 NULL,NULL,NULL,NULL,false,
 'randomized_groups','low_post_treatment_missingness',
 '{"no_pooled_effect_extracted":true}'::jsonb,
 'active'
),
(
 '81000000-0000-0000-0000-000000000034','80000000-0000-0000-0000-000000000034',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"multicenter adults"}'::jsonb,
 NULL,NULL,'post-treatment','treatment_effect','mean_difference_isi',
 '{"intervention_mean":9.0,"control_mean":12.8}'::jsonb,
 '{"value":-3.8,"orientation":"intervention_minus_control"}'::jsonb,
 NULL,NULL,'ISI points',false,
 'intention_to_treat','LOCF',
 '{"response_intervention":0.57,"response_control":0.22,"remission_intervention":0.45,"remission_control":0.12,"possible_overlap_with_hwang":true}'::jsonb,
 'active'
);

INSERT INTO evidence.result_source(
 result_version_uuid,report_version_uuid,source_location,source_type,
 original_text_or_value,extraction_method,is_primary_source,extractor
) VALUES
('81000000-0000-0000-0000-000000000030','81000000-0000-0000-0000-000000000020','Comparator subgroup: online education about sleep','meta_analysis_result','{"SMD":-0.93,"CI95":[-1.07,-0.79],"k":10,"I2":68}'::jsonb,'manual_structured_extraction',true,'OES'),
('81000000-0000-0000-0000-000000000031','81000000-0000-0000-0000-000000000021','Primary 8-week ISI result','results','{"adjusted_difference":7.32,"CI95":[5.0,9.6],"cohen_d":1.64,"favors":"dCBT-I"}'::jsonb,'manual_structured_extraction',true,'OES'),
('81000000-0000-0000-0000-000000000032','81000000-0000-0000-0000-000000000022','Primary 10-week ISI result','results','{"cohen_d":0.60,"favors":"SleepioRx"}'::jsonb,'manual_structured_extraction',true,'OES'),
('81000000-0000-0000-0000-000000000033','81000000-0000-0000-0000-000000000023','Post-treatment response/remission','results','{"response":[0.38,0.05],"remission":[0.30,0.02]}'::jsonb,'manual_structured_extraction',true,'OES'),
('81000000-0000-0000-0000-000000000034','81000000-0000-0000-0000-000000000024','Post-treatment ISI','results','{"means":[9.0,12.8],"response":[0.57,0.22],"remission":[0.45,0.12]}'::jsonb,'manual_structured_extraction',true,'OES');

-- ---------------------------------------------------------------------------
-- RISK OF BIAS / ROBIS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000040','OES-RA-2026-000110','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000041','OES-RA-2026-000111','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000042','OES-RA-2026-000112','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000043','OES-RA-2026-000113','RiskAssessment','real-case-01'),
('80000000-0000-0000-0000-000000000044','OES-RA-2026-000114','RiskAssessment','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000040','80000000-0000-0000-0000-000000000040',1,'current','real-case-01','initial','ROBIS Hwang 2025'),
('81000000-0000-0000-0000-000000000041','80000000-0000-0000-0000-000000000041',1,'current','real-case-01','initial','RoB 2 Sweetman 2024'),
('81000000-0000-0000-0000-000000000042','80000000-0000-0000-0000-000000000042',1,'current','real-case-01','initial','RoB 2 SleepioRx 2025'),
('81000000-0000-0000-0000-000000000043','80000000-0000-0000-0000-000000000043',1,'current','real-case-01','initial','RoB 2 OASIS 2025'),
('81000000-0000-0000-0000-000000000044','80000000-0000-0000-0000-000000000044',1,'current','real-case-01','initial','RoB 2 Somzz 2024');

INSERT INTO appraisal.risk_assessment(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000040'),
('80000000-0000-0000-0000-000000000041'),
('80000000-0000-0000-0000-000000000042'),
('80000000-0000-0000-0000-000000000043'),
('80000000-0000-0000-0000-000000000044');

INSERT INTO appraisal.risk_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,framework,framework_version,
 target_entity_uuid,outcome_entity_uuid,overall_judgement,assessor,assessment_date,
 verification_status,instrument_payload,status
) VALUES
('81000000-0000-0000-0000-000000000040','80000000-0000-0000-0000-000000000040','81000000-0000-0000-0000-000000000002','ROBIS','current OES protocol','80000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000003','unclear_risk','OES AI-assisted appraisal',DATE '2026-10-04','pending_human_review','{"reason":"cutoff/publication chronology discrepancy and residual synthesis concerns"}'::jsonb,'draft'),
('81000000-0000-0000-0000-000000000041','80000000-0000-0000-0000-000000000041','81000000-0000-0000-0000-000000000002','RoB 2','current','80000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted appraisal',DATE '2026-10-04','pending_human_review','{"main_concerns":["allocation concealment clarity","missing data","self-reported outcome in open-label context"]}'::jsonb,'draft'),
('81000000-0000-0000-0000-000000000042','80000000-0000-0000-0000-000000000042','81000000-0000-0000-0000-000000000002','RoB 2','current','80000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted appraisal',DATE '2026-10-04','pending_human_review','{"main_concern":"missing data slightly differential"}'::jsonb,'draft'),
('81000000-0000-0000-0000-000000000043','80000000-0000-0000-0000-000000000043','81000000-0000-0000-0000-000000000002','RoB 2','current','80000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted appraisal',DATE '2026-10-04','pending_human_review','{"main_concern":"allocation concealment description"}'::jsonb,'draft'),
('81000000-0000-0000-0000-000000000044','80000000-0000-0000-0000-000000000044','81000000-0000-0000-0000-000000000002','RoB 2','current','80000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted appraisal',DATE '2026-10-04','pending_human_review','{"main_concern":"LOCF for missing outcomes"}'::jsonb,'draft');

INSERT INTO appraisal.risk_assessment_domain(
 risk_assessment_version_uuid,domain_code,judgement,rationale,sequence_no
) VALUES
('81000000-0000-0000-0000-000000000040','eligibility_criteria','low_concern','Eligibility criteria are explicit and aligned with fully automated dCBT-I RCTs.',1),
('81000000-0000-0000-0000-000000000040','identification_selection','high_concern','Declared cutoff predates a later publication cited/included without a documented explanation.',2),
('81000000-0000-0000-0000-000000000040','data_collection_appraisal','unclear_concern','Double extraction and RoB 2 are strengths, but the impact of exclusions for unavailable data is incompletely characterized.',3),
('81000000-0000-0000-0000-000000000040','synthesis_findings','unclear_concern','Comparator-specific synthesis is useful but heterogeneity remains and no GRADE assessment was identified.',4),

('81000000-0000-0000-0000-000000000041','randomization','some_concerns','Random sequence described; concealment not sufficiently demonstrated in retrieved report.',1),
('81000000-0000-0000-0000-000000000041','deviations','low_risk','Digital active comparator and ITT analysis; no material differential deviations identified.',2),
('81000000-0000-0000-0000-000000000041','missing_outcome_data','some_concerns','Approximately 14.5% missing at 8 weeks and limited MNAR sensitivity evidence.',3),
('81000000-0000-0000-0000-000000000041','measurement','some_concerns','ISI is validated but self-reported in an open-label context.',4),
('81000000-0000-0000-0000-000000000041','selection_reported_result','low_risk','Prospective registration and prespecified primary outcome identified.',5),

('81000000-0000-0000-0000-000000000042','randomization','low_risk','Central electronic blocked randomization with sequence inaccessible to study staff.',1),
('81000000-0000-0000-0000-000000000042','deviations','low_risk','Teams masked and both arms framed as sleep programs; ITT analysis used.',2),
('81000000-0000-0000-0000-000000000042','missing_outcome_data','some_concerns','Slightly differential dropout; primary mixed model assumes MAR.',3),
('81000000-0000-0000-0000-000000000042','measurement','low_risk','Validated ISI and masking of hypotheses reduce differential measurement concern.',4),
('81000000-0000-0000-0000-000000000042','selection_reported_result','low_risk','Prospective registration and explicit primary endpoints.',5),

('81000000-0000-0000-0000-000000000043','randomization','some_concerns','Randomized process described but practical concealment remains incompletely clear.',1),
('81000000-0000-0000-0000-000000000043','deviations','low_risk','Automated intervention; no clinical guidance in focal arm.',2),
('81000000-0000-0000-0000-000000000043','missing_outcome_data','low_risk','Post-treatment missingness was low for the focal timepoint.',3),
('81000000-0000-0000-0000-000000000043','measurement','low_risk','Validated ISI with reported participant masking.',4),
('81000000-0000-0000-0000-000000000043','selection_reported_result','low_risk','Trial registration and primary insomnia outcome identified.',5),

('81000000-0000-0000-0000-000000000044','randomization','low_risk','Interactive web response system with stratified block randomization.',1),
('81000000-0000-0000-0000-000000000044','deviations','low_risk','Digital intervention and control with ITT analysis.',2),
('81000000-0000-0000-0000-000000000044','missing_outcome_data','some_concerns','LOCF used for missing data.',3),
('81000000-0000-0000-0000-000000000044','measurement','low_risk','Validated ISI; participants were masked to allocation.',4),
('81000000-0000-0000-0000-000000000044','selection_reported_result','low_risk','Trial registration and prespecified ISI primary outcome identified.',5);

-- ---------------------------------------------------------------------------
-- SYNTHESIS: EXTERNAL ADOPTED + OES UPDATE
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('80000000-0000-0000-0000-000000000050','OES-SY-2026-000110','Synthesis','real-case-01'),
('80000000-0000-0000-0000-000000000051','OES-SY-2026-000111','Synthesis','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('81000000-0000-0000-0000-000000000050','80000000-0000-0000-0000-000000000050',1,'current','real-case-01','initial','Adopted external Hwang meta-analysis'),
('81000000-0000-0000-0000-000000000051','80000000-0000-0000-0000-000000000051',1,'current','real-case-01','initial','OES directed narrative update; no repooling');

INSERT INTO synthesis.synthesis(entity_uuid) VALUES
('80000000-0000-0000-0000-000000000050'),
('80000000-0000-0000-0000-000000000051');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 population_descriptor,comparison_payload,timepoint_payload,estimand,
 synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES
(
 '81000000-0000-0000-0000-000000000050',
 '80000000-0000-0000-0000-000000000050',
 '81000000-0000-0000-0000-000000000002',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"online education about sleep"}'::jsonb,
 '{"timepoint":"post-treatment"}'::jsonb,
 'treatment_effect',
 'meta_analysis','adopted_external',
 'critical adoption of published comparator-specific meta-analysis',
 'published_random_effects',
 '{
   "summary_type":"adopted_quantitative_estimate",
   "effect_measure":"SMD",
   "effect_value":-0.93,
   "ci_lower":-1.07,
   "ci_upper":-0.79,
   "reported_study_count":10,
   "heterogeneity_i2":68,
   "effect_display":"SMD -0,93 (IC95% -1,07 a -0,79)",
   "interpretation":"Efeito favorável à dCBT-I; magnitude grande na síntese publicada.",
   "recalculated_by_oes":false
 }'::jsonb,
 'active',TIMESTAMPTZ '2026-10-04 11:50:00-03'
),
(
 '81000000-0000-0000-0000-000000000051',
 '80000000-0000-0000-0000-000000000051',
 '81000000-0000-0000-0000-000000000002',
 '80000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia; update includes older-adult subgroup evidence"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"digital sleep education / sleep hygiene education"}'::jsonb,
 '{"timepoint":"approximately 6–12 weeks / post-treatment"}'::jsonb,
 'direction_and_magnitude_of_effect',
 'narrative_update','oes_update',
 'critical adoption of comparator-specific meta-analysis plus directed qualitative update with newer RCTs; no repooling',
 'no_new_pooling',
 '{
   "summary_type":"narrative_update",
   "direction":"favors_intervention",
   "effect_display":"SMD -0,93 (IC95% -1,07 a -0,79) — estimativa publicada de Hwang 2025; não recalculada pelo OES",
   "reported_study_count":10,
   "newly_modelled_studies":4,
   "pooled_by_oes":false,
   "interpretation":"A dCBT-I totalmente automatizada provavelmente reduz a gravidade da insônia; a direção é consistente, mas a magnitude varia entre estudos.",
   "summary_text":"Os RCTs recentes mantêm direção favorável, com magnitude variável.",
   "analysis_note":"Estimativa quantitativa-base adotada de Hwang 2025; atualização narrativa OES até 04/10/2026; sem novo pooling. Somzz possui possível sobreposição com a síntese-base."
 }'::jsonb,
 'active',TIMESTAMPTZ '2026-10-04 11:55:00-03'
);

INSERT INTO synthesis.contribution(
 synthesis_version_uuid,result_version_uuid,contribution_role,included_main_analysis,notes
) VALUES
('81000000-0000-0000-0000-000000000050','81000000-0000-0000-0000-000000000030','adopted_external_estimate',true,'Published Hwang comparator-specific estimate; not recalculated by OES'),
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000030','adopted_external_anchor',false,'Quantitative anchor only; not repooled'),
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000031','update_evidence',false,'Newer RCT supports direction; no pooling'),
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000032','update_evidence',false,'Newer RCT supports direction; no pooling'),
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000033','update_evidence',false,'Older-adult RCT supports direction; no pooling'),
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000034','eligible_possible_overlap',false,'Eligible result; possible overlap with Hwang pooling unresolved; not counted as independent pooled update');

-- Provenance: external anchor + Gao corroboration.
INSERT INTO provenance.record(
 provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
 source_location,source_value,process_type,actor,status
) VALUES
(
 '82300000-0000-0000-0000-000000000001',
 '81000000-0000-0000-0000-000000000050',
 '/result_summary',
 '81000000-0000-0000-0000-000000000020',
 'Comparator subgroup: online education about sleep',
 '{"SMD":-0.93,"CI95":[-1.07,-0.79],"k":10,"I2":68}'::jsonb,
 'external_synthesis_adoption','OES','active'
),
(
 '82300000-0000-0000-0000-000000000002',
 '81000000-0000-0000-0000-000000000051',
 '/result_summary/base_effect',
 '81000000-0000-0000-0000-000000000020',
 'Published comparator-specific meta-analysis',
 '{"SMD":-0.93,"CI95":[-1.07,-0.79],"k":10}'::jsonb,
 'external_synthesis_adoption','OES','active'
),
(
 '82300000-0000-0000-0000-000000000003',
 '81000000-0000-0000-0000-000000000051',
 '/result_summary/triangulation',
 '81000000-0000-0000-0000-000000000025',
 'Abstract/meta-analysis result',
 '{"global_SMD":-0.82,"trial_count":15,"interpretation":"corroborative; not comparator-specific in retrieved abstract"}'::jsonb,
 'triangulation','OES','active'
);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('81000000-0000-0000-0000-000000000030','81000000-0000-0000-0000-000000000050','result_supports_adopted_synthesis','synthesis.contribution'),
('81000000-0000-0000-0000-000000000050','81000000-0000-0000-0000-000000000051','external_synthesis_informs_update','adopted external quantitative anchor; no repooling'),
('81000000-0000-0000-0000-000000000031','81000000-0000-0000-0000-000000000051','rct_informs_update','narrative update'),
('81000000-0000-0000-0000-000000000032','81000000-0000-0000-0000-000000000051','rct_informs_update','narrative update'),
('81000000-0000-0000-0000-000000000033','81000000-0000-0000-0000-000000000051','rct_informs_update','narrative update'),
('81000000-0000-0000-0000-000000000034','81000000-0000-0000-0000-000000000051','rct_possible_overlap_informs_update','narrative update with overlap caution');

-- ---------------------------------------------------------------------------
-- GRADE CERTAINTY — PROVISIONAL / PENDING HUMAN REVIEW
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('80000000-0000-0000-0000-000000000060','OES-CE-2026-000110','CertaintyAssessment','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '81000000-0000-0000-0000-000000000060',
 '80000000-0000-0000-0000-000000000060',
 1,'current','real-case-01','initial',
 'Provisional GRADE assessment; human review required before publication'
);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000060');

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,outcome_entity_uuid,
 framework,framework_version,initial_level,final_level,evidence_state,assessment_date,status
) VALUES (
 '81000000-0000-0000-0000-000000000060',
 '80000000-0000-0000-0000-000000000060',
 '81000000-0000-0000-0000-000000000002',
 '81000000-0000-0000-0000-000000000051',
 '80000000-0000-0000-0000-000000000003',
 'GRADE','OES intervention protocol 2026','high','moderate',
 'evidence_available',DATE '2026-10-04','draft'
);

INSERT INTO appraisal.certainty_domain(
 certainty_assessment_version_uuid,domain_code,concern_level,downgrade_steps,upgrade_steps,rationale,reviewer,sequence_no
) VALUES
('81000000-0000-0000-0000-000000000060','risk_of_bias','serious',1,0,'The body is not dominated by unequivocally low-risk evidence; Hwang and newer RCTs retain material methodological concerns.','OES AI-assisted; pending human review',1),
('81000000-0000-0000-0000-000000000060','inconsistency','not_serious',0,0,'Magnitude varies and Hwang I2 is 68%, but all directly relevant sources identified favor dCBT-I; uncertainty affects magnitude more than direction.','OES AI-assisted; pending human review',2),
('81000000-0000-0000-0000-000000000060','indirectness','not_serious',0,0,'Population, intervention, comparator, post-treatment outcome and timing are directly represented.','OES AI-assisted; pending human review',3),
('81000000-0000-0000-0000-000000000060','imprecision','not_serious',0,0,'The published comparator-specific CI remains entirely favorable and information is supported by multiple additional RCTs.','OES AI-assisted; pending human review',4),
('81000000-0000-0000-0000-000000000060','publication_bias','undetected_residual_uncertainty',0,0,'Publication bias was not demonstrated; residual uncertainty remains because the N2 update is not exhaustive and subgroup-specific missing-evidence assessment is limited.','OES AI-assisted; pending human review',5);

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000060','updated_synthesis_informs_grade','GRADE body-of-evidence assessment'),
('81000000-0000-0000-0000-000000000040','81000000-0000-0000-0000-000000000060','robis_informs_grade','risk-of-bias domain'),
('81000000-0000-0000-0000-000000000041','81000000-0000-0000-0000-000000000060','rob2_informs_grade','risk-of-bias domain'),
('81000000-0000-0000-0000-000000000042','81000000-0000-0000-0000-000000000060','rob2_informs_grade','risk-of-bias domain'),
('81000000-0000-0000-0000-000000000043','81000000-0000-0000-0000-000000000060','rob2_informs_grade','risk-of-bias domain'),
('81000000-0000-0000-0000-000000000044','81000000-0000-0000-0000-000000000060','rob2_informs_grade','risk-of-bias domain');

-- ---------------------------------------------------------------------------
-- PRODUCT — UNDER REVIEW / NOT PUBLISHABLE
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('80000000-0000-0000-0000-000000000070','OES-P-2026-000110','Product','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '81000000-0000-0000-0000-000000000070',
 '80000000-0000-0000-0000-000000000070',
 1,'current','real-case-01','initial',
 'Real Case 01 Evidence Sheet preview; human review pending'
);

INSERT INTO product.product(entity_uuid)
VALUES ('80000000-0000-0000-0000-000000000070');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,evidence_cutoff_date,
 publication_date,status,conclusion_text,applicability_summary,limitations_summary
) VALUES (
 '81000000-0000-0000-0000-000000000070',
 '80000000-0000-0000-0000-000000000070',
 'evidence_sheet',
 'dCBT-I totalmente automatizada versus educação digital sobre sono para redução da gravidade da insônia em adultos',
 'technical_evidence_users',
 DATE '2026-10-04',
 NULL,
 'under_review',
 'A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos; a estimativa quantitativa-base não foi recalculada pelo OES.',
 'A evidência é razoavelmente direta para adultos com insônia, incluindo diferentes faixas etárias. Para o Brasil, a transferibilidade científica é plausível, mas disponibilidade, idioma, regulação, integração assistencial, acesso digital e implementação no SUS não foram formalmente avaliados.',
 'A síntese-base tem inconsistência temporal não explicada no processo de busca, heterogeneidade relevante (I2=68%) e distribuição de risco de viés não ideal; os RCTs de atualização têm algumas preocupações; o OES não realizou novo pooling; a busca N2 não reivindica exaustividade; segurança é menos bem caracterizada; não foi identificado RCT brasileiro diretamente aderente.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 '81000000-0000-0000-0000-000000000070',
 '81000000-0000-0000-0000-000000000002',
 'primary',1
);

-- Only the OES update synthesis is a Product priority synthesis.
INSERT INTO product.synthesis_link(
 product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
 '81000000-0000-0000-0000-000000000070',
 '81000000-0000-0000-0000-000000000051',
 'primary',1
);

INSERT INTO product.certainty_link(
 product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
 '81000000-0000-0000-0000-000000000070',
 '81000000-0000-0000-0000-000000000060',
 'primary',1
);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,assessed_at,assessed_by,rationale,record_status
) VALUES (
 '82400000-0000-0000-0000-000000000001',
 '81000000-0000-0000-0000-000000000070',
 'current',
 TIMESTAMPTZ '2026-10-04 12:00:00-03',
 'OES',
 'Search update executed through the evidence cutoff; product remains under scientific review.',
 'active'
);

-- Deliberately NO product.review_record with decision=approved.
-- The real-case product must remain non-publishable until human review.

INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('81000000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000070','updated_synthesis_informs_product','product.synthesis_link'),
('81000000-0000-0000-0000-000000000060','81000000-0000-0000-0000-000000000070','provisional_grade_informs_product','product.certainty_link');

COMMIT;
