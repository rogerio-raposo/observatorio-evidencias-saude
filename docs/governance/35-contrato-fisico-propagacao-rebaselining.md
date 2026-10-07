# 35 — Contrato Físico v0.1 de Propagation/Re-baselining

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISED_AFTER_PHYSICAL_GATE — READY_FOR_DOCUMENT_36_RECHECK — MIGRATION_NOT_AUTHORIZED**  
**Dependências:** Documentos 33–34; Documentos 05–09, 16–32; docs/architecture/28–29; migrations 004, 021–030  
**Objeto:** contrato físico candidato para propagation assessment, dependency-path snapshot, re-baselining same-entity e handover explícito de maintenance objects

---

## 1. Finalidade

Especificar um contrato físico implementável que preserve as decisões dos Documentos 33–34 sem:

- retargeting in-place;
- cross-target misuse de supersession existente;
- write propagation;
- mudança automática de currentness;
- promoção de assurance;
- fabricação de revisão humana;
- auto-M3;
- scheduler/notifications;
- numeric SLA/cadence.

Este documento não autoriza migration.

---

# PARTE A — PRINCÍPIOS FÍSICOS

## 2. Princípio central

> **Descoberta é projetável; julgamento é persistido; handover é explícito; história permanece ancorada ao target que a originou.**

Consequências:

1. dependency traversal pode usar `provenance.dependency_edge`;
2. o resultado authoritative do impacto não é gravado no grafo de dependência;
3. paths usados na decisão são congelados em estrutura própria;
4. rebaseline não altera FK histórica de policy/signal/SLA/workflow;
5. cada novo target recebe seus próprios objetos operacionais prospectivos.

---

## 3. Escopo físico v0.1

Estruturas candidatas:

1. `maintenance.propagation_assessment`;
2. `maintenance.propagation_candidate`;
3. `maintenance.propagation_path`;
4. `maintenance.propagation_path_step`;
5. extensão estruturada de `maintenance.update_signal_source`;
6. `maintenance.rebaseline_decision`;
7. `maintenance.rebaseline_policy_link`;
8. `maintenance.rebaseline_monitor_link`;
9. `maintenance.rebaseline_risk_profile_link`;
10. `maintenance.rebaseline_coverage_item`;
11. `maintenance.rebaseline_sla_rule_link`;
12. `maintenance.rebaseline_sla_instance_disposition`;
13. `maintenance.rebaseline_open_signal_disposition`;
14. `maintenance.rebaseline_workflow_link`;
15. issue/readiness helpers.

Não criar:

- tabela de scheduler;
- notification channel;
- auto-escalation engine;
- risk score;
- numeric cadence defaults;
- numeric SLA defaults;
- M3-ready boolean simples.

---

# PARTE B — PROPAGATION ASSESSMENT

## 4. maintenance.propagation_assessment

Representa uma avaliação de propagação iniciada por evento sobre uma versão upstream.

Campos candidatos:

- `propagation_assessment_uuid uuid PK`;
- `origin_version_uuid uuid NOT NULL FK core.entity_version(version_uuid)`;
- `replacement_version_uuid uuid NULL FK core.entity_version(version_uuid)`;
- `origin_event_class text NOT NULL`;
- `triggered_at timestamptz NOT NULL`;
- `dependency_snapshot_at timestamptz NOT NULL`;
- `max_depth integer NOT NULL CHECK (max_depth > 0)`;
- `lineage_validation_status text NOT NULL`;
- `lineage_validation_payload jsonb NOT NULL DEFAULT '{}'`;
- `assessment_scope text NOT NULL`;
- `rationale text NOT NULL`;
- `initiated_by text NOT NULL`;
- `actor_type text NOT NULL`;
- `verification_status text NOT NULL`;
- `verified_by text NULL`;
- `verifier_actor_type text NULL`;
- `verified_at timestamptz NULL`;
- `authority_status text NOT NULL`;
- `assessed_at timestamptz NOT NULL`;
- `recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- `record_status text NOT NULL DEFAULT 'active'`;
- `supersedes_propagation_assessment_uuid uuid NULL FK self`.

### 4.1 origin_event_class

Domínio inicial:

- `new_version`;
- `invalidation`;
- `correction`;
- `retraction`;
- `expression_of_concern`;
- `methodological_change`;
- `certainty_change`;
- `applicability_change`;
- `dependency_graph_change`;
- `governance_reassessment`;
- `other`.

`other` exige rationale não vazio, mas rationale é obrigatório em todos os casos.

### 4.2 lineage_validation_status

Domínio:

- `validated_against_canonical_relations`;
- `projection_only_unverified`;
- `projection_divergence_detected`;
- `incomplete_or_unknown`.

### 4.3 assessment_scope

Domínio:

- `direct_only`;
- `transitive`.

### 4.4 authority

`authority_status`:

- `proposal`;
- `authoritative`.

`actor_type`:

- `system`;
- `ai_system`;
- `human_reviewer`;
- `human_expert`;
- `owner`.

Authoritative assessment:

- system/AI proibidos;
- se o escopo inclui julgamento científico de completude/impacto, exigir human_reviewer/human_expert;
- owner pode authoritative apenas quando o assessment for puramente operacional e isso estiver expresso nos candidates.

Verification usa `maintenance.assert_verification_metadata()`.

---

## 5. replacement_version_uuid

Quando preenchido:

1. origin e replacement devem possuir mesma `entity_uuid`;
2. replacement deve diferir da origin;
3. replacement deve ser temporal/versionally posterior;
4. a cadeia `supersedes_version_uuid` entre origin e replacement deve ser auditável;
5. salto de versões é permitido somente com chain snapshot no RebaselineDecision correspondente quando houver rebaseline.

O campo não significa que replacement seja automaticamente target downstream.

---

## 6. Supersession do assessment

Nova avaliação do mesmo evento/escopo pode superseder outra.

`supersedes_propagation_assessment_uuid` exige:

- mesma origin_version_uuid;
- mesma replacement_version_uuid;
- temporalidade monotônica;
- assessment anterior active no momento do novo INSERT.

O registro antigo somente transita `active → superseded`.

Material fields são imutáveis.

---

# PARTE C — PROPAGATION CANDIDATE

## 7. maintenance.propagation_candidate

Uma linha por impacted version dentro de um assessment.

Campos candidatos:

- `propagation_candidate_uuid uuid PK`;
- `propagation_assessment_uuid uuid NOT NULL FK`;
- `impacted_version_uuid uuid NOT NULL FK core.entity_version`;
- `target_class text NOT NULL`;
- `impact_domain text NOT NULL`;
- `assessment_status text NOT NULL`;
- `disposition text NULL`;
- `authority_domain text NOT NULL`;
- `rationale text NULL`;
- `assessed_by text NULL`;
- `actor_type text NULL`;
- verification metadata;
- `authority_status text NOT NULL`;
- `assessed_at timestamptz NULL`;
- `recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- `record_status text NOT NULL DEFAULT 'active'`;
- `supersedes_propagation_candidate_uuid uuid NULL FK self`.

Unique active:

> `(propagation_assessment_uuid, impacted_version_uuid)`.

---

## 8. target_class

Domínio:

- `maintainable_product`;
- `maintainable_investigation`;
- `nonmaintainable_version`.

Validator:

### maintainable_product

impacted_version_uuid deve existir em `product.product_version` e o `product_type` deve ser elegível a UpdatePolicy, excluindo pelo menos `evidence_monitor` e `evidence_alert`.

### maintainable_investigation

deve existir em `investigation.investigation_version` e:

> `investigation_type <> 'evidence_monitoring'`.

### nonmaintainable_version

Inclui explicitamente:

- ProductVersion com `product_type IN ('evidence_monitor','evidence_alert')`;
- InvestigationVersion com `investigation_type='evidence_monitoring'`;
- outros objetos versionados sem UpdatePolicy própria.

Não pode simultaneamente ser classificado como maintainable target.

Essa classificação é física e verificável; não deve depender apenas de texto livre.

---

## 9. impact_domain

Domínio:

- `scientific_content`;
- `methodological`;
- `certainty`;
- `applicability`;
- `safety_integrity`;
- `currentness_review`;
- `maintenance`;
- `operational_only`;
- `mixed`;
- `unknown_pending_review`.

---

## 10. assessment_status

Domínio:

- `pending`;
- `assessed`;
- `unresolved`.

Regras:

- pending → disposition NULL;
- assessed → disposition NOT NULL;
- unresolved → disposition = unresolved.

Candidate authoritative `assessed` exige rationale.

---

## 11. disposition

Domínio:

- `no_action_supported`;
- `reassessment_required`;
- `maintenance_policy_required`;
- `open_update_signal`;
- `method_review_required`;
- `new_version_workflow_required`;
- `rebaseline_required`;
- `dependency_correction_required`;
- `governance_review_required`;
- `unresolved`.

### 11.1 no_action_supported

Authoritative só é permitido quando:

- lineage_validation_status do parent = `validated_against_canonical_relations`;
- rationale existe;
- authority_domain é compatível;
- scientific/methodological/mixed exige qualified human.

### 11.2 open_update_signal

Somente:

- maintainable_product;
- maintainable_investigation;

e somente quando existir UpdatePolicy ativa para aquele exact version target.

O candidate não cria signal automaticamente.

### 11.3 maintenance_policy_required

Somente maintainable target sem policy ativa aplicável.

### 11.4 nonmaintainable_version

Não pode usar:

- open_update_signal;
- maintenance_policy_required;
- rebaseline_required.

---

## 12. authority_domain

Domínio:

- `operational`;
- `scientific`;
- `methodological`;
- `mixed`.

Authoritative scientific/methodological/mixed:

- actor_type ∈ human_reviewer | human_expert;
- verification_status ∈ human_verified | human_consensus.

Authoritative operational:

- owner permitido;
- system/AI proibidos.

Proposal pode ser system/AI.

---

# PARTE D — PATH SNAPSHOT

## 13. maintenance.propagation_path

Representa um caminho independente entre origin e impacted version.

Campos:

- `propagation_path_uuid uuid PK`;
- `propagation_candidate_uuid uuid NOT NULL FK`;
- `path_no integer NOT NULL CHECK >0`;
- `depth integer NOT NULL CHECK >0`;
- `path_status text NOT NULL`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- UNIQUE(`propagation_candidate_uuid,path_no`).

`path_status`:

- `complete`;
- `cycle_detected`;
- `depth_limit_reached`;
- `projection_divergence`;
- `incomplete_unknown`.

Uma candidate pode possuir múltiplos paths.

---

## 14. maintenance.propagation_path_step

Campos:

- `propagation_path_uuid uuid NOT NULL FK`;
- `step_no integer NOT NULL CHECK >0`;
- `source_version_uuid uuid NOT NULL FK core.entity_version`;
- `target_version_uuid uuid NOT NULL FK core.entity_version`;
- `dependency_type text NOT NULL`;
- `derivation_rule text NOT NULL`;
- `edge_created_at timestamptz NOT NULL`;
- `edge_status_at_snapshot text NOT NULL`;
- PRIMARY KEY(`propagation_path_uuid,step_no`).

Não apontar por FK para a linha atual de `dependency_edge`, porque o objetivo é congelar o estado usado no julgamento.

### 14.1 Guards

Deferred validator deve assegurar:

1. steps contíguos 1..depth;
2. step 1 source = parent assessment origin_version_uuid;
3. último step target = candidate impacted_version_uuid;
4. step N target = step N+1 source;
5. nenhum version_uuid se repete em path complete;
6. depth = count(steps);
7. `complete` exige exatamente depth steps;
8. cycle/depth-limit status não pode ser mascarado como complete.

---

# PARTE E — PROPAGATION → UPDATE SIGNAL

## 15. Extensão de maintenance.update_signal_source

Adicionar candidato futuro:

- `source_type='propagation_candidate'`;
- `propagation_candidate_uuid uuid FK maintenance.propagation_candidate`.

Atualizar locator XOR.

### 15.1 Regras

PropagationCandidate usado como source deve:

- estar active;
- estar assessed;
- possuir disposition `open_update_signal`;
- ser authoritative;
- apontar para exact target da UpdatePolicy do novo UpdateSignal;
- ser maintainable target.

O source propagation_candidate pode ser primary.

O signal_type permanece causal:

- não criar `signal_type='propagation'`.

### 15.2 Invalidated upstream

Como UpdateSignalSource aponta para candidate, a invalidação/archival da origin version não impede o linkage.

A origin permanece rastreável pelo assessment/path snapshot.

---

# PARTE F — REBASELINE DECISION

## 16. maintenance.rebaseline_decision

Representa planned/activated/cancelled handover entre versões da mesma entidade científica.

Campos candidatos:

- `rebaseline_decision_uuid uuid PK`;
- old target XOR:
  - `old_target_product_version_uuid uuid FK`;
  - `old_target_investigation_version_uuid uuid FK`;
- new target XOR:
  - `new_target_product_version_uuid uuid FK`;
  - `new_target_investigation_version_uuid uuid FK`;
- `decision_stage text NOT NULL`;
- `transition_basis_type text NOT NULL`;
- structured locator columns;
- `version_chain_summary_payload jsonb NOT NULL DEFAULT '{}'::jsonb`;
- `authority_domain text NOT NULL`;
- `rationale text NOT NULL`;
- `decided_by text NOT NULL`;
- `actor_type text NOT NULL`;
- verification metadata;
- `authority_status text NOT NULL`;
- `decided_at timestamptz NOT NULL`;
- `activated_at timestamptz NULL`;
- `recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`;
- `record_status text NOT NULL DEFAULT 'active'`;
- `supersedes_rebaseline_decision_uuid uuid NULL FK self`.

XOR old/new:

- exatamente um old target;
- exatamente um new target;
- ambos do mesmo target family.

---

## 17. Same-entity guard

Para product:

`old_product.entity_uuid = new_product.entity_uuid`.

Para investigation:

`old_investigation.entity_uuid = new_investigation.entity_uuid`.

Além disso:

- old != new;
- new version_no > old version_no;
- new.valid_from >= old.valid_from;
- version chain precisa ser demonstrável.

Cross-entity rebaseline é rejeitado.

---

## 18. decision_stage

Domínio:

- `planned`;
- `activated`;
- `cancelled_invalidated`.

### planned

- new target pode ser draft/current;
- child dispositions podem estar pending;
- não significa handover efetivo.

### activated

Exige:

- new target `current`;
- authority_status authoritative;
- `activated_at NOT NULL`;
- required child records completos;
- readiness helper sem errors.

### cancelled_invalidated

Exige rationale explícito.

Se new target muda:

- não editar decision;
- supersede/append.

---

## 19. transition_basis_type

Domínio:

- `update_decision`;
- `workflow_round`;
- `result_product_version`;
- `result_investigation_version`;
- `governance_decision`;
- `propagation_candidate`;
- `other`.

Locators candidatos:

- `update_decision_uuid`;
- `workflow_round_uuid`;
- `result_product_version_uuid`;
- `result_investigation_version_uuid`;
- `propagation_candidate_uuid`;
- `basis_artifact_uuid`;
- `external_basis_payload`.

Locator XOR coerente com transition_basis_type.

Para `governance_decision`/other, exigir artifact ou payload/rationale estruturado.

---

## 20. version chain normalizada

`version_chain_summary_payload` pode existir apenas como serializer/snapshot derivado.

A fonte física primária da cadeia será `maintenance.rebaseline_version_chain_step`, definida no hardening pós-Documento 36.

Validator físico deve recomputar a cadeia com `core.entity_version.supersedes_version_uuid` e exigir igualdade exata para activation.

---

# PARTE G — POLICY HANDOVER

## 21. maintenance.rebaseline_policy_link

Uma linha por RebaselineDecision.

Campos:

- `rebaseline_decision_uuid uuid PK/FK`;
- `old_update_policy_uuid uuid NULL FK maintenance.update_policy`;
- `new_update_policy_uuid uuid NULL FK maintenance.update_policy`;
- `policy_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- `linked_at timestamptz NOT NULL`.

`policy_disposition`:

- `replace_with_new_policy`;
- `stop_maintenance`;
- `maintenance_policy_required`;
- `not_applicable`;
- `pending`.

### 21.1 Guards

If old policy exists:

- exact target = old target do decision.

If new policy exists:

- exact target = new target.

`replace_with_new_policy`:

- old_policy NOT NULL;
- new_policy NOT NULL.

`maintenance_policy_required`:

- new_policy NULL.

`stop_maintenance`:

- new_policy NULL.

Nunca usar `supersedes_update_policy_uuid` para old→new cross-target link.

---

# PARTE H — MONITOR HANDOVER

## 22. maintenance.rebaseline_monitor_link

Uma linha por decision.

Campos:

- `rebaseline_decision_uuid uuid PK/FK`;
- `old_monitor_product_version_uuid uuid NULL FK product.product_version`;
- `new_monitor_product_version_uuid uuid NULL FK product.product_version`;
- `monitor_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- `linked_at timestamptz NOT NULL`.

Domínio:

- `continue_same_monitor_lineage`;
- `replace_with_new_monitor_entity`;
- `stop_monitoring`;
- `not_applicable`;
- `pending`.

### 22.1 Guards

Old/new locators, quando presentes:

- product_type = evidence_monitor;
- possuem MonitorDefinition + MonitorTarget.

Old Monitor target = old target.

New Monitor target = new target.

Para activation M2/M3 da new policy:

- new Monitor deve existir;
- core.entity_version.version_status = current;
- monitor_state active;
- UpdatePolicy.governing_monitor_product_version_uuid = new Monitor.

### 22.2 Same monitor lineage

`continue_same_monitor_lineage` exige:

- old/new Monitor entity_uuid iguais;
- new version_no > old version_no.

### 22.3 Replacement

`replace_with_new_monitor_entity` exige:

- old/new Monitor presentes;
- entity_uuid diferentes.

Nenhum ciclo é movido.

---

# PARTE I — RISK PROFILE HANDOVER

## 23. maintenance.rebaseline_risk_profile_link

Uma linha por decision.

Campos:

- `rebaseline_decision_uuid uuid PK/FK`;
- `source_update_risk_profile_uuid uuid NULL FK`;
- `target_update_risk_profile_uuid uuid NULL FK`;
- `profile_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- `linked_at timestamptz NOT NULL`.

Domínio:

- `target_profile_available`;
- `carry_forward_authorized`;
- `new_assessment_required`;
- `target_reassessment_required`;
- `not_applicable`;
- `pending`.

### 23.1 Guards

Source profile:

- target = old target.

Target profile:

- target = new target.

`carry_forward_authorized` exige:

- source profile authoritative;
- target profile `assessment_kind='carry_forward'`;
- target.carried_forward_from_profile_uuid = source;
- migration 030 guards satisfeitos.

`target_reassessment_required` refere-se apenas a reassessment de profile já pertencente ao new target; reassessment preserva exact target e não substitui carry-forward cross-version.

Activation não exige profile universalmente. `pending` bloqueia activation; ausência de target profile é readiness gap/warning salvo quando uma operação já exige profile. Qualquer nova PriorityAssessment continua sujeita ao guard obrigatório da migration 030.

---

# PARTE J — COVERAGE HANDOVER

## 24. maintenance.rebaseline_coverage_item

1:N por decision.

Campos:

- `rebaseline_decision_uuid uuid NOT NULL FK`;
- `coverage_code text NOT NULL`;
- `source_monitor_product_version_uuid uuid NULL FK`;
- `source_cycle_uuid uuid NULL FK`;
- `window_start_date date NULL`;
- `window_end_date date NULL`;
- `payload jsonb NOT NULL DEFAULT '{}'`;
- `rationale text NOT NULL`;
- `sequence_no integer NOT NULL`;
- PRIMARY KEY(`rebaseline_decision_uuid,coverage_code,sequence_no`).

coverage_code:

- `incorporated_through_new_target_cutoff`;
- `post_cutoff_pending_assessment`;
- `known_gap_carried_forward`;
- `source_recheck_required`;
- `no_carry_forward_supported`.

### 24.1 Cutoff guard

For `incorporated_through_new_target_cutoff`:

- quando houver janela, `window_end_date = new target evidence_cutoff_date`.

For `post_cutoff_pending_assessment`:

- window_start_date > new target evidence_cutoff_date, when date-bounded.

Não derivar baseline de old Monitor completed_at.

---

# PARTE K — SLA HANDOVER

## 25. maintenance.rebaseline_sla_rule_link

0:N por decision.

Campos:

- `rebaseline_decision_uuid uuid NOT NULL FK`;
- `old_sla_rule_uuid uuid NULL FK`;
- `new_sla_rule_uuid uuid NULL FK`;
- `rule_code text NOT NULL`;
- `rule_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- PRIMARY KEY(`rebaseline_decision_uuid,rule_code`).

Domínio:

- `adopt_new_rule`;
- `not_configured`;
- `retire_without_successor`;
- `not_applicable`;
- `pending`.

### 25.1 Guards

Old rule, quando presente:

- update_policy_uuid = old policy.

New rule, quando presente:

- update_policy_uuid = new policy.

`adopt_new_rule` exige new rule.

Old/new rule may share `rule_code`, but:

> new rule must not use `supersedes_sla_rule_uuid` to point to old-policy rule.

Calendar reuse is allowed only by explicit new rule FK.

No duration/deadline copying rule is introduced.

---

## 26. maintenance.rebaseline_sla_instance_disposition

0:N por old open/terminal-relevant instance.

Campos:

- `rebaseline_decision_uuid uuid NOT NULL FK`;
- `old_sla_instance_uuid uuid NOT NULL FK`;
- `new_sla_instance_uuid uuid NULL FK`;
- `instance_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- `decided_at timestamptz NOT NULL`;
- PRIMARY KEY(`rebaseline_decision_uuid,old_sla_instance_uuid`).

Domínio:

- `finish_on_old_obligation`;
- `terminate_or_cancel_with_rationale`;
- `supersede_operational_obligation_with_linkage`;
- `open_new_obligation_independently`;
- `governance_review_required`.

### 26.1 Guards

Old SLA Instance must belong to old policy/old signal scope.

New instance, when present:

- must belong to new policy/new signal scope;
- cannot share same UUID;
- cannot mutate old snapshot.

No guard may permit erasing:

- original start;
- original due;
- first breach;
- pause history.

---

# PARTE L — OPEN SIGNAL / WORKFLOW HANDOVER

## 27. maintenance.rebaseline_open_signal_disposition

1:N for old active signals relevant to handover.

Fields:

- `rebaseline_decision_uuid uuid NOT NULL FK`;
- `old_update_signal_uuid uuid NOT NULL FK`;
- `new_update_signal_uuid uuid NULL FK`;
- `signal_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- PRIMARY KEY(`rebaseline_decision_uuid,old_update_signal_uuid`).

Domain:

- `resolve_on_old_target`;
- `retain_historical_no_transfer`;
- `continue_old_target_workflow`;
- `create_new_signal_on_new_target`;
- `governance_review_required`.

Rules:

- old signal policy = old policy;
- new signal policy = new policy;
- old signal FK never changes;
- create_new_signal_on_new_target requires new signal UUID;
- new signal cannot equal old signal.

---

## 28. maintenance.rebaseline_workflow_link

0:N by relevant old workflow round.

Fields:

- `rebaseline_decision_uuid uuid NOT NULL FK`;
- `old_workflow_round_uuid uuid NOT NULL FK`;
- `new_workflow_round_uuid uuid NULL FK`;
- `workflow_disposition text NOT NULL`;
- `rationale text NOT NULL`;
- PRIMARY KEY(`rebaseline_decision_uuid,old_workflow_round_uuid`).

Domain:

- `complete_old_round`;
- `terminate_old_round`;
- `old_round_produced_new_target`;
- `open_new_round_independently`;
- `not_applicable`.

If `old_round_produced_new_target`:

- old round result ProductVersion/InvestigationVersion must equal RebaselineDecision new target.

No milestone is copied.

---

# PARTE M — ACTIVATION READINESS

## 29. maintenance.rebaseline_decision_issues(uuid)

Read-only helper.

Minimum issues:

- `REBASELINE_OLD_NEW_TYPE_MISMATCH`;
- `REBASELINE_CROSS_ENTITY`;
- `REBASELINE_NEW_TARGET_NOT_CURRENT`;
- `REBASELINE_VERSION_CHAIN_MISMATCH`;
- `REBASELINE_MISSING_POLICY_LINK`;
- `REBASELINE_POLICY_TARGET_MISMATCH`;
- `REBASELINE_M2_M3_MONITOR_MISSING`;
- `REBASELINE_MONITOR_NOT_CURRENT`;
- `REBASELINE_MONITOR_TARGET_MISMATCH`;
- `REBASELINE_PROFILE_REQUIRED`;
- `REBASELINE_PROFILE_TARGET_MISMATCH`;
- `REBASELINE_COVERAGE_UNRESOLVED`;
- `REBASELINE_SLA_RULES_PENDING`;
- `REBASELINE_OPEN_SLA_UNDISPOSED`;
- `REBASELINE_OPEN_SIGNAL_UNDISPOSED`;
- `REBASELINE_WORKFLOW_UNDISPOSED`;
- `REBASELINE_AUTHORITY_INSUFFICIENT`;
- `REBASELINE_M3_FORMAL_BLOCKED`.

For activated decision:

> no error-severity issue may remain.

---

## 30. maintenance.propagation_assessment_issues(uuid)

Minimum issues:

- missing assessment;
- invalid replacement lineage;
- path missing;
- path discontinuity;
- candidate without path;
- cycle/depth truncation unresolved;
- lineage projection divergence;
- authoritative no_action without validated lineage;
- maintainable target misclassified;
- open_update_signal without active policy;
- propagation candidate source mismatch;
- scientific/methodological authoritative without qualified human.

---

## 31. maintenance.propagation_candidate_issues(uuid)

Minimum issues:

- candidate missing;
- target classification mismatch;
- disposition/status mismatch;
- disposition invalid for intermediate;
- missing rationale;
- insufficient authority;
- policy missing for open_update_signal;
- path incomplete;
- downstream signal linkage mismatch.

---

# PARTE N — IMMUTABILITY / LIFECYCLE

## 32. Append-preserving objects

Must be append-preserving:

- propagation_assessment;
- propagation_candidate;
- rebaseline_decision.

Allowed UPDATE:

> active → superseded preserving all material fields.

New correction:

> new row + supersedes FK.

---

## 33. Immutable child records

Immutable after INSERT:

- propagation_path;
- propagation_path_step;
- rebaseline_policy_link;
- rebaseline_monitor_link;
- rebaseline_risk_profile_link;
- rebaseline_coverage_item;
- rebaseline_sla_rule_link;
- rebaseline_sla_instance_disposition;
- rebaseline_open_signal_disposition;
- rebaseline_workflow_link.

If disposition changes materially:

- supersede parent decision and append a new decision/children.

This avoids child-level contradictory histories.

---

# PARTE O — CURRENTNESS / ASSURANCE / M3

## 34. Currentness

Migration future must not:

- INSERT CurrencyState automatically from propagation;
- UPDATE CurrencyState automatically from rebaseline;
- infer outdated/current from dependency status.

Downstream currentness remains local UpdateDecision/Monitor contract.

---

## 35. Assurance

No table in this contract:

- creates ReviewRecord;
- creates AssuranceRecord;
- promotes assurance;
- equates human verification of propagation/rebaseline with independent expert review.

---

## 36. M3

Every readiness helper for M3-relevant policy continues to emit:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

until a separate M3 gate explicitly authorizes change.

Migration 031, if later authorized, must not remove or bypass the blocker.

---

# PARTE P — BACKFILL / HISTORICAL DATA

## 37. No fabricated backfill

No historical propagation assessment or rebaseline decision is inferred from:

- existing superseded versions;
- old Monitor targets;
- old policy targets;
- old SLA rules/instances;
- old risk profiles.

Existing history remains valid without synthetic new rows.

New structures begin prospectively.

---

## 38. Grandfathering

Historical objects before migration:

- remain valid;
- are not required to gain propagation/rebaseline links;
- future issue helpers must distinguish legacy absence from post-migration required absence.

A migration timestamp/effective boundary should be explicit.

---

# PARTE Q — INDEXES / UNIQUENESS

## 39. Minimum indexes

Candidate indexes:

- propagation_assessment(origin_version_uuid,record_status);
- propagation_assessment(replacement_version_uuid);
- propagation_candidate(propagation_assessment_uuid,record_status);
- propagation_candidate(impacted_version_uuid,record_status);
- propagation_path(propagation_candidate_uuid,path_no);
- propagation_path_step(source_version_uuid);
- propagation_path_step(target_version_uuid);
- rebaseline_decision(old target,record_status);
- rebaseline_decision(new target,record_status);
- rebaseline links by old/new policy/Monitor/profile/SLA.

---

## 40. Active uniqueness

Do not enforce universal "one active rebaseline per entity" without context.

Minimum safe uniqueness:

- one active PropagationCandidate per assessment + impacted version;
- one child singleton link per RebaselineDecision where specified.

Potential concurrency guard for overlapping active planned rebaseline on same old target should be decided by the physical gate, because multiple competing proposals may legitimately exist before authoritative activation.

---

# PARTE R — MIGRATION BOUNDARY

## 41. Candidate migration number

If and only if Documento 36 passes:

> candidate migration = `031_propagation_rebaseline_contract.sql`.

At this stage:

> **MIGRATION_031 = NOT_AUTHORIZED**.

---

## 42. Migration 031 allowed scope if later authorized

Potentially allowed:

- structures listed in section 3;
- validators/guards;
- extension of update_signal_source with propagation candidate locator;
- issue/readiness helpers;
- synthetic test fixtures only;
- S5 integration;
- no normative production seed.

---

## 43. Explicitly prohibited from migration 031

- numeric SLA durations;
- real operational SLA rules;
- real calendars;
- scheduler;
- notification channels;
- auto-escalation;
- auto-propagation;
- automatic currentness writes;
- automatic policy creation;
- automatic Monitor creation;
- automatic risk profile creation;
- automatic UpdateSignal creation;
- fabricated human verification;
- fabricated historical rebaseline;
- M3 unblock.

---

# PARTE S — TEST PLAN

## 44. F4-PRB test families

Future suite:

> `database/f4-propagation-rebaseline-tests.sql`

and synthetic fixture:

> `database/f4-propagation-rebaseline-fixtures.sql`

Minimum test IDs proposed:

### Assessment — T01–T12

T01 structure exists;  
T02 origin FK;  
T03 event domain;  
T04 replacement same entity;  
T05 replacement later version;  
T06 invalid cross-entity replacement rejected;  
T07 verification metadata;  
T08 system authoritative rejected;  
T09 lineage status domain;  
T10 supersession same event;  
T11 material mutation rejected;  
T12 no fabricated backfill.

### Candidate — T13–T28

T13 active uniqueness;  
T14 product classification;  
T15 investigation classification;  
T16 evidence_monitoring not maintainable;  
T17 intermediate classification;  
T18 status/disposition matrix;  
T19 no_action requires validated lineage;  
T20 no_action scientific requires qualified human;  
T21 open signal only maintainable;  
T22 open signal requires active exact-target policy;  
T23 maintenance_policy_required only without active policy;  
T24 intermediate cannot open signal;  
T25 proposal AI allowed;  
T26 authoritative AI rejected;  
T27 operational owner allowed;  
T28 scientific owner rejected.

### Paths — T29–T42

T29 multi-path accepted;  
T30 one candidate per impacted version;  
T31 contiguous steps;  
T32 first source origin;  
T33 final target impacted;  
T34 step continuity;  
T35 depth count;  
T36 duplicate node rejected for complete path;  
T37 cycle_detected representable;  
T38 depth_limit representable;  
T39 incomplete path blocks no_action;  
T40 projection divergence blocks no_action;  
T41 path immutable;  
T42 dependency_edge later change does not rewrite snapshot.

### Signal adapter — T43–T50

T43 source_type propagation_candidate valid;  
T44 locator XOR;  
T45 candidate must be active;  
T46 candidate must be authoritative assessed/open_update_signal;  
T47 signal target matches candidate;  
T48 invalidated origin remains traceable;  
T49 signal causal type preserved;  
T50 no auto-signal on candidate disposition.

### Rebaseline header — T51–T66

T51 target XOR;  
T52 product→product only;  
T53 investigation→investigation only;  
T54 same entity;  
T55 new version later;  
T56 chain payload validator;  
T57 skipped versions represented;  
T58 planned with draft allowed;  
T59 activated requires current target;  
T60 authoritative activation;  
T61 activated_at required;  
T62 cross-entity rejected;  
T63 follow-latest impossible;  
T64 concurrent target change requires new row;  
T65 material mutation rejected;  
T66 supersession temporal.

### Policy/Monitor — T67–T80

T67 old policy target match;  
T68 new policy target match;  
T69 cross-target supersedes policy prohibited by existing contract;  
T70 rebaseline policy link preserves lineage;  
T71 maintenance_policy_required representable;  
T72 old Monitor target match;  
T73 new Monitor target match;  
T74 new M2/M3 Monitor must be current;  
T75 new M2/M3 Monitor state active;  
T76 same Monitor lineage entity check;  
T77 replacement Monitor different entity;  
T78 no old cycles moved;  
T79 M0/M1 monitor not required;  
T80 M3 blocker preserved.

### Profile/Coverage — T81–T92

T81 source profile old target;  
T82 target profile new target;  
T83 carry_forward linkage exact;  
T84 no old profile retarget;  
T85 target profile required for Priority path;  
T86 incorporated cutoff bound;  
T87 post-cutoff bound;  
T88 gap carry-forward representable;  
T89 source recheck representable;  
T90 old completed_at not baseline;  
T91 coverage debt preserved;  
T92 coverage child immutable.

### SLA — T93–T106

T93 old rule old policy;  
T94 new rule new policy;  
T95 cross-policy sla_rule supersession not used;  
T96 new rule explicit adoption;  
T97 no duration copy default;  
T98 calendar reuse explicit;  
T99 old instance old scope;  
T100 new instance new scope;  
T101 old start/due immutable;  
T102 first breach preserved;  
T103 pause history preserved;  
T104 new obligation independent;  
T105 rebase cannot erase breach;  
T106 unresolved old obligation blocks activation when required.

### Signal/workflow — T107–T116

T107 old signal policy preserved;  
T108 new signal separate;  
T109 old signal cannot move;  
T110 workflow result may be new target;  
T111 old workflow may complete;  
T112 old workflow may terminate;  
T113 new workflow separate;  
T114 milestones not copied;  
T115 Priority not retargeted;  
T116 Escalation not retargeted.

### Global — T117–T128

T117 propagation does not change CurrencyState;  
T118 rebaseline does not change CurrencyState automatically;  
T119 Assurance unchanged;  
T120 Alert not moved;  
T121 no Monitor retarget UPDATE;  
T122 no UpdatePolicy cross-target supersession;  
T123 M3 blocker;  
T124 migration idempotency;  
T125 rebuild-through-031;  
T126 F4-UP regression;  
T127 F4-OC/F4-RP regression;  
T128 F2-B/S4/S5/F3/Monitor/Alert regressions.

---

# PARTE T — READINESS

## 45. Physical gate required

Antes de migration, Documento 36 deve atacar no mínimo:

- duplicate/circular lineage;
- FK/constraint feasibility;
- target classification;
- authoritative boundary;
- path snapshot normalization;
- candidate→signal adapter;
- version-chain recomputation;
- policy handover lifecycle;
- Monitor activation ordering;
- profile carry-forward;
- coverage date semantics;
- SLA cross-policy lineage;
- historical grandfathering;
- concurrency;
- idempotency feasibility;
- issue helper circular dependencies.

---

## 46. Estado

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = REVISED_READY_FOR_RECHECK**

> **F4_PRB_T01_T140 = TEST_PLAN_REVISED_FOR_RECHECK**

> **MIGRATION_031 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 47. Próximo passo exato

> **Executar o recheck do Documento 36 sobre o hardening abaixo; somente PASS/PASS_WITH_ARCHITECTURAL_DECISIONS poderá autorizar migration 031 em escopo estrito.**


---

# PARTE U — HARDENING PÓS-DOCUMENTO 36

## 48. Interpretação normativa do hardening

As regras desta parte corrigem e prevalecem sobre qualquer formulação anterior ambígua do Documento 35.

---

## 49. Target classification final

`target_class`:

- `maintainable_product`;
- `maintainable_investigation`;
- `nonmaintainable_version`.

### maintainable_product

Exige:

- row em `product.product_version`;
- `product_type NOT IN ('evidence_monitor','evidence_alert')`;
- compatibilidade com as demais restrições de UpdatePolicy vigentes.

### maintainable_investigation

Exige:

- row em `investigation.investigation_version`;
- `investigation_type <> 'evidence_monitoring'`.

### nonmaintainable_version

Abrange:

- Evidence Monitor;
- Evidence Alert;
- evidence_monitoring InvestigationVersion;
- demais objetos versionados sem policy própria.

Somente os dois maintainable classes podem usar:

- `maintenance_policy_required`;
- `open_update_signal`;
- `rebaseline_required`.

---

## 50. max_depth

`max_depth`:

- obrigatório;
- inteiro > 0;
- sem default universal;
- sem teto normativo neste contrato.

O valor usado em cada assessment é provenance operacional da traversal.

Resource guards de execução não podem ser reinterpretados como threshold científico/metodológico.

---

## 51. no_action_supported endurecido

Authoritative `no_action_supported` exige:

1. parent `lineage_validation_status='validated_against_canonical_relations'`;
2. candidate com ao menos um path `complete`, quando originado por traversal;
3. ausência de path relevante em `cycle_detected`, `depth_limit_reached`, `projection_divergence` ou `incomplete_unknown` sem resolução explícita;
4. rationale;
5. authority humana qualificada para scientific/methodological/mixed.

Traversal truncada nunca sustenta ausência de impacto.

---

## 52. maintenance.rebaseline_version_chain_step

Nova estrutura física obrigatória.

Campos:

- `rebaseline_decision_uuid uuid NOT NULL FK maintenance.rebaseline_decision`;
- `step_no integer NOT NULL CHECK (step_no > 0)`;
- `from_version_uuid uuid NOT NULL FK core.entity_version`;
- `to_version_uuid uuid NOT NULL FK core.entity_version`;
- `relationship_type text NOT NULL DEFAULT 'supersedes'`;
- PRIMARY KEY(`rebaseline_decision_uuid,step_no`).

Guards:

1. relationship_type v0.1 = `supersedes`;
2. step 1 from = old target;
3. último step to = new target;
4. step N to = step N+1 from;
5. cada `to_version_uuid.supersedes_version_uuid = from_version_uuid`;
6. from/to pertencem à mesma entity_uuid;
7. nenhuma version se repete;
8. steps contíguos;
9. count >= 1.

`version_chain_summary_payload` é apenas derivado/serializer e não substitui essas FKs.

---

## 53. RebaselineDecision supersession/lifecycle

Supersession exige:

- old target exatamente igual;
- new target exatamente igual;
- mesma target family;
- `decided_at` monotônico.

Transições:

- `planned → activated`;
- `planned → cancelled_invalidated`;
- `activated → activated` somente para correção append-preserving que preserve target pair, activation fact e causal basis essencial;
- `cancelled_invalidated` terminal.

Mudança do new target:

> nova decisão causal, não supersession da mesma decisão.

Child records da nova decision são novos registros completos; children do parent anterior permanecem imutáveis.

---

## 54. Unicidade da activation authoritative

Adicionar partial unique indexes separados:

- old ProductVersion;
- old InvestigationVersion.

Condição:

- `record_status='active'`;
- `decision_stage='activated'`;
- `authority_status='authoritative'`.

Resultado:

> no máximo um handover authoritative activated ativo por old target.

Planned/proposal concorrentes continuam permitidos.

---

## 55. Policy activation readiness

Para `decision_stage='activated'`:

### replace_with_new_policy

- old policy target = old target;
- new policy target = new target;
- new policy `record_status='active'`.

Old policy:

- pode estar active ou superseded;
- nunca pode apontar para target diferente.

### maintenance_policy_required

Bloqueia activation.

### pending

Bloqueia activation.

### stop_maintenance

Pode ativar com new policy NULL.

### not_applicable

Exige rationale que demonstre por que manutenção não se aplica.

Cross-target `supersedes_update_policy_uuid` continua proibido.

---

## 56. Profile readiness final

`profile_disposition`:

- `target_profile_available`;
- `carry_forward_authorized`;
- `new_assessment_required`;
- `target_reassessment_required`;
- `not_applicable`;
- `pending`.

Rules:

- `pending` bloqueia activation;
- target_profile_available exige target profile do new target;
- carry_forward_authorized exige physical carry-forward da migration 030;
- target_reassessment_required só pode referir reassessment de profile já do new target;
- ausência de profile não bloqueia toda activation por default;
- se nova PriorityAssessment existir/for criada, migration 030 continua exigindo physical profile.

`REBASELINE_PROFILE_REQUIRED` vira issue contextual, não universal.

---

## 57. Coverage cutoff final

`incorporated_through_new_target_cutoff`:

- se window_end_date estiver presente, deve ser exatamente new target `evidence_cutoff_date`;
- window_start_date <= window_end_date;
- ausência de janela exige payload/rationale com basis estruturado.

`post_cutoff_pending_assessment`:

- window_start_date, quando presente, deve ser > cutoff.

Nenhum old Monitor `completed_at` é usado como scientific baseline.

---

## 58. Old UpdateSignal não é invalidated por supersession do target

`signal_disposition` final:

- `retain_historical_no_transfer`;
- `resolve_on_old_target`;
- `continue_old_target_workflow`;
- `create_new_signal_on_new_target`;
- `governance_review_required`.

Rebaseline disposition:

- não muda `update_signal.status` por si só;
- não transforma target supersession em signal invalidation.

`update_signal.status='invalidated'` continua reservado ao caso em que o signal em si é invalidado segundo o contrato existente.

---

## 59. UpdateSignalSource propagation adapter completo

Migration 031, se autorizada, deverá modificar em conjunto:

1. source_type domain;
2. nova FK `propagation_candidate_uuid`;
3. locator XOR;
4. `maintenance.assert_update_signal_source_consistency()`;
5. `maintenance.update_signal_issues()`;
6. qualquer query/test que conte locators;
7. idempotência das alterações de constraint.

Candidate source válido exige:

- candidate active;
- assessment_status = assessed;
- disposition = open_update_signal;
- authority_status = authoritative;
- candidate target = exact UpdatePolicy target do signal.

---

## 60. maintenance.contract_epoch

Adicionar metadata técnica transversal se não houver mecanismo equivalente.

Schema candidato:

- `contract_code text PRIMARY KEY`;
- `schema_version text NOT NULL`;
- `effective_at timestamptz NOT NULL`;
- `migration_id text NOT NULL`;
- `created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP`.

Migration 031 insere idempotentemente:

- contract_code = `PROPAGATION_REBASELINE_V01`;
- schema_version = `0.1`;
- migration_id = `031`;
- effective_at = timestamp de primeira aplicação do contrato.

Idempotência:

> reaplicação não altera effective_at original.

Uso permitido:

- grandfathering técnico.

Uso proibido:

- evidence cutoff;
- cadence anchor;
- SLA start;
- publication timestamp;
- scientific event time;
- rebaseline decision time.

---

## 61. Transition basis equality

Se:

- `transition_basis_type='result_product_version'`, então locator = new ProductVersion;
- `transition_basis_type='result_investigation_version'`, então locator = new InvestigationVersion.

Se basis = workflow_round:

- o round deve pertencer à causalidade declarada;
- quando sua result version é usada como justificativa de produção do target, result = new target.

Locator XOR permanece obrigatório.

---

## 62. SLA cross-policy guard

Para `rebaseline_sla_rule_link`:

- old rule.policy = old policy;
- new rule.policy = new policy;
- `new_rule.supersedes_sla_rule_uuid IS DISTINCT FROM old_rule_uuid`;
- mesma `rule_code` pode documentar continuidade semântica;
- supersession FK de SLA continua estritamente same-policy.

Nenhuma rule é copiada por default.

---

## 63. Child sets e activation

Planned decision e activated decision possuem child sets próprios.

Não:

- UPDATE child de planned para “virar” activated;
- mover child entre parent decisions;
- reutilizar child PK.

A parent supersession fornece lineage entre os snapshots de handover.

---

## 64. Activation completeness

`rebaseline_decision_issues()` para activated authoritative deverá verificar adicionalmente:

- version chain normalizada completa;
- policy disposition não pending/maintenance_policy_required;
- Monitor requirements satisfeitos para M2/M3;
- profile disposition não pending;
- coverage sem pending obrigatório;
- old active signals relevantes possuem disposition;
- old open/relevant SLA instances possuem disposition;
- active workflow rounds relevantes possuem disposition;
- child set pertence à mesma decision;
- contract epoch existe;
- M3 blocker quando aplicável.

---

## 65. Test plan revisado — T129–T140

Adicionar:

T129 — maintainable_product rejeita Evidence Monitor/Alert;  
T130 — nonmaintainable_version classifica Monitor/Alert/evidence_monitoring;  
T131 — max_depth sem teto universal e valor explícito;  
T132 — no_action bloqueado por candidate path truncado;  
T133 — rebaseline_version_chain_step FK/contiguidade/supersession;  
T134 — authoritative activated unique por old target;  
T135 — planned→activated preserva exact target pair;  
T136 — target supersession não invalida UpdateSignal;  
T137 — propagation adapter atualiza locator count + issue helper;  
T138 — contract_epoch idempotente e effective_at preservado;  
T139 — transition result locator deve igualar new target;  
T140 — activated child set completo + M3 blocker.

---

## 66. Estado após hardening

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = REVISED_READY_FOR_RECHECK**

> **F4_PRB_T01_T140 = TEST_PLAN_REVISED_FOR_RECHECK**

> **MIGRATION_031 = NOT_AUTHORIZED_UNTIL_DOCUMENT_36_RECHECK**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

