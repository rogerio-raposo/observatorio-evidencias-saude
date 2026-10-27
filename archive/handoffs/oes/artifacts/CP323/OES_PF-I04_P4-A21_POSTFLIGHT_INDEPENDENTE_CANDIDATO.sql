-- OES / PF-I04/P4-A21 — POSTFLIGHT INDEPENDENTE, READ ONLY, CANDIDATO.
-- Executar somente sob gate READ ONLY próprio, em nova consulta/sessão, após COMMIT aprovado.
-- Os resultados de cada consulta devem ser inspecionados e documentados; qualquer divergência = HOLD.

SELECT current_database() AS banco, session_user, current_user;

SELECT rolname,rolcanlogin,rolinherit,rolsuper,rolcreatedb,rolcreaterole,
       rolreplication,rolbypassrls
FROM pg_roles WHERE rolname IN ('oes_runtime','oes_django_migrator');

SELECT m.oid AS membership_oid, p.rolname AS granted_role,
       u.rolname AS member, pg_get_userbyid(m.grantor) AS grantor,
       m.admin_option,m.inherit_option,m.set_option
FROM pg_auth_members m JOIN pg_roles p ON p.oid=m.roleid
JOIN pg_roles u ON u.oid=m.member
WHERE (p.rolname='oes_django_migrator' AND u.rolname='oes_sandbox_owner')
   OR u.rolname='oes_runtime';

SELECT n.nspname,pg_get_userbyid(n.nspowner) AS owner,
       has_schema_privilege('oes_runtime',n.oid,'USAGE') AS runtime_usage,
       has_schema_privilege('oes_runtime',n.oid,'CREATE') AS runtime_create
FROM pg_namespace n WHERE n.nspname IN ('oes_app','core','investigation','public')
ORDER BY n.nspname;

SELECT n.nspname,c.relname,pg_get_userbyid(c.relowner) AS owner,
       op.privilege_type,
       has_table_privilege('oes_runtime',c.oid,op.privilege_type) AS effective,
       has_table_privilege('oes_runtime',c.oid,op.privilege_type||' WITH GRANT OPTION') AS grant_option
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE','TRUNCATE',
                              'REFERENCES','TRIGGER','MAINTAIN']) AS op(privilege_type)
WHERE c.relkind='r' AND (n.nspname='oes_app'
   OR (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[]))
ORDER BY n.nspname,c.relname,op.privilege_type;

SELECT n.nspname,c.relname,a.attname,op.privilege_type,
       has_column_privilege('oes_runtime',c.oid,a.attnum,op.privilege_type) AS effective,
       has_column_privilege('oes_runtime',c.oid,a.attnum,op.privilege_type||' WITH GRANT OPTION') AS grant_option
FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) AS op(privilege_type)
WHERE c.relkind='r' AND a.attnum>0 AND NOT a.attisdropped
 AND (n.nspname='oes_app' OR (n.nspname || '.' || c.relname)=ANY(ARRAY['core.entity', 'core.entity_version', 'investigation.question', 'investigation.question_version', 'investigation.question_command_receipt']::text[]))
ORDER BY n.nspname,c.relname,a.attnum,op.privilege_type;

SELECT n.nspname,c.relname,pg_get_userbyid(c.relowner) AS owner,
       op.privilege_type,has_sequence_privilege('oes_runtime',c.oid,op.privilege_type) AS effective
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN LATERAL unnest(ARRAY['USAGE','SELECT','UPDATE']) AS op(privilege_type)
WHERE n.nspname='oes_app' AND c.relkind='S'
ORDER BY c.relname,op.privilege_type;

SELECT n.nspname,c.relname,acl.grantor::regrole AS grantor,acl.grantee::regrole AS grantee,
       acl.privilege_type,acl.is_grantable
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN LATERAL aclexplode(COALESCE(c.relacl,acldefault('r',c.relowner))) acl
WHERE n.nspname='oes_app' AND c.relkind='r'
 AND acl.grantee='oes_runtime'::regrole
ORDER BY c.relname,acl.privilege_type;

SELECT n.nspname,c.relname,a.attname,acl.grantor::regrole AS grantor,
       acl.grantee::regrole AS grantee,acl.privilege_type,acl.is_grantable
FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
CROSS JOIN LATERAL aclexplode(COALESCE(a.attacl,'{}'::aclitem[])) acl
WHERE n.nspname='oes_app' AND c.relkind='r' AND a.attnum>0 AND NOT a.attisdropped
 AND acl.grantee='oes_runtime'::regrole
ORDER BY c.relname,a.attnum,acl.privilege_type;

SELECT n.nspname,acl.grantor::regrole AS grantor,acl.grantee::regrole AS grantee,
       acl.privilege_type,acl.is_grantable
FROM pg_namespace n CROSS JOIN LATERAL
aclexplode(COALESCE(n.nspacl,acldefault('n',n.nspowner))) acl
WHERE n.nspname IN ('oes_app','core','investigation') AND acl.grantee='oes_runtime'::regrole
ORDER BY n.nspname,acl.privilege_type;
