# 144 — Especificação do Template Operacional do Overview de Revisões

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** especificação operacional candidata  
**Dependências:** Documentos 138–143; migrations 019–020  
**Input contract:** `oes.overview_of_reviews_view/0.1`

---

# 1. Finalidade

Definir a estrutura canônica da primeira renderização Markdown do Overview de Revisões, consumindo exclusivamente:

> `product.overview_of_reviews_view(product_version_uuid)`

O template apresenta a síntese de evidência em nível de revisão sistemática sem criar nova inferência científica.

---

# 2. Arquivos previstos

- `templates/overview-of-reviews.md`;
- `templates/overview-of-reviews-presentation-map.json`;
- `scripts/render_overview_of_reviews_reference.py`;
- `scripts/validate_overview_of_reviews_render.py`.

---

# 3. Princípio operacional

O template apresenta:

- Review-level evidence;
- currentness;
- ROBIS;
- OutcomeEvidence;
- certainty quando disponível;
- overlap;
- membership;
- CCA/pairwise overlap;
- cluster resolution;
- concordance;
- método;
- controls;
- assurance;
- provenance;
- publication issues.

O template não cria:

- Review nova;
- Result novo;
- Synthesis nova;
- certainty nova;
- CCA;
- pairwise overlap;
- global certainty;
- reanalysis;
- indirect comparison;
- recommendation clínica;
- approval editorial.

---

# 4. Ordem canônica

1. banner de fixture sintética;
2. banner do publication gate;
3. cabeçalho;
4. pergunta;
5. conclusão canônica;
6. aplicabilidade e limitações;
7. aviso epistemológico;
8. protocolo;
9. decisões metodológicas;
10. buscas e exports;
11. fluxo de seleção;
12. exclusões full text;
13. Reviews incluídas;
14. lineage de Reports/updates;
15. ROBIS;
16. OutcomeEvidence;
17. certainty;
18. membership Review × primary Study;
19. clusters;
20. métricas de overlap;
21. resolução de overlap;
22. concordância/divergência;
23. reviewer assignments;
24. quality controls;
25. reanalysis status;
26. referências;
27. lineage/provenance;
28. currency/update state;
29. assurance/audit;
30. publication issues;
31. assurance records;
32. IDs técnicos.

---

# 5. Banner de fixture sintética

Quando:

`audit.synthetic_fixture=true`

exibir no topo:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA OVERVIEW REAL**

Texto obrigatório:

> Reviews, primary Studies, reviewers, expert review, ROBIS, certainty, assurance e decisões metodológicas desta fixture são sintéticos e existem exclusivamente para validação do contrato técnico.

---

# 6. Banner do publication gate

Se:

`audit.publishable=true`

exibir:

> **Gate de publicação do Overview: aprovado.**

Se:

`audit.publishable=false`

exibir:

> **GATE DE PUBLICAÇÃO DO OVERVIEW NÃO APROVADO**

e:

> Assurance, inclusive A3, não substitui requisitos de search coverage, screening, ROBIS, membership, overlap control, OutcomeEvidence, concordance e controles humanos qualificados.

---

# 7. Cabeçalho

Exibir:

- Product ID;
- versão;
- product type;
- Investigation ID;
- depth;
- maintenance;
- editorial status;
- evidence cutoff;
- publication date;
- currency;
- assurance;
- assurance requerida;
- publishable.

Não rotular N4 como “nível do Overview”; N4 é depth da Investigation.

---

# 8. Pergunta

Exibir:

- normalized question;
- original question quando diferente;
- structure type;
- context quando útil.

---

# 9. Conclusão

Exibir:

`conclusion.text`

sem reescrita.

Se não publicável:

> rotular como conclusão de versão não publicável.

Renderer não poderá regenerar a conclusão a partir de:

- número de Reviews;
- overlap;
- CCA;
- estimates;
- ROBIS;
- certainty.

---

# 10. Aplicabilidade

Exibir:

`conclusion.applicability_summary`

literalmente.

---

# 11. Limitações

Exibir:

`limitations.summary`

literalmente.

---

# 12. Aviso epistemológico

Texto permanente:

> **Reviews sobrepostas não constituem observações independentes.**

Adicionar:

> **CCA e pairwise overlap descrevem redundância estrutural entre Reviews e não representam risco de viés, certeza ou magnitude de efeito.**

Adicionar:

> **ROBIS, certainty e currentness são dimensões distintas e não devem ser agregadas em um score único.**

---

# 13. Protocolo

Exibir:

- artifact UUID;
- type;
- storage key;
- content hash;
- hash algorithm;
- created_at;
- status.

---

# 14. Decisões metodológicas

Fonte:

`method.policies[]`

Tabela:

- decision type;
- stage;
- decision code;
- planned;
- rationale;
- risk;
- mitigation;
- impact;
- resolution status;
- linked artifact;
- decided_at.

Protocol deviations/amendments devem aparecer no mesmo bloco auditável, com rótulo explícito.

Renderer não pode esconder um protocol deviation apenas por estar resolved.

---

# 15. Buscas

Fonte:

`searches[]`

Tabela:

- search ID;
- source;
- platform;
- source class;
- executed_at;
- result count;
- strategy version;
- status;
- export artifact UUID;
- storage key;
- content hash;
- hash algorithm;
- artifact status.

Search presence não equivale a search peer review.

---

# 16. Fluxo de seleção

Fonte:

`selection_flow`

Exibir:

- search hits;
- unique Report targets;
- screening decisions;
- title/abstract decisions;
- full-text decisions;
- full-text exclusions;
- adjudications;
- included ReviewItems.

Não chamar automaticamente de PRISMA.

---

# 17. Exclusões full text

Fonte:

`excluded_full_text[]`

Tabela:

- target ID;
- target entity;
- reviewer;
- decision;
- exclusion reason;
- decided_at;
- adjudication.

---

# 18. Reviews incluídas

Fonte:

`review_items[]`

Tabela principal:

- ReviewItem UUID;
- Review Study ID;
- StudyVersion;
- title;
- item role;
- eligibility basis;
- last search date;
- membership completeness;
- currentness status;
- currentness rationale;
- ROBIS summary.

Review Study é a unidade científica.

Reports associados deverão aparecer subordinados à Review, nunca como Reviews adicionais.

---

# 19. Reports das Reviews

Para cada Review:

- Report ID;
- ReportVersion;
- relation type;
- title;
- publication date.

Não escolher silenciosamente “o mais recente”.

---

# 20. Report lineage

Fonte:

`report_lineage[]`

Exibir:

- Review Study ID;
- source Report ID/version;
- target Report ID/version;
- relation type;
- relation date;
- notes/status quando projetados.

Relações possíveis devem ser preservadas literalmente, inclusive:

- update_of;
- correction_of;
- retraction/retraction_of;
- demais relações canônicas.

Renderer não infere lineage por título, ano ou DOI.

---

# 21. Currentness

Exibir visualmente os estados:

- current;
- possibly_outdated;
- outdated;
- unclear.

Currentness não altera ROBIS automaticamente.

Currentness não altera certainty automaticamente.

---

# 22. ROBIS

Fonte:

`appraisal[]`

Tabela:

- ReviewItem;
- framework;
- overall judgement;
- assessor;
- assessment date;
- verification status.

Drill-down:

- domain code;
- judgement;
- rationale;
- sequence.

Não transformar ROBIS em certainty.

---

# 23. OutcomeEvidence

Fonte:

`outcome_evidence[]`

Tabela mínima:

- ReviewItem;
- Outcome;
- comparison;
- timepoint;
- analysis role;
- primary-study-set status;
- verification;
- ResultVersion;
- SynthesisVersion;
- CertaintyAssessmentVersion.

Quando Result existir:

- measure;
- reported value;
- derived value;
- CI;
- unit;
- estimand;
- method metadata.

Quando Synthesis existir:

- synthesis type;
- origin;
- method;
- model;
- result summary.

---

# 24. OutcomeEvidence source reports

Para cada OutcomeEvidence, exibir:

`source_reports[]`

com:

- Report ID/version;
- source location;
- source type;
- extraction method;
- original text/value quando projetado;
- extractor;
- extracted_at.

Renderer não poderá escolher fonte alternativa.

---

# 25. OutcomeEvidence provenance

Exibir:

`provenance[]`

incluindo:

- field path;
- source ReportVersion;
- source location;
- source value;
- process type;
- transformation;
- actor;
- status.

Não reconstruir provenance fora da View.

---

# 26. Certainty

Quando presente:

- framework;
- initial level;
- final level;
- evidence state;
- assessment date.

Quando ausente:

> **Certainty não reportada / não disponível para este OutcomeEvidence.**

Nunca preencher ausência como “baixa”.

Não criar certainty global do Overview.

---

# 27. Primary-study membership

Fonte:

`primary_study_membership[]`

Tabela:

- ReviewItem;
- primary Study ID/entity;
- source ReportVersion;
- source location;
- identity confidence;
- verification status;
- context.

Primary Studies não viram automaticamente referências principais do Overview.

---

# 28. Completeness da membership

Exibir explicitamente:

- complete;
- partial;
- unknown.

Quando partial/unknown:

> destacar limitação de overlap.

Não calcular ou aproximar CCA no renderer.

---

# 29. Clusters

Fonte:

`overlap.clusters[]`

Para cada cluster:

- code;
- label;
- scope;
- members;
- disposition;
- rationale;
- order/sequence.

---

# 30. Métricas de overlap

Exibir somente valores já derivados:

- review count;
- study occurrence count;
- unique primary-study count;
- redundant occurrence count;
- membership completeness;
- CCA;
- cca_calculable.

Quando:

`cca_calculable=false`

mostrar:

> **CCA não calculável com a membership disponível.**

Nunca inferir valor.

---

# 31. Pairwise overlap

Fonte:

`overlap.clusters[].pairwise[]`

Tabela:

- Review A;
- Review B;
- studies A;
- studies B;
- shared studies;
- union studies;
- Jaccard;
- proportion A shared;
- proportion B shared;
- calculable;
- completeness.

Não criar heatmap quantitativo que introduza thresholds não protocolados.

---

# 32. Overlap resolution

Exibir:

- strategy;
- decision payload;
- rationale;
- decided_by;
- actor type;
- verification;
- decided_at.

Quando strategy = `prioritize_review`:

- destacar Review priorizada;
- manter as demais Reviews elegíveis visíveis;
- distinguir `excluded_overlap` de exclusão por eligibility.

---

# 33. Estratégia v0.1 não suportada

Se aparecer:

`include_all_deduplicate_outcomes`

em estado bloqueado:

- exibir o blocker do publication gate;
- não tentar executar de-duplicação outcome-level no renderer.

---

# 34. Concordância

Fonte:

`concordance[]`

Tabela:

- cluster;
- outcome;
- comparison;
- timepoint;
- state;
- dimensions;
- rationale;
- assessed_by;
- actor type;
- verification;
- assessed_at.

Estados canônicos:

- concordant;
- directionally_discordant;
- magnitude_discordant;
- certainty_discordant;
- not_comparable.

Não criar votação por maioria entre Reviews.

---

# 35. Comparação indireta informal

É proibido inferir ranking de eficácia entre intervenções a partir de estimates de Reviews diferentes.

Quando Reviews não forem diretamente comparáveis:

- manter `not_comparable`;
- evitar linguagem de superioridade;
- evitar ordenação visual por “melhor efeito”.

---

# 36. Reviewer assignments

Fonte:

`method.reviewer_assignments[]`

Tabela:

- stage;
- role;
- actor;
- actor type;
- qualification;
- independent;
- scope;
- conflict;
- assigned_at;
- ended_at.

Não reduzir qualification a simples ícone/selo.

---

# 37. Quality controls

Fonte:

`method.quality_controls[]`

Tabela:

- stage;
- control type;
- control code;
- actor;
- actor type;
- qualification;
- independent;
- decision;
- scope;
- agreement;
- discrepancy;
- resolution;
- evidence artifact;
- notes;
- performed_at.

---

# 38. Reanalysis status

Fonte:

`audit.reanalysis_present`
e
`audit.statistical_controls_satisfied`

Se não houver reanalysis:

> **Nenhuma nova reanálise quantitativa do Overview foi executada.**

Se houver:

- exibir apenas elementos projetados;
- manter code/dataset/statistical controls auditáveis;
- não executar qualquer cálculo no renderer.

---

# 39. Referências

Fonte:

`references[]`

Lista principal deve manter:

- Review Reports;
- update Reports relevantes;
- Reports usados como fonte canônica de OutcomeEvidence quando projetados.

Não expandir automaticamente todos os primary-study Reports.

Não deduplicar editorialmente além do que já foi feito pela View.

---

# 40. Dependency lineage

Fonte:

`lineage[]`

Exibir:

- source version;
- target version;
- dependency type;
- derivation rule;
- status.

---

# 41. Invalidated dependencies

Fonte:

`invalidated_dependencies_detail[]`

Quando não vazio:

- mostrar seção crítica;
- preservar reason/status;
- não esconder por existir A3.

---

# 42. Currency/update state

Fonte:

`update_state`

Exibir:

- currency status;
- assessed_at;
- assessed_by;
- rationale.

---

# 43. Assurance/audit

Exibir:

- synthetic fixture;
- assurance level;
- required assurance;
- publishable;
- review count;
- membership complete;
- overlap assessed;
- appraisal complete;
- extraction complete;
- human controls satisfied;
- reanalysis present;
- statistical controls satisfied;
- lineage available;
- invalidated dependencies.

---

# 44. Publication issues

Exibir todas as issues.

Ordenação:

1. errors;
2. warnings.

Nenhuma issue pode ser suprimida por:

- A3;
- publishable=true;
- fixture sintética.

---

# 45. Assurance records

Tabela:

- assurance type;
- actor;
- actor type;
- independent;
- decision;
- performed_at.

---

# 46. IDs técnicos

Exibir:

- schema version;
- Product entity/version UUID;
- Investigation entity/version UUID;
- Question entity/version UUID;
- ReviewItem UUIDs;
- cluster UUIDs quando necessário;
- OutcomeEvidence UUIDs quando necessário.

---

# 47. Presentation map

Arquivo:

`templates/overview-of-reviews-presentation-map.json`

Deverá traduzir:

- editorial status;
- currency;
- assurance;
- actor type;
- reviewer roles;
- stages;
- control types;
- decisions;
- currentness;
- membership completeness;
- item roles;
- cluster dispositions;
- overlap strategies;
- identity confidence;
- verification status;
- ROBIS judgements;
- certainty levels;
- concordance states;
- analysis roles;
- publication issue severity;
- booleans auditáveis.

O presentation map não conterá lógica científica.

---

# 48. Renderer

Arquivo previsto:

`scripts/render_overview_of_reviews_reference.py`

Deverá reutilizar o engine neutro já usado pelos produtos anteriores.

O wrapper:

- não consulta banco;
- não altera payload;
- não recalcula CCA;
- não recalcula pairwise overlap;
- não cria OutcomeEvidence;
- não altera analysis role;
- não cria certainty;
- não cria conclusion;
- não altera assurance;
- não executa reanalysis.

---

# 49. Validator — cenário formal sintético

Arquivo:

`scripts/validate_overview_of_reviews_render.py`

Validar:

- schema `oes.overview_of_reviews_view/0.1`;
- banner sintético;
- gate aprovado;
- A3;
- 3 ReviewItems;
- 5 primary Studies únicos;
- 9 memberships;
- CCA = 0,4;
- pairwise A×B = 0,5;
- pairwise A×C = 0,2;
- pairwise B×C = 0,5;
- Review B priorizada;
- Review A update lineage;
- 3 ROBIS;
- Review C high ROBIS;
- 3 OutcomeEvidence;
- 2 certainty links;
- 1 concordance assessment;
- 7 reviewer assignments;
- 4 quality controls;
- 2 Searches com export hashes;
- 1 full-text exclusion;
- 6 dependency lineage edges;
- 4 references;
- conclusion;
- limitations;
- zero tokens não resolvidos.

---

# 50. Validator — A3 bloqueado

Criar cópia em memória com:

- `audit.publishable=false`;
- A3 mantido;
- issue sintética de error.

Exigir:

- gate bloqueado;
- A3 ainda visível;
- mensagem de não bypass;
- issue renderizada;
- ausência de mensagem de gate aprovado.

---

# 51. Validator — membership incompleta

Criar cópia em memória com:

- membership completeness = partial;
- CCA = null;
- cca_calculable=false;
- publication issue correspondente.

Exigir:

- disclosure de incomplete membership;
- “CCA não calculável”;
- nenhuma estimativa de CCA criada pelo renderer.

---

# 52. Validator — certainty ausente

Criar cópia em memória removendo certainty de um OutcomeEvidence.

Exigir:

> **Certainty não reportada / não disponível para este OutcomeEvidence.**

Não permitir texto “low certainty” sem payload canônico.

---

# 53. Validator — not comparable

Criar cópia em memória de concordance com:

`state=not_comparable`

Exigir:

- rótulo not comparable;
- rationale;
- ausência de ranking/superioridade.

---

# 54. Validator — invalidated dependency

Criar cópia em memória com:

- `audit.publishable=false`;
- `audit.invalidated_dependencies=true`;
- `invalidated_dependencies_detail[]` preenchido;
- blocker do gate.

Exigir:

- gate bloqueado;
- seção de dependency invalidation;
- A3 não ocultando blocker.

---

# 55. Critérios de PASS

Template v0.1 = PASS somente quando:

1. render da fixture formal sintética;
2. validator positivo;
3. A3-blocked scenario;
4. incomplete-membership scenario;
5. certainty-absent scenario;
6. not-comparable scenario;
7. invalidated-dependency scenario;
8. nenhum token não resolvido;
9. nenhum cálculo científico realizado pelo renderer;
10. integração S5;
11. regressões N0–N4 + Evidence Map + MAP-01;
12. rebuild completo.

---

# 56. Próxima etapa

> **Implementar template, presentation map, renderer e validator do Overview de Revisões e integrar ao S5.**

---

**Resultado:** Template Operacional do Overview de Revisões especificado.
