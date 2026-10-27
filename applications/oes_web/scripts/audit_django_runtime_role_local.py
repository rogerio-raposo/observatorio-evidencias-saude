"""Inspect separate runtime grants after local-only Django migration."""
import os
if os.getenv("OES_LOCAL_ROLE_AUDIT") != "1":
    raise SystemExit("HOLD: local audit gate")
import psycopg
conn = dict(host="127.0.0.1", port=5432, dbname="oes_local_inventory")
with psycopg.connect(**conn, user="oes_runtime", password="local-runtime-only") as db:
    with db.cursor() as cur:
        cur.execute("""SELECT current_database(),current_user,
            has_schema_privilege(current_user,'oes_app','USAGE'),
            has_schema_privilege(current_user,'oes_app','CREATE'),
            has_schema_privilege(current_user,'public','CREATE')""")
        state=cur.fetchone()
        assert state == ("oes_local_inventory","oes_runtime",True,False,False), state
        cur.execute("""SELECT table_name, privilege_type FROM information_schema.role_table_grants
            WHERE table_schema='oes_app' AND grantee=current_user ORDER BY 1,2""")
        actual=set(cur.fetchall())
        expected={(table, permission) for table in
            ("auth_user","auth_group","auth_permission","django_content_type","django_session")
            for permission in ("SELECT","INSERT","UPDATE","DELETE")}
        assert expected.issubset(actual), sorted(expected-actual)
        cur.execute("""SELECT COUNT(*) FROM oes_app.django_migrations""")
        assert cur.fetchone()[0] == 15
        cur.execute("""SELECT has_sequence_privilege(current_user,'oes_app.auth_user_id_seq','USAGE')""")
        assert cur.fetchone()[0] is True
        cur.execute("""SELECT COUNT(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
            WHERE n.nspname='public' AND c.relname LIKE 'auth_%'""")
        assert cur.fetchone()[0] == 0
        print("ROLE AUDIT PASS: runtime usage, minimal DML and sequence; CREATE denied; 15 migrations")
