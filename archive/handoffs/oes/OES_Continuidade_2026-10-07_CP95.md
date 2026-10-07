# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Arquitetura Transversal de Prioridade e Escalation

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP95  
**Checkpoint anterior:** CP94  
**Status:** artefato de continuidade; não normativo  
**Escopo:** arquitetura transversal de prioridade e escalation, sem contrato físico novo

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING**

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT_DESIGN**

> **MIGRATION_029 = NOT_AUTHORIZED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **NUMERIC_PRIORITY_WEIGHTS = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada. A Fase 5 não foi iniciada.

## 2. Freshness Gate de abertura

A retomada confirmou:

- HEAD inicial: `31d434f8abba8f9732f07c28f632621221a0df26`;
- checkpoint vigente: CP94;
- ponteiro/STATE/CHANGELOG coerentes;
- nenhum commit concorrente posterior a CP94;
- nenhum bloco de prioridade/escalation iniciado antes da instrução explícita do usuário.

## 3. Documento 25

Arquivo:

`docs/governance/25-arquitetura-transversal-prioridade-escalation.md`

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Objeto:

- prioridade transversal por case/UpdateSignal/target version;
- response classes;
- dominance floors;
- relação com materiality/currentness;
- Alert;
- SLA/breach;
- dependency reach;
- capacity/feasibility;
- escalation reasons/routes/lifecycle/authority.

## 4. Response class

Domínio conceitual:

- `standard`;
- `expedited`;
- `urgent`;
- `immediate`.

Essas classes:

- são ordinais;
- não contêm duração;
- não são Alert reassessment_priority;
- não alteram materiality/currentness;
- não definem escalation route.

## 5. Priority × escalation

Decisão central:

> **priority e escalation são eixos independentes.**

Priority responde:

> qual necessidade relativa de resposta existe agora?

Escalation responde:

> qual rota adicional de autoridade/coordenação/intervenção precisa ser ativada?

A primeira versão do Documento 25 usou `immediate_governance`, o que misturava os eixos. O Documento 26 identificou o problema e o baseline foi corrigido para `immediate`.

## 6. Método de resolução

Não foi autorizado score aditivo.

Modelo:

> dominance rules + qualitative floors + explicit modifiers + auditable rationale.

Não usar:

`criticality + materiality + alert + breach - cost`

como score simples.

## 7. Floors consolidados

### safety/integrity qualificado

Quando houver ameaça de uso/validade qualificada:

- floor `urgent`;
- escalation assessment obrigatório.

### validity_or_use_threat

- floor `urgent`;
- escalation assessment obrigatório;
- uso autoritativo do outcome científico exige qualificação humana apropriada.

### suspend_current_use

- floor `immediate`;
- current-use/safety governance route obrigatória;
- não executa retirada/publicação/currentness automaticamente.

### material_change_confirmed + A1 high

- floor `urgent`.

### potentially_material + A1 high/A3 high

- floor `expedited`.

### outdated + A1 high

- floor `urgent`.

Não existem floors universais isolados para:

- `material_change_confirmed`;
- `update_recommended`.

Esses estados permanecem strong modifiers fora das combinações dominantes.

## 8. PriorityAssessment

Objeto conceitual future-ready, ainda não físico.

Deverá preservar:

- target version;
- UpdateSignal/case;
- stage;
- response_class;
- dominance basis;
- risk/materiality/currentness inputs;
- Alert/SLA/dependency inputs;
- feasibility;
- rationale;
- actor/verification;
- `authority_status = proposal | authoritative`;
- supersession/history.

AI/system:

- pode propor;
- não cria priority authoritative científica;
- não reduz floors dominantes.

## 9. Alert

Alert continua com:

- classification: informational | relevant | critical;
- reassessment_priority: routine | priority | urgent.

Não existe mapping automático:

> Alert urgent != transversal urgent

> Alert critical != transversal immediate

Critical/urgent Alert qualificado exige priority reassessment.

Downgrade transversal abaixo de expedited diante de Alert human-qualified forte exige rationale explícita.

## 10. SLA × priority

Anti-circularidade preservada:

- PriorityAssessment vigente pode informar SLA Rule selection;
- SLA Instance congela rule/snapshot;
- mudança posterior de priority não recalcula silenciosamente a instância;
- breach é operational pressure modifier;
- breach não cria materiality/currentness;
- repeated breach pode elevar prioridade operacional/escalation.

## 11. Capacity/feasibility

Regra:

> **capacity nunca reduz importance/priority.**

Caso:

> urgent + unavailable capacity

continua urgent e exige resource/capacity escalation.

Update cost também não reduz prioridade.

## 12. Dependency reach

A5 restricted/moderate/broad/systemic:

- não altera materiality sozinho;
- aumenta coordination/propagation-assessment pressure;
- confirmed material change + systemic reach exige dependency escalation assessment.

Nenhum dependente é modificado automaticamente.

## 13. Escalation

Motivos conceituais:

- safety_integrity;
- validity_or_use;
- scientific_materiality;
- current_use_control;
- methodological_reroute;
- operational_delay;
- capacity_constraint;
- dependency_coordination;
- regulatory_external;
- governance_exception.

Rotas conceituais:

- operational_owner;
- qualified_scientific_review;
- methodological_governance;
- current_use_governance;
- safety_integrity_governance;
- publication_governance;
- dependency_coordination;
- resource_governance.

Lifecycle:

- candidate;
- active;
- acknowledged;
- resolved;
- cancelled_invalidated.

Baseline:

> candidate pode ser automático; active exige autoridade humana compatível.

Auto-escalation permanece não autorizada.

## 14. Queue aggregation

Priority é por signal/case.

Uma fila futura pode derivar a maior necessidade relativa, mas:

- não substitui PriorityAssessments causais por registro agregado implícito;
- não deduplica apenas por target;
- qualquer agregação persistida futura precisa de linkage explícito aos casos componentes.

## 15. Target lifecycle

Supersession/invalidation:

- não é dominance gate;
- abre issue/reassessment/closure/carry-forward;
- não retarget silenciosamente.

## 16. Documento 26

Arquivo:

`docs/governance/26-revisao-adversarial-prioridade-escalation.md`

Primeira passagem:

> **REVISE**

Correções obrigatórias identificadas:

1. separar immediate de governance;
2. remover floors isolados não dominantes;
3. adicionar authority_status;
4. impedir AI-only materiality como floor authoritative;
5. mover target supersession/invalidation para lifecycle;
6. preservar causalidade na queue aggregation;
7. reforçar candidate automático ≠ escalation active.

Após correção:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 17. Referências metodológicas consideradas

Compatibilidade conceitual verificada com:

- Cochrane Handbook Chapter IV;
- Cochrane Handbook Chapter 22;
- Cochrane Interactive Learning Module 14, atualizado em 2026;
- NICE PMG49, 2025;
- WHO living-guidelines approach.

Nenhuma frequência, prazo, score ou categoria externa foi copiada como default OES.

## 18. Estado técnico

Não houve mudança em migrations, fixtures ou testes neste bloco.

Logo, a evidência técnica canônica continua:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37576434417** (#144);
- technical HEAD: `3f36b5dd4103e15834adde107fedeeb1c81fb084`;
- conclusion: **success**;
- artifact: **11462802190**;
- digest: `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- T01–T63 = PASS;
- P01–P63 = PASS;
- rebuild-through-028 = PASS;
- M3 blocker preservado.

## 19. Estado do repositório antes do checkpoint

HEAD imediatamente antes da criação de CP95:

`e328e5bdfc07cc428b0618b5e18b83ea5275b33c`

Mensagem:

`Log Phase 4 priority and escalation architecture`

Após criação/ativação do CP95 haverá commits documentais adicionais de continuidade.

## 20. Próximo passo exato

> **Definir o contrato de dados integrado do plano operacional da Fase 4, ainda sem migration.**

O contrato deverá cobrir conjuntamente, no mínimo:

1. transversal triage;
2. PriorityAssessment;
3. escalation candidate/case;
4. SLA Rule/version;
5. SLA Instance;
6. pause ledger;
7. workflow started/completed milestones;
8. review/publication endpoint adapters;
9. causal workflow/review round identity;
10. authority/snapshot/supersession;
11. issue helpers/readiness.

Motivo:

> priority/escalation isolados não devem ser persistidos sem as referências mínimas a triage/SLA/workflow que evitam estados órfãos ou circularidade.

Somente após esse contrato lógico:

> executar gate físico próprio para decidir se migration 029 pode ser autorizada.

## 21. Disciplina de modo

O próximo bloco continua arquitetural e difícil de reverter.

> **Modo alto é apropriado.**

## 22. Regra de parada

Após ativação deste checkpoint:

> **parar e aguardar instrução explícita do usuário antes de iniciar o contrato integrado.**

**Fim do CP95**
