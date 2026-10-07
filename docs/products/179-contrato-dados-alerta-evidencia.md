# 179 — Alerta de Evidência: Contrato de Dados v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **DATA_CONTRACT_READY**  
**Dependências:** Documentos 177–178; OES-P1; migrations 002–023  
**Migration prevista:** database/024_evidence_alert_contract.sql

---

## 1. Finalidade

Transformar a especificação científica e arquitetural do Alerta em contrato físico implementável, sem criar Investigation nova, duplicar EvidenceEvent/CandidateAssessment, transformar Alert em atualização científica, criar currentness paralelo, criar thresholds/SLA ou iniciar Fase 4.

O contrato deve permitir reconstruir:

> **source context → signal source(s) → AlertVersion → target version → classification/dimensions/urgency → verification/assurance → lifecycle → eventual incorporation.**

## 2. Product identity

Alert formal usa product.product_version.product_type='evidence_alert'.

O ProductVersion:

- usa identidade/versionamento genéricos;
- possui evidence_cutoff_date;
- pode possuir publication_date;
- usa editorial status genérico;
- deve manter conclusion_text IS NULL.

## 3. Investigation link

Exatamente um product.investigation_link com role='source_context' por AlertVersion.

Não exigir primary Investigation. A Investigation de contexto deve estar current no momento de publicação formal.

## 4. Estruturas especializadas

Criar:

1. maintenance.evidence_alert;
2. maintenance.alert_source;
3. maintenance.alert_affected_dimension.

Reutilizar Product/ProductVersion, InvestigationLink, EvidenceEvent, CandidateAssessment, Artifact, core EntityVersion, CurrencyState, AssuranceRecord, provenance.record e dependency_edge.

## 5. maintenance.evidence_alert

Campos mínimos:

- alert_product_version_uuid PK/FK para product.product_version;
- target_product_version_uuid ou target_investigation_version_uuid, exatamente um;
- headline;
- summary;
- signal_date;
- detected_at;
- classification em informational|relevant|critical;
- reassessment_priority em routine|priority|urgent;
- lifecycle_status em triage|evaluation|incorporated|discarded;
- justification;
- assessed_by e actor_type;
- verification_status, verified_by, verifier_actor_type, verified_at;
- issued_at;
- resolution_rationale;
- incorporated_version_uuid opcional;
- incorporated_currency_state_uuid opcional;
- created_at.

## 6. Alert consistency guard

maintenance.assert_evidence_alert_consistency() deverá verificar:

1. ProductVersion existe e é evidence_alert;
2. conclusion_text é NULL;
3. exatamente um source_context InvestigationLink;
4. source_context não invalidated/archived;
5. target não é o próprio Alert ProductVersion;
6. target existe e não está invalidated/archived na criação;
7. headline/summary/justification não vazios;
8. verification semantics coerentes;
9. signal_date <= evidence_cutoff_date quando signal_date existir;
10. issued_at não anterior a detected_at;
11. incorporated exige incorporation linkage;
12. discarded exige resolution_rationale;
13. non-incorporated não declara incorporation linkage;
14. triage não possui issued_at formal;
15. AI e human verification permanecem distintos.

## 7. Lifecycle/versioning guard

AlertVersion é materialmente imutável. UPDATE/DELETE de conteúdo material é proibido.

Mudança de classification, urgency, lifecycle, dimensions, target, headline/summary, justification ou verification material exige nova core EntityVersion/ProductVersion do mesmo Alert Product, usando supersedes_version_uuid.

## 8. maintenance.alert_source

Cada source row contém:

- alert_source_uuid;
- alert_product_version_uuid;
- source_role primary|supporting;
- source_type candidate_assessment|evidence_event|entity_version|artifact|uri;
- exatamente um FK/URI correspondente;
- source_date;
- description;
- sequence_no.

Regra estrutural: num_nonnulls dos cinco source locators = 1.

## 9. AlertSource guards

Deverá garantir:

- source_type corresponde ao locator preenchido;
- URI não vazia;
- Artifact ativo quando usado;
- EntityVersion não invalidated para source ativa de publicação;
- CandidateAssessment não superseded;
- EvidenceEvent não invalidated;
- source_date não posterior ao Alert Product cutoff;
- sequence positiva quando presente.

Índice parcial: uma única source_role='primary' por AlertVersion.

Publication gate exige exatamente uma primary source.

## 10. Source de Monitor

Quando source_type for candidate_assessment ou evidence_event, a View deve derivar source → cycle → Monitor ProductVersion → Monitor Investigation.

O contrato não duplica cycle UUID ou Monitor UUID na AlertSource.

## 11. Direct source

Quando o Alert não vier de Monitor, permitir EntityVersion, Artifact ou URI.

source_context Investigation continua obrigatória. Ausência de Monitor gera warning ALERT_SOURCE_OUTSIDE_MONITOR, não erro estrutural.

## 12. maintenance.alert_affected_dimension

Chave: alert_product_version_uuid + dimension_code.

dimension_code em:

- benefit;
- harm;
- magnitude;
- precision;
- certainty;
- applicability;
- conclusion;
- regulatory_status;
- validity;
- scope;
- other.

Campos adicionais: rationale e sequence_no.

Publication gate exige ao menos uma dimensão. Não existe dimensão primary obrigatória.

## 13. Target dependency

Todo AlertVersion exige provenance.dependency_edge ativa:

- source = target version;
- target = Alert ProductVersion;
- dependency_type='maintenance_alert_target'.

## 14. Source dependency

Quando AlertSource referenciar source_entity_version_uuid, exigir edge maintenance_alert_source para o AlertVersion.

Para CandidateAssessment/EvidenceEvent/Artifact/URI, AlertSource especializada é a ligação canônica; não criar dependency_edge artificial para UUID não versionado.

## 15. Incorporation dependency

Quando incorporated_version_uuid existir, exigir edge:

- source = Alert ProductVersion;
- target = incorporated version;
- dependency_type='maintenance_alert_incorporation'.

Para CurrencyState, usar FK especializada e provenance/process record quando aplicável.

## 16. Human verification

Semântica:

- unverified: sem verifier metadata;
- ai_verified: verifier_actor_type=ai_system e metadata obrigatória;
- human_verified/human_consensus: verifier_actor_type humano e metadata obrigatória.

Publication gate exige human_verified ou human_consensus.

## 17. Assurance

Reutilizar product.assurance_level(alert_product_version_uuid).

Publication formal exige nível >= A2. A3 ausente é warning, não blocker v0.1.

Critical sem A3 gera warning CRITICAL_WITHOUT_EXPERT_REVIEW.

## 18. Publication issues

Criar product.evidence_alert_publication_issues(uuid), retornando issue_code, severity e message.

Errors mínimos:

- MISSING_PRODUCT_VERSION;
- WRONG_PRODUCT_TYPE;
- MISSING_ALERT_RECORD;
- ALERT_CONCLUSION_NOT_NULL;
- MISSING_SOURCE_CONTEXT;
- MULTIPLE_SOURCE_CONTEXTS;
- SOURCE_CONTEXT_INVALID;
- MISSING_TARGET;
- INVALID_TARGET;
- MISSING_PRIMARY_SOURCE;
- MULTIPLE_PRIMARY_SOURCES;
- INVALID_PRIMARY_SOURCE;
- MISSING_AFFECTED_DIMENSION;
- MISSING_HEADLINE;
- MISSING_SUMMARY;
- MISSING_JUSTIFICATION;
- ALERT_STILL_IN_TRIAGE;
- MISSING_HUMAN_VERIFICATION;
- ASSURANCE_BELOW_A2;
- MISSING_PUBLICATION_DATE;
- NOT_CURRENT_ENTITY_VERSION;
- MISSING_TARGET_DEPENDENCY;
- INVALIDATED_DEPENDENCY;
- INCORPORATED_WITHOUT_LINEAGE;
- DISCARDED_WITHOUT_RATIONALE.

Warnings mínimos:

- NO_EXPERT_REVIEW_OF_ALERT;
- CRITICAL_WITHOUT_EXPERT_REVIEW;
- ALERT_SOURCE_OUTSIDE_MONITOR;
- TARGET_CURRENCY_UNDER_EVALUATION;
- TARGET_CURRENCY_UPDATE_RECOMMENDED;
- TARGET_CURRENCY_OUTDATED;
- TARGET_ASSURANCE_BELOW_A2.

## 19. Publishability

product.evidence_alert_is_publishable(uuid) retorna true somente quando evidence_alert_publication_issues não contém severity='error'.

Warnings não bloqueiam.

## 20. Editorial state

Publication gate formal exige ProductVersion status='published' e publication_date não nula.

Draft/under_review não são publishable.

## 21. EntityVersion state

Alert ProductVersion publicado exige core EntityVersion.version_status='current'. Versões superseded/archived/invalidated continuam auditáveis, mas não são a versão publicável corrente.

## 22. Target Product currentness

Quando target for ProductVersion, projetar Current CurrencyState.

- under_evaluation → warning;
- update_recommended → warning;
- outdated → warning.

Quando target for InvestigationVersion, target currency é not applicable.

## 23. Target assurance

Quando target for ProductVersion, projetar product.assurance_level(target). Não herdar.

Abaixo de A2: warning informativo, não blocker universal do Alert.

## 24. Issued_at

issued_at representa emissão comunicacional. Para Alert published, issued_at é obrigatório.

Pode coincidir com publication_date, mas não é substituído por ela.

## 25. Classification e urgency

Constraints de domínio apenas. Nenhuma função deriva classification ou urgency, promove critical, calcula SLA, agenda notificação ou executa auto-update.

## 26. Projection Readiness

Antes da EvidenceAlertView, executar gate explícito verificando se o contrato projeta sem interpretação externa:

- identity/version;
- source_context;
- target;
- target currentness;
- target assurance;
- sources;
- Monitor/cycle derivation;
- dimensions;
- classification;
- urgency;
- lifecycle;
- verification;
- assurance;
- publication issues;
- lineage/incorporation;
- source invalidation.

Se houver lacuna, migration 025 será hardening. Se não houver, migration 025 pode implementar EvidenceAlertView.

## 27. Fixtures mínimas

### Alert A — formal published

- target ProductVersion;
- source Monitor CandidateAssessment;
- EvidenceEvent supporting;
- relevant / priority;
- dimensions conclusion + certainty;
- lifecycle evaluation;
- human_verified;
- A2;
- published;
- zero errors.

### Alert B — AI-only blocked

- target ProductVersion;
- source Monitor;
- informational;
- ai_verified;
- A1;
- under_review;
- blocked.

### Alert C — direct critical

- target InvestigationVersion;
- direct Artifact/URI source;
- critical / urgent;
- human_verified;
- A2;
- published;
- warning source outside Monitor;
- warning no expert review;
- nenhuma regra automática da Fase 4.

### Alert D — incorporated

- nova versão do Alert A;
- lifecycle incorporated;
- incorporation link concreto;
- lineage preservada.

### Alert E — discarded

- lifecycle discarded;
- rationale obrigatório.

## 28. Testes mínimos migration 024

AL-T01–T30:

1. product_type/record consistency;
2. no Alert conclusion;
3. source_context exactly one;
4. target xor;
5. source type consistency;
6. one primary source;
7. supporting sources;
8. source invalidation guard;
9. dimensions 1:N;
10. duplicate dimension rejected;
11. classification domain;
12. urgency domain;
13. verification semantics;
14. AI != human;
15. incorporated lineage;
16. discarded rationale;
17. lifecycle immutability/versioning;
18. target dependency;
19. source dependency;
20. human verification publication blocker;
21. A2 blocker;
22. publication date blocker;
23. current EntityVersion blocker;
24. target invalidation blocker;
25. warning target currentness;
26. critical-no-expert warning;
27. direct-source warning;
28. formal Alert A publishable;
29. AI-only Alert B blocked;
30. migration idempotency + rebuild/regressions.

## 29. Migration discipline

Migration 024 contém contrato físico, guards e publication gate. Não inclui template.

Preferência: não incluir View antes do Projection Readiness explícito.

## 30. Próxima etapa

> **Implementar migration 024 + fixtures + AL-T01–T30 + regressões/rebuild.**

---

**Resultado:** Contrato de Dados v0.1 do Alerta de Evidência pronto para implementação sem antecipar Fase 4.
