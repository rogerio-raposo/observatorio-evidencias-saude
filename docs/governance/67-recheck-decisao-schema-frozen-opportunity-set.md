# 67 — Recheck Adversarial da Decisão de Schema do Frozen Opportunity Set

**Projeto:** Observatório de Evidências em Saúde — OES
**Fase:** 4 — Protocolo Transversal de Atualização
**Data:** 8 de outubro de 2026
**Status:** PASS_WITH_ARCHITECTURAL_DECISIONS
**Modo:** alto
**Objeto:** recheck do Documento 66

## 1. Resultado

SCHEMA_DECISION = PASS_WITH_ARCHITECTURAL_DECISIONS

FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD

SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_ONLY

NEW_TABLE_REQUIRED = NO

NEW_COLUMN_REQUIRED = NO

MIGRATION_033_IMPLEMENTATION = AUTHORIZED_TO_RESUME_AFTER_CHECKPOINT

MEASUREMENT_SCHEDULE = NOT_SELECTED

PHASE_B_EXECUTION = NOT_AUTHORIZED

## 2. Canonical-store attack

Ataque:

Manter payload e Opportunity rows poderia criar duas fontes de verdade.

Recheck:

- o payload é o design snapshot canônico;
- Opportunity rows são projeção relacional necessária para linkage causal;
- a igualdade payload↔rows é obrigatória;
- row extra falha no insert;
- item do payload sem row bloqueia authorization;
- EpochSource e Opportunity permanecem imutáveis.

Resultado:

PASS

Não há dual truth livre; existe canonical source + constrained projection.

## 3. Artifact-content attack

Verificação do repositório não encontrou guard de imutabilidade material específico para artifact.artifact.

Logo não se deve afirmar que o banco garante imutabilidade do conteúdo/hash do Artifact.

A decisão do Documento 66 evita depender dessa garantia:

- schedule payload controla o conjunto;
- Artifact é locator/provenance/rationale;
- activation continua exigindo Artifact active;
- issue functions podem expor status drift;
- nenhum timestamp ou opportunity é inferido a partir do conteúdo externo do Artifact.

Resultado:

PASS_WITH_EXPLICIT_LIMITATION

O contrato 033 não ampliará artifact.artifact neste bloco.

## 4. Payload-shape attack

O schema oes.temporal_opportunity_set/0.1 precisa ser estrito.

Requisitos confirmados:

- allowed root keys explícitas;
- opportunities array não vazio;
- item keys somente opportunity_no/planned_for;
- números positivos, únicos, contíguos desde 1;
- timestamps parseáveis;
- offset explícito ou Z obrigatório;
- instantes únicos;
- forbidden temporal keys recursivas;
- sem opportunity_count redundante;
- sem recurrence rule.

Resultado:

PASS

## 5. Timezone attack

Duas strings com offsets diferentes podem representar o mesmo instante.

Decisão:

- payload preserva a string original;
- Opportunity.planned_for persiste o instante normalizado;
- equality usa valor timestamptz;
- uniqueness de planned instant continua no relational layer;
- replay preserva offset original no payload.

Resultado:

PASS

## 6. Partial-materialization attack

Durante draft, o payload pode possuir quatro opportunities e apenas duas rows temporariamente.

Isso é permitido enquanto o design está sendo materializado.

Controles:

- opportunity insert deve corresponder ao payload;
- authorization exige igualdade completa;
- execution não pode iniciar em draft;
- nenhuma ausência parcial atravessa a boundary authorized_non_normative.

Resultado:

PASS

## 7. Lifecycle attack

O guard parcialmente implementado exigia Epoch active para inserir Opportunity.

Isso é incompatível com aprovação humana de um design congelado.

Decisão confirmada:

draft:
- EpochSource;
- canonical payload;
- Opportunity rows;
- authority decision.

draft -> authorized_non_normative:
- exact equality;
- current target;
- Artifact liveness;
- runtime prerequisites;
- current operational authority approved;
- authority freshness.

authorized_non_normative -> active:
- no design mutation;
- authority ainda approved;
- target current;
- started_at.

Resultado:

PASS_WITH_REQUIRED_SQL_PATCH

## 8. Authority-before-design attack

Uma approval poderia ser emitida antes da última Opportunity e ser reutilizada depois.

Controle:

design_frozen_at = maior created_at entre Epoch, EpochSources e Opportunities.

A controlling operational authority usada para authorization deve ter:

decided_at >= design_frozen_at.

Resultado:

PASS

Esse guard é obrigatório na 033c.

## 9. Same-timestamp attack

Em sistemas com timestamp de alta resolução, authority e último insert podem compartilhar o mesmo instante observável.

O contrato usa >=, não >.

Isso é aceitável porque:

- rows são transacionais e imutáveis;
- equality é verificada na transition;
- authority continua scoped ao exact Epoch;
- conflict resolver permanece ativo.

Resultado:

PASS

## 10. Draft-error attack

Opportunity incorreta não pode ser UPDATE/DELETE para “corrigir” silenciosamente.

Decisão:

- EpochSource/Opportunity são imutáveis;
- draft defeituoso é invalidado;
- novo Epoch é criado.

Resultado:

PASS

Custo operacional maior é aceito em troca de auditabilidade causal.

## 11. Artifact↔payload equality attack

Pergunta:

o banco deve provar que o Artifact humano contém os mesmos timestamps do payload?

Decisão:

NÃO.

Razões:

- Artifact não é controlling snapshot;
- artifact.artifact não armazena conteúdo consultável;
- impor igualdade reabriria o blocker;
- o payload já é a fonte física auditável e estruturada.

O Artifact documenta rationale/decision provenance, não a verdade relacional do schedule.

Resultado:

PASS

## 12. Scheduler-leakage attack

O payload contém apenas timestamps concretos.

Não contém:

- recurrence;
- interval generator;
- next due;
- overdue;
- grace;
- SLA;
- compliance.

O banco não gera opportunities.

Resultado:

PASS

## 13. Normative-laundering attack

Um finite opportunity set poderia ser interpretado como cadence.

Controles preservados:

- non_normative=true obrigatório;
- forbidden-key recursion;
- Opportunity não é CadenceObligation;
- ausência de overdue/breach/compliance;
- nenhuma ligação causal com 032;
- measurement schedule real continua NOT_SELECTED;
- synthetic timestamps são test-only.

Resultado:

PASS

## 14. Migration-scope attack

A resolução não requer:

- nova tabela;
- nova coluna;
- extensão PostgreSQL;
- alteração de Artifact;
- scheduler;
- source-specific hard-code.

Mudanças necessárias ficam restritas a:

- validator;
- lifecycle guards;
- equality helper;
- issue/test coverage.

Resultado:

PASS

Logo o boundary do Documento 64 continua válido.

## 15. SQL parcial atual

Os arquivos já persistidos 033a/033b/033c não são promovidos como válidos ainda.

Antes de continuar:

1. substituir o validator antigo de measurement_schedule_payload;
2. alterar Opportunity insert de active para draft;
3. validar membership payload↔row no insert;
4. implementar exact equality helper;
5. exigir equality na authorization transition;
6. implementar authority freshness;
7. manter activation separada de authorization;
8. adicionar TNO-T91–T100.

Até isso ocorrer:

MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED

## 16. Supersession documental

O Documento 66, confirmado por este recheck, supersede especificamente:

- Documento 61, seção 8, quanto ao shape do schedule payload;
- Documento 61, seção 38D, quanto ao papel do Artifact no schedule;
- Documento 63, seção 24, quanto à afirmação de que o Artifact é o frozen opportunity set controlador.

Os demais invariantes dos Documentos 61/63 permanecem válidos.

Não haverá rewrite retroativo desses documentos.

## 17. Test plan

O test plan passa a ser:

TNO-T01–T100

TNO-T91–T100 são controlling para este hardening.

A migration não pode ser promovida se esses testes não forem executados com sucesso.

## 18. Estado final

SCHEMA_DECISION = PASS_WITH_ARCHITECTURAL_DECISIONS

FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD

SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_ONLY

OPPORTUNITY_MATERIALIZATION_STAGE = DRAFT

AUTHORITY_FRESHNESS_GUARD = REQUIRED

TEST_PLAN = TNO_T01_TO_T100

MIGRATION_033_IMPLEMENTATION = AUTHORIZED_TO_RESUME_AFTER_CHECKPOINT

MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED

MEASUREMENT_SCHEDULE = NOT_SELECTED

PHASE_B_AUTHORITY = NOT_REQUESTED

PHASE_B_EXECUTION = NOT_AUTHORIZED

NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED

M3_FORMAL_OPERATIONALIZATION = BLOCKED

PHASE_5 = NOT_STARTED

## 19. Próximo passo

Após checkpoint:

retomar em modo médio a migration 033, primeiro corrigindo 033c conforme Documento 66/67; depois implementar 033d/033e, fixtures, TNO-T01–T100, validate-s5 integration e CI.

**Fim do Documento 67**
