# 140 — Overview de Revisões: Contrato de Dados v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status:** contrato de dados candidato v0.1  
**Dependências:** Documentos 138–139; OES-P1; migrations 002–018  
**Migration prevista:** `database/019_overview_of_reviews_contract.sql`

---

# 1. Finalidade

Transformar a especificação científica e a decisão arquitetural do Overview de Revisões em contrato lógico implementável.

O contrato deve permitir:

- selecionar StudyVersions de systematic reviews;
- representar membership Review → primary Study;
- derivar overlap;
- agrupar reviews relacionadas;
- registrar decisão explícita sobre overlap;
- selecionar Result/Synthesis/Certainty usados pelo Overview;
- registrar concordância/divergência;
- construir publication gate;
- projetar `OverviewOfReviewsView`;
- testar double counting, updates, currentness, ROBIS, assurance e controles humanos.

---

# 2. Princípio de persistência

Persistir:

> **identidades, memberships, seleções e julgamentos metodológicos.**

Derivar:

> **contagens e métricas matemáticas de overlap.**

Não persistir como verdade primária:

- CCA;
- pairwise overlap;
- heatmap;
- unique-study count;
- redundant-occurrence count;
- review-count summaries.

---

# 3. Schema

Criar:

> `overview`

Sem criar nova entidade científica Review.

Systematic review continua:

> `Study → StudyVersion`

---

# 4. Estrutura 1 — overview.review_item

## 4.1 DDL lógico

```sql
CREATE TABLE overview.review_item (
    review_item_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    review_study_version_uuid uuid NOT NULL
        REFERENCES evidence.study_version(version_uuid),
    item_role text NOT NULL CHECK (
        item_role IN ('primary','supporting','contextual')
    ),
    eligibility_basis_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    last_search_date date,
    membership_completeness text NOT NULL CHECK (
        membership_completeness IN ('complete','partial','unknown')
    ),
    currentness_status text NOT NULL CHECK (
        currentness_status IN (
            'current','possibly_outdated','outdated','unclear'
        )
    ),
    currentness_rationale text,
    included_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded','excluded')
    ),
    UNIQUE (investigation_version_uuid,review_study_version_uuid)
);
```

---

# 5. Guard de ReviewItem

Trigger:

> `overview.assert_review_item_target()`

Deverá verificar:

1. target existe;
2. target pertence a Study entity;
3. StudyVersion está current ou explicitamente selecionada como versão histórica válida;
4. `study_type='systematic_review'` na v0.1 formal;
5. Review StudyVersion não está invalidada;
6. `currentness_rationale` é obrigatório se status != current;
7. `membership_completeness=complete` não pode coexistir com registro ativo de resolução pendente documentado no protocolo/controle, quando detectável.

O gate formal fará verificações adicionais.

---

# 6. Review update identity

Quando uma review for atualização de outra:

- preferir mesma Study entity com nova StudyVersion;
- Reports podem usar `ReportRelation.update_of`;
- Overview seleciona uma StudyVersion concreta.

Guard futuro deverá bloquear dois ReviewItems ativos da mesma Study entity dentro da mesma Investigation, salvo override metodológico explícito.

Regra v0.1:

> **uma Study entity = no máximo um ReviewItem ativo por InvestigationVersion.**

---

# 7. Estrutura 2 — overview.primary_study_membership

## 7.1 DDL lógico

```sql
CREATE TABLE overview.primary_study_membership (
    membership_uuid uuid PRIMARY KEY,
    review_item_uuid uuid NOT NULL
        REFERENCES overview.review_item(review_item_uuid),
    primary_study_entity_uuid uuid NOT NULL
        REFERENCES evidence.study(entity_uuid),
    source_report_version_uuid uuid
        REFERENCES evidence.report_version(version_uuid),
    source_location text,
    identity_confidence text NOT NULL CHECK (
        identity_confidence IN ('high','medium','low')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    context_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    UNIQUE (review_item_uuid,primary_study_entity_uuid)
);
```

---

# 8. Membership guard

Trigger:

> `overview.assert_primary_study_membership()`

Verificar:

- primary target é Study;
- primary Study não é a própria review Study;
- source Report, quando presente, pertence à Review Study via StudyReportLink;
- `human_verified`/human_consensus exige verifier humano;
- `ai_verified` exige ai_system;
- `unverified` não pode possuir verifier;
- low confidence não pode ser human_consensus sem rationale/provenance.

---

# 9. Materialização dos primary Studies

Formal Overview exige Study entity para cada primary study identificado.

Não exige:

- Result extraction;
- appraisal OES próprio;
- full-text extraction completa.

Materialização mínima é suficiente para:

- identity;
- identifiers;
- Reports;
- overlap.

---

# 10. Membership completeness

`review_item.membership_completeness` é julgamento de completude da lista de studies incluídos na review.

Formal publication:

> todas as ReviewItems analíticas usadas em overlap deverão estar `complete`.

`partial`/unknown:

- permitido em A0/A1 developmental;
- bloqueia CCA formal completo;
- bloqueia publicação formal quando a review participa da análise de overlap.

---

# 11. Estrutura 3 — overview.review_cluster

## 11.1 DDL lógico

```sql
CREATE TABLE overview.review_cluster (
    cluster_uuid uuid PRIMARY KEY,
    investigation_version_uuid uuid NOT NULL
        REFERENCES investigation.investigation_version(version_uuid),
    cluster_code text NOT NULL,
    label text NOT NULL,
    scope_payload jsonb NOT NULL,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    UNIQUE (investigation_version_uuid,cluster_code)
);
```

---

# 12. Estrutura 4 — overview.cluster_membership

## 12.1 DDL lógico

```sql
CREATE TABLE overview.cluster_membership (
    cluster_uuid uuid NOT NULL
        REFERENCES overview.review_cluster(cluster_uuid),
    review_item_uuid uuid NOT NULL
        REFERENCES overview.review_item(review_item_uuid),
    analysis_disposition text NOT NULL CHECK (
        analysis_disposition IN (
            'retained','prioritized','excluded_overlap','contextual_only'
        )
    ),
    rationale text NOT NULL,
    sequence_no integer,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    PRIMARY KEY (cluster_uuid,review_item_uuid)
);
```

---

# 13. Cluster-membership guard

Trigger:

> `overview.assert_cluster_membership_consistency()`

Verificar:

- ReviewItem e Cluster pertencem à mesma InvestigationVersion;
- `excluded_overlap` não modifica ScreeningDecision;
- ReviewItem contextual só poderá ser `contextual_only` ou retained com rationale explícito;
- cluster ativo não poderá conter ReviewItem superseded.

---

# 14. Estrutura 5 — overview.overlap_resolution

## 14.1 DDL lógico

```sql
CREATE TABLE overview.overlap_resolution (
    overlap_resolution_uuid uuid PRIMARY KEY,
    cluster_uuid uuid NOT NULL
        REFERENCES overview.review_cluster(cluster_uuid),
    strategy text NOT NULL CHECK (
        strategy IN (
            'include_all_deduplicate_outcomes',
            'prioritize_review',
            'include_all_separate_estimates'
        )
    ),
    decision_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text NOT NULL,
    decided_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    decided_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    )
);
```

Unique index:

> uma resolução ativa por cluster.

---

# 15. Limitação formal v0.1 — estratégia de deduplicação por outcome

A revisão do contrato identificou uma limitação importante.

`include_all_deduplicate_outcomes` exige:

> **membership Study-level específica para cada outcome/estimate.**

As sete estruturas mínimas representam:

- membership review-level;
- status do primary-study set no OutcomeEvidence;

mas não uma junction normalizada OutcomeEvidence → PrimaryStudy.

Logo:

> **a strategy `include_all_deduplicate_outcomes` será registrada no enum, mas ficará BLOQUEADA PARA PUBLICAÇÃO FORMAL v0.1.**

Ela poderá ser:

- testada em fixture developmental;
- evoluída em versão futura com estrutura outcome-level membership.

Formal v0.1 permite:

1. `prioritize_review`;
2. `include_all_separate_estimates`.

Isso evita falsa deduplicação.

---

# 16. Guard de overlap resolution

Trigger:

> `overview.assert_overlap_resolution_consistency()`

Verificar:

- cluster ativo;
- verification semantics coerentes com actor;
- `prioritize_review` exige pelo menos um ClusterMembership prioritized;
- não pode haver mais de um prioritized no mesmo cluster ativo, salvo protocolo explicitamente multimodal futuro;
- `include_all_separate_estimates` não pode coexistir com ClusterMembership excluded_overlap sem rationale de exceção;
- strategy deduplicate é marcada como experimental v0.1.

---

# 17. Estrutura 6 — overview.outcome_evidence

## 17.1 DDL lógico

```sql
CREATE TABLE overview.outcome_evidence (
    outcome_evidence_uuid uuid PRIMARY KEY,
    review_item_uuid uuid NOT NULL
        REFERENCES overview.review_item(review_item_uuid),
    result_version_uuid uuid
        REFERENCES evidence.result_version(version_uuid),
    synthesis_version_uuid uuid
        REFERENCES synthesis.synthesis_version(version_uuid),
    certainty_assessment_version_uuid uuid
        REFERENCES appraisal.certainty_assessment_version(version_uuid),
    outcome_entity_uuid uuid
        REFERENCES evidence.outcome(entity_uuid),
    comparison_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    timepoint_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    analysis_role text NOT NULL CHECK (
        analysis_role IN (
            'primary_estimate','supporting_estimate',
            'narrative_only','excluded_overlap','excluded_scope'
        )
    ),
    primary_study_set_status text NOT NULL CHECK (
        primary_study_set_status IN (
            'complete','partial','unknown','not_applicable'
        )
    ),
    extraction_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    ),
    CHECK (
        result_version_uuid IS NOT NULL
        OR synthesis_version_uuid IS NOT NULL
    )
);
```

---

# 18. OutcomeEvidence guard

Trigger:

> `overview.assert_outcome_evidence_consistency()`

Se ResultVersion:

- localizar Result entity;
- Result.study_entity_uuid deve ser a Study entity da ReviewItem.

Se SynthesisVersion:

- exigir provenance ativa ligando a Review StudyVersion ou a ResultVersion da review à SynthesisVersion;
- ou exigir synthesis_origin compatível com adopted_external/updated_external conforme regra OES.

Se certainty:

- outcome deve ser compatível quando ambos definidos;
- certainty deve estar ligada ao Synthesis/Outcome selecionado de forma coerente.

Human verification semantics seguem as regras gerais.

---

# 19. OutcomeEvidence não copia estimate

A tabela NÃO terá colunas próprias para:

- effect estimate;
- CI;
- p-value;
- I²;
- tau²;
- sample size.

Esses dados vêm de:

- ResultVersion;
- SynthesisVersion.

`extraction_payload` é reservado a:

- review-reported number of studies/participants;
- exact source location;
- caveats;
- extraction notes;

sem substituir os objetos científicos.

---

# 20. Estrutura 7 — overview.concordance_assessment

## 20.1 DDL lógico

```sql
CREATE TABLE overview.concordance_assessment (
    concordance_uuid uuid PRIMARY KEY,
    cluster_uuid uuid NOT NULL
        REFERENCES overview.review_cluster(cluster_uuid),
    outcome_entity_uuid uuid
        REFERENCES evidence.outcome(entity_uuid),
    comparison_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    timepoint_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    concordance_state text NOT NULL CHECK (
        concordance_state IN (
            'concordant',
            'directionally_discordant',
            'magnitude_discordant',
            'certainty_discordant',
            'not_comparable'
        )
    ),
    dimensions_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    rationale text NOT NULL,
    assessed_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verified_at timestamptz,
    assessed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded')
    )
);
```

---

# 21. Concordance guard

Trigger:

> `overview.assert_concordance_consistency()`

Verificar:

- cluster existe;
- cluster tem pelo menos duas ReviewItems ativas para concordância substantiva;
- actor/verification coerentes;
- `not_comparable` exige rationale;
- assessment não cria certainty global.

---

# 22. Append-preserving semantics

Julgamentos devem ser preservados.

Aplicar guards append-preserving a:

- overlap_resolution;
- concordance_assessment.

ReviewItem/Cluster/OutcomeEvidence:

- update material de scientific state deverá preferir supersession/new InvestigationVersion;
- mutações de campos estruturais após publication deverão ser bloqueadas por guard.

---

# 23. Method policy reutilizada

Não criar tabela `overview.protocol_policy`.

Usar:

> `investigation.method_decision`

Decision codes candidatos:

- `overview_search_coverage_policy`;
- `overview_systematic_review_definition`;
- `overview_overlap_policy`;
- `overview_currentness_policy`;
- `overview_certainty_policy`;
- `overview_reanalysis_policy`.

Para search policy, `impact_payload` deverá conter:

- `minimum_bibliographic_sources`;
- `required_source_names`;
- `required_source_classes`;
- `search_export_required`;
- `grey_literature_required`.

---

# 24. Derivação de overlap — função global/cluster

Criar:

> `overview.overlap_metrics(p_investigation_version_uuid, p_cluster_uuid default null)`

Retorno:

- cluster_uuid;
- review_count;
- study_occurrence_count;
- unique_primary_study_count;
- redundant_occurrence_count;
- membership_completeness;
- cca;
- cca_calculable.

---

# 25. Membership completeness derivada

Para um cluster:

- `complete` se todas as ReviewItems analíticas ativas forem complete;
- `partial` se pelo menos uma partial e nenhuma unknown;
- `unknown` se qualquer unknown.

CCA:

> NULL quando completeness != complete.

---

# 26. CCA

```
CCA = (N - r) / (r*c - r)
```

onde:

- N = total de membership occurrences;
- r = unique primary Studies;
- c = ReviewItems no cluster.

Retornar NULL se:

- c < 2;
- r = 0;
- denominator <= 0;
- membership incompleta.

Nunca persistir o valor.

---

# 27. Pairwise overlap

Criar:

> `overview.pairwise_overlap(cluster_uuid)`

Retorno por par:

- review_item_a;
- review_item_b;
- studies_a;
- studies_b;
- shared_studies;
- union_studies;
- jaccard;
- proportion_a_shared;
- proportion_b_shared;
- calculable;
- completeness.

NULL para métricas quando membership não for complete.

---

# 28. Publication gate — funções

Criar:

> `product.overview_of_reviews_publication_issues(product_version_uuid)`

e:

> `product.overview_of_reviews_is_publishable(product_version_uuid)`

---

# 29. Gate — identidade do Product

Errors:

- `MISSING_PRODUCT_VERSION`;
- `WRONG_PRODUCT_TYPE`;
- `MISSING_PRIMARY_INVESTIGATION`;
- `MULTIPLE_PRIMARY_INVESTIGATIONS`;
- `PRIMARY_INVESTIGATION_NOT_N4`;
- `CUTOFF_DATE_MISMATCH`;
- `PRIMARY_INVESTIGATION_NOT_CURRENT`.

Expected:

> `product_type=overview_of_reviews`

---

# 30. Gate — protocolo

Errors:

- `MISSING_PROTOCOL`;
- `PROTOCOL_NOT_TRACEABLE`;
- `PROTOCOL_NOT_PROSPECTIVE` quando first Search precede protocolo sem declaração adequada.

Formal protocol artifact:

- active;
- hash presente;
- ligado à primary Investigation.

---

# 31. Gate — policy records

Errors quando ausentes:

- `MISSING_REVIEW_DEFINITION_POLICY`;
- `MISSING_SEARCH_COVERAGE_POLICY`;
- `MISSING_OVERLAP_POLICY`;
- `MISSING_CURRENTNESS_POLICY`.

Policies devem estar:

- active;
- planned=true;
- accepted/resolved;
- anteriores ou concomitantes à execução material aplicável.

---

# 32. Gate — busca

Errors:

- `MISSING_SEARCH_RECORD`;
- `INSUFFICIENT_DECLARED_COVERAGE`;
- `MISSING_REQUIRED_SEARCH_SOURCE`;
- `MISSING_REQUIRED_SEARCH_SOURCE_CLASS`;
- `MISSING_SEARCH_EXPORT`;
- `MISSING_SEARCH_PEER_REVIEW`.

A busca deve pertencer à primary Overview Investigation.

Não usar `source_corpus` para satisfazer formal Overview v0.1.

---

# 33. Gate — seleção

Errors:

- `MISSING_SCREENING_CONTROL`;
- `INCOMPLETE_SCREENING`;
- `MISSING_FULLTEXT_EXCLUSION_REASON`;
- `UNRESOLVED_SCREENING_DISAGREEMENT`;
- `MISSING_INCLUDED_REVIEW_SCREENING_DECISION`.

Formal Overview exige inclusão explícita da Review Study entity.

---

# 34. Gate — ReviewItems

Errors:

- `TOO_FEW_INCLUDED_REVIEWS` se <2 ReviewItems analíticas;
- `NON_SYSTEMATIC_REVIEW_ITEM`;
- `DUPLICATE_REVIEW_ENTITY_VERSION`;
- `MULTIPLE_ACTIVE_VERSIONS_SAME_REVIEW`;
- `INVALIDATED_REVIEW_VERSION`;
- `MISSING_LAST_SEARCH_DATE`;
- `MISSING_CURRENTNESS_ASSESSMENT`.

Warnings:

- `OUTDATED_INCLUDED_REVIEW`;
- `POSSIBLY_OUTDATED_INCLUDED_REVIEW`.

---

# 35. Gate — ROBIS

Errors:

- `MISSING_REVIEW_ROBIS`;
- `MISSING_APPRAISAL_CONTROL`;
- `UNVERIFIED_REVIEW_APPRAISAL`.

Cada ReviewItem analítico exige:

- ROBIS ativo;
- Qualified human appraisal control;
- ReviewerAssignments compatíveis.

High ROBIS:

> warning, não exclusão automática.

Warning:

- `HIGH_RISK_REVIEW_INCLUDED`.

---

# 36. Gate — membership

Errors:

- `MISSING_PRIMARY_STUDY_MEMBERSHIP`;
- `INCOMPLETE_MEMBERSHIP`;
- `LOW_CONFIDENCE_STUDY_IDENTITY`;
- `UNVERIFIED_MEMBERSHIP`;
- `MISSING_OVERLAP_CONTROL`.

Formal:

- membership_completeness=complete;
- no low-confidence active membership;
- membership human_verified/human_consensus;
- qualified independent overlap verification.

---

# 37. Gate — clusters

Errors:

- `UNCLUSTERED_ANALYTIC_REVIEW`;
- `CROSS_INVESTIGATION_CLUSTER_MEMBER`;
- `MISSING_OVERLAP_RESOLUTION` para cluster multi-review;
- `MULTIPLE_ACTIVE_OVERLAP_RESOLUTIONS`.

Singleton cluster:

- permitido;
- overlap resolution não obrigatória.

---

# 38. Gate — overlap strategy

Error:

> `OUTCOME_DEDUP_STRATEGY_UNSUPPORTED_V01`

quando strategy:

> `include_all_deduplicate_outcomes`

em Product candidato à formal publication v0.1.

Isso é deliberado.

Para `prioritize_review`:

Errors:

- `MISSING_PRIORITIZED_REVIEW`;
- `MULTIPLE_PRIORITIZED_REVIEWS`;
- `PRIORITIZATION_WITHOUT_CRITERIA`.

Para `include_all_separate_estimates`:

Error se detectar:

- nova Synthesis quantitativa que combine estimates de reviews do cluster sem statistical/reanalysis policy apropriada.

---

# 39. Gate — OutcomeEvidence

Errors:

- `MISSING_OUTCOME_EVIDENCE` para ReviewItem primary/prioritized;
- `OUTCOME_EVIDENCE_REVIEW_MISMATCH`;
- `INCOMPLETE_OUTCOME_EXTRACTION`;
- `UNVERIFIED_OUTCOME_EVIDENCE`;
- `INVALIDATED_OUTCOME_DEPENDENCY`.

Formal:

> OutcomeEvidence material deverá estar human_verified/human_consensus.

---

# 40. Gate — informal indirect comparison

O contrato não consegue inferir toda comparação indireta inválida automaticamente.

Exigir method policy:

> `overview_reanalysis_policy`

Se houver comparação entre estimates de reviews sem comparador/PICO comum, emitir blocker via QualityControl/MethodDecision quando detectado.

Adversarial fixture deverá demonstrar:

> direct review-estimate juxtaposition não cria claim de superioridade.

---

# 41. Gate — concordance

Multi-review analytic cluster requer:

- pelo menos um ConcordanceAssessment aplicável ou
- rationale `not_comparable`.

Errors:

- `MISSING_CONCORDANCE_ASSESSMENT`;
- `UNVERIFIED_CONCORDANCE`.

Formal:

> human verified/consensus.

---

# 42. Gate — certainty

Não exigir GRADE em todas as reviews.

Exigir:

- certainty provenance quando apresentada;
- nenhum global-overview certainty.

Error:

- `GLOBAL_OVERVIEW_CERTAINTY_NOT_ALLOWED` se Product tentar vincular CertaintyAssessment com role que declare rating global do Overview sem método específico autorizado.

Warnings:

- `CERTAINTY_NOT_REPORTED_BY_REVIEW` quando relevante.

---

# 43. Gate — supplemental primary studies

Formal v0.1 não permite primary Study como unidade analítica OutcomeEvidence independente.

Error:

> `SUPPLEMENTAL_PRIMARY_STUDY_NOT_SUPPORTED_V01`

quando dependency/analysis structure indicar primary Study result diretamente incorporado à síntese do Overview fora de ReviewItem membership/provenance.

---

# 44. Gate — reanalysis

Se nova Synthesis quantitativa for produzida pelo Overview:

exigir:

- method policy explícita;
- code artifact;
- analysis dataset artifact;
- statistical reviewer assignment;
- passed `synthesis_statistical_review`;
- qualified independent statistical reviewer.

Errors:

- `REANALYSIS_WITHOUT_POLICY`;
- `REANALYSIS_WITHOUT_CODE`;
- `REANALYSIS_WITHOUT_DATASET`;
- `REANALYSIS_WITHOUT_STATISTICAL_REVIEW`.

---

# 45. Gate — assurance

Formal Overview requires:

> **A3**

Errors:

- `MISSING_AI_METHODOLOGICAL_VERIFICATION`;
- `MISSING_OWNER_APPROVAL`;
- `MISSING_EXPERT_INDEPENDENT_REVIEW`;
- `MISSING_EXPERT_REVIEWER_ASSIGNMENT`;
- `ASSURANCE_BELOW_REQUIRED_LEVEL`.

A3 não elimina nenhum stage-control error.

---

# 46. Gate — publication/currency

Errors:

- `PRODUCT_NOT_PUBLISHED`;
- `MISSING_PUBLICATION_DATE`;
- `MISSING_CURRENCY_STATE`;
- `NOT_CURRENT_ENTITY_VERSION`;
- `MISSING_LIMITATIONS`;
- `INVALIDATED_DEPENDENCY`.

---

# 47. Warnings formais

Possíveis warnings:

- outdated/possibly outdated review;
- high ROBIS review included;
- no stakeholder engagement;
- certainty absent;
- heterogeneous review scope;
- AI assistance used;
- overlap high according to protocol-defined threshold;
- no quantitative reanalysis.

Warnings não podem ser ocultados por A3.

---

# 48. OverviewOfReviewsView

Criar:

> `product.overview_of_reviews_view(product_version_uuid)`

Schema:

> `oes.overview_of_reviews_view/0.1`

---

# 49. View — identity/question/investigation

Projetar:

- Product identity/version/status;
- evidence cutoff;
- currency;
- assurance;
- Question;
- primary Investigation;
- protocol.

---

# 50. View — method

Projetar:

- review definition policy;
- search coverage policy;
- overlap policy;
- currentness policy;
- certainty policy;
- reanalysis policy;
- qualified controls.

---

# 51. View — searches/flow

Projetar:

- Searches;
- exports;
- source classes;
- selection counts;
- review-level inclusion flow;
- included ReviewItems.

Não inferir PRIOR compliance.

---

# 52. View — review_items

Para cada item:

- ReviewItem UUID;
- Review Study ID;
- Review StudyVersion;
- canonical Reports;
- item role;
- eligibility basis;
- last search date;
- membership completeness;
- currentness;
- ROBIS summary;
- status.

---

# 53. View — membership

Projetar:

- ReviewItem;
- primary Study ID;
- identity confidence;
- verification;
- source Report/location;
- context.

Primary Studies não viram referências principais do Overview por default.

---

# 54. View — overlap

Projetar derivados:

- cluster metrics;
- pairwise overlap;
- CCA + calculability;
- completeness;
- cluster dispositions;
- overlap resolution.

Renderer não recalcula CCA.

---

# 55. View — outcome evidence

Projetar:

- ReviewItem;
- Result/Synthesis IDs;
- Outcome;
- comparison;
- timepoint;
- role;
- Result scientific data;
- heterogeneity when available;
- reported study/participant counts;
- certainty link;
- verification.

---

# 56. View — appraisal

Projetar Review-level ROBIS:

- overall judgement;
- domains;
- assessor;
- verification;
- date.

Não gerar score numérico.

---

# 57. View — concordance

Projetar:

- cluster;
- outcome;
- comparison;
- timepoint;
- state;
- dimensions;
- rationale;
- verification.

---

# 58. View — audit

Projetar:

- synthetic_fixture;
- assurance level;
- required assurance = A3;
- publishable;
- review count;
- membership complete;
- overlap assessed;
- CCA calculability;
- appraisal complete;
- extraction complete;
- human controls satisfied;
- reanalysis present;
- statistical controls satisfied;
- invalidated dependencies;
- publication issues;
- assurance records.

---

# 59. References

Criar helper candidato:

> `product.overview_reference_reports(product_version_uuid)`

Prioridade:

1. canonical Reports das Review StudyVersions;
2. update/correction Reports relevantes;
3. supporting reports usados em ResultSource/provenance.

Primary-study Reports poderão aparecer em camada auditável de overlap, não na lista principal de review references, salvo necessidade de provenance.

---

# 60. Synthetic fixture v0.1

IDs próprios e explicitamente sintéticos.

Conteúdo:

- 3 systematic Review StudyVersions;
- 5 primary Study entities;
- membership:
  - A = 1,2,3;
  - B = 2,3,4;
  - C = 3,4,5;
- 9 occurrences;
- 5 unique Studies;
- CCA calculável;
- one multi-review cluster;
- strategy `prioritize_review` na fixture formal principal;
- Review B prioritized por protocolo pre-specified;
- Review C high ROBIS;
- last search dates distintas;
- Review A com Report update relation;
- Results por outcome;
- certainty em pelo menos duas reviews;
- one concordance assessment;
- synthetic qualified human controls;
- synthetic A3.

---

# 61. Fixture — CCA esperado

Com:

- c=3;
- r=5;
- N=9;

CCA:

> `(9-5)/(5*3-5)=4/10=0.4`

A fixture poderá validar:

> CCA = 0.4

sem converter esse valor em categoria sem threshold protocolar.

---

# 62. Testes mínimos — positivos

- OV-T01 formal fixture publishable A3;
- OV-T02 3 ReviewItems/5 unique primary Studies;
- OV-T03 membership occurrence count = 9;
- OV-T04 CCA = 0.4;
- OV-T05 pairwise intersections corretas;
- OV-T06 Review update não duplica ReviewItem;
- OV-T07 ROBIS por ReviewItem;
- OV-T08 prioritized review coerente;
- OV-T09 OutcomeEvidence pertence à review correta;
- OV-T10 certainty link preservado;
- OV-T11 concordance projetada;
- OV-T12 reference list privilegia review Reports;
- OV-T13 OverviewOfReviewsView smoke test.

---

# 63. Testes mínimos — adversariais

- OV-T14 duplicated Report não cria segunda review;
- OV-T15 old+updated StudyVersion ativa simultaneamente rejeitada;
- OV-T16 shared primary Study conta uma vez em unique count;
- OV-T17 incomplete membership → CCA null/not calculable;
- OV-T18 low-confidence membership fecha formal gate;
- OV-T19 AI não pode human-verify membership;
- OV-T20 missing ROBIS fecha gate;
- OV-T21 Result de review errada rejeitado;
- OV-T22 missing overlap resolution fecha gate;
- OV-T23 deduplicate-outcomes strategy bloqueada formal v0.1;
- OV-T24 A3 não bypassa missing overlap control;
- OV-T25 missing human extraction verification fecha gate;
- OV-T26 global Overview certainty rejeitada;
- OV-T27 supplemental primary Result rejeitado;
- OV-T28 outdated review permanece disclosure;
- OV-T29 reanalysis sem statistical review/code/dataset fecha gate;
- OV-T30 invalidated dependency fecha gate;
- OV-T31 migration idempotence/duplicate policy conforme desenho;
- OV-T32 rebuild preserves contract;
- OV-T33 N0–N4 + Evidence Map regressions stay green.

---

# 64. Template embargo

Regra:

> **não criar template do Overview antes do PASS técnico do contrato, fixture, gate e View.**

Sequência obrigatória:

1. migration 019;
2. synthetic fixture;
3. OV-T01–T33;
4. OverviewOfReviewsView;
5. rebuild/regressions;
6. Documento de resultado técnico = PASS;
7. somente então contrato de renderização/template.

---

# 65. Critério de PASS técnico

PASS requer:

- sete estruturas criadas;
- guards funcionando;
- metrics derivadas;
- formal A3 fixture publishable;
- adversarial blockers ativos;
- View completa;
- no duplicated scientific truth;
- rebuild;
- regressões;
- CI success.

---

# 66. Decisão

> **Contrato de Dados v0.1 do Overview de Revisões definido.**

Refinamento de escopo:

> `include_all_deduplicate_outcomes` fica **não publicável no formal v0.1** até existir representação relacional outcome-level de primary-study membership.

Isso preserva a integridade metodológica sem ampliar prematuramente o schema.

---

# 67. Próxima etapa

> **Implementar `database/019_overview_of_reviews_contract.sql`, fixture formal sintética e testes, sem criar template antes de PASS técnico.**

---

**Resultado:** contrato lógico v0.1 fechado e pronto para implementação controlada.
