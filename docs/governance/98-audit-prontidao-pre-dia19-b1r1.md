# 98 — Audit de Prontidão Pré-19/10 do Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data de preparação:** 9 de outubro de 2026  
**Status:** **PRE-DAY19 READINESS AUDIT — PREPARATORY ONLY**  
**Modo:** médio  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Dependências:** Documentos 88–97; migration 035; CP141  
**Objeto:** consolidar em uma única leitura read-only a prontidão preparatória para 19/10, sem confundir readiness operacional com autorização temporal de activation.

## 1. Princípio

Antes da janela de activation, o preflight temporal deve continuar retornando:

> **ACTIVATION_WINDOW = WAIT**

Isso é esperado.

O objetivo deste audit não é transformar WAIT em PASS.

O objetivo é responder:

> **Há algum blocker não temporal conhecido que impeça chegar a 19/10 com o pacote preparado?**

## 2. Read-only audit

Arquivo:

`database/f4-topi-n2-dcbti-b1r1-pre-day19-readiness-readonly.sql`

O script:

- usa `BEGIN TRANSACTION READ ONLY`;
- consulta o preflight atual;
- separa `ACTIVATION_WINDOW` dos checks não temporais;
- reporta `PREPARATION_READY` somente se não houver blocker não temporal;
- preserva `WAIT` temporal antes da janela;
- reconcilia Epoch, authority, target, source connectivity, opportunity set, zero-state e blocking deviations;
- termina com `ROLLBACK`.

## 3. Checks não temporais

Devem permanecer sem blocker:

- EPOCH_EXISTS;
- EPOCH_STATUS;
- TARGET_CURRENT;
- AUTHORITY_STATE;
- CONTROLLING_ARTIFACTS;
- RUNTIME_CONNECTIVITY;
- OPPORTUNITY_SET;
- MATERIAL_DEVIATIONS;
- PRESTART_EVENT_STATE.

SOURCE_DEBT_VISIBILITY pode permanecer INFO.

## 4. Estado esperado antes de 19/10

Esperado:

- B1 = invalidated;
- B1R1 = authorized_non_normative;
- started_at = NULL;
- authority approved;
- target current;
- PubMed source current/verified;
- ClinicalTrials.gov source current/verified;
- PubMed Opportunities = 8;
- ClinicalTrials.gov Opportunities = 6;
- zero MeasurementEvent;
- zero OpportunityResolution;
- zero blocking deviations;
- activation window = WAIT.

Então:

> **PREPARATION_READY**

não significa:

> **ACTIVATION_ALLOWED_NOW**

## 5. Artifacts congelados verificados no preparo deste audit

Blobs observados no GitHub:

- measurement design B1R1: `b3dfe5f2c6509cd66941e5c8d422a7a8c49cdfcd`;
- ClinicalTrials query v2: `e02987ce16c10cbb915499621de05fbfaee49930`;
- ClinicalTrials interface v2: `621ed0252c028a33b666494f49a70a62e570a15c`;
- PubMed interface v2: `8f61b25c3bca5bb4f4da38867371955aec0e05e4`.

Qualquer mudança futura nesses blobs exige reconciliação no Freshness Gate.

## 6. Pacote operacional verificado

Documentos correntes:

- Documento 88 — runbook das measurements reais;
- Documento 90 — contingências;
- Documento 91 — live activation;
- Documento 92 — pacote do dia 19;
- Documento 93 — templates de activation/pós-activation;
- Documento 94 — primeira measurement PubMed;
- Documento 95 — primeira measurement ClinicalTrials.gov;
- Documento 96 — persistence/post-readout;
- Documento 97 — Opportunities subsequentes.

## 7. Scripts operacionais verificados

- live preflight read-only;
- post-activation read-only;
- first PubMed precheck read-only;
- first ClinicalTrials.gov precheck read-only;
- first measurements post-readout read-only;
- subsequent opportunities readiness read-only;
- pre-day19 readiness read-only.

Nenhum desses scripts deve persistir estado factual.

## 8. Freshness requirement no dia 19

Este audit não substitui o Freshness Gate do dia 19.

Em 19/10:

1. revalidar HEAD;
2. revalidar README/STATE/checkpoint;
3. revalidar commits e workflows;
4. revalidar blobs controladores;
5. obter hora factual America/Recife;
6. executar live preflight;
7. exigir PASS factual dentro da janela.

## 9. Drift após este audit

Se antes de 19/10 ocorrer:

- commit que altera frozen artifact;
- runtime/API material change;
- authority change;
- target currentness change;
- Opportunity mutation;
- new blocking deviation;
- prestart MeasurementEvent/Resolution inesperado;

então:

> **PREPARATION_READY IS VOID UNTIL RECONCILED**

## 10. Não autorização

Documento 98 não autoriza:

- activation;
- source query;
- MeasurementEvent;
- Resolution;
- normative cadence;
- calibration;
- Phase 5.

## 11. Estado

> **PRE_DAY19_READINESS_AUDIT = READY_READ_ONLY**

> **PRE_DAY19_PREPARATION_STATUS = PENDING_CI_PROOF**

> **ACTIVATION_WINDOW_EXPECTED_NOW = WAIT**

> **ACTIVATION = NOT_STARTED**

> **REAL_SOURCE_EXECUTION = NO**

**Fim do Documento 98**
