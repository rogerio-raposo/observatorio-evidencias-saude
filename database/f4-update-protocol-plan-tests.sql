-- F4 Transversal Update Protocol — plan-mirrored audit tests
-- F4-UP-P01–P58 map exactly to Documento 07 §34 items 1–58.
-- P59–P63 are workflow/rebuild/regression requirements and are proven by
-- explicitly labelled steps in validate-s5.yml.
-- Requires migrations through 028 + F3 Monitor/Alert fixtures + F4 fixtures.
-- Run after historical F4-UP-T01–T63.
--
-- This suite is intentionally transaction-scoped and rolls back its own
-- synthetic audit rows. It validates guards without changing canonical fixtures.

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

CREATE OR REPLACE FUNCTION pg_temp.expect_error_like(
    p_sql text,
    p_pattern text,
    p_label text
)
RETURNS void
LANGUAGE plpgsql
AS $fn$
DECLARE
    msg text;
BEGIN
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
        IF position(lower(p_pattern) IN lower(msg))>0 THEN
            RETURN;
        END IF;
        RAISE EXCEPTION '% FAIL — wrong error: %',p_label,msg;
    END;
    RAISE EXCEPTION '% FAIL — expected error was not raised',p_label;
END;
$fn$;

-- P01 — target XOR de policy.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,target_investigation_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000001',
 'e5100000-0000-0000-0000-000000000003',
 'e5100000-0000-0000-0000-000000000002',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:00+00',
 'P01 XOR negative','audit-owner','owner','superseded'
)$$,'F4-UP-P01');

-- P02 — uma policy ativa por ProductVersion.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 governing_monitor_product_version_uuid,effective_at,rationale,
 created_by,actor_type
) VALUES (
 'fb000000-0000-0000-0000-000000000002',
 'e5100000-0000-0000-0000-000000000003',
 'M2','periodic','e5100000-0000-0000-0000-000000000005',
 TIMESTAMPTZ '2026-10-07 01:01+00','P02 duplicate active Product policy',
 'audit-owner','owner'
)$$,'F4-UP-P02');

-- P03 — uma policy ativa por InvestigationVersion.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_investigation_version_uuid,
 effective_maintenance_level,cadence_mode,
 governing_monitor_product_version_uuid,effective_at,rationale,
 created_by,actor_type
) VALUES (
 'fb000000-0000-0000-0000-000000000003',
 'e5100000-0000-0000-0000-000000000002',
 'M3','continuous','e5100000-0000-0000-0000-000000000007',
 TIMESTAMPTZ '2026-10-07 01:02+00','P03 duplicate active Investigation policy',
 'audit-owner','owner'
)$$,'F4-UP-P03');

-- P04 — policy sobre target não-current é rejeitada.
SAVEPOINT f4_p04;
UPDATE core.entity_version
   SET version_status='superseded'
 WHERE version_uuid='61000000-0000-0000-0000-000000000014';
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000004',
 '61000000-0000-0000-0000-000000000014',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:03+00',
 'P04 non-current target','audit-owner','owner','superseded'
)$$,'must be current','F4-UP-P04');
ROLLBACK TO SAVEPOINT f4_p04;
RELEASE SAVEPOINT f4_p04;

-- P05 — target superseded posteriormente gera issue, sem retarget silencioso.
SAVEPOINT f4_p05;
UPDATE core.entity_version
   SET version_status='superseded'
 WHERE version_uuid='e5100000-0000-0000-0000-000000000003';
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM maintenance.update_policy_issues(
            'f4000000-0000-0000-0000-000000000001'
          )
         WHERE issue_code='UPDATE_POLICY_TARGET_SUPERSEDED'
    )
    AND
    (SELECT target_product_version_uuid=
            'e5100000-0000-0000-0000-000000000003'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),
    'F4-UP-P05'
);
ROLLBACK TO SAVEPOINT f4_p05;
RELEASE SAVEPOINT f4_p05;

-- P06 — supersessão de policy preserva target exato.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status,supersedes_update_policy_uuid
) VALUES (
 'fb000000-0000-0000-0000-000000000006',
 '61000000-0000-0000-0000-000000000014',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:04+00',
 'P06 wrong-target supersession','audit-owner','owner','superseded',
 'f4000000-0000-0000-0000-000000000001'
)$$,'supersession must preserve exact target','F4-UP-P06');

-- P07 — M0 × cadence: none válido; outra cadence inválida.
SAVEPOINT f4_p07;
INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000071',
 '61000000-0000-0000-0000-000000000014',
 'M0','none',TIMESTAMPTZ '2026-10-07 01:05+00',
 'P07 valid M0 none','audit-owner','owner','superseded'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000072',
 '61000000-0000-0000-0000-000000000014',
 'M0','event_driven',TIMESTAMPTZ '2026-10-07 01:06+00',
 'P07 invalid M0 cadence','audit-owner','owner','superseded'
)$$,'maintenance level/cadence mode mismatch','F4-UP-P07');
ROLLBACK TO SAVEPOINT f4_p07;
RELEASE SAVEPOINT f4_p07;

-- P08 — pós-032, toda cadence não-none exige CadenceContract; continuous segue inválido para M1.
SAVEPOINT f4_p08;
SELECT pg_temp.expect_error(
$q$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000081','61000000-0000-0000-0000-000000000014',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:07+00','P08 unbound event',
 'audit-owner','owner','superseded'
)$q$,'F4-UP-P08-event-contract');
SELECT pg_temp.expect_error(
$q$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000082','61000000-0000-0000-0000-000000000014',
 'M1','periodic',TIMESTAMPTZ '2026-10-07 01:08+00','P08 unbound periodic',
 'audit-owner','owner','superseded'
)$q$,'F4-UP-P08-periodic-contract');
SELECT pg_temp.expect_error(
$q$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000083','61000000-0000-0000-0000-000000000014',
 'M1','hybrid',TIMESTAMPTZ '2026-10-07 01:09+00','P08 unbound hybrid',
 'audit-owner','owner','superseded'
)$q$,'F4-UP-P08-hybrid-contract');
SELECT pg_temp.expect_error_like(
$q$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000084',
 '61000000-0000-0000-0000-000000000014',
 'M1','continuous',TIMESTAMPTZ '2026-10-07 01:10+00',
 'P08 invalid M1 continuous','audit-owner','owner','superseded'
)$q$,'maintenance level/cadence mode mismatch','F4-UP-P08');
SELECT pg_temp.assert_true(
 (SELECT cadence_contract_uuid IS NOT NULL
    FROM maintenance.update_policy
   WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000001'),
 'F4-UP-P08-bound-policy-control'
);
ROLLBACK TO SAVEPOINT f4_p08;
RELEASE SAVEPOINT f4_p08;

-- P09 — policy em evidence_monitor/evidence_alert é rejeitada.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000091',
 'e5100000-0000-0000-0000-000000000005',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:11+00',
 'P09 Monitor target','audit-owner','owner','superseded'
)$$,'cannot be evidence_monitor/evidence_alert','F4-UP-P09-monitor');
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000092',
 'a7100000-0000-0000-0000-000000000001',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:12+00',
 'P09 Alert target','audit-owner','owner','superseded'
)$$,'cannot be evidence_monitor/evidence_alert','F4-UP-P09-alert');

-- P10 — policy em Investigation evidence_monitoring é rejeitada.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_investigation_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000010',
 'e5100000-0000-0000-0000-000000000004',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:13+00',
 'P10 monitoring Investigation target','audit-owner','owner','superseded'
)$$,'cannot be evidence_monitoring','F4-UP-P10');

-- P11 — policy por system/AI é rejeitada.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000011',
 '61000000-0000-0000-0000-000000000014',
 'M1','event_driven',TIMESTAMPTZ '2026-10-07 01:14+00',
 'P11 AI policy','audit-ai','ai_system','superseded'
)$$,'F4-UP-P11');

-- P12 — transição M0–M3 inválida é rejeitada (M2→M0 direto).
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status,supersedes_update_policy_uuid
) VALUES (
 'fb000000-0000-0000-0000-000000000012',
 'e5100000-0000-0000-0000-000000000003',
 'M0','none',TIMESTAMPTZ '2026-10-07 01:15+00',
 'P12 invalid M2 to M0','audit-owner','owner','superseded',
 'f4000000-0000-0000-0000-000000000001'
)$$,'Invalid UpdatePolicy maintenance transition','F4-UP-P12');

-- P13 — M1 com governing Monitor é rejeitada.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 governing_monitor_product_version_uuid,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000013',
 'e5100000-0000-0000-0000-000000000003',
 'M1','event_driven','e5100000-0000-0000-0000-000000000005',
 TIMESTAMPTZ '2026-10-07 01:16+00','P13 M1 Monitor',
 'audit-owner','owner','superseded'
)$$,'M0/M1 UpdatePolicy cannot have governing Monitor','F4-UP-P13');

-- P14 — M2 exige governing Monitor.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000014',
 '61000000-0000-0000-0000-000000000014',
 'M2','periodic',TIMESTAMPTZ '2026-10-07 01:17+00',
 'P14 M2 no Monitor','audit-owner','owner','superseded'
)$$,'M2/M3 UpdatePolicy requires governing Monitor','F4-UP-P14');

-- P15 — post-032 policy fixture is M2; Monitor M3 remains formally blocked.
SELECT pg_temp.assert_true(
    (SELECT effective_maintenance_level='M2'
            AND cadence_mode='periodic'
            AND governing_monitor_product_version_uuid='e5100000-0000-0000-0000-000000000007'
       FROM maintenance.update_policy
      WHERE update_policy_uuid='f4000000-0000-0000-0000-000000000002')
    AND EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
            'e5100000-0000-0000-0000-000000000007'
          )
         WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
           AND severity='error'
    ),
    'F4-UP-P15'
);

-- P16 — governing Monitor deve apontar para o mesmo target da policy.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,
 governing_monitor_product_version_uuid,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000016',
 '61000000-0000-0000-0000-000000000014',
 'M2','periodic','e5100000-0000-0000-0000-000000000005',
 TIMESTAMPTZ '2026-10-07 01:18+00','P16 wrong Monitor target',
 'audit-owner','owner','superseded'
)$$,'Governing Monitor target must match UpdatePolicy target','F4-UP-P16');

-- P17 — signal exige policy ativa no INSERT.
SAVEPOINT f4_p17;
INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,
 effective_maintenance_level,cadence_mode,effective_at,rationale,
 created_by,actor_type,record_status
) VALUES (
 'fb000000-0000-0000-0000-000000000170',
 '61000000-0000-0000-0000-000000000014',
 'M0','none',TIMESTAMPTZ '2026-10-07 01:19+00',
 'P17 inactive policy','audit-owner','owner','superseded'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000017',
 'fb000000-0000-0000-0000-000000000170',
 'scientific_currentness','new_evidence','new_study',
 TIMESTAMPTZ '2026-10-07 01:20+00','P17','P17','audit','system','unverified'
)$$,'requires active UpdatePolicy','F4-UP-P17');
ROLLBACK TO SAVEPOINT f4_p17;
RELEASE SAVEPOINT f4_p17;

-- P18 — matriz completa signal_type × class × trigger.
SELECT pg_temp.assert_true(
    (
      SELECT bool_and(
          maintenance.signal_mapping_is_valid(
              signal_type,signal_class,trigger_class,'mapped'
          )
      )
      FROM (VALUES
        ('new_study','scientific_currentness','new_evidence'),
        ('new_review','scientific_currentness','new_evidence'),
        ('review_update','scientific_currentness','new_evidence'),
        ('estimate_change_signal','scientific_currentness','new_evidence'),
        ('safety_signal','scientific_currentness','safety_regulatory'),
        ('new_population_signal','scientific_currentness','new_evidence'),
        ('certainty_change_signal','scientific_currentness','new_evidence'),
        ('correction','scientific_currentness','integrity_validity'),
        ('retraction','scientific_currentness','integrity_validity'),
        ('expression_of_concern','scientific_currentness','integrity_validity'),
        ('methodology_change','scientific_currentness','methodological'),
        ('regulatory_change','scientific_currentness','safety_regulatory'),
        ('cadence_due','operational','temporal_operational'),
        ('cycle_incomplete','operational','temporal_operational'),
        ('source_coverage_gap','operational','temporal_operational'),
        ('explicit_reassessment_request','scientific_currentness','governance_demand'),
        ('use_context_change','scientific_currentness','governance_demand'),
        ('scope_change','scientific_currentness','scope')
      ) AS m(signal_type,signal_class,trigger_class)
    )
    AND NOT maintenance.signal_mapping_is_valid(
        'new_study','operational','temporal_operational','bad'
    ),
    'F4-UP-P18'
);

-- P19 — other exige rationale e combinação class/trigger não contraditória.
SELECT pg_temp.assert_true(
    maintenance.signal_mapping_is_valid(
        'other','scientific_currentness','new_evidence','documented other signal'
    )
    AND maintenance.signal_mapping_is_valid(
        'other','operational','temporal_operational','documented operational signal'
    )
    AND NOT maintenance.signal_mapping_is_valid(
        'other','scientific_currentness','new_evidence',NULL
    )
    AND NOT maintenance.signal_mapping_is_valid(
        'other','operational','new_evidence','contradictory'
    )
    AND NOT maintenance.signal_mapping_is_valid(
        'other','scientific_currentness','temporal_operational','contradictory'
    ),
    'F4-UP-P19'
);

-- P20 — invariantes de verification metadata do signal.
SELECT pg_temp.assert_true(
    maintenance.assert_verification_metadata('unverified',NULL,NULL,NULL)
    AND maintenance.assert_verification_metadata(
        'ai_verified','ai','ai_system',TIMESTAMPTZ '2026-10-07 01:21+00'
    )
    AND maintenance.assert_verification_metadata(
        'human_verified','reviewer','human_reviewer',
        TIMESTAMPTZ '2026-10-07 01:21+00'
    )
    AND NOT maintenance.assert_verification_metadata(
        'unverified','forged','human_reviewer',
        TIMESTAMPTZ '2026-10-07 01:21+00'
    )
    AND NOT maintenance.assert_verification_metadata(
        'human_verified','ai','ai_system',
        TIMESTAMPTZ '2026-10-07 01:21+00'
    ),
    'F4-UP-P20'
);

-- P21 — signal material é imutável.
SELECT pg_temp.expect_error(
$$UPDATE maintenance.update_signal
     SET summary='P21 forbidden mutation'
   WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000003'$$,
'F4-UP-P21');

-- P22 — source locator XOR.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,source_role,source_type,
 candidate_assessment_uuid,source_uri,note
) VALUES (
 'fb200000-0000-0000-0000-000000000022',
 'f4100000-0000-0000-0000-000000000003',
 'supporting','candidate_assessment',
 'e5530000-0000-0000-0000-000000000002',
 'https://example.invalid/p22','P22 two locators'
)$$,'F4-UP-P22');

-- P23 — no máximo uma primary source.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,source_role,source_type,source_uri,note
) VALUES (
 'fb200000-0000-0000-0000-000000000023',
 'f4100000-0000-0000-0000-000000000003',
 'primary','uri','https://example.invalid/p23','P23 second primary'
)$$,'F4-UP-P23');

-- P24 — cadence_due sem source externa é permitido.
SELECT pg_temp.assert_true(
    (SELECT signal_type='cadence_due'
       FROM maintenance.update_signal
      WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000002')
    AND
    (SELECT count(*)=0
       FROM maintenance.update_signal_source
      WHERE update_signal_uuid='f4100000-0000-0000-0000-000000000002'),
    'F4-UP-P24'
);

-- P25 — SearchHit fora de Monitor é rejeitado.
SAVEPOINT f4_p25;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000025',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:25+00','P25 isolated signal','P25',
 'audit','system','unverified'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM investigation.search_hit sh
         WHERE NOT EXISTS (
            SELECT 1
              FROM maintenance.cycle_search cs
             WHERE cs.search_uuid=sh.search_uuid
         )
    ),
    'F4-UP-P25-fixture'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,source_role,source_type,search_hit_uuid,note
)
SELECT
 'fb200000-0000-0000-0000-000000000025',
 'fb100000-0000-0000-0000-000000000025',
 'supporting','search_hit',sh.search_hit_uuid,'P25 outside Monitor'
FROM investigation.search_hit sh
WHERE NOT EXISTS (
  SELECT 1 FROM maintenance.cycle_search cs WHERE cs.search_uuid=sh.search_uuid
)
ORDER BY sh.search_hit_uuid
LIMIT 1$$,'must belong to a MonitorCycle','F4-UP-P25');
ROLLBACK TO SAVEPOINT f4_p25;
RELEASE SAVEPOINT f4_p25;

-- P26 — source Monitor pertence ao governing Monitor.
SAVEPOINT f4_p26;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000026',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:26+00','P26 isolated signal','P26',
 'audit','system','unverified'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,source_role,source_type,
 monitor_cycle_uuid,note
) VALUES (
 'fb200000-0000-0000-0000-000000000026',
 'fb100000-0000-0000-0000-000000000026',
 'supporting','monitor_cycle',
 'e5420000-0000-0000-0000-000000000003','P26 wrong Monitor'
)$$,'must belong to governing Monitor','F4-UP-P26');
ROLLBACK TO SAVEPOINT f4_p26;
RELEASE SAVEPOINT f4_p26;

-- P27 — Alert source target compatível.
SAVEPOINT f4_p27;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000027',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:27+00','P27 isolated signal','P27',
 'audit','system','unverified'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,source_role,source_type,
 alert_product_version_uuid,note
) VALUES (
 'fb200000-0000-0000-0000-000000000027',
 'fb100000-0000-0000-0000-000000000027',
 'supporting','alert_product_version',
 'a7100000-0000-0000-0000-000000000003','P27 wrong Alert target'
)$$,'Alert source target must match UpdatePolicy target','F4-UP-P27');
ROLLBACK TO SAVEPOINT f4_p27;
RELEASE SAVEPOINT f4_p27;

-- P28 — SignalSource selada após assessment.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_signal_source(
 update_signal_source_uuid,update_signal_uuid,source_role,source_type,source_uri,note
) VALUES (
 'fb200000-0000-0000-0000-000000000028',
 'f4100000-0000-0000-0000-000000000001',
 'supporting','uri','https://example.invalid/p28','P28 sealed'
)$$,'sealed after MaterialityAssessment','F4-UP-P28');

-- P29 — assessment sem primary source é rejeitado quando exigido.
SAVEPOINT f4_p29;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000029',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','new_evidence','new_review',
 TIMESTAMPTZ '2026-10-07 01:29+00','P29 no source','P29',
 'audit','system','unverified'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000029',
 'fb100000-0000-0000-0000-000000000029',
 'potentially_material','P29','audit','human_reviewer','unverified',
 TIMESTAMPTZ '2026-10-07 01:30+00'
)$$,'requires exactly one primary source','F4-UP-P29');
ROLLBACK TO SAVEPOINT f4_p29;
RELEASE SAVEPOINT f4_p29;

-- P30 — owner como materiality assessor é rejeitado.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000030',
 'f4100000-0000-0000-0000-000000000003',
 'no_material_change','P30','audit-owner','owner','unverified',
 TIMESTAMPTZ '2026-10-07 01:31+00'
)$$,'F4-UP-P30');

-- P31 — operational signal não confirma material_change_confirmed.
SAVEPOINT f4_p31;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000031',
 'f4000000-0000-0000-0000-000000000001',
 'operational','temporal_operational','cadence_due',
 TIMESTAMPTZ '2026-10-07 01:32+00','P31 operational','P31',
 'audit','system','unverified'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000031',
 'fb100000-0000-0000-0000-000000000031',
 'material_change_confirmed','P31','audit','human_reviewer','unverified',
 TIMESTAMPTZ '2026-10-07 01:33+00'
)$$,'Operational signal cannot confirm scientific material change','F4-UP-P31');
ROLLBACK TO SAVEPOINT f4_p31;
RELEASE SAVEPOINT f4_p31;

-- P32 — um assessment ativo por signal.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000032',
 'f4100000-0000-0000-0000-000000000001',
 'potentially_material','P32 second active','audit','human_reviewer','unverified',
 TIMESTAMPTZ '2026-10-07 01:34+00'
)$$,'F4-UP-P32');

-- P33 — assessment supersession preserva o mesmo signal.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at,record_status,
 supersedes_materiality_assessment_uuid
) VALUES (
 'fb300000-0000-0000-0000-000000000033',
 'f4100000-0000-0000-0000-000000000003',
 'potentially_material','P33 wrong signal','audit','human_reviewer','unverified',
 TIMESTAMPTZ '2026-10-07 01:35+00','superseded',
 'f4300000-0000-0000-0000-000000000001'
)$$,'supersession must preserve signal','F4-UP-P33');

-- P34 — materiality outcome × dimensions coerente.
SAVEPOINT f4_p34;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000034',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:35+00','P34 isolated signal','P34',
 'audit','system','unverified'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000034',
 'fb100000-0000-0000-0000-000000000034',
 'no_material_change','P34','audit','human_reviewer','unverified',
 TIMESTAMPTZ '2026-10-07 01:36+00'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'fb300000-0000-0000-0000-000000000034',
 'conclusion','confirmed','P34 invalid dimension'
)$$,'No-material-change assessment cannot contain confirmed/threat dimension',
'F4-UP-P34');
ROLLBACK TO SAVEPOINT f4_p34;
RELEASE SAVEPOINT f4_p34;

-- P35 — MaterialityDimension selada após decision.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'f4300000-0000-0000-0000-000000000001',
 'applicability','potential','P35 sealed'
)$$,'sealed after UpdateDecision','F4-UP-P35');

-- P36 — proposal por AI é permitida.
SAVEPOINT f4_p36;
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,decided_at,record_status
) VALUES (
 'fb400000-0000-0000-0000-000000000036',
 'f4100000-0000-0000-0000-000000000001',
 'f4300000-0000-0000-0000-000000000001',
 'observe','proposal','no_change','P36 AI proposal',
 'audit-ai','ai_system','unverified',
 TIMESTAMPTZ '2026-10-07 01:37+00','superseded'
);
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1 FROM maintenance.update_decision
         WHERE update_decision_uuid='fb400000-0000-0000-0000-000000000036'
           AND actor_type='ai_system' AND authority_status='proposal'
    ),
    'F4-UP-P36'
);
ROLLBACK TO SAVEPOINT f4_p36;
RELEASE SAVEPOINT f4_p36;

-- P37 — authoritative por AI é rejeitada.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at,record_status
) VALUES (
 'fb400000-0000-0000-0000-000000000037',
 'f4100000-0000-0000-0000-000000000001',
 'f4300000-0000-0000-0000-000000000001',
 'observe','authoritative','no_change','P37 AI authoritative',
 'audit-ai','ai_system','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:38+00',TIMESTAMPTZ '2026-10-07 01:38+00',
 'superseded'
)$$,'AI cannot create authoritative UpdateDecision','F4-UP-P37');

-- P38 — authoritative com assessment AI-only é rejeitada.
SAVEPOINT f4_p38;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000038',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:38+00','P38 isolated signal','P38',
 'audit','system','unverified'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000038',
 'fb100000-0000-0000-0000-000000000038',
 'potentially_material','P38 AI-only assessment',
 'audit-ai','ai_system','ai_verified','audit-ai-check','ai_system',
 TIMESTAMPTZ '2026-10-07 01:39+00',TIMESTAMPTZ '2026-10-07 01:39+00'
);
INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'fb300000-0000-0000-0000-000000000038',
 'magnitude','potential','P38'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000038',
 'fb100000-0000-0000-0000-000000000038',
 'fb300000-0000-0000-0000-000000000038',
 'observe','authoritative','no_change','P38',
 'audit-owner','owner','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:40+00',TIMESTAMPTZ '2026-10-07 01:40+00'
)$$,'requires human-verified materiality assessment','F4-UP-P38');
ROLLBACK TO SAVEPOINT f4_p38;
RELEASE SAVEPOINT f4_p38;

-- P39 — authoritative sem human verification é rejeitada.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,decided_at,record_status
) VALUES (
 'fb400000-0000-0000-0000-000000000039',
 'f4100000-0000-0000-0000-000000000001',
 'f4300000-0000-0000-0000-000000000001',
 'observe','authoritative','no_change','P39',
 'audit-owner','owner','unverified',
 TIMESTAMPTZ '2026-10-07 01:41+00','superseded'
)$$,'requires human verification','F4-UP-P39');

-- P40 — um decision ativo por signal.
SELECT pg_temp.expect_error(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000040',
 'f4100000-0000-0000-0000-000000000001',
 'f4300000-0000-0000-0000-000000000001',
 'observe','authoritative','no_change','P40 second active',
 'audit-owner','owner','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:42+00',TIMESTAMPTZ '2026-10-07 01:42+00'
)$$,'F4-UP-P40');

-- P41 — decision supersession preserva o mesmo signal.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at,record_status,supersedes_update_decision_uuid
) VALUES (
 'fb400000-0000-0000-0000-000000000041',
 'f4100000-0000-0000-0000-000000000002',
 'f4300000-0000-0000-0000-000000000002',
 'observe','authoritative','set_under_evaluation','P41 wrong signal',
 'audit-owner','owner','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:43+00',TIMESTAMPTZ '2026-10-07 01:43+00',
 'superseded','f4400000-0000-0000-0000-000000000001'
)$$,'supersession must preserve signal','F4-UP-P41');

-- P42 — insufficient_to_decide não encerra como no_scientific_update.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at,record_status
) VALUES (
 'fb400000-0000-0000-0000-000000000042',
 'f4100000-0000-0000-0000-000000000002',
 'f4300000-0000-0000-0000-000000000002',
 'no_scientific_update','authoritative','no_change','P42',
 'audit-owner','owner','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:44+00',TIMESTAMPTZ '2026-10-07 01:44+00',
 'superseded'
)$$,'no_scientific_update decision/outcome/currency mismatch','F4-UP-P42');

-- P43 — material_change_confirmed → set_current é rejeitado.
SAVEPOINT f4_p43;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status
) VALUES (
 'fb100000-0000-0000-0000-000000000043',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:44+00','P43 isolated signal','P43',
 'audit','system','unverified'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000043',
 'fb100000-0000-0000-0000-000000000043',
 'material_change_confirmed','P43',
 'audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:45+00',TIMESTAMPTZ '2026-10-07 01:45+00'
);
INSERT INTO maintenance.materiality_dimension(
 materiality_assessment_uuid,dimension_code,dimension_status,rationale
) VALUES (
 'fb300000-0000-0000-0000-000000000043',
 'conclusion','confirmed','P43 confirmed conclusion'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000043',
 'fb100000-0000-0000-0000-000000000043',
 'fb300000-0000-0000-0000-000000000043',
 'currentness_only','authoritative','set_current','P43',
 'audit-owner','owner','human_verified','audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:46+00',TIMESTAMPTZ '2026-10-07 01:46+00'
)$$,'currentness_only outcome/currency matrix violation','F4-UP-P43');
ROLLBACK TO SAVEPOINT f4_p43;
RELEASE SAVEPOINT f4_p43;

-- P44 — insufficient_to_decide → set_current é rejeitado.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at,record_status
) VALUES (
 'fb400000-0000-0000-0000-000000000044',
 'f4100000-0000-0000-0000-000000000002',
 'f4300000-0000-0000-0000-000000000002',
 'currentness_only','authoritative','set_current','P44',
 'audit-owner','owner','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:47+00',TIMESTAMPTZ '2026-10-07 01:47+00',
 'superseded'
)$$,'currentness_only outcome/currency matrix violation','F4-UP-P44');

-- P45 — decision × materiality coerente.
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at,record_status
) VALUES (
 'fb400000-0000-0000-0000-000000000045',
 'f4100000-0000-0000-0000-000000000001',
 'f4300000-0000-0000-0000-000000000001',
 'no_scientific_update','authoritative','no_change','P45',
 'audit-owner','owner','human_verified','audit-human','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:48+00',TIMESTAMPTZ '2026-10-07 01:48+00',
 'superseded'
)$$,'no_scientific_update decision/outcome/currency mismatch','F4-UP-P45');

-- P46 — Investigation target com currency action é rejeitado.
SAVEPOINT f4_p46;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at
) VALUES (
 'fb100000-0000-0000-0000-000000000046',
 'f4000000-0000-0000-0000-000000000002',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:49+00','P46','P46',
 'audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',TIMESTAMPTZ '2026-10-07 01:49+00'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000046',
 'fb100000-0000-0000-0000-000000000046',
 'no_material_change','P46','audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:50+00',TIMESTAMPTZ '2026-10-07 01:50+00'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000046',
 'fb100000-0000-0000-0000-000000000046',
 'fb300000-0000-0000-0000-000000000046',
 'currentness_only','authoritative','set_current','P46',
 'audit-owner','owner','human_verified','audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:51+00',TIMESTAMPTZ '2026-10-07 01:51+00'
)$$,'InvestigationVersion target cannot receive CurrencyState action','F4-UP-P46');
ROLLBACK TO SAVEPOINT f4_p46;
RELEASE SAVEPOINT f4_p46;

-- P47 — Product target currency linkage coerente.
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM maintenance.update_decision d
          JOIN maintenance.update_signal s
            ON s.update_signal_uuid=d.update_signal_uuid
          JOIN maintenance.update_policy p
            ON p.update_policy_uuid=s.update_policy_uuid
          JOIN maintenance.update_decision_currency_state l
            ON l.update_decision_uuid=d.update_decision_uuid
          JOIN product.currency_state cs
            ON cs.currency_state_uuid=l.currency_state_uuid
         WHERE d.update_decision_uuid='f4400000-0000-0000-0000-000000000001'
           AND cs.product_version_uuid=p.target_product_version_uuid
           AND d.currency_action='set_under_evaluation'
           AND cs.currency_status='under_evaluation'
    ),
    'F4-UP-P47'
);

-- Helper setup repeated in savepoints for P48/P49/P51/P54:
-- governance demand -> no_material_change -> authoritative currentness decision.

-- P48 — wrong-target CurrencyState rejeitado.
SAVEPOINT f4_p48;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at
) VALUES (
 'fb100000-0000-0000-0000-000000000048',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:52+00','P48','P48',
 'audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',TIMESTAMPTZ '2026-10-07 01:52+00'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000048',
 'fb100000-0000-0000-0000-000000000048',
 'no_material_change','P48','audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:53+00',TIMESTAMPTZ '2026-10-07 01:53+00'
);
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000048',
 'fb100000-0000-0000-0000-000000000048',
 'fb300000-0000-0000-0000-000000000048',
 'currentness_only','authoritative','set_current','P48',
 'audit-owner','owner','human_verified','audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:54+00',TIMESTAMPTZ '2026-10-07 01:54+00'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision_currency_state(
 update_decision_uuid,currency_state_uuid
) VALUES (
 'fb400000-0000-0000-0000-000000000048',
 'e5300000-0000-0000-0000-000000000010'
)$$,'belong to UpdatePolicy target ProductVersion','F4-UP-P48');
ROLLBACK TO SAVEPOINT f4_p48;
RELEASE SAVEPOINT f4_p48;

-- P49 — currency action/status mismatch rejeitado.
SAVEPOINT f4_p49;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at
) VALUES (
 'fb100000-0000-0000-0000-000000000049',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:55+00','P49','P49',
 'audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',TIMESTAMPTZ '2026-10-07 01:55+00'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000049',
 'fb100000-0000-0000-0000-000000000049',
 'no_material_change','P49','audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:56+00',TIMESTAMPTZ '2026-10-07 01:56+00'
);
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000049',
 'fb100000-0000-0000-0000-000000000049',
 'fb300000-0000-0000-0000-000000000049',
 'currentness_only','authoritative','set_current','P49',
 'audit-owner','owner','human_verified','audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:57+00',TIMESTAMPTZ '2026-10-07 01:57+00'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision_currency_state(
 update_decision_uuid,currency_state_uuid
) VALUES (
 'fb400000-0000-0000-0000-000000000049',
 'e5300000-0000-0000-0000-000000000003'
)$$,'currency action/status mismatch','F4-UP-P49');
ROLLBACK TO SAVEPOINT f4_p49;
RELEASE SAVEPOINT f4_p49;

-- P50 — archived não pode ser produzido por UpdateDecision.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1 FROM maintenance.update_decision
         WHERE currency_action='set_archived'
    )
    AND NOT EXISTS (
        SELECT 1
          FROM information_schema.columns
         WHERE table_schema='maintenance'
           AND table_name='update_decision'
           AND column_name='currency_action'
           AND column_default='set_archived'
    ),
    'F4-UP-P50'
);

-- P51 — no_change com CurrencyState linkage é rejeitado.
SAVEPOINT f4_p51;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at
) VALUES (
 'fb100000-0000-0000-0000-000000000051',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 01:58+00','P51','P51',
 'audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',TIMESTAMPTZ '2026-10-07 01:58+00'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000051',
 'fb100000-0000-0000-0000-000000000051',
 'no_material_change','P51','audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 01:59+00',TIMESTAMPTZ '2026-10-07 01:59+00'
);
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000051',
 'fb100000-0000-0000-0000-000000000051',
 'fb300000-0000-0000-0000-000000000051',
 'no_scientific_update','authoritative','no_change','P51',
 'audit-owner','owner','human_verified','audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:00+00',TIMESTAMPTZ '2026-10-07 02:00+00'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision_currency_state(
 update_decision_uuid,currency_state_uuid
) VALUES (
 'fb400000-0000-0000-0000-000000000051',
 'e5300000-0000-0000-0000-000000000003'
)$$,'currency action/status mismatch','F4-UP-P51');
ROLLBACK TO SAVEPOINT f4_p51;
RELEASE SAVEPOINT f4_p51;

-- P52 — dois signals podem compartilhar o mesmo CurrencyState quando coerentes.
SELECT pg_temp.assert_true(
    (SELECT count(*)=2
       FROM maintenance.update_decision_currency_state
      WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003'
        AND update_decision_uuid IN (
          'f4400000-0000-0000-0000-000000000001',
          'f4400000-0000-0000-0000-000000000002'
        )),
    'F4-UP-P52'
);

-- P53 — CurrencyState produzido por cycle pode ser reutilizado.
SELECT pg_temp.assert_true(
    EXISTS (
        SELECT 1
          FROM maintenance.cycle_currency_state ccs
          JOIN maintenance.update_decision_currency_state uds
            ON uds.currency_state_uuid=ccs.currency_state_uuid
         WHERE ccs.cycle_uuid='e5420000-0000-0000-0000-000000000002'
           AND uds.update_decision_uuid=
               'f4400000-0000-0000-0000-000000000001'
    ),
    'F4-UP-P53'
);

-- P54 — contradição cycle/decision é rejeitada.
SAVEPOINT f4_p54;
INSERT INTO maintenance.update_signal(
 update_signal_uuid,update_policy_uuid,signal_class,trigger_class,signal_type,
 detected_at,summary,rationale,detected_by,actor_type,verification_status,
 verified_by,verifier_actor_type,verified_at
) VALUES (
 'fb100000-0000-0000-0000-000000000054',
 'f4000000-0000-0000-0000-000000000001',
 'scientific_currentness','governance_demand','explicit_reassessment_request',
 TIMESTAMPTZ '2026-10-07 02:01+00','P54','P54',
 'audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',TIMESTAMPTZ '2026-10-07 02:01+00'
);
INSERT INTO maintenance.materiality_assessment(
 materiality_assessment_uuid,update_signal_uuid,outcome,rationale,
 assessed_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,assessed_at
) VALUES (
 'fb300000-0000-0000-0000-000000000054',
 'fb100000-0000-0000-0000-000000000054',
 'no_material_change','P54','audit-human','human_reviewer','human_verified',
 'audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:02+00',TIMESTAMPTZ '2026-10-07 02:02+00'
);
INSERT INTO maintenance.update_decision(
 update_decision_uuid,update_signal_uuid,materiality_assessment_uuid,
 decision_type,authority_status,currency_action,rationale,
 decided_by,actor_type,verification_status,verified_by,verifier_actor_type,
 verified_at,decided_at
) VALUES (
 'fb400000-0000-0000-0000-000000000054',
 'fb100000-0000-0000-0000-000000000054',
 'fb300000-0000-0000-0000-000000000054',
 'currentness_only','authoritative','set_current','P54 says current',
 'audit-owner','owner','human_verified','audit-human-2','human_reviewer',
 TIMESTAMPTZ '2026-10-07 02:03+00',TIMESTAMPTZ '2026-10-07 02:03+00'
);
SELECT pg_temp.assert_true(
    (SELECT currency_status='under_evaluation'
       FROM product.currency_state
      WHERE currency_state_uuid='e5300000-0000-0000-0000-000000000003')
    AND EXISTS (
        SELECT 1 FROM maintenance.cycle_currency_state
         WHERE cycle_uuid='e5420000-0000-0000-0000-000000000002'
           AND currency_state_uuid='e5300000-0000-0000-0000-000000000003'
    ),
    'F4-UP-P54-precondition'
);
SELECT pg_temp.expect_error_like(
$$INSERT INTO maintenance.update_decision_currency_state(
 update_decision_uuid,currency_state_uuid
) VALUES (
 'fb400000-0000-0000-0000-000000000054',
 'e5300000-0000-0000-0000-000000000003'
)$$,'currency action/status mismatch','F4-UP-P54');
ROLLBACK TO SAVEPOINT f4_p54;
RELEASE SAVEPOINT f4_p54;

-- P55 — nenhuma decisão cria ProductVersion automaticamente.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1 FROM product.product_version pv
        JOIN core.entity_version ev ON ev.version_uuid=pv.version_uuid
         WHERE ev.created_by IN ('audit','audit-owner','audit-ai','audit-human')
    ),
    'F4-UP-P55'
);

-- P56 — nenhuma decisão cria InvestigationVersion automaticamente.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1 FROM investigation.investigation_version iv
        JOIN core.entity_version ev ON ev.version_uuid=iv.version_uuid
         WHERE ev.created_by IN ('audit','audit-owner','audit-ai','audit-human')
    ),
    'F4-UP-P56'
);

-- P57 — nenhum registro F4 promove assurance.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM product.assurance_record
         WHERE actor IN ('audit','audit-owner','audit-ai','audit-human')
            OR notes ILIKE '%Phase 4 audit%'
    ),
    'F4-UP-P57'
);

-- P58 — M3 blocker existente continua ativo sem policy M3 pós-032.
SELECT pg_temp.assert_true(
    NOT EXISTS (
        SELECT 1 FROM maintenance.update_policy
        WHERE effective_maintenance_level='M3'
          AND NOT maintenance.temporal_object_is_grandfathered('update_policy',update_policy_uuid)
    )
    AND EXISTS (
        SELECT 1
          FROM product.evidence_monitor_publication_issues(
            'e5100000-0000-0000-0000-000000000007'
          )
         WHERE issue_code='M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL'
           AND severity='error'
    ),
    'F4-UP-P58'
);

SELECT 'F4-UP-P01–P58 PASS — Documento 07 plan-mirrored contract requirements validated'
AS f4_update_protocol_plan_tests_status;

-- P59–P63 are intentionally not faked here:
-- P59 migrations 021–026 idempotency      -> workflow F4-UP-P59
-- P60 migration 028 idempotency           -> workflow F4-UP-P60
-- P61 rebuild-from-zero through 028        -> workflow F4-UP-P61
-- P62 F2-B/S4/S5 regressions               -> workflow F4-UP-P62
-- P63 Monitor/Alert complete regressions   -> workflow F4-UP-P63

ROLLBACK;
