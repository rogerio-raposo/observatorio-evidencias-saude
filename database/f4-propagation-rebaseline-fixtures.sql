-- F4 Propagation/Re-baselining synthetic fixtures
-- Requires migrations through 031 plus F3 Monitor/Alert and F4 update/risk fixtures.
-- All records are synthetic. No normative policy defaults.
-- Date: 2026-10-07

BEGIN;

-- Synthetic upstream version used only for propagation tests.
INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES (
  'f7000000-0000-0000-0000-000000000001',
  'OES-TST-PRB-UPSTREAM-001',
  'synthetic_dependency_source',
  'f4-prb-fixture'
)
ON CONFLICT (entity_uuid) DO NOTHING;

INSERT INTO core.entity_version(
  version_uuid,entity_uuid,version_no,version_status,
  supersedes_version_uuid,created_by,change_type,change_note
) VALUES (
  'f7100000-0000-0000-0000-000000000001',
  'f7000000-0000-0000-0000-000000000001',
  1,'current',NULL,
  'f4-prb-fixture','initial',
  'Synthetic upstream version for propagation tests'
)
ON CONFLICT (version_uuid) DO NOTHING;

INSERT INTO provenance.dependency_edge(
  source_version_uuid,target_version_uuid,dependency_type,derivation_rule,status
) VALUES (
  'f7100000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000003',
  'synthetic_prb_dependency',
  'f4-prb-fixture',
  'active'
)
ON CONFLICT (source_version_uuid,target_version_uuid,dependency_type) DO NOTHING;

-- Prospective same-entity ProductVersion. It remains draft so prior regressions keep
-- the established target current until individual tests temporarily switch state.
INSERT INTO core.entity_version(
  version_uuid,entity_uuid,version_no,version_status,
  supersedes_version_uuid,created_by,change_type,change_note
)
SELECT
  'f7200000-0000-0000-0000-000000000002',
  ev.entity_uuid,2,'draft',
  'e5100000-0000-0000-0000-000000000003',
  'f4-prb-fixture','new_evidence',
  'Synthetic prospective target version for rebaseline tests'
FROM core.entity_version ev
WHERE ev.version_uuid='e5100000-0000-0000-0000-000000000003'
ON CONFLICT (version_uuid) DO NOTHING;

INSERT INTO product.product_version(
  version_uuid,entity_uuid,product_type,title,intended_audience,
  evidence_cutoff_date,publication_date,status,
  conclusion_text,applicability_summary,limitations_summary
)
SELECT
  'f7200000-0000-0000-0000-000000000002',
  pv.entity_uuid,pv.product_type,
  pv.title||' — prospective v2',
  pv.intended_audience,
  DATE '2026-10-06',NULL,'draft',
  pv.conclusion_text,pv.applicability_summary,pv.limitations_summary
FROM product.product_version pv
WHERE pv.version_uuid='e5100000-0000-0000-0000-000000000003'
ON CONFLICT (version_uuid) DO NOTHING;

-- Authoritative propagation assessment and candidate for the existing maintained target.
INSERT INTO maintenance.propagation_assessment(
  propagation_assessment_uuid,origin_version_uuid,
  origin_event_class,triggered_at,dependency_snapshot_at,max_depth,
  lineage_validation_status,lineage_validation_payload,assessment_scope,
  rationale,initiated_by,actor_type,
  verification_status,verified_by,verifier_actor_type,verified_at,
  authority_status,assessed_at
) VALUES (
  'f7300000-0000-0000-0000-000000000001',
  'f7100000-0000-0000-0000-000000000001',
  'correction',
  TIMESTAMPTZ '2026-10-07 03:10:00+00',
  TIMESTAMPTZ '2026-10-07 03:11:00+00',
  8,
  'validated_against_canonical_relations',
  '{"fixture":true,"canonical_relations_checked":true}'::jsonb,
  'transitive',
  'Synthetic propagation assessment for contract tests',
  'fixture-reviewer','human_reviewer',
  'human_verified','fixture-reviewer-2','human_reviewer',
  TIMESTAMPTZ '2026-10-07 03:12:00+00',
  'authoritative',
  TIMESTAMPTZ '2026-10-07 03:13:00+00'
)
ON CONFLICT (propagation_assessment_uuid) DO NOTHING;

INSERT INTO maintenance.propagation_candidate(
  propagation_candidate_uuid,propagation_assessment_uuid,
  impacted_version_uuid,target_class,impact_domain,
  assessment_status,disposition,authority_domain,
  rationale,assessed_by,actor_type,
  verification_status,verified_by,verifier_actor_type,verified_at,
  authority_status,assessed_at
) VALUES (
  'f7310000-0000-0000-0000-000000000001',
  'f7300000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000003',
  'maintainable_product','currentness_review',
  'assessed','open_update_signal','scientific',
  'Synthetic qualified candidate requiring a local update signal',
  'fixture-reviewer','human_reviewer',
  'human_verified','fixture-reviewer-2','human_reviewer',
  TIMESTAMPTZ '2026-10-07 03:14:00+00',
  'authoritative',
  TIMESTAMPTZ '2026-10-07 03:15:00+00'
)
ON CONFLICT (propagation_candidate_uuid) DO NOTHING;

INSERT INTO maintenance.propagation_path(
  propagation_path_uuid,propagation_candidate_uuid,path_no,depth,path_status
) VALUES (
  'f7320000-0000-0000-0000-000000000001',
  'f7310000-0000-0000-0000-000000000001',
  1,1,'complete'
)
ON CONFLICT (propagation_path_uuid) DO NOTHING;

INSERT INTO maintenance.propagation_path_step(
  propagation_path_uuid,step_no,source_version_uuid,target_version_uuid,
  dependency_type,derivation_rule,edge_created_at,edge_status_at_snapshot
)
SELECT
  'f7320000-0000-0000-0000-000000000001',1,
  de.source_version_uuid,de.target_version_uuid,
  de.dependency_type,de.derivation_rule,de.created_at,de.status
FROM provenance.dependency_edge de
WHERE de.source_version_uuid='f7100000-0000-0000-0000-000000000001'
  AND de.target_version_uuid='e5100000-0000-0000-0000-000000000003'
  AND de.dependency_type='synthetic_prb_dependency'
ON CONFLICT (propagation_path_uuid,step_no) DO NOTHING;

-- New local signal remains independent from the upstream event.
INSERT INTO maintenance.update_signal(
  update_signal_uuid,update_policy_uuid,
  signal_class,trigger_class,signal_type,
  signal_date,detected_at,summary,rationale,
  detected_by,actor_type,verification_status,
  verified_by,verifier_actor_type,verified_at
) VALUES (
  'f7330000-0000-0000-0000-000000000001',
  'f4000000-0000-0000-0000-000000000001',
  'scientific_currentness','integrity_validity','correction',
  DATE '2026-10-07',
  TIMESTAMPTZ '2026-10-07 03:16:00+00',
  'Synthetic downstream signal opened from propagation assessment',
  'Causal signal type remains correction rather than generic propagation',
  'fixture-reviewer','human_reviewer',
  'human_verified','fixture-reviewer-2','human_reviewer',
  TIMESTAMPTZ '2026-10-07 03:17:00+00'
)
ON CONFLICT (update_signal_uuid) DO NOTHING;

INSERT INTO maintenance.update_signal_source(
  update_signal_source_uuid,update_signal_uuid,
  source_role,source_type,propagation_candidate_uuid,
  note,sequence_no
) VALUES (
  'f7340000-0000-0000-0000-000000000001',
  'f7330000-0000-0000-0000-000000000001',
  'primary','propagation_candidate',
  'f7310000-0000-0000-0000-000000000001',
  'Synthetic structured propagation source',1
)
ON CONFLICT (update_signal_source_uuid) DO NOTHING;

-- Planned rebaseline snapshot. No policy/Monitor retargeting occurs.
INSERT INTO maintenance.rebaseline_decision(
  rebaseline_decision_uuid,
  old_target_product_version_uuid,new_target_product_version_uuid,
  decision_stage,transition_basis_type,result_product_version_uuid,
  version_chain_summary_payload,authority_domain,
  rationale,decided_by,actor_type,verification_status,
  authority_status,decided_at
) VALUES (
  'f7400000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000003',
  'f7200000-0000-0000-0000-000000000002',
  'planned','result_product_version',
  'f7200000-0000-0000-0000-000000000002',
  '{"schema_version":"oes.rebaseline_chain/0.1","fixture":true}'::jsonb,
  'scientific',
  'Synthetic planned handover; no activation implied',
  'fixture-ai','ai_system','ai_verified',
  'fixture-ai-verifier','ai_system',TIMESTAMPTZ '2026-10-07 03:19:30+00',
  'proposal',TIMESTAMPTZ '2026-10-07 03:20:00+00'
)
ON CONFLICT (rebaseline_decision_uuid) DO NOTHING;

INSERT INTO maintenance.rebaseline_version_chain_step(
  rebaseline_decision_uuid,step_no,from_version_uuid,to_version_uuid
) VALUES (
  'f7400000-0000-0000-0000-000000000001',
  1,
  'e5100000-0000-0000-0000-000000000003',
  'f7200000-0000-0000-0000-000000000002'
)
ON CONFLICT (rebaseline_decision_uuid,step_no) DO NOTHING;

INSERT INTO maintenance.rebaseline_policy_link(
  rebaseline_decision_uuid,old_update_policy_uuid,new_update_policy_uuid,
  policy_disposition,rationale,linked_at
) VALUES (
  'f7400000-0000-0000-0000-000000000001',
  'f4000000-0000-0000-0000-000000000001',
  NULL,
  'pending',
  'Synthetic planned handover intentionally has no new policy yet',
  TIMESTAMPTZ '2026-10-07 03:21:00+00'
)
ON CONFLICT (rebaseline_decision_uuid) DO NOTHING;

INSERT INTO maintenance.rebaseline_risk_profile_link(
  rebaseline_decision_uuid,
  source_update_risk_profile_uuid,target_update_risk_profile_uuid,
  profile_disposition,rationale,linked_at
) VALUES (
  'f7400000-0000-0000-0000-000000000001',
  'f6000000-0000-0000-0000-000000000001',
  NULL,
  'pending',
  'Synthetic planned handover intentionally leaves new-target profile unresolved',
  TIMESTAMPTZ '2026-10-07 03:22:00+00'
)
ON CONFLICT (rebaseline_decision_uuid) DO NOTHING;

COMMIT;
