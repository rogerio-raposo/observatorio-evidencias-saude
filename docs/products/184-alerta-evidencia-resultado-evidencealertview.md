# 184 — Alerta de Evidência: Resultado da Validação da EvidenceAlertView 0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **PASS DA CAMADA DE PROJEÇÃO**  
**Dependências:** Documentos 177–183; migrations 024–026

---

## 1. Decisão

> **EVIDENCE_ALERT_VIEW_0_1 = PASS.**

Schema:

> `oes.evidence_alert_view/0.1`

Migration:

> `database/026_evidence_alert_view_rendering_readiness.sql`

---

## 2. Semântica projetada

A View preserva separadamente:

- identidade/versionamento do Alert Product;
- editorial status;
- information cutoff;
- source_context Investigation;
- Alert lifecycle;
- classification preliminar;
- reassessment priority qualitativa;
- verification;
- target ProductVersion ou InvestigationVersion;
- target currentness somente quando ProductVersion;
- Alert assurance;
- target assurance;
- todas as sources, inclusive supporting;
- Monitor/cycle origin quando source vem de CandidateAssessment/EvidenceEvent;
- múltiplas affected dimensions;
- lineage;
- publication issues;
- projection hardening issues.

---

## 3. Ausências intencionais

A View não cria:

- currentness próprio do Alert;
- scientific conclusion do Alert;
- nova Investigation;
- nova Search;
- threshold;
- SLA;
- classificação automática;
- urgency automática;
- update automático;
- Alert automático;
- regra M3 transversal.

---

## 4. Target polimórfico

### ProductVersion

Projeta:

- identidade;
- tipo;
- título;
- cutoff;
- editorial status;
- assurance;
- currentness;
- scientific conclusion;
- applicability;
- limitations.

### InvestigationVersion

Projeta:

- identidade;
- tipo;
- profundidade;
- manutenção;
- objetivo;
- cutoff;
- status.

Mantém como null/not applicable:

- Product assurance;
- Product currency;
- Product scientific conclusion.

---

## 5. Sources

A View projeta:

- primary e supporting sources;
- CandidateAssessment origin;
- EvidenceEvent origin;
- EntityVersion source;
- Artifact source;
- URI source;
- Monitor/cycle derivation;
- source issues;
- dependency status quando aplicável.

Nenhuma source supporting é omitida.

---

## 6. Verification e assurance

Alert A:

- verification = human_verified;
- verifier actor type = human_reviewer;
- Alert assurance = A2;
- target assurance = A0;
- publishable = true;
- expert independent review = ausente e explicitamente visível.

Alert B:

- verification = ai_verified;
- assurance = A1;
- publishable = false;
- blocker de human verification preservado.

Alert C:

- classification = critical;
- priority = urgent;
- target = InvestigationVersion;
- publishable = true;
- direct-source warning preservado;
- critical sem expert review permanece warning;
- nenhuma automação da Fase 4 é inferida.

---

## 7. Testes

Arquivo:

`database/f3-evidence-alert-view-tests.sql`

### EAV-T01–T15

Validam:

- schema/identity;
- source_context;
- Alert content/lifecycle;
- target ProductVersion;
- sources e Monitor/cycle origin;
- affected dimensions;
- assurance;
- warnings;
- AI-only blocking;
- InvestigationVersion target;
- direct-source semantics;
- lineage;
- ausência de scientific conclusion/currentness próprios do Alert;
- determinismo;
- função STABLE.

Resultado:

> **PASS**

### EAV-T16

Migration 026 reaplicada.

Resultado:

> **PASS — idempotent re-apply**

### EAV-T17

Rebuild-from-zero through migration 026.

Resultado:

> **PASS**

---

## 8. Evidência CI

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37560891043**

Run number:

> **138**

HEAD validado:

`7e41436bb02b47b039356c9ec51aa5d3708a2615`

Conclusão:

> **success**

Artifact:

- id **11456283842**;
- name `oes-s5-evidence-37560891043`;
- size **212584 bytes**;
- digest `sha256:9513fab7aa3209c8fc4cc008f7b26b687b31d167cbd51ed68a60bae6289740d6`.

---

## 9. Readiness

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

EvidenceAlertView 0.1:

> PASS

Template/presentation:

> **NOT_YET_SPECIFIED**

Caso Real:

> não obrigatório para fechamento taxonômico da Fase 3

Fase 4:

> **NOT_STARTED**

---

## 10. Próxima etapa

> **Definir contrato de renderização e Template Operacional do Alerta de Evidência.**

A apresentação deverá consumir exclusivamente a `EvidenceAlertView`, sem recalcular classification, urgency, currentness, assurance ou scientific conclusion.

---

**Resultado final:** EvidenceAlertView 0.1 validada em PASS; próxima etapa = camada de apresentação do Alerta.
