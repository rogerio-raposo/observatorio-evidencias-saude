# 29 — Resultado da Validação Técnica do Controle Operacional Integrado da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS — migration 029 e contrato operacional integrado tecnicamente validados**  
**Dependências:** Documentos 27–28; migrations 027–029

---

## 1. Finalidade

Registrar o resultado técnico da implementação do contrato operacional integrado autorizado pelos Documentos 27–28.

---

## 2. Resultado executivo

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_029 = PASS**

> **F4_OC_T01_T72 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A migration 029 implementa somente infraestrutura operacional.

Ela não define:

- durações SLA normativas;
- priority score;
- pesos numéricos;
- auto-escalation;
- scheduler;
- notification channels;
- propagação científica automática;
- assurance promotion;
- publicação automática;
- M3 readiness.

---

## 3. Run canônico

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37580906483** (#150)

Technical HEAD:

`ae45918bb8cbf1ab929aec2e1af53f7239f75323`

Job:

`postgres-s5`

Conclusão:

> **success**

Artifact:

> **11464672034**

Nome:

`oes-s5-evidence-37580906483`

Digest:

`sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`

Expiração prevista:

`2026-11-06T06:20:33Z`

---

## 4. Migration 029

Arquivo:

`database/029_integrated_operational_control_contract.sql`

Estruturas implementadas:

1. `maintenance.update_triage`;
2. `maintenance.priority_assessment`;
3. `maintenance.priority_basis`;
4. `maintenance.escalation_case`;
5. `maintenance.escalation_reason`;
6. `maintenance.escalation_route`;
7. `maintenance.sla_calendar_version`;
8. `maintenance.sla_rule`;
9. `maintenance.sla_instance`;
10. `maintenance.sla_pause`;
11. `maintenance.workflow_round`;
12. `maintenance.workflow_milestone`.

Também foram implementados validators, guards, issue helpers e helpers derivados estritamente necessários ao contrato.

---

## 5. Triage

Validado:

- proposal × authoritative;
- uma triage autoritativa ativa por signal;
- AI/system não encerram autoritativamente signal científico como invalid/out_of_scope;
- duplicate exige linkage;
- routed_elsewhere exige destino;
- accepted_for_materiality habilita cadeia de materialidade/SLA;
- invalid_signal possui consistency guard deferred;
- supersession preserva signal.

---

## 6. Priority

Validado:

- uma PriorityAssessment ativa por signal;
- proposal de AI permitido;
- authoritative scientific/mixed exige humano qualificado;
- MaterialityAssessment AI-only não sustenta floor científico autoritativo;
- response class fechada;
- Alert não possui mapping automático;
- capacity não reduz floor;
- breach permanece operational pressure;
- PriorityBasis usa source_type/locator XOR;
- queue aggregation não substitui causalidade por signal/case.

---

## 7. Escalation

Validado:

- candidate pode ser criado por system;
- activation automática por system/AI é rejeitada;
- reasons/routes são obrigatórios quando aplicáveis;
- safety/validity/capacity exigem rotas coerentes;
- lifecycle possui transições controladas;
- resolução não altera CurrencyState.

Auto-escalation autoritativa continua:

> **NOT_AUTHORIZED**

---

## 8. SLA Calendar e SLA Rule

Validado:

- calendar version requerido para business calendar;
- payloads de calendar possuem validator;
- fixed deadline possui payload determinístico;
- fixed deadline é non-pausable por default;
- rule_code e selection_precedence são determinísticos;
- clock→endpoint matrix é fechada;
- time_basis matrix é fechada;
- não existem defaults normativos numéricos na migration.

Os intervalos presentes em fixtures são:

> **TEST-ONLY / NON-NORMATIVE**

---

## 9. SLA Instance

Validado:

- snapshot de rule é congelado;
- SLA-1 preserva upstream detection;
- pre-policy age não cria breach retroativo;
- SLA-2 exige triage accepted autoritativa;
- SLA-2 satisfied exige materiality human-qualified;
- proposal de UpdateDecision não encerra SLA-3;
- SLA-3 satisfied exige decision authoritative qualificada;
- SLA-4 exige WorkflowRound e milestone de start;
- SLA-5 exige start explícito;
- SLA-6 usa endpoint congelado;
- first_breached_at é imutável;
- breached_then_satisfied é preservado;
- priority posterior não recalcula due;
- pause posterior ao breach não apaga o breach;
- effective_due/current compliance são derivados.

---

## 10. Workflow

Validado:

- target XOR;
- result version não é auto-criada;
- start não é inferido de ticket/draft;
- scientific completion não equivale a review/publication;
- adapters estruturados preservam objetos existentes;
- revise pode abrir child review_revision round;
- publication milestone exige publicação real;
- method reroute não se converte silenciosamente em scientific update;
- causalidade do round é imutável;
- status do round não duplica milestones científicos/review/publication.

---

## 11. Suíte F4-OC

Arquivo:

`database/f4-operational-control-tests.sql`

Resultado SQL:

> **F4-OC-T01–T69 = PASS**

Evidências de workflow:

### T70 — idempotência da migration 029

> **PASS**

A migration 029 foi reaplicada e T01–T69 permaneceram verdes.

### T71 — rebuild-from-zero

> **PASS**

O rebuild foi executado through migration 029 com fixtures/testes do controle operacional.

### T72 — regressões

> **PASS**

Permaneceram verdes:

- F2-B;
- S4;
- S5;
- produtos F3;
- Evidence Monitor;
- Evidence Alert;
- F4 Update Protocol.

---

## 12. Compatibilidade com o contrato anterior

Após migration 029:

- F4-UP-T01–T63 = PASS;
- F4-UP-P01–P63 = PASS;
- migration 027 idempotency = PASS;
- migration 028 idempotency = PASS;
- migrations 021–026 idempotency = PASS.

A suíte P01–P58 foi endurecida para não depender de o antigo signal 3 permanecer sem MaterialityAssessment.

Isso foi correção de:

> **TEST ISOLATION**

e não mudança do contrato científico.

---

## 13. Runs de diagnóstico anteriores

### Run #145 — 37580322842

Falha por:

> alias PL/pgSQL/SQL ambíguo em validação de triage SLA.

Classificação:

> **IMPLEMENTATION ERROR**

Corrigido sem alteração arquitetural.

### Run #146 — 37580398825

Executada antes da correção do alias.

Classificação:

> **NON-CANONICAL FAILED RUN**

### Run #147 — 37580448414

Falha porque T62 criou MaterialityAssessment `potentially_material` sem MaterialityDimension exigida pelo contrato 027.

Classificação:

> **TEST SETUP ERROR**

### Run #148 — 37580616416

F4-OC passou, mas P60 revelou que P25 da suíte antiga dependia implicitamente do signal 3 ainda estar sem assessment.

Classificação:

> **TEST ISOLATION ERROR**

### Run #149 — 37580789193

Falha por erro textual de delimitador PostgreSQL introduzido ao isolar P25–P27.

Classificação:

> **TEST EDITING ERROR**

Nenhuma dessas runs é evidência de PASS.

A evidência canônica é exclusivamente:

> **run #150 — 37580906483**

---

## 14. M3

Foi reconfirmado:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

A readiness operacional da migration 029:

- não remove o blocker;
- não torna M3 formalmente operacional;
- não cria living evidence automaticamente.

---

## 15. Invariantes científicas preservadas

A migration 029 não:

- altera MaterialityAssessment automaticamente;
- altera UpdateDecision automaticamente;
- altera CurrencyState automaticamente;
- cria ProductVersion/InvestigationVersion;
- cria MethodDecision automaticamente;
- cria ReviewRecord humano automaticamente;
- promove assurance;
- publica;
- propaga ciência entre dependentes.

---

## 16. Decisão

> **MIGRATION_029 = TECHNICALLY_VALIDATED**

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **F4_OC_T01_T72 = PASS**

O bloco de implementação autorizado no CP96 está concluído.

---

## 17. Limites ainda abertos

A validação não resolve automaticamente:

- calibração normativa de durações SLA;
- criação de calendários operacionais reais;
- configuração de SLA Rules reais;
- materialização física de UpdateRiskProfile;
- scheduler;
- notification channels;
- auto-escalation;
- propagation/re-baselining;
- M3 readiness;
- operação humana real.

Esses itens exigem bloco próprio e autorização posterior.

---

## 18. Próximo passo

O próximo passo deverá ser determinado no checkpoint pós-PASS.

Nenhum bloco novo é iniciado neste documento.
