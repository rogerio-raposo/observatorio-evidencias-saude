-- OES / PF-I04 / P4-A39 — POSTFLIGHT V2 / READ ONLY / CANDIDATO HOLD
-- Um UNICO WITH ... SELECT, em sessao administrativa INDEPENDENTE apos rollback A37.
-- Nao executar sem gate nominal; PASS isolado nao comprova que o ensaio ocorreu.
-- PostgreSQL roles e pg_auth_members/pg_shdepend sao cluster-wide NA BRANCH.
-- A identidade Neon branch/endpoint exige comprovacao externa adicional.
WITH
ids AS (
  SELECT pg_catalog.to_regrole('oes_p4_trial_target')::oid AS target_oid,
         pg_catalog.to_regrole('oes_p4_trial_login')::oid AS trial_oid,
         pg_catalog.to_regrole('oes_sandbox_owner')::oid AS owner_oid,
         pg_catalog.to_regrole('oes_django_migrator')::oid AS migrator_oid,
         pg_catalog.to_regrole('oes_runtime')::oid AS runtime_oid
),
checks AS (
  SELECT check_name, passed
  FROM ids i
  CROSS JOIN LATERAL (
    VALUES
      ('database', current_database() = 'oes_sandbox'),
      ('session_user_owner', session_user = 'oes_sandbox_owner'),
      ('current_user_owner', current_user = 'oes_sandbox_owner'),
      ('postgresql_18', current_setting('server_version_num')::integer BETWEEN 180000 AND 189999),
      ('target_exists', i.target_oid IS NOT NULL),
      ('trial_exists', i.trial_oid IS NOT NULL),
      ('target_role_flags',
        EXISTS (SELECT 1 FROM pg_catalog.pg_roles r
                WHERE r.oid=i.target_oid AND NOT r.rolcanlogin AND NOT r.rolinherit
                  AND NOT r.rolsuper AND NOT r.rolcreatedb AND NOT r.rolcreaterole
                  AND NOT r.rolreplication AND NOT r.rolbypassrls)),
      ('trial_role_flags',
        EXISTS (SELECT 1 FROM pg_catalog.pg_roles r
                WHERE r.oid=i.trial_oid AND r.rolcanlogin AND NOT r.rolinherit
                  AND NOT r.rolsuper AND NOT r.rolcreatedb AND NOT r.rolcreaterole
                  AND NOT r.rolreplication AND NOT r.rolbypassrls AND r.rolconnlimit=1)),
      ('target_grants_to_only_trial',
        (SELECT count(*)=1 FROM pg_catalog.pg_auth_members m WHERE m.roleid=i.target_oid)),
      ('target_has_no_parent_roles',
        (SELECT count(*)=0 FROM pg_catalog.pg_auth_members m WHERE m.member=i.target_oid)),
      ('trial_has_only_target_membership',
        (SELECT count(*)=1 FROM pg_catalog.pg_auth_members m WHERE m.member=i.trial_oid)),
      ('target_trial_one_membership',
        (SELECT count(*)=1 FROM pg_catalog.pg_auth_members m
          WHERE m.roleid=i.target_oid AND m.member=i.trial_oid)),
      ('original_synthetic_grant_exact',
        EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members m
          WHERE m.roleid=i.target_oid AND m.member=i.trial_oid AND m.grantor=i.owner_oid
            AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)),
      ('no_trial_self_grant',
        NOT EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members m
          WHERE m.roleid=i.target_oid AND m.member=i.trial_oid AND m.grantor=i.trial_oid)),
      ('target_no_shared_object_dependencies',
        (SELECT count(*)=0 FROM pg_catalog.pg_shdepend s
          WHERE s.refclassid='pg_catalog.pg_authid'::regclass AND s.refobjid=i.target_oid)),
      ('target_no_role_config',
        (SELECT count(*)=0 FROM pg_catalog.pg_db_role_setting d WHERE d.setrole=i.target_oid)),
      ('trial_cannot_SET_target',
        CASE WHEN i.trial_oid IS NOT NULL AND i.target_oid IS NOT NULL
          THEN NOT pg_catalog.pg_has_role(i.trial_oid,i.target_oid,'SET') ELSE false END),
      ('trial_cannot_USAGES_target',
        CASE WHEN i.trial_oid IS NOT NULL AND i.target_oid IS NOT NULL
          THEN NOT pg_catalog.pg_has_role(i.trial_oid,i.target_oid,'USAGE') ELSE false END),
      ('trial_cannot_SET_owner',
        CASE WHEN i.trial_oid IS NOT NULL AND i.owner_oid IS NOT NULL
          THEN NOT pg_catalog.pg_has_role(i.trial_oid,i.owner_oid,'SET') ELSE false END),
      ('trial_cannot_SET_migrator',
        CASE WHEN i.trial_oid IS NOT NULL AND i.migrator_oid IS NOT NULL
          THEN NOT pg_catalog.pg_has_role(i.trial_oid,i.migrator_oid,'SET') ELSE false END),
      ('trial_cannot_USAGES_owner',
        CASE WHEN i.trial_oid IS NOT NULL AND i.owner_oid IS NOT NULL
          THEN NOT pg_catalog.pg_has_role(i.trial_oid,i.owner_oid,'USAGE') ELSE false END),
      ('trial_cannot_USAGES_migrator',
        CASE WHEN i.trial_oid IS NOT NULL AND i.migrator_oid IS NOT NULL
          THEN NOT pg_catalog.pg_has_role(i.trial_oid,i.migrator_oid,'USAGE') ELSE false END),
      ('original_migrator_only_one',
        (SELECT count(*)=1 FROM pg_catalog.pg_auth_members m
          WHERE m.roleid=i.migrator_oid AND m.member=i.owner_oid)),
      ('original_migrator_oid_155649_intact',
        EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members m
          WHERE m.oid=155649 AND m.roleid=i.migrator_oid AND m.member=i.owner_oid
            AND m.grantor='cloud_admin'::regrole
            AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)),
      ('runtime_has_no_memberships',
        (SELECT count(*)=0 FROM pg_catalog.pg_auth_members m WHERE m.member=i.runtime_oid)),
      ('no_active_trial_connections',
        (SELECT count(*)=0 FROM pg_catalog.pg_stat_activity a WHERE a.usename='oes_p4_trial_login'))
  ) AS c(check_name,passed)
),
summary AS (
  SELECT count(*)::integer AS checks_total,
         count(*) FILTER (WHERE passed IS NOT TRUE)::integer AS checks_failed FROM checks
)
SELECT 0 AS sort_order,'SUMMARY'::text AS item,
       (checks_total=26 AND checks_failed=0) AS passed,
       checks_total AS check_count,checks_failed AS failed_count
  FROM summary
UNION ALL
SELECT 1,check_name,COALESCE(passed,false),NULL::integer,NULL::integer FROM checks
ORDER BY sort_order,item;
