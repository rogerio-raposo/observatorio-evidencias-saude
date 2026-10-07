# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Perfis de Risco e Política Temporal da Fase 4

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP91  
**Checkpoint anterior:** CP90  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Fase 4 — perfis de risco operacional/científico + cadence + thresholds temporais

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada.

## 2. Baseline física preservada

O primeiro contrato físico transversal continua validado:

- migration `027_transversal_update_protocol_contract.sql`;
- F4-UP-T01–T63 = PASS;
- F4-UP-IDEM = PASS;
- rebuild-through-027 = PASS;
- S5 run **37570978847** = success;
- HEAD técnico validado `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- artifact **11460960487**;
- digest `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

Nenhuma migration posterior a 027 foi criada neste bloco.

## 3. Correção de inventário — MethodDecision

Foi confirmado que:

> `investigation.method_decision` existe fisicamente desde a migration 014.

A premissa documental anterior de inexistência foi corrigida nos Documentos 07–09 e no CHANGELOG.

Fronteira consolidada:

- `investigation.method_decision` = decisão metodológica ligada a InvestigationVersion;
- `maintenance.update_decision` = decisão especializada de atualização/currentness no protocolo transversal.

A correção:

- não invalida migration 027;
- não altera seu PASS técnico;
- não cria dupla autoridade;
- não reabre Fase 3.

Para Monitor, exceções temporais já usam MethodDecision, incluindo:

- `monitor_cycle_window_gap_exception`;
- `monitor_search_temporal_exception`.

## 4. Perfis de risco — Documentos 16–17

### Documento 16

`docs/governance/16-perfis-risco-atualizacao.md`

Estado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Dimensões científicas/decisórias:

- A1 criticidade;
- A2 volatilidade;
- A3 sensibilidade da conclusão;
- A4 exposição estrutural a safety/integrity;
- A5 alcance de dependências.

Dimensões operacionais:

- B1 observabilidade;
- B2 latência de detecção;
- B3 carga de vigilância;
- B4 custo de incorporação;
- B5 capacidade sustentável.

Regras consolidadas:

- reutilizar criticidade/volatilidade do Routing Record sem reescrita histórica;
- risco científico e capacidade operacional são separados;
- capacidade não compensa criticidade;
- score agregado aditivo rejeitado;
- taxonomia paralela R0–R3 rejeitada;
- saída recomendatória usa domínio canônico M0–M3;
- recomendação M3 não ativa M3;
- currentness não é saída do perfil;
- profile assessment pode mudar ao longo do tempo sem nova versão científica;
- nova versão científica exige novo assessment ou carry-forward explícito.

### Documento 17

`docs/governance/17-revisao-adversarial-perfis-risco-atualizacao.md`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 5. Cadence e thresholds temporais — Documentos 18–19

### Documento 18

`docs/governance/18-politica-cadence-thresholds-temporais.md`

Estado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Arquitetura consolidada:

### quatro relógios

1. vigilância;
2. processamento;
3. reassessment de policy/profile;
4. atualização científica.

### schedule × coverage

Atraso operacional e gap de cobertura são estados distintos.

Casos possíveis:

- late + fully covered;
- on-time + gap;
- late + gap;
- on-time + fully covered.

### M1

- event_driven, periodic ou hybrid;
- Monitor governante proibido;
- periodic = reassessment programado, não Monitoring Cycle.

### M2

- periodic ou hybrid;
- Monitor governante obrigatório;
- periodic = surveillance ativa por Monitoring Cycle.

### M3

- continuous ou hybrid;
- continua bloqueado formalmente.

### planned_at

`monitor_cycle.planned_at` = instante nominal programado de início.

Contrato existente preservado:

> `started_at >= planned_at`.

`grace_until` = conceito separado de limite superior sem atraso formal.

### âncoras

- fixed_anchor;
- rolling_anchor;
- event_anchor.

fixed_anchor não desliza por atraso.

rolling_anchor exige rationale explícita.

### estados temporais

- not_open;
- within_grace;
- satisfied_on_time;
- overdue;
- satisfied_late;
- escalation_overdue;
- suspended_by_authority;
- not_applicable.

Preferência:

> overdue derivado de regra + tempo + evidência de satisfação, não boolean mutável.

### event-driven

Mecanismos:

- push;
- pull;
- external notice.

Canal push indisponível não pode ser interpretado como “nenhum evento”.

### supersessão

Nova UpdatePolicy não apaga:

- overdue histórico;
- gap;
- incidente;
- escalation.

### timezone

Calendar rules devem declarar timezone; timestamps persistidos em `timestamptz`.

### currentness

Proibido:

> overdue → outdated

e:

> gap → currentness change

sem a cadeia UpdateSignal → MaterialityAssessment → UpdateDecision.

### Documento 19

`docs/governance/19-revisao-adversarial-cadence-thresholds-temporais.md`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 6. M3

Permanece:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL**

Nenhum perfil, cadence, frequência, grace ou latency remove o blocker.

## 7. O que não foi definido

Ainda não foram definidos:

- classes formais de SLA;
- durações de SLA;
- condições de pause/stop de SLA;
- breach/escalation formal de SLA;
- prioridade global;
- thresholds quantitativos de materialidade;
- notification channels;
- scheduler;
- auto-classification;
- auto-escalation;
- propagation;
- Monitor re-baselining físico;
- M3 readiness;
- migration 028.

## 8. Referências externas consideradas

A arquitetura foi confrontada com princípios de:

- Cochrane Handbook Chapter 22;
- Cochrane Handbook Chapter IV;
- NICE PMG49, 2025;
- WHO living-guidelines approach.

Nenhum exemplo de periodicidade externa foi convertido em default universal do OES.

## 9. Commits principais desde CP90

- `de8175f71e9c7b1f93e92fea57b5da5ff5ed58b4` — Define Phase 4 update risk profiles
- `89416484b65328fa2db3888c1a589f65acb4b935` — Harden Phase 4 update risk profile semantics
- `f81343f502e7e74534ee63869f104bb88a360ba7` — Clean Phase 4 risk profile vocabulary
- `84ee5234fbd0dcd5f42f3ffa700cb9cb0310d2c0` — Align risk profile output with canonical maintenance domain
- `29c18b7072cdee9a6fd8dd4d4c7354acfb7a3f9e` — Review Phase 4 update risk profiles adversarially
- `bf2696c9a3caf097fa48117bccb3b750894b86bd` — Approve Phase 4 update risk profile baseline
- `b5b27593003729954a74372c322f2c6e66d1e000` — Correct MethodDecision boundary in Phase 4 contract
- `82c803910cfd0aa3c8a793a860698337182e6d75` — Record MethodDecision correction after Phase 4 gate
- `fa942951a9bf9e484f3af26dba5d830a09cda982` — Add MethodDecision erratum to Phase 4 validation
- `3f714758a244a1dc111ea2967309d50420a9f9a7` — Correct Phase 4 MethodDecision inventory
- `e9b449ca404233acdc9a3c0d3c0a5c0fa4115240` — Define Phase 4 cadence and temporal threshold policy
- `759d1d575b14bf7045a82732262f30d36562b6fa` — Harden Phase 4 cadence anchor and due semantics
- `8b90ae8c7004ed6f455f425caf4943fef528323d` — Reconcile Phase 4 cadence with M1 and Monitor planned_at
- `f8348fed82f6125856b8fddfad4dc65b0dc7a8d5` — Finalize Phase 4 cadence audit semantics
- `dd307823a10248111f8a26544c29268fa0ef505a` — Review Phase 4 cadence policy adversarially
- `b9f5f481e57370325fb747fa5602879ca9982ffa` — Approve Phase 4 cadence and temporal policy

## 10. Ponto exato de retomada

> **Definir a arquitetura transversal de SLAs como contratos operacionais entre eventos claramente definidos.**

Relógios mínimos a tratar:

1. detecção → triagem;
2. triagem → materiality assessment;
3. materiality → UpdateDecision;
4. UpdateDecision → início do workflow científico;
5. início → conclusão da atualização científica;
6. conclusão científica → revisão/publicação quando aplicável.

O bloco deve também definir:

- pause/stop conditions;
- breach semantics;
- relação com criticidade/materialidade/prioridade;
- diferença entre SLA e cadence;
- diferença entre SLA breach e currentness;
- ligação com Alert urgency;
- fronteira de automação.

Não fixar durações universais antes do gate semântico.

## 11. Disciplina de modo

O próximo bloco é arquitetural/metodológico e transversal.

> **Modo alto é apropriado para definir a arquitetura de SLA.**

**Fim do CP91**
