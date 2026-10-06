# 136 — Resultado da Validação do Suporte a Source Corpus no Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Caso:** MAP-01  
**Data:** 6 de outubro de 2026  
**Status:** **PASS técnico**  
**Dependências:** Documento 135; migrations 016–018

---

# 1. Finalidade

Validar a correção arquitetural que separa:

- a Question/Investigation própria do MAP-01;
- a Investigation N3-01 que fornece o corpus herdado.

# 2. Migration

Criada:

`database/018_evidence_map_source_corpus_support.sql`

Natureza:

> extensão aditiva e idempotente de projeção/publication gate.

A migration não altera as tabelas do schema `mapping`.

# 3. Comportamento implementado

## 3.1 Product investigation roles

O Evidence Map passa a reconhecer:

- `primary`;
- `source_corpus`.

A primary Investigation define:

- pergunta do Mapa;
- objetivo;
- protocolo do mapping;
- FrameworkVersion.

A source_corpus Investigation fornece:

- Search;
- SearchHit;
- ScreeningDecision;
- corpus rastreável.

## 3.2 EvidenceMapView

A view passa a projetar:

- `source_investigations[]`;
- Search com `investigation_id`;
- Search com `investigation_role`;
- selection flow agregado entre primary/source_corpus;
- `audit.source_corpus_count`.

A pergunta continua vindo exclusivamente da primary Investigation.

## 3.3 Publication gate

Para mapa não sistemático:

- Search pode estar na primary Investigation ou em `source_corpus`.

Para:

- `systematic_comprehensive`;
- `formal_within_scope`;
- systematic evidence map;
- evidence gap map formal;

Search deve existir na primary Investigation do próprio mapa.

Assim:

> **source_corpus não pode contornar requisitos formais de cobertura.**

# 4. Testes

Arquivo:

`database/f3-evidence-map-source-corpus-tests.sql`

Validações:

- **EMVSC-T01** — pergunta da primary MAP Investigation preservada e Searches herdadas da source_corpus projetadas;
- **EMVSC-T02** — mapa não sistemático pode satisfazer requisito de Search por source_corpus;
- **EMVSC-T03** — mapa formal não pode usar source_corpus para contornar Search primária;
- **EMVSC-T04** — fixture anterior permanece inalterada após rollback;
- **EMVSC-T05** — migration 018 reaplica idempotentemente junto da 017.

# 5. Regressões

Pipeline integrado:

- F2-B PASS;
- S4 PASS;
- S5 PASS;
- N0 PASS;
- N1 PASS;
- N2 PASS;
- N3 PASS;
- N4 PASS;
- Evidence Map contract PASS;
- EvidenceMapView PASS;
- template/renderização PASS;
- migration 017 idempotent reapply PASS;
- migration 018 idempotent reapply PASS;
- rebuild through migration 018 PASS.

# 6. GitHub Actions

Run:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37479566944**;
- conclusion **success**;
- commit validado `9c7e6def5dfb8b659dc87d63f118a2c9c8bcf95a`.

Artifact:

- ID **11420063123**;
- nome `oes-s5-evidence-37479566944`;
- tamanho **121475 bytes**;
- digest `sha256:c7dc99be7781200e0ad603b0d03f9e90e3022ed7eafabd32be5138f41c29024b`.

# 7. Interpretação

A correção arquitetural do Documento 135 foi tecnicamente validada.

Logo:

> **MAP-01 pode ter identidade científica própria sem duplicar a busca/seleção do N3-01.**

E:

> **a herança de corpus permanece incapaz de elevar artificialmente um mapa exploratório a systematic map/EGM formal.**

# 8. Decisão

> **Suporte a source_corpus = PASS.**

Próxima etapa:

> **persistir o Caso Real MAP-01 usando Question/Investigation próprias e a N3-01 como source_corpus.**

---

**Resultado final:** correção arquitetural validada; MAP-01 apto à persistência controlada.
