-- OES / PF-I04 / P4-A29 — POSTFLIGHT INDEPENDENTE CANDIDATO
-- DOCUMENTAL / NAO AUTORIZADO PARA EXECUCAO. UM UNICO SELECT CATALOGAL.
-- Executar SOMENTE mediante gate separado, numa NOVA sessao apos o ROLLBACK.
-- Se houver erro, saida incompleta ou divergencia: HOLD, sem repeticao automatica.
-- Esta consulta verifica fronteiras do ensaio A29, NAO auditoria universal de ACL.

WITH
ids AS (
    SELECT
        'oes_django_migrator'::regrole::oid AS migrator_oid,
        'oes_sandbox_owner'::regrole::oid AS owner_oid,
        'oes_runtime'::regrole::oid AS runtime_oid,
        'cloud_admin'::regrole::oid AS cloud_admin_oid
),
django_tables(table_name) AS (
    VALUES ('auth_group'),('auth_group_permissions'),('auth_permission'),
           ('auth_user'),('auth_user_groups'),('auth_user_user_permissions'),
           ('django_content_type'),('django_migrations'),('django_session')
),
q0_tables(schema_name,table_name) AS (
    VALUES ('core','entity'),('core','entity_version'),
           ('investigation','question'),('investigation','question_version'),
           ('investigation','question_command_receipt')
),
django_sequences(sequence_name) AS (
    VALUES ('auth_group_id_seq'),('auth_group_permissions_id_seq'),
           ('auth_permission_id_seq'),('auth_user_groups_id_seq'),
           ('auth_user_id_seq'),('auth_user_user_permissions_id_seq'),
           ('django_content_type_id_seq'),('django_migrations_id_seq')
),
checks AS (
    SELECT 'environment'::text AS check_group,'database'::text AS subject,
           'oes_sandbox'::text AS expected,current_database()::text AS actual,
           current_database()='oes_sandbox' AS passed
    UNION ALL SELECT 'environment','session_user','oes_sandbox_owner',
           session_user::text,session_user='oes_sandbox_owner'
    UNION ALL SELECT 'environment','current_user','oes_sandbox_owner',
           current_user::text,current_user='oes_sandbox_owner'
    UNION ALL SELECT 'environment','pg18','true',
           (current_setting('server_version_num')::int BETWEEN 180000 AND 189999)::text,
           current_setting('server_version_num')::int BETWEEN 180000 AND 189999
    UNION ALL SELECT 'membership','original_count','1',
           (SELECT count(*)::text FROM pg_auth_members m CROSS JOIN ids i
            WHERE m.roleid=i.migrator_oid AND m.member=i.owner_oid),
           (SELECT count(*)=1 FROM pg_auth_members m CROSS JOIN ids i
            WHERE m.roleid=i.migrator_oid AND m.member=i.owner_oid)
    UNION ALL SELECT 'membership','original_oid_155649','true',
           EXISTS (SELECT 1 FROM pg_auth_members m CROSS JOIN ids i
                   WHERE m.oid=155649 AND m.roleid=i.migrator_oid
                     AND m.member=i.owner_oid AND m.grantor=i.cloud_admin_oid
                     AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)::text,
           EXISTS (SELECT 1 FROM pg_auth_members m CROSS JOIN ids i
                   WHERE m.oid=155649 AND m.roleid=i.migrator_oid
                     AND m.member=i.owner_oid AND m.grantor=i.cloud_admin_oid
                     AND m.admin_option AND NOT m.inherit_option AND NOT m.set_option)
    UNION ALL SELECT 'membership','no_owner_self_grant','0',
           (SELECT count(*)::text FROM pg_auth_members m CROSS JOIN ids i
            WHERE m.roleid=i.migrator_oid AND m.member=i.owner_oid
              AND m.grantor=i.owner_oid),
           (SELECT count(*)=0 FROM pg_auth_members m CROSS JOIN ids i
            WHERE m.roleid=i.migrator_oid AND m.member=i.owner_oid
              AND m.grantor=i.owner_oid)
    UNION ALL SELECT 'membership','owner_SET','false',
           pg_has_role('oes_sandbox_owner','oes_django_migrator','SET')::text,
           pg_has_role('oes_sandbox_owner','oes_django_migrator','SET') IS FALSE
    UNION ALL SELECT 'membership','owner_USAGE','false',
           pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE')::text,
           pg_has_role('oes_sandbox_owner','oes_django_migrator','USAGE') IS FALSE
    UNION ALL SELECT 'membership','runtime_member_count','0',
           (SELECT count(*)::text FROM pg_auth_members m CROSS JOIN ids i
            WHERE m.member=i.runtime_oid),
           (SELECT count(*)=0 FROM pg_auth_members m CROSS JOIN ids i
            WHERE m.member=i.runtime_oid)
    UNION ALL SELECT 'role','migrator_NOLOGIN','true',
           (SELECT NOT rolcanlogin FROM pg_roles WHERE rolname='oes_django_migrator')::text,
           (SELECT NOT rolcanlogin FROM pg_roles WHERE rolname='oes_django_migrator') IS TRUE
    UNION ALL SELECT 'role','runtime_LOGIN_NOINHERIT','true',
           (SELECT rolcanlogin AND NOT rolinherit FROM pg_roles WHERE rolname='oes_runtime')::text,
           (SELECT rolcanlogin AND NOT rolinherit FROM pg_roles WHERE rolname='oes_runtime') IS TRUE
    UNION ALL SELECT 'schema','runtime_oes_app_USAGE','false',
           has_schema_privilege('oes_runtime','oes_app','USAGE')::text,
           has_schema_privilege('oes_runtime','oes_app','USAGE') IS FALSE
    UNION ALL SELECT 'schema','runtime_oes_app_CREATE','false',
           has_schema_privilege('oes_runtime','oes_app','CREATE')::text,
           has_schema_privilege('oes_runtime','oes_app','CREATE') IS FALSE
    UNION ALL SELECT 'schema','runtime_core_USAGE','false',
           has_schema_privilege('oes_runtime','core','USAGE')::text,
           has_schema_privilege('oes_runtime','core','USAGE') IS FALSE
    UNION ALL SELECT 'schema','runtime_investigation_USAGE','false',
           has_schema_privilege('oes_runtime','investigation','USAGE')::text,
           has_schema_privilege('oes_runtime','investigation','USAGE') IS FALSE
    UNION ALL
    SELECT 'ownership','django_tables_exact_owner_count','9',
           (SELECT count(*)::text FROM django_tables e JOIN pg_namespace n
                       ON n.nspname='oes_app'
                    JOIN pg_class c ON c.relnamespace=n.oid AND c.relname=e.table_name
                       AND c.relkind='r' AND c.relowner='oes_django_migrator'::regrole),
           (SELECT count(*)=9 FROM django_tables e JOIN pg_namespace n
                       ON n.nspname='oes_app'
                    JOIN pg_class c ON c.relnamespace=n.oid AND c.relname=e.table_name
                       AND c.relkind='r' AND c.relowner='oes_django_migrator'::regrole)
    UNION ALL
    SELECT 'ownership','django_sequence_exact_owner_count','8',
           (SELECT count(*)::text FROM django_sequences e JOIN pg_namespace n
                       ON n.nspname='oes_app'
                    JOIN pg_class c ON c.relnamespace=n.oid AND c.relname=e.sequence_name
                       AND c.relkind='S' AND c.relowner='oes_django_migrator'::regrole),
           (SELECT count(*)=8 FROM django_sequences e JOIN pg_namespace n
                       ON n.nspname='oes_app'
                    JOIN pg_class c ON c.relnamespace=n.oid AND c.relname=e.sequence_name
                       AND c.relkind='S' AND c.relowner='oes_django_migrator'::regrole)
    UNION ALL
    SELECT 'ownership','q0_tables_exact_owner_count','5',
           (SELECT count(*)::text FROM q0_tables e JOIN pg_namespace n
                     ON n.nspname=e.schema_name JOIN pg_class c
                     ON c.relnamespace=n.oid AND c.relname=e.table_name
                       AND c.relkind='r' AND c.relowner='oes_sandbox_owner'::regrole),
           (SELECT count(*)=5 FROM q0_tables e JOIN pg_namespace n
                     ON n.nspname=e.schema_name JOIN pg_class c
                     ON c.relnamespace=n.oid AND c.relname=e.table_name
                       AND c.relkind='r' AND c.relowner='oes_sandbox_owner'::regrole)
    UNION ALL
    SELECT 'runtime_access','runtime_any_Django_table_right','false',
           EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE',
                      'TRUNCATE','REFERENCES','TRIGGER','MAINTAIN']) op(priv)
                   WHERE n.nspname='oes_app' AND c.relkind='r'
                     AND has_table_privilege('oes_runtime',c.oid,op.priv))::text,
           NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE',
                      'TRUNCATE','REFERENCES','TRIGGER','MAINTAIN']) op(priv)
                   WHERE n.nspname='oes_app' AND c.relkind='r'
                     AND has_table_privilege('oes_runtime',c.oid,op.priv))
    UNION ALL
    SELECT 'runtime_access','runtime_any_Django_column_right','false',
           EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   JOIN pg_attribute a ON a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped
                   CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) op(priv)
                   WHERE n.nspname='oes_app' AND c.relkind='r'
                     AND has_column_privilege('oes_runtime',c.oid,a.attnum,op.priv))::text,
           NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   JOIN pg_attribute a ON a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped
                   CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','REFERENCES']) op(priv)
                   WHERE n.nspname='oes_app' AND c.relkind='r'
                     AND has_column_privilege('oes_runtime',c.oid,a.attnum,op.priv))
    UNION ALL
    SELECT 'runtime_access','runtime_any_sequence_right','false',
           EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   CROSS JOIN LATERAL unnest(ARRAY['USAGE','SELECT','UPDATE']) op(priv)
                   WHERE n.nspname='oes_app' AND c.relkind='S'
                     AND has_sequence_privilege('oes_runtime',c.oid,op.priv))::text,
           NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   CROSS JOIN LATERAL unnest(ARRAY['USAGE','SELECT','UPDATE']) op(priv)
                   WHERE n.nspname='oes_app' AND c.relkind='S'
                     AND has_sequence_privilege('oes_runtime',c.oid,op.priv))
    UNION ALL
    SELECT 'runtime_access','runtime_any_Q0_table_right','false',
           EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE',
                      'TRUNCATE','REFERENCES','TRIGGER','MAINTAIN']) op(priv)
                   WHERE c.relkind='r' AND (n.nspname,c.relname) IN
                     (('core','entity'),('core','entity_version'),
                      ('investigation','question'),('investigation','question_version'),
                      ('investigation','question_command_receipt'))
                     AND has_table_privilege('oes_runtime',c.oid,op.priv))::text,
           NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
                   CROSS JOIN LATERAL unnest(ARRAY['SELECT','INSERT','UPDATE','DELETE',
                      'TRUNCATE','REFERENCES','TRIGGER','MAINTAIN']) op(priv)
                   WHERE c.relkind='r' AND (n.nspname,c.relname) IN
                     (('core','entity'),('core','entity_version'),
                      ('investigation','question'),('investigation','question_version'),
                      ('investigation','question_command_receipt'))
                     AND has_table_privilege('oes_runtime',c.oid,op.priv))
),
summary AS (
    SELECT count(*)::bigint AS check_count,
           count(*) FILTER (WHERE passed IS NOT TRUE)::bigint AS failed_count
    FROM checks
)
SELECT 0 AS sort_order,'SUMMARY'::text AS check_group,'POST_ROLLBACK'::text AS subject,
       'zero mismatches'::text AS expected,
       s.failed_count::text||' mismatches / '||s.check_count::text||' checks' AS actual,
       s.failed_count=0 AND s.check_count>0 AS passed,
       CASE WHEN s.failed_count=0 AND s.check_count>0 THEN 'PASS' ELSE 'HOLD' END AS overall_status
FROM summary s
UNION ALL
SELECT 1,c.check_group,c.subject,c.expected,c.actual,
       coalesce(c.passed,false),
       CASE WHEN s.failed_count=0 AND s.check_count>0 THEN 'PASS' ELSE 'HOLD' END
FROM checks c CROSS JOIN summary s
ORDER BY sort_order,check_group,subject;
