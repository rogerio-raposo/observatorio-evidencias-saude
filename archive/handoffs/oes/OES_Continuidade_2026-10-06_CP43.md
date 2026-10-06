# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP43  
**Checkpoint anterior:** CP42  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento do Projection Readiness Gate da EvidenceMapView  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP42 criado no commit `b96e08574f2d27b6331f36c9b21a8fc2e426f419`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP42: `ahead`;
- commits à frente: **11**;
- commits atrás: **0**.

Avanço material:

- migration 017 de projeção;
- EvidenceMapView 0.1 ampliada;
- helper de referências do Mapa;
- testes EMV-T01–T11;
- integração S5;
- rebuild através da migration 017;
- Documento 128;
- Projection Readiness Gate = READY.

## 2. Marco do CP43

> **EvidenceMapView Projection Readiness Gate = READY.**

Validação:

- workflow **OES PoC-S5 PostgreSQL Validation**;
- run **37466183355**;
- conclusion **success**;
- commit validado `0cd132d215bf156dee51c1ce49e3dd2a2c2adde2`;
- artifact **11414726018**;
- digest `sha256:44ee38666b3d502bae5936adb388cdd49660b0f763990eb23b00b2a01bd420c6`.

## 3. Implementação aditiva validada

- `database/017_evidence_map_view_rendering_readiness.sql`;
- `product.evidence_map_reference_reports()`;
- `product.evidence_map_view()` ampliada;
- schema lógico permanece `oes.evidence_map_view/0.1`.

Campos/coleções adicionados:

- synthetic fixture;
- conclusão;
- protocolo;
- codebook;
- reviewer assignments;
- method controls;
- searches/selection flow ampliados;
- lineage;
- invalidated dependencies;
- referências via Study–Report linkage.

## 4. Testes

- EMV-T01–T09 — projeção ampliada;
- EMV-T10 — rebuild;
- EMV-T11 — reaplicação idempotente da migration 017;
- regressões N0–N4 mantidas em PASS.

## 5. Regra arquitetural preservada

Migration 016 não foi reaberta.

As mudanças de presentation-readiness foram isoladas na migration 017.

## 6. Autorização

Com o gate em READY:

> **fica autorizada a Especificação do Template Operacional do Mapa de Evidências.**

Ainda não autorizado:

- Caso Real;
- formal gap claim real;
- uso da fixture sintética como evidência clínica.

## 7. Ponto exato de retomada

> **Criar a Especificação do Template Operacional do Mapa de Evidências, consumindo exclusivamente `oes.evidence_map_view/0.1` e implementando o Documento 127.**

## 8. Sequência

1. especificação do template;
2. template Markdown;
3. presentation map;
4. renderer;
5. validator;
6. testes adversariais;
7. validação final da camada de apresentação;
8. readiness para eventual Caso Real.

**Fim do CP43**
