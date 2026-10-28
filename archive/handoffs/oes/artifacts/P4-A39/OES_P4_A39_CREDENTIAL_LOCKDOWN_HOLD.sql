-- OES / PF-I04 / P4-A39 — CREDENTIAL LOCKDOWN / MUTANTE PERSISTENTE / HOLD.
-- UMA TRANSACAO AUTONOMA: invalida novas autenticacoes ANTES do cleanup.
-- Execute somente com aprovacao NOMINAL; nao inclui PASSWORD, senha ou segredo.
-- NOLOGIN nao encerra sessoes existentes; cleanup exige nenhuma sessao trial.
-- Pode ser priorizado em contingencia sob gate proprio, mesmo sem postflight PASS.
BEGIN;
SET LOCAL search_path = pg_catalog;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '15s';
DO $oes_a39_lock_pre$
BEGIN
  IF current_database()<>'oes_sandbox'
     OR session_user<>'oes_sandbox_owner'
     OR current_user<>'oes_sandbox_owner'
     OR current_setting('server_version_num')::integer NOT BETWEEN 180000 AND 189999
     OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_roles r
         WHERE r.rolname='oes_p4_trial_login'
           AND NOT r.rolsuper AND NOT r.rolcreaterole AND NOT r.rolcreatedb
           AND NOT r.rolreplication AND NOT r.rolbypassrls)
  THEN RAISE EXCEPTION 'HOLD A39: wrong owner, database or login identity'; END IF;
END
$oes_a39_lock_pre$;
ALTER ROLE oes_p4_trial_login WITH NOLOGIN PASSWORD NULL;
DO $oes_a39_lock_post$
BEGIN
  IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_roles r
      WHERE r.rolname='oes_p4_trial_login' AND NOT r.rolcanlogin
        AND NOT r.rolsuper AND NOT r.rolcreaterole AND NOT r.rolcreatedb
        AND NOT r.rolreplication AND NOT r.rolbypassrls)
  THEN RAISE EXCEPTION 'HOLD A39: role not disabled'; END IF;
END
$oes_a39_lock_post$;
COMMIT;
-- A senha nao aparece em pg_roles. A confirmacao de PASSWORD NULL e
-- a execucao bem-sucedida do ALTER ROLE com COMMIT, nao uma leitura do hash.
-- Se este script falhar, nao executar cleanup; tratar credencial como ativa.
