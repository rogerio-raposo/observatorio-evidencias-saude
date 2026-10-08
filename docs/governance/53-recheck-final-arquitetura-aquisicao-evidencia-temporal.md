# 53 — Recheck Final da Arquitetura de Aquisição de Evidência Temporal Não Normativa

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS**  
**Modo:** alto  
**Objeto:** recheck do Documento 51 após hardening requerido pelo Documento 52

## 1. Resultado

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **ARCHITECTURE_CHOICE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

> **FIRST_OBSERVATION_INSTANCE = AUTHORIZED_FOR_SELECTION_AND_SPECIFICATION_ONLY**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

A arquitetura metodológica está suficientemente fechada para selecionar e especificar a primeira instância piloto, mas ainda não para executá-la.

## 2. TEA-G01 — shadow M2

Recheck:

- measurement event é distinto de MonitoringCycle;
- repetição não muda maintenance level;
- M1 não ganha governing Monitor;
- não existe coverage guarantee/currentness automation;
- mudança de purpose para surveillance exige STOP_AND_REASSESS_M1_TO_M2.

Resultado:

> **PASS**

## 3. TEA-G02 — Search semantic laundering

Recheck:

- semantic storage mapping tornou-se obrigatório;
- Search só pode registrar Search científica real;
- liveness/latency/capacity probes não podem usar Search por conveniência;
- ausência de storage adequado usa Artifact/documentação até decisão posterior;
- CadenceObservation permanece proibida para pre-calibration measurement.

Resultado:

> **PASS**

## 4. TEA-G03 — latency endpoint semantics

Recheck:

- publication, indexing, source availability, OES detection e OES processing latency são separados;
- endpoints, precision, timezone e timestamp provenance são obrigatórios;
- censoring/interval bounds são aceitos;
- ausência de endpoint observável resulta em LATENCY_NOT_OBSERVABLE.

Resultado:

> **PASS**

## 5. TEA-G04 — measurement schedule anchoring

Recheck:

- measurement schedule nunca recebe candidate status;
- não é copiada automaticamente para Calibration Dossier;
- igualdade numérica futura exige justificativa independente.

Resultado:

> **PASS**

## 6. TEA-G05 — adaptive design / opportunistic changes

Recheck:

- Observation Epoch fixa design;
- mudança material cria novo epoch/plan version;
- deviations são append-only;
- dados pré/pós mudança permanecem estratificados;
- stop/review boundary é pré-especificado.

Resultado:

> **PASS**

## 7. TEA-G06 — source scope laundering

Recheck:

- production sources não definem surveillance universe;
- candidate source universe/included/excluded/unknown são explícitos;
- coverage claim é limitado ao measurement scope.

Resultado:

> **PASS**

## 8. TEA-G07 — authority laundering

Recheck:

- execution authority exige evidence record;
- instrução genérica, publication approval e AI verification não bastam;
- operational execution authority deve ser decisão humana competente;
- data-governance authority, quando aplicável, deve ser humana/institucional;
- scientific/methodological judgments qualificados exigem human reviewer/expert apropriado.

Resultado:

> **PASS**

Consequência:

> **REAL_PROSPECTIVE_OBSERVATION continua NOT_AUTHORIZED.**

## 9. TEA-G08 — capacity laundering

Recheck:

- pilot effort;
- throughput;
- constrained performance;
- provisional resource requirement;
- sustainable capacity

são conceitos separados.

Pilot effort pode informar B3/B5, mas não prova sustainable capacity.

Resultado:

> **PASS**

## 10. TEA-G09 — incidental finding

Recheck:

Fluxo obrigatório:

`measurement_event → observed_finding → provenance → candidate triage → canonical update workflow`

Sem alteração automática de conclusion, assurance, currentness ou ProductVersion.

Resultado:

> **PASS**

## 11. TEA-G10 — false negative / outcome conflation

Recheck:

O modelo foi endurecido para dimensões ortogonais:

- execution_status;
- result_state;
- denominator_status;
- failure_attribution.

`result_count=NULL` nunca equivale a zero.

Falha observada pelo OES não é atribuída à fonte sem evidência causal.

Resultado:

> **PASS**

## 12. TEA-G11 — drift

Recheck:

- target/source/query/interface/instrumentation/authority/operational change exige novo epoch, supersession ou invalidation;
- fatos históricos são preservados;
- transportability exige decisão explícita.

Resultado:

> **PASS**

## 13. TEA-G12 — data governance

Recheck:

- minimization por event class;
- retention/disposal;
- access scope;
- secrets/credentials proibidos em evidence artifacts;
- termos/licenças e conteúdo protegido tratados explicitamente.

Resultado:

> **PASS**

## 14. TEA-G13 — Result Package laundering

Recheck:

Fluxo obrigatório:

> **Observation Plan → Observation Epoch(s) → Result Package → novo Evidence Readiness Assessment → somente se READY: Calibration Dossier**

Não há atalho.

Resultado:

> **PASS**

## 15. TEA-G14 — favorable stopping

Recheck:

- review boundary;
- termination reasons;
- extension rule;
- early-stop governance

são pré-especificados.

Não existe minimum-N implícito.

Resultado:

> **PASS**

## 16. TEA-G15 — query/source heterogeneity

Recheck:

Mudanças materiais geram nova versão/epoch e permanecem visíveis.

Resultado:

> **PASS**

## 17. TEA-G16 — external facts without locator

Recheck:

Fato externo material exige source, locator, retrieval time, version/effective date quando disponível, precision e interpretation.

Sem locator auditável, não pode controlar readiness/calibration.

Resultado:

> **PASS**

## 18. TEA-G17 — premature physical migration

Recheck:

- semantic event model vem antes do physical contract;
- existing objects são usados apenas quando semanticamente corretos;
- Artifact/documentação pode sustentar o primeiro bloco;
- migration nova depende de lacuna comprovada + gate próprio.

Resultado:

> **PASS**

## 19. TEA-G18 — pilot selection before architecture closure

Recheck:

O Documento 51 não selecionou N1 ou N2 durante o hardening.

Resultado:

> **PASS**

Esse isolamento reduz risco de overfitting da arquitetura ao primeiro piloto.

## 20. Checagem adicional — outcome model ortogonal

O modelo final evita tratar como mutuamente exclusivos fatos que podem coexistir, por exemplo:

- retrieval completed;
- nonzero records;
- denominator unknown.

Resultado:

> **PASS**

## 21. Checagem adicional — execution authority boundary

A arquitetura diferencia claramente:

- plan preparation;
- plan specification;
- authority to execute;
- future authority to calibrate/activate.

Logo:

> especificar uma instância não equivale a autorizar observação.

Resultado:

> **PASS**

## 22. Checagem adicional — M1 versus M2

O contrato está coerente com a Política de Cadence:

- M1 observation = measurement;
- M1 periodic policy = reassessment;
- M2 = Monitor + MonitoringCycles;
- o piloto não cria “M2 sem Monitor”.

Resultado:

> **PASS**

## 23. Checagem adicional — migration 032

CadenceObservation continua reservada a semântica de CadenceObligation/CadenceContract.

O piloto não reutilizará a infraestrutura normativa para armazenar pre-calibration measurement.

Resultado:

> **PASS**

## 24. Decisões arquiteturais consolidadas

1. O OES terá protocolo transversal reutilizável de aquisição temporal.
2. Toda coleta real ocorre em instância target/source-specific.
3. Toda execução é versionada por Observation Epoch.
4. Measurement schedule é não normativo e anti-anchoring.
5. M1 pilot não é Monitor.
6. Search só registra Search semanticamente real.
7. Pre-calibration measurement não é CadenceObservation.
8. Fatos externos materiais exigem locator auditável.
9. Outcome de measurement event é multidimensional.
10. Authority humana explícita é pré-requisito de execução.
11. Result Package retorna obrigatoriamente ao Evidence Readiness.
12. Novo physical contract só será aberto se a instância demonstrar lacuna semântica material.

## 25. O que o PASS autoriza

Autoriza:

- selecionar o primeiro exact target piloto;
- especificar a primeira Temporal Observation Plan Instance;
- mapear candidate source universe;
- preparar semantic storage mapping;
- preparar authority package;
- preparar data-governance package;
- definir observation epochs e measurement design não normativo;
- submeter a instância a gate target-specific.

Não autoriza:

- iniciar source checks reais;
- executar measurement schedule;
- criar Search real para o piloto;
- obter ou registrar authority fictícia;
- criar UpdateRiskProfile como “approved” sem authority;
- abrir Calibration Dossier;
- criar cadence;
- criar UpdatePolicy;
- criar Monitor;
- criar scheduler/notifications;
- criar migration nova.

## 26. Seleção do piloto ainda pendente

> **FIRST_OBSERVATION_INSTANCE = AUTHORIZED_FOR_SELECTION_AND_SPECIFICATION_ONLY**

A escolha entre N1-01 e N2/dCBT-I deve ser feita no próximo bloco com critérios explícitos de:

- information gain;
- source complexity;
- cost;
- semantic storage feasibility;
- authority feasibility;
- data-governance feasibility;
- risk of overfitting.

## 27. Estado final

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **ARCHITECTURE_CHOICE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

> **FIRST_OBSERVATION_INSTANCE = AUTHORIZED_FOR_SELECTION_AND_SPECIFICATION_ONLY**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = DEFERRED_PENDING_INSTANCE_NEED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **SCHEDULER = DEFERRED**

> **NOTIFICATIONS = DEFERRED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 28. Próximo passo exato

> **Após checkpoint, em modo alto, selecionar o primeiro exact target para Temporal Observation Plan Instance e especificar a instância completa, sem executar observação real.**

A instância deverá ser submetida a gate target-specific antes de qualquer execução.

**Fim do Documento 53**
