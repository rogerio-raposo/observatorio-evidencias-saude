# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Corrective Preparation B1R1 PASS / Execution Authority Pending

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP130  
**Checkpoint anterior:** CP129  
**Status:** artefato de continuidade; não normativo  
**Escopo:** corrective preparation autorizada para substituir B1 por B1R1, com B1R1 congelado em draft e nova execution authority ainda pendente.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **B1 = INVALIDATED_WITHOUT_EXECUTION**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_DESIGN_FROZEN_AT = 2026-10-08T19:48:20-03:00**

> **B1R1_EXECUTION_AUTHORITY = PENDING**

> **B1R1_ACTIVATION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Owner authority

Received:

> **APPROVED — corrective preparation / Documento 82 / TOPI-N2-DCBTI-01 / replace B1 with B1R1**

Recorded in:

`docs/governance/83-authority-corrective-preparation-b1r1.md`

Scope was preparation only.

## 3. Corrective connectivity

Run:

`37855302262`

Run number:

`224`

Validated HEAD:

`9e04ba94a7bf5b90040bd156bd0f8595cdd9543f`

Result:

> **success**

Observed:

- PubMed E-utilities = VERIFIED;
- ClinicalTrials.gov API v2 = VERIFIED;
- ClinicalTrials.gov apiVersion = `2.0.5`;
- no target-specific query;
- no materialization in probe step.

Artifact:

- ID `11583468584`;
- digest `sha256:c0d933ca42961e1f0605751544e603dac33039b1c3d1476dbe187c65925f2e52`;
- expiry `2026-12-07T22:45:55Z`.

## 4. Corrective artifacts frozen

Created:

- `artifacts/topi-n2-dcbti-01/phase-b/measurement-design-b1r1.md`;
- `artifacts/topi-n2-dcbti-01/phase-b/pubmed-interface-v2.json`;
- `artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-query-v2.txt`;
- `artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v2.json`.

Old frozen artifacts were preserved.

## 5. Original B1

Epoch:

`b3120000-0000-0000-0000-000000000001`

Final state:

> **invalidated**

Preserved:

- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

The invalidation is corrective governance state, not a failed measurement.

## 6. Replacement B1R1

Epoch:

`b3120000-0000-0000-0000-000000000002`

State:

> **draft**

Plan:

`TOPI-N2-DCBTI-01 / v2`

PubMed EpochSource:

`b3130000-0000-0000-0000-000000000003`

ClinicalTrials.gov EpochSource:

`b3130000-0000-0000-0000-000000000004`

Both connectivity statuses:

> **verified**

## 7. Frozen request mapping

PubMed:

- ESearch GET;
- db = pubmed;
- term = frozen query;
- retmode = json;
- retmax = 10000;
- no relative date filter.

ClinicalTrials.gov:

- GET /api/v2/studies;
- query.cond = insomnia;
- query.term = (digital CBT OR digital CBT-I OR internet CBT-I);
- format = json;
- pageSize = 10;
- complete pagination via nextPageToken/pageToken.

No scientific scope change occurred.

## 8. Frozen temporal design

Start:

`2026-10-19T08:00:00-03:00`

Review:

`2026-11-10T18:00:00-03:00`

PubMed:

> **8 Opportunities**

ClinicalTrials.gov:

> **6 Opportunities**

All 14 timestamps equal the original B1 timestamps.

> **NO_SCHEDULE_SLIDING = PASS**

## 9. New design freeze

`maintenance.temporal_observation_design_frozen_at(B1R1)`

returns:

`2026-10-08T19:48:20-03:00`

Any valid B1R1 execution authority must be decided after this timestamp.

## 10. Corrective validation

Suite:

> **B1R1-T01–T24 = PASS**

Canonical validation:

- run `37855834411`;
- run number `229`;
- validated HEAD `cea4c1a67b7de4537bdf95485146199c86989a48`;
- conclusion = success;
- artifact `11583902320`;
- digest `sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`;
- expiry `2026-12-07T22:50:05Z`.

Rebuild:

> **TOPI-B1R1-PREP-REBUILD = PASS**

## 11. Result document

`docs/governance/84-resultado-corrective-preparation-b1r1.md`

Status:

> **CORRECTIVE_PREPARATION_PASS — B1R1_DRAFT_FROZEN — EXECUTION_NOT_AUTHORIZED**

## 12. New execution authority package

`docs/governance/85-pacote-authority-execucao-b1r1.md`

Status:

> **PENDING OWNER DECISION**

Required explicit formulation for approval:

> **APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**

Generic “Prossiga” does not grant execution authority.

## 13. Current prohibitions

Until explicit B1R1 execution authority:

- do not transition B1R1 to authorized_non_normative;
- do not activate B1R1;
- do not run target-specific PubMed query;
- do not run target-specific ClinicalTrials.gov query;
- do not create MeasurementEvent;
- do not create OpportunityResolution;
- do not alter timestamps;
- do not start M3 or Phase 5.

## 14. Mandatory pause

After CP130 activation:

> **stop and await owner decision on Documento 85.**

## 15. HEAD before CP130 creation

`6c70e8d786b962f94a88c0a7f091620af8128c29`

**Fim do CP130**
