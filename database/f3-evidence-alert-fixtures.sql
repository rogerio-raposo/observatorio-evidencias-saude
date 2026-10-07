-- F3 Evidence Alert synthetic fixtures
-- Requires migrations through 024 and f3-evidence-monitor-fixtures.sql.

BEGIN;

-- ---------------------------------------------------------------------------
-- Alert Product identities
-- ---------------------------------------------------------------------------

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by) VALUES
('a7000000-0000-0000-0000-000000000001','OES-P-2026-ALT001','Product','f3-alert'),
('a7000000-0000-0000-0000-000000000002','OES-P-2026-ALT002','Product','f3-alert'),
('a7000000-0000-0000-0000-000000000003','OES-P-2026-ALT003','Product','f3-alert');

INSERT INTO core.entity_version(
    version_uuid,entity_uuid,version_no,version_status,
    created_by,change_type,change_note
) VALUES
('a7100000-0000-0000-0000-000000000001','a7000000-0000-0000-0000-000000000001',1,'current','f3-alert','initial','Formal Monitor-derived Evidence Alert'),
('a7100000-0000-0000-0000-000000000002','a7000000-0000-0000-0000-000000000002',1,'current','f3-alert','initial','AI-only blocked Evidence Alert'),
('a7100000-0000-0000-0000-000000000003','a7000000-0000-0000-0000-000000000003',1,'current','f3-alert','initial','Direct-source critical Evidence Alert');

INSERT INTO product.product(entity_uuid) VALUES
('a7000000-0000-0000-0000-000000000001'),
('a7000000-0000-0000-0000-000000000002'),
('a7000000-0000-0000-0000-000000000003');

INSERT INTO product.product_version(
    version_uuid,entity_uuid,product_type,title,intended_audience,
    evidence_cutoff_date,publication_date,status,
    conclusion_text,applicability_summary,limitations_summary
) VALUES
(
 'a7100000-0000-0000-0000-000000000001',
 'a7000000-0000-0000-0000-000000000001',
 'evidence_alert','Synthetic Evidence Alert A','architecture_validation',
 DATE '2026-10-06',DATE '2026-10-06','published',
 NULL,NULL,
 'Synthetic alert generated from Monitor signals; classification is preliminary.'
),
(
 'a7100000-0000-0000-0000-000000000002',
 'a7000000-0000-0000-0000-000000000002',
 'evidence_alert','Synthetic Evidence Alert B AI-only','architecture_validation',
 DATE '2026-10-06',NULL,'under_review',
 NULL,NULL,
 'Synthetic blocked alert used to prove AI-only publication is not allowed.'
),
(
 'a7100000-0000-0000-0000-000000000003',
 'a7000000-0000-0000-0000-000000000003',
 'evidence_alert','Synthetic Evidence Alert C direct critical','architecture_validation',
 DATE '2026-10-06',DATE '2026-10-06','published',
 NULL,NULL,
 'Synthetic direct-source critical alert; no Phase-4 automatic rule is implied.'
);

-- Alert A/B context = Monitor Investigation; Alert C context = target scientific Investigation.
INSERT INTO product.investigation_link(
    product_version_uuid,investigation_version_uuid,role,sequence_no
) VALUES
('a7100000-0000-0000-0000-000000000001','e5100000-0000-0000-0000-000000000004','source_context',1),
('a7100000-0000-0000-0000-000000000002','e5100000-0000-0000-0000-000000000004','source_context',1),
('a7100000-0000-0000-0000-000000000003','e5100000-0000-0000-0000-000000000002','source_context',1);

-- ---------------------------------------------------------------------------
-- Specialized alert records
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.evidence_alert(
    alert_product_version_uuid,
    target_product_version_uuid,
    headline,summary,signal_date,detected_at,
    classification,reassessment_priority,lifecycle_status,
    justification,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    issued_at
) VALUES (
    'a7100000-0000-0000-0000-000000000001',
    'e5100000-0000-0000-0000-000000000003',
    'New evidence may affect the target conclusion and certainty',
    'A retained new-study signal and a regulatory event require scientific reassessment of the monitored target.',
    DATE '2026-10-06',TIMESTAMPTZ '2026-10-06 09:00:00+00',
    'relevant','priority','evaluation',
    'Monitor cycle 2 retained a quantitative candidate and a regulatory applicability signal; the Alert communicates potential impact without changing the target conclusion.',
    'fixture-ai','ai_system',
    'human_verified','fixture-reviewer','human_reviewer',
    TIMESTAMPTZ '2026-10-06 10:30:00+00',
    TIMESTAMPTZ '2026-10-06 11:00:00+00'
);

INSERT INTO maintenance.evidence_alert(
    alert_product_version_uuid,
    target_product_version_uuid,
    headline,summary,signal_date,detected_at,
    classification,reassessment_priority,lifecycle_status,
    justification,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
    'a7100000-0000-0000-0000-000000000002',
    'e5100000-0000-0000-0000-000000000003',
    'Informational signal awaiting human verification',
    'Synthetic AI-only Alert used to validate publication blockers.',
    DATE '2026-10-06',TIMESTAMPTZ '2026-10-06 09:05:00+00',
    'informational','routine','evaluation',
    'The signal is retained for internal review only and must not be formally published without human verification and A2.',
    'fixture-ai','ai_system',
    'ai_verified','fixture-ai-check','ai_system',
    TIMESTAMPTZ '2026-10-06 10:35:00+00'
);

INSERT INTO maintenance.evidence_alert(
    alert_product_version_uuid,
    target_investigation_version_uuid,
    headline,summary,signal_date,detected_at,
    classification,reassessment_priority,lifecycle_status,
    justification,assessed_by,actor_type,
    verification_status,verified_by,verifier_actor_type,verified_at,
    issued_at
) VALUES (
    'a7100000-0000-0000-0000-000000000003',
    'e5100000-0000-0000-0000-000000000002',
    'Critical source-validity signal requires urgent reassessment',
    'A direct external source reports a potentially material validity event affecting the scientific Investigation.',
    DATE '2026-10-06',TIMESTAMPTZ '2026-10-06 09:10:00+00',
    'critical','urgent','evaluation',
    'The classification is a preliminary communication label only; no automatic SLA, target update or expert-review claim is created in Phase 3.',
    'fixture-ai','ai_system',
    'human_verified','fixture-reviewer','human_reviewer',
    TIMESTAMPTZ '2026-10-06 10:40:00+00',
    TIMESTAMPTZ '2026-10-06 11:10:00+00'
);

-- ---------------------------------------------------------------------------
-- Sources
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.alert_source(
    alert_source_uuid,alert_product_version_uuid,
    source_role,source_type,candidate_assessment_uuid,
    source_date,description,sequence_no
) VALUES (
    'a7200000-0000-0000-0000-000000000001',
    'a7100000-0000-0000-0000-000000000001',
    'primary','candidate_assessment',
    'e5530000-0000-0000-0000-000000000002',
    DATE '2026-10-06',
    'Retained new-study candidate from Monitor cycle 2',1
);

INSERT INTO maintenance.alert_source(
    alert_source_uuid,alert_product_version_uuid,
    source_role,source_type,evidence_event_uuid,
    source_date,description,sequence_no
) VALUES (
    'a7200000-0000-0000-0000-000000000002',
    'a7100000-0000-0000-0000-000000000001',
    'supporting','evidence_event',
    'e5520000-0000-0000-0000-000000000001',
    DATE '2026-10-05',
    'Supporting regulatory EvidenceEvent from the same Monitor cycle',2
);

INSERT INTO maintenance.alert_source(
    alert_source_uuid,alert_product_version_uuid,
    source_role,source_type,evidence_event_uuid,
    source_date,description,sequence_no
) VALUES (
    'a7200000-0000-0000-0000-000000000003',
    'a7100000-0000-0000-0000-000000000002',
    'primary','evidence_event',
    'e5520000-0000-0000-0000-000000000001',
    DATE '2026-10-05',
    'AI-only internal Alert source',1
);

INSERT INTO maintenance.alert_source(
    alert_source_uuid,alert_product_version_uuid,
    source_role,source_type,source_uri,
    source_date,description,sequence_no
) VALUES (
    'a7200000-0000-0000-0000-000000000004',
    'a7100000-0000-0000-0000-000000000003',
    'primary','uri',
    'https://example.invalid/direct-critical-alert-fixture',
    DATE '2026-10-06',
    'Direct external validity signal used only for architecture validation',1
);

-- ---------------------------------------------------------------------------
-- Affected dimensions
-- ---------------------------------------------------------------------------

INSERT INTO maintenance.alert_affected_dimension(
    alert_product_version_uuid,dimension_code,rationale,sequence_no
) VALUES
('a7100000-0000-0000-0000-000000000001','conclusion','Potential change in target conclusion requires evaluation',1),
('a7100000-0000-0000-0000-000000000001','certainty','New evidence may alter certainty',2),
('a7100000-0000-0000-0000-000000000002','applicability','Internal signal may affect applicability',1),
('a7100000-0000-0000-0000-000000000003','validity','Direct signal may affect validity of the scientific evidence base',1),
('a7100000-0000-0000-0000-000000000003','regulatory_status','Direct signal has regulatory relevance',2);

-- ---------------------------------------------------------------------------
-- Target dependency lineage
-- ---------------------------------------------------------------------------

INSERT INTO provenance.dependency_edge(
    source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES
(
 'e5100000-0000-0000-0000-000000000003',
 'a7100000-0000-0000-0000-000000000001',
 'maintenance_alert_target','alert_target','active'
),
(
 'e5100000-0000-0000-0000-000000000003',
 'a7100000-0000-0000-0000-000000000002',
 'maintenance_alert_target','alert_target','active'
),
(
 'e5100000-0000-0000-0000-000000000002',
 'a7100000-0000-0000-0000-000000000003',
 'maintenance_alert_target','alert_target','active'
);

-- ---------------------------------------------------------------------------
-- Assurance
-- ---------------------------------------------------------------------------

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,
    actor,actor_type,independent_flag,decision,performed_at,
    notes,evidence_payload,status
) VALUES
(
 'a7600000-0000-0000-0000-000000000001',
 'a7100000-0000-0000-0000-000000000001',
 'ai_methodological_verification','fixture-alert-ai','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-06 10:45:00+00',
 'Synthetic AI verification of Alert traceability and communication contract',
 '{"fixture":true}'::jsonb,'active'
),
(
 'a7600000-0000-0000-0000-000000000002',
 'a7100000-0000-0000-0000-000000000001',
 'owner_governance_approval','fixture-owner','owner',false,'approved',
 TIMESTAMPTZ '2026-10-06 10:50:00+00',
 'Synthetic owner governance approval for formal Alert A',
 '{"fixture":true}'::jsonb,'active'
),
(
 'a7600000-0000-0000-0000-000000000003',
 'a7100000-0000-0000-0000-000000000002',
 'ai_methodological_verification','fixture-alert-ai','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-06 10:45:00+00',
 'Synthetic AI verification only; deliberately no owner approval',
 '{"fixture":true}'::jsonb,'active'
),
(
 'a7600000-0000-0000-0000-000000000004',
 'a7100000-0000-0000-0000-000000000003',
 'ai_methodological_verification','fixture-alert-ai','ai_system',false,'passed',
 TIMESTAMPTZ '2026-10-06 10:45:00+00',
 'Synthetic AI verification for direct critical Alert',
 '{"fixture":true}'::jsonb,'active'
),
(
 'a7600000-0000-0000-0000-000000000005',
 'a7100000-0000-0000-0000-000000000003',
 'owner_governance_approval','fixture-owner','owner',false,'approved',
 TIMESTAMPTZ '2026-10-06 10:50:00+00',
 'Synthetic owner governance approval; not expert review',
 '{"fixture":true}'::jsonb,'active'
);

COMMIT;
