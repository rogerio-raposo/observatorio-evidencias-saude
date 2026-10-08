# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Autorização da Migration 033

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP117  
**Checkpoint anterior:** CP116  
**Status:** artefato de continuidade; não normativo  
**Escopo:** autorização formal e boundary técnico da migration 033 antes de qualquer implementação SQL

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **MIGRATION_033 = AUTHORIZED_FOR_IMPLEMENTATION**

> **MIGRATION_BOUNDARY = INFRASTRUCTURE_ONLY_SYNTHETIC_TESTS_ONLY_ZERO_REAL_SEED**

> **PHYSICAL_SCHEMA = APPROVED_FOR_IMPLEMENTATION**

> **TEST_PLAN = APPROVED_FOR_IMPLEMENTATION**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP116 foi confirmado:

- branch `main`;
- HEAD inicial `dd706a38efa0b4b98939f4cd7c1208800644479b`;
- CP116 vigente;
- nenhum avanço concorrente;
- Documento 63 em PASS_WITH_ARCHITECTURAL_DECISIONS;
- migration 033 elegível, ainda não autorizada;
- measurement schedule não selecionado;
- Phase B não autorizada.

## 3. Documento de decisão

Arquivo:

`docs/governance/64-autorizacao-boundary-tecnico-migration-033.md`

Commit:

`9b8c0c7dbe10ca02e627cc60d1f612fb56958b7f`

Resultado:

> **MIGRATION_033 = AUTHORIZED_FOR_IMPLEMENTATION**

## 4. Justificativa

A migration foi autorizada porque a lacuna física foi demonstrada e o contrato físico v0.1 passou gate adversarial/recheck.

A infraestrutura é necessária para representar de forma estruturada e sem semantic laundering:

- Plan/Source/Epoch;
- planned opportunities;
- attempts/retries;
- OpportunityResolution;
- item-level observations;
- item-level timepoints;
- authority;
- source debt;
- deviations;
- replay/readiness evidence.

## 5. Decomposição técnica autorizada

Master:

`database/033_non_normative_temporal_observation.sql`

Fragments:

- `database/033a_temporal_observation_core.sql`;
- `database/033b_temporal_measurement_core.sql`;
- `database/033c_temporal_observation_guards.sql`;
- `database/033d_temporal_observation_helpers_views.sql`;
- `database/033e_temporal_observation_issue_validators.sql`.

O master seguirá o padrão 031/032:

- dependency 001–032;
- `BEGIN`;
- schema maintenance;
- `\ir` fragments;
- `COMMIT`.

## 6. Test files autorizados

- `database/f4-temporal-observation-fixtures.sql`;
- `database/f4-temporal-observation-smoke-tests.sql`;
- `database/f4-temporal-observation-tests.sql`.

Fixtures:

> **SYNTHETIC_TEST_ONLY**

Proibido usar:

- TOPI-N2 real;
- ProductVersion real `81000000-0000-0000-0000-000000000701`;
- owner authority real;
- real source observations;
- real measurement schedule.

## 7. CI

Workflow canônico:

> `.github/workflows/validate-s5.yml`

Não criar workflow paralelo.

Adicionar:

- path triggers;
- SHA256 evidence;
- install 033 após 032;
- smoke;
- synthetic fixtures/tests;
- idempotency;
- rebuild through 033;
- regressions;
- F4-TNO evidence logs.

## 8. No-seed guarantee

Migration/fragments não podem inserir rows reais ou sintéticas nas novas root tables.

Immediately-after-migration smoke deve provar root tables vazias antes de fixtures.

## 9. Normative isolation

A migration não pode:

- criar/alterar UpdatePolicy;
- criar CadenceContract/Obligation/Observation;
- criar SLARule/SLAInstance;
- criar MonitoringCycle;
- criar UpdateSignal;
- alterar CurrencyState;
- alterar assurance;
- criar scheduler/notification infrastructure;
- selecionar numeric schedule.

## 10. contract_epoch

Decisão:

> **maintenance.contract_epoch não será reutilizado.**

Nenhum marker normativo será criado para a 033.

## 11. Idempotência / rebuild

A migration deve ser idempotente.

Rollback operacional continua:

> **rebuild-from-zero**

Não criar down migration destrutiva.

Reapply deve preservar:

- object counts;
- row counts;
- zero-seed state;
- synthetic fixture state quando aplicável.

## 12. Boundary de implementação

Se durante coding surgir necessidade de:

- nova tabela não prevista;
- mudança de lifecycle;
- nova source-specific hard-code;
- scheduler/recurrence generator;
- normative linkage;
- real seed;
- mudança no significado de Opportunity/Event/Resolution/Item/Timepoint;

> **parar e voltar ao modo alto antes de prosseguir.**

## 13. Estado de STATE/CHANGELOG

STATE:

`7d0ffc3de9e62a76eb0f59dd3e8c9cd1538e0104`

CHANGELOG:

`4b3a4a7ce3a2de1de70b76df05b991e9d42ddf96`

## 14. Próximo passo exato

Após a pausa obrigatória:

> **implementar a migration 033 master + fragments, fixtures/smoke/full tests e integração no validate-s5.yml; executar CI e promover somente se o conjunto técnico passar.**

## 15. Disciplina de modo

> **Modo médio é suficiente para a implementação mecânica dentro do boundary aprovado.**

Voltar a modo alto se surgir nova decisão arquitetural/schema/lifecycle.

## 16. Regra de parada

Após ativação do CP117:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 17. HEAD antes da criação do CP117

`4b3a4a7ce3a2de1de70b76df05b991e9d42ddf96`

**Fim do CP117**
