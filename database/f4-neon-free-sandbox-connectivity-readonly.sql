-- OES — Neon Free sandbox synthetic-only connectivity smoke / CP152
-- Read-only; no migration, no user data, no B1R1 preflight.
-- Run only in an explicitly approved Neon Free aws-sa-east-1 sandbox database.
-- Do not copy credentials/connection strings to output or GitHub.
BEGIN TRANSACTION READ ONLY;

SELECT
    CURRENT_TIMESTAMP AS observed_database_time,
    current_database() AS connected_database,
    current_user AS connected_role,
    current_setting('server_version') AS server_version,
    current_setting('transaction_read_only') AS transaction_read_only;

SELECT
    count(*) AS visible_non_template_databases
FROM pg_catalog.pg_database
WHERE datistemplate = false
  AND datallowconn = true;

ROLLBACK;

