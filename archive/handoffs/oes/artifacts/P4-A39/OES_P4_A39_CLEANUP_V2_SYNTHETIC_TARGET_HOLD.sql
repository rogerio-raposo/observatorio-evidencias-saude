-- OES / PF-I04 / P4-A39 — CLEANUP V2: CANDIDATO MUTANTE PERSISTENTE — HOLD
-- GATE AUTONOMO apos postflight v2 PASS, evidencias de trial e sem outras sessoes.
-- Branch Neon deve ser certificada fora do SQL. Nao usa DROP OWNED/CASCADE.
BEGIN;
SET LOCAL search_path = pg_catalog;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '15s';
DO $oes_a39_cleanup_pre$
DECLARE
 v_target oid := pg_catalog.to_regrole('oes_p4_trial_target')::oid;
 v_trial oid := pg_catalog.to_regrole('oes_p4_trial_login')::oid;
BEGIN
 IF current_database()<>'oes_sandbox'
    OR session_user<>'oes_sandbox_owner' OR current_user<>'oes_sandbox_owner'
    OR current_setting('server_version_num')::integer NOT BETWEEN 180000 AND 189999
    OR v_target IS NULL OR v_trial IS NULL
    OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_roles r WHERE r.oid=v_target
      AND NOT r.rolcanlogin AND NOT r.rolinherit AND NOT r.rolsuper
      AND NOT r.rolcreatedb AND NOT r.rolcreaterole AND NOT r.rolreplication AND NOT r.rolbypassrls)
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members WHERE roleid=v_target)<>1
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members WHERE member=v_target)<>0
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members WHERE member=v_trial)<>1
    OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_auth_members
        WHERE roleid=v_target AND member=v_trial AND grantor='oes_sandbox_owner'::regrole
          AND admin_option AND NOT inherit_option AND NOT set_option)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_shdepend
        WHERE refclassid='pg_catalog.pg_authid'::regclass AND refobjid=v_target
          AND classid <> 'pg_catalog.pg_auth_members'::regclass)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_db_role_setting WHERE setrole=v_target)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_stat_activity
        WHERE usename='oes_p4_trial_login')
    OR pg_catalog.pg_has_role(v_trial,v_target,'SET')
    OR pg_catalog.pg_has_role(v_trial,v_target,'USAGE')
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members
         WHERE roleid='oes_django_migrator'::regrole
           AND member='oes_sandbox_owner'::regrole)<>1
    OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_auth_members
        WHERE oid=155649 AND roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole AND grantor='cloud_admin'::regrole
          AND admin_option AND NOT inherit_option AND NOT set_option)
 THEN RAISE EXCEPTION 'HOLD A39 cleanup: external dependency, session, grant or baseline'; END IF;
END
$oes_a39_cleanup_pre$;
ALTER ROLE oes_p4_trial_login WITH NOLOGIN PASSWORD NULL;
REVOKE oes_p4_trial_target FROM oes_p4_trial_login
  GRANTED BY oes_sandbox_owner RESTRICT;
DROP ROLE oes_p4_trial_target;
DO $oes_a39_cleanup_post$
BEGIN
 IF pg_catalog.to_regrole('oes_p4_trial_target') IS NOT NULL
    OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_roles
        WHERE rolname='oes_p4_trial_login' AND NOT rolcanlogin)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_auth_members
        WHERE member='oes_p4_trial_login'::regrole
           OR roleid='oes_p4_trial_login'::regrole)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_stat_activity
        WHERE usename='oes_p4_trial_login')
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole)<>1
    OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_auth_members
        WHERE oid=155649 AND roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole AND grantor='cloud_admin'::regrole
          AND admin_option AND NOT inherit_option AND NOT set_option)
 THEN RAISE EXCEPTION 'HOLD A39 cleanup: incomplete or migrator changed'; END IF;
END
$oes_a39_cleanup_post$;
COMMIT;
-- ALTER ROLE ... PASSWORD NULL foi executado, mas consulta posterior de pg_roles
-- nao revela senha/hash; nao consultar pg_authid sem gate e necessidade explicita.
