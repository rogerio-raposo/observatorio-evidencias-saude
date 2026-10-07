-- F4 Transversal Update Protocol tests
-- Requires migration 027 + F3 Monitor/Alert fixtures + f4-update-protocol-fixtures.sql.

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.assert_true(
    p_condition boolean,
    p_label text
)
RETURNS void
LANGUAGE plpgsql
AS $fn$
BEGIN
    IF p_condition IS DISTINCT FROM true THEN
        RAISE EXCEPTION '% FAIL',p_label;
    END IF;
END;
$fn$;

CREATE OR REPLACE FUNCTION pg_temp.expect_error(
    p_sql text,
    p_label text
)
RETURNS void
LANGUAGE plpgsql
AS $fn$
BEGIN
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        RETURN;
    END;
    RAISE EXCEPTION '% FAIL — expected error was not raised',p_label;
END;
$fn$;

-- F4-UP-T01 — seven new contract tables exist.
SELECT pg_temp.assert_true(
    (SELECT count(*)=7
       FROM information_schema.tables
      WHERE table_schema='maintenance'
        AND table_name IN (
            'update_policy','update_signal','update_signal_source',
            'materiality_assessment','materiality_dimension',
            'update_decision','update_decision_currency_state'
        )),
    'F4-UP-T01'
);

-- F4-UP-T02 — M2 policy persisted.
SELECT pg_temp.assert_true(
    (SELECT effective_maintenance_level='M2'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),
    'F4-UP-T02'
);

-- F4-UP-T03 — M2 policy target is the scientific ProductVersion.
SELECT pg_temp.assert_true(
    (SELECT target_product_version_uuid='e5100000-0000-0000-0000-000000000003'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),
    'F4-UP-T03'
);

-- F4-UP-T04 — M2 policy points to the matching governing Monitor.
SELECT pg_temp.assert_true(
    (SELECT governing_monitor_product_version_uuid='e5100000-0000-0000-0000-000000000005'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),
    'F4-UP-T04'
);

-- F4-UP-T05 — second InvestigationVersion policy is M2 under temporal v0.1.
SELECT pg_temp.assert_true(
    (SELECT effective_maintenance_level='M2'
            AND cadence_mode='periodic'
            AND target_investigation_version_uuid='e5100000-0000-0000-0000-000000000002'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000002'),
    'F4-UP-T05'
);

-- F4-UP-T06 — a new post-032 M3/continuous policy is rejected.
SELECT pg_temp.expect_error(
$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_investigation_version_uuid,
 effective_maintenance_level,cadence_mode,
 governing_monitor_product_version_uuid,effective_at,rationale,created_by,actor_type
) VALUES (
 'f4900000-0000-0000-0000-000000000006',
 'e5100000-0000-0000-0000-000000000002',
 'M3','continuous','e5100000-0000-0000-0000-000000000007',
 TIMESTAMPTZ '2026-10-07 00:02:00+00',
 'M3 must remain blocked after temporal v0.1','fixture-owner','owner'
)$,'F4-UP-T06');

-- F4-UP-T07 — existing Monitor M3 publication blocker remains active.
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
            'e5100000-0000-0000-0000-000000000007'
          )
         WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
           AND severity='error'
    ),
    'F4-UP-T07'
);

-- F4-UP-T08 — M2 policy itself has no current target/monitor error.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM maintenance.update_policy_issues(
            'f4000000-0000-0000-0000-000000000001'
          )
         WHERE severity='error'
    ),
    'F4-UP-T08'
);

-- F4-UP-T09 — scientific signal mapping persisted.
SELECT pg_temp.assert_true(
    (SELECT signal_class='scientific_currentness'
            AND trigger_class='new_evidence'
            AND signal_type='new_study'
       FROM maintenance.update_signal
      WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000001'),
    'F4-UP-T09'
);

-- F4-UP-T10 — signal 1 has exactly one primary source.
SELECT pg_temp.assert_true(
    (SELECT count(*)=1
       FROM maintenance.update_signal_source
      WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000001'
        AND source_role='primary'),
    'F4-UP-T10'
);

-- F4-UP-T11 — source is the retained CandidateAssessment.
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM maintenance.update_signal_source
         WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000001'
           AND candidate_assessment_uuid='e5530000-0000-0000-0000-000000000002'
    ),
    'F4-UP-T11'
);

-- F4-UP-T12 — materiality is potentially material.
SELECT pg_temp.assert_true(
    (SELECT outcome='potentially_material'
            AND verification_status='human_verified'
       FROM maintenance.materiality_assessment
      WHERE materiality_assessment_uuid='f4300000-0000-0000-0000-000000000001'),
    'F4-UP-T12'
);

-- F4-UP-T13 — two materiality dimensions are preserved.
SELECT pg_temp.assert_true(
    (SELECT count(*)=2
       FROM maintenance.materiality_dimension
      WHERE materiality_assessment_uuid='f4300000-0000-0000-0000-000000000001'),
    'F4-UP-T13'
);

-- F4-UP-T14 — authoritative decision is human-verified.
SELECT pg_temp.assert_true(
    (SELECT authority_status='authoritative'
            AND verification_status='human_verified'
       FROM maintenance.update_decision
      WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000001'),
    'F4-UP-T14'
);

-- F4-UP-T15 — currentness action is under_evaluation.
SELECT pg_temp.assert_true(
    (SELECT currency_action='set_under_evaluation'
       FROM maintenance.update_decision
      WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000001'),
    'F4-UP-T15'
);

-- F4-UP-T16 — decision reuses the Monitor-produced active CurrencyState.
SELECT pg_temp.assert_true(
    (SELECT currency_state_uuid='e5300000-0000-0000-0000-000000000003'
       FROM maintenance.update_decision_currency_state
      WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000001'),
    'F4-UP-T16'
);

-- F4-UP-T17 — cadence_due signal legitimately has no external source.
SELECT pg_temp.assert_true(
    (SELECT count(*)=0
       FROM maintenance.update_signal_source
      WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000002'),
    'F4-UP-T17'
);

-- F4-UP-T18 — cadence signal is operational, not scientific.
SELECT pg_temp.assert_true(
    (SELECT signal_class='operational'
            AND trigger_class='temporal_operational'
       FROM maintenance.update_signal
      WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000002'),
    'F4-UP-T18'
);

-- F4-UP-T19 — cadence signal remains insufficient_to_decide.
SELECT pg_temp.assert_true(
    (SELECT outcome='insufficient_to_decide'
       FROM maintenance.materiality_assessment
      WHERE materiality_assessment_uuid='f4300000-0000-0000-0000-000000000002'),
    'F4-UP-T19'
);

-- F4-UP-T20 — two decisions may resolve to the same CurrencyState.
SELECT pg_temp.assert_true(
    (SELECT count(*)=2
       FROM maintenance.update_decision_currency_state
      WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003'),
    'F4-UP-T20'
);

-- F4-UP-T21 — Alert-derived signal points to the formal Alert.
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM maintenance.update_signal_source
         WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000003'
           AND alert_product_version_uuid='a7100000-0000-0000-0000-000000000001'
    ),
    'F4-UP-T21'
);

-- F4-UP-T22 — signal issue helper accepts valid Alert-derived signal.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM maintenance.update_signal_issues(
            'f4100000-0000-0000-0000-000000000003'
          )
         WHERE severity='error'
    ),
    'F4-UP-T22'
);

-- F4-UP-T23 — materiality issue helper accepts valid assessment.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM maintenance.materiality_assessment_issues(
            'f4300000-0000-0000-0000-000000000001'
          )
         WHERE severity='error'
    ),
    'F4-UP-T23'
);

-- F4-UP-T24 — decision issue helper accepts current decision.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM maintenance.update_decision_issues(
            'f4400000-0000-0000-0000-000000000001'
          )
         WHERE severity='error'
    ),
    'F4-UP-T24'
);

-- F4-UP-T25 — helper functions are read-only STABLE where expected.
SELECT pg_temp.assert_true(
    (SELECT count(*)=4
       FROM pg_proc p
       JOIN pg_namespace n ON n.oid=p.pronamespace
      WHERE n.nspname='maintenance'
        AND p.proname IN (
            'update_policy_issues','update_signal_issues',
            'materiality_assessment_issues','update_decision_issues'
        )
        AND p.provolatile='s'),
    'F4-UP-T25'
);

-- F4-UP-T26 — verification helper is IMMUTABLE.
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON n.oid=p.pronamespace
        WHERE n.nspname='maintenance'
          AND p.proname='assert_verification_metadata'
          AND p.provolatile='i'
    ),
    'F4-UP-T26'
);

-- F4-UP-T27 — policy on Evidence Monitor is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 effective_at,rationale,created_by,actor_type,record_status
) VALUES (
 'f4900000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000005',
 'M0','none',CURRENT_TIMESTAMP,'invalid monitor target',
 'fixture-owner','owner','superseded'
)$$,'F4-UP-T27');

-- F4-UP-T28 — AI cannot create UpdatePolicy.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 effective_at,rationale,created_by,actor_type,record_status
) VALUES (
 'f4900000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000003',
 'M1','event_driven',CURRENT_TIMESTAMP,'invalid AI policy',
 'fixture-ai','ai_system','superseded'
)$$,'F4-UP-T28');

-- F4-UP-T29 — M1 cannot retain a governing Monitor.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 governing_monitor_product_version_uuid,
 effective_at,rationale,created_by,actor_type,record_status
) VALUES (
 'f4900000-0000-0000-0000-000000000003',
 'e5100000-0000-0000-0000-000000000003',
 'M1','event_driven','e5100000-0000-0000-0000-000000000005',
 CURRENT_TIMESTAMP,'invalid M1 monitor policy',
 'fixture-owner','owner','superseded'
)$$,'F4-UP-T29');

-- F4-UP-T30 — direct M2 -> M0 supersession is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 effective_at,rationale,created_by,actor_type,
 record_status,supersedes_update_policy_uuid
) VALUES (
 'f4900000-0000-0000-0000-000000000004',
 'e5100000-0000-0000-0000-000000000003',
 'M0','none',TIMESTAMPTZ '2026-10-07 02:00:00+00',
 'invalid direct M2 to M0','fixture-owner','owner','superseded',
 'f4000000-0000-0000-0000-000000000001'
)$$,'F4-UP-T30');

-- F4-UP-T31 — invalid signal type/class mapping is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'f4910000-0000-0000-0000-000000000001',
 'f4000000-0000-0000-0000-000000000001',
 'operational','temporal_operational','retraction',
 CURRENT_TIMESTAMP,'invalid mapping','negative test',
 'fixture-system','system','unverified'
)$$,'F4-UP-T31');

-- F4-UP-T32 — SignalSource is sealed after MaterialityAssessment.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,
 source_role,source_type,source_uri,note
) VALUES (
 'f4920000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000001',
 'supporting','uri','https://example.invalid/late-source','late source'
)$$,'F4-UP-T32');

-- F4-UP-T33 — source from a different Monitor is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,
 source_role,source_type,monitor_cycle_uuid,note
) VALUES (
 'f4920000-0000-0000-0000-000000000002',
 'f4100000-0000-0000-0000-000000000003',
 'supporting','monitor_cycle',
 'e5420000-0000-0000-0000-000000000003','wrong monitor'
)$$,'F4-UP-T33');

-- F4-UP-T34 — Alert with another target is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,
 source_role,source_type,alert_product_version_uuid,note
) VALUES (
 'f4920000-0000-0000-0000-000000000003',
 'f4100000-0000-0000-0000-000000000003',
 'supporting','alert_product_version',
 'a7100000-0000-0000-0000-000000000003','wrong-target alert'
)$$,'F4-UP-T34');

-- Setup operational signal for negative materiality tests.
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'f4100000-0000-0000-0000-000000000004',
 'f4000000-0000-0000-0000-000000000001',
 'operational','temporal_operational','cadence_due',
 TIMESTAMPTZ '2026-10-07 01:00:00+00',
 'Operational test signal','negative-test setup',
 'fixture-system','system','unverified'
);

-- F4-UP-T35 — owner cannot act as MaterialityAssessment scientist.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'f4930000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000004',
 'insufficient_to_decide','owner is not scientific assessor by role alone',
 'fixture-owner','owner','unverified',CURRENT_TIMESTAMP
)$$,'F4-UP-T35');

-- F4-UP-T36 — operational signal cannot confirm material scientific change.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'f4930000-0000-0000-0000-000000000002',
 'f4100000-0000-0000-0000-000000000004',
 'material_change_confirmed','invalid operational confirmation',
 'fixture-reviewer','human_reviewer','unverified',CURRENT_TIMESTAMP
)$$,'F4-UP-T36');

-- Add valid assessment for operational test signal.
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'f4300000-0000-0000-0000-000000000004',
 'f4100000-0000-0000-0000-000000000004',
 'insufficient_to_decide','Operational lapse does not establish scientific change',
 'fixture-reviewer','human_reviewer',
 'human_verified','fixture-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:03:00+00',
 TIMESTAMPTZ '2026-10-07 01:02:00+00'
);

-- F4-UP-T37 — insufficient_to_decide cannot close as no_scientific_update.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4940000-0000-0000-0000-000000000001',
 'f4100000-0000-0000-0000-000000000004',
 'f4300000-0000-0000-0000-000000000004',
 'no_scientific_update','authoritative','no_change','invalid closure',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
)$$,'F4-UP-T37');

-- F4-UP-T38 — second active decision on an existing signal is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4940000-0000-0000-0000-000000000002',
 'f4100000-0000-0000-0000-000000000001',
 'f4300000-0000-0000-0000-000000000001',
 'observe','authoritative','set_under_evaluation','duplicate active decision',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
)$$,'F4-UP-T38');

-- F4-UP-T39 — MaterialityDimension is sealed after UpdateDecision.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'f4300000-0000-0000-0000-000000000001',
 'conclusion','potential','late dimension'
)$$,'F4-UP-T39');

-- Setup scientific governance signal with confirmed materiality.
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at
) VALUES (
 'f4100000-0000-0000-0000-000000000005',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:10:00+00',
 'Scientific governance reassessment request',
 'Explicit governance demand used for matrix tests',
 'fixture-owner','owner',
 'human_verified','fixture-reviewer','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:11:00+00'
);

INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'f4300000-0000-0000-0000-000000000005',
 'f4100000-0000-0000-0000-000000000005',
 'material_change_confirmed','Synthetic confirmed materiality for matrix test',
 'fixture-reviewer','human_reviewer',
 'human_verified','fixture-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:13:00+00',
 TIMESTAMPTZ '2026-10-07 01:12:00+00'
);

INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'f4300000-0000-0000-0000-000000000005',
 'conclusion','confirmed','Confirmed conclusion-relevant impact'
);

-- F4-UP-T40 — confirmed material change cannot set current.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4940000-0000-0000-0000-000000000003',
 'f4100000-0000-0000-0000-000000000005',
 'f4300000-0000-0000-0000-000000000005',
 'currentness_only','authoritative','set_current','invalid current action',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
)$$,'F4-UP-T40');

-- Setup AI-only assessment.
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'f4100000-0000-0000-0000-000000000006',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:20:00+00',
 'AI-only assessment test signal','AI proposal test',
 'fixture-ai','ai_system','unverified'
);

INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'f4300000-0000-0000-0000-000000000006',
 'f4100000-0000-0000-0000-000000000006',
 'potentially_material','AI-only materiality suggestion',
 'fixture-ai','ai_system',
 'ai_verified','fixture-ai-check','ai_system',
 TIMESTAMPTZ '2026-10-07 01:22:00+00',
 TIMESTAMPTZ '2026-10-07 01:21:00+00'
);

INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'f4300000-0000-0000-0000-000000000006',
 'magnitude','potential','AI-proposed potential impact'
);

-- F4-UP-T41 — AI-only assessment cannot support authoritative decision.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4940000-0000-0000-0000-000000000004',
 'f4100000-0000-0000-0000-000000000006',
 'f4300000-0000-0000-0000-000000000006',
 'observe','authoritative','set_under_evaluation','invalid AI-only authority',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
)$$,'F4-UP-T41');

-- F4-UP-T42 — AI proposal is allowed.
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4400000-0000-0000-0000-000000000006',
 'f4100000-0000-0000-0000-000000000006',
 'f4300000-0000-0000-0000-000000000006',
 'observe','proposal','set_under_evaluation','AI proposal only',
 'fixture-ai','ai_system','ai_verified',
 'fixture-ai-check','ai_system',
 TIMESTAMPTZ '2026-10-07 01:24:00+00',
 TIMESTAMPTZ '2026-10-07 01:23:00+00'
);
SELECT pg_temp.assert_true(
    (SELECT authority_status='proposal'
       FROM maintenance.update_decision
      WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000006'),
    'F4-UP-T42'
);

-- F4-UP-T43 — AI actor cannot be authoritative even with forged human verification metadata.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at,
 record_status
) VALUES (
 'f4940000-0000-0000-0000-000000000005',
 'f4100000-0000-0000-0000-000000000005',
 'f4300000-0000-0000-0000-000000000005',
 'scientific_update_incremental','authoritative','set_update_recommended',
 'AI cannot be authority','fixture-ai','ai_system','human_verified',
 'fixture-reviewer','human_reviewer',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,
 'superseded'
)$$,'F4-UP-T43');

-- F4-UP-T44 — Investigation target cannot receive currentness action.
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'f4100000-0000-0000-0000-000000000007',
 'f4000000-0000-0000-0000-000000000002',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:30:00+00',
 'Investigation target currentness test','governance demand',
 'fixture-owner','owner','unverified'
);

INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'f4300000-0000-0000-0000-000000000007',
 'f4100000-0000-0000-0000-000000000007',
 'potentially_material','Investigation signal may require reassessment',
 'fixture-reviewer','human_reviewer',
 'human_verified','fixture-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:32:00+00',
 TIMESTAMPTZ '2026-10-07 01:31:00+00'
);

INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'f4300000-0000-0000-0000-000000000007',
 'method','potential','Potential methodological impact'
);

SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4940000-0000-0000-0000-000000000006',
 'f4100000-0000-0000-0000-000000000007',
 'f4300000-0000-0000-0000-000000000007',
 'observe','authoritative','set_under_evaluation','invalid investigation currency',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
)$$,'F4-UP-T44');

-- Setup Product decision for wrong CurrencyState linkage.
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'f4100000-0000-0000-0000-000000000008',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:40:00+00',
 'Wrong currency target test','governance demand',
 'fixture-owner','owner','unverified'
);

INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'f4300000-0000-0000-0000-000000000008',
 'f4100000-0000-0000-0000-000000000008',
 'potentially_material','Potential materiality',
 'fixture-reviewer','human_reviewer',
 'human_verified','fixture-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:42:00+00',
 TIMESTAMPTZ '2026-10-07 01:41:00+00'
);

INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'f4300000-0000-0000-0000-000000000008',
 'magnitude','potential','Potential magnitude impact'
);

INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4400000-0000-0000-0000-000000000008',
 'f4100000-0000-0000-0000-000000000008',
 'f4300000-0000-0000-0000-000000000008',
 'observe','authoritative','set_under_evaluation','Observe target',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:44:00+00',
 TIMESTAMPTZ '2026-10-07 01:43:00+00'
);

-- F4-UP-T45 — wrong-target CurrencyState is rejected.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision_currency_state(
 update_decision_uuid,currency_state_uuid
) VALUES (
 'f4400000-0000-0000-0000-000000000008',
 'e5300000-0000-0000-0000-000000000010'
)$$,'F4-UP-T45');

-- F4-UP-T46 — no_change cannot link a CurrencyState.
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'f4100000-0000-0000-0000-000000000009',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:50:00+00',
 'No-change linkage test','governance demand',
 'fixture-owner','owner','unverified'
);

INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,
 verification_status,verified_by,verifier_actor_type,verified_at,assessed_at
) VALUES (
 'f4300000-0000-0000-0000-000000000009',
 'f4100000-0000-0000-0000-000000000009',
 'no_material_change','No material change identified',
 'fixture-reviewer','human_reviewer',
 'human_verified','fixture-reviewer-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:52:00+00',
 TIMESTAMPTZ '2026-10-07 01:51:00+00'
);

INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at,decided_at
) VALUES (
 'f4400000-0000-0000-0000-000000000009',
 'f4100000-0000-0000-0000-000000000009',
 'f4300000-0000-0000-0000-000000000009',
 'no_scientific_update','authoritative','no_change','No change required',
 'fixture-owner','owner','human_verified',
 'fixture-reviewer','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:54:00+00',
 TIMESTAMPTZ '2026-10-07 01:53:00+00'
);

SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision_currency_state(
 update_decision_uuid,currency_state_uuid
) VALUES (
 'f4400000-0000-0000-0000-000000000009',
 'e5300000-0000-0000-0000-000000000003'
)$$,'F4-UP-T46');

-- F4-UP-T47 — UpdateSignal cannot be materially edited.
SELECT pg_temp.expect_error(
$$UPDATE maintenance.update_signal
   SET summary='mutated'
 WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000003'$$,
'F4-UP-T47');

-- F4-UP-T48 — UpdatePolicy cannot be materially edited.
SELECT pg_temp.expect_error(
$$UPDATE maintenance.update_policy
   SET rationale='mutated'
 WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'$$,
'F4-UP-T48');

-- F4-UP-T49 — MaterialityAssessment cannot be materially edited.
SELECT pg_temp.expect_error(
$$UPDATE maintenance.materiality_assessment
   SET rationale='mutated'
 WHERE materiality_assessment_uuid='f4300000-0000-0000-0000-000000000001'$$,
'F4-UP-T49');

-- F4-UP-T50 — UpdateDecision cannot be materially edited.
SELECT pg_temp.expect_error(
$$UPDATE maintenance.update_decision
   SET rationale='mutated'
 WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000001'$$,
'F4-UP-T50');

-- F4-UP-T51 — UpdateDecisionCurrencyState is immutable.
SELECT pg_temp.expect_error(
$$DELETE FROM maintenance.update_decision_currency_state
 WHERE update_decision_uuid='f4400000-0000-0000-0000-000000000001'$$,
'F4-UP-T51');

-- F4-UP-T52 — UpdateSignalSource is immutable.
SELECT pg_temp.expect_error(
$$DELETE FROM maintenance.update_signal_source
 WHERE update_signal_source_uuid='f4200000-0000-0000-0000-000000000002'$$,
'F4-UP-T52');

-- F4-UP-T53 — MaterialityDimension is immutable.
SELECT pg_temp.expect_error(
$$UPDATE maintenance.materiality_dimension
   SET rationale='mutated'
 WHERE materiality_assessment_uuid='f4300000-0000-0000-0000-000000000001'
   AND dimension_code='magnitude'$$,
'F4-UP-T53');

-- F4-UP-T54 — current target CurrencyState remains under_evaluation.
SELECT pg_temp.assert_true(
    (SELECT currency_status='under_evaluation'
       FROM product.currency_state
      WHERE product_version_uuid='e5100000-0000-0000-0000-000000000003'
        AND record_status='active'),
    'F4-UP-T54'
);

-- F4-UP-T55 — F4 records do not create assurance records.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE notes ILIKE '%transversal update protocol%'
    ),
    'F4-UP-T55'
);

-- F4-UP-T56 — F4 records do not create new scientific EntityVersions.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM core.entity_version
         WHERE created_by LIKE 'f4-update%'
    ),
    'F4-UP-T56'
);

-- F4-UP-T57 — F4 does not create dependency edges for operational UUIDs.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM provenance.dependency_edge
         WHERE dependency_type LIKE 'transversal_update%'
    ),
    'F4-UP-T57'
);

-- F4-UP-T58 — Product target policy cadence is periodic.
SELECT pg_temp.assert_true(
    (SELECT cadence_mode='periodic'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),
    'F4-UP-T58'
);

-- F4-UP-T59 — second synthetic policy is periodic under v0.1.
SELECT pg_temp.assert_true(
    (SELECT cadence_mode='periodic'
            AND cadence_contract_uuid='fc640000-0000-0000-0000-000000000002'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000002'),
    'F4-UP-T59'
);

-- F4-UP-T60 — currentness-only archived action does not exist in the domain.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM maintenance.update_decision
         WHERE currency_action='set_archived'
    ),
    'F4-UP-T60'
);

-- F4-UP-T61 — M2 Monitor remains publishable after F4 fixtures.
SELECT pg_temp.assert_true(
    product.evidence_monitor_is_publishable(
        'e5100000-0000-0000-0000-000000000005'
    ),
    'F4-UP-T61'
);

-- F4-UP-T62 — M3 Monitor remains blocked after F4 policy exists.
SELECT pg_temp.assert_true(
    NOT product.evidence_monitor_is_publishable(
        'e5100000-0000-0000-0000-000000000007'
    ),
    'F4-UP-T62'
);

-- F4-UP-T63 — exact core counts for canonical fixture objects.
SELECT pg_temp.assert_true(
    (SELECT count(*)=2 FROM maintenance.update_policy
      WHERE update_policy_uuid::text LIKE 'f4000000-%')
    AND
    (SELECT count(*)>=9 FROM maintenance.update_signal
      WHERE update_signal_uuid::text LIKE 'f4%')
    AND
    (SELECT count(*)>=6 FROM maintenance.materiality_assessment
      WHERE materiality_assessment_uuid::text LIKE 'f4%')
    AND
    (SELECT count(*)>=5 FROM maintenance.update_decision
      WHERE update_decision_uuid::text LIKE 'f4%'),
    'F4-UP-T63'
);

SELECT 'F4-UP-T01–T63 PASS — transversal update protocol contract validated'
AS f4_update_protocol_tests_status;

COMMIT;
