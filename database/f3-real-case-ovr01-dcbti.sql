-- OES Fase 3 — Real Case OVR-01 dCBT-I
-- Developmental Overview of Reviews persistence at assurance A0.
-- Requires baseline + migrations 002–020 + database/f3-real-case-01-dcbti.sql.
-- Authorized by Documents 149, 160 and 161 after CP70.
-- Deliberately non-publishable: no human controls/verification are fabricated.
-- CCA is NOT calculated here; overlap metrics remain database-derived.

BEGIN;

-- ---------------------------------------------------------------------------
-- TRACEABLE PROTOCOL / AMENDMENT / MATRIX / MICRO-GATE ARTIFACTS
-- ---------------------------------------------------------------------------

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,hash_algorithm,
    mime_type,original_filename,source_uri,created_at,created_by,status
) VALUES
('d9900000-0000-0000-0000-000000000001','protocol','docs/products/149-protocolo-developmental-ovr01-dcbti.md','f998cec83d8eb868d2f5050fcabe4f7186edd7b9','git-blob-sha1','text/markdown','149-protocolo-developmental-ovr01-dcbti.md',NULL,TIMESTAMPTZ '2026-10-06 18:00:00-03','oes-real-ovr01','active'),
('d9900000-0000-0000-0000-000000000002','protocol','docs/products/160-emenda-01-protocolo-developmental-ovr01-dcbti.md','bf2e0d0b9b76a0788484c6d0db33a8c899bb356a','git-blob-sha1','text/markdown','160-emenda-01-protocolo-developmental-ovr01-dcbti.md',NULL,TIMESTAMPTZ '2026-10-06 18:01:00-03','oes-real-ovr01','active'),
('d9900000-0000-0000-0000-000000000003','codebook','docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md','85859111fe9d7651715ca7c5ef7e7a421dd43829','git-blob-sha1','text/markdown','155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md',NULL,TIMESTAMPTZ '2026-10-06 18:02:00-03','oes-real-ovr01','active'),
('d9900000-0000-0000-0000-000000000004','protocol','docs/products/161-micro-gate-autorizacao-persistencia-ovr01-dcbti.md','28b1646a9365380c1147a0588b6d716f1300af82','git-blob-sha1','text/markdown','161-micro-gate-autorizacao-persistencia-ovr01-dcbti.md',NULL,TIMESTAMPTZ '2026-10-06 18:03:00-03','oes-real-ovr01','active');

-- ---------------------------------------------------------------------------
-- OVR-01 QUESTION / INVESTIGATION / PRODUCT IDENTITIES
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('d9000000-0000-0000-0000-000000000001','OES-Q-2026-001601','Question','oes-real-ovr01'),
('d9000000-0000-0000-0000-000000000002','OES-I-2026-001601','Investigation','oes-real-ovr01'),
('d9000000-0000-0000-0000-000000000020','OES-P-2026-001601','Product','oes-real-ovr01');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d9100000-0000-0000-0000-000000000001','d9000000-0000-0000-0000-000000000001',1,'current','oes-real-ovr01','initial','OVR-01 developmental review-level question'),
('d9100000-0000-0000-0000-000000000002','d9000000-0000-0000-0000-000000000002',1,'current','oes-real-ovr01','initial','OVR-01 developmental Investigation A0'),
('d9100000-0000-0000-0000-000000000020','d9000000-0000-0000-0000-000000000020',1,'current','oes-real-ovr01','initial','OVR-01 developmental Product A0');

INSERT INTO investigation.question(entity_uuid)
VALUES ('d9000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload,time_horizon_payload
) VALUES (
    'd9100000-0000-0000-0000-000000000001',
    'd9000000-0000-0000-0000-000000000001',
    'O que mostram revisões sistemáticas elegíveis sobre dCBT-I totalmente automatizada para gravidade da insônia em adultos?',
    'Quais são as estimativas review-level de revisões sistemáticas elegíveis sobre dCBT-I totalmente automatizada versus controles elegíveis para gravidade da insônia em adultos, preservando comparadores, overlap de estudos primários, ROBIS, atualidade e proveniência?',
    'effectiveness','PICO',
    '{"population":"adults with insomnia","intervention":"fully automated dCBT-I","comparator":"eligible controls kept stratified","outcome":"insomnia severity","review_level":true,"route":"developmental"}'::jsonb,
    '{"evidence_cutoff":"2026-10-06"}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('d9000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'd9100000-0000-0000-0000-000000000002',
    'd9000000-0000-0000-0000-000000000002',
    'd9000000-0000-0000-0000-000000000001',
    'overview_of_reviews','N3','M0',
    'Developmental internal Overview of Reviews validation for fully automated dCBT-I; preserve review-level estimates and derive overlap from canonical Study-level membership without claiming formal N4 completeness.',
    'd9900000-0000-0000-0000-000000000001',
    DATE '2026-10-06',DATE '2026-10-06','active'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'd9100000-0000-0000-0000-000000000002',
    'd9100000-0000-0000-0000-000000000001','primary',1
);

INSERT INTO artifact.entity_link(artifact_uuid,entity_version_uuid,role,sequence_no)
VALUES (
    'd9900000-0000-0000-0000-000000000001',
    'd9100000-0000-0000-0000-000000000002','protocol',1
);

-- ---------------------------------------------------------------------------
-- DEVELOPMENTAL METHOD POLICIES — NO HUMAN CONTROLS CLAIMED
-- ---------------------------------------------------------------------------

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,decision_type,stage,
    decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
    impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES
('d9200000-0000-0000-0000-000000000001','d9100000-0000-0000-0000-000000000002','other','screening','overview_systematic_review_definition',true,'Analytic ReviewItems must be systematic reviews aligned with the prospectively defined OVR-01 eligibility criteria.',NULL,NULL,'{"required_study_type":"systematic_review","route":"developmental"}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:10:00-03','active'),
('d9200000-0000-0000-0000-000000000002','d9100000-0000-0000-0000-000000000002','other','search','overview_search_coverage_policy',true,'Developmental discovery is structured_non_exhaustive and remains distinct from a formal N4 Overview search.',NULL,NULL,'{"minimum_bibliographic_sources":2,"required_source_classes":["bibliographic_database"],"search_export_required":false,"grey_literature_required":false,"coverage_claim":"structured_non_exhaustive","formal_route_satisfied":false}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:11:00-03','active'),
('d9200000-0000-0000-0000-000000000003','d9100000-0000-0000-0000-000000000002','other','cross_cutting','overview_overlap_policy',true,'Retain all three eligible analytic Reviews and keep review-level estimates separate; primary-study overlap is derived from Study-level membership.',NULL,NULL,'{"strategy":"include_all_separate_estimates","manual_cca":false,"membership_matrix":"Document 155"}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:12:00-03','active'),
('d9200000-0000-0000-0000-000000000004','d9100000-0000-0000-0000-000000000002','other','cross_cutting','overview_currentness_policy',true,'Currentness preserves known search timing without inferring unavailable exact dates.',NULL,NULL,'{"hwang_last_search":"2024-03-31","gao_last_search":null,"gao_status":"unclear","nazari_search_coverage":"through January 2025","nazari_exact_day":null,"date_inference_prohibited":true}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:13:00-03','active'),
('d9200000-0000-0000-0000-000000000005','d9100000-0000-0000-0000-000000000002','other','certainty','overview_certainty_policy',true,'Do not reuse N2 OES GRADE as review-reported certainty; leave certainty absent when not explicitly reported by the Review.',NULL,NULL,'{"hwang":null,"gao":null,"nazari":null,"reuse_n2_grade":false}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:14:00-03','active'),
('d9200000-0000-0000-0000-000000000006','d9100000-0000-0000-0000-000000000002','other','synthesis','overview_reanalysis_policy',true,'No new OES meta-analysis; only traceable review-level estimates are represented.',NULL,NULL,'{"new_meta_analysis":false,"review_level_estimates":"separate","comparator_collapsing":false}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:15:00-03','active'),
('d9200000-0000-0000-0000-000000000007','d9100000-0000-0000-0000-000000000002','other','search','overview_developmental_amendment_01',false,'Amendment 01 permits Gao last_search_date=NULL only on the developmental route while preserving MISSING_LAST_SEARCH_DATE as a publication blocker.',NULL,'{"currentness_status":"unclear","explicit_rationale_required":true}'::jsonb,'{"formal_route_unchanged":true,"publication_blocker_preserved":true}'::jsonb,'accepted','OES_AI_ASSISTED',TIMESTAMPTZ '2026-10-06 19:16:00-03','active');

-- ---------------------------------------------------------------------------
-- STRUCTURED NON-EXHAUSTIVE DISCOVERY TRACE + SCREENING DECISIONS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,executed_at,
    result_count,strategy_version,operator,status
) VALUES (
    'd9400000-0000-0000-0000-000000000001','OES-SRCH-2026-001601',
    'd9100000-0000-0000-0000-000000000002',
    'PubMed/MEDLINE','PubMed',
    '(insomnia[Title/Abstract]) AND ("digital cognitive behavioral therapy"[Title/Abstract] OR "digital cognitive behavioural therapy"[Title/Abstract] OR "internet cognitive behavioral therapy"[Title/Abstract] OR "internet cognitive behavioural therapy"[Title/Abstract] OR dCBT-I[Title/Abstract] OR "fully automated"[Title/Abstract]) AND (systematic review[Publication Type] OR meta-analysis[Publication Type] OR systematic review[Title/Abstract] OR meta-analysis[Title/Abstract])',
    '{"purpose":"developmental review discovery","source_class":"bibliographic_database","coverage_claim":"structured_non_exhaustive"}'::jsonb,
    TIMESTAMPTZ '2026-10-06 17:00:00-03',NULL,'developmental-v1','OES_AI_ASSISTED','completed'
);

-- ---------------------------------------------------------------------------
-- NAZARI REVIEW MATERIALIZATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('d9300000-0000-0000-0000-000000000101','OES-ST-2026-001601','Study','oes-real-ovr01'),
('d9300000-0000-0000-0000-000000000401','OES-RP-2026-001601','Report','oes-real-ovr01'),
('d9300000-0000-0000-0000-000000000501','OES-RS-2026-001601','Result','oes-real-ovr01');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d9310000-0000-0000-0000-000000000101','d9300000-0000-0000-0000-000000000101',1,'current','oes-real-ovr01','initial','Nazari et al. 2025 systematic review'),
('d9310000-0000-0000-0000-000000000401','d9300000-0000-0000-0000-000000000401',1,'current','oes-real-ovr01','initial','Nazari et al. 2025 report'),
('d9310000-0000-0000-0000-000000000501','d9300000-0000-0000-0000-000000000501',1,'current','oes-real-ovr01','initial','Nazari published overall insomnia-severity estimate');

INSERT INTO evidence.study(entity_uuid)
VALUES ('d9300000-0000-0000-0000-000000000101');

INSERT INTO evidence.study_version(
    version_uuid,entity_uuid,study_type,design,title_or_label,sample_size,status
) VALUES (
    'd9310000-0000-0000-0000-000000000101',
    'd9300000-0000-0000-0000-000000000101',
    'systematic_review','systematic_review_meta_analysis',
    'Nazari et al. 2025 — fully automated dCBT-I meta-analysis',
    20118,'active'
);

INSERT INTO evidence.report(entity_uuid)
VALUES ('d9300000-0000-0000-0000-000000000401');

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES (
    'd9310000-0000-0000-0000-000000000401',
    'd9300000-0000-0000-0000-000000000401',
    'journal_article',
    'Effectiveness of Digital Cognitive Behavioral Therapy for Insomnia: A Meta-Analysis of Randomized Controlled Trials',
    NULL,'Iranian Journal of Psychiatry','en','published','available',
    '{"pmid":"41798736","pmcid":"PMC12965280","doi":"10.18502/ijps.v20i4.19689","prospero":"CRD42023455678","year":2025,"volume":20,"issue":4,"pages":"523-544"}'::jsonb,
    'active'
);

INSERT INTO evidence.study_report_link(
    link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
    confidence,reviewer,status
) VALUES (
    'd9320000-0000-0000-0000-000000000401',
    'd9300000-0000-0000-0000-000000000101',
    'd9300000-0000-0000-0000-000000000401',
    'primary_report','confirmed','OES_AI_ASSISTED','active'
);

INSERT INTO evidence.result(entity_uuid,study_entity_uuid)
VALUES (
    'd9300000-0000-0000-0000-000000000501',
    'd9300000-0000-0000-0000-000000000101'
);

INSERT INTO evidence.result_version(
    version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,
    timepoint_label,estimand,measure,reported_value,ci_lower,ci_upper,
    unit,adjusted_flag,analysis_population,method_payload,status
) VALUES (
    'd9310000-0000-0000-0000-000000000501',
    'd9300000-0000-0000-0000-000000000501',
    '80000000-0000-0000-0000-000000000003',
    '{"population":"adults represented in Nazari et al. 2025"}'::jsonb,
    'post-treatment','effect_of_assignment','weighted_mean_difference',
    '{"value":-3.42,"reported_trial_lines":49,"participants":20118,"heterogeneity_i2":98.1,"p":"<0.001"}'::jsonb,
    -4.35,-2.48,'reported scale units',false,'meta-analysis',
    '{"source":"published meta-analysis","recalculated_by_oes":false,"comparator_family":"mixed_multiple_controls","unit_of_analysis_concern":"see OVR-01 ROBIS draft"}'::jsonb,
    'active'
);

INSERT INTO evidence.result_source(
    result_version_uuid,report_version_uuid,source_location,source_type,
    original_text_or_value,is_primary_source,extractor
) VALUES (
    'd9310000-0000-0000-0000-000000000501',
    'd9310000-0000-0000-0000-000000000401',
    'Abstract results + Overall Meta-Analysis Findings / Figure 2',
    'figure',
    '{"wmd":-3.42,"ci95":[-4.35,-2.48],"p":"<0.001","i2":98.1,"reported_trial_lines":49,"n":20118}'::jsonb,
    true,'OES_AI_ASSISTED'
);

INSERT INTO provenance.record(
    provenance_uuid,target_version_uuid,field_path,source_report_version_uuid,
    source_location,source_value,process_type,transformation,actor,status
) VALUES (
    'd9350000-0000-0000-0000-000000000501',
    'd9310000-0000-0000-0000-000000000501',
    'reported_value',
    'd9310000-0000-0000-0000-000000000401',
    'Abstract results + Overall Meta-Analysis Findings / Figure 2',
    '{"wmd":-3.42,"ci95":[-4.35,-2.48],"p":"<0.001","i2":98.1}'::jsonb,
    'structured_extraction',
    '{"recalculated_by_oes":false,"new_meta_analysis":false}'::jsonb,
    'OES_AI_ASSISTED','active'
);

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
    source_record_id,raw_title,raw_year,raw_identifier,resolution_status
) VALUES
('d9410000-0000-0000-0000-000000000001','OES-HIT-2026-001601','d9400000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000201','40075149','Systematic review and meta-analysis on fully automated digital cognitive behavioral therapy for insomnia',2025,'PMID:40075149','resolved'),
('d9410000-0000-0000-0000-000000000002','OES-HIT-2026-001602','d9400000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000202','42240717','Efficacy of fully automated digital cognitive behavioral therapy for insomnia in adults',2026,'PMID:42240717','resolved'),
('d9410000-0000-0000-0000-000000000003','OES-HIT-2026-001603','d9400000-0000-0000-0000-000000000001','d9300000-0000-0000-0000-000000000401','41798736','Effectiveness of Digital Cognitive Behavioral Therapy for Insomnia: A Meta-Analysis of Randomized Controlled Trials',2025,'PMID:41798736','resolved');

INSERT INTO investigation.screening_decision(
    screening_uuid,oes_screening_id,investigation_version_uuid,
    target_entity_uuid,stage,reviewer,decision,exclusion_reason,
    decided_at,adjudication_flag
) VALUES
('d9420000-0000-0000-0000-000000000001','OES-SCR-2026-001601','d9100000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000201','full_text','OES_AI_ASSISTED','include',NULL,TIMESTAMPTZ '2026-10-06 17:30:00-03',false),
('d9420000-0000-0000-0000-000000000002','OES-SCR-2026-001602','d9100000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000202','full_text','OES_AI_ASSISTED','include',NULL,TIMESTAMPTZ '2026-10-06 17:31:00-03',false),
('d9420000-0000-0000-0000-000000000003','OES-SCR-2026-001603','d9100000-0000-0000-0000-000000000002','d9300000-0000-0000-0000-000000000401','full_text','OES_AI_ASSISTED','include',NULL,TIMESTAMPTZ '2026-10-06 17:32:00-03',false);

-- ---------------------------------------------------------------------------
-- 58 NEW PRIMARY STUDY CANDIDATES + REUSE OF EXISTING SWEETMAN 2024
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('d9600000-0000-0000-0000-000000000001','OES-ST-2026-001701','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000002','OES-ST-2026-001702','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000003','OES-ST-2026-001703','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000004','OES-ST-2026-001704','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000005','OES-ST-2026-001705','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000006','OES-ST-2026-001706','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000007','OES-ST-2026-001707','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000008','OES-ST-2026-001708','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000009','OES-ST-2026-001709','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000010','OES-ST-2026-001710','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000011','OES-ST-2026-001711','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000012','OES-ST-2026-001712','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000013','OES-ST-2026-001713','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000014','OES-ST-2026-001714','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000015','OES-ST-2026-001715','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000016','OES-ST-2026-001716','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000017','OES-ST-2026-001717','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000018','OES-ST-2026-001718','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000019','OES-ST-2026-001719','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000020','OES-ST-2026-001720','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000021','OES-ST-2026-001721','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000022','OES-ST-2026-001722','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000023','OES-ST-2026-001723','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000024','OES-ST-2026-001724','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000025','OES-ST-2026-001725','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000026','OES-ST-2026-001726','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000027','OES-ST-2026-001727','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000028','OES-ST-2026-001728','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000029','OES-ST-2026-001729','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000030','OES-ST-2026-001730','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000031','OES-ST-2026-001731','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000032','OES-ST-2026-001732','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000033','OES-ST-2026-001733','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000034','OES-ST-2026-001734','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000035','OES-ST-2026-001735','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000036','OES-ST-2026-001736','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000037','OES-ST-2026-001737','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000038','OES-ST-2026-001738','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000039','OES-ST-2026-001739','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000040','OES-ST-2026-001740','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000041','OES-ST-2026-001741','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000042','OES-ST-2026-001742','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000043','OES-ST-2026-001743','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000044','OES-ST-2026-001744','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000045','OES-ST-2026-001745','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000046','OES-ST-2026-001746','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000047','OES-ST-2026-001747','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000048','OES-ST-2026-001748','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000049','OES-ST-2026-001749','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000050','OES-ST-2026-001750','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000051','OES-ST-2026-001751','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000052','OES-ST-2026-001752','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000053','OES-ST-2026-001753','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000054','OES-ST-2026-001754','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000055','OES-ST-2026-001755','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000056','OES-ST-2026-001756','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000057','OES-ST-2026-001757','Study','oes-real-ovr01'),
('d9600000-0000-0000-0000-000000000058','OES-ST-2026-001758','Study','oes-real-ovr01');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d9610000-0000-0000-0000-000000000001','d9600000-0000-0000-0000-000000000001',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Behrendt-2020'),
('d9610000-0000-0000-0000-000000000002','d9600000-0000-0000-0000-000000000002',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Bernstein-2017'),
('d9610000-0000-0000-0000-000000000003','d9600000-0000-0000-0000-000000000003',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Chan-CS-2023'),
('d9610000-0000-0000-0000-000000000004','d9600000-0000-0000-0000-000000000004',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Chan-GAO-2025'),
('d9610000-0000-0000-0000-000000000005','d9600000-0000-0000-0000-000000000005',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Chan-WS-2024'),
('d9610000-0000-0000-0000-000000000006','d9600000-0000-0000-0000-000000000006',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate DIALS'),
('d9610000-0000-0000-0000-000000000007','d9600000-0000-0000-0000-000000000007',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Denis-2019'),
('d9610000-0000-0000-0000-000000000008','d9600000-0000-0000-0000-000000000008',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Ebert-2015'),
('d9610000-0000-0000-0000-000000000009','d9600000-0000-0000-0000-000000000009',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Eigl-2023'),
('d9610000-0000-0000-0000-000000000010','d9600000-0000-0000-0000-000000000010',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Espie-2012'),
('d9610000-0000-0000-0000-000000000011','d9600000-0000-0000-0000-000000000011',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Fleming-2024'),
('d9610000-0000-0000-0000-000000000012','d9600000-0000-0000-0000-000000000012',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Freeman-2017'),
('d9610000-0000-0000-0000-000000000013','d9600000-0000-0000-0000-000000000013',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Glozier-2019'),
('d9610000-0000-0000-0000-000000000014','d9600000-0000-0000-0000-000000000014',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Godzik-2021'),
('d9610000-0000-0000-0000-000000000015','d9600000-0000-0000-0000-000000000015',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate GoodNight'),
('d9610000-0000-0000-0000-000000000016','d9600000-0000-0000-0000-000000000016',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Hagatun-2019'),
('d9610000-0000-0000-0000-000000000017','d9600000-0000-0000-0000-000000000017',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Hinterberger-2024'),
('d9610000-0000-0000-0000-000000000018','d9600000-0000-0000-0000-000000000018',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Ho-2022'),
('d9610000-0000-0000-0000-000000000019','d9600000-0000-0000-0000-000000000019',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Holmqvist-2014'),
('d9610000-0000-0000-0000-000000000020','d9600000-0000-0000-0000-000000000020',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Horsch-2017'),
('d9610000-0000-0000-0000-000000000021','d9600000-0000-0000-0000-000000000021',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Hurlimann-2023'),
('d9610000-0000-0000-0000-000000000022','d9600000-0000-0000-0000-000000000022',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Kallestad-2021'),
('d9610000-0000-0000-0000-000000000023','d9600000-0000-0000-0000-000000000023',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Kalmbach-2020'),
('d9610000-0000-0000-0000-000000000024','d9600000-0000-0000-0000-000000000024',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Kyle-DISCO-2020'),
('d9610000-0000-0000-0000-000000000025','d9600000-0000-0000-0000-000000000025',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Lancee-2012'),
('d9610000-0000-0000-0000-000000000026','d9600000-0000-0000-0000-000000000026',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Lancee-2013'),
('d9610000-0000-0000-0000-000000000027','d9600000-0000-0000-0000-000000000027',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Li-2022'),
('d9610000-0000-0000-0000-000000000028','d9600000-0000-0000-0000-000000000028',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Lopez-2019'),
('d9610000-0000-0000-0000-000000000029','d9600000-0000-0000-0000-000000000029',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Lorenz-2018'),
('d9610000-0000-0000-0000-000000000030','d9600000-0000-0000-0000-000000000030',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Mason-2023'),
('d9610000-0000-0000-0000-000000000031','d9600000-0000-0000-0000-000000000031',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Maurer-2024'),
('d9610000-0000-0000-0000-000000000032','d9600000-0000-0000-0000-000000000032',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate McGrath-2017'),
('d9610000-0000-0000-0000-000000000033','d9600000-0000-0000-0000-000000000033',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Nazem-2023'),
('d9610000-0000-0000-0000-000000000034','d9600000-0000-0000-0000-000000000034',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Pillai-2015'),
('d9610000-0000-0000-0000-000000000035','d9600000-0000-0000-0000-000000000035',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate REST'),
('d9610000-0000-0000-0000-000000000036','d9600000-0000-0000-0000-000000000036',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate RajabiMajd-2020'),
('d9610000-0000-0000-0000-000000000037','d9600000-0000-0000-0000-000000000037',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Ramfjord-2023'),
('d9610000-0000-0000-0000-000000000038','d9600000-0000-0000-0000-000000000038',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Ritterband-2009'),
('d9610000-0000-0000-0000-000000000039','d9600000-0000-0000-0000-000000000039',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Ritterband-2011'),
('d9610000-0000-0000-0000-000000000040','d9600000-0000-0000-0000-000000000040',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Ritterband-2017'),
('d9610000-0000-0000-0000-000000000041','d9600000-0000-0000-0000-000000000041',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Rotger-2024'),
('d9610000-0000-0000-0000-000000000042','d9600000-0000-0000-0000-000000000042',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate SPREAD'),
('d9610000-0000-0000-0000-000000000043','d9600000-0000-0000-0000-000000000043',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Sato-2022'),
('d9610000-0000-0000-0000-000000000044','d9600000-0000-0000-0000-000000000044',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Shimamoto-2022'),
('d9610000-0000-0000-0000-000000000045','d9600000-0000-0000-0000-000000000045',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Shin-2024'),
('d9610000-0000-0000-0000-000000000046','d9600000-0000-0000-0000-000000000046',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Short-2019'),
('d9610000-0000-0000-0000-000000000047','d9600000-0000-0000-0000-000000000047',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Spanhel-2022'),
('d9610000-0000-0000-0000-000000000048','d9600000-0000-0000-0000-000000000048',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Specht-2025'),
('d9610000-0000-0000-0000-000000000049','d9600000-0000-0000-0000-000000000049',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Starling-2024'),
('d9610000-0000-0000-0000-000000000050','d9600000-0000-0000-0000-000000000050',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Taylor-2017'),
('d9610000-0000-0000-0000-000000000051','d9600000-0000-0000-0000-000000000051',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Theadom-2018'),
('d9610000-0000-0000-0000-000000000052','d9600000-0000-0000-0000-000000000052',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Vedaa-2020'),
('d9610000-0000-0000-0000-000000000053','d9600000-0000-0000-0000-000000000053',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Watanabe-2023'),
('d9610000-0000-0000-0000-000000000054','d9600000-0000-0000-0000-000000000054',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Wu-2024'),
('d9610000-0000-0000-0000-000000000055','d9600000-0000-0000-0000-000000000055',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Yang-2023'),
('d9610000-0000-0000-0000-000000000056','d9600000-0000-0000-0000-000000000056',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Zachariae-2018'),
('d9610000-0000-0000-0000-000000000057','d9600000-0000-0000-0000-000000000057',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Zhang-2023'),
('d9610000-0000-0000-0000-000000000058','d9600000-0000-0000-0000-000000000058',1,'current','oes-real-ovr01','initial','OVR-01 primary Study candidate Zhou-2022');

INSERT INTO evidence.study(entity_uuid) VALUES
('d9600000-0000-0000-0000-000000000001'),
('d9600000-0000-0000-0000-000000000002'),
('d9600000-0000-0000-0000-000000000003'),
('d9600000-0000-0000-0000-000000000004'),
('d9600000-0000-0000-0000-000000000005'),
('d9600000-0000-0000-0000-000000000006'),
('d9600000-0000-0000-0000-000000000007'),
('d9600000-0000-0000-0000-000000000008'),
('d9600000-0000-0000-0000-000000000009'),
('d9600000-0000-0000-0000-000000000010'),
('d9600000-0000-0000-0000-000000000011'),
('d9600000-0000-0000-0000-000000000012'),
('d9600000-0000-0000-0000-000000000013'),
('d9600000-0000-0000-0000-000000000014'),
('d9600000-0000-0000-0000-000000000015'),
('d9600000-0000-0000-0000-000000000016'),
('d9600000-0000-0000-0000-000000000017'),
('d9600000-0000-0000-0000-000000000018'),
('d9600000-0000-0000-0000-000000000019'),
('d9600000-0000-0000-0000-000000000020'),
('d9600000-0000-0000-0000-000000000021'),
('d9600000-0000-0000-0000-000000000022'),
('d9600000-0000-0000-0000-000000000023'),
('d9600000-0000-0000-0000-000000000024'),
('d9600000-0000-0000-0000-000000000025'),
('d9600000-0000-0000-0000-000000000026'),
('d9600000-0000-0000-0000-000000000027'),
('d9600000-0000-0000-0000-000000000028'),
('d9600000-0000-0000-0000-000000000029'),
('d9600000-0000-0000-0000-000000000030'),
('d9600000-0000-0000-0000-000000000031'),
('d9600000-0000-0000-0000-000000000032'),
('d9600000-0000-0000-0000-000000000033'),
('d9600000-0000-0000-0000-000000000034'),
('d9600000-0000-0000-0000-000000000035'),
('d9600000-0000-0000-0000-000000000036'),
('d9600000-0000-0000-0000-000000000037'),
('d9600000-0000-0000-0000-000000000038'),
('d9600000-0000-0000-0000-000000000039'),
('d9600000-0000-0000-0000-000000000040'),
('d9600000-0000-0000-0000-000000000041'),
('d9600000-0000-0000-0000-000000000042'),
('d9600000-0000-0000-0000-000000000043'),
('d9600000-0000-0000-0000-000000000044'),
('d9600000-0000-0000-0000-000000000045'),
('d9600000-0000-0000-0000-000000000046'),
('d9600000-0000-0000-0000-000000000047'),
('d9600000-0000-0000-0000-000000000048'),
('d9600000-0000-0000-0000-000000000049'),
('d9600000-0000-0000-0000-000000000050'),
('d9600000-0000-0000-0000-000000000051'),
('d9600000-0000-0000-0000-000000000052'),
('d9600000-0000-0000-0000-000000000053'),
('d9600000-0000-0000-0000-000000000054'),
('d9600000-0000-0000-0000-000000000055'),
('d9600000-0000-0000-0000-000000000056'),
('d9600000-0000-0000-0000-000000000057'),
('d9600000-0000-0000-0000-000000000058');

INSERT INTO evidence.study_version(
    version_uuid,entity_uuid,study_type,design,title_or_label,sample_size,status
) VALUES
('d9610000-0000-0000-0000-000000000001','d9600000-0000-0000-0000-000000000001','primary_study','randomized_trial','Behrendt-2020',NULL,'active'),
('d9610000-0000-0000-0000-000000000002','d9600000-0000-0000-0000-000000000002','primary_study','randomized_trial','Bernstein-2017',NULL,'active'),
('d9610000-0000-0000-0000-000000000003','d9600000-0000-0000-0000-000000000003','primary_study','randomized_trial','Chan-CS-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000004','d9600000-0000-0000-0000-000000000004','primary_study','randomized_trial','Chan-GAO-2025',NULL,'active'),
('d9610000-0000-0000-0000-000000000005','d9600000-0000-0000-0000-000000000005','primary_study','randomized_trial','Chan-WS-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000006','d9600000-0000-0000-0000-000000000006','primary_study','randomized_trial','DIALS',NULL,'active'),
('d9610000-0000-0000-0000-000000000007','d9600000-0000-0000-0000-000000000007','primary_study','randomized_trial','Denis-2019',NULL,'active'),
('d9610000-0000-0000-0000-000000000008','d9600000-0000-0000-0000-000000000008','primary_study','randomized_trial','Ebert-2015',NULL,'active'),
('d9610000-0000-0000-0000-000000000009','d9600000-0000-0000-0000-000000000009','primary_study','randomized_trial','Eigl-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000010','d9600000-0000-0000-0000-000000000010','primary_study','randomized_trial','Espie-2012',NULL,'active'),
('d9610000-0000-0000-0000-000000000011','d9600000-0000-0000-0000-000000000011','primary_study','randomized_trial','Fleming-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000012','d9600000-0000-0000-0000-000000000012','primary_study','randomized_trial','Freeman-2017',NULL,'active'),
('d9610000-0000-0000-0000-000000000013','d9600000-0000-0000-0000-000000000013','primary_study','randomized_trial','Glozier-2019',NULL,'active'),
('d9610000-0000-0000-0000-000000000014','d9600000-0000-0000-0000-000000000014','primary_study','randomized_trial','Godzik-2021',NULL,'active'),
('d9610000-0000-0000-0000-000000000015','d9600000-0000-0000-0000-000000000015','primary_study','randomized_trial','GoodNight',NULL,'active'),
('d9610000-0000-0000-0000-000000000016','d9600000-0000-0000-0000-000000000016','primary_study','randomized_trial','Hagatun-2019',NULL,'active'),
('d9610000-0000-0000-0000-000000000017','d9600000-0000-0000-0000-000000000017','primary_study','randomized_trial','Hinterberger-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000018','d9600000-0000-0000-0000-000000000018','primary_study','randomized_trial','Ho-2022',NULL,'active'),
('d9610000-0000-0000-0000-000000000019','d9600000-0000-0000-0000-000000000019','primary_study','randomized_trial','Holmqvist-2014',NULL,'active'),
('d9610000-0000-0000-0000-000000000020','d9600000-0000-0000-0000-000000000020','primary_study','randomized_trial','Horsch-2017',NULL,'active'),
('d9610000-0000-0000-0000-000000000021','d9600000-0000-0000-0000-000000000021','primary_study','randomized_trial','Hurlimann-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000022','d9600000-0000-0000-0000-000000000022','primary_study','randomized_trial','Kallestad-2021',NULL,'active'),
('d9610000-0000-0000-0000-000000000023','d9600000-0000-0000-0000-000000000023','primary_study','randomized_trial','Kalmbach-2020',NULL,'active'),
('d9610000-0000-0000-0000-000000000024','d9600000-0000-0000-0000-000000000024','primary_study','randomized_trial','Kyle-DISCO-2020',NULL,'active'),
('d9610000-0000-0000-0000-000000000025','d9600000-0000-0000-0000-000000000025','primary_study','randomized_trial','Lancee-2012',NULL,'active'),
('d9610000-0000-0000-0000-000000000026','d9600000-0000-0000-0000-000000000026','primary_study','randomized_trial','Lancee-2013',NULL,'active'),
('d9610000-0000-0000-0000-000000000027','d9600000-0000-0000-0000-000000000027','primary_study','randomized_trial','Li-2022',NULL,'active'),
('d9610000-0000-0000-0000-000000000028','d9600000-0000-0000-0000-000000000028','primary_study','randomized_trial','Lopez-2019',NULL,'active'),
('d9610000-0000-0000-0000-000000000029','d9600000-0000-0000-0000-000000000029','primary_study','randomized_trial','Lorenz-2018',NULL,'active'),
('d9610000-0000-0000-0000-000000000030','d9600000-0000-0000-0000-000000000030','primary_study','randomized_trial','Mason-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000031','d9600000-0000-0000-0000-000000000031','primary_study','randomized_trial','Maurer-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000032','d9600000-0000-0000-0000-000000000032','primary_study','randomized_trial','McGrath-2017',NULL,'active'),
('d9610000-0000-0000-0000-000000000033','d9600000-0000-0000-0000-000000000033','primary_study','randomized_trial','Nazem-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000034','d9600000-0000-0000-0000-000000000034','primary_study','randomized_trial','Pillai-2015',NULL,'active'),
('d9610000-0000-0000-0000-000000000035','d9600000-0000-0000-0000-000000000035','primary_study','randomized_trial','REST',NULL,'active'),
('d9610000-0000-0000-0000-000000000036','d9600000-0000-0000-0000-000000000036','primary_study','randomized_trial','RajabiMajd-2020',NULL,'active'),
('d9610000-0000-0000-0000-000000000037','d9600000-0000-0000-0000-000000000037','primary_study','randomized_trial','Ramfjord-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000038','d9600000-0000-0000-0000-000000000038','primary_study','randomized_trial','Ritterband-2009',NULL,'active'),
('d9610000-0000-0000-0000-000000000039','d9600000-0000-0000-0000-000000000039','primary_study','randomized_trial','Ritterband-2011',NULL,'active'),
('d9610000-0000-0000-0000-000000000040','d9600000-0000-0000-0000-000000000040','primary_study','randomized_trial','Ritterband-2017',NULL,'active'),
('d9610000-0000-0000-0000-000000000041','d9600000-0000-0000-0000-000000000041','primary_study','randomized_trial','Rotger-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000042','d9600000-0000-0000-0000-000000000042','primary_study','randomized_trial','SPREAD',NULL,'active'),
('d9610000-0000-0000-0000-000000000043','d9600000-0000-0000-0000-000000000043','primary_study','randomized_trial','Sato-2022',NULL,'active'),
('d9610000-0000-0000-0000-000000000044','d9600000-0000-0000-0000-000000000044','primary_study','randomized_trial','Shimamoto-2022',NULL,'active'),
('d9610000-0000-0000-0000-000000000045','d9600000-0000-0000-0000-000000000045','primary_study','randomized_trial','Shin-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000046','d9600000-0000-0000-0000-000000000046','primary_study','randomized_trial','Short-2019',NULL,'active'),
('d9610000-0000-0000-0000-000000000047','d9600000-0000-0000-0000-000000000047','primary_study','randomized_trial','Spanhel-2022',NULL,'active'),
('d9610000-0000-0000-0000-000000000048','d9600000-0000-0000-0000-000000000048','primary_study','randomized_trial','Specht-2025',NULL,'active'),
('d9610000-0000-0000-0000-000000000049','d9600000-0000-0000-0000-000000000049','primary_study','randomized_trial','Starling-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000050','d9600000-0000-0000-0000-000000000050','primary_study','randomized_trial','Taylor-2017',NULL,'active'),
('d9610000-0000-0000-0000-000000000051','d9600000-0000-0000-0000-000000000051','primary_study','randomized_trial','Theadom-2018',NULL,'active'),
('d9610000-0000-0000-0000-000000000052','d9600000-0000-0000-0000-000000000052','primary_study','randomized_trial','Vedaa-2020',NULL,'active'),
('d9610000-0000-0000-0000-000000000053','d9600000-0000-0000-0000-000000000053','primary_study','randomized_trial','Watanabe-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000054','d9600000-0000-0000-0000-000000000054','primary_study','randomized_trial','Wu-2024',NULL,'active'),
('d9610000-0000-0000-0000-000000000055','d9600000-0000-0000-0000-000000000055','primary_study','randomized_trial','Yang-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000056','d9600000-0000-0000-0000-000000000056','primary_study','randomized_trial','Zachariae-2018',NULL,'active'),
('d9610000-0000-0000-0000-000000000057','d9600000-0000-0000-0000-000000000057','primary_study','randomized_trial','Zhang-2023',NULL,'active'),
('d9610000-0000-0000-0000-000000000058','d9600000-0000-0000-0000-000000000058','primary_study','randomized_trial','Zhou-2022',NULL,'active');

-- ---------------------------------------------------------------------------
-- REVIEW ITEMS — STRUCTURAL COMPLETENESS, NO HUMAN VERIFICATION
-- ---------------------------------------------------------------------------

INSERT INTO overview.review_item(
    review_item_uuid,investigation_version_uuid,review_study_version_uuid,
    item_role,eligibility_basis_payload,last_search_date,
    membership_completeness,currentness_status,currentness_rationale,
    included_at,status
) VALUES
('d9500000-0000-0000-0000-000000000101','d9100000-0000-0000-0000-000000000002','81000000-0000-0000-0000-000000000101','primary','{"review":"Hwang 2025","eligibility":"Document 150 C4 PASS","route":"developmental"}'::jsonb,DATE '2024-03-31','complete','possibly_outdated','Last search 2024-03-31 predates the 2026-10-06 OVR-01 evidence cutoff; retained with explicit currentness caution.',TIMESTAMPTZ '2026-10-06 19:18:00-03','active'),
('d9500000-0000-0000-0000-000000000102','d9100000-0000-0000-0000-000000000002','81000000-0000-0000-0000-000000000102','primary','{"review":"Gao 2026","eligibility":"Document 150 C4 PASS","route":"developmental","amendment":"Document 160"}'::jsonb,NULL,'complete','unclear','Exact last-search date is not verifiable in accessible sources; no date is inferred. Developmental Amendment 01 preserves MISSING_LAST_SEARCH_DATE as a publication blocker.',TIMESTAMPTZ '2026-10-06 19:18:00-03','active'),
('d9500000-0000-0000-0000-000000000103','d9100000-0000-0000-0000-000000000002','d9310000-0000-0000-0000-000000000101','primary','{"review":"Nazari 2025","eligibility":"Document 150 C3/C4 PASS","route":"developmental","search_precision":"month_only"}'::jsonb,NULL,'complete','unclear','The report states coverage through January 2025 but does not provide an exact search day in the canonical preparation; no day-level date is inferred.',TIMESTAMPTZ '2026-10-06 19:18:00-03','active');

-- ---------------------------------------------------------------------------
-- CANONICAL REVIEW x PRIMARY STUDY MEMBERSHIP — 86 OCCURRENCES / 59 STUDIES
-- ---------------------------------------------------------------------------

INSERT INTO overview.primary_study_membership(
    membership_uuid,review_item_uuid,primary_study_entity_uuid,
    source_report_version_uuid,source_location,identity_confidence,
    verification_status,verified_by,verifier_actor_type,verified_at,
    context_payload,status
) VALUES
('d9510000-0000-0000-0000-000000000001','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000001','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-behrendt-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000002','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000001','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-behrendt-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000003','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000002','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-bernstein-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000004','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000002','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-bernstein-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000005','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000003','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-chan-cs-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000006','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000004','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-chan-gao-2025","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000007','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000005','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-chan-ws-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000008','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000006','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-dials","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"confirmed multiple-report cluster; ISRCTN60530898","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000009','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000006','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-dials","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"confirmed multiple-report cluster; ISRCTN60530898","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000010','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000007','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-denis-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000011','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000008','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ebert-2015","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000012','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000009','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-eigl-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"distinct randomization verified against Hinterberger 2024","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000013','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000010','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-espie-2012","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000014','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000011','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-fleming-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000015','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000012','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-freeman-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000016','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000013','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-glozier-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2018/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000017','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000013','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-glozier-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2018/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000018','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000014','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-godzik-2021","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000019','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000015','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-goodnight","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"same-trial registry ACTRN12611000121965","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000020','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000015','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-goodnight","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"same-trial registry ACTRN12611000121965","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000021','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000016','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-hagatun-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2017/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000022','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000016','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-hagatun-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2017/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000023','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000017','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-hinterberger-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"distinct randomization and DOI verified","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000024','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000017','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-hinterberger-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"distinct randomization and DOI verified","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000025','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000017','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-hinterberger-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"distinct randomization and DOI verified","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000026','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000018','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ho-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000027','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000019','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-holmqvist-2014","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000028','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000020','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-horsch-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000029','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000020','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-horsch-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000030','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000021','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-hurlimann-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000031','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000022','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-kallestad-2021","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000032','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000022','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-kallestad-2021","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000033','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000023','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-kalmbach-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000034','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000023','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-kalmbach-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000035','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000024','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-kyle-disco-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000036','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000024','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-kyle-disco-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000037','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000025','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lancee-2012","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000038','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000025','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lancee-2012","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000039','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000026','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lancee-2013","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000040','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000027','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-li-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000041','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000028','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lopez-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000042','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000029','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lorenz-2018","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2018/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000043','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000029','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lorenz-2018","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2018/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000044','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000029','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-lorenz-2018","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2018/2019 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000045','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000030','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-mason-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000046','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000031','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-maurer-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2024/2025 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000047','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000031','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-maurer-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"2024/2025 bibliographic alias resolved by DOI","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000048','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000032','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-mcgrath-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000049','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000033','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-nazem-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000050','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000034','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-pillai-2015","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000051','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000035','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-rest","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"confirmed multiple-report cluster; NCT02805998","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000052','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000035','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-rest","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"confirmed multiple-report cluster; NCT02805998","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000053','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000036','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-rajabimajd-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000054','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000037','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ramfjord-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000055','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000038','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2009","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000056','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000038','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2009","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000057','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000038','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2009","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000058','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000039','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2011","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000059','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000040','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"Ritterband 2017 / Shaffer 2020 confirmed same trial; NCT01438697","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000060','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000040','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"Ritterband 2017 / Shaffer 2020 confirmed same trial; NCT01438697","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000061','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000040','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-ritterband-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"Ritterband 2017 / Shaffer 2020 confirmed same trial; NCT01438697","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000062','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000041','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-rotger-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000063','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000042','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-spread","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"confirmed multiple-report cluster; NCT02988375","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000064','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000042','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','high','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-spread","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"confirmed multiple-report cluster; NCT02988375","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000065','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000043','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-sato-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000066','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000044','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-shimamoto-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000067','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000045','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-shin-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000068','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000046','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-short-2019","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000069','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000047','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-spanhel-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000070','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000048','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-specht-2025","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000071','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000049','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-starling-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000072','d9500000-0000-0000-0000-000000000103','80000000-0000-0000-0000-000000000103','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-sweetman-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000073','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000050','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-taylor-2017","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000074','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000051','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-theadom-2018","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000075','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000052','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-vedaa-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000076','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000052','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-vedaa-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000077','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000052','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-vedaa-2020","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000078','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000053','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-watanabe-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000079','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000053','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-watanabe-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000080','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000054','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-wu-2024","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000081','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000055','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-yang-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000082','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000056','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-zachariae-2018","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000083','d9500000-0000-0000-0000-000000000102','d9600000-0000-0000-0000-000000000057','81000000-0000-0000-0000-000000000202','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-zhang-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000084','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000057','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-zhang-2023","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000085','d9500000-0000-0000-0000-000000000101','d9600000-0000-0000-0000-000000000058','81000000-0000-0000-0000-000000000201','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-zhou-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active'),
('d9510000-0000-0000-0000-000000000086','d9500000-0000-0000-0000-000000000103','d9600000-0000-0000-0000-000000000058','d9310000-0000-0000-0000-000000000401','Document 155 canonical Review x primary Study matrix','medium','unverified',NULL,NULL,NULL,'{"candidate_key":"OVR01-PS-zhou-2022","matrix_document":"docs/products/155-matriz-canonica-preparatoria-c5-c6-ovr01-dcbti.md","identity_basis":"canonical Document 155 reconciliation; no decisive registry identifier encoded in this persistence payload","ai_assisted":true,"human_verified":false}'::jsonb,'active');

-- ---------------------------------------------------------------------------
-- OVERLAP CLUSTER / RESOLUTION — NO MANUAL CCA
-- ---------------------------------------------------------------------------

INSERT INTO overview.review_cluster(
    cluster_uuid,investigation_version_uuid,cluster_code,label,
    scope_payload,status
) VALUES (
    'd9520000-0000-0000-0000-000000000001',
    'd9100000-0000-0000-0000-000000000002',
    'fully_automated_dcbti_insomnia_severity_adults',
    'Fully automated dCBT-I — insomnia severity in adults',
    '{"population":"adults","intervention":"fully automated dCBT-I","outcome":"insomnia severity","comparator_policy":"preserve review-level comparator families","overlap_unit":"primary Study"}'::jsonb,
    'active'
);

INSERT INTO overview.cluster_membership(
    cluster_uuid,review_item_uuid,analysis_disposition,rationale,
    sequence_no,status
) VALUES
('d9520000-0000-0000-0000-000000000001','d9500000-0000-0000-0000-000000000101','retained','Eligible analytic Review; estimate retained separately under protocol comparator policy.',1,'active'),
('d9520000-0000-0000-0000-000000000001','d9500000-0000-0000-0000-000000000102','retained','Eligible analytic Review; mixed-control estimate retained separately and not collapsed with Hwang.',2,'active'),
('d9520000-0000-0000-0000-000000000001','d9500000-0000-0000-0000-000000000103','retained','Eligible analytic Review; mixed-control estimate retained separately with ROBIS unit-of-analysis concern.',3,'active');

INSERT INTO overview.overlap_resolution(
    overlap_resolution_uuid,cluster_uuid,strategy,decision_payload,rationale,
    decided_by,actor_type,verification_status,verified_by,
    verifier_actor_type,verified_at,decided_at,status
) VALUES (
    'd9530000-0000-0000-0000-000000000001',
    'd9520000-0000-0000-0000-000000000001',
    'include_all_separate_estimates',
    '{"manual_cca":false,"membership_source":"Document 155","comparator_collapsing":false,"human_overlap_verification":false}'::jsonb,
    'All eligible Reviews remain visible; estimates are not pooled by OES and overlap metrics must be derived by overview.overlap_metrics from persisted Study-level membership.',
    'OES_AI_ASSISTED','ai_system','unverified',NULL,NULL,NULL,
    TIMESTAMPTZ '2026-10-06 19:19:00-03','active'
);

-- ---------------------------------------------------------------------------
-- OVR-SCOPED ROBIS DRAFTS — AI-ONLY / UNVERIFIED
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('d9300000-0000-0000-0000-000000000701','OES-RA-2026-001601','RiskAssessment','oes-real-ovr01'),
('d9300000-0000-0000-0000-000000000702','OES-RA-2026-001602','RiskAssessment','oes-real-ovr01'),
('d9300000-0000-0000-0000-000000000703','OES-RA-2026-001603','RiskAssessment','oes-real-ovr01');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d9310000-0000-0000-0000-000000000701','d9300000-0000-0000-0000-000000000701',1,'current','oes-real-ovr01','initial','OVR-01 Hwang ROBIS draft scoped to OVR Investigation'),
('d9310000-0000-0000-0000-000000000702','d9300000-0000-0000-0000-000000000702',1,'current','oes-real-ovr01','initial','OVR-01 Gao ROBIS preparatory draft'),
('d9310000-0000-0000-0000-000000000703','d9300000-0000-0000-0000-000000000703',1,'current','oes-real-ovr01','initial','OVR-01 Nazari ROBIS preparatory draft');

INSERT INTO appraisal.risk_assessment(entity_uuid) VALUES
('d9300000-0000-0000-0000-000000000701'),
('d9300000-0000-0000-0000-000000000702'),
('d9300000-0000-0000-0000-000000000703');

INSERT INTO appraisal.risk_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,framework,
    framework_version,target_entity_uuid,outcome_entity_uuid,
    overall_judgement,assessor,assessment_date,verification_status,
    instrument_payload,status
) VALUES
('d9310000-0000-0000-0000-000000000701','d9300000-0000-0000-0000-000000000701','d9100000-0000-0000-0000-000000000002','ROBIS','2016','80000000-0000-0000-0000-000000000101',NULL,'unclear','OES AI-assisted draft',DATE '2026-10-06','unverified','{"source_existing_risk_assessment_version_uuid":"81000000-0000-0000-0000-000000000401","reuse_mode":"judgement_and_rationale_transcription","human_verification":false}'::jsonb,'active'),
('d9310000-0000-0000-0000-000000000702','d9300000-0000-0000-0000-000000000702','d9100000-0000-0000-0000-000000000002','ROBIS','2016','80000000-0000-0000-0000-000000000102',NULL,'unclear','OES AI-assisted draft',DATE '2026-10-06','unverified','{"document":"158-robis-preparatorio-c10-ovr01-dcbti.md","human_verification":false}'::jsonb,'active'),
('d9310000-0000-0000-0000-000000000703','d9300000-0000-0000-0000-000000000703','d9100000-0000-0000-0000-000000000002','ROBIS','2016','d9300000-0000-0000-0000-000000000101',NULL,'high','OES AI-assisted draft',DATE '2026-10-06','unverified','{"document":"158-robis-preparatorio-c10-ovr01-dcbti.md","unit_of_analysis_concern":true,"human_verification":false}'::jsonb,'active');

INSERT INTO appraisal.risk_assessment_domain(
    risk_assessment_version_uuid,domain_code,judgement,rationale,sequence_no
) VALUES
('d9310000-0000-0000-0000-000000000701','eligibility','low_concern','Eligibility criteria are explicit and relevant to the OVR-01 question; transcribed from the existing OES Hwang draft.',1),
('d9310000-0000-0000-0000-000000000701','identification_selection','unclear_concern','Search/selection limitations remain in the existing OES Hwang ROBIS draft; no human verification is added.',2),
('d9310000-0000-0000-0000-000000000701','data_collection_appraisal','unclear_concern','Dual extraction and RoB 2 are reported, but residual methodological uncertainty remains; no human verification is added.',3),
('d9310000-0000-0000-0000-000000000701','synthesis_findings','unclear_concern','Comparator-specific synthesis has material heterogeneity and no formal certainty assessment.',4),

('d9310000-0000-0000-0000-000000000702','eligibility','low_concern','Adult population, fully automated dCBT-I, RCT design and insomnia-severity outcome are aligned with the review question.',1),
('d9310000-0000-0000-0000-000000000702','identification_selection','unclear_concern','Exact last-search date and sufficiently auditable full search methods are not verifiable in accessible sources.',2),
('d9310000-0000-0000-0000-000000000702','data_collection_appraisal','unclear_concern','Risk-of-bias assessment is reported, but duplicate extraction/appraisal procedures are not sufficiently verifiable in accessible material.',3),
('d9310000-0000-0000-0000-000000000702','synthesis_findings','low_concern','Random-effects, REML and truncated Knapp-Hartung methods are reported with cautious interpretation; this remains an AI-only preparatory judgement.',4),

('d9310000-0000-0000-0000-000000000703','eligibility','low_concern','Eligibility criteria are explicit and aligned with fully automated dCBT-I RCTs in adults.',1),
('d9310000-0000-0000-0000-000000000703','identification_selection','low_concern','Multiple databases, explicit coverage through January 2025, supplementary discovery and multi-author screening are reported.',2),
('d9310000-0000-0000-0000-000000000703','data_collection_appraisal','low_concern','Structured extraction and RoB 2 with independent appraisal are reported.',3),
('d9310000-0000-0000-0000-000000000703','synthesis_findings','high_concern','At least five confirmed multiple-Report clusters create material unit-of-analysis risk; the global estimate also has extreme heterogeneity and mixed controls.',4);

-- ---------------------------------------------------------------------------
-- REVIEW-LEVEL OUTCOME EVIDENCE — COMPARATORS KEPT DISTINCT, CERTAINTY NULL
-- ---------------------------------------------------------------------------

INSERT INTO overview.outcome_evidence(
    outcome_evidence_uuid,review_item_uuid,result_version_uuid,
    synthesis_version_uuid,certainty_assessment_version_uuid,
    outcome_entity_uuid,comparison_payload,timepoint_payload,
    analysis_role,primary_study_set_status,extraction_payload,
    verification_status,verified_by,verifier_actor_type,verified_at,status
) VALUES
('d9540000-0000-0000-0000-000000000001','d9500000-0000-0000-0000-000000000101','81000000-0000-0000-0000-000000000301','81000000-0000-0000-0000-000000000501',NULL,'80000000-0000-0000-0000-000000000003','{"family":"digital_sleep_education_or_hygiene","reported_comparator":"online education about sleep","collapsible_with_mixed_controls":false}'::jsonb,'{"label":"post-treatment"}'::jsonb,'primary_estimate','complete','{"effect_measure":"SMD","reported_value":-0.93,"ci95":[-1.07,-0.79],"reported_study_count":10,"recalculated_by_oes":false}'::jsonb,'unverified',NULL,NULL,NULL,'active'),
('d9540000-0000-0000-0000-000000000002','d9500000-0000-0000-0000-000000000102','81000000-0000-0000-0000-000000000302','81000000-0000-0000-0000-000000000502',NULL,'80000000-0000-0000-0000-000000000003','{"family":"mixed_multiple_controls","collapsible_with_hwang":false}'::jsonb,'{"label":"post-treatment"}'::jsonb,'primary_estimate','complete','{"effect_measure":"SMD","reported_value":-0.82,"reported_trial_count":15,"participants":3507,"recalculated_by_oes":false}'::jsonb,'unverified',NULL,NULL,NULL,'active'),
('d9540000-0000-0000-0000-000000000003','d9500000-0000-0000-0000-000000000103','d9310000-0000-0000-0000-000000000501',NULL,NULL,'80000000-0000-0000-0000-000000000003','{"family":"mixed_multiple_controls","collapsible_with_hwang":false}'::jsonb,'{"label":"post-treatment"}'::jsonb,'primary_estimate','complete','{"effect_measure":"WMD","reported_value":-3.42,"ci95":[-4.35,-2.48],"reported_trial_lines":49,"participants":20118,"heterogeneity_i2":98.1,"recalculated_by_oes":false}'::jsonb,'unverified',NULL,NULL,NULL,'active');

-- Comparator/measure differences preclude direct magnitude concordance.
INSERT INTO overview.concordance_assessment(
    concordance_uuid,cluster_uuid,outcome_entity_uuid,
    comparison_payload,timepoint_payload,concordance_state,
    dimensions_payload,rationale,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    assessed_at,status
) VALUES (
    'd9550000-0000-0000-0000-000000000001',
    'd9520000-0000-0000-0000-000000000001',
    '80000000-0000-0000-0000-000000000003',
    '{"policy":"review-specific comparator families retained"}'::jsonb,
    '{"label":"post-treatment"}'::jsonb,
    'not_comparable',
    '{"direction":"qualitatively favorable across reported estimates","magnitude":"not directly comparable","certainty":"not materialized at review level"}'::jsonb,
    'Magnitude concordance is not assessed because Hwang is comparator-specific while Gao/Nazari pool mixed controls, and Nazari reports WMD rather than the Hwang/Gao SMD representation.',
    'OES_AI_ASSISTED','ai_system','unverified',NULL,NULL,NULL,
    TIMESTAMPTZ '2026-10-06 19:20:00-03','active'
);

-- ---------------------------------------------------------------------------
-- PROVENANCE / DEPENDENCY LINEAGE
-- ---------------------------------------------------------------------------

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,
    derivation_rule,status
) VALUES
('81000000-0000-0000-0000-000000000101','d9100000-0000-0000-0000-000000000020','review_evidence_informs_overview','Hwang Review retained as analytic OVR-01 ReviewItem','active'),
('81000000-0000-0000-0000-000000000102','d9100000-0000-0000-0000-000000000020','review_evidence_informs_overview','Gao Review retained as analytic OVR-01 ReviewItem','active'),
('d9310000-0000-0000-0000-000000000101','d9100000-0000-0000-0000-000000000020','review_evidence_informs_overview','Nazari Review materialized for OVR-01','active'),
('81000000-0000-0000-0000-000000000301','d9100000-0000-0000-0000-000000000020','outcome_evidence_informs_overview','Hwang published comparator-specific estimate','active'),
('81000000-0000-0000-0000-000000000302','d9100000-0000-0000-0000-000000000020','outcome_evidence_informs_overview','Gao published mixed-control estimate','active'),
('d9310000-0000-0000-0000-000000000501','d9100000-0000-0000-0000-000000000020','outcome_evidence_informs_overview','Nazari published mixed-control estimate; no OES recalculation','active'),
('81000000-0000-0000-0000-000000000401','d9310000-0000-0000-0000-000000000701','prior_appraisal_informs_ovr_appraisal','Existing Hwang OES ROBIS draft informs OVR-scoped draft without changing N2','active'),
('d9310000-0000-0000-0000-000000000401','d9310000-0000-0000-0000-000000000501','report_supports_result','evidence.result_source; no OES reanalysis','active');

-- ---------------------------------------------------------------------------
-- PRODUCT A0 — UNDER REVIEW, NO PUBLICATION, NO ASSURANCE RECORDS
-- ---------------------------------------------------------------------------

INSERT INTO product.product(entity_uuid)
VALUES ('d9000000-0000-0000-0000-000000000020');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'd9100000-0000-0000-0000-000000000020',
    'd9000000-0000-0000-0000-000000000020',
    'overview_of_reviews',
    'OVR-01 — dCBT-I totalmente automatizada para gravidade da insônia em adultos',
    'internal_methodological_development',
    DATE '2026-10-06',NULL,'under_review',
    'As três Reviews analíticas elegíveis reportam estimativas favoráveis à dCBT-I totalmente automatizada, mas os estimates não são combinados pelo OES. Comparadores e medidas permanecem separados, e o overlap de primary Studies deve ser interpretado a partir das métricas derivadas pelo banco.',
    'Produto developmental interno para validação metodológica e arquitetural; não constitui recomendação clínica nem produto publicável.',
    'A0 sem assurance adicional; memberships e ROBIS são AI-assisted/unverified; não há controle humano independente; Gao não possui last-search date verificável; Nazari informa apenas cobertura até janeiro de 2025 sem dia exato; comparadores não são intercambiáveis; ROBIS Nazari tem preocupação alta de unidade de análise; nenhuma nova meta-análise OES foi criada.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'd9100000-0000-0000-0000-000000000020',
    'd9100000-0000-0000-0000-000000000002',
    'primary',1
);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'd9800000-0000-0000-0000-000000000001',
    'd9100000-0000-0000-0000-000000000020',
    'under_evaluation',
    TIMESTAMPTZ '2026-10-06 19:20:00-03',
    'OES_AI_ASSISTED',
    'Developmental currentness remains under evaluation because Gao has no verifiable last-search date and no formal N4 update has been performed.',
    'active'
);

-- Intentionally no product.assurance_record rows: product remains A0.
-- Intentionally no human reviewer_assignment / quality_control_record rows.
-- Intentionally no owner approval, expert review, A2/A3 promotion or publication.
-- Intentionally no CCA value persisted or manually computed.

COMMIT;
