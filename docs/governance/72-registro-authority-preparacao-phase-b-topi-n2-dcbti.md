# 72 — Registro de Decisão de Authority para Preparação da Phase B da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data da decisão:** 8 de outubro de 2026  
**Timestamp de registro:** 2026-10-08T13:04:01-03:00  
**Decisor:** proprietário do projeto / owner  
**Documento de decisão:** Documento 71  
**Instância:** TOPI-N2-DCBTI-01  
**Resultado:** **APPROVED**

## 1. Decisão explícita

Foi recebida decisão explícita do proprietário:

> **APPROVED — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

A formulação satisfaz o requisito do Documento 71 de vincular a decisão simultaneamente a:

- Phase B preparation;
- Documento 71;
- TOPI-N2-DCBTI-01.

Logo:

> **PREPARATION_AUTHORITY = APPROVED**

> **RUNTIME_CONNECTIVITY_PROBES = AUTHORIZED**

> **REAL_DRAFT_MATERIALIZATION = AUTHORIZED_CONDITIONALLY_ON_CONNECTIVITY_AND_TARGET_RECHECK**

## 2. Escopo autorizado

A decisão autoriza somente:

1. Freshness Gate e target-current recheck;
2. probes mínimos de conectividade de PubMed E-utilities e ClinicalTrials.gov API v2;
3. congelamento de Artifacts/config/query strategy;
4. materialização real em draft da TOPI v0.2-final e Epoch B1;
5. materialização das Opportunities previstas no Documento 69;
6. validação payload↔Opportunity;
7. preservação de design_frozen_at.

## 3. Limites

A decisão não autoriza:

- MeasurementEvent;
- execução das queries B1 como measurement;
- Search científica por força deste pacote;
- SearchHit/ScreeningDecision;
- OpportunityResolution por measurement;
- transition para authorized_non_normative;
- transition para active;
- Phase B execution;
- UpdatePolicy;
- CadenceContract;
- CadenceObservation;
- Monitor/MonitoringCycle;
- scheduler/notification/auto-escalation;
- Calibration Dossier;
- normative temporal value;
- M3.

## 4. Natureza da authority

Esta decisão é:

> **OWNER PREPARATION AUTHORITY**

Ela não é:

> **PHASE B OPERATIONAL EXECUTION AUTHORITY**

A execution authority deverá ser nova, específica do exact frozen design e emitida em ou depois de design_frozen_at.

## 5. Estado

> **PREPARATION_AUTHORITY = APPROVED**

> **PHASE_B_EXECUTION_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **PHASE_5 = NOT_STARTED**

**Fim do Documento 72**
