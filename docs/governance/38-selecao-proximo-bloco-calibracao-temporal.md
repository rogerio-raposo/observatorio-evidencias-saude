# 38 — Seleção da Próxima Dívida da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **NEXT_BLOCK_SELECTED — NOT_YET_STARTED**

## 1. Decisão

Após o PASS técnico da migration 031 e o fechamento do bloco de propagation/re-baselining, a próxima dívida selecionada da Fase 4 é:

> **CALIBRAÇÃO TEMPORAL NORMATIVA — CADENCE/THRESHOLDS + DURAÇÕES SLA**

Este documento **não inicia a calibração**.

## 2. Motivo da seleção

As dívidas remanescentes relevantes são:

- calibração normativa de cadence/thresholds;
- calibração normativa de durações SLA;
- calendários operacionais reais;
- scheduler;
- notifications;
- auto-escalation;
- M3 readiness.

A ordem causal é:

1. sem cadence/thresholds temporais calibrados, scheduler não possui obrigação temporal normativa a executar;
2. sem durações SLA calibradas e calendário aplicável, breach/overdue operacional não pode ser materializado de forma normativa;
3. notifications dependem de eventos operacionais definidos e thresholds aprovados;
4. auto-escalation permanece não autorizada e depende de regras temporais/causais explícitas;
5. M3 readiness depende, entre outros fatores, de cadence e SLA operacionais coerentes.

Portanto, iniciar scheduler, notifications ou M3 antes da calibração temporal inverteria a ordem arquitetural.

## 3. Priority score não é próxima dívida

O repositório registra:

- `PRIORITY_SCORE = NOT_DEFINED`;
- `NUMERIC_PRIORITY_WEIGHTS = NOT_DEFINED`.

Isso não representa uma lacuna que precise necessariamente ser preenchida.

A arquitetura aprovada definiu explicitamente:

> **regras de dominância + floors qualitativos + modificadores explícitos + rationale auditável**

e rejeitou score aditivo universal por produzir falsa precisão.

Logo:

> **PRIORITY_SCORE = DELIBERATELY_NOT_REQUIRED_FOR_BASELINE**

Nenhum trabalho de score/weights é iniciado.

## 4. Escopo do próximo bloco, quando autorizado

O próximo bloco deverá tratar conjuntamente:

### 4.1 Cadence/thresholds

- unidade de cadence;
- âncora temporal;
- due calculation;
- source-specific cadence quando aplicável;
- grace;
- overdue;
- reassessment de cadence;
- relação com source latency;
- relação com UpdateRiskProfile;
- relação com M0–M3 sem equivalência automática.

### 4.2 SLA durations

- duração por clock SLA-1…SLA-6;
- applicability por clock;
- rule selection;
- calendário aplicável;
- pause semantics já existentes;
- due calculation;
- warning/breach thresholds;
- grandfathering e effective_at;
- capacidade sem relaxamento silencioso;
- independência de currentness científico.

### 4.3 Calibration governance

Qualquer número futuro deverá possuir:

- rationale explícita;
- fonte/evidência ou decisão de governança;
- versão;
- effective_at;
- escopo de aplicabilidade;
- owner/authority;
- regra de revisão;
- ausência de default universal sem justificativa.

## 5. Fora de escopo nesta seleção

Ainda não iniciar:

- scheduler;
- notification channels;
- auto-escalation;
- automatic currentness;
- automatic policy changes;
- M3 activation;
- Fase 5.

## 6. Dependências já disponíveis

A calibração poderá usar contratos já fechados:

- UpdateRiskProfile;
- cadence architecture;
- SLA architecture;
- priority/escalation architecture;
- operational-control physical contract;
- propagation/re-baselining;
- Monitor/Alert contracts.

## 7. Gate metodológico

Antes de qualquer migration ou valor numérico normativo:

> **CALIBRATION_METHODOLOGY_GATE_REQUIRED**

A etapa deverá distinguir:

- números derivados de evidência externa;
- números derivados de capacidade operacional;
- números decididos por governança;
- valores exemplificativos não normativos.

Nenhum número poderá entrar no contrato físico apenas por conveniência de teste.

## 8. Disciplina de modo

A seleção foi feita em modo médio.

A execução do próximo bloco envolve decisões metodológicas/normativas com alto custo de reversão.

Portanto:

> **HIGH_MODE_RECOMMENDED_BEFORE_TEMPORAL_CALIBRATION**

## 9. Estado

> **NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION**

> **TEMPORAL_CALIBRATION = SELECTED_NOT_STARTED**

> **PRIORITY_SCORE = DELIBERATELY_NOT_REQUIRED_FOR_BASELINE**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **SCHEDULER = NOT_STARTED**

> **NOTIFICATIONS = NOT_STARTED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

## 10. Próximo passo exato

> **Em modo alto, definir a metodologia de calibração temporal antes de propor qualquer número normativo de cadence, threshold ou SLA.**
