# 07 — Protocolo Transversal de Atualização: Contrato de Dados v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **DATA CONTRACT CANDIDATE — requer gate de coerência física antes de migration**  
**Dependências:** Documentos 05–06; OES-P1; migrations 006, 021–026  
**Migration candidata:** `database/027_transversal_update_protocol_contract.sql` — **NÃO AUTORIZADA neste documento**

---

## 1. Finalidade

Transformar a baseline conceitual aprovada nos Documentos 05–06 em um contrato físico mínimo, aditivo e auditável para a Fase 4.

O contrato cobre quatro unidades nucleares:

1. policy/version de manutenção;
2. update signal;
3. materiality assessment;
4. update decision.

O objetivo é criar uma base capaz de sustentar, posteriormente:

- thresholds;
- SLAs;
- priorização;
- propagação;
- M3;
- automação controlada;

sem antecipar esses mecanismos nem criar conclusões científicas automáticas.

---

## 2. Decisões arquiteturais de entrada

### 2.1 Nenhuma nova entidade científica

O contrato v0.1 não cria novo tipo em `core.entity`.

Policy, signal, materiality assessment e update decision são:

> **registros operacionais/metodológicos especializados da camada `maintenance`**.

Quando houver mudança científica real:

- ProductVersion continua sendo versionada via `core.entity_version`;
- InvestigationVersion continua sendo versionada via `core.entity_version`;
- QuestionVersion continua sendo versionada apenas quando a pergunta/escopo mudar.

### 2.2 Append-preserving

Policy revisions, materiality assessments e update decisions deverão preservar histórico por supersessão.

Signals são eventos detectados. Conteúdo material de um signal não poderá ser reescrito; correção exige novo signal ou invalidation explícita.

### 2.3 Currentness não será duplicado

O contrato não cria tabela paralela de atualidade.

Para ProductVersion:

> usar exclusivamente `product.currency_state`.

Para InvestigationVersion:

> não criar CurrencyState artificial.

### 2.4 MethodDecision

Não existe, no baseline físico atual, tabela genérica `MethodDecision`.

Portanto:

- o contrato não dependerá de entidade física inexistente;
- `maintenance.update_decision` será a decisão especializada deste protocolo;
- eventual registro metodológico genérico futuro poderá referenciar ou projetar essas decisões, mas não é requisito do v0.1.

### 2.5 Monitor e Alert não serão duplicados

O contrato reutiliza:

- `maintenance.monitor_cycle`;
- `maintenance.candidate_assessment`;
- `maintenance.evidence_event`;
- `maintenance.evidence_alert`;
- `product.currency_state`;
- `provenance.record`;
- `provenance.dependency_edge`.

---

## 3. Visão do fluxo físico

```text
Target version
   ↓
UpdatePolicy
   ↓
UpdateSignal
   ↓
MaterialityAssessment
   ↓
UpdateDecision
   ├─→ eventual CurrencyState (ProductVersion only)
   ├─→ eventual workflow científico
   └─→ eventual nova ProductVersion / InvestigationVersion
```

Regra:

> o contrato registra decisão e causalidade; não executa automaticamente atualização científica.

---

# 4. Estrutura 1 — `maintenance.update_policy`

Representa a política transversal vigente para um target versionado.

DDL lógico:

```sql
CREATE TABLE maintenance.update_policy (
    update_policy_uuid uuid PRIMARY KEY,

    target_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),

    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),

    effective_maintenance_level text NOT NULL CHECK (
        effective_maintenance_level IN ('M0','M1','M2','M3')
    ),

    cadence_mode text NOT NULL CHECK (
        cadence_mode IN (
            'none',
            'event_driven',
            'periodic',
            'hybrid',
            'continuous'
        )
    ),

    cadence_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    trigger_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    materiality_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    escalation_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    governance_policy_payload jsonb NOT NULL DEFAULT '{}'::jsonb,

    governing_monitor_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),

    effective_at timestamptz NOT NULL,
    rationale text NOT NULL,

    created_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'system',
            'ai_system',
            'human_reviewer',
            'human_expert',
            'owner'
        )
    ),

    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),

    supersedes_update_policy_uuid uuid
        REFERENCES maintenance.update_policy(update_policy_uuid),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CHECK (
        num_nonnulls(
            target_product_version_uuid,
            target_investigation_version_uuid
        )=1
    ),

    CHECK (jsonb_typeof(cadence_policy_payload)='object'),
    CHECK (jsonb_typeof(trigger_policy_payload)='object'),
    CHECK (jsonb_typeof(materiality_policy_payload)='object'),
    CHECK (jsonb_typeof(escalation_policy_payload)='object'),
    CHECK (jsonb_typeof(governance_policy_payload)='object'),

    CHECK (
        supersedes_update_policy_uuid IS NULL
        OR supersedes_update_policy_uuid<>update_policy_uuid
    )
);
```

---

## 5. Semântica de `effective_maintenance_level`

Esse campo representa:

> **regime operacional efetivo de manutenção do target versionado no período da policy**.

Ele não reescreve retroativamente:

`investigation.investigation_version.maintenance_level`.

A coluna já existente na InvestigationVersion permanece:

> valor de roteamento/manutenção registrado naquela versão da investigação.

Essa distinção é necessária porque transições M0–M3 podem ocorrer sem mudança científica da ProductVersion.

Portanto:

- InvestigationVersion preserva a decisão histórica de roteamento;
- UpdatePolicy registra o regime operacional efetivo posterior;
- nenhuma das duas será silenciosamente sobrescrita.

---

## 6. Unicidade de policy ativa

Exigir:

```sql
CREATE UNIQUE INDEX ux_update_policy_active_product
ON maintenance.update_policy(target_product_version_uuid)
WHERE record_status='active'
  AND target_product_version_uuid IS NOT NULL;
```

e equivalente para InvestigationVersion.

Resultado:

> exatamente zero ou uma policy ativa por target version.

Zero é permitido para conteúdo histórico ainda não incorporado ao protocolo da Fase 4.

---

## 7. Supersessão de policy

`supersedes_update_policy_uuid` deverá apontar para policy do mesmo target versionado.

A nova policy:

- deve possuir `effective_at >= prior.effective_at`;
- torna a anterior `record_status='superseded'`;
- preserva a anterior integralmente.

Mudança de target version não é supersessão da mesma policy.

Quando o target científico for versionado:

> criar nova policy para a nova versão, com eventual linkage de derivação a ser definido no bloco de propagação/re-baselining.

Não antecipar esse linkage no v0.1.

---

## 8. Policy × Monitor

`governing_monitor_product_version_uuid` é opcional.

Quando presente:

1. deve ser ProductVersion com `product_type='evidence_monitor'`;
2. deve possuir exatamente um `maintenance.monitor_target`;
3. o target do Monitor deve corresponder exatamente ao target da UpdatePolicy;
4. o Monitor não pode estar invalidated/archived;
5. a policy não altera o MonitorDefinition existente.

Regras por regime:

- M0 → governing Monitor deve ser NULL;
- M1 → governing Monitor normalmente NULL;
- M2 → policy formal ativa deve possuir governing Monitor;
- M3 → governing Monitor obrigatório, mas isso **não torna M3 formalmente operacional**.

---

## 9. Cadence mode

### none

Adequado a M0.

### event_driven

Adequado a M1 ou políticas acionadas por evento.

### periodic

Adequado a M1/M2.

### hybrid

Combina periodicidade e gatilhos por evento.

### continuous

Reservado a M3.

Compatibilidade mínima:

| M | cadence_mode permitido |
|---|---|
| M0 | none |
| M1 | event_driven, periodic, hybrid |
| M2 | periodic, hybrid |
| M3 | continuous, hybrid |

Valores temporais concretos ficam em `cadence_policy_payload`, mas o v0.1:

- não define defaults universais;
- não define SLA;
- não transforma idade em obsolescência;
- não torna M3 operacional.

---

# 10. Estrutura 2 — `maintenance.update_signal`

Representa um signal detectado sob determinada policy.

DDL lógico:

```sql
CREATE TABLE maintenance.update_signal (
    update_signal_uuid uuid PRIMARY KEY,

    update_policy_uuid uuid NOT NULL
        REFERENCES maintenance.update_policy(update_policy_uuid),

    signal_class text NOT NULL CHECK (
        signal_class IN (
            'scientific_currentness',
            'operational'
        )
    ),

    trigger_class text NOT NULL CHECK (
        trigger_class IN (
            'new_evidence',
            'integrity_validity',
            'safety_regulatory',
            'temporal_operational',
            'governance_demand',
            'methodological',
            'scope'
        )
    ),

    signal_type text NOT NULL,

    signal_date date,
    detected_at timestamptz NOT NULL,

    summary text NOT NULL,
    rationale text,

    detected_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'system',
            'ai_system',
            'human_reviewer',
            'human_expert',
            'owner'
        )
    ),

    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified',
            'ai_verified',
            'human_verified',
            'human_consensus'
        )
    ),

    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN (
            'ai_system',
            'human_reviewer',
            'human_expert'
        )
    ),

    verified_at timestamptz,

    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','invalidated')
    ),

    invalidated_at timestamptz,
    invalidation_reason text,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 11. Vocabulário inicial de `signal_type`

O campo será texto controlado por check no contrato inicial, com pelo menos:

- new_study;
- new_review;
- review_update;
- estimate_change_signal;
- safety_signal;
- new_population_signal;
- certainty_change_signal;
- correction;
- retraction;
- expression_of_concern;
- methodology_change;
- regulatory_change;
- cadence_due;
- cycle_incomplete;
- source_coverage_gap;
- future_sla_breach;
- explicit_reassessment_request;
- use_context_change;
- scope_change;
- other.

Mapeamentos inválidos serão rejeitados.

Exemplos:

- `cadence_due` deve ser operational + temporal_operational;
- `retraction` deve ser scientific_currentness + integrity_validity;
- `safety_signal` deve ser scientific_currentness + safety_regulatory.

---

# 12. Estrutura 3 — `maintenance.update_signal_source`

Signal pode ter múltiplas fontes.

DDL lógico:

```sql
CREATE TABLE maintenance.update_signal_source (
    update_signal_source_uuid uuid PRIMARY KEY,

    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),

    source_role text NOT NULL CHECK (
        source_role IN ('primary','supporting')
    ),

    source_type text NOT NULL CHECK (
        source_type IN (
            'monitor_cycle',
            'candidate_assessment',
            'evidence_event',
            'alert_product_version',
            'search_hit',
            'entity_version',
            'artifact',
            'uri'
        )
    ),

    monitor_cycle_uuid uuid
        REFERENCES maintenance.monitor_cycle(cycle_uuid),

    candidate_assessment_uuid uuid
        REFERENCES maintenance.candidate_assessment(candidate_assessment_uuid),

    evidence_event_uuid uuid
        REFERENCES maintenance.evidence_event(evidence_event_uuid),

    alert_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),

    search_hit_uuid uuid
        REFERENCES investigation.search_hit(search_hit_uuid),

    source_entity_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),

    source_artifact_uuid uuid
        REFERENCES artifact.artifact(artifact_uuid),

    source_uri text,

    note text,
    sequence_no integer,

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

Regra:

> exatamente um locator deve estar preenchido e deve corresponder a `source_type`.

Permitir múltiplas supporting sources.

No máximo uma primary source por signal.

Signals `governance_demand` podem existir sem source externa, desde que rationale e actor estejam explícitos.

---

## 13. Signal × Monitor

Quando source_type for:

- monitor_cycle;
- candidate_assessment;
- evidence_event;
- search_hit;

o guard deverá verificar que a origem pertence ao mesmo Monitor que governa a policy, quando `governing_monitor_product_version_uuid` estiver definido.

Isso impede apropriação silenciosa de eventos de outro Monitor.

---

## 14. Signal × Alert

Alert pode originar signal transversal.

Regras:

- Alert ProductVersion precisa ter `product_type='evidence_alert'`;
- target do Alert deve corresponder ao target da UpdatePolicy;
- Alert lifecycle/classification não determina materiality outcome;
- Alert critical não produz outdated automaticamente.

---

## 15. Imutabilidade de signal

Após INSERT, campos materiais do signal são imutáveis.

Permitido:

- `active → invalidated`;
- preencher `invalidated_at` e `invalidation_reason`.

Não permitir:

- editar signal_class;
- editar trigger_class;
- editar signal_type;
- trocar policy;
- trocar data;
- trocar ator;
- trocar verification status retrospectivamente.

Correção material:

> criar novo signal e registrar a relação causal na documentação/provenance aplicável.

---

# 16. Estrutura 4 — `maintenance.materiality_assessment`

Representa avaliação transversal da materialidade de um signal.

DDL lógico:

```sql
CREATE TABLE maintenance.materiality_assessment (
    materiality_assessment_uuid uuid PRIMARY KEY,

    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),

    outcome text NOT NULL CHECK (
        outcome IN (
            'no_material_change',
            'potentially_material',
            'material_change_confirmed',
            'validity_or_use_threat',
            'insufficient_to_decide'
        )
    ),

    rationale text NOT NULL,

    assessed_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'ai_system',
            'human_reviewer',
            'human_expert',
            'owner'
        )
    ),

    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified',
            'ai_verified',
            'human_verified',
            'human_consensus'
        )
    ),

    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN (
            'ai_system',
            'human_reviewer',
            'human_expert'
        )
    ),

    verified_at timestamptz,

    assessed_at timestamptz NOT NULL,

    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),

    supersedes_materiality_assessment_uuid uuid
        REFERENCES maintenance.materiality_assessment(
            materiality_assessment_uuid
        ),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 17. Unicidade e supersessão da materialidade

Exigir:

> no máximo um assessment ativo por UpdateSignal.

Supersessão:

- precisa preservar o mesmo `update_signal_uuid`;
- assessment anterior torna-se superseded;
- novo assessment possui timestamp igual ou posterior;
- conteúdo anterior permanece imutável.

---

# 18. Estrutura 5 — `maintenance.materiality_dimension`

Normaliza dimensões afetadas.

DDL lógico:

```sql
CREATE TABLE maintenance.materiality_dimension (
    materiality_assessment_uuid uuid NOT NULL
        REFERENCES maintenance.materiality_assessment(
            materiality_assessment_uuid
        ),

    dimension_code text NOT NULL CHECK (
        dimension_code IN (
            'benefit',
            'harm',
            'magnitude',
            'precision',
            'certainty',
            'applicability',
            'conclusion',
            'regulatory_status',
            'validity',
            'scope',
            'method',
            'other'
        )
    ),

    dimension_status text NOT NULL CHECK (
        dimension_status IN (
            'potential',
            'confirmed',
            'threat',
            'uncertain'
        )
    ),

    rationale text,
    sequence_no integer,

    PRIMARY KEY (
        materiality_assessment_uuid,
        dimension_code
    )
);
```

Regras:

- `material_change_confirmed` exige pelo menos uma dimensão `confirmed`;
- `validity_or_use_threat` exige pelo menos uma dimensão `threat`;
- `potentially_material` exige pelo menos uma dimensão `potential|uncertain`;
- `no_material_change` não pode possuir `confirmed` ou `threat`.

---

# 19. Estrutura 6 — `maintenance.update_decision`

Registra a decisão derivada de assessment.

DDL lógico:

```sql
CREATE TABLE maintenance.update_decision (
    update_decision_uuid uuid PRIMARY KEY,

    materiality_assessment_uuid uuid NOT NULL
        REFERENCES maintenance.materiality_assessment(
            materiality_assessment_uuid
        ),

    decision_type text NOT NULL CHECK (
        decision_type IN (
            'no_scientific_update',
            'observe',
            'currentness_only',
            'scientific_update_incremental',
            'scientific_update_broad',
            'reroute_method',
            'suspend_current_use'
        )
    ),

    authority_status text NOT NULL CHECK (
        authority_status IN (
            'proposal',
            'authoritative'
        )
    ),

    currency_action text NOT NULL DEFAULT 'no_change' CHECK (
        currency_action IN (
            'no_change',
            'set_current',
            'set_under_evaluation',
            'set_update_recommended',
            'set_outdated',
            'set_archived'
        )
    ),

    rationale text NOT NULL,

    decided_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'ai_system',
            'human_reviewer',
            'human_expert',
            'owner'
        )
    ),

    verification_status text NOT NULL CHECK (
        verification_status IN (
            'unverified',
            'ai_verified',
            'human_verified',
            'human_consensus'
        )
    ),

    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN (
            'ai_system',
            'human_reviewer',
            'human_expert'
        )
    ),

    verified_at timestamptz,

    decided_at timestamptz NOT NULL,

    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),

    supersedes_update_decision_uuid uuid
        REFERENCES maintenance.update_decision(update_decision_uuid),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 20. Proposta × decisão autoritativa

### proposal

Pode ser criada por:

- ai_system;
- human_reviewer;
- human_expert;
- owner.

Não produz efeito autoritativo por si só.

### authoritative

Não pode ser criada por `ai_system`.

Deve possuir:

- `verification_status IN ('human_verified','human_consensus')`;
- verifier humano explícito;
- rationale não vazio.

Regra adicional:

> owner pode registrar decisão de governança, mas decisão científica material autoritativa deverá possuir verificação por human_reviewer ou human_expert.

Esse contrato não declara automaticamente que qualquer humano é especialista.

---

## 21. Coerência decision × materiality

Mapeamento mínimo:

### no_scientific_update

Compatível com:

- no_material_change;
- insufficient_to_decide, apenas quando a rationale justificar observação sem atualização imediata.

Não pode usar `currency_action=set_outdated`.

### observe

Compatível com:

- potentially_material;
- insufficient_to_decide;
- validity_or_use_threat em situação ainda sob avaliação.

Pode usar:

- no_change;
- set_under_evaluation.

### currentness_only

Não inicia nova versão científica.

Pode aplicar:

- set_current;
- set_under_evaluation;
- set_update_recommended;
- set_outdated;
- set_archived.

Somente para ProductVersion target.

### scientific_update_incremental

Compatível com:

- potentially_material;
- material_change_confirmed;
- validity_or_use_threat.

Pode aplicar:

- set_under_evaluation;
- set_update_recommended;
- set_outdated;
- no_change, quando atualização for preventiva.

### scientific_update_broad

Mesmas regras de autoridade, com rationale explícita sobre por que atualização ampla é necessária.

### reroute_method

Aplicável quando:

- scope;
- method;
- criticidade;
- pergunta;

exigem reroteamento.

### suspend_current_use

Exige decisão autoritativa.

Para ProductVersion:

> deve resultar em `currency_action=set_outdated` ou `set_archived`, conforme o caso.

Para InvestigationVersion:

> não cria CurrencyState; registra suspensão/decisão operacional e eventual reroteamento.

---

# 22. Estrutura 7 — `maintenance.update_decision_currency_state`

Liga decisão autoritativa aplicada ao CurrencyState resultante.

DDL lógico:

```sql
CREATE TABLE maintenance.update_decision_currency_state (
    update_decision_uuid uuid PRIMARY KEY
        REFERENCES maintenance.update_decision(update_decision_uuid),

    currency_state_uuid uuid NOT NULL UNIQUE
        REFERENCES product.currency_state(currency_state_uuid),

    linked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

Regras:

1. UpdateDecision deve estar `authority_status='authoritative'`;
2. target da policy deve ser ProductVersion;
3. CurrencyState deve pertencer exatamente ao target ProductVersion;
4. CurrencyState deve ser active no momento do linkage;
5. `currency_status` deve corresponder a `currency_action`;
6. `currency_action='no_change'` não pode possuir linkage.

Mapeamento:

| currency_action | CurrencyState |
|---|---|
| set_current | current |
| set_under_evaluation | under_evaluation |
| set_update_recommended | update_recommended |
| set_outdated | outdated |
| set_archived | archived |

---

## 23. Relação com CurrencyState produzido por Monitor Cycle

Pode ocorrer que um Monitor Cycle já tenha criado CurrencyState via:

`maintenance.cycle_currency_state`.

Nesse caso:

- a UpdateDecision pode referenciar o mesmo CurrencyState somente se a decisão representar formalização do mesmo assessment;
- não criar CurrencyState duplicado;
- deve ser possível reconstruir:
  `cycle → signal → materiality → decision → currency state`.

Não será permitido:

> cycle produzir um estado e update decision contraditório apontar para o mesmo CurrencyState.

---

## 24. Relação com atualização científica futura

Uma decisão:

- scientific_update_incremental;
- scientific_update_broad;
- reroute_method;

**não cria** nova ProductVersion ou InvestigationVersion.

Ela apenas autoriza/ordena a abertura de workflow apropriado.

O linkage da decisão para versão científica futura será objeto de bloco posterior, provavelmente por:

- provenance.record com `process_type='transversal_update_decision'` e `process_record_uuid=update_decision_uuid`;
- dependency edge derivado quando aplicável;
- estrutura especializada de resolution caso a revisão adversarial posterior demonstre necessidade.

Não antecipar tabela de “resulting version” neste v0.1.

---

## 25. Provenance

### 25.1 Process provenance

Quando uma nova EntityVersion for criada por atualização:

`provenance.record.process_record_uuid`

poderá apontar para:

- UpdateDecision;
- MaterialityAssessment;
- Monitoring Cycle;

conforme a cadeia causal.

### 25.2 Dependency edge

`provenance.dependency_edge` continua sendo projeção auxiliar entre EntityVersions.

Não usar dependency_edge para:

- UpdatePolicy;
- UpdateSignal;
- MaterialityAssessment;
- UpdateDecision;
- CurrencyState;

porque esses objetos não são EntityVersions.

---

## 26. Verification invariants

Para signal, assessment e decision:

### unverified

- verified_by NULL;
- verifier_actor_type NULL;
- verified_at NULL.

### ai_verified

- verifier_actor_type='ai_system';
- verified_by NOT NULL;
- verified_at NOT NULL.

### human_verified / human_consensus

- verifier_actor_type IN ('human_reviewer','human_expert');
- verified_by NOT NULL;
- verified_at NOT NULL.

IA nunca poderá preencher estado humano.

---

## 27. Actor semantics

Domínios têm finalidade distinta:

- `system` — evento mecânico sem julgamento;
- `ai_system` — classificação/sugestão assistida por IA;
- `human_reviewer` — revisão humana metodológica/científica não necessariamente especializada;
- `human_expert` — revisão humana especializada;
- `owner` — decisão de governança/propriedade.

Não inferir expertise apenas da presença de humano.

---

## 28. M3

O contrato v0.1 permite policy com:

`effective_maintenance_level='M3'`.

Entretanto:

> **M3 permanece não operacional para publicação formal.**

Migration candidata 027, se autorizada, não deverá remover:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

Não haverá neste bloco:

- m3_ready boolean;
- global living flag;
- auto-unblock;
- threshold de frequência;
- SLA M3.

O desbloqueio exige contrato posterior específico de M3 readiness.

---

## 29. Não escopo do contrato v0.1

Não implementar ainda:

- threshold quantitativo;
- score;
- SLA duration;
- scheduler;
- notification channel;
- auto-classification;
- auto-escalation;
- global priority queue;
- propagation table;
- Monitor re-baselining;
- M3 readiness gate físico;
- automatic publication;
- resulting-version linkage especializado.

---

## 30. Guards candidatos da futura migration

A migration candidata deverá implementar pelo menos:

- `maintenance.assert_update_policy_consistency()`;
- `maintenance.guard_update_policy_mutation()`;
- `maintenance.assert_update_signal_consistency()`;
- `maintenance.guard_update_signal_mutation()`;
- `maintenance.assert_update_signal_source_consistency()`;
- `maintenance.guard_update_signal_source_mutation()`;
- `maintenance.assert_materiality_assessment_consistency()`;
- `maintenance.guard_materiality_assessment_mutation()`;
- `maintenance.assert_materiality_dimension_consistency()`;
- `maintenance.guard_materiality_dimension_mutation()`;
- `maintenance.assert_update_decision_consistency()`;
- `maintenance.guard_update_decision_mutation()`;
- `maintenance.assert_update_decision_currency_state_consistency()`;
- `maintenance.guard_update_decision_currency_state_mutation()`.

---

## 31. Testes mínimos esperados

A futura bateria F4-UP deverá cobrir, no mínimo:

1. target XOR de policy;
2. uma policy ativa por ProductVersion;
3. uma policy ativa por InvestigationVersion;
4. supersessão preserva target;
5. M0 × cadence;
6. M1 × cadence;
7. M2 exige Monitor em policy formal;
8. M3 exige Monitor mas permanece bloqueado formalmente;
9. Monitor da policy aponta para mesmo target;
10. signal exige policy;
11. signal_type × class × trigger coerentes;
12. signal verification invariants;
13. signal material imutável;
14. source locator XOR;
15. no máximo uma primary source;
16. source Monitor pertencente ao Monitor governante;
17. Alert source target compatível;
18. um assessment ativo por signal;
19. assessment supersession preserva signal;
20. materiality outcome × dimensions coerente;
21. proposal por AI permitida;
22. authoritative por AI rejeitada;
23. authoritative sem human verification rejeitada;
24. decision × materiality coerente;
25. Investigation target com currency action rejeitado;
26. Product target currency linkage coerente;
27. wrong-target CurrencyState rejeitado;
28. currency action/status mismatch rejeitado;
29. no_change com CurrencyState rejeitado;
30. cycle CurrencyState pode ser reutilizado quando coerente;
31. contradição cycle/decision rejeitada;
32. nenhuma decisão cria ProductVersion automaticamente;
33. nenhuma decisão cria InvestigationVersion automaticamente;
34. nenhum registro promove assurance;
35. M3 blocker existente continua ativo;
36. migrations 021–026 permanecem idempotentes;
37. futura migration candidata é idempotente quando desenhada para tal;
38. rebuild-from-zero through migration candidata;
39. regressões globais F2-B/S4/S5;
40. regressões completas de Monitor e Alert.

---

## 32. Gate obrigatório antes de migration

Antes de autorizar `database/027_transversal_update_protocol_contract.sql`, executar revisão adversarial física cobrindo:

- conflito com `investigation_version.maintenance_level`;
- unicidade de policy;
- lifecycle/supersession;
- policy × Monitor target;
- signal source normalization;
- duplicação com CandidateAssessment/EvidenceEvent/Alert;
- materiality semantics;
- AI proposal × authoritative decision;
- CurrencyState linkage;
- provenance;
- M3 blocker;
- rebuild order;
- compatibilidade com migrations 021–026.

Resultados permitidos:

- PASS;
- PASS_WITH_ARCHITECTURAL_DECISIONS;
- REVISE;
- NOT_READY.

---

## 33. Próximo passo exato

> **Executar a revisão adversarial física do Documento 07. Somente em PASS ou PASS_WITH_ARCHITECTURAL_DECISIONS poderá ser autorizada a migration candidata 027.**
