# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Contrato Físico do UpdateRiskProfile

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP98  
**Checkpoint anterior:** CP97  
**Status:** artefato de continuidade; não normativo  
**Escopo:** arquitetura e gate físico do UpdateRiskProfile, sem implementation SQL

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_MIGRATION_030**

> **MIGRATION_030_SCOPE = UPDATE_RISK_PROFILE_NORMALIZATION_ONLY**

> **MIGRATION_030 = NOT_IMPLEMENTED**

> **RISK_SCORE = NOT_DEFINED**

> **NUMERIC_CADENCE = NOT_DEFINED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **AUTO_POLICY_CHANGE = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada. A Fase 5 não foi iniciada.

## 2. Freshness Gate de abertura

A retomada confirmou:

- HEAD inicial: `4a7ed356d70a2c6eb7c0327b4253d3571e940c0e`;
- checkpoint vigente: CP97;
- ponteiro/STATE/CHANGELOG coerentes;
- nenhum commit concorrente;
- migration 029 tecnicamente validada;
- próxima dívida ainda não selecionada.

## 3. Dívida selecionada

Foi escolhida:

> **materialização física do UpdateRiskProfile**

Motivo:

- PriorityAssessment/SLA ainda dependiam de `risk_profile_snapshot`;
- o Documento 27 já registrava isso como dívida explícita;
- profile físico é dependência estrutural mais anterior do que calibração normativa de SLA, scheduler, notifications, propagation/re-baselining ou M3 readiness.

## 4. Documento 30

Arquivo:

`docs/governance/30-contrato-fisico-update-risk-profile.md`

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 5. Estruturas candidatas autorizadas

Migration 030 poderá criar:

1. `maintenance.update_risk_profile`;
2. `maintenance.update_risk_profile_dimension`;
3. `maintenance.update_risk_profile_dimension_basis`;
4. `maintenance.update_risk_profile_trigger`;
5. `maintenance.update_policy_risk_profile_basis`.

Além disso poderá:

- adicionar `priority_assessment.update_risk_profile_uuid`;
- estender PriorityBasis com source_type=`risk_profile`;
- criar serializer/validators/guards/issues/readiness;
- atualizar fixtures/testes sintéticos.

## 6. Modelagem do profile

Profile é:

- por target ProductVersion ou InvestigationVersion;
- versionado;
- temporal;
- supersedível;
- history-preserving.

Não possui:

- CurrencyState;
- priority class;
- SLA duration;
- score.

## 7. Dimensões

Cada profile authoritative possui exatamente dez dimensões:

- A1 criticality;
- A2 evidence_volatility;
- A3 conclusion_sensitivity;
- A4 safety_integrity;
- A5 dependency_reach;
- B1 source_observability;
- B2 detection_latency;
- B3 surveillance_load;
- B4 incorporation_cost;
- B5 sustainable_capacity.

Não existe R0–R3 nem soma aditiva.

## 8. Authority

Profile header authoritative:

> human_reviewer ou human_expert.

AI/system:

> proposal apenas.

### A2/A3/A4

Authoritative:

- human_reviewer; ou
- human_expert.

### A1/A5/B1–B4

Authoritative:

- human_reviewer;
- human_expert;
- owner.

### B5

Authoritative:

> owner.

Importante:

> authority do owner ≠ scientific verification.

B5 owner declaration pode ser authoritative sem fabricar `owner` como verifier_actor_type.

## 9. Proposal incompleto

Proposal pode ser construído incrementalmente.

Entretanto:

> proposal incompleto não é serializer-eligible e não pode alimentar PriorityAssessment.

Para ser input de PriorityAssessment proposal:

- dez dimensões completas;
- valores válidos;
- outputs mínimos completos;
- serializer válido.

## 10. Provenance dimensional

Foi rejeitado basis JSON sem integridade.

Estrutura autorizada:

> `update_risk_profile_dimension_basis`

Com source_type/locator XOR e FKs reais para:

- MonitorCycle;
- CandidateAssessment;
- UpdateSignal;
- Evidence Alert ProductVersion;
- EntityVersion;
- Artifact;

ou external_reference explícita.

Não esconder UUID OES em JSON.

## 11. Reassessment trigger

`update_risk_profile_trigger` usa:

- trigger_code;
- source_type;
- locator XOR.

Triggers incluem:

- initial_baseline;
- new_scientific_version;
- use_context_change;
- policy_regulatory_change;
- evidence_pipeline_change;
- certainty_change;
- signal_frequency_change;
- capacity_change;
- source_observability_change;
- maintenance_level_change;
- dependency_graph_change;
- explicit_governance_request;
- other.

Reassessment trigger:

> não é UpdateSignal automaticamente.

## 12. Carry-forward

Carry-forward entre versões exige:

- mesmo tipo de target;
- mesmo `entity_uuid`;
- source profile authoritative;
- novo target version;
- effective_at não anterior ao source;
- dimensões explicitamente assessed ou carried_forward.

Carry-forward de dimensão:

- source profile explícito;
- mesmo value;
- rationale;
- aceitação humana adequada.

Nunca copiar profile silenciosamente.

## 13. Recomendação

Profile authoritative pode recomendar:

- M0;
- M1;
- M2;
- M3.

E cadence:

- none;
- event_driven;
- periodic;
- hybrid;
- continuous.

Compatibilidade:

- M0 → none;
- M1 → event_driven/periodic/hybrid;
- M2 → periodic/hybrid;
- M3 → continuous/hybrid.

Profile:

> recomenda.

UpdatePolicy:

> decide.

## 14. Regras de não compensação

- A4 high → event_driven required;
- A1 high → M0 proibido;
- A4 high → M0 proibido;
- B5 define teto de feasibility;
- B5 strained/insufficient/unavailable bloqueia recommendation M3;
- M3 recommendation exige B5 adequate + feasibility adequate.

Nenhuma regra cria currentness ou policy automaticamente.

## 15. Policy basis

`update_policy_risk_profile_basis`:

- possui UUID próprio;
- governing/supporting;
- record_status;
- supersession.

Governing profile:

- authoritative;
- target igual à policy;
- no máximo um governing ativo;
- não pode ser ligado retroativamente como se tivesse fundamentado policy anterior.

Policies históricas:

> não recebem governing link fabricado.

## 16. PriorityAssessment adoption

Migration futura:

- adiciona `update_risk_profile_uuid` nullable por compatibilidade;
- rows históricos permanecem snapshot-only;
- **novos INSERTs** após migration 030 exigem profile FK;
- authoritative scientific/mixed exige profile authoritative;
- proposal exige profile completo serializer-eligible;
- snapshot novo deve ser exatamente o serializer canônico.

Não backfillar profiles autoritativos a partir de snapshots antigos.

## 17. Serializer

Função candidata:

> `maintenance.update_risk_profile_snapshot(profile_uuid)`

Deve preservar shape compatível com:

> `maintenance.risk_profile_snapshot_is_valid()`

E incluir:

- profile UUID;
- effective_at;
- recommended maintenance/cadence;
- feasibility.

Profile incompleto:

> não serializa snapshot válido.

## 18. PriorityBasis

Migration 030 poderá adicionar:

- source_type=`risk_profile`;
- `update_risk_profile_uuid` FK.

Legacy source_type=snapshot:

> permanece válido para histórico.

## 19. SLA

Risk profile físico poderá ser input/snapshot de future SLA Rule/Instance.

Não:

- cria duração;
- recalcula instância;
- retroage profile novo;
- cria SLA Rule.

## 20. Documento 31

Arquivo:

`docs/governance/31-gate-adversarial-update-risk-profile.md`

Primeira passagem:

> **REVISE**

Blockers identificados:

1. provenance dimensional em JSON;
2. authority do profile composto;
3. trigger locators;
4. policy basis lifecycle;
5. snapshot adoption;
6. carry-forward details.

No recheck surgiu blocker adicional:

> proposal incompleto × serializer/PriorityAssessment.

Todos foram corrigidos.

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 21. Migration 030

Autorização:

> **READY_FOR_MIGRATION_030**

Escopo:

> **UPDATE_RISK_PROFILE_NORMALIZATION_ONLY**

Não pode:

- criar risk score;
- criar numeric cadence;
- criar numeric SLA;
- inserir SLA Rule normativa;
- alterar UpdatePolicy automaticamente;
- backfillar profiles autoritativos fabricados;
- backfillar policy governing links fabricados;
- alterar CurrencyState;
- promover assurance;
- criar UpdateSignal/Alert;
- criar scheduler;
- ativar auto-escalation;
- remover blocker M3.

## 22. Plano mínimo futuro

Implementação deverá cobrir:

> **F4-RP-T01–T87**

Além de:

- migration 030 idempotency;
- rebuild-through-030;
- F4-UP T/P;
- F4-OC-T01–T72;
- F2-B/S4/S5;
- F3 Products;
- Monitor;
- Alert;
- M3 blocker.

## 23. Estado técnico

Nenhuma migration 030 foi criada neste bloco.

Último PASS técnico continua:

- run **37580906483** (#150);
- technical HEAD `ae45918bb8cbf1ab929aec2e1af53f7239f75323`;
- artifact **11464672034**;
- through migration 029.

## 24. Estado do repositório antes do checkpoint

HEAD imediatamente antes da criação de CP98:

`a01420cd8100c4d3027e6c23a645c2940b1fb89a`

Mensagem:

`Log UpdateRiskProfile physical contract`

Após criação/ativação do CP98 haverá commits documentais adicionais.

## 25. Próximo passo

> **Implementar migration 030 no escopo autorizado.**

Obrigatório:

1. cinco estruturas do Documento 30;
2. serializer/validators/guards/issues;
3. integração PriorityAssessment/PriorityBasis;
4. fixtures sintéticas;
5. F4-RP-T01–T87;
6. S5;
7. idempotência;
8. rebuild;
9. regressões;
10. M3 blocker preservado.

Não declarar PASS antes de run canônico verde.

## 26. Disciplina de modo

A arquitetura está fechada.

> **Modo médio é seguro para implementação mecânica da migration 030 e testes.**

Se surgir nova decisão arquitetural difícil de reverter:

> parar antes de executar e recomendar modo alto.

## 27. Regra de visibilidade

Durante implementação:

- reportar em intervalos curtos;
- não deixar execução longa sem status visível;
- se a interface ocultar progresso, reconciliar GitHub antes de continuar.

## 28. Regra de parada

Após ativar CP98:

> **parar e aguardar instrução explícita do usuário.**

**Fim do CP98**
