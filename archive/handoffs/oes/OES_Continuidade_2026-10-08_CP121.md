# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Phase B Finite Design / Preparation Authority Pending

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP121  
**Checkpoint anterior:** CP120  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento do desenho experimental candidato da Phase B da TOPI-N2-DCBTI-01 antes de qualquer real materialization

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **MIGRATION_033 = TECHNICALLY_VALIDATED**

> **TOPI_N2_DCBTI_V02_FINAL_DESIGN = READY_FOR_PREPARATION_AUTHORITY_REQUEST**

> **PHASE_B_EXPERIMENTAL_DESIGN = FINITE_IRREGULAR_SOURCE_SPECIFIC**

> **TOPI_N2_DCBTI_PHASE_B_DESIGN_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PREPARATION_AUTHORITY = PENDING**

> **RUNTIME_CONNECTIVITY_PROBES = NOT_AUTHORIZED**

> **REAL_TOPI_DRAFT_MATERIALIZATION = NOT_AUTHORIZED**

> **DESIGN_FROZEN_AT = NOT_ESTABLISHED**

> **PHASE_B_EXECUTION_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP120:

- branch `main`;
- HEAD `592ccba83079c6608c1891f44c155ac4a71df7ce`;
- CP120 vigente;
- nenhum commit concorrente posterior;
- migration 033 = TECHNICALLY_VALIDATED;
- TOPI real não materializada;
- measurement schedule real = NOT_SELECTED;
- Phase B authority/execution = NOT_AUTHORIZED.

## 3. Source design

Phase B B1 candidata inclui:

- PubMed/MEDLINE;
- ClinicalTrials.gov.

BVS/LILACS:

> **DEFERRED_SOURCE_DEBT**

Reason:
- programmatic access path para intended OES workflow não foi estabelecido de modo reproduzível na Phase A.

BVS continua no candidate source universe.

## 4. External documentary recheck

Em 2026-10-08 foram rechecadas official source documents.

PubMed:
- current User Guide;
- daily incremental update behavior;
- CRDT/EDAT semantics;
- E-utilities usage controls.

ClinicalTrials.gov:
- current structured data fields;
- API v2 REST/OpenAPI;
- ISO 8601 date model;
- StudyFirstPostDate / ResultsFirstPostDate / LastUpdatePostDate.

Nenhum runtime API probe foi executado.

Nenhuma target-specific scientific search foi executada.

## 5. Observation Epoch B1 candidate

Epoch code:

> **B1**

Start boundary:

> **2026-10-19T08:00:00-03:00**

Review boundary:

> **2026-11-10T18:00:00-03:00**

Timezone:

> **America/Recife**

O epoch não pode completar antes do review boundary.

## 6. PubMed opportunity set

8 finite opportunities:

1. 2026-10-19T09:00:00-03:00
2. 2026-10-20T09:00:00-03:00
3. 2026-10-22T09:00:00-03:00
4. 2026-10-26T09:00:00-03:00
5. 2026-10-29T09:00:00-03:00
6. 2026-11-03T09:00:00-03:00
7. 2026-11-06T09:00:00-03:00
8. 2026-11-09T09:00:00-03:00

Design:

> finite / irregular / non-normative.

Query candidate:

> fixed union of the two historical PubMed review/RCT scopes.

No relative date filter.

## 7. ClinicalTrials.gov opportunity set

6 finite opportunities:

1. 2026-10-19T10:30:00-03:00
2. 2026-10-22T10:30:00-03:00
3. 2026-10-27T10:30:00-03:00
4. 2026-10-30T10:30:00-03:00
5. 2026-11-04T10:30:00-03:00
6. 2026-11-09T10:30:00-03:00

Query semantics:

> insomnia AND (digital CBT OR digital CBT-I OR internet CBT-I)

Actual API request/parameterization:

> must be frozen only after runtime connectivity verification and before EpochSource materialization.

## 8. Baseline semantics

No complete trustworthy pre-B1 baseline exists.

First successful event of each source:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

Rules:

- novelty_state = not_applicable;
- new_identifier_count = NULL;
- items may be structurally new_to_epoch;
- new_to_epoch != new in science;
- new_to_epoch != new since evidence cutoff.

Subsequent source events compare against prior epoch observations.

## 9. No hidden cadence

The design deliberately rejects:

- daily regular schedule;
- weekly regular schedule;
- same interval for both sources;
- recurrence generator;
- scheduler.

Purpose:

- source repeatability;
- replay;
- missingness;
- OES detection process;
- source date observability;
- pilot effort.

No statistical power claim.

No minimum-N claim.

## 10. Runtime connectivity ordering

Because EpochSource is immutable:

> **runtime connectivity must be verified before real EpochSource insertion.**

Required probes:

- PubMed E-utilities;
- ClinicalTrials.gov API v2.

These probes:

- are preparation activities;
- are not Search;
- are not MeasurementEvent;
- are not MonitoringCycle.

At CP121:

> **NOT AUTHORIZED**

## 11. Authority ordering

Migration 033 requires:

> **authority.decided_at >= design_frozen_at**

Therefore final Phase B execution approval cannot occur before physical freeze.

Required sequence:

1. owner preparation authority;
2. runtime connectivity probes;
3. Artifact/query/interface freeze;
4. real draft materialization;
5. payload↔Opportunity equality;
6. preserve design_frozen_at;
7. create exact Phase B execution authority package;
8. owner/institutional decision after freeze;
9. persist authority row;
10. authorized_non_normative;
11. active;
12. execution.

## 12. Documento 69

Path:

`docs/governance/69-desenho-experimental-finito-phase-b-topi-n2-dcbti.md`

Commit:

`4d7717b5e541b0f0210d5abb9a4955e9785a3324`

State:

> **SPECIFIED_CANDIDATE**

## 13. Documento 70

Path:

`docs/governance/70-recheck-desenho-experimental-phase-b-topi-n2-dcbti.md`

Commit:

`d280f9618affc9c38d8bed8b6722c73fbfc11b1e`

Result:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 14. Documento 71

Path:

`docs/governance/71-pacote-authority-preparacao-phase-b-topi-n2-dcbti.md`

Commit:

`aa9438fc3638545d55a71c7750380c91c70a8ad3`

Status:

> **AWAITING_EXPLICIT_OWNER_DECISION**

## 15. Owner decision required

A próxima decisão não pode ser inferida de:

- Prossiga;
- Ok;
- Pode continuar.

Para autorizar preparation, a decisão deve vincular explicitamente:

- Phase B preparation;
- Documento 71;
- TOPI-N2-DCBTI-01.

Exemplo válido:

> **APPROVED — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

Outras opções válidas:

> **REVISE — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

> **REJECTED — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

## 16. O que uma futura APPROVED autorizará

Somente:

- target-current recheck;
- minimal runtime connectivity probes;
- query/interface Artifact freeze;
- real draft materialization;
- integrity/equality validation;
- design_frozen_at preservation.

Não autoriza:

- MeasurementEvent;
- B1 query execution como measurement;
- Search científica por força do pacote;
- Phase B execution;
- normative objects.

## 17. Schedule expiry

Se o processo não estiver pronto antes da primeira opportunity:

> **não deslocar timestamps.**

Candidate B1:

> **EXPIRED_NOT_EXECUTED**

Novo design/version/gate será obrigatório.

## 18. STATE / CHANGELOG

STATE commit:

`18fd9eaeebfc652526d731a60d0c65526aa3bb01`

CHANGELOG commit:

`febcad18cd83a801c6a8497e71298acd879634fc`

## 19. Próximo passo exato

> **Aguardar a decisão explícita do owner sobre Documento 71.**

Se APPROVED:

- rerun Freshness Gate;
- execute somente preparation scope;
- stop após real draft freeze;
- criar novo Phase B execution authority package;
- solicitar nova owner decision.

## 20. Regra de parada

Após ativação do CP121:

> **parar.**

Não executar probe.

Não materializar TOPI real.

Não interpretar “Prossiga” como authority.

## 21. HEAD antes da criação do CP121

`febcad18cd83a801c6a8497e71298acd879634fc`

**Fim do CP121**
