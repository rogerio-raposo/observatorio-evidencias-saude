-- OES-DBM-2026-0033
-- Fase 4 — Non-normative temporal observation infrastructure
-- Depends on: migrations 001–032
-- Date: 2026-10-08
-- Strict scope: pre-calibration observation persistence, guards, replay/readiness helpers.
-- No real plan/source/authority/epoch/opportunity/event seed.
-- No numeric measurement schedule, cadence/SLA, scheduler, notifications, Phase B execution or M3 unblock.

BEGIN;

CREATE SCHEMA IF NOT EXISTS maintenance;

\ir 033a_temporal_observation_core.sql
\ir 033b_temporal_measurement_core.sql
\ir 033c_temporal_observation_guards.sql
\ir 033d_temporal_observation_helpers_views.sql
\ir 033e_temporal_observation_issue_validators.sql

COMMIT;
