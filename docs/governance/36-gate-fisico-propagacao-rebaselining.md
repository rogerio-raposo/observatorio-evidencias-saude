# 36 — Gate Adversarial/Físico do Contrato de Propagation/Re-baselining

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — primeira passagem física**  
**Dependências:** Documento 35; Documentos 33–34; migrations 021–030  
**Objeto:** testar implementabilidade, integridade, lifecycle e compatibilidade do contrato físico candidato antes de migration

---

## 1. Finalidade

Atacar o Documento 35 contra o schema vigente e impedir que migration 031 seja autorizada com:

- classificação incompatível com UpdatePolicy;
- JSON usado onde FK/lineage normalizada é necessária;
- lifecycle ambíguo;
- handover que reinterprete história;
- adapters incompletos;
- grandfathering não operacionalizável;
- thresholds técnicos arbitrários;
- M3 unblock implícito.

---

## 2. Resultado da primeira passagem

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = REVISE**

> **MIGRATION_031 = NOT_AUTHORIZED**

A decomposição geral em PropagationAssessment/Candidate/Path e RebaselineDecision + child records é adequada.

Os blockers abaixo devem ser corrigidos antes de novo gate.

---

## 3. AR-F4-PRB01 — maintainable_product está amplo demais

### Achado

Documento 35 classifica qualquer ProductVersion como `maintainable_product`.

Porém `maintenance.update_policy_issues()` e o contrato da migration 027 proíbem UpdatePolicy sobre:

- `product_type='evidence_monitor'`;
- `product_type='evidence_alert'`.

### Decisão

`maintainable_product` deve exigir ProductVersion cujo `product_type` seja elegível a UpdatePolicy.

Adicionar categoria física:

> `nonmaintainable_version`

para:

- Evidence Monitor ProductVersion;
- Evidence Alert ProductVersion;
- evidence_monitoring InvestigationVersion;
- outros versioned objects sem UpdatePolicy própria.

`intermediate_dependency_object` pode ser substituído por `nonmaintainable_version` para evitar fingir que Monitor/Alert são apenas objetos intermediários.

### Resultado

**REVISE_REQUIRED**

---

## 4. AR-F4-PRB02 — max_depth <= 64 é threshold arbitrário

### Achado

O contrato candidata limite máximo universal 64 sem fundamento canônico.

A PoC histórica usa 32 em função específica, mas isso não torna 32 ou 64 regra transversal.

### Decisão

Persistir:

- `max_depth integer > 0`;
- sem default universal;
- sem teto normativo no contrato.

A execução poderá ter resource guard técnico, mas o valor usado deve ser explícito no assessment e auditável.

### Resultado

**REVISE_REQUIRED**

---

## 5. AR-F4-PRB03 — no_action depende do path, não só do header

### Achado

O Documento 35 bloqueia `no_action_supported` quando lineage_validation_status do assessment não é validated.

Mas um candidate específico pode ter:

- path cycle_detected;
- depth_limit_reached;
- incomplete_unknown;

mesmo que outras partes do assessment tenham sido validadas.

### Decisão

Authoritative `no_action_supported` exige cumulativamente:

1. assessment lineage = validated_against_canonical_relations;
2. pelo menos um path completo quando o candidate é derivado de dependency traversal;
3. nenhum path relevante do candidate em unresolved cycle/depth/divergence state;
4. rationale;
5. authority qualificada quando aplicável.

### Resultado

**REVISE_REQUIRED**

---

## 6. AR-F4-PRB04 — version_chain_payload não pode ser a única estrutura de chain

### Achado

A cadeia old→new é central para rebaseline.

Guardar UUIDs apenas em JSON:

- perde FKs;
- enfraquece validação;
- dificulta query/auditoria;
- permite UUID inexistente dentro do payload.

### Decisão

Criar:

> `maintenance.rebaseline_version_chain_step`

com:

- rebaseline_decision_uuid;
- step_no;
- from_version_uuid;
- to_version_uuid;
- expected_supersedes_version_uuid/relationship semantics;
- PK decision+step.

O JSON pode existir apenas como snapshot/serializer derivado, não como fonte física primária.

### Resultado

**REVISE_REQUIRED**

---

## 7. AR-F4-PRB05 — lifecycle do RebaselineDecision está incompleto

### Achado

planned → activated no desenho append-preserving exige nova row, mas o Documento 35 não fecha o guard de supersession.

Sem isso, nova decision poderia mudar old/new target silenciosamente.

### Decisão

Supersession exige:

- mesmo old target;
- mesmo new target;
- mesma target family;
- temporalidade monotônica.

Transições de stage:

- planned → activated;
- planned → cancelled_invalidated;
- activated → activated apenas para correção history-preserving que não altera target pair nem activation fact;
- cancelled_invalidated é terminal.

Mudança de new target exige nova lineage causal, não supersession fingindo mesma decisão.

### Resultado

**REVISE_REQUIRED**

---

## 8. AR-F4-PRB06 — concorrência de activation authoritative

### Achado

Múltiplas propostas podem coexistir, mas duas decisões authoritative activated para o mesmo old target criariam dois handovers correntes.

### Decisão

Adicionar partial uniqueness separada para ProductVersion e InvestigationVersion:

> no máximo um `record_status='active' AND decision_stage='activated' AND authority_status='authoritative'` por old target.

Proposals/planned concorrentes continuam permitidos.

### Resultado

**REVISE_REQUIRED**

---

## 9. AR-F4-PRB07 — policy handover precisa de lifecycle state

### Achado

`replace_with_new_policy` verifica FKs/targets, mas não exige que a new policy esteja active na activation.

### Decisão

Para activated rebaseline:

- `replace_with_new_policy` exige new policy `record_status='active'`;
- old policy pode estar active ou superseded, mas nunca pode ter target diferente do old target;
- `maintenance_policy_required` e `pending` bloqueiam activation;
- `stop_maintenance` pode ativar sem new policy;
- `not_applicable` somente quando manutenção realmente não se aplica ao target/fase documentada.

### Resultado

**REVISE_REQUIRED**

---

## 10. AR-F4-PRB08 — profile readiness não é universal

### Achado

Migration 030 exige physical profile para novas PriorityAssessments, não para toda UpdatePolicy.

Logo, activation de rebaseline não deve falhar universalmente pela ausência de target profile.

### Decisão

Refinar dispositions:

- `target_profile_available`;
- `carry_forward_authorized`;
- `new_assessment_required`;
- `target_reassessment_required`;
- `not_applicable`;
- `pending`.

Activation:

- `pending` bloqueia;
- ausência de target profile é warning/readiness gap, salvo quando existe operação que já exige profile (por exemplo nova PriorityAssessment);
- qualquer nova PriorityAssessment continua bloqueada pelo guard da migration 030.

### Resultado

**REVISE_REQUIRED**

---

## 11. AR-F4-PRB09 — coverage cutoff precisa de regra mais forte

### Achado

`incorporated_through_new_target_cutoff` com `window_end_date <= cutoff` poderia afirmar “through cutoff” terminando antes do cutoff.

### Decisão

Quando esse code tiver janela:

> `window_end_date = new target evidence_cutoff_date`.

Se não houver semântica de janela, payload/rationale deve explicar o basis.

`post_cutoff_pending_assessment` deve começar estritamente após cutoff.

### Resultado

**REVISE_REQUIRED**

---

## 12. AR-F4-PRB10 — target superseded não invalida UpdateSignal

### Achado

`invalidate_as_target_superseded` mistura lifecycle do signal com lifecycle do target.

UpdateSignal status `invalidated` significa que o signal em si foi invalidado; target supersession não prova isso.

### Decisão

Remover `invalidate_as_target_superseded`.

Substituir por:

- `retain_historical_no_transfer`;
- `resolve_on_old_target`;
- `continue_old_target_workflow`;
- `create_new_signal_on_new_target`;
- `governance_review_required`.

Rebaseline disposition é overlay auditável e não precisa alterar `update_signal.status`.

Signal só é invalidated quando o próprio signal for inválido, pela regra já vigente.

### Resultado

**REVISE_REQUIRED**

---

## 13. AR-F4-PRB11 — UpdateSignalSource exige hardening completo

### Achado

Adicionar apenas column/source_type quebra o helper da migration 028, cujo locator_count e matrix conhecem somente os locators antigos.

### Decisão

Migration 031, se autorizada, deve atualizar em conjunto:

1. CHECK/source_type domain;
2. locator XOR;
3. `assert_update_signal_source_consistency()`;
4. `update_signal_issues()`;
5. testes positivos/negativos;
6. idempotência.

### Resultado

**REVISE_REQUIRED**

---

## 14. AR-F4-PRB12 — grandfathering precisa de epoch física

### Achado

Documento 35 exige distinguir ausência legacy de ausência pós-migration, mas não define como.

Inferir pelo primeiro row novo ou por timestamp hardcoded é frágil.

### Decisão

Criar metadata técnica:

> `maintenance.contract_epoch`

se ainda não existir mecanismo equivalente.

Campos mínimos:

- contract_code PK;
- schema_version;
- effective_at;
- migration_id;
- created_at.

Migration 031 poderá inserir idempotentemente:

- contract_code = `PROPAGATION_REBASELINE_V01`;
- migration_id = `031`.

Isso é metadata técnica, não configuração normativa.

Issue helpers usam o epoch somente para distinguir obrigação prospectiva de história legacy.

### Resultado

**REVISE_REQUIRED**

---

## 15. AR-F4-PRB13 — transition basis result deve provar o new target

### Achado

O locator XOR não basta.

Se `transition_basis_type='result_product_version'`, o result precisa ser exatamente o new ProductVersion.

Idem InvestigationVersion.

### Decisão

Adicionar guards:

- result_product_version_uuid = new_target_product_version_uuid;
- result_investigation_version_uuid = new_target_investigation_version_uuid.

Se basis = workflow_round e o round declara result version, ela deve ser coerente com new target quando a claim for “workflow produced target”.

### Resultado

**REVISE_REQUIRED**

---

## 16. AR-F4-PRB14 — SLA cross-policy lineage

### Achado

O desenho é conceitualmente correto, mas precisa tornar explícito que existing `supersedes_sla_rule_uuid` já rejeita cross-policy.

### Decisão

No validator do rebaseline SLA link:

- confirmar old rule belongs old policy;
- confirmar new rule belongs new policy;
- confirmar `new_rule.supersedes_sla_rule_uuid IS DISTINCT FROM old_rule_uuid`;
- permitir mesma rule_code como lineage de negócio, sem usar a FK de supersession.

### Resultado

**PASS_WITH_REQUIRED_TEST**

---

## 17. AR-F4-PRB15 — child immutability × activation

### Achado

A estratégia de children imutáveis é consistente, desde que activation seja nova parent row com novo child set completo.

### Decisão

Explicitar:

- children nunca são “promovidos” de planned para activated in-place;
- activated decision deve possuir seu próprio conjunto de children;
- parent supersession estabelece lineage entre planned e activated;
- serializer/helper pode comparar conjuntos, mas não copiar silenciosamente.

### Resultado

**PASS_WITH_CLARIFICATION**

---

## 18. AR-F4-PRB16 — contract epoch não pode virar policy clock

### Achado

Metadata técnica de migration não deve ser usada como cadence, SLA ou scientific cutoff.

### Decisão

`contract_epoch.effective_at` serve exclusivamente a grandfathering técnico.

Proibir uso como:

- evidence cutoff;
- cadence anchor;
- SLA start;
- publication timestamp;
- rebaseline decision time.

### Resultado

**PASS_WITH_ARCHITECTURAL_DECISION**

---

## 19. AR-F4-PRB17 — M3

### Achado

O novo readiness helper poderia ser confundido com M3 readiness.

### Decisão

Todo activated M3 rebaseline continua apresentando blocker:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

Nenhuma migration 031 pode remover esse blocker.

### Resultado

**PASS**

---

## 20. Correções obrigatórias

Documento 35 deve incorporar:

1. `nonmaintainable_version`;
2. remoção do teto 64;
3. candidate-path completeness para no_action;
4. chain normalizada em tabela;
5. lifecycle/supersession fechado;
6. unique authoritative activation;
7. policy lifecycle readiness;
8. profile readiness condicional;
9. cutoff coverage exato;
10. remoção de signal invalidation por target superseded;
11. hardening completo do UpdateSignalSource helper;
12. `maintenance.contract_epoch`;
13. transition-basis equality;
14. SLA cross-policy guard/test;
15. explicit child-set replacement on parent supersession.

---

## 21. Estado

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = REVISE**

> **F4_PRB_T01_T128 = REQUIRES_UPDATE**

> **MIGRATION_031 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 22. Próximo passo exato

> **Corrigir o Documento 35 conforme AR-F4-PRB01–PRB17 e executar recheck físico; não escrever migration 031 antes de PASS/PASS_WITH_ARCHITECTURAL_DECISIONS.**
