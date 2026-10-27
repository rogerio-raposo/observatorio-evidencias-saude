-- OES / PF-I04/P4-A21 — TRANSACAO V2 CANDIDATA — HOLD / NAO EXECUTAR
-- Este arquivo NÃO constitui autorização de SQL mutante.
-- Caso ocorra erro em qualquer statement: ROLLBACK integral, sem recuperacao ad hoc.
-- SQL Editor Neon/cliente deve garantir UMA SESSAO e UMA TRANSACAO para TODAS as instrucoes.
-- Neon nao foi usado nesta atividade; sintaxe e semantica ainda carecem de ensaio autorizado.
-- NÃO executar antes de gate nominal e aprovação da matriz/identidade/canal.
-- Não usar no branch de produção. Nunca repetir automaticamente após commit incerto.

-- Convenções: somente catálogos, funções de privilégio e ACL; nunca SELECT em dados Django/Q0.
-- PostgreSQL 18; manter all statements no mesmo backend/uma transação; canal ainda NÃO VALIDADO.
-- Baseline exata antes dos GRANTs e matriz de privilégio após a concessão.
-- Resultado do commit incerto: consultar estado independentemente; NUNCA repetir automaticamente.

BEGIN;
SET LOCAL lock_timeout = '2s';
SET LOCAL statement_timeout = '12s';
SET LOCAL idle_in_transaction_session_timeout = '30s';
SET LOCAL search_path = pg_catalog;

-- TRAVA FISICA DO CANDIDATO: impede execução acidental. NÃO remover sem novo gate.
DO $oes_hard_hold$
BEGIN
    RAISE EXCEPTION 'HOLD: P4-A21 documentary candidate. No mutating SQL authorized.';
END
$oes_hard_hold$;

DO $oes_pre$
DECLARE actual text[];
BEGIN
    IF current_database() <> 'oes_sandbox' OR session_user <> 'oes_sandbox_owner'
       OR current_user <> 'oes_sandbox_owner'
    THEN RAISE EXCEPTION 'HOLD: database/session/executor mismatch'; END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_runtime'
       AND rolcanlogin AND NOT rolinherit AND NOT rolsuper AND NOT rolcreatedb
       AND NOT rolcreaterole AND NOT rolreplication AND NOT rolbypassrls)
    OR NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_django_migrator'
       AND NOT rolcanlogin AND NOT rolsuper AND NOT rolcreatedb
       AND NOT rolcreaterole AND NOT rolreplication AND NOT rolbypassrls)
    THEN RAISE EXCEPTION 'HOLD: unexpected role attributes'; END IF;

    IF (SELECT count(*) FROM pg_auth_members
          WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 1
    OR NOT EXISTS (
        SELECT 1 FROM pg_auth_members WHERE oid=155649
        AND roleid='oes_django_migrator'::regrole
        AND member='oes_sandbox_owner'::regrole
        AND grantor='cloud_admin'::regrole
        AND admin_option AND NOT inherit_option AND NOT set_option
    )
    OR EXISTS(SELECT 1 FROM pg_auth_members WHERE member='oes_runtime'::regrole)
    OR pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')
    OR pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE')
    THEN RAISE EXCEPTION 'HOLD: unexpected role memberships'; END IF;

    IF (SELECT count(*) FROM pg_namespace
        WHERE nspname IN ('oes_app','core','investigation')
          AND nspowner='oes_sandbox_owner'::regrole) <> 3
    OR has_schema_privilege('oes_django_migrator','oes_app','CREATE')
    OR NOT has_database_privilege('oes_runtime','oes_sandbox','CONNECT')
    OR has_schema_privilege('oes_runtime','oes_app','USAGE')
    OR has_schema_privilege('oes_runtime','oes_app','CREATE')
    OR has_schema_privilege('oes_runtime','core','USAGE')
    OR has_schema_privilege('oes_runtime','core','CREATE')
    OR has_schema_privilege('oes_runtime','investigation','USAGE')
    OR has_schema_privilege('oes_runtime','investigation','CREATE')
    THEN RAISE EXCEPTION 'HOLD: schema/CONNECT baseline mismatch'; END IF;

    SELECT array_agg(c.relname::text ORDER BY c.relname)
    INTO actual FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='oes_app' AND c.relkind='r';
    IF actual IS DISTINCT FROM ARRAY['auth_group', 'auth_group_permissions', 'auth_permission', 'auth_user', 'auth_user_groups', 'auth_user_user_permissions', 'django_content_type', 'django_migrations', 'django_session']::text[]
    THEN RAISE EXCEPTION 'HOLD: exact Django table inventory mismatch'; END IF;

    IF (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE n.nspname='oes_app' AND c.relkind='r'
          AND c.relowner='oes_django_migrator'::regrole) <> 9
    THEN RAISE EXCEPTION 'HOLD: Django table owner mismatch'; END IF;

    SELECT array_agg(c.relname::text ORDER BY c.relname)
    INTO actual FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='oes_app' AND c.relkind='S';
    IF actual IS DISTINCT FROM ARRAY['auth_group_id_seq', 'auth_group_permissions_id_seq', 'auth_permission_id_seq', 'auth_user_groups_id_seq', 'auth_user_id_seq', 'auth_user_user_permissions_id_seq', 'django_content_type_id_seq', 'django_migrations_id_seq']::text[]
    OR (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE n.nspname='oes_app' AND c.relkind='S'
          AND c.relowner='oes_django_migrator'::regrole) <> 8
    THEN RAISE EXCEPTION 'HOLD: exact Django sequence inventory/owner mismatch'; END IF;

    IF (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
         WHERE c.relkind='r' AND c.relowner='oes_sandbox_owner'::regrole
         AND (n.nspname || '.' || c.relname) = ANY (ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[])) <> 5
    THEN RAISE EXCEPTION 'HOLD: Q0 table owner/inventory mismatch'; END IF;

    IF (SELECT count(*) FROM pg_attribute a
        WHERE a.attrelid='oes_app.auth_user'::regclass AND a.attnum>0
          AND NOT a.attisdropped AND a.attname IN ('last_login','password')) <> 2
    THEN RAISE EXCEPTION 'HOLD: auth_user columns changed'; END IF;

    -- Verificar todos os oito privilégios em cada uma das 14 tabelas, um por vez.
    IF EXISTS (
        SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        CROSS JOIN LATERAL unnest(ARRAY[
          'SELECT','INSERT','UPDATE','DELETE','TRUNCATE',
          'REFERENCES','TRIGGER','MAINTAIN']) AS op(priv)
        WHERE c.relkind='r' AND (
          n.nspname='oes_app' OR (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[]))
          AND (has_table_privilege('oes_runtime',c.oid,op.priv)
          OR has_table_privilege('oes_runtime',c.oid,op.priv||' WITH GRANT OPTION'))
    )
    THEN RAISE EXCEPTION 'HOLD: runtime has unexpected preexisting table rights'; END IF;

    -- Verificar também direitos por coluna, que não são cobertos por has_table_privilege.
    IF EXISTS (
        SELECT 1 FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) AS op(priv)
        WHERE a.attnum>0 AND NOT a.attisdropped AND c.relkind='r'
          AND (n.nspname='oes_app' OR (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[]))
          AND (has_column_privilege('oes_runtime',c.oid,a.attnum,op.priv)
             OR has_column_privilege('oes_runtime',c.oid,a.attnum,op.priv||' WITH GRANT OPTION'))
    )
    THEN RAISE EXCEPTION 'HOLD: runtime has unexpected preexisting column rights'; END IF;

    IF EXISTS (
        SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        CROSS JOIN LATERAL unnest(ARRAY['USAGE','SELECT','UPDATE']) AS op(priv)
        WHERE n.nspname='oes_app' AND c.relkind='S'
          AND has_sequence_privilege('oes_runtime',c.oid,op.priv)
    ) THEN RAISE EXCEPTION 'HOLD: runtime has sequence rights'; END IF;
END
$oes_pre$;


-- Somente após uma autorização operacional nominal e validação do canal.
-- 1. Nova associação do concedente oes_sandbox_owner, não modificar OID 155649.
GRANT oes_django_migrator TO oes_sandbox_owner
    WITH ADMIN FALSE, INHERIT FALSE, SET TRUE
    GRANTED BY oes_sandbox_owner;

DO $oes_temp$
BEGIN
    IF (SELECT count(*) FROM pg_auth_members
          WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 2
    OR NOT EXISTS (
       SELECT 1 FROM pg_auth_members
       WHERE roleid='oes_django_migrator'::regrole
       AND member='oes_sandbox_owner'::regrole
       AND grantor='oes_sandbox_owner'::regrole
       AND NOT admin_option AND NOT inherit_option AND set_option
    )
    OR NOT pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')
    THEN RAISE EXCEPTION 'HOLD: temporary membership unavailable'; END IF;
END
$oes_temp$;

-- 2. Owner de objetos Django (NOLOGIN preservado).
SET LOCAL ROLE oes_django_migrator;

DO $oes_who$
BEGIN
    IF current_user <> 'oes_django_migrator'
       OR session_user <> 'oes_sandbox_owner'
    THEN RAISE EXCEPTION 'HOLD: incorrect effective grantor'; END IF;
END
$oes_who$;

GRANT SELECT ON TABLE
    oes_app.auth_user, oes_app.auth_permission,
    oes_app.django_content_type, oes_app.auth_user_user_permissions,
    oes_app.auth_group, oes_app.auth_user_groups,
    oes_app.auth_group_permissions
TO oes_runtime GRANTED BY oes_django_migrator;

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE oes_app.django_session
TO oes_runtime GRANTED BY oes_django_migrator;

GRANT UPDATE (last_login) ON TABLE oes_app.auth_user
TO oes_runtime GRANTED BY oes_django_migrator;

-- 3. Retorno ao proprietário de schema e remoção estrita da janela.
SET LOCAL ROLE NONE;

DO $oes_restored$
BEGIN
    IF current_user <> 'oes_sandbox_owner'
       OR session_user <> 'oes_sandbox_owner'
    THEN RAISE EXCEPTION 'HOLD: owner identity not restored'; END IF;
END
$oes_restored$;

GRANT USAGE ON SCHEMA oes_app
TO oes_runtime GRANTED BY oes_sandbox_owner;

REVOKE oes_django_migrator FROM oes_sandbox_owner
    GRANTED BY oes_sandbox_owner RESTRICT;


-- P4-A21: assertions de concessão. DO contém apenas SELECTs catalogais.
DO $oes_post$
DECLARE actual text[];
BEGIN
    IF current_database() <> 'oes_sandbox' OR current_user <> 'oes_sandbox_owner'
       OR session_user <> 'oes_sandbox_owner'
    THEN RAISE EXCEPTION 'HOLD: postflight wrong identity'; END IF;

    IF (SELECT count(*) FROM pg_auth_members
        WHERE roleid='oes_django_migrator'::regrole
          AND member='oes_sandbox_owner'::regrole) <> 1
    OR NOT EXISTS (
       SELECT 1 FROM pg_auth_members WHERE oid=155649
       AND roleid='oes_django_migrator'::regrole
       AND member='oes_sandbox_owner'::regrole
       AND grantor='cloud_admin'::regrole
       AND admin_option AND NOT inherit_option AND NOT set_option
    )
    OR pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')
    OR EXISTS (SELECT 1 FROM pg_auth_members WHERE member='oes_runtime'::regrole)
    THEN RAISE EXCEPTION 'HOLD: original membership not restored'; END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_django_migrator'
           AND NOT rolcanlogin AND NOT rolcreaterole)
    OR NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='oes_runtime'
           AND rolcanlogin AND NOT rolinherit AND NOT rolcreaterole
           AND NOT rolsuper AND NOT rolcreatedb AND NOT rolreplication AND NOT rolbypassrls)
    OR has_schema_privilege('oes_django_migrator','oes_app','CREATE')
    THEN RAISE EXCEPTION 'HOLD: role/scheme invariants violated'; END IF;

    SELECT array_agg(c.relname::text ORDER BY c.relname) INTO actual
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='oes_app' AND c.relkind='r';
    IF actual IS DISTINCT FROM ARRAY['auth_group', 'auth_group_permissions', 'auth_permission', 'auth_user', 'auth_user_groups', 'auth_user_user_permissions', 'django_content_type', 'django_migrations', 'django_session']::text[]
    OR (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE n.nspname='oes_app' AND c.relkind='r'
          AND c.relowner='oes_django_migrator'::regrole) <> 9
    THEN RAISE EXCEPTION 'HOLD: Django ownership/inventory drift'; END IF;

    SELECT array_agg(c.relname::text ORDER BY c.relname) INTO actual
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='oes_app' AND c.relkind='S';
    IF actual IS DISTINCT FROM ARRAY['auth_group_id_seq', 'auth_group_permissions_id_seq', 'auth_permission_id_seq', 'auth_user_groups_id_seq', 'auth_user_id_seq', 'auth_user_user_permissions_id_seq', 'django_content_type_id_seq', 'django_migrations_id_seq']::text[]
    OR (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE n.nspname='oes_app' AND c.relkind='S'
          AND c.relowner='oes_django_migrator'::regrole) <> 8
    THEN RAISE EXCEPTION 'HOLD: sequence ownership/inventory drift'; END IF;

    IF (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
       WHERE c.relkind='r' AND c.relowner='oes_sandbox_owner'::regrole
       AND (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[])) <> 5
    THEN RAISE EXCEPTION 'HOLD: Q0 inventory/owner drift'; END IF;

    IF NOT has_schema_privilege('oes_runtime','oes_app','USAGE')
       OR has_schema_privilege('oes_runtime','oes_app','CREATE')
       OR has_schema_privilege('oes_runtime','core','USAGE')
       OR has_schema_privilege('oes_runtime','core','CREATE')
       OR has_schema_privilege('oes_runtime','investigation','USAGE')
       OR has_schema_privilege('oes_runtime','investigation','CREATE')
    THEN RAISE EXCEPTION 'HOLD: schema privilege mismatch'; END IF;

    -- Confira individualmente TODOS os oito privilégios de tabela para 9 Django + 5 Q0.
    IF EXISTS(
       SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
       CROSS JOIN LATERAL (VALUES
        ('SELECT'::text, n.nspname='oes_app' AND c.relname=ANY(ARRAY['auth_user', 'auth_permission', 'django_content_type', 'auth_user_user_permissions', 'auth_group', 'auth_user_groups', 'auth_group_permissions', 'django_session']::text[])),
        ('INSERT'::text, n.nspname='oes_app' AND c.relname='django_session'),
        ('UPDATE'::text, n.nspname='oes_app' AND c.relname='django_session'),
        ('DELETE'::text, n.nspname='oes_app' AND c.relname='django_session'),
        ('TRUNCATE'::text, false),('REFERENCES'::text, false),
        ('TRIGGER'::text, false),('MAINTAIN'::text, false)
       ) AS exp(priv,want)
       WHERE c.relkind='r' AND (n.nspname='oes_app'
          OR (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[]))
       AND (has_table_privilege('oes_runtime',c.oid,exp.priv) IS DISTINCT FROM exp.want
         OR has_table_privilege('oes_runtime',c.oid,exp.priv||' WITH GRANT OPTION'))
    ) THEN RAISE EXCEPTION 'HOLD: table privilege matrix mismatch'; END IF;

    -- Conferir TODOS os privilégios por coluna: UPDATE apenas last_login,
    -- ou colunas de django_session por herança do UPDATE da tabela inteira.
    IF EXISTS(
       SELECT 1 FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
       JOIN pg_namespace n ON n.oid=c.relnamespace
       CROSS JOIN LATERAL (VALUES
          ('SELECT'::text, n.nspname='oes_app' AND c.relname=ANY(ARRAY['auth_user', 'auth_permission', 'django_content_type', 'auth_user_user_permissions', 'auth_group', 'auth_user_groups', 'auth_group_permissions', 'django_session']::text[])),
          ('INSERT'::text, n.nspname='oes_app' AND c.relname='django_session'),
          ('UPDATE'::text, n.nspname='oes_app' AND
            (c.relname='django_session' OR (c.relname='auth_user' AND a.attname='last_login'))),
          ('REFERENCES'::text, false)
       ) AS exp(priv,want)
       WHERE a.attnum>0 AND NOT a.attisdropped AND c.relkind='r'
         AND (n.nspname='oes_app'
           OR (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[]))
         AND (has_column_privilege('oes_runtime',c.oid,a.attnum,exp.priv)
                    IS DISTINCT FROM exp.want
            OR has_column_privilege('oes_runtime',c.oid,a.attnum,
                                   exp.priv||' WITH GRANT OPTION'))
    ) THEN RAISE EXCEPTION 'HOLD: column privilege matrix mismatch'; END IF;

    IF EXISTS(
       SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
       CROSS JOIN LATERAL unnest(ARRAY['USAGE','SELECT','UPDATE']) AS exp(priv)
       WHERE n.nspname='oes_app' AND c.relkind='S'
         AND (has_sequence_privilege('oes_runtime',c.oid,exp.priv)
           OR has_sequence_privilege('oes_runtime',c.oid,exp.priv||' WITH GRANT OPTION'))
    ) THEN RAISE EXCEPTION 'HOLD: Django sequence privileges changed'; END IF;

    -- 7 SELECT + 4 CRUD = 11 grants de tabela diretos exatamente, sem grant option.
    IF (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        CROSS JOIN LATERAL aclexplode(COALESCE(c.relacl,acldefault('r',c.relowner))) acl
        WHERE n.nspname='oes_app' AND c.relkind='r'
          AND acl.grantee='oes_runtime'::regrole) <> 11
    OR EXISTS (
        SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
        CROSS JOIN LATERAL aclexplode(COALESCE(c.relacl,acldefault('r',c.relowner))) acl
        WHERE n.nspname='oes_app' AND c.relkind='r'
          AND acl.grantee='oes_runtime'::regrole
          AND (acl.grantor <> 'oes_django_migrator'::regrole OR acl.is_grantable
            OR NOT ( (acl.privilege_type='SELECT' AND c.relname=ANY(ARRAY['auth_user', 'auth_permission', 'django_content_type', 'auth_user_user_permissions', 'auth_group', 'auth_user_groups', 'auth_group_permissions', 'django_session']::text[]))
               OR (acl.privilege_type IN ('INSERT','UPDATE','DELETE')
                   AND c.relname='django_session')))
    ) THEN RAISE EXCEPTION 'HOLD: table ACL/grantor mismatch'; END IF;

    IF (SELECT count(*) FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        CROSS JOIN LATERAL aclexplode(COALESCE(a.attacl,'{}'::aclitem[])) acl
        WHERE n.nspname='oes_app' AND c.relkind='r'
          AND a.attnum>0 AND NOT a.attisdropped
          AND acl.grantee='oes_runtime'::regrole) <> 1
    OR NOT EXISTS (
        SELECT 1 FROM pg_attribute a
        CROSS JOIN LATERAL aclexplode(COALESCE(a.attacl,'{}'::aclitem[])) acl
        WHERE a.attrelid='oes_app.auth_user'::regclass AND a.attname='last_login'
          AND acl.grantee='oes_runtime'::regrole
          AND acl.grantor='oes_django_migrator'::regrole
          AND acl.privilege_type='UPDATE' AND NOT acl.is_grantable
    ) THEN RAISE EXCEPTION 'HOLD: column ACL/grantor mismatch'; END IF;

    IF (SELECT count(*) FROM pg_namespace n
        CROSS JOIN LATERAL aclexplode(COALESCE(n.nspacl,acldefault('n',n.nspowner))) acl
        WHERE n.nspname='oes_app' AND acl.grantee='oes_runtime'::regrole) <> 1
    OR NOT EXISTS (
        SELECT 1 FROM pg_namespace n
        CROSS JOIN LATERAL aclexplode(COALESCE(n.nspacl,acldefault('n',n.nspowner))) acl
        WHERE n.nspname='oes_app' AND acl.grantee='oes_runtime'::regrole
          AND acl.grantor='oes_sandbox_owner'::regrole
          AND acl.privilege_type='USAGE' AND NOT acl.is_grantable
    ) THEN RAISE EXCEPTION 'HOLD: schema ACL/grantor mismatch'; END IF;
END
$oes_post$;

-- Limiar de COMMIT requer aprovação separada e um postflight independente.
COMMIT;
