# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — B1 Authorized Non-Normative / Awaiting Start Boundary

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP123  
**Checkpoint anterior:** CP122  
**Status:** artefato de continuidade; não normativo  
**Escopo:** validação da execution authority do Epoch B1 e preservação do boundary temporal antes da ativação

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_B_EXECUTION_AUTHORITY = APPROVED_AND_VALIDATED**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Owner execution decision

Controlling package:

`docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md`

Status:

> **APPROVED — OWNER DECISION RECORDED**

Decision timestamp:

`2026-10-08T13:31:42-03:00`

Exact scope:

- Phase B execution;
- Documento 75;
- TOPI-N2-DCBTI-01;
- Epoch B1.

## 3. Authority freshness

Design freeze:

`2026-10-08T13:12:23-03:00`

Owner decision:

`2026-10-08T13:31:42-03:00`

Result:

> **OWNER_DECISION_AFTER_DESIGN_FREEZE = PASS**

## 4. Physical authority

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

Actor:

`OES_PROJECT_OWNER`

Actor type:

`owner`

Decision Artifact UUID:

`b3000000-0000-0000-0000-000000000012`

## 5. Physical state

B1 status:

> **authorized_non_normative**

`started_at`:

> **NULL**

`completed_at`:

> **NULL**

MeasurementEvent count:

> **0**

OpportunityResolution count:

> **0**

No source query has been executed as B1 measurement.

## 6. Activation chronology gap discovered and corrected

Before persisting authority, review found that migration 033 required a non-null `started_at` for activation but did not explicitly enforce all factual chronology constraints relative to the first Opportunity.

The correction was implemented incrementally, without rewriting migration 033:

`database/034_temporal_observation_activation_chronology.sql`

Migration 034 adds a guard for:

`authorized_non_normative → active`

requiring:

1. at least one materialized Opportunity;
2. `started_at < first Opportunity`;
3. authority `operational_execution = approved` at `started_at`;
4. no material/invalidating deviation recorded at or before `started_at`.

The pre-existing table constraint continues to require:

`started_at >= start_boundary_at`.

## 7. B1 activation interval

Start boundary:

`2026-10-19T08:00:00-03:00`

First PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Therefore factual activation must satisfy:

> **2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00**

This is an experimental operational boundary.

It is not:

- cadence;
- SLA;
- due/overdue rule;
- compliance window.

## 8. Migration 034 validation

Migration commit:

`0b002c8c2d834f871f58364a2b7dc72c2a6069a8`

Test file:

`database/f4-temporal-activation-chronology-tests.sql`

Test result:

> **TACT-T01–T08 = PASS**

Idempotent re-apply:

> **PASS**

Rebuild:

> **PASS**

## 9. Authority materialization

SQL:

`database/f4-topi-n2-dcbti-phase-b-authority.sql`

Tests:

`database/f4-topi-n2-dcbti-phase-b-authority-tests.sql`

Result:

> **TOPI-AUTH-T01–T15 = PASS**

The tests confirm:

- exact owner authority row;
- exact Plan/Epoch scope;
- decision after design freeze;
- active decision Artifact;
- unchanged opportunity sets;
- target current;
- authorized_non_normative state;
- started_at NULL;
- zero MeasurementEvent;
- zero OpportunityResolution;
- no epoch blocker;
- BVS/LILACS source debt still visible.

## 10. Canonical CI

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Promoted run:

> **37815729503**

Run number:

> **218**

Validated HEAD:

`01c7a72d630fb5fb5c8f6eda8c87fdddc8268bb1`

Conclusion:

> **success**

Created:

`2026-10-08T17:19:58Z`

Completed:

`2026-10-08T17:25:59Z`

The run confirmed:

- migration 034 install;
- TACT-T01–T08;
- migration 033/034 idempotency;
- prior regressions;
- real TOPI preparation;
- real TOPI authority;
- rebuild-from-zero;
- Final S5 status.

## 11. Evidence artifact

Artifact ID:

`11567660235`

Name:

`oes-s5-evidence-37815729503`

Size:

`261686 bytes`

Digest:

`sha256:736cb0f552d944bd1e8506a79e48f7dba1f69278bde01ea3d1b5fd554a007fa0`

Expiry:

`2026-11-07T17:20:50Z`

Run 217 is not promoted; it was an implementation iteration whose transaction rolled back before commit.

## 12. Documento 76

Path:

`docs/governance/76-resultado-authority-execucao-phase-b-topi-n2-dcbti.md`

Commit:

`78ae9683436af54063fd62c1f9caa3348b642efa`

Result:

> **AUTHORITY_PASS — AUTHORIZED_NON_NORMATIVE — NOT_ACTIVE**

## 13. Boundary preserved

Still prohibited now:

- setting B1 active before start boundary;
- creating MeasurementEvent before a real measurement act;
- moving Opportunity timestamps;
- adding Opportunities;
- automatic extension;
- BVS substitution;
- Monitor/MonitoringCycle;
- automatic UpdateSignal;
- automatic scientific update;
- UpdatePolicy;
- CadenceContract;
- SLA;
- normative temporal values;
- M3;
- Phase 5.

## 14. Next exact operational act

At or after:

`2026-10-19T08:00:00-03:00`

and before:

`2026-10-19T09:00:00-03:00`

perform a live activation preflight.

The preflight must confirm:

1. Freshness Gate;
2. exact target still current;
3. authority state still approved;
4. controlling Artifacts active;
5. payload↔Opportunity exact equality;
6. no material/invalidating deviation;
7. actual time inside activation interval;
8. no schedule-expiry condition.

Only after PASS may:

> `authorized_non_normative → active`

occur with factual `started_at`.

Activation itself must create:

> **zero MeasurementEvent**

The first actual measurement act remains the first PubMed Opportunity at:

`2026-10-19T09:00:00-03:00`.

## 15. Mode discipline

> **High mode remains recommended for the activation + first real prospective measurement.**

Reason:

- first real Phase B execution;
- baseline-acquisition semantics;
- source-date interpretation;
- failure attribution;
- incidental scientific findings;
- strict anti-policy-laundering boundary.

After the first real measurement contract is proven operationally stable, medium mode may again become sufficient for routine opportunities.

## 16. Rule of pause

After CP123 activation:

> **stop and await explicit continuation.**

No activation is to be performed on 2026-10-08.

## 17. HEAD before CP123 creation

`d737dd4207ebd057300405645b190b0cf3b6009a`

**Fim do CP123**
