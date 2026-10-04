# 44 — EvidenceSheetView: Contrato de Renderização da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato de renderização inicial  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 40–43  
**Baseline:** OES-P1 + migration 006

---

# 1. Finalidade

Definir a projeção estruturada que alimentará o template operacional da Ficha de Evidência.

O objeto será denominado:

> **EvidenceSheetView**

Ele é uma representação derivada.

Não é:

- entidade científica;
- nova fonte canônica;
- substituto de ProductVersion;
- substituto de Synthesis/Certainty;
- armazenamento paralelo da Ficha.

---

# 2. Decisão de implementação

A implementação de referência será:

`product.evidence_sheet_view(product_version_uuid) → jsonb`

Motivos:

- a saída é naturalmente aninhada;
- resultados e certainty são coleções;
- histórico e audit trail também são coleções;
- um SQL view tabular simples exigiria múltiplas linhas ou duplicação;
- JSONB é apropriado como projeção, sem se tornar fonte de verdade.

A função será:

- `STABLE`;
- somente leitura;
- determinística para o mesmo estado do banco;
- construída exclusivamente a partir de entidades canônicas.

---

# 3. Versionamento do contrato

O objeto deverá incluir:

`schema_version = "oes.evidence_sheet_view/0.1"`

Esse versionamento é diferente de:

- ProductVersion;
- versão metodológica;
- versão do template.

Mudança incompatível no contrato de renderização deverá alterar `schema_version`.

---

# 4. Estrutura de topo

```text
EvidenceSheetView
├── schema_version
├── identity
├── question
├── routing
├── method
├── evidence_base
├── priority_results[]
├── risk_of_bias
├── certainty_assessments[]
├── safety
├── limitations
├── applicability
├── conclusion
├── update_history
├── references[]
└── audit
```

---

# 5. identity

Campos:

- product_id;
- product_entity_uuid;
- product_version_uuid;
- version_no;
- product_type;
- title;
- intended_audience;
- editorial_status;
- entity_version_status;
- publication_date;
- evidence_cutoff_date;
- currency_status;
- currency_assessed_at.

Fontes:

- core.entity;
- core.entity_version;
- product.product_version;
- product.current_currency_state.

---

# 6. question

Campos:

- question_id;
- question_entity_uuid;
- question_version_uuid;
- original_text;
- normalized_text;
- question_type;
- structure_type;
- context;
- time_horizon.

Fonte:

- Investigation primary;
- InvestigationQuestion primary;
- QuestionVersion.

Regra:

a versão exibida da pergunta deverá ser a QuestionVersion vinculada à Investigation primary.

---

# 7. routing

Campos:

- investigation_id;
- investigation_entity_uuid;
- investigation_version_uuid;
- investigation_type;
- depth_level;
- maintenance_level;
- objective;
- start_date;
- evidence_cutoff_date.

Fonte:

- product.investigation_link role=primary;
- investigation.investigation_version.

---

# 8. method

Objeto:

```text
method
├── searches[]
├── last_search_at
├── screening_summary
├── synthesis_methods[]
└── certainty_frameworks[]
```

## 8.1 searches

Cada item:

- search_id;
- source_name;
- platform;
- executed_at;
- result_count;
- strategy_version;
- status.

A estratégia completa não precisa estar no payload padrão; permanece auditável no Search.

## 8.2 last_search_at

Maior `executed_at` entre searches da Investigation primary.

## 8.3 screening_summary

Contagens derivadas por:

- stage;
- decision.

Não pretende substituir fluxo PRISMA.

## 8.4 synthesis_methods

Lista das Syntheses vinculadas ao ProductVersion:

- synthesis_type;
- synthesis_origin;
- method;
- model;
- software;
- software_version.

## 8.5 certainty_frameworks

Lista distinta dos frameworks vinculados.

---

# 9. evidence_base

Campos:

- study_count;
- report_count;
- study_designs[];
- included_studies[];
- included_reports[].

## 9.1 Regra de contagem

Study será contado por identidade.

Report será contado separadamente.

Não somar publicações como se fossem estudos distintos.

## 9.2 included_studies

Representação mínima:

- study_id;
- study_entity_uuid;
- study_type;
- design;
- title_or_label;
- sample_size.

## 9.3 included_reports

Representação mínima:

- report_id;
- report_entity_uuid;
- report_type;
- title;
- publication_date;
- publication_status.

---

# 10. priority_results

Coleção ordenada pelas ligações ProductSynthesis.

Cada item:

```text
priority_result
├── role
├── sequence_no
├── synthesis
├── outcome
├── result_summary
├── contributing_studies
├── contributing_results
└── certainty
```

## 10.1 synthesis

- synthesis_id;
- synthesis_version_uuid;
- synthesis_type;
- synthesis_origin;
- population;
- comparison;
- timepoint;
- estimand;
- method;
- model;
- result_summary.

## 10.2 outcome

Quando houver:

- outcome_id;
- preferred_name;
- definition;
- direction_of_benefit.

## 10.3 contributing_studies

Contagem distinta de Study.

## 10.4 contributing_results

Contagem de ResultVersions contribuindo à Synthesis.

## 10.5 certainty

Quando existir CertaintyAssessment vinculada àquela Synthesis:

- certainty_id;
- certainty_version_uuid;
- framework;
- framework_version;
- final_level;
- evidence_state;
- assessment_date;
- domains[].

Quando não existir:

```json
{
  "formal_assessment": false,
  "display": "não avaliada formalmente"
}
```

Quando `evidence_state=no_evidence`:

- não renderizar como `very_low`;
- comunicar estado próprio.

---

# 11. risk_of_bias

Objeto resumido:

- assessment_count;
- frameworks[];
- overall_judgements[];
- assessments[].

Cada assessment mínimo:

- risk_assessment_id;
- version_uuid;
- framework;
- target_entity_uuid;
- outcome_entity_uuid;
- overall_judgement;
- assessment_date;
- verification_status.

A view não produzirá score agregado.

---

# 12. certainty_assessments

Além da certainty embutida em cada priority_result, a view deverá expor lista completa das CertaintyAssessmentVersions vinculadas ao produto.

Motivo:

- auditabilidade;
- casos qualitativos;
- certainty sem Synthesis tradicional;
- múltiplas unidades.

Campos:

- certainty_id;
- version_uuid;
- framework;
- final_level;
- evidence_state;
- synthesis_version_uuid;
- outcome_entity_uuid;
- review_finding_version_uuid, quando existente;
- assessment_date;
- domains[].

---

# 13. safety

Na versão 0.1:

- será coleção derivada de ProductSynthesis links cujo `role` indique safety/harms;
- se não houver papel correspondente, retorna array vazio;
- não inferir segurança pela ausência de itens.

Estados possíveis de apresentação:

- resultados de segurança disponíveis;
- não aplicável;
- não avaliado especificamente.

A taxonomia fina de roles será consolidada junto ao template.

---

# 14. limitations

Fonte:

`ProductVersion.limitations_summary`

Objeto:

- summary;
- present boolean.

Limitations é material interpretativo do produto e não será reconstruído por algoritmo a partir dos domínios metodológicos.

---

# 15. applicability

Fonte inicial:

`ProductVersion.applicability_summary`

Objeto:

- summary;
- formal_assessment: false.

Quando ApplicabilityAssessment for implementado futuramente, o contrato poderá evoluir sem alterar a natureza da Ficha.

---

# 16. conclusion

Objeto:

- text;
- recommendation_present: false.

A função não tentará classificar semanticamente frases como recomendação nesta primeira versão.

O gate editorial continuará responsável por impedir recomendação normativa indevida.

---

# 17. update_history

Objeto:

```text
update_history
├── change_classes[]
├── currency_history[]
├── predecessor_version_uuid
└── current_version_no
```

## 17.1 change_classes

Fonte:

- product.version_change_class.

## 17.2 currency_history

Fonte:

- product.currency_state.

Ordenação:

`assessed_at ASC, currency_state_uuid ASC`.

## 17.3 predecessor

Fonte:

- core.entity_version.supersedes_version_uuid.

---

# 18. references

Derivar Reports efetivamente utilizados em Results que contribuem para Syntheses vinculadas ao ProductVersion.

Campos:

- report_id;
- title;
- publication_date;
- publication_status;
- source_locations[].

A lista é científica/auditável, não necessariamente a bibliografia editorial final.

---

# 19. audit

Objeto:

- publishable;
- publication_issues[];
- reviews[];
- linked_investigations[];
- linked_syntheses[];
- linked_certainty_assessments[];
- lineage_available.

## 19.1 publication_issues

Resultado direto de:

`product.evidence_sheet_publication_issues(...)`

## 19.2 reviews

- reviewer;
- role;
- independent;
- decision;
- reviewed_at;
- status.

## 19.3 lineage_available

Boolean derivado da presença de dependency edges relevantes.

Não significa que toda provenance possível esteja completa; apenas que existe grafo de lineage para a versão.

---

# 20. Null, vazio e não aplicável

Regras:

- coleção sem itens → `[]`;
- objeto opcional ausente → `null`;
- texto não formalizado → `null`;
- certainty não avaliada → objeto explícito de “não avaliada formalmente”;
- no_evidence → estado científico explícito;
- não usar string vazia como substituto de null.

---

# 21. Ordenação determinística

Para permitir testes e renderização reproduzível:

- priority_results: `sequence_no NULLS LAST`, depois synthesis_version_uuid;
- searches: `executed_at`, depois search_uuid;
- studies: oes_id;
- reports: publication_date, oes_id;
- certainty domains: sequence_no, domain_code;
- reviews: reviewed_at, review_uuid;
- currency history: assessed_at, currency_state_uuid;
- change classes: sequence_no, change_class.

---

# 22. Conteúdo proibido na view

A função não deverá:

- recalcular meta-análise;
- recalcular certainty;
- criar julgamento de Risk of Bias;
- inferir recomendação;
- inventar efeito absoluto;
- escolher outcomes;
- alterar estado;
- gravar ProductVersion;
- copiar texto gerado por IA como evidência.

Ela apenas projeta o estado já persistido.

---

# 23. Consistência temporal

A view poderá incluir dados de versões historicamente específicas vinculadas ao ProductVersion.

Não deverá substituir automaticamente por “última versão” de Synthesis/Certainty.

Regra:

> **ProductVersion aponta para versões concretas; EvidenceSheetView respeita essas versões.**

Isso preserva reprodutibilidade histórica.

---

# 24. Regras para fontes externas e certainty herdada

Quando a Ficha reutilizar certainty de fonte externa previamente internalizada:

- framework e origem deverão permanecer rastreáveis;
- a view apenas apresenta o CertaintyAssessment registrado;
- não presumirá equivalência se o registro não existir.

---

# 25. Camada Brasil

A versão 0.1 não cria objeto separado `brazil_layer`.

Quando o contexto-alvo brasileiro estiver presente:

- informações estruturadas permanecem em Question/Investigation;
- interpretação permanece em applicability;
- template poderá rotular visualmente “Aplicabilidade ao Brasil”.

---

# 26. Implementação física proposta

Criar migration:

`database/007_evidence_sheet_view.sql`

Ela deverá implementar:

`product.evidence_sheet_view(uuid) RETURNS jsonb`

Sem novas tabelas canônicas.

---

# 27. Testes mínimos

## F3-VIEW-T01

Função retorna JSONB válido.

## F3-VIEW-T02

`schema_version` correto.

## F3-VIEW-T03

Product ID/version corretos.

## F3-VIEW-T04

Question e Investigation primárias corretas.

## F3-VIEW-T05

N=N2 e M derivados da Investigation.

## F3-VIEW-T06

Search summary correto.

## F3-VIEW-T07

Study/Report contados sem dupla contagem.

## F3-VIEW-T08

Priority result contém Synthesis correta.

## F3-VIEW-T09

Certainty moderada aparece vinculada à Synthesis.

## F3-VIEW-T10

Limitations/applicability/conclusion corretos.

## F3-VIEW-T11

Currency history e current status corretos.

## F3-VIEW-T12

Review/audit e publishable corretos.

## F3-VIEW-T13

References derivadas de ResultSource.

## F3-VIEW-T14

Ordenação determinística.

## F3-VIEW-T15

Regressões F2-B/S4/S5/Ficha continuam verdes.

## F3-VIEW-T16

Rebuild do zero passa.

---

# 28. Critério de PASS

EvidenceSheetView = PASS quando:

- contrato JSON é reproduzível;
- fixture validada é projetada corretamente;
- não há duplicação canônica;
- gate continua coerente;
- regressões permanecem verdes;
- rebuild passa.

---

# 29. Relação com template

Somente após PASS:

> **EvidenceSheetView → Template da Ficha**

O template será uma transformação de apresentação.

Ele não decidirá:

- quais estudos incluir;
- qual certainty usar;
- qual conclusão científica produzir.

---

# 30. Próxima etapa

Implementar e testar:

`database/007_evidence_sheet_view.sql`

Depois:

1. criar especificação do template;
2. criar primeiro template operacional;
3. validar com a fixture;
4. selecionar um caso real para validação científica.

---

**Documento vivo. Alterações incompatíveis do objeto de renderização deverão atualizar schema_version.**
