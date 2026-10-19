#!/usr/bin/env bash
# DO NOT run against Neon. This harness writes ONLY to a disposable CI PG18 service.
set -euo pipefail
if [[ "${PGHOST:-}" != "127.0.0.1" || "${PGPORT:-}" != "5432" ||
      "${PGDATABASE:-}" != "oes_f4_ledger_synthetic" || "${PGUSER:-}" != "postgres" ]]; then
  echo "BLOCKED: synthetic-only local PostgreSQL CI destination required" >&2
  exit 20
fi
dir="f4-pg18-ledger-artifacts"
mkdir -p "$dir"
printf 'check\tresult\n' > "$dir/checks.tsv"
record() { printf '%s\tPASS\n' "$1" | tee -a "$dir/checks.tsv"; }
db() { psql -X -q -v ON_ERROR_STOP=1 -At -c "$1"; }
check_equal() {
  local expected="$1" actual="$2" label="$3"
  if [[ "$expected" != "$actual" ]]; then
    printf 'FAILED: %s expected [%s], observed [%s]\n' "$label" "$expected" "$actual" >&2
    exit 21
  fi
  record "$label"
}
must_fail_with() {
  local label="$1" pattern="$2" sql="$3"
  if psql -X -v ON_ERROR_STOP=1 -c "$sql" > "$dir/$label.log" 2>&1; then
    echo "FAILED: $label unexpectedly succeeded" >&2; exit 22
  fi
  if ! grep -Fq "$pattern" "$dir/$label.log"; then
    echo "FAILED: $label did not fail for expected reason ($pattern)" >&2; exit 23
  fi
  record "$label"
}
sha=$(sha256sum tests/fixtures/f4-ledger-synthetic/bootstrap.sql | awk '{print $1}')
drift_sha=$(printf 'synthetic-changed-hash' | sha256sum | awk '{print $1}')
psql -X -v ON_ERROR_STOP=1 -Atc 'SHOW server_version;' > "$dir/server-version.txt"
psql --version > "$dir/psql-version.txt"
grep -q '^18' "$dir/server-version.txt"
psql -X -v ON_ERROR_STOP=1 -f tests/fixtures/f4-ledger-synthetic/bootstrap.sql > "$dir/bootstrap.log" 2>&1
record "bootstrap_fixture_pg18"

# An intent is durable before this deliberately aborted SQL transaction.
db "SELECT ops.assert_can_start('atomic_failure', '$sha');" > /dev/null
db "INSERT INTO ops.schema_migration_event(migration_id,content_sha256,event_type,evidence) VALUES ('atomic_failure','$sha','prepared','synthetic durable intent');" > /dev/null
cat > "$dir/atomic-forced-rollback.sql" <<SQL
BEGIN;
CREATE TABLE oes_ci.atomic_rolled_back (id integer PRIMARY KEY);
INSERT INTO ops.schema_migration_event(migration_id,content_sha256,event_type,evidence)
VALUES ('atomic_failure','$sha','applied','receipt will rollback');
SELECT 1 / 0;
COMMIT;
SQL
if psql -X -v ON_ERROR_STOP=1 -f "$dir/atomic-forced-rollback.sql" > "$dir/atomic-forced-rollback.log" 2>&1; then
  echo "FAILED: forced SQL error unexpectedly committed" >&2; exit 24
fi
grep -Fq 'division by zero' "$dir/atomic-forced-rollback.log"
check_equal "0" "$(db "SELECT count(*) FROM information_schema.tables WHERE table_schema='oes_ci' AND table_name='atomic_rolled_back';")" "forced_ddl_rollback"
check_equal "0" "$(db "SELECT count(*) FROM ops.schema_migration_event WHERE migration_id='atomic_failure' AND event_type='applied';")" "forced_receipt_rollback"
check_equal "1" "$(db "SELECT count(*) FROM ops.schema_migration_event WHERE migration_id='atomic_failure' AND event_type='prepared';")" "durable_intent_survives_rollback"
must_fail_with "no_auto_retry_after_failed_attempt" "RETRY_BLOCKED" "SELECT ops.assert_can_start('atomic_failure','$sha');"

# Synthetic migration and receipt atomically commit only when in the same transaction.
cat > "$dir/atomic-success.sql" <<SQL
BEGIN;
SELECT ops.assert_can_start('atomic_success', '$sha');
CREATE TABLE oes_ci.atomic_success (id integer PRIMARY KEY);
INSERT INTO ops.schema_migration_event(migration_id,content_sha256,event_type,evidence)
VALUES ('atomic_success','$sha','applied','same DB transaction as synthetic DDL');
COMMIT;
SQL
psql -X -v ON_ERROR_STOP=1 -f "$dir/atomic-success.sql" > "$dir/atomic-success.log" 2>&1
check_equal "1" "$(db "SELECT count(*) FROM information_schema.tables WHERE table_schema='oes_ci' AND table_name='atomic_success';")" "atomic_ddl_committed"
check_equal "1" "$(db "SELECT count(*) FROM ops.schema_migration_event WHERE migration_id='atomic_success' AND event_type='applied';")" "atomic_receipt_committed"
must_fail_with "applied_replay_blocked" "RETRY_BLOCKED" "SELECT ops.assert_can_start('atomic_success','$sha');"
must_fail_with "append_only_update_blocked" "APPEND_ONLY" "UPDATE ops.schema_migration_event SET evidence='tampered' WHERE migration_id='atomic_success';"
must_fail_with "append_only_delete_blocked" "APPEND_ONLY" "DELETE FROM ops.schema_migration_event WHERE migration_id='atomic_success';"

# Legacy commit-gap: DDL committed; receipt not written. Intent blocks replay.
db "SELECT ops.assert_can_start('legacy_commit_gap', '$sha');" > /dev/null
db "INSERT INTO ops.schema_migration_event(migration_id,content_sha256,event_type,evidence) VALUES ('legacy_commit_gap','$sha','prepared','durable pre-commit intent');" > /dev/null
db "BEGIN; CREATE TABLE oes_ci.legacy_committed (id integer PRIMARY KEY); COMMIT;" > /dev/null
must_fail_with "committed_ddl_without_receipt_blocks_retry" "RETRY_BLOCKED" "SELECT ops.assert_can_start('legacy_commit_gap','$sha');"
db "INSERT INTO ops.schema_migration_event(migration_id,content_sha256,event_type,evidence) VALUES ('legacy_commit_gap','$sha','uncertain_requires_reconciliation','injected receipt gap; never blind retry');" > /dev/null
check_equal "1" "$(db "SELECT count(*) FROM information_schema.tables WHERE table_schema='oes_ci' AND table_name='legacy_committed';")" "legacy_ddl_survived_commit_gap"
check_equal "0" "$(db "SELECT count(*) FROM ops.schema_migration_event WHERE migration_id='legacy_commit_gap' AND event_type='applied';")" "legacy_receipt_not_faked"
must_fail_with "drift_refused" "DRIFT_BLOCKED" "SELECT ops.assert_can_start('legacy_commit_gap','$drift_sha');"
check_equal "uncertain_requires_reconciliation" "$(db "SELECT event_type FROM ops.schema_migration_event WHERE migration_id='legacy_commit_gap' ORDER BY event_id DESC LIMIT 1;")" "uncertain_state_persisted"

# Test only advisory-lock primitives, not a durable cross-process runner guard.
psql -X -v ON_ERROR_STOP=1 -Atc 'SELECT pg_advisory_lock(419161); SELECT pg_sleep(5);' > "$dir/lock-holder.log" 2>&1 &
holder=$!
trap 'kill "$holder" 2>/dev/null || true' EXIT
seen=0
for _ in {1..30}; do
  if [[ "$(db 'SELECT NOT pg_try_advisory_lock(419161);')" == "t" ]]; then
    seen=1
    break
  fi
  sleep 0.1
done
check_equal "1" "$seen" "advisory_lock_excludes_second_session"
wait "$holder"
trap - EXIT
check_equal "t" "$(db 'SELECT pg_try_advisory_lock(419161);')" "advisory_lock_released_after_session"
echo "SYNTHETIC_LEDGER_HARNESS_PASS" | tee "$dir/result.txt"
