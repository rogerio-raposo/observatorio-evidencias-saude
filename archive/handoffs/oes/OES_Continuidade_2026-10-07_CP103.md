# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Seleção do próximo bloco da Fase 4

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP103  
**Checkpoint anterior:** CP102  
**Status:** artefato de continuidade; não normativo  
**Escopo:** seleção explícita da próxima dívida da Fase 4

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION**

> **TEMPORAL_CALIBRATION = SELECTED_NOT_STARTED**

> **PRIORITY_SCORE = DELIBERATELY_NOT_REQUIRED_FOR_BASELINE**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **SCHEDULER = NOT_STARTED**

> **NOTIFICATIONS = NOT_STARTED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de retomada

A retomada partiu do CP102.

Freshness Gate confirmou:

- HEAD inicial: `f388e06cb777e9fa0259abe5c61fc387a26725ef`;
- checkpoint vigente: CP102;
- README/STATE/CHANGELOG/CP102 coerentes;
- nenhum commit concorrente posterior ao checkpoint.

## 3. Inventário de dívidas remanescentes

Foram identificadas:

- calibração normativa de cadence/thresholds;
- calibração normativa de durações SLA;
- calendários operacionais reais;
- scheduler;
- notifications;
- auto-escalation;
- M3 readiness;
- priority score/pesos numéricos marcados como NOT_DEFINED.

## 4. Decisão sobre priority score

A arquitetura de prioridade já rejeitou score aditivo universal.

Baseline aprovado:

> **regras de dominância + floors qualitativos + modificadores explícitos + rationale auditável**

Portanto:

> **PRIORITY_SCORE = DELIBERATELY_NOT_REQUIRED_FOR_BASELINE**

Esse item não é selecionado como próxima dívida.

## 5. Próximo bloco selecionado

Documento 38:

`docs/governance/38-selecao-proximo-bloco-calibracao-temporal.md`

Decisão:

> **NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION**

O bloco abrange, quando iniciado:

- cadence/thresholds;
- SLA durations;
- calibration governance;
- calendar applicability;
- due/warning/breach semantics já arquitetadas.

## 6. Justificativa causal

A seleção precede logicamente:

1. scheduler;
2. notifications;
3. auto-escalation;
4. M3 readiness.

Motivo:

- scheduler necessita obrigação temporal normativa;
- breach/overdue necessita SLA duration + calendar;
- notifications dependem de thresholds/eventos definidos;
- M3 depende de cadence/SLA operacionais coerentes.

## 7. O que não foi iniciado

Neste checkpoint não foram definidos:

- intervalos numéricos;
- durações SLA;
- grace periods numéricos;
- thresholds numéricos;
- calendários reais;
- scheduler;
- notifications;
- auto-escalation;
- M3 readiness;
- migration nova.

## 8. Disciplina de modo

A seleção foi feita em modo médio.

A próxima etapa envolve decisão normativa/metodológica difícil de reverter.

Portanto:

> **HIGH_MODE_RECOMMENDED_BEFORE_TEMPORAL_CALIBRATION**

## 9. Commits do bloco

- `4081f325b4452a04c20b85986ab01ea2043e51d2` — Documento 38;
- `627692ae2c8029bacdada8e8ec681fded1d08687` — STATE;
- `f7123f955bf2d549591fa6f7bbbc0b140830ca8b` — CHANGELOG.

## 10. Estado antes do CP103

HEAD antes da criação deste checkpoint:

`f7123f955bf2d549591fa6f7bbbc0b140830ca8b`

## 11. Próximo passo exato

> **Após a pausa obrigatória do checkpoint, em modo alto, definir a metodologia de calibração temporal antes de qualquer valor normativo de cadence, threshold ou SLA.**

## 12. Regra de parada

Após ativação do CP103:

> **parar e aguardar instrução explícita do usuário.**

**Fim do CP103**
