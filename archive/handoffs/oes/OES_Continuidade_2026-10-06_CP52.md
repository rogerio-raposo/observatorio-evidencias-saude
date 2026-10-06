# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP52  
**Checkpoint anterior:** CP51  
**Status:** artefato de continuidade; não normativo  
**Escopo:** implementação estrutural da migration 019 do Overview de Revisões  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP51 vigente antes desta implementação.

Avanço material após CP51:

- correções editoriais de continuidade sem efeito metodológico;
- criação de `database/019_overview_of_reviews_contract.sql`;
- integração da migration 019 ao baseline/rebuild S5;
- validação incremental completa do baseline existente.

## 2. Marco do CP52

> **Migration 019 implementada e estruturalmente compatível com o OES existente.**

Ainda NÃO constitui PASS técnico completo do contrato do Overview.

Faltam:

- fixture formal sintética;
- OV-T01–T33;
- validação positiva/adversarial da View/gate;
- resultado técnico final do contrato.

## 3. Migration 019

Arquivo:

`database/019_overview_of_reviews_contract.sql`

Implementa:

- schema `overview`;
- sete estruturas especializadas;
- guards de identidade/verificação;
- append-preserving semantics para julgamentos;
- `overview.overlap_metrics()`;
- `overview.pairwise_overlap()`;
- `product.overview_reference_reports()`;
- publication gate;
- `product.overview_of_reviews_view()`.

Nenhum template foi criado.

## 4. Validação incremental

GitHub Actions:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37500255586**;
- conclusion **success**;
- commit validado `0558051dcf8d23402be45e6d1e99de5889ce2656`.

Artifact:

- ID **11429895618**;
- nome `oes-s5-evidence-37500255586`;
- tamanho **151570 bytes**;
- digest `sha256:385e4457936aa3dc435ee8d6b92c21382f4e9b80025cff5404c235c39e8508f6`.

Passaram:

- instalação through migration 019;
- regressões F2-B/S4/S5;
- produtos N0–N4;
- Evidence Map;
- MAP-01;
- rebuild do zero through migration 019.

## 5. Limite do marco

> **Não declarar Overview contract PASS ainda.**

A migration foi provada apenas quanto a:

- instalação;
- compatibilidade estrutural;
- não regressão;
- rebuild.

A semântica especializada do Overview ainda precisa da fixture formal e OV-T01–T33.

## 6. Embargo

Permanece vigente:

> **nenhum template do Overview antes do PASS técnico completo.**

## 7. Ponto exato de retomada

> **Criar a fixture formal sintética do Overview, com 3 systematic reviews, 5 primary Studies, 9 memberships, CCA esperado 0,4, overlap policy `prioritize_review`, ROBIS, human controls e A3; depois executar OV-T01–T33.**

**Fim do CP52**
