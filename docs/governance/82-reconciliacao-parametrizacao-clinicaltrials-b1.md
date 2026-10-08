# 82 — Reconciliação do Defeito de Parametrização do ClinicalTrials.gov no Epoch B1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **CORRECTIVE_PREPARATION_AUTHORITY_REQUIRED — CURRENT_B1_ACTIVATION_BLOCKED**  
**Modo:** alto  
**Dependências:** Documentos 69–81; CP128  
**Instância:** TOPI-N2-DCBTI-01  
**Objeto:** reconciliar a ausência de parametrização exata da requisição ClinicalTrials.gov no frozen design, sem executar qualquer source query real.

## 1. Freshness Gate

Na entrada deste bloco:

- branch: `main`;
- HEAD: `5b5cdc61da29af58e8a28b3e1ccaf42a33c6458b`;
- pointer: CP128;
- nenhuma concorrência posterior detectada;
- current B1 = `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

## 2. Defeito identificado

O Documento 69 determinou que a actual API request/parameterization do ClinicalTrials.gov deveria ser congelada após connectivity verification e antes da materialização do EpochSource.

O Documento 70 confirmou essa condição como precondition.

O artifact congelado:

`artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v1.json`

registra:

- endpoint `studies`;
- interface `clinicaltrials_api_v2`;
- formato JSON;
- uso de `query.cond/query.term`;
- exigência de que a request exata corresponda ao artifact.

Porém ele não materializa:

- qual parte da query lógica vai para `query.cond`;
- qual parte vai para `query.term`;
- regra de paginação para garantir result set completo;
- representação canônica da request semântica.

Logo:

> **CLINICALTRIALS_EXACT_REQUEST_PARAMETERIZATION = NOT_ACTUALLY_FROZEN**

## 3. Consequência para CP128

O CP128 declarou:

> **B1_PRE_EXECUTION_PACKAGE = READY**

Essa conclusão foi excessiva.

A readiness técnica de schema/preflight/harness permanece válida, mas a readiness do frozen execution package não.

Portanto:

> **CP128_PRE_EXECUTION_READY_CLAIM = SUPERSEDED_BY_DOCUMENT_82**

> **CURRENT_B1_ACTIVATION_GOVERNANCE_STATUS = BLOCKED**

O blocker não é temporal.

É um defeito de design freeze detectado antes da execução.

## 4. Evidência documental externa

A documentação oficial vigente do ClinicalTrials.gov separa:

- Condition/disease;
- Other terms;
- Intervention/treatment.

A própria interface oficial descreve Other terms como campo usado para estreitar uma busca.

NLM Technical Bulletin orienta que consultas por condição/doença usem `query.cond`.

A documentação oficial de migração da API v2 mantém `query.term` como mecanismo de query geral/other terms.

Para paginação, NLM documenta:

- `pageSize`;
- default = 10;
- uso de `pageToken` para obter o conjunto completo quando houver mais resultados que o pageSize.

Nenhuma query target-specific foi executada para esta decisão.

## 5. Query lógica congelada

O artifact:

`clinicaltrials-query-v1.txt`

contém:

`insomnia AND (digital CBT OR digital CBT-I OR internet CBT-I)`

Essa query lógica não será alterada.

## 6. Parametrização candidata corrigida

A representação normalizada candidata é:

- method: `GET`;
- endpoint: `https://clinicaltrials.gov/api/v2/studies`;
- `query.cond = insomnia`;
- `query.term = (digital CBT OR digital CBT-I OR internet CBT-I)`;
- `format = json`;
- `pageSize = 10`;
- paginação: seguir `nextPageToken/pageToken` até ausência de próximo token.

Não adicionar:

- relative date;
- status filter;
- phase filter;
- location filter;
- `query.intr`;
- sort sem necessidade;
- termo científico adicional.

## 7. Semântica de request

A request não será definida por uma byte-identical URL.

A identidade semântica será definida pelo mapa normalizado de parâmetros.

São não semânticos:

- ordem dos query parameters;
- percent-encoding equivalente;
- token de paginação retornado pela source;
- headers HTTP sem efeito sobre o escopo científico.

São semânticos:

- endpoint;
- query.cond;
- query.term;
- ausência/presença de filtros científicos;
- qualquer alteração da expressão lógica;
- qualquer alteração de source scope.

## 8. Completeness

ClinicalTrials.gov somente poderá ser registrado como `completed` se a paginação terminar normalmente.

O result set será definido pelos NCT IDs obtidos em todas as páginas.

`raw_result_count` poderá ser `known` como cardinalidade do conjunto de NCT IDs somente quando:

- todas as páginas forem obtidas;
- parsing completar;
- não houver ambiguity de completeness.

Se a paginação for interrompida:

> **UNKNOWN ≠ ZERO**

e o event não poderá fingir completion completa.

## 9. Minimal materialized record

Para cada NCT ID, o measurement deve preservar no mínimo, quando disponível:

- NCT ID;
- BriefTitle;
- OverallStatus;
- StudyFirstPostDate;
- ResultsFirstPostDate;
- LastUpdatePostDate.

A query provenance deve permanecer separada do record payload.

Não é necessário reter payload clínico integral para que a observation temporal seja válida.

## 10. Alternativas de correção

### A — Corrigir o artifact atual in place

Rejeitada.

Razões:

- artifact já está congelado e referenciado fisicamente;
- EpochSource é imutável;
- authority do Documento 75 aprovou o exact frozen design;
- reescrever o artifact seria provenance break.

### B — Adicionar apenas um runbook suplementar ao B1 atual

Rejeitada.

Razão:

- deixaria o physical EpochSource apontando para um interface artifact incompleto;
- transformaria uma precondition pré-freeze em interpretação pós-freeze.

### C — Criar Plan v3

Não selecionada neste momento.

Razão:

- target, calibration object, source universe, logical query e opportunity set permanecem iguais;
- o defeito está no execution specification do EpochSource, não no Plan científico/temporal.

### D — Replacement Epoch sob Plan v2

Selecionada.

> **CORRECTIVE_ARCHITECTURE = REPLACEMENT_EPOCH_B1R1_UNDER_PLAN_V2**

## 11. Current B1

O current B1 não será executado.

Após explicit corrective preparation authority:

> **B1: authorized_non_normative → invalidated**

Condições antes da invalidação:

- started_at = NULL;
- MeasurementEvent = 0;
- OpportunityResolution = 0.

A invalidação não será tratada como failed measurement.

## 12. Replacement Epoch

Epoch code candidato:

> **B1R1**

Plan:

- mesmo `TOPI-N2-DCBTI-01`;
- mesma physical Plan version 2.

Boundaries:

- start: `2026-10-19T08:00:00-03:00`;
- review: `2026-11-10T18:00:00-03:00`.

Opportunity set:

- mesmos 8 timestamps PubMed;
- mesmos 6 timestamps ClinicalTrials.gov;
- nenhum timestamp deslocado.

Logo:

> **NO_SCHEDULE_SLIDING = PASS**

## 13. B1R1 source design

### PubMed

Pode reutilizar semanticamente:

- source definition;
- frozen logical query;
- interface code;
- schedule.

O novo EpochSource será uma nova row física pertencente ao B1R1.

### ClinicalTrials.gov

Deve usar novos controlling artifacts versionados que materializem:

1. logical query;
2. normalized query parameter mapping;
3. endpoint;
4. pagination contract;
5. minimal record extraction contract.

Os artifacts antigos não serão apagados nem reescritos.

## 14. Connectivity

Antes da materialização do replacement EpochSource:

- repetir somente minimal non-target-specific connectivity probe;
- não executar a query dCBT-I;
- registrar versão/API observada;
- congelar os novos request/interface artifacts.

Se connectivity não puder ser honestamente verificada:

> **DO_NOT_MATERIALIZE_B1R1_AS_VERIFIED**

## 15. Novo design freeze

Após criar:

- B1R1;
- PubMed EpochSource;
- ClinicalTrials.gov EpochSource;
- 14 Opportunities;

calcular novo:

> **design_frozen_at(B1R1)**

Esse timestamp será controlador.

## 16. Authority

A authority existente do Documento 75:

> **não se transfere para B1R1.**

Após o novo design freeze deverá existir:

- novo execution authority package;
- nova owner decision explícita;
- decided_at >= novo design_frozen_at;
- authority row específica para B1R1;
- somente então `draft → authorized_non_normative`.

## 17. Activation

B1R1 somente poderá ser ativado se toda a correção estiver concluída antes da primeira Opportunity.

A activation interval permanece:

`2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`

Se isso não ocorrer:

> **não deslocar timestamps**

> **replacement schedule expires without execution**

## 18. PubMed operational completeness note

A futura runbook deve explicitar que ESearch:

- usa `db=pubmed`;
- usa a frozen query como `term`;
- usa `retmode=json`;
- deve recuperar o identifier set completo;
- não usa relative date filter.

NCBI documenta retmax default 20 e limite de 10.000 UIDs para PubMed ESearch.

Se a query retornar mais de 10.000 PMIDs:

> **não fingir completeness e não alterar a query silenciosamente.**

Isso deverá ser tratado como blocker/deviation conforme o contrato vigente.

## 19. O que esta decisão não autoriza

Este Documento 82 não autoriza, por si só:

- invalidar B1;
- criar B1R1;
- executar connectivity probe;
- materializar novos artifacts físicos;
- criar novas EpochSource rows;
- criar Opportunities;
- persistir nova authority;
- ativar qualquer Epoch;
- executar PubMed;
- executar ClinicalTrials.gov;
- criar MeasurementEvent.

## 20. Corrective preparation authority solicitada

Para prosseguir, requer decisão explícita do owner vinculada a:

- corrective preparation;
- Documento 82;
- TOPI-N2-DCBTI-01;
- replacement B1 → B1R1.

Formulação válida:

> **APPROVED — corrective preparation / Documento 82 / TOPI-N2-DCBTI-01 / replace B1 with B1R1**

Essa decisão autorizará somente:

1. invalidar o B1 não executado;
2. criar artifacts corretivos candidatos/finais;
3. minimal non-target-specific connectivity probe;
4. materializar B1R1 draft com os mesmos timestamps;
5. validar payload↔Opportunity equality;
6. calcular/preservar novo design_frozen_at;
7. executar testes/rebuild necessários.

Ela não autorizará execution authority do B1R1.

## 21. Próximo gate posterior

Depois da corrective preparation:

> **novo execution authority package para exact B1R1**

e nova owner decision explícita.

## 22. Estado enquanto não houver corrective authority

> **CURRENT_B1 = AUTHORIZED_NON_NORMATIVE_BUT_GOVERNANCE_BLOCKED**

> **CURRENT_B1_ACTIVATION = PROHIBITED**

> **B1R1 = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

**Fim do Documento 82**
