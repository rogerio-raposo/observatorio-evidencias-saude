-- OES / PF-I04 / P4-A37 — SETUP SINTETICO: NAO EXECUTAR SEM AUTORIZACAO NOMINAL.
-- EXECUTOR: oes_sandbox_owner, projeto weathered-boat-65779510,
-- branch br-gentle-hall-b6jaxehf, database oes_sandbox, PostgreSQL 18.
-- ALTERA ESTADO: cria uma role NOLOGIN sem ownership e delega ADMIN SOMENTE SOBRE ELA.
-- NAO concede ousandbox_owner, oes_django_migrator ou qualquer papel Django.
BEGIN;
SET LOCAL search_path = pg_catalog;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '15s';
DO $oes_a37_setup_pre$
BEGIN
  IF current_database() <> 'oes_sandbox'
     OR session_user <> 'oes_sandbox_owner'
     OR current_user <> 'oes_sandbox_owner'
     OR current_setting('server_version_num')::integer NOT BETWEEN 180000 AND 189999
     OR to_regrole('oes_p4_trial_target') IS NOT NULL
     OR to_regrole('oes_p4_trial_login') IS NULL
     OR NOT EXISTS (
       SELECT 1 FROM pg_roles
        WHERE rolname = 'oes_p4_trial_login' AND rolcanlogin AND NOT rolinherit
          AND NOT rolsuper AND NOT rolcreaterole AND NOT rolcreatedb
          AND NOT rolreplication AND NOT rolbypassrls AND rolconnlimit=1)
     OR EXISTS (SELECT 1 FROM pg_auth_members WHERE member='oes_p4_trial_login'::regrole)
     OR (SELECT count(*) FROM pg_auth_members
         WHERE roleid='oes_django_migrator'::regrole
           AND member='oes_sandbox_owner'::regrole) <> 1
     OR NOT EXISTS (SELECT 1 FROM pg_auth_members WHERE oid=155649
         AND roleid='oes_django_migrator'::regrole
         AND member='oes_sandbox_owner'::regrole
         AND grantor='cloud_admin'::regrole
         AND admin_option AND NOT inherit_option AND NOT set_option)
  THEN RAISE EXCEPTION 'HOLD A37: setup baseline diverged'; END IF;
END
$oes_a37_setup_pre$;
CREATE ROLE oes_p4_trial_target
  WITH NOLOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE
       NOREPLICATION NOBYPASSRLS;
GRANT oes_p4_trial_target TO oes_p4_trial_login
  WITH ADMIN TRUE, INHERIT FALSE, SET FALSE
  GRANTED BY oes_sandbox_owner;
DO $oes_a37_setup_post$
BEGIN
  IF (SELECT count(*) FROM pg_auth_members
       WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole) <> 1
     OR NOT EXISTS (SELECT 1 FROM pg_auth_members
       WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole
         AND grantor='oes_sandbox_owner'::regrole
         AND admin_option AND NOT inherit_option AND NOT set_option)
     OR pg_has_role('oes_p4_trial_login','oes_p4_trial_target','SET')
     OR pg_has_role('oes_p4_trial_login','oes_p4_trial_target','USAGE')
  THEN RAISE EXCEPTION 'HOLD A37: synthetic membership not isolated'; END IF;
END
$oes_a37_setup_post$;
COMMIT;
-- SOMENTE APOS NOVO GATE: este SETUP e persistente ate limpeza nominalmente autorizada.
