# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP83  
**Checkpoint anterior:** CP82  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação científica e decisão arquitetural do Alerta de Evidência

## 1. Marco

> **EVIDENCE_ALERT_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

Documentos:

- `docs/products/177-especificacao-alerta-evidencia.md`;
- `docs/products/178-alerta-evidencia-revisao-coerencia-arquitetura.md`.

## 2. Decisões

- Alerta formal = Product/ProductVersion;
- `product_type='evidence_alert'`;
- não cria Investigation nova;
- exatamente um Investigation link de contexto `source_context`;
- target especializado = ProductVersion xor InvestigationVersion;
- sources normalizadas 1:N;
- exatamente uma primary source;
- affected dimensions normalizadas 1:N;
- classification `informational|relevant|critical`;
- reassessment priority `routine|priority|urgent`;
- nenhuma dessas categorias possui threshold/SLA na Fase 3;
- lifecycle = triage/evaluation/incorporated/discarded;
- mudanças materiais de lifecycle geram nova ProductVersion;
- incorporated exige lineage;
- discarded exige rationale;
- Alerta não cria Product currency próprio;
- `conclusion_text` permanece NULL;
- assurance reutiliza A0–A3;
- publicação formal exige A2 + human verification explícita do conteúdo/classificação;
- critical não ganha A3 obrigatório ou auto-trigger na Fase 3.

## 3. Estruturas candidatas

Migration 024 deverá introduzir:

- `maintenance.evidence_alert`;
- `maintenance.alert_source`;
- `maintenance.alert_affected_dimension`;
- integrity guards;
- publication issues/is_publishable helpers;
- fixture/test support.

View deverá ser separada em migration posterior, preferencialmente 025, após Projection Readiness explícito.

## 4. Limites

Não iniciar:

- thresholds quantitativos;
- SLAs;
- auto-classification;
- auto-publication;
- canais/notificações;
- M3 transversal;
- Fase 4.

## 5. Ponto exato de retomada

> **Contrato de Dados v0.1 do Alerta de Evidência.**

Depois:

> **migration 024 + fixture + testes + rebuild + Projection Readiness Gate.**

## 6. Proibição de avanço

> **Não iniciar a Fase 4 sem consentimento explícito do usuário.**

**Fim do CP83**
