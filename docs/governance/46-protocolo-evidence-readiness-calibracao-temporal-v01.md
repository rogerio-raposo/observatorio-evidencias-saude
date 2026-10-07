# 46 — Protocolo de Evidence Readiness para Calibração Temporal v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **CANDIDATE_FOR_ADVERSARIAL_GATE — NO_NORMATIVE_VALUES_AUTHORIZED**  
**Modo:** alto  
**Dependências:** Documentos 39–45; migration 032; CP107  
**Objeto:** protocolo pré-calibração para determinar se existe base real suficiente para abrir um Calibration Dossier temporal

## 1. Finalidade

Este protocolo responde, antes de qualquer número temporal:

> **há evidência real, provenance e authority suficientes para iniciar uma calibração normativa neste contexto específico?**

Ele não calibra cadence, SLA, grace, warning, post-breach threshold ou calendário.

Ele não substitui o Calibration Dossier. Ele decide apenas se a abertura de uma calibração real é metodologicamente defensável.

## 2. Estado de entrada

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = IMPLEMENTED_AND_TECHNICALLY_VALIDATED**

> **NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

A infraestrutura física existe; a suficiência da base real ainda não foi demonstrada.

## 3. Unidade de análise

A unidade de readiness é um **TemporalEvidenceReadinessContext** que identifica:

- calibration object;
- exact current target;
- governing UpdateRiskProfile, quando aplicável;
- UpdatePolicy, quando já existir;
- source scope, quando cadence;
- SLA clock e endpoint, quando SLA;
- time-basis class, sem duração;
- governing Monitor, quando aplicável;
- janela observacional;
- authority necessária;
- external constraints potencialmente aplicáveis.

Readiness não pode ser emitido genericamente para M1, M2, M3 ou para o OES inteiro.

## 4. Objetos cobertos

O protocolo cobre separadamente:

1. cadence;
2. SLA1;
3. SLA2;
4. SLA3;
5. SLA4;
6. SLA5;
7. SLA6;
8. institutional SLA calendar;
9. grace;
10. warning lead;
11. post-breach escalation threshold;
12. fixed deadline applicability.

## 5. Evidência real e evidência sintética

Evidência real admissível exige:

- locator auditável;
- origem identificável;
- timestamp/período;
- target/source/context compatível;
- provenance;
- ausência de rótulo fixture/test-only/synthetic;
- interpretação metodológica explícita.

Fixtures, smoke-test data, synthetic replay, test calendars, synthetic risk profiles, synthetic SLA instances e synthetic actors/approvals não são evidência normativa.

> **Evidência sintética pode validar software, mas não pode elevar readiness para calibração normativa real.**

Dados reais coletados originalmente para outra finalidade podem ser reutilizados somente quando o significado temporal permanece válido, os timestamps são causalmente compatíveis, missingness/censoring são avaliados e não existe seleção retrospectiva favorável.

## 6. Classes de origem

Cada required input recebe uma classe de origem:

- **R1 — repository-observable real now**;
- **R2 — prospective OES observation required**;
- **R3 — source-specific external characterization required**;
- **R4 — external normative artifact required**;
- **R5 — owner/institutional decision required**;
- **R6 — qualified scientific/methodological human judgment required**;
- **R7 — not applicable**.

A classe expressa de onde a informação legítima deve vir. Não é score nem peso.

## 7. Domínios de readiness

Readiness é avaliado por domínios independentes, sem score total.

### ER-A — Target validity

Verificar exact target, current status, maintainability, Monitor binding, rebaseline/replacement status e UpdateRiskProfile aplicável.

Falha: **NOT_READY_TARGET_INVALID**.

### ER-B — Need evidence

Verificar se A1–A5 e o contexto decisório possuem basis real suficiente para sustentar necessidade temporal.

Classes qualitativas não viram números automaticamente.

Ausência: **NEEDS_SCIENTIFIC_METHOD_AUTHORITY** ou **INSUFFICIENT_NEED_EVIDENCE**.

### ER-C — Source reality

Para cadence, verificar source identity/class, publication/indexing pattern, availability, API/feed behavior, event-channel liveness, timestamp precision, observed latency, failures, expected coverage e fallback path.

Ausência material: **NEEDS_SOURCE_CHARACTERIZATION**.

### ER-D — Operational history

Verificar disponibilidade e qualidade de MonitorCycles, Searches/source checks, signals, triage, MaterialityAssessment, UpdateDecision, WorkflowMilestones, SLA instances, pauses/incidents, throughput, backlog e workload.

Ausência: **NEEDS_PROSPECTIVE_OBSERVATION**.

### ER-E — Data quality

Avaliar completeness, missingness, censoring, timestamp precision, event-order consistency, source attribution, duplication, survivorship/selection bias e structural change.

Sem percentual universal de completude.

Resultado local: adequate_for_context, material_limitations ou unusable.

### ER-F — External constraints

Verificar artifact versionado, jurisdiction/applicability, target applicability, semantic start, semantic endpoint, precision, effective window e conflitos.

Sem artifact aplicável, não inventar external constraint.

### ER-G — Operational feasibility

Verificar observed workload, throughput, sustainable capacity, handoffs, process dependencies, tooling availability, coverage hours e incidents.

Capacidade insuficiente não redefine need.

Conflito: **READINESS_CAPACITY_CONFLICT**.

### ER-H — Institutional calendar

Quando business-calendar for potencialmente aplicável, exigir owner/institutional authority, timezone, operating hours, weekends, holidays/exceptions, 24×7 obligations, effective window e versioning trigger.

Ausência: **NEEDS_INSTITUTIONAL_CALENDAR**.

### ER-I — Authority readiness

Separar:

- scientific/methodological authority: human_reviewer ou human_expert qualificado;
- operational authority: owner/institutional authority.

IA/system não satisfaz autoridade final.

Ausência: **NEEDS_HUMAN_AUTHORITY**.

### ER-J — Replay/stress readiness

Verificar se é possível reconstruir casos sem inventar timestamps, preservar censura, incluir falhas/casos incompletos/períodos de maior carga e distinguir source latency de polling/process latency.

Se impossível: **REPLAY_NOT_CURRENTLY_FEASIBLE**.

A impossibilidade de replay não bloqueia automaticamente todo objeto; sua consequência depende da base alternativa real disponível.

## 8. Cadence

Para cada target/source scope, registrar readiness de:

- source scope real;
- observability;
- availability/indexing latency;
- event-channel behavior;
- timestamp precision;
- failure history;
- historical checks;
- signal yield;
- redundant checks;
- missed/late observations;
- coverage gaps;
- workload;
- capacity;
- satisfaction evidence;
- fallback path;
- authority.

Sem história suficiente: **NEEDS_PROSPECTIVE_OBSERVATION**.

Não escolher um intervalo provisório apenas para “começar a medir”.

Se uma agenda experimental for necessária, ela deve ser rotulada **measurement schedule — non-normative**, não cria compliance nem overdue normativo e não pode virar policy por inércia.

## 9. SLA1–SLA6

Cada clock é avaliado separadamente.

Registrar:

- causal start observável;
- endpoint observável;
- timestamp precision;
- comparable cases;
- missing/censored/open cases;
- wall-time distribution;
- accountable-time reconstructibility;
- pauses/incidents;
- throughput;
- backlog;
- capacity;
- response-class availability no start;
- filters aplicáveis;
- external constraints;
- authority.

Não há quantidade universal mínima de casos.

Registrar obrigatoriamente case count, observation window, missingness, censoring, representativeness, structural changes, heterogeneity e outliers.

## 10. Heterogeneidade

Testar diferenças materiais por:

- response_class;
- signal_class;
- trigger_class;
- decision_type;
- materiality_outcome;
- endpoint;
- target/policy;
- workflow context.

Se uma diferença relevante exigir estratificador não suportado:

> **UNSUPPORTED_RULE_STRATIFIER**

Não esconder estratificador em rationale ou JSON livre.

## 11. Grace

Readiness de grace exige evidência sobre jitter operacional, start-window variance, transient system delay, timestamp precision, source-side delay e process-side delay.

Grace não pode alongar silenciosamente cadence, esconder atraso crônico ou compensar capacity deficit.

Sem base: **GRACE_NOT_READY**.

## 12. Warning lead

Exigir corrective-action lead time, handoff latency, intervention feasibility before due e operational consequence.

Não usar percentual fixo de SLA.

Sem base: **WARNING_NOT_READY**.

## 13. Post-breach threshold

Exigir consequence after breach, meaningful intervention window, escalation ownership, process latency e relação com first breach.

O threshold nunca move first breach, nunca transforma atraso em materiality e não é justificado apenas por breaches frequentes.

Sem base: **POST_BREACH_THRESHOLD_NOT_READY**.

## 14. Fixed deadline

Pode ter readiness sem grande história operacional quando existe obrigação externa suficientemente explícita.

Exigir artifact/version, applicability, semantic start/end, precision, date/timestamp semantics, timezone/boundary rule, effective window e conflict resolution.

Date-only não pode virar timestamp inventado.

## 15. Institutional calendar

Calendar readiness não deriva de horário de trabalho informal.

Exige regra institucional ou owner decision explícita e avaliação se a obrigação deveria ser 24×7.

Risco de usar business-calendar para acomodar capacidade insuficiente:

> **CALENDAR_CAPACITY_LAUNDERING_RISK**

## 16. Estados de readiness

Cada contexto recebe um estado primário:

- READY_FOR_CALIBRATION;
- PROVISIONAL_EVIDENCE_ONLY;
- NEEDS_PROSPECTIVE_OBSERVATION;
- NEEDS_SOURCE_CHARACTERIZATION;
- NEEDS_INSTITUTIONAL_CALENDAR;
- NEEDS_EXTERNAL_APPLICABILITY_REVIEW;
- NEEDS_HUMAN_AUTHORITY;
- READINESS_CAPACITY_CONFLICT;
- INSUFFICIENT_EVIDENCE;
- NOT_APPLICABLE;
- NOT_READY_TARGET_INVALID;
- UNSUPPORTED_RULE_STRATIFIER.

Pode haver blockers secundários.

Não existe ordenação numérica universal entre estados.

## 17. Regra de READY_FOR_CALIBRATION

READY_FOR_CALIBRATION somente pode ser usado quando:

1. target é válido;
2. need basis real é suficiente para o objeto;
3. source/operational basis necessária é real;
4. data limitations são conhecidas;
5. external constraints foram avaliadas;
6. feasibility foi avaliada;
7. authority path necessária está disponível;
8. replay/stress é possível ou há justificativa explícita de não aplicabilidade;
9. não há blocker dominante;
10. nenhuma fixture/test-only basis preenche requisito real.

READY_FOR_CALIBRATION autoriza apenas **abrir** um Calibration Dossier real.

Não autoriza selected candidate, normative activation, UpdatePolicy, SLARule, CadenceContract, calendar ou número.

## 18. PROVISIONAL_EVIDENCE_ONLY

Usar quando existe basis real relevante, mas incerteza material impede calibração normativa plena.

Esse estado não cria rule/policy nem dossier approved.

Pode justificar observation plan e deve definir o que falta para reavaliação.

## 19. INSUFFICIENT_EVIDENCE

Quando não há base suficiente:

> **nenhum número é proposto.**

A saída deve listar explicitamente as evidências faltantes.

## 20. Temporal Observation Plan

Quando necessário, readiness pode recomendar um plano prospectivo contendo:

- objeto observado;
- target;
- source/clock;
- eventos/timestamps;
- data-quality checks;
- observation window;
- responsável operacional;
- failure/missingness logging;
- change log;
- termination conditions.

Não contém normative SLA, normative cadence ou compliance threshold.

Uma periodicidade de medição experimental, se indispensável, é **measurement schedule — non-normative**.

## 21. Fonte externa atual

Quando readiness depender de características atuais de fonte externa:

- confirmar a fonte vigente;
- registrar data de verificação;
- preservar artifact/record quando possível;
- separar informação oficial de inferência;
- não presumir uptime, indexing latency ou API behavior sem observação/documentação.

Mudança material exige reassessment.

## 22. Evidence cut-off e horizon

Todo readiness deve possuir:

- assessed_at;
- evidence_cutoff_at;
- observation window;
- reassessment triggers.

Evidência posterior não pode ser retroativamente tratada como disponível na decisão original.

Triggers incluem source/API change, target rebaseline, Monitor version, workflow/capacity/calendar change, external rule change, major missingness discovery e structural break.

## 23. Minimum N

Não existe minimum_n universal.

Suficiência depende de diversidade, censoring, stability, endpoint precision, heterogeneity, representativeness, event rarity e structural breaks.

Amostra numericamente grande pode continuar insuficiente.

Uma obrigação externa explícita pode sustentar fixed deadline sem história operacional extensa.

## 24. Ausência de evento

Zero breaches, zero signals ou zero failures não prova adequação.

Distinguir ausência real de baixa observabilidade, período curto, censoring, canal inativo e missingness.

## 25. Capacity laundering

Quando need exige resposta mais rápida que a capacidade sustentável observada:

> **READINESS_CAPACITY_CONFLICT**

Não escolher valor mais lento sem reavaliar need, resources e governance.

## 26. Governance judgment

Governance judgment pode ser necessário quando a evidência não determina um único valor.

Readiness deve separar:

- evidence uncertainty;
- value judgment;
- resource decision.

Governance não pode fingir que dado ausente existe.

## 27. Artefato de saída

O registro de readiness deve conter:

- readiness context;
- assessed target;
- calibration object;
- evidence_cutoff_at;
- observation window;
- required inputs;
- classe R1–R7 por input;
- locators disponíveis;
- missing inputs;
- data-quality limitations;
- authority gaps;
- external applicability status;
- capacity status;
- replay feasibility;
- primary readiness state;
- secondary blockers;
- reassessment trigger;
- assessor;
- verification status;
- rationale.

Neste estágio, é artefato metodológico/governamental, não nova tabela normativa.

## 28. Relação com migration 032

O protocolo não requer migration 033.

A migration 032 já fornece infraestrutura para a calibração futura.

Readiness pode referenciar objetos físicos existentes, mas não deve criar Calibration Dossier real antes de READY_FOR_CALIBRATION.

## 29. Transição readiness → Calibration Dossier

A abertura de Calibration Dossier real exige:

1. readiness = READY_FOR_CALIBRATION;
2. target ainda current;
3. evidence cut-off ainda aplicável;
4. nenhum reassessment trigger invalidante;
5. authority path identificada;
6. nenhum blocker material aberto.

Abrir dossier inicia calibração; não significa aprovação, candidate selected ou normative activation.

## 30. Quando retornar à arquitetura

Parar e retornar à arquitetura se readiness identificar:

- stratifier necessário sem suporte físico;
- source-scope não representável;
- novo time basis;
- novo endpoint;
- nova authority class;
- nova calendar semantics;
- incapacidade de preservar provenance;
- novo tipo de external deadline.

Não contornar limites com JSON/rationale.

## 31. Casos reais existentes

Casos reais científicos podem contribuir somente se o dado temporal é real, comparável e explicitamente vinculado.

Produto real não implica operação real de manutenção.

Não fabricar MonitorCycle, source latency, SLA history, capacity ou authority que não existiram.

## 32. Proibições

Este protocolo não autoriza:

- números normativos;
- real CadenceContract;
- real SLARule;
- real SLACalendarVersion;
- real calibrated UpdatePolicy;
- scheduler;
- notification delivery;
- auto-escalation;
- automatic UpdateSignal;
- automatic Currentness change;
- assurance promotion;
- publication automation;
- M3 unblock;
- fabricated authority;
- fabricated replay;
- fixture-to-policy promotion.

## 33. Gate adversarial obrigatório

Antes de usar o protocolo para declarar qualquer contexto READY_FOR_CALIBRATION, atacar:

- synthetic leakage;
- circularidade readiness ↔ calibration;
- hidden minimum-N;
- sampling/survivorship bias;
- future leakage;
- target/source drift;
- capacity/calendar laundering;
- fake authority;
- external applicability error;
- observation plan becoming policy by inertia;
- absence-of-event fallacy;
- heterogeneity hidden in aggregate;
- real-case overgeneralization;
- readiness inflation;
- undocumented governance judgment.

## 34. Estado

> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = CANDIDATE_FOR_ADVERSARIAL_GATE**

> **READINESS_ASSESSMENT_ON_REAL_CONTEXT = NOT_YET_AUTHORIZED**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **SCHEDULER = DEFERRED**

> **NOTIFICATIONS = DEFERRED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 35. Próximo passo

> **Executar gate adversarial do Protocolo de Evidence Readiness v0.1.**

Somente PASS ou PASS_WITH_ARCHITECTURAL_DECISIONS poderá autorizar a primeira avaliação de readiness em contexto real.

Mesmo após PASS, nenhuma calibração numérica fica automaticamente autorizada.
