# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Arquitetura de Aquisição Temporal Não Normativa

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP112  
**Checkpoint anterior:** CP111  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento arquitetural do bloco de aquisição de evidência temporal não normativa

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **ARCHITECTURE_CHOICE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

> **FIRST_OBSERVATION_INSTANCE = AUTHORIZED_FOR_SELECTION_AND_SPECIFICATION_ONLY**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = DEFERRED_PENDING_INSTANCE_NEED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP111 foi confirmado:

- branch `main`;
- HEAD inicial `023691c7a180137a800e570d86bb8092917effba`;
- CP111 vigente;
- nenhum commit posterior inesperado;
- dois readiness assessments reais concluídos;
- N1-01 e N2/dCBT-I = `INSUFFICIENT_EVIDENCE`;
- próximo problema = aquisição de evidência temporal não normativa.

## 3. Documentos do bloco

### Documento 51

`docs/governance/51-arquitetura-aquisicao-evidencia-temporal-nao-normativa-v01.md`

Commits principais:
- candidato inicial: `12d4cc9510d1ced7cddd1bccb65e90c569aae9a2`;
- hardening pós-gate: `0ae895caab901da80baf68090c1cd756a7531c6d`;
- fechamento de outcome/authority semantics: `b439a638867d5cda5ec829d91caeed04ef307836`.

### Documento 52

`docs/governance/52-gate-adversarial-arquitetura-aquisicao-evidencia-temporal.md`

Commit:

`037632745671809788c3bf69ebc6cda686cdf870`

Resultado first pass:

> **REVISE**

### Documento 53

`docs/governance/53-recheck-final-arquitetura-aquisicao-evidencia-temporal.md`

Commit:

`86cc71ac6d016afe2ff5a0c718c9ae8a67ffa042`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 4. Decisão arquitetural

A arquitetura escolhida é:

> **protocolo transversal reutilizável + Temporal Observation Plan Instance target/source-specific**

Racional:

- blockers temporais recorrentes em N1/N2 justificam invariantes comuns;
- source scope, authority, measurement design e fatos observados permanecem contextuais;
- um plano puramente target-specific duplicaria regras e aumentaria risco de overfitting;
- um protocolo transversal sem instância específica criaria risco de generalização e Monitor genérico.

## 5. M1 / Monitor boundary

Os dois pilots candidatos atuais são M1.

Logo:

- observation pilot não é Monitor;
- não cria MonitoringCycle;
- não cria governing Monitor;
- não cria cadence_due;
- não cria compliance/overdue/breach;
- não muda M1 para M2;
- não sustenta currentness automática.

Se o purpose passar a surveillance persistente:

> **STOP_AND_REASSESS_M1_TO_M2**

## 6. Storage semantics

Obrigatório semantic storage mapping antes de execução.

Regras consolidadas:

- Search somente para Search científica real;
- source liveness/latency/capacity probe não é Search;
- pre-calibration measurement não é CadenceObservation;
- CadenceObservation permanece vinculada à semântica normativa CadenceContract/CadenceObligation;
- ausência de objeto físico compatível pode ser tratada com Artifact/documentação auditável;
- migration nova somente se lacuna material for comprovada e passar por gate próprio.

## 7. Measurement design

Toda execução futura deverá usar Observation Epoch versionado.

Cada epoch fixa:

- plan version;
- exact target;
- source scope;
- query/strategy versions;
- interfaces;
- measurement design;
- start/review boundary;
- data-quality rules.

Mudança material gera novo epoch/versão ou invalidação.

## 8. Measurement schedule

Estado obrigatório:

> **NON_NORMATIVE**

Não cria:

- cadence candidate;
- UpdatePolicy;
- CadenceContract;
- overdue;
- breach;
- notifications;
- auto-escalation.

Persistência ou repetição não promove agenda experimental a policy.

## 9. Source / latency discipline

Production-search source não vira surveillance source por herança.

Instância futura deverá registrar candidate source universe, inclusões, exclusões, unknowns e scope claim.

Latencies distintas:

- publication;
- indexing;
- source availability;
- OES detection;
- OES processing.

Sem endpoints/precision adequados:

> **LATENCY_NOT_OBSERVABLE**

## 10. Outcome model

Measurement event usa dimensões ortogonais:

- execution_status;
- result_state;
- denominator_status;
- failure_attribution.

`result_count=NULL` nunca significa zero.

Falha observada pelo OES não é atribuída à fonte sem evidência causal.

## 11. Authority

Antes de observação real, exigir evidence record com:

- authority type;
- human actor/role competente;
- scope;
- decision;
- timestamp;
- artifact/locator;
- limitations.

Não bastam:

- instrução genérica de continuidade;
- owner publication approval;
- AI verification;
- papel abstrato sem decisão.

Logo:

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

## 12. Data governance

Instância deverá fechar antes da execução:

- data minimization;
- access;
- retention/disposal;
- terms/licensing quando material;
- personal/sensitive data handling;
- secrets handling;
- incident path.

## 13. Incidental findings

Fluxo:

> `measurement_event → observed_finding → provenance → candidate triage → canonical update workflow`

Sem alteração automática de:

- conclusion;
- assurance;
- currentness;
- ProductVersion.

## 14. Capacity

Distinguir:

- pilot effort;
- observed throughput;
- constrained performance;
- provisional resource requirement;
- sustainable capacity assessment.

Pilot effort não prova B5 suficiente.

## 15. Chain após observação

Fluxo obrigatório:

> **Observation Plan → Observation Epoch(s) → Result Package → novo Evidence Readiness Assessment → somente se READY: Calibration Dossier**

Nenhum atalho autorizado.

## 16. CI / evidência técnica

O bloco foi exclusivamente documental/metodológico.

Nenhuma migration, View, validator, template ou workflow foi alterado.

Não há novo run técnico a promover.

## 17. Próximo passo exato

Após a pausa obrigatória, em modo alto:

> **selecionar entre N1-01 e N2/dCBT-I o primeiro exact target para a Temporal Observation Plan Instance e especificar a instância completa, sem executar observação real.**

A seleção deve comparar explicitamente:

- information gain;
- source complexity;
- cost;
- semantic storage feasibility;
- authority feasibility;
- data-governance feasibility;
- risk of overfitting.

A instância deverá então especificar:

- target/source scope;
- candidate source universe;
- source characterization tasks;
- UpdateRiskProfile preparation;
- semantic storage mapping;
- observation events;
- non-normative measurement design;
- authority package;
- data-governance package;
- start/review boundary;
- stop conditions;
- invalidation triggers;
- expected Result Package.

A instância deverá passar por gate target-specific antes de execução.

## 18. Disciplina de modo

> **Modo alto permanece recomendado para seleção/especificação do primeiro piloto.**

Após fechamento e gate da instância, reavaliar necessidade de modo alto para eventual implementação mecânica/documental.

## 19. Regra de parada

Após ativação do CP112:

> **parar e aguardar “Prossiga” explícito do usuário.**

## 20. HEAD antes da criação do CP112

`b46be3cad630f1d8559d1a1a13b5ce7180cce6bd`

**Fim do CP112**
