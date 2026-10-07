# 167 — Monitor de Evidências: Contrato de Dados v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** contrato de dados candidato v0.1  
**Dependências:** Documentos 165–166; OES-P1; migrations 002–020  
**Migration prevista:** `database/021_evidence_monitor_contract.sql`

---

# 1. Finalidade

Transformar a especificação científica e a decisão arquitetural do Monitor de Evidências em um contrato lógico implementável, sem:

- contaminar a Investigation científica histórica do alvo;
- duplicar Search/SearchHit;
- criar currentness paralelo;
- criar ProductVersion científica a cada ciclo;
- antecipar o contrato do Alerta de Evidência;
- antecipar thresholds transversais reservados à Fase 4.

O contrato deve permitir reconstruir:

> **Monitor → alvo → plano → ciclo → Search/SearchHit ou evento → candidate assessment → decisão de manutenção → target currency state → eventual atualização científica.**

---

# 2. Decisão estrutural

Criar namespace:

> `maintenance`

Product:

> `product_type='evidence_monitor'`

Investigation do Monitor:

> `investigation_type='evidence_monitoring'`

A Investigation do Monitor:

- possui Question;
- possui protocolo/plano;
- herda o `depth_level` do alvo primário;
- usa somente `maintenance_level IN ('M2','M3')`;
- recebe suas próprias Searches;
- não substitui nem modifica retrospectivamente a Investigation científica do alvo.

---

# 3. Estruturas especializadas v0.1

Criar:

1. `maintenance.monitor_definition`;
2. `maintenance.monitor_target`;
3. `maintenance.monitor_state`;
4. `maintenance.monitor_cycle`;
5. `maintenance.cycle_search`;
6. `maintenance.evidence_event`;
7. `maintenance.candidate_assessment`;
8. `maintenance.cycle_currency_state`.

Reutilizar:

- `investigation.search`;
- `investigation.search_hit`;
- `investigation.dedup_cluster`;
- `investigation.screening_decision` quando o target científico já for Study/Report;
- `investigation.method_decision`;
- `investigation.quality_control_record`;
- `product.currency_state`;
- `product.version_change_class`;
- `product.assurance_record`;
- `evidence.report_relation`;
- `provenance.record`;
- `provenance.dependency_edge`.

---

# 4. Semântica temporal do cutoff

Para `evidence_monitor`:

> **`ProductVersion.evidence_cutoff_date` representa o cutoff basal do alvo no momento em que aquela Monitor ProductVersion foi criada.**

O mesmo cutoff basal deve constar na InvestigationVersion do Monitor.

Ele não será atualizado a cada ciclo.

Cutoffs posteriores pertencem a:

> `maintenance.monitor_cycle.window_end_date`.

Isso evita:

- versionamento artificial por execução rotineira;
- sobrescrita histórica;
- ambiguidade entre plano e execução.

A View deverá nomear explicitamente:

- `baseline_evidence_cutoff_date`;
- `latest_completed_cycle_cutoff_date`.

---

# 5. Question e profundidade herdada

O Monitor reutiliza a Question científica do alvo.

No v0.1:

> **a primary Question entity da Investigation do Monitor deve ser a mesma primary Question entity do alvo.**

Se a pergunta mudar materialmente:

> não é simples manutenção; reavaliar roteamento.

A profundidade N é herdada:

- target N0 → monitor Investigation N0;
- target N1 → N1;
- target N2 → N2;
- target N3 → N3;
- target N4 → N4.

O nível herdado não implica repetir integralmente o método original em cada ciclo.

---

# 6. Estrutura 1 — `maintenance.monitor_definition`

Uma linha por Monitor ProductVersion.

DDL lógico:

```sql
CREATE TABLE maintenance.monitor_definition (
    monitor_product_version_uuid uuid PRIMARY KEY
        REFERENCES product.product_version(version_uuid),
    surveillance_scope_payload jsonb NOT NULL,
    source_policy_payload jsonb NOT NULL,
    strategy_policy_payload jsonb NOT NULL,
    cadence_policy_payload jsonb NOT NULL,
    impact_policy_payload jsonb NOT NULL,
    escalation_policy_payload jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

Regras:

- ProductVersion deve possuir `product_type='evidence_monitor'`;
- todos os payloads devem ser objetos JSON não nulos;
- mudança material do plano exige nova Monitor ProductVersion;
- UPDATE/DELETE material da definição é proibido.

---

# 7. Conteúdo mínimo dos payloads do plano

## 7.1 `surveillance_scope_payload`

Deve ser capaz de registrar:

- população/condição;
- intervenção/exposição;
- comparador quando aplicável;
- outcomes/dimensões prioritárias;
- tipos de evidência/evento;
- limites de escopo;
- relação com o alvo.

## 7.2 `source_policy_payload`

Pode registrar, por instância:

- `required_source_names`;
- `required_source_classes`;
- `minimum_bibliographic_sources`;
- registros/registries;
- fontes regulatórias;
- fontes de retração/correção;
- citation chaining;
- grey literature;
- event-only sources.

Importante:

> **nenhum minimum global de bases é criado neste contrato.**

A política vale somente quando prospectivamente declarada para aquele Monitor.

## 7.3 `strategy_policy_payload`

Pode registrar:

- estratégia incremental;
- relação com estratégia original;
- versionamento;
- restrições;
- deduplicação;
- handling de novos Reports/Studies.

## 7.4 `cadence_policy_payload`

Registra a cadência daquela instância sem criar padrão transversal OES.

Exemplos:

- intervalo planejado;
- calendário;
- trigger local;
- rationale.

Os defaults transversais permanecem para a Fase 4.

## 7.5 `impact_policy_payload`

Define quais dimensões de impacto serão avaliadas.

## 7.6 `escalation_policy_payload`

Define quando o ciclo deve recomendar:

- avaliação adicional;
- atualização;
- avaliação de futuro Alerta.

Não define ainda severity final de Alerta.

---

# 8. Protocolo/plano

A fonte canônica documental do plano é:

> `investigation.investigation_version.protocol_artifact_uuid`

Para Monitor formal:

- obrigatório;
- artifact ativo;
- prospectivo à execução regular;
- coerente com os payloads da `monitor_definition`.

Não criar artifact paralelo específico do namespace maintenance.

---

# 9. Estrutura 2 — `maintenance.monitor_target`

v0.1 possui exatamente um alvo primário por Monitor ProductVersion.

DDL lógico:

```sql
CREATE TABLE maintenance.monitor_target (
    monitor_target_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL UNIQUE
        REFERENCES product.product_version(version_uuid),
    target_product_version_uuid uuid
        REFERENCES product.product_version(version_uuid),
    target_investigation_version_uuid uuid
        REFERENCES investigation.investigation_version(version_uuid),
    rationale text NOT NULL,
    linked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        num_nonnulls(
            target_product_version_uuid,
            target_investigation_version_uuid
        ) = 1
    )
);
```

Default preferencial:

> ProductVersion como alvo.

InvestigationVersion isolada é permitida quando não houver ProductVersion científico apropriado.

---

# 10. Guard de target

Trigger candidato:

> `maintenance.assert_monitor_target_consistency()`

Deverá verificar:

1. Monitor ProductVersion existe e é `evidence_monitor`;
2. Monitor possui exatamente uma primary Investigation;
3. primary Investigation tem `investigation_type='evidence_monitoring'`;
4. maintenance level é M2 ou M3;
5. target não é o próprio Monitor;
6. target ProductVersion não é `evidence_monitor`;
7. target não está invalidado no momento da vinculação;
8. depth da Monitor Investigation = depth herdada do target;
9. primary Question entity do Monitor = primary Question entity do target;
10. Monitor cutoff = target cutoff no momento da criação;
11. Monitor Investigation cutoff = Monitor Product cutoff.

Para target ProductVersion:

- depth/cutoff/Question são derivados de sua primary Investigation.

Para target InvestigationVersion:

- são lidos diretamente dessa versão.

---

# 11. Dependency edge do alvo

Criar dependency edge ativa:

> source = target version  
> target = Monitor ProductVersion  
> dependency_type = `maintenance_surveillance_target`

Se alvo for ProductVersion, source é a ProductVersion.

Se alvo for InvestigationVersion, source é a InvestigationVersion.

O vínculo operacional continua sendo `monitor_target`; dependency edge fornece lineage/invalidation traversal.

---

# 12. Target version concreta

O Monitor vigia uma versão concreta.

Se uma atualização científica criar nova ProductVersion do alvo:

> **o Monitor atual não deve trocar silenciosamente de target.**

A continuação do monitoramento da nova versão exige:

- nova Monitor ProductVersion; ou
- decisão explícita de encerramento/rerroteamento.

Isso preserva reprodutibilidade histórica.

---

# 13. Estrutura 3 — `maintenance.monitor_state`

Estado operacional do Monitor é separado do editorial status e do target currency.

DDL lógico:

```sql
CREATE TABLE maintenance.monitor_state (
    monitor_state_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    operational_status text NOT NULL CHECK (
        operational_status IN (
            'planned','active','paused','closed','archived'
        )
    ),
    effective_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rationale text NOT NULL,
    changed_by text NOT NULL,
    actor_type text NOT NULL CHECK (
        actor_type IN (
            'system','ai_system','human_reviewer',
            'human_expert','owner'
        )
    ),
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_monitor_state_uuid uuid,
    UNIQUE (monitor_state_uuid,monitor_product_version_uuid),
    FOREIGN KEY (
        supersedes_monitor_state_uuid,
        monitor_product_version_uuid
    ) REFERENCES maintenance.monitor_state(
        monitor_state_uuid,
        monitor_product_version_uuid
    )
);
```

Índice único parcial:

> uma state ativa por Monitor ProductVersion.

---

# 14. Append-preserving do MonitorState

Material fields são imutáveis.

Transição:

1. state ativa anterior → `record_status='superseded'`;
2. nova state ativa aponta `supersedes_monitor_state_uuid`.

DELETE proibido.

Nenhuma mudança operacional reescreve a história.

---

# 15. Quatro dimensões que não podem ser colapsadas

O contrato distingue:

1. **editorial status do Monitor ProductVersion**;
2. **currency do plano/produto Monitor**, via `product.currency_state` do próprio Monitor;
3. **operational status**, via `maintenance.monitor_state`;
4. **currency do alvo científico**, via `product.currency_state` do target ProductVersion.

A View deve apresentar cada dimensão separadamente.

---

# 16. Estrutura 4 — `maintenance.monitor_cycle`

Ciclo é unidade operacional recorrente.

DDL lógico:

```sql
CREATE TABLE maintenance.monitor_cycle (
    cycle_uuid uuid PRIMARY KEY,
    monitor_product_version_uuid uuid NOT NULL
        REFERENCES product.product_version(version_uuid),
    cycle_no integer NOT NULL CHECK (cycle_no > 0),
    previous_cycle_uuid uuid
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    window_start_date date NOT NULL,
    window_end_date date NOT NULL,
    planned_at timestamptz,
    started_at timestamptz,
    completed_at timestamptz,
    execution_status text NOT NULL CHECK (
        execution_status IN (
            'planned','running','completed','incomplete','cancelled'
        )
    ),
    completeness_status text NOT NULL CHECK (
        completeness_status IN (
            'not_assessed','complete','partial','failed'
        )
    ),
    maintenance_decision text CHECK (
        maintenance_decision IN (
            'no_update_needed',
            'evaluate_update',
            'update_recommended',
            'outdated'
        )
    ),
    decision_rationale text,
    escalation_recommendation text NOT NULL DEFAULT 'none' CHECK (
        escalation_recommendation IN (
            'none','evaluate_alert','urgent_reassessment'
        )
    ),
    decided_by text,
    actor_type text CHECK (
        actor_type IN ('ai_system','human_reviewer','human_expert')
    ),
    verification_status text NOT NULL DEFAULT 'unverified' CHECK (
        verification_status IN (
            'unverified','ai_verified','human_verified','human_consensus'
        )
    ),
    verified_by text,
    verifier_actor_type text CHECK (
        verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    execution_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (monitor_product_version_uuid,cycle_no),
    CHECK (window_end_date >= window_start_date),
    CHECK (
        previous_cycle_uuid IS NULL
        OR previous_cycle_uuid <> cycle_uuid
    )
);
```

---

# 17. Cycle lifecycle guard

Trigger:

> `maintenance.assert_monitor_cycle_lifecycle()`

Regras mínimas:

- `previous_cycle_uuid` pertence ao mesmo Monitor;
- previous cycle tem `cycle_no < current cycle_no`;
- `running` exige `started_at`;
- terminal `completed|incomplete|cancelled` exige `completed_at`;
- `completed` exige `completeness_status='complete'`;
- `completed` exige maintenance decision, rationale, actor e actor_type;
- `no_update_needed` só é permitido em cycle `completed`;
- `incomplete|cancelled` não podem declarar `no_update_needed`;
- verification semantics devem ser coerentes com ator/verifier;
- IA nunca pode ser registrada como human verification.

Depois de terminal:

> **campos materiais do ciclo tornam-se imutáveis e DELETE é proibido.**

Correção material de ciclo terminal exige novo ciclo/registro corretivo, não overwrite silencioso.

---

# 18. Janela de vigilância

O contrato não exige continuidade diária rígida.

Pode existir:

- overlap temporal;
- retry;
- janela complementar;
- gap justificado.

Entretanto a View/gate deve conseguir detectar:

- gap não explicado;
- janela anterior ao baseline;
- janela futura inválida;
- ciclo fora de ordem.

Justificativas podem residir em `execution_payload` ou MethodDecision.

Fase 4 poderá endurecer regras temporais.

---

# 19. Estrutura 5 — `maintenance.cycle_search`

Não criar Search paralela.

DDL lógico:

```sql
CREATE TABLE maintenance.cycle_search (
    cycle_uuid uuid NOT NULL
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    search_uuid uuid NOT NULL UNIQUE
        REFERENCES investigation.search(search_uuid),
    search_role text NOT NULL CHECK (
        search_role IN (
            'primary','supplementary',
            'registry','citation_chaining','other'
        )
    ),
    sequence_no integer,
    PRIMARY KEY (cycle_uuid,search_uuid)
);
```

A unicidade de `search_uuid` garante:

> **uma execução Search do Monitor pertence a no máximo um cycle.**

---

# 20. CycleSearch guard

Trigger:

> `maintenance.assert_cycle_search_consistency()`

Deve garantir:

- Search pertence à primary Investigation do Monitor;
- cycle pertence ao mesmo Monitor ProductVersion;
- Search não pertence à Investigation científica do target;
- Search.executed_at é temporalmente compatível com o cycle, salvo import histórico explicitamente documentado;
- Search invalidada/cancelada não satisfaz cobertura de ciclo completo.

Toda Search da Monitor Investigation usada operacionalmente deverá estar vinculada a um cycle.

---

# 21. SearchHit e dedup

Reutilizar:

- `investigation.search_hit`;
- `investigation.dedup_cluster`.

Não criar cópia no namespace maintenance.

SearchHit continua podendo existir:

- sem Report resolvido;
- com Report resolvido;
- em cluster de deduplicação.

Isso exige CandidateAssessment próprio para a etapa de manutenção.

---

# 22. Estrutura 6 — `maintenance.evidence_event`

Eventos não bibliográficos ou de validade não devem ser forçados a SearchHit.

DDL lógico:

```sql
CREATE TABLE maintenance.evidence_event (
    evidence_event_uuid uuid PRIMARY KEY,
    cycle_uuid uuid NOT NULL
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    event_type text NOT NULL CHECK (
        event_type IN (
            'correction',
            'retraction',
            'expression_of_concern',
            'report_update',
            'dataset_invalidation',
            'regulatory_update',
            'guidance_update',
            'source_withdrawal',
            'other_validity_event'
        )
    ),
    event_date date,
    detected_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    report_relation_uuid uuid
        REFERENCES evidence.report_relation(relation_uuid),
    affected_version_uuid uuid
        REFERENCES core.entity_version(version_uuid),
    source_artifact_uuid uuid
        REFERENCES artifact.artifact(artifact_uuid),
    source_uri text,
    description text NOT NULL,
    event_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    detected_by text NOT NULL,
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
        verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    status text NOT NULL DEFAULT 'active' CHECK (
        status IN ('active','superseded','invalidated')
    ),
    CHECK (
        num_nonnulls(
            report_relation_uuid,
            source_artifact_uuid,
            source_uri
        ) >= 1
    )
);
```

---

# 23. EvidenceEvent guard

Trigger candidato:

> `maintenance.assert_evidence_event_consistency()`

Deve verificar:

- cycle/Monitor válidos;
- verification semantics;
- `source_uri` não vazio quando presente;
- artifact ativo quando utilizado;
- ReportRelation compatível quando o event_type for correction/retraction/expression_of_concern;
- affected version não deve ser inventada por inferência sem suporte;
- invalidated event não pode sustentar decisão final sem disclosure/reavaliação.

Quando existir ReportRelation canônica:

> **reutilizá-la; EvidenceEvent não duplica a relação científica.**

---

# 24. Estrutura 7 — `maintenance.candidate_assessment`

CandidateAssessment registra avaliação inicial de um sinal detectado.

Origens suportadas:

1. SearchHit;
2. entidade científica conhecida diretamente;
3. EvidenceEvent.

DDL lógico:

```sql
CREATE TABLE maintenance.candidate_assessment (
    candidate_assessment_uuid uuid PRIMARY KEY,
    cycle_uuid uuid NOT NULL
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    origin_type text NOT NULL CHECK (
        origin_type IN ('search_hit','entity','evidence_event')
    ),
    origin_search_hit_uuid uuid
        REFERENCES investigation.search_hit(search_hit_uuid),
    origin_entity_uuid uuid
        REFERENCES core.entity(entity_uuid),
    origin_evidence_event_uuid uuid
        REFERENCES maintenance.evidence_event(evidence_event_uuid),
    resolved_target_entity_uuid uuid
        REFERENCES core.entity(entity_uuid),
    candidate_kind text NOT NULL CHECK (
        candidate_kind IN (
            'new_report','new_study','review_update',
            'validity_event','regulatory_signal',
            'scope_change_signal','other'
        )
    ),
    decision text NOT NULL CHECK (
        decision IN ('pending','excluded','retained_for_impact')
    ),
    exclusion_reason text,
    impact_class text CHECK (
        impact_class IN (
            'none',
            'quantitative',
            'certainty',
            'applicability',
            'conclusion',
            'validity',
            'scope'
        )
    ),
    impact_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
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
        verifier_actor_type IN (
            'ai_system','human_reviewer','human_expert'
        )
    ),
    verified_at timestamptz,
    assessed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_status text NOT NULL DEFAULT 'active' CHECK (
        record_status IN ('active','superseded')
    ),
    supersedes_candidate_assessment_uuid uuid,
    CHECK (
        (origin_type='search_hit'
         AND origin_search_hit_uuid IS NOT NULL
         AND origin_entity_uuid IS NULL
         AND origin_evidence_event_uuid IS NULL)
        OR
        (origin_type='entity'
         AND origin_search_hit_uuid IS NULL
         AND origin_entity_uuid IS NOT NULL
         AND origin_evidence_event_uuid IS NULL)
        OR
        (origin_type='evidence_event'
         AND origin_search_hit_uuid IS NULL
         AND origin_entity_uuid IS NULL
         AND origin_evidence_event_uuid IS NOT NULL)
    ),
    CHECK (
        decision<>'excluded'
        OR exclusion_reason IS NOT NULL
    )
);
```

---

# 25. CandidateAssessment guard

Trigger:

> `maintenance.assert_candidate_assessment_consistency()`

Deve garantir:

- SearchHit originou-se de Search ligada ao mesmo cycle;
- EvidenceEvent pertence ao mesmo cycle;
- entity origin/resolved target é Report ou Study no v0.1;
- `retained_for_impact` exige `impact_class` diferente de null;
- `excluded` não deve ser usado para esconder evento de validade material já conhecido;
- verification semantics coerentes;
- supersession permanece dentro do mesmo cycle e da mesma origem lógica.

Índices parciais deverão impedir duas avaliações ativas para a mesma origem dentro do mesmo cycle.

---

# 26. CandidateAssessment e ScreeningDecision

CandidateAssessment:

> decisão de manutenção/priorização do sinal.

ScreeningDecision:

> decisão de elegibilidade científica em Investigation quando Study/Report já constitui target adequado.

Logo:

- CandidateAssessment não substitui ScreeningDecision;
- ScreeningDecision não será ampliada para SearchHit;
- quando atualização científica formal for aberta, eligibility deve seguir o método do produto alvo.

---

# 27. Ciclo completo e candidatos pendentes

Um cycle não poderá produzir decisão `no_update_needed` se existir:

- CandidateAssessment ativa `pending`;
- EvidenceEvent material não avaliado;
- Search necessária não executada;
- coverage incompleta sem rationale explícita.

O gate deverá retornar blocker.

---

# 28. Estrutura 8 — `maintenance.cycle_currency_state`

Liga o resultado de cycle à avaliação de currentness do ProductVersion científico alvo.

DDL lógico:

```sql
CREATE TABLE maintenance.cycle_currency_state (
    cycle_uuid uuid PRIMARY KEY
        REFERENCES maintenance.monitor_cycle(cycle_uuid),
    currency_state_uuid uuid NOT NULL UNIQUE
        REFERENCES product.currency_state(currency_state_uuid),
    linked_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

Só se aplica quando o target primário é ProductVersion.

---

# 29. CycleCurrencyState guard

Trigger:

> `maintenance.assert_cycle_currency_state_consistency()`

Deve verificar:

1. cycle está `completed`;
2. target é ProductVersion;
3. CurrencyState pertence exatamente ao target ProductVersion;
4. CurrencyState é a avaliação resultante do ciclo;
5. status de currentness é coerente com a maintenance decision.

Mapeamento v0.1:

| Maintenance decision | Currency status |
|---|---|
| `no_update_needed` | `current` |
| `evaluate_update` | `under_evaluation` |
| `update_recommended` | `update_recommended` |
| `outdated` | `outdated` |

Para target InvestigationVersion:

> CycleCurrencyState não é exigido.

---

# 30. CurrencyState sem nova ProductVersion

Um cycle `no_update_needed` pode:

- superseder o CurrencyState ativo anterior do target;
- criar novo CurrencyState também `current`;
- registrar nova data/rationale de avaliação.

Isso:

> **não cria nova ProductVersion científica.**

A nova linha de CurrencyState representa reavaliação temporal do mesmo conteúdo científico.

---

# 31. Provenance do CurrencyState

`product.currency_state` não é Core EntityVersion.

O vínculo causal primário será:

> `maintenance.cycle_currency_state`.

Quando necessário, `provenance.record.process_type/process_record_uuid` poderá apontar para o `cycle_uuid` ao registrar provenance de uma versão científica futura.

Não criar dependency edge diretamente para CurrencyState.

---

# 32. Atualização científica posterior

Se cycle recomendar atualização e uma nova ProductVersion científica for criada:

- ProductVersion nova usa seu próprio workflow;
- `product.version_change_class` registra a natureza da mudança;
- provenance da nova versão pode registrar:
  - `process_type='monitor_cycle'`;
  - `process_record_uuid=cycle_uuid`;
- lineage entre versões continua por `core.entity_version.supersedes_version_uuid`.

Não criar `maintenance.version_change_class`.

---

# 33. Operational status × cycle

Regras:

- `planned`: cycles podem ser planejados, mas execução formal ainda não ativa;
- `active`: cycles podem executar;
- `paused`: novo cycle running deve ser bloqueado, salvo fechamento/import de cycle já iniciado;
- `closed|archived`: nenhum novo cycle pode iniciar.

Trigger/gate deverá impedir início incompatível.

---

# 34. Monitor Product currency

O Monitor ProductVersion também pode possuir seu próprio `product.currency_state`.

Semântica:

> **refere-se à atualidade do plano/produto Monitor, não à atualidade científica do target.**

Exemplos de plano desatualizado:

- fontes relevantes mudaram;
- estratégia deixou de ser válida;
- scope ficou incompatível;
- target foi superseded;
- política M2/M3 mudou materialmente.

Nunca apresentar esse estado como target currency.

---

# 35. Assurance

Usar:

> `product.assurance_level(product_version_uuid)`

Monitor assurance avalia o Monitor.

Target assurance é contexto separado.

Regra v0.1:

- A0 = sem AI methodological verification passed;
- A1 = AI methodological verification passed;
- A2 = + owner governance approval;
- A3 = + expert independent review.

Não copiar assurance do target.

---

# 36. Assurance mínima para Monitor formal M2

Para publicação formal de Monitor M2 v0.1:

> **mínimo A2**

Justificativa:

- Monitor publicado é produto operacional persistente;
- exige verificação metodológica do plano/processo;
- exige aprovação de governança;
- expert review não é universalmente exigida para o produto Monitor em si.

A3 pode existir, mas não é default obrigatório.

Isso:

> **não reduz assurance ou controles exigidos quando uma atualização científica do target entra em N3/N4.**

---

# 37. M3 e fronteira da Fase 4

M3 é representável no schema.

Entretanto, antes do Protocolo de Atualização transversal da Fase 4:

> **Monitor M3 não poderá ser considerado formalmente publicável como living evidence.**

Blocker candidato:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

M3 poderá ser:

- fixture;
- developmental;
- interno;
- testado tecnicamente.

Mas o gate formal v0.1 permanece fechado até política posterior explícita.

---

# 38. Human controls

O contrato não inventa requisito humano universal por cycle.

Fase 4 definirá controles transversais adicionais.

No v0.1:

- actor e verification status são sempre explícitos;
- AI não pode human-verify;
- owner approval do Monitor não equivale a human scientific verification;
- ciclos unverified/AI-only devem ser apresentados como tais;
- eventual atualização N3/N4 continua submetida aos controles humanos do método alvo.

---

# 39. Product fields do Monitor

Para `evidence_monitor`:

## `title`

Obrigatório.

## `evidence_cutoff_date`

Cutoff basal, conforme seção 4.

## `conclusion_text`

Não é exigido como conclusão científica.

Se utilizado:

> somente resumo operacional do estado do Monitor.

A conclusão científica do target deve ser projetada separadamente.

## `limitations_summary`

Obrigatório para publicação formal.

Deve incluir limitações de cobertura/automação/verificação relevantes.

---

# 40. Monitor publication issues — identidade/configuração

Errors candidatos:

- `MISSING_PRODUCT_VERSION`;
- `WRONG_PRODUCT_TYPE`;
- `MISSING_PRIMARY_INVESTIGATION`;
- `MULTIPLE_PRIMARY_INVESTIGATIONS`;
- `PRIMARY_INVESTIGATION_NOT_MONITORING`;
- `MONITOR_MAINTENANCE_NOT_M2_M3`;
- `MISSING_QUESTION`;
- `MISSING_MONITOR_PROTOCOL`;
- `MISSING_MONITOR_DEFINITION`;
- `MISSING_PRIMARY_TARGET`;
- `MULTIPLE_PRIMARY_TARGETS`;
- `TARGET_DEPTH_MISMATCH`;
- `TARGET_QUESTION_MISMATCH`;
- `BASELINE_CUTOFF_MISMATCH`;
- `TARGET_INVALIDATED`;
- `TARGET_IS_MONITOR`.

---

# 41. Publication issues — lifecycle/cycles

Errors candidatos:

- `MISSING_MONITOR_STATE`;
- `MISSING_COMPLETED_CYCLE`;
- `CYCLE_WINDOW_INVALID`;
- `CYCLE_SEARCH_INVESTIGATION_MISMATCH`;
- `UNLINKED_MONITOR_SEARCH`;
- `INCOMPLETE_REQUIRED_SOURCE_COVERAGE`;
- `PENDING_CYCLE_CANDIDATE`;
- `UNASSESSED_MATERIAL_EVENT`;
- `NO_UPDATE_FROM_INCOMPLETE_CYCLE`;
- `MISSING_CYCLE_CURRENCY_STATE`;
- `CYCLE_CURRENCY_STATE_TARGET_MISMATCH`;
- `CYCLE_DECISION_CURRENCY_MISMATCH`.

---

# 42. Publication issues — governance/assurance

Errors candidatos:

- `MISSING_AI_METHODOLOGICAL_VERIFICATION`;
- `ACTIVE_AI_METHOD_BLOCK`;
- `MISSING_OWNER_APPROVAL`;
- `ACTIVE_OWNER_BLOCK`;
- `ASSURANCE_BELOW_A2`;
- `MISSING_PUBLICATION_DATE`;
- `MISSING_LIMITATIONS`;
- `MONITOR_PRODUCT_NOT_CURRENT`;
- `MISSING_MONITOR_CURRENCY_STATE`;
- `INVALIDATED_DEPENDENCY`;
- `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

Expert review ausente:

> warning para M2 v0.1, não error.

---

# 43. Warnings candidatos

- `MONITOR_PAUSED`;
- `MONITOR_CLOSED`;
- `TARGET_VERSION_SUPERSEDED`;
- `TARGET_CURRENCY_UNDER_EVALUATION`;
- `TARGET_UPDATE_RECOMMENDED`;
- `TARGET_OUTDATED`;
- `LATEST_CYCLE_INCOMPLETE`;
- `AI_ONLY_LATEST_CYCLE`;
- `UNVERIFIED_CANDIDATE_ASSESSMENTS`;
- `NON_BIBLIOGRAPHIC_SOURCE_LIMITATIONS`;
- `GREY_LITERATURE_NOT_MONITORED`;
- `NO_EXPERT_REVIEW_OF_MONITOR`;
- `ALERT_EVALUATION_RECOMMENDED`;
- `URGENT_REASSESSMENT_RECOMMENDED`.

Warnings refletem estado real; não são checklist ornamental.

---

# 44. Source-policy validation

O gate deve validar somente regras declaradas na própria `source_policy_payload`.

Exemplos:

- source name obrigatório;
- source class obrigatória;
- minimum bibliographic sources definido pelo plano;
- registry exigido;
- source de retraction exigida.

Não deve:

> inventar regra global inexistente.

Essa regra é explicitamente protegida pela experiência adversarial do OVR-01.

---

# 45. Cycle completeness

Cycle `completed` formal exige:

- todas as sources obrigatórias executadas ou exceção MethodDecision ativa e justificada;
- Searches vinculadas ao cycle;
- eventos materiais avaliados;
- nenhum CandidateAssessment ativo pending;
- maintenance decision;
- rationale;
- actor;
- completeness `complete`.

Cycle `incomplete`:

- permanece auditável;
- não pode declarar `no_update_needed`;
- não pode gerar falsa confirmação de currentness.

---

# 46. MethodDecision

Reutilizar `investigation.method_decision` da Monitor Investigation.

Usos:

- source indisponível;
- mudança de estratégia;
- exceção de cobertura;
- cycle retry;
- rerouting;
- mudança de método;
- desvio do plano.

Não criar `maintenance.method_decision`.

---

# 47. QualityControlRecord

Reutilizar `investigation.quality_control_record`.

`control_type='other'` poderá usar `scope_payload.control_code` como:

- `monitor_plan_verification`;
- `monitor_cycle_verification`;
- `monitor_candidate_assessment_verification`;
- `monitor_event_verification`.

Não alterar enum global apenas por nomes do Monitor na migration 021.

---

# 48. ReviewerAssignment

Reutilizar `investigation.reviewer_assignment` quando controles humanos forem realmente executados.

Nenhum ReviewerAssignment sintético deve ser criado para satisfazer gate.

---

# 49. EvidenceMonitorView — schema candidato

Schema:

> `oes.evidence_monitor_view/0.1`

Estrutura candidata:

```text
EvidenceMonitorView
├── schema_version
├── identity
├── question
├── monitor_investigation
├── monitor_plan
│   ├── surveillance_scope
│   ├── source_policy
│   ├── strategy_policy
│   ├── cadence_policy
│   ├── impact_policy
│   └── escalation_policy
├── operational_state
├── monitor_currency
├── target
│   ├── identity
│   ├── depth
│   ├── baseline_cutoff
│   ├── editorial_status
│   ├── assurance
│   ├── currency
│   └── scientific_conclusion
├── latest_cycle
├── cycles[]
│   ├── window
│   ├── execution
│   ├── searches[]
│   ├── events[]
│   ├── candidates[]
│   ├── maintenance_decision
│   ├── verification
│   ├── escalation_recommendation
│   └── resulting_target_currency
├── update_lineage
├── limitations
├── quality_controls[]
└── audit
```

---

# 50. EvidenceMonitorView — regras

A View:

- é read-only;
- não executa buscas;
- não muda CurrencyState;
- não cria Alert;
- não cria ProductVersion;
- não inferirá human verification;
- não transforma Search.result_count em SearchHit count;
- não trata Monitor Product currency como target currency;
- não trata baseline cutoff como latest cycle cutoff.

---

# 51. Audit

Campos mínimos:

- assurance_level do Monitor;
- target_assurance_level;
- publishable;
- required_assurance_level;
- monitor_operational_status;
- monitor_currency_status;
- target_currency_status;
- maintenance_level;
- latest_completed_cycle_uuid;
- latest_completed_cycle_cutoff;
- latest_cycle_verification_status;
- pending_candidate_count;
- active_event_count;
- required_source_coverage_satisfied;
- invalidated_dependencies;
- publication_issues[];
- assurance_records[].

---

# 52. Funções candidatas

A migration 021 poderá criar:

- `maintenance.monitor_primary_investigation(product_version_uuid)`;
- `maintenance.monitor_target_depth(product_version_uuid)`;
- `maintenance.monitor_cycle_source_coverage(cycle_uuid)`;
- `maintenance.monitor_cycle_issues(cycle_uuid)`;
- `product.evidence_monitor_publication_issues(product_version_uuid)`;
- `product.evidence_monitor_is_publishable(product_version_uuid)`;
- futura função de View somente após Projection Readiness específica, se arquitetura seguir o padrão Overview/Mapa.

Preferência:

> separar contrato/gate de Projection View quando isso reduzir risco, seguindo o aprendizado das migrations 019–020.

---

# 53. Projection readiness inicial

O contrato de dados não implica que a View já esteja pronta.

Após migration 021 + fixture + testes:

> executar Projection Readiness Gate específico.

Se faltarem dados/projeções:

> criar migration 022 aditiva da View, sem forçar template prematuro.

---

# 54. Fixture formal candidata M2

Fixture sintética inicial deverá representar:

- target ProductVersion científico N2 ou N1 estável;
- Monitor Product `evidence_monitor`;
- Monitor Investigation herdando N;
- maintenance M2;
- protocolo/plano;
- target linkage;
- dependency edge;
- operational state active;
- Monitor Product currency current;
- dois cycles;
- primeiro cycle com nova evidência irrelevante → `no_update_needed`;
- novo target CurrencyState `current`;
- segundo cycle com candidato potencialmente relevante → `evaluate_update`;
- target CurrencyState `under_evaluation`;
- Searches vinculadas;
- SearchHits;
- candidate assessments;
- pelo menos um EvidenceEvent de validade em cenário de teste separado;
- A2 sintético para fixture formal;
- ausência de expert review permitida com warning;
- publishable=true somente quando todos os demais gates estiverem satisfeitos.

---

# 55. Fixture M3 bloqueada

Fixture adicional:

- maintenance M3;
- dados estruturais completos;
- A3 opcional;
- cycles completos.

Esperado antes da Fase 4:

> `publishable=false`

por:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

Isso protege a fronteira de fase.

---

# 56. Testes mínimos do contrato

A implementação deverá demonstrar, no mínimo:

1. schema `maintenance` criado;
2. Product errado é rejeitado;
3. Monitor exige primary Investigation própria;
4. maintenance M0/M1 rejeitada;
5. Investigation type incorreto bloqueado;
6. exatamente um target primário;
7. target Monitor→Monitor rejeitado;
8. depth mismatch rejeitado;
9. Question mismatch rejeitado;
10. baseline cutoff mismatch rejeitado;
11. dependency edge do target preservada;
12. MonitorDefinition é imutável;
13. somente um MonitorState ativo;
14. MonitorState append-preserving;
15. cycle_no único;
16. previous cycle deve ser do mesmo Monitor;
17. lifecycle temporal válido;
18. `no_update_needed` em cycle incomplete rejeitado;
19. terminal cycle é imutável;
20. Search só pode ligar ao cycle do mesmo Monitor;
21. Search não pode pertencer a dois cycles;
22. Search da Investigation científica do target não pode ser apropriada pelo Monitor;
23. EvidenceEvent exige fonte rastreável;
24. ReportRelation compatibility é validada;
25. AI não pode human-verify event;
26. Candidate origin polymorphism é válido;
27. SearchHit candidate deve pertencer ao mesmo cycle;
28. event candidate deve pertencer ao mesmo cycle;
29. direct entity candidate aceita somente Report/Study;
30. excluded candidate exige reason;
31. retained candidate exige impact class;
32. AI não pode human-verify candidate;
33. apenas uma candidate assessment ativa por origem/cycle;
34. cycle completo com pending candidate bloqueia;
35. cycle completo sem required source coverage bloqueia;
36. CycleCurrencyState target mismatch rejeitado;
37. decision↔currency mapping é validado;
38. no-update pode renovar CurrencyState current sem nova ProductVersion;
39. update recommended não altera conclusão do target;
40. new target ProductVersion não é criada automaticamente;
41. target superseded é detectado;
42. Monitor Product currency permanece distinta da target currency;
43. assurance do target não é copiada;
44. A1 Monitor interno continua não publicável;
45. A2 M2 formal pode ser publicável;
46. A3 não é obrigatória para M2 v0.1;
47. M3 continua bloqueado antes da Fase 4;
48. invalidated dependency bloqueia publicação;
49. no expert review produz warning, não falso PASS humano;
50. rebuild-from-zero preserva estado;
51. migration 021 é idempotente;
52. regressões N0–N4/Mapa/Overview permanecem verdes.

---

# 57. Critérios de PASS para migration 021

Migration 021 somente poderá ser considerada validada se:

- todas as oito estruturas existirem com constraints;
- guards de target/cycle/search/event/candidate/currency passarem;
- nenhum objeto científico canônico for duplicado;
- nenhum existing Search/Screening contract for enfraquecido;
- M2 e M3 permanecerem distintos;
- M3 formal continuar bloqueado;
- assurance A0–A3 continuar com semântica existente;
- nenhum controle humano puder ser fabricado por actor_type inconsistente;
- rebuild e regressões passarem.

---

# 58. Migration candidata

Fica autorizada:

> `database/021_evidence_monitor_contract.sql`

Escopo:

- schema `maintenance`;
- oito estruturas v0.1;
- constraints/indexes;
- guards;
- helpers de cycle/source/currentness;
- publication issues/gate do Monitor;
- sem View completa ainda, salvo helper mínimo estritamente necessário.

Não deverá:

- alterar SearchHit para aceitar novo tipo;
- alterar ScreeningDecision target types;
- alterar `product.currency_state`;
- alterar `version_change_class`;
- implementar Alert;
- criar thresholds globais da Fase 4.

---

# 59. Próxima etapa

> **Implementar migration 021 + fixture sintética M2/M3 + testes de contrato + regressões/rebuild.**

Somente após PASS técnico:

> **avaliar Projection Readiness da EvidenceMonitorView.**

---

**Decisão do contrato:** **DATA_CONTRACT_V0_1_READY_FOR_IMPLEMENTATION**.
