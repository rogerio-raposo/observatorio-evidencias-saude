-- OES / PF-I04 / P4-A39 — SETUP V2: CANDIDATO MUTANTE PERSISTENTE — HOLD
-- Nao executar sem gate nominal. CUIDADO: CREATE ROLE/GRANT sao cluster-wide NA BRANCH.
-- Banco oes_sandbox nao identifica por si so a branch Neon.
BEGIN;
SET LOCAL search_path = pg_catalog;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '15s';
DO $oes_a39_setup_pre$
BEGIN
 IF current_database()<>'oes_sandbox'
    OR session_user<>'oes_sandbox_owner' OR current_user<>'oes_sandbox_owner'
    OR current_setting('server_version_num')::integer NOT BETWEEN 180000 AND 189999
    OR to_regrole('oes_p4_trial_target') IS NOT NULL
    OR to_regrole('oes_p4_trial_login') IS NULL
    OR NOT EXISTS (SELECT 1 FROM pg_catalog.pg_roles r
          WHERE r.rolname='oes_p4_trial_login' AND r.rolcanlogin AND NOT r.rolinherit
            AND NOT r.rolsuper AND NOT r.rolcreatedb AND NOT r.rolcreaterole
            AND NOT r.rolreplication AND NOT r.rolbypassrls AND r.rolconnlimit=1)
    OR EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members
          WHERE member='oes_p4_trial_login'::regrole
             OR roleid='oes_p4_trial_login'::regrole)
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members
          WHERE roleid='oes_django_migrator'::regrole
            AND member='oes_sandbox_owner'::regrole)<>1
    OR NOT EXISTS (SELECT 1 FROM pg_catalog.pg_auth_members
          WHERE oid=155649 AND roleid='oes_django_migrator'::regrole
            AND member='oes_sandbox_owner'::regrole AND grantor='cloud_admin'::regrole
            AND admin_option AND NOT inherit_option AND NOT set_option)
 THEN RAISE EXCEPTION 'HOLD A39 setup: baseline or identity unexpected'; END IF;
END
$oes_a39_setup_pre$;
CREATE ROLE oes_p4_trial_target
  WITH NOLOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE
       NOREPLICATION NOBYPASSRLS;
DO $oes_a39_target_only$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_roles
        WHERE rolname='oes_p4_trial_target' AND NOT rolcanlogin AND NOT rolinherit
          AND NOT rolsuper AND NOT rolcreatedb AND NOT rolcreaterole
          AND NOT rolreplication AND NOT rolbypassrls)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
           OR member='oes_p4_trial_target'::regrole)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_shdepend
        WHERE refclassid='pg_catalog.pg_authid'::regclass
          AND refobjid='oes_p4_trial_target'::regrole::oid
          AND classid <> 'pg_catalog.pg_auth_members'::regclass)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_db_role_setting
        WHERE setrole='oes_p4_trial_target'::regrole::oid)
 THEN RAISE EXCEPTION 'HOLD A39 setup: target not pristine'; END IF;
END
$oes_a39_target_only$;
GRANT oes_p4_trial_target TO oes_p4_trial_login
  WITH ADMIN TRUE, INHERIT FALSE, SET FALSE
  GRANTED BY oes_sandbox_owner;
DO $oes_a39_setup_post$
BEGIN
 IF (SELECT count(*) FROM pg_catalog.pg_auth_members
       WHERE roleid='oes_p4_trial_target'::regrole)<>1
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members
       WHERE member='oes_p4_trial_target'::regrole)<>0
    OR (SELECT count(*) FROM pg_catalog.pg_auth_members
       WHERE member='oes_p4_trial_login'::regrole)<>1
    OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_auth_members
       WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole
         AND grantor='oes_sandbox_owner'::regrole
         AND admin_option AND NOT inherit_option AND NOT set_option)
    OR pg_catalog.pg_has_role('oes_p4_trial_login','oes_p4_trial_target','SET')
    OR pg_catalog.pg_has_role('oes_p4_trial_login','oes_p4_trial_target','USAGE')
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_shdepend
       WHERE refclassid='pg_catalog.pg_authid'::regclass
         AND refobjid='oes_p4_trial_target'::regrole::oid
          AND classid <> 'pg_catalog.pg_auth_members'::regclass)
    OR EXISTS(SELECT 1 FROM pg_catalog.pg_db_role_setting
       WHERE setrole='oes_p4_trial_target'::regrole::oid)
 THEN RAISE EXCEPTION 'HOLD A39 setup: unexpected synthetic rights or dependencies'; END IF;
END
$oes_a39_setup_post$;
COMMIT;
-- PERSISTENTE: nao executar antes de autorizacao exata SHA/branch/canal.
