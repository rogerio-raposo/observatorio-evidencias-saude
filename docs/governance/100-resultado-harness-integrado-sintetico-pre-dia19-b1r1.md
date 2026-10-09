# 100 — Resultado da Validação do Harness Integrado Sintético Dual-Source (ISE)

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 9 de outubro de 2026  
**Status:** **TECHNICALLY_VALIDATED — SYNTHETIC_ONLY — NO_FACTUAL_ACTIVATION**  
**Implementação:** `database/f4-temporal-integrated-synthetic-harness-tests.sql`  
**Workflow:** `.github/workflows/validate-s5.yml`  
**Base metodológica:** Documento 99 / CP143

## 1. Resultado

> **F4_ISE_IMPLEMENTATION = DONE**  
> **F4_ISE_TECHNICAL_VALIDATION = PASS**  
> **ISE_T01_T24 = 24_OF_24_PASS**  
> **ISE_ROLLBACK_PROOF = PASS**  
> **B1R1_FACTUAL_ACTIVATION = NOT_STARTED**

O harness roda exclusivamente no PostgreSQL de testes em uma transação iniciada por `BEGIN` e encerrada por `ROLLBACK`. A CI confirma estado pré/pós em sessões separadas. Não há HTTP nem query real de PubMed/ClinicalTrials.gov. Nenhuma migration ou contrato congelado foi alterado.

## 2. Evidência de execução

- GitHub Actions: run **245**, ID `37933007291`;
- Commit validado: `af5595d14647df51d076d64081bec1d6a5328c22`;
- Job `postgres-s5`: ID `113828097739`, conclusão `success`;
- Etapa `F4-ISE — isolated dual-source synthetic integration T01–T24`: `success`;
- Artifact: `11616374106`;
- Name: `oes-s5-evidence-37933007291`;
- Digest: `sha256:ccccba178c51d71f21c56c878c02c333e677e4ae76e14ce087faececd2fe7bb4`;
- Expiração reportada: `2026-12-08T12:54:07Z`.

Log real inspecionado: os avisos `ISE-T01 PASS` até `ISE-T24 PASS` foram encontrados individualmente, seguidos de `F4-ISE-T01-T24 PASS` e `F4-ISE PASS — 24 synthetic assertions; ROLLBACK verified; B1/B1R1 and normative state unchanged`.

Também presentes: `TOPI-B1R1-PRE-DAY19-READINESS PASS`, `S5-T16 PASS` (rebuild) e `TOPI-B1R1-AUTH-REBUILD PASS`.

## 3. Cobertura positiva efetivamente executada

- novo Plan e Epoch sintéticos com duas fontes independentes e quatro Opportunities;
- design freeze e authority artificiais;
- preflight determinístico `WAIT`, `PASS`, `FAIL`, sem mutation;
- activation em Epoch sintético;
- PubMed sintético: primeiro completed com baseline `not_applicable`, identifier, source timepoint bounded, Event Artifacts e OpportunityResolution;
- PubMed subsequente com `zero_new` e identifier `reobserved`;
- ClinicalTrials.gov sintético: tentativa failed com failure Artifact, retry completed de zero resultados como baseline independente;
- segunda ClinicalTrials.gov Opportunity: partial com identifier e retry completed com `zero_new`;
- resolução terminal, replay e ausência de issues bloqueantes selecionadas;
- rejeição de `not_executed` após tentativa existente e de completion prematura por Opportunity ainda unresolved ou review boundary não vencido;
- completion do Epoch estritamente sintético após a review boundary artificial.

## 4. Integridade e limitações

A CI verifica pre/post fingerprint dos dois Epochs reais B1/B1R1, contagens globais de eventos e resolutions, UpdateSignal, CadenceObservation e MonitorCycle; também verifica ausência de registros do Plan e Artifacts artificiais após rollback e zero eventos/resolutions de B1/B1R1.

Este teste **não** reproduz uma requisição HTTP factual, um parser real de fontes, a disponibilidade das APIs em 19/10, um mecanismo de calendário real, nem a revisão humana; não deve ser interpretado como substituto do preflight factual do B1R1 ou dos gates normativos de cadence/SLA/M3.

O Documento 99 permanece snapshot de desenho em estado `NOT_IMPLEMENTED` naquele momento; este Documento 100 é evidência posterior que atualiza o **estado corrente** sem reescrever o documento histórico.

## 5. Próxima dívida independente recomendada

Desenvolver **contratos offline de resposta das fontes PubMed e ClinicalTrials.gov**, com fixtures artificiais e testes de paginação, incompletude, identificadores duplicados, payload inesperado e falha de acesso. Antes de codificar, executar em modo alto a revisão de escopo das interfaces congeladas e decidir explicitamente o formato de saída do parser/captura, sem tocar queries reais nem frozen artifacts.

Essa é uma **proposta de trabalho subsequente**, não uma autorização para modificar interfaces congeladas nem para executar consultas reais.

## 6. Estado preservado

> **B1 = INVALIDATED**  
> **B1R1 = AUTHORIZED_NON_NORMATIVE**  
> **B1R1_STARTED_AT = NULL**  
> **ACTIVATION = NOT_STARTED**  
> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**  
> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**  
> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**  
> **PRE_DAY19_PREPARATION_STATUS = PREPARATION_READY**  
> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**  
> **PHASE_5 = NOT_STARTED**

**Fim do Documento 100**
