-- OES / PF-I04 / P4-A37 — ENSAIO SINTETICO ROLLBACK-ONLY.
-- NAO EXECUTAR SEM AUTORIZACAO NOMINAL POR SHA256 E CANAL DE SESSAO UNICA.
-- LOGIN: oes_p4_trial_login; alvo vazio: oes_p4_trial_target.
-- Nenhuma operacao em oes_django_migrator, oes_sandbox_owner, oes_app ou Q0.
BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '15s';
SET LOCAL idle_in_transaction_session_timeout = '30s';
SET LOCAL search_path = pg_catalog;
DO $oes_a37_pre$
BEGIN
  IF current_database() <> 'oes_sandbox'
     OR session_user <> 'oes_p4_trial_login'
     OR current_user <> 'oes_p4_trial_login'
     OR current_setting('server_version_num')::integer NOT BETWEEN 180000 AND 189999
     OR NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_p4_trial_target'
         AND NOT rolcanlogin AND NOT rolsuper AND NOT rolcreatedb
         AND NOT rolcreaterole AND NOT rolreplication AND NOT rolbypassrls)
     OR (SELECT count(*) FROM pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
          AND member='oes_p4_trial_login'::regrole) <> 1
     OR NOT EXISTS (SELECT 1 FROM pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
          AND member='oes_p4_trial_login'::regrole
          AND grantor='oes_sandbox_owner'::regrole
          AND admin_option AND NOT inherit_option AND NOT set_option)
     OR pg_has_role('oes_p4_trial_login','oes_p4_trial_target','SET')
     OR pg_has_role('oes_p4_trial_login','oes_p4_trial_target','USAGE')
     OR pg_has_role('oes_p4_trial_login','oes_django_migrator','SET')
     OR pg_has_role('oes_p4_trial_login','oes_sandbox_owner','SET')
     OR (SELECT count(*) FROM pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 1
     OR NOT EXISTS (SELECT 1 FROM pg_auth_members WHERE oid=155649
        AND roleid='oes_django_migrator'::regrole
        AND member='oes_sandbox_owner'::regrole
        AND grantor='cloud_admin'::regrole
        AND admin_option AND NOT inherit_option AND NOT set_option)
  THEN RAISE EXCEPTION 'HOLD A37: preflight mismatch'; END IF;
END
$oes_a37_pre$;
SELECT 'A37_PRE'::text AS phase,pg_backend_pid() AS backend_pid,
       session_user::text AS session_user,current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole) AS membership_count;
GRANT oes_p4_trial_target TO oes_p4_trial_login
  WITH ADMIN FALSE, INHERIT FALSE, SET TRUE
  GRANTED BY oes_p4_trial_login;
DO $oes_a37_grant$
BEGIN
 IF (SELECT count(*) FROM pg_auth_members
      WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole) <> 2
    OR NOT EXISTS (SELECT 1 FROM pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole
        AND grantor='oes_sandbox_owner'::regrole
        AND admin_option AND NOT inherit_option AND NOT set_option)
    OR NOT EXISTS (SELECT 1 FROM pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole
        AND grantor='oes_p4_trial_login'::regrole
        AND NOT admin_option AND NOT inherit_option AND set_option)
    OR NOT pg_has_role('oes_p4_trial_login','oes_p4_trial_target','SET')
 THEN RAISE EXCEPTION 'HOLD A37: grantor isolation failed'; END IF;
END
$oes_a37_grant$;
SELECT 'A37_TEMP_GRANT'::text AS phase,pg_backend_pid() AS backend_pid,
       session_user::text AS session_user,current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole) AS membership_count;
SET LOCAL ROLE oes_p4_trial_target;
DO $oes_a37_set$
BEGIN
 IF current_user <> 'oes_p4_trial_target' OR session_user <> 'oes_p4_trial_login'
 THEN RAISE EXCEPTION 'HOLD A37: SET LOCAL ROLE failed'; END IF;
END
$oes_a37_set$;
SELECT 'A37_TARGET'::text AS phase,pg_backend_pid() AS backend_pid,
       session_user::text AS session_user,current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole) AS membership_count;
SET LOCAL ROLE NONE;
DO $oes_a37_reset$
BEGIN
 IF current_user <> 'oes_p4_trial_login' OR session_user <> 'oes_p4_trial_login'
 THEN RAISE EXCEPTION 'HOLD A37: identity not restored'; END IF;
END
$oes_a37_reset$;
REVOKE oes_p4_trial_target FROM oes_p4_trial_login
  GRANTED BY oes_p4_trial_login RESTRICT;
DO $oes_a37_clean$
BEGIN
 IF (SELECT count(*) FROM pg_auth_members
      WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole) <> 1
    OR NOT EXISTS (SELECT 1 FROM pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole
        AND grantor='oes_sandbox_owner'::regrole
        AND admin_option AND NOT inherit_option AND NOT set_option)
    OR EXISTS (SELECT 1 FROM pg_auth_members
        WHERE roleid='oes_p4_trial_target'::regrole
        AND member='oes_p4_trial_login'::regrole
        AND grantor='oes_p4_trial_login'::regrole)
    OR pg_has_role('oes_p4_trial_login','oes_p4_trial_target','SET')
 THEN RAISE EXCEPTION 'HOLD A37: cleanup failed'; END IF;
END
$oes_a37_clean$;
SELECT 'A37_CLEAN'::text AS phase,pg_backend_pid() AS backend_pid,
       session_user::text AS session_user,current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_p4_trial_target'::regrole
         AND member='oes_p4_trial_login'::regrole) AS membership_count;
ROLLBACK;
-- INTEGRIDADE: ultimo comando e ROLLBACK. Proibido COMMIT.
