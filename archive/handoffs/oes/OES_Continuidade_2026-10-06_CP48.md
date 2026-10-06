# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP48  
**Checkpoint anterior:** CP47  
**Status:** artefato de continuidade; não normativo  
**Escopo:** validação do suporte a source_corpus antes da persistência do MAP-01  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP47 criado no commit `f1a1999d150da4b31281c0cf16628f7d32c6aa66`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP47: `ahead`;
- commits à frente: **10**;
- commits atrás: **0**.

Avanço material:

- migration 018;
- testes EMVSC;
- integração S5;
- run de validação em success;
- Documento 136;
- atualização de STATE, CHANGELOG e índice de produtos.

## 2. Marco do CP48

> **Suporte a source_corpus do Evidence Map = PASS técnico.**

Validação:

- workflow **OES PoC-S5 PostgreSQL Validation**;
- run **37479566944**;
- conclusion **success**;
- commit validado `9c7e6def5dfb8b659dc87d63f118a2c9c8bcf95a`;
- artifact **11420063123**;
- digest `sha256:c7dc99be7781200e0ad603b0d03f9e90e3022ed7eafabd32be5138f41c29024b`.

## 3. Arquitetura vigente

MAP-01:

- terá Question própria;
- terá Investigation própria;
- terá FrameworkVersion vinculada à Investigation própria;
- ligará N3-01 como `source_corpus`;
- não duplicará Search/SearchHit/ScreeningDecision.

EvidenceMapView:

- preserva a pergunta da primary Investigation;
- projeta `source_investigations[]`;
- projeta Search com origem/role;
- agrega selection flow primary + source_corpus;
- registra `audit.source_corpus_count`.

## 4. Invariante formal

Para mapas não sistemáticos:

> Search pode ser herdada por `source_corpus`.

Para mapas systematic/formal:

> Search deve pertencer à primary Investigation do próprio mapa.

Logo:

> **source_corpus não pode elevar um mapa exploratório a systematic map/EGM formal.**

## 5. Testes

- EMVSC-T01 — identidade da pergunta + herança;
- EMVSC-T02 — non-systematic source-corpus Search aceita;
- EMVSC-T03 — formal map não pode contornar Search primária;
- EMVSC-T04 — regressão da fixture anterior;
- EMVSC-T05 — reaplicação idempotente;
- rebuild through migration 018 = PASS;
- regressões N0–N4 = PASS.

## 6. Ponto exato de retomada

> **Persistir o Caso Real MAP-01 com Question/Investigation próprias e N3-01 como source_corpus, usando os Documentos 132–134 como protocolo, inventário e codebook.**

## 7. Sequência

1. artifacts de protocolo/codebook;
2. Question/Investigation MAP-01;
3. Framework/FrameworkVersion;
4. dimensions/categories;
5. 17 MapItems;
6. assignments finais IA/unverified;
7. 20 CellScope;
8. Product evidence_map interno;
9. links primary + source_corpus;
10. testes;
11. render;
12. adversarial verification;
13. assurance final derivada.

**Fim do CP48**
