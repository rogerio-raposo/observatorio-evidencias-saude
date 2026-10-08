# 80 — Resultado Técnico da Migration 036 e Harness FM-T01–T24

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **TECHNICALLY_VALIDATED — REAL_EXECUTION_NOT_STARTED**  
**Modo:** médio  
**Dependências:** Documentos 78–79; CP126  
**Objeto:** registrar a implementação e validação do hardening físico da semântica do primeiro measurement, sem ativar o B1 e sem executar fonte real.

## 1. Resultado

> **MIGRATION_036 = TECHNICALLY_VALIDATED**

> **FM_T01_TO_T24 = PASS**

> **MIGRATION_036_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_036 = PASS**

> **REAL_B1_NON_MUTATION = PASS**

> **REAL_SOURCE_NETWORK_EXECUTION = NO**

## 2. Migration 036

Arquivo:

`database/036_temporal_first_measurement_semantics.sql`

Objeto:

> **first-measurement aggregate semantics hardening**

Implementa trigger aditivo sobre:

`maintenance.temporal_measurement_event`

Sem reescrever migrations 033–035.

## 3. Semântica fisicamente enforced

Para cada `epoch_source_uuid`:

### Primeiro completed event

Exige:

- `novelty_state = not_applicable`;
- `new_identifier_count IS NULL`;
- `failure_attribution = not_applicable`.

### Completed events subsequentes

- não podem usar `novelty_state = not_applicable`;
- devem usar semântica observacional factual compatível com o schema;
- `failure_attribution = not_applicable`.

### Eventos não completed

`partial`, `failed` e `indeterminate` não estabelecem successful baseline.

## 4. Fixtures sintéticas históricas

O fixture sintético de observação temporal foi alinhado ao novo contrato:

- primeiro completed event sintético passou de `new_items` para `not_applicable`;
- `new_identifier_count` passou de `1` para `NULL`;
- testes TNO correspondentes foram atualizados.

Não houve alteração em dados reais.

## 5. Harness FM

Arquivo:

`database/f4-temporal-first-measurement-tests.sql`

Suite:

> **FM-T01–T24**

O harness usa:

- namespace UUID sintético próprio;
- Plan/Epoch/Source/Opportunities sintéticos;
- nenhuma chamada de rede;
- transação com rollback;
- prova explícita de não mutação do B1 real.

## 6. Cobertura FM-T01–T24

Validado:

- attempt antes de epoch active = rejeitado;
- Opportunity inexistente = rejeitada;
- Opportunity resolvida não recebe nova attempt;
- attempt number duplicado/não contíguo = rejeitado;
- primeira successful observation aceita baseline aggregate;
- baseline com `new_identifier_count` não-NULL = rejeitada;
- `new_to_epoch` não altera aggregate baseline;
- completed subsequente com `not_applicable` = rejeitado;
- known count sem valor = rejeitado;
- unknown count com valor = rejeitado;
- `zero_new` incompatível com count > 0 = rejeitado;
- `new_items` incompatível com count <= 0 = rejeitado;
- source-confirmed/mixed failure sem evidence Artifact = rejeitado;
- failed + unknown attribution = representável;
- completed com failure attribution = rejeitado;
- duplicate identifier no mesmo event = rejeitado;
- date-only timepoint preserva precision/bounds;
- not-observable com bounds = rejeitado;
- OES detection time permanece distinto do source timepoint;
- missed Opportunity pode ser `not_executed` sem MeasurementEvent;
- completed resolution referencia terminal completed event;
- nenhum UpdateSignal/CadenceObservation/MonitorCycle é criado;
- B1 real permanece zero-event/zero-resolution.

## 7. CI canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37829798269**

Run number:

> **222**

Validated HEAD:

`59225572679ebb0e446956a030f54e700614419a`

Conclusion:

> **success**

Created:

`2026-10-08T19:09:19Z`

Updated/completed:

`2026-10-08T19:10:12Z`

## 8. Evidência de CI

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

## 9. Idempotência

O workflow reaplicou migration 036 e confirmou:

- trigger único;
- FM-T01–T24 continuam PASS;
- B1 real continua intacto.

> **F4-FM-IDEM = PASS**

## 10. Rebuild-from-zero

O rebuild instalou migrations até 036, reconstruiu o B1 autorizado e executou FM-T01–T24.

Resultado:

> **F4-FM-REBUILD = PASS**

Também permaneceram verdes:

- F2-B;
- S4;
- S5;
- F3 products;
- Monitor/Alert;
- F4 update protocol;
- operational control;
- risk profile;
- propagation/re-baselining;
- temporal calibration prerequisites;
- TNO;
- activation chronology;
- activation preflight;
- TOPI preparation/authority.

## 11. Run intermediário

Durante commits incrementais, o run 220:

- run ID `37829514608`;
- conclusion = failure;

ocorreu após o fixture sintético ser alterado antes do commit correspondente de ajuste dos testes.

Ele não foi promovido.

O commit seguinte alinhou os testes e o run 221 passou; a validação canônica final deste bloco é exclusivamente o run 222.

## 12. Estado real do B1

Após validação:

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **PHASE_B_EXECUTION_STARTED = NO**

Nenhuma query target-specific real foi executada.

## 13. Boundaries preservadas

Continuam não autorizados:

- activation antes da janela;
- MeasurementEvent real antes de Opportunity real;
- UpdateSignal automático;
- normative cadence;
- SLA;
- M3 formalization;
- Phase 5.

## 14. Próximo passo

O caminho técnico do primeiro measurement está agora validado sinteticamente.

Antes de 19/10 ainda podem existir atividades documentais/analíticas preparatórias, mas nenhum novo ato físico de activation é válido antes da janela.

O próximo ato operacional irreversível permanece:

> **live activation preflight em 2026-10-19, 08:00–09:00 -03, em modo alto.**

**Fim do Documento 80**
