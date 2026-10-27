"""Local disposable role least-privilege audit; no Neon and no persisted writes."""
import os
if os.getenv("OES_LOCAL_ROLE_AUDIT") != "1":
    raise SystemExit("HOLD: local audit gate")
import psycopg
from psycopg import errors

dsn = dict(host="127.0.0.1", port=5432, dbname="oes_local_inventory",
           user="oes_runtime", password="local-runtime-only",
           options="-c search_path=oes_app")
with psycopg.connect(**dsn, autocommit=True) as db:
    with db.cursor() as cur:
        cur.execute("""SELECT current_database(),current_user,current_schema(),
           has_schema_privilege(current_user,'oes_app','USAGE'),
           has_schema_privilege(current_user,'oes_app','CREATE'),
           has_schema_privilege(current_user,'public','CREATE')""")
        assert cur.fetchone() == ("oes_local_inventory","oes_runtime","oes_app",True,False,False)
        expected = {
            "auth_user": {"SELECT","INSERT","UPDATE","DELETE"},
            "django_session": {"SELECT","INSERT","UPDATE","DELETE"},
            "auth_user_groups": {"SELECT","INSERT","UPDATE","DELETE"},
            "auth_user_user_permissions": {"SELECT","INSERT","UPDATE","DELETE"},
            "auth_group": {"SELECT"},
            "auth_permission": {"SELECT"},
            "django_content_type": {"SELECT"},
            "auth_group_permissions": {"SELECT"},
            "django_migrations": set(),
        }
        for table, allowed in expected.items():
            for op in ("SELECT","INSERT","UPDATE","DELETE"):
                cur.execute("SELECT has_table_privilege(current_user,%s,%s)",
                            ("oes_app." + table, op))
                assert cur.fetchone()[0] == (op in allowed), (table,op)
        for seq in ("auth_user_id_seq", "auth_user_groups_id_seq",
                    "auth_user_user_permissions_id_seq"):
            cur.execute("SELECT has_sequence_privilege(current_user,%s,'USAGE')",
                        ("oes_app." + seq,))
            assert cur.fetchone()[0] is True
        for seq in ("auth_group_id_seq", "django_content_type_id_seq",
                    "django_migrations_id_seq"):
            cur.execute("SELECT has_sequence_privilege(current_user,%s,'USAGE')",
                        ("oes_app." + seq,))
            assert cur.fetchone()[0] is False

        # Real rejected statements, not merely catalog predicates. No changes are committed.
        def expect_denied(sql):
            try:
                cur.execute(sql)
            except errors.InsufficientPrivilege:
                return
            raise AssertionError("HOLD: unauthorized command succeeded: " + sql)
        expect_denied("CREATE TABLE oes_app.runtime_must_not_create (id integer)")
        expect_denied("INSERT INTO oes_app.django_migrations (app,name,applied) VALUES ('x','y',now())")
        expect_denied("UPDATE oes_app.auth_permission SET name=name WHERE FALSE")
        expect_denied("SELECT COUNT(*) FROM oes_app.django_migrations")
        cur.execute("""SELECT COUNT(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
          WHERE n.nspname='public' AND c.relname LIKE 'auth_%'""")
        assert cur.fetchone()[0] == 0
        print("ROLE AUDIT PASS: per-table grants; runtime DDL and privileged writes denied")
