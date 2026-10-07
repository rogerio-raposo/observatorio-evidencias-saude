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

## 5. Escopo de target da policy

No v0.1, UpdatePolicy transversal poderá ter como target:

- ProductVersion científica;
- InvestigationVersion científica.

Não poderá ter como target:

- ProductVersion `evidence_monitor`;
- ProductVersion `evidence_alert`;
- InvestigationVersion com `investigation_type='evidence_monitoring'`.

Motivo:

> Monitor possui seu próprio estado/plano/currency; Alert possui lifecycle próprio. Aplicar UpdatePolicy a esses objetos criaria recursão semântica e duplicação da camada de manutenção.

Na criação de uma policy ativa:

- target EntityVersion deve existir e estar `version_status='current'`;
- target ProductVersion não pode estar editorialmente `superseded` ou `archived`;
- target InvestigationVersion não pode estar invalidated/archived.

Se o target for supersedido depois:

> a policy histórica não muda de target; helper de issues deverá sinalizar `UPDATE_POLICY_TARGET_SUPERSEDED` e exigir nova policy para a nova versão quando a manutenção continuar.

## 6. Semântica de `effective_maintenance_level`

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

## 7. Unicidade de policy ativa

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

## 8. Supersessão de policy

`supersedes_update_policy_uuid` deverá apontar para policy do mesmo target versionado.

A nova policy:

- deve possuir `effective_at >= prior.effective_at`;
- torna a anterior `record_status='superseded'`;
- preserva a anterior integralmente.

Mudança de target version não é supersessão da mesma policy.

UpdatePolicy é configuração autoritativa do regime operacional. Por isso, no v0.1:

- `actor_type='system'` é proibido;
- `actor_type='ai_system'` é proibido;
- IA pode preparar draft fora deste registro, mas não ativar policy;
- ator humano/owner e rationale são obrigatórios.

Transições diretas permitidas por supersessão:

- mesmo M → mesmo M, para revisão de detalhes;
- M0 → M1 ou M2;
- M1 → M0 ou M2;
- M2 → M1 ou M3;
- M3 → M2, M1 ou M0.

M0 → M3, M1 → M3 e M2 → M0 exigem passagem por estado intermediário ou nova decisão de target/version, não supersessão direta.

Quando o target científico for versionado:

> criar nova policy para a nova versão, com eventual linkage de derivação a ser definido no bloco de propagação/re-baselining.

Não antecipar esse linkage no v0.1.

---

## 9. Policy × Monitor

`governing_monitor_product_version_uuid` é opcional.

Quando presente:

1. deve ser ProductVersion com `product_type='evidence_monitor'`;
2. deve possuir exatamente um `maintenance.monitor_target`;
3. o target do Monitor deve corresponder exatamente ao target da UpdatePolicy;
4. o Monitor não pode estar invalidated/archived;
5. a policy não altera o MonitorDefinition existente.

Regras por regime:

- M0 → governing Monitor deve ser NULL;
- M1 → governing Monitor deve ser NULL;
- M2 → policy ativa deve possuir governing Monitor;
- M3 → governing Monitor obrigatório, mas isso **não torna M3 formalmente operacional**.

Se uma policy M2 for reduzida para M1, a nova policy não reutiliza o Monitor como governante. O Monitor existente permanece historicamente preservado e seu estado operacional deve ser tratado separadamente.

---

## 10. Cadence mode

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

# 11. Estrutura 2 — `maintenance.update_signal`

Representa um signal detectado sob determinada policy.

No INSERT, a policy referenciada deve estar `record_status='active'`. Supersessão posterior da policy não invalida retrospectivamente o signal: o registro preserva qual regra estava vigente na detecção.

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

## 12. Vocabulário inicial de `signal_type`

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

# 13. Estrutura 3 — `maintenance.update_signal_source`

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

## 14. Signal × Monitor

Quando source_type for:

- monitor_cycle;
- candidate_assessment;
- evidence_event;
- search_hit;

o guard deverá verificar que a origem pertence ao mesmo Monitor que governa a policy, quando `governing_monitor_product_version_uuid` estiver definido.

Isso impede apropriação silenciosa de eventos de outro Monitor.

No v0.1, `source_type='search_hit'` só será permitido quando houver `governing_monitor_product_version_uuid` e o SearchHit pertencer a Search ligada a MonitoringCycle desse mesmo Monitor. Busca ad hoc fora de Monitor deverá originar signal por EntityVersion, Artifact, URI ou outro registro explicitamente rastreável, evitando reutilizar SearchHit histórico da investigação original como se fosse vigilância prospectiva.

---

## 15. Signal × Alert

Alert pode originar signal transversal.

Regras:

- Alert ProductVersion precisa ter `product_type='evidence_alert'`;
- target do Alert deve corresponder ao target da UpdatePolicy;
- Alert lifecycle/classification não determina materiality outcome;
- Alert critical não produz outdated automaticamente.

---

## 16. Imutabilidade de signal

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

Após existir qualquer MaterialityAssessment para o signal:

> `update_signal_source` fica selada para INSERT/UPDATE/DELETE.

Isso preserva exatamente o conjunto de fontes sobre o qual o assessment foi produzido.

---

# 17. Estrutura 4 — `maintenance.materiality_assessment`

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
            'human_expert'
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

MaterialityAssessment é julgamento científico/metodológico. Por isso `actor_type='owner'` não é permitido nesse registro. Owner pode atuar na UpdateDecision de governança, mas não será tratado como avaliador científico apenas por ser proprietário.

## 18. Unicidade e supersessão da materialidade

Antes de inserir MaterialityAssessment:

- signal deve estar ativo;
- se `trigger_class<>'governance_demand'`, deve existir exatamente uma primary source;
- todas as fontes referenciadas devem passar validação dinâmica de existência/status;
- sources monitor-derived devem continuar coerentes com o Monitor governante da policy.

Exigir:

> no máximo um assessment ativo por UpdateSignal.

Supersessão:

- precisa preservar o mesmo `update_signal_uuid`;
- assessment anterior torna-se superseded;
- novo assessment possui timestamp igual ou posterior;
- conteúdo anterior permanece imutável.

---

# 19. Estrutura 5 — `maintenance.materiality_dimension`

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

- após existir qualquer UpdateDecision que referencie o assessment, suas MaterialityDimensions ficam seladas para INSERT/UPDATE/DELETE;
- correção de dimensão exige novo MaterialityAssessment por supersessão;
- `material_change_confirmed` exige pelo menos uma dimensão `confirmed`;
- `validity_or_use_threat` exige pelo menos uma dimensão `threat`;
- `potentially_material` exige pelo menos uma dimensão `potential|uncertain`;
- `no_material_change` não pode possuir `confirmed` ou `threat`.

---

# 20. Estrutura 6 — `maintenance.update_decision`

Registra a decisão derivada de assessment.

DDL lógico:

```sql
CREATE TABLE maintenance.update_decision (
    update_decision_uuid uuid PRIMARY KEY,

    update_signal_uuid uuid NOT NULL
        REFERENCES maintenance.update_signal(update_signal_uuid),

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
            'set_outdated'
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

## 21. Unicidade e supersessão de UpdateDecision

O campo `update_signal_uuid` é denormalização controlada para permitir integridade e consulta eficiente.

Guard obrigatório:

- o signal do decision deve ser o mesmo do MaterialityAssessment;
- no INSERT, MaterialityAssessment referenciado deve estar `record_status='active'`;
- no máximo um UpdateDecision ativo por UpdateSignal;
- supersessão deve preservar o mesmo UpdateSignal;
- novo decision pode referenciar assessment mais recente do mesmo signal;
- decisão anterior permanece historicamente preservada.

Isso impede múltiplas decisões concorrentes “ativas” quando a materialidade é reavaliada.

## 22. Proposta × decisão autoritativa

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
- rationale não vazio;
- MaterialityAssessment referenciado também `human_verified` ou `human_consensus`.

Assim, assessment AI-only pode sustentar proposal, mas não decisão autoritativa.

Regra adicional:

> owner pode registrar decisão de governança, mas decisão científica material autoritativa deverá possuir verificação por human_reviewer ou human_expert.

Esse contrato não declara automaticamente que qualquer humano é especialista.

---

## 23. Coerência decision × materiality

Mapeamento mínimo:

### no_scientific_update

Compatível somente com:

- no_material_change.

Pode usar:

- no_change;
- set_current.

Não pode usar under_evaluation, update_recommended ou outdated.

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

Somente para ProductVersion target.

Matriz obrigatória:

| Materiality outcome | currency_action permitido |
|---|---|
| no_material_change | set_current |
| potentially_material | set_under_evaluation, set_update_recommended |
| material_change_confirmed | set_update_recommended, set_outdated |
| validity_or_use_threat | set_under_evaluation, set_update_recommended, set_outdated |
| insufficient_to_decide | set_under_evaluation |

Não permitir:

> `material_change_confirmed → set_current`

nem:

> `insufficient_to_decide → set_current`.

`currency_status='archived'` não será produzido por UpdateDecision v0.1; arquivamento permanece lifecycle/editorial separado.

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

> deve resultar em `currency_action=set_outdated`.

Arquivamento, quando pertinente, ocorre por lifecycle próprio e não é abreviado por UpdateDecision.

Para InvestigationVersion:

> não cria CurrencyState; registra suspensão/decisão operacional e eventual reroteamento.

---

# 24. Estrutura 7 — `maintenance.update_decision_currency_state`

Liga decisão autoritativa aplicada ao CurrencyState resultante.

DDL lógico:

```sql
CREATE TABLE maintenance.update_decision_currency_state (
    update_decision_uuid uuid PRIMARY KEY
        REFERENCES maintenance.update_decision(update_decision_uuid),

    currency_state_uuid uuid NOT NULL
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
6. `currency_action='no_change'` não pode possuir linkage;
7. múltiplos UpdateDecisions coerentes podem apontar para o mesmo CurrencyState quando uma única avaliação de currentness resolve mais de um signal.

Mapeamento:

| currency_action | CurrencyState |
|---|---|
| set_current | current |
| set_under_evaluation | under_evaluation |
| set_update_recommended | update_recommended |
| set_outdated | outdated |

---

## 25. Relação com CurrencyState produzido por Monitor Cycle

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

## 26. Relação com atualização científica futura

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

## 27. Provenance

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

## 28. Verification invariants

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

## 29. Actor semantics

Domínios têm finalidade distinta:

- `system` — evento mecânico sem julgamento;
- `ai_system` — classificação/sugestão assistida por IA;
- `human_reviewer` — revisão humana metodológica/científica não necessariamente especializada;
- `human_expert` — revisão humana especializada;
- `owner` — decisão de governança/propriedade.

Não inferir expertise apenas da presença de humano.

---

## 30. Issues/readiness helpers

A futura migration deverá expor pelo menos:

- `maintenance.update_policy_issues(update_policy_uuid)`;
- `maintenance.update_signal_issues(update_signal_uuid)`;
- `maintenance.materiality_assessment_issues(materiality_assessment_uuid)`;
- `maintenance.update_decision_issues(update_decision_uuid)`.

Esses helpers deverão detectar estado inválido dinâmico que não pode ser congelado apenas no INSERT, incluindo:

- target superseded/invalidated;
- Monitor governante superseded/incompatível;
- source invalidada;
- Alert source drift;
- signal sem primary source quando exigida;
- active decision baseado em assessment superseded;
- CurrencyState linkage cujo target/status nunca correspondeu à decisão.

Supersessão posterior normal do CurrencyState **não** constitui issue: o linkage é histórico e deve permanecer válido.

Helpers não deverão alterar dados.

## 31. M3

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

## 32. Não escopo do contrato v0.1

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

## 33. Guards candidatos da futura migration

A migration candidata deverá implementar pelo menos:

- `maintenance.assert_update_policy_consistency()`;
- `maintenance.guard_update_policy_mutation()`;
- `maintenance.assert_update_policy_transition()`;
- `maintenance.assert_update_signal_consistency()`;
- `maintenance.guard_update_signal_mutation()`;
- `maintenance.assert_update_signal_source_consistency()`;
- `maintenance.guard_update_signal_source_mutation()`;
- `maintenance.guard_update_signal_sources_after_assessment()`;
- `maintenance.assert_materiality_assessment_consistency()`;
- `maintenance.guard_materiality_assessment_mutation()`;
- `maintenance.assert_materiality_dimension_consistency()`;
- `maintenance.guard_materiality_dimension_mutation()`;
- `maintenance.guard_materiality_dimensions_after_decision()`;
- `maintenance.assert_update_decision_consistency()`;
- `maintenance.guard_update_decision_mutation()`;
- `maintenance.assert_update_decision_currency_state_consistency()`;
- `maintenance.guard_update_decision_currency_state_mutation()`.

---

## 34. Testes mínimos esperados

A futura bateria F4-UP deverá cobrir, no mínimo:

1. target XOR de policy;
2. uma policy ativa por ProductVersion;
3. uma policy ativa por InvestigationVersion;
4. policy sobre target não-current é rejeitada;
5. target superseded posteriormente gera issue sem retarget silencioso;
6. supersessão preserva target;
7. M0 × cadence;
8. M1 × cadence;
9. policy em evidence_monitor/evidence_alert é rejeitada;
10. policy em Investigation evidence_monitoring é rejeitada;
11. policy por system/AI é rejeitada;
12. transições M0–M3 inválidas são rejeitadas;
13. M1 com governing Monitor é rejeitada;
14. M2 exige Monitor em policy ativa;
15. M3 exige Monitor mas permanece bloqueado formalmente;
16. Monitor da policy aponta para mesmo target;
17. signal exige policy ativa no INSERT;
18. signal_type × class × trigger coerentes;
19. signal verification invariants;
20. signal material imutável;
21. source locator XOR;
22. no máximo uma primary source;
23. SearchHit fora de Monitor rejeitado;
24. source Monitor pertencente ao Monitor governante;
25. Alert source target compatível;
26. SignalSource selada após assessment;
27. assessment sem primary source rejeitado quando exigida;
28. owner como materiality assessor rejeitado;
29. um assessment ativo por signal;
30. assessment supersession preserva signal;
31. materiality outcome × dimensions coerente;
32. MaterialityDimension selada após decision;
33. proposal por AI permitida;
34. authoritative por AI rejeitada;
35. authoritative com assessment AI-only rejeitada;
36. authoritative sem human verification rejeitada;
37. um decision ativo por signal;
38. decision supersession preserva signal;
39. insufficient_to_decide não pode encerrar como no_scientific_update;
40. material_change_confirmed → set_current é rejeitado;
41. insufficient_to_decide → set_current é rejeitado;
42. decision × materiality coerente;
43. Investigation target com currency action rejeitado;
44. Product target currency linkage coerente;
45. wrong-target CurrencyState rejeitado;
46. currency action/status mismatch rejeitado;
47. archived não pode ser produzido por UpdateDecision;
48. no_change com CurrencyState rejeitado;
49. dois signals podem compartilhar o mesmo CurrencyState quando coerentes;
50. cycle CurrencyState pode ser reutilizado quando coerente;
51. contradição cycle/decision rejeitada;
52. nenhuma decisão cria ProductVersion automaticamente;
53. nenhuma decisão cria InvestigationVersion automaticamente;
54. nenhum registro promove assurance;
55. M3 blocker existente continua ativo;
56. migrations 021–026 permanecem idempotentes;
57. futura migration candidata é idempotente quando desenhada para tal;
58. rebuild-from-zero through migration candidata;
59. regressões globais F2-B/S4/S5;
60. regressões completas de Monitor e Alert.

---

## 35. Gate obrigatório antes de migration

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

## 36. Próximo passo exato

> **Executar a revisão adversarial física do Documento 07. Somente em PASS ou PASS_WITH_ARCHITECTURAL_DECISIONS poderá ser autorizada a migration candidata 027.**
