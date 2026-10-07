# 30 — Contrato Físico Candidato do UpdateRiskProfile

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISED_AFTER_ADVERSARIAL_REVIEW — pronto para recheck do Documento 31**  
**Dependências:** Documentos 16–17, 18–21, 25–29; migrations 027–029  
**Migration:** **não autorizada neste documento**

---

## 1. Finalidade

Normalizar fisicamente o perfil de risco de atualização definido no Documento 16, substituindo a dependência exclusiva de snapshots JSON por uma identidade versionada, auditável e referenciável.

O contrato deve permitir representar:

- risco científico/decisório A1–A5;
- perfil operacional B1–B5;
- recomendação M0–M3;
- recomendação de cadence;
- necessidade event-driven;
- feasibility;
- temporalidade;
- reassessment;
- carry-forward explícito;
- provenance/rationale;
- autoridade e verificação;
- integração com UpdatePolicy, PriorityAssessment e SLA;

sem:

- criar score agregado;
- alterar currentness;
- ativar M0–M3 automaticamente;
- calibrar SLA numérico;
- remover o blocker M3;
- reescrever snapshots históricos da migration 029.

---

## 2. Decisão de modelagem

Não persistir A1–A5/B1–B5 como dez colunas sem identidade própria.

Motivo:

> as dimensões possuem autoridades epistemológicas diferentes.

Exemplos:

- A2/A3/A4 exigem qualificação científica;
- A5 pode ser derivada do dependency graph;
- B3/B4 combinam método e operação;
- B5 representa capacidade sustentável institucional.

Baseline candidata:

1. `maintenance.update_risk_profile`;
2. `maintenance.update_risk_profile_dimension`;
3. `maintenance.update_risk_profile_dimension_basis`;
4. `maintenance.update_risk_profile_trigger`;
5. `maintenance.update_policy_risk_profile_basis`.

---

# PARTE A — UPDATE RISK PROFILE

## 3. maintenance.update_risk_profile

Representa um assessment versionado do perfil de risco para uma versão científica concreta.

Campos mínimos:

- `update_risk_profile_uuid` PK;
- `target_product_version_uuid` opcional;
- `target_investigation_version_uuid` opcional;
- `assessment_kind`;
- `recommended_maintenance_level`;
- `recommended_cadence_mode`;
- `event_driven_surveillance_required`;
- `feasibility_status`;
- `priority_implications_payload`;
- `rationale`;
- `profiled_by`;
- `actor_type`;
- `verification_status`;
- `verified_by`;
- `verifier_actor_type`;
- `verified_at`;
- `authority_status`;
- `assessed_at`;
- `effective_at`;
- `recorded_at`;
- `record_status`;
- `supersedes_update_risk_profile_uuid` opcional;
- `carried_forward_from_profile_uuid` opcional.

Target:

> exatamente um entre ProductVersion e InvestigationVersion.

---

## 4. assessment_kind

Domínio:

- `initial`;
- `reassessment`;
- `carry_forward`.

### initial

- primeiro perfil daquele target version;
- `supersedes...` NULL;
- `carried_forward_from...` NULL.

### reassessment

- nova avaliação do mesmo target version;
- `supersedes...` obrigatório;
- perfil supersedido deve apontar para exatamente o mesmo target version;
- `carried_forward_from...` NULL.

### carry_forward

- novo target version;
- `carried_forward_from_profile_uuid` obrigatório;
- source e novo target devem pertencer ao mesmo objeto científico subjacente;
- target version deve ser diferente;
- `supersedes...` NULL no primeiro profile do novo target.

Lineage:

- ProductVersion → mesmo `product.product.entity_uuid`;
- InvestigationVersion → mesmo `investigation.investigation.entity_uuid`.

Carry-forward entre Product e Investigation:

> proibido.

---

## 5. Temporalidade

Cada profile deve ter:

- `assessed_at`;
- `effective_at`.

Regras:

- `effective_at >= assessed_at`, salvo rationale normativa explícita? **Não**: baseline v0.1 proíbe backdating.
- supersession deve respeitar ordem temporal;
- profile histórico permanece imutável;
- mudança posterior de capacidade, observabilidade ou pipeline cria novo profile.

Baseline:

> `effective_at >= assessed_at`.

Não backdate profile.

---

## 6. Authority status

Domínio:

- `proposal`;
- `authoritative`.

### proposal

Pode ser produzido por:

- system;
- ai_system;
- human_reviewer;
- human_expert;
- owner.

### authoritative

Exige:

- `actor_type = human_reviewer | human_expert`;
- verification_status = human_verified | human_consensus;
- dez dimensões completas;
- dimensões autoritativas;
- B5 authoritative emitida por owner;
- regras de authority por dimensão satisfeitas;
- regras de dominância/não compensação satisfeitas.

Owner pode assess dimensões autorizadas e B5, mas:

> não sintetiza sozinho o profile composto authoritative.

AI/system:

> não cria profile authoritative.

---

## 7. Uma versão vigente

Por target version:

> no máximo um profile `active + authoritative`.

Proposals podem coexistir.

Proposal:

- pode ser incompleto;
- pode possuir subconjunto das dimensões;
- issue helper deve reportar dimensões ausentes;
- não pode ser usado como authoritative governing basis.

Um novo profile authoritative para o mesmo target:

> supersede + append.

Não editar profile histórico.

---

# PARTE B — DIMENSÕES

## 8. maintenance.update_risk_profile_dimension

Uma linha por dimensão por profile.

Campos mínimos:

- `update_risk_profile_uuid` FK;
- `dimension_code`;
- `value_code`;
- `assessment_mode`;
- `source_profile_uuid` opcional;
- `rationale`;
- `assessed_by`;
- `actor_type`;
- `verification_status`;
- `verified_by`;
- `verifier_actor_type`;
- `verified_at`;
- `authority_status`;
- `assessed_at`;
- `recorded_at`.

PK:

> `update_risk_profile_uuid + dimension_code`.

Dimensões fechadas:

- A1;
- A2;
- A3;
- A4;
- A5;
- B1;
- B2;
- B3;
- B4;
- B5.

Nenhuma dimensão R0–R3.

---

## 9. Domínio de valores

### A1 — criticality

- low;
- moderate;
- high.

### A2 — evidence_volatility

- low;
- moderate;
- high.

### A3 — conclusion_sensitivity

- low;
- moderate;
- high.

### A4 — safety_integrity

- low;
- moderate;
- high.

### A5 — dependency_reach

- restricted;
- moderate;
- broad;
- systemic.

### B1 — source_observability

- high;
- moderate;
- low;
- very_low.

### B2 — detection_latency

- short;
- moderate;
- long;
- unpredictable.

### B3 — surveillance_load

- low;
- moderate;
- high;
- extreme.

### B4 — incorporation_cost

- low;
- moderate;
- high;
- very_high.

### B5 — sustainable_capacity

- adequate;
- strained;
- insufficient;
- unavailable.

Uma validator function futura deverá validar:

> dimension_code × value_code.

---

## 10. assessment_mode da dimensão

Domínio:

- `assessed`;
- `carried_forward`.

### assessed

A dimensão foi efetivamente reavaliada neste profile.

Pode manter o mesmo valor anterior.

### carried_forward

A dimensão foi explicitamente mantida a partir de profile anterior.

Exige:

- `source_profile_uuid`;
- source profile authoritative;
- mesma dimension_code existente no source;
- value_code idêntico ao source;
- rationale explícita;
- aceitação humana para dimensão authoritative.

Não existe carry-forward silencioso.

---

## 11. Regra por assessment_kind

### profile initial

Todas as dez dimensões:

> `assessment_mode='assessed'`.

### profile reassessment

Cada dimensão deve declarar:

- assessed; ou
- carried_forward do profile supersedido.

### profile carry_forward

Cada dimensão deve declarar:

- assessed; ou
- carried_forward do `carried_forward_from_profile_uuid`.

Logo:

> o novo profile sempre possui dez linhas completas.

Não representar “apenas os deltas” como profile vigente.

---

## 12. Authority da dimensão

Toda dimensão possui:

- authority_status;
- verification metadata.

AI/system:

> proposal apenas.

Dimension authoritative:

- ator humano;
- human_verified | human_consensus.

Além disso:

### A2 — evidence_volatility

Authoritative:

- human_reviewer; ou
- human_expert.

### A3 — conclusion_sensitivity

Authoritative:

- human_reviewer; ou
- human_expert.

### A4 — safety_integrity

Authoritative:

- human_reviewer; ou
- human_expert.

### A1 — criticality

Authoritative:

- human_reviewer;
- human_expert;
- owner.

A1 é criticidade do uso/decisão, não conclusão científica isolada.

### A5 — dependency_reach

Authoritative:

- human_reviewer;
- human_expert;
- owner.

System pode gerar proposta derivada do grafo; humano deve aceitar a linha authoritative.

### B1–B4

Authoritative:

- human_reviewer;
- human_expert;
- owner.

### B5 — sustainable_capacity

Authoritative:

> owner.

Motivo:

> B5 declara capacidade sustentável institucional, não inferência científica.

---

## 13. maintenance.update_risk_profile_dimension_basis

Provenance por dimensão será normalizada em estrutura própria.

Campos mínimos:

- `update_risk_profile_uuid`;
- `dimension_code`;
- `source_type`;
- `monitor_cycle_uuid` opcional;
- `candidate_assessment_uuid` opcional;
- `update_signal_uuid` opcional;
- `alert_product_version_uuid` opcional;
- `source_entity_version_uuid` opcional;
- `source_artifact_uuid` opcional;
- `external_reference_payload` opcional;
- `observation_payload` opcional;
- `rationale`;
- `sequence_no`.

FK composta:

> profile_uuid + dimension_code deve existir em `update_risk_profile_dimension`.

Domínio `source_type`:

- monitor_cycle;
- candidate_assessment;
- update_signal;
- alert_product_version;
- entity_version;
- artifact;
- external_reference.

Regras:

- source OES estruturado → exatamente um locator FK compatível;
- external_reference → nenhum locator OES e payload externo obrigatório;
- source_type/locator mismatch é erro;
- Alert locator deve ser ProductVersion `evidence_alert`;
- MonitorCycle/CandidateAssessment mantêm integridade referencial real.

Não criar UUID fictício nem esconder identificadores OES em JSON.

`observation_payload` registra a observação extraída da fonte.

A migration futura valida integridade/shape:

> não interpreta ciência automaticamente.

---

# PARTE C — SAÍDA RECOMENDATÓRIA

## 14. recommended_maintenance_level

Domínio:

- M0;
- M1;
- M2;
- M3.

É recomendação.

Não altera:

- `maintenance.update_policy.effective_maintenance_level`;
- `investigation_version.maintenance_level`.

---

## 15. recommended_cadence_mode

Domínio:

- none;
- event_driven;
- periodic;
- hybrid;
- continuous.

Compatibilidade com manutenção:

- M0 → none;
- M1 → event_driven | periodic | hybrid;
- M2 → periodic | hybrid;
- M3 → continuous | hybrid.

Um profile authoritative incompatível:

> inválido.

---

## 16. event_driven_surveillance_required

Booleano recomendatório.

Regra de dominância:

> A4=high exige `event_driven_surveillance_required=true`.

A4 high não:

- cria UpdateSignal;
- muda currentness;
- ativa M3;
- cria Alert.

---

## 17. feasibility_status

Domínio:

- adequate;
- strained;
- insufficient;
- unavailable.

Não é score.

É síntese explícita de:

- B3 surveillance load;
- B4 incorporation cost;
- B5 sustainable capacity.

Regra de não compensação:

> feasibility nunca altera A1–A5.

### Ceiling por B5

Feasibility não pode ser mais favorável que B5:

- B5 adequate → feasibility pode ser adequate/strained/insufficient/unavailable;
- B5 strained → feasibility não pode ser adequate;
- B5 insufficient → feasibility = insufficient | unavailable;
- B5 unavailable → feasibility = unavailable.

Isso é ceiling qualitativo, não soma/score.

---

## 18. M3 recommendation

Profile authoritative com:

> `recommended_maintenance_level='M3'`

exige:

- B5 = adequate;
- feasibility_status = adequate;
- recommended_cadence_mode = continuous | hybrid.

Ainda assim:

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**.

Recomendação M3 não remove blocker nem torna Monitor M3 publicável.

---

## 19. Criticidade/safety e M0

Profile authoritative:

- A1=high → não pode recomendar M0;
- A4=high → não pode recomendar M0.

Motivo:

> criticidade/safety alta não pode ser compensada por baixa volatilidade para eliminar vigilância.

M1 event-driven permanece opção possível.

---

## 20. A2/A3

A2 high isolada:

- não força M3;
- não produz algoritmo automático.

A3 high:

- não muda currentness;
- pode sustentar vigilância mais intensa;
- não possui mapping automático para M2/M3.

---

## 21. priority_implications_payload

Não é priority score.

Shape mínimo:

- `schema_version`;
- `dominance_notes` array;
- `coordination_notes` array;
- `feasibility_notes` array;
- `rationale`.

Não deve conter:

- numeric priority weight;
- resposta `standard/expedited/urgent/immediate` autoritativa automática.

PriorityAssessment continua sendo objeto próprio.

---

# PARTE D — REASSESSMENT TRIGGERS

## 22. maintenance.update_risk_profile_trigger

1:N por profile.

Campos:

- `update_risk_profile_uuid`;
- `trigger_code`;
- `source_type`;
- `update_signal_uuid` opcional;
- `alert_product_version_uuid` opcional;
- `monitor_cycle_uuid` opcional;
- `source_entity_version_uuid` opcional;
- `source_artifact_uuid` opcional;
- `external_reference_payload` opcional;
- `rationale`;
- `sequence_no`.

Domínio `source_type`:

- none;
- update_signal;
- alert_product_version;
- monitor_cycle;
- entity_version;
- artifact;
- external_reference.

Regra:

> source_type determina exatamente o locator permitido.

`source_type='none'` exige todos os locators NULL.

`external_reference` exige payload externo e nenhum locator OES.

Domínio `trigger_code`:

- initial_baseline;
- new_scientific_version;
- use_context_change;
- policy_regulatory_change;
- evidence_pipeline_change;
- certainty_change;
- signal_frequency_change;
- capacity_change;
- source_observability_change;
- maintenance_level_change;
- dependency_graph_change;
- explicit_governance_request;
- other.

---

## 23. Trigger semantics

### initial profile

Exige:

> initial_baseline.

Pode usar:

> `source_type='none'`

quando o baseline não nasce de um evento OES específico.

### reassessment

Exige pelo menos um trigger diferente de initial_baseline.

### carry_forward

Exige:

> new_scientific_version.

Trigger:

- explica por que o profile existe;
- não altera as dimensões automaticamente;
- não é MaterialityAssessment;
- não é UpdateSignal por default.

Quando houver UpdateSignal real:

> pode referenciá-lo.

Não fabricar UpdateSignal apenas para justificar reassessment operacional.

---

# PARTE E — POLICY BASIS

## 24. maintenance.update_policy_risk_profile_basis

Link append-preserving entre UpdatePolicy e profile.

Campos:

- `update_policy_risk_profile_basis_uuid` PK;
- `update_policy_uuid` FK;
- `update_risk_profile_uuid` FK;
- `basis_role`;
- `linked_at`;
- `linked_by`;
- `actor_type`;
- `rationale`;
- `record_status`;
- `supersedes_update_policy_risk_profile_basis_uuid` opcional.

Correção:

> supersede + append.

Governing link novo para a mesma policy deve superseder o anterior; não atualizar FK in place.

Domínio `basis_role`:

- governing;
- supporting.

Baseline:

> no máximo um governing link ativo por UpdatePolicy.

---

## 25. Policy basis consistency

Governing profile:

- authoritative;
- active no momento do linkage;
- target exatamente igual ao UpdatePolicy target;
- `effective_at <= UpdatePolicy.effective_at` quando o profile já existia na decisão.

Para profile criado posteriormente apenas para reconstrução histórica:

> não marcar como governing retroativamente.

Isso evita falsa provenance.

---

## 26. Policy continua soberana

Diferença entre profile recommendation e UpdatePolicy é permitida.

Exemplo:

- profile recomenda M2;
- policy mantém M1 por governança/capacidade/escopo.

Obrigatório:

> rationale explícita na policy/governance quando houver divergence relevante.

O profile:

- não edita policy;
- não supersede policy;
- não ativa cadence;
- não cria SLA Rule.

---

# PARTE F — INTEGRAÇÃO COM PRIORITYASSESSMENT

## 27. Referência física

Migration futura deverá adicionar:

> `maintenance.priority_assessment.update_risk_profile_uuid` nullable para compatibilidade histórica.

Não remover:

> `risk_profile_snapshot`.

Regra de adoção:

- linhas já existentes antes da migration permanecem snapshot-only;
- **todo novo INSERT** de PriorityAssessment após a migration deve possuir `update_risk_profile_uuid`;
- não backfill histórico fabricado.

A referência física informa a origem.

O snapshot:

> continua congelando o estado usado naquela PriorityAssessment.

---

## 28. Compatibilidade histórica

PriorityAssessments existentes após migration 029:

- permanecem válidas;
- não recebem profile_uuid fabricado;
- não são reescritas.

Elas continuam:

> legacy snapshot-only.

Não criar profile retroativo apenas para preencher FK.

---

## 29. Novas PriorityAssessments

Após a migration que materializar o profile:

- novo PriorityAssessment deve sempre referenciar `update_risk_profile_uuid`;
- profile deve corresponder ao mesmo target/policy context;
- authoritative scientific/mixed exige profile authoritative;
- proposal pode usar profile proposal ou authoritative;
- `risk_profile_snapshot` deve ser **exatamente** o serializer canônico daquele profile no INSERT.

Não depender de JSON montado manualmente para novas linhas.

---

## 30. Serializer canônico

Função futura candidata:

> `maintenance.update_risk_profile_snapshot(profile_uuid)`

Deve produzir JSON compatível com:

> `maintenance.risk_profile_snapshot_is_valid()`

Incluindo no mínimo:

- schema_version;
- assessed_at;
- A1–A5;
- B1–B5;
- rationale.

Deve adicionar:

- update_risk_profile_uuid;
- effective_at;
- recommended_maintenance_level;
- recommended_cadence_mode;
- feasibility_status.

Para novos PriorityAssessments:

> igualdade exata com o serializer canônico é obrigatória no momento do INSERT.

Snapshot não substitui FK.

---

## 31. PriorityBasis

Migration futura poderá estender:

> `maintenance.priority_basis.source_type`

com:

> `risk_profile`.

E adicionar:

> `update_risk_profile_uuid` FK.

Locator XOR deve continuar fechado.

Legacy `source_type='snapshot'` permanece válido para registros históricos; novos basis que representem profile físico devem usar `source_type='risk_profile'`.

---

# PARTE G — INTEGRAÇÃO COM SLA

## 32. SLA Rule

Risk profile físico pode ser selector/input normativo futuro.

Entretanto:

- não define duração automaticamente;
- não cria SLA Rule;
- não recalibra rule existente;
- não retroage SLA Instance.

SLA Rule selection continua governada pelo contrato próprio.

---

## 33. SLA Instance

Quando uma SLA Instance usar risk profile:

- rule snapshot deve preservar profile UUID/version;
- snapshot temporal não deve consultar “profile atual” retroativamente.

Mudança posterior do profile:

> não recalcula SLA Instance.

---

# PARTE H — INTEGRAÇÃO COM MONITOR/ALERT

## 34. Monitor

Monitor pode fornecer basis para:

- A2;
- B1;
- B2;
- B3;
- B5.

Monitor:

> não decide profile automaticamente.

Cycle metrics podem gerar proposal/reassessment candidate no futuro, não authoritative profile.

---

## 35. Alert

Alert pode ser trigger de reassessment.

Não define automaticamente:

- A4;
- A3;
- recommended M;
- currentness.

Alert critical/urgent:

> pode justificar reassessment prioritário.

---

# PARTE I — TARGET LIFECYCLE

## 36. Same-target reassessment

Mesmo target version:

- novo profile reassessment;
- supersedes profile authoritative anterior;
- cada dimensão assessed ou carried_forward explicitamente.

---

## 37. Nova versão científica

Nova ProductVersion/InvestigationVersion:

- exige profile initial novo; ou
- profile carry_forward explícito.

Nunca:

> copiar profile silenciosamente.

---

## 38. Carry-forward lineage

Carry-forward permitido somente se:

- source e target são ambos ProductVersion do mesmo `entity_uuid`; ou
- ambos InvestigationVersion do mesmo `entity_uuid`.

Além disso:

- novo profile `effective_at >= source_profile.effective_at`;
- source profile deve ser authoritative;
- dimension `carried_forward` em profile carry_forward deve usar o source profile do header;
- dimension `carried_forward` em reassessment deve usar o profile supersedido.

Não basta título semelhante.

---

## 39. Superseded target

Profile histórico permanece válido como histórico.

Não retarget.

Se nova target version surgir:

> criar novo profile.

---

# PARTE J — READINESS / ISSUES

## 40. Helpers futuros

Candidatos:

- `maintenance.update_risk_profile_issues(uuid)`;
- `maintenance.update_risk_profile_dimension_issues(profile_uuid)`;
- `maintenance.current_authoritative_risk_profile(target)`;
- `maintenance.update_risk_profile_snapshot(uuid)`;
- `maintenance.update_policy_risk_profile_basis_issues(policy_uuid)`.

Helpers:

- não alteram profile;
- não alteram policy;
- não mudam currentness;
- não criam PriorityAssessment;
- não ativam M3.

---

## 41. Profile completeness

Profile authoritative ativo deve possuir:

> exatamente 10 dimensões.

Uma por:

A1, A2, A3, A4, A5, B1, B2, B3, B4, B5.

O guard físico deve ser:

> deferred constraint / commit-time validation.

Motivo:

- profile header e dimensions são inseridos na mesma transação.

---

## 42. Issue classes

No mínimo:

- PROFILE_TARGET_MISSING;
- PROFILE_TARGET_MISMATCH;
- PROFILE_DIMENSION_MISSING;
- PROFILE_DIMENSION_VALUE_INVALID;
- PROFILE_DIMENSION_AUTHORITY_INVALID;
- PROFILE_DIMENSION_VERIFICATION_INVALID;
- PROFILE_CARRY_FORWARD_SOURCE_INVALID;
- PROFILE_CARRY_FORWARD_VALUE_DRIFT;
- PROFILE_TEMPORAL_ORDER_INVALID;
- PROFILE_MAINTENANCE_CADENCE_MISMATCH;
- PROFILE_A4_EVENT_DRIVEN_REQUIRED;
- PROFILE_HIGH_CRITICALITY_M0_FORBIDDEN;
- PROFILE_HIGH_SAFETY_M0_FORBIDDEN;
- PROFILE_FEASIBILITY_EXCEEDS_B5;
- PROFILE_M3_CAPACITY_BLOCKED;
- PROFILE_TRIGGER_MISSING;
- PROFILE_POLICY_TARGET_MISMATCH;
- PROFILE_PRIORITY_SNAPSHOT_DRIFT;
- PROFILE_TARGET_SUPERSEDED_REASSESSMENT_REQUIRED.

---

# PARTE K — MIGRATION COMPATIBILITY

## 43. Alterações físicas candidatas

Uma migration futura poderá:

1. criar as cinco estruturas deste documento;
2. criar validators/guards/helpers;
3. adicionar FK nullable `priority_assessment.update_risk_profile_uuid`;
4. estender PriorityBasis com source_type risk_profile + FK;
5. manter `risk_profile_snapshot` obrigatório;
6. adicionar serializer;
7. adicionar readiness/issue integration.

---

## 44. Sem backfill fabricado

Não fazer:

```text
for every historical risk_profile_snapshot
    create an authoritative UpdateRiskProfile
```

Isso fabricaria:

- assessor;
- verification;
- effective_at;
- authority;
- provenance.

Snapshots históricos permanecem snapshots.

---

## 45. Fixture migration

Fixtures sintéticas podem criar profile físico correspondente ao cenário F4-OC.

Nesse caso:

- profile é explicitamente sintético;
- dimensões possuem atores sintéticos;
- PriorityAssessment fixture futura pode referenciar o profile;
- snapshot deve ser gerado pelo serializer.

Isso é teste, não backfill canônico de dados reais.

---

# PARTE L — INVARIANTES

## 46. Currentness

UpdateRiskProfile:

> não possui CurrencyState.

Não muda:

- current;
- under_evaluation;
- update_recommended;
- outdated.

---

## 47. Assurance

Profile authoritative:

> não promove A1/A2/A3 assurance.

Não equivale a expert independent review.

---

## 48. M0–M3

Profile recomenda.

UpdatePolicy decide.

InvestigationVersion histórico permanece histórico.

Nenhum trigger:

> profile → UpdatePolicy automático.

---

## 49. M3

Mesmo profile:

- A1 high;
- A2 high;
- A3 high;
- B5 adequate;
- recommendation M3;

não remove:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

---

## 50. SLA

Profile não contém:

- duration;
- due_at;
- calendar;
- breach.

---

## 51. Priority

Profile não contém:

- standard;
- expedited;
- urgent;
- immediate.

Priority implications são rationale, não decisão.

---

# PARTE M — PLANO MÍNIMO DE TESTES FUTUROS

## 52. Estrutura e target

1. target XOR;
2. ProductVersion válido;
3. InvestigationVersion válido;
4. um authoritative active por target;
5. proposals coexistentes;
6. profile imutável;
7. supersession same-target;
8. carry-forward same lineage;
9. carry-forward cross-lineage rejeitado;
10. cross-type carry-forward rejeitado.

## 53. Dimensões

11. exatamente dez dimensões authoritative;
12. dimension_code fechado;
13. value mapping A1;
14. value mapping A2;
15. value mapping A3;
16. value mapping A4;
17. value mapping A5;
18. value mapping B1;
19. value mapping B2;
20. value mapping B3;
21. value mapping B4;
22. value mapping B5;
23. duplicate dimension rejeitada;
24. AI/system authoritative dimension rejeitada;
25. A2 owner authoritative rejeitado;
26. A3 owner authoritative rejeitado;
27. A4 owner authoritative rejeitado;
28. B5 non-owner authoritative rejeitado;
29. verification humana authoritative exigida;
30. profile header authoritative por owner rejeitado;
31. dimension basis locator XOR;
32. monitor_cycle basis FK real;
33. external basis sem UUID OES fictício.

## 54. Carry-forward

34. initial somente assessed;
35. reassessment source = superseded profile;
36. reassessment carried dimension mantém valor;
37. carry_forward source = header source;
38. carried dimension mantém valor;
39. carried dimension rationale obrigatório;
40. new scientific version sem carry-forward silencioso;
41. carried source authoritative exigido;
42. carry-forward effective_at não antecede source profile.

## 55. Recomendação

43. M0→none;
44. M1 cadence compatível;
45. M2 cadence compatível;
46. M3 cadence compatível;
47. A4 high exige event-driven;
48. A1 high bloqueia M0;
49. A4 high bloqueia M0;
50. B5 strained bloqueia M3;
51. B5 insufficient bloqueia M3;
52. B5 unavailable bloqueia M3;
53. feasibility não supera B5 ceiling;
54. sem score agregado;
55. priority_implications não contém response_class autoritativa.

## 56. Triggers

56. initial_baseline obrigatório para initial;
57. reassessment exige trigger não inicial;
58. carry_forward exige new_scientific_version;
59. Alert pode ser trigger sem definir A4;
60. capacity_change pode gerar reassessment sem UpdateSignal;
61. trigger source_type/locator XOR;
62. source_type none sem locator.

## 57. Policy basis

63. governing profile target = policy target;
64. governing profile authoritative;
65. um governing ativo por policy;
66. governing link supersession preserva histórico;
67. profile posterior não vira governing retroativo;
68. recommendation divergence permitida;
69. divergence não altera policy automaticamente.

## 58. Priority/SLA integration

70. legacy snapshot-only permanece válido;
71. novo PriorityAssessment sem profile FK rejeitado;
72. profile FK + canonical snapshot exatamente coerentes;
73. drift entre FK e snapshot rejeitado;
74. authoritative scientific priority exige authoritative profile;
75. PriorityBasis risk_profile locator XOR;
76. SLA snapshot congela profile UUID;
77. profile posterior não recalcula SLA Instance.

## 59. Invariantes e regressões

78. profile não altera CurrencyState;
79. profile não altera Assurance;
80. profile não cria UpdatePolicy;
81. profile não cria UpdateSignal;
82. profile não cria Alert;
83. M3 blocker preservado;
84. migration idempotency;
85. rebuild;
86. regressões F4-UP/F4-OC/F2-B/S4/S5/F3/Monitor/Alert.

---

# PARTE N — STATUS

## 60. Estado

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = CANDIDATE**

> **MIGRATION_030 = NOT_AUTHORIZED**

> **RISK_SCORE = NOT_DEFINED**

> **NUMERIC_CADENCE = NOT_DEFINED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 61. Próximo passo

> **Executar gate adversarial do contrato físico candidato antes de qualquer migration 030.**


---

## 62. Correções decorrentes do Documento 31

Foram incorporadas:

1. provenance dimensional normalizada em `update_risk_profile_dimension_basis`;
2. locator XOR + FKs reais para fontes OES;
3. profile header authoritative restrito a human_reviewer/human_expert;
4. B5 authoritative preservada como owner-only;
5. trigger source_type/locator XOR;
6. policy basis com UUID próprio + supersession;
7. proposal incompleto explicitamente permitido;
8. legacy snapshot-only grandfathered;
9. novos PriorityAssessment passam a exigir profile FK após migration;
10. snapshot novo deve ser exatamente o serializer canônico;
11. carry-forward temporal/source reforçado.

Estado:

> **READY_FOR_DOCUMENT_31_RECHECK**

> **MIGRATION_030 = NOT_AUTHORIZED_UNTIL_RECHECK**
