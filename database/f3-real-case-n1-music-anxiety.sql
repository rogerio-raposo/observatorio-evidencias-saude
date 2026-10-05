-- OES Fase 3 — Real N1 Case 01: recorded music and perioperative anxiety
-- Purpose: end-to-end validation of a real Evidence Response N1 before methodological verification/owner approval.
-- Evidence cutoff: 2026-10-05
-- Initial state: under_review / A0 / publication_date NULL.

BEGIN;

-- QUESTION / INVESTIGATION
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('a0000000-0000-0000-0000-000000000001','OES-Q-2026-000501','Question','real-n1-01'),
('a0000000-0000-0000-0000-000000000002','OES-I-2026-000501','Investigation','real-n1-01');

INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note) VALUES
('a1000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001',1,'current','real-n1-01','initial','Real N1-01 question'),
('a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000002',1,'current','real-n1-01','initial','Real N1-01 investigation');

INSERT INTO investigation.question(entity_uuid) VALUES ('a0000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
 version_uuid,entity_uuid,original_text,normalized_text,question_type,structure_type,context_payload,time_horizon_payload
) VALUES (
 'a1000000-0000-0000-0000-000000000001',
 'a0000000-0000-0000-0000-000000000001',
 'Em adultos submetidos a procedimentos cirúrgicos hospitalares, ouvir música gravada no período perioperatório reduz a ansiedade em comparação ao cuidado usual ou ausência de música?',
 'Em adultos submetidos a cirurgia hospitalar, música gravada no período perioperatório, comparada ao cuidado usual ou ausência de música, reduz escores de ansiedade perioperatória?',
 'intervention','PICO',
 '{"population":"adults undergoing hospital surgery","intervention":"recorded perioperative music","comparator":"usual care or no music","primary_outcome":"perioperative anxiety"}'::jsonb,
 '{"perioperative_window":"preoperative, intraoperative, or immediate postoperative as represented in eligible syntheses"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid) VALUES ('a0000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
 version_uuid,entity_uuid,primary_question_entity_uuid,investigation_type,depth_level,maintenance_level,objective,start_date,evidence_cutoff_date,status
) VALUES (
 'a1000000-0000-0000-0000-000000000002',
 'a0000000-0000-0000-0000-000000000002',
 'a0000000-0000-0000-0000-000000000001',
 'focused_evidence_response','N1','M1',
 'Assess what recent systematic syntheses indicate about recorded perioperative music and anxiety without claiming exhaustive evidence retrieval.',
 DATE '2026-10-05',DATE '2026-10-05','active'
);

INSERT INTO investigation.investigation_question(investigation_version_uuid,question_version_uuid,role,sequence_no)
VALUES ('a1000000-0000-0000-0000-000000000002','a1000000-0000-0000-0000-000000000001','primary',1);

-- SEARCHES: structured and selective, not exhaustive.
INSERT INTO investigation.search(
 search_uuid,oes_search_id,investigation_version_uuid,source_name,platform,exact_strategy,filters_payload,executed_at,result_count,strategy_version,operator,status
) VALUES
(
 'a2000000-0000-0000-0000-000000000001','OES-S-2026-000501','a1000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(music intervention OR recorded music OR music therapy) AND (surgery OR perioperative OR preoperative) AND anxiety AND (systematic review OR meta-analysis OR umbrella review)',
 '{"purpose":"recent syntheses","priority_years":"2024-2026","non_exhaustive":true}'::jsonb,
 TIMESTAMPTZ '2026-10-05 14:15:00-03',NULL,'1','OES','completed'
),
(
 'a2000000-0000-0000-0000-000000000002','OES-S-2026-000502','a1000000-0000-0000-0000-000000000002',
 'PubMed/MEDLINE','PubMed',
 '(music intervention OR recorded music) AND (surgery OR perioperative OR preoperative) AND anxiety AND (randomized controlled trial OR randomized OR randomised)',
 '{"purpose":"post-cutoff update","date_from":"2025-04-15","date_to":"2026-10-05","non_exhaustive":true}'::jsonb,
 TIMESTAMPTZ '2026-10-05 14:25:00-03',NULL,'1','OES','completed'
);

-- REPORTS
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('a0000000-0000-0000-0000-000000000201','OES-RP-2026-000501','Report','real-n1-01'),
('a0000000-0000-0000-0000-000000000202','OES-RP-2026-000502','Report','real-n1-01'),
('a0000000-0000-0000-0000-000000000203','OES-RP-2026-000503','Report','real-n1-01'),
('a0000000-0000-0000-0000-000000000204','OES-RP-2026-000504','Report','real-n1-01'),
('a0000000-0000-0000-0000-000000000205','OES-RP-2026-000505','Report','real-n1-01'),
('a0000000-0000-0000-0000-000000000206','OES-RP-2026-000506','Report','real-n1-01'),
('a0000000-0000-0000-0000-000000000207','OES-RP-2026-000507','Report','real-n1-01');

INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note) VALUES
('a1000000-0000-0000-0000-000000000201','a0000000-0000-0000-0000-000000000201',1,'current','real-n1-01','initial','Stoop 2026 systematic review report'),
('a1000000-0000-0000-0000-000000000202','a0000000-0000-0000-0000-000000000202',1,'current','real-n1-01','initial','Yu 2026 systematic review report'),
('a1000000-0000-0000-0000-000000000203','a0000000-0000-0000-0000-000000000203',1,'current','real-n1-01','initial','Yang 2025 umbrella review report'),
('a1000000-0000-0000-0000-000000000204','a0000000-0000-0000-0000-000000000204',1,'current','real-n1-01','initial','Geensen 2025 systematic review report'),
('a1000000-0000-0000-0000-000000000205','a0000000-0000-0000-0000-000000000205',1,'current','real-n1-01','initial','Nouri 2025 randomized trial report'),
('a1000000-0000-0000-0000-000000000206','a0000000-0000-0000-0000-000000000206',1,'current','real-n1-01','initial','Hsieh 2026 randomized trial report'),
('a1000000-0000-0000-0000-000000000207','a0000000-0000-0000-0000-000000000207',1,'current','real-n1-01','initial','Li 2026 randomized trial report');

INSERT INTO evidence.report(entity_uuid) VALUES
('a0000000-0000-0000-0000-000000000201'),('a0000000-0000-0000-0000-000000000202'),
('a0000000-0000-0000-0000-000000000203'),('a0000000-0000-0000-0000-000000000204'),
('a0000000-0000-0000-0000-000000000205'),('a0000000-0000-0000-0000-000000000206'),
('a0000000-0000-0000-0000-000000000207');

INSERT INTO evidence.report_version(
 version_uuid,entity_uuid,report_type,title,publication_date,journal_or_source,language,publication_status,full_text_status,bibliographic_payload,status
) VALUES
(
 'a1000000-0000-0000-0000-000000000201','a0000000-0000-0000-0000-000000000201','systematic_review',
 'The Number Needed to Treat for Music as a Medicine against Perioperative Anxiety: A Systematic Review and Meta-Analysis',
 DATE '2026-04-01','Anesthesia & Analgesia','en','published','available',
 '{"authors":"Stoop JM et al.","pmid":"41294333","pmcid":"PMC12959583","doi":"10.1213/ANE.0000000000007815","prospero":"CRD420250608218","search_cutoff":"2025-04-14"}'::jsonb,'active'
),
(
 'a1000000-0000-0000-0000-000000000202','a0000000-0000-0000-0000-000000000202','systematic_review',
 'Effect of music intervention on anxiety in surgical patients: Systematic review and meta-analysis of randomized controlled trials',
 DATE '2026-03-01','General Hospital Psychiatry','en','published','indexed',
 '{"authors":"Yu Y et al.","pmid":"41547232","doi":"10.1016/j.genhosppsych.2026.01.008","search_cutoff":"2025-07"}'::jsonb,'active'
),
(
 'a1000000-0000-0000-0000-000000000203','a0000000-0000-0000-0000-000000000203','umbrella_review',
 'Music intervention as a strategy to reduce preoperative anxiety: an umbrella review',
 DATE '2025-08-20','BMC Anesthesiology','en','published','available',
 '{"authors":"Yang KL et al.","pmid":"40836211","pmcid":"PMC12366122","doi":"10.1186/s12871-025-03120-z","search_cutoff":"2024-08-22"}'::jsonb,'active'
),
(
 'a1000000-0000-0000-0000-000000000204','a0000000-0000-0000-0000-000000000204','systematic_review',
 'Music interventions in patients undergoing surgery: A systematic review using strict inclusion criteria',
 DATE '2025-09-01','Complementary Therapies in Medicine','en','published','indexed',
 '{"authors":"Geensen R et al.","pmid":"40409738","doi":"10.1016/j.ctim.2025.103195","search_cutoff":"2024-07-05"}'::jsonb,'active'
),
(
 'a1000000-0000-0000-0000-000000000205','a0000000-0000-0000-0000-000000000205','randomized_trial',
 'Effects of traditional vocal and instrumental music on preoperative anxiety in candidates for general surgery',
 DATE '2025-10-09','BMC Complementary Medicine and Therapies','en','published','indexed',
 '{"authors":"Nouri et al.","pmid":"41068753","doi":"10.1186/s12906-025-05124-1"}'::jsonb,'active'
),
(
 'a1000000-0000-0000-0000-000000000206','a0000000-0000-0000-0000-000000000206','randomized_trial',
 'Effectiveness of Music Intervention on Perioperative Anxiety and Physiological Indicators in Orthopedic Surgery Patients: A Pilot Randomized Controlled Trial',
 DATE '2026-02-01','Journal of PeriAnesthesia Nursing','en','published','indexed',
 '{"authors":"Hsieh et al.","pmid":"40838926","doi":"10.1016/j.jopan.2025.05.177"}'::jsonb,'active'
),
(
 'a1000000-0000-0000-0000-000000000207','a0000000-0000-0000-0000-000000000207','randomized_trial',
 'Effects of Music Therapy on Perioperative Anxiety, Physiological Stress, and Postoperative Recovery in Patients Undergoing Knee Arthroscopy: A Randomized Controlled Trial',
 DATE '2026-06-01','Journal of PeriAnesthesia Nursing','en','published','indexed',
 '{"authors":"Li et al.","pmid":"41591321","doi":"10.1016/j.jopan.2025.10.008"}'::jsonb,'active'
);

-- SEARCH HITS AND SELECTIVE SCREENING
INSERT INTO investigation.search_hit(search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,source_record_id,raw_title,raw_year,raw_identifier,source_rank,resolution_status) VALUES
('a2100000-0000-0000-0000-000000000201','OES-HIT-2026-000501','a2000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000201','41294333','Stoop et al. 2026',2026,'PMID:41294333',1,'resolved'),
('a2100000-0000-0000-0000-000000000202','OES-HIT-2026-000502','a2000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000202','41547232','Yu et al. 2026',2026,'PMID:41547232',2,'resolved'),
('a2100000-0000-0000-0000-000000000203','OES-HIT-2026-000503','a2000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000203','40836211','Yang et al. 2025',2025,'PMID:40836211',3,'resolved'),
('a2100000-0000-0000-0000-000000000204','OES-HIT-2026-000504','a2000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000204','40409738','Geensen et al. 2025',2025,'PMID:40409738',4,'resolved'),
('a2100000-0000-0000-0000-000000000205','OES-HIT-2026-000505','a2000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000205','41068753','Nouri et al. 2025',2025,'PMID:41068753',1,'resolved'),
('a2100000-0000-0000-0000-000000000206','OES-HIT-2026-000506','a2000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000206','40838926','Hsieh et al. 2026',2026,'PMID:40838926',2,'resolved'),
('a2100000-0000-0000-0000-000000000207','OES-HIT-2026-000507','a2000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000207','41591321','Li et al. 2026',2026,'PMID:41591321',3,'resolved');

INSERT INTO investigation.screening_decision(screening_uuid,oes_screening_id,investigation_version_uuid,target_entity_uuid,stage,reviewer,decision,decided_at) VALUES
('a2200000-0000-0000-0000-000000000201','OES-SCR-2026-000501','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000201','full_text','OES','include',TIMESTAMPTZ '2026-10-05 14:35:00-03'),
('a2200000-0000-0000-0000-000000000202','OES-SCR-2026-000502','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000202','full_text','OES','include',TIMESTAMPTZ '2026-10-05 14:36:00-03'),
('a2200000-0000-0000-0000-000000000203','OES-SCR-2026-000503','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000203','full_text','OES','include',TIMESTAMPTZ '2026-10-05 14:37:00-03'),
('a2200000-0000-0000-0000-000000000204','OES-SCR-2026-000504','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000204','full_text','OES','include',TIMESTAMPTZ '2026-10-05 14:38:00-03'),
('a2200000-0000-0000-0000-000000000205','OES-SCR-2026-000505','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000205','update_check','OES','include',TIMESTAMPTZ '2026-10-05 14:39:00-03'),
('a2200000-0000-0000-0000-000000000206','OES-SCR-2026-000506','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000206','update_check','OES','include',TIMESTAMPTZ '2026-10-05 14:40:00-03'),
('a2200000-0000-0000-0000-000000000207','OES-SCR-2026-000507','a1000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000207','update_check','OES','include',TIMESTAMPTZ '2026-10-05 14:41:00-03');

-- ROBIS OF DECISIVE REVIEW
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('a0000000-0000-0000-0000-000000000401','OES-RA-2026-000501','RiskAssessment','real-n1-01');

INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('a1000000-0000-0000-0000-000000000401','a0000000-0000-0000-0000-000000000401',1,'current','real-n1-01','initial','ROBIS appraisal of Stoop et al. 2026');

INSERT INTO appraisal.risk_assessment(entity_uuid) VALUES ('a0000000-0000-0000-0000-000000000401');

INSERT INTO appraisal.risk_assessment_version(
 version_uuid,entity_uuid,investigation_version_uuid,framework,framework_version,target_entity_uuid,overall_judgement,assessor,assessment_date,verification_status,instrument_payload,status
) VALUES (
 'a1000000-0000-0000-0000-000000000401','a0000000-0000-0000-0000-000000000401','a1000000-0000-0000-0000-000000000002',
 'ROBIS','2016','a0000000-0000-0000-0000-000000000201','high_risk','OES',DATE '2026-10-05','pending_adversarial_verification',
 '{"relevance":"high","global_rationale":"Strong review process, but primary-trial outcome-measurement bias, possible publication/small-study bias, transformed NNT assumptions, and interpretive overreach materially affect confidence in magnitude."}'::jsonb,'active'
);

INSERT INTO appraisal.risk_assessment_domain(risk_assessment_version_uuid,domain_code,judgement,rationale,supporting_reference,sequence_no) VALUES
('a1000000-0000-0000-0000-000000000401','D1_ELIGIBILITY','low_concern','Eligibility criteria were explicit, prospectively registered and closely matched the OES question; language/date/full-text restrictions remain limitations.','Document 77',1),
('a1000000-0000-0000-0000-000000000401','D2_IDENTIFICATION_SELECTION','low_concern','Six major databases, information-specialist input and duplicate selection support a low-concern judgement despite language and grey-literature limitations.','Document 77',2),
('a1000000-0000-0000-0000-000000000401','D3_DATA_APPRAISAL','low_concern','Duplicate extraction and RoB 2 appraisal were used; primary-study measurement bias remains a limitation of the evidence rather than an obvious failure of review appraisal.','Document 77',3),
('a1000000-0000-0000-0000-000000000401','D4_SYNTHESIS_FINDINGS','high_concern','Magnitude is vulnerable to high-risk outcome measurement, possible publication/small-study bias, transformed-NNT assumptions and overinterpretation beyond direct comparisons.','Document 77',4);

-- PRODUCT: under review, publication date intentionally NULL.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('a0000000-0000-0000-0000-000000000701','OES-P-2026-000501','Product','real-n1-01');

INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('a1000000-0000-0000-0000-000000000701','a0000000-0000-0000-0000-000000000701',1,'current','real-n1-01','initial','Real N1-01 Evidence Response draft');

INSERT INTO product.product(entity_uuid) VALUES ('a0000000-0000-0000-0000-000000000701');

INSERT INTO product.product_version(
 version_uuid,entity_uuid,product_type,title,intended_audience,evidence_cutoff_date,publication_date,status,conclusion_text,applicability_summary,limitations_summary
) VALUES (
 'a1000000-0000-0000-0000-000000000701','a0000000-0000-0000-0000-000000000701','evidence_response',
 'Música gravada no período perioperatório reduz a ansiedade em adultos submetidos a cirurgia?',
 'technical_and_evidence_users',DATE '2026-10-05',NULL,'under_review',
 'Sínteses sistemáticas recentes indicam que ouvir música gravada no período perioperatório reduz, em média, os escores de ansiedade em comparação ao cuidado usual ou ausência de música. Meta-análises de 2026 estimaram efeitos favoráveis de aproximadamente SMD -0,50 a -0,73. A magnitude e a relevância clínica exatas permanecem incertas porque muitos ensaios apresentam limitações metodológicas, as intervenções e contextos são heterogêneos e há sinal de possível viés de publicação em uma das principais meta-análises. Estudos publicados após o cutoff da síntese decisiva mantêm direção geral favorável e não sugerem reversão da conclusão.',
 'A intervenção é não farmacológica e conceitualmente simples, mas protocolos, preferências, timing, anestesia e contexto assistencial variam. Não foi realizada avaliação formal de aplicabilidade ao Brasil/SUS.',
 'Ansiedade predominantemente autorreferida e sem cegamento do participante; risco de viés importante em parte dos ensaios; heterogeneidade clínica; magnitude variável entre sínteses; possível publication/small-study bias; relevância clínica exata incerta; NNT transformado e não diretamente observado; busca OES seletiva e não exaustiva; certainty formal OES não realizada.'
);

INSERT INTO product.investigation_link(product_version_uuid,investigation_version_uuid,role,sequence_no)
VALUES ('a1000000-0000-0000-0000-000000000701','a1000000-0000-0000-0000-000000000002','primary',1);

INSERT INTO product.currency_state(currency_state_uuid,product_version_uuid,currency_status,assessed_at,assessed_by,rationale,record_status)
VALUES ('a2400000-0000-0000-0000-000000000701','a1000000-0000-0000-0000-000000000701','current',TIMESTAMPTZ '2026-10-05 15:00:00-03','OES','Selective update check completed through the N1 evidence cutoff; no rerouting trigger identified.','active');

-- FIELD-LEVEL PROVENANCE
INSERT INTO provenance.record(provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,source_location,source_value,process_type,transformation,actor,status) VALUES
('a5000000-0000-0000-0000-000000000701','a1000000-0000-0000-0000-000000000701','conclusion_text','a1000000-0000-0000-0000-000000000201','Abstract/Results/Discussion','{"direction":"favors_music","smd":-0.73,"ci95":[-0.94,-0.53],"participants":2242}'::jsonb,'critical_adoption_of_external_meta_analysis',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000702','a1000000-0000-0000-0000-000000000701','key_results.0.effect_estimate','a1000000-0000-0000-0000-000000000201','Meta-analysis primary result','{"measure":"SMD","estimate":-0.73,"lower":-0.94,"upper":-0.53,"participants":2242,"role":"decisive"}'::jsonb,'direct_extraction',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000703','a1000000-0000-0000-0000-000000000701','key_results.1.effect_estimate','a1000000-0000-0000-0000-000000000202','Primary meta-analysis after reported outlier handling','{"measure":"SMD","estimate":-0.50,"lower":-0.60,"upper":-0.39,"i2_percent":33.3,"total_rcts":33,"primary_analysis_studies":25,"role":"corroborative"}'::jsonb,'direct_extraction',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000704','a1000000-0000-0000-0000-000000000701','key_results.2.transformed_nnt','a1000000-0000-0000-0000-000000000201','NNT transformation section','{"estimate":3.9,"type":"transformed_from_continuous_effect","direct_binary_event_nnt":false,"role":"contextual"}'::jsonb,'reported_transformation',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000705','a1000000-0000-0000-0000-000000000701','supporting_evidence.umbrella','a1000000-0000-0000-0000-000000000203','Results/quality assessment','{"direction":"favors_music","reviews":6,"primary_studies":40,"amstar2":{"high":1,"moderate":4,"low":1}}'::jsonb,'corroborative_synthesis',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000706','a1000000-0000-0000-0000-000000000701','limitations_summary','a1000000-0000-0000-0000-000000000204','Results/Discussion','{"finding":"overall risk of bias high in included trials; anxiety benefit observed in part of the studies"}'::jsonb,'critical_appraisal_support',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000707','a1000000-0000-0000-0000-000000000701','update.post_cutoff.nouri','a1000000-0000-0000-0000-000000000205','Abstract/Results','{"direction":"favors_music","post_cutoff":true}'::jsonb,'selective_update_check',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000708','a1000000-0000-0000-0000-000000000701','update.post_cutoff.hsieh','a1000000-0000-0000-0000-000000000206','Abstract/Results','{"direction":"favors_music","post_cutoff":true}'::jsonb,'selective_update_check',NULL,'OES','active'),
('a5000000-0000-0000-0000-000000000709','a1000000-0000-0000-0000-000000000701','update.post_cutoff.li','a1000000-0000-0000-0000-000000000207','Abstract/Results','{"direction":"favors_music","post_cutoff":true}'::jsonb,'selective_update_check',NULL,'OES','active');

INSERT INTO provenance.dependency_edge(source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status) VALUES
('a1000000-0000-0000-0000-000000000201','a1000000-0000-0000-0000-000000000701','decisive_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000202','a1000000-0000-0000-0000-000000000701','corroborative_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000203','a1000000-0000-0000-0000-000000000701','umbrella_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000204','a1000000-0000-0000-0000-000000000701','methodological_review_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000205','a1000000-0000-0000-0000-000000000701','post_cutoff_trial_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000206','a1000000-0000-0000-0000-000000000701','post_cutoff_trial_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000207','a1000000-0000-0000-0000-000000000701','post_cutoff_trial_informs_response','provenance.record','active'),
('a1000000-0000-0000-0000-000000000401','a1000000-0000-0000-0000-000000000701','robis_informs_response','ROBIS','active');

COMMIT;