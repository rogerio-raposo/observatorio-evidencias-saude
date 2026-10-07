-- OES-DBM-2026-0031
-- Fase 4 — Propagation / re-baselining physical contract
-- Depends on: migrations 001–030
-- Date: 2026-10-07
-- Logical migration assembled from internal fragments because of repository transport limits.
-- Strict scope: persistence, guards, issue/readiness helpers and technical grandfathering.
-- No numeric SLA/cadence, scheduler, notifications, auto-propagation,
-- auto-rebaseline, fabricated review or M3 unblock.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

\ir 031a_propagation_core.sql
\ir 031b_propagation_signal_adapter.sql
\ir 031c_rebaseline_core.sql
\ir 031d_propagation_rebaseline_helpers.sql

COMMIT;
