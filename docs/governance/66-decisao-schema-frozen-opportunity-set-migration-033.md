# 66 — Decisão de Schema para Frozen Opportunity Set da Migration 033

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **ARCHITECTURAL_DECISION_CANDIDATE_FOR_RECHECK**  
**Modo:** alto  
**Dependências:** Documentos 61–65; CP118  
**Objeto:** resolver o blocker de persistência/enforcement do finite frozen opportunity set

## 1. Decisão

A Opção A do Documento 65 é adotada com uma revisão importante:

> **não criar uma nova coluna `opportunity_set_payload`.**

O campo já previsto:

> **`maintenance.temporal_observation_epoch_source.measurement_schedule_payload`**

passa a ser a **representação física canônica e consultável** do frozen opportunity set.

O Artifact:

> **`schedule_definition_artifact_uuid`**

permanece obrigatório, mas com papel de:

- provenance;
- rationale;
- documentação humana;
- locator/hash externo.

Ele **não é a fonte física controladora da lista de timestamps**.

Estado candidato:

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD**

> **SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_NOT_CONTROLLING_SNAPSHOT**

## 2. Por que esta solução é preferida

### Contra Opção B — ampliar Artifact

Rejeitada porque:

- alteraria contrato transversal de Artifact;
- ampliaria muito o escopo da migration 033;
- criaria impacto potencial em Fases 1–4;
- exigiria gate transversal próprio.

### Contra Opção C — tabela filha adicional de schedule design

Rejeitada porque:

- duplicaria estruturalmente as futuras Opportunity rows;
- acrescentaria nova entidade/lifecycle;
- não eliminaria a necessidade de sincronização entre design rows e execution rows.

### Contra Opção D — validação externa somente

Rejeitada porque:

- o banco aceitaria drift entre design e Opportunity rows;
- replay e auditability dependeriam de processo externo;
- violaria o contrato 61/63.

### Solução escolhida

O payload estruturado já existente:

- não adiciona nova tabela;
- não adiciona nova coluna;
- é queryable;
- é imutável porque EpochSource é imutável;
- pode ser validado no PostgreSQL;
- pode ser comparado transacionalmente com Opportunity rows.

## 3. Novo schema lógico do payload

Schema lógico:

> **`oes.temporal_opportunity_set/0.1`**

Shape:

```json
{
  "schema": "oes.temporal_opportunity_set/0.1",
  "non_normative": true,
  "schedule_kind": "finite_opportunity_set",
  "rationale": "...",
  "opportunities": [
    {
      "opportunity_no": 1,
      "planned_for": "2026-10-15T09:00:00-03:00"
    }
  ]
}
```

Campos opcionais permitidos no root:

- `timezone_name`;
- `note`.

Não existe:

- recurrence rule;
- interval generator;
- next_due;
- cadence;
- grace;
- SLA;
- compliance.

## 4. Invariantes do payload

O validator deve exigir:

1. root JSON object;
2. `schema = oes.temporal_opportunity_set/0.1`;
3. `non_normative = true`;
4. `schedule_kind = finite_opportunity_set`;
5. `rationale` não vazio;
6. `opportunities` array não vazio;
7. somente keys permitidas;
8. cada item contém apenas:
   - `opportunity_no`;
   - `planned_for`;
9. `opportunity_no` inteiro positivo;
10. números únicos;
11. números contíguos iniciando em 1;
12. `planned_for` parseável como `timestamptz`;
13. timestamp textual contém offset explícito ou `Z`;
14. planned instants únicos;
15. recursive forbidden temporal keys = false.

Não armazenar `opportunity_count`.

O count é:

> **`jsonb_array_length(opportunities)`**

evitando dual truth.

## 5. Relação payload ↔ Opportunity rows

O payload é:

> **design snapshot canônico**

As rows em:

> **`maintenance.temporal_measurement_opportunity`**

são:

> **materialização relacional do design para linkage causal com attempts/resolutions.**

Logo existem duas representações com papéis distintos:

- payload = design source;
- rows = constrained materialized projection.

Elas não podem divergir.

Helper obrigatório:

> **`maintenance.temporal_epoch_opportunity_set_matches_schedule(epoch_source_uuid)`**

deve provar igualdade estrita:

- mesmo número de rows;
- mesmo `opportunity_no`;
- mesmo instante `planned_for`;
- nenhuma row extra;
- nenhum item do payload ausente.

## 6. Timezone/offset

`planned_for` no payload preserva a representação textual original com offset.

A row relacional usa `timestamptz`.

Comparação física:

> comparar o instante após parse para `timestamptz`.

Replay:

- o instante normalizado vem da row;
- o offset textual original continua preservado no payload.

Não criar segundo campo de timezone por opportunity.

## 7. Papel do schedule_definition_artifact

O Artifact deixa de ser definido como lista controladora de timestamps.

Ele documenta:

- rationale;
- método que levou à seleção do conjunto;
- decision package;
- human-readable schedule definition;
- locator/provenance.

Ele pode reproduzir a lista por conveniência humana, mas:

> **o PostgreSQL não depende do conteúdo externo do Artifact para enforcement.**

Portanto não há obrigação física de provar igualdade Artifact↔payload.

O Artifact continua com:

- active-status requirement;
- content hash;
- locator;
- audit trail.

## 8. Lifecycle corrigido

O blocker revelou também uma inconsistência do guard já parcialmente implementado:

> Opportunity não pode ser criada somente após Epoch = active.

Isso impediria validar o design antes da autorização.

Lifecycle correto:

### 8.1 draft

Em `draft`:

- criar EpochSource;
- persistir canonical opportunity-set payload;
- materializar todas as Opportunity rows;
- validar igualdade payload↔rows;
- registrar authority decision sobre o design congelado.

### 8.2 draft → authorized_non_normative

Transição exige:

- target current;
- controlling Artifacts active;
- pelo menos uma included EpochSource;
- runtime connectivity verificada quando requerida;
- payload válido;
- payload↔Opportunity equality = true para cada EpochSource;
- operational execution authority = approved;
- authority approval posterior ou simultânea ao congelamento do design.

### 8.3 authorized_non_normative → active

Exige:

- authority ainda approved;
- target ainda current;
- Artifact liveness;
- nenhum material/invalidation issue;
- `started_at`.

Nenhuma nova Opportunity pode ser criada após sair de `draft`.

## 9. Authority freshness

Para impedir approval anterior a uma alteração de design:

a controlling operational authority usada na transição para `authorized_non_normative` deve satisfazer:

> **`decided_at >= design_frozen_at`**

onde:

> **`design_frozen_at = GREATEST(epoch.created_at, MAX(epoch_source.created_at), MAX(opportunity.created_at))`**

Como EpochSource e Opportunity são imutáveis:

> authority posterior ao freeze aprova exatamente aquele conjunto.

Se houver authority anterior ao último insert de Opportunity:

> não satisfaz authorization.

## 10. Opportunity insert guard revisado

Opportunity insert é permitido somente quando:

- parent Epoch = `draft`;
- target ainda current;
- `opportunity_no` existe no payload canônico;
- `planned_for` equivale ao timestamp daquele item;
- planned instant está entre start/review boundaries;
- row ainda não existe.

Logo:

> row extra fora do payload falha no INSERT.

Payload item ausente como row:

> é detectado na authorization guard.

## 11. Draft error handling

Opportunity/EpochSource permanecem imutáveis.

Se houver erro material após insert:

- não UPDATE/DELETE;
- invalidate Epoch;
- criar novo Epoch.

Isso preserva auditabilidade.

## 12. Activation versus authorization

Distinguir:

### authorization
Confirma que:

- design completo está congelado;
- authority humana aprovou o design;
- prerequisites estão presentes.

### activation
Marca início real da execução.

Logo:

> **schedule/opportunity equality deve ser satisfeita já em `authorized_non_normative`.**

Não esperar `active` para descobrir drift de design.

## 13. Epoch completion

Completion continua exigindo:

- `completed_at >= review_boundary_at`;
- target current;
- todas as Opportunities resolvidas;
- nenhum invalidating/material deviation;
- source debt explicitamente preservado.

Frozen payload não muda durante execução.

## 14. Measurement schedule continua não selecionado

Esta decisão define **como** um conjunto futuro será persistido.

Ela não define:

- número de opportunities;
- timestamps;
- intervalo;
- duração;
- PubMed schedule;
- ClinicalTrials.gov schedule.

Logo:

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

Synthetic fixtures poderão usar timestamps fictícios apenas para testes.

## 15. Impacto na migration 033 parcial

Ajustes autorizáveis se o recheck passar:

### 033a
Nenhuma nova tabela/coluna.

Manter:

- `measurement_schedule_payload jsonb NOT NULL`;
- `schedule_definition_artifact_uuid`.

### 033c
Revisar:

- schedule payload validator;
- Opportunity insert guard;
- epoch authorization guard;
- authority freshness;
- payload↔Opportunity equality helper/guard.

### 033d
Implementar helper de igualdade e replay/readiness conforme contrato.

### tests
Adicionar casos específicos de payload canonical/enforcement.

## 16. Test deltas

Além de TNO-T01–T90, explicitar:

- **TNO-T91** payload com opportunity numbers não contíguos é rejeitado;
- **TNO-T92** payload com timestamp sem offset/Z é rejeitado;
- **TNO-T93** Opportunity extra fora do payload é rejeitada no insert;
- **TNO-T94** payload item sem Opportunity row bloqueia authorization;
- **TNO-T95** Opportunity timestamp divergente do payload é rejeitado;
- **TNO-T96** authority anterior ao design freeze não autoriza Epoch;
- **TNO-T97** Opportunity insert após draft é rejeitado;
- **TNO-T98** Artifact permanece provenance-only; enforcement independe de conteúdo externo;
- **TNO-T99** payload imutável por EpochSource immutability;
- **TNO-T100** invalidated draft preserva Opportunity rows históricas.

## 17. Estado candidato

> **SCHEMA_DECISION = CANONICAL_STRUCTURED_PAYLOAD_IN_EXISTING_EPOCH_SOURCE_FIELD**

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD**

> **SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_ONLY**

> **NEW_TABLE_REQUIRED = NO**

> **NEW_COLUMN_REQUIRED = NO**

> **MIGRATION_033_IMPLEMENTATION = STILL_BLOCKED_PENDING_RECHECK**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

## 18. Próximo passo

> **Executar recheck adversarial específico desta decisão. Se PASS, atualizar o contrato 61 por supersession documental e autorizar retomada da implementação 033 em modo médio.**

**Fim do Documento 66**
