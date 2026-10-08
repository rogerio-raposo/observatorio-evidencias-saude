# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — First Measurement Contract Specified / Synthetic Harness Pending

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP125  
**Checkpoint anterior:** CP124  
**Status:** artefato de continuidade; não normativo  
**Escopo:** contrato operacional do primeiro measurement real e plano de harness sintético pós-activation, sem execução real.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **FIRST_REAL_MEASUREMENT_CONTRACT = SPECIFIED**

> **SYNTHETIC_POST_ACTIVATION_HARNESS = PLANNED_NOT_IMPLEMENTED**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Documento 78

Path:

`docs/governance/78-contrato-primeiro-measurement-real-harness-sintetico-b1.md`

Commit:

`937ff13f5bf7e5f8b8d11d7e7a4b8b2fbdae680b`

Status:

> **SPECIFIED — IMPLEMENTATION_NOT_STARTED**

## 3. Decisões principais

- activation não cria MeasurementEvent;
- primeiro MeasurementEvent só nasce de tentativa real em Opportunity congelada;
- primeira successful observation por source = `OBSERVED_EPOCH_BASELINE_ACQUISITION`;
- aggregate inicial = `novelty_state=not_applicable`;
- aggregate inicial = `new_identifier_count=NULL`;
- `new_to_epoch` não é scientific novelty;
- unknown count não é zero;
- missed Opportunity não cria failed MeasurementEvent;
- failure attribution exige evidência;
- nenhum caminho temporal cria UpdateSignal automaticamente;
- nenhuma alteração automática de conclusion/currentness/assurance.

## 4. Schema

Revisão de 033b/033c confirmou:

> **NEW_SCHEMA_MIGRATION_REQUIRED = NO**

O schema atual já suporta:

- attempts;
- resolutions;
- measurement items;
- item timepoints;
- event artifacts;
- deviations;
- failure attribution;
- effort payload.

Nenhuma migration nova foi autorizada neste checkpoint.

## 5. Harness sintético

Suite planejada:

> **FM-T01–T24**

Arquivo proposto:

`database/f4-temporal-first-measurement-tests.sql`

Escopo:

- lifecycle/preconditions;
- baseline semantics;
- count semantics;
- failure attribution;
- item/timepoint semantics;
- resolution semantics;
- anti-laundering;
- prova de zero mutation no B1 real.

O harness:

- não usa network;
- não consulta PubMed real;
- não consulta ClinicalTrials.gov real;
- não usa UUIDs do B1 real para inserts de measurement;
- não altera B1;
- não cria MeasurementEvent real;
- não cria OpportunityResolution real.

## 6. Estado temporal

Activation interval permanece:

`2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`

Primeira PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Nenhum timestamp foi deslocado.

Nenhuma activation foi antecipada.

## 7. Próximo passo

> **Modo médio: implementar FM-T01–T24, integrar ao validate-s5.yml e validar em CI, preservando zero mutation do B1 real.**

Se implementação exigir:

- nova migration;
- mudança de schema;
- mudança de baseline semantics;
- mudança de failure attribution;
- alteração de invariantes;

então:

> **parar e retornar a modo alto.**

## 8. Mandatory pause

Após ativação do CP125:

> **stop and await user “Prossiga”.**

Não implementar FM-T01–T24 antes desse novo comando.

**Fim do CP125**
