# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Contrato Operacional Integrado da Fase 4

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP96  
**Checkpoint anterior:** CP95  
**Status:** artefato de continuidade; não normativo  
**Escopo:** contrato lógico integrado de triage + priority/escalation + SLA + workflow, com migration 029 autorizada em escopo estrito e ainda não implementada

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING**

> **PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_MIGRATION_029**

> **MIGRATION_029_SCOPE = OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **NUMERIC_PRIORITY_WEIGHTS = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada. A Fase 5 não foi iniciada.

## 2. Freshness Gate de abertura

A retomada confirmou:

- HEAD inicial: `8bee2badc340a6a338f70252ed3d0c11c43353ff`;
- checkpoint vigente: CP95;
- ponteiro/STATE/CHANGELOG coerentes;
- nenhum commit concorrente;
- migration 029 inexistente;
- próximo passo correto: contrato lógico integrado, ainda sem migration.

## 3. Documento 27

Arquivo:

`docs/governance/27-contrato-dados-integrado-plano-operacional-fase-4.md`

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Contrato integra:

1. update_triage;
2. priority_assessment;
3. priority_basis;
4. escalation_case;
5. escalation_reason;
6. escalation_route;
7. sla_calendar_version;
8. sla_rule;
9. sla_instance;
10. sla_pause;
11. workflow_round;
12. workflow_milestone.

## 4. Âncora

Não foi criado OperationalPlan paralelo.

A âncora permanece:

> `maintenance.update_policy`

Isso evita duplicar target, regime M, versionamento e lifecycle.

## 5. Triage

Objeto:

> `maintenance.update_triage`

Dispositions:

- accepted_for_materiality;
- duplicate_or_already_covered;
- invalid_signal;
- out_of_scope;
- routed_elsewhere.

Authority:

- proposal;
- authoritative.

Proteções:

- invalid/out_of_scope authoritative exigem human_reviewer/human_expert;
- invalid_signal authoritative exige, no COMMIT, UpdateSignal invalidated;
- guard escolhido: constraint trigger `DEFERRABLE INITIALLY DEFERRED`;
- issue helper deve detectar drift.

## 6. PriorityAssessment

Objeto conceitual físico autorizado:

> `maintenance.priority_assessment`

Um vigente por UpdateSignal.

Response class:

- standard;
- expedited;
- urgent;
- immediate.

Authority scope:

- operational;
- scientific;
- mixed.

Authority status:

- proposal;
- authoritative.

Authoritative scientific/mixed:

- exige humano qualificado;
- não pode derivar floor científico autoritativo de MaterialityAssessment AI-only.

## 7. PriorityBasis

Objeto:

> `maintenance.priority_basis`

Sem score.

Effects:

- dominance_floor;
- strong_modifier;
- coordination_modifier;
- operational_pressure;
- feasibility;
- context.

Source integrity:

- source_type;
- locator XOR;
- snapshot_payload para fontes sem tabela física;
- UUID genérico sem FK proibido.

## 8. Risk-profile bridge

UpdateRiskProfile ainda não possui tabela física.

Bridge autorizado:

`risk_profile_snapshot` versionado com:

- schema_version;
- assessed_at;
- A1–A5;
- B1–B5;
- rationale/reference.

Validator futuro obrigatório.

Não criar pseudo-FK.

## 9. Escalation

Estruturas:

- escalation_case;
- escalation_reason;
- escalation_route.

Lifecycle:

- candidate;
- active;
- acknowledged;
- resolved;
- cancelled_invalidated.

Transições fechadas.

Baseline:

- candidate pode ser system/AI/humano;
- activation de active exige humano;
- auto-escalation autoritativa permanece não autorizada.

Reasons e routes preservam a taxonomia do Documento 25.

## 10. SLA Calendar

Objeto:

> `maintenance.sla_calendar_version`

Versionado.

Weekly schedule:

- weekday 1–7;
- intervals HH:MM-HH:MM;
- não sobrepostos;
- timezone explícito.

Exceptions:

- date;
- mode closed | custom;
- custom intervals;
- rationale opcional.

Migration futura deverá validar os payloads.

## 11. SLA Rule

Objeto:

> `maintenance.sla_rule`

Campos decisivos:

- rule_code;
- update_policy_uuid;
- clock_code;
- selection_precedence;
- filters;
- endpoint_type;
- time_basis;
- duração/deadline;
- calendar;
- pause/warning/breach/escalation policies;
- versioning.

Selection:

> menor `selection_precedence` casa primeiro.

Constraints:

- rule_code estável;
- precedência única por policy+clock;
- fallback explícito;
- precedência não é priority score.

## 12. Clock → endpoint matrix

Obrigatória:

- SLA1 → triage;
- SLA2 → materiality;
- SLA3 → update_decision;
- SLA4 → workflow_started;
- SLA5 → scientific_completed;
- SLA6 → review_disposition | publication.

Not applicable:

> estado da instância, não endpoint da rule.

## 13. Time basis

### elapsed_time

- target_duration > 0;
- sem calendar;
- sem fixed deadline payload.

### business_calendar

- target_duration > 0;
- calendar version obrigatória.

### fixed_deadline

- target_duration NULL;
- payload determinístico;
- deadline_at ou deadline_date, exatamente um;
- time_precision explícita;
- non-pausable por default.

Nenhum valor numérico default foi definido.

## 14. SLA Instance

Objeto:

> `maintenance.sla_instance`

Cardinalidade:

- SLA1–SLA3: uma obrigação vigente por UpdateSignal + clock;
- SLA4–SLA6: uma obrigação vigente por WorkflowRound + clock.

SLA4:

> exige WorkflowRound planned existente.

Persistir:

- rule snapshot;
- start;
- nominal_due;
- end facts;
- first_breached_at;
- satisfied/termination;
- rebase metadata.

Derivar:

- effective_due;
- wall_elapsed;
- accountable_elapsed;
- current compliance.

## 15. Rebase

Rebase:

- supersede a instância anterior;
- preserva obligation identity;
- exige reason/actor/timestamp;
- não apaga first breach;
- não troca target/round causal.

## 16. SLA Pause

Objeto:

> `maintenance.sla_pause`

Lifecycle limitado:

- open → closed.

Pode preencher uma vez:

- ended_at;
- closed_by;
- closed_at.

Demais campos materiais imutáveis.

Pause:

- exige autorização humana/owner compatível;
- não é backlog;
- não apaga breach;
- fixed deadline é non-pausable por default.

## 17. WorkflowRound

Objeto:

> `maintenance.workflow_round`

Types:

- scientific_update;
- methodological_reroute;
- review_revision;
- publication_remediation;
- other.

Status simplificado:

- planned;
- active;
- closed;
- terminated;
- cancelled_invalidated.

Não persistir:

- scientific_complete;
- in_review;
- publication_complete;

porque esses fatos pertencem aos milestones.

Review revision:

- parent round obrigatório;
- opened_by_workflow_milestone_uuid obrigatório para retrabalho originado por review.

Result:

- no máximo um primário ProductVersion/InvestigationVersion;
- nunca auto-criado.

## 18. WorkflowMilestone

Objeto:

> `maintenance.workflow_milestone`

Types:

- scientific_workflow_started;
- methodological_workflow_started;
- scientific_workflow_completed;
- review_disposition;
- publication;
- workflow_terminated.

Adapter types:

- native_event;
- product_review;
- assurance_record;
- method_decision;
- product_version;
- investigation_version;
- artifact.

Structured adapter:

> locator XOR + type/locator consistency.

## 19. Authority dos milestones

### workflow started

Authoritative native scientific start:

- human_reviewer/human_expert.

Owner pode registrar mobilização operacional, mas não substituir confirmação científica.

### scientific completion

Authoritative native event:

- human_reviewer/human_expert.

AI/system:

- proposal;
- ou adaptação de fonte estruturada qualificante;
- não inventa completion.

### review_disposition

Autoridade é herdada/validada do objeto adaptado.

### publication

Adapter de publicação já ocorrida; não publica.

## 20. Precisão temporal

Milestones distinguem:

- time_precision=timestamp + occurred_at;
- time_precision=date + occurred_date.

Não fabricar hora.

SLA com granularidade incompatível com precisão do endpoint:

> não aplicável sem fonte temporal melhor.

## 21. Adapter matrix

Review não é universal.

Baseline:

- Evidence Sheet pode usar product.review_record;
- Evidence Response/Scan podem usar ReviewRecord/AssuranceRecord conforme gate;
- Rapid Evidence Synthesis/Evidence Review/Evidence Map/Overview dependem de AssuranceRecord/controles especializados;
- MethodDecision somente em workflow metodológico;
- publication permanece subordinada ao publishability gate especializado.

WorkflowMilestone:

> normaliza evento, não substitui fonte/gate especializado.

## 22. Circularidade

### priority → SLA → priority

Permitida apenas temporalmente:

- priority inicial pode selecionar rule;
- SLA breach posterior pode informar nova priority;
- nova priority não recalcula instância antiga.

Guard:

> triggering SLA precisa anteceder assessed_at da nova PriorityAssessment.

### priority ↔ escalation

Pode haver reavaliação posterior, mas:

- não self-cycle no mesmo snapshot;
- não editar assessment antigo.

## 23. Currentness / Assurance / Publication

Novos objetos operacionais:

- não escrevem CurrencyState automaticamente;
- não promovem assurance;
- não criam human verification;
- não publicam.

Currentness continua:

> MaterialityAssessment → UpdateDecision → CurrencyState linkage.

## 24. Documento 28

Arquivo:

`docs/governance/28-gate-coerencia-fisica-plano-operacional-integrado.md`

Primeira passagem:

> **REVISE**

Foram identificados blockers de:

- rule ambiguity;
- due duplication;
- milestone adapter;
- workflow status duplication;
- lifecycle;
- circularidade;
- temporal precision;
- authority.

Após hardening do Documento 27:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 25. Migration 029

Autorização:

> **READY_FOR_MIGRATION_029**

Escopo:

> **OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**

Pode implementar as 12 estruturas + validators/guards/readiness/helpers estritamente necessários.

Não pode:

- inserir SLA rules numéricas normativas arbitrárias;
- criar score/pesos;
- ativar escalation automaticamente;
- criar scheduler;
- criar notification channels;
- mudar currentness automaticamente;
- criar assurance;
- publicar;
- propagar ciência;
- remover M3 blocker.

## 26. Dados seed

Migration 029 não deve inserir decisões operacionais substantivas.

Nenhuma duração/default de SLA é seed técnico.

## 27. Plano mínimo de testes

Implementação deverá espelhar Documento 27:

> **F4-OC-T01–T72**

Além de:

- migration 029 idempotency;
- rebuild-through-029;
- T01–T63/P01–P63 anteriores;
- F2-B/S4/S5;
- F3 Products;
- Monitor;
- Alert;
- M3 blocker.

## 28. Estado técnico

Não houve alteração técnica neste bloco.

Último PASS técnico permanece:

- run **37576434417** (#144);
- technical HEAD `3f36b5dd4103e15834adde107fedeeb1c81fb084`;
- artifact **11462802190**;
- digest `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- through migration 028.

Migration 029:

> autorizada, mas não implementada.

## 29. Estado do repositório antes do checkpoint

HEAD imediatamente antes da criação do CP96:

`938c1d42b3841e1d4d1980d32e1b732885657146`

Mensagem:

`Log integrated Phase 4 operational contract`

Após criação/ativação do CP96 haverá commits documentais adicionais.

## 30. Próximo passo exato

> **Implementar migration 029 no escopo autorizado.**

Obrigatório:

1. estruturas/constraints/guards do Documento 27;
2. F4-OC-T01–T72;
3. workflow S5;
4. migration 029 idempotency;
5. rebuild-through-029;
6. regressões completas;
7. M3 blocker preservado;
8. resultado técnico formal.

Não declarar PASS antes dessas evidências.

## 31. Disciplina de modo

A implementação será grande, mas a arquitetura está fechada.

> **Modo médio é seguro para a implementação mecânica da migration 029 e testes, desde que nenhuma decisão arquitetural nova surja.**

Se surgir decisão difícil de reverter:

> parar antes de executar e recomendar modo alto.

## 32. Regra de parada

Após ativação do CP96:

> **parar e aguardar instrução explícita do usuário antes de implementar migration 029.**

**Fim do CP96**
