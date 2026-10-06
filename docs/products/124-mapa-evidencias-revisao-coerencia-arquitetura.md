# 124 — Mapa de Evidências: Revisão de Coerência e Decisão Arquitetural Inicial

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** decisão arquitetural inicial  
**Dependências canônicas:** Documentos 02–04, 10–15, 20–21, 40, 123; migrations 001–015

---

# 1. Objetivo

Determinar como representar um Mapa de Evidências de forma normalizada, auditável e versionável, reutilizando o núcleo científico OES-P1 e criando somente as estruturas necessárias à classificação cartográfica.

Pergunta arquitetural:

> **O mapa exige um novo modelo de evidência ou apenas uma camada versionada de classificação sobre as entidades científicas já existentes?**

Resposta:

> **OES-P1 já contém a evidência. O Mapa exige uma camada própria de framework/classificação, não um segundo modelo científico.**

---

# 2. Decisão principal

Reutilizar integralmente:

- Question/Investigation;
- Search/SearchHit/Dedup/Screening;
- Study/Report/Result;
- RiskAssessment;
- Synthesis;
- CertaintyAssessment;
- Artifact;
- Provenance/dependency graph;
- ReviewerAssignment;
- QualityControlRecord;
- Assurance/ProductVersion/CurrencyState.

Criar schema lógico candidato:

> `mapping`

com estruturas mínimas para:

- framework versionado;
- dimensões;
- categorias;
- itens incluídos no mapa;
- assignments item→categoria;
- escopo das células primárias.

---

# 3. Princípio epistemológico

O mapa não deverá persistir uma matriz como fonte primária.

A fonte primária será:

> **evidence units + framework version + classifications.**

Matriz, bubbles, heatmaps, contagens e gaps serão projeções derivadas.

---

# 4. Por que não usar apenas JSONB

Um único JSONB de mapa seria simples, mas inadequado para:

- drill-down por célula;
- filtros;
- versionamento de categorias;
- reconstrução histórica;
- auditoria de classificações;
- reclassificação controlada;
- invalidation/impact analysis;
- cálculo confiável de gaps;
- atualização M1–M3.

JSONB continuará útil para metadata/rules, não como único repositório da classificação.

---

# 5. Nova entidade — MapFramework

Proposta:

- `mapping.framework`;
- `mapping.framework_version`.

`framework` especializa `core.entity`.

`framework_version` especializa `core.entity_version`.

Um framework representa:

- subtype do mapa;
- regra de cobertura;
- unidade primária de contagem;
- política de gaps;
- eixos primários;
- filtros;
- codebook;
- visualização padrão;
- versão metodológica.

---

# 6. Campos candidatos de `mapping.framework_version`

- `version_uuid`;
- `entity_uuid`;
- `investigation_version_uuid`;
- `mapping_subtype`;
- `coverage_claim`;
- `gap_claim_mode`;
- `counting_unit_policy`;
- `codebook_artifact_uuid`;
- `primary_row_dimension_code`;
- `primary_column_dimension_code`;
- `classification_policy_payload`;
- `gap_rules_payload`;
- `visualization_payload`;
- `stakeholder_payload`;
- `status`.

---

# 7. `mapping_subtype`

Vocabulário inicial:

- `scoping_evidence_map`;
- `systematic_evidence_map`;
- `evidence_gap_map`;
- `descriptive_mapping_review`;
- `other_evidence_map`.

---

# 8. `coverage_claim`

Vocabulário candidato:

- `exploratory`;
- `structured_non_exhaustive`;
- `systematic_comprehensive`.

Função:

> tornar explícita a força da alegação de cobertura independentemente do layout visual.

---

# 9. `gap_claim_mode`

Vocabulário candidato:

- `none`;
- `apparent_only`;
- `formal_within_scope`.

Regras candidatas:

- exploratory → none/apparent_only;
- structured_non_exhaustive → none/apparent_only;
- systematic_comprehensive → pode usar formal_within_scope se demais controles passarem.

---

# 10. Dimensões

Nova tabela candidata:

> `mapping.dimension`

Campos:

- `dimension_uuid`;
- `framework_version_uuid`;
- `dimension_code`;
- `label`;
- `description`;
- `dimension_role`;
- `multi_valued`;
- `required_flag`;
- `sequence_no`;
- `metadata_payload`;
- `status`.

`dimension_role`:

- `row_axis`;
- `column_axis`;
- `filter`;
- `descriptive`.

---

# 11. Categorias

Nova tabela candidata:

> `mapping.category`

Campos:

- `category_uuid`;
- `dimension_uuid`;
- `parent_category_uuid`;
- `category_code`;
- `label`;
- `definition`;
- `sequence_no`;
- `metadata_payload`;
- `status`.

Hierarquia permite categorias/subcategorias sem codificar árvore em texto.

---

# 12. Versionamento de dimensões/categorias

Dimensões/categorias serão imutáveis dentro de uma FrameworkVersion.

Alteração material exige:

> nova `framework_version` + novo conjunto de child rows.

Isso evita editar silenciosamente uma taxonomia usada por produto publicado.

---

# 13. MapItem

Nova tabela candidata:

> `mapping.map_item`

Função:

> declarar quais versões de entidades científicas pertencem ao mapa e qual papel possuem.

Campos:

- `map_item_uuid`;
- `framework_version_uuid`;
- `target_version_uuid`;
- `item_role`;
- `inclusion_basis_payload`;
- `status`;
- `included_at`.

---

# 14. Target de MapItem

`target_version_uuid` referencia `core.entity_version`.

Isso permite mapear, conforme protocolo:

- StudyVersion;
- ReportVersion;
- SynthesisVersion;
- outras entidades científicas versionadas permitidas futuramente.

O tipo real será validado por guard.

---

# 15. `item_role`

Vocabulário candidato:

- `primary_evidence`;
- `synthesis`;
- `contextual`;
- `ongoing`;
- `other`.

A unidade contada continua sendo definida pelo framework.

---

# 16. Assignment

Nova tabela candidata:

> `mapping.assignment`

Função:

> vincular MapItem a uma categoria do framework.

Campos:

- `assignment_uuid`;
- `map_item_uuid`;
- `category_uuid`;
- `assigned_by`;
- `actor_type`;
- `assignment_method`;
- `verification_status`;
- `rationale_payload`;
- `assigned_at`;
- `status`.

---

# 17. Assignment method

Vocabulário candidato:

- `manual`;
- `ai_assisted`;
- `rule_based`;
- `imported`;
- `consensus`.

---

# 18. Verification status

Vocabulário candidato:

- `unverified`;
- `ai_verified`;
- `human_verified`;
- `human_consensus`.

Esse campo descreve verificação da classificação; não substitui Assurance do produto.

---

# 19. CellScope

Nova tabela candidata:

> `mapping.cell_scope`

Função:

> declarar quais combinações do eixo primário são metodologicamente interpretáveis e podem gerar gap.

Campos:

- `cell_scope_uuid`;
- `framework_version_uuid`;
- `row_category_uuid`;
- `column_category_uuid`;
- `scope_status`;
- `gap_eligible`;
- `rationale`;
- `metadata_payload`.

---

# 20. Por que CellScope é necessário

Sem CellScope, todo cruzamento vazio de categorias poderia ser tratado como gap.

Isso geraria falsos gaps em combinações:

- conceitualmente impossíveis;
- fora de escopo;
- não aplicáveis;
- deliberadamente excluídas.

Portanto:

> **zero count só pode gerar empty-cell gap se a célula estiver explicitamente in_scope e gap_eligible.**

---

# 21. Não criar tabela Gap

Decisão inicial:

> **não persistir `mapping.gap`.**

Gap é estado derivado de:

- FrameworkVersion;
- CellScope;
- MapItems;
- Assignments;
- gap rules;
- data de corte.

Persistir gap separadamente criaria risco de divergência após inclusão/reclassificação de evidência.

---

# 22. Tipos de gap derivados

View/funções poderão derivar:

- empty_cell_gap;
- primary_evidence_gap;
- synthesis_gap;
- population_gap;
- outcome_gap;
- geographic_gap;
- design_gap.

`quality_gap` e `certainty_gap` somente quando o framework declarar bases metodológicas para isso.

---

# 23. Evidence concentration

Também será derivada.

Não persistir classificação genérica de densidade como verdade primária.

Framework poderá possuir thresholds de apresentação em `visualization_payload`, mas:

- counts permanecem canônicos;
- labels low/medium/high são presentation rules versionadas.

---

# 24. Produto e framework exato

ProductVersion deverá depender de uma FrameworkVersion concreta.

Não criar tabela de link inicialmente.

Usar:

> `provenance.dependency_edge`

com tipo candidato:

> `map_framework_informs_product`

Isso preserva a versão exata usada pelo produto.

---

# 25. MapItem e lineage

Cada MapItem deverá gerar dependency edge:

> `target_version_uuid → framework_version_uuid`

tipo candidato:

> `mapped_evidence_informs_framework`

Assim uma invalidação upstream poderá propagar impacto ao mapa/produto.

---

# 26. Investigation

Mapa permanece ligado a uma Investigation primária.

O campo `depth_level` existente continuará obrigatório como:

> **profundidade declarada da investigação que sustenta o produto transversal**

e não como identidade do produto.

O `mapping_subtype` e `coverage_claim` são independentes do N declarado.

Não alterar o CHECK N0–N4 nesta etapa.

---

# 27. Busca e seleção

Reutilizar integralmente:

- investigation.search;
- search_hit;
- dedup_cluster;
- screening_decision;
- method_decision;
- quality_control_record;
- reviewer_assignment quando necessário.

Não criar Search/Screening próprios do mapa.

---

# 28. Codebook

Codebook será Artifact.

`framework_version.codebook_artifact_uuid` referencia o artifact canônico.

Pode conter:

- definições;
- exemplos;
- regras de múltipla classificação;
- handling de ambiguidade;
- categorias residuais;
- calibration guidance.

---

# 29. Stakeholder engagement

Não criar tabela dedicada em v0.1.

Representar por:

- `stakeholder_payload` no FrameworkVersion;
- artifacts de workshop/consenso;
- provenance/MethodDecision quando material.

Reavaliar entidade própria se uso se tornar recorrente/complexo.

---

# 30. Critical appraisal

Reutilizar RiskAssessment existente.

Mapa poderá:

- não usar appraisal;
- mostrar appraisal pré-existente;
- executar appraisal próprio conforme protocolo.

Framework deverá declarar `appraisal_mode`:

- none;
- reuse_existing;
- map_specific_required.


---

# 31. Certainty

Reutilizar CertaintyAssessment.

Não criar certainty do mapa.

Framework poderá declarar `certainty_display_mode`:

- none;
- linked_only;
- filter.

---

# 32. EvidenceMapView

Nome proposto:

> **EvidenceMapView**

Schema candidato:

> `oes.evidence_map_view/0.1`

Seções:

- identity;
- question;
- investigation;
- mapping_method;
- coverage_claim;
- gap_claim_mode;
- protocol;
- framework;
- dimensions;
- categories;
- searches;
- selection_flow;
- coding_controls;
- map_items;
- assignments;
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

---

# 33. Cells na view

`cells` será projeção derivada.

Cada célula poderá conter:

- row category;
- column category;
- scope status;
- gap eligibility;
- study_count;
- report_count;
- synthesis_count;
- other_count;
- total_count;
- linked item IDs;
- derived gap flags.

---

# 34. Drill-down

Requisito:

> toda contagem exibida deverá permitir recuperar os MapItems que a originam.

Mesmo em visualização agregada, a view deve preservar item identifiers.

---

# 35. Formal gap claim

`formal_within_scope` só poderá publicar quando:

- coverage_claim=systematic_comprehensive;
- protocolo ativo;
- busca/seleção compatíveis com o método;
- CellScope explícito;
- framework/codebook versionado;
- classification controls satisfeitos;
- assurance requerido satisfeito;
- data de corte registrada.

---

# 36. Apparent gap

`apparent_only` poderá ser usado por mapa exploratório/structured_non_exhaustive.

A apresentação deverá usar linguagem:

> **nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação**

e nunca:

> **não existe evidência**.

---

# 37. Assurance — decisão inicial

Assurance será condicionado por coverage/gap claim.

Proposta:

## Exploratory / structured_non_exhaustive

- A1/A2 possível;
- gaps apenas apparent;
- sem rótulo systematic map/EGM formal.

## Systematic comprehensive + formal gap claims

- A3 candidato obrigatório;
- controles humanos qualificados de busca/seleção/classificação;
- revisão especializada independente.

A regra final será formalizada no contrato de dados.

---

# 38. IA e classificação

AI-assisted assignment é permitido.

Para mapa formal:

- assignment method deve permanecer visível;
- categorias críticas devem ter verification proporcional;
- baixa confiança/ambiguidade deve ser roteada a humano qualificado quando protocolo exigir;
- IA não pode transformar `unverified` em `human_verified`.

---

# 39. Classification disagreement

Não criar tabela específica em v0.1.

Preservar via:

- assignments independentes quando requeridos;
- provenance;
- QualityControlRecord;
- supersession/consensus assignment.

Se fixture/caso real mostrar insuficiência, reavaliar.

---

# 40. Atualização

Nova evidência pode adicionar MapItems/Assignments dentro da mesma FrameworkVersion quando o framework não muda.

Mudança de framework exige nova FrameworkVersion.

ProductVersion deverá distinguir:

- evidence_update;
- framework_change;
- coding_correction;
- editorial_change.

---

# 41. Framework change

Uma mudança de categorias pode alterar:

- células;
- contagens;
- gaps;
- concentrações.

Portanto:

> **comparações entre versões deverão sempre identificar FrameworkVersion.**

---

# 42. Visualização

Não persistir imagem/dashboard como fonte científica.

Visualization config em FrameworkVersion + EvidenceMapView alimentará:

- Markdown/tabular output;
- dashboards;
- interactive matrix;
- future UI widget.

Rendered artifact poderá ser persistido por ProductVersion.

---

# 43. Tabelas novas candidatas

1. `mapping.framework`;
2. `mapping.framework_version`;
3. `mapping.dimension`;
4. `mapping.category`;
5. `mapping.map_item`;
6. `mapping.assignment`;
7. `mapping.cell_scope`.

Total inicial:

> **7 tabelas especializadas de classificação/mapa.**

---

# 44. Tabelas explicitamente não propostas

Não criar:

- MapStudy;
- MapReport;
- MapResult;
- MapSynthesis;
- MapCertainty;
- MapSearch;
- MapScreening;
- Gap;
- Concentration;
- CellCount;
- VisualizationData.

Esses conceitos são reutilizados ou derivados.

---

# 45. Migration candidata

Após contrato de dados:

> `database/016_evidence_map_contract.sql`

DDL previsto:

- schema mapping;
- 7 tabelas;
- mutation guards;
- type guards;
- helper functions;
- gap/cell projections;
- publication gate;
- EvidenceMapView.

---

# 46. Fixture candidata

Fixture inicial deverá demonstrar:

- evidence_gap_map;
- systematic_comprehensive;
- formal_within_scope;
- duas dimensões primárias;
- filtros adicionais;
- hierarquia simples;
- dois Studies;
- uma Synthesis;
- pelo menos uma célula populada;
- uma célula formalmente vazia/gap;
- uma célula not_applicable vazia que **não** gera gap;
- drill-down;
- codebook;
- search/screening;
- classification controls;
- A3 sintético para mapa formal.

---

# 47. Testes adversariais mínimos

Provar que:

- célula vazia fora de escopo não vira gap;
- gap formal não publica com coverage não sistemática;
- gap formal não publica sem CellScope;
- Report duplicado do mesmo Study não infla Study count;
- assignment de categoria de outro framework é rejeitado;
- MapItem de tipo não permitido é rejeitado;
- alteração de categoria dentro da mesma FrameworkVersion é bloqueada;
- framework change exige nova versão;
- AI assignment não se torna human_verified;
- A3 não bypassa search/coding controls;
- invalidated item bloqueia/afeta mapa;
- drill-down reconcilia com count.

---

# 48. Decisão

> **OES-P1 é adequado ao Mapa de Evidências mediante uma camada especializada de classificação versionada.**

> **Células, gaps e concentrações serão derivados; não serão novas fontes primárias.**

> **A migration ainda não está autorizada: primeiro deverá existir Contrato de Dados do Mapa.**

---

# 49. Próxima etapa

> **Criar o Documento 125 — Contrato de Dados do Mapa de Evidências.**

O contrato deverá formalizar:

- product_type;
- mapping subtype;
- coverage/gap modes;
- schema mapping;
- invariantes das 7 tabelas;
- allowed target types;
- count semantics;
- cell derivation;
- gap derivation;
- classification verification;
- assurance/gate;
- EvidenceMapView;
- fixture/testes.

---

**Resultado:** decisão arquitetural inicial do Mapa de Evidências consolidada; nenhuma migration criada nesta etapa.