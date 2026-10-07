-- F3 Evidence Monitor synthetic fixtures
-- Requires migrations through 021.

BEGIN;

-- ---------------------------------------------------------------------------
-- Shared scientific target (N2)
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('e5000000-0000-0000-0000-000000000001','OES-Q-2026-MON001','Question','f3-monitor'),
('e5000000-0000-0000-0000-000000000002','OES-I-2026-MON001','Investigation','f3-monitor'),
('e5000000-0000-0000-0000-000000000003','OES-P-2026-MON001','Product','f3-monitor'),
('e5000000-0000-0000-0000-000000000004','OES-I-2026-MON002','Investigation','f3-monitor'),
('e5000000-0000-0000-0000-000000000005','OES-P-2026-MON002','Product','f3-monitor'),
('e5000000-0000-0000-0000-000000000006','OES-I-2026-MON003','Investigation','f3-monitor'),
('e5000000-0000-0000-0000-000000000007','OES-P-2026-MON003','Product','f3-monitor');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('e5100000-0000-0000-0000-000000000001','e5000000-0000-0000-0000-000000000001',1,'current','f3-monitor','initial','Monitor fixture question'),
('e5100000-0000-0000-0000-000000000002','e5000000-0000-0000-0000-000000000002',1,'current','f3-monitor','initial','Scientific target investigation'),
('e5100000-0000-0000-0000-000000000003','e5000000-0000-0000-0000-000000000003',1,'current','f3-monitor','initial','Scientific target product'),
('e5100000-0000-0000-0000-000000000004','e5000000-0000-0000-0000-000000000004',1,'current','f3-monitor','initial','M2 monitor investigation'),
('e5100000-0000-0000-0000-000000000005','e5000000-0000-0000-0000-000000000005',1,'current','f3-monitor','initial','M2 monitor product'),
('e5100000-0000-0000-0000-000000000006','e5000000-0000-0000-0000-000000000006',1,'current','f3-monitor','initial','M3 monitor investigation'),
('e5100000-0000-0000-0000-000000000007','e5000000-0000-0000-0000-000000000007',1,'current','f3-monitor','initial','M3 monitor product');

INSERT INTO investigation.question(entity_uuid)
VALUES ('e5000000-0000-0000-0000-000000000001');

INSERT INTO investigation.question_version(
    version_uuid,entity_uuid,original_text,normalized_text,
    question_type,structure_type,context_payload
) VALUES (
    'e5100000-0000-0000-0000-000000000001',
    'e5000000-0000-0000-0000-000000000001',
    'A intervenção A melhora o desfecho O em adultos?',
    'intervencao a melhora desfecho o em adultos',
    'intervention','PICO',
    '{"fixture":"evidence_monitor"}'::jsonb
);

INSERT INTO artifact.artifact(
    artifact_uuid,artifact_type,storage_key,content_hash,
    mime_type,byte_size,original_filename,created_by,status
) VALUES
('e5200000-0000-0000-0000-000000000001','protocol','fixtures/monitor/m2-plan.md','sha256-monitor-m2-plan','text/markdown',100,'monitor-m2-plan.md','f3-monitor','active'),
('e5200000-0000-0000-0000-000000000002','protocol','fixtures/monitor/m3-plan.md','sha256-monitor-m3-plan','text/markdown',100,'monitor-m3-plan.md','f3-monitor','active');

INSERT INTO investigation.investigation(entity_uuid) VALUES
('e5000000-0000-0000-0000-000000000002'),
('e5000000-0000-0000-0000-000000000004'),
('e5000000-0000-0000-0000-000000000006');

INSERT INTO investigation.investigation_version(
    version_uuid,entity_uuid,primary_question_entity_uuid,
    investigation_type,depth_level,maintenance_level,
    objective,protocol_artifact_uuid,start_date,evidence_cutoff_date,status
) VALUES
(
 'e5100000-0000-0000-0000-000000000002',
 'e5000000-0000-0000-0000-000000000002',
 'e5000000-0000-0000-0000-000000000001',
 'evidence_sheet','N2','M1',
 'Synthetic scientific target for Evidence Monitor',
 NULL,DATE '2026-09-01',DATE '2026-10-01','active'
),
(
 'e5100000-0000-0000-0000-000000000004',
 'e5000000-0000-0000-0000-000000000004',
 'e5000000-0000-0000-0000-000000000001',
 'evidence_monitoring','N2','M2',
 'Synthetic active M2 evidence monitoring',
 'e5200000-0000-0000-0000-000000000001',
 DATE '2026-10-02',DATE '2026-10-01','active'
),
(
 'e5100000-0000-0000-0000-000000000006',
 'e5000000-0000-0000-0000-000000000006',
 'e5000000-0000-0000-0000-000000000001',
 'evidence_monitoring','N2','M3',
 'Synthetic M3 monitor blocked until Phase 4',
 'e5200000-0000-0000-0000-000000000002',
 DATE '2026-10-02',DATE '2026-10-01','active'
);

INSERT INTO investigation.investigation_question(
    investigation_version_uuid,question_version_uuid,role,sequence_no
) VALUES
('e5100000-0000-0000-0000-000000000002','e5100000-0000-0000-0000-000000000001','primary',1),
('e5100000-0000-0000-0000-000000000004','e5100000-0000-0000-0000-000000000001','primary',1),
('e5100000-0000-0000-0000-000000000006','e5100000-0000-0000-0000-000000000001','primary',1);

INSERT INTO product.product(entity_uuid) VALUES
('e5000000-0000-0000-0000-000000000003'),
('e5000000-0000-0000-0000-000000000005'),
('e5000000-0000-0000-0000-000000000007');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,
    conclusion_text,applicability_summary,limitations_summary
) VALUES
(
 'e5100000-0000-0000-0000-000000000003',
 'e5000000-0000-0000-0000-000000000003',
 'evidence_sheet','Synthetic scientific target','architecture_validation',
 DATE '2026-10-01',DATE '2026-10-01','published',
 'Synthetic target conclusion.',
 'Synthetic applicability.',
 'Synthetic target limitations.'
),
(
 'e5100000-0000-0000-0000-000000000005',
 'e5000000-0000-0000-0000-000000000005',
 'evidence_monitor','Synthetic Evidence Monitor M2','architecture_validation',
 DATE '2026-10-01',DATE '2026-10-06','published',
 NULL,NULL,
 'Synthetic monitor; latest cycle is AI-verified and target is under evaluation.'
),
(
 'e5100000-0000-0000-0000-000000000007',
 'e5000000-0000-0000-0000-000000000007',
 'evidence_monitor','Synthetic Evidence Monitor M3','architecture_validation',
 DATE '2026-10-01',DATE '2026-10-06','published',
 NULL,NULL,
 'Synthetic M3 monitor used only to validate the Phase 4 blocker.'
);

INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES
('e5100000-0000-0000-0000-000000000003','e5100000-0000-0000-0000-000000000002','primary',1),
('e5100000-0000-0000-0000-000000000005','e5100000-0000-0000-0000-000000000004','primary',1),
('e5100000-0000-0000-0000-000000000007','e5100000-0000-0000-0000-000000000006','primary',1);

-- Initial target currentness.
INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES (
    'e5300000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000003',
    'current',TIMESTAMPTZ '2026-10-01 12:00:00+00',
    'fixture','Current at target publication','active'
);

-- Monitor product-plan currency.
INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,record_status
) VALUES
(
 'e5300000-0000-0000-0000-000000000010',
 'e5100000-0000-0000-0000-000000000005',
 'current',TIMESTAMPTZ '2026-10-02 12:00:00+00',
 'fixture','M2 monitoring plan is current','active'
),
(
 'e5300000-0000-0000-0000-000000000011',
 'e5100000-0000-0000-0000-000000000007',
 'current',TIMESTAMPTZ '2026-10-02 12:00:00+00',
 'fixture','M3 monitoring plan is current','active'
);

-- ---------------------------------------------------------------------------
-- M2 formal monitor
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.monitor_definition(
    monitor_product_version_uuid,
    surveillance_scope_payload,source_policy_payload,
    strategy_policy_payload,cadence_policy_payload,
    impact_policy_payload,escalation_policy_payload
) VALUES (
    'e5100000-0000-0000-0000-000000000005',
    '{"population":"adults","intervention":"A","outcome":"O"}'::jsonb,
    '{
      "required_source_names":["PubMed"],
      "required_source_classes":["bibliographic"],
      "minimum_bibliographic_sources":1
    }'::jsonb,
    '{"mode":"incremental","deduplication":"canonical"}'::jsonb,
    '{"instance_interval":"monthly","phase4_default":false}'::jsonb,
    '{"dimensions":["quantitative","certainty","applicability","conclusion","validity"]}'::jsonb,
    '{"alert_candidate_allowed":true,"severity_not_defined":true}'::jsonb
);

INSERT INTO maintenance.monitor_source_requirement(
    source_requirement_uuid,monitor_product_version_uuid,
    requirement_code,requirement_kind,required_value,minimum_count,
    allow_exception,rationale,sequence_no
) VALUES
(
 'e5450000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000005',
 'pubmed_required','source_name','PubMed',NULL,true,
 'PubMed is prospectively required by the M2 fixture plan',1
),
(
 'e5450000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000005',
 'bibliographic_class_required','source_class','bibliographic',NULL,true,
 'At least one bibliographic-class source is required',2
),
(
 'e5450000-0000-0000-0000-000000000003',
 'e5100000-0000-0000-0000-000000000005',
 'minimum_bibliographic_sources',
 'minimum_distinct_bibliographic_sources',NULL,1,true,
 'At least one distinct bibliographic source is required',3
);

INSERT INTO maintenance.monitor_target(
    monitor_target_uuid,monitor_product_version_uuid,
    target_product_version_uuid,rationale
) VALUES (
    'e5400000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000005',
    'e5100000-0000-0000-0000-000000000003',
    'Monitor the concrete N2 target ProductVersion'
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
    'e5100000-0000-0000-0000-000000000003',
    'e5100000-0000-0000-0000-000000000005',
    'maintenance_surveillance_target',
    'monitor_target',
    'active'
);

INSERT INTO maintenance.monitor_state(
    monitor_state_uuid,monitor_product_version_uuid,
    operational_status,effective_at,rationale,changed_by,actor_type
) VALUES (
    'e5410000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000005',
    'active',TIMESTAMPTZ '2026-10-02 12:00:00+00',
    'Synthetic M2 monitor activated','fixture','system'
);

-- Cycle 1: no update needed.
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,planned_at,started_at,
    execution_status,completeness_status,verification_status,
    execution_payload
) VALUES (
    'e5420000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000005',1,
    DATE '2026-10-02',DATE '2026-10-03',
    TIMESTAMPTZ '2026-10-02 08:00:00+00',
    TIMESTAMPTZ '2026-10-03 08:00:00+00',
    'running','not_assessed','unverified',
    '{"fixture":true}'::jsonb
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,
    executed_at,result_count,strategy_version,operator,status
) VALUES (
    'e5500000-0000-0000-0000-000000000001',
    'OES-SEARCH-2026-MON001',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','PubMed','("intervention A"[Title/Abstract])',
    '{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-03 08:10:00+00',1,'v1','fixture','completed'
);

INSERT INTO maintenance.cycle_search(
    cycle_uuid,search_uuid,search_role,sequence_no
) VALUES (
    'e5420000-0000-0000-0000-000000000001',
    'e5500000-0000-0000-0000-000000000001',
    'primary',1
);

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,
    source_record_id,raw_payload,raw_title,raw_authors,raw_year,
    raw_identifier,source_rank,resolution_status
) VALUES (
    'e5510000-0000-0000-0000-000000000001',
    'OES-HIT-2026-MON001',
    'e5500000-0000-0000-0000-000000000001',
    'fixture-hit-1','{"fixture":true}'::jsonb,
    'Irrelevant monitoring record','Fixture Author',2026,
    'fixture:1',1,'unresolved'
);

INSERT INTO maintenance.candidate_assessment(
    candidate_assessment_uuid,cycle_uuid,origin_type,
    origin_search_hit_uuid,candidate_kind,decision,exclusion_reason,
    impact_class,impact_payload,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'e5530000-0000-0000-0000-000000000001',
    'e5420000-0000-0000-0000-000000000001',
    'search_hit','e5510000-0000-0000-0000-000000000001',
    'new_report','excluded','Outside target population','none',
    '{"reason":"population"}'::jsonb,
    'fixture-ai','ai_system','ai_verified',
    'fixture-ai-check','ai_system',
    TIMESTAMPTZ '2026-10-03 08:50:00+00'
);

UPDATE maintenance.monitor_cycle
   SET completed_at=TIMESTAMPTZ '2026-10-03 09:00:00+00',
       execution_status='completed',
       completeness_status='complete',
       maintenance_decision='no_update_needed',
       decision_rationale='No retained candidate with material impact.',
       escalation_recommendation='none',
       decided_by='fixture-ai',
       actor_type='ai_system',
       verification_status='ai_verified',
       verified_by='fixture-ai-check',
       verifier_actor_type='ai_system',
       verified_at=TIMESTAMPTZ '2026-10-03 09:05:00+00'
 WHERE cycle_uuid='e5420000-0000-0000-0000-000000000001';

UPDATE product.currency_state
   SET record_status='superseded'
 WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000001';

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,
    supersedes_currency_state_uuid,record_status
) VALUES (
    'e5300000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000003',
    'current',TIMESTAMPTZ '2026-10-03 09:10:00+00',
    'fixture-ai',
    'Cycle 1 completed with no material update needed',
    'e5300000-0000-0000-0000-000000000001','active'
);

INSERT INTO maintenance.cycle_currency_state(
    cycle_uuid,currency_state_uuid
) VALUES (
    'e5420000-0000-0000-0000-000000000001',
    'e5300000-0000-0000-0000-000000000002'
);

-- Cycle 2: evaluate update.
INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,previous_cycle_uuid,
    window_start_date,window_end_date,planned_at,started_at,
    execution_status,completeness_status,verification_status,
    execution_payload
) VALUES (
    'e5420000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000005',2,
    'e5420000-0000-0000-0000-000000000001',
    DATE '2026-10-04',DATE '2026-10-06',
    TIMESTAMPTZ '2026-10-04 08:00:00+00',
    TIMESTAMPTZ '2026-10-06 08:00:00+00',
    'running','not_assessed','unverified',
    '{"fixture":true}'::jsonb
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,
    executed_at,result_count,strategy_version,operator,status
) VALUES (
    'e5500000-0000-0000-0000-000000000002',
    'OES-SEARCH-2026-MON002',
    'e5100000-0000-0000-0000-000000000004',
    'PubMed','PubMed','("intervention A"[Title/Abstract]) AND 2026[pdat]',
    '{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-06 08:10:00+00',1,'v2','fixture','completed'
);

INSERT INTO maintenance.cycle_search(
    cycle_uuid,search_uuid,search_role,sequence_no
) VALUES (
    'e5420000-0000-0000-0000-000000000002',
    'e5500000-0000-0000-0000-000000000002',
    'primary',1
);

INSERT INTO investigation.search_hit(
    search_hit_uuid,oes_search_hit_id,search_uuid,
    source_record_id,raw_payload,raw_title,raw_authors,raw_year,
    raw_identifier,source_rank,resolution_status
) VALUES (
    'e5510000-0000-0000-0000-000000000002',
    'OES-HIT-2026-MON002',
    'e5500000-0000-0000-0000-000000000002',
    'fixture-hit-2','{"fixture":true}'::jsonb,
    'Potentially relevant new trial','Fixture Author',2026,
    'fixture:2',1,'unresolved'
);

INSERT INTO maintenance.candidate_assessment(
    candidate_assessment_uuid,cycle_uuid,origin_type,
    origin_search_hit_uuid,candidate_kind,decision,
    impact_class,impact_payload,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'e5530000-0000-0000-0000-000000000002',
    'e5420000-0000-0000-0000-000000000002',
    'search_hit','e5510000-0000-0000-0000-000000000002',
    'new_study','retained_for_impact',
    'quantitative','{"possible_effect_change":true}'::jsonb,
    'fixture-ai','ai_system','ai_verified',
    'fixture-ai-check','ai_system',
    TIMESTAMPTZ '2026-10-06 08:45:00+00'
);

INSERT INTO maintenance.candidate_impact(
    candidate_impact_uuid,candidate_assessment_uuid,
    impact_class,is_primary,impact_payload,rationale,sequence_no
) VALUES
(
 'e5540000-0000-0000-0000-000000000001',
 'e5530000-0000-0000-0000-000000000002',
 'quantitative',true,
 '{"possible_effect_change":true}'::jsonb,
 'Primary impact dimension for the new-study candidate',1
),
(
 'e5540000-0000-0000-0000-000000000002',
 'e5530000-0000-0000-0000-000000000002',
 'certainty',false,
 '{"possible_certainty_change":true}'::jsonb,
 'The same candidate may also alter certainty',2
);

INSERT INTO maintenance.evidence_event(
    evidence_event_uuid,cycle_uuid,event_type,event_date,
    source_uri,description,event_payload,detected_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'e5520000-0000-0000-0000-000000000001',
    'e5420000-0000-0000-0000-000000000002',
    'regulatory_update',DATE '2026-10-05',
    'https://example.invalid/regulatory-monitor-fixture',
    'Synthetic regulatory signal for Monitor fixture',
    '{"fixture":true}'::jsonb,
    'fixture-ai','ai_system','ai_verified',
    'fixture-ai-check','ai_system',
    TIMESTAMPTZ '2026-10-06 08:50:00+00'
);

INSERT INTO maintenance.candidate_assessment(
    candidate_assessment_uuid,cycle_uuid,origin_type,
    origin_evidence_event_uuid,candidate_kind,decision,
    impact_class,impact_payload,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'e5530000-0000-0000-0000-000000000003',
    'e5420000-0000-0000-0000-000000000002',
    'evidence_event','e5520000-0000-0000-0000-000000000001',
    'regulatory_signal','retained_for_impact',
    'applicability','{"requires_evaluation":true}'::jsonb,
    'fixture-ai','ai_system','ai_verified',
    'fixture-ai-check','ai_system',
    TIMESTAMPTZ '2026-10-06 08:55:00+00'
);

INSERT INTO maintenance.candidate_impact(
    candidate_impact_uuid,candidate_assessment_uuid,
    impact_class,is_primary,impact_payload,rationale,sequence_no
) VALUES (
    'e5540000-0000-0000-0000-000000000003',
    'e5530000-0000-0000-0000-000000000003',
    'applicability',true,
    '{"requires_evaluation":true}'::jsonb,
    'Primary applicability impact for regulatory signal',1
);

UPDATE maintenance.monitor_cycle
   SET completed_at=TIMESTAMPTZ '2026-10-06 09:00:00+00',
       execution_status='completed',
       completeness_status='complete',
       maintenance_decision='evaluate_update',
       decision_rationale='A retained candidate and regulatory signal require scientific evaluation.',
       escalation_recommendation='evaluate_alert',
       decided_by='fixture-ai',
       actor_type='ai_system',
       verification_status='ai_verified',
       verified_by='fixture-ai-check',
       verifier_actor_type='ai_system',
       verified_at=TIMESTAMPTZ '2026-10-06 09:05:00+00'
 WHERE cycle_uuid='e5420000-0000-0000-0000-000000000002';

UPDATE product.currency_state
   SET record_status='superseded'
 WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000002';

INSERT INTO product.currency_state(
    currency_state_uuid,product_version_uuid,currency_status,
    assessed_at,assessed_by,rationale,
    supersedes_currency_state_uuid,record_status
) VALUES (
    'e5300000-0000-0000-0000-000000000003',
    'e5100000-0000-0000-0000-000000000003',
    'under_evaluation',TIMESTAMPTZ '2026-10-06 09:10:00+00',
    'fixture-ai',
    'Cycle 2 retained signals that require scientific evaluation',
    'e5300000-0000-0000-0000-000000000002','active'
);

INSERT INTO maintenance.cycle_currency_state(
    cycle_uuid,currency_state_uuid
) VALUES (
    'e5420000-0000-0000-0000-000000000002',
    'e5300000-0000-0000-0000-000000000003'
);

-- A2 for M2 formal Monitor.
INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,
    actor,actor_type,independent_flag,decision,performed_at,
    notes,evidence_payload,status
) VALUES
(
 'e5600000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000005',
 'ai_methodological_verification','fixture-ai','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-06 10:00:00+00',
 'Synthetic Monitor methodological verification',
 '{"fixture":true}'::jsonb,'active'
),
(
 'e5600000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000005',
 'owner_governance_approval','fixture-owner','owner',false,'approved',
 TIMESTAMPTZ '2026-10-06 10:05:00+00',
 'Synthetic governance approval for Monitor fixture',
 '{"fixture":true}'::jsonb,'active'
);

-- ---------------------------------------------------------------------------
-- M3 fixture: structurally complete but Phase 4 blocked.
-- Target is the scientific InvestigationVersion, so no target CurrencyState link.
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.monitor_definition(
    monitor_product_version_uuid,
    surveillance_scope_payload,source_policy_payload,
    strategy_policy_payload,cadence_policy_payload,
    impact_policy_payload,escalation_policy_payload
) VALUES (
    'e5100000-0000-0000-0000-000000000007',
    '{"population":"adults","intervention":"A","outcome":"O"}'::jsonb,
    '{
      "required_source_names":["PubMed"],
      "required_source_classes":["bibliographic"],
      "minimum_bibliographic_sources":1
    }'::jsonb,
    '{"mode":"living_incremental"}'::jsonb,
    '{"instance_interval":"weekly","phase4_default":false}'::jsonb,
    '{"dimensions":["conclusion","validity"]}'::jsonb,
    '{"alert_candidate_allowed":true,"severity_not_defined":true}'::jsonb
);

INSERT INTO maintenance.monitor_source_requirement(
    source_requirement_uuid,monitor_product_version_uuid,
    requirement_code,requirement_kind,required_value,minimum_count,
    allow_exception,rationale,sequence_no
) VALUES
(
 'e5450000-0000-0000-0000-000000000011',
 'e5100000-0000-0000-0000-000000000007',
 'pubmed_required','source_name','PubMed',NULL,true,
 'PubMed is prospectively required by the M3 fixture plan',1
),
(
 'e5450000-0000-0000-0000-000000000012',
 'e5100000-0000-0000-0000-000000000007',
 'bibliographic_class_required','source_class','bibliographic',NULL,true,
 'At least one bibliographic-class source is required',2
),
(
 'e5450000-0000-0000-0000-000000000013',
 'e5100000-0000-0000-0000-000000000007',
 'minimum_bibliographic_sources',
 'minimum_distinct_bibliographic_sources',NULL,1,true,
 'At least one distinct bibliographic source is required',3
);

INSERT INTO maintenance.monitor_target(
    monitor_target_uuid,monitor_product_version_uuid,
    target_investigation_version_uuid,rationale
) VALUES (
    'e5400000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000007',
    'e5100000-0000-0000-0000-000000000002',
    'M3 fixture monitors the concrete scientific InvestigationVersion'
);

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
    'e5100000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000007',
    'maintenance_surveillance_target',
    'monitor_target',
    'active'
);

INSERT INTO maintenance.monitor_state(
    monitor_state_uuid,monitor_product_version_uuid,
    operational_status,effective_at,rationale,changed_by,actor_type
) VALUES (
    'e5410000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000007',
    'active',TIMESTAMPTZ '2026-10-02 12:00:00+00',
    'Synthetic M3 monitor activated','fixture','system'
);

INSERT INTO maintenance.monitor_cycle(
    cycle_uuid,monitor_product_version_uuid,cycle_no,
    window_start_date,window_end_date,started_at,
    execution_status,completeness_status,verification_status
) VALUES (
    'e5420000-0000-0000-0000-000000000003',
    'e5100000-0000-0000-0000-000000000007',1,
    DATE '2026-10-02',DATE '2026-10-06',
    TIMESTAMPTZ '2026-10-06 07:00:00+00',
    'running','not_assessed','unverified'
);

INSERT INTO investigation.search(
    search_uuid,oes_search_id,investigation_version_uuid,
    source_name,platform,exact_strategy,filters_payload,
    executed_at,result_count,strategy_version,operator,status
) VALUES (
    'e5500000-0000-0000-0000-000000000003',
    'OES-SEARCH-2026-MON003',
    'e5100000-0000-0000-0000-000000000006',
    'PubMed','PubMed','("intervention A"[Title/Abstract])',
    '{"source_class":"bibliographic"}'::jsonb,
    TIMESTAMPTZ '2026-10-06 07:10:00+00',0,'v1','fixture','completed'
);

INSERT INTO maintenance.cycle_search(
    cycle_uuid,search_uuid,search_role,sequence_no
) VALUES (
    'e5420000-0000-0000-0000-000000000003',
    'e5500000-0000-0000-0000-000000000003',
    'primary',1
);

UPDATE maintenance.monitor_cycle
   SET completed_at=TIMESTAMPTZ '2026-10-06 07:30:00+00',
       execution_status='completed',
       completeness_status='complete',
       maintenance_decision='no_update_needed',
       decision_rationale='Synthetic complete living cycle.',
       escalation_recommendation='none',
       decided_by='fixture-ai',
       actor_type='ai_system',
       verification_status='ai_verified',
       verified_by='fixture-ai-check',
       verifier_actor_type='ai_system',
       verified_at=TIMESTAMPTZ '2026-10-06 07:35:00+00'
 WHERE cycle_uuid='e5420000-0000-0000-0000-000000000003';

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,
    actor,actor_type,independent_flag,decision,performed_at,
    notes,evidence_payload,status
) VALUES
(
 'e5600000-0000-0000-0000-000000000003',
 'e5100000-0000-0000-0000-000000000007',
 'ai_methodological_verification','fixture-ai','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-06 10:00:00+00',
 'Synthetic M3 methodological verification',
 '{"fixture":true}'::jsonb,'active'
),
(
 'e5600000-0000-0000-0000-000000000004',
 'e5100000-0000-0000-0000-000000000007',
 'owner_governance_approval','fixture-owner','owner',false,'approved',
 TIMESTAMPTZ '2026-10-06 10:05:00+00',
 'Synthetic M3 governance approval',
 '{"fixture":true}'::jsonb,'active'
);

COMMIT;
