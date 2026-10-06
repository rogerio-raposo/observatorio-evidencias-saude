# 142 — OverviewOfReviewsView: Contrato de Renderização e Projection Readiness Gate

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** contrato de renderização definido; Projection Readiness = **NOT_READY**  
**Dependências:** Documentos 138–141; migration 019; `oes.overview_of_reviews_view/0.1`

---

# 1. Finalidade

Definir como a `OverviewOfReviewsView` deverá alimentar a apresentação do Overview de Revisões sem introduzir:

- novos julgamentos científicos;
- novos cálculos de overlap;
- nova certainty;
- novas decisões de priorização;
- comparações indiretas informais;
- dupla contagem;
- assurance;
- aprovação editorial.

O renderer será:

> **camada somente leitura sobre uma projeção derivada, auditável e versionada.**

---

# 2. Fonte canônica

O renderer deverá consumir exclusivamente:

> `product.overview_of_reviews_view(product_version_uuid)`

Não poderá consultar diretamente:

- tabelas `overview`;
- Study/Report/Result;
- ROBIS;
- Synthesis;
- CertaintyAssessment;
- Search/Screening;
- ReviewerAssignment;
- QualityControlRecord;
- AssuranceRecord;
- provenance graph.

Qualquer dado necessário à apresentação deverá estar projetado pela View.

---

# 3. Regra epistemológica central

Overview organiza e interpreta:

> **evidência em nível de revisão sistemática.**

Não transforma Reviews em observações independentes quando compartilham primary Studies.

Logo:

> **overlap deve permanecer visível e não pode ser apagado pela apresentação.**

O renderer não poderá:

- somar reviews como se fossem independentes;
- somar participantes entre reviews sem de-duplicação canônica;
- recalcular CCA;
- recalcular Jaccard;
- criar meta-análise de review estimates;
- inferir superioridade entre intervenções por comparação informal de reviews.

---

# 4. Review ≠ Report

A apresentação deverá distinguir explicitamente:

- **Review Study** = unidade científica;
- **Report** = publicação/documento associado à Review.

Multiple Reports da mesma Review:

> **não podem aparecer como Reviews independentes.**

Quando existir update/correction/retraction lineage:

- a relação deverá ficar visível;
- o renderer não poderá inferir lineage somente por título/ano;
- não deverá selecionar silenciosamente o Report “mais recente”.

---

# 5. Eligibility ≠ overlap disposition

Estados de inclusão e decisão analítica são distintos.

Uma Review pode ser:

- elegível/incluída;
- mas `excluded_overlap` na análise de determinado cluster.

Logo:

> **excluded_overlap não significa review inelegível.**

Da mesma forma:

> **prioritized não significa que as demais reviews sejam cientificamente inválidas.**

A apresentação deverá sempre separar:

- eligibility;
- item_role;
- cluster membership;
- analysis_disposition;
- overlap resolution;
- rationale.

---

# 6. Overlap

Exibir:

- ReviewItems do cluster;
- membership completeness;
- study occurrence count;
- unique primary-study count;
- redundant occurrence count;
- CCA;
- `cca_calculable`;
- pairwise overlap;
- strategy;
- rationale;
- priorização/disposition.

Regra:

> **renderer não recalcula overlap.**

Se:

- `cca_calculable=false`;
- ou CCA = null;

não estimar, preencher ou aproximar CCA.

Não converter CCA em:

- risco de viés;
- certeza;
- qualidade metodológica;
- magnitude de efeito.

Qualquer categoria “baixo/moderado/alto overlap” só poderá ser exibida se vier de regra protocolar explicitamente projetada.

---

# 7. Membership completeness

Os estados:

- complete;
- partial;
- unknown;

devem ser visíveis.

`partial` ou `unknown` não podem ser visualmente apresentados como equivalentes a complete.

Quando membership for incompleta:

- sinalizar limitação;
- não apresentar CCA como completo;
- não esconder a impossibilidade de cálculo.

---

# 8. ROBIS ≠ certainty

ROBIS avalia risco de viés da Review.

Certainty:

- pode ser reportada pela Review;
- pode variar por outcome/comparison;
- pode estar ausente.

A apresentação não poderá:

- converter ROBIS em GRADE;
- converter GRADE em ROBIS;
- produzir score agregado;
- criar “certeza global do Overview”.

Quando certainty estiver ausente:

> apresentar **não reportada / não disponível**, nunca “baixa” por default.

---

# 9. Currentness ≠ quality

Estados:

- current;
- possibly_outdated;
- outdated;
- unclear;

deverão ser apresentados separadamente de:

- ROBIS;
- certainty;
- relevance;
- analysis disposition.

Review outdated:

> **não é automaticamente review de alto risco de viés.**

Review current:

> **não é automaticamente review de baixo risco de viés.**

---

# 10. High ROBIS

Quando uma Review possuir high ROBIS:

- manter warning;
- mostrar julgamento;
- não remover a Review do produto por decisão do renderer;
- não transformar automaticamente em excluded_overlap.

Qualquer exclusão/priorização deve vir da decisão metodológica canônica.

---

# 11. OutcomeEvidence

Para cada item material, exibir:

- ReviewItem;
- Outcome;
- comparison;
- timepoint;
- analysis role;
- primary-study-set status;
- Result/Synthesis selecionado;
- estimate;
- CI quando existente;
- measure;
- heterogeneity/method metadata quando existente;
- certainty quando existente;
- verification status;
- source/provenance.

O renderer não poderá:

- escolher outro Result;
- selecionar outra Synthesis;
- combinar estimates;
- transformar `supporting_estimate` em primary;
- reintroduzir `excluded_overlap` em síntese quantitativa.

---

# 12. Comparação indireta informal

A apresentação pode juxtapôr estimates de Reviews diferentes para transparência.

Não poderá concluir:

> “A é superior a B”

apenas porque:

- uma Review apresenta estimate maior;
- populações/comparadores diferem;
- escopos diferem;
- Search dates diferem.

Se os elementos não forem diretamente comparáveis:

- manter disclosure;
- respeitar `not_comparable`;
- não gerar ranking visual de eficácia.

---

# 13. Concordance

Exibir somente os estados canônicos:

- concordant;
- directionally_discordant;
- magnitude_discordant;
- certainty_discordant;
- not_comparable.

Exibir:

- dimensions;
- rationale;
- assessor;
- verification.

Não produzir “votação por maioria” entre Reviews.

---

# 14. Quantitative reanalysis

Se:

- `audit.reanalysis_present=false`;

a apresentação deverá deixar claro que:

> **nenhuma nova reanálise quantitativa do Overview foi executada.**

Se reanalysis existir:

- mostrar artifacts;
- método;
- controles estatísticos;
- status.

O renderer nunca executa reanalysis.

---

# 15. Gate de publicação e assurance

Assurance e publication gate são dimensões distintas.

Se:

- A3;
- `publishable=false`;

mostrar simultaneamente:

- assurance A3;
- gate bloqueado;
- blockers do gate.

A3 não pode suprimir:

- missing controls;
- incomplete membership;
- missing ROBIS;
- unsupported overlap strategy;
- invalidated dependency.

---

# 16. Fixture sintética

Quando:

`audit.synthetic_fixture=true`

exibir no topo:

> **FIXTURE SINTÉTICA — NÃO REPRESENTA OVERVIEW REAL**

Esclarecer:

- Reviews são sintéticas;
- primary Studies são sintéticos;
- reviewers/experts são fictícios;
- ROBIS/certainty são sintéticos;
- A3 existe apenas para validação do contrato.

---

# 17. Camadas de leitura

## 17.1 Executiva

Exibir:

- título;
- pergunta;
- conclusão;
- cutoff;
- currency;
- assurance;
- gate;
- review count;
- overlap status;
- limitações;
- warnings críticos.

## 17.2 Review-level evidence

Exibir:

- ReviewItems;
- currentness;
- ROBIS;
- OutcomeEvidence;
- certainty;
- item role;
- analysis disposition.

## 17.3 Overlap

Exibir:

- membership;
- cluster;
- CCA;
- pairwise overlap;
- completeness;
- resolution;
- rationale.

## 17.4 Metodológica

Exibir:

- protocolo;
- policies;
- searches;
- search exports;
- selection flow;
- exclusions;
- reviewer assignments;
- quality controls;
- extraction/overlap verification;
- appraisal controls.

## 17.5 Auditável

Exibir:

- schema version;
- IDs/versioning;
- artifacts/hashes;
- Report lineage;
- Result provenance;
- dependency lineage;
- invalidations;
- assurance records;
- publication issues.

---

# 18. identity/question/investigation

Exibir literalmente dados projetados.

Não inferir:

- PRIOR compliance;
- systematicity superior ao estado canônico;
- readiness real.

---

# 19. Protocol

Exibir:

- artifact UUID;
- storage key;
- hash;
- hash algorithm;
- created_at;
- status.

Se houver registro externo no futuro, somente exibir se projetado.

---

# 20. Method policies

Exibir por policy:

- code;
- stage;
- planned;
- rationale;
- risk;
- mitigation;
- impact;
- resolution;
- linked artifact quando existir.

Protocol deviations/amendments ativos deverão ficar visíveis.

---

# 21. Reviewer assignments

Exibir:

- stage;
- actor;
- actor type;
- role;
- qualification payload;
- independent;
- scope;
- conflict.

Não reduzir qualification a selo sem conteúdo auditável.

---

# 22. Quality controls

Exibir:

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
- performed_at.

---

# 23. Searches

Exibir:

- source;
- platform;
- source class;
- executed_at;
- result count;
- strategy version;
- export artifact;
- export hash/storage metadata.

Search presence não equivale a search peer review.

---

# 24. Selection flow

Exibir pelo menos:

- search hits;
- unique Report targets;
- screening decisions;
- title/abstract decisions;
- full-text decisions;
- full-text exclusions;
- adjudications;
- included ReviewItems.

Full-text exclusions devem manter:

- target;
- reason;
- reviewer;
- date.

---

# 25. ReviewItems

Exibir:

- Review Study ID/version;
- title;
- item role;
- eligibility basis;
- last search date;
- currentness;
- membership completeness;
- ROBIS;
- Reports.

Reports deverão preservar:

- Report ID/version;
- relation type;
- update/correction/retraction lineage quando aplicável.

---

# 26. Primary-study membership

Exibir:

- ReviewItem;
- primary Study;
- source Report;
- source location;
- identity confidence;
- verification;
- context.

Primary Studies são camada de overlap/auditoria:

> **não viram automaticamente referências principais do Overview.**

---

# 27. References

Lista principal:

- Review Reports;
- updates/corrections relevantes;
- supporting Reports usados nos Results/provenance.

Renderer não deverá expandir todos os primary-study Reports para a bibliografia principal por default.

---

# 28. Publication issues

Exibir:

1. errors;
2. warnings.

Não ocultar warning por existir publishable=true.

---

# 29. Conclusion/applicability/limitations

Usar literalmente a ProductVersion.

Renderer não reescreve conclusão com base em:

- número de Reviews;
- CCA;
- ROBIS;
- estimate;
- certainty.

---

# 30. Projection Readiness Review

A `OverviewOfReviewsView 0.1` validada no Documento 141 já projeta o núcleo científico necessário, incluindo:

- identity/question/investigation;
- protocolo;
- policies básicas;
- ReviewItems;
- membership;
- overlap;
- CCA/pairwise;
- OutcomeEvidence;
- ROBIS;
- certainty;
- concordance;
- references;
- gate/assurance.

Entretanto, a revisão de renderização identificou campos auditáveis ainda ausentes ou insuficientes.

---

# 31. Lacunas da projeção

Antes de criar template operacional, a View deverá ser ampliada aditivamente para expor:

## 31.1 Method decisions completos

Atualmente `method.policies` não projeta integralmente:

- risk_payload;
- mitigation_payload;
- linked artifact;
- method decisions relevantes que não usem prefixo `overview_`, como protocol deviations/amendments.

## 31.2 Reviewer conflicts

`reviewer_assignments` não projeta:

- conflict_payload;
- assigned_at/ended_at.

## 31.3 Quality controls completos

A View não projeta integralmente:

- qualification_payload;
- scope_payload completo;
- agreement_payload;
- discrepancy_payload;
- resolution_payload;
- evidence artifact metadata;
- notes.

## 31.4 Search export artifacts

Search projeta `export_artifact_uuid`, mas não:

- storage key;
- hash;
- hash algorithm;
- artifact status.

## 31.5 Selection details

`selection_flow` não projeta:

- unique Report targets;
- title/abstract decisions;
- adjudications;
- excluded full-text records com reason/reviewer/date.

## 31.6 Review Report lineage

ReviewItems projetam Reports, mas não o grafo explícito de:

- update_of;
- correction_of;
- retraction/retraction_of;
- demais `ReportRelation` relevantes.

A lineage não deverá ser inferida por data/título.

## 31.7 OutcomeEvidence source provenance

A View não projeta integralmente:

- `ResultSource`;
- source Report;
- source location;
- extraction method;
- provenance relevante do Result/Synthesis/Certainty selecionado.

## 31.8 Dependency lineage/invalidation detail

`audit.invalidated_dependencies` é booleano, porém a View não oferece:

- lineage de dependências;
- detalhe das dependências invalidadas;
- source/target/dependency type.

---

# 32. Projection Readiness Gate

Resultado:

> **NOT_READY para template operacional.**

Motivo:

o núcleo científico está presente, mas a camada de auditoria/reprodutibilidade ainda não possui projeção suficiente para que um renderer permaneça completamente read-only.

Essa conclusão:

> **não invalida o PASS técnico do Documento 141.**

Ela representa requisito da camada de apresentação descoberto após o PASS do contrato.

---

# 33. Evolução aditiva

Não reabrir:

`database/019_overview_of_reviews_contract.sql`

Criar migration aditiva:

> `database/020_overview_of_reviews_view_rendering_readiness.sql`

Objetivos:

1. ampliar `OverviewOfReviewsView 0.1`;
2. preservar o schema version se a mudança permanecer aditiva;
3. não alterar as sete estruturas científicas;
4. não recalcular overlap;
5. não alterar publication semantics;
6. adicionar testes de projection readiness;
7. manter todas as regressões verdes.

---

# 34. Testes de projection readiness

A migration 020 deverá validar, no mínimo:

- OVR-T01 — schema permanece `oes.overview_of_reviews_view/0.1`;
- OVR-T02 — method decisions completos;
- OVR-T03 — reviewer conflict/assignment metadata;
- OVR-T04 — quality-control audit payloads;
- OVR-T05 — search export hash/storage metadata;
- OVR-T06 — selection/exclusion details;
- OVR-T07 — Review A update lineage explícita;
- OVR-T08 — OutcomeEvidence ResultSource/provenance;
- OVR-T09 — dependency lineage/invalidation detail;
- OVR-T10 — overlap/CCA/publication/assurance semantics permanecem inalteradas;
- OVR-T11 — migration 020 idempotent reapply;
- OVR-T12 — rebuild/regressions PASS.

---

# 35. Próxima etapa

> **Implementar migration 020 de Projection Readiness, validar OVR-T01–T12 e somente então decidir se o Overview está READY para template.**

---

**Resultado final:** contrato de renderização definido; **Projection Readiness Gate = NOT_READY para template** até extensão aditiva da View.
