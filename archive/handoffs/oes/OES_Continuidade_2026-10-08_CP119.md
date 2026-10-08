# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Frozen Opportunity Set Schema Decision

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP119  
**Checkpoint anterior:** CP118  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechar a decisão de schema que desbloqueia a migration 033 sem ampliar Artifact, criar tabela nova ou selecionar schedule real

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **SCHEMA_DECISION = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD**

> **SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_ONLY**

> **NEW_TABLE_REQUIRED = NO**

> **NEW_COLUMN_REQUIRED = NO**

> **OPPORTUNITY_MATERIALIZATION_STAGE = DRAFT**

> **AUTHORITY_FRESHNESS_GUARD = REQUIRED**

> **TEST_PLAN = TNO_T01_TO_T100**

> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = AUTHORIZED_TO_RESUME_AFTER_CHECKPOINT**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP118 foi confirmado:

- branch `main`;
- HEAD inicial `77d8ee6f597135403bd0f9b16d65dc1083f628f7`;
- CP118 vigente;
- nenhum avanço concorrente;
- migration 033 parcialmente implementada;
- 033 master/033a/033b/033c existentes;
- implementation blocker = frozen opportunity-set enforcement;
- measurement schedule real não selecionado;
- Phase B não autorizada.

## 3. Documento 66

Arquivo:

`docs/governance/66-decisao-schema-frozen-opportunity-set-migration-033.md`

Commit:

`8b6da35982d8b3e5d78115cbb07f78f064ab308a`

Decisão candidata:

> **usar o `measurement_schedule_payload` já existente como canonical structured snapshot do finite opportunity set.**

Não criar:

- nova coluna;
- nova tabela;
- conteúdo consultável no Artifact;
- scheduler.

## 4. Documento 67

Arquivo:

`docs/governance/67-recheck-decisao-schema-frozen-opportunity-set.md`

Commit:

`2e713b4d1c0bce700186c048e904edd48a3e81fa`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 5. Canonical payload

Schema lógico:

`oes.temporal_opportunity_set/0.1`

O payload persiste:

- `non_normative=true`;
- `schedule_kind=finite_opportunity_set`;
- rationale;
- array finito de:
  - opportunity_no;
  - planned_for.

Não persiste:

- recurrence;
- interval generator;
- next_due;
- cadence;
- grace;
- SLA;
- compliance.

## 6. Payload versus Opportunity rows

O payload é:

> **design snapshot canônico**

As Opportunity rows são:

> **projeção relacional causal do design.**

Obrigatório:

- mesmo número;
- mesmos opportunity numbers;
- mesmos instantes;
- nenhuma row extra;
- nenhum payload item ausente.

Helper obrigatório:

`maintenance.temporal_epoch_opportunity_set_matches_schedule(epoch_source_uuid)`

## 7. Artifact

`schedule_definition_artifact_uuid` passa a ter papel de:

- provenance;
- rationale;
- decision documentation;
- locator/hash externo.

Ele não controla a lista de timestamps.

Verificação adicional:

- não foi identificado guard genérico de imutabilidade material de `artifact.artifact`;
- isso não bloqueia esta decisão porque nenhum enforcement do frozen set depende do conteúdo externo do Artifact;
- controlling design facts permanecem no payload/rows da 033.

## 8. Lifecycle corrigido

### draft

Permitido:

- EpochSource;
- canonical payload;
- Opportunity rows;
- authority decision.

### authorization

`draft → authorized_non_normative` exige:

- target current;
- Artifacts controladores active;
- included EpochSources;
- runtime connectivity quando requerida;
- payload válido;
- payload↔rows exact equality;
- operational authority approved;
- authority freshness.

### active

`authorized_non_normative → active` exige:

- authority ainda approved;
- target current;
- no blocking issue;
- started_at.

Nenhuma nova Opportunity após draft.

## 9. Authority freshness

Design freeze:

> maior `created_at` entre Epoch, EpochSources e Opportunities.

Authority usada para authorization:

> `decided_at >= design_frozen_at`

Approval anterior à última materialização de Opportunity não satisfaz o gate.

## 10. Draft error handling

EpochSource e Opportunity continuam imutáveis.

Erro material no draft:

- invalidar Epoch;
- criar novo Epoch.

Não corrigir silenciosamente por UPDATE/DELETE.

## 11. Supersession documental

Documentos 66–67 supersedem apenas os trechos do contrato anterior referentes a:

- schedule payload shape;
- Artifact como frozen set controlador;
- stage de criação das Opportunity rows.

Documentos 61/63 permanecem válidos nos demais pontos.

Não houve rewrite retroativo.

## 12. Test plan

Test plan final desta migration:

> **TNO-T01–T100**

Novos testes T91–T100 cobrem:

- contiguidade;
- explicit offset/Z;
- extra row;
- missing row;
- timestamp mismatch;
- authority freshness;
- post-draft insert;
- Artifact provenance-only;
- payload immutability;
- invalidated draft preservation.

## 13. Migration parcial

Já existem:

- 033 master;
- 033a;
- 033b;
- 033c.

Eles permanecem:

> **PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

Antes de continuar, 033c precisa ser corrigido para o lifecycle/documentos 66–67.

Ainda faltam:

- 033d;
- 033e;
- fixtures;
- smoke;
- TNO-T01–T100;
- validate-s5 integration;
- CI.

## 14. Estado de STATE/CHANGELOG

STATE commit:

`4ee030ded7d81f5645eb72ed717d0d1d27d036fb`

CHANGELOG commit:

`b293ef5fb87faef3ad9b4ab9ca8abc6416e8c78b`

## 15. Próximo passo exato

Após a pausa:

> **retomar em modo médio a migration 033.**

Ordem:

1. corrigir 033c para canonical payload + draft materialization + authority freshness;
2. implementar 033d;
3. implementar 033e;
4. criar fixtures sintéticas;
5. implementar smoke + TNO-T01–T100;
6. integrar validate-s5;
7. executar CI;
8. promover somente se o conjunto técnico passar.

## 16. Disciplina de modo

> **Modo médio é novamente suficiente para a implementação mecânica.**

Voltar ao modo alto somente se surgir nova decisão de schema/lifecycle além do Documento 66/67.

## 17. Regra de parada

Após ativação do CP119:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 18. HEAD antes da criação do CP119

`b293ef5fb87faef3ad9b4ab9ca8abc6416e8c78b`

**Fim do CP119**
