# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Migration 033 Technical PASS

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP120  
**Checkpoint anterior:** CP119  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento técnico da migration 033 de observação temporal não normativa

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **MIGRATION_033 = TECHNICALLY_VALIDATED**

> **NON_NORMATIVE_TEMPORAL_OBSERVATION_INFRASTRUCTURE = AVAILABLE_NOT_ACTIVATED_FOR_REAL_TOPI**

> **F4_TNO_TESTS = TNO_T01_TO_T100_PASS**

> **MIGRATION_033_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_033 = PASS**

> **ZERO_REAL_SEED = PASS**

> **NORMATIVE_ISOLATION = PASS**

> **TOPI_N2_DCBTI_REAL_MATERIALIZATION = NOT_AUTHORIZED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP119 foi confirmado:

- branch `main`;
- HEAD inicial `940cf742991a41bdc9a2cda7d76d2b5588413afd`;
- CP119 vigente;
- nenhum avanço concorrente;
- frozen opportunity-set schema decision = PASS_WITH_ARCHITECTURAL_DECISIONS;
- migration 033 parcial e autorizada a retomar em modo médio.

## 3. Implementação final

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

## 4. Contrato físico implementado

Root objects:

1. temporal_observation_plan;
2. temporal_observation_source;
3. temporal_observation_epoch;
4. temporal_observation_epoch_source;
5. temporal_observation_authority;
6. temporal_measurement_opportunity;
7. temporal_measurement_event;
8. temporal_measurement_opportunity_resolution;
9. temporal_measurement_item;
10. temporal_measurement_item_timepoint;
11. temporal_measurement_event_artifact;
12. temporal_observation_deviation.

## 5. Frozen opportunity set

Decisão implementada:

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = measurement_schedule_payload**

O Artifact de schedule:

> **PROVENANCE_ONLY**

O banco valida:

- payload estrito;
- finite-only;
- non-normative;
- opportunity numbers contíguos;
- timestamps explícitos;
- ausência de recurrence;
- ausência de semantics normativas;
- equality exata payload↔Opportunity rows.

## 6. Lifecycle

### draft
- EpochSource;
- canonical payload;
- Opportunity rows;
- authority.

### authorized_non_normative
Exige:
- target current;
- Artifacts ativos;
- included source;
- runtime prerequisite quando aplicável;
- exact opportunity-set materialization;
- current operational authority approved;
- authority freshness em relação ao design freeze.

### active
- started_at;
- authority/target continuam válidos.

### completed
- review boundary alcançado;
- all opportunities resolved;
- no material/invalidating deviation;
- target current.

## 7. Retry / resolution / items

Separado fisicamente:

- Opportunity = planned act;
- MeasurementEvent = attempted execution;
- OpportunityResolution = closure;
- MeasurementItem = observed source record;
- MeasurementItemTimepoint = source temporal endpoint.

Ausência de execução não é fake event.

Latency é derivada.

## 8. Source debt

Readiness evidence expõe:

- epoch_execution_completed;
- candidate_source_debt_present.

Não cria `coverage_complete`.

BVS/LILACS deferred não desaparece em razão de eventual completion.

## 9. Synthetic tests

Fixtures:

> **SYNTHETIC_TEST_ONLY**

Usam target sintético do Evidence Monitor.

Não usam:

- ProductVersion N2 real;
- TOPI-N2 real;
- authority real;
- source observations reais;
- schedule real.

## 10. Iterações de implementação

Runs 205–213 foram iterações de coding/test harness e não são evidência final promovida.

Problemas corrigidos incluíram:

- corrupção/truncagem textual de guard;
- PL/pgSQL rowtype/scalar SELECT INTO;
- replay JOIN ambiguity;
- falso positivo de normative FK isolation;
- falso positivo de SLA substring;
- CadenceObservation PK nominal;
- falso positivo de UpdateSignal isolation.

Nenhum desses fixes mudou a arquitetura aprovada.

## 11. CI canônica promovida

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37802083791**

Run number:

> **214**

Head validado:

> **6b9efb3a2439aa700fe8b38334995cf008327fb5**

Conclusão:

> **success**

Início:

`2026-10-08T15:35:58Z`

Conclusão:

`2026-10-08T15:36:48Z`

## 12. Resultado técnico

Run 214:

- install 033 = PASS;
- zero-seed smoke = PASS;
- TNO-T01–T100 = PASS;
- 033 idempotent reapply = PASS;
- rebuild-from-zero through 033 = PASS;
- Final S5 status = PASS;
- prior F2-B/S4/S5/F3/F4 regressions = PASS.

## 13. Evidence artifact

Artifact ID:

`11560209688`

Name:

`oes-s5-evidence-37802083791`

Size:

`256002 bytes`

Digest:

`sha256:fc2909171dfa16f94cccae8cc5bd739b11c6091c4b04bb3ad78136af4ecd0c6b`

Head:

`6b9efb3a2439aa700fe8b38334995cf008327fb5`

## 14. Documento 68

Arquivo:

`docs/governance/68-resultado-tecnico-migration-033-observacao-temporal-nao-normativa.md`

Commit:

`6086f543a7ddeee69c565b4cfc3068f746117972`

STATE:

`d04db50dbf44749a98d9c726f4f7431616944ade`

CHANGELOG:

`22a3f5c695846ceb05cd80376ce6f0714714f79f`

## 15. Boundary preservado

O technical PASS não autoriza:

- real TOPI-N2 materialization;
- real sources/authority/epoch/opportunities/events;
- numeric measurement schedule;
- Phase B;
- source polling;
- Calibration Dossier;
- UpdatePolicy;
- CadenceContract;
- scheduler/notifications;
- normative temporal values;
- M3.

## 16. Próximo passo exato

Após pausa:

> **em modo alto, definir o finite non-normative experimental opportunity set da Phase B da TOPI-N2-DCBTI-01.**

A decisão deve fechar antes de qualquer materialização real:

1. source-specific experimental design para PubMed;
2. source-specific experimental design para ClinicalTrials.gov;
3. número de opportunities;
4. concrete timestamps;
5. observation window;
6. review boundary;
7. rationale de information gain;
8. operational burden;
9. runtime connectivity precondition;
10. target-specific recheck;
11. novo explicit Phase B authority package.

BVS/LILACS permanece deferred source debt.

## 17. Disciplina de modo

> **Modo alto é recomendado novamente.**

O próximo bloco escolhe valores temporais experimentais que podem introduzir anchoring se forem definidos sem justificativa.

## 18. Regra de parada

Após ativação do CP120:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 19. HEAD antes da criação do CP120

`22a3f5c695846ceb05cd80376ce6f0714714f79f`

**Fim do CP120**
