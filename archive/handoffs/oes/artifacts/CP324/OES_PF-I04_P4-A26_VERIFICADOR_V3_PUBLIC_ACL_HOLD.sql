-- OES / PF-I04/P4-A26 — VERIFICADOR PASS/HOLD v3 — CANDIDATO DOCUMENTAL
-- NAO EXECUTAR SEM NOVO GATE NOMINAL READ ONLY ESPECIFICO.
-- Derivado do A23 SHA256 567985d9026b1b0a5d5298367ce2f1b70c37e802a95d6ac22876255ea254c0c7.
-- Corrige ACL zero-dimensional (falha A25) e exige ausencia de ACL PUBLIC em
-- oes_app/core/investigation e nas 14 tabelas/colunas + oito sequencias escopadas.
-- Schema public intencionalmente fora da restricao de ACL PUBLIC (USAGE historico).
-- PUBLIC = grantee 0. Outros beneficiarios e objetos fora do universo: nao auditados integralmente.
-- SQL exclusivamente SELECT catalogal; baseline pre-GRANTs esperada HOLD.
-- Falha/erro/saida incompleta/resultado inesperado PASS: HOLD de investigacao.

WITH
role_ids AS (
    SELECT
        (SELECT oid FROM pg_roles WHERE rolname = 'oes_runtime') AS runtime_oid,
        (SELECT oid FROM pg_roles WHERE rolname = 'oes_django_migrator') AS migrator_oid,
        (SELECT oid FROM pg_roles WHERE rolname = 'oes_sandbox_owner') AS owner_oid,
        (SELECT oid FROM pg_roles WHERE rolname = 'cloud_admin') AS cloud_admin_oid
),
expected_role_flags (role_name, flag, expected_value) AS (
    VALUES
      ('oes_runtime','LOGIN',true), ('oes_runtime','INHERIT',false),
      ('oes_runtime','SUPERUSER',false), ('oes_runtime','CREATEDB',false),
      ('oes_runtime','CREATEROLE',false), ('oes_runtime','REPLICATION',false),
      ('oes_runtime','BYPASSRLS',false),
      ('oes_django_migrator','LOGIN',false),
      ('oes_django_migrator','SUPERUSER',false), ('oes_django_migrator','CREATEDB',false),
      ('oes_django_migrator','CREATEROLE',false), ('oes_django_migrator','REPLICATION',false),
      ('oes_django_migrator','BYPASSRLS',false)
),
actual_role_flags AS (
    SELECT r.rolname AS role_name, f.flag, f.actual_value
    FROM pg_roles r
    CROSS JOIN LATERAL (VALUES
      ('LOGIN',r.rolcanlogin),('INHERIT',r.rolinherit),
      ('SUPERUSER',r.rolsuper),('CREATEDB',r.rolcreatedb),
      ('CREATEROLE',r.rolcreaterole),('REPLICATION',r.rolreplication),
      ('BYPASSRLS',r.rolbypassrls)
    ) AS f(flag,actual_value)
    WHERE r.rolname IN ('oes_runtime','oes_django_migrator')
),
expected_schemas(schema_name, expected_owner, expected_usage, expected_create) AS (
    VALUES ('oes_app','oes_sandbox_owner',true,false),
           ('core','oes_sandbox_owner',false,false),
           ('investigation','oes_sandbox_owner',false,false),
           ('public',NULL::text,true,false)
),
expected_tables(schema_name,table_name,expected_owner) AS (
    VALUES
      ('oes_app','auth_group','oes_django_migrator'),
      ('oes_app','auth_group_permissions','oes_django_migrator'),
      ('oes_app','auth_permission','oes_django_migrator'),
      ('oes_app','auth_user','oes_django_migrator'),
      ('oes_app','auth_user_groups','oes_django_migrator'),
      ('oes_app','auth_user_user_permissions','oes_django_migrator'),
      ('oes_app','django_content_type','oes_django_migrator'),
      ('oes_app','django_migrations','oes_django_migrator'),
      ('oes_app','django_session','oes_django_migrator'),
      ('core','entity','oes_sandbox_owner'),
      ('core','entity_version','oes_sandbox_owner'),
      ('investigation','question','oes_sandbox_owner'),
      ('investigation','question_version','oes_sandbox_owner'),
      ('investigation','question_command_receipt','oes_sandbox_owner')
),
observed_tables AS (
    SELECT n.nspname AS schema_name,c.relname AS table_name,c.oid AS table_oid,
           pg_get_userbyid(c.relowner) AS owner_name,c.relacl,c.relowner
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE c.relkind IN ('r','p')
      AND (n.nspname='oes_app'
           OR (n.nspname,c.relname) IN
                (('core','entity'),('core','entity_version'),
                 ('investigation','question'),('investigation','question_version'),
                 ('investigation','question_command_receipt')))
),
scoped_tables AS (
    SELECT coalesce(e.schema_name,a.schema_name) AS schema_name,
           coalesce(e.table_name,a.table_name) AS table_name,
           e.expected_owner,a.owner_name,a.table_oid,a.relacl,a.relowner,
           e.table_name IS NOT NULL AS expected_present,
           a.table_oid IS NOT NULL AS actual_present
    FROM expected_tables e FULL OUTER JOIN observed_tables a
        ON a.schema_name=e.schema_name AND a.table_name=e.table_name
),
expected_sequences(sequence_name) AS (
    VALUES ('auth_group_id_seq'),('auth_group_permissions_id_seq'),
           ('auth_permission_id_seq'),('auth_user_groups_id_seq'),
           ('auth_user_id_seq'),('auth_user_user_permissions_id_seq'),
           ('django_content_type_id_seq'),('django_migrations_id_seq')
),
observed_sequences AS (
    SELECT c.relname AS sequence_name,c.oid AS sequence_oid,
           pg_get_userbyid(c.relowner) AS owner_name,c.relacl,c.relowner
    FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='oes_app' AND c.relkind='S'
),
scoped_sequences AS (
    SELECT coalesce(e.sequence_name,a.sequence_name) AS sequence_name,
           e.sequence_name IS NOT NULL AS expected_present,
           a.sequence_oid IS NOT NULL AS actual_present,
           a.sequence_oid,a.owner_name,a.relacl,a.relowner
    FROM expected_sequences e FULL OUTER JOIN observed_sequences a
      ON e.sequence_name=a.sequence_name
),
expected_table_acl(schema_name,table_name,privilege_type,expected_grantor) AS (
    VALUES
      ('oes_app','auth_user','SELECT','oes_django_migrator'),
      ('oes_app','auth_permission','SELECT','oes_django_migrator'),
      ('oes_app','django_content_type','SELECT','oes_django_migrator'),
      ('oes_app','auth_user_user_permissions','SELECT','oes_django_migrator'),
      ('oes_app','auth_group','SELECT','oes_django_migrator'),
      ('oes_app','auth_user_groups','SELECT','oes_django_migrator'),
      ('oes_app','auth_group_permissions','SELECT','oes_django_migrator'),
      ('oes_app','django_session','SELECT','oes_django_migrator'),
      ('oes_app','django_session','INSERT','oes_django_migrator'),
      ('oes_app','django_session','UPDATE','oes_django_migrator'),
      ('oes_app','django_session','DELETE','oes_django_migrator')
),
actual_table_acl AS (
    SELECT t.schema_name,t.table_name, acl.privilege_type,
           pg_get_userbyid(acl.grantor) AS grantor,acl.is_grantable
    FROM observed_tables t CROSS JOIN role_ids ids
    CROSS JOIN LATERAL aclexplode(CASE WHEN cardinality(coalesce(t.relacl,acldefault('r',t.relowner))) > 0 THEN coalesce(t.relacl,acldefault('r',t.relowner)) ELSE NULL::aclitem[] END) acl
    WHERE acl.grantee=ids.runtime_oid
),
expected_column_acl(schema_name,table_name,column_name,privilege_type,expected_grantor) AS (
    VALUES ('oes_app','auth_user','last_login','UPDATE','oes_django_migrator')
),
actual_column_acl AS (
    SELECT t.schema_name,t.table_name,a.attname AS column_name,
           acl.privilege_type,pg_get_userbyid(acl.grantor) AS grantor,
           acl.is_grantable
    FROM observed_tables t JOIN pg_attribute a ON a.attrelid=t.table_oid
    CROSS JOIN role_ids ids
    CROSS JOIN LATERAL aclexplode(CASE WHEN cardinality(a.attacl) > 0 THEN a.attacl ELSE NULL::aclitem[] END) acl
    WHERE a.attnum>0 AND NOT a.attisdropped AND acl.grantee=ids.runtime_oid
),
expected_schema_acl(schema_name,privilege_type,expected_grantor) AS (
    VALUES ('oes_app','USAGE','oes_sandbox_owner')
),
actual_schema_acl AS (
    SELECT n.nspname AS schema_name,acl.privilege_type,
           pg_get_userbyid(acl.grantor) AS grantor,acl.is_grantable
    FROM pg_namespace n CROSS JOIN role_ids ids
    CROSS JOIN LATERAL aclexplode(CASE WHEN cardinality(coalesce(n.nspacl,acldefault('n',n.nspowner))) > 0 THEN coalesce(n.nspacl,acldefault('n',n.nspowner)) ELSE NULL::aclitem[] END) acl
    WHERE n.nspname IN ('oes_app','core','investigation','public')
      AND acl.grantee=ids.runtime_oid
),
actual_sequence_acl AS (
    SELECT s.sequence_name,acl.privilege_type,
           pg_get_userbyid(acl.grantor) AS grantor,acl.is_grantable
    FROM observed_sequences s CROSS JOIN role_ids ids
    CROSS JOIN LATERAL aclexplode(CASE WHEN cardinality(coalesce(s.relacl,acldefault('s',s.relowner))) > 0 THEN coalesce(s.relacl,acldefault('s',s.relowner)) ELSE NULL::aclitem[] END) acl
    WHERE acl.grantee=ids.runtime_oid
),
-- PUBLIC tem pseudo-oid 0; ausencia de ACL explicito deve ser demonstrada.
-- A whitelist de PUBLIC nao inclui schema public, cujo USAGE preexistente e permitido.
actual_public_acl AS (
    SELECT 'schema'::text AS object_class,n.nspname::text AS object_name,
           acl.privilege_type,pg_get_userbyid(acl.grantor)::text AS grantor,
           acl.is_grantable
    FROM pg_namespace n
    CROSS JOIN LATERAL aclexplode(CASE
      WHEN cardinality(coalesce(n.nspacl,acldefault('n',n.nspowner))) > 0
      THEN coalesce(n.nspacl,acldefault('n',n.nspowner))
      ELSE NULL::aclitem[] END) AS acl
    WHERE n.nspname IN ('oes_app','core','investigation') AND acl.grantee=0
    UNION ALL
    SELECT 'table',t.schema_name||'.'||t.table_name,
           acl.privilege_type,pg_get_userbyid(acl.grantor)::text,acl.is_grantable
    FROM observed_tables t
    CROSS JOIN LATERAL aclexplode(CASE
      WHEN cardinality(coalesce(t.relacl,acldefault('r',t.relowner))) > 0
      THEN coalesce(t.relacl,acldefault('r',t.relowner))
      ELSE NULL::aclitem[] END) AS acl
    WHERE acl.grantee=0
    UNION ALL
    SELECT 'column',t.schema_name||'.'||t.table_name||'.'||a.attname,
           acl.privilege_type,pg_get_userbyid(acl.grantor)::text,acl.is_grantable
    FROM observed_tables t JOIN pg_attribute a ON a.attrelid=t.table_oid
    CROSS JOIN LATERAL aclexplode(CASE
      WHEN cardinality(a.attacl) > 0 THEN a.attacl
      ELSE NULL::aclitem[] END) AS acl
    WHERE a.attnum>0 AND NOT a.attisdropped AND acl.grantee=0
    UNION ALL
    SELECT 'sequence','oes_app.'||s.sequence_name,
           acl.privilege_type,pg_get_userbyid(acl.grantor)::text,acl.is_grantable
    FROM observed_sequences s
    CROSS JOIN LATERAL aclexplode(CASE
      WHEN cardinality(coalesce(s.relacl,acldefault('s',s.relowner))) > 0
      THEN coalesce(s.relacl,acldefault('s',s.relowner))
      ELSE NULL::aclitem[] END) AS acl
    WHERE acl.grantee=0
),
expected_table_ops(privilege_type) AS (
    VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),
           ('REFERENCES'),('TRIGGER'),('MAINTAIN')
),
expected_column_ops(privilege_type) AS (
    VALUES ('SELECT'),('INSERT'),('UPDATE'),('REFERENCES')
),
expected_sequence_ops(privilege_type) AS (
    VALUES ('USAGE'),('SELECT'),('UPDATE')
),
checks AS (
    -- Execucao em identidade administrativa aprovada (o runtime nunca e usado no postflight).
    SELECT 'identity'::text AS check_group,'database'::text AS subject,
           'oes_sandbox'::text AS expected,current_database()::text AS actual,
           current_database()='oes_sandbox' AS passed
    UNION ALL SELECT 'identity','session_user','oes_sandbox_owner',session_user::text,
           session_user='oes_sandbox_owner'
    UNION ALL SELECT 'identity','current_user','oes_sandbox_owner',current_user::text,
           current_user='oes_sandbox_owner'
    UNION ALL SELECT 'identity','runtime_db_CONNECT','true',
           has_database_privilege('oes_runtime',current_database(),'CONNECT')::text,
           has_database_privilege('oes_runtime',current_database(),'CONNECT') IS TRUE
    UNION ALL
    -- Os papeis devem existir, e os atributos examinados devem coincidir exatamente.
    SELECT 'role',e.role_name||'.'||e.flag,e.expected_value::text,
           coalesce(a.actual_value::text,'NULL'),
           a.actual_value IS NOT DISTINCT FROM e.expected_value
    FROM expected_role_flags e LEFT JOIN actual_role_flags a
      ON a.role_name=e.role_name AND a.flag=e.flag
    UNION ALL
    -- Uma associacao original cloud_admin, nenhuma temporaria e nenhum membership runtime.
    SELECT 'membership','owner_to_migrator_count','1',
           (SELECT count(*)::text FROM pg_auth_members m CROSS JOIN role_ids ids
            WHERE m.roleid=ids.migrator_oid AND m.member=ids.owner_oid),
           (SELECT count(*)=1 FROM pg_auth_members m CROSS JOIN role_ids ids
            WHERE m.roleid=ids.migrator_oid AND m.member=ids.owner_oid)
    UNION ALL SELECT 'membership','original_oid_155649_intact','true',
           EXISTS (SELECT 1 FROM pg_auth_members m CROSS JOIN role_ids ids
                   WHERE m.oid=155649 AND m.roleid=ids.migrator_oid
                     AND m.member=ids.owner_oid AND m.grantor=ids.cloud_admin_oid
                     AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)::text,
           EXISTS (SELECT 1 FROM pg_auth_members m CROSS JOIN role_ids ids
                   WHERE m.oid=155649 AND m.roleid=ids.migrator_oid
                     AND m.member=ids.owner_oid AND m.grantor=ids.cloud_admin_oid
                     AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)
    UNION ALL SELECT 'membership','runtime_membership_count','0',
           (SELECT count(*)::text FROM pg_auth_members m CROSS JOIN role_ids ids
            WHERE m.member=ids.runtime_oid),
           (SELECT count(*)=0 FROM pg_auth_members m CROSS JOIN role_ids ids
            WHERE m.member=ids.runtime_oid)
    UNION ALL SELECT 'membership','owner_can_SET_migrator','false',
           coalesce(pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')::text,'NULL'),
           pg_has_role('oes_sandbox_owner','oes_django_migrator','SET') IS FALSE
    UNION ALL SELECT 'membership','owner_inherits_migrator','false',
           coalesce(pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE')::text,'NULL'),
           pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE') IS FALSE
    UNION ALL SELECT 'membership','owner_member_of_migrator','true',
           coalesce(pg_has_role('oes_sandbox_owner','oes_django_migrator','MEMBER')::text,'NULL'),
           pg_has_role('oes_sandbox_owner','oes_django_migrator','MEMBER') IS TRUE
    UNION ALL SELECT 'schema','migrator_oes_app_CREATE','false',
           coalesce(has_schema_privilege('oes_django_migrator','oes_app','CREATE')::text,'NULL'),
           has_schema_privilege('oes_django_migrator','oes_app','CREATE') IS FALSE
    UNION ALL
    SELECT 'schema',s.schema_name||'.owner',s.expected_owner,
           coalesce(pg_get_userbyid(n.nspowner),'MISSING'),
           s.expected_owner IS NULL OR pg_get_userbyid(n.nspowner) IS NOT DISTINCT FROM s.expected_owner
    FROM expected_schemas s LEFT JOIN pg_namespace n ON n.nspname=s.schema_name
    WHERE s.expected_owner IS NOT NULL
    UNION ALL
    SELECT 'schema',s.schema_name||'.USAGE',s.expected_usage::text,
           coalesce(has_schema_privilege('oes_runtime',n.oid,'USAGE')::text,'NULL'),
           has_schema_privilege('oes_runtime',n.oid,'USAGE') IS NOT DISTINCT FROM s.expected_usage
    FROM expected_schemas s LEFT JOIN pg_namespace n ON n.nspname=s.schema_name
    UNION ALL
    SELECT 'schema',s.schema_name||'.CREATE',s.expected_create::text,
           coalesce(has_schema_privilege('oes_runtime',n.oid,'CREATE')::text,'NULL'),
           has_schema_privilege('oes_runtime',n.oid,'CREATE') IS NOT DISTINCT FROM s.expected_create
    FROM expected_schemas s LEFT JOIN pg_namespace n ON n.nspname=s.schema_name
    UNION ALL
    -- Falha tanto para objetos faltantes como extras ou com owner diferente.
    SELECT 'table_inventory',t.schema_name||'.'||t.table_name,
           coalesce(t.expected_owner,'ABSENT'),coalesce(t.owner_name,'ABSENT'),
           t.expected_present AND t.actual_present
             AND t.owner_name IS NOT DISTINCT FROM t.expected_owner
    FROM scoped_tables t
    UNION ALL
    SELECT 'table_privilege',t.schema_name||'.'||t.table_name||'.'||op.privilege_type,
           want.expected_value::text,
           coalesce(has_table_privilege('oes_runtime',t.table_oid,op.privilege_type)::text,'NULL'),
           has_table_privilege('oes_runtime',t.table_oid,op.privilege_type)
             IS NOT DISTINCT FROM want.expected_value
    FROM scoped_tables t CROSS JOIN expected_table_ops op
    CROSS JOIN LATERAL (SELECT
      t.schema_name='oes_app' AND
      CASE WHEN op.privilege_type='SELECT' THEN
        t.table_name IN ('auth_user','auth_permission','django_content_type',
          'auth_user_user_permissions','auth_group','auth_user_groups',
          'auth_group_permissions','django_session')
      WHEN op.privilege_type IN ('INSERT','UPDATE','DELETE') THEN
        t.table_name='django_session'
      ELSE false END AS expected_value
    ) want
    UNION ALL
    SELECT 'table_grant_option',t.schema_name||'.'||t.table_name||'.'||op.privilege_type,
           'false',coalesce(has_table_privilege('oes_runtime',t.table_oid,
                       op.privilege_type||' WITH GRANT OPTION')::text,'NULL'),
           has_table_privilege('oes_runtime',t.table_oid,
                       op.privilege_type||' WITH GRANT OPTION') IS FALSE
    FROM scoped_tables t CROSS JOIN expected_table_ops op
    UNION ALL
    -- Privilegios por coluna nao sao inferidos apenas dos privilegios de tabela.
    SELECT 'column_privilege',t.schema_name||'.'||t.table_name||'.'||a.attname||'.'||op.privilege_type,
           want.expected_value::text,
           coalesce(has_column_privilege('oes_runtime',t.table_oid,a.attnum,op.privilege_type)::text,'NULL'),
           has_column_privilege('oes_runtime',t.table_oid,a.attnum,op.privilege_type)
              IS NOT DISTINCT FROM want.expected_value
    FROM scoped_tables t JOIN pg_attribute a
      ON a.attrelid=t.table_oid AND a.attnum>0 AND NOT a.attisdropped
    CROSS JOIN expected_column_ops op
    CROSS JOIN LATERAL (SELECT t.schema_name='oes_app' AND
      CASE WHEN op.privilege_type='SELECT' THEN
        t.table_name IN ('auth_user','auth_permission','django_content_type',
          'auth_user_user_permissions','auth_group','auth_user_groups',
          'auth_group_permissions','django_session')
      WHEN op.privilege_type='INSERT' THEN t.table_name='django_session'
      WHEN op.privilege_type='UPDATE' THEN t.table_name='django_session'
         OR (t.table_name='auth_user' AND a.attname='last_login')
      ELSE false END AS expected_value
    ) want
    UNION ALL
    SELECT 'column_grant_option',t.schema_name||'.'||t.table_name||'.'||a.attname||'.'||op.privilege_type,
           'false',coalesce(has_column_privilege('oes_runtime',t.table_oid,a.attnum,
                       op.privilege_type||' WITH GRANT OPTION')::text,'NULL'),
           has_column_privilege('oes_runtime',t.table_oid,a.attnum,
                       op.privilege_type||' WITH GRANT OPTION') IS FALSE
    FROM scoped_tables t JOIN pg_attribute a
      ON a.attrelid=t.table_oid AND a.attnum>0 AND NOT a.attisdropped
    CROSS JOIN expected_column_ops op
    UNION ALL
    SELECT 'column_inventory','oes_app.auth_user.'||req.col_name,'present',
           CASE WHEN EXISTS (SELECT 1 FROM pg_attribute a
               JOIN observed_tables t ON t.table_oid=a.attrelid
               WHERE t.schema_name='oes_app' AND t.table_name='auth_user'
                 AND a.attname=req.col_name AND a.attnum>0 AND NOT a.attisdropped)
              THEN 'present' ELSE 'missing' END,
           EXISTS (SELECT 1 FROM pg_attribute a JOIN observed_tables t
                   ON t.table_oid=a.attrelid
                   WHERE t.schema_name='oes_app' AND t.table_name='auth_user'
                     AND a.attname=req.col_name AND a.attnum>0 AND NOT a.attisdropped)
    FROM (VALUES ('last_login'),('password')) AS req(col_name)
    UNION ALL
    SELECT 'sequence_inventory','oes_app.'||s.sequence_name,
           CASE WHEN s.expected_present THEN 'oes_django_migrator' ELSE 'ABSENT' END,
           coalesce(s.owner_name,'ABSENT'),
           s.expected_present AND s.actual_present AND s.owner_name='oes_django_migrator'
    FROM scoped_sequences s
    UNION ALL
    SELECT 'sequence_privilege','oes_app.'||s.sequence_name||'.'||op.privilege_type,
           'false',coalesce(has_sequence_privilege('oes_runtime',s.sequence_oid,op.privilege_type)::text,'NULL'),
           has_sequence_privilege('oes_runtime',s.sequence_oid,op.privilege_type) IS FALSE
    FROM scoped_sequences s CROSS JOIN expected_sequence_ops op
    UNION ALL
    SELECT 'sequence_grant_option','oes_app.'||s.sequence_name||'.'||op.privilege_type,
           'false',coalesce(has_sequence_privilege('oes_runtime',s.sequence_oid,
                  op.privilege_type||' WITH GRANT OPTION')::text,'NULL'),
           has_sequence_privilege('oes_runtime',s.sequence_oid,
                  op.privilege_type||' WITH GRANT OPTION') IS FALSE
    FROM scoped_sequences s CROSS JOIN expected_sequence_ops op
    UNION ALL
    -- ACLs diretas: comparar tanto direitos esperados como concessoes excedentes.
    SELECT 'table_acl',coalesce(e.schema_name,a.schema_name)||'.'||
           coalesce(e.table_name,a.table_name)||'.'||
           coalesce(e.privilege_type,a.privilege_type)||'.grantor='||
           coalesce(e.expected_grantor,a.grantor,'NULL'),
           CASE WHEN e.privilege_type IS NOT NULL THEN 'present / grantable=false' ELSE 'ABSENT' END,
           CASE WHEN a.privilege_type IS NOT NULL THEN 'present / grantable='||a.is_grantable::text ELSE 'ABSENT' END,
           e.privilege_type IS NOT NULL AND a.privilege_type IS NOT NULL AND NOT a.is_grantable
    FROM expected_table_acl e FULL OUTER JOIN actual_table_acl a
      ON e.schema_name=a.schema_name AND e.table_name=a.table_name
         AND e.privilege_type=a.privilege_type AND e.expected_grantor=a.grantor
    UNION ALL
    SELECT 'column_acl',coalesce(e.schema_name,a.schema_name)||'.'||
           coalesce(e.table_name,a.table_name)||'.'||
           coalesce(e.column_name,a.column_name)||'.'||
           coalesce(e.privilege_type,a.privilege_type)||'.grantor='||
           coalesce(e.expected_grantor,a.grantor,'NULL'),
           CASE WHEN e.privilege_type IS NOT NULL THEN 'present / grantable=false' ELSE 'ABSENT' END,
           CASE WHEN a.privilege_type IS NOT NULL THEN 'present / grantable='||a.is_grantable::text ELSE 'ABSENT' END,
           e.privilege_type IS NOT NULL AND a.privilege_type IS NOT NULL AND NOT a.is_grantable
    FROM expected_column_acl e FULL OUTER JOIN actual_column_acl a
      ON e.schema_name=a.schema_name AND e.table_name=a.table_name
         AND e.column_name=a.column_name AND e.privilege_type=a.privilege_type
         AND e.expected_grantor=a.grantor
    UNION ALL
    SELECT 'schema_acl',coalesce(e.schema_name,a.schema_name)||'.'||
           coalesce(e.privilege_type,a.privilege_type)||'.grantor='||
           coalesce(e.expected_grantor,a.grantor,'NULL'),
           CASE WHEN e.privilege_type IS NOT NULL THEN 'present / grantable=false' ELSE 'ABSENT' END,
           CASE WHEN a.privilege_type IS NOT NULL THEN 'present / grantable='||a.is_grantable::text ELSE 'ABSENT' END,
           e.privilege_type IS NOT NULL AND a.privilege_type IS NOT NULL AND NOT a.is_grantable
    FROM expected_schema_acl e FULL OUTER JOIN actual_schema_acl a
      ON e.schema_name=a.schema_name AND e.privilege_type=a.privilege_type
         AND e.expected_grantor=a.grantor
    UNION ALL
    SELECT 'sequence_acl_direct','runtime_direct_acl_count','0',
           (SELECT count(*)::text FROM actual_sequence_acl),
           (SELECT count(*)=0 FROM actual_sequence_acl)
    UNION ALL
    -- PUBLIC em qualquer objeto escopado reprova a aceitacao; nao altera grants.
    SELECT 'public_acl_count','public_grants_in_scoped_objects','0',
           (SELECT count(*)::text FROM actual_public_acl),
           (SELECT count(*)=0 FROM actual_public_acl)
    UNION ALL
    SELECT 'public_acl', p.object_class||'.'||p.object_name||'.'||
           p.privilege_type||'.grantor='||coalesce(p.grantor,'UNKNOWN'),
           'ABSENT', 'PRESENT / grantable='||p.is_grantable::text,
           false
    FROM actual_public_acl p
),
summary AS (
    SELECT count(*)::bigint AS check_count,
           count(*) FILTER (WHERE passed IS NOT TRUE)::bigint AS failed_count
    FROM checks
)
SELECT 0 AS sort_order,'SUMMARY'::text AS check_group,'GLOBAL_POSTFLIGHT'::text AS subject,
       'zero mismatches'::text AS expected,
       s.failed_count::text||' mismatches / '||s.check_count::text||' checks' AS actual,
       s.failed_count=0 AS passed,
       CASE WHEN s.failed_count=0 AND s.check_count>0 THEN 'PASS' ELSE 'HOLD' END AS overall_status
FROM summary s
UNION ALL
SELECT 1,c.check_group,c.subject,c.expected,c.actual,
       coalesce(c.passed,false) AS passed,
       CASE WHEN s.failed_count=0 AND s.check_count>0 THEN 'PASS' ELSE 'HOLD' END
FROM checks c CROSS JOIN summary s
ORDER BY sort_order,check_group,subject;
