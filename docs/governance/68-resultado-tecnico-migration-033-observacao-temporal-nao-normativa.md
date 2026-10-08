# 68 — Resultado Técnico da Migration 033: Aquisição Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **TECHNICAL_PASS — INFRASTRUCTURE_ONLY**  
**Modo:** médio  
**Dependências:** Documentos 61–67; CP119  
**Objeto:** registrar implementação e validação técnica da migration 033

## 1. Resultado

> **MIGRATION_033 = TECHNICALLY_VALIDATED**

> **MIGRATION_033_PROMOTION = INFRASTRUCTURE_ONLY**

> **F4_TNO_TESTS = TNO_T01_TO_T100_PASS**

> **MIGRATION_033_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_033 = PASS**

> **PRIOR_REGRESSIONS = PASS**

> **ZERO_REAL_SEED = PASS**

> **NORMATIVE_ISOLATION = PASS**

A migration 033 implementa infraestrutura para observação temporal experimental pré-calibração.

Ela não implementa Phase B real, schedule real ou regra temporal normativa.

## 2. Implementação

Master:

- `database/033_non_normative_temporal_observation.sql`

Fragments:

- `database/033a_temporal_observation_core.sql`;
- `database/033b_temporal_measurement_core.sql`;
- `database/033c_temporal_observation_guards.sql`;
- `database/033d_temporal_observation_helpers_views.sql`;
- `database/033e_temporal_observation_issue_validators.sql`.

Test assets:

- `database/f4-temporal-observation-fixtures.sql`;
- `database/f4-temporal-observation-smoke-tests.sql`;
- `database/f4-temporal-observation-tests.sql`.

Workflow:

- `.github/workflows/validate-s5.yml`.

## 3. Root physical objects

A migration cria 12 objetos root no schema `maintenance`:

1. `temporal_observation_plan`;
2. `temporal_observation_source`;
3. `temporal_observation_epoch`;
4. `temporal_observation_epoch_source`;
5. `temporal_observation_authority`;
6. `temporal_measurement_opportunity`;
7. `temporal_measurement_event`;
8. `temporal_measurement_opportunity_resolution`;
9. `temporal_measurement_item`;
10. `temporal_measurement_item_timepoint`;
11. `temporal_measurement_event_artifact`;
12. `temporal_observation_deviation`.

## 4. Frozen opportunity-set contract

A decisão do CP119 está implementada:

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = measurement_schedule_payload**

O payload:

- é estruturado;
- finite-only;
- non-normative;
- sem recurrence generator;
- sem opportunity_count redundante;
- com timestamps explícitos;
- com forbidden temporal keys recursivos.

`schedule_definition_artifact_uuid` permanece:

> **provenance-only**

e não controla a lista física de timestamps.

## 5. Lifecycle

Implementado:

### draft
- EpochSource;
- canonical payload;
- Opportunity materialization;
- authority decision.

### authorized_non_normative
Exige:
- current target;
- controlling Artifacts active;
- included source;
- runtime connectivity quando requerida;
- payload válido;
- exact payload↔Opportunity equality;
- operational authority approved;
- authority posterior/simultânea ao design freeze.

### active
Exige:
- authority ainda approved;
- target current;
- started_at;
- prerequisites preservados.

### completed
Exige:
- review boundary alcançado;
- target current;
- all Opportunities resolved;
- no material/invalidating deviation.

## 6. Opportunity / event / resolution

O contrato separa:

- planned Opportunity;
- actual MeasurementEvent attempt;
- append-only OpportunityResolution.

Ausência de execução:

> **não é MeasurementEvent falso**

mas:

> `OpportunityResolution.not_executed`.

Retries preservam histórico.

## 7. Item/timepoint

MeasurementEvent é execution-level.

MeasurementItem é record-level.

MeasurementItemTimepoint é source temporal endpoint-level.

Isso preserva:

- multi-item result sets;
- multiple source dates;
- per-item OES detection;
- date precision;
- replay.

Latency:

> **derivada**

e não persistida como segunda verdade material.

## 8. Source debt

O readiness layer expõe:

- `epoch_execution_completed`;
- `candidate_source_debt_present`.

Não existe:

> `coverage_complete` global.

Logo BVS/LILACS pode permanecer deferred sem ser ocultado por completion do epoch.

## 9. No-seed guarantee

Smoke executado imediatamente após migration 033 confirmou:

> **nenhum TemporalObservationPlan real ou sintético é criado pela migration.**

Fixtures são carregadas somente em arquivo separado:

> **SYNTHETIC_TEST_ONLY**

A fixture não utiliza:

- ProductVersion real N2;
- TOPI-N2 real;
- owner decision real;
- source observation real;
- schedule real.

## 10. Normative isolation

A suite provou isolamento da migration 033 em relação a:

- CadenceContract;
- CadenceObligation;
- CadenceObservation;
- SLA;
- MonitorCycle;
- UpdateSignal.

Não foi criado:

- scheduler;
- next_due;
- overdue;
- breach;
- compliance semantics.

## 11. CI canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37802083791**

Run number:

> **214**

Head validado:

> **6b9efb3a2439aa700fe8b38334995cf008327fb5**

Resultado:

> **success**

Período:

- início: `2026-10-08T15:35:58Z`;
- conclusão: `2026-10-08T15:36:48Z`.

## 12. Evidência técnica

Job:

> **postgres-s5**

Run 214 confirmou:

- migration 033 install = PASS;
- F4-TNO smoke = PASS;
- F2-B regression = PASS;
- S4 regression = PASS;
- S5 base = PASS;
- F3 product contracts = PASS;
- Monitor/Alert = PASS;
- F4 Update Protocol = PASS;
- UpdateRiskProfile = PASS;
- Operational Control = PASS;
- Propagation/Re-baselining = PASS;
- temporal calibration 032 = PASS;
- TNO-T01–T100 = PASS;
- migration 033 idempotent re-apply = PASS;
- migration 021–032 idempotency/regressions = PASS;
- rebuild-from-zero through 033 = PASS;
- Final S5 status = PASS.

## 13. Artifact de evidência

Artifact:

- ID: `11560209688`;
- name: `oes-s5-evidence-37802083791`;
- size: `256002 bytes`;
- digest:
  `sha256:fc2909171dfa16f94cccae8cc5bd739b11c6091c4b04bb3ad78136af4ecd0c6b`;
- head:
  `6b9efb3a2439aa700fe8b38334995cf008327fb5`.

Esse artifact é a evidência técnica promovida para este marco.

Runs 205–213 foram iterações de implementação/fix e não são promovidos como evidência final.

## 14. Histórico de defeitos corrigidos

Durante a implementação foram corrigidos sem mudança arquitetural:

- truncagem/corrupção textual do primeiro `033c`;
- rowtype + scalar em um único `SELECT INTO`;
- ambiguity em replay view join;
- falso positivo de normative-link test;
- falso positivo de SLA substring;
- PK nominal em CadenceObservation;
- falso positivo de UpdateSignal isolation.

Todos foram defeitos de implementação/test harness dentro do boundary aprovado.

## 15. O que este PASS não autoriza

O technical PASS não autoriza:

- materializar TOPI-N2-DCBTI-01 no banco;
- criar sources reais da TOPI;
- criar operational authority real para B1;
- selecionar opportunity timestamps;
- selecionar interval;
- executar Phase B;
- executar PubMed/ClinicalTrials.gov measurement;
- reclassificar BVS/LILACS;
- abrir Calibration Dossier;
- criar UpdatePolicy;
- criar CadenceContract;
- definir normative temporal values;
- desbloquear M3.

## 16. Estado após validação

> **MIGRATION_033 = TECHNICALLY_VALIDATED**

> **NON_NORMATIVE_TEMPORAL_OBSERVATION_INFRASTRUCTURE = AVAILABLE_NOT_ACTIVATED_FOR_REAL_TOPI**

> **TOPI_N2_DCBTI_REAL_MATERIALIZATION = NOT_AUTHORIZED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 17. Próximo passo

> **retornar ao plano metodológico da TOPI-N2-DCBTI-01 e decidir, antes de qualquer materialização real, como especificar o finite non-normative opportunity set da Phase B (número, timestamps, source-specific design e review boundary) e qual novo target-specific gate/authority package será necessário.**

Como essa próxima etapa volta a escolher valores temporais experimentais e desenho de observação:

> **modo alto volta a ser recomendado.**

**Fim do Documento 68**
