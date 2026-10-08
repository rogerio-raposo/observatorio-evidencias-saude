# 74 — Resultado da Preparação da Phase B da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **PREPARATION_PASS — DRAFT_FROZEN — EXECUTION_NOT_AUTHORIZED**  
**Authority basis:** Documento 71 + Documento 72 / owner APPROVED  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1  
**Natureza:** não normativa

## 1. Resultado

> **PREPARATION_AUTHORITY = APPROVED_AND_EXECUTED**

> **RUNTIME_CONNECTIVITY = VERIFIED_FOR_B1_INTERFACES**

> **REAL_TOPI_DRAFT_MATERIALIZATION = COMPLETED**

> **TOPI_PREP_TESTS = TOPI_PREP_T01_TO_T30_PASS**

> **OBSERVATION_EPOCH_B1 = DRAFT_FROZEN**

> **DESIGN_FROZEN_AT = 2026-10-08T13:12:23-03:00**

> **PHASE_B_EXECUTION_AUTHORITY = NOT_GRANTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT = 0**

Nenhuma execução científica/prospectiva da Phase B ocorreu.

## 2. Freshness e target

Antes da preparação, o Freshness Gate confirmou:

- branch `main`;
- CP121 vigente;
- nenhum avanço concorrente;
- ProductVersion `81000000-0000-0000-0000-000000000701` current/published;
- InvestigationVersion `81000000-0000-0000-0000-000000000002` current/active N2/M1;
- vínculo primary ProductVersion→InvestigationVersion presente.

## 3. Authority de preparação

Decisão explícita do owner:

> **APPROVED — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

Registro:

- Documento 72;
- commit `f423baba583c9524f14c4cd9e8560e68c8791d72`.

Essa decisão autorizou preparação, não execução.

## 4. Connectivity evidence

### 4.1 Run canônico

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37806308031**

Run number:

> **215**

Head:

> **05de3cc6af8f393e2bd6ac524f14c310cc755aa0**

Job:

> **113411379827**

Resultado:

> **success**

### 4.2 PubMed

Probe:

`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed&retmode=json`

Resultado:

> **PUBMED_EUTILS_CONNECTIVITY = VERIFIED**

Nenhum termo científico foi consultado.

### 4.3 ClinicalTrials.gov

Probe:

`https://clinicaltrials.gov/api/v2/version`

Resultado:

> **CLINICALTRIALS_GOV_API_V2_CONNECTIVITY = VERIFIED**

Observed API version:

> **2.0.5**

Nenhuma busca de estudos foi executada.

### 4.4 Connectivity artifact

- artifact ID: `11563182298`;
- name: `oes-s5-evidence-37806308031`;
- digest:
  `sha256:7f01b41e7156993c547e936e53d7cf161490d5768b120de5051c4722fd74284f`.

Documento 73 registra esse resultado.

## 5. Controlling Artifacts congelados

Foram congelados no repositório:

- plan v0.2-final;
- measurement design B1;
- source definitions PubMed / ClinicalTrials.gov / BVS-LILACS;
- PubMed query v1;
- PubMed interface v1;
- PubMed schedule B1;
- ClinicalTrials.gov query v1;
- ClinicalTrials.gov interface v1;
- ClinicalTrials.gov schedule B1.

Os registros `artifact.artifact` usam:

> **hash_algorithm = git_blob_sha1**

para provenance do conteúdo congelado.

## 6. Physical Plan

TemporalObservationPlan:

- UUID: `b3100000-0000-0000-0000-000000000001`;
- plan_code: `TOPI-N2-DCBTI-01`;
- plan_version: `2`;
- target ProductVersion: `81000000-0000-0000-0000-000000000701`;
- calibration_object: `cadence`;
- readiness_scope: `policy_aggregate`;
- record_status: `active`.

A versão documental v0.1 nunca teve row física.

Logo:

> **supersedes_observation_plan_uuid = NULL**

com provenance documental explícita.

## 7. Candidate source universe materializado

### PubMed/MEDLINE

ObservationSource UUID:

`b3110000-0000-0000-0000-000000000001`

Status:

> **included**

Runtime connectivity required:

> **true**

### ClinicalTrials.gov

ObservationSource UUID:

`b3110000-0000-0000-0000-000000000002`

Status:

> **included**

Runtime connectivity required:

> **true**

### BVS/LILACS

ObservationSource UUID:

`b3110000-0000-0000-0000-000000000003`

Status:

> **deferred**

Debt:

> **access_path_not_reproducible**

Nenhuma Opportunity BVS foi criada.

## 8. Observation Epoch B1

Epoch UUID:

`b3120000-0000-0000-0000-000000000001`

Status:

> **draft**

Start boundary:

`2026-10-19T08:00:00-03:00`

Review boundary:

`2026-11-10T18:00:00-03:00`

Não existe:

- started_at;
- completed_at;
- authority row;
- MeasurementEvent;
- OpportunityResolution.

## 9. EpochSources

PubMed EpochSource:

`b3130000-0000-0000-0000-000000000001`

Runtime connectivity:

> **verified**

ClinicalTrials.gov EpochSource:

`b3130000-0000-0000-0000-000000000002`

Runtime connectivity:

> **verified**

Os dois rows são imutáveis.

## 10. Frozen opportunity sets

PubMed:

> **8 Opportunities**

ClinicalTrials.gov:

> **6 Opportunities**

Total:

> **14 Opportunities**

Todas:

- pertencem ao exact B1;
- correspondem ao canonical `measurement_schedule_payload`;
- estão dentro das boundaries;
- são `frozen_opportunity_set`;
- permanecem não normativas.

## 11. Physical design freeze

A última Opportunity foi criada em:

> **2026-10-08T13:12:23-03:00**

O helper:

`maintenance.temporal_observation_design_frozen_at('b3120000-0000-0000-0000-000000000001')`

retorna:

> **2026-10-08T13:12:23-03:00**

Esse timestamp passa a ser controlling para authority freshness.

Qualquer Phase B execution authority válida deve possuir:

> **decided_at >= 2026-10-08T13:12:23-03:00**

## 12. Validation run

Workflow run:

> **37807367640**

Run number:

> **216**

Head validado:

> **f1034c439082ffdf3f2fbba345daf00b2e2c4a35**

Resultado:

> **success**

Job:

> **113415041833**

### Test result

> **TOPI-PREP-T01-T30 PASS**

A suite confirmou:

- target current/published;
- exact Product↔Investigation linkage;
- Plan v2 correto;
- ausência de physical v1;
- 3 sources;
- BVS debt;
- B1 draft;
- 2 EpochSources;
- runtime connectivity verified;
- payload↔Opportunity exact equality;
- 8 + 6 opportunities;
- design_frozen_at exato;
- operational execution authority = missing;
- zero authority rows;
- zero MeasurementEvent;
- zero OpportunityResolution;
- zero deviations;
- controlling Artifacts active;
- source debt visível;
- draft preservado.

### Rebuild

> **TOPI-B1-PREP-REBUILD PASS**

O rebuild-from-zero reproduziu o mesmo draft sem execução.

## 13. Evidence artifact

Run 216 artifact:

- ID: `11563323408`;
- name: `oes-s5-evidence-37807367640`;
- size: `258456 bytes`;
- digest:
  `sha256:3516f2de565655628ab74ecfe5ad0d48fe33658b7ceb9561e61e1802259b12c8`.

## 14. O que esta preparação não autoriza

Continua proibido:

- persistir execution authority sem nova owner decision;
- transicionar B1 para `authorized_non_normative`;
- transicionar B1 para `active`;
- criar MeasurementEvent;
- executar PubMed B1 measurement;
- executar ClinicalTrials.gov B1 measurement;
- resolver Opportunity;
- alterar currentness/conclusion/assurance;
- criar UpdateSignal automático;
- abrir Calibration Dossier;
- criar UpdatePolicy/CadenceContract;
- definir normative temporal value.

## 15. Próximo passo

A preparação atingiu o design freeze.

Portanto agora, e somente agora, pode ser solicitado:

> **Phase B Operational Execution Authority**

para o exact Plan/Epoch congelado.

Essa authority precisa ser nova e explicitamente humana.

**Fim do Documento 74**
