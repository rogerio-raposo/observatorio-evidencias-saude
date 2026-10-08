# 56 — Pacote de Decisão de Authority: Phase A da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **AWAITING_EXPLICIT_OWNER_DECISION**  
**Dependências:** Documentos 54–55  
**Objeto:** decisão humana específica sobre execução da Phase A da primeira Temporal Observation Plan Instance

## 1. Contexto

A arquitetura transversal de aquisição temporal não normativa foi aprovada no Documento 53.

A primeira instância foi selecionada e especificada no Documento 54:

> **TOPI-N2-DCBTI-01**

Target:

- Product `OES-P-2026-000401`;
- ProductVersion `81000000-0000-0000-0000-000000000701`;
- N2/evidence_sheet;
- A2/published;
- maintenance level histórico M1.

O Documento 55 concluiu:

> **PASS_FOR_AUTHORITY_REQUEST_ONLY**

Nenhuma interação real com fontes está autorizada até decisão explícita deste pacote.

## 2. Decisão solicitada

Solicita-se ao proprietário/authority competente uma decisão exclusivamente sobre:

> **autorizar ou não a Phase A da TOPI-N2-DCBTI-01.**

A Phase A é limitada a:

1. source characterization;
2. source-access/data-governance review;
3. confirmação de semantic storage mapping;
4. preparação de evidence inputs para UpdateRiskProfile;
5. registro de effort de characterization;
6. preservação auditável de locators, retrieval times e interpretações.

## 3. O que a Phase A NÃO é

A Phase A:

- não é Monitor;
- não é MonitoringCycle;
- não é surveillance persistente;
- não executa Phase B;
- não possui measurement schedule repetida;
- não define cadence;
- não cria overdue/breach;
- não muda currentness;
- não cria UpdatePolicy;
- não cria CadenceContract;
- não cria Calibration Dossier;
- não cria normative temporal values;
- não cria scheduler;
- não cria notifications;
- não cria auto-escalation;
- não desbloqueia M3;
- não autoriza migration nova.

## 4. Fontes candidatas da Phase A

O escopo de characterization inclui inicialmente:

- PubMed/MEDLINE;
- BVS/LILACS;
- ClinicalTrials.gov.

Elas são candidates por terem sido usadas no Caso Real N2.

Isso não declara que formem um future surveillance universe completo.

Fontes adicionais permanecem:

> **UNASSESSED**

e não podem ser adicionadas ao escopo sem registro explícito.

## 5. Atos que uma decisão APPROVED autoriza

A decisão APPROVED autoriza, dentro do escopo acima:

- consultar documentação pública/oficial das fontes;
- verificar interfaces e mecanismos de acesso vigentes;
- verificar quais timestamps/metadados são disponibilizados;
- registrar locators e retrieval times;
- avaliar observability;
- verificar restrições relevantes de acesso/uso;
- realizar probes mínimos quando necessários para characterization, desde que não sejam apresentados como Search científica ou surveillance;
- confirmar qual objeto/artefato deve armazenar cada event class;
- preparar evidence inputs A1–A5/B1–B5 sem fechar ratings authoritative;
- registrar esforço operacional de characterization.

## 6. Limites da autorização

Mesmo se APPROVED:

### 6.1 Phase B

> **continua bloqueada.**

### 6.2 Scientific Search

Uma Search científica real só pode ser executada/persistida quando um ato futuro tiver finalidade científica compatível com `investigation.search`.

A autorização deste pacote não transforma probe de characterization em Search.

### 6.3 UpdateRiskProfile

A Phase A pode preparar evidência.

Não pode declarar ratings authoritative sem a authority científica/metodológica requerida.

### 6.4 Measurement schedule

> **continua NOT_SELECTED.**

Nenhuma agenda periódica é autorizada.

### 6.5 Policy/calibration

Nenhuma policy ou calibration é autorizada.

## 7. Data governance

A execução deverá:

- minimizar dados;
- evitar retenção de payload desnecessário;
- não armazenar credentials/secrets em artifacts;
- não coletar dados pessoais de pacientes;
- registrar source/access constraints relevantes;
- preservar apenas conteúdo necessário para auditabilidade e provenance.

Se uma restrição material impedir uso legítimo da fonte:

> parar a atividade naquela fonte e registrar o blocker.

## 8. Invalidation / stop conditions

Mesmo após APPROVED, parar a Phase A se ocorrer:

- target supersession/rebaseline;
- mudança material de source/API/interface;
- alteração material de acesso/termos;
- authority withdrawal;
- impossibilidade de preservar provenance;
- purpose drift para surveillance;
- necessidade material de M1→M2;
- storage semantic mismatch;
- blocker de governança que torne a continuação inadequada.

## 9. Resultado esperado

Uma Phase A concluída deve produzir:

> **TOPI-N2-DCBTI-01 Phase A Characterization Package**

Esse pacote deverá retornar para:

> **Plan Amendment v0.2 + target-specific recheck**

antes de qualquer Phase B.

## 10. Decisão

Escolher explicitamente uma opção:

- [ ] **APPROVED** — autorizo a execução da Phase A da TOPI-N2-DCBTI-01 exatamente no escopo e com os limites deste Documento 56.
- [ ] **REVISE** — solicito alteração do escopo antes de autorizar.
- [ ] **REJECTED** — não autorizo a Phase A.

Uma mensagem genérica como “prossiga”, “ok” ou aprovação anterior do projeto:

> **não será interpretada como decisão deste pacote.**

A decisão deve mencionar explicitamente **APPROVED**, **REVISE** ou **REJECTED** em relação à **Phase A / Documento 56 / TOPI-N2-DCBTI-01**.

## 11. Estado enquanto não houver decisão

> **AUTHORITY_DECISION = PENDING**

> **PHASE_A_EXECUTION = NOT_AUTHORIZED**

> **PHASE_B = BLOCKED**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **PHASE_5 = NOT_STARTED**

**Fim do Documento 56**
