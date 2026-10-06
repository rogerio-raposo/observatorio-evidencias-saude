# 129 — Especificação do Template Operacional do Mapa de Evidências

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Mapa de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** especificação operacional candidata  
**Dependências:** Documentos 123–128; migrations 016–017  
**Input contract:** `oes.evidence_map_view/0.1`

---

# 1. Finalidade

Definir a estrutura canônica da primeira renderização Markdown do Mapa de Evidências, consumindo exclusivamente `EvidenceMapView`.

# 2. Arquivos previstos

- `templates/evidence-map.md`;
- `templates/evidence-map-presentation-map.json`;
- `scripts/render_evidence_map_reference.py`;
- `scripts/validate_evidence_map_render.py`.

# 3. Princípio operacional

O template apresenta:

- estrutura;
- distribuição;
- cells;
- counts;
- gaps derivados;
- concentrations;
- método;
- controles;
- assurance;
- provenance.

O template não cria:

- nova classificação;
- nova contagem;
- novo gap;
- interpretação de eficácia;
- certainty global;
- recommendation;
- research priority.

# 4. Ordem canônica

1. banner de fixture sintética;
2. banner do publication gate;
3. cabeçalho;
4. pergunta/objetivo;
5. conclusão canônica;
6. aviso epistemológico;
7. método do mapa;
8. protocolo e codebook;
9. framework/dimensões/categorias;
10. composição do corpus;
11. matriz/células;
12. gaps;
13. concentrações;
14. MapItems e drill-down;
15. classifications;
16. searches;
17. selection flow;
18. reviewer assignments;
19. method controls;
20. stakeholder engagement;
21. appraisal/certainty quando projetados;
22. limitações;
23. referências;
24. lineage;
25. update state;
26. assurance/audit;
27. publication issues;
28. assurance records;
29. IDs técnicos.

# 5. Banner de fixture sintética

Quando `audit.synthetic_fixture=true`:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA MAPA DE EVIDÊNCIAS REAL**

Texto adicional obrigatório:

> Codificadores, reviewer assignments, expert review, assurance, gaps e concentrações desta fixture existem somente para validação do contrato técnico.

# 6. Banner do gate

Se `audit.publishable=true`:

> **Gate de publicação do Mapa: aprovado.**

Se `audit.publishable=false`:

> **GATE DE PUBLICAÇÃO DO MAPA NÃO APROVADO**

e:

> Assurance, inclusive A3, não substitui requisitos de coverage, search, screening, classification e CellScope.

# 7. Cabeçalho

Exibir:

- Product ID;
- versão;
- mapping subtype;
- coverage;
- gap mode;
- counting unit;
- depth da Investigation;
- maintenance;
- estado editorial;
- currency;
- cutoff;
- publication date;
- assurance;
- assurance requerida.

# 8. Pergunta e objetivo

Exibir:

- normalized question;
- original question quando presente;
- objective.

Não rotular depth como “nível do Mapa”.

# 9. Conclusão

Exibir `conclusion.text` sem reescrita.

A conclusão não pode ser gerada a partir de counts pelo renderer.

# 10. Aviso epistemológico

Texto permanente:

> **Densidade de evidência não equivale a magnitude de efeito, certeza, qualidade ou benefício.**

E:

> **Gap é dependente do framework, escopo, coverage, fontes e data de corte.**

# 11. Método do mapa

Exibir:

- subtype;
- coverage;
- gap mode;
- counting unit;
- coverage policy;
- classification policy;
- gap rules.

# 12. Protocolo e codebook

Exibir separadamente:

- artifact;
- type;
- storage key;
- hash;
- status.

# 13. Framework

Exibir:

- Framework ID/version;
- row axis;
- column axis;
- visualization policy.

# 14. Dimensões

Tabela:

- code;
- label;
- role;
- multi-valued;
- required;
- sequence.

# 15. Categorias

Tabela:

- dimension;
- code;
- label;
- parent;
- order.

# 16. Composição do corpus

Apresentar `distributions` sem interpretar tipos como qualidade.

# 17. Matriz/células

Tabela mínima:

- row;
- column;
- scope;
- gap eligibility;
- study count;
- report count;
- synthesis count;
- total count;
- counted unit count;
- MapItem UUIDs;
- formal empty-cell gap;
- apparent gap;
- primary-evidence gap;
- synthesis gap.

# 18. Semântica de CellScope

`not_applicable` e `excluded_by_framework` devem aparecer de forma distinta de `in_scope`.

Nunca usar linguagem de gap em células fora de escopo.

# 19. Gap formal

Quando `empty_cell_gap=true`:

> **Gap formal dentro do escopo definido.**

Adicionar:

> A afirmação é restrita ao framework, fontes, critérios e data de corte deste ProductVersion.

# 20. Gap aparente

Quando `apparent_gap=true`:

> **Gap aparente.**

Adicionar:

> Nenhuma unidade elegível foi localizada nas fontes consultadas para esta classificação; isso não demonstra ausência universal de evidência.

# 21. Primary-evidence gap

Quando `primary_evidence_gap=true`:

> Nenhum Study MapItem foi classificado nesta célula dentro do corpus mapeado.

Não converter em necessidade de novo estudo.

# 22. Synthesis gap

Quando `synthesis_gap=true`:

> Há evidência primária mapeada, mas nenhuma Synthesis MapItem classificada na célula.

Não converter em recomendação automática de revisão sistemática.

# 23. Concentrações

Tabela derivada de `concentrations[]`.

Manter counts.

Não utilizar rótulos “forte”, “melhor” ou equivalentes.

# 24. MapItems e drill-down

Tabela:

- MapItem UUID;
- target ID;
- target version;
- target type;
- role;
- inclusion basis.

Cells devem mostrar seus MapItem UUIDs para reconciliação.

# 25. Assignments

Tabela:

- MapItem;
- dimension;
- category;
- candidate/final;
- actor;
- actor type;
- method;
- verification;
- verifier;
- rationale.

# 26. Searches

Tabela:

- source;
- platform;
- class;
- strategy version;
- executed_at;
- result count;
- export artifact;
- status.

# 27. Selection flow

Exibir todas as contagens projetadas.

Não denominar automaticamente como PRISMA.

# 28. Reviewer assignments

Tabela:

- stage;
- role;
- actor;
- type;
- qualification;
- independence;
- scope;
- conflict.

# 29. Method controls

Tabela:

- stage;
- control type/code;
- actor;
- type;
- independence;
- decision;
- scope;
- date;
- evidence artifact.

# 30. Stakeholder engagement

Exibir payload projetado sem inferir endorsement.

# 31. Appraisal e certainty

Se arrays vazios:

- declarar apenas que nenhuma estrutura foi projetada;
- não inferir nível de qualidade/certainty.

Se presentes futuramente:

- renderizar sem agregação global arbitrária.

# 32. Limitações

Exibir `limitations.summary` literalmente.

# 33. Referências

Listar todas as references projetadas, incluindo as alcançadas por Study–Report linkage.

# 34. Lineage

Exibir cada dependency edge projetada.

# 35. Update state

Exibir:

- currency;
- assessed_at;
- assessed_by;
- rationale.

# 36. Assurance/audit

Exibir:

- synthetic fixture;
- assurance;
- assurance requerida;
- publishable;
- classification complete;
- search controls satisfied;
- classification controls satisfied;
- formal gap eligible;
- reviewer assignment count;
- expert independent reviewed;
- lineage available;
- invalidated dependencies.

# 37. Publication issues

Renderizar todos os errors e warnings.

Nenhuma issue deve ser suprimida.

# 38. Presentation map

Deverá traduzir:

- editorial status;
- currency;
- assurance;
- mapping subtype;
- coverage claim;
- gap claim mode;
- counting unit;
- dimension role;
- CellScope status;
- item role;
- decision state;
- actor type;
- assignment method;
- verification status;
- stage;
- reviewer role;
- control type;
- decisions;
- severity;
- booleans relevantes.

# 39. Renderer

Reutilizar o engine neutro de `render_evidence_sheet_reference.py`.

O wrapper do Mapa:

- não consulta banco;
- não altera payload;
- não recalcula cells/counts;
- não cria gap;
- não cria conclusion;
- não muda assurance.

# 40. Validator — cenário formal sintético

Deverá validar:

- schema 0.1;
- synthetic banner;
- gate aprovado;
- A3;
- `systematic_comprehensive`;
- `formal_within_scope`;
- counting unit = study;
- 3 dimensions;
- 5 categories;
- 4 MapItems;
- 4 cells;
- A×Y com Study=1, Report=1, Synthesis=1 e counted unit=1;
- A×Z como formal gap;
- B×Z como not_applicable e não gap;
- B×Y com synthesis gap;
- 6 reviewer assignments;
- 3 method controls;
- protocol/codebook;
- 2 references incluindo Report B via Study linkage;
- 5 lineage edges;
- conclusão e limitações;
- zero tokens não resolvidos.

# 41. Validator — A3 bloqueado

Criar cópia em memória com:

- `audit.publishable=false`;
- A3 mantido;
- issue sintética de erro.

Exigir:

- gate bloqueado;
- A3 visível;
- mensagem de não bypass;
- issue renderizada;
- ausência de mensagem de gate aprovado.

# 42. Validator — apparent gap

Criar cópia em memória com:

- coverage não exaustiva;
- gap mode = apparent_only;
- A×Z com `apparent_gap=true`;
- formal gap desativado;
- warnings de non-exhaustive/apparent gap.

Exigir:

- rótulo **Gap aparente**;
- linguagem “fontes consultadas”;
- nenhuma alegação de gap formal para A×Z.

# 43. Critérios de PASS

PASS exige:

- render da fixture;
- validator formal;
- validator A3-blocked;
- validator apparent-gap;
- integração S5;
- regressões N0–N4;
- rebuild;
- nenhum token não resolvido.

# 44. Próxima etapa

> Implementar template, presentation map, renderer e validator do Mapa de Evidências e integrar ao CI.

---

**Resultado:** Template Operacional do Mapa de Evidências especificado.
