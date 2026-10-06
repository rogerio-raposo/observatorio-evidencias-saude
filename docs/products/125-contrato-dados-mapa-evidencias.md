# 125 — Contrato de Dados do Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** contrato de dados candidato  
**Dependências canônicas:** Documentos 04, 10–15, 20–21, 40, 123–124; migrations 001–015

---

# 1. Finalidade

Formalizar as estruturas persistentes, invariantes, projeções e gates do Mapa de Evidências antes da migration 016.

---

# 2. Identidade do produto

Contrato inicial:

- `product_type = evidence_map`;
- exactly one primary Investigation;
- Product cutoff = Investigation cutoff;
- ProductVersion current para publicação;
- exatamente uma FrameworkVersion concreta ligada ao ProductVersion por dependency edge ativa.

---

# 3. Profundidade

`InvestigationVersion.depth_level` continua usando N0–N4.

No Mapa:

> representa a profundidade declarada da investigação de suporte, não o tipo do produto.

O product type permanece transversal.

---

# 4. Framework entity

Novas tabelas:

- `mapping.framework`;
- `mapping.framework_version`.

`mapping.framework.entity_uuid` especializa `core.entity`.

`mapping.framework_version` especializa `core.entity_version`.

---

# 5. FrameworkVersion — campos

Obrigatórios:

- `version_uuid`;
- `entity_uuid`;
- `investigation_version_uuid`;
- `mapping_subtype`;
- `coverage_claim`;
- `gap_claim_mode`;
- `counting_unit_policy`;
- `codebook_artifact_uuid`;
- `classification_policy_payload`;
- `coverage_policy_payload`;
- `gap_rules_payload`;
- `visualization_payload`;
- `stakeholder_payload`;
- `status`.

Condicionais:

- `primary_row_dimension_code`;
- `primary_column_dimension_code`.

---

# 6. `mapping_subtype`

Permitidos:

- scoping_evidence_map;
- systematic_evidence_map;
- evidence_gap_map;
- descriptive_mapping_review;
- other_evidence_map.

---

# 7. `coverage_claim`

Permitidos:

- exploratory;
- structured_non_exhaustive;
- systematic_comprehensive.

---

# 8. `gap_claim_mode`

Permitidos:

- none;
- apparent_only;
- formal_within_scope.

Constraint:

> `formal_within_scope` exige `systematic_comprehensive`.

---

# 9. `counting_unit_policy`

Permitidos:

- study;
- report;
- synthesis;
- mixed.

Essa política define a interpretação das contagens principais.

---

# 10. Coverage policy

`coverage_policy_payload` poderá registrar:

- minimum_bibliographic_sources;
- required_source_names;
- required_source_classes;
- grey_literature_required;
- registry_required;
- supplementary_search_required;
- language_policy;
- date_policy.

Para `systematic_comprehensive`, ausência de política de cobertura é error.

---

# 11. Codebook

`codebook_artifact_uuid` é obrigatório para produto formal.

Artifact deverá estar ativo e possuir hash.

---

# 12. Dimension

Nova tabela:

> `mapping.dimension`

Campos:

- dimension_uuid PK;
- framework_version_uuid FK;
- dimension_code;
- label;
- description;
- dimension_role;
- multi_valued;
- required_flag;
- sequence_no;
- metadata_payload;
- status.

Roles:

- row_axis;
- column_axis;
- filter;
- descriptive.

Unique:

> framework_version_uuid + dimension_code

Somente uma row_axis e uma column_axis ativas por FrameworkVersion em v0.1.

---

# 13. Category

Nova tabela:

> `mapping.category`

Campos:

- category_uuid PK;
- dimension_uuid FK;
- parent_category_uuid;
- category_code;
- label;
- definition;
- sequence_no;
- metadata_payload;
- status.

Parent deve pertencer à mesma dimension.

Unique:

> dimension_uuid + category_code

---

# 14. Imutabilidade estrutural

Dimension e Category são imutáveis dentro da FrameworkVersion.

Não permitir UPDATE/DELETE material.

Mudança exige nova FrameworkVersion.

---

# 15. MapItem

Nova tabela:

> `mapping.map_item`

Campos:

- map_item_uuid PK;
- framework_version_uuid FK;
- target_version_uuid FK `core.entity_version`;
- item_role;
- inclusion_basis_payload;
- included_at;
- status.

Unique:

> framework_version_uuid + target_version_uuid

---

# 16. Tipos de target permitidos v0.1

Inicialmente:

- Study;
- Report;
- Synthesis.

Trigger verificará `core.entity.entity_type`.

Outros tipos exigem extensão explícita futura.

---

# 17. Item role

Permitidos:

- primary_evidence;
- synthesis;
- contextual;
- ongoing;
- other.

---

# 18. Assignment

Nova tabela:

> `mapping.assignment`

Campos:

- assignment_uuid PK;
- map_item_uuid FK;
- category_uuid FK;
- decision_state;
- assigned_by;
- actor_type;
- assignment_method;
- verification_status;
- verified_by;
- verifier_actor_type;
- verified_at;
- rationale_payload;
- assigned_at;
- status.

---

# 19. Decision state

Permitidos:

- candidate;
- final.

`candidate` preserva codificação independente.

`final` alimenta células/contagens.

---

# 20. Actor type

Permitidos:

- ai_system;
- human_reviewer;
- human_expert;
- system.

---

# 21. Assignment method

Permitidos:

- manual;
- ai_assisted;
- rule_based;
- imported;
- consensus.

---

# 22. Verification status

Permitidos:

- unverified;
- ai_verified;
- human_verified;
- human_consensus.

Regras:

- human_verified/human_consensus exigem `verified_by`, verifier humano e `verified_at`;
- ai_verified exige verifier_actor_type=ai_system;
- IA não pode ser registrada como verifier humano.

---

# 23. Framework consistency

Trigger obrigatório:

> Category do Assignment deve pertencer à mesma FrameworkVersion do MapItem.

Assignment cross-framework é error.

---

# 24. Single-valued dimensions

Se `dimension.multi_valued=false`:

> um MapItem pode possuir no máximo uma categoria `final` ativa nessa dimension.

Candidate assignments podem divergir.

---

# 25. Multi-valued dimensions

Se `multi_valued=true`:

> múltiplas categorias final ativas são permitidas.

Cada final representa pertencimento real conforme codebook.

---

# 26. Formal classification controls

Para `systematic_comprehensive` com formal publication:

cada MapItem deverá possuir, em cada dimension `required_flag=true`:

1. pelo menos uma classificação final ativa;
2. classificação final human_verified ou human_consensus;
3. quando `classification_policy_payload.independent_coding=true`, pelo menos dois candidate assignments de atores humanos distintos antes do final.

---

# 27. Classification disagreement

Se candidates em dimension single-valued discordarem:

> final deverá usar `assignment_method=consensus` ou possuir rationale de adjudication/consensus.

Sem final resolvido:

> error.

---

# 28. Classification QualityControlRecord

Reutilizar `investigation.quality_control_record`.

Forma:

- stage=`extraction`;
- control_type=`other`;
- `scope_payload.control_code=map_classification_verification`;
- scope define framework/dimensions/items;
- decision=passed;
- human qualified quando exigido.

Não alterar enumeração global de control_type na migration 016.

---

# 29. ReviewerAssignment

Para mapas formais, reutilizar `investigation.reviewer_assignment`:

- search peer reviewer;
- primary/secondary reviewer para screening;
- data_extractor/data_verifier para coding/classification;
- expert independent reviewer para A3 quando exigido.

Não criar reviewer model paralelo.

---

# 30. CellScope

Nova tabela:

> `mapping.cell_scope`

Campos:

- cell_scope_uuid PK;
- framework_version_uuid FK;
- row_category_uuid FK;
- column_category_uuid FK;
- scope_status;
- gap_eligible;
- rationale;
- metadata_payload.

`scope_status`:

- in_scope;
- not_applicable;
- excluded_by_framework.

---

# 31. CellScope consistency

Triggers devem garantir:

- row category pertence à row_axis da mesma FrameworkVersion;
- column category pertence à column_axis da mesma FrameworkVersion;
- row != column dimension;
- pair unique por FrameworkVersion.

---

# 32. Gap eligibility

`gap_eligible=true` somente permitido quando `scope_status=in_scope`.

Células not_applicable nunca geram gap.

---

# 33. Não persistir cell count

Contagens são derivadas.

Não criar:

- CellCount;
- Density;
- Gap.

---

# 34. Célula derivada

Função candidata:

> `mapping.evidence_map_cells(framework_version_uuid)`

Saída:

- cell_scope_uuid;
- row category;
- column category;
- scope_status;
- gap_eligible;
- study_count;
- report_count;
- synthesis_count;
- other_count;
- total_count;
- counted_unit_count;
- map_item_uuids;
- empty_cell_gap;
- primary_evidence_gap;
- synthesis_gap.

---

# 35. Semântica de contagem

`study_count`: MapItems cujo target entity_type=Study.

`report_count`: target=Report.

`synthesis_count`: target=Synthesis.

`counted_unit_count` segue `counting_unit_policy`.

Em `mixed`, não criar total epistemologicamente homogêneo como principal sem disclosure; exibir counts por tipo.

---

# 36. Reports e Studies

Quando counting_unit_policy=study:

> Reports adicionais não podem aumentar study_count.

Study/Report linkage existente será a referência canônica.

---

# 37. Empty cell gap

Derivado somente quando:

- scope_status=in_scope;
- gap_eligible=true;
- counted_unit_count=0;
- gap_claim_mode permite gap.

---

# 38. Apparent gap

Se gap_claim_mode=apparent_only:

> cell flag deve ser rotulada `apparent_gap`, não formal gap.

Presentation deverá carregar disclaimer de cobertura.

---

# 39. Formal gap

`formal_within_scope` exige:

- systematic_comprehensive;
- protocolo;
- coverage policy satisfeita;
- search/screening completos;
- required classifications final/verified;
- CellScope;
- classification QC;
- assurance exigida;
- data de corte.

---

# 40. Synthesis gap

Derivar somente se:

- `gap_rules_payload.derive_synthesis_gap=true`;
- existe primary evidence na célula;
- não existe Synthesis MapItem classificada na célula;
- cell gap_eligible.

Não inferir automaticamente que revisão sistemática é necessária.

---

# 41. Quality/certainty gaps

Não implementar como padrão v0.1.

Somente habilitar no futuro quando:

- appraisal/certainty estiver metodologicamente disponível;
- rules forem explícitas;
- semântica de gap estiver definida.

---

# 42. Dependency graph

ProductVersion → FrameworkVersion:

`dependency_type = map_framework_informs_product`

Map evidence target → FrameworkVersion:

`dependency_type = mapped_evidence_informs_framework`

Ambas ativas.

---

# 43. Framework link invariant

ProductVersion evidence_map formal exige exatamente uma dependency edge ativa:

> source=FrameworkVersion → target=ProductVersion / map_framework_informs_product

---

# 44. Search requirements

Para `systematic_comprehensive`:

- completed Searches compatíveis com coverage_policy;
- minimum bibliographic sources satisfeito quando definido;
- required sources/classes satisfeitos;
- exports quando exigidos;
- search peer review quando protocolo/assurance exigir.

Para exploratory/structured_non_exhaustive:

- busca deve ser rastreável;
- limitações obrigatórias;
- formal gap claim proibido.

---

# 45. Screening

Formal systematic map/EGM deverá cumprir controles de seleção definidos no protocolo.

Gate candidato exige:

- screening decisions para hits materializados;
- full-text exclusion reason;
- qualified controls quando formal coverage/gap claim.

Não duplicar Screening table.

---

# 46. Framework dimensions

Para matriz v0.1 formal:

- exatamente uma row_axis ativa;
- exatamente uma column_axis ativa;
- codes coincidem com FrameworkVersion;
- ambas possuem ao menos uma category ativa.

Mapas sem matriz poderão existir futuramente, mas fixture v0.1 será matricial.

---

# 47. Required dimensions

Todo MapItem ativo precisa classificação final nas dimensions required.

Item sem classificação obrigatória:

> error para publicação formal.

---

# 48. Product type e status

`product_type = evidence_map`.

Formal publication:

- ProductVersion current;
- status=published;
- publication_date não nula;
- active CurrencyState.

---

# 49. Assurance — mapa não sistemático

Para published map com:

- coverage exploratory/structured_non_exhaustive;
- gap mode none/apparent_only;
- sem rótulo systematic/EGM formal;

regra candidata:

> **mínimo A2**

com disclosure de ausência de expert review quando A3 não existir.

Internal map poderá permanecer A1 e não published.

---

# 50. Assurance — systematic map / EGM formal

Quando:

- coverage=systematic_comprehensive; ou
- gap_claim_mode=formal_within_scope; ou
- subtype=systematic_evidence_map/evidence_gap_map com alegação formal;

exigir:

> **A3 + human-qualified stage controls aplicáveis.**

A3 isolada não bypassa busca/seleção/classificação.

---

# 51. Publication issues — identidade/framework

Errors candidatos:

- MISSING_PRODUCT_VERSION;
- WRONG_PRODUCT_TYPE;
- MISSING_PRIMARY_INVESTIGATION;
- MULTIPLE_PRIMARY_INVESTIGATIONS;
- CUTOFF_MISMATCH;
- MISSING_MAP_FRAMEWORK;
- MULTIPLE_MAP_FRAMEWORKS;
- MISSING_CODEBOOK;
- INVALID_MAPPING_SUBTYPE;
- INVALID_COVERAGE_GAP_COMBINATION;
- MISSING_ROW_DIMENSION;
- MISSING_COLUMN_DIMENSION;
- MISSING_ACTIVE_CATEGORY.

---

# 52. Publication issues — busca/seleção

- MISSING_SEARCH_RECORD;
- INSUFFICIENT_DECLARED_COVERAGE;
- MISSING_REQUIRED_SEARCH_SOURCE;
- MISSING_SEARCH_EXPORT quando requerido;
- MISSING_SEARCH_PEER_REVIEW quando requerido;
- INCOMPLETE_SCREENING;
- MISSING_FULLTEXT_EXCLUSION_REASON;
- UNRESOLVED_SCREENING_DISAGREEMENT.

---

# 53. Publication issues — classificação

- MISSING_MAP_ITEM_CLASSIFICATION;
- CATEGORY_FRAMEWORK_MISMATCH;
- MULTIPLE_FINAL_SINGLE_VALUE_ASSIGNMENTS;
- UNVERIFIED_FORMAL_CLASSIFICATION;
- INSUFFICIENT_INDEPENDENT_CODING;
- UNRESOLVED_CLASSIFICATION_DISAGREEMENT;
- MISSING_CLASSIFICATION_QC.

---

# 54. Publication issues — cells/gaps

- MISSING_CELL_SCOPE;
- INVALID_CELL_SCOPE;
- FORMAL_GAP_WITH_NON_SYSTEMATIC_COVERAGE;
- GAP_ELIGIBLE_OUTSIDE_SCOPE;
- CELL_COUNT_DRILLDOWN_MISMATCH.

---

# 55. Publication issues — governança

- MISSING_CURRENCY_STATE;
- MISSING_AI_METHODOLOGICAL_VERIFICATION;
- MISSING_OWNER_APPROVAL;
- MISSING_EXPERT_INDEPENDENT_REVIEW quando A3 requerido;
- ASSURANCE_BELOW_REQUIRED_LEVEL;
- MISSING_PUBLICATION_DATE;
- INVALIDATED_DEPENDENCY;
- ACTIVE_REVISE_OR_FAILED_CONTROL.

---

# 56. Warnings candidatos

- NON_EXHAUSTIVE_MAP;
- APPARENT_GAPS_ONLY;
- NO_CRITICAL_APPRAISAL;
- NO_CERTAINTY_DISPLAY;
- NO_STAKEHOLDER_ENGAGEMENT;
- GREY_LITERATURE_LIMITED;
- NO_UPDATE_PLAN;
- NO_LOCAL_EVIDENCE;
- AI_ASSISTED_CLASSIFICATION;
- UNVERIFIED_OPTIONAL_CLASSIFICATION.

---

# 57. EvidenceMapView

Schema:

> `oes.evidence_map_view/0.1`

Seções:

- schema_version;
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

---

# 58. Audit

Incluir:

- assurance_level;
- required_assurance_level;
- publishable;
- coverage_claim;
- gap_claim_mode;
- framework_version_uuid;
- framework_version_no;
- counting_unit_policy;
- classification completeness;
- formal gap eligibility;
- search controls;
- classification controls;
- invalidated dependencies;
- publication issues;
- assurance records.

---

# 59. Fixture formal candidata

Fixture v0.1:

- product_type evidence_map;
- subtype evidence_gap_map;
- coverage systematic_comprehensive;
- gap mode formal_within_scope;
- counting unit study;
- depth declarada N3 ou N4 conforme Investigation de fixture;
- row axis intervention;
- column axis outcome;
- filtro geography;
- 2 Studies;
- 1 Synthesis;
- 1 not_applicable cell;
- 1 populated cell;
- 1 empty in-scope gap cell;
- candidate codings por dois humanos sintéticos;
- final consensus assignments;
- classification QC;
- systematic search/screening sintéticos;
- A3 sintético;
- published synthetic fixture.

---

# 60. Fixture exploratória candidata

Opcional após formal fixture:

- structured_non_exhaustive;
- apparent_only;
- AI-assisted classifications;
- A1/A2;
- non-published ou published A2 conforme cenário;
- gaps rotulados aparentes.

Não necessária para primeira migration se testes transacionais cobrirem o comportamento.

---

# 61. Testes mínimos

Provar:

1. formal fixture publishable com A3 + controls;
2. EvidenceMapView counts corretos;
3. drill-down = count;
4. empty in-scope cell = formal gap;
5. not_applicable empty cell != gap;
6. report não infla study_count;
7. formal gap + structured_non_exhaustive bloqueia;
8. formal gap sem CellScope bloqueia;
9. missing required dimension classification bloqueia;
10. cross-framework assignment rejeitado;
11. two final categories em single-valued dimension rejeitadas;
12. independent coding exigido quando configurado;
13. disagreement sem consensus bloqueia;
14. AI cannot human-verify;
15. missing classification QC bloqueia formal map;
16. missing search control bloqueia formal map;
17. A3 não bypassa stage controls;
18. invalidated MapItem dependency bloqueia;
19. framework child mutation é bloqueada;
20. rebuild preserva counts/gaps;
21. migration duplicate detection;
22. regressões N0–N4.

---

# 62. Migration candidata

> `database/016_evidence_map_contract.sql`

DDL:

- schema `mapping`;
- framework;
- framework_version;
- dimension;
- category;
- map_item;
- assignment;
- cell_scope;
- guards/triggers/indexes;
- cell/gap helpers;
- gate;
- EvidenceMapView.

---

# 63. Próxima etapa

> **Implementar migration 016, fixture formal sintética, testes e rebuild; integrar ao S5.**

Não criar template antes do PASS técnico do contrato.

---

**Resultado:** contrato de dados v0.1 do Mapa de Evidências consolidado; implementação autorizada.