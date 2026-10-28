-- OES / PF-I04 / P4-A37 — POSTFLIGHT INDEPENDENTE, CANDIDATO, NAO AUTORIZADO.
-- Uma unica consulta catalogal, nova sessao, nao implica alteracao de dados.
WITH checks AS (
  SELECT 'database'::text AS subject,
         current_database() = 'oes_sandbox' AS passed
  UNION ALL SELECT 'original_migrator_membership',
    (SELECT count(*) = 1 FROM pg_auth_members
      WHERE roleid='oes_django_migrator'::regrole
        AND member='oes_sandbox_owner'::regrole)
  UNION ALL SELECT 'original_migrator_oid',
    EXISTS (SELECT 1 FROM pg_auth_members WHERE oid=155649
      AND roleid='oes_django_migrator'::regrole
      AND member='oes_sandbox_owner'::regrole
      AND grantor='cloud_admin'::regrole
      AND admin_option AND NOT inherit_option AND NOT set_option)
  UNION ALL SELECT 'target_no_login',
    EXISTS(SELECT 1 FROM pg_roles WHERE rolname='oes_p4_trial_target'
      AND NOT rolcanlogin AND NOT rolsuper AND NOT rolcreatedb
      AND NOT rolcreaterole AND NOT rolreplication AND NOT rolbypassrls)
  UNION ALL SELECT 'trial_membership_count_one',
    (SELECT count(*)=1 FROM pg_auth_members
      WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole)
  UNION ALL SELECT 'original_synthetic_grant_intact',
    EXISTS(SELECT 1 FROM pg_auth_members
      WHERE roleid='oes_p4_trial_target'::regrole
      AND member='oes_p4_trial_login'::regrole
      AND grantor='oes_sandbox_owner'::regrole
      AND admin_option AND NOT inherit_option AND NOT set_option)
  UNION ALL SELECT 'no_trial_self_grant',
    NOT EXISTS(SELECT 1 FROM pg_auth_members
      WHERE roleid='oes_p4_trial_target'::regrole
      AND member='oes_p4_trial_login'::regrole
      AND grantor='oes_p4_trial_login'::regrole)
  UNION ALL SELECT 'trial_target_no_SET',
    pg_has_role('oes_p4_trial_login','oes_p4_trial_target','SET') IS FALSE
  UNION ALL SELECT 'trial_target_no_USAGE',
    pg_has_role('oes_p4_trial_login','oes_p4_trial_target','USAGE') IS FALSE
  UNION ALL SELECT 'trial_migrator_no_SET',
    pg_has_role('oes_p4_trial_login','oes_django_migrator','SET') IS FALSE
  UNION ALL SELECT 'trial_owner_no_SET',
    pg_has_role('oes_p4_trial_login','oes_sandbox_owner','SET') IS FALSE
  UNION ALL SELECT 'runtime_no_memberships',
    (SELECT count(*)=0 FROM pg_auth_members WHERE member='oes_runtime'::regrole)
), summary AS (
  SELECT count(*) AS total, count(*) FILTER (WHERE passed IS NOT TRUE) AS failures FROM checks
)
SELECT 0 AS sort_order,'SUMMARY'::text AS item,
       (failures=0 AND total=12) AS passed,
       total::integer AS check_count,failures::integer AS failed_count
  FROM summary
UNION ALL
SELECT 1,subject,COALESCE(passed,false),NULL::integer,NULL::integer FROM checks
ORDER BY sort_order,item;
