# 135 — MAP-01: Correção Arquitetural de Identidade da Investigation e Herança de Corpus

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Caso:** MAP-01  
**Data:** 6 de outubro de 2026  
**Status:** decisão arquitetural corretiva pré-persistência  
**Supera:** decisão do CP46 de reutilizar diretamente a InvestigationVersion N3-01 como primary Investigation do MAP-01

---

# 1. Problema identificado

A `EvidenceMapView` obtém a pergunta exibida a partir da `primary Investigation`.

Se o MAP-01 reutilizar diretamente a InvestigationVersion N3-01 como primary Investigation:

- a view exibirá a pergunta causal do N3;
- o Mapa perderá identidade própria de pergunta;
- o renderer poderá apresentar como pergunta do Mapa uma questão que não corresponde ao objetivo cartográfico;
- Product e Investigation ficarão semanticamente acoplados de forma incorreta.

Portanto:

> **a decisão do CP46 de reutilizar a N3-01 como primary Investigation não deve ser executada.**

---

# 2. Decisão corrigida

O MAP-01 terá:

1. **Question própria de mapeamento**;
2. **Investigation própria de mapeamento**;
3. N3-01 ligada ao Product como **`source_corpus`**;
4. nenhum Search ou Screening duplicado.

O Product terá:

- uma única Investigation com role `primary`;
- uma ou mais InvestigationVersions com role `source_corpus`, quando o corpus for herdado.

---

# 3. Pergunta do MAP-01

Pergunta normalizada:

> **Como as unidades de evidência recuperadas no corpus N3-01 sobre ambient AI scribes se distribuem por papel da evidência e domínio de outcome?**

Tipo:

> `mapping`

Estrutura:

> `PCC`

Essa pergunta é descritiva/cartográfica e não substitui a pergunta causal do N3.

---

# 4. Investigation própria do MAP-01

`investigation_type=evidence_mapping`

A Investigation representa:

- definição do framework;
- codebook;
- inventário do corpus herdado;
- classificação;
- CellScope;
- construção do mapa.

Ela não executa nova busca científica.

---

# 5. Depth level

O schema OES-P1 exige `depth_level` N0–N4 para toda Investigation.

Como o Mapa não recebe automaticamente um nível N0–N4, o campo deverá ser interpretado como:

> **profundidade do substrato investigativo que sustenta o mapeamento, não nível do produto Mapa.**

Para MAP-01:

> `depth_level=N3`

Motivo:

- o corpus herdado foi produzido por uma Investigation N3;
- o Mapa reutiliza esse substrato sem reduzi-lo a N0/N1;
- o template já declara que depth se refere à Investigation de suporte e não ao nível do Mapa.

Essa escolha não transforma MAP-01 em “Mapa N3”.

---

# 6. Role source_corpus

Uso de `product.investigation_link`:

### primary

Investigation própria do MAP-01.

### source_corpus

InvestigationVersion N3-01:

`e1000000-0000-0000-0000-000000000002`

Sem duplicação de:

- Search;
- SearchHit;
- ScreeningDecision;
- MethodDecision;
- QualityControlRecord existentes.

---

# 7. EvidenceMapView

A projeção deverá distinguir:

- `investigation` = primary MAP Investigation;
- `source_investigations[]` = Investigations que fornecem corpus;
- searches/selection flow herdados = identificados com a Investigation de origem.

A pergunta exibida será sempre a da primary MAP Investigation.

---

# 8. Publication gate

Para mapas não sistemáticos:

- Search poderá ser satisfeito pela primary Investigation ou por `source_corpus`;
- a origem deverá permanecer rastreável.

Para:

- `systematic_comprehensive`;
- `formal_within_scope`;

a cobertura formal deverá continuar vinculada à Investigation primária do próprio mapa.

Assim:

> **herança de corpus não poderá ser usada para contornar requisitos de systematic map/EGM formal.**

---

# 9. FrameworkVersion

`mapping.framework_version.investigation_version_uuid` deverá apontar para:

> **a InvestigationVersion própria do MAP-01**

e não para a N3-01.

Isso mantém:

- identidade metodológica do framework;
- pergunta correta;
- separação entre método de mapping e método de produção do corpus.

---

# 10. Provenance

A relação de herança deverá ser visível por:

- `product.investigation_link(role='source_corpus')`;
- lineage adicional quando aplicável;
- `source_investigations[]` na view;
- searches com indicação da Investigation de origem.

---

# 11. Compatibilidade

Esta correção:

- não altera N3-01;
- não duplica Search/Screening;
- não reabre migrations 016–017;
- não invalida Documentos 132–134;
- altera somente a decisão de identidade da Investigation do MAP-01.

O CP46 permanece como checkpoint histórico, mas sua decisão específica sobre primary Investigation fica:

> **SUPERADA pelo Documento 135.**

---

# 12. Próxima implementação

Criar migration aditiva:

> `database/018_evidence_map_source_corpus_support.sql`

Ela deverá:

1. ampliar `EvidenceMapView` para `source_investigations`;
2. projetar Searches/selection flow da primary + source_corpus;
3. identificar a origem de cada Search;
4. ajustar o publication gate para aceitar source_corpus apenas em mapas não sistemáticos;
5. preservar exigência de primary-search para systematic comprehensive/formal gaps;
6. manter schema `oes.evidence_map_view/0.1` se a extensão continuar aditiva.

---

# 13. Decisão

> **MAP-01 terá Question/Investigation próprias e herdará o corpus N3-01 via role `source_corpus`.**

Essa decisão deve ser implementada antes da persistência do Caso Real.

---

**Resultado:** identidade científica do MAP-01 separada da Investigation que produziu o corpus, sem duplicação de busca/seleção.
