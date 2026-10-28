-- OES / PF-I04 / P4-A37 — LIMPEZA FINAL SEPARADA; NAO EXECUTAR SEM GATE.
-- Requer resultado do postflight independente anterior, ausencia de execucao ativa,
-- autorizacao de REVOKE e DROP ROLE sinteticamente, executor oes_sandbox_owner.
-- Deixa oes_p4_trial_login com NOLOGIN e PASSWORD NULL por seguranca.
BEGIN;
SET LOCAL search_path = pg_catalog;
DO $oes_a37_cleanup_pre$
BEGIN
 IF current_database()<>'oes_sandbox'
    OR session_user<>'oes_sandbox_owner' OR current_user<>'oes_sandbox_owner'
    OR to_regrole('oes_p4_trial_target') IS NULL
    OR to_regrole('oes_p4_trial_login') IS NULL
    OR (SELECT count(*) FROM pg_auth_members
         WHERE roleid='oes_p4_trial_target'::regrole
           AND member='oes_p4_trial_login'::regrole) <> 1
    OR NOT EXISTS(SELECT 1 FROM pg_auth_members
         WHERE roleid='oes_p4_trial_target'::regrole
           AND member='oes_p4_trial_login'::regrole
           AND grantor='oes_sandbox_owner'::regrole
           AND admin_option AND NOT inherit_option AND NOT set_option)
    OR (SELECT count(*) FROM pg_auth_members
         WHERE roleid='oes_django_migrator'::regrole
           AND member='oes_sandbox_owner'::regrole) <> 1
    OR NOT EXISTS (SELECT 1 FROM pg_auth_members WHERE oid=155649
         AND roleid='oes_django_migrator'::regrole
         AND member='oes_sandbox_owner'::regrole
         AND grantor='cloud_admin'::regrole
         AND admin_option AND NOT inherit_option AND NOT set_option)
 THEN RAISE EXCEPTION 'HOLD A37: cleanup baseline mismatch'; END IF;
END
$oes_a37_cleanup_pre$;
ALTER ROLE oes_p4_trial_login NOLOGIN PASSWORD NULL;
REVOKE oes_p4_trial_target FROM oes_p4_trial_login
  GRANTED BY oes_sandbox_owner RESTRICT;
-- DROP ROLE faz automaticamente as associacoes da role removida, sem alterar migrator.
DROP ROLE oes_p4_trial_target;
DO $oes_a37_cleanup_post$
BEGIN
 IF to_regrole('oes_p4_trial_target') IS NOT NULL
    OR NOT EXISTS(SELECT 1 FROM pg_roles
        WHERE rolname='oes_p4_trial_login' AND NOT rolcanlogin)
    OR EXISTS(SELECT 1 FROM pg_auth_members
        WHERE member='oes_p4_trial_login'::regrole)
 THEN RAISE EXCEPTION 'HOLD A37: cleanup incomplete'; END IF;
END
$oes_a37_cleanup_post$;
COMMIT;
-- Executar somente apos postflight independente PASS, com autorizacao separada.
