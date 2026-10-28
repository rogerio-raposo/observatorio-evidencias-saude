-- OES / PF-I04 / P4-A29 — ENSAIO DE ASSOCIACAO TEMPORARIA, ROLLBACK-ONLY
-- DOCUMENTO CANDIDATO, NAO AUTORIZADO PARA EXECUCAO NO NEON.
-- ATENCAO: CONTEM GRANT/REVOKE DE ROLE E SET LOCAL ROLE (MUTACOES TRANSITORIAS).
-- SOMENTE no projeto weathered-boat-65779510, branch br-gentle-hall-b6jaxehf,
-- banco oes_sandbox, login de sessao oes_sandbox_owner, apos gate nominal POR SHA256.
-- Exige unica sessao/backend e unico bloco transacional, sem autocommit por statement.
-- Cliente DEVE tratar qualquer erro/interrupcao como HOLD, encerrar/abortar transacao
-- e exigir postflight independente. Nao repetir. NUNCA SUBSTITUIR ROLLBACK POR COMMIT.
-- Nao realizar GRANT em schema/tabela/coluna/sequencia, INSERT, UPDATE ou DELETE.

BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '15s';
SET LOCAL idle_in_transaction_session_timeout = '30s';
SET LOCAL search_path = pg_catalog;

DO $oes_a29_pre$
BEGIN
    IF current_database() <> 'oes_sandbox'
       OR session_user <> 'oes_sandbox_owner'
       OR current_user <> 'oes_sandbox_owner'
       OR current_setting('server_version_num')::int < 180000
       OR current_setting('server_version_num')::int >= 190000
    THEN RAISE EXCEPTION 'HOLD A29: environment/version/session mismatch'; END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_roles
        WHERE rolname='oes_django_migrator'
          AND NOT rolcanlogin AND NOT rolsuper AND NOT rolcreaterole
          AND NOT rolcreatedb AND NOT rolreplication AND NOT rolbypassrls
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_roles
        WHERE rolname='oes_runtime' AND rolcanlogin AND NOT rolinherit
          AND NOT rolsuper AND NOT rolcreaterole AND NOT rolcreatedb
          AND NOT rolreplication AND NOT rolbypassrls
    ) THEN RAISE EXCEPTION 'HOLD A29: role flags mismatch'; END IF;

    IF (SELECT count(*) FROM pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 1
       OR NOT EXISTS (
        SELECT 1 FROM pg_auth_members
        WHERE oid=155649
          AND roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole
          AND grantor='cloud_admin'::regrole
          AND admin_option AND NOT inherit_option AND NOT set_option
    )
       OR EXISTS (
        SELECT 1 FROM pg_auth_members
        WHERE member='oes_runtime'::regrole
    )
       OR pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')
       OR pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE')
    THEN RAISE EXCEPTION 'HOLD A29: membership baseline mismatch'; END IF;

    IF has_schema_privilege('oes_runtime','oes_app','USAGE')
       OR has_schema_privilege('oes_runtime','oes_app','CREATE')
       OR has_table_privilege('oes_runtime','oes_app.auth_user','SELECT')
       OR has_table_privilege('oes_runtime','oes_app.django_session','INSERT')
    THEN RAISE EXCEPTION 'HOLD A29: runtime baseline is no longer pre-GRANT'; END IF;
END
$oes_a29_pre$;

SELECT 'A29_PRE'::text AS phase, pg_backend_pid() AS backend_pid,
       session_user::text AS session_user, current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) AS membership_count;

-- A associacao ORIGINAL OID 155649 (grantor cloud_admin) nao pode ser tocada.
-- Admin true da associacao original permite o grant temporario da opcao SET.
GRANT oes_django_migrator TO oes_sandbox_owner
    WITH ADMIN FALSE, INHERIT FALSE, SET TRUE
    GRANTED BY oes_sandbox_owner;

DO $oes_a29_temp$
BEGIN
    IF (SELECT count(*) FROM pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 2
       OR NOT EXISTS (
          SELECT 1 FROM pg_auth_members
          WHERE oid=155649
            AND roleid='oes_django_migrator'::regrole
            AND member='oes_sandbox_owner'::regrole
            AND grantor='cloud_admin'::regrole
            AND admin_option AND NOT inherit_option AND NOT set_option
       )
       OR (SELECT count(*) FROM pg_auth_members
           WHERE roleid='oes_django_migrator'::regrole
             AND member='oes_sandbox_owner'::regrole
             AND grantor='oes_sandbox_owner'::regrole
             AND NOT admin_option AND NOT inherit_option AND set_option) <> 1
       OR NOT pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')
    THEN RAISE EXCEPTION 'HOLD A29: temporary membership not isolated'; END IF;
END
$oes_a29_temp$;

SELECT 'A29_TEMP_GRANT'::text AS phase, pg_backend_pid() AS backend_pid,
       session_user::text AS session_user, current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) AS membership_count;

-- UNICO objetivo da mudanca de identidade: verificar possibilidade de SET ROLE.
-- Nao executar GRANT em objetos do Django, nem consultas aos dados do Django.
SET LOCAL ROLE oes_django_migrator;

DO $oes_a29_as_migrator$
BEGIN
    IF current_user <> 'oes_django_migrator'
       OR session_user <> 'oes_sandbox_owner'
       OR NOT EXISTS (
           SELECT 1 FROM pg_roles
           WHERE rolname=current_user AND NOT rolcanlogin
       )
    THEN RAISE EXCEPTION 'HOLD A29: SET LOCAL ROLE did not take effect'; END IF;
END
$oes_a29_as_migrator$;

SELECT 'A29_MIGRATOR'::text AS phase, pg_backend_pid() AS backend_pid,
       session_user::text AS session_user, current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) AS membership_count;

SET LOCAL ROLE NONE;

DO $oes_a29_restored$
BEGIN
    IF current_user <> 'oes_sandbox_owner'
       OR session_user <> 'oes_sandbox_owner'
    THEN RAISE EXCEPTION 'HOLD A29: original identity not restored'; END IF;
END
$oes_a29_restored$;

-- REVOKE EXCLUSIVAMENTE DA CONCESSAO DO PROPRIO OWNER. SEM CASCADE.
REVOKE oes_django_migrator FROM oes_sandbox_owner
    GRANTED BY oes_sandbox_owner RESTRICT;

DO $oes_a29_cleanup$
BEGIN
    IF (SELECT count(*) FROM pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 1
       OR NOT EXISTS (
           SELECT 1 FROM pg_auth_members
           WHERE oid=155649
             AND roleid='oes_django_migrator'::regrole
             AND member='oes_sandbox_owner'::regrole
             AND grantor='cloud_admin'::regrole
             AND admin_option AND NOT inherit_option AND NOT set_option
       )
       OR EXISTS (
           SELECT 1 FROM pg_auth_members
           WHERE roleid='oes_django_migrator'::regrole
             AND member='oes_sandbox_owner'::regrole
             AND grantor='oes_sandbox_owner'::regrole
       )
       OR pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')
       OR pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE')
       OR current_user <> 'oes_sandbox_owner'
    THEN RAISE EXCEPTION 'HOLD A29: cleanup or original association mismatch'; END IF;
END
$oes_a29_cleanup$;

SELECT 'A29_CLEAN'::text AS phase, pg_backend_pid() AS backend_pid,
       session_user::text AS session_user, current_user::text AS current_user,
       (SELECT count(*) FROM pg_auth_members WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) AS membership_count;

-- ESTE EH O UNICO TERMINADOR DE TRANSACAO NO ARQUIVO. NUNCA COMMIT.
ROLLBACK;
