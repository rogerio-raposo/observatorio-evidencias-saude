# 51 — Arquitetura de Aquisição de Evidência Temporal Não Normativa v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISED_READY_FOR_RECHECK — NO_OBSERVATION_AUTHORIZED**  
**Modo:** alto  
**Dependências:** Documentos 16, 18, 39, 41, 46–50; CP111  
**Objeto:** definir a arquitetura metodológica para adquirir evidência temporal real antes de qualquer calibração normativa

## 1. Decisão arquitetural

Após dois Evidence Readiness Assessments reais com blockers temporais recorrentes, o OES adota como arquitetura candidata:

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

A alternativa de criar primeiro um plano totalmente específico de um único target e só depois abstrair regras comuns não é selecionada.

A razão é que os dois pilots N1/N2 já demonstraram blockers recorrentes suficientemente semelhantes para justificar invariantes transversais, enquanto os dados efetivamente observados, source scope, authority e measurement design continuam necessariamente target-specific.

A arquitetura possui duas camadas:

1. **Temporal Evidence Acquisition Protocol — transversal e reutilizável**;
2. **Temporal Observation Plan Instance — exact target/source-specific**.

Nenhuma das duas é policy de cadence.

## 2. Por que não usar um plano puramente target-specific

Um plano isolado para um único target criaria risco de:

- duplicar regras de admissibilidade;
- variar silenciosamente definição de missingness/failure;
- variar sem controle a fronteira entre measurement e policy;
- transportar decisões acidentais do primeiro piloto;
- dificultar comparação N1/N2;
- dificultar auditoria de drift entre futuros pilots.

Os blockers recorrentes justificam um núcleo metodológico comum.

## 3. Por que o protocolo transversal não pode ser um Monitor genérico

N1-01 e N2/dCBT-I possuem `maintenance_level=M1`.

A política de cadence já estabelece:

> M1 periodic = reassessment programado, não Monitoring Cycle.

Logo, uma instância de aquisição temporal em M1:

- não é Evidence Monitor;
- não cria Monitor Product;
- não cria MonitoringCycle;
- não promete surveillance contínua;
- não cria `cadence_due`;
- não cria overdue/breach;
- não muda M1 para M2;
- não sustenta currentness automática.

> **NON_NORMATIVE_OBSERVATION_MUST_NOT_BECOME_SHADOW_M2**

## 4. Relação com a migration 032

A infraestrutura temporal normativa possui:

- Calibration Dossier;
- CadenceContract;
- CadenceObligation;
- CadenceObservation.

Porém `CadenceObservation` depende de uma obrigação normativa criada por CadenceContract.

Portanto:

> **CadenceObservation não é storage legítimo para coleta experimental pré-calibração.**

Usá-la antes de READY/calibration criaria semantic laundering.

Estado:

> **MIGRATION_032 = SUFFICIENT_FOR_NORMATIVE_FUTURE, NOT_FOR_NON_NORMATIVE_OBSERVATION_LOGGING**

Este documento não autoriza migration nova.

## 5. Camada A — Temporal Evidence Acquisition Protocol

O protocolo transversal define invariantes obrigatórios para qualquer instância.

### 5.1 Identidade

Toda instância deve registrar:

- plan identifier;
- exact target version;
- calibration object;
- readiness scope;
- readiness assessment de origem;
- source scope pretendido;
- plan version;
- status;
- prepared_at;
- execution authority status;
- start boundary;
- end/review boundary;
- reassessment triggers.

### 5.2 Estados mínimos da instância

Estados conceituais:

- `draft`;
- `awaiting_authority`;
- `authorized_non_normative`;
- `active_observation`;
- `paused`;
- `completed`;
- `invalidated`;
- `superseded`.

Esses estados não são assurance nem currentness.

### 5.3 Separação de authority

Distinguir:

- plan preparation;
- scientific/methodological verification;
- operational execution authority;
- data-governance authority;
- future calibration authority.

Nenhuma authority é inferida da outra.

IA/system pode preparar o plano.

IA/system não satisfaz autoridade humana final quando Documento 46/47 a exige.

### 5.4 Trilhas independentes

Toda instância deve separar pelo menos cinco trilhas:

1. **need/risk-profile preparation**;
2. **source characterization**;
3. **prospective observation**;
4. **operational feasibility/capacity observation**;
5. **authority/data-governance record**.

Ausência em uma trilha não pode ser preenchida por dado de outra.

## 6. Need / UpdateRiskProfile preparation

A aquisição de evidência deve permitir preparar um UpdateRiskProfile real para o exact target.

Entretanto:

- A1–A5 são avaliação científica/metodológica;
- B1–B5 incluem componentes operacionais;
- B5 possui temporalidade própria;
- nenhuma dimensão vira número de cadence automaticamente;
- nenhum profile é considerado authoritative sem a verificação humana requerida.

O observation plan pode reunir evidência para o profile.

Ele não pode declarar o profile aprovado por si só.

## 7. Source characterization

Para cada source/canal potencial deve registrar, quando aplicável:

- source identity;
- source class;
- interface/canal observado;
- publication/indexing semantics;
- availability mechanism;
- API/feed/web behavior;
- timestamp fields disponíveis;
- precision;
- liveness;
- retrieval/access constraints;
- source-side failures;
- OES-side failures;
- fallback;
- expected coverage;
- evidence locator;
- observation/retrieval date.

Separar explicitamente:

1. **documented source behavior**;
2. **observed source behavior**;
3. **OES detection behavior**.

Documentação oficial não é observação.

Observação local não prova regra universal da fonte.

## 8. Prospective observation

A observação prospectiva existe para adquirir dados que não podem ser inferidos da produção histórica.

Pode registrar fatos como:

- source check executado;
- timestamp do check;
- query/strategy version;
- source timestamp quando disponível;
- result_count quando confiável;
- retrieved candidates;
- empty check;
- access failure;
- partial failure;
- missing timestamp;
- source unavailability;
- OES processing start/end;
- handoff event;
- incident;
- backlog/load context.

Somente fatos realmente observados podem ser persistidos.

Não fabricar:

- checks não executados;
- source latency;
- denominator;
- failure;
- capacity;
- human review;
- authority.

## 9. Measurement schedule — non-normative

Se uma agenda de medição for necessária, ela deve possuir explicitamente:

> **MEASUREMENT_SCHEDULE_STATUS = NON_NORMATIVE**

Registrar:

- purpose;
- rationale;
- exact target/source;
- start;
- end ou mandatory review boundary;
- planned measurement opportunities;
- deviations;
- missed measurement opportunities;
- change rationale.

A agenda:

- não é cadence candidate automaticamente;
- não cria compliance;
- não cria overdue;
- não cria breach;
- não cria `cadence_due`;
- não cria UpdatePolicy;
- não cria CadenceContract;
- não cria notification;
- não cria auto-escalation.

Persistência ou repetição histórica não promove measurement schedule a policy.

## 10. M1 observation guard

Para target M1:

- repeated source checks são **measurement events**, não Monitoring Cycles;
- ausência de nova evidência não prova currentness normativa;
- execução regular não significa M2;
- nenhuma cobertura contínua pode ser alegada;
- não existe governing Monitor implícito;
- source checks não recebem identidade de MonitorCycle.

Se a operação desejada passar a exigir vigilância persistente substantiva:

> parar e reavaliar M1 → M2 por governança própria.

## 11. Incidental material finding guard

Uma observação pode encontrar nova evidência potencialmente importante.

Esse fato não pode ser ignorado nem convertido automaticamente em atualização.

Quando ocorrer:

1. preservar o finding com provenance;
2. classificá-lo como candidate finding;
3. encaminhar ao mecanismo canônico de triage/update;
4. não alterar conclusion_text;
5. não alterar assurance;
6. não alterar currentness automaticamente;
7. não transformar o observation plan em Monitor por esse evento.

O finding pode iniciar workflow legítimo separado.

## 12. Data quality e denominator

Cada instância deve registrar:

- known denominator, quando realmente conhecido;
- denominator unknown, quando não conhecido;
- missingness;
- censoring;
- partial retrieval;
- duplication;
- timestamp precision;
- source attribution;
- structural change;
- instrumentation change;
- query/strategy change.

`result_count=NULL` não pode ser reinterpretado como zero.

Um empty check só é válido quando a execução suportar essa interpretação.

## 13. Feasibility / capacity

A instância pode observar:

- wall time;
- operator effort;
- processing time;
- handoff time;
- backlog context;
- tool availability;
- failure/retry burden;
- coverage hours;
- resource constraints.

Capacity observation:

- não redefine scientific need;
- não justifica cadence mais lenta por si só;
- não pode ser convertida em calendar rule;
- deve distinguir constrained performance de sustainable capacity.

## 14. Data governance

Antes de execução real, a instância deve declarar:

- quais dados serão coletados;
- finalidade;
- fonte;
- acesso;
- armazenamento;
- retenção;
- minimização;
- presença/ausência de dados pessoais;
- termos/licenças aplicáveis quando relevantes;
- secrets/credentials handling;
- quem pode operar/revisar;
- incident path.

Não persistir credenciais, tokens ou dados sensíveis desnecessários em artifacts de auditoria.

## 15. Drift e invalidation

A instância deve definir triggers de invalidação/reassessment, incluindo:

- target supersession/rebaseline;
- source/API/interface change;
- query/strategy material change;
- source scope change;
- authority change;
- tooling change;
- material missingness discovery;
- operational model change;
- structural break;
- data-governance constraint change.

Após trigger material:

> observações anteriores permanecem históricas, mas sua transportabilidade deve ser reavaliada.

## 16. Reassessment boundary

Conclusão da observação não significa READY.

Ao final, produzir:

> **Temporal Evidence Acquisition Result Package**

contendo:

- observed data inventory;
- source characterization;
- missingness/failure summary;
- operational feasibility evidence;
- risk-profile evidence;
- authority status;
- observation-window rationale;
- denominator limitations;
- structural changes;
- unresolved blockers;
- recommendation for readiness reassessment.

Somente novo Evidence Readiness Assessment pode reconsiderar READY_FOR_CALIBRATION.

## 17. Camada B — Temporal Observation Plan Instance

Cada instância aplica o protocolo comum a um exact context.

Campos conceituais mínimos:

- target ProductVersion/InvestigationVersion;
- calibration object;
- readiness scope;
- plan purpose;
- included sources;
- excluded sources + rationale;
- source characterization tasks;
- need/risk tasks;
- observation events;
- measurement schedule non-normative, se necessário;
- operational metrics;
- data-quality checks;
- authority map;
- data-governance constraints;
- start/end/review boundary;
- stop conditions;
- invalidation triggers;
- expected reassessment output.

## 18. Seleção da primeira instância

Este documento **não seleciona ainda** N1-01 ou N2/dCBT-I como primeira instância.

A seleção deve ocorrer após o gate adversarial desta arquitetura.

Critérios mínimos de seleção:

- target válido/current;
- readiness assessment recente;
- source access operacionalmente possível;
- capacidade de preservar provenance;
- possibilidade de obter authority explícita;
- valor informacional;
- custo/complexidade;
- risco de overfitting;
- data-governance feasibility.

## 19. Persistência nesta etapa

Estado:

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_YET_SPECIFIED**

Antes de criar nova migration, deve ser demonstrado que os fatos necessários não podem ser preservados legitimamente por:

- documentação/artifacts;
- Search real, quando uma Search de fato ocorrer;
- provenance existente;
- records operacionais já semanticamente compatíveis.

É proibido reutilizar um objeto apenas porque seus campos “cabem” se a semântica for diferente.

## 20. Regra de não reutilização de CadenceObservation

> **CadenceObservation requires normative cadence obligation semantics.**

Logo:

> **PRE_CALIBRATION_MEASUREMENT_EVENT != CadenceObservation**

Nenhuma observação experimental pré-calibração deve ser persistida como satisfação de CadenceObligation.

## 21. Critérios de conclusão do bloco

A arquitetura só poderá passar para instância piloto após gate adversarial que ataque, no mínimo:

- policy laundering;
- shadow M2;
- fabricated authority;
- source-scope laundering;
- measurement-schedule inertia;
- denominator laundering;
- capacity laundering;
- incidental finding handling;
- drift;
- target supersession;
- data-governance gaps;
- storage semantic mismatch.


## 24. Hardening após Documento 52

O gate adversarial do Documento 52 resultou em `REVISE`.

Os controles abaixo passam a integrar o contrato metodológico.

## 25. Semantic storage mapping obrigatório

Antes de iniciar qualquer instância, cada event class deve possuir mapeamento explícito:

- event semantic;
- canonical object existente, se houver;
- reason semantic match;
- prohibited substitute;
- fallback documental quando não houver objeto adequado.

Regras:

- scientific search realmente executada pode usar `investigation.search` quando compatível com a Investigation;
- source liveness probe não é Search;
- latency probe não é Search;
- operator-effort measurement não é Search;
- availability check não é MonitoringCycle;
- pre-calibration measurement não é CadenceObservation.

Quando não houver estrutura física semanticamente correta:

> **persistir como Artifact/documento/log auditável até decisão física posterior.**

Não criar migration apenas para eliminar desconforto de armazenamento.

## 26. Latency endpoint contract

Nenhuma latency pode ser registrada como observada sem:

- causal start semantic;
- end semantic;
- timestamp source de ambos;
- timezone;
- precision;
- observed/inferred flag;
- censoring ou interval bounds quando aplicável.

Separar obrigatoriamente:

- publication latency;
- indexing latency;
- source availability latency;
- OES detection latency;
- OES processing latency.

Se o endpoint necessário não for observável:

> **LATENCY_NOT_OBSERVABLE**

Não estimar ponto exato a partir de janela de detecção.

## 27. Observation epoch e versionamento

Toda execução ocorre dentro de um:

> **Observation Epoch**

Um epoch fixa, no mínimo:

- plan version;
- exact target;
- source scope;
- query/strategy versions;
- interfaces/canais;
- measurement design;
- start boundary;
- planned review boundary;
- data-quality rules.

Mudança material cria novo epoch ou nova plan version.

Deviations:

- são append-only;
- não reescrevem o desenho original;
- devem registrar motivo, instante e impacto.

Dados de epochs diferentes não são agregados sem rationale explícita.

## 28. Candidate source universe

Production-search sources não definem surveillance scope por herança.

Cada instância deve registrar:

- candidate source universe;
- included sources;
- excluded sources;
- exclusion rationale;
- unknown/unassessed sources;
- measurement-scope claim.

O plano não pode declarar cobertura além do escopo realmente medido.

## 29. Execution authority evidence

Antes de `authorized_non_normative` ou `active_observation`, deve existir evidence record documental contendo:

- authority type;
- actor/role;
- exact scope;
- decision;
- decision timestamp;
- artifact/locator;
- limitations/conditions.

Não são suficientes por si só:

- instrução genérica para continuar o projeto;
- aprovação editorial anterior;
- owner publication approval;
- AI verification;
- existência abstrata de um owner role.

Sem evidence record:

> **EXECUTION_NOT_AUTHORIZED**

## 30. Taxonomia de resultado de measurement event

Cada measurement event deve terminar em um estado inequívoco, por exemplo:

- `successful_zero_result`;
- `successful_nonzero_result`;
- `denominator_unknown`;
- `partial_retrieval`;
- `source_failure`;
- `oes_failure`;
- `not_executed`;
- `indeterminate`.

Somente `successful_zero_result` sustenta interpretação de ausência de resultado no scope executado.

`result_count=NULL` nunca significa zero.

## 31. Pilot effort não é sustainable capacity

Distinguir:

- observed pilot effort;
- observed throughput;
- constrained performance;
- provisional resource requirement;
- sustainable capacity assessment.

Nenhum desses campos é intercambiável.

Observed pilot effort pode informar B3/B5.

Ele não demonstra B5 adequado sem avaliação própria.

## 32. Drift partitioning e transportability

Quando houver:

- target supersession;
- source/API/interface change;
- query/strategy change;
- measurement instrumentation change;
- authority change;
- operational-model change;

deve ocorrer uma destas ações:

1. novo epoch;
2. plan supersession;
3. invalidation.

Fatos source-level anteriores permanecem históricos.

Seu reuso em target/epoch novo exige explicit transportability assessment.

## 33. Stopping/review rule

Nenhuma instância pode terminar simplesmente porque os dados “parecem suficientes”.

Antes da execução, registrar:

- review boundary;
- allowed termination reasons;
- stop conditions;
- extension rule;
- early-stop governance.

Extensão/encurtamento deve ser versionada antes do readiness reassessment.

Não há minimum-N implícito.

A representatividade é avaliada posteriormente no readiness.

## 34. Measurement schedule anti-anchoring

Measurement schedule:

- não recebe status de cadence candidate;
- não é copiado automaticamente para Calibration Dossier;
- não ganha prioridade por ter sido usado no piloto;
- não vira policy por repetição.

Se futura calibration considerar candidate numericamente igual à agenda experimental:

> exigir justificativa independente baseada nos envelopes de calibration e comparação com alternativas.

## 35. External source fact locator

Qualquer fato externo material para o desenho deve registrar:

- source;
- locator;
- retrieval/observation time;
- version/effective date quando disponível;
- precision;
- interpretation;
- whether documented or observed.

Sem locator auditável:

> não pode ser controlling basis para readiness ou calibration.

## 36. Data minimization por event class

A instância deve especificar, por event class:

- campos estritamente necessários;
- campos proibidos;
- retention;
- disposal;
- access scope.

Credenciais, secrets e tokens nunca são dados de observação.

Conteúdo protegido/licenciado deve ser referenciado de forma mínima e compatível com o direito de acesso/uso, sem cópia desnecessária.

## 37. Chain obrigatória após observação

Fluxo obrigatório:

> **Temporal Observation Plan Instance → Observation Epoch(s) → Temporal Evidence Acquisition Result Package → novo Evidence Readiness Assessment → somente se READY: Calibration Dossier**

É proibido:

- transformar Result Package em Calibration Dossier;
- promover measurement schedule a candidate automaticamente;
- ativar policy diretamente do piloto;
- emitir READY apenas porque o plano foi concluído.

## 38. Query/source heterogeneity

Mudança material de:

- query;
- filters;
- platform;
- interface;
- source;
- coverage rule;

deve ser:

- nova plan version; ou
- novo Observation Epoch.

A heterogeneidade deve permanecer visível na análise final.

## 39. No-shadow-M2 closure

Para M1:

> **repetition frequency does not determine maintenance level.**

Independentemente do número de measurement events:

- não existe MonitoringCycle;
- não existe governing Monitor;
- não existe coverage guarantee;
- não existe cadence compliance;
- não existe overdue/breach;
- não existe currentness automation.

Se o purpose se transformar de measurement em surveillance persistente:

> **STOP_AND_REASSESS_M1_TO_M2**

A instância não pode continuar sob o mesmo significado.

## 40. Incidental finding routing

Finding incidental segue:

> `measurement_event → observed_finding → provenance → candidate triage → canonical update workflow`

O observation plan não possui autoridade para:

- aceitar/rejeitar cientificamente o finding como atualização final;
- alterar conclusão;
- alterar assurance;
- alterar currentness;
- criar ProductVersion automaticamente.

## 41. Estado revisado

> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = REVISED_READY_FOR_RECHECK**

> **ARCHITECTURE_CHOICE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

> **SEMANTIC_STORAGE_MAPPING = REQUIRED_BEFORE_EXECUTION**

> **OBSERVATION_EPOCH_VERSIONING = REQUIRED**

> **EXECUTION_AUTHORITY_EVIDENCE = REQUIRED**

> **FIRST_OBSERVATION_INSTANCE = NOT_YET_SELECTED**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_YET_SPECIFIED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 42. Próximo passo revisado

> **Executar recheck adversarial contra TEA-G01–G18. Somente após PASS selecionar a primeira Temporal Observation Plan Instance.**


**Fim do Documento 51**
