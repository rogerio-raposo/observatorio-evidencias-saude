# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Contrato Físico de Propagation/Re-baselining

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP101  
**Checkpoint anterior:** CP100  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação e gate físico do contrato de propagation/re-baselining, sem implementação da migration 031

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_PRB_T01_T145 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_031 = AUTHORIZED_IN_STRICT_SCOPE**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada.  
A Fase 5 não foi iniciada.

## 2. Freshness Gate de abertura

A retomada começou a partir do CP100.

Confirmado:

- HEAD inicial: `906ba78c7c72d9bc51c2cf2a49772cffab6197c3`;
- checkpoint vigente: CP100;
- STATE/CHANGELOG coerentes;
- nenhum commit posterior ao CP100;
- nenhuma divergência material;
- nenhum avanço concorrente.

Última validação técnica canônica herdada:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37618433929** (#161);
- technical HEAD: `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- conclusion: **success**;
- artifact: **11480858194**;
- digest: `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`.

Nenhuma mudança técnica de banco/workflow foi feita neste bloco; não existe nova run canônica para este marco documental.

## 3. Documento 35

Criado:

`docs/governance/35-contrato-fisico-propagacao-rebaselining.md`

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS — aprovado após Documento 36**

Contrato físico candidato inclui:

- PropagationAssessment;
- PropagationCandidate;
- PropagationPath;
- PropagationPathStep;
- adapter PropagationCandidate → UpdateSignalSource;
- RebaselineDecision;
- RebaselineVersionChainStep;
- policy handover;
- Monitor handover;
- risk-profile handover;
- coverage handover;
- SLA Rule/Instance handover;
- open-signal disposition;
- workflow handover;
- contract epoch;
- issue/readiness helpers.

## 4. Documento 36

Criado:

`docs/governance/36-gate-fisico-propagacao-rebaselining.md`

Primeira passagem:

> **REVISE**

Recheck final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 5. Correções físicas relevantes

O gate corrigiu:

1. target classification ampla demais;
2. teto arbitrário de traversal depth;
3. no_action sem path completeness;
4. version chain apenas em JSON;
5. lifecycle incompleto do RebaselineDecision;
6. ausência de uniqueness para authoritative activation;
7. policy handover sem lifecycle readiness;
8. profile readiness tratada como universal;
9. coverage cutoff insuficientemente fechado;
10. invalidação indevida de UpdateSignal por target supersession;
11. adapter de UpdateSignalSource incompleto;
12. grandfathering sem epoch físico;
13. causal basis sem igualdade forte;
14. SLA cross-policy sem guard explícito;
15. child set semantics pouco explícitas.

## 6. Target classification final

Domínio físico:

- `maintainable_product`;
- `maintainable_investigation`;
- `nonmaintainable_version`.

Maintainable product exclui:

- evidence_monitor;
- evidence_alert.

Maintainable investigation exclui:

- evidence_monitoring.

Monitor/Alert não são target primário de RebaselineDecision.

## 7. Propagation

Authoritative no_action exige:

- lineage validado contra relações canônicas;
- path completo;
- ausência de cycle/depth/divergence unresolved;
- rationale;
- authority compatível.

Multiple paths:

- um candidate por assessment + impacted version;
- paths 1:N;
- steps normalizados e imutáveis.

## 8. Rebaseline chain

A cadeia old→new deixa de depender de JSON como fonte primária.

Nova estrutura obrigatória:

> `maintenance.rebaseline_version_chain_step`

com FKs reais para cada from/to version.

Activation exige cadeia recomputável via `core.entity_version.supersedes_version_uuid`.

## 9. Rebaseline lifecycle

Stages:

- planned;
- activated;
- cancelled_invalidated.

Supersession preserva exact old/new target pair.

Mudança de new target:

> nova decisão causal.

Unique partial guard:

> no máximo uma authoritative activated active por old target.

## 10. Policy/Monitor

Cross-target policy lineage:

> separada de `supersedes_update_policy_uuid`.

Para replace_with_new_policy em activation:

- new policy ativa;
- target = new target.

M2/M3:

- novo Monitor ProductVersion;
- Monitor current;
- Monitor target = new target;
- monitor_state active;
- new policy aponta para esse Monitor.

M3 continua formalmente bloqueado.

## 11. Risk profile

Profile não é requisito universal de activation.

Disposition final:

- target_profile_available;
- carry_forward_authorized;
- new_assessment_required;
- target_reassessment_required;
- not_applicable;
- pending.

Nova PriorityAssessment continua obrigatoriamente usando physical UpdateRiskProfile conforme migration 030.

## 12. Signal lifecycle

Removido:

> invalidar UpdateSignal apenas porque target foi superseded.

Disposition final inclui:

- retain_historical_no_transfer;
- resolve_on_old_target;
- continue_old_target_workflow;
- create_new_signal_on_new_target;
- governance_review_required.

UpdateSignal status só muda para invalidated quando o signal em si for inválido.

## 13. Propagation → UpdateSignalSource

Migration 031 deverá atualizar atomicamente:

- source_type domain;
- propagation_candidate_uuid;
- locator XOR;
- consistency trigger;
- update_signal_issues;
- locator counts;
- testes/idempotência.

Nenhum generic signal_type propagation será criado.

## 14. Grandfathering

Nova metadata técnica candidata:

> `maintenance.contract_epoch`

Uso:

- distinguir obrigação prospectiva de legacy absence.

Proibido usar epoch como:

- evidence cutoff;
- cadence anchor;
- SLA start;
- publication timestamp;
- scientific event time;
- rebaseline decision time.

Sem backfill fabricado.

## 15. SLA

SLARule:

- old rule = old policy;
- new rule = new policy;
- cross-policy não usa `supersedes_sla_rule_uuid`;
- mesma rule_code pode documentar continuidade;
- nenhum duration/deadline é copiado automaticamente.

SLAInstance:

- disposition não cria transição nova;
- existing execution lifecycle permanece soberano;
- causal/snapshot fields permanecem imutáveis;
- first breach permanece imutável;
- new obligation = nova instance, não cross-signal rebase.

## 16. Transition basis

Guards fechados:

- update_decision basis pertence ao old target;
- workflow basis target = old target;
- result basis = new target;
- propagation candidate basis impacted_version = old target + disposition rebaseline_required;
- governance/other exige artifact/payload+rationale.

## 17. F4-PRB test plan

Plano mínimo aprovado:

> **F4-PRB-T01–T145**

Cobertura inclui:

- assessment;
- candidate;
- paths;
- UpdateSignalSource adapter;
- rebaseline header;
- policy/Monitor;
- profile/coverage;
- SLA;
- signal/workflow;
- currentness/assurance/M3;
- contract epoch;
- idempotência;
- rebuild;
- regressões globais.

## 18. Migration 031

Estado:

> **AUTHORIZED_IN_STRICT_SCOPE**

Arquivo previsto:

`database/031_propagation_rebaseline_contract.sql`

Fixtures previstas:

`database/f4-propagation-rebaseline-fixtures.sql`

Testes previstos:

`database/f4-propagation-rebaseline-tests.sql`

## 19. Escopo permitido

Migration 031 poderá implementar somente:

- contract_epoch;
- propagation structures;
- rebaseline structures;
- structured adapter;
- validators/guards;
- issue/readiness helpers;
- synthetic fixtures;
- F4-PRB suite;
- S5 integration.

## 20. Escopo proibido

Não implementar:

- numeric SLA calibration;
- real operational calendars;
- scheduler;
- notifications;
- auto-escalation;
- auto-propagation;
- auto-rebaseline;
- automatic UpdatePolicy/Monitor/UpdateSignal creation;
- automatic currentness write;
- assurance promotion;
- publication automation;
- fabricated human/expert review;
- historical fabricated backfill;
- M3 unblock.

## 21. Commits principais do bloco

- `3211abe387ce8bc10237fe4a9facbe830d69d546` — Specify propagation and rebaseline physical contract;
- `ff972b2b3d928751ca1cbe9fd48097d8fe7c016d` — Record propagation physical contract candidate in state;
- `c833d4e7a9ac985625e0b6f9766bccb3f803402b` — Log propagation physical contract candidate;
- `055f3f498c352e66a62d8a45a21ef7b858711139` — Adversarial physical gate propagation rebaseline contract;
- `85668b146f4ad29c7381e9629b1f39a75aa548ca` — Harden propagation physical contract after gate;
- `6497878ef38f1589a9b1ef74055596ad253d2abb` — Close causal guards in propagation physical contract;
- `3fa075f00d5de11b13fe5f3d93dedaa2e82e6841` — Pass physical gate for propagation rebaseline contract;
- `4941ef6987d6ba06b53f7781cb721d7b4983a5c5` — Finalize propagation physical contract after gate;
- `69a17d48b57dc7b75c7601a2dbe475c66bcea686` — Record propagation physical gate in state;
- `797c062d873253ba2dbfae348299d6cc96c01c81` — Log propagation physical gate.

## 22. Estado antes do CP101

HEAD imediatamente antes da criação deste checkpoint:

`797c062d873253ba2dbfae348299d6cc96c01c81`

Nenhum commit concorrente identificado durante o bloco.

## 23. Próximo passo exato

> **Implementar migration 031 + fixtures sintéticas + F4-PRB-T01–T145; integrar ao workflow S5; validar camada específica, idempotência, rebuild-through-031 e regressões completas antes de declarar PASS técnico.**

## 24. Disciplina de modo

A etapa arquitetural de alta complexidade terminou.

> **Modo médio é suficiente para a implementação mecânica já especificada.**

Se a implementação revelar nova decisão arquitetural, semântica ou de invariantes não coberta pelos Documentos 35–36:

> **parar antes de improvisar e recomendar retorno ao modo alto.**

## 25. Regra de parada

Após ativação do CP101:

> **parar e aguardar instrução explícita do usuário antes de iniciar migration 031.**

**Fim do CP101**
