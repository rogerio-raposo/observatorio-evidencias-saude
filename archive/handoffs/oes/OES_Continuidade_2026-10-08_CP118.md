# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Blocker da Migration 033 / Frozen Opportunity Set

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP118  
**Checkpoint anterior:** CP117  
**Status:** artefato de continuidade; não normativo  
**Escopo:** registrar implementação parcial da migration 033 e blocker material de schema descoberto antes de views/tests/CI

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = BLOCKED_PENDING_SCHEMA_DECISION**

> **FROZEN_OPPORTUNITY_SET_ENFORCEMENT = UNRESOLVED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP117 foi confirmado:

- branch `main`;
- HEAD inicial `2ec3c05a6edc6e7b95360fb25a5e792ffe7c4422`;
- CP117 vigente;
- migration 033 autorizada para implementation;
- boundary = infrastructure-only / synthetic-tests-only / zero-real-seed;
- measurement schedule não selecionado;
- Phase B não autorizada.

## 3. Implementação já persistida

### Master

`database/033_non_normative_temporal_observation.sql`

Commit:

`55a779dcf5e05dc612b3966ecb13c4ae264f3317`

### Core

`database/033a_temporal_observation_core.sql`

Commit:

`03f4ca1596f8984e24bec6122d9696bebcd44bf1`

### Measurement core

`database/033b_temporal_measurement_core.sql`

Commit:

`a6cfaa88f3126e0740d21448db7c48092f4f8019`

### Guards

`database/033c_temporal_observation_guards.sql`

Commits:

- initial guards: `39d11f54f356079b5acb5c693a5378bcb790f96d`;
- authority resolver hardening: `5f6e2bf8936e8b26febba776a4703b7f369397c0`.

## 4. O que já está implementado

Dentro do boundary aprovado:

- Plan/Source/Epoch/Authority;
- EpochSource;
- Opportunity;
- MeasurementEvent;
- OpportunityResolution;
- MeasurementItem;
- MeasurementItemTimepoint;
- EventArtifact;
- Deviation;
- recursive anti-normative JSON guard;
- schedule/source-semantics/effort validators;
- Artifact liveness helpers;
- Plan/Source/Authority/Epoch lifecycle guards;
- target-current guard;
- attempt/retry guard;
- Search scope guard;
- OpportunityResolution guard;
- item/timepoint consistency;
- deviation consistency.

Nenhum seed real foi criado.

## 5. Blocker descoberto

Contrato metodológico aprovado:

> cada EpochSource usa finite frozen opportunity set.

As Opportunity rows devem ser iguais ao conjunto congelado de:

- opportunity_no;
- planned_for.

O schema atual aponta para:

> `schedule_definition_artifact_uuid`

Porém:

`artifact.artifact` armazena apenas metadados/locator/hash e **não o conteúdo do Artifact**.

Consequência:

> PostgreSQL não consegue ler os timestamps congelados para comparar com as Opportunity rows.

## 6. Por que não foi contornado em modo médio

As alternativas de contorno mudam o contrato físico:

- adicionar payload estruturado;
- ampliar Artifact;
- criar nova tabela;
- enfraquecer enforcement.

Isso é nova decisão de schema/lifecycle e excede o boundary de implementação mecânica do CP117.

Logo a implementação foi interrompida antes de improvisar.

## 7. Documento 65

Arquivo:

`docs/governance/65-blocker-migration-033-frozen-opportunity-set.md`

Commit:

`4d2204f0b55711879f262761a0456908a9655a29`

Opções registradas:

### A — payload estruturado no EpochSource
Adicionar `opportunity_set_payload jsonb`.

### B — conteúdo consultável no Artifact
Expandir contrato transversal de Artifact.

### C — tabela filha de frozen schedule design
Nova estrutura específica.

### D — validação externa apenas
Não recomendada.

Recomendação candidata:

> **Opção A**

por ser a menor expansão arquitetural.

A recomendação ainda não foi aprovada.

## 8. Por que count-only não é suficiente

Validar apenas `opportunity_count` permitiria:

- timestamps divergentes;
- opportunity extra/omitida compensada por outra;
- replay incorreto;
- drift silencioso do measurement design.

Logo:

> **COUNT_ONLY_VALIDATION = NOT_ACCEPTABLE**

## 9. Arquivos ainda NÃO implementados

Não foram criados:

- `033d_temporal_observation_helpers_views.sql`;
- `033e_temporal_observation_issue_validators.sql`;
- `f4-temporal-observation-fixtures.sql`;
- `f4-temporal-observation-smoke-tests.sql`;
- `f4-temporal-observation-tests.sql`.

Também não houve alteração no:

- `.github/workflows/validate-s5.yml`.

## 10. CI

Migration 033 ainda:

- não foi instalada em CI;
- não foi executada em PostgreSQL;
- não passou smoke;
- não passou TNO-T01–T90;
- não passou idempotency;
- não passou rebuild;
- não passou regressions.

Logo:

> **MIGRATION_033 = NOT_PROMOTED**

## 11. Commits de estado

Documento 65:

`4d2204f0b55711879f262761a0456908a9655a29`

STATE:

`6b03f5d192af89e6526f5b205564f018daf06aa1`

CHANGELOG:

`5aade6d3a5478aa84e2b608e2099f9ef81bf83fa`

## 12. Próximo passo exato

Após a pausa:

> **mudar para modo alto e decidir como o frozen opportunity set será fisicamente persistido e validado.**

A decisão deve escolher/revisar uma das opções do Documento 65.

Somente depois:

1. ajustar 033a/033c;
2. implementar 033d/033e;
3. criar fixtures/tests;
4. integrar CI;
5. executar validação.

## 13. Disciplina de modo

> **Modo alto é necessário no próximo bloco.**

Após fechar essa decisão de schema, a implementação poderá retornar a modo médio.

## 14. Regra de parada

Após ativação do CP118:

> **parar e aguardar “Prossiga” explícito do usuário em modo alto.**

## 15. HEAD antes da criação do CP118

`5aade6d3a5478aa84e2b608e2099f9ef81bf83fa`

**Fim do CP118**
