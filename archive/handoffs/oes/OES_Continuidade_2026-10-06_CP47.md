# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP47  
**Checkpoint anterior:** CP46  
**Status:** artefato de continuidade; não normativo  
**Escopo:** correção arquitetural da identidade do MAP-01 e herança de corpus  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Freshness Gate

Checkpoint de referência:

- CP46 criado no commit `4109480d38d7c901f5c2de01c1520cb9aee405f7`.

Estado da branch `main` antes deste checkpoint:

- status relativo ao CP46: `ahead`;
- commits à frente: **9**;
- commits atrás: **0**.

Avanço material:

- Documento 135 — MAP-01: Correção Arquitetural de Identidade da Investigation e Herança de Corpus;
- atualização de STATE, CHANGELOG e índice de produtos;
- correção residual da taxonomia da Fase 3 em STATE.

## 2. Problema identificado

A decisão do CP46 de reutilizar diretamente a InvestigationVersion N3-01 como primary Investigation faria a EvidenceMapView exibir a pergunta causal N3 como pergunta do Mapa.

Isso é semanticamente incorreto.

## 3. Decisão corretiva

> **MAP-01 terá Question e Investigation próprias.**

A N3-01 será ligada ao novo Product como:

> `role='source_corpus'`

Search, SearchHit e ScreeningDecision permanecerão exclusivamente na Investigation N3-01.

Não haverá duplicação de busca/seleção.

## 4. Superação controlada

A decisão do CP46 sobre reutilização direta da N3-01 como primary Investigation fica:

> **SUPERADA PELO DOCUMENTO 135 E CP47.**

Demais decisões do CP46 permanecem vigentes:

- 17 MapItems;
- 20 CellScope;
- codebook v0.1;
- descriptive_mapping_review;
- structured_non_exhaustive;
- apparent_only;
- counting unit = study;
- nenhuma fabricação de controles humanos.

## 5. Identidade do MAP-01

Question:

> Como as unidades de evidência recuperadas no corpus N3-01 sobre ambient AI scribes se distribuem por papel da evidência e domínio de outcome?

Investigation:

- type = `evidence_mapping`;
- depth = `N3` como profundidade do substrato investigativo, não como nível do produto Mapa;
- maintenance = `M0`;
- sem nova busca científica;
- cutoff = 2026-10-05.

## 6. Próxima implementação

Criar migration aditiva:

> `database/018_evidence_map_source_corpus_support.sql`

Objetivos:

1. suportar `source_corpus` na EvidenceMapView;
2. projetar source investigations;
3. projetar Searches/selection flow herdados com origem;
4. manter pergunta da primary MAP Investigation;
5. impedir que herança de corpus contorne requisitos de systematic map/EGM formal;
6. preservar schema `oes.evidence_map_view/0.1` se a mudança permanecer aditiva.

## 7. Ponto exato de retomada

> **Implementar e validar migration 018 de suporte a source_corpus antes de persistir o MAP-01.**

**Fim do CP47**
