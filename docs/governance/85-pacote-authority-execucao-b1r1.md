# 85 — Pacote de Decisão de Authority Operacional para Execução do Replacement Epoch B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **PENDING OWNER DECISION**  
**Dependências:** Documentos 82–84  
**Instância:** TOPI-N2-DCBTI-01  
**Epoch:** B1R1  
**Objeto:** decisão humana específica sobre execução operacional do replacement Epoch corrigido.

## 1. Contexto

O B1 original foi invalidado antes de qualquer execução porque sua parametrização ClinicalTrials.gov não estava integralmente congelada.

A corrective preparation autorizada no Documento 83 produziu:

> **B1 = invalidated / zero execution**

> **B1R1 = draft_frozen**

> **DESIGN_FROZEN_AT = 2026-10-08T19:48:20-03:00**

> **B1R1_EXECUTION_AUTHORITY = MISSING**

## 2. Exact physical scope

Plan:

- UUID: `b3100000-0000-0000-0000-000000000001`;
- code: `TOPI-N2-DCBTI-01`;
- version: 2.

Epoch:

- UUID: `b3120000-0000-0000-0000-000000000002`;
- code: `B1R1`;
- status: `draft`.

Target permanece o mesmo ProductVersion current/published e InvestigationVersion N2/M1.

## 3. Included sources

PubMed EpochSource:

`b3130000-0000-0000-0000-000000000003`

ClinicalTrials.gov EpochSource:

`b3130000-0000-0000-0000-000000000004`

BVS/LILACS permanece:

> **deferred_source_debt**

## 4. Corrective request freeze

PubMed:

- query científica inalterada;
- request contract v2 congelado;
- ESearch / db=pubmed / retmode=json / retmax=10000;
- sem filtro temporal relativo.

ClinicalTrials.gov:

- query lógica inalterada;
- `query.cond=insomnia`;
- `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- `format=json`;
- `pageSize=10`;
- paginação completa obrigatória.

## 5. Frozen temporal scope

Start boundary:

`2026-10-19T08:00:00-03:00`

Review boundary:

`2026-11-10T18:00:00-03:00`

Design freeze:

`2026-10-08T19:48:20-03:00`

PubMed:

- mesmas 8 Opportunities do B1.

ClinicalTrials.gov:

- mesmas 6 Opportunities do B1.

> **NO TIMESTAMP SHIFT**

## 6. Evidence package

Corrective connectivity:

- run 224 / `37855302262`;
- artifact `11583468584`;
- digest `sha256:c0d933ca42961e1f0605751544e603dac33039b1c3d1476dbe187c65925f2e52`.

Corrective materialization:

- run 229 / `37855834411`;
- validated HEAD `cea4c1a67b7de4537bdf95485146199c86989a48`;
- artifact `11583902320`;
- digest `sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`;
- B1R1-T01–T24 = PASS;
- rebuild = PASS.

## 7. Decisão solicitada

Solicita-se decisão exclusivamente sobre:

> **autorizar ou não a execução operacional não normativa do replacement Epoch B1R1 da TOPI-N2-DCBTI-01 exatamente como corrigido e congelado.**

APPROVED autorizará apenas:

1. persistir nova authority `operational_execution` específica do B1R1;
2. transicionar B1R1 `draft → authorized_non_normative`, sujeito aos guards;
3. futura activation separada somente na janela temporal válida;
4. execução das Opportunities apenas quando realmente ocorrerem.

## 8. APPROVED não autoriza

Não autoriza:

- reativar B1;
- alterar source/query/request mapping;
- mover timestamps;
- adicionar Opportunities;
- activation antecipada;
- MeasurementEvent imediato;
- automatic UpdateSignal;
- scientific update automático;
- cadence normativa;
- SLA;
- M3;
- Phase 5.

## 9. Authority freshness

A decisão deve ocorrer depois de:

> **2026-10-08T19:48:20-03:00**

A authority do Documento 75 não é reutilizável.

## 10. Formulação válida

> **APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**

Alternativas:

- **REVISE — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**
- **REJECTED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1**

Mensagem genérica como “Prossiga” não constitui execution authority.

## 11. Estado enquanto não houver decisão

> **B1 = INVALIDATED**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_EXECUTION_AUTHORITY = PENDING**

> **B1R1_ACTIVATION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

**Fim do Documento 85**
