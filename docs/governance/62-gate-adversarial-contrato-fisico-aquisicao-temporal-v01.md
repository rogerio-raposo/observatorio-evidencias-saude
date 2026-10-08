# 62 — Gate Adversarial do Contrato Físico v0.1 de Aquisição Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **FIRST_PASS = REVISE**  
**Modo:** alto  
**Objeto:** revisão adversarial do Documento 61  
**Migration:** não autorizada

## 1. Resultado

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REVISE**

> **PHYSICAL_SCHEMA = NOT_READY_FOR_IMPLEMENTATION**

> **MIGRATION_033 = NOT_AUTHORIZED**

A arquitetura geral é adequada, mas o contrato físico candidato ainda possui ambiguidades que podem comprometer replay e semântica causal.

## 2. TNO-G01 — colapso multi-item no TemporalMeasurementEvent

Ataque:

Uma execução PubMed retorna múltiplos PMIDs, cada um com CRDT/EDAT/publication date distintos.

O Documento 61 coloca `source_time_payload`, `oes_detected_at` e latency no event de execução.

Risco:

- uma única row não representa temporalidade por registro;
- distribuição de latency fica impossível;
- escolher um timestamp agregado fabricaria precisão;
- replay item-level dependeria de parsing de Artifact.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Adicionar child object:

> **maintenance.temporal_measurement_item**

Uma row por identificador/record observado que precise de análise temporal.

Mover para item:

- source identifier;
- item state;
- source locator;
- source-time payload;
- OES detected timestamp;
- latency status/bounds;
- optional SearchHit/Report linkage.

Event permanece execução/query-level.

## 3. TNO-G02 — result_count sem semântica inequívoca

Ataque:

`retrieved_identifier_count` pode significar:

- raw hits;
- IDs materializados;
- novos IDs;
- candidatos potencialmente elegíveis.

Risco:

> denominator laundering.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Separar:

- `raw_result_count` — quando a fonte fornece total confiável;
- `materialized_identifier_count`;
- `new_identifier_count`;
- `measurement_item_count` derivado.

Não usar `result_state` sem declarar a dimensão à qual ele se refere.

Preferir:

> `novelty_state = zero_new | new_items | unknown | not_applicable`.

## 4. TNO-G03 — failure evidence child-order paradox

Ataque:

Event `source_confirmed` exige child link com role `failure_evidence`, mas child row só pode ser inserida depois do event pai.

Risco:

- trigger impossível no INSERT comum;
- implementação dependeria de constraint trigger deferred sem ter sido especificado.

Resultado:

> **REVISE_REQUIRED**

Hardening preferido:

Adicionar ao event:

> `failure_evidence_artifact_uuid`

e manter junction table para artifacts suplementares.

`source_confirmed`/mixed exige direct failure evidence locator.

## 5. TNO-G04 — review boundary duplicado

Ataque:

Epoch possui `review_boundary_at`.

Schedule payload também contém `review_boundary_at`.

Risco:

> dual truth.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Remover review boundary do schedule payload.

Epoch é a única fonte canônica.

## 6. TNO-G05 — normative leakage aninhado em JSON

Ataque:

Validator proíbe chaves normativas apenas no nível esperado, mas `generation_payload` pode conter:

`{"settings":{"overdue":true}}`.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Criar helper recursivo:

> **maintenance.jsonb_contains_forbidden_temporal_keys(jsonb)**

Bloquear forbidden keys em qualquer profundidade.

## 7. TNO-G06 — hard-code de ClinicalTrials.gov no activation guard

Ataque:

Contrato reutilizável contém regra:

> CTG runtime connectivity must be verified.

Risco:

- contrato geral acoplado a uma source específica;
- próxima source exige migration apenas para novo guard.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Source definition deve conter:

- `access_mode`;
- `runtime_connectivity_required boolean`.

Activation guard exige verified conforme metadado da source, sem hard-code de marca.

## 8. TNO-G07 — source-time semantics hard-coded por marca

Ataque:

Validator codifica lista PubMed/CTG.

Risco:

- extensibilidade ruim;
- migration por source nova;
- source code vira lógica estrutural.

Resultado:

> **REVISE_REQUIRED**

Hardening:

`temporal_observation_source` deve possuir:

> `time_semantics_payload`

versionado/validado, declarando semantic codes permitidos.

Event/item validator verifica membership nessa definição.

## 9. TNO-G08 — retry lifecycle insuficientemente fechado

Ataque:

Após um `completed`, pode ser inserido attempt 3.

Após `not_executed`, pode ser inserido attempt posterior.

Attempt 1 e 3 podem existir sem 2.

Resultado:

> **REVISE_REQUIRED**

Hardening:

- attempt_no deve ser next contiguous integer;
- `completed` success fecha a opportunity;
- `not_executed` fecha a opportunity e deve ser único;
- retries permitidos somente após failed/partial/indeterminate;
- não permitir attempt novo após terminal resolution.

## 10. TNO-G09 — opportunity terminal semantics

Ataque:

`partial` é tratado ao mesmo tempo como terminal outcome e como condição retryable.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Separar:

- event execution status;
- opportunity resolution derivada.

Event `partial` não precisa fechar opportunity.

Opportunity resolution final:

- completed;
- failed_closed;
- not_executed;
- indeterminate_closed;
- unresolved;
- conflicted.

Closure deve ser derivada por explicit close event/decision ou regras inequívocas.

## 11. TNO-G10 — favorable stopping via "early-stop deviation"

Ataque:

Epoch completion pode ocorrer antes do review boundary se houver “early-stop reason permitido”, mas a lista e authority não estão definidas.

Risco:

- stopping oportunista.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Epoch não deve poder `completed` antes do review boundary.

Antes disso, apenas:

- invalidated;
- superseded por novo plan/epoch quando aplicável.

Se futuramente early completion for necessária, exige contrato/gate próprio.

## 12. TNO-G11 — target drift durante epoch ativo

Ataque:

Target deixa de current enquanto B1 está ativo.

Issue function detecta, mas o contrato não fecha o efeito operacional.

Resultado:

> **REVISE_REQUIRED**

Hardening:

- target-not-current torna epoch não-completable;
- nova measurement opportunity não pode ser criada;
- novos attempts devem ser bloqueados, exceto event de encerramento administrativo `not_executed` se necessário;
- epoch deve ser invalidado.

## 13. TNO-G12 — authority artifact liveness

Ataque:

Authority artifact é superseded/invalidated ou não é active.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Approval só conta quando decision Artifact está active no momento da activation.

Histórico permanece, mas issue deve bloquear caso controlling authority locator deixe de ser válido.

## 14. TNO-G13 — authority withdrawal concorrente

Ataque:

Withdrawal é inserido depois de approval.

Qual decisão governa?

Resultado:

> **REVISE_REQUIRED**

Hardening:

Definir resolver:

> **maintenance.temporal_observation_authority_state(epoch_uuid,domain,as_of)**

Ordenado causalmente por `decided_at`, com ambiguity/conflict detection.

Activation/execution exige current state = approved.

## 15. TNO-G14 — source scope versus epoch source snapshot

Ataque:

PlanSource é included, epoch_source criado, depois nova PlanVersion muda source scope.

Risco:

novo plan contaminar epoch antigo.

Resultado:

> **PASS_WITH_REQUIRED_GUARD**

Epoch sempre referencia source row da própria immutable PlanVersion.

Plan supersession não reparenta epoch/source.

## 16. TNO-G15 — scientific Search linkage insuficiente

Ataque:

ProductVersion pode ter múltiplas Investigations.

Dizer “Search deve pertencer à Investigation do exact target” é ambíguo.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Epoch deve congelar:

> `measurement_investigation_version_uuid`

quando scientific Search for permitido.

Esse exact Investigation deve:

- estar linked ao ProductVersion target quando target for ProductVersion; ou
- igual target quando target for InvestigationVersion.

Search validator usa esse UUID, não inferência dinâmica.

## 17. TNO-G16 — source query version não congelada suficientemente

Ataque:

`query_strategy_artifact_uuid` existe, mas manual/API parameters/runtime request shape podem mudar sem ficar explícitos.

Resultado:

> **REVISE_REQUIRED**

Hardening:

EpochSource deve congelar:

- query_strategy_artifact_uuid;
- interface code;
- interface/config artifact ou request-contract artifact;
- source semantics definition;
- runtime family/version quando material.

Mudança material exige novo epoch.

## 18. TNO-G17 — item novelty/baseline semantics ausentes

Ataque:

Um PMID reaparece em todos os checks.

Sem baseline/item state, ele pode ser contado como “new” repetidamente.

Resultado:

> **REVISE_REQUIRED**

Hardening:

MeasurementItem deve ter:

- `item_state = new_to_epoch | reobserved | updated_record | indeterminate`;
- normalized source identifier;
- uniqueness/reobservation rules;
- baseline snapshot/locator do epoch.

“new” significa novo em relação ao baseline/previous observations do epoch, não “novo na ciência”.

## 19. TNO-G18 — zero_new versus zero_raw

Ataque:

Uma query pode retornar 20 records, mas zero são novos.

`result_state='zero'` seria ambíguo.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Substituir result_state por novelty state:

- zero_new;
- new_items;
- unknown;
- not_applicable.

Raw count permanece separado.

## 20. TNO-G19 — latency com múltiplos endpoints

Ataque:

Um item pode suportar CRDT e EDAT simultaneamente; uma única `source_time_payload` perde dimensões.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Adicionar child:

> **maintenance.temporal_measurement_item_timepoint**

Uma row por semantic endpoint.

E latency derivada não precisa ser persistida como verdade principal.

Preferência:

- persistir endpoints;
- derivar bounds por função/view versionada.

Só persistir latency snapshot se necessário, com calculator version.

## 21. TNO-G20 — derived latency dual truth

Ataque:

Persistir source endpoint + `latency_bounds_payload` calculado permite divergência.

Resultado:

> **REVISE_REQUIRED**

Hardening:

No v0.1:

> **não persistir latency calculada como campo material.**

Derivar em view/function a partir de timepoints + OES detected_at.

Quando não derivável:

> LATENCY_NOT_OBSERVABLE.

## 22. TNO-G21 — OES detection timestamp

Ataque:

`oes_detected_at` no event é execution-level, mas cada item pode ser parsed/recognized em momentos diferentes.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Mover `oes_detected_at` para MeasurementItem.

Event mantém execution start/end.

## 23. TNO-G22 — effort payload sem schema recursivo

Ataque:

JSON livre pode virar storage de rating B5 ou dados sensíveis.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Validator estrito com allowed keys e primitive types.

Sem nested arbitrary JSON.

## 24. TNO-G23 — deviation scope

Ataque:

Deviation pode apontar simultaneamente opportunity e event incompatíveis ou nenhum contexto suficiente.

Resultado:

> **REVISE_REQUIRED**

Hardening:

- epoch obrigatório;
- event, quando presente, determina opportunity/epoch;
- opportunity, quando presente, deve pertencer ao epoch;
- cross-reference inconsistency bloqueada;
- material deviation nunca “resolvida” por update da row.

## 25. TNO-G24 — epoch completion e deferred source debt

Ataque:

BVS deferred é exposto em readiness view, mas epoch B1 pode ser chamado genericamente “completed”.

Isso pode ser interpretado como source universe completo.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Distinguir:

> **epoch execution completed**

de:

> **source universe complete**

Readiness view deve expor:

- `execution_completed=true/false`;
- `candidate_source_debt_present=true/false`.

Nunca produzir `coverage_complete` global no v0.1.

## 26. TNO-G25 — plan readiness scope livre

Ataque:

`readiness_scope text` aceita valores arbitrários.

Resultado:

> **REVISE_REQUIRED**

Hardening:

v0.1 deve restringir:

- `policy_aggregate`;
- `source_specific`.

TOPI-N2 usa `policy_aggregate`.

## 27. TNO-G26 — contract_epoch ambiguity

Ataque:

Documento 61 menciona registrar em `maintenance.contract_epoch` “se apropriado”.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Não usar `contract_epoch` no candidate v0.1 até verificar que ele não representa apenas normative temporal epoch.

A migration specification deve decidir explicitamente; nenhuma ambiguidade.

## 28. TNO-G27 — artifact deletion/status drift

Ataque:

Event/plan refere Artifact que depois deixa active.

Resultado:

> **REVISE_REQUIRED**

Hardening:

- creation/activation exige active Artifact;
- histórico não é apagado;
- issue functions expõem artifact status drift;
- não mutar causal rows retroativamente.

## 29. TNO-G28 — schedule generation reproducibility

Ataque:

Payload diz fixed_elapsed, mas opportunities são criadas manualmente com timestamps diferentes.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Criar validator/function:

> **maintenance.temporal_epoch_opportunity_set_matches_schedule(epoch_uuid)**

Quando schedule_kind for generator determinístico.

Para manual opportunity set:

- Artifact congelado deve listar opportunities;
- rows devem igual snapshot.

## 30. TNO-G29 — no schedule selecionado versus physical spec

Ataque:

Physical contract pode inadvertidamente escolher semântica de schedule ao definir generator.

Resultado:

> **PASS**

Definir shape não escolhe valor.

Manter:

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

## 31. TNO-G30 — migration scope creep

Ataque:

Migration 033 poderia incluir real TOPI plan/source/epoch rows “para testar”.

Resultado:

> **REVISE_REQUIRED**

Hardening:

Migration e fixtures separados.

Migration:
- schema/functions/views only.

Fixtures:
- synthetic only, explicit test schema/data, nunca real authority ou real Phase B execution.

Real TOPI materialization deve ser decisão posterior separada.

## 32. Test-plan gaps identificados

Adicionar testes para:

- multi-item temporal endpoints;
- raw count versus novelty count;
- item reobservation;
- source semantics registry;
- authority resolver conflicts;
- schedule/opportunity equality;
- retry terminal lock;
- target drift mid-epoch;
- epoch execution-complete versus source-debt distinction;
- artifact status drift;
- no real seed in migration;
- fixture isolation.

## 33. Síntese

A estrutura raiz permanece defensável:

- Plan;
- Source;
- Epoch;
- Authority;
- Opportunity;
- Event;
- Artifact linkage;
- Deviation.

Mas é necessário acrescentar:

- MeasurementItem;
- MeasurementItemTimepoint;

e endurecer:

- retry/closure;
- count semantics;
- source semantics;
- authority resolution;
- schedule snapshot;
- target drift;
- artifact liveness;
- physical migration boundary.

## 34. Estado

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REVISE**

> **PHYSICAL_SCHEMA = NOT_READY_FOR_IMPLEMENTATION**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MIGRATION_033 = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 35. Próximo passo

> **Hardenizar o Documento 61 incorporando TNO-G01–G30 e executar recheck físico final antes de qualquer decisão de migration.**

**Fim do Documento 62**
