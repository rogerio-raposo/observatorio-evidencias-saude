# 183 — Alerta de Evidência: Projection Readiness Gate 02 pós-hardening

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **Projection Readiness = READY**  
**Dependências:** Documentos 177–182; migrations 024–025

---

## 1. Finalidade

Reexecutar adversarialmente o gate da futura `oes.evidence_alert_view/0.1` após o hardening 025.

READY significa:

> o estado persistido oferece semântica suficiente para uma View determinística, auditável e read-only.

Não significa template pronto, Caso Real pronto ou Fase 4 iniciada.

## 2. Resultado

> **READY**

Os quatro blockers do Documento 181 foram resolvidos.

## 3. PR-ALT-01 — AlertSource pós-publicação

Resolvido.

AlertSource pode ser montada enquanto o AlertVersion está não publicado. Após `published`/publication_date:

> novos INSERTs são bloqueados.

UPDATE/DELETE já permaneciam bloqueados.

## 4. PR-ALT-02 — affected dimensions pós-publicação

Resolvido.

Novas dimensions são permitidas apenas durante montagem pré-publicação. Após sealing:

> INSERT/UPDATE/DELETE material é bloqueado.

## 5. PR-ALT-03 — drift de todas as sources

Resolvido por:

> `maintenance.evidence_alert_source_issues(...)`

O helper revalida dinamicamente:

- CandidateAssessment active;
- EvidenceEvent active;
- Monitor/source_context consistency;
- EntityVersion validity;
- Artifact activity;
- source dependency de EntityVersion.

Supporting source inválida passa a gerar error e bloquear publishability.

## 6. PR-ALT-04 — EntityVersion source lineage

Resolvido.

EntityVersion AlertSource exige edge ativa:

> `maintenance_alert_source`

Drift da edge volta a produzir error dinamicamente.

## 7. Source-context e ProductVersion sealing

Também ficou validado:

- source_context não pode ser alterado após publicação;
- ProductVersion publicado não pode ter material fields reescritos;
- transição histórica `published → superseded → archived` permanece possível sem mudar conteúdo.

## 8. EvidenceAlertView autorizada

A migration candidata passa a ser:

> `database/026_evidence_alert_view_rendering_readiness.sql`

Schema:

> `oes.evidence_alert_view/0.1`

## 9. Campos que a View pode projetar sem inferência

### Identity

- Alert Product/ProductVersion;
- editorial status;
- publication date;
- Alert information cutoff;
- title/audience.

### Source context

- Investigation ID/version;
- depth;
- maintenance level;
- objective/status;
- cutoff.

### Alert

- headline;
- summary;
- signal/detection/issue dates;
- classification;
- reassessment priority;
- lifecycle;
- justification;
- assessment actor;
- verification;
- resolution/incorporation.

### Target

- ProductVersion ou InvestigationVersion;
- identity/type;
- target cutoff;
- target editorial status quando Product;
- target currentness quando Product;
- target assurance quando Product;
- target scientific conclusion apenas quando Product.

### Sources

- source role/type;
- locator/identity;
- description/date;
- Monitor/cycle derivation para candidate/event;
- current source validity;
- dependency status para EntityVersion.

### Dimensions

- todas as affected dimensions e rationale.

### Governance/audit

- Alert assurance;
- target assurance;
- human verification;
- publication issues;
- hardening issues;
- target/source/incorporation lineage;
- assurance records;
- publishable.

## 10. Regras obrigatórias para migration 026

EvidenceAlertView deverá:

1. ser STABLE/read-only;
2. não criar Alert;
3. não classificar automaticamente;
4. não derivar urgency;
5. não criar SLA;
6. não alterar target currentness;
7. não criar scientific conclusion;
8. distinguir Alert assurance de target assurance;
9. distinguir Alert lifecycle de editorial status;
10. distinguir source_context de target;
11. projetar todas as sources, inclusive supporting;
12. projetar source hardening issues;
13. preservar múltiplas affected dimensions;
14. projetar human/AI verification literalmente;
15. manter direct-source warning explícito;
16. preservar critical como classificação preliminar;
17. projetar incorporation sem inferir mudança de conclusão;
18. ordenar arrays deterministicamente.

## 11. Evidência

Run final pós-hardening:

- **37560513048** (#135);
- HEAD `bb1cd11c1882583b001597044dda94ac34b966af`;
- conclusion success;
- ALT-H01–H13 PASS;
- rebuild-through-025 PASS;
- artifact **11456149431**;
- digest `sha256:1606e2b0379910b9100a285fba0dd62d250d07bec70aaa1374d45c797e30fb3b`.

## 12. Fase 4

Permanece:

> **NÃO INICIADA**

Nenhum threshold, SLA, auto-trigger, canal ou política M3 transversal foi definido.

## 13. Decisão final

> **EVIDENCE_ALERT_PROJECTION_READINESS = READY.**

Autorizado:

> migration 026 para EvidenceAlertView 0.1 + testes de projeção + idempotência + rebuild.

---

**Resultado:** camada persistida do Alerta está pronta para projeção read-only sem antecipar a Fase 4.