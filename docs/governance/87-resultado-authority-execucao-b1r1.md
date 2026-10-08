# 87 — Resultado da Execution Authority do Replacement Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **APPROVED_AND_VALIDATED — ACTIVATION_PENDING**  
**Authority package:** Documento 85  
**Decision record:** Documento 86  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Natureza:** operacional não normativa

## 1. Resultado

> **B1R1_EXECUTION_AUTHORITY = APPROVED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **B1R1_ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1R1 = 0**

> **ORIGINAL_B1 = INVALIDATED**

## 2. Owner decision

Decisão explícita recebida:

> **APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**

Timestamp factual da decisão:

> **2026-10-08T20:26:21-03:00**

Design freeze do B1R1:

> **2026-10-08T19:48:20-03:00**

Resultado:

> **AUTHORITY_AFTER_DESIGN_FREEZE = PASS**

## 3. Decision Artifact

Documento:

`docs/governance/86-decisao-authority-execucao-b1r1.md`

Git blob SHA-1:

`5e71b65df149c91a41879b1d1610e0edf8a3ef29`

Physical Artifact UUID:

`b3000000-0000-0000-0000-000000000017`

Status:

> **active**

## 4. Physical authority

Authority UUID:

`b3150000-0000-0000-0000-000000000002`

Plan UUID:

`b3100000-0000-0000-0000-000000000001`

Epoch UUID:

`b3120000-0000-0000-0000-000000000002`

Domain:

`operational_execution`

Decision:

`approved`

Actor:

`OES_PROJECT_OWNER`

Actor type:

`owner`

Decided at:

`2026-10-08T20:26:21-03:00`

## 5. State transition

Before:

> **B1R1 = draft**

After:

> **B1R1 = authorized_non_normative**

Preserved:

- started_at = NULL;
- completed_at = NULL;
- 14 frozen Opportunities;
- exact source/query/interface/request mapping;
- original boundaries;
- zero MeasurementEvent;
- zero OpportunityResolution.

Original B1 remains:

> **invalidated**

## 6. Authority test suite

File:

`database/f4-topi-n2-dcbti-b1r1-authority-tests.sql`

Suite:

> **B1R1-AUTH-T01–T20**

Validated:

- exact authority row;
- exact decision timestamp;
- authority after design freeze;
- authority state = approved;
- B1R1 status = authorized_non_normative;
- original B1 remains invalidated;
- decision Artifact active and hash-matched;
- both opportunity sets equal frozen schedules;
- target current;
- zero MeasurementEvent;
- zero OpportunityResolution;
- no blocker issue;
- source debt remains visible;
- owner decision before first Opportunity;
- current-state preflight = WAIT;
- activation-window start = PASS;
- activation-window interior = PASS;
- first Opportunity boundary = FAIL;
- no measurement mutation.

Result:

> **B1R1-AUTH-T01–T20 = PASS**

## 7. Deterministic activation preflight

For B1R1:

At:

`2026-10-08T20:26:21-03:00`

Result:

> **WAIT**

At:

`2026-10-19T08:00:00-03:00`

Result:

> **PASS**

At:

`2026-10-19T08:30:00-03:00`

Result:

> **PASS**

At:

`2026-10-19T09:00:00-03:00`

Result:

> **FAIL**

Therefore:

> **ACTIVATION_INTERVAL = [2026-10-19T08:00:00-03:00, 2026-10-19T09:00:00-03:00)**

## 8. Canonical CI validation

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Canonical run:

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

Rebuild final state:

- B1 = invalidated;
- B1R1 = authorized_non_normative;
- B1R1 started_at = NULL;
- zero MeasurementEvent;
- zero OpportunityResolution.

## 11. Activation remains separate

Esta authority não ativa o B1R1.

Activation continua exigindo, em 19/10:

1. modo alto;
2. Freshness Gate completo;
3. hora factual America/Recife;
4. live activation preflight;
5. PASS integral;
6. persistência factual de started_at;
7. prova pós-activation de zero MeasurementEvent;
8. checkpoint antes da primeira PubMed Opportunity.

## 12. Proibições preservadas

Antes da activation:

- não executar PubMed target-specific query;
- não executar ClinicalTrials.gov target-specific query;
- não criar MeasurementEvent;
- não criar OpportunityResolution;
- não alterar timestamps;
- não alterar request mapping;
- não criar UpdateSignal automático;
- não operacionalizar M3;
- não iniciar Fase 5.

**Fim do Documento 87**
