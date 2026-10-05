-- OES Fase 3 — Rapid Evidence Synthesis N3 experimental fixture
-- Requires baseline + migrations 002–014.
-- Synthetic only: demonstrates A2 + AI controls but no qualified human controls.

BEGIN;

-- ---------------------------------------------------------------------------
-- PROTOCOL ARTIFACT
-- ---------------------------------------------------------------------------

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,
    hash_algorithm,mime_type,original_filename,created_by,status
) VALUES (
    'd9000000-0000-0000-0000-000000000001',
    'protocol',
    'fixtures/n3/rapid-synthesis-protocol-v1.md',
    'synthetic-n3-protocol-sha256',
    'sha256',
    'text/markdown',
    'rapid-synthesis-protocol-v1.md',
    'n3-fixture',
    'active'
);

-- ---------------------------------------------------------------------------
-- QUESTION / INVESTIGATION
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('d0000000-0000-0000-0000-000000000001','OES-Q-2026-001101','Question','n3-fixture'),
('d0000000-0000-0000-0000-000000000002','OES-I-2026-001101','Investigation','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
(
 'd1000000-0000-0000-0000-000000000001',
 'd0000000-0000-0000-0000-000000000001',
 1,'current','n3-fixture','initial','Synthetic N3 question'
),
(
 'd1000000-0000-0000-0000-000000000002',
 'd0000000-0000-0000-0000-000000000002',
 1,'current','n3-fixture','initial','Synthetic N3 investigation'
);

INSERT INTO investigation.question(entity_uuid)
VALUES ('d0000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload
) VALUES (
    'd1000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001',
    'Em adultos com condição sintética X, a intervenção A melhora o desfecho Y?',
    'Em adultos com condição sintética X, qual é o efeito da intervenção A versus cuidado usual sobre o desfecho crítico Y?',
    'intervention','PICO',
    '{"population":"adults with synthetic condition X","intervention":"A","comparator":"usual care","outcome":"Y","fixture":true}'::jsonb
);

INSERT INTO investigation.investigation(entity_uuid)
VALUES ('d0000000-0000-0000-0000-000000000002');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,objective,
    protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES (
    'd1000000-0000-0000-0000-000000000002',
    'd0000000-0000-0000-0000-000000000002',
    'd0000000-0000-0000-0000-000000000001',
    'rapid_evidence_synthesis','N3','M0',
    'Produce a synthetic rapid evidence synthesis for a time-sensitive decision while testing governance blockers.',
    'd9000000-0000-0000-0000-000000000001',
    DATE '2026-10-05',DATE '2026-10-05','completed'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES (
    'd1000000-0000-0000-0000-000000000002',
    'd1000000-0000-0000-0000-000000000001',
    'primary',1
);

INSERT INTO artifact.entity_link(
    artifact_uuid,entity_version_uuid,role,sequence_no
) VALUES (
    'd9000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000002',
    'protocol',1
);

-- ---------------------------------------------------------------------------
-- RAPID-METHOD DECISIONS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,decision_type,stage,
    decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
    impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES
(
    'd6000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000002',
    'rapid_restriction','search','limited_grey_literature',true,
    'Grey literature is restricted in the synthetic rapid-review protocol.',
    '{"risk":"publication bias / missed non-indexed evidence"}'::jsonb,
    '{"mitigation":"two bibliographic sources plus reference checks in protocol"}'::jsonb,
    '{"expected_impact":"limited for synthetic validation"}'::jsonb,
    'accepted','N3_FIXTURE_METHOD',TIMESTAMPTZ '2026-10-05 19:20:00-03','active'
),
(
    'd6000000-0000-0000-0000-000000000002',
    'd1000000-0000-0000-0000-000000000002',
    'rapid_restriction','screening','single_screen_after_calibration',true,
    'Protocol permits single screening after calibrated secondary verification.',
    '{"risk":"eligible records may be missed"}'::jsonb,
    '{"mitigation":"planned pilot and secondary verification sample"}'::jsonb,
    '{"expected_impact":"must be disclosed"}'::jsonb,
    'accepted','N3_FIXTURE_METHOD',TIMESTAMPTZ '2026-10-05 19:21:00-03','active'
),
(
    'd6000000-0000-0000-0000-000000000003',
    'd1000000-0000-0000-0000-000000000002',
    'rapid_restriction','certainty','focused_certainty',true,
    'Certainty assessment is limited to the single critical outcome Y.',
    '{"risk":"secondary outcomes not graded"}'::jsonb,
    '{"mitigation":"critical outcome pre-specified in protocol"}'::jsonb,
    '{"expected_impact":"decision focuses on Y"}'::jsonb,
    'accepted','N3_FIXTURE_METHOD',TIMESTAMPTZ '2026-10-05 19:22:00-03','active'
),
(
    'd6000000-0000-0000-0000-000000000004',
    'd1000000-0000-0000-0000-000000000002',
    'other','reporting','summary_of_findings_not_applicable',true,
    'Synthetic validation uses structured view instead of a standalone SoF artifact.',
    NULL,NULL,
    '{"scope":"fixture-only"}'::jsonb,
    'accepted','N3_FIXTURE_METHOD',TIMESTAMPTZ '2026-10-05 19:23:00-03','active'
);

-- ---------------------------------------------------------------------------
-- SEARCHES
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,executed_at,
    result_count,strategy_version,operator,status
) VALUES
(
    'd2000000-0000-0000-0000-000000000001',
    'OES-SRCH-2026-001101',
    'd1000000-0000-0000-0000-000000000002',
    'PubMed/MEDLINE','PubMed',
    'synthetic condition X AND intervention A AND randomized',
    '{"fixture":true,"design":"RCT"}'::jsonb,
    TIMESTAMPTZ '2026-10-05 19:30:00-03',2,'n3-v1','N3_FIXTURE','completed'
),
(
    'd2000000-0000-0000-0000-000000000002',
    'OES-SRCH-2026-001102',
    'd1000000-0000-0000-0000-000000000002',
    'CENTRAL','Cochrane Library',
    'synthetic condition X AND intervention A',
    '{"fixture":true,"design":"controlled trials"}'::jsonb,
    TIMESTAMPTZ '2026-10-05 19:31:00-03',2,'n3-v1','N3_FIXTURE','completed'
);

-- ---------------------------------------------------------------------------
-- OUTCOME
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('d0000000-0000-0000-0000-000000000010','OES-O-2026-001101','Outcome','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
    'd1000000-0000-0000-0000-000000000010',
    'd0000000-0000-0000-0000-000000000010',
    1,'current','n3-fixture','initial','Critical outcome Y'
);

INSERT INTO evidence.outcome(entity_uuid)
VALUES ('d0000000-0000-0000-0000-000000000010');

INSERT INTO evidence.outcome_version(
    version_uuid,entity_uuid,preferred_name,definition,
    domain,direction_of_benefit,unit_family,status
) VALUES (
    'd1000000-0000-0000-0000-000000000010',
    'd0000000-0000-0000-0000-000000000010',
    'Critical outcome Y','Synthetic critical outcome',
    'effectiveness','lower','continuous','active'
);

-- ---------------------------------------------------------------------------
-- TWO STUDIES / REPORTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('d0000000-0000-0000-0000-000000000101','OES-ST-2026-001101','Study','n3-fixture'),
('d0000000-0000-0000-0000-000000000102','OES-ST-2026-001102','Study','n3-fixture'),
('d0000000-0000-0000-0000-000000000201','OES-RP-2026-001101','Report','n3-fixture'),
('d0000000-0000-0000-0000-000000000202','OES-RP-2026-001102','Report','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d1000000-0000-0000-0000-000000000101','d0000000-0000-0000-0000-000000000101',1,'current','n3-fixture','initial','Synthetic Study A'),
('d1000000-0000-0000-0000-000000000102','d0000000-0000-0000-0000-000000000102',1,'current','n3-fixture','initial','Synthetic Study B'),
('d1000000-0000-0000-0000-000000000201','d0000000-0000-0000-0000-000000000201',1,'current','n3-fixture','initial','Synthetic Report A'),
('d1000000-0000-0000-0000-000000000202','d0000000-0000-0000-0000-000000000202',1,'current','n3-fixture','initial','Synthetic Report B');

INSERT INTO evidence.study(entity_uuid)
VALUES
('d0000000-0000-0000-0000-000000000101'),
('d0000000-0000-0000-0000-000000000102');

INSERT INTO evidence.study_version(
    version_uuid,entity_uuid,study_type,design,title_or_label,
    sample_size,status
) VALUES
('d1000000-0000-0000-0000-000000000101','d0000000-0000-0000-0000-000000000101','primary_study','randomized_controlled_trial','Synthetic trial A',120,'active'),
('d1000000-0000-0000-0000-000000000102','d0000000-0000-0000-0000-000000000102','primary_study','randomized_controlled_trial','Synthetic trial B',150,'active');

INSERT INTO evidence.report(entity_uuid)
VALUES
('d0000000-0000-0000-0000-000000000201'),
('d0000000-0000-0000-0000-000000000202');

INSERT INTO evidence.report_version(
    version_uuid,entity_uuid,report_type,title,publication_date,
    journal_or_source,language,publication_status,full_text_status,
    bibliographic_payload,status
) VALUES
(
 'd1000000-0000-0000-0000-000000000201',
 'd0000000-0000-0000-0000-000000000201',
 'primary_report','Synthetic randomized trial A',
 DATE '2025-06-01','Synthetic Journal A','en','published','available',
 '{"fixture":true,"doi":"10.synthetic/n3a"}'::jsonb,'active'
),
(
 'd1000000-0000-0000-0000-000000000202',
 'd0000000-0000-0000-0000-000000000202',
 'primary_report','Synthetic randomized trial B',
 DATE '2026-01-15','Synthetic Journal B','en','published','available',
 '{"fixture":true,"doi":"10.synthetic/n3b"}'::jsonb,'active'
);

INSERT INTO evidence.study_report_link(
    link_uuid,study_entity_uuid,report_entity_uuid,relation_type,
    confidence,evidence_note,reviewer,decision_date,status
) VALUES
(
 'd3000000-0000-0000-0000-000000000201',
 'd0000000-0000-0000-0000-000000000101',
 'd0000000-0000-0000-0000-000000000201',
 'primary_report','high','Synthetic fixture mapping','N3_FIXTURE',
 DATE '2026-10-05','active'
),
(
 'd3000000-0000-0000-0000-000000000202',
 'd0000000-0000-0000-0000-000000000102',
 'd0000000-0000-0000-0000-000000000202',
 'primary_report','high','Synthetic fixture mapping','N3_FIXTURE',
 DATE '2026-10-05','active'
);

-- ---------------------------------------------------------------------------
-- SEARCH HITS AND SCREENING
-- ---------------------------------------------------------------------------

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,report_entity_uuid,
    source_record_id,raw_payload,raw_title,raw_year,raw_identifier,
    source_rank,resolution_status
) VALUES
(
 'd2500000-0000-0000-0000-000000000201',
 'OES-HIT-2026-001101',
 'd2000000-0000-0000-0000-000000000001',
 'd0000000-0000-0000-0000-000000000201',
 'SYN-N3-A','{"fixture":true}'::jsonb,
 'Synthetic randomized trial A',2025,'10.synthetic/n3a',1,'linked'
),
(
 'd2500000-0000-0000-0000-000000000202',
 'OES-HIT-2026-001102',
 'd2000000-0000-0000-0000-000000000002',
 'd0000000-0000-0000-0000-000000000202',
 'SYN-N3-B','{"fixture":true}'::jsonb,
 'Synthetic randomized trial B',2026,'10.synthetic/n3b',1,'linked'
);

INSERT INTO investigation.screening_decision(
    screening_uuid,oes_screening_id,investigation_version_uuid,
    target_entity_uuid,stage,reviewer,decision,decided_at
) VALUES
(
 'd3500000-0000-0000-0000-000000000201',
 'OES-SCR-2026-001101',
 'd1000000-0000-0000-0000-000000000002',
 'd0000000-0000-0000-0000-000000000201',
 'title_abstract','N3_FIXTURE_AI','include',
 TIMESTAMPTZ '2026-10-05 19:35:00-03'
),
(
 'd3500000-0000-0000-0000-000000000202',
 'OES-SCR-2026-001102',
 'd1000000-0000-0000-0000-000000000002',
 'd0000000-0000-0000-0000-000000000202',
 'title_abstract','N3_FIXTURE_AI','include',
 TIMESTAMPTZ '2026-10-05 19:35:30-03'
),
(
 'd3500000-0000-0000-0000-000000000203',
 'OES-SCR-2026-001103',
 'd1000000-0000-0000-0000-000000000002',
 'd0000000-0000-0000-0000-000000000201',
 'full_text','N3_FIXTURE_AI','include',
 TIMESTAMPTZ '2026-10-05 19:36:00-03'
),
(
 'd3500000-0000-0000-0000-000000000204',
 'OES-SCR-2026-001104',
 'd1000000-0000-0000-0000-000000000002',
 'd0000000-0000-0000-0000-000000000202',
 'full_text','N3_FIXTURE_AI','include',
 TIMESTAMPTZ '2026-10-05 19:36:30-03'
);

-- ---------------------------------------------------------------------------
-- RESULTS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('d0000000-0000-0000-0000-000000000301','OES-R-2026-001101','Result','n3-fixture'),
('d0000000-0000-0000-0000-000000000302','OES-R-2026-001102','Result','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d1000000-0000-0000-0000-000000000301','d0000000-0000-0000-0000-000000000301',1,'current','n3-fixture','initial','Synthetic result A'),
('d1000000-0000-0000-0000-000000000302','d0000000-0000-0000-0000-000000000302',1,'current','n3-fixture','initial','Synthetic result B');

INSERT INTO evidence.result(entity_uuid,study_entity_uuid)
VALUES
('d0000000-0000-0000-0000-000000000301','d0000000-0000-0000-0000-000000000101'),
('d0000000-0000-0000-0000-000000000302','d0000000-0000-0000-0000-000000000102');

INSERT INTO evidence.result_version(
    version_uuid,entity_uuid,outcome_entity_uuid,population_descriptor,
    timepoint_value,timepoint_unit,timepoint_label,estimand,measure,
    reported_value,variance_or_se,ci_lower,ci_upper,unit,
    adjusted_flag,analysis_population,missing_data_state,method_payload,status
) VALUES
(
 'd1000000-0000-0000-0000-000000000301',
 'd0000000-0000-0000-0000-000000000301',
 'd0000000-0000-0000-0000-000000000010',
 '{"population":"synthetic adults"}'::jsonb,
 8,'week','8 weeks','mean_difference','MD',
 '{"value":-2.0}'::jsonb,'{"se":0.7}'::jsonb,
 -3.37,-0.63,'points',false,'intention_to_treat','reported',
 '{"fixture":true}'::jsonb,'active'
),
(
 'd1000000-0000-0000-0000-000000000302',
 'd0000000-0000-0000-0000-000000000302',
 'd0000000-0000-0000-0000-000000000010',
 '{"population":"synthetic adults"}'::jsonb,
 8,'week','8 weeks','mean_difference','MD',
 '{"value":-1.4}'::jsonb,'{"se":0.6}'::jsonb,
 -2.58,-0.22,'points',false,'intention_to_treat','reported',
 '{"fixture":true}'::jsonb,'active'
);

INSERT INTO evidence.result_source(
    result_version_uuid,report_version_uuid,source_location,source_type,
    original_text_or_value,extraction_method,is_primary_source,
    extractor,extracted_at
) VALUES
(
 'd1000000-0000-0000-0000-000000000301',
 'd1000000-0000-0000-0000-000000000201',
 'Table 2','table',
 '{"md":-2.0,"ci":[-3.37,-0.63]}'::jsonb,
 'structured_ai_assisted',true,'N3_FIXTURE_AI',
 TIMESTAMPTZ '2026-10-05 19:40:00-03'
),
(
 'd1000000-0000-0000-0000-000000000302',
 'd1000000-0000-0000-0000-000000000202',
 'Table 3','table',
 '{"md":-1.4,"ci":[-2.58,-0.22]}'::jsonb,
 'structured_ai_assisted',true,'N3_FIXTURE_AI',
 TIMESTAMPTZ '2026-10-05 19:41:00-03'
);

-- ---------------------------------------------------------------------------
-- RISK OF BIAS
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('d0000000-0000-0000-0000-000000000401','OES-RA-2026-001101','RiskAssessment','n3-fixture'),
('d0000000-0000-0000-0000-000000000402','OES-RA-2026-001102','RiskAssessment','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d1000000-0000-0000-0000-000000000401','d0000000-0000-0000-0000-000000000401',1,'current','n3-fixture','initial','Synthetic RoB A'),
('d1000000-0000-0000-0000-000000000402','d0000000-0000-0000-0000-000000000402',1,'current','n3-fixture','initial','Synthetic RoB B');

INSERT INTO appraisal.risk_assessment(entity_uuid)
VALUES
('d0000000-0000-0000-0000-000000000401'),
('d0000000-0000-0000-0000-000000000402');

INSERT INTO appraisal.risk_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    framework,framework_version,target_entity_uuid,outcome_entity_uuid,
    overall_judgement,assessor,assessment_date,verification_status,
    instrument_payload,status
) VALUES
(
 'd1000000-0000-0000-0000-000000000401',
 'd0000000-0000-0000-0000-000000000401',
 'd1000000-0000-0000-0000-000000000002',
 'RoB 2','fixture',
 'd0000000-0000-0000-0000-000000000101',
 'd0000000-0000-0000-0000-000000000010',
 'low','N3_FIXTURE_AI',DATE '2026-10-05',
 'ai_verified_only','{"fixture":true}'::jsonb,'active'
),
(
 'd1000000-0000-0000-0000-000000000402',
 'd0000000-0000-0000-0000-000000000402',
 'd1000000-0000-0000-0000-000000000002',
 'RoB 2','fixture',
 'd0000000-0000-0000-0000-000000000102',
 'd0000000-0000-0000-0000-000000000010',
 'some_concerns','N3_FIXTURE_AI',DATE '2026-10-05',
 'ai_verified_only','{"fixture":true}'::jsonb,'active'
);

INSERT INTO appraisal.risk_assessment_domain(
    risk_assessment_version_uuid,domain_code,judgement,
    rationale,sequence_no
) VALUES
('d1000000-0000-0000-0000-000000000401','randomization','low','Synthetic low-risk domain',1),
('d1000000-0000-0000-0000-000000000402','randomization','some_concerns','Synthetic concern domain',1);

-- ---------------------------------------------------------------------------
-- SYNTHESIS / CERTAINTY
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES
('d0000000-0000-0000-0000-000000000501','OES-SY-2026-001101','Synthesis','n3-fixture'),
('d0000000-0000-0000-0000-000000000502','OES-CA-2026-001101','CertaintyAssessment','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('d1000000-0000-0000-0000-000000000501','d0000000-0000-0000-0000-000000000501',1,'current','n3-fixture','initial','Synthetic narrative rapid synthesis'),
('d1000000-0000-0000-0000-000000000502','d0000000-0000-0000-0000-000000000502',1,'current','n3-fixture','initial','Synthetic GRADE assessment');

INSERT INTO synthesis.synthesis(entity_uuid)
VALUES ('d0000000-0000-0000-0000-000000000501');

INSERT INTO synthesis.synthesis_version(
    version_uuid,entity_uuid,investigation_version_uuid,outcome_entity_uuid,
    population_descriptor,comparison_payload,timepoint_payload,estimand,
    synthesis_type,synthesis_origin,method,model,result_summary,status,executed_at
) VALUES (
    'd1000000-0000-0000-0000-000000000501',
    'd0000000-0000-0000-0000-000000000501',
    'd1000000-0000-0000-0000-000000000002',
    'd0000000-0000-0000-0000-000000000010',
    '{"population":"synthetic adults"}'::jsonb,
    '{"intervention":"A","comparator":"usual care"}'::jsonb,
    '{"timepoint":"8 weeks"}'::jsonb,
    'mean_difference',
    'narrative_synthesis',
    'new_calculation',
    'structured narrative synthesis (SWiM-compatible fixture)',
    NULL,
    '{"direction":"favours intervention A","study_effects":[-2.0,-1.4],"pooled":false}'::jsonb,
    'active',
    TIMESTAMPTZ '2026-10-05 19:45:00-03'
);

INSERT INTO synthesis.contribution(
    synthesis_version_uuid,result_version_uuid,contribution_role,
    included_main_analysis,notes
) VALUES
(
 'd1000000-0000-0000-0000-000000000501',
 'd1000000-0000-0000-0000-000000000301',
 'main',true,'Synthetic study A'
),
(
 'd1000000-0000-0000-0000-000000000501',
 'd1000000-0000-0000-0000-000000000302',
 'main',true,'Synthetic study B'
);

INSERT INTO appraisal.certainty_assessment(entity_uuid)
VALUES ('d0000000-0000-0000-0000-000000000502');

INSERT INTO appraisal.certainty_assessment_version(
    version_uuid,entity_uuid,investigation_version_uuid,
    synthesis_version_uuid,outcome_entity_uuid,framework,framework_version,
    initial_level,final_level,evidence_state,assessment_date,status
) VALUES (
    'd1000000-0000-0000-0000-000000000502',
    'd0000000-0000-0000-0000-000000000502',
    'd1000000-0000-0000-0000-000000000002',
    'd1000000-0000-0000-0000-000000000501',
    'd0000000-0000-0000-0000-000000000010',
    'GRADE','fixture','high','moderate',
    'evidence_available',DATE '2026-10-05','active'
);

INSERT INTO appraisal.certainty_domain(
    certainty_assessment_version_uuid,domain_code,concern_level,
    downgrade_steps,rationale,reviewer,sequence_no
) VALUES (
    'd1000000-0000-0000-0000-000000000502',
    'risk_of_bias','some_concern',1,
    'One synthetic study has some concerns.','N3_FIXTURE_AI',1
);

-- ---------------------------------------------------------------------------
-- PRODUCT A2 (SYNTHETIC GOVERNANCE)
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('d0000000-0000-0000-0000-000000000601','OES-P-2026-001101','Product','n3-fixture');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES (
    'd1000000-0000-0000-0000-000000000601',
    'd0000000-0000-0000-0000-000000000601',
    1,'current','n3-fixture','initial',
    'Synthetic N3 product — intentionally missing human controls/A3'
);

INSERT INTO product.product(entity_uuid)
VALUES ('d0000000-0000-0000-0000-000000000601');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,conclusion_text,
    applicability_summary,limitations_summary
) VALUES (
    'd1000000-0000-0000-0000-000000000601',
    'd0000000-0000-0000-0000-000000000601',
    'rapid_evidence_synthesis',
    'Synthetic Rapid Evidence Synthesis N3',
    'architecture_validation',
    DATE '2026-10-05',
    DATE '2026-10-05',
    'under_review',
    'Synthetic evidence favours intervention A for outcome Y, with moderate certainty in the fixture; formal publication remains blocked until qualified human controls and A3 exist.',
    'Synthetic fixture; no real-world applicability claim.',
    'Rapid-method restrictions include limited grey literature, single screening after planned calibration, and certainty limited to the critical outcome. This is a synthetic validation artifact.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES (
    'd1000000-0000-0000-0000-000000000601',
    'd1000000-0000-0000-0000-000000000002',
    'primary',1
);

INSERT INTO product.synthesis_link(
    product_version_uuid,synthesis_version_uuid,role,sequence_no
) VALUES (
    'd1000000-0000-0000-0000-000000000601',
    'd1000000-0000-0000-0000-000000000501',
    'primary',1
);

INSERT INTO product.certainty_link(
    product_version_uuid,certainty_assessment_version_uuid,role,sequence_no
) VALUES (
    'd1000000-0000-0000-0000-000000000601',
    'd1000000-0000-0000-0000-000000000502',
    'primary',1
);

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'd7000000-0000-0000-0000-000000000601',
    'd1000000-0000-0000-0000-000000000601',
    'current',TIMESTAMPTZ '2026-10-05 19:50:00-03',
    'N3_FIXTURE',
    'Synthetic searches current through fixture cutoff.',
    'active'
);

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES
(
    'd8000000-0000-0000-0000-000000000601',
    'd1000000-0000-0000-0000-000000000601',
    'ai_methodological_verification','N3_FIXTURE_AI','ai_system',
    false,'passed',TIMESTAMPTZ '2026-10-05 19:51:00-03',
    'Synthetic AI verification for gate testing.',
    '{"fixture":true}'::jsonb,'active'
),
(
    'd8000000-0000-0000-0000-000000000602',
    'd1000000-0000-0000-0000-000000000601',
    'owner_governance_approval','N3_FIXTURE_OWNER','owner',
    false,'approved',TIMESTAMPTZ '2026-10-05 19:52:00-03',
    'Synthetic owner approval for gate testing only.',
    '{"fixture":true}'::jsonb,'active'
);

-- ---------------------------------------------------------------------------
-- AI QUALITY CONTROLS — TRANSPARENT BUT NOT QUALIFIED HUMAN CONTROLS
-- ---------------------------------------------------------------------------

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,independent_flag,decision,scope_payload,
    agreement_payload,performed_at,notes,record_status
) VALUES
(
 'd6500000-0000-0000-0000-000000000001',
 'd1000000-0000-0000-0000-000000000002',
 'search','search_strategy_verification',
 'N3_FIXTURE_AI','ai_system',false,'passed',
 '{"search_ids":["OES-SRCH-2026-001101","OES-SRCH-2026-001102"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 19:32:00-03',
 'AI check; does not satisfy human-qualified control.','active'
),
(
 'd6500000-0000-0000-0000-000000000002',
 'd1000000-0000-0000-0000-000000000002',
 'screening','screening_pilot',
 'N3_FIXTURE_AI','ai_system',false,'passed',
 '{"records_sampled":2,"records_total":2}'::jsonb,
 '{"agreement":"synthetic"}'::jsonb,
 TIMESTAMPTZ '2026-10-05 19:34:00-03',
 'AI pilot; not a human pilot.','active'
),
(
 'd6500000-0000-0000-0000-000000000003',
 'd1000000-0000-0000-0000-000000000002',
 'screening','screening_secondary_verification',
 'N3_FIXTURE_AI','ai_system',false,'passed',
 '{"screening_decision_ids":["OES-SCR-2026-001101","OES-SCR-2026-001102","OES-SCR-2026-001103","OES-SCR-2026-001104"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 19:37:00-03',
 'AI secondary check; not qualified human verification.','active'
),
(
 'd6500000-0000-0000-0000-000000000004',
 'd1000000-0000-0000-0000-000000000002',
 'extraction','critical_data_verification',
 'N3_FIXTURE_AI','ai_system',false,'passed',
 '{"result_version_uuids":["d1000000-0000-0000-0000-000000000301","d1000000-0000-0000-0000-000000000302"],"critical_fields":["reported_value","ci_lower","ci_upper"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 19:42:00-03',
 'AI data verification only.','active'
),
(
 'd6500000-0000-0000-0000-000000000005',
 'd1000000-0000-0000-0000-000000000002',
 'appraisal','risk_of_bias_verification',
 'N3_FIXTURE_AI','ai_system',false,'passed',
 '{"risk_assessment_version_uuids":["d1000000-0000-0000-0000-000000000401","d1000000-0000-0000-0000-000000000402"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 19:44:00-03',
 'AI RoB verification only.','active'
),
(
 'd6500000-0000-0000-0000-000000000006',
 'd1000000-0000-0000-0000-000000000002',
 'certainty','certainty_verification',
 'N3_FIXTURE_AI','ai_system',false,'passed',
 '{"certainty_version_uuids":["d1000000-0000-0000-0000-000000000502"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 19:48:00-03',
 'AI certainty verification only.','active'
);

-- ---------------------------------------------------------------------------
-- LINEAGE
-- ---------------------------------------------------------------------------

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
('d1000000-0000-0000-0000-000000000201','d1000000-0000-0000-0000-000000000301','report_supports_result','result_source','active'),
('d1000000-0000-0000-0000-000000000202','d1000000-0000-0000-0000-000000000302','report_supports_result','result_source','active'),
('d1000000-0000-0000-0000-000000000301','d1000000-0000-0000-0000-000000000501','result_contributes_to_synthesis','synthesis.contribution','active'),
('d1000000-0000-0000-0000-000000000302','d1000000-0000-0000-0000-000000000501','result_contributes_to_synthesis','synthesis.contribution','active'),
('d1000000-0000-0000-0000-000000000501','d1000000-0000-0000-0000-000000000502','synthesis_informs_certainty','certainty.synthesis_version_uuid','active'),
('d1000000-0000-0000-0000-000000000502','d1000000-0000-0000-0000-000000000601','certainty_informs_product','product.certainty_link','active');

COMMIT;
