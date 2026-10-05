# 90 — EvidenceScanView: Contrato de Renderização do Evidence Scan — N0

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** Documento vivo — contrato de renderização inicial  
**Data:** 5 de outubro de 2026  
**Dependências:** Documentos 86–89; migration 013  
**Baseline:** OES-P1 + migration 013  
**Produto:** OES — Evidence Scan  
**Nível:** N0  
**Schema version:** `oes.evidence_scan_view/0.1`

---

# 1. Finalidade

Definir formalmente a projeção estruturada que alimentará a apresentação do **Evidence Scan — N0**.

O objeto de entrada é:

> **EvidenceScanView**

Ele é uma representação derivada e somente de leitura.

Não é:

- entidade científica;
- fonte canônica independente;
- substitute de ProductVersion;
- substitute de Investigation/Search;
- template final;
- mecanismo de decisão metodológica;
- evidence map;
- scoping review;
- resposta focal N1.

Sua função é reunir de forma determinística e auditável os elementos exploratórios necessários à apresentação N0 sem duplicar o modelo científico.

# 2. Princípios

EvidenceScanView deverá ser:

- derivada de entidades canônicas;
- determinística para o mesmo estado do banco;
- somente leitura;
- específica do subtipo `evidence_scan`;
- explicitamente não exaustiva;
- compatível com ausência de Synthesis;
- compatível com ausência de CertaintyAssessment;
- compatível com ausência de RiskAssessment formal;
- provenance-aware;
- assurance-aware;
- compatível com campo `insufficient` sem Report central quando a exceção do contrato for satisfeita.

A view não deverá transformar exploração em alegação de completude.

# 3. Separação entre camadas

A arquitetura seguirá:

`Entidades canônicas → EvidenceScanView → Template/Renderização`

A EvidenceScanView poderá:

- agregar;
- ordenar;
- projetar;
- expor julgamentos operacionais já persistidos;
- traduzir estado canônico em estrutura de apresentação;
- expor audit state.

Ela não poderá:

- criar maturity;
- inventar gap;
- resolver controvérsia;
- decidir routing;
- inferir ausência de evidência;
- criar certainty;
- transformar Search count em tamanho do campo;
- aprovar publicação.

# 4. Estrutura de topo

```text
EvidenceScanView
├── schema_version
├── identity
├── question
├── investigation
├── objective
├── method
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

# 5. Versionamento

Versão inicial:

`oes.evidence_scan_view/0.1`

Esse versionamento é independente de:

- ProductVersion;
- InvestigationVersion;
- versão metodológica;
- versão do template;
- versão do artefato renderizado.

Mudança incompatível na estrutura JSON exige nova `schema_version`.

# 6. identity

Campos:

- `product_id`;
- `product_entity_uuid`;
- `product_version_uuid`;
- `version_no`;
- `product_type`;
- `title`;
- `intended_audience`;
- `editorial_status`;
- `entity_version_status`;
- `publication_date`;
- `evidence_cutoff_date`;
- `currency_status`.

Invariante normal:

`product_type = evidence_scan`.

# 7. question

Campos:

- `question_id`;
- `question_entity_uuid`;
- `question_version_uuid`;
- `original_text`;
- `normalized_text`;
- `question_type`;
- `structure_type`;
- `context`;
- `time_horizon`.

Regra:

> a apresentação deve preservar a pergunta original e distinguir a formulação exploratória normalizada quando ambas forem materialmente diferentes.

N0 não deverá esconder que a pergunta inicial pode ainda estar em Q0/Q1.

# 8. investigation

Campos:

- `investigation_id`;
- `investigation_entity_uuid`;
- `investigation_version_uuid`;
- `investigation_type`;
- `depth_level`;
- `maintenance_level`;
- `objective`;
- `start_date`;
- `evidence_cutoff_date`.

Invariante:

`depth_level = N0`.

# 9. objective

Fonte:

`InvestigationVersion.objective`

Deve explicar a finalidade exploratória do scan.

Não deverá ser transformado pelo renderer em pergunta clínica focal.

# 10. method

Campos:

- `non_exhaustive`;
- `searches[]`;
- `count_disclaimer`.

## 10.1 non_exhaustive

Para N0:

`true`

Mensagem semântica obrigatória:

> **Este Evidence Scan é exploratório e não pretende demonstrar identificação exaustiva de toda a literatura.**

## 10.2 searches[]

Cada Search poderá expor:

- search_id;
- source_name;
- platform;
- exact_strategy;
- filters;
- executed_at;
- result_count;
- strategy_version;
- status;
- materialized_hit_count.

O renderer não deve somar automaticamente result_count entre fontes.

## 10.3 count_disclaimer

Deverá permanecer visível quando contagens de busca forem apresentadas.

# 11. field_description

Objeto estruturado proveniente de `scan.field_description`.

Campos esperados:

- `text`;
- `scope_qualifier`.

Função:

> resumir como o campo parece estar estruturado dentro da cobertura exploratória executada.

Não é conclusão focal de efeito.

# 12. terminology[]

Cada item poderá conter:

- term;
- normalized_label;
- role;
- context.

Papéis:

- preferred;
- synonym;
- legacy;
- emerging;
- ambiguous.

Quando houver termos ambíguos, a apresentação deverá preservar essa ambiguidade.

# 13. volume_signals[]

Representam sinais operacionais, não tamanho real do universo científico.

Campos possíveis:

- signal_type;
- value;
- qualifier;
- context.

Exemplos:

- search_hit_count;
- reported_study_count;
- reported_review_count;
- qualitative_volume.

Regra:

> nenhum volume signal isolado pode ser rotulado como número total de estudos do campo.

# 14. evidence_types[]

Cada item poderá apresentar:

- evidence_type;
- signal;
- count;
- qualifier.

Finalidade:

> mostrar a distribuição exploratória de tipos de evidência identificados.

Não é evidence map formal.

# 15. central_sources[]

Representa fontes centrais para caracterização do campo.

Campos:

- report_id;
- report_entity_uuid;
- report_version_uuid;
- title;
- publication_date;
- publication_status;
- source_location;
- component.role;
- component.reason.

Papéis candidatos:

- field_overview;
- recent_synthesis;
- guideline;
- map;
- seminal;
- contextual.

Quando não houver central source por exceção `insufficient`, a seção poderá estar vazia sem tornar o artefato inválido.

# 16. maturity

Objeto estruturado:

- category;
- rationale;
- confidence_qualifier.

Categorias:

- well_synthesized;
- partially_synthesized;
- fragmented;
- emerging;
- saturated;
- insufficient.

Regra de apresentação:

> **Maturidade do campo é julgamento operacional de roteamento, não avaliação de certeza da evidência.**

O template deverá exibir essa distinção de forma explícita.

# 17. controversies[]

Cada controvérsia poderá conter:

- statement;
- type;
- status;
- rationale.

A apresentação deverá usar linguagem como:

- controvérsia aparente;
- diferença preliminarmente explicada;
- conflito ainda não resolvido.

Não usar:

- consenso;
- refutado;
- resolvido;

salvo se isso estiver explicitamente persistido em nível metodológico adequado.

# 18. gaps[]

Cada lacuna poderá conter:

- statement;
- scope;
- qualifier;
- limitation.

Regra obrigatória:

> gaps em N0 são **lacunas aparentes na cobertura exploratória**, não prova definitiva de ausência de evidência.

Quando houver gap, o qualifier deverá permanecer visível.

# 19. candidate_questions[]

Representa subperguntas candidatas identificadas durante o scan.

Campos:

- text;
- priority;
- suggested_question_class.

Esses itens não são Questions canônicas obrigatoriamente.

O renderer deverá rotulá-los como:

> **perguntas candidatas para investigação posterior**.

# 20. routing_recommendation

Estrutura:

- `recommendation`;
- `rationale`.

`recommendation` poderá conter:

- target;
- status;
- requires_question_reformulation.

Targets:

- stop_after_scan;
- repeat_n0;
- N1;
- N2;
- N3;
- N4;
- evidence_map;
- overview;
- other.

O template deverá apresentar claramente:

> **Próxima rota metodológica sugerida**

e nunca como recomendação clínica.

# 21. conclusion

Objeto:

- `text`;
- `type = exploratory`.

Fonte:

`ProductVersion.conclusion_text`.

Regra:

> a conclusão deve permanecer uma conclusão sobre o campo, sua estrutura e o próximo passo.

Se o texto contiver conclusão clínica focal incompatível com N0, o problema deve ser resolvido antes da renderização/publicação; o template não corrige conteúdo científico.

# 22. limitations

Objeto:

- summary;
- present.

Em produto formal publicado, a seção é obrigatória.

Limitações típicas:

- busca exploratória;
- não exaustividade;
- indexação;
- ausência de triagem completa;
- contagens específicas de Search;
- ausência de appraisal formal;
- terminologia instável;
- possíveis estudos não localizados.

O template não cria novas limitações.

# 23. applicability

Objeto:

- summary;
- formal_assessment=false.

Em N0, aplicabilidade é descritiva e opcional.

Não produzir score de transferibilidade.

# 24. references[]

Lista deduplicada de ReportVersions rastreáveis.

Pode estar vazia somente quando a exceção `insufficient` do contrato for válida.

Quando houver referências, cada item poderá expor:

- report_id;
- title;
- publication_date;
- publication_status;
- source_locations.

# 25. audit

Campos:

- publishable;
- assurance_level;
- expert_independent_reviewed;
- assurance_records[];
- assurance_disclosure;
- publication_issues[];
- lineage_available;
- traceable_basis_type.

## 25.1 publishable

Derivado de:

`product.evidence_scan_is_publishable()`

## 25.2 assurance_level

Derivado de:

`product.evidence_scan_assurance_level()`

## 25.3 traceable_basis_type

Valores:

- reports;
- mixed;
- search_only_insufficient;
- none.

Esse campo deverá controlar apenas apresentação de rastreabilidade; não substitui publication gate.

# 26. Scan interno A1 versus scan formal A2

## 26.1 A1 interno

Se o artefato for renderizado para uso operacional interno e estiver em A1:

- deve ser identificado como **artefato interno / não publicado**;
- não deve receber status de publicação;
- owner governance approval ainda não está registrada;
- ausência de expert review deve permanecer explícita.

## 26.2 A2 formal

Para produto formal persistente publicado:

- assurance A2 mínimo;
- publication_date presente;
- publishable=true;
- owner governance approval registrada;
- ausência de expert review divulgada quando A3 não existir.

# 27. Estado `insufficient` sem Report central

Quando:

- maturity.category = insufficient;
- references=[];
- traceable_basis_type = search_only_insufficient;
- gate = aprovado;

a apresentação deverá:

1. mostrar as Search records;
2. explicar que nenhuma fonte central foi localizada nas fontes consultadas;
3. preservar linguagem não definitiva;
4. mostrar warning `NO_TRACEABLE_CENTRAL_REPORTS`;
5. não apresentar seção vazia de “fontes-chave” como erro.

Texto conceitual recomendado:

> **Nenhuma fonte central foi localizada nas buscas exploratórias registradas. Isso não demonstra ausência definitiva de evidência.**

# 28. Publication gate versus view

A view não decide publicação.

Fluxo:

`dados canônicos → publication issues → publishable → EvidenceScanView.audit`

O template apenas apresenta esse estado.

# 29. Reprodutibilidade histórica

A renderização deve respeitar versões concretas.

Não substituir automaticamente:

- QuestionVersion;
- InvestigationVersion;
- ReportVersion;
- ProductVersion;

por versões mais recentes.

# 30. Critérios de PASS do contrato de renderização

EvidenceScanView estará apta ao template quando a apresentação puder:

1. identificar produto e versão;
2. preservar pergunta original;
3. mostrar pergunta exploratória quando diferente;
4. declarar não exaustividade;
5. mostrar buscas e contagens qualificadas;
6. mostrar descrição do campo;
7. mostrar terminologia;
8. mostrar maturidade como julgamento operacional;
9. mostrar controvérsias como aparentes;
10. mostrar gaps como preliminares;
11. mostrar perguntas candidatas;
12. mostrar routing metodológico;
13. mostrar conclusão exploratória;
14. mostrar limitações;
15. mostrar fontes/referências quando existentes;
16. suportar `insufficient` sem Report central;
17. distinguir A1 interno de A2 formal;
18. mostrar ausência de expert review;
19. mostrar publication issues;
20. não criar informação científica nova.

# 31. Relação com template

Somente após este contrato:

> **EvidenceScanView → Template Operacional do Evidence Scan — N0**

O template será transformação de apresentação.

Ele não decidirá:

- maturity;
- gap;
- controversy;
- routing;
- suficiência da busca;
- assurance;
- publication gate.

# 32. Decisões consolidadas

1. EvidenceScanView é projeção derivada, não entidade.
2. Schema inicial = `oes.evidence_scan_view/0.1`.
3. N0 deve declarar não exaustividade.
4. Maturity é julgamento operacional, não certainty.
5. Gaps são aparentes/preliminares.
6. Controvérsias não são resolvidas pelo template.
7. Routing é metodológico, não clínico.
8. A1 interno e A2 formal devem ter apresentação distinta.
9. `search_only_insufficient` é estado válido e explicitamente comunicável.
10. Ausência de Report central não equivale a ausência de evidência.
11. Template não poderá ocultar warnings ou blockers.
12. Template não consulta tabelas científicas diretamente.

# 33. Próxima etapa

Especificar o:

> **Template Operacional do Evidence Scan — N0**

A especificação deverá definir:

- ordem de leitura;
- cabeçalho;
- camada executiva;
- método exploratório;
- field description;
- maturity;
- controversy/gaps;
- candidate questions;
- routing;
- fontes e referências;
- audit/assurance;
- comportamento A1 interno;
- comportamento A2 formal;
- comportamento `insufficient` sem Report central.

Somente após essa especificação deverá ser criado o template executável.

---

**Documento vivo. Alterações incompatíveis deverão considerar evolução de `schema_version`.**