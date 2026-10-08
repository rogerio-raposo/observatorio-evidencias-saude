# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — TOPI Phase B Draft Frozen / Execution Authority Pending

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP122  
**Checkpoint anterior:** CP121  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento da preparação física da Phase B da TOPI-N2-DCBTI-01 e abertura do gate de execution authority

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PREPARATION_AUTHORITY = APPROVED_AND_EXECUTED**

> **RUNTIME_CONNECTIVITY = VERIFIED_FOR_B1_INTERFACES**

> **REAL_TOPI_DRAFT_MATERIALIZATION = COMPLETED**

> **TOPI_PREP_TESTS = TOPI_PREP_T01_TO_T30_PASS**

> **OBSERVATION_EPOCH_B1 = DRAFT_FROZEN**

> **DESIGN_FROZEN_AT = 2026-10-08T13:12:23-03:00**

> **PHASE_B_EXECUTION_AUTHORITY = AWAITING_EXPLICIT_OWNER_DECISION**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate

Na retomada do CP121:

- HEAD inicial `66ef2cbf08ae51a4fb0eca78b1bf51d9c39a58fb`;
- CP121 vigente;
- nenhum avanço concorrente;
- Documento 71 aguardava explicit owner decision.

O owner respondeu:

> **APPROVED — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

A decisão foi registrada no Documento 72.

## 3. Preparation authority

Documento:

`docs/governance/72-registro-authority-preparacao-phase-b-topi-n2-dcbti.md`

Commit:

`f423baba583c9524f14c4cd9e8560e68c8791d72`

Authority type:

> **owner preparation authority**

Não é Phase B execution authority.

## 4. Runtime connectivity

Documento:

`docs/governance/73-resultado-probes-conectividade-preparacao-phase-b-topi-n2-dcbti.md`

Connectivity run:

- workflow run `37806308031`;
- run number `215`;
- head `05de3cc6af8f393e2bd6ac524f14c310cc755aa0`;
- job `113411379827`;
- conclusion `success`.

PubMed:

> **PUBMED_EUTILS_CONNECTIVITY = VERIFIED**

ClinicalTrials.gov:

> **CLINICALTRIALS_GOV_API_V2_CONNECTIVITY = VERIFIED**

Observed API version:

> **2.0.5**

No target-specific query was executed.

No MeasurementEvent was executed.

Evidence artifact:

- ID `11563182298`;
- digest `sha256:7f01b41e7156993c547e936e53d7cf161490d5768b120de5051c4722fd74284f`.

## 5. Frozen controlling artifacts

Plan/specification, measurement design, three source definitions, two query definitions, two interface configs and two finite schedule definitions were frozen in:

`artifacts/topi-n2-dcbti-01/phase-b/`

Physical Artifact provenance uses:

> **git_blob_sha1**

No credentials/secrets were persisted.

## 6. Real physical Plan

Plan UUID:

`b3100000-0000-0000-0000-000000000001`

Plan code:

`TOPI-N2-DCBTI-01`

Plan version:

`2`

Target ProductVersion:

`81000000-0000-0000-0000-000000000701`

Calibration object:

`cadence`

Readiness scope:

`policy_aggregate`

Status:

`active`

Plan active means plan record active; it does not mean B1 execution active.

## 7. Source universe

PubMed ObservationSource:

`b3110000-0000-0000-0000-000000000001`

ClinicalTrials.gov ObservationSource:

`b3110000-0000-0000-0000-000000000002`

BVS/LILACS ObservationSource:

`b3110000-0000-0000-0000-000000000003`

BVS state:

> **deferred / access_path_not_reproducible**

Source debt remains explicit.

## 8. Observation Epoch B1

Epoch UUID:

`b3120000-0000-0000-0000-000000000001`

Epoch code:

`B1`

Status:

> **draft**

Start boundary:

`2026-10-19T08:00:00-03:00`

Review boundary:

`2026-11-10T18:00:00-03:00`

No started_at.

No completed_at.

## 9. EpochSource rows

PubMed:

`b3130000-0000-0000-0000-000000000001`

Connectivity:

> **verified**

ClinicalTrials.gov:

`b3130000-0000-0000-0000-000000000002`

Connectivity:

> **verified**

Both are immutable.

## 10. Frozen Opportunities

PubMed:

> **8**

ClinicalTrials.gov:

> **6**

Total:

> **14**

All match their canonical `measurement_schedule_payload` exactly.

No BVS opportunity exists.

## 11. Design freeze

Controlling timestamp:

> **2026-10-08T13:12:23-03:00**

Equivalent UTC:

> **2026-10-08T16:12:23Z**

Derived by:

`maintenance.temporal_observation_design_frozen_at('b3120000-0000-0000-0000-000000000001')`

Any valid Phase B operational execution authority must satisfy:

> **decided_at >= design_frozen_at**

## 12. Draft validation run

Workflow run:

> **37807367640**

Run number:

> **216**

Validated HEAD:

> **f1034c439082ffdf3f2fbba345daf00b2e2c4a35**

Job:

> **113415041833**

Conclusion:

> **success**

Results:

- TOPI-PREP-T01–T30 = PASS;
- target identity/currentness = PASS;
- source debt = PASS;
- payload↔Opportunity equality = PASS;
- exact 8+6 opportunities = PASS;
- design_frozen_at = PASS;
- zero authority rows = PASS;
- zero MeasurementEvent = PASS;
- zero OpportunityResolution = PASS;
- rebuild reproducibility = PASS;
- full prior regressions = PASS.

Evidence artifact:

- ID `11563323408`;
- name `oes-s5-evidence-37807367640`;
- digest `sha256:3516f2de565655628ab74ecfe5ad0d48fe33658b7ceb9561e61e1802259b12c8`.

## 13. Documento 74

Path:

`docs/governance/74-resultado-preparacao-phase-b-topi-n2-dcbti.md`

Commit:

`22b36b9a0e993d6e811cb341bd4e6922e2f52fc8`

Result:

> **PREPARATION_PASS — DRAFT_FROZEN — EXECUTION_NOT_AUTHORIZED**

## 14. Documento 75

Path:

`docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md`

Commit:

`7286560b171d2ffe0d97ee6cfa0a8b6f40e22a93`

Status:

> **AWAITING_EXPLICIT_OWNER_DECISION**

This is the controlling authority package for the exact frozen B1.

## 15. Valid owner decision

For APPROVED, the response must explicitly bind:

- Phase B execution;
- Documento 75;
- TOPI-N2-DCBTI-01;
- Epoch B1.

Valid form:

> **APPROVED — Phase B execution / Documento 75 / TOPI-N2-DCBTI-01 / Epoch B1**

Also valid with REVISE or REJECTED instead of APPROVED.

Generic:

- Prossiga;
- Ok;
- Pode continuar;

> **does not authorize execution.**

## 16. If APPROVED later

Only after explicit approval:

1. Freshness Gate;
2. target-current recheck;
3. record exact owner execution decision;
4. persist operational_execution authority row for exact B1;
5. validate authority freshness;
6. transition draft → authorized_non_normative;
7. only when activation preconditions remain satisfied, transition authorized_non_normative → active;
8. execute Opportunities only at actual planned measurement acts.

No measurement may occur before these steps.

## 17. Schedule expiry

If B1 is not validly authorized/activated before the first opportunity:

> **do not slide timestamps.**

The frozen B1 becomes:

> **EXPIRED_NOT_EXECUTED**

A new design/version/gate is then required.

## 18. STATE / CHANGELOG

Preparation state commit:

`4b6633106ed2a043526baccae0522a1cb421676c`

Preparation CHANGELOG commit:

`73bbd388a2864ed7084dd49f14250d8f61ec24e5`

## 19. Próximo passo exato

> **Aguardar explicit owner decision on Phase B execution / Documento 75 / TOPI-N2-DCBTI-01 / Epoch B1.**

## 20. Regra de parada

Após ativação do CP122:

> **parar.**

Não criar authority row.

Não transicionar B1.

Não executar source query.

Não criar MeasurementEvent.

## 21. HEAD antes da criação do CP122

`73bbd388a2864ed7084dd49f14250d8f61ec24e5`

**Fim do CP122**
