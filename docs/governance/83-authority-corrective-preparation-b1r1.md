# 83 — Registro de Authority para Corrective Preparation do B1R1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **APPROVED — CORRECTIVE PREPARATION AUTHORIZED**  
**Dependência:** Documento 82 / CP129  
**Instância:** TOPI-N2-DCBTI-01  
**Replacement:** B1 → B1R1

## 1. Decisão recebida

Formulação explícita do owner:

> **APPROVED — corrective preparation / Documento 82 / TOPI-N2-DCBTI-01 / replace B1 with B1R1**

A formulação satisfaz integralmente o gate do Documento 82.

## 2. Escopo autorizado

Esta decisão autoriza somente:

1. repetir minimal runtime connectivity probes não target-specific;
2. invalidar o B1 atual, desde que ainda tenha `started_at=NULL`, zero MeasurementEvent e zero OpportunityResolution;
3. criar artifacts corretivos versionados do B1R1;
4. materializar B1R1 em estado `draft`;
5. criar novos EpochSource rows para B1R1;
6. preservar exatamente os mesmos start/review boundaries;
7. preservar exatamente os mesmos 8 timestamps PubMed e 6 timestamps ClinicalTrials.gov;
8. validar payload↔Opportunity equality;
9. calcular e preservar o novo `design_frozen_at`;
10. executar testes, idempotência/rebuild e regressões necessárias.

## 3. Não autorizado

Esta decisão não autoriza:

- execution authority do B1R1;
- `draft → authorized_non_normative` do B1R1;
- activation;
- MeasurementEvent;
- OpportunityResolution factual;
- query target-specific em PubMed;
- query target-specific em ClinicalTrials.gov;
- alteração do logical query;
- deslocamento de timestamps;
- nova source;
- UpdateSignal;
- cadence normativa;
- SLA;
- M3;
- Fase 5.

## 4. Ordering obrigatório

> **CONNECTIVITY PROBE → CORRECTIVE ARTIFACT FREEZE → B1 INVALIDATION + B1R1 DRAFT MATERIALIZATION → NEW DESIGN FREEZE**

A prova de conectividade deve existir antes de B1R1 ser materializado com `runtime_connectivity_status=verified`.

## 5. Authority futura

A authority operacional do Documento 75 permanece limitada ao B1 original.

Ela não pode ser reutilizada no B1R1.

Após o novo design freeze será necessário um novo pacote de execution authority e uma nova decisão explícita do owner.

**Fim do Documento 83**
