# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — B1R1 Contingency Decision Tables Ready

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP134  
**Checkpoint anterior:** CP133  
**Status:** artefato de continuidade; não normativo  
**Escopo:** pré-especificação das contingências operacionais do B1R1, sem activation, sem source execution e sem expansão de schema.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_REAL_MEASUREMENT_RUNBOOK = READY**

> **B1R1_REVIEW_PROTOCOL = PRE_SPECIFIED**

> **B1R1_CONTINGENCY_TABLES = PRE_SPECIFIED**

> **B1R1_STARTED_AT = NULL**

> **B1R1_ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Documento 90

Path:

`docs/governance/90-decision-tables-contingencias-b1r1.md`

Status:

> **PRE-SPECIFIED — CONTINGENCY_READY**

## 3. Coverage

Pré-especificado:

- activation WAIT/PASS/FAIL;
- activation expiry;
- target/authority/artifact/connectivity blockers;
- PubMed access/JSON/count/idlist contingencies;
- ClinicalTrials.gov pagination/schema/token contingencies;
- duplicate/reobserved/updated identifiers;
- missing/date-only timepoints;
- retries;
- missed Opportunity;
- failed/indeterminate closure;
- execution delay;
- query/interface/source-scope drift;
- data governance;
- failure evidence constraints;
- incidental findings;
- mixed source outcomes;
- review-boundary blockers;
- escalation de modo.

## 4. Partial closure boundary

O schema não possui `partial_closed`.

Portanto, um partial event sem completed posterior:

- não recebe closure state inventado;
- permanece unresolved enquanto não houver resposta física válida;
- exige retorno a modo alto se for necessário decidir encerramento definitivo fora do vocabulário existente.

Isso não altera o schema.

## 5. Nenhuma expansão arquitetural

> **NEW_SCHEMA = NO**

> **NEW_MIGRATION = NO**

> **NEW_AUTHORITY = NO**

> **B1R1_STATE_MUTATION = NO**

> **REAL_SOURCE_EXECUTION = NO**

## 6. Estado preservado

B1 permanece:

> **invalidated**

B1R1 permanece:

> **authorized_non_normative**

Preservado:

- started_at = NULL;
- zero MeasurementEvent;
- zero OpportunityResolution;
- nenhuma query target-specific.

## 7. Próximo ato irreversível

Em 19/10/2026:

> **modo alto obrigatório**

Sequência:

1. Freshness Gate;
2. hora factual America/Recife;
3. live B1R1 activation preflight;
4. somente se PASS, activation factual;
5. checkpoint;
6. primeira PubMed Opportunity às 09:00 -03.

## 8. Mandatory pause

Após ativação do CP134:

> **stop and await user “Prossiga”.**

Antes de 19/10, “Prossiga” autoriza somente trabalho preparatório não irreversível.

## 9. HEAD before CP134 creation

`5b7d195024aaa70407de7d2f5312df51fc3d20fc`

**Fim do CP134**
