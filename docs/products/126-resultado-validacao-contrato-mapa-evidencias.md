# 126 — Resultado da Validação Técnica do Contrato do Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS técnico**

---

# 1. Escopo

Registrar o resultado da implementação e validação técnica do contrato de dados v0.1 do Mapa de Evidências definido nos Documentos 123–125.

O PASS deste documento é de arquitetura, persistência, derivação, gates e projeção estruturada. Ele não constitui validação de template e não autoriza inferências clínicas a partir da fixture sintética.

# 2. Implementação validada

Artefatos principais:

- `database/016_evidence_map_contract.sql`;
- `database/f3-evidence-map-fixtures.sql`;
- `database/f3-evidence-map-tests-a.sql`;
- `database/f3-evidence-map-tests-b.sql`;
- `database/f3-evidence-map-rebuild-check.sql`;
- integração em `.github/workflows/validate-s5.yml`.

Novo schema lógico:

- `mapping`.

Estruturas especializadas persistentes:

1. `mapping.framework`;
2. `mapping.framework_version`;
3. `mapping.dimension`;
4. `mapping.category`;
5. `mapping.map_item`;
6. `mapping.assignment`;
7. `mapping.cell_scope`.

O núcleo científico OES-P1 foi reutilizado para Question, Investigation, Search, Screening, Study, Report, Synthesis, Artifact, provenance, ReviewerAssignment, QualityControlRecord, CurrencyState e AssuranceRecord.

# 3. Derivação de células, contagens e gaps

Foi implementada:

`mapping.evidence_map_cells(framework_version_uuid)`

A função deriva, sem criar novas fontes primárias:

- células;
- contagens por Study;
- contagens por Report;
- contagens por Synthesis;
- total de MapItems;
- contagem segundo `counting_unit_policy`;
- drill-down de MapItems;
- empty-cell gaps;
- apparent gaps;
- primary-evidence gaps;
- synthesis gaps.

A fixture demonstrou que um Report associado a um Study não infla a contagem quando a unidade declarada é `study`.

Também foi validado que:

- célula vazia `in_scope + gap_eligible` pode gerar gap formal;
- célula vazia `not_applicable` não gera gap;
- gap formal não pode coexistir com coverage não sistemático.

# 4. Controles estruturais de framework e classificação

A migration 016 valida:

- tipo permitido de MapItem: Study, Report ou Synthesis;
- pertencimento de Assignment ao mesmo FrameworkVersion;
- apenas um final ativo em dimensão single-valued;
- verificação humana separada de verificação por IA;
- CellScope coerente com row_axis e column_axis;
- imutabilidade material de Dimension e Category dentro de uma FrameworkVersion;
- nova FrameworkVersion como mecanismo de mudança estrutural.

Para mapas sistemáticos formais, o publication gate exige:

- classificação final em dimensões obrigatórias;
- `human_verified` ou `human_consensus`;
- dupla codificação humana quando configurada;
- consenso quando candidatos divergem em dimensão single-valued;
- quality control independente para classificação.

# 5. Coverage, busca e screening

Para `systematic_comprehensive`, o gate valida, entre outros elementos:

- coverage policy explícita;
- número mínimo de fontes bibliográficas;
- fontes e classes obrigatórias declaradas;
- exports quando exigidos;
- search peer review qualificado e independente;
- screening secundário qualificado;
- materialização das decisões de screening para os Reports recuperados;
- bloqueio de desacordos não adjudicados.

A3 não substitui esses controles de etapa.

# 6. Assurance e publication gate

Foram implementadas:

- `product.evidence_map_publication_issues(product_version_uuid)`;
- `product.evidence_map_is_publishable(product_version_uuid)`.

Regra validada:

- mapa publicado não sistemático exige pelo menos A2;
- mapa `systematic_comprehensive`, formal gap ou subtipo sistemático/EGM exige A3;
- A3 permanece insuficiente quando search, screening, classification ou outros controles materiais estão ausentes.

# 7. EvidenceMapView

Schema:

`oes.evidence_map_view/0.1`

Implementação:

`product.evidence_map_view(product_version_uuid)`

A projeção inclui:

- identity;
- question;
- investigation;
- mapping_method;
- framework;
- dimensions;
- categories;
- searches;
- selection_flow;
- map_items;
- assignments;
- classification_controls;
- cell_scope;
- cells;
- distributions;
- gaps;
- concentrations;
- appraisal;
- certainty_links;
- stakeholder_engagement;
- limitations;
- references;
- update_state;
- audit.

Não foi criado template do Mapa nesta etapa.

# 8. Fixture formal sintética

A fixture representa um `evidence_gap_map` sintético com:

- `systematic_comprehensive`;
- `formal_within_scope`;
- `counting_unit_policy=study`;
- uma Investigation N3 de suporte;
- row axis = intervention;
- column axis = outcome;
- filter = geography;
- dois Studies;
- um Report adicional para testar semântica de contagem;
- uma Synthesis;
- duas células populadas;
- uma célula vazia `in_scope` com gap formal;
- uma célula `not_applicable` vazia sem gap;
- duas codificações humanas sintéticas por dimensão obrigatória;
- discordância sintética deliberada resolvida por consenso;
- search peer review sintético;
- dupla seleção sintética;
- classification QC sintético;
- assurance A3 sintético;
- estado `published` exclusivamente para validação do gate.

Todos os atores humanos da fixture são explicitamente fictícios. Nenhum controle sintético deve ser interpretado como revisão humana real.

# 9. Testes

Foram executados os comportamentos do contrato previstos no Documento 125.

Cobertura principal:

- **EM-T01** — fixture formal publishable com A3 + controles;
- **EM-T02** — contagens por tipo;
- **EM-T03** — drill-down reconciliável;
- **EM-T04** — empty in-scope cell gera gap formal;
- **EM-T05** — not_applicable não gera gap;
- **EM-T06** — Report não infla `study_count`;
- **EM-T07** — formal gap + coverage não sistemático bloqueado;
- **EM-T08** — ausência de CellScope bloqueia formal gap;
- **EM-T09** — classificação obrigatória ausente bloqueia;
- **EM-T10** — Assignment cross-framework rejeitado;
- **EM-T11** — duas categorias finais em dimensão single-valued rejeitadas;
- **EM-T12** — dupla codificação humana exigida quando configurada;
- **EM-T13** — discordância sem consenso bloqueia;
- **EM-T14** — IA não pode produzir `human_verified`;
- **EM-T15** — ausência de classification QC bloqueia;
- **EM-T16** — ausência de search peer review bloqueia;
- **EM-T17** — A3 não contorna controles de etapa;
- **EM-T18** — dependência MapItem invalidada bloqueia;
- **EM-T19** — mutação material de Dimension/Category bloqueada;
- **EM-T20** — rebuild preserva contagens, gaps e gate;
- **EM-T21** — reaplicação indevida da migration 016 é detectada;
- **EM-T22** — regressões N0–N4 permanecem verdes no pipeline S5 integrado.

# 10. Rebuild e regressões

O pipeline validou:

- instalação da migration 016 sobre a baseline existente;
- regressões F2-B;
- regressões S4;
- runtime S5;
- N0;
- N1;
- N2;
- N3;
- N4;
- Evidence Map;
- duplicate detection da migration 016;
- rebuild completo do zero através da migration 016.

Resultado:

> **nenhuma regressão prévia foi introduzida pelo contrato do Mapa de Evidências.**

# 11. GitHub Actions

Run de validação:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37464023391**;
- conclusion **success**;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`.

Artifact:

- ID **11413512318**;
- nome `oes-s5-evidence-37464023391`;
- tamanho **112432 bytes**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

# 12. Interpretação

O PASS demonstra que:

> **OES-P1 consegue representar o núcleo científico e de governança de um Mapa de Evidências, acrescentando apenas a camada especializada e versionada `mapping`.**

Também demonstra que:

> **células, contagens, concentrações e gaps podem permanecer derivados e auditáveis até os MapItems de origem, sem criar novas verdades primárias paralelas.**

E:

> **assurance A3 não substitui coverage, search peer review, screening, dupla codificação e classification QC quando esses controles são requeridos pelo tipo de mapa.**

# 13. Limite do PASS

Este resultado é um **PASS técnico sintético**.

Não foi demonstrado:

- Caso Real de Mapa de Evidências;
- adequação de uma busca real a `systematic_comprehensive`;
- qualificação humana real para dupla classificação;
- validade de um formal gap claim em corpus real;
- template/renderização final do produto.

Portanto:

> **o PASS técnico autoriza avançar para o contrato de renderização do EvidenceMapView, não para alegações reais de gap.**

# 14. Decisão

> **Contrato técnico do Mapa de Evidências v0.1 = PASS.**

Próxima etapa:

> **definir o contrato de renderização do EvidenceMapView, preservando a semântica de coverage, counting unit, CellScope, gaps, concentrações, assurance e provenance.**

Somente depois dessa etapa deverá ser especificado e validado o template operacional do Mapa.

---

**Resultado final:** PASS técnico do contrato de dados e da projeção estruturada; template ainda não criado e Caso Real ainda não iniciado.
