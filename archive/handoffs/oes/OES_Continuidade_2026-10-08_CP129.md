# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — ClinicalTrials Request Freeze Defect / Corrective Authority Required

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP129  
**Checkpoint anterior:** CP128  
**Status:** artefato de continuidade; não normativo  
**Escopo:** reconciliação arquitetural do defeito de parametrização ClinicalTrials.gov, sem correção física do B1 e sem source query real.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **CURRENT_B1 = AUTHORIZED_NON_NORMATIVE_BUT_GOVERNANCE_BLOCKED**

> **CURRENT_B1_ACTIVATION = PROHIBITED**

> **CLINICALTRIALS_EXACT_REQUEST_PARAMETERIZATION = NOT_ACTUALLY_FROZEN**

> **CORRECTIVE_ARCHITECTURE = REPLACEMENT_EPOCH_B1R1_UNDER_PLAN_V2**

> **CORRECTIVE_PREPARATION_AUTHORITY = REQUIRED**

> **B1R1 = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Defeito

Documentos 69–70 exigiam que a actual ClinicalTrials.gov API request/parameterization estivesse congelada antes da materialização do EpochSource.

O artifact congelado:

`artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v1.json`

registra:

- API v2;
- endpoint studies;
- JSON;
- uso de `query.cond/query.term`.

Mas não registra a decomposição exata da frozen logical query entre esses parâmetros.

Logo o execution package não satisfaz integralmente a própria precondition de freeze.

## 3. Documento 82

Path:

`docs/governance/82-reconciliacao-parametrizacao-clinicaltrials-b1.md`

Status:

> **CORRECTIVE_PREPARATION_AUTHORITY_REQUIRED — CURRENT_B1_ACTIVATION_BLOCKED**

## 4. CP128 supersession

O CP128 permanece histórico quanto a:

- schema readiness;
- activation preflight;
- first-measurement harness;
- CI;
- retention.

Mas sua declaração global:

> **B1_PRE_EXECUTION_PACKAGE = READY**

fica supersedida para execution readiness pelo Documento 82.

Estado corrente:

> **B1_PRE_EXECUTION_PACKAGE = BLOCKED_BY_REQUEST_FREEZE_DEFECT**

## 5. Evidência externa

Documentação oficial rechecada em 2026-10-08 confirmou:

- ClinicalTrials.gov separa Condition/disease e Other terms;
- Other terms estreita a busca;
- NLM orienta uso de `query.cond` para condição/doença;
- API v2 usa paginação e page token para conjuntos maiores que pageSize;
- nenhuma target-specific query foi executada.

## 6. Parametrização candidata

Frozen logical query permanece:

`insomnia AND (digital CBT OR digital CBT-I OR internet CBT-I)`

Normalized API mapping candidato:

- `query.cond=insomnia`;
- `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- `format=json`;
- `pageSize=10`;
- seguir paginação até ausência de próximo token.

Nenhum scientific filter adicional.

## 7. Arquitetura corretiva

Selecionada:

> **replacement Epoch B1R1 under existing Plan v2**

Não selecionados:

- rewrite do frozen artifact;
- runbook-only patch;
- Plan v3.

Racional:

- target não muda;
- source universe não muda;
- logical query não muda;
- schedule não muda;
- calibration object não muda;
- apenas o exact execution parameterization estava incompleto.

## 8. Current B1

O B1 atual:

- ainda está fisicamente `authorized_non_normative`;
- não foi invalidado;
- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

Apesar disso:

> **ACTIVATION IS GOVERNANCE-PROHIBITED**

até conclusão do corrective path.

## 9. Replacement B1R1

Somente após explicit corrective authority:

- invalidar current B1;
- criar B1R1 draft;
- mesmos boundaries;
- mesmos 8 PubMed timestamps;
- mesmos 6 ClinicalTrials.gov timestamps;
- novos controlling artifacts ClinicalTrials.gov;
- minimal connectivity probe não target-specific;
- novos EpochSource rows;
- 14 Opportunities;
- novo design_frozen_at;
- validation/rebuild.

## 10. Authority discipline

A authority do Documento 75:

> **não transfere para B1R1.**

Após materialização/freeze do B1R1:

- novo execution authority package;
- nova owner decision explícita;
- authority específica do B1R1;
- só então `authorized_non_normative`.

## 11. Corrective preparation decision required

Formulação requerida:

> **APPROVED — corrective preparation / Documento 82 / TOPI-N2-DCBTI-01 / replace B1 with B1R1**

Mensagem genérica:

- Prossiga;
- Ok;
- Pode continuar;

> **não autoriza corrective preparation.**

## 12. Temporal discipline

Não deslocar timestamps.

Activation interval candidate do B1R1 permanece:

`2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`

Se o corrective path + nova execution authority não estiverem concluídos antes da primeira Opportunity:

> **não executar nem deslizar o schedule.**

## 13. Próximo passo

> **aguardar explicit corrective preparation authority do owner.**

Nenhuma alteração física adicional é válida antes dessa decisão.

## 14. Mandatory pause

Após ativação do CP129:

> **stop and await owner decision.**

## 15. HEAD before CP129 creation

`2381a6e06e0a7d5b43f9be1570fa054da7c48f17`

**Fim do CP129**
