# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — B1R1 Execution Authority Approved / Activation Pending

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP131  
**Checkpoint anterior:** CP130  
**Status:** artefato de continuidade; não normativo  
**Escopo:** persistência e validação da execution authority específica do replacement Epoch B1R1, sem activation e sem MeasurementEvent.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_EXECUTION_AUTHORITY = APPROVED**

> **B1R1_STARTED_AT = NULL**

> **B1R1_ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Owner decision

Received:

> **APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**

Factual decision timestamp:

`2026-10-08T20:26:21-03:00`

B1R1 design freeze:

`2026-10-08T19:48:20-03:00`

> **AUTHORITY_AFTER_DESIGN_FREEZE = PASS**

## 3. Decision record

Document:

`docs/governance/86-decisao-authority-execucao-b1r1.md`

Git blob SHA-1:

`5e71b65df149c91a41879b1d1610e0edf8a3ef29`

Physical Artifact UUID:

`b3000000-0000-0000-0000-000000000017`

## 4. Physical authority

Authority UUID:

`b3150000-0000-0000-0000-000000000002`

Plan:

`b3100000-0000-0000-0000-000000000001`

Epoch:

`b3120000-0000-0000-0000-000000000002`

Domain:

`operational_execution`

Decision:

`approved`

Actor type:

`owner`

Decided at:

`2026-10-08T20:26:21-03:00`

## 5. State transition

B1R1:

> **draft → authorized_non_normative**

Preserved:

- started_at = NULL;
- completed_at = NULL;
- 14 frozen Opportunities;
- exact request mappings;
- same boundaries;
- zero MeasurementEvent;
- zero OpportunityResolution.

Original B1 remains:

> **invalidated**

## 6. Authority validation

Suite:

`database/f4-topi-n2-dcbti-b1r1-authority-tests.sql`

Result:

> **B1R1-AUTH-T01–T20 = PASS**

Coverage includes:

- exact authority row;
- authority ordering;
- decision Artifact integrity;
- B1R1 authorized state;
- B1 invalidated state;
- frozen opportunity equality;
- target currentness;
- zero measurement/resolution;
- source debt visibility;
- activation preflight WAIT/PASS/FAIL behavior.

## 7. Activation preflight for B1R1

At `2026-10-08T20:26:21-03:00`:

> **WAIT**

At `2026-10-19T08:00:00-03:00`:

> **PASS**

At `2026-10-19T08:30:00-03:00`:

> **PASS**

At `2026-10-19T09:00:00-03:00`:

> **FAIL**

Valid activation interval:

`2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`

## 8. Canonical CI

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run ID:

`37859791833`

Run number:

`232`

Validated HEAD:

`bfcd493a74e095d1c28974c7a033c5dbf0a08b39`

Conclusion:

> **success**

Created:

`2026-10-08T23:30:14Z`

Completed:

`2026-10-08T23:31:17Z`

## 9. Evidence artifact

Artifact ID:

`11585626965`

Name:

`oes-s5-evidence-37859791833`

Size:

`275422 bytes`

Digest:

`sha256:ea7b831fa6b0d8c2547bb5763e8c0cf0072c6dcabac4e279dd4d7bf10266a0a6`

Expiry:

`2026-12-07T23:31:09Z`

## 10. Rebuild

> **TOPI-B1R1-AUTH-REBUILD = PASS**

Final rebuild state:

- B1 = invalidated;
- B1R1 = authorized_non_normative;
- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

## 11. Result document

`docs/governance/87-resultado-authority-execucao-b1r1.md`

Status:

> **APPROVED_AND_VALIDATED — ACTIVATION_PENDING**

## 12. Current prohibitions

Before valid activation:

- no target-specific PubMed query;
- no target-specific ClinicalTrials.gov query;
- no MeasurementEvent;
- no OpportunityResolution;
- no timestamp shift;
- no request mapping change;
- no normative cadence/SLA;
- no M3;
- no Phase 5.

## 13. Next irreversible act

> **2026-10-19, high mode: Freshness Gate + factual America/Recife time + live B1R1 activation preflight.**

Only if live preflight = PASS may factual `started_at` be persisted.

At or after `2026-10-19T09:00:00-03:00` without prior valid activation:

> **do not activate and do not slide the schedule.**

## 14. Mandatory pause

After CP131 activation:

> **stop and await user “Prossiga”.**

A generic “Prossiga” before 19/10 may authorize only preparatory non-activation work, not activation.

## 15. HEAD before CP131 creation

`a27748f5dc0795d8001dbc1afb49b3068df8b940`

**Fim do CP131**
