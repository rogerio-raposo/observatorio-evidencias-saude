-- OES Fase 3 — Real Case 01 deterministic dataset
-- dCBT-I fully automated vs digital sleep education in adults with insomnia
-- Requires baseline + migrations 002–009.
-- Status: scientific validation dataset; Product intentionally under_review.
-- Cutoff: 2026-10-04

BEGIN;

-- ---------------------------------------------------------------------------
-- QUESTION + INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid, oes_id, entity_type, created_by)
VALUES
('86000000-0000-0000-0000-000000000001','OES-Q-2026-000401','Question','real-case-01'),
('86000000-0000-0000-0000-000000000002','OES-I-2026-000401','Investigation','real-case-01'),
('86000000-0000-0000-0000-000000000003','OES-OUT-2026-000401','Outcome','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('86100000-0000-0000-0000-000000000001','86000000-0000-0000-0000-000000000001',1,'current','real-case-01','initial','Real Case 01 question'),
('86100000-0000-0000-0000-000000000002','86000000-0000-0000-0000-000000000002',1,'current','real-case-01','initial','Real Case 01 N2 investigation'),
('86100000-0000-0000-0000-000000000003','86000000-0000-0000-0000-000000000003',1,'current','real-case-01','initial','Insomnia severity outcome');

INSERT INTO investigation.question(entity_uuid)
VALUES ('86000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,
 question_type,structure_type,context_payload,time_horizon_payload
) VALUES (
 '86100000-0000-0000-0000-000000000001',
 '86000000-0000-0000-0000-000000000001',
 'Em adultos com insônia, a terapia cognitivo-comportamental digital para insônia totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia ao final do tratamento?',
 'Em adultos com insônia, dCBT-I totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia no pós-tratamento?',
 'intervention',
 'PICO',
 '{"population":"adults with insomnia","intervention":"fully automated dCBT-I","comparator":"digital sleep education / sleep hygiene education","outcome":"insomnia severity"}'::jsonb,
 '{"primary_window":"approximately 6-12 weeks after baseline","focus":"post-treatment"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('86000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
 version_uuid,entity_uuid,primary_question_entity_uuid,
 investigation_type,depth_level,maintenance_level,objective,
 start_date,evidence_cutoff_date,status
) VALUES (
 '86100000-0000-0000-0000-000000000002',
 '86000000-0000-0000-0000-000000000002',
 '86000000-0000-0000-0000-000000000001',
 'evidence_sheet_validation',
 'N2','M1',
 'Validate the OES Evidence Sheet end-to-end using a real intervention question',
 DATE '2026-10-04',DATE '2026-10-04','active'
);

INSERT INTO investigation.investigation_question(
 investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
 '86100000-0000-0000-0000-000000000002',
 '86100000-0000-0000-0000-000000000001',
 'primary',1
);

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('86000000-0000-0000-0000-000000000003');

INSERT INTO evidence.outcome_version(
 version_uuid,entity_uuid,preferred_name,definition,domain,
 direction_of_benefit,unit_family,status
) VALUES (
 '86100000-0000-0000-0000-000000000003',
 '86000000-0000-0000-0000-000000000003',
 'Gravidade da insônia',
 'Gravidade dos sintomas de insônia no pós-tratamento, priorizando o Insomnia Severity Index (ISI) ou escala validada equivalente.',
 'sleep',
 'lower_is_better',
 'symptom_scale',
 'active'
);

-- ---------------------------------------------------------------------------
-- SEARCH RECORDS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,
 source_name,platform,exact_strategy,filters_payload,
 executed_at,result_count,strategy_version,operator,status
) VALUES
(
 '86200000-0000-0000-0000-000000000001','OES-S-2026-000401',
 '86100000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(insomnia[Title/Abstract]) AND ("digital cognitive behavioral therapy"[Title/Abstract] OR "digital cognitive behavioural therapy"[Title/Abstract] OR "internet cognitive behavioral therapy"[Title/Abstract] OR "internet cognitive behavioural therapy"[Title/Abstract] OR dCBT-I[Title/Abstract] OR "fully automated"[Title/Abstract]) AND (systematic review[Publication Type] OR meta-analysis[Publication Type] OR systematic review[Title/Abstract] OR meta-analysis[Title/Abstract])',
 '{"purpose":"systematic_reviews_meta_analyses","language_restriction":null,"date_restriction":null,"raw_hit_count_unavailable":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 10:00:00-03',
 NULL,'1.0','OES-development','completed'
),
(
 '86200000-0000-0000-0000-000000000002','OES-S-2026-000402',
 '86100000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(insomnia[Title/Abstract]) AND ("digital cognitive behavioral therapy"[Title/Abstract] OR "digital cognitive behavioural therapy"[Title/Abstract] OR "internet cognitive behavioral therapy"[Title/Abstract] OR "internet cognitive behavioural therapy"[Title/Abstract] OR dCBT-I[Title/Abstract] OR "fully automated"[Title/Abstract]) AND (randomized controlled trial[Publication Type] OR randomized[Title/Abstract] OR randomised[Title/Abstract])',
 '{"purpose":"randomized_trials","language_restriction":null,"date_restriction":null,"raw_hit_count_unavailable":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 10:05:00-03',
 NULL,'1.0','OES-development','completed'
),
(
 '86200000-0000-0000-0000-000000000003','OES-S-2026-000403',
 '86100000-0000-0000-0000-000000000002',
 'BVS/LILACS','BVS',
 'insomnia AND ("digital cognitive behavioral therapy" OR "digital cognitive behavioural therapy" OR dCBT-I OR "terapia cognitivo-comportamental digital")',
 '{"purpose":"regional_brazil_latin_america","raw_hit_count_unavailable":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 10:10:00-03',
 NULL,'1.0','OES-development','completed'
),
(
 '86200000-0000-0000-0000-000000000004','OES-S-2026-000404',
 '86100000-0000-0000-0000-000000000002',
 'ClinicalTrials.gov','ClinicalTrials.gov',
 'insomnia AND digital cognitive behavioral therapy AND fully automated',
 '{"purpose":"trial_registry_check","raw_hit_count_unavailable":true}'::jsonb,
 TIMESTAMPTZ '2026-10-04 10:15:00-03',
 NULL,'1.0','OES-development','completed'
);

-- ---------------------------------------------------------------------------
-- STUDIES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('86000000-0000-0000-0000-000000000010','OES-ST-2026-000401','Study','real-case-01'),
('86000000-0000-0000-0000-000000000011','OES-ST-2026-000402','Study','real-case-01'),
('86000000-0000-0000-0000-000000000012','OES-ST-2026-000403','Study','real-case-01'),
('86000000-0000-0000-0000-000000000013','OES-ST-2026-000404','Study','real-case-01'),
('86000000-0000-0000-0000-000000000014','OES-ST-2026-000405','Study','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('86100000-0000-0000-0000-000000000010','86000000-0000-0000-0000-000000000010',1,'current','real-case-01','initial','Hwang 2025 systematic review'),
('86100000-0000-0000-0000-000000000011','86000000-0000-0000-0000-000000000011',1,'current','real-case-01','initial','Sweetman 2024 RCT'),
('86100000-0000-0000-0000-000000000012','86000000-0000-0000-0000-000000000012',1,'current','real-case-01','initial','SleepioRx 2025 RCT'),
('86100000-0000-0000-0000-000000000013','86000000-0000-0000-0000-000000000013',1,'current','real-case-01','initial','SHUTi OASIS 2025 RCT'),
('86100000-0000-0000-0000-000000000014','86000000-0000-0000-0000-000000000014',1,'current','real-case-01','initial','Somzz 2024 RCT');

INSERT INTO evidence.study(entity_uuid) VALUES
('86000000-0000-0000-0000-000000000010'),
('86000000-0000-0000-0000-000000000011'),
('86000000-0000-0000-0000-000000000012'),
('86000000-0000-0000-0000-000000000013'),
('86000000-0000-0000-0000-000000000014');

INSERT INTO evidence.study_version(
 version_uuid,entity_uuid,study_type,design,title_or_label,
 recruitment_context,sample_size,status
) VALUES
(
 '86100000-0000-0000-0000-000000000010','86000000-0000-0000-0000-000000000010',
 'systematic_review','systematic_review_meta_analysis',
 'Hwang et al. 2025 — fully automated dCBT-I systematic review and meta-analysis',
 '{"scope":"adults","included_rcts":29,"total_n":9475,"focal_subgroup_k":10}'::jsonb,
 9475,'active'
),
(
 '86100000-0000-0000-0000-000000000011','86000000-0000-0000-0000-000000000011',
 'primary_study','randomized_controlled_trial',
 'Sweetman et al. 2024 — dCBT-I vs digital sleep education',
 '{"country":"Australia","setting":"community"}'::jsonb,
 62,'active'
),
(
 '86100000-0000-0000-0000-000000000012','86000000-0000-0000-0000-000000000012',
 'primary_study','randomized_controlled_trial',
 'Prather et al. 2025 — SleepioRx CrEDIT trial',
 '{"country":"United States","setting":"nationwide decentralized","registry":"NCT05541055"}'::jsonb,
 336,'active'
),
(
 '86100000-0000-0000-0000-000000000013','86000000-0000-0000-0000-000000000013',
 'primary_study','randomized_controlled_trial',
 'Ritterband et al. 2025 — SHUTi OASIS older-adult trial',
 '{"country":"United States","age_range":"55-95","registry":"NCT03213132"}'::jsonb,
 311,'active'
),
(
 '86100000-0000-0000-0000-000000000014','86000000-0000-0000-0000-000000000014',
 'primary_study','randomized_controlled_trial',
 'Shin et al. 2024 — Somzz multicenter randomized clinical trial',
 '{"country":"South Korea","registry":"KCT0007292","possible_overlap_with_hwang_pooling":true}'::jsonb,
 98,'active'
);

-- ---------------------------------------------------------------------------
-- REPORTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('86000000-0000-0000-0000-000000000020','OES-RP-2026-000401','Report','real-case-01'),
('86000000-0000-0000-0000-000000000021','OES-RP-2026-000402','Report','real-case-01'),
('86000000-0000-0000-0000-000000000022','OES-RP-2026-000403','Report','real-case-01'),
('86000000-0000-0000-0000-000000000023','OES-RP-2026-000404','Report','real-case-01'),
('86000000-0000-0000-0000-000000000024','OES-RP-2026-000405','Report','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('86100000-0000-0000-0000-000000000020','86000000-0000-0000-0000-000000000020',1,'current','real-case-01','initial','Hwang report'),
('86100000-0000-0000-0000-000000000021','86000000-0000-0000-0000-000000000021',1,'current','real-case-01','initial','Sweetman report'),
('86100000-0000-0000-0000-000000000022','86000000-0000-0000-0000-000000000022',1,'current','real-case-01','initial','SleepioRx report'),
('86100000-0000-0000-0000-000000000023','86000000-0000-0000-0000-000000000023',1,'current','real-case-01','initial','OASIS report'),
('86100000-0000-0000-0000-000000000024','86000000-0000-0000-0000-000000000024',1,'current','real-case-01','initial','Somzz report');

INSERT INTO evidence.report(entity_uuid) VALUES
('86000000-0000-0000-0000-000000000020'),
('86000000-0000-0000-0000-000000000021'),
('86000000-0000-0000-0000-000000000022'),
('86000000-0000-0000-0000-000000000023'),
('86000000-0000-0000-0000-000000000024');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,
 language,publication_status,full_text_status,bibliographic_payload,status
) VALUES
(
 '86100000-0000-0000-0000-000000000020','86000000-0000-0000-0000-000000000020',
 'systematic_review',
 'Systematic review and meta-analysis on fully automated digital cognitive behavioral therapy for insomnia',
 DATE '2025-03-12','npj Digital Medicine','en','published','full_text_available',
 '{"pmid":"40075149","pmcid":"PMC11903857","doi":"10.1038/s41746-025-01514-4","prospero":"CRD42024526617"}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000021','86000000-0000-0000-0000-000000000021',
 'journal_article',
 'Digital cognitive behavioural therapy for insomnia versus digital sleep education control in an Australian community-based sample: a randomised controlled trial',
 DATE '2024-09-10','Internal Medicine Journal','en','published','full_text_available',
 '{"pmid":"39257295","doi":"10.1111/imj.16521","registry":"ACTRN12621001395820"}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000022','86000000-0000-0000-0000-000000000022',
 'journal_article',
 'The Effectiveness of Digital Cognitive Behavioral Therapy to Treat Insomnia Disorder in US Adults: Nationwide Decentralized Randomized Controlled Trial',
 DATE '2025-12-04','JMIR Mental Health','en','published','full_text_available',
 '{"pmid":"41343796","registry":"NCT05541055"}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000023','86000000-0000-0000-0000-000000000023',
 'journal_article',
 'A randomized controlled trial of a digital cognitive behavioral therapy for insomnia for older adults',
 DATE '2025-07-18','npj Digital Medicine','en','published','full_text_available',
 '{"pmid":"40681664","pmcid":"PMC12274496","doi":"10.1038/s41746-025-01847-0","registry":"NCT03213132"}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000024','86000000-0000-0000-0000-000000000024',
 'journal_article',
 'Efficacy of Mobile App-Based Cognitive Behavioral Therapy for Insomnia: Multicenter, Single-Blind Randomized Clinical Trial',
 DATE '2024-07-26','Journal of Medical Internet Research','en','published','full_text_available',
 '{"pmid":"39058549","pmcid":"PMC11316165","doi":"10.2196/50555","registry":"KCT0007292"}'::jsonb,'active'
);

INSERT INTO evidence.study_report_link(
 link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
 confidence,evidence_note,reviewer,decision_date,status
) VALUES
('86300000-0000-0000-0000-000000000020','86000000-0000-0000-0000-000000000010','86000000-0000-0000-0000-000000000020','primary_report','confirmed','Systematic review primary report','OES-development',DATE '2026-10-04','active'),
('86300000-0000-0000-0000-000000000021','86000000-0000-0000-0000-000000000011','86000000-0000-0000-0000-000000000021','primary_report','confirmed','RCT primary report','OES-development',DATE '2026-10-04','active'),
('86300000-0000-0000-0000-000000000022','86000000-0000-0000-0000-000000000012','86000000-0000-0000-0000-000000000022','primary_report','confirmed','RCT primary report','OES-development',DATE '2026-10-04','active'),
('86300000-0000-0000-0000-000000000023','86000000-0000-0000-0000-000000000013','86000000-0000-0000-0000-000000000023','primary_report','confirmed','RCT primary report','OES-development',DATE '2026-10-04','active'),
('86300000-0000-0000-0000-000000000024','86000000-0000-0000-0000-000000000014','86000000-0000-0000-0000-000000000024','primary_report','confirmed','RCT primary report; possible overlap with Hwang pooling unresolved','OES-development',DATE '2026-10-04','active');

-- Screening decisions for material included reports.
INSERT INTO investigation.screening_decision(
 screening_uuid,oes_screening_id,investigation_version_uuid,target_entity_uuid,
 stage,reviewer,decision,decided_at,adjudication_flag
) VALUES
('86400000-0000-0000-0000-000000000020','OES-SCR-2026-000401','86100000-0000-0000-0000-000000000002','86000000-0000-0000-0000-000000000020','full_text','OES-development','include',TIMESTAMPTZ '2026-10-04 10:30:00-03',false),
('86400000-0000-0000-0000-000000000021','OES-SCR-2026-000402','86100000-0000-0000-0000-000000000002','86000000-0000-0000-0000-000000000021','full_text','OES-development','include',TIMESTAMPTZ '2026-10-04 10:31:00-03',false),
('86400000-0000-0000-0000-000000000022','OES-SCR-2026-000403','86100000-0000-0000-0000-000000000002','86000000-0000-0000-0000-000000000022','full_text','OES-development','include',TIMESTAMPTZ '2026-10-04 10:32:00-03',false),
('86400000-0000-0000-0000-000000000023','OES-SCR-2026-000404','86100000-0000-0000-0000-000000000002','86000000-0000-0000-0000-000000000023','full_text','OES-development','include',TIMESTAMPTZ '2026-10-04 10:33:00-03',false),
('86400000-0000-0000-0000-000000000024','OES-SCR-2026-000405','86100000-0000-0000-0000-000000000002','86000000-0000-0000-0000-000000000024','full_text','OES-development','include',TIMESTAMPTZ '2026-10-04 10:34:00-03',false);

-- ---------------------------------------------------------------------------
-- RESULTS + SOURCES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('86000000-0000-0000-0000-000000000030','OES-R-2026-000401','Result','real-case-01'),
('86000000-0000-0000-0000-000000000031','OES-R-2026-000402','Result','real-case-01'),
('86000000-0000-0000-0000-000000000032','OES-R-2026-000403','Result','real-case-01'),
('86000000-0000-0000-0000-000000000033','OES-R-2026-000404','Result','real-case-01'),
('86000000-0000-0000-0000-000000000034','OES-R-2026-000405','Result','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('86100000-0000-0000-0000-000000000030','86000000-0000-0000-0000-000000000030',1,'current','real-case-01','initial','Hwang focal subgroup result'),
('86100000-0000-0000-0000-000000000031','86000000-0000-0000-0000-000000000031',1,'current','real-case-01','initial','Sweetman primary outcome result'),
('86100000-0000-0000-0000-000000000032','86000000-0000-0000-0000-000000000032',1,'current','real-case-01','initial','SleepioRx primary outcome result'),
('86100000-0000-0000-0000-000000000033','86000000-0000-0000-0000-000000000033',1,'current','real-case-01','initial','OASIS directional primary outcome result'),
('86100000-0000-0000-0000-000000000034','86000000-0000-0000-0000-000000000034',1,'current','real-case-01','initial','Somzz primary outcome result');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid) VALUES
('86000000-0000-0000-0000-000000000030','86000000-0000-0000-0000-000000000010'),
('86000000-0000-0000-0000-000000000031','86000000-0000-0000-0000-000000000011'),
('86000000-0000-0000-0000-000000000032','86000000-0000-0000-0000-000000000012'),
('86000000-0000-0000-0000-000000000033','86000000-0000-0000-0000-000000000013'),
('86000000-0000-0000-0000-000000000034','86000000-0000-0000-0000-000000000014');

INSERT INTO evidence.result_version(
 version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,
 timepoint_value,timepoint_unit,timepoint_label,estimand,measure,
 reported_value,ci_lower,ci_upper,unit,adjusted_flag,analysis_population,
 missing_data_state,method_payload,status
) VALUES
(
 '86100000-0000-0000-0000-000000000030','86000000-0000-0000-0000-000000000030',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia","comparison":"fully automated dCBT-I vs online sleep education"}'::jsonb,
 NULL,NULL,'post-treatment','between_group_standardized_effect',
 'standardized_mean_difference',
 '{"effect":-0.93,"direction":"favors_intervention","reported_study_count":10,"heterogeneity_i2":68}'::jsonb,
 -1.07,-0.79,'standard_deviation',true,'meta-analysis subgroup','not_applicable',
 '{"origin":"published_meta_analysis","model":"random_effects","recalculated_by_oes":false}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000031','86000000-0000-0000-0000-000000000031',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"Australian community adults with insomnia symptoms"}'::jsonb,
 8,'week','8 weeks','adjusted_between_group_difference',
 'ISI_mean_difference',
 '{"difference":-7.32,"direction":"favors_intervention","cohen_d":1.64}'::jsonb,
 -9.6,-5.0,'ISI_points',true,'intention_to_treat','partially_missing',
 '{"analysis":"mixed_models","interpretation":"negative difference favors lower insomnia severity"}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000032','86000000-0000-0000-0000-000000000032',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"US adults with DSM-5 insomnia disorder"}'::jsonb,
 10,'week','10 weeks','between_group_standardized_effect',
 'cohen_d_favors_intervention',
 '{"effect_size":0.60,"direction":"favors_intervention"}'::jsonb,
 NULL,NULL,'standard_deviation',true,'intention_to_treat','partially_missing',
 '{"analysis":"linear_mixed_models","missing_assumption":"MAR"}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000033','86000000-0000-0000-0000-000000000033',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"adults aged 55-95 years"}'::jsonb,
 NULL,NULL,'post-treatment','between_group_directional_effect',
 'ISI_directional_effect',
 '{"direction":"favors_intervention","response_intervention_pct":38,"response_control_pct":5,"remission_intervention_pct":30,"remission_control_pct":2,"note":"Exact focal-arm continuous mean difference not stored in this N2 dataset"}'::jsonb,
 NULL,NULL,'mixed',false,'trial arm comparison','low_post_treatment_missingness',
 '{"analysis":"published trial result","age_specific_population":true}'::jsonb,'active'
),
(
 '86100000-0000-0000-0000-000000000034','86000000-0000-0000-0000-000000000034',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia in multicenter Korean trial"}'::jsonb,
 NULL,NULL,'post-intervention','between_group_post_treatment_difference',
 'ISI_post_treatment_mean_difference',
 '{"intervention_mean":9.0,"control_mean":12.8,"difference":-3.8,"direction":"favors_intervention"}'::jsonb,
 NULL,NULL,'ISI_points',false,'intention_to_treat','LOCF',
 '{"analysis":"LOCF for missing data","possible_overlap_with_hwang_pooling":true}'::jsonb,'active'
);

INSERT INTO evidence.result_source(
 result_version_uuid,report_version_uuid,source_location,source_type,
 original_text_or_value,extraction_method,is_primary_source,extractor
) VALUES
('86100000-0000-0000-0000-000000000030','86100000-0000-0000-0000-000000000020','Meta-analysis subgroup: online education about sleep','meta_analysis','{"SMD":-0.93,"CI95":[-1.07,-0.79],"k":10,"I2":68}'::jsonb,'manual_structured_extraction',true,'OES-development'),
('86100000-0000-0000-0000-000000000031','86100000-0000-0000-0000-000000000021','Primary outcome / 8-week ISI result','article_result','{"adjusted_difference":-7.32,"CI95":[-9.6,-5.0],"d":1.64}'::jsonb,'manual_structured_extraction',true,'OES-development'),
('86100000-0000-0000-0000-000000000032','86100000-0000-0000-0000-000000000022','Primary outcome / 10-week ISI result','article_result','{"d":0.60}'::jsonb,'manual_structured_extraction',true,'OES-development'),
('86100000-0000-0000-0000-000000000033','86100000-0000-0000-0000-000000000023','Post-treatment ISI/response/remission results','article_result','{"response":[38,5],"remission":[30,2]}'::jsonb,'manual_structured_extraction',true,'OES-development'),
('86100000-0000-0000-0000-000000000034','86100000-0000-0000-0000-000000000024','Post-intervention ISI result','article_result','{"means":[9.0,12.8]}'::jsonb,'manual_structured_extraction',true,'OES-development');

-- ---------------------------------------------------------------------------
-- RISK OF BIAS / ROBIS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('86000000-0000-0000-0000-000000000050','OES-RA-2026-000401','RiskAssessment','real-case-01'),
('86000000-0000-0000-0000-000000000051','OES-RA-2026-000402','RiskAssessment','real-case-01'),
('86000000-0000-0000-0000-000000000052','OES-RA-2026-000403','RiskAssessment','real-case-01'),
('86000000-0000-0000-0000-000000000053','OES-RA-2026-000404','RiskAssessment','real-case-01'),
('86000000-0000-0000-0000-000000000054','OES-RA-2026-000405','RiskAssessment','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('86100000-0000-0000-0000-000000000050','86000000-0000-0000-0000-000000000050',1,'current','real-case-01','initial','ROBIS Hwang'),
('86100000-0000-0000-0000-000000000051','86000000-0000-0000-0000-000000000051',1,'current','real-case-01','initial','RoB 2 Sweetman'),
('86100000-0000-0000-0000-000000000052','86000000-0000-0000-0000-000000000052',1,'current','real-case-01','initial','RoB 2 SleepioRx'),
('86100000-0000-0000-0000-000000000053','86000000-0000-0000-0000-000000000053',1,'current','real-case-01','initial','RoB 2 OASIS'),
('86100000-0000-0000-0000-000000000054','86000000-0000-0000-0000-000000000054',1,'current','real-case-01','initial','RoB 2 Somzz');

INSERT INTO appraisal.risk_assessment(entity_uuid) VALUES
('86000000-0000-0000-0000-000000000050'),
('86000000-0000-0000-0000-000000000051'),
('86000000-0000-0000-0000-000000000052'),
('86000000-0000-0000-0000-000000000053'),
('86000000-0000-0000-0000-000000000054');

INSERT INTO appraisal.risk_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,framework,framework_version,
 target_entity_uuid,outcome_entity_uuid,overall_judgement,assessor,assessment_date,
 verification_status,instrument_payload,status
) VALUES
('86100000-0000-0000-0000-000000000050','86000000-0000-0000-0000-000000000050','86100000-0000-0000-0000-000000000002','ROBIS','current guidance','86000000-0000-0000-0000-000000000010',NULL,'unclear_risk','OES AI-assisted methodological draft',DATE '2026-10-04','pending_human_verification','{"key_issue":"declared search cutoff inconsistent with later-published study cited/included"}'::jsonb,'active'),
('86100000-0000-0000-0000-000000000051','86000000-0000-0000-0000-000000000051','86100000-0000-0000-0000-000000000002','RoB 2','current guidance','86000000-0000-0000-0000-000000000011','86000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted methodological draft',DATE '2026-10-04','pending_human_verification','{}'::jsonb,'active'),
('86100000-0000-0000-0000-000000000052','86000000-0000-0000-0000-000000000052','86100000-0000-0000-0000-000000000002','RoB 2','current guidance','86000000-0000-0000-0000-000000000012','86000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted methodological draft',DATE '2026-10-04','pending_human_verification','{}'::jsonb,'active'),
('86100000-0000-0000-0000-000000000053','86000000-0000-0000-0000-000000000053','86100000-0000-0000-0000-000000000002','RoB 2','current guidance','86000000-0000-0000-0000-000000000013','86000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted methodological draft',DATE '2026-10-04','pending_human_verification','{}'::jsonb,'active'),
('86100000-0000-0000-0000-000000000054','86000000-0000-0000-0000-000000000054','86100000-0000-0000-0000-000000000002','RoB 2','current guidance','86000000-0000-0000-0000-000000000014','86000000-0000-0000-0000-000000000003','some_concerns','OES AI-assisted methodological draft',DATE '2026-10-04','pending_human_verification','{}'::jsonb,'active');

INSERT INTO appraisal.risk_assessment_domain(
 risk_assessment_version_uuid,domain_code,judgement,rationale,sequence_no
) VALUES
('86100000-0000-0000-0000-000000000050','eligibility','low_concern','Eligibility criteria were explicit and protocol registered.',1),
('86100000-0000-0000-0000-000000000050','identification_selection','high_concern','Search cutoff was declared as 2024-03-31, yet a later-published trial is cited/included without a clear update mechanism.',2),
('86100000-0000-0000-0000-000000000050','data_collection_appraisal','unclear_concern','Double extraction and RoB 2 were used, but the impact of exclusions for unavailable data is insufficiently clear.',3),
('86100000-0000-0000-0000-000000000050','synthesis_findings','unclear_concern','Comparator subgroup is relevant but I2=68%, study-level risk contribution is not fully reconstructable, and no GRADE certainty was reported.',4),

('86100000-0000-0000-0000-000000000051','randomization','some_concerns','Computer randomization described; allocation concealment not sufficiently demonstrated in the recovered report.',1),
('86100000-0000-0000-0000-000000000051','deviations','low_risk','Digital active control and ITT mixed-model analysis reduce concern about deviations.',2),
('86100000-0000-0000-0000-000000000051','missing_outcome_data','some_concerns','Approximately 14.5% missing at 8 weeks; no robust MNAR sensitivity analysis identified for continuous ISI.',3),
('86100000-0000-0000-0000-000000000051','outcome_measurement','some_concerns','ISI is validated but self-reported in an open-label context.',4),
('86100000-0000-0000-0000-000000000051','reported_result_selection','low_risk','Prospective registration and primary ISI outcome were identifiable.',5),

('86100000-0000-0000-0000-000000000052','randomization','low_risk','Central randomized allocation with concealed sequence.',1),
('86100000-0000-0000-0000-000000000052','deviations','low_risk','Both arms were digital sleep programs and analysis was ITT.',2),
('86100000-0000-0000-0000-000000000052','missing_outcome_data','some_concerns','Dropout was slightly higher in SleepioRx; MAR models and sensitivity analyses reduce but do not eliminate concern.',3),
('86100000-0000-0000-0000-000000000052','outcome_measurement','low_risk','Validated ISI, masked hypotheses, same measurement across groups.',4),
('86100000-0000-0000-0000-000000000052','reported_result_selection','low_risk','Prospective registration and primary endpoints were explicit.',5),

('86100000-0000-0000-0000-000000000053','randomization','some_concerns','Randomized sequence reported, but practical concealment before assignment is not completely clear.',1),
('86100000-0000-0000-0000-000000000053','deviations','low_risk','Automated intervention; technical support did not provide clinical guidance.',2),
('86100000-0000-0000-0000-000000000053','missing_outcome_data','low_risk','Post-treatment missingness was low for the focal timepoint.',3),
('86100000-0000-0000-0000-000000000053','outcome_measurement','low_risk','Validated ISI and reported participant masking to allocation.',4),
('86100000-0000-0000-0000-000000000053','reported_result_selection','low_risk','Prospective registry and planned insomnia outcomes were identifiable.',5),

('86100000-0000-0000-0000-000000000054','randomization','low_risk','Web-response system with stratified blocked randomization.',1),
('86100000-0000-0000-0000-000000000054','deviations','low_risk','Intervention delivered by app; same visit schedule and ITT analysis.',2),
('86100000-0000-0000-0000-000000000054','missing_outcome_data','some_concerns','LOCF was used for missing data and relies on strong assumptions.',3),
('86100000-0000-0000-0000-000000000054','outcome_measurement','low_risk','Validated ISI with participant masking reported.',4),
('86100000-0000-0000-0000-000000000054','reported_result_selection','low_risk','Trial registration and primary ISI outcome were identifiable.',5);

-- ---------------------------------------------------------------------------
-- SYNTHESES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('86000000-0000-0000-0000-000000000060','OES-SY-2026-000401','Synthesis','real-case-01'),
('86000000-0000-0000-0000-000000000061','OES-SY-2026-000402','Synthesis','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES
('86100000-0000-0000-0000-000000000060','86000000-0000-0000-0000-000000000060',1,'current','real-case-01','initial','Adopted external quantitative synthesis'),
('86100000-0000-0000-0000-000000000061','86000000-0000-0000-0000-000000000061',1,'current','real-case-01','initial','OES directed narrative update');

INSERT INTO synthesis.synthesis(entity_uuid) VALUES
('86000000-0000-0000-0000-000000000060'),
('86000000-0000-0000-0000-000000000061');

INSERT INTO synthesis.synthesis_version(
 version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
 population_descriptor,comparison_payload,timepoint_payload,estimand,
 synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES
(
 '86100000-0000-0000-0000-000000000060',
 '86000000-0000-0000-0000-000000000060',
 '86100000-0000-0000-0000-000000000002',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"online education about sleep"}'::jsonb,
 '{"timepoint":"post-treatment"}'::jsonb,
 'between_group_standardized_effect',
 'meta_analysis','adopted_external',
 'critical_adoption_of_published_meta_analysis','published_random_effects',
 '{"summary_type":"adopted_quantitative_estimate","effect_measure":"SMD","effect_value":-0.93,"ci_lower":-1.07,"ci_upper":-0.79,"reported_study_count":10,"heterogeneity_i2":68,"effect_display":"SMD -0,93 (IC95% -1,07 a -0,79)","interpretation":"Efeito favorável à dCBT-I; magnitude grande na síntese publicada.","recalculated_by_oes":false,"analysis_note":"Meta-análise não recalculada pelo OES."}'::jsonb,
 'active',TIMESTAMPTZ '2026-10-04 11:00:00-03'
),
(
 '86100000-0000-0000-0000-000000000061',
 '86000000-0000-0000-0000-000000000061',
 '86100000-0000-0000-0000-000000000002',
 '86000000-0000-0000-0000-000000000003',
 '{"population":"adults with insomnia; one update trial restricted to age 55-95"}'::jsonb,
 '{"intervention":"fully automated dCBT-I","comparator":"digital sleep education / patient education"}'::jsonb,
 '{"timepoint":"approximately 6-12 weeks; post-treatment"}'::jsonb,
 'direction_and_magnitude_update',
 'narrative_update','oes_update',
 'directed_update_without_repooling','no_new_pooling',
 '{"summary_type":"narrative_update","direction":"favors_intervention","newly_modelled_primary_studies":4,"pooled_by_oes":false,"summary_text":"Os RCTs recentes mantêm direção favorável à dCBT-I, com magnitude variável.","interpretation":"A direção do benefício é consistente; a magnitude exata é mais incerta.","analysis_note":"Atualização qualitativa dirigida; nenhum pooling incremental foi calculado pelo OES."}'::jsonb,
 'active',TIMESTAMPTZ '2026-10-04 11:05:00-03'
);

INSERT INTO synthesis.contribution(
 synthesis_version_uuid,result_version_uuid,contribution_role,
 included_main_analysis,included_sensitivity,notes
) VALUES
('86100000-0000-0000-0000-000000000060','86100000-0000-0000-0000-000000000030','adopted_external_estimate',true,false,'Published Hwang comparator-specific estimate'),
('86100000-0000-0000-0000-000000000061','86100000-0000-0000-0000-000000000031','update_evidence',false,false,'Directional and magnitude update; no repooling'),
('86100000-0000-0000-0000-000000000061','86100000-0000-0000-0000-000000000032','update_evidence',false,false,'Directional and magnitude update; no repooling'),
('86100000-0000-0000-0000-000000000061','86100000-0000-0000-0000-000000000033','update_evidence',false,false,'Older-adult population; informs direction and applicability'),
('86100000-0000-0000-0000-000000000061','86100000-0000-0000-0000-000000000034','eligible_possible_overlap',false,false,'Possible overlap with Hwang pooling remains unresolved; not treated as incremental quantitative evidence');

-- Adopted synthesis informs the OES update, without implying repooling.
INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES (
 '86100000-0000-0000-0000-000000000060',
 '86100000-0000-0000-0000-000000000061',
 'adopted_synthesis_informs_update',
 'Published quantitative anchor informs OES narrative update; no statistical recomputation'
);

-- ---------------------------------------------------------------------------
-- GRADE CERTAINTY — PROVISIONAL / UNDER REVIEW
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('86000000-0000-0000-0000-000000000070','OES-CA-2026-000401','CertaintyAssessment','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '86100000-0000-0000-0000-000000000070',
 '86000000-0000-0000-0000-000000000070',
 1,'current','real-case-01','initial','Provisional GRADE assessment pending human review'
);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('86000000-0000-0000-0000-000000000070');

INSERT INTO appraisal.certainty_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,synthesis_version_uuid,
 outcome_entity_uuid,framework,framework_version,initial_level,final_level,
 evidence_state,assessment_date,status
) VALUES (
 '86100000-0000-0000-0000-000000000070',
 '86000000-0000-0000-0000-000000000070',
 '86100000-0000-0000-0000-000000000002',
 '86100000-0000-0000-0000-000000000061',
 '86000000-0000-0000-0000-000000000003',
 'GRADE','OES operational guidance current at 2026-10-04',
 'high','moderate','evidence_available',DATE '2026-10-04','under_review'
);

INSERT INTO appraisal.certainty_domain(
 certainty_assessment_version_uuid,domain_code,concern_level,
 downgrade_steps,upgrade_steps,rationale,reviewer,sequence_no
) VALUES
('86100000-0000-0000-0000-000000000070','risk_of_bias','serious',1,0,'Few studies are unequivocally low risk; recent RCTs have some concerns and the base review has unresolved study-level risk contribution.','OES AI-assisted draft — human verification pending',1),
('86100000-0000-0000-0000-000000000070','inconsistency','not_serious',0,0,'Magnitude varies and I2=68% in the focal subgroup, but all decisive studies favor dCBT-I; certainty statement is directional rather than a fixed effect size.','OES AI-assisted draft — human verification pending',2),
('86100000-0000-0000-0000-000000000070','indirectness','not_serious',0,0,'Population, intervention, comparator, outcome and post-treatment timepoint are directly represented; the older-adult trial is supplementary.','OES AI-assisted draft — human verification pending',3),
('86100000-0000-0000-0000-000000000070','imprecision','not_serious',0,0,'The published subgroup CI remains entirely favorable and additional trials provide substantial information for direction of effect.','OES AI-assisted draft — human verification pending',4),
('86100000-0000-0000-0000-000000000070','publication_bias','undetected_residual_uncertainty',0,0,'Publication bias was not demonstrated; N2 search is not exhaustive and the Hwang cutoff discrepancy remains a residual uncertainty.','OES AI-assisted draft — human verification pending',5);

-- Risk assessments inform certainty.
INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('86100000-0000-0000-0000-000000000050','86100000-0000-0000-0000-000000000070','risk_assessment_informs_certainty','ROBIS informs GRADE risk-of-bias judgement'),
('86100000-0000-0000-0000-000000000051','86100000-0000-0000-0000-000000000070','risk_assessment_informs_certainty','RoB 2 informs GRADE risk-of-bias judgement'),
('86100000-0000-0000-0000-000000000052','86100000-0000-0000-0000-000000000070','risk_assessment_informs_certainty','RoB 2 informs GRADE risk-of-bias judgement'),
('86100000-0000-0000-0000-000000000053','86100000-0000-0000-0000-000000000070','risk_assessment_informs_certainty','RoB 2 informs GRADE risk-of-bias judgement'),
('86100000-0000-0000-0000-000000000054','86100000-0000-0000-0000-000000000070','risk_assessment_informs_certainty','RoB 2 informs GRADE risk-of-bias judgement'),
('86100000-0000-0000-0000-000000000060','86100000-0000-0000-0000-000000000070','adopted_synthesis_informs_certainty','Published comparator-specific estimate informs OES GRADE'),
('86100000-0000-0000-0000-000000000061','86100000-0000-0000-0000-000000000070','updated_synthesis_informs_certainty','OES narrative update informs OES GRADE');

-- ---------------------------------------------------------------------------
-- PRODUCT — EVIDENCE SHEET PREVIEW
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('86000000-0000-0000-0000-000000000080','OES-P-2026-000401','Product','real-case-01');

INSERT INTO core.entity_version(
 version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note
) VALUES (
 '86100000-0000-0000-0000-000000000080',
 '86000000-0000-0000-0000-000000000080',
 1,'current','real-case-01','initial',
 'Real Case 01 Evidence Sheet preview — human review pending'
);

INSERT INTO product.product(entity_uuid)
VALUES ('86000000-0000-0000-0000-000000000080');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,
 evidence_cutoff_date,publication_date,status,conclusion_text,
 applicability_summary,limitations_summary
) VALUES (
 '86100000-0000-0000-0000-000000000080',
 '86000000-0000-0000-0000-000000000080',
 'evidence_sheet',
 'dCBT-I totalmente automatizada versus educação digital sobre sono para redução da gravidade da insônia em adultos',
 'evidence_observatory_validation',
 DATE '2026-10-04',
 NULL,
 'under_review',
 'A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento, em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos; por isso, a estimativa grande observada na meta-análise comparador-específica não deve ser interpretada como um efeito único e fixo para todas as plataformas e populações.',
 'A evidência é razoavelmente direta para adultos com insônia. Não foi identificado RCT brasileiro diretamente aderente. A transferência científica do efeito é plausível, mas disponibilidade, idioma, regulação, integração assistencial, acesso digital e implementação no SUS não foram formalmente avaliados.',
 'A síntese-base tem discrepância entre cutoff declarado e publicação posterior citada; I2=68% no subgrupo focal; o risco de viés específico dos dez estudos não pôde ser reconstruído integralmente; novos estudos apresentam magnitude variável; não foi realizada nova meta-análise OES; a busca é N2 e não reivindica exaustividade; hit count bruto do PubMed não foi recuperado de forma confiável; segurança é menos sistematicamente caracterizada; não há RCT brasileiro diretamente aderente.'
);

INSERT INTO product.investigation_link(
 product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
 '86100000-0000-0000-0000-000000000080',
 '86100000-0000-0000-0000-000000000002',
 'primary',1
);

INSERT INTO product.synthesis_link(
 product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES
('86100000-0000-0000-0000-000000000080','86100000-0000-0000-0000-000000000060','quantitative_anchor',1),
('86100000-0000-0000-0000-000000000080','86100000-0000-0000-0000-000000000061','primary',2);

INSERT INTO product.certainty_link(
 product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
 '86100000-0000-0000-0000-000000000080',
 '86100000-0000-0000-0000-000000000070',
 'primary',1
);

INSERT INTO product.currency_state(
 currency_state_uuid,product_version_uuid,currency_status,
 assessed_at,assessed_by,rationale,record_status
) VALUES (
 '86500000-0000-0000-0000-000000000080',
 '86100000-0000-0000-0000-000000000080',
 'current',
 TIMESTAMPTZ '2026-10-04 11:30:00-03',
 'OES-development',
 'Search and directed update completed through evidence cutoff 2026-10-04; publication remains blocked pending human review.',
 'active'
);

INSERT INTO product.version_change_class(
 product_version_uuid,change_class,rationale,sequence_no
) VALUES (
 '86100000-0000-0000-0000-000000000080',
 'new_evidence',
 'Initial real-case Evidence Sheet integrates a published quantitative anchor and newer RCT evidence.',
 1
);

-- No approved review_record is inserted deliberately.
-- No publication_date is assigned deliberately.
-- The publication gate MUST remain false.

-- Explicit lineage to Product.
INSERT INTO provenance.dependency_edge(
 source_version_uuid,target_version_uuid,dependency_type,derivation_rule
) VALUES
('86100000-0000-0000-0000-000000000060','86100000-0000-0000-0000-000000000080','synthesis_informs_evidence_sheet','Quantitative anchor linked to Product'),
('86100000-0000-0000-0000-000000000061','86100000-0000-0000-0000-000000000080','synthesis_informs_evidence_sheet','Updated narrative synthesis linked to Product'),
('86100000-0000-0000-0000-000000000070','86100000-0000-0000-0000-000000000080','certainty_informs_evidence_sheet','Provisional GRADE linked to Product');

COMMIT;
