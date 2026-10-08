# 91 — Runbook de Live Activation Preflight e Ativação do Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **READY_FOR_LIVE_PREFLIGHT — ACTIVATION_NOT_YET_ALLOWED**  
**Modo:** médio  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 82–90; migration 035; CP134  
**Objeto:** substituir operacionalmente o runbook histórico do B1 por um runbook específico do replacement B1R1.

## 1. Supersession operacional

O Documento 77 permanece histórico para o B1 original.

Para qualquer ato futuro de activation:

> **DOCUMENT_91_SUPERSEDES_DOCUMENT_77_OPERATIONALLY_FOR_ACTIVATION**

O Documento 77 não deve mais ser usado como runbook de activation do estado corrente.

## 2. Estado de entrada esperado

Antes da janela de activation:

> **B1 = invalidated**

> **B1R1 = authorized_non_normative**

> **B1R1 started_at = NULL**

> **B1R1 authority = approved**

> **MeasurementEvent count = 0**

> **OpportunityResolution count = 0**

Epoch UUID:

`b3120000-0000-0000-0000-000000000002`

Authority UUID:

`b3150000-0000-0000-0000-000000000002`

## 3. Janela factual

Start boundary:

`2026-10-19T08:00:00-03:00`

First PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Activation interval:

> **[2026-10-19T08:00:00-03:00, 2026-10-19T09:00:00-03:00)**

Antes:

> **WAIT**

Dentro:

> **PASS somente se todos os demais checks passarem**

A partir de 09:00:

> **FAIL / EXPIRED_NOT_EXECUTED**

## 4. Modo

Para o ato real:

> **HIGH MODE REQUIRED**

Isso inclui:

- Freshness Gate final;
- live preflight;
- interpretação de qualquer blocker;
- persistência factual de started_at;
- primeiro measurement real.

## 5. Freshness Gate em 19/10

Antes de qualquer preflight factual:

1. HEAD atual de `main`;
2. README pointer;
3. STATE;
4. CHANGELOG tail;
5. checkpoint vigente;
6. commits posteriores;
7. workflows/runs relevantes;
8. reconciliação de qualquer divergência.

Se houver mudança material após CP134/CP subsequente:

> **STOP AND RECONCILE BEFORE ACTIVATION**

## 6. Hora factual

Obter a hora real America/Recife no momento da operação.

Não:

- estimar;
- usar hora da conversa;
- usar timestamp pré-calculado;
- usar start boundary como fato.

## 7. Live preflight

Executar:

`maintenance.temporal_activation_preflight(
  'b3120000-0000-0000-0000-000000000002',
  CURRENT_TIMESTAMP
)`

e:

`maintenance.temporal_activation_preflight_state(
  'b3120000-0000-0000-0000-000000000002',
  CURRENT_TIMESTAMP
)`

Requisito:

> **aggregate state = PASS**

## 8. Checks individuais obrigatórios

Inspecionar explicitamente:

- EPOCH_EXISTS = PASS;
- EPOCH_STATUS = PASS;
- TARGET_CURRENT = PASS;
- AUTHORITY_STATE = PASS;
- CONTROLLING_ARTIFACTS = PASS;
- RUNTIME_CONNECTIVITY = PASS;
- OPPORTUNITY_SET = PASS;
- MATERIAL_DEVIATIONS = PASS;
- PRESTART_EVENT_STATE = PASS;
- ACTIVATION_WINDOW = PASS;
- SOURCE_DEBT_VISIBILITY = INFO.

Não ativar olhando apenas o aggregate state.

## 9. Controlling Artifacts esperados

Entre os artifacts controladores do B1R1 devem permanecer ativos:

- Plan specification artifact;
- measurement design B1R1;
- source definitions;
- PubMed query;
- PubMed interface v2;
- PubMed schedule;
- ClinicalTrials query v2;
- ClinicalTrials interface v2;
- ClinicalTrials schedule;
- decision Artifact do Documento 86.

Qualquer inactive/missing:

> **FAIL**

## 10. Connectivity

O frozen status atual é `verified`.

Isso não autoriza ignorar fato novo evidente de quebra de interface.

Se houver mudança material observada antes da activation:

- preservar evidence;
- registrar deviation quando aplicável;
- não ativar se isso quebrar o frozen execution path.

## 11. Opportunity equality

Os 14 timestamps materializados devem continuar iguais ao frozen schedule payload.

PubMed: 8.

ClinicalTrials.gov: 6.

Qualquer mismatch:

> **FAIL**

Não corrigir in place durante live activation.

## 12. Material deviations

Se existir deviation com:

- `new_epoch_required`;
- `invalidating`;

registrada até o instante do preflight:

> **FAIL**

Não ignorar deviation por pressão temporal.

## 13. Prestart state

Antes de activation:

> **MeasurementEvent = 0**

> **OpportunityResolution = 0**

Se qualquer row existir:

> **FAIL**

Activation não é measurement.

## 14. Activation artifact factual

Somente após live preflight PASS, criar um novo Artifact/documento factual contendo:

- timestamp real observado;
- HEAD;
- checkpoint;
- Plan UUID;
- B1R1 Epoch UUID;
- authority UUID;
- design_frozen_at;
- first Opportunity timestamp;
- output integral do preflight;
- aggregate preflight state;
- zero-event/zero-resolution proof;
- operator/actor;
- mode = high.

## 15. SQL factual de activation

Somente depois do activation Artifact existir.

O SQL deve:

1. verificar que B1R1 ainda está `authorized_non_normative`;
2. repetir/confirmar preflight PASS no timestamp factual;
3. persistir:
   - `epoch_status='active'`;
   - `started_at=<actual observed timestamp>`;
4. não criar MeasurementEvent;
5. não criar Resolution;
6. falhar fechado se o estado tiver mudado.

## 16. started_at

`started_at` é fato operacional.

Deve:

- ser >= start boundary;
- ser < first Opportunity;
- corresponder ao instante real de activation.

Não pode ser:

- timestamp futuro;
- timestamp retroativo;
- rounded planned time usado por conveniência.

## 17. Post-activation validation

Confirmar imediatamente:

- B1 = invalidated;
- B1R1 = active;
- started_at dentro da interval;
- authority approved at started_at;
- target current;
- opportunity sets intactos;
- controlling artifacts ativos;
- zero MeasurementEvent;
- zero OpportunityResolution;
- zero material deviation bloqueante.

## 18. Checkpoint pós-activation

Criar checkpoint antes da primeira PubMed Opportunity sempre que o tempo operacional permitir.

Esse checkpoint deve registrar:

- exact started_at;
- preflight evidence;
- activation Artifact;
- activation SQL commit;
- validation result;
- zero-event state.

## 19. Se activation ocorrer perto de 09:00

Não sacrificar validação para “caber” na janela.

Se não houver tempo factual suficiente para concluir corretamente antes de 09:00:

> **DO NOT ACTIVATE**

Não backdate started_at.

## 20. Se relógio chegar a 09:00 sem activation válida

Estado:

> **EXPIRED_NOT_EXECUTED**

Ação:

- não ativar;
- não mover Opportunity;
- não mover start boundary;
- não criar fake activation;
- não criar fake MeasurementEvent;
- retornar à governança.

## 21. Primeira PubMed Opportunity

Somente após valid activation.

Timestamp:

`2026-10-19T09:00:00-03:00`

Opportunity UUID:

`b3140000-0000-0000-0000-000000000015`

Execution segue Documento 88.

Por ser o primeiro measurement real:

> **HIGH MODE REQUIRED**

## 22. Primeira ClinicalTrials.gov Opportunity

Timestamp:

`2026-10-19T10:30:00-03:00`

Opportunity UUID:

`b3140000-0000-0000-0000-000000000023`

Execution segue Documento 88.

Primeira successful observation da source continua baseline source-specific.

## 23. Contingências

Usar Documento 90.

Em caso de conflito:

1. schema/guards físicos;
2. frozen artifacts;
3. Documento 82;
4. Documento 88;
5. Documento 90;
6. este runbook.

Se persistir ambiguidade semântica:

> **STOP → HIGH MODE GOVERNANCE DECISION**

## 24. Documentos históricos

Documento 77:

> **HISTORICAL_B1_ACTIVATION_RUNBOOK**

Ele não deve ser apagado.

Seu valor é provenance do caminho original B1.

## 25. Pré-condição de prontidão

Antes de 19/10, considerar activation path preparado somente se:

- B1R1 authority continua approved;
- Documento 91 current;
- migration 035 current;
- Documento 88 current;
- Documento 90 current;
- zero prestart events/resolutions;
- nenhum material drift conhecido.

## 26. Estado atual

> **B1R1_ACTIVATION_RUNBOOK = READY**

> **LIVE_PREFLIGHT = NOT_YET_RUN**

> **ACTIVATION = NOT_STARTED**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **ACTIVATION_ARTIFACT = NOT_YET_CREATED**

> **B1R1 started_at = NULL**

## 27. Próximo ato irreversível

Em 19/10/2026, dentro de 08:00–09:00 -03:

> **Freshness Gate + factual clock + live preflight + PASS-only factual activation**

**Fim do Documento 91**
