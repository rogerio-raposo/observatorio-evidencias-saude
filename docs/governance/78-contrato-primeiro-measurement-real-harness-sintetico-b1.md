# 78 — Contrato Operacional do Primeiro Measurement Real e Plano de Harness Sintético Pós-Activation

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **SPECIFIED — IMPLEMENTATION_NOT_STARTED**  
**Modo:** alto  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1  
**Dependências:** Documentos 51, 61, 69–70, 76–77; migrations 033–035; CP124  
**Objeto:** congelar o contrato operacional do primeiro measurement real e o plano de validação sintética do caminho pós-activation, sem executar qualquer Opportunity real.

## 1. Decisão

O OES adota para o primeiro measurement real do B1 um caminho explicitamente separado em duas fases:

1. **activation factual do Epoch B1**;
2. **measurement real de uma Opportunity congelada**.

A activation não cria MeasurementEvent.

O primeiro MeasurementEvent somente pode nascer de uma tentativa real na primeira Opportunity congelada aplicável.

> **ACTIVATION ≠ MEASUREMENT**

> **FIRST_REAL_MEASUREMENT = SOURCE-SPECIFIC OPPORTUNITY EXECUTION**

## 2. Preconditions do primeiro measurement

Antes de qualquer primeira tentativa real, devem estar simultaneamente verdadeiros:

- B1 = `active`;
- `started_at` factual e dentro da activation interval;
- zero MeasurementEvent criado pela activation;
- exact target ainda current;
- authority operacional ainda válida;
- controlling Artifacts ativos;
- frozen opportunity set íntegro;
- ausência de deviation `new_epoch_required` ou `invalidating`;
- Opportunity-alvo existente e não resolvida;
- source/query/interface correspondentes ao frozen design;
- relógio factual no contexto da Opportunity real.

Qualquer falha bloqueia a execução.

## 3. PubMed Opportunity #1

Primeira Opportunity PubMed:

`2026-10-19T09:00:00-03:00`

Semântica da primeira observação bem-sucedida:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

No primeiro evento bem-sucedido da source:

- `novelty_state = not_applicable`;
- `new_identifier_count = NULL`.

Isto é obrigatório mesmo que identifiers sejam materializados.

A razão é que não existe observação anterior do Epoch contra a qual novidade interna possa ser inferida.

## 4. Semântica de item no primeiro evento

`item_state = new_to_epoch` significa exclusivamente:

> identifier ainda não observado anteriormente neste Epoch.

Não significa:

- novo desde o evidence cutoff;
- novo na literatura;
- novo desde a publicação do produto;
- scientific novelty;
- material scientific change.

Logo:

> **SOURCE NOVELTY ≠ SCIENTIFIC NOVELTY**

## 5. Aggregate event semantics

A persistência em `maintenance.temporal_measurement_event` deve usar somente valores suportados pelo schema.

Campos mínimos factuais:

- exact `measurement_opportunity_uuid`;
- `attempt_no`;
- `execution_status`;
- `execution_started_at`;
- `execution_completed_at`, quando conhecido;
- `novelty_state`;
- `raw_result_count`, somente quando realmente conhecido;
- `raw_result_count_status`;
- `materialized_identifier_count`, quando mensurável;
- `new_identifier_count` conforme semântica aplicável;
- `failure_attribution`;
- `effort_payload`;
- operator;
- actor_type.

Não preencher NULL factual com zero.

## 6. Raw result count

`raw_result_count_status = known` somente quando a interface/execução suportar contagem confiável.

Caso contrário:

- `raw_result_count = NULL`;
- `raw_result_count_status = unknown` ou `not_applicable`, conforme o caso.

> **UNKNOWN ≠ ZERO**

Empty result somente pode ser interpretado como zero quando a execução provar que a resposta é completa e semanticamente contável.

## 7. Failure attribution

Valores físicos permitidos:

- `source_confirmed`;
- `oes_confirmed`;
- `mixed`;
- `unknown`;
- `not_applicable`.

Regras:

- `source_confirmed` exige evidência externa suficiente de falha da source/interface;
- `oes_confirmed` exige evidência suficiente de falha local/OES;
- `mixed` exige evidência de contribuição de ambas;
- `unknown` quando causalidade não puder ser atribuída com segurança;
- `not_applicable` para execução sem failure.

Não inferir source failure apenas porque a requisição não retornou resultado útil.

## 8. Failure evidence

Quando `failure_attribution` for `source_confirmed` ou `mixed`:

- `failure_evidence_artifact_uuid` é obrigatório pelo schema.

Mesmo quando não obrigatório fisicamente, toda falha real relevante deve preservar, quando possível:

- request metadata não sensível;
- response/status;
- timestamp;
- interface/config version;
- retry evidence;
- local execution logs;
- evidence locator.

Secrets e tokens nunca devem ser persistidos.

## 9. Attempts

Cada execução real contra uma Opportunity cria uma tentativa factual.

`attempt_no` é monotônico por Opportunity.

Não criar retry fictício.

Retry somente ocorre após tentativa real precedente.

A política de retries não pode transformar uma Opportunity finita em scheduler contínuo.

## 10. Opportunity resolution

A Opportunity deve ser resolvida somente quando houver base factual para estado terminal.

Estados físicos disponíveis:

- `completed`;
- `failed_closed`;
- `not_executed`;
- `indeterminate_closed`;
- `invalidated`.

A resolução deve referenciar o terminal MeasurementEvent quando aplicável.

Ausência de execução não cria MeasurementEvent.

> **MISSED OPPORTUNITY ≠ FAILED MEASUREMENT EVENT**

## 11. Measurement items

Cada identifier materializado deve preservar:

- `source_identifier`;
- source locator, quando disponível;
- `item_state`;
- `oes_detected_at`;
- source record Artifact, quando aplicável.

No primeiro successful event de uma source, identifiers materializados podem ser `new_to_epoch`, mas o aggregate permanece `novelty_state = not_applicable`.

## 12. Source timepoints

Timepoints devem registrar somente semânticas realmente disponibilizadas pela source e frozen no source semantics payload.

Preservar:

- semantic_code;
- source_field;
- raw_value;
- precision;
- timezone_name quando aplicável;
- lower/upper bounds;
- observability_status;
- provenance Artifact.

Date-only não pode ser transformada em exact timestamp.

## 13. Incidental scientific finding

Se a execução encontrar registro potencialmente relevante:

1. preservar o registro e provenance;
2. concluir o measurement conforme o contrato temporal;
3. encaminhar o finding ao workflow canônico de triage/update;
4. não criar UpdateSignal automaticamente;
5. não alterar conclusion/currentness/assurance automaticamente.

> **MEASUREMENT PATH AND SCIENTIFIC UPDATE PATH REMAIN SEPARATE**

## 14. No automatic signal

Nenhum MeasurementEvent, MeasurementItem ou OpportunityResolution pode, por si só:

- criar UpdateSignal;
- alterar UpdateRiskProfile;
- alterar cadence;
- criar SLA;
- alterar currentness;
- alterar assurance;
- reclassificar M1 para M2;
- abrir Calibration Dossier automaticamente.

## 15. Effort payload

`effort_payload` pode conter apenas campos aceitos pelo validator atual:

- `operator_minutes`;
- `machine_elapsed_seconds`;
- `retry_count`;
- `handoff_count`;
- `note`.

Esses valores são evidência operacional experimental.

Não são sustainable capacity por definição.

## 16. Deviations

Devem ser registradas quando factual e relevante:

- execution_delay;
- source_access;
- runtime_change;
- query_change;
- interface_change;
- source_scope_change;
- authority_change;
- data_governance;
- other.

Materialidade:

- non_material;
- new_epoch_required;
- invalidating.

Nenhum material change pode ser absorvido silenciosamente.

## 17. Primeiro ClinicalTrials.gov measurement

A mesma arquitetura se aplica à primeira Opportunity ClinicalTrials.gov.

Entretanto, a primeira execução da source também é baseline acquisition.

Logo, a primeira successful observation dessa source deve igualmente usar:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

com:

- aggregate novelty_state = not_applicable;
- new_identifier_count = NULL.

A baseline é source-specific, não apenas epoch-global.

## 18. Test harness sintético pós-activation

Antes de 19/10, deve ser implementado um harness exclusivamente sintético, sem atingir PubMed ou ClinicalTrials.gov reais e sem modificar o B1 real.

Nome proposto:

`database/f4-temporal-first-measurement-tests.sql`

Suite proposta:

> **FM-T01–T24**

## 19. Cenários FM-T01–T24

### Preconditions e lifecycle

- FM-T01 — measurement antes de epoch active = reject;
- FM-T02 — measurement em Opportunity inexistente = reject;
- FM-T03 — measurement em Opportunity já resolvida = reject;
- FM-T04 — attempt_no duplicado = reject.

### Baseline semantics

- FM-T05 — primeiro successful event da source aceita `novelty_state=not_applicable`;
- FM-T06 — baseline event exige `new_identifier_count IS NULL`;
- FM-T07 — `new_to_epoch` item não promove aggregate para scientific novelty;
- FM-T08 — segunda observação da mesma source pode usar novelty semantics apenas contra histórico do epoch.

### Counts

- FM-T09 — known raw count exige valor não NULL;
- FM-T10 — unknown raw count exige NULL;
- FM-T11 — zero_new exige `new_identifier_count=0`;
- FM-T12 — new_items exige `new_identifier_count>0`.

### Failure attribution

- FM-T13 — source_confirmed sem failure Artifact = reject;
- FM-T14 — mixed sem failure Artifact = reject;
- FM-T15 — failed + unknown attribution permanece representável;
- FM-T16 — successful execution usa failure_attribution=not_applicable.

### Items/timepoints

- FM-T17 — duplicate source_identifier no mesmo event = reject;
- FM-T18 — date-only source field preserva precision=day/bounded;
- FM-T19 — not_observable não recebe bounds;
- FM-T20 — oes_detected_at é factual e independente de source timestamp.

### Opportunity closure e anti-laundering

- FM-T21 — missed Opportunity pode ser `not_executed` sem MeasurementEvent;
- FM-T22 — completed resolution referencia terminal event aplicável;
- FM-T23 — nenhuma execução sintética cria UpdateSignal/CadenceObservation/MonitorCycle;
- FM-T24 — harness deixa B1 real com zero MeasurementEvent/OpportunityResolution.

## 20. Synthetic isolation

O harness deverá usar UUID namespace sintético próprio e target sintético.

É proibido:

- usar UUIDs do B1 real em inserts de measurement;
- executar target-specific queries reais;
- alterar status do B1;
- criar measurement no B1;
- criar OpportunityResolution no B1.

O teste final deve provar explicitamente:

> **REAL_B1_NON_MUTATION = PASS**

## 21. Necessidade de migration

Neste checkpoint:

> **NEW_SCHEMA_MIGRATION_REQUIRED = NO**

O schema 033b/033c já comporta o contrato.

Se durante implementação surgir necessidade de alterar guard ou helper, isso deve ser tratado como decisão separada e não presumido neste documento.

## 22. Integração CI proposta

Após implementação e revisão:

- integrar FM-T01–T24 ao `validate-s5.yml`;
- preservar migrations 033–035;
- executar idempotência relevante;
- rebuild-from-zero;
- regressões anteriores;
- prova explícita de zero mutation no B1 real.

Não executar network call real na CI.

## 23. Critério de readiness para 19/10

O primeiro measurement real somente estará tecnicamente pronto se:

- Documento 78 estiver vigente;
- FM-T01–T24 = PASS;
- regressões = PASS;
- rebuild = PASS;
- B1 real = zero events antes da activation;
- Documento 77 continuar válido;
- nenhuma mudança material de source/query/interface tiver ocorrido.

Isso não substitui Freshness Gate nem live activation preflight.

## 24. Boundaries preservadas

Continuam proibidos antes de evidência real:

- normative cadence;
- SLA;
- M3 formalization;
- calibration recommendation;
- hidden minimum N;
- favorable stopping;
- automatic extension;
- automatic UpdateSignal;
- automatic conclusion/currentness/assurance change.

## 25. Próximo passo

Após este documento:

> **implementar FM-T01–T24 em modo médio, integrar ao S5 e validar em CI, sem tocar no B1 real.**

Se qualquer teste exigir mudança semântica do contrato ou migration nova:

> **parar e retornar a modo alto.**

**Fim do Documento 78**
