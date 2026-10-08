# 59 — TOPI-N2-DCBTI-01 Plan Amendment v0.2 — Phase B Design Boundary

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Instância:** TOPI-N2-DCBTI-01  
**Plan version:** v0.2 candidate  
**Status:** **CANDIDATE_FOR_TARGET_SPECIFIC_RECHECK — PHASE_B_NOT_AUTHORIZED**  
**Dependências:** Documentos 51–58; CP114  
**Objeto:** fechar source inclusion, event model e physical-boundary da Phase B antes de qualquer repeated measurement

## 1. Decisão geral

A Phase A demonstrou que a Phase B não deve começar com as três fontes históricas tratadas de forma homogênea.

O Amendment v0.2 propõe:

> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

> **PHASE_B_EVENT_MODEL = SOURCE_SPECIFIC_NON_NORMATIVE_MEASUREMENT_EVENT**

> **PHASE_B_PHYSICAL_EVENT_CONTRACT = REQUIRED_BEFORE_EXECUTION**

> **MEASUREMENT_SCHEDULE = NOT_YET_SELECTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

## 2. Source inclusion

### 2.1 PubMed/MEDLINE

Incluir na Phase B candidata.

Racional:

- E-utilities documentada;
- identificador estável PMID;
- CRDT/EDAT/publication-date fields disponíveis;
- source behavior suficientemente caracterizado para desenho experimental;
- access controls conhecidos.

Estado:

> **INCLUDED_CANDIDATE**

### 2.2 ClinicalTrials.gov

Incluir na Phase B candidata.

Racional:

- API v2 documentada;
- identificador estável NCT ID;
- posting/update date fields disponíveis;
- interface de dados estruturados;
- source class distinta de bibliographic database, aumentando valor informacional.

Condição:

> runtime connectivity deve ser confirmada antes da primeira execução.

Estado:

> **INCLUDED_CANDIDATE_WITH_RUNTIME_CONNECTIVITY_PRECONDITION**

### 2.3 BVS/LILACS

Não incluir no primeiro repeated-measurement epoch.

Racional:

- importância científica não é negada;
- source environment foi parcialmente caracterizado;
- public reproducible programmatic path para o intended OES workflow não foi estabelecido;
- misturar execução manual ad hoc com dois canais programáticos produziria séries operacionalmente heterogêneas e risco de false comparability.

Estado:

> **DEFERRED_SOURCE_DEBT**

BVS/LILACS permanece:

- no candidate source universe;
- explicitamente fora do primeiro Phase B epoch;
- elegível para futuro epoch próprio se:
  - access path programático reproduzível for estabelecido; ou
  - um manual measurement design explícito, versionado e re-gated for aprovado.

Exclusão inicial não autoriza claim de source completeness.

## 3. Por que não usar um único policy-aggregate event

PubMed e ClinicalTrials.gov possuem:

- semânticas distintas;
- identificadores distintos;
- datas operacionais distintas;
- access paths distintos;
- tipos de novidade distintos.

Logo:

> **PHASE_B_MEASUREMENT_EVENTS = SOURCE_SPECIFIC**

É proibido registrar apenas:

> "cycle completed"

ou equivalente agregado.

A eventual análise policy_aggregate só poderá ser derivada depois, preservando source-specific debt.

## 4. Event semantic proposto

Nome conceitual:

> **TemporalMeasurementEvent**

Natureza:

- pré-calibração;
- não normativa;
- target-specific;
- source-specific;
- append-preserving;
- não Monitor;
- não CadenceObservation;
- não UpdateSignal;
- não EvidenceEvent.

Cada evento representa:

> uma oportunidade planejada ou uma execução real de measurement experimental de uma source específica dentro de um Observation Epoch.

## 5. Identidade mínima do evento

Campos conceituais:

- measurement_event_uuid;
- plan_instance_code;
- plan_version;
- observation_epoch_code;
- exact target version UUID;
- source_code;
- source_class;
- interface_code;
- planned_for;
- execution_started_at;
- execution_completed_at;
- operator/runtime;
- query_or_strategy_version;
- execution_status;
- result_state;
- denominator_status;
- result_count;
- failure_attribution;
- source_failure_evidence;
- source_locator;
- source_date_semantics_payload;
- source_observed_date;
- oes_detected_at;
- latency_observability_status;
- latency_bounds_payload;
- retrieved_identifier_count;
- retrieved_identifiers_artifact_uuid;
- effort_payload;
- deviation_uuid / deviation reference;
- created_at;
- created_by;
- record_status.

Nem todos os campos são obrigatórios em todos os event types.

## 6. Outcome model

Mantém o modelo do Documento 51.

### execution_status

- completed;
- partial;
- failed;
- not_executed;
- indeterminate.

### result_state

- zero;
- nonzero;
- unknown;
- not_applicable.

### denominator_status

- known;
- unknown;
- not_applicable.

### failure_attribution

- source_confirmed;
- oes_confirmed;
- mixed;
- unknown;
- not_applicable.

`result_count=NULL` nunca significa zero.

## 7. Planned opportunity versus executed event

Para evitar perder missingness:

cada planned measurement opportunity deve possuir identidade própria, ainda que não seja executada.

Logo o event model precisa representar:

- planned;
- attempted;
- completed;
- not_executed;
- failed.

Um evento não executado não pode ser apagado.

Isso permite medir:

- missingness;
- adherence ao measurement design experimental;
- operational burden;
- reasons for non-execution.

Não cria compliance normativa.

## 8. Observation Epoch B1

A futura Phase B começará, se autorizada, em:

> **OBSERVATION_EPOCH = B1**

B1 deverá fixar antes da execução:

- target;
- PubMed + ClinicalTrials.gov;
- query/strategy version por source;
- interface;
- measurement schedule;
- start boundary;
- review boundary;
- event schema version;
- data-quality rules;
- failure taxonomy;
- runtime/tool versions quando material.

BVS/LILACS não pertence a B1.

## 9. Semantic storage assessment

### 9.1 artifact.artifact

O objeto existente armazena:

- artifact_type;
- storage_key;
- content_hash;
- mime_type;
- source_uri;
- created_at;
- status.

Ele é adequado para:

- locator;
- file metadata;
- immutable payload externalizado;
- supporting evidence.

Não é adequado como único event store para B1 porque não normaliza:

- exact target;
- source;
- planned_for;
- execution status;
- result state;
- denominator status;
- failure attribution;
- latency semantics;
- effort;
- epoch;
- deviations.

Usar apenas Artifact tornaria replay dependente de parsing de arquivos e reduziria queryability/auditability.

### 9.2 investigation.search

Adequado apenas quando o measurement event produzir uma Search científica real.

Não pode ser event store genérico.

### 9.3 maintenance.evidence_event

Inadequado porque:

- exige `MonitoringCycle`;
- pertence à semântica de validade/evidence events em Monitor;
- target M1 não possui governing Monitor.

### 9.4 maintenance.cadence_observation

Inadequado porque:

- exige CadenceObligation;
- implica contrato temporal normativo;
- produziria policy laundering.

## 10. Conclusão física

A Phase B revela uma lacuna física material:

> **structured, queryable, append-preserving pre-calibration measurement events are not representable without semantic compromise.**

Logo:

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REQUIRED_FOR_PHASE_B**

Mas:

> **MIGRATION = NOT_YET_AUTHORIZED**

Antes de migration é obrigatório:

1. especificar contrato físico;
2. adversarial gate;
3. fechar schema/test plan;
4. só então autorizar implementação.

## 11. Regra para payloads/artifacts

Mesmo com futuro event object:

- identifier lists extensas;
- raw response snapshots;
- query export;
- evidence locator package;

devem permanecer como Artifacts referenciados pelo evento.

O event object deve conter apenas o necessário para:

- identidade;
- causal/temporal semantics;
- outcome;
- observability;
- linkage;
- replay.

Evitar duplicar payload bruto no banco.

## 12. Source-specific fields — PubMed

Event B1/PubMed deverá conseguir registrar:

- query version;
- interface = E-utilities / explicit alternative;
- PMID set locator/artifact;
- CRDT quando disponível;
- EDAT quando disponível;
- publication/e-publication date quando relevante;
- OES detection timestamp;
- denominator status;
- result count quando confiável;
- rate-limit/access incident sem presumir source failure.

Não exigir timestamp precision maior que a fonte fornece.

## 13. Source-specific fields — ClinicalTrials.gov

Event B1/CTG deverá conseguir registrar:

- query version;
- API v2/runtime path;
- NCT identifier set;
- StudyFirstPostDate;
- ResultsFirstPostDate quando aplicável;
- LastUpdatePostDate;
- OES detection timestamp;
- denominator status;
- result count;
- runtime connectivity status.

Não interpretar registry posting como article publication.

## 14. BVS/LILACS debt representation

O futuro physical contract deve conseguir registrar source debt mesmo para source fora do epoch.

No mínimo, o Plan/Epoch deve registrar:

- candidate_source = BVS_LILACS;
- inclusion_status = deferred;
- reason_code = access_path_not_reproducible;
- reassessment trigger.

BVS debt não pode desaparecer porque B1 tenha apenas duas sources.

## 15. Measurement schedule decision

Neste Amendment:

> **MEASUREMENT_SCHEDULE = DEFERRED_PENDING_PHYSICAL_EVENT_CONTRACT**

Racional:

1. um schedule sem event object estruturado produziria logs frágeis;
2. missed/non-executed opportunities precisam ser representáveis;
3. source-specific precision deve ser expressa corretamente;
4. schedule deve ser testável/replayable antes da execução.

O fato de PubMed atualizar corpus diariamente:

> **não determina automaticamente a agenda experimental do OES.**

O fato de ClinicalTrials.gov expor posting dates:

> **não determina intervalo experimental.**

Logo nenhum número é selecionado ainda.

## 16. Schedule design principles para etapa posterior

Quando o physical contract passar:

o Amendment final da Phase B deverá escolher um schedule que:

- maximize information gain sobre OES detection process;
- respeite source update resolution;
- seja operacionalmente executável;
- produza planned opportunities suficientes para missingness/replay;
- tenha review boundary pré-definido;
- não seja apresentado como candidate cadence;
- não tente compensar source latency com polling excessivo;
- permaneça source-specific se necessário.

É permitido que PubMed e ClinicalTrials.gov tenham schedules experimentais diferentes.

## 17. Review boundary da futura Phase B

A Phase B não deverá encerrar por "dados parecem suficientes".

O futuro B1 deverá possuir:

- fixed review boundary;
- allowed early-stop reasons;
- extension rule;
- invalidation rules.

Early stop só por:

- target supersession;
- source/interface material change;
- authority withdrawal;
- governance/data issue;
- storage contract failure;
- safety/security incident;
- purpose drift;
- inability to preserve provenance.

## 18. Authority

A approval do Documento 56:

> **não autoriza Phase B.**

Nova authority deverá referenciar explicitamente:

- Plan v0.2 final;
- Observation Epoch B1;
- included sources;
- measurement schedule;
- event physical contract/version;
- start/review boundary.

## 19. UpdateRiskProfile

A Phase B poderá produzir evidence inputs para:

- A2;
- B1;
- B2;
- B3;
- B5.

Ela não pode produzir authoritative ratings automaticamente.

A1/A3/A4 e interpretações de materiality continuam exigindo qualified human judgment.

## 20. Currentness / scientific change guard

Phase B:

- não atualiza currentness automaticamente;
- não altera conclusion;
- não altera assurance;
- não cria ProductVersion;
- não gera `no_update_needed` em sentido normativo.

Scientific finding incidental:

> measurement event → provenance → candidate triage → canonical update workflow.

## 21. Estado v0.2 candidate

> **PLAN_VERSION = V0_2_CANDIDATE**

> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

> **PHASE_B_EVENT_MODEL = SOURCE_SPECIFIC_NON_NORMATIVE_MEASUREMENT_EVENT**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REQUIRED_FOR_PHASE_B**

> **MEASUREMENT_SCHEDULE = DEFERRED_PENDING_PHYSICAL_EVENT_CONTRACT**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION = NOT_YET_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 22. Próximo passo exato

> **Executar target-specific recheck do Plan Amendment v0.2. Se PASS, abrir bloco de especificação física do non-normative measurement event contract antes de qualquer schedule numérico ou Phase B authority request.**

**Fim do Documento 59**
