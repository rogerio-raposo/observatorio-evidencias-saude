# 173 — Monitor de Evidências: Resultado da Validação da EvidenceMonitorView 0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS DA CAMADA DE PROJEÇÃO**  
**Dependências:** Documentos 165–172; migrations 021–023

---

## 1. Decisão

> **EVIDENCE_MONITOR_VIEW_0_1 = PASS.**

A migration 023 implementou e validou a projeção read-only:

> `oes.evidence_monitor_view/0.1`

sem criar template, Caso Real, Alert ou regras da Fase 4.

---

## 2. Migration

Arquivo:

`database/023_evidence_monitor_view_rendering_readiness.sql`

Funções:

- `product.evidence_monitor_target_projection(...)`;
- `maintenance.monitor_cycle_projection(...)`;
- `product.evidence_monitor_view(...)`.

Todas são:

> **read-only / STABLE**

e não executam Search nem alteram estado persistido.

---

## 3. Target projection

A View preserva o target polimórfico.

### ProductVersion target

Projeta:

- identidade;
- product type;
- version;
- editorial status;
- publication date;
- baseline cutoff;
- inherited depth;
- primary Investigation;
- assurance;
- currentness;
- scientific conclusion;
- applicability;
- limitations;
- target dependency.

### InvestigationVersion target

Projeta explicitamente:

- target type = `investigation_version`;
- identity/version;
- investigation type;
- depth;
- maintenance level;
- objective;
- cutoff;
- status.

Não inventa:

- target assurance;
- target Product currency;
- target scientific conclusion.

Esses campos permanecem null/not applicable.

---

## 4. Cycle projection

Cada Monitoring Cycle projeta:

- identity/sequence;
- previous cycle;
- window;
- lifecycle/execution;
- Searches;
- SearchHits;
- temporal acceptability;
- normalized SourceRequirement status;
- EvidenceEvents;
- CandidateAssessments;
- CandidateImpacts;
- maintenance decision;
- verification;
- escalation recommendation;
- resulting target CurrencyState;
- cycle issues.

O histórico de CurrencyState é preservado:

- cycle anterior pode apontar para CurrencyState já `superseded`;
- latest cycle pode apontar para CurrencyState `active`.

A View não reescreve essa história.

---

## 5. Impactos múltiplos

O candidato científico sintético é projetado com:

- primary impact = `quantitative`;
- secondary impact = `certainty`.

Logo:

> **a View não colapsa múltiplas dimensões de impacto no campo legado singular.**

---

## 6. Source requirements e exceções

A View projeta, por cycle:

- requirement;
- fulfilled;
- exception_applied;
- exception MethodDecision;
- satisfied;
- evidence.

Assim:

> uma exceção metodológica não é apresentada como fonte efetivamente executada.

---

## 7. Quatro dimensões de estado

A View mantém separadas:

1. Monitor editorial status;
2. Monitor operational status;
3. Monitor Product currency;
4. target scientific currency.

Na fixture M2:

- editorial = `published`;
- operational = `active`;
- Monitor currency = `current`;
- target currency = `under_evaluation`.

Nenhuma dimensão substitui outra.

---

## 8. Audit

O envelope `audit` projeta:

- Monitor assurance;
- target assurance;
- required assurance;
- publishable;
- maintenance level;
- baseline cutoff;
- latest completed cycle/cutoff;
- latest cycle verification;
- pending candidate count;
- active event count;
- source coverage;
- invalidated dependencies;
- M3 policy state;
- publication issues;
- projection-hardening issues;
- assurance records.

Na fixture M2:

- Monitor assurance = A2;
- target assurance = A0;
- publishable = true;
- hardening errors = zero;
- warnings permanecem visíveis.

---

## 9. M3

A fixture M3 é projetada corretamente.

A View preserva:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

como error formal.

Logo:

> **migration 023 não inicia Fase 4 nem torna living evidence publicável.**

---

## 10. Testes MONV

Arquivo:

`database/f3-evidence-monitor-view-tests.sql`

### MONV-T01–T17

Validam:

- schema/identity;
- separação das quatro dimensões de estado;
- ProductVersion target;
- source requirements;
- cycle ordering/cutoffs;
- Search/SearchHit;
- requirement status;
- impactos múltiplos;
- EvidenceEvent/candidate;
- histórico de CurrencyState;
- assurance/audit;
- warnings/hardening issues;
- InvestigationVersion target;
- ausência de human verification inventada;
- determinismo;
- wrong-product blocking;
- função STABLE/read-only.

Resultado:

> **PASS**

### MONV-T18

Migration 023 reaplicada.

Resultado:

> **PASS — idempotent re-apply**

### MONV-T19

Rebuild-from-zero through migration 023.

Resultado:

> **PASS**

---

## 11. Evidência CI

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37556593132**

Run number:

> **128**

HEAD validado:

`613a9ced4ad43a3eb890a2b5db35acf51a08127e`

Conclusão:

> **success**

Confirmado:

- install through migration 023;
- MON-T01–T32;
- MONH-T01–T22;
- MON-T33;
- MONH-T23;
- MONV-T01–T17;
- MONV-T18;
- rebuild-through-023;
- regressões globais.

Artifact:

- id **11454488440**;
- name `oes-s5-evidence-37556593132`;
- size **197417 bytes**;
- digest `sha256:6043e52ac33800ec5d944b1a4633bfe5049a9c8ecff2613eb577aadea2916630`.

---

## 12. Readiness

Scientific/functional:

> PASS

Architecture:

> PASS

Data contract:

> PASS

Projection hardening:

> PASS

Projection Readiness:

> READY

EvidenceMonitorView 0.1:

> PASS

Template/presentation:

> **NOT_YET_SPECIFIED**

Caso Real:

> NOT_AUTHORIZED

Fase 4:

> NOT_STARTED

---

## 13. Próxima etapa

> **Definir o contrato de renderização e a especificação do Template Operacional do Monitor de Evidências.**

Essa etapa deverá:

- consumir exclusivamente `EvidenceMonitorView`;
- não consultar tabelas diretamente;
- não inferir estado ausente;
- preservar Monitor × target × currentness × cycle × assurance;
- mostrar exceptions como exceptions;
- deixar o blocker M3 visível.

Somente após especificação:

> implementar template/renderer/validator e integrar ao S5.

---

**Resultado final:** EvidenceMonitorView 0.1 validada em PASS; próxima etapa = contrato de renderização/template, sem Caso Real e sem Fase 4.
