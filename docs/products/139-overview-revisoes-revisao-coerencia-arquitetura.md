# 139 — Overview de Revisões: Revisão de Coerência e Decisão Arquitetural

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** decisão arquitetural inicial consolidada  
**Dependências:** Documentos 02, 22, 40 e 138; OES-P1; migrations 002–018

---

# 1. Finalidade

Revisar a especificação científica do Documento 138 contra o modelo OES-P1 já implementado e decidir:

1. o que será reutilizado sem alteração;
2. quais lacunas exigem camada especializada;
3. qual será a unidade de versionamento;
4. como representar reviews, primary Studies, overlap, resultados e concordância;
5. quais dados serão persistidos e quais permanecerão derivados;
6. quais invariantes deverão orientar o contrato de dados.

---

# 2. Resultado agregado

> **PASS WITH SPECIALIZED LAYER**

O OES-P1 já representa adequadamente:

- systematic review;
- Reports de uma review;
- Results de uma review;
- ROBIS;
- Synthesis;
- CertaintyAssessment;
- Search/Screening;
- reviewer controls;
- assurance;
- provenance;
- Product.

A lacuna arquitetural é específica do método de Overview:

- seleção de ReviewVersions concretas;
- membership review → primary Study;
- clusters de reviews;
- política de overlap/double counting;
- seleção de outcome evidence relevante;
- concordância/divergência entre reviews.

---

# 3. Decisão — systematic review não vira nova entidade

Uma systematic review continuará sendo:

> **Study**

com:

> `StudyVersion.study_type = systematic_review`

ou subtipo equivalente explicitamente permitido.

Não criar:

- `OverviewReview`;
- `ReviewEntity`;
- cópia paralela de Study.

Motivo:

- identidade científica da review já pertence a Study;
- múltiplos Reports já são suportados;
- Results já pertencem ao Study;
- RiskAssessment pode atingir Study;
- versionamento StudyVersion já existe.

---

# 4. Review version como unidade concreta

O Overview não deve apontar apenas para Study entity.

Cada unidade incluída será:

> **uma StudyVersion concreta da systematic review.**

Motivo:

- review pode ser atualizada;
- eligibility/search date/resultados podem mudar;
- uma versão anterior não deve ser silenciosamente substituída.

Regra:

> `overview.review_item.review_study_version_uuid` será FK para `evidence.study_version(version_uuid)`.

Trigger deverá confirmar:

- entidade = Study;
- StudyVersion é do tipo systematic review permitido;
- EntityVersion não está invalidada.

---

# 5. Multiple reports e updates

Reutilizar:

- `evidence.study_report_link`;
- `evidence.report_relation`;
- `core.entity_version`.

Quando update for realmente continuação da mesma review:

> preferir mesma Study entity + nova StudyVersion.

Reports poderão ser ligados por:

- `update_of`;
- `correction_of`;
- `retraction_of`;
- `supplement_to`.

Não contar dois Reports como duas reviews.

---

# 6. Search e Screening

Reutilizar integralmente:

- `investigation.search`;
- `investigation.search_hit`;
- `investigation.screening_decision`.

O Overview não precisa de tabela própria de busca/seleção.

Screening continua registrando:

- record/report-level decisions;
- Study-level decisions quando a identidade da review estiver resolvida.

A camada Overview começa:

> **depois da identificação da Review StudyVersion elegível.**

---

# 7. Risk of bias da review

Reutilizar:

> `appraisal.risk_assessment_version`

Target:

> Review Study entity.

Framework default:

> `ROBIS`

Não criar tabela especializada de ROBIS para Overview.

Os domínios permanecem em:

> `appraisal.risk_assessment_domain`

AMSTAR 2/JBI, se usados, também podem ser representados no mesmo framework genérico, sem fusão de scores.

---

# 8. Results da review

Pooled estimates e review-level outcome data permanecem:

> `evidence.result_version`

associados ao Review Study.

Não criar cópia do estimate dentro da camada Overview.

A camada especializada apenas selecionará:

> **qual ResultVersion da review é utilizada no Overview e em qual contexto analítico.**

---

# 9. Synthesis

Reutilizar:

> `synthesis.synthesis_version`

Somente criar nova Synthesis OES quando houver síntese adicional legítima do Overview.

Não criar Synthesis automaticamente apenas porque reviews foram comparadas.

`product.synthesis_link` continuará sendo o vínculo Product → Synthesis.

---

# 10. Certainty

Reutilizar:

> `appraisal.certainty_assessment_version`

Quando certainty vier da review:

- representar como versão concreta;
- preservar framework/rating/rationale;
- vincular ao outcome/result/synthesis apropriado por provenance ou camada Overview.

Não criar certainty global do Overview.

---

# 11. Reviewer controls e assurance

Reutilizar:

- `investigation.reviewer_assignment`;
- `investigation.quality_control_record`;
- `product.assurance_record`;
- `product.assurance_level()`.

Não criar subsystem paralelo de reviewers.

Formal Overview exige:

> **A3 + qualified human stage controls.**

---

# 12. Unidade de versionamento do método Overview

Não criar `OverviewVersion` paralela.

A unidade metodológica versionada será:

> **InvestigationVersion**

e o produto comunicacional continuará:

> **ProductVersion**

As estruturas especializadas do schema `overview` serão vinculadas à InvestigationVersion.

Motivo:

- corpus, membership, overlap e análise são parte da investigação;
- Product apenas comunica uma versão concreta desse trabalho;
- nova execução material do Overview pode criar nova InvestigationVersion;
- correção editorial do Product não precisa reescrever o corpus.

---

# 13. Camada especializada aprovada

Criar schema candidato:

> `overview`

Com **sete estruturas persistentes**:

1. `overview.review_item`;
2. `overview.primary_study_membership`;
3. `overview.review_cluster`;
4. `overview.cluster_membership`;
5. `overview.overlap_resolution`;
6. `overview.outcome_evidence`;
7. `overview.concordance_assessment`.

Não criar estruturas adicionais sem necessidade demonstrada no contrato/testes.

---

# 14. overview.review_item

Função:

> registrar a StudyVersion da systematic review que pertence ao corpus analítico do Overview.

Campos mínimos candidatos:

- `review_item_uuid`;
- `investigation_version_uuid`;
- `review_study_version_uuid`;
- `item_role`;
- `eligibility_basis_payload`;
- `last_search_date`;
- `currentness_status`;
- `currentness_rationale`;
- `included_at`;
- `status`.

Item roles candidatos:

- `primary`;
- `supporting`;
- `contextual`.

Default formal:

> reviews analíticas = `primary`.

---

# 15. Currentness da review

`last_search_date` é dado extraído e deverá ser persistido.

`currentness_status` é julgamento metodológico e também poderá ser persistido:

- `current`;
- `possibly_outdated`;
- `outdated`;
- `unclear`.

Não derivar currentness apenas da publication date.

O rationale é obrigatório quando status != current.

---

# 16. overview.primary_study_membership

Função:

> representar a verdade auditável ReviewVersion → primary Study.

Campos mínimos:

- `membership_uuid`;
- `review_item_uuid`;
- `primary_study_entity_uuid`;
- `source_report_version_uuid`;
- `source_location`;
- `identity_confidence`;
- `verification_status`;
- `verified_by`;
- `verifier_actor_type`;
- `verified_at`;
- `context_payload`;
- `status`.

---

# 17. Materialização mínima de primary Studies

Para formal overlap:

> **todo estudo primário identificado em uma review incluída deverá possuir Study entity no OES.**

Isso não significa extrair todos os Results do estudo.

Pode ser uma materialização mínima de identidade:

- Study ID;
- identificadores;
- design quando disponível;
- Reports conhecidos.

Motivo:

> overlap deve operar em Study identity, não em citation string.

---

# 18. Membership incompleto/ambíguo

Não criar linha falsa apontando para Study incorreto.

Quando uma citação ainda não puder ser resolvida:

- mantê-la fora da membership confirmada;
- registrar incompletude no ReviewItem/controle metodológico;
- formal Overview não poderá declarar membership completo.

Decisão:

> **v0.1 não cria entidade paralela “unresolved citation”.**

Artefatos/listas de resolução podem preservar candidatos até materialização.

---

# 19. Estado de completude de membership

Adicionar a `review_item`:

> `membership_completeness`

Valores:

- `complete`;
- `partial`;
- `unknown`.

Formal Overview:

> requer `complete` para todas as reviews usadas em cálculo completo de overlap/deduplicação.

---

# 20. Identity confidence

`primary_study_membership.identity_confidence`:

- `high`;
- `medium`;
- `low`.

Formal overlap principal:

> apenas high/medium podem ser usados; low exige resolução antes de publication gate.

---

# 21. Verification status de membership

Estados:

- `unverified`;
- `ai_verified`;
- `human_verified`;
- `human_consensus`.

Formal Overview:

> membership que sustenta overlap/deduplication exige human verification conforme protocolo.

IA não pode preencher human status.

---

# 22. overview.review_cluster

Função:

> agrupar reviews suficientemente relacionadas para análise de overlap/concordância.

Campos:

- `cluster_uuid`;
- `investigation_version_uuid`;
- `cluster_code`;
- `label`;
- `scope_payload`;
- `status`.

O cluster não substitui:

- PICO;
- Outcome;
- ReviewItem.

---

# 23. overview.cluster_membership

Função:

> vincular ReviewItems aos clusters e registrar sua disposição analítica.

Campos:

- `cluster_uuid`;
- `review_item_uuid`;
- `analysis_disposition`;
- `rationale`;
- `sequence_no`;
- `status`.

Disposition:

- `retained`;
- `prioritized`;
- `excluded_overlap`;
- `contextual_only`.

---

# 24. Excluded_overlap não é screening exclusion

Uma review pode ser metodologicamente elegível e incluída no corpus, mas não alimentar determinada síntese por overlap.

Portanto:

> `excluded_overlap` pertence à análise do cluster, não a `ScreeningDecision`.

Isso evita reescrever retrospectivamente a elegibilidade.

---

# 25. overview.overlap_resolution

Função:

> registrar a política escolhida para cada cluster.

Campos:

- `overlap_resolution_uuid`;
- `cluster_uuid`;
- `strategy`;
- `decision_payload`;
- `rationale`;
- `decided_by`;
- `actor_type`;
- `verification_status`;
- `verified_by`;
- `verifier_actor_type`;
- `verified_at`;
- `decided_at`;
- `status`.

Strategies:

- `include_all_deduplicate_outcomes`;
- `prioritize_review`;
- `include_all_separate_estimates`.

---

# 26. Regra de resolução

`prioritize_review` exige:

- pelo menos um ClusterMembership `prioritized`;
- rationale;
- critérios explícitos no decision_payload.

`include_all_deduplicate_outcomes` exige:

- membership completa;
- OutcomeEvidence com rastreabilidade ao Study set.

`include_all_separate_estimates`:

- proíbe combinação estatística que pressuponha independência;
- exige disclosure de overlap.

---

# 27. overview.outcome_evidence

Função:

> selecionar a evidência de outcome da review que efetivamente entra no Overview.

Não copia o valor científico.

Campos:

- `outcome_evidence_uuid`;
- `review_item_uuid`;
- `result_version_uuid` nullable;
- `synthesis_version_uuid` nullable;
- `certainty_assessment_version_uuid` nullable;
- `outcome_entity_uuid`;
- `comparison_payload`;
- `timepoint_payload`;
- `analysis_role`;
- `primary_study_set_status`;
- `extraction_payload`;
- `verification_status`;
- verifier fields;
- `status`.

Constraint:

> pelo menos `result_version_uuid` ou `synthesis_version_uuid` deve existir.

---

# 28. Coerência do OutcomeEvidence

Se `result_version_uuid` existir:

> o Result deverá pertencer ao mesmo Review Study do ReviewItem.

Se `synthesis_version_uuid` existir:

> provenance deverá demonstrar adoção/derivação da review correspondente ou da Investigation do Overview.

Não aceitar Result de outra review por engano.

---

# 29. Analysis role

Valores candidatos:

- `primary_estimate`;
- `supporting_estimate`;
- `narrative_only`;
- `excluded_overlap`;
- `excluded_scope`.

A role descreve uso no Overview, não validade intrínseca da review.

---

# 30. Primary-study set status por outcome

Campo:

> `primary_study_set_status`

Valores:

- `complete`;
- `partial`;
- `unknown`;
- `not_applicable`.

Necessário porque:

- membership global da review pode ser completa;
- mas a composição específica de um outcome/meta-analysis pode não estar identificável.

---

# 31. overview.concordance_assessment

Função:

> persistir julgamento interpretativo sobre concordância/divergência entre evidências de reviews comparáveis.

Campos:

- `concordance_uuid`;
- `cluster_uuid`;
- `outcome_entity_uuid` nullable;
- `comparison_payload`;
- `timepoint_payload`;
- `concordance_state`;
- `dimensions_payload`;
- `rationale`;
- `assessed_by`;
- `actor_type`;
- `verification_status`;
- verifier fields;
- `assessed_at`;
- `status`.

States:

- `concordant`;
- `directionally_discordant`;
- `magnitude_discordant`;
- `certainty_discordant`;
- `not_comparable`.

---

# 32. Concordância não é votação

A função não contará:

- quantas reviews são “positivas”;
- quantas são “negativas”.

O rationale deverá poder considerar:

- overlap;
- scope;
- search date;
- RoB;
- method;
- effect estimate;
- heterogeneity;
- certainty.

---

# 33. Dados que NÃO serão persistidos como verdade primária

Não criar tabelas primárias para:

- CCA;
- pairwise overlap percentage;
- overlap heatmap;
- review count por cluster;
- unique primary Study count;
- coverage counts;
- concordance summary agregado;
- currentness age em dias.

Esses dados serão derivados.

---

# 34. Derivação de overlap

Função futura candidata:

> `overview.overlap_metrics(investigation_version_uuid, cluster_uuid)`

Deverá derivar, conforme membership disponível:

- number of reviews;
- total study occurrences;
- unique primary Studies;
- redundant occurrences;
- pairwise intersections;
- pairwise proportions;
- CCA quando calculável;
- membership completeness.

---

# 35. CCA

Quando:

- c = número de reviews;
- r = número de unique primary Studies;
- N = total de ocorrências Study × Review;

CCA:

> `(N - r) / (r*c - r)`

apenas quando denominador > 0 e membership for suficiente.

A função deverá retornar:

- value;
- calculable boolean;
- completeness state.

Não categorizar automaticamente o CCA como baixo/moderado/alto sem regra protocolar versionada.

---

# 36. Review-level Results continuam científicos

Não copiar para `outcome_evidence`:

- estimate;
- CI;
- p-value;
- heterogeneity;
- sample size;

quando já existem em ResultVersion/SynthesisVersion.

O specialized layer guarda:

> **seleção + contexto + decisão de uso.**

---

# 37. Review-level certainty

Não duplicar rating GRADE.

`outcome_evidence.certainty_assessment_version_uuid` seleciona a versão existente.

Quando a review relata GRADE mas ainda não existe CertaintyAssessment no OES:

> materializar CertaintyAssessment antes de vincular.

---

# 38. RiskAssessment relationship

Formal Overview:

> todo ReviewItem analítico deverá possuir RiskAssessment ROBIS ativo na Investigation do Overview ou uma versão validamente reutilizada/derivada com provenance explícita.

Publication gate não deve aceitar ausência silenciosa de appraisal.

---

# 39. Search date

`review_item.last_search_date` deverá vir de:

- Report;
- supplement;
- protocol/update;
- informação explícita na review.

Não inferir do publication date.

Provenance deverá preservar a origem.

---

# 40. Investigation depth

Para **formal systematic Overview v0.1**:

> supporting Investigation deverá usar `depth_level=N4`.

Interpretação:

> N4 descreve a profundidade metodológica da Investigation, não transforma Overview em produto N4.

Internal developmental Overview poderá usar N3/A0–A1 quando explicitamente não formal.

---

# 41. Product

O Product continuará em:

> `product.product_version`

Product type:

> `overview_of_reviews`

Um ProductVersion terá:

- one primary Investigation;
- optional Synthesis links;
- optional Certainty links;
- conclusion;
- limitations;
- currency;
- assurance.

Não criar `OverviewProduct` paralelo.

---

# 42. Ligação Product ↔ specialized layer

Não criar FK direta de Product para cada ReviewItem.

O vínculo é:

> ProductVersion → primary InvestigationVersion → Overview structures.

Provenance/dependency edges serão usados para versões científicas específicas que sustentam o Product.

---

# 43. Review items e Product references

Referências do Product deverão ser derivadas a partir de:

- Reports canônicos das Review StudyVersions;
- Reports que documentam update/correction;
- Reports de primary Studies apenas quando necessários a provenance/overlap, não como referências analíticas principais.

A lista principal do Overview deve privilegiar:

> **as reviews incluídas.**

---

# 44. Search/selection controls

Reutilizar ReviewerAssignment e QualityControlRecord.

Formal gate deverá exigir:

- search peer reviewer;
- primary + secondary screening;
- adjudication/consensus quando necessário.

Não criar tabelas Overview específicas para esses controles.

---

# 45. Appraisal controls

Formal gate:

- pelo menos dois julgamentos humanos ou verificação independente conforme protocolo;
- ReviewItem ↔ ROBIS coverage completo;
- QualityControlRecord `risk_of_bias_verification`;
- ReviewerAssignment `appraisal_reviewer`.

---

# 46. Extraction controls

Formal gate:

- extraction verification;
- ReviewerAssignments;
- QualityControlRecord `critical_data_verification`;
- escopo deverá incluir review characteristics, outcome evidence e membership.

---

# 47. Overlap control

Não existe control_type específico no baseline.

Decisão:

> **usar `control_type=other` + `scope_payload.control_code='overview_overlap_verification'` na v0.1.**

Evita alterar enum global antes de necessidade comprovada.

Formal gate exige:

- qualified human actor;
- independent=true;
- passed;
- ReviewerAssignment compatível, inicialmente `data_verifier` ou `other`.

---

# 48. Concordance control

Quando concordance assessments sustentarem conclusão material:

> usar `control_type=other` + `control_code='overview_concordance_verification'`.

Formal gate deverá exigir verificação humana independente.

---

# 49. Statistical review

Se não houver reanálise quantitativa nova:

> `synthesis_statistical_review` pode ser not_applicable com rationale.

Se houver reanalysis:

> statistical reviewer qualificado é obrigatório.

Não considerar simples juxtaposição de estimates como nova meta-analysis.

---

# 50. Assurance

Formal Overview:

- AI methodological verification;
- owner governance approval;
- expert independent review;
- assurance derived = A3;
- qualified stage controls preservados.

A3:

> **não substitui overlap verification, search, screening, appraisal ou extraction.**

---

# 51. Product publication gate — núcleo

Formal publication deverá falhar se houver:

- wrong product type;
- missing primary Investigation;
- depth diferente de N4 para formal Overview;
- missing protocol;
- missing review Search;
- incomplete screening;
- review item com target não systematic-review StudyVersion;
- ReviewItem sem currentness;
- ReviewItem sem ROBIS;
- membership incompleta;
- low-confidence unresolved identity;
- missing overlap cluster/resolution quando aplicável;
- outcome evidence incompleto;
- double counting detectável;
- missing conflict/concordance handling;
- missing qualified human controls;
- invalidated dependency;
- outdated/unresolved critical review sem disclosure;
- missing currency;
- assurance < A3;
- missing publication status/date.

---

# 52. Internal developmental gate

A0/A1 internal Overview poderá existir com:

- incomplete membership;
- AI-only classification;
- no A3;
- under_review;
- publication_date NULL.

Mas deverá sempre exibir:

- developmental status;
- overlap completeness;
- absence of human verification;
- nonpublishable state.

---

# 53. Imutabilidade/versionamento

ReviewItem membership e specialized analysis são scientific state.

Não editar silenciosamente após publication.

Mudança material exige:

- nova InvestigationVersion e/ou
- novos records com supersession, conforme estrutura final.

O contrato físico deverá preferir append-preserving semantics nos julgamentos.

---

# 54. Relação de updates das reviews

Quando uma Review StudyVersion é atualizada:

- nova StudyVersion;
- ReviewItem da nova Investigation deve selecionar versão concreta;
- antiga versão permanece auditável;
- ReportRelation update_of ajuda provenance;
- não incluir simultaneamente versões original/updated como reviews independentes, salvo razão metodológica explícita.

---

# 55. Relação com primary Studies

Primary Studies materializados para overlap:

- não se tornam automaticamente unidades de síntese do Overview;
- não entram em `outcome_evidence` diretamente;
- não transformam o Overview em N4 de primary evidence.

Se o produto passar a extrair/analisar primary Results de forma substantiva:

> reavaliar roteamento.

---

# 56. Supplemental primary studies

Nenhuma estrutura especializada adicional será criada para supplemental primary studies na v0.1.

Se necessários:

> **fora do escopo formal v0.1.**

Isso reduz risco de Overview híbrido metodologicamente ambíguo.

---

# 57. Currentness

Currentness não será inferido globalmente por threshold fixo.

O protocolo poderá definir regra.

A arquitetura persiste:

- raw last_search_date;
- currentness_status;
- rationale.

Isso permite mudança futura sem perder o dado fonte.

---

# 58. Derived Overview View

View futura:

> `product.overview_of_reviews_view(product_version_uuid)`

Schema:

> `oes.overview_of_reviews_view/0.1`

Deverá projetar:

- identity;
- question;
- investigation;
- protocol;
- searches;
- selection flow;
- review items;
- review reports;
- review appraisal;
- primary-study membership;
- overlap metrics;
- clusters;
- overlap resolutions;
- outcome evidence;
- certainty;
- concordance;
- currentness;
- limitations;
- conclusion;
- references;
- update state;
- audit/assurance.

Renderer não consulta tabelas diretamente.

---

# 59. Synthetic fixture required before template

Fixture formal candidata:

- 3 Review StudyVersions;
- 5 primary Study entities;
- Review A: Studies 1,2,3;
- Review B: Studies 2,3,4;
- Review C: Studies 3,4,5;
- overlap membership completo;
- CCA calculável;
- A/B parcialmente concordantes;
- C discordante em outcome selecionado;
- Review C high ROBIS;
- diferentes last_search_dates;
- pelo menos um review Report update relation;
- GRADE disponível em duas reviews;
- one overlap cluster;
- explicit resolution strategy;
- synthetic qualified human controls;
- synthetic A3.

---

# 60. Adversarial requirements

Contrato deverá provar:

1. Report duplicado não cria ReviewItem duplicado;
2. old + updated ReviewVersion não são contadas como independentes;
3. primary Study compartilhado não é duplicado na unique-study count;
4. CCA é bloqueado/flagged quando membership incompleta;
5. low-confidence identity bloqueia formal overlap;
6. Result de review errada não entra em OutcomeEvidence;
7. review sem ROBIS bloqueia formal publication;
8. overlap sem resolution bloqueia;
9. `include_all_separate_estimates` não permite meta-analysis de review estimates;
10. certainty global não é criada;
11. AI não cria human membership verification;
12. A3 não bypassa stage controls;
13. review currentness baseada em publication date apenas é rejeitada;
14. excluded_overlap não vira screening exclusion;
15. supplemental primary study não entra no corpus analítico v0.1;
16. invalidated Review/Result dependency bloqueia;
17. statistical reanalysis sem reviewer/code/dataset bloqueia;
18. N0–N4/Mapa regressions continuam verdes.

---

# 61. Estruturas rejeitadas

Não criar:

- nova entidade Review;
- nova entidade Overview;
- tabela própria de ROBIS;
- tabela própria de GRADE;
- tabela de Search do Overview;
- tabela de Screening do Overview;
- tabela persistente CCA;
- tabela persistente pairwise overlap;
- tabela persistente heatmap;
- score global de review quality;
- score global de certainty do Overview;
- subsystem de ReviewerAssignment;
- supplemental-primary-study layer v0.1.

---

# 62. Resultado da revisão

> **A arquitetura científica do Overview é compatível com OES-P1 mediante uma camada especializada mínima de sete estruturas.**

Os maiores princípios de contenção são:

- reuse Study/Report/Result/Risk/Synthesis/Certainty;
- persist membership e decisões, não métricas derivadas;
- materializar primary Study identity para overlap;
- separar eligibility de overlap disposition;
- tratar OutcomeEvidence como link/context, não cópia de Result;
- formal Overview = N4-depth Investigation + A3 + human controls;
- nenhum template antes de PASS técnico do contrato/view.

---

# 63. Próxima etapa

> **Criar o Contrato de Dados v0.1 do Overview de Revisões.**

O contrato deverá fechar:

1. DDL lógico das sete estruturas;
2. triggers/guards;
3. funções de overlap;
4. publication gate;
5. `OverviewOfReviewsView`;
6. fixture sintética;
7. testes positivos/adversariais;
8. rebuild/regressões;
9. somente depois contrato de renderização/template.

---

**Resultado:** revisão de coerência concluída; camada especializada mínima aprovada; implementação ainda não iniciada.
