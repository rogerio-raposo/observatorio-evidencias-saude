# 88 — Contrato de Dados do Evidence Scan — N0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato inicial consolidado  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 20–21, 28–30, 38, 40, 86–87  
**Baseline:** OES-P1 + migrations 002–012  
**Produto:** OES — Evidence Scan  
**Nível:** N0

---

# 1. Finalidade

Definir como o contrato científico do Documento 86 será representado no baseline OES-P1, distinguindo:

- campos persistidos;
- campos derivados;
- componentes estruturados via provenance;
- enums;
- campos condicionais;
- publication gate;
- contrato da EvidenceScanView.

Este documento não implementa ainda a migration 013.

---

# 2. Princípio

> **Persistir apenas o que precisa de identidade/versionamento; representar componentes exploratórios como campos derivados e provenanciados da ProductVersion.**

N0 não criará tabela ou coluna nova na versão inicial.

---

# 3. Classes de campo

| Classe | Significado |
|---|---|
| O | obrigatório para publicação formal |
| C | condicional |
| D | derivado de estrutura canônica |
| P | persistido em estrutura existente |
| PR | derivado de provenance/process |
| A | apresentação |

---

# 4. Identidade

| Campo lógico | Classe | Fonte | Regra |
|---|---|---|---|
| product_id | O/D | core.entity.oes_id | entidade Product |
| product_version_uuid | O/D | product.product_version | versão concreta |
| version_no | O/D | core.entity_version | imutável por versão |
| product_type | O/P | product.product_version.product_type | `evidence_scan` |
| title | O/P | product.product_version.title | obrigatório |
| intended_audience | C/P | product.product_version.intended_audience | quando material |
| editorial_status | O/P | product.product_version.status | vocabulário comum |
| publication_date | C/P | product.product_version.publication_date | obrigatória em published |
| evidence_cutoff_date | O/P | product.product_version.evidence_cutoff_date | obrigatória |
| currency_status | O/D | product.currency_state | ativo |

---

# 5. Investigation e Question

Invariantes:

- exatamente uma primary Investigation por ProductVersion formal;
- `depth_level = N0`;
- `maintenance_level` preferencial M0/M1;
- cutoff da Investigation = cutoff do Product;
- pelo menos uma QuestionVersion vinculada como primary;
- Q0 deve permanecer preservada em `original_text`;
- Q1 exploratória pode estar em `normalized_text`;
- Q2 não é obrigatória.

`investigation_type` candidato:

`evidence_scan`

---

# 6. Busca

Para Evidence Scan formal:

- pelo menos uma Search concluída;
- `exact_strategy` ou estratégia equivalente deve estar preenchida;
- `executed_at` deve existir;
- `source_name` deve existir;
- `result_count` é opcional;
- múltiplos ciclos de busca são permitidos;
- natureza não exaustiva é regra derivada do produto.

Uma única fonte de busca não bloqueia automaticamente N0, mas deverá gerar warning quando não houver justificativa contextual.

---

# 7. SearchHit

SearchHit é opcional em cobertura completa.

Quando houver hits materialmente citados no scan, eles deverão ser resolvidos para ReportVersion ou permanecer claramente identificados como ocorrência de busca.

O produto não poderá usar ausência de SearchHit completo como prova de ausência de literatura.

---

# 8. Conclusão e limitações

| Campo | Classe | Fonte |
|---|---|---|
| conclusão exploratória | O/P | product.product_version.conclusion_text |
| limitações | O/P | product.product_version.limitations_summary |
| aplicabilidade exploratória | C/P | product.product_version.applicability_summary |

`conclusion_text` deverá ser interpretado como **conclusão sobre o campo/roteamento**, não resposta clínica focal.

---

# 9. Convenção de field paths

Prefixo reservado:

`scan.`

Componentes v0.1:

- `scan.field_description`;
- `scan.terminology.N`;
- `scan.volume_signals.N`;
- `scan.evidence_types.N`;
- `scan.central_sources.N`;
- `scan.maturity`;
- `scan.controversies.N`;
- `scan.gaps.N`;
- `scan.subquestions.N`;
- `scan.routing.recommendation`;
- `scan.routing.rationale`.

Paths não reconhecidos sob `scan.` deverão ser tratados como incompatíveis com o contrato v0.1 até evolução explícita.

---

# 10. Regras gerais de provenance N0

Todo componente N0 provenanciado usa:

`target_version_uuid = ProductVersion`

Campos:

- `field_path` = componente lógico;
- `source_report_version_uuid` = fonte documental quando houver;
- `source_location` = seção/página/localização;
- `source_value` = payload do componente;
- `process_type` = natureza da extração/julgamento;
- `process_record_uuid` = Search ou outro registro operacional quando aplicável;
- `transformation` = rationale/derivação;
- `actor` = responsável.

`source_report_version_uuid` pode ser nulo para julgamentos derivados da busca ou do conjunto de fontes.

---

# 11. process_type permitido

Vocabulário inicial:

- `direct_extraction`;
- `search_signal`;
- `terminology_discovery`;
- `evidence_type_classification`;
- `oes_exploratory_judgement`;
- `routing_judgement`;
- `contextual_extraction`.

Outros valores exigem evolução documentada ou justificativa explícita.

---

# 12. `scan.field_description`

Classe: O/PR para produto formal.

Payload mínimo:

```json
{
  "text": "descrição sintética do campo",
  "scope_qualifier": "exploratory_non_exhaustive"
}
```

Pode ser derivado de múltiplas fontes e da busca.

Não deve conter resposta focal de efeito.

---

# 13. `scan.terminology.N`

Classe: C/PR.

Payload candidato:

```json
{
  "term": "digital therapeutics",
  "normalized_label": "digital therapeutics",
  "role": "preferred|synonym|legacy|emerging|ambiguous",
  "context": "opcional"
}
```

Fonte documental é recomendada quando o termo for material para interpretação.

---

# 14. `scan.volume_signals.N`

Classe: C/PR.

Payload:

```json
{
  "signal_type": "search_hit_count|reported_study_count|reported_review_count|qualitative_volume",
  "value": 120,
  "qualifier": "approximate|reported_by_source|search_specific",
  "context": "PubMed query 1"
}
```

Regras:

- contagem de Search nunca representa tamanho total do campo;
- valores de fontes diferentes não são automaticamente somados;
- `value` pode ser nulo em sinal qualitativo.

---

# 15. `scan.evidence_types.N`

Classe: C/PR.

Payload:

```json
{
  "evidence_type": "systematic_review|meta_analysis|guideline|hta|rct|observational|qualitative|other",
  "signal": "none|few|multiple|many|unknown",
  "count": null,
  "qualifier": "exploratory"
}
```

---

# 16. `scan.central_sources.N`

Classe: C/PR.

Usado quando uma ReportVersion for central para caracterizar o campo.

Payload mínimo:

```json
{
  "role": "field_overview|recent_synthesis|guideline|map|seminal|contextual",
  "reason": "por que a fonte é central"
}
```

`source_report_version_uuid` é obrigatório neste path.

---

# 17. `scan.maturity`

Classe: O/PR.

Payload:

```json
{
  "category": "well_synthesized|partially_synthesized|fragmented|emerging|saturated|insufficient",
  "rationale": "justificativa operacional",
  "confidence_qualifier": "preliminary"
}
```

A categoria não é score científico.

`process_type = oes_exploratory_judgement`.

---

# 18. `scan.controversies.N`

Classe: C/PR.

Payload:

```json
{
  "statement": "descrição da controvérsia aparente",
  "type": "apparent_conflict|population_difference|intervention_difference|outcome_difference|temporal_difference|methodological_difference|unexplained",
  "status": "apparent|explained_preliminarily|unresolved",
  "rationale": "opcional"
}
```

Controvérsia em N0 não é resolução de conflito.

---

# 19. `scan.gaps.N`

Classe: C/PR.

Payload:

```json
{
  "statement": "lacuna aparente",
  "scope": "população/desfecho/contexto/etc.",
  "qualifier": "apparent_in_exploratory_search|not_located_in_consulted_sources",
  "limitation": "não implica ausência definitiva de evidência"
}
```

Não permitir qualifier equivalente a `definitive_absence` em v0.1.

---

# 20. `scan.subquestions.N`

Classe: C/PR.

Payload:

```json
{
  "text": "subpergunta candidata",
  "priority": "high|medium|low|unspecified",
  "suggested_question_class": "opcional"
}
```

Subpergunta formal reutilizável poderá ser materializada posteriormente como Question.

---

# 21. `scan.routing.recommendation`

Classe: O/PR.

Payload:

```json
{
  "target": "stop_after_scan|repeat_n0|N1|N2|N3|N4|evidence_map|overview|other",
  "status": "recommended",
  "requires_question_reformulation": false
}
```

`process_type = routing_judgement`.

---

# 22. `scan.routing.rationale`

Classe: O/PR.

Payload:

```json
{
  "text": "justificativa da rota recomendada",
  "routing_dimensions": ["maturity","complexity","completeness_need"]
}
```

Se target=`stop_after_scan`, rationale deve explicar por que nenhuma investigação adicional é necessária.

---

# 23. Fontes centrais e referências

Reutilizar:

`product.product_reference_reports()`

Reports são projetados quando provenance direta/lineage os torna alcançáveis.

Wrapper candidato:

`product.evidence_scan_reference_reports()`

não cria nova verdade.

---

# 24. Exceção legítima: scan sem Report central

Um scan formal pode não localizar Report central quando o campo aparentar ser insuficiente.

Esse estado somente é válido se:

1. existir pelo menos uma Search concluída;
2. `scan.maturity.category = insufficient`;
3. existir `scan.field_description` ou `scan.gaps.N` com processo baseado na Search;
4. `process_record_uuid` corresponder a Search da Investigation;
5. a linguagem usar `não localizado nas fontes consultadas` ou equivalente;
6. não houver afirmação de ausência definitiva.

Nesse caso, ausência de Report central não deve bloquear automaticamente publicação.

---

# 25. Scan interno versus Product formal

## 25.1 Investigation N0 interna

Pode existir sem Product formal.

Após verificação metodológica:

- A1 é suficiente para encerrar o artefato operacional;
- não há `publication_date`;
- não há publicação no catálogo.

## 25.2 Evidence Scan formal persistente

Quando ProductVersion for publicado:

- assurance mínimo = A2;
- owner approval obrigatória;
- `publication_date` obrigatória;
- publication gate N0 deve passar.

---

# 26. Publication issues — erros

Gate formal candidato deve emitir `error` para:

- `MISSING_PRODUCT_VERSION`;
- `WRONG_PRODUCT_TYPE`;
- `MISSING_PRIMARY_INVESTIGATION`;
- `MULTIPLE_PRIMARY_INVESTIGATIONS`;
- `PRIMARY_INVESTIGATION_NOT_N0`;
- `CUTOFF_DATE_MISMATCH`;
- `PRIMARY_INVESTIGATION_NOT_CURRENT`;
- `MISSING_QUESTION`;
- `MISSING_SEARCH_RECORD`;
- `MISSING_TITLE`;
- `MISSING_EXPLORATORY_CONCLUSION`;
- `MISSING_LIMITATIONS`;
- `MISSING_CURRENCY_STATE`;
- `MISSING_FIELD_DESCRIPTION`;
- `MISSING_MATURITY_JUDGEMENT`;
- `MISSING_ROUTING_RECOMMENDATION`;
- `MISSING_ROUTING_RATIONALE`;
- `MISSING_TRACEABLE_BASIS`;
- `MISSING_AI_METHODOLOGICAL_VERIFICATION`;
- `ACTIVE_AI_METHOD_BLOCK`;
- `MISSING_OWNER_APPROVAL`;
- `ACTIVE_OWNER_BLOCK`;
- `ACTIVE_EXPERT_BLOCK`;
- `MISSING_PUBLICATION_DATE`;
- `INVALIDATED_DEPENDENCY`.

`MISSING_TRACEABLE_BASIS` pode ser satisfeito por:

- ReportVersion rastreável; ou
- exceção de scan insuficiente baseada em Search conforme seção 24.

---

# 27. Publication issues — warnings

Warnings candidatos:

- `NO_EXPERT_INDEPENDENT_REVIEW`;
- `SINGLE_SEARCH_SOURCE`;
- `NO_TRACEABLE_CENTRAL_REPORTS` quando exceção de insuficiência for válida;
- `NO_FORMAL_APPRAISAL` somente quando a saída depender fortemente de uma fonte central sem appraisal;
- `NO_STRUCTURED_SEARCH_HITS` quando nenhum hit material for preservado;
- `FIELD_TERMINOLOGY_UNSTABLE` quando registrado;
- `APPARENT_EVIDENCE_GAP` quando gaps existirem;
- `ROUTING_REQUIRES_REFORMULATION` quando route indicar reformulação.

Warnings não devem insinuar que N0 exige appraisal formal universal.

---

# 28. Assurance

Reutilizar `product.assurance_level()`.

Wrapper candidato:

`product.evidence_scan_assurance_level()`.

Para Product formal publicado:

> **A2 mínimo.**

A3 não é requisito padrão.

Se expert review não existir, a view deverá declarar explicitamente essa ausência.

---

# 29. EvidenceScanView

Schema candidato:

`oes.evidence_scan_view/0.1`

Estrutura:

```text
EvidenceScanView
├── schema_version
├── identity
├── question
├── investigation
├── objective
├── method
│   ├── non_exhaustive
│   └── searches[]
├── field_description
├── terminology[]
├── volume_signals[]
├── evidence_types[]
├── central_sources[]
├── maturity
├── controversies[]
├── gaps[]
├── candidate_questions[]
├── routing_recommendation
├── conclusion
├── limitations
├── applicability
├── references[]
└── audit
```

---

# 30. `identity`

Derivar:

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
- currency_status.

---

# 31. `question`

Derivar QuestionVersion primary:

- question_id;
- entity/version UUID;
- original_text;
- normalized_text;
- question_type;
- structure_type;
- context;
- time_horizon.

---

# 32. `investigation`

Derivar:

- investigation_id;
- entity/version UUID;
- investigation_type;
- depth_level;
- maintenance_level;
- objective;
- start_date;
- evidence_cutoff_date.

---

# 33. `method`

Campos:

- `non_exhaustive = true`;
- searches[];
- número de Search records;
- opcionalmente número de SearchHits materializados;
- disclaimer de contagens de busca.

A view não deverá somar hit counts de bases diferentes como tamanho total do campo.

---

# 34. Componentes derivados

`field_description`, `terminology`, `volume_signals`, `evidence_types`, `maturity`, `controversies`, `gaps`, `candidate_questions` e `routing_recommendation` serão projetados a partir dos field paths v0.1.

Ordenação:

- usar índice `N` do field_path;
- se ausente/inválido, ordenar deterministicamente por provenance_uuid.

---

# 35. `central_sources[]`

Cada item deverá expor:

- Report ID;
- ReportVersion UUID;
- title;
- publication_date;
- publication_status;
- source locations;
- role/reason do componente `scan.central_sources.N`.

---

# 36. `conclusion`, `limitations`, `applicability`

Derivar de ProductVersion:

- conclusion_text;
- limitations_summary;
- applicability_summary.

A view deverá rotular a conclusão como `exploratory`.

---

# 37. `audit`

Campos:

- publishable;
- assurance_level;
- expert_independent_reviewed;
- assurance_records[];
- assurance_disclosure;
- publication_issues[];
- lineage_available;
- traceable_basis_type: `reports|search_only_insufficient|mixed`.

---

# 38. Reprodutibilidade histórica

A EvidenceScanView deve respeitar versões concretas.

Não substituir automaticamente:

- QuestionVersion;
- InvestigationVersion;
- ReportVersion;
- ProductVersion;

por versões correntes mais novas.

---

# 39. Critérios de PASS do contrato

Contrato N0 será considerado implementado corretamente quando fixture/testes demonstrarem:

1. Product `evidence_scan` com Investigation N0;
2. pergunta original preservada;
3. pelo menos uma Search concluída;
4. field description;
5. maturity válida;
6. routing recommendation + rationale;
7. conclusão exploratória;
8. limitações;
9. provenance de fontes/juízos;
10. ausência de Synthesis obrigatória;
11. ausência de Certainty obrigatória;
12. ausência de RiskAssessment obrigatório;
13. A2 publicável no regime formal;
14. A1 não publicável como Product formal;
15. ausência de expert review como warning;
16. exceção válida de `insufficient` sem Report central;
17. dependência invalidada bloqueia;
18. rebuild reproduz a projeção;
19. regressões N1/N2 permanecem verdes.

---

# 40. Decisão sobre implementação

Está autorizada, após este contrato, a criação de:

`database/013_evidence_scan_contract.sql`

com escopo restrito a:

- funções;
- wrappers;
- publication gate;
- EvidenceScanView.

A migration 013 **não deverá criar tabela nem coluna**.

---

# 41. Próxima etapa

Implementar migration 013, fixture sintética e testes de contrato N0.

Somente após PASS técnico:

1. formalizar contrato de renderização;
2. especificar template;
3. validar com caso real Evidence Scan.

---

**Decisão do contrato:** N0 será uma especialização funcional/projetiva sobre OES-P1, com componentes exploratórios estruturados por provenance e sem expansão física do schema na v0.1.