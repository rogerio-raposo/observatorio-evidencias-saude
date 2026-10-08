# 65 — Blocker de Implementação da Migration 033: Reprodutibilidade do Frozen Opportunity Set

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **IMPLEMENTATION_BLOCKED_PENDING_HIGH_MODE_SCHEMA_DECISION**  
**Contexto:** implementação autorizada da migration 033 após CP117

## 1. Estado da implementação

Foram persistidos, sem seed real:

- `database/033_non_normative_temporal_observation.sql`;
- `database/033a_temporal_observation_core.sql`;
- `database/033b_temporal_measurement_core.sql`;
- `database/033c_temporal_observation_guards.sql`.

Commits:
- master: `55a779dcf5e05dc612b3966ecb13c4ae264f3317`;
- core: `03f4ca1596f8984e24bec6122d9696bebcd44bf1`;
- measurement core: `a6cfaa88f3126e0740d21448db7c48092f4f8019`;
- guards: `39d11f54f356079b5acb5c693a5378bcb790f96d`;
- authority resolver hardening: `5f6e2bf8936e8b26febba776a4703b7f369397c0`.

A migration ainda não está completa, integrada ao CI ou validada.

## 2. Blocker descoberto

O contrato aprovado exige que cada `EpochSource` use:

> **finite frozen opportunity set**

e que as rows de `TemporalMeasurementOpportunity` correspondam exatamente ao conjunto congelado de:

- `opportunity_no`;
- `planned_for`.

O desenho atual aponta para:

> `schedule_definition_artifact_uuid`

Porém `artifact.artifact` contém somente metadados do arquivo:

- storage_key;
- content_hash;
- mime_type;
- source_uri;
- status;
- etc.

Ele **não contém o conteúdo JSON do Artifact**.

Logo o PostgreSQL não consegue, por si só:

- ler a lista congelada de timestamps;
- comparar Opportunity rows com o Artifact;
- provar igualdade estrita do opportunity set no activation/completion guard.

## 3. Por que isso é material

Enfraquecer a validação para apenas:

- contar opportunities; ou
- confiar no locator externo

violaria o Documento 61/63 porque permitiria:

- timestamps divergentes do frozen design;
- opportunities extras ou omitidas;
- replay incompleto;
- alteração silenciosa do measurement design.

Logo:

> **COUNT_ONLY_VALIDATION = NOT_ACCEPTABLE**

## 4. Opções arquiteturais

### Opção A — snapshot estruturado no EpochSource

Adicionar ao `temporal_observation_epoch_source`:

> `opportunity_set_payload jsonb NOT NULL`

com schema estrito, por exemplo:

- schema_version;
- opportunities[];
  - opportunity_no;
  - planned_for;
- timezone/offset preservado;
- opportunity_count.

O Artifact permanece como provenance/hash/locator.

O banco valida Opportunity rows contra o payload estruturado.

Vantagens:
- queryable;
- deterministic;
- transactionally enforceable;
- não exige ampliar o subsistema genérico de Artifacts;
- não cria tabela nova.

Risco:
- DB payload e Artifact podem divergir externamente; deve ficar claro que o payload é o **snapshot físico canônico para enforcement**, enquanto o Artifact é provenance/evidence locator.

### Opção B — armazenar conteúdo estruturado no subsistema Artifact

Expandir o contrato genérico de Artifact para tornar payload consultável pelo banco.

Vantagens:
- uma fonte única de conteúdo.

Riscos:
- amplia significativamente o escopo da migration 033;
- altera contrato transversal de Artifact;
- pode afetar várias fases;
- exige gate próprio.

### Opção C — nova tabela filha de schedule opportunities

Criar tabela específica de frozen schedule design, separada das MeasurementOpportunity rows.

Vantagens:
- normalização forte.

Riscos:
- nova entidade física não prevista no contrato aprovado;
- duplica parcialmente Opportunity;
- aumenta lifecycle e joins;
- exige nova decisão arquitetural.

### Opção D — validação externa apenas

Manter Artifact como único snapshot e validar fora do banco/CI.

Risco:
- o banco aceitaria estado inconsistente;
- enfraquece constraint/replay guarantees.

> **NOT_RECOMMENDED**

## 5. Recomendação a avaliar em modo alto

A opção de menor expansão arquitetural é:

> **Opção A — opportunity_set_payload estruturado no EpochSource**

com as seguintes invariantes candidatas:

1. payload explicitamente `non_normative=true`;
2. apenas finite opportunity set;
3. timestamps concretos, sem recurrence rule;
4. opportunity_count consistente;
5. Opportunity rows devem corresponder exatamente ao payload;
6. payload imutável;
7. Artifact continua obrigatório como provenance;
8. nenhuma geração automática de opportunities;
9. nenhum scheduler;
10. nenhum significado de due/compliance.

Esta recomendação **não está aprovada neste documento**.

## 6. Boundary preservado enquanto bloqueado

Não continuar:

- 033d;
- 033e;
- fixtures;
- testes;
- workflow CI;
- schedule design;
- Phase B.

Não alterar ainda o schema para resolver o blocker.

## 7. Estado

> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = BLOCKED_PENDING_SCHEMA_DECISION**

> **FROZEN_OPPORTUNITY_SET_ENFORCEMENT = UNRESOLVED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **PHASE_5 = NOT_STARTED**

## 8. Próximo passo

> **Retornar a modo alto e decidir como o frozen opportunity set será fisicamente persistido e validado antes de continuar a migration 033.**

**Fim do Documento 65**
