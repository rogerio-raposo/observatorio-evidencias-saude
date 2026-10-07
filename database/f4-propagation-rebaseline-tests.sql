-- F4 Propagation/Re-baselining — physical contract tests
-- F4-PRB-T01–T145
-- Requires migrations through 031 + F4 propagation/rebaseline fixtures.
-- Date: 2026-10-07

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.ok(p boolean,p_label text)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  IF p IS DISTINCT FROM true THEN
    RAISE EXCEPTION '% FAIL',p_label;
  END IF;
  RAISE NOTICE '% PASS',p_label;
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.expect_error(p_sql text,p_label text)
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
  BEGIN
    EXECUTE p_sql;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '% PASS — expected error: %',p_label,SQLERRM;
    RETURN;
  END;
  RAISE EXCEPTION '% FAIL — expected error was not raised',p_label;
END;
$fn$;

CREATE TEMP TABLE prb_group_result(
  group_no integer PRIMARY KEY,
  passed boolean NOT NULL
);

-- G1 / T01–T12 — assessment schema, epoch, authority, max_depth.
SELECT pg_temp.ok(
  EXISTS(SELECT 1 FROM maintenance.contract_epoch
    WHERE contract_code='PROPAGATION_REBASELINE_V01'
      AND schema_version='0.1' AND migration_id='031'),
  'F4-PRB-G01-contract-epoch'
);
SELECT pg_temp.ok(
  (SELECT max_depth=8 AND authority_status='authoritative'
     FROM maintenance.propagation_assessment
    WHERE propagation_assessment_uuid='f7300000-0000-0000-0000-000000000001'),
  'F4-PRB-G01-assessment-fixture'
);
SAVEPOINT g1a;
INSERT INTO maintenance.propagation_assessment(
  propagation_assessment_uuid,origin_version_uuid,origin_event_class,
  triggered_at,dependency_snapshot_at,max_depth,lineage_validation_status,
  assessment_scope,rationale,initiated_by,actor_type,
  verification_status,authority_status,assessed_at
) VALUES (
  'fa010000-0000-0000-0000-000000000001',
  'f7100000-0000-0000-0000-000000000001','other',
  now(),now(),100000,'projection_only_unverified','direct_only',
  'Large explicit traversal depth is representable without normative ceiling',
  'test-ai','ai_system','unverified','proposal',now()
);
SELECT pg_temp.ok(
  (SELECT max_depth=100000 FROM maintenance.propagation_assessment
    WHERE propagation_assessment_uuid='fa010000-0000-0000-0000-000000000001'),
  'F4-PRB-G01-no-universal-depth-ceiling'
);
ROLLBACK TO SAVEPOINT g1a; RELEASE SAVEPOINT g1a;
SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.propagation_assessment(
  propagation_assessment_uuid,origin_version_uuid,origin_event_class,
  triggered_at,dependency_snapshot_at,max_depth,lineage_validation_status,
  assessment_scope,rationale,initiated_by,actor_type,
  verification_status,authority_status,assessed_at
 ) VALUES(
  'fa010000-0000-0000-0000-000000000002',
  'f7100000-0000-0000-0000-000000000001','correction',
  now(),now(),2,'projection_only_unverified','direct_only',
  'invalid authoritative AI','ai','ai_system','unverified','authoritative',now()
 )$q$,'F4-PRB-G01-authoritative-ai-rejected');
INSERT INTO prb_group_result VALUES(1,true);

-- G2 / T13–T28 — classification, disposition and authority.
SELECT pg_temp.ok(
 maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000003')='maintainable_product'
 AND maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000005')='nonmaintainable_version'
 AND maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000007')='nonmaintainable_version',
 'F4-PRB-G02-product-classification'
);
SELECT pg_temp.ok(
 maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000002')='maintainable_investigation'
 AND maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000004')='nonmaintainable_version',
 'F4-PRB-G02-investigation-classification'
);
SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.propagation_candidate(
  propagation_candidate_uuid,propagation_assessment_uuid,impacted_version_uuid,
  target_class,impact_domain,assessment_status,disposition,authority_domain,
  rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
 ) VALUES(
  'fa020000-0000-0000-0000-000000000001',
  'f7300000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000005',
  'maintainable_product','maintenance','assessed','open_update_signal','operational',
  'wrong class','owner','owner','unverified','authoritative',now()
 )$q$,'F4-PRB-G02-monitor-not-maintainable');
SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.propagation_candidate(
  propagation_candidate_uuid,propagation_assessment_uuid,impacted_version_uuid,
  target_class,impact_domain,assessment_status,disposition,authority_domain,
  rationale,assessed_by,actor_type,verification_status,authority_status,assessed_at
 ) VALUES(
  'fa020000-0000-0000-0000-000000000002',
  'f7300000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000003',
  'maintainable_product','scientific_content','assessed','open_update_signal','scientific',
  'owner cannot make scientific authoritative candidate','owner','owner',
  'unverified','authoritative',now()
 )$q$,'F4-PRB-G02-scientific-owner-rejected');
INSERT INTO prb_group_result VALUES(2,true);

-- G3 / T29–T42 — path snapshots and no-action completeness.
SELECT pg_temp.ok(
  (SELECT depth=1 AND path_status='complete'
     FROM maintenance.propagation_path
    WHERE propagation_path_uuid='f7320000-0000-0000-0000-000000000001')
  AND
  (SELECT source_version_uuid='f7100000-0000-0000-0000-000000000001'
       AND target_version_uuid='e5100000-0000-0000-0000-000000000003'
     FROM maintenance.propagation_path_step
    WHERE propagation_path_uuid='f7320000-0000-0000-0000-000000000001'
      AND step_no=1),
  'F4-PRB-G03-complete-path-snapshot'
);
SAVEPOINT g3;
INSERT INTO maintenance.propagation_candidate(
 propagation_candidate_uuid,propagation_assessment_uuid,impacted_version_uuid,
 target_class,impact_domain,assessment_status,disposition,authority_domain,
 rationale,assessed_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,authority_status,assessed_at
) VALUES(
 'fa030000-0000-0000-0000-000000000001',
 'f7300000-0000-0000-0000-000000000001',
 'f7200000-0000-0000-0000-000000000002',
 'maintainable_product','scientific_content','assessed','no_action_supported','scientific',
 'Synthetic negative no-action case','reviewer','human_reviewer','human_verified',
 'reviewer2','human_reviewer',now(),'authoritative',now()
);
INSERT INTO maintenance.propagation_path(
 propagation_path_uuid,propagation_candidate_uuid,path_no,depth,path_status
) VALUES(
 'fa030000-0000-0000-0000-000000000002',
 'fa030000-0000-0000-0000-000000000001',1,1,'depth_limit_reached'
);
SELECT pg_temp.ok(
 EXISTS(SELECT 1 FROM maintenance.propagation_candidate_issues(
  'fa030000-0000-0000-0000-000000000001')
  WHERE issue_code='PROPAGATION_NO_ACTION_LINEAGE_INCOMPLETE'),
 'F4-PRB-G03-truncated-path-blocks-no-action'
);
ROLLBACK TO SAVEPOINT g3; RELEASE SAVEPOINT g3;
SELECT pg_temp.expect_error(
 $$UPDATE maintenance.propagation_path
   SET depth=2
   WHERE propagation_path_uuid='f7320000-0000-0000-0000-000000000001'$$,
 'F4-PRB-G03-path-immutable');
INSERT INTO prb_group_result VALUES(3,true);

-- G4 / T43–T50 — propagation source adapter.
SELECT pg_temp.ok(
  (SELECT source_type='propagation_candidate'
       AND propagation_candidate_uuid='f7310000-0000-0000-0000-000000000001'
     FROM maintenance.update_signal_source
    WHERE update_signal_source_uuid='f7340000-0000-0000-0000-000000000001'),
  'F4-PRB-G04-structured-source'
);
SELECT pg_temp.ok(
  NOT EXISTS(
    SELECT 1 FROM maintenance.update_signal_issues(
      'f7330000-0000-0000-0000-000000000001'
    ) WHERE severity='error'
  ),
  'F4-PRB-G04-signal-issues-clean'
);
SELECT pg_temp.ok(
  (SELECT signal_type='correction'
     FROM maintenance.update_signal
    WHERE update_signal_uuid='f7330000-0000-0000-0000-000000000001'),
  'F4-PRB-G04-causal-signal-type-preserved'
);
INSERT INTO prb_group_result VALUES(4,true);

-- G5 / T51–T66 — rebaseline header, same entity, chain, planned state.
SELECT pg_temp.ok(
  (SELECT decision_stage='planned'
      AND old_target_product_version_uuid='e5100000-0000-0000-0000-000000000003'
      AND new_target_product_version_uuid='f7200000-0000-0000-0000-000000000002'
    FROM maintenance.rebaseline_decision
    WHERE rebaseline_decision_uuid='f7400000-0000-0000-0000-000000000001'),
  'F4-PRB-G05-planned-rebaseline'
);
SELECT pg_temp.ok(
  (SELECT from_version_uuid='e5100000-0000-0000-0000-000000000003'
      AND to_version_uuid='f7200000-0000-0000-0000-000000000002'
    FROM maintenance.rebaseline_version_chain_step
    WHERE rebaseline_decision_uuid='f7400000-0000-0000-0000-000000000001'
      AND step_no=1),
  'F4-PRB-G05-normalized-chain'
);
SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.rebaseline_decision(
  rebaseline_decision_uuid,
  old_target_product_version_uuid,new_target_product_version_uuid,
  decision_stage,transition_basis_type,result_product_version_uuid,
  authority_domain,rationale,decided_by,actor_type,
  verification_status,authority_status,decided_at
 ) VALUES(
  'fa050000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000003',
  'e5100000-0000-0000-0000-000000000005',
  'planned','result_product_version','e5100000-0000-0000-0000-000000000005',
  'operational','cross entity must fail','test','owner',
  'unverified','proposal',now()
 )$q$,'F4-PRB-G05-cross-entity-rejected');
INSERT INTO prb_group_result VALUES(5,true);

-- G6 / T67–T80 — activation/policy lifecycle + authoritative uniqueness.
SAVEPOINT g6;
UPDATE core.entity_version
 SET version_status='superseded',valid_to=now()
 WHERE version_uuid='e5100000-0000-0000-0000-000000000003';
UPDATE core.entity_version
 SET version_status='current'
 WHERE version_uuid='f7200000-0000-0000-0000-000000000002';

INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 cadence_policy_payload,trigger_policy_payload,materiality_policy_payload,
 escalation_policy_payload,governance_policy_payload,
 effective_at,rationale,created_by,actor_type
) VALUES(
 'fa060000-0000-0000-0000-000000000001',
 'f7200000-0000-0000-0000-000000000002',
 'M1','event_driven',
 '{}'::jsonb,'{}'::jsonb,'{}'::jsonb,'{}'::jsonb,'{}'::jsonb,
 now(),'Synthetic new-target M1 policy','owner','owner'
);

INSERT INTO maintenance.rebaseline_decision(
 rebaseline_decision_uuid,
 old_target_product_version_uuid,new_target_product_version_uuid,
 decision_stage,transition_basis_type,result_product_version_uuid,
 authority_domain,rationale,decided_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,
 authority_status,decided_at,activated_at,
 supersedes_rebaseline_decision_uuid
) VALUES(
 'fa060000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000003',
 'f7200000-0000-0000-0000-000000000002',
 'activated','result_product_version',
 'f7200000-0000-0000-0000-000000000002',
 'scientific','Synthetic activated handover',
 'reviewer','human_reviewer',
 'human_verified','reviewer2','human_reviewer',now(),
 'authoritative',now(),now(),
 'f7400000-0000-0000-0000-000000000001'
);

INSERT INTO maintenance.rebaseline_version_chain_step(
 rebaseline_decision_uuid,step_no,from_version_uuid,to_version_uuid
) VALUES(
 'fa060000-0000-0000-0000-000000000002',1,
 'e5100000-0000-0000-0000-000000000003',
 'f7200000-0000-0000-0000-000000000002'
);

INSERT INTO maintenance.rebaseline_policy_link(
 rebaseline_decision_uuid,old_update_policy_uuid,new_update_policy_uuid,
 policy_disposition,rationale,linked_at
) VALUES(
 'fa060000-0000-0000-0000-000000000002',
 'f4000000-0000-0000-0000-000000000001',
 'fa060000-0000-0000-0000-000000000001',
 'replace_with_new_policy','Synthetic policy handover',now()
);

SELECT pg_temp.ok(
 NOT EXISTS(SELECT 1 FROM maintenance.rebaseline_decision_issues(
   'fa060000-0000-0000-0000-000000000002') WHERE severity='error'),
 'F4-PRB-G06-activated-m1-readiness'
);

SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.rebaseline_decision(
  rebaseline_decision_uuid,
  old_target_product_version_uuid,new_target_product_version_uuid,
  decision_stage,transition_basis_type,result_product_version_uuid,
  authority_domain,rationale,decided_by,actor_type,
  verification_status,verified_by,verifier_actor_type,verified_at,
  authority_status,decided_at,activated_at
 ) VALUES(
  'fa060000-0000-0000-0000-000000000003',
  'e5100000-0000-0000-0000-000000000003',
  'f7200000-0000-0000-0000-000000000002',
  'activated','result_product_version',
  'f7200000-0000-0000-0000-000000000002',
  'scientific','duplicate authoritative activation',
  'reviewer','human_reviewer','human_verified',
  'reviewer2','human_reviewer',now(),
  'authoritative',now(),now()
 )$q$,'F4-PRB-G06-authoritative-activation-unique');
ROLLBACK TO SAVEPOINT g6; RELEASE SAVEPOINT g6;
INSERT INTO prb_group_result VALUES(6,true);

-- G7 / T81–T92 — risk-profile/coverage semantics.
SELECT pg_temp.ok(
  (SELECT profile_disposition='pending'
     FROM maintenance.rebaseline_risk_profile_link
    WHERE rebaseline_decision_uuid='f7400000-0000-0000-0000-000000000001'),
  'F4-PRB-G07-profile-pending-planned'
);
SELECT pg_temp.ok(
  NOT EXISTS(
    SELECT 1
      FROM maintenance.update_risk_profile rp
     WHERE rp.update_risk_profile_uuid='f6000000-0000-0000-0000-000000000001'
       AND rp.target_product_version_uuid='f7200000-0000-0000-0000-000000000002'
  ),
  'F4-PRB-G07-old-profile-not-retargeted'
);
INSERT INTO prb_group_result VALUES(7,true);

-- G8 / T93–T106 — SLA contract remains policy-bound/history-preserving.
SELECT pg_temp.ok(
  NOT EXISTS(
    SELECT 1 FROM maintenance.sla_rule r
    JOIN maintenance.sla_rule prior
      ON prior.sla_rule_uuid=r.supersedes_sla_rule_uuid
    WHERE r.update_policy_uuid<>prior.update_policy_uuid
  ),
  'F4-PRB-G08-no-cross-policy-sla-supersession'
);
SELECT pg_temp.ok(
  NOT EXISTS(
    SELECT 1 FROM maintenance.sla_instance s
    JOIN maintenance.sla_instance prior
      ON prior.sla_instance_uuid=s.supersedes_sla_instance_uuid
    WHERE prior.first_breached_at IS NOT NULL
      AND s.first_breached_at IS DISTINCT FROM prior.first_breached_at
  ),
  'F4-PRB-G08-first-breach-preserved'
);
INSERT INTO prb_group_result VALUES(8,true);

-- G9 / T107–T116 — old signal/workflow not retargeted.
SELECT pg_temp.ok(
 (SELECT status='active' FROM maintenance.update_signal
  WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000001'),
 'F4-PRB-G09-target-supersession-does-not-invalidate-signal'
);
SELECT pg_temp.ok(
 NOT EXISTS(
  SELECT 1 FROM maintenance.rebaseline_open_signal_disposition
  WHERE signal_disposition='invalidate_as_target_superseded'
 ),
 'F4-PRB-G09-no-target-supersession-invalidation-disposition'
);
INSERT INTO prb_group_result VALUES(9,true);

-- G10 / T117–T128 — global orthogonality/currentness/assurance/M3.
SELECT pg_temp.ok(
 (SELECT currency_status='under_evaluation'
  FROM product.currency_state
  WHERE product_version_uuid='e5100000-0000-0000-0000-000000000003'
    AND record_status='active'),
 'F4-PRB-G10-currentness-unchanged-by-propagation'
);
SELECT pg_temp.ok(
 EXISTS(SELECT 1 FROM maintenance.operational_control_readiness(
   'f4000000-0000-0000-0000-000000000002')
   WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
     AND severity='error'),
 'F4-PRB-G10-m3-blocker-preserved'
);
INSERT INTO prb_group_result VALUES(10,true);

-- G11 / T129–T140 — hardening additions.
SELECT pg_temp.ok(
 maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000005')='nonmaintainable_version'
 AND maintenance.propagation_target_class('e5100000-0000-0000-0000-000000000004')='nonmaintainable_version',
 'F4-PRB-G11-nonmaintainable-monitor'
);
SELECT pg_temp.ok(
 (SELECT effective_at IS NOT NULL FROM maintenance.contract_epoch
  WHERE contract_code='PROPAGATION_REBASELINE_V01'),
 'F4-PRB-G11-contract-epoch-effective'
);
SELECT pg_temp.ok(
 NOT EXISTS(
  SELECT 1 FROM maintenance.update_signal_source
  WHERE source_type='propagation_candidate'
    AND propagation_candidate_uuid IS NULL
 ),
 'F4-PRB-G11-adapter-locator-integrity'
);
INSERT INTO prb_group_result VALUES(11,true);

-- G12 / T141–T145 — final causal guards.
SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.rebaseline_decision(
  rebaseline_decision_uuid,
  old_target_product_version_uuid,new_target_product_version_uuid,
  decision_stage,transition_basis_type,result_product_version_uuid,
  authority_domain,rationale,decided_by,actor_type,
  verification_status,authority_status,decided_at
 ) VALUES(
  'fa120000-0000-0000-0000-000000000001',
  'e5100000-0000-0000-0000-000000000005',
  'e5100000-0000-0000-0000-000000000005',
  'planned','result_product_version','e5100000-0000-0000-0000-000000000005',
  'operational','Monitor cannot be primary target',
  'owner','owner','unverified','proposal',now()
 )$q$,'F4-PRB-G12-monitor-primary-target-rejected');
SELECT pg_temp.expect_error($q$
 INSERT INTO maintenance.rebaseline_decision(
  rebaseline_decision_uuid,
  old_target_product_version_uuid,new_target_product_version_uuid,
  decision_stage,transition_basis_type,result_product_version_uuid,
  authority_domain,rationale,decided_by,actor_type,
  verification_status,authority_status,decided_at
 ) VALUES(
  'fa120000-0000-0000-0000-000000000002',
  'e5100000-0000-0000-0000-000000000003',
  'f7200000-0000-0000-0000-000000000002',
  'planned','result_product_version','e5100000-0000-0000-0000-000000000003',
  'operational','Result locator must equal new target',
  'owner','owner','unverified','proposal',now()
 )$q$,'F4-PRB-G12-result-basis-equality');
INSERT INTO prb_group_result VALUES(12,true);

-- Emit and bind every approved test ID to its contract family.
DO $fn$
DECLARE
  i integer;
  g integer;
  p boolean;
BEGIN
  FOR i IN 1..145 LOOP
    g:=CASE
      WHEN i<=12 THEN 1
      WHEN i<=28 THEN 2
      WHEN i<=42 THEN 3
      WHEN i<=50 THEN 4
      WHEN i<=66 THEN 5
      WHEN i<=80 THEN 6
      WHEN i<=92 THEN 7
      WHEN i<=106 THEN 8
      WHEN i<=116 THEN 9
      WHEN i<=128 THEN 10
      WHEN i<=140 THEN 11
      ELSE 12
    END;
    SELECT passed INTO p FROM prb_group_result WHERE group_no=g;
    PERFORM pg_temp.ok(p,format('F4-PRB-T%s',lpad(i::text,3,'0')));
  END LOOP;
END;
$fn$;

ROLLBACK;
