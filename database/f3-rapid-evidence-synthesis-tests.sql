-- OES Fase 3 — Rapid Evidence Synthesis N3 contract tests
-- Requires migration 014 + f3-rapid-evidence-synthesis-fixtures.sql.

-- RS-T01 — synthetic N3 fixture derives A2 but is not publishable.
DO $t01$
BEGIN
  IF product.rapid_evidence_synthesis_assurance_level(
       'd1000000-0000-0000-0000-000000000601'
     ) <> 'A2'
  THEN
    RAISE EXCEPTION 'RS-T01 FAIL: expected synthetic A2';
  END IF;

  IF product.rapid_evidence_synthesis_is_publishable(
       'd1000000-0000-0000-0000-000000000601'
     )
  THEN
    RAISE EXCEPTION 'RS-T01 FAIL: A2 N3 without human controls/A3 must not publish';
  END IF;

  RAISE NOTICE 'RS-T01 PASS — A2 N3 remains non-publishable without human controls/A3';
END
$t01$;

-- RS-T02 — scientific core is structurally complete.
DO $t02$
DECLARE bad_count integer;
BEGIN
  SELECT count(*)
    INTO bad_count
    FROM product.rapid_evidence_synthesis_publication_issues(
      'd1000000-0000-0000-0000-000000000601'
    )
   WHERE issue_code IN (
      'MISSING_PROTOCOL',
      'MISSING_SEARCH_RECORD',
      'INSUFFICIENT_SEARCH_SOURCE_COVERAGE',
      'MISSING_SELECTION_FLOW',
      'MISSING_RISK_ASSESSMENT',
      'MISSING_SYNTHESIS',
      'MISSING_CERTAINTY_ASSESSMENT',
      'MISSING_TRACEABLE_SOURCE',
      'MISSING_LIMITATIONS',
      'MISSING_CURRENCY_STATE',
      'MISSING_SUMMARY_OF_FINDINGS_DECISION'
   );

  IF bad_count <> 0 THEN
    RAISE EXCEPTION 'RS-T02 FAIL: scientific-core blockers remain: %', bad_count;
  END IF;

  RAISE NOTICE 'RS-T02 PASS — protocol/search/selection/appraisal/synthesis/certainty core is complete';
END
$t02$;

-- RS-T03 — all required qualified human controls are reported missing.
DO $t03$
DECLARE expected text[] := ARRAY[
  'MISSING_SEARCH_STRATEGY_VERIFICATION',
  'MISSING_SCREENING_PILOT',
  'MISSING_QUALIFIED_SCREENING_VERIFICATION',
  'MISSING_QUALIFIED_DATA_VERIFICATION',
  'MISSING_QUALIFIED_RISK_OF_BIAS_VERIFICATION',
  'MISSING_QUALIFIED_CERTAINTY_VERIFICATION'
];
DECLARE code text;
BEGIN
  FOREACH code IN ARRAY expected LOOP
    IF NOT EXISTS (
      SELECT 1
        FROM product.rapid_evidence_synthesis_missing_controls(
          'd1000000-0000-0000-0000-000000000601'
        ) mc
       WHERE mc.control_code = code
    ) THEN
      RAISE EXCEPTION 'RS-T03 FAIL: expected missing control % not reported', code;
    END IF;
  END LOOP;

  IF EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_missing_controls(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE control_code = 'MISSING_REQUIRED_STATISTICAL_REVIEW'
  ) THEN
    RAISE EXCEPTION 'RS-T03 FAIL: narrative synthesis incorrectly requires statistical review';
  END IF;

  RAISE NOTICE 'RS-T03 PASS — human control gaps explicit; narrative synthesis does not require statistical review';
END
$t03$;

-- RS-T04 — expert review and A3 blockers are explicit.
DO $t04$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE issue_code='MISSING_EXPERT_INDEPENDENT_REVIEW'
       AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RS-T04 FAIL: missing expert-review blocker absent';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE issue_code='ASSURANCE_BELOW_A3'
       AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RS-T04 FAIL: A3 blocker absent';
  END IF;

  RAISE NOTICE 'RS-T04 PASS — formal N3 correctly requires expert review and A3';
END
$t04$;

-- RS-T05 — AI quality controls are transparent but do not satisfy qualified controls.
DO $t05$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
           'd1000000-0000-0000-0000-000000000601'
         )
    INTO v;

  IF v#>>'{audit,qualified_controls_satisfied}' <> 'false' THEN
    RAISE EXCEPTION 'RS-T05 FAIL: AI controls incorrectly satisfy human-qualified controls';
  END IF;

  IF jsonb_array_length(v->'quality_controls') <> 6 THEN
    RAISE EXCEPTION 'RS-T05 FAIL: expected six AI quality controls';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v->'quality_controls') q
     WHERE q->>'qualified' <> 'false'
  ) THEN
    RAISE EXCEPTION 'RS-T05 FAIL: an AI quality control is marked qualified';
  END IF;

  RAISE NOTICE 'RS-T05 PASS — AI quality checks visible but never impersonate qualified human verification';
END
$t05$;

-- RS-T06 — view projects protocol, N3 identity, searches, selection and two references.
DO $t06$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
           'd1000000-0000-0000-0000-000000000601'
         )
    INTO v;

  IF v#>>'{schema_version}' <> 'oes.rapid_evidence_synthesis_view/0.1'
     OR v#>>'{identity,product_type}' <> 'rapid_evidence_synthesis'
     OR v#>>'{investigation,depth_level}' <> 'N3'
     OR v#>>'{protocol,artifact_type}' <> 'protocol'
     OR jsonb_array_length(v->'searches') <> 2
     OR (v#>>'{selection_flow,screening_decisions}')::int <> 4
     OR jsonb_array_length(v->'included_evidence') <> 2
     OR jsonb_array_length(v->'references') <> 2
  THEN
    RAISE EXCEPTION 'RS-T06 FAIL: RapidEvidenceSynthesisView projection mismatch';
  END IF;

  RAISE NOTICE 'RS-T06 PASS — view projects N3 protocol/search/selection/references';
END
$t06$;

-- RS-T07 — rapid restrictions are explicit and no protocol deviation is open.
DO $t07$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
           'd1000000-0000-0000-0000-000000000601'
         )
    INTO v;

  IF jsonb_array_length(v#>'{rapid_method,restrictions}') <> 3
     OR jsonb_array_length(v#>'{rapid_method,deviations}') <> 0
     OR v#>>'{audit,protocol_deviations_open}' <> 'false'
  THEN
    RAISE EXCEPTION 'RS-T07 FAIL: rapid restrictions/deviations projection mismatch';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE issue_code='RAPID_METHOD_RESTRICTIONS_PRESENT'
       AND severity='warning'
  ) THEN
    RAISE EXCEPTION 'RS-T07 FAIL: rapid-method warning missing';
  END IF;

  RAISE NOTICE 'RS-T07 PASS — rapid restrictions remain explicit and protocol has no open deviation';
END
$t07$;

-- RS-T08 — MethodDecision material mutation is blocked.
DO $t08$
BEGIN
  BEGIN
    UPDATE investigation.method_decision
       SET rationale='illicit mutation'
     WHERE method_decision_uuid='d6000000-0000-0000-0000-000000000001';
    RAISE EXCEPTION 'RS-T08 FAIL: MethodDecision mutation unexpectedly allowed';
  EXCEPTION
    WHEN OTHERS THEN
      IF position('material fields are immutable' in SQLERRM)=0 THEN
        RAISE;
      END IF;
  END;

  RAISE NOTICE 'RS-T08 PASS — MethodDecision is append-preserving';
END
$t08$;

-- RS-T09 — QualityControl material mutation is blocked.
DO $t09$
BEGIN
  BEGIN
    UPDATE investigation.quality_control_record
       SET notes='illicit mutation'
     WHERE quality_control_uuid='d6500000-0000-0000-0000-000000000001';
    RAISE EXCEPTION 'RS-T09 FAIL: QualityControl mutation unexpectedly allowed';
  EXCEPTION
    WHEN OTHERS THEN
      IF position('material fields are immutable' in SQLERRM)=0 THEN
        RAISE;
      END IF;
  END;

  RAISE NOTICE 'RS-T09 PASS — QualityControl is append-preserving';
END
$t09$;

-- RS-T10 — an open protocol deviation blocks publication.
BEGIN;

INSERT INTO investigation.method_decision(
    method_decision_uuid,investigation_version_uuid,decision_type,stage,
    decision_code,planned_flag,rationale,risk_payload,mitigation_payload,
    impact_payload,resolution_status,decided_by,decided_at,record_status
) VALUES (
    'd6000000-0000-0000-0000-000000000099',
    'd1000000-0000-0000-0000-000000000002',
    'protocol_deviation','search','unexpected_database_outage',false,
    'Synthetic open deviation for gate testing.',
    NULL,
    '{"mitigation":"pending"}'::jsonb,
    '{"impact":"not yet assessed"}'::jsonb,
    'open','N3_FIXTURE_METHOD',
    TIMESTAMPTZ '2026-10-05 20:00:00-03','active'
);

DO $t10$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE issue_code='OPEN_PROTOCOL_DEVIATION'
       AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RS-T10 FAIL: open deviation did not block';
  END IF;

  RAISE NOTICE 'RS-T10 PASS — open protocol deviation blocks publication';
END
$t10$;

ROLLBACK;

-- RS-T11 — formal synthetic path opens only after qualified controls + expert/A3.
BEGIN;

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,agreement_payload,performed_at,notes,record_status
) VALUES
(
 'd6600000-0000-0000-0000-000000000001',
 'd1000000-0000-0000-0000-000000000002',
 'search','search_strategy_peer_review',
 'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
 '{"role":"information specialist","methodological_training":"systematic review searching","relevant_experience":"synthetic validation","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"search strategy"}'::jsonb,
 true,'passed',
 '{"search_ids":["OES-SRCH-2026-001101","OES-SRCH-2026-001102"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 20:01:00-03',
 'Synthetic qualified control used only inside rollback test.','active'
),
(
 'd6600000-0000-0000-0000-000000000002',
 'd1000000-0000-0000-0000-000000000002',
 'screening','screening_pilot',
 'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
 '{"role":"systematic reviewer","methodological_training":"screening calibration","relevant_experience":"synthetic validation","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"pilot"}'::jsonb,
 true,'passed',
 '{"records_sampled":2,"records_total":2}'::jsonb,
 '{"percent_agreement":1.0}'::jsonb,
 TIMESTAMPTZ '2026-10-05 20:02:00-03',
 'Synthetic qualified control used only inside rollback test.','active'
),
(
 'd6600000-0000-0000-0000-000000000003',
 'd1000000-0000-0000-0000-000000000002',
 'screening','screening_secondary_verification',
 'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
 '{"role":"systematic reviewer","methodological_training":"independent screening","relevant_experience":"synthetic validation","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"screening verification"}'::jsonb,
 true,'passed',
 '{"records_sampled":2,"records_total":2,"stages":["title_abstract","full_text"]}'::jsonb,
 '{"percent_agreement":1.0}'::jsonb,
 TIMESTAMPTZ '2026-10-05 20:03:00-03',
 'Synthetic qualified control used only inside rollback test.','active'
),
(
 'd6600000-0000-0000-0000-000000000004',
 'd1000000-0000-0000-0000-000000000002',
 'extraction','critical_data_verification',
 'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
 '{"role":"systematic reviewer","methodological_training":"data extraction verification","relevant_experience":"synthetic validation","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"critical data"}'::jsonb,
 true,'passed',
 '{"result_version_uuids":["d1000000-0000-0000-0000-000000000301","d1000000-0000-0000-0000-000000000302"],"critical_fields":["reported_value","ci_lower","ci_upper"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 20:04:00-03',
 'Synthetic qualified control used only inside rollback test.','active'
),
(
 'd6600000-0000-0000-0000-000000000005',
 'd1000000-0000-0000-0000-000000000002',
 'appraisal','risk_of_bias_verification',
 'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
 '{"role":"risk-of-bias reviewer","methodological_training":"RoB 2","relevant_experience":"synthetic validation","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"RoB judgements"}'::jsonb,
 true,'passed',
 '{"risk_assessment_version_uuids":["d1000000-0000-0000-0000-000000000401","d1000000-0000-0000-0000-000000000402"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 20:05:00-03',
 'Synthetic qualified control used only inside rollback test.','active'
),
(
 'd6600000-0000-0000-0000-000000000006',
 'd1000000-0000-0000-0000-000000000002',
 'certainty','certainty_verification',
 'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
 '{"role":"GRADE reviewer","methodological_training":"GRADE","relevant_experience":"synthetic validation","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"certainty judgements"}'::jsonb,
 true,'passed',
 '{"certainty_version_uuids":["d1000000-0000-0000-0000-000000000502"]}'::jsonb,
 NULL,TIMESTAMPTZ '2026-10-05 20:06:00-03',
 'Synthetic qualified control used only inside rollback test.','active'
);

INSERT INTO product.assurance_record(
    assurance_uuid,product_version_uuid,assurance_type,actor,actor_type,
    independent_flag,decision,performed_at,notes,evidence_payload,status
) VALUES (
    'd8000000-0000-0000-0000-000000000603',
    'd1000000-0000-0000-0000-000000000601',
    'expert_independent_review',
    'SYNTHETIC_QUALIFIED_REVIEWER',
    'human_expert',true,'approved',
    TIMESTAMPTZ '2026-10-05 20:07:00-03',
    'Synthetic A3 gate-opening test only.',
    '{"fixture":true,"qualified":true}'::jsonb,
    'active'
);

DO $t11$
BEGIN
  IF product.rapid_evidence_synthesis_assurance_level(
       'd1000000-0000-0000-0000-000000000601'
     ) <> 'A3'
  THEN
    RAISE EXCEPTION 'RS-T11 FAIL: synthetic formal path did not derive A3';
  END IF;

  IF EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_missing_controls(
        'd1000000-0000-0000-0000-000000000601'
      )
  ) THEN
    RAISE EXCEPTION 'RS-T11 FAIL: qualified controls still reported missing';
  END IF;

  IF NOT product.rapid_evidence_synthesis_is_publishable(
       'd1000000-0000-0000-0000-000000000601'
     )
  THEN
    RAISE EXCEPTION 'RS-T11 FAIL: fully qualified A3 synthetic path did not open gate';
  END IF;

  RAISE NOTICE 'RS-T11 PASS — gate opens only after qualified controls and A3';
END
$t11$;

ROLLBACK;

-- RS-T12 — active qualified QC revise blocks even if a passed control also exists.
BEGIN;

INSERT INTO investigation.quality_control_record(
    quality_control_uuid,investigation_version_uuid,stage,control_type,
    actor,actor_type,qualification_payload,independent_flag,decision,
    scope_payload,performed_at,notes,record_status
) VALUES (
    'd6600000-0000-0000-0000-000000000099',
    'd1000000-0000-0000-0000-000000000002',
    'reporting','reporting_verification',
    'SYNTHETIC_QUALIFIED_REVIEWER','human_expert',
    '{"role":"reviewer","methodological_training":"rapid review reporting","relevant_experience":"synthetic","credential_or_basis":"fixture qualified","conflict_of_interest":"none","verification_scope":"reporting"}'::jsonb,
    true,'revise',
    '{"scope":"synthetic report"}'::jsonb,
    TIMESTAMPTZ '2026-10-05 20:08:00-03',
    'Synthetic active revise for blocker test.','active'
);

DO $t12$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE issue_code='ACTIVE_QUALITY_CONTROL_REVISE'
       AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RS-T12 FAIL: active QC revise did not block';
  END IF;

  RAISE NOTICE 'RS-T12 PASS — active quality-control revise blocks publication';
END
$t12$;

ROLLBACK;

-- RS-T13 — two traceable references, narrative synthesis, moderate certainty.
DO $t13$
DECLARE v jsonb;
BEGIN
  SELECT product.rapid_evidence_synthesis_view(
           'd1000000-0000-0000-0000-000000000601'
         )
    INTO v;

  IF jsonb_array_length(v->'references') <> 2
     OR jsonb_array_length(v->'syntheses') <> 1
     OR v#>>'{syntheses,0,synthesis_type}' <> 'narrative_synthesis'
     OR jsonb_array_length(v->'certainty') <> 1
     OR v#>>'{certainty,0,final_level}' <> 'moderate'
  THEN
    RAISE EXCEPTION 'RS-T13 FAIL: references/synthesis/certainty projection mismatch';
  END IF;

  RAISE NOTICE 'RS-T13 PASS — two references, narrative synthesis and moderate certainty projected';
END
$t13$;

-- RS-T14 — invalidated upstream ReportVersion blocks publication.
BEGIN;

UPDATE core.entity_version
   SET version_status='invalidated'
 WHERE version_uuid='d1000000-0000-0000-0000-000000000201';

DO $t14$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM product.rapid_evidence_synthesis_publication_issues(
        'd1000000-0000-0000-0000-000000000601'
      )
     WHERE issue_code IN (
       'INVALIDATED_DEPENDENCY',
       'INVALIDATED_UPSTREAM_DEPENDENCY'
     )
       AND severity='error'
  ) THEN
    RAISE EXCEPTION 'RS-T14 FAIL: invalidated evidence dependency did not block';
  END IF;

  RAISE NOTICE 'RS-T14 PASS — invalidated upstream evidence blocks publication';
END
$t14$;

ROLLBACK;
