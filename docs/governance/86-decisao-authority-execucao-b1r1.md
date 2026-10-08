# 86 — Registro da Decisão de Authority Operacional do Replacement Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **APPROVED — B1R1 OPERATIONAL EXECUTION AUTHORIZED**  
**Pacote:** Documento 85  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Natureza:** authority operacional não normativa

## 1. Decisão recebida

Formulação explícita do owner:

> **APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**

A decisão corresponde exatamente ao gate definido no Documento 85.

## 2. Timestamp factual da decisão

Current local time obtido no momento da decisão:

> **2026-10-08T20:26:21-03:00**

Design freeze do B1R1:

> **2026-10-08T19:48:20-03:00**

Logo:

> **AUTHORITY_AFTER_DESIGN_FREEZE = PASS**

## 3. Escopo autorizado

A decisão autoriza:

1. persistir uma nova authority `operational_execution` específica do B1R1;
2. transicionar B1R1 de `draft` para `authorized_non_normative`, sujeito aos guards físicos;
3. manter o replacement elegível para futura activation somente dentro da janela já congelada;
4. executar Opportunities apenas quando seus timestamps reais forem alcançados e após activation válida.

## 4. Escopo não autorizado

A decisão não autoriza:

- reativar o B1 original;
- alterar source/query/request mapping;
- mover timestamps;
- adicionar Opportunities;
- activation antes de 2026-10-19T08:00:00-03:00;
- activation a partir de 2026-10-19T09:00:00-03:00;
- criar `started_at` antecipado;
- executar query target-specific agora;
- criar MeasurementEvent agora;
- criar OpportunityResolution agora;
- criar UpdateSignal automaticamente;
- alterar cadence normativa;
- criar SLA;
- operacionalizar M3;
- iniciar Fase 5.

## 5. Physical scope

Plan:

- UUID `b3100000-0000-0000-0000-000000000001`;
- code `TOPI-N2-DCBTI-01`;
- version 2.

Epoch B1R1:

- UUID `b3120000-0000-0000-0000-000000000002`;
- design freeze `2026-10-08T19:48:20-03:00`.

Authority domain:

> **operational_execution**

Decision:

> **approved**

Actor type:

> **owner**

## 6. Expected post-persistence state

Após persistência e validação:

> **B1 = invalidated**

> **B1R1 = authorized_non_normative**

> **B1R1 started_at = NULL**

> **B1R1 activation = pending temporal window**

> **MeasurementEvent count = 0**

> **OpportunityResolution count = 0**

## 7. Próximo boundary

A activation continua sendo um ato separado.

Janela válida:

> **2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00**

Na data da activation serão obrigatórios:

- Freshness Gate;
- hora factual America/Recife;
- live activation preflight;
- PASS integral;
- só então materialização de `started_at`.

**Fim do Documento 86**
