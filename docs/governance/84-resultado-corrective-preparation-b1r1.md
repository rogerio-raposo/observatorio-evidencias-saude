# 84 — Resultado da Corrective Preparation do Replacement Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **CORRECTIVE_PREPARATION_PASS — B1R1_DRAFT_FROZEN — EXECUTION_NOT_AUTHORIZED**  
**Authority basis:** Documento 82 + Documento 83 / owner APPROVED  
**Instância:** TOPI-N2-DCBTI-01  
**Replacement:** B1 → B1R1  
**Natureza:** não normativa

## 1. Resultado

> **CORRECTIVE_PREPARATION_AUTHORITY = APPROVED_AND_EXECUTED**

> **ORIGINAL_B1 = INVALIDATED_WITHOUT_EXECUTION**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_DESIGN_FROZEN_AT = 2026-10-08T19:48:20-03:00**

> **B1R1_EXECUTION_AUTHORITY = NOT_GRANTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

## 2. Connectivity ordering

A materialização respeitou:

> **CONNECTIVITY PROBE → ARTIFACT FREEZE → B1 INVALIDATION + B1R1 DRAFT MATERIALIZATION**

Primeira corrective connectivity evidence:

- workflow run: `37855302262`;
- run number: `224`;
- validated HEAD: `9e04ba94a7bf5b90040bd156bd0f8595cdd9543f`;
- job: `113577921135`;
- PubMed E-utilities = VERIFIED;
- ClinicalTrials.gov API v2 = VERIFIED;
- apiVersion observed = `2.0.5`;
- probe completed = `2026-10-08T22:45:40Z`;
- target-specific query executed = false.

Artifact:

- ID: `11583468584`;
- name: `oes-s5-evidence-37855302262`;
- digest: `sha256:c0d933ca42961e1f0605751544e603dac33039b1c3d1476dbe187c65925f2e52`;
- expiry: `2026-12-07T22:45:55Z`.

## 3. Corrective artifacts

Novos artifacts de repositório:

- `measurement-design-b1r1.md`;
- `pubmed-interface-v2.json`;
- `clinicaltrials-query-v2.txt`;
- `clinicaltrials-interface-v2.json`.

Physical Artifact UUIDs:

- B1R1 measurement design: `b3000000-0000-0000-0000-000000000013`;
- ClinicalTrials query v2: `b3000000-0000-0000-0000-000000000014`;
- ClinicalTrials interface v2: `b3000000-0000-0000-0000-000000000015`;
- PubMed interface v2: `b3000000-0000-0000-0000-000000000016`.

Os artifacts v1 foram preservados e não reescritos.

## 4. PubMed request contract

Scientific query scope:

> **unchanged**

Frozen operational mapping:

- ESearch GET;
- `db=pubmed`;
- `term` = frozen PubMed query v1;
- `retmode=json`;
- `retmax=10000`;
- relative date filter = prohibited.

Completeness:

- completed somente quando source count <= 10.000 e o PMID idlist estiver completo;
- count > 10.000 = fail closed / deviation;
- não alterar a query silenciosamente.

## 5. ClinicalTrials.gov request contract

Logical scientific scope:

> **unchanged**

Frozen normalized mapping:

- endpoint: `/api/v2/studies`;
- method: GET;
- `query.cond=insomnia`;
- `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- `format=json`;
- `pageSize=10`;
- seguir `nextPageToken/pageToken` até ausência do próximo token.

Completed retrieval exige paginação completa.

Minimal record contract:

- NCTId;
- BriefTitle;
- OverallStatus;
- StudyFirstPostDate;
- ResultsFirstPostDate;
- LastUpdatePostDate.

## 6. Original B1

Epoch UUID:

`b3120000-0000-0000-0000-000000000001`

Final corrective state:

> **invalidated**

Preservado:

- started_at = NULL;
- completed_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

A invalidation não representa failed measurement.

A authority do Documento 75 permanece historical e limitada ao B1 original.

## 7. Replacement B1R1

Epoch UUID:

`b3120000-0000-0000-0000-000000000002`

Status:

> **draft**

Plan:

`b3100000-0000-0000-0000-000000000001` / TOPI-N2-DCBTI-01 v2.

Boundaries:

- start: `2026-10-19T08:00:00-03:00`;
- review: `2026-11-10T18:00:00-03:00`.

Nenhum timestamp foi deslocado.

## 8. B1R1 EpochSources

PubMed:

`b3130000-0000-0000-0000-000000000003`

ClinicalTrials.gov:

`b3130000-0000-0000-0000-000000000004`

Ambos:

> **runtime_connectivity_status = verified**

## 9. Opportunity set

PubMed:

- UUIDs `b314...0015` a `b314...0022`;
- 8 timestamps idênticos ao B1 original.

ClinicalTrials.gov:

- UUIDs `b314...0023` a `b314...0028`;
- 6 timestamps idênticos ao B1 original.

Total:

> **14 Opportunities**

> **NO_SCHEDULE_SLIDING = PASS**

## 10. New design freeze

Helper:

`maintenance.temporal_observation_design_frozen_at('b3120000-0000-0000-0000-000000000002')`

Resultado:

> **2026-10-08T19:48:20-03:00**

Esse timestamp passa a controlar qualquer execution authority futura do B1R1.

## 11. Corrective tests

Suite:

`database/f4-topi-n2-dcbti-b1r1-corrective-preparation-tests.sql`

Resultado:

> **B1R1-T01–T24 = PASS**

Validado:

- B1 invalidado e não executado;
- B1R1 draft;
- boundaries preservadas;
- 2 EpochSources;
- connectivity verified;
- artifacts corretivos exatos;
- 8 + 6 Opportunities;
- payload↔Opportunity equality;
- design_frozen_at exato;
- zero B1R1 execution authority;
- zero MeasurementEvent;
- zero OpportunityResolution;
- source debt BVS/LILACS visível;
- target current.

## 12. CI canônica da materialização

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

`37855834411`

Run number:

`229`

Validated HEAD:

`cea4c1a67b7de4537bdf95485146199c86989a48`

Conclusion:

> **success**

Created:

`2026-10-08T22:49:13Z`

Completed:

`2026-10-08T22:50:12Z`

O próprio run 229 repetiu o connectivity probe e reconfirmou ClinicalTrials.gov API v2 `2.0.5`.

## 13. Evidence artifact

Artifact ID:

`11583902320`

Name:

`oes-s5-evidence-37855834411`

Size:

`273971 bytes`

Digest:

`sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`

Expiry:

`2026-12-07T22:50:05Z`

## 14. Rebuild

> **TOPI-B1R1-PREP-REBUILD = PASS**

O rebuild reproduz a sequência histórica:

1. B1 draft;
2. B1 authority;
3. APF/FM regressions;
4. B1 invalidation;
5. B1R1 draft corrective materialization.

Estado final do rebuild:

- B1 = invalidated;
- B1R1 = draft;
- B1R1 authority = missing;
- zero MeasurementEvent.

## 15. Próximo gate

Somente agora pode ser solicitado:

> **B1R1 Operational Execution Authority**

A nova decisão precisa:

- referenciar exact B1R1;
- ocorrer após `2026-10-08T19:48:20-03:00`;
- ser explícita;
- não reutilizar Documento 75.

**Fim do Documento 84**
