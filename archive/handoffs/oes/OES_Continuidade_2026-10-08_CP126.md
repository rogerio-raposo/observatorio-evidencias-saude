# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — First Measurement Semantics Hardening Required

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP126  
**Checkpoint anterior:** CP125  
**Status:** artefato de continuidade; não normativo  
**Escopo:** decisão arquitetural de hardening físico da semântica do primeiro measurement, sem implementação da migration 036.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **FIRST_REAL_MEASUREMENT_CONTRACT = SPECIFIED**

> **FIRST_MEASUREMENT_SEMANTICS_HARDENING = REQUIRED**

> **MIGRATION_036_REQUIRED = YES**

> **FM_T06_AND_FM_T08 = BLOCKED_UNTIL_036**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Freshness Gate

Entrada deste bloco:

- HEAD inicial: `d511b484148037c53c6c9dd71dc487da0202468e`;
- pointer vigente: CP125;
- Documento 79 existia, porém ainda não promovido;
- nenhum commit concorrente posterior;
- B1 continuava `authorized_non_normative`;
- zero MeasurementEvent;
- zero OpportunityResolution.

Após revisão em modo alto, Documento 79 foi considerado coerente com o contrato do Documento 78, com supersessão técnica limitada.

## 3. Documento 79

Path:

`docs/governance/79-hardening-semantica-primeiro-measurement.md`

Commit revisado:

`f28d88d15b7abf52e4b0019059b54af68da5318d`

Status:

> **ARCHITECTURAL_DECISION — IMPLEMENTATION_PENDING**

## 4. Blocker físico identificado

O schema atual permite situações incompatíveis com o contrato do Documento 78:

1. `novelty_state=not_applicable` com `new_identifier_count` não-NULL;
2. ausência de distinção relacional entre primeiro completed event da source e completed events posteriores;
3. completed event sem obrigação física de `failure_attribution=not_applicable`.

Portanto:

> **FM-T06/FM-T08 cannot be fully enforced with current guards.**

## 5. Supersessão limitada do Documento 78

O Documento 78 permanece vigente como contrato metodológico.

Apenas a conclusão:

> **NEW_SCHEMA_MIGRATION_REQUIRED = NO**

é supersedida por:

> **NEW_SCHEMA_MIGRATION_REQUIRED = YES — MIGRATION 036**

Nenhuma outra semântica do Documento 78 é enfraquecida.

## 6. Migration 036

Objetivo:

> **first-measurement aggregate semantics hardening**

Deverá ser aditiva.

Não reescrever:

- migration 033;
- migration 034;
- migration 035.

Guard proposto sobre `maintenance.temporal_measurement_event`.

## 7. Baseline aggregate source-specific

Para cada `epoch_source_uuid`:

primeiro `execution_status=completed`:

- `novelty_state = not_applicable`;
- `new_identifier_count = NULL`;
- `failure_attribution = not_applicable`.

Completed event subsequente da mesma source:

- não pode usar `novelty_state=not_applicable`;
- deve usar `zero_new`, `new_items` ou `unknown` conforme fatos.

Partial, failed e indeterminate não estabelecem successful baseline.

## 8. Compatibilidade e dados reais

B1 ainda possui:

- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

Logo:

> **NO_REAL_BACKFILL_REQUIRED**

Fixtures sintéticas poderão ser ajustadas se necessário.

## 9. Próximo passo

Após CP126:

> **modo médio: implementar migration 036 + FM-T01–T24 + integração no validate-s5.yml + idempotência + rebuild-from-zero + regressões.**

Se durante implementação surgir nova decisão semântica, schema expansion não prevista ou mudança de invariantes:

> **parar e retornar a modo alto antes de escrever essa decisão.**

## 10. Boundaries preservadas

Migration 036 não autoriza:

- activation antecipada;
- MeasurementEvent real;
- source query real;
- UpdateSignal automático;
- cadence normativa;
- SLA;
- M3;
- Fase 5.

Activation interval continua:

`2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`

## 11. Mandatory pause

Após ativação do CP126:

> **stop and await user “Prossiga”.**

Não implementar migration 036 ou FM-T01–T24 antes desse comando.

## 12. HEAD before CP126 creation

`0de96cfadfe8fbd291fe1c9d5401be9591d47eb0`

**Fim do CP126**
