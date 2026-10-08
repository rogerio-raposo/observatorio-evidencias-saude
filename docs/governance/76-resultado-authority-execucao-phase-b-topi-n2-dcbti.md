# 76 — Resultado da Authority de Execução da Phase B / Epoch B1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **AUTHORITY_PASS — AUTHORIZED_NON_NORMATIVE — NOT_ACTIVE**  
**Pacote controlador:** Documento 75  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1

## 1. Resultado

> **PHASE_B_EXECUTION_AUTHORITY = APPROVED_AND_VALIDATED**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

## 2. Owner decision

O Documento 75 foi atualizado para:

> **APPROVED — OWNER DECISION RECORDED**

Decision timestamp:

`2026-10-08T13:31:42-03:00`

Design freeze:

`2026-10-08T13:12:23-03:00`

Logo:

> **OWNER_DECISION_AFTER_DESIGN_FREEZE = PASS**

## 3. Physical authority

Authority UUID:

`b3150000-0000-0000-0000-000000000001`

Plan UUID:

`b3100000-0000-0000-0000-000000000001`

Epoch UUID:

`b3120000-0000-0000-0000-000000000001`

Domain:

`operational_execution`

Decision:

`approved`

Actor type:

`owner`

Decision Artifact UUID:

`b3000000-0000-0000-0000-000000000012`

The authority is specific to the exact frozen B1.

## 4. Activation chronology hardening

During pre-authorization review, a physical gap was identified:

the migration 033 lifecycle guard required `started_at` for activation but did not explicitly guarantee that the persisted start precedes the first frozen Opportunity or that authority was already approved at that persisted start.

This was corrected incrementally through:

`database/034_temporal_observation_activation_chronology.sql`

without modifying migration 033 retrospectively.

The new guard requires for:

`authorized_non_normative → active`

that:

- a first Opportunity exists;
- `started_at < first opportunity`;
- operational execution authority is already `approved` at `started_at`;
- no `new_epoch_required` or `invalidating` deviation exists at `started_at`.

The existing table constraint already requires:

`started_at >= start_boundary_at`.

Thus the factual activation interval for B1 is structurally:

> **2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00**

This is an experimental operational boundary, not a normative cadence/SLA.

## 5. Migration 034 validation

Tests:

`database/f4-temporal-activation-chronology-tests.sql`

Result:

> **TACT-T01–T08 = PASS**

They prove:

- guard function/trigger exists;
- valid historical activation chronology remains accepted;
- activation before authority is rejected;
- activation at the first Opportunity is rejected;
- valid start after authority and before first Opportunity is accepted.

Migration 034 re-apply:

> **IDEMPOTENT = PASS**

Rebuild:

> **PASS**

## 6. Real B1 authority validation

Authority materialization:

`database/f4-topi-n2-dcbti-phase-b-authority.sql`

Tests:

`database/f4-topi-n2-dcbti-phase-b-authority-tests.sql`

Result:

> **TOPI-AUTH-T01–T15 = PASS**

The suite confirms:

- one exact operational execution authority row;
- correct Plan/Epoch scope;
- owner actor type;
- decision timestamp preserved;
- authority decision after design freeze;
- authority state = approved;
- B1 status = authorized_non_normative;
- started_at remains NULL;
- controlling decision Artifact active;
- frozen opportunity sets unchanged;
- target current;
- zero MeasurementEvent;
- zero OpportunityResolution;
- no epoch blockers;
- source debt remains visible.

## 7. Canonical CI evidence

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37815729503**

Run number:

> **218**

Validated HEAD:

> **01c7a72d630fb5fb5c8f6eda8c87fdddc8268bb1**

Conclusion:

> **success**

Run interval:

- created: `2026-10-08T17:19:58Z`;
- completed/update: `2026-10-08T17:25:59Z`.

The run confirmed:

- migration 034 install = PASS;
- TACT-T01–T08 = PASS;
- 033/034 idempotency = PASS;
- TOPI preparation = PASS;
- TOPI authority = PASS;
- all prior regressions = PASS;
- rebuild-from-zero = PASS;
- Final S5 status = PASS.

## 8. Evidence artifact

Artifact:

- ID: `11567660235`;
- name: `oes-s5-evidence-37815729503`;
- size: `261686 bytes`;
- digest:
  `sha256:736cb0f552d944bd1e8506a79e48f7dba1f69278bde01ea3d1b5fd554a007fa0`;
- expires at: `2026-11-07T17:20:50Z`.

Run 217 was an implementation iteration and is not promoted.

## 9. Current temporal state

Current date remains 2026-10-08.

B1 start boundary:

`2026-10-19T08:00:00-03:00`

First PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Therefore:

> **ACTIVATION_NOW = NOT_ALLOWED**

The owner authority is valid and persisted, but the Epoch remains pre-start.

## 10. Next operational act

At or after the start boundary, before the first Opportunity, a live activation preflight must verify:

- target currentness;
- authority state still approved;
- controlling Artifacts active;
- exact payload↔Opportunity equality;
- no material/invalidating deviation;
- actual current time within the activation interval;
- no schedule expiry.

Only then may:

> `authorized_non_normative → active`

occur with factual `started_at`.

No MeasurementEvent should be created by the activation act itself.

## 11. Boundaries preserved

Still not authorized:

- moving Opportunity timestamps;
- adding Opportunities;
- automatic extension;
- Monitor/MonitoringCycle;
- automatic UpdateSignal;
- automatic scientific update;
- UpdatePolicy;
- CadenceContract;
- SLA;
- normative temporal values;
- M3 formalization;
- Phase 5.

**Fim do Documento 76**
