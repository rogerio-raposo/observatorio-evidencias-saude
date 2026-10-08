# 79 — Hardening de Semântica do Primeiro Measurement

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **ARCHITECTURAL_DECISION — IMPLEMENTATION_PENDING**  
**Modo:** alto  
**Dependências:** Documento 78; migrations 033–035; CP125  
**Objeto:** definir o hardening físico mínimo necessário para tornar executável e testável o contrato do primeiro measurement real.

## 1. Blocker identificado

A implementação de FM-T01–T24 revelou que o schema atual não impõe integralmente duas semânticas do Documento 78:

1. `novelty_state=not_applicable` pode atualmente coexistir com `new_identifier_count` não-NULL;
2. o schema não distingue a primeira successful observation de uma source das observações successful subsequentes.

Também não há guard relacional que obrigue uma execução `completed` a usar `failure_attribution=not_applicable`.

Logo:

> **FM_T06_AND_FM_T08_CANNOT_BE_PROVEN_WITH_CURRENT_GUARDS**

> **DOCUMENT_78_MUST_NOT_BE_WEAKENED_TO_MATCH_THE_SCHEMA**

## 2. Decisão

Criar hardening aditivo em nova migration.

> **MIGRATION_036_REQUIRED = YES**

Não reescrever migrations 033–035.

Objeto da migration:

> **first-measurement aggregate semantics hardening**

## 3. Regra de baseline por source

Para cada `epoch_source_uuid`, a primeira successful observation é definida como o primeiro MeasurementEvent com:

`execution_status = completed`

Antes da inserção desse primeiro completed event da source:

- `novelty_state` deve ser `not_applicable`;
- `new_identifier_count` deve ser NULL;
- `failure_attribution` deve ser `not_applicable`.

Isso é source-specific.

PubMed e ClinicalTrials.gov possuem baseline independente.

## 4. Observações posteriores

Depois que existir pelo menos um completed event para a mesma `epoch_source_uuid`:

- novo completed event não pode usar `novelty_state=not_applicable`;
- deve usar `zero_new`, `new_items` ou `unknown` conforme fatos observados;
- os constraints já existentes continuam regendo `new_identifier_count` para `zero_new` e `new_items`.

`unknown` não exige fabricação de contagem.

## 5. Partial e failed

`partial`, `failed` e `indeterminate` não estabelecem, por si só, successful baseline.

Um partial anterior pode materializar items factuais, mas a primeira observação `completed` da source continua sendo a baseline aggregate.

Item-level `new_to_epoch` continua dependente do histórico real do epoch.

## 6. Failure attribution

Para `execution_status=completed`:

> `failure_attribution = not_applicable`

Para estados não-completed:

- attribution pode ser factual conforme schema;
- `source_confirmed` e `mixed` continuam exigindo Artifact;
- nenhum attribution pode ser inventado.

## 7. Enforcement

Implementar por função/trigger aditivo sobre `maintenance.temporal_measurement_event`.

O guard deve determinar `epoch_source_uuid` a partir da Opportunity e consultar somente eventos previamente persistidos dessa mesma source no mesmo epoch source.

A decisão não depende do relógio real nem de source network.

## 8. Compatibilidade

A migration deve ser idempotente.

Rebuild-from-zero deve continuar funcionando.

Fixtures sintéticas históricas que violem a nova baseline semantics deverão ser corrigidas apenas se forem sintéticas e não normativas.

Nenhum dado real do B1 existe para migrar:

- MeasurementEvent B1 = 0;
- OpportunityResolution B1 = 0.

Portanto não há backfill real.

## 9. Suite FM

Após migration 036:

- FM-T06 deve provar rejeição de baseline completed com `new_identifier_count` não-NULL;
- FM-T08 deve provar rejeição de `not_applicable` em completed subsequente da mesma source;
- FM-T16 deve provar que completed com failure attribution diferente de `not_applicable` é rejeitado.

Os demais FM permanecem conforme Documento 78.

## 10. Boundaries

Migration 036 não:

- ativa B1;
- cria MeasurementEvent real;
- altera Opportunities;
- muda schedule;
- cria UpdateSignal;
- cria cadence/SLA;
- inicia M3;
- inicia Fase 5.

## 11. Próximo passo

> **Modo médio após checkpoint: implementar migration 036 + FM-T01–T24 + integração S5 + idempotência/rebuild/regressões.**

Se surgir nova mudança semântica além deste documento:

> **parar e retornar a modo alto.**

**Fim do Documento 79**
