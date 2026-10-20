-- OES 032 synthetic-only, constraint-consistent *preexisting* source rows.
-- Do not use as scientific data, policy decisions, or a database migration.
\set ON_ERROR_STOP on
BEGIN;

INSERT INTO core.entity(entity_uuid,oes_id,entity_type,created_by)
VALUES ('11111111-1111-4111-8111-000000000171','OES-CI-ONLY-GRANDFATHER-171','Product','synthetic_ci');

INSERT INTO core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,change_note)
VALUES ('22222222-2222-4222-8222-000000000171',
        '11111111-1111-4111-8111-000000000171',
        1,'current','synthetic_ci','initial','Disposable CI record only');

INSERT INTO product.product(entity_uuid)
VALUES ('11111111-1111-4111-8111-000000000171');

INSERT INTO product.product_version(version_uuid,entity_uuid,product_type,title,evidence_cutoff_date,status)
VALUES ('22222222-2222-4222-8222-000000000171',
        '11111111-1111-4111-8111-000000000171',
        'evidence_sheet','SYNTHETIC CI ONLY','2026-01-01','draft');

INSERT INTO maintenance.update_policy(
 update_policy_uuid,target_product_version_uuid,effective_maintenance_level,
 cadence_mode,effective_at,rationale,created_by,actor_type
) VALUES (
 '33333333-3333-4333-8333-000000000171',
 '22222222-2222-4222-8222-000000000171',
 'M0','none','2026-01-02T00:00:00Z','Disposable synthetic policy', 'synthetic_ci','owner'
);

INSERT INTO maintenance.sla_calendar_version(
 sla_calendar_version_uuid,calendar_key,version_no,timezone_name,
 weekly_schedule_payload,effective_from,created_by,actor_type
) VALUES (
 '44444444-4444-4444-8444-000000000171',
 'SYNTHETIC_CI_CALENDAR',1,'UTC',
 '{"1":[{"start":"09:00","end":"17:00"}]}'::jsonb,
 '2026-01-02T00:00:00Z','synthetic_ci','owner'
);

INSERT INTO maintenance.sla_rule(
 sla_rule_uuid,rule_code,update_policy_uuid,clock_code,selection_precedence,
 endpoint_type,time_basis,target_duration,effective_at,rationale,created_by,actor_type
) VALUES (
 '55555555-5555-4555-8555-000000000171','SYNTHETIC_CI_RULE',
 '33333333-3333-4333-8333-000000000171',
 'SLA1_DETECTION_TO_TRIAGE',1,'triage','elapsed_time',interval '1 hour',
 '2026-01-03T00:00:00Z','Disposable synthetic rule','synthetic_ci','owner'
);
COMMIT;
