# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP45  
**Checkpoint anterior:** CP44  
**Status:** artefato de continuidade; não normativo  
**Escopo:** decisão de readiness para o primeiro Caso Real do Mapa de Evidências  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP44 criado no commit `08281f38b6cec7259a6a1363800924661bfa3950`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP44: `ahead`;
- commits à frente: **7**;
- commits atrás: **0**.

Avanço material:

- Documento 131 — Mapa de Evidências: Readiness Gate Pré-Caso Real;
- atualização de STATE, CHANGELOG e índice de produtos.

## 2. Resultado do Readiness Gate

### Rota A — exploratória / structured non-exhaustive

> **READY_WITH_DOCUMENTED_CONDITIONS**

Autorizado:

- Caso Real interno;
- assurance inicial compatível com A1;
- `under_review`;
- `publication_date=NULL`;
- `coverage_claim=structured_non_exhaustive`;
- `gap_claim_mode=apparent_only`;
- sem alegação de completude;
- sem rótulo systematic map/EGM formal.

### Rota B — systematic map / EGM formal

> **NOT_READY**

Blockers:

- cobertura bibliográfica abrangente não garantida;
- ausência de search peer reviewer qualificado;
- ausência de dupla classificação humana qualificada;
- ausência de expert independent reviewer;
- caminho real A3 inexistente.

## 3. Caso Real autorizado

> **MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01.**

Princípio:

> o MAP-01 é um novo Product transversal e não altera o Caso Real N3-01.

Corpus:

> reutilizar o corpus real acumulado e rastreável do N3-01, com suas limitações preservadas.

## 4. Parâmetros iniciais autorizados

- subtype: `descriptive_mapping_review`;
- coverage: `structured_non_exhaustive`;
- gap mode: `apparent_only`;
- counting unit: `study`;
- finalidade: interna/experimental;
- assurance inicial alvo: A1, se a verificação metodológica real existente for suficiente para A1 do novo produto;
- sem publicação;
- sem formal gap claims.

A assurance final será derivada dos registros efetivamente criados, não pré-atribuída.

## 5. Proibições

Não:

- reabrir N3-01 como ProductVersion 3;
- elevar assurance do N3-01;
- fabricar ReviewerAssignments humanos;
- criar `human_verified` sem humano real;
- tratar supplemental discovery como segunda base bibliográfica;
- usar `systematic_comprehensive`;
- usar `formal_within_scope`;
- afirmar ausência global de evidência;
- converter apparent gap em research priority.

## 6. Ponto exato de retomada

> **Criar o protocolo do MAP-01 antes da persistência de Question/Investigation/Framework/Product do novo caso.**

## 7. Sequência

1. protocolo MAP-01;
2. inventário formal do corpus herdado;
3. framework e codebook;
4. decisão final de entidades MapItem;
5. persistência do caso;
6. classificações;
7. validação técnica;
8. verificação metodológica adversarial;
9. encerramento com assurance real derivada.

**Fim do CP45**
