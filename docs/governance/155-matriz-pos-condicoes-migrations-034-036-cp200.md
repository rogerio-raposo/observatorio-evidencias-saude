# 155 — Matriz documental G1-MIG de pós-condições das migrações 034–036

**OES | Fase 4 | 2026-10-20 | CP200 | modo médio**  
**Estado:** `G1_MIG_034_036_POSTCONDITIONS_DRAFT_ONLY` — análise estática, sem validação PostgreSQL e sem autorização operacional.

## 1. Continuidade e escopo

Freshness Gate CP199/main `8bb870ccac736cb9b713affb2ea560498f1a816e` identical, ahead/behind zero. Consolidação das atividades internas A1–A3 e formalização A4, seguindo o protocolo equilibrado. Arquivos lidos: `database/034_temporal_observation_activation_chronology.sql`, `database/035_temporal_observation_activation_preflight.sql`, `database/036_temporal_first_measurement_semantics.sql`, com comparação pontual com 033b/033c. Nenhum SQL, Neon, CI, consulta científica ou serviço pago.

## 2. Migração 034 — cronologia da ativação

Cria/substitui função `maintenance.assert_temporal_epoch_activation_chronology()` e trigger `tr_temporal_epoch_activation_chronology`, `BEFORE UPDATE OF epoch_status,started_at`, `FOR EACH ROW`, sobre `maintenance.temporal_observation_epoch`.

No caminho `authorized_non_normative → active`, o código exige:
- `started_at` não nulo e estritamente anterior à primeira oportunidade `planned_for`, que deve existir;
- estado `approved` para `operational_execution` **no instante `started_at`**, não meramente na data da consulta;
- ausência de desvio `new_epoch_required` ou `invalidating` registrado até `started_at`.

**Pós-condições propostas:** `M034-FUN` (assinatura/definição), `M034-TRG` (nome, vínculo, eventos/habilitação), `M034-WINDOW`, `M034-AUTH-AT-START`, `M034-DEVIATION`, `M034-ROLLBACK`. Testes positivos/negativos futuros, não executados.

## 3. Migração 035 — preflight não mutante

Cria/substitui duas funções `STABLE`:
- `maintenance.temporal_activation_preflight(p_epoch uuid,p_as_of timestamptz DEFAULT CURRENT_TIMESTAMP)`: linhas `check_code/check_status/detail`;
- `maintenance.temporal_activation_preflight_state(p_epoch uuid,p_as_of timestamptz DEFAULT CURRENT_TIMESTAMP)`: estado consolidado `FAIL` (precedência máxima), `WAIT`, ou `PASS`.

Verificações potencialmente impeditivas: `EPOCH_EXISTS`, `EPOCH_STATUS`, `TARGET_CURRENT`, `AUTHORITY_STATE`, `CONTROLLING_ARTIFACTS`, `RUNTIME_CONNECTIVITY`, `OPPORTUNITY_SET`, `MATERIAL_DEVIATIONS`, `PRESTART_EVENT_STATE`, `ACTIVATION_WINDOW`. `SOURCE_DEBT_VISIBILITY` produz `INFO` (não bloqueia).

**Distinção de risco:** a 035 não instala trigger que obrigue a realização do preflight para ativação. `PASS` é diagnóstico, **não** autorização, ativação, garantia de ausência de TOCTOU nem evidência de acesso real à fonte. `STABLE` e ausência aparente de DML na definição não substituem inspeção de funções chamadas.

**Pós-condições propostas:** `M035-FUN` (duas assinaturas e atributos), `M035-CHECKS` (11 códigos e classes), `M035-STATUS-PRECEDENCE`, `M035-ACTIVATION-WINDOW` (WAIT antes de start_boundary, FAIL quando p_as_of alcança primeira oportunidade), `M035-AUTH-AS-OF`, `M035-ZERO-PRESTART`, `M035-READONLY`.

## 4. Migração 036 — primeira medição por fonte do epoch

Cria/substitui função `maintenance.assert_temporal_first_measurement_semantics()` e trigger `tr_temporal_event_first_measurement_semantics` sobre `maintenance.temporal_measurement_event`, `BEFORE INSERT FOR EACH ROW`.

A regra aplica-se a `execution_status='completed'` e é **por `epoch_source_uuid`**:
- primeira conclusão: `novelty_state='not_applicable'`, `new_identifier_count IS NULL`, `failure_attribution='not_applicable'`;
- conclusões subsequentes: `novelty_state<>'not_applicable'` e `failure_attribution='not_applicable'`;
- status diferente de completed não recebe essas regras adicionais da 036.

**Pós-condições propostas:** `M036-FUN`, `M036-TRG`, `M036-FIRST`, `M036-SUBSEQUENT`, `M036-FAILURE`, `M036-SOURCE-SCOPE`, `M036-CONCURRENCY`. A função utiliza `count(*)` de conclusões anteriores; **não se comprovou serialização concorrente**. A FK obrigatória de `measurement_opportunity_uuid` em 033b complementa a checagem da oportunidade.

## 5. Dependências cruzadas e critérios de evidência

A 033 provê tabelas, guardas de lifecycle e append; a 034 adiciona cronologia obrigatória em trigger; a 035 fornece preflight consultivo e a 036 adiciona semântica do primeiro evento. Nenhum componente isolado basta para aprovar a primeira medição factual.

Cada pós-condição aprovada futuramente precisará de fonte SHA-256, assinatura/DDL alvo, query de catálogo somente leitura, resultado esperado inequívoco, evidência observada de execução, ambiente, instante, executor e revisão independente. Os testes comportamentais (incluindo concorrência, rollback e janela temporal) necessitam de ambiente descartável **separadamente autorizado**, sem o que permanecem propostas.

**Bloqueios:** 36 migrations `UNREVIEWED`, 0 pós-condições aprovadas, 36 requisitos 034–036 `NOT_COLLECTED`, 12 roles insatisfeitas; BRG-03/06/07/08 `BLOCKED`, BRG-04/05 históricos, BRG-09 parcial. B1R1 `EXPIRED_NOT_EXECUTED`, novo epoch e P-B factual não autorizados, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED.

## 6. Retomada

Quatro atividades internas consolidadas em CP200. Próxima atividade, sob novo `Prossiga`: avaliar **lacunas transversais de evidências 031–036 e prioridades concretas para BRG-06**, evitando tratar novas matrizes documentais como pós-condições aprovadas. Modo médio e nenhuma execução.

**STOP.**
