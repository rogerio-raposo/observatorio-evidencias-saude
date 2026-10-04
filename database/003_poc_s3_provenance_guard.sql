-- OES-DBM-2026-0003
-- PoC-S3 — Provenance mutation guard
-- Depends on: database/poc-s1.sql
-- Status: experimental, non-production
-- Date: 2026-10-04
--
-- Purpose:
-- Enforce the architectural rule that material provenance content is
-- append-preserving. Corrections create a new provenance.record and may
-- transition the prior record lifecycle status, but must not rewrite the
-- source/target/transformation payload in place.

BEGIN;

CREATE OR REPLACE FUNCTION provenance.guard_record_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $guard$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION
            'provenance.record is history-preserving; DELETE is not allowed for %',
            OLD.provenance_uuid;
    END IF;

    IF NEW.provenance_uuid IS DISTINCT FROM OLD.provenance_uuid
       OR NEW.target_version_uuid IS DISTINCT FROM OLD.target_version_uuid
       OR NEW.field_path IS DISTINCT FROM OLD.field_path
       OR NEW.source_report_version_uuid IS DISTINCT FROM OLD.source_report_version_uuid
       OR NEW.source_location IS DISTINCT FROM OLD.source_location
       OR NEW.source_value IS DISTINCT FROM OLD.source_value
       OR NEW.process_type IS DISTINCT FROM OLD.process_type
       OR NEW.process_record_uuid IS DISTINCT FROM OLD.process_record_uuid
       OR NEW.transformation IS DISTINCT FROM OLD.transformation
       OR NEW.actor IS DISTINCT FROM OLD.actor
       OR NEW.created_at IS DISTINCT FROM OLD.created_at
       OR NEW.supersedes_provenance_uuid IS DISTINCT FROM OLD.supersedes_provenance_uuid
    THEN
        RAISE EXCEPTION
            'Material provenance fields are immutable for %; create a new provenance.record',
            OLD.provenance_uuid;
    END IF;

    IF OLD.status = 'invalidated' AND NEW.status IS DISTINCT FROM OLD.status THEN
        RAISE EXCEPTION
            'Invalidated provenance % cannot transition to another status',
            OLD.provenance_uuid;
    END IF;

    IF OLD.status = 'superseded' AND NEW.status = 'active' THEN
        RAISE EXCEPTION
            'Superseded provenance % cannot return to active',
            OLD.provenance_uuid;
    END IF;

    RETURN NEW;
END;
$guard$;

CREATE TRIGGER tr_provenance_guard_update
BEFORE UPDATE ON provenance.record
FOR EACH ROW
EXECUTE FUNCTION provenance.guard_record_mutation();

CREATE TRIGGER tr_provenance_guard_delete
BEFORE DELETE ON provenance.record
FOR EACH ROW
EXECUTE FUNCTION provenance.guard_record_mutation();

COMMIT;
