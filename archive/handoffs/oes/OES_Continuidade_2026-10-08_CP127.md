# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Migration 036 / First-Measurement Harness Validated

**Data do checkpoint:** 2026-10-08  
**Checkpoint:** CP127  
**Checkpoint anterior:** CP126  
**Status:** artefato de continuidade; não normativo  
**Escopo:** implementação e validação técnica do hardening da semântica do primeiro measurement, sem activation do B1 e sem execução real de source.

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **MIGRATION_036 = TECHNICALLY_VALIDATED**

> **FM_T01_TO_T24 = PASS**

> **MIGRATION_036_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_036 = PASS**

> **REAL_B1_NON_MUTATION = PASS**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 2. Implementação

Migration:

`database/036_temporal_first_measurement_semantics.sql`

Harness:

`database/f4-temporal-first-measurement-tests.sql`

Resultado técnico:

`docs/governance/80-resultado-migration-036-first-measurement-fm.md`

## 3. Semântica enforced

Por `epoch_source_uuid`:

primeiro completed event:

- `novelty_state = not_applicable`;
- `new_identifier_count = NULL`;
- `failure_attribution = not_applicable`.

Completed subsequente:

- não pode usar `novelty_state=not_applicable`;
- mantém `failure_attribution=not_applicable`.

Partial/failed/indeterminate não estabelecem successful baseline.

## 4. Fixtures e regressões

Fixture sintético TNO foi alinhado à baseline semantics.

TNO histórico permanece validado após ajuste.

Nenhum dado real foi alterado.

## 5. FM-T01–T24

Suite cobre:

- lifecycle/preconditions;
- attempt sequencing;
- baseline aggregate semantics;
- count semantics;
- failure attribution;
- item/timepoint semantics;
- opportunity resolution;
- anti-laundering;
- real B1 non-mutation.

Resultado:

> **FM-T01–T24 = PASS**

## 6. CI canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run ID:

`37829798269`

Run number:

`222`

Validated HEAD:

`59225572679ebb0e446956a030f54e700614419a`

Conclusion:

> **success**

Created:

`2026-10-08T19:09:19Z`

Completed:

`2026-10-08T19:10:12Z`

## 7. Evidence artifact

Artifact ID:

`11572917207`

Name:

`oes-s5-evidence-37829798269`

Size:

`265530 bytes`

Digest:

`sha256:a5d01a58f60e1a4424c24753d9a65290a18443408525ebfd2e53081d1e03f347`

Expiry:

`2026-11-07T19:10:08Z`

## 8. Idempotência e rebuild

> **F4-FM-IDEM = PASS**

> **F4-FM-REBUILD = PASS**

Também permaneceram verdes as regressões anteriores relevantes.

## 9. Run intermediário

Run 220 / `37829514608` falhou durante estado incremental em que o fixture sintético já havia sido ajustado e os testes correspondentes ainda não.

Esse run:

- não foi promovido;
- não representa estado final;
- foi sucedido por alinhamento fixture/test;
- run 222 é a evidência canônica deste bloco.

## 10. Estado real do B1

Após toda a validação:

- B1 = `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0;
- nenhuma source query real;
- nenhuma activation;
- nenhum UpdateSignal automático.

## 11. Boundary temporal

Activation interval permanece:

`2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`

Primeira PubMed Opportunity:

`2026-10-19T09:00:00-03:00`

Nenhuma data foi deslocada.

## 12. Próximo ato operacional

O caminho técnico do primeiro measurement está validado sinteticamente.

O próximo ato operacional irreversível permanece:

> **em 2026-10-19, entre 08:00 e 09:00 -03, executar Freshness Gate + live activation preflight em modo alto.**

Antes disso, somente trabalho preparatório que não altere o B1 é admissível.

## 13. Mandatory pause

Após ativação do CP127:

> **stop and await user “Prossiga”.**

Não ativar B1.

Não criar activation SQL factual antecipado.

Não criar MeasurementEvent real.

## 14. HEAD before CP127 creation

`b4224d18273b85a6aeda4aa22def8134f339f49b`

**Fim do CP127**
