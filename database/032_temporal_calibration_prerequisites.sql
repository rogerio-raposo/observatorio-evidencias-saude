-- OES-DBM-2026-0032
-- Fase 4 — Temporal calibration prerequisites physical infrastructure
-- Depends on: migrations 001–031
-- Date: 2026-10-07
-- Logical migration assembled from internal fragments because of repository transport limits.
-- Strict scope: calibration provenance, cadence/SLA deterministic infrastructure,
-- technical grandfathering, guards and readiness helpers.
-- No normative cadence/SLA values, real calendars, scheduler, notifications,
-- automatic escalation/currentness/assurance/publication or M3 unblock.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

\ir 032a_temporal_calibration_core.sql
\ir 032b_temporal_cadence_contract.sql
\ir 032c_temporal_sla_contract.sql
\ir 032d_temporal_sla_runtime.sql

COMMIT;
