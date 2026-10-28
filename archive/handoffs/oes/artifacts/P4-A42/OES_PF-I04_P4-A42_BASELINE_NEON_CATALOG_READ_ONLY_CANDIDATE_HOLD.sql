-- OES / PF-I04 / P4-A42 — baseline PostgreSQL 18, catalog-only, CANDIDATE/HOLD.
-- One WITH ... SELECT; never run on Neon without separate nominal authorization.
-- Database, session and roles are verified inside SQL; branch/endpoint must be
-- checked independently using Neon API metadata before any connected execution.
-- No pg_authid, secrets, Django/Q0 data, DDL, DML, SET, or transaction command.
WITH
ids AS (
    SELECT pg_catalog.to_regrole('oes_sandbox_owner')::oid AS owner_oid,
           pg_catalog.to_regrole('oes_p4_trial_login')::oid AS trial_oid,
           pg_catalog.to_regrole('oes_p4_trial_target')::oid AS target_oid,
           pg_catalog.to_regrole('oes_django_migrator')::oid AS migrator_oid,
           pg_catalog.to_regrole('oes_runtime')::oid AS runtime_oid,
           pg_catalog.to_regrole('cloud_admin')::oid AS original_grantor_oid
),
environment AS (
    SELECT pg_catalog.current_database() AS database_name,
           CURRENT_USER::text AS current_role,
           SESSION_USER::text AS session_role,
           pg_catalog.current_setting('server_version_num')::integer AS pg_version_num
),
trial_sessions AS (
    SELECT count(*)::integer AS n
      FROM pg_catalog.pg_stat_activity
     WHERE usename = 'oes_p4_trial_login'
),
role_inventory AS (
    SELECT r.rolname, r.rolcanlogin, r.rolinherit, r.rolsuper,
           r.rolcreatedb, r.rolcreaterole, r.rolreplication,
           r.rolbypassrls, r.rolconnlimit, r.rolvaliduntil
      FROM pg_catalog.pg_roles r CROSS JOIN ids i
     WHERE r.oid IN (i.owner_oid, i.trial_oid, i.target_oid,
                     i.migrator_oid, i.runtime_oid)
),
membership_inventory AS (
    SELECT m.oid AS membership_oid, granted.rolname AS granted_role,
           member.rolname AS member_role, grantor.rolname AS grantor_role,
           m.admin_option, m.inherit_option, m.set_option
      FROM pg_catalog.pg_auth_members m CROSS JOIN ids i
      LEFT JOIN pg_catalog.pg_roles granted ON granted.oid = m.roleid
      LEFT JOIN pg_catalog.pg_roles member ON member.oid = m.member
      LEFT JOIN pg_catalog.pg_roles grantor ON grantor.oid = m.grantor
     WHERE m.member IN (i.trial_oid, i.target_oid, i.runtime_oid)
        OR m.roleid IN (i.trial_oid, i.target_oid)
        OR (m.roleid = i.migrator_oid AND m.member = i.owner_oid)
),
shared_dependency_inventory AS (
    SELECT CASE WHEN s.refobjid = i.trial_oid THEN 'oes_p4_trial_login'
                ELSE 'oes_p4_trial_target' END AS referenced_role,
           s.classid::pg_catalog.regclass::text AS dependent_catalog,
           s.deptype::text AS dependency_type,
           s.dbid AS database_oid,
           count(*)::integer AS n
      FROM pg_catalog.pg_shdepend s CROSS JOIN ids i
     WHERE s.refclassid = 'pg_catalog.pg_authid'::pg_catalog.regclass
       AND s.refobjid IN (i.trial_oid, i.target_oid)
     GROUP BY 1, 2, 3, 4
),
role_setting_inventory AS (
    SELECT CASE WHEN d.setrole = i.trial_oid THEN 'oes_p4_trial_login'
                ELSE 'oes_p4_trial_target' END AS setting_role,
           d.setdatabase AS database_oid,
           count(*)::integer AS n
      FROM pg_catalog.pg_db_role_setting d CROSS JOIN ids i
     WHERE d.setrole IN (i.trial_oid, i.target_oid)
     GROUP BY 1, 2
),
checks AS (
    SELECT v.item, v.actual, COALESCE(v.passed, false) AS passed
      FROM ids i CROSS JOIN environment e CROSS JOIN trial_sessions ss
      CROSS JOIN LATERAL (VALUES
        ('database_is_oes_sandbox', pg_catalog.to_jsonb(e.database_name),
         e.database_name = 'oes_sandbox'),
        ('current_role_is_owner', pg_catalog.to_jsonb(e.current_role),
         e.current_role = 'oes_sandbox_owner'),
        ('session_role_is_owner', pg_catalog.to_jsonb(e.session_role),
         e.session_role = 'oes_sandbox_owner'),
        ('postgres_major_18', pg_catalog.to_jsonb(e.pg_version_num),
         e.pg_version_num >= 180000 AND e.pg_version_num < 190000),
        ('owner_nonsuper_createrole', pg_catalog.to_jsonb(i.owner_oid),
         EXISTS (SELECT 1 FROM pg_catalog.pg_roles r WHERE r.oid = i.owner_oid
                 AND r.rolcreaterole AND NOT r.rolsuper)),
        ('trial_exists', pg_catalog.to_jsonb(i.trial_oid),
         i.trial_oid IS NOT NULL),
        ('trial_attributes_minimal', pg_catalog.to_jsonb(i.trial_oid),
         EXISTS (SELECT 1 FROM pg_catalog.pg_roles r WHERE r.oid = i.trial_oid
                 AND r.rolcanlogin AND NOT r.rolinherit AND NOT r.rolsuper
                 AND NOT r.rolcreatedb AND NOT r.rolcreaterole
                 AND NOT r.rolreplication AND NOT r.rolbypassrls
                 AND r.rolconnlimit = 1)),
        ('trial_credential_not_expired', pg_catalog.to_jsonb(
             (SELECT r.rolvaliduntil FROM pg_catalog.pg_roles r WHERE r.oid = i.trial_oid)),
         EXISTS (SELECT 1 FROM pg_catalog.pg_roles r WHERE r.oid = i.trial_oid
                 AND r.rolvaliduntil IS NOT NULL AND r.rolvaliduntil > CURRENT_TIMESTAMP)),
        ('target_absent', pg_catalog.to_jsonb(i.target_oid),
         i.target_oid IS NULL),
        ('trial_member_edge_count_zero', pg_catalog.to_jsonb(
             (SELECT count(*)::integer FROM pg_catalog.pg_auth_members m WHERE m.member = i.trial_oid)),
         NOT EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members m WHERE m.member = i.trial_oid)),
        ('trial_granted_edge_creator_autogrant_only', pg_catalog.to_jsonb(
             (SELECT count(*)::integer FROM pg_catalog.pg_auth_members m WHERE m.roleid = i.trial_oid)),
         (SELECT count(*) FROM pg_catalog.pg_auth_members m WHERE m.roleid = i.trial_oid) <= 1
         AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members m
                          WHERE m.roleid = i.trial_oid
                            AND (m.member IS DISTINCT FROM i.owner_oid
                                 OR NOT m.admin_option OR m.inherit_option OR m.set_option))),
        ('original_membership_count_one', pg_catalog.to_jsonb(
             (SELECT count(*)::integer FROM pg_catalog.pg_auth_members m
               WHERE m.roleid = i.migrator_oid AND m.member = i.owner_oid)),
         (SELECT count(*) FROM pg_catalog.pg_auth_members m
           WHERE m.roleid = i.migrator_oid AND m.member = i.owner_oid) = 1),
        ('original_oid_155649_intact', pg_catalog.to_jsonb(155649),
         EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members m
                  WHERE m.oid = 155649 AND m.roleid = i.migrator_oid
                    AND m.member = i.owner_oid AND m.grantor = i.original_grantor_oid
                    AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)),
        ('runtime_has_no_memberships', pg_catalog.to_jsonb(
             (SELECT count(*)::integer FROM pg_catalog.pg_auth_members m WHERE m.member = i.runtime_oid)),
         i.runtime_oid IS NOT NULL AND NOT EXISTS
           (SELECT 1 FROM pg_catalog.pg_auth_members m WHERE m.member = i.runtime_oid)),
        ('trial_no_set_owner_or_migrator', pg_catalog.to_jsonb('SET'::text),
         CASE WHEN i.trial_oid IS NOT NULL AND i.owner_oid IS NOT NULL
                     AND i.migrator_oid IS NOT NULL
              THEN NOT pg_catalog.pg_has_role(i.trial_oid, i.owner_oid, 'SET')
                   AND NOT pg_catalog.pg_has_role(i.trial_oid, i.migrator_oid, 'SET')
              ELSE false END),
        ('trial_no_usage_owner_or_migrator', pg_catalog.to_jsonb('USAGE'::text),
         CASE WHEN i.trial_oid IS NOT NULL AND i.owner_oid IS NOT NULL
                     AND i.migrator_oid IS NOT NULL
              THEN NOT pg_catalog.pg_has_role(i.trial_oid, i.owner_oid, 'USAGE')
                   AND NOT pg_catalog.pg_has_role(i.trial_oid, i.migrator_oid, 'USAGE')
              ELSE false END),
        ('trial_session_count_zero', pg_catalog.to_jsonb(ss.n), ss.n = 0),
        ('trial_role_settings_count_zero', pg_catalog.to_jsonb(
             (SELECT count(*)::integer FROM pg_catalog.pg_db_role_setting d
               WHERE d.setrole = i.trial_oid)),
         NOT EXISTS (SELECT 1 FROM pg_catalog.pg_db_role_setting d
                      WHERE d.setrole = i.trial_oid))
      ) AS v(item, actual, passed)
),
results AS (
    SELECT 0 AS order_group, 'SUMMARY'::text AS section, 'baseline_checks'::text AS item,
           pg_catalog.jsonb_build_object('total', count(*)::integer,
                            'pass', count(*) FILTER (WHERE passed)::integer,
                            'hold', count(*) FILTER (WHERE NOT passed)::integer) AS details,
           CASE WHEN pg_catalog.bool_and(passed) THEN 'PASS' ELSE 'HOLD' END AS verdict
      FROM checks
    UNION ALL
    SELECT 1, 'CHECK', c.item, pg_catalog.jsonb_build_object('actual', c.actual),
           CASE WHEN c.passed THEN 'PASS' ELSE 'HOLD' END
      FROM checks c
    UNION ALL
    SELECT 2, 'ROLE', r.rolname,
           pg_catalog.jsonb_build_object('login',r.rolcanlogin,'inherit',r.rolinherit,
             'superuser',r.rolsuper,'createdb',r.rolcreatedb,'createrole',r.rolcreaterole,
             'replication',r.rolreplication,'bypassrls',r.rolbypassrls,
             'connection_limit',r.rolconnlimit,'valid_until',r.rolvaliduntil), 'INFO'
      FROM role_inventory r
    UNION ALL
    SELECT 3, 'MEMBERSHIP', m.membership_oid::text,
           pg_catalog.jsonb_build_object('granted_role',m.granted_role,
             'member',m.member_role,'grantor',m.grantor_role,
             'admin',m.admin_option,'inherit',m.inherit_option,'set',m.set_option), 'INFO'
      FROM membership_inventory m
    UNION ALL
    SELECT 4, 'SHDEPEND', d.referenced_role,
           pg_catalog.jsonb_build_object('catalog',d.dependent_catalog,
             'type',d.dependency_type,'database_oid',d.database_oid,'count',d.n), 'INFO'
      FROM shared_dependency_inventory d
    UNION ALL
    SELECT 5, 'DB_ROLE_SETTING', s.setting_role,
           pg_catalog.jsonb_build_object('database_oid',s.database_oid,'count',s.n), 'INFO'
      FROM role_setting_inventory s
)
SELECT section, item, details, verdict
  FROM results
 ORDER BY order_group, section, item, details::text;
