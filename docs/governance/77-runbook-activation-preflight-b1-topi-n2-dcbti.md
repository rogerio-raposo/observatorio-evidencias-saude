# 77 — Runbook de Activation Preflight e Ativação do Epoch B1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **READY_FOR_LIVE_PREFLIGHT — ACTIVATION_NOT_YET_ALLOWED**  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1  
**Natureza:** operacional não normativa

## 1. Objetivo

Este runbook define o procedimento exato para a ativação futura do Epoch B1.

Ele não ativa o B1 em 8 de outubro de 2026.

Estado de entrada:

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MeasurementEvent = 0**

> **OpportunityResolution = 0**

## 2. Janela factual de ativação

Start boundary:

`2026-10-19T08:00:00-03:00`

First PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Logo:

> **ACTIVATION_INTERVAL = [2026-10-19T08:00:00-03:00, 2026-10-19T09:00:00-03:00)**

Antes da boundary:

> **WAIT**

A partir da primeira Opportunity:

> **FAIL / EXPIRED_NOT_EXECUTED**

Não existe deslocamento automático.

## 3. Migration 035

Arquivo:

`database/035_temporal_observation_activation_preflight.sql`

Função principal:

`maintenance.temporal_activation_preflight(epoch_uuid, as_of)`

Função agregadora:

`maintenance.temporal_activation_preflight_state(epoch_uuid, as_of)`

Estados possíveis:

- `PASS`;
- `WAIT`;
- `FAIL`.

A função é read-only.

Ela não:

- muda epoch_status;
- preenche started_at;
- cria MeasurementEvent;
- cria OpportunityResolution;
- executa source query;
- cria scheduler.

## 4. Checks do preflight

O preflight verifica explicitamente:

1. Epoch existe;
2. estado = `authorized_non_normative`;
3. exact target ainda current;
4. operational execution authority = approved no instante avaliado;
5. controlling Artifacts ativos;
6. runtime connectivity statuses frozen = verified;
7. payload↔Opportunity equality;
8. ausência de deviation `new_epoch_required` ou `invalidating`;
9. zero MeasurementEvent e zero OpportunityResolution antes da ativação;
10. relógio dentro da activation interval;
11. deferred source debt continua visível.

BVS/LILACS permanece debt informativa e não bloqueia B1 porque sua exclusão do B1 foi explicitamente aprovada e congelada.

## 5. Validação determinística

Testes:

`database/f4-temporal-activation-preflight-tests.sql`

Resultado:

> **APF-T01–T13 = PASS**

Cenários provados contra o B1 real reconstruído:

### 5.1 Pré-janela

As-of:

`2026-10-08T14:47:00-03:00`

Resultado:

> **WAIT**

Detail:

> **NOT_IN_ACTIVATION_WINDOW**

### 5.2 Janela elegível

As-of:

`2026-10-19T08:00:00-03:00`

Resultado:

> **PASS**

As-of:

`2026-10-19T08:30:00-03:00`

Resultado:

> **PASS**

### 5.3 Expiração

As-of:

`2026-10-19T09:00:00-03:00`

Resultado:

> **FAIL**

Detail:

> **EXPIRED_NOT_EXECUTED**

## 6. Evidência canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37819755672**

Run number:

> **219**

Validated HEAD:

`830fcad1e79b237c5c672c5bf8e19aad66d2711f`

Conclusion:

> **success**

Created:

`2026-10-08T17:51:14Z`

Completed:

`2026-10-08T17:52:05Z`

Evidence Artifact:

- ID: `11568343046`;
- name: `oes-s5-evidence-37819755672`;
- size: `263399 bytes`;
- digest:
  `sha256:73f147fca89833f944b1bbb55fda324afa005bd0f17e9ea3b29fdc46810d906b`;
- expires at: `2026-11-07T17:51:58Z`.

Run 219 confirmou:

- migration 035 install;
- APF-T01–T13;
- migration 035 re-apply sem mutação;
- B1 real authority state;
- preflight WAIT/PASS/FAIL;
- zero mutação pelo preflight;
- rebuild-from-zero;
- Final S5 status;
- regressões anteriores.

## 7. Procedimento em 19/10/2026

Na janela de ativação, executar na ordem:

### Etapa 1 — Freshness Gate do repositório

Confirmar:

- HEAD de `main`;
- README pointer;
- STATE;
- CHANGELOG;
- CP vigente;
- commits posteriores ao checkpoint;
- reconciliação de divergências.

### Etapa 2 — hora factual

Obter a hora local atual.

Não estimar.

Não usar timestamp preparado previamente.

### Etapa 3 — live preflight read-only

Executar:

`maintenance.temporal_activation_preflight(B1, CURRENT_TIMESTAMP)`

e:

`maintenance.temporal_activation_preflight_state(B1, CURRENT_TIMESTAMP)`.

Requisito:

> **state = PASS**

Qualquer `WAIT` ou `FAIL` bloqueia ativação.

### Etapa 4 — inspecionar checks individuais

Não confiar apenas no aggregate.

Confirmar especialmente:

- TARGET_CURRENT = PASS;
- AUTHORITY_STATE = PASS;
- CONTROLLING_ARTIFACTS = PASS;
- RUNTIME_CONNECTIVITY = PASS;
- OPPORTUNITY_SET = PASS;
- MATERIAL_DEVIATIONS = PASS;
- PRESTART_EVENT_STATE = PASS;
- ACTIVATION_WINDOW = PASS.

SOURCE_DEBT_VISIBILITY deve continuar INFO.

### Etapa 5 — criar o artifact factual de ativação

Somente depois do live preflight PASS:

criar um novo documento/Artifact registrando:

- actual observed activation timestamp;
- HEAD;
- checkpoint;
- exact Plan/Epoch UUIDs;
- preflight output;
- authority UUID;
- first Opportunity timestamp;
- zero-event state antes da ativação.

### Etapa 6 — materializar a ativação

Criar o SQL factual naquele momento.

O SQL deve persistir exatamente:

- `epoch_status = active`;
- `started_at = actual observed timestamp`.

Ele deve falhar se:

- o preflight não for PASS;
- o Epoch não estiver em `authorized_non_normative`;
- qualquer guard 033/034 rejeitar a transição.

### Etapa 7 — post-activation validation

Confirmar:

- B1 = active;
- started_at dentro da activation interval;
- authority approved at started_at;
- target current;
- opportunity sets iguais ao frozen payload;
- zero MeasurementEvent;
- zero OpportunityResolution.

Ativação não é measurement.

### Etapa 8 — checkpoint antes do primeiro measurement

Registrar novo checkpoint antes da primeira Opportunity sempre que operacionalmente possível.

O primeiro MeasurementEvent somente pode nascer de tentativa real na Opportunity PubMed #1.

## 8. Por que o SQL factual de ativação não é criado agora

O campo:

`started_at`

representa um fato operacional.

Criar hoje um arquivo que já declare um timestamp futuro como fato de ativação seria:

- fabricação temporal;
- incompatível com auditabilidade;
- incompatível com o guard fail-closed;
- risco de confundir scheduled opportunity com actual activation.

Portanto:

> **ACTIVATION_SQL = DEFERRED_UNTIL_LIVE_PREFLIGHT_PASS**

Pode existir runbook e lógica de preflight antecipadamente.

Não pode existir activation fact antecipado.

## 9. Primeiro measurement

A primeira Opportunity PubMed ocorre em:

`2026-10-19T09:00:00-03:00`

A primeira successful observation deve ser tratada como:

> **OBSERVED_EPOCH_BASELINE_ACQUISITION**

No aggregate event:

- `novelty_state = not_applicable`;
- `new_identifier_count = NULL`.

Item `new_to_epoch` significa somente ausência em observação anterior do epoch.

Não significa:

- novo desde evidence cutoff;
- nova evidência científica;
- mudança material.

## 10. Boundary científico

Qualquer finding incidental potencialmente relevante:

> source observation → provenance → canonical triage/update workflow

Não:

> source observation → automatic product update.

Nenhuma alteração automática de:

- conclusion;
- currentness;
- assurance.

## 11. Modo

> **HIGH MODE REQUIRED**

para:

- live activation;
- first PubMed measurement;
- first ClinicalTrials.gov measurement;
- validação das baseline semantics;
- primeira interpretação de source timepoints;
- primeira failure attribution, se houver.

Depois da estabilização comprovada do primeiro ciclo, oportunidades subsequentes podem ser avaliadas para execução em modo médio.

## 12. Estado ao final deste runbook

> **B1 = AUTHORIZED_NON_NORMATIVE**

> **LIVE_PREFLIGHT_IMPLEMENTATION = VALIDATED**

> **ACTIVATION = NOT_YET_ALLOWED**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3 = BLOCKED**

> **PHASE_5 = NOT_STARTED**

**Fim do Documento 77**
