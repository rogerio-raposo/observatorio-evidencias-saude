# 88 — Runbook Operacional das Medições Reais do Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **READY_FOR_REAL_OPPORTUNITY_EXECUTION — ACTIVATION_STILL_PENDING**  
**Modo:** médio  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 77–87; migrations 033–036; CP131  
**Objeto:** definir a execução operacional das Opportunities reais de PubMed e ClinicalTrials.gov já congeladas, sem alterar metodologia, source scope, query, interface, schedule ou authority.

## 1. Escopo

Este runbook começa a valer operacionalmente somente quando:

- B1R1 = `active`;
- `started_at` tiver sido persistido factualmente dentro da activation interval;
- a Opportunity correspondente tiver alcançado seu timestamp real;
- Freshness Gate e live preflight aplicáveis não apontarem blocker.

Este documento:

- não ativa o B1R1;
- não cria MeasurementEvent antecipado;
- não executa source query antes do timestamp da Opportunity;
- não altera query/interface/schedule;
- não cria novos status físicos;
- não substitui os guards do banco.

## 2. Estado controlador

B1R1:

- Epoch UUID: `b3120000-0000-0000-0000-000000000002`;
- status antes de 19/10: `authorized_non_normative`;
- started_at: NULL;
- execution authority: approved;
- design_frozen_at: `2026-10-08T19:48:20-03:00`.

PubMed EpochSource:

`b3130000-0000-0000-0000-000000000003`

ClinicalTrials.gov EpochSource:

`b3130000-0000-0000-0000-000000000004`

## 3. Opportunity sets congelados

### PubMed

1. `b3140000-0000-0000-0000-000000000015` — 2026-10-19 09:00 -03
2. `b3140000-0000-0000-0000-000000000016` — 2026-10-20 09:00 -03
3. `b3140000-0000-0000-0000-000000000017` — 2026-10-22 09:00 -03
4. `b3140000-0000-0000-0000-000000000018` — 2026-10-26 09:00 -03
5. `b3140000-0000-0000-0000-000000000019` — 2026-10-29 09:00 -03
6. `b3140000-0000-0000-0000-000000000020` — 2026-11-03 09:00 -03
7. `b3140000-0000-0000-0000-000000000021` — 2026-11-06 09:00 -03
8. `b3140000-0000-0000-0000-000000000022` — 2026-11-09 09:00 -03

### ClinicalTrials.gov

1. `b3140000-0000-0000-0000-000000000023` — 2026-10-19 10:30 -03
2. `b3140000-0000-0000-0000-000000000024` — 2026-10-22 10:30 -03
3. `b3140000-0000-0000-0000-000000000025` — 2026-10-27 10:30 -03
4. `b3140000-0000-0000-0000-000000000026` — 2026-10-30 10:30 -03
5. `b3140000-0000-0000-0000-000000000027` — 2026-11-04 10:30 -03
6. `b3140000-0000-0000-0000-000000000028` — 2026-11-09 10:30 -03

Nenhum timestamp pode ser deslizado.

## 4. Preflight imediato de cada Opportunity

Antes de iniciar uma tentativa real:

1. confirmar hora factual America/Recife;
2. confirmar que B1R1 está `active`;
3. confirmar que `started_at` existe e pertence à activation interval;
4. confirmar que target continua current;
5. confirmar authority operacional ainda aprovada;
6. confirmar Opportunity exata e não resolvida;
7. confirmar source/query/interface artifacts ativos;
8. confirmar ausência de deviation `new_epoch_required` ou `invalidating`;
9. confirmar que a request a ser executada coincide com o frozen interface artifact;
10. confirmar que `attempt_no` esperado é `max(attempt_no)+1`.

Se qualquer item falhar:

> **DO NOT EXECUTE SOURCE REQUEST**

Registrar deviation/evidência factual quando aplicável.

## 5. Regra de início da tentativa

`execution_started_at` deve ser o instante factual imediatamente associado ao início da tentativa real.

Não usar:

- timestamp da Opportunity como substituto;
- timestamp pré-escrito;
- timestamp retroativo;
- timestamp do scheduler.

A primeira tentativa usa:

> **attempt_no = 1**

Retries reais usam sequência contígua:

> **2, 3, ...**

Nunca criar retry fictício.

## 6. PubMed — request congelada

Artifact:

`artifacts/topi-n2-dcbti-01/phase-b/pubmed-interface-v2.json`

Interface:

- base: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/`;
- utility: `esearch.fcgi`;
- method: GET;
- `db=pubmed`;
- `term` = conteúdo integral de `pubmed-query-v1.txt`;
- `retmode=json`;
- `retmax=10000`.

Proibido:

- relative date filter;
- data cutoff ad hoc;
- termo extra;
- remoção de termo;
- filtro por tipo não contido na query congelada;
- alteração do source scope.

## 7. PubMed — completude

Após a resposta ESearch:

- capturar `count`;
- capturar o PMID idlist;
- confirmar parse bem-sucedido;
- comparar cardinalidade do idlist com o conjunto recuperável.

Completed somente se:

- request completou;
- resposta foi parseada;
- `count <= 10000`;
- todos os PMIDs esperados foram materializados.

Se `count > 10000`:

> **FAIL CLOSED**

Não:

- segmentar a query silenciosamente;
- acrescentar datas;
- alterar retmax além do contrato;
- fingir completude.

O evento deverá refletir falha/indeterminação factual e, se materialmente necessário, deviation.

## 8. ClinicalTrials.gov — request congelada

Artifact:

`artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v2.json`

Request:

- endpoint: `https://clinicaltrials.gov/api/v2/studies`;
- method: GET;
- `query.cond=insomnia`;
- `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- `format=json`;
- `pageSize=10`.

Proibido adicionar:

- status filter;
- phase filter;
- location filter;
- intervention filter;
- sort;
- date filter;
- termo científico adicional.

## 9. ClinicalTrials.gov — paginação

Primeira página:

- executar sem `pageToken`.

Enquanto a resposta contiver `nextPageToken`:

- usar exatamente esse token como `pageToken` da página seguinte;
- preservar os mesmos parâmetros científicos;
- continuar até ausência de novo token.

Completed somente se:

- todas as páginas forem recebidas;
- todas forem parseadas;
- nenhum token esperado ficar sem seguimento;
- o conjunto final de NCT IDs estiver materializado.

Se paginação interromper:

> **execution_status != completed**

e:

> **raw_result_count_status = unknown**

a menos que haja prova independente e confiável de cardinalidade completa.

## 10. Identidade do conjunto observado

PubMed:

> **source_identifier = PMID**

ClinicalTrials.gov:

> **source_identifier = NCT ID**

O conjunto observado de uma Opportunity é definido pelos identifiers efetivamente recuperados sob a request congelada.

Não usar título como identifier.

## 11. Primeira successful observation por source

Migration 036 aplica a regra fisicamente.

Na primeira `execution_status=completed` de cada EpochSource:

- `novelty_state = not_applicable`;
- `new_identifier_count = NULL`;
- `failure_attribution = not_applicable`.

Isso vale independentemente da quantidade de identifiers encontrados.

É baseline acquisition, não declaração de novidade científica.

## 12. Observações completed subsequentes

A partir do segundo completed event da mesma source:

- `not_applicable` é proibido;
- usar `zero_new`, `new_items` ou `unknown` factualmente.

Se nenhum identifier novo no Epoch:

- `novelty_state = zero_new`;
- `new_identifier_count = 0`.

Se houver identifiers ainda não observados no Epoch:

- `novelty_state = new_items`;
- `new_identifier_count > 0`.

Se não for possível determinar novelty de forma segura:

- `novelty_state = unknown`;
- não fabricar contagem.

## 13. raw_result_count

Usar:

> **raw_result_count_status = known**

somente quando a execução provar cardinalidade completa.

Nesse caso:

- `raw_result_count` deve ser não-NULL.

Se cardinalidade não for confiável:

> **raw_result_count_status = unknown**

e:

- `raw_result_count = NULL`.

UNKNOWN nunca significa zero.

## 14. materialized_identifier_count

Registrar a cardinalidade dos identifiers efetivamente materializados no evento.

Não igualar automaticamente:

- raw result count;
- materialized identifier count;
- new identifier count.

Cada campo expressa conceito diferente.

## 15. MeasurementItem

Para cada identifier materializado em evento `completed` ou `partial`:

- criar um `MeasurementItem`;
- preencher `source_identifier`;
- usar `source_locator` quando disponível;
- preencher `oes_detected_at` com instante factual de detecção OES;
- ligar `source_record_artifact_uuid` quando snapshot do record for preservado.

`item_state`:

- `new_to_epoch`: identifier nunca observado antes no Epoch;
- `reobserved`: identifier já observado e sem evidência de record update;
- `updated_record`: identifier já observado e record factual mudou;
- `indeterminate`: estado não determinável com segurança.

O guard impede classificar identifier previamente visto como `new_to_epoch`.

## 16. Minimal source record — ClinicalTrials.gov

Quando disponíveis, preservar:

- NCTId;
- BriefTitle;
- OverallStatus;
- StudyFirstPostDate;
- ResultsFirstPostDate;
- LastUpdatePostDate.

Não é necessário persistir payload clínico integral.

O snapshot preservado deve ser suficiente para:

- identifier provenance;
- update comparison;
- source timepoint provenance;
- auditoria posterior.

## 17. PubMed source record

Preservar, no mínimo, informação suficiente para:

- PMID;
- locator PubMed;
- provenance do identifier;
- source temporal fields quando posteriormente consultados/observáveis;
- comparação factual quando houver record update.

Não inferir data temporal não retornada/observada.

## 18. Timepoints

Usar apenas `semantic_code` declarado pela source.

Para date-only:

- preservar raw value;
- usar `precision=day`;
- usar bounds correspondentes ao dia quando a semântica for bounded;
- não converter arbitrariamente em timestamp exato.

Se um timepoint não puder ser observado:

- `observability_status=not_observable`;
- bounds = NULL.

`oes_detected_at` permanece separado de qualquer source timestamp.

## 19. Artifacts da execução

Quando materialmente disponíveis, preservar como Artifact:

- query/request snapshot;
- result/response snapshot;
- identifier set;
- failure evidence;
- source documentation relevante.

Em `temporal_measurement_event_artifact`, usar os roles físicos existentes:

- `query_snapshot`;
- `result_snapshot`;
- `identifier_set`;
- `failure_evidence`;
- `source_documentation`;
- `other`.

Não armazenar credenciais, tokens secretos ou headers sensíveis.

## 20. Failure attribution

Valores físicos:

- `source_confirmed`;
- `oes_confirmed`;
- `mixed`;
- `unknown`;
- `not_applicable`.

Completed:

> **failure_attribution = not_applicable**

Falha claramente evidenciada pela source:

> **source_confirmed**

Falha claramente local/OES:

> **oes_confirmed**

Evidência de ambos:

> **mixed**

Sem atribuição segura:

> **unknown**

`source_confirmed` e `mixed` exigem `failure_evidence_artifact_uuid`.

## 21. execution_status

### completed

Usar somente quando a execução da source estiver integralmente completa segundo o contrato da interface.

### partial

Usar quando houve obtenção factual de parte do conjunto/records, mas não completude suficiente para `completed`.

Items podem ser persistidos.

### failed

Usar quando a tentativa falhou de forma factual e não produziu execução completa.

### indeterminate

Usar quando o estado de execução não puder ser classificado com segurança como completed/partial/failed.

Não converter ambiguidade em completed.

## 22. Retries

Retry é permitido apenas após tentativa real não completed.

Antes de retry:

- preservar a tentativa anterior;
- preservar evidence relevante;
- incrementar `attempt_no` exatamente em 1;
- não editar evento anterior.

Um evento completed encerra retries daquela Opportunity.

## 23. OpportunityResolution

A resolução é separada do MeasurementEvent.

### completed

Exige terminal MeasurementEvent `completed`.

### failed_closed

Exige terminal MeasurementEvent `failed`.

### indeterminate_closed

Exige terminal MeasurementEvent `indeterminate`.

### not_executed

Somente quando não existe nenhuma tentativa.

Não criar MeasurementEvent falso para justificar `not_executed`.

### invalidated

Somente quando o Epoch estiver fisicamente `invalidated`.

## 24. Quando fechar uma Opportunity

Fechar quando:

- existe completed terminal;
- decisão operacional factual encerra failed attempt;
- decisão factual encerra indeterminate attempt;
- Opportunity foi realmente perdida sem tentativa e deve ser registrada como not_executed.

Não fechar preventivamente.

Não usar resolution como scheduler acknowledgement.

## 25. Delay

Se a execução iniciar após o timestamp congelado, mas ainda for uma tentativa factual da mesma Opportunity:

- não alterar `planned_for`;
- registrar `execution_started_at` real;
- avaliar deviation type `execution_delay`;
- materiality deve refletir o caso factual.

O runbook não cria tolerância temporal normativa automática.

## 26. Runtime/interface change

Se source/API/interface apresentar mudança material em relação ao frozen artifact:

- interromper antes de adaptar a request;
- preservar evidence;
- registrar deviation apropriada;
- não corrigir silenciosamente.

Se materiality = `new_epoch_required` ou `invalidating`:

> **DO NOT CONTINUE CURRENT EPOCH EXECUTION**

## 27. Query drift

Qualquer necessidade percebida de:

- adicionar termo;
- remover termo;
- alterar campo;
- adicionar filtro;
- segmentar query;
- modificar source scope;

é query/interface/source-scope drift.

Não executar sob B1R1 sem novo gate.

## 28. Effort payload

Somente campos já permitidos pelo validator:

- `operator_minutes`;
- `machine_elapsed_seconds`;
- `retry_count`;
- `handoff_count`;
- `note`.

Esses dados são evidência operacional experimental.

Não convertê-los automaticamente em:

- sustainable capacity;
- SLA;
- cadence normativa;
- staffing requirement.

## 29. Sequência transacional recomendada

Para uma tentativa factual:

1. executar source request e preservar evidence externa antes de escrever event;
2. determinar status factual;
3. criar/ativar Artifacts necessários;
4. inserir MeasurementEvent;
5. inserir MeasurementItems aplicáveis;
6. inserir item timepoints observáveis;
7. ligar event Artifacts;
8. inserir deviation se aplicável;
9. inserir OpportunityResolution somente quando factual e terminal;
10. consultar replay/readiness views para pós-validação.

A ordem deve respeitar FKs/guards.

## 30. Pós-validação de uma tentativa

Confirmar:

- event pertence à Opportunity correta;
- attempt_no contíguo;
- timestamps coerentes;
- baseline semantics correta;
- counts coerentes;
- identifiers únicos no evento;
- item_state coerente com histórico do Epoch;
- timepoints com precision/observability corretos;
- failure Artifact obrigatório presente quando necessário;
- nenhum UpdateSignal automático;
- nenhuma cadence/SLA alterada.

## 31. Vistas de auditoria

Usar, quando aplicável:

`maintenance.temporal_measurement_replay_v`

para revisar:

- opportunity status;
- attempt count;
- last execution status;
- last novelty state;
- item count;
- timepoint count;
- resolution.

Usar:

`maintenance.temporal_measurement_readiness_evidence_v`

para agregação de readiness do Epoch.

Essas views não substituem inspeção de evidence artifacts.

## 32. Scientific triage boundary

Se a observação revelar material potencialmente relevante:

> **observation → provenance → canonical triage/update workflow**

Nunca:

> **observation → automatic scientific conclusion change**

MeasurementEvent/Item não pode sozinho:

- criar UpdateSignal automático;
- alterar currentness;
- alterar assurance;
- promover M1→M2;
- abrir Calibration Dossier;
- modificar recomendação científica.

## 33. Primeira Opportunity PubMed — checklist específico

Timestamp:

`2026-10-19T09:00:00-03:00`

Opportunity UUID:

`b3140000-0000-0000-0000-000000000015`

Como será a primeira successful observation PubMed se completed:

- attempt_no = 1;
- novelty_state = not_applicable;
- new_identifier_count = NULL;
- failure_attribution = not_applicable.

Se não completed:

- essa tentativa não estabelece successful baseline;
- a próxima future completed observation PubMed continuará sendo a baseline da source.

## 34. Primeira Opportunity ClinicalTrials.gov — checklist específico

Timestamp:

`2026-10-19T10:30:00-03:00`

Opportunity UUID:

`b3140000-0000-0000-0000-000000000023`

Se for a primeira completed observation da source:

- novelty_state = not_applicable;
- new_identifier_count = NULL;
- failure_attribution = not_applicable.

Uma completed PubMed anterior não elimina a baseline própria do ClinicalTrials.gov.

## 35. Missed Opportunity

Se nenhuma tentativa ocorrer:

- não criar MeasurementEvent;
- quando factual e apropriado, resolver como `not_executed`;
- registrar razão factual em `reason_code`;
- usar `reason_artifact_uuid` quando houver evidence material.

Missed Opportunity não equivale a failed MeasurementEvent.

## 36. Segurança contra backfill

É proibido, após perder o timestamp:

- inventar execution_started_at no passado;
- criar tentativa fictícia;
- reaproveitar resposta obtida em outro horário como se fosse execução original;
- ajustar planned_for;
- preencher opportunity retroativamente sem provenance factual.

## 37. Clock discipline

Todos os timestamps OES factuais devem derivar do relógio efetivamente observado no ato.

Não confundir:

- `planned_for`;
- `execution_started_at`;
- `execution_completed_at`;
- `oes_detected_at`;
- source publication/update time;
- `resolved_at`.

## 38. Evidência mínima em falha de acesso

Quando possível preservar:

- source;
- endpoint/interface;
- parâmetros não sensíveis;
- HTTP/status ou erro;
- timestamp;
- attempt number;
- runtime context;
- retry evidence;
- logs;
- locator da evidence.

Não preservar secrets/tokens.

## 39. Regra de não improvisação

Se uma situação real não estiver coberta por:

- schema;
- Documento 78;
- Documento 82;
- artifacts v2;
- este runbook;

e a decisão puder mudar semântica, source scope, completeness ou scientific interpretation:

> **STOP**

> **RETURN TO HIGH MODE**

> **DO NOT IMPROVISE**

## 40. Readiness do runbook

O runbook está operacionalmente pronto quando:

- B1R1 authority continua válida;
- artifacts v2 continuam ativos;
- migration 036 continua vigente;
- runbook não diverge do frozen design;
- activation ocorrer validamente;
- nenhuma mudança material de API/source surgir.

## 41. Próximo ato

Antes de 19/10:

> **nenhuma source query target-specific deve ser executada.**

Em 19/10:

1. activation do B1R1 em modo alto, se live preflight PASS;
2. checkpoint pós-activation;
3. às 09:00 -03, primeira Opportunity PubMed, em modo alto por ser o primeiro measurement real;
4. após validação do primeiro caminho real, execuções posteriores poderão ser reavaliadas quanto ao modo apropriado.

**Fim do Documento 88**
