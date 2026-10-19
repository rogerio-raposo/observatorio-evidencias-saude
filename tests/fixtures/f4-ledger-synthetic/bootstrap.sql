-- Synthetic-only fixture: created exclusively in a disposable GitHub Actions PG18 service.
-- This is NOT the approved OES ops.schema_migration schema and MUST NOT be deployed to Neon.
\set ON_ERROR_STOP on
BEGIN;
CREATE SCHEMA ops;
CREATE SCHEMA oes_ci;

CREATE TABLE ops.schema_migration_event (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    migration_id text NOT NULL,
    content_sha256 text NOT NULL CHECK (content_sha256 ~ '^[0-9a-f]{64}$'),
    event_type text NOT NULL CHECK (event_type IN (
        'prepared', 'applied', 'uncertain_requires_reconciliation',
        'failed_verified_rollback', 'reconciled_applied'
    )),
    evidence text NOT NULL CHECK (length(evidence) > 0),
    created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);

CREATE UNIQUE INDEX one_final_receipt_per_migration
ON ops.schema_migration_event (migration_id)
WHERE event_type IN ('applied', 'reconciled_applied');

CREATE FUNCTION ops.block_event_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'APPEND_ONLY: modification prohibited';
END
$$;

CREATE TRIGGER append_only_events BEFORE UPDATE OR DELETE
ON ops.schema_migration_event FOR EACH ROW
EXECUTE FUNCTION ops.block_event_mutation();

CREATE FUNCTION ops.assert_can_start(p_id text, p_sha text) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  prior_count integer;
BEGIN
  IF p_sha !~ '^[0-9a-f]{64}$' THEN
    RAISE EXCEPTION 'INVALID_SHA256';
  END IF;
  SELECT count(*) INTO prior_count FROM ops.schema_migration_event
    WHERE migration_id = p_id AND content_sha256 <> p_sha;
  IF prior_count > 0 THEN
    RAISE EXCEPTION 'DRIFT_BLOCKED: migration % has other hash', p_id;
  END IF;
  SELECT count(*) INTO prior_count FROM ops.schema_migration_event
    WHERE migration_id = p_id;
  IF prior_count > 0 THEN
    RAISE EXCEPTION 'RETRY_BLOCKED: migration % requires reconciliation', p_id;
  END IF;
END
$$;

COMMIT;
