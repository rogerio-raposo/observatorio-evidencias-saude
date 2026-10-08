# 71 — Pacote de Decisão de Authority para Preparação da Phase B da TOPI-N2-DCBTI-01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **AWAITING_EXPLICIT_OWNER_DECISION**  
**Dependências:** Documentos 69–70  
**Instância:** TOPI-N2-DCBTI-01  
**Escopo:** preparation-only antes do design freeze físico

## 1. Contexto

O Documento 69 especificou o primeiro desenho experimental finito da Phase B.

O Documento 70 concluiu:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

O recheck identificou uma ordem operacional obrigatória:

1. connectivity verification;
2. real draft materialization;
3. design freeze;
4. somente depois execution authority.

Razões:

- `runtime_connectivity_status` do EpochSource é imutável;
- a migration 033 exige execution authority com `decided_at >= design_frozen_at`.

Logo:

> **este pacote NÃO é Phase B execution authority.**

## 2. Decisão solicitada

Solicita-se ao owner uma decisão exclusivamente sobre:

> **autorizar ou não a PREPARAÇÃO da Phase B da TOPI-N2-DCBTI-01.**

A preparação existe para tornar o desenho documental do Documento 69 um draft físico íntegro, sem executar measurement.

## 3. Atos que APPROVED autoriza

Se APPROVED, autoriza somente:

### 3.1 Freshness e target recheck

- Freshness Gate do repositório;
- confirmar exact target ainda current;
- confirmar ausência de invalidation trigger.

### 3.2 Runtime connectivity probes mínimos

PubMed/MEDLINE:

- verificar conectividade real do runtime pretendido com NCBI E-utilities;
- executar somente probe mínimo necessário para provar interface availability;
- registrar timestamp, runtime/client, endpoint/locator e observed response.

ClinicalTrials.gov:

- verificar conectividade real do runtime pretendido com API v2;
- executar somente probe mínimo necessário para provar interface availability;
- registrar timestamp, runtime/client, endpoint/locator e observed response.

Esses probes:

- não são scientific Search;
- não são prospective measurement;
- não são MonitoringCycle;
- não são CadenceObservation.

### 3.3 Query/interface Artifact freeze

Autoriza preparar/persistir Artifacts necessários para:

- TOPI specification;
- source definition;
- measurement design;
- PubMed query strategy;
- ClinicalTrials.gov query/API parameterization;
- interface configuration;
- schedule definition/provenance.

Não autoriza executar as queries como B1 measurement.

### 3.4 Real draft materialization

Se e somente se connectivity prerequisites forem honestamente satisfeitos:

autoriza materializar em `maintenance`:

- TemporalObservationPlan;
- ObservationSource rows:
  - PubMed included;
  - ClinicalTrials.gov included;
  - BVS/LILACS deferred;
- ObservationEpoch B1 em `draft`;
- EpochSource PubMed;
- EpochSource ClinicalTrials.gov;
- canonical `measurement_schedule_payload`;
- 8 PubMed Opportunity rows;
- 6 ClinicalTrials.gov Opportunity rows.

### 3.5 Integrity verification

Autoriza verificar:

- payload validity;
- payload↔Opportunity exact equality;
- target/source/epoch consistency;
- Artifact active state;
- source-debt preservation;
- design_frozen_at.

## 4. Desenho que será materializado

Plan:

> **TOPI-N2-DCBTI-01 v0.2-final**

Physical plan version candidate:

> **2**

Epoch:

> **B1**

Start boundary:

> **2026-10-19T08:00:00-03:00**

Review boundary:

> **2026-11-10T18:00:00-03:00**

PubMed:

> **8 finite opportunities**

ClinicalTrials.gov:

> **6 finite opportunities**

BVS/LILACS:

> **deferred source debt — no B1 opportunities**

Os timestamps exatos são os do Documento 69.

Nenhuma alteração silenciosa é autorizada.

## 5. O que APPROVED NÃO autoriza

Mesmo após APPROVED, permanece proibido:

- iniciar B1 measurement;
- criar MeasurementEvent;
- executar target-specific PubMed B1 query como measurement;
- executar target-specific ClinicalTrials.gov B1 query como measurement;
- criar genuine scientific Search por força deste pacote;
- criar SearchHit/ScreeningDecision;
- resolver opportunity como completed por measurement;
- alterar product currentness;
- alterar conclusion;
- alterar assurance;
- criar UpdateSignal automaticamente;
- criar UpdatePolicy;
- criar CadenceContract;
- criar CadenceObservation;
- criar Monitor/MonitoringCycle;
- criar scheduler;
- notification;
- auto-escalation;
- Calibration Dossier;
- normative temporal value;
- M3 formalization.

## 6. Connectivity failure rule

Se PubMed ou ClinicalTrials.gov não puder ser classificada honestamente como runtime `verified`:

> **não materializar EpochSource daquela source como verified.**

Também não é autorizado:

- remover silenciosamente a source;
- trocar para manual;
- alterar interface;
- mudar query scope;
- mover timestamps.

Nesse caso:

> **PREPARATION_RESULT = REVISE_REQUIRED**

e retornar ao gate.

## 7. Target drift rule

Se o exact ProductVersion ou Investigation deixar de current:

> **parar.**

Não materializar B1.

Produzir novo target-specific assessment.

## 8. Schedule expiry rule

Se o processo de preparação + draft freeze + posterior execution authority não estiver concluído antes da primeira opportunity de 2026-10-19:

> **não deslocar timestamps.**

O desenho B1 deve ser classificado:

> **EXPIRED_NOT_EXECUTED**

e substituído por novo desenho versionado/re-gated.

## 9. Design freeze

Após draft materialization íntegra:

calcular/preservar:

> **design_frozen_at**

conforme migration 033.

A partir desse instante:

- EpochSource não muda;
- Opportunities não mudam;
- schedule payload não muda.

Erro material:

> invalidate draft + new epoch.

Não UPDATE/DELETE corretivo.

## 10. Próximo authority package após preparação

Se a preparação terminar com PASS:

criar novo pacote específico:

> **Phase B Operational Execution Authority**

Esse pacote futuro deverá referenciar:

- exact Plan UUID;
- exact Epoch UUID;
- exact source rows;
- exact opportunity sets;
- design_frozen_at;
- Artifact locators/hashes;
- runtime connectivity evidence;
- start/review boundary;
- limitations.

A decisão humana final precisa ocorrer:

> **em ou depois de design_frozen_at.**

Uma approval anterior não será reutilizada.

## 11. Scientific/methodological authority

Este pacote não satisfaz:

- UpdateRiskProfile human review;
- A1/A3/A4 scientific judgment;
- calibration authority;
- normative activation.

Isso permanece separado.

## 12. Decisão

Escolher explicitamente:

- [ ] **APPROVED** — autorizo a **preparação da Phase B**, conforme Documento 71, da TOPI-N2-DCBTI-01, limitada a connectivity probes, Artifact/config freeze e draft materialization, sem measurement execution.
- [ ] **REVISE** — solicito alteração antes da preparação.
- [ ] **REJECTED** — não autorizo a preparação.

Para ser válida, a resposta deve vincular explicitamente:

- **Phase B preparation**;
- **Documento 71**;
- **TOPI-N2-DCBTI-01**.

Exemplo válido:

> **APPROVED — Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01**

Mensagem genérica:

- `Prossiga`;
- `Ok`;
- `Pode continuar`;

> **não será interpretada como authority.**

## 13. Estado enquanto não houver decisão

> **PREPARATION_AUTHORITY = PENDING**

> **RUNTIME_CONNECTIVITY_PROBES = NOT_AUTHORIZED**

> **REAL_TOPI_DRAFT_MATERIALIZATION = NOT_AUTHORIZED**

> **DESIGN_FROZEN_AT = NOT_ESTABLISHED**

> **PHASE_B_EXECUTION_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

**Fim do Documento 71**
