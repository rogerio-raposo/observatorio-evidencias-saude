# 39 — Metodologia de Calibração Temporal da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **CANDIDATE_FOR_ADVERSARIAL_GATE — NO_NORMATIVE_VALUES_AUTHORIZED**  
**Dependências:** Documentos 16–21, 25–31, 33–38; migrations 027, 029–031  
**Objeto:** metodologia para calibrar cadence, thresholds temporais, calendários e durações SLA antes de qualquer valor normativo

---

## 1. Finalidade

Definir **como** o OES deverá chegar a valores temporais normativos sem:

- criar defaults universais por M0–M3;
- converter risco em score aditivo;
- confundir capacidade com risco científico;
- copiar prazos externos sem análise de aplicabilidade;
- usar desempenho histórico como justificativa automática de SLA;
- fabricar precisão estatística;
- retroagir obrigações sobre casos históricos;
- inserir números diretamente em JSON ou timestamps manuais sem provenance;
- desbloquear M3, scheduler, notifications ou auto-escalation.

Este documento:

> **não define nenhum intervalo, duração, grace period ou threshold numérico.**

---

# PARTE A — PRINCÍPIOS

## 2. Quatro relógios continuam separados

A calibração preserva a separação arquitetural entre:

1. **cadence de vigilância** — quando procurar/observar;
2. **reassessment de policy/profile** — quando rever a própria regra;
3. **SLA operacional** — quanto tempo existe entre eventos causais definidos;
4. **currentness científico** — estado científico derivado de assessment/decision, nunca do relógio isolado.

Consequência:

> atraso operacional pode exigir ação sem produzir automaticamente `outdated`.

---

## 3. Unidade de calibração não é M0–M3 isoladamente

Nenhum número será definido apenas porque uma policy é M1, M2 ou M3.

A unidade conceitual de calibração é um:

> **TemporalCalibrationContext**

composto, conforme aplicável, por:

- target ProductVersion/InvestigationVersion;
- UpdatePolicy;
- UpdateRiskProfile authoritative aplicável;
- maintenance level;
- cadence mode;
- source class/canal;
- clock SLA;
- response_class;
- signal_class;
- trigger_class;
- decision_type;
- materiality_outcome;
- endpoint;
- time basis;
- calendar;
- período de vigência.

M0–M3 restringe modos possíveis, mas não fornece números.

---

## 4. Modelo de calibração por envelopes, não por score

O método não soma pontos.

Para cada contexto são avaliados quatro envelopes independentes.

### 4.1 Need envelope

Representa a necessidade científica/decisória de detecção ou resposta.

Inputs:

- A1 criticality;
- A2 evidence volatility;
- A3 conclusion sensitivity;
- A4 safety/integrity;
- A5 dependency reach;
- materiality/decision context;
- priority response_class quando já existente.

O need envelope pode impor:

- maior frequência;
- menor latência tolerável;
- event-driven surveillance;
- necessidade de escalonamento.

Não é calculado por soma ponderada.

### 4.2 Source-reality envelope

Representa o que a fonte permite observar.

Inputs:

- B1 source observability;
- B2 detection latency;
- disponibilidade real da fonte;
- frequência de indexação/publicação;
- existência de webhook/feed/alert/canal regulatório;
- precision dos timestamps;
- falhas/indisponibilidade observadas.

Regra:

> cadence muito mais rápida que a resolução real da fonte não cria maior currentness.

### 4.3 Feasibility envelope

Representa capacidade operacional sustentável.

Inputs:

- B3 surveillance load;
- B4 incorporation cost;
- B5 sustainable capacity;
- carga observada;
- disponibilidade real de equipe/sistemas;
- duração operacional histórica.

Regra de não compensação:

> feasibility nunca reduz A1–A5 nem redefine materiality.

Se necessidade e capacidade não se intersectam:

> **CALIBRATION_CAPACITY_CONFLICT**

e não “SLA mais longo porque a equipe não consegue”.

### 4.4 External-constraint envelope

Representa obrigação externa real:

- prazo legal/regulatório;
- deadline de financiador/contrato;
- data de vigência formal;
- regra institucional aprovada;
- limite explícito proveniente de artifact/entity externa auditável.

Quando aplicável:

> fixed deadline pode dominar a regra, desde que a fonte e a precisão sejam preservadas.

---

# PARTE B — BASE DE EVIDÊNCIA

## 5. Tipos de basis permitidos

Uma calibração poderá combinar:

### A. OES empirical basis

Dados observados no próprio OES:

- Monitoring Cycles;
- source checks/searches;
- signal timestamps;
- triage;
- MaterialityAssessment;
- UpdateDecision;
- WorkflowMilestones;
- SLA pauses/incidents futuros;
- workload e throughput.

### B. Source-characteristic basis

Características documentadas de fontes/sistemas:

- indexation latency;
- publication schedule;
- API/feed behavior;
- source uptime;
- timestamp precision.

### C. External normative basis

Regras externas vinculantes ou formalmente adotadas.

### D. Methodological evidence basis

Literatura/métodos usados para justificar estratégia de surveillance/atualização.

### E. Governance basis

Decisão explícita quando evidência empírica não determina um único valor.

Governance judgment:

> deve ser identificado como judgment, não disfarçado de dado.

---

## 6. Suficiência da base

A metodologia usa três estados, sem score:

- `sufficient_for_calibration`;
- `provisional_only`;
- `insufficient`.

### sufficient_for_calibration

Há bases suficientes para justificar um valor e sua aplicabilidade.

### provisional_only

Existe fundamento para uma regra temporária/revisável, mas a incerteza operacional é material.

Isso não autoriza inserção física automática; exige governance específica e regra de reassessment.

### insufficient

Não existe base suficiente.

Resultado:

> nenhum número normativo é fabricado.

---

## 7. Dados históricos não viram compliance retroativo

Backtesting usa história apenas como:

> **counterfactual replay**

Não se pode declarar que caso passado “cumpriu” ou “violou” SLA que não existia naquele período.

Métricas históricas são analíticas, não fatos contratuais retroativos.

---

# PARTE C — CALIBRAÇÃO DE CADENCE

## 8. Cadence é calibrada por obrigação observável

A calibração deve identificar primeiro:

- qual fonte/classe é observada;
- por qual mecanismo;
- qual evento satisfaz a obrigação;
- qual timestamp é confiável;
- qual cobertura é esperada.

Não começar por “quantos dias”.

---

## 9. Sequência metodológica para cadence

### Passo C1 — classificar o modo

Determinar:

- none;
- event_driven;
- periodic;
- hybrid;
- continuous apenas como análise futura M3.

### Passo C2 — decompor fontes

Para cada source class:

- observabilidade;
- availability latency;
- ingestion latency;
- falhas;
- event channel;
- periodic polling necessário;
- redundância.

### Passo C3 — escolher âncora

Preferência:

> `fixed_anchor` quando a intenção é preservar frequência estável.

`rolling_anchor` somente quando a obrigação for semanticamente “X após última execução”.

`event_anchor` somente com evento causal explícito.

Atraso nunca redefine silenciosamente fixed anchor.

### Passo C4 — gerar candidatos

Gerar um conjunto de schedules candidatos compatíveis com:

- need envelope;
- source reality;
- policy mode;
- capacidade.

Nenhum candidato vira policy automaticamente.

### Passo C5 — replay

Reexecutar contrafactualmente os candidatos sobre dados históricos disponíveis.

Avaliar, sem threshold universal pré-fixado:

- detection lag;
- checks redundantes;
- checks sem nova informação;
- missed/late observations;
- workload;
- overdue occurrence;
- coverage gaps;
- signal yield;
- diferença entre source latency e polling latency.

### Passo C6 — seleção

Selecionar:

> o schedule de menor carga que ainda satisfaça a necessidade documentada e a realidade da fonte.

Se nenhum schedule for simultaneamente adequado e sustentável:

> **CALIBRATION_CAPACITY_CONFLICT**.

### Passo C7 — grace

Calibrar grace separadamente da cadence.

Grace representa:

- jitter operacional tolerado;
- janela realista de início;

e não:

- frequência adicional;
- cobertura científica;
- licença para esconder atraso sistemático.

Grace não pode esvaziar a própria cadence.

---

## 10. Multiple-source cadence

Cadence agregada não pode esconder source-specific debt.

Para cada fonte deve ser possível determinar:

- obligation due;
- satisfaction evidence;
- late execution;
- unavailable channel;
- fallback.

Se fontes possuem latências materialmente diferentes:

> calibrar source-specific obligations ou demonstrar que o cycle agregado preserva todas as exigências.

---

## 11. Event-driven surveillance

Event-driven deve calibrar:

- evento elegível;
- canal;
- liveness/observability;
- expected detection path;
- fallback quando o canal falha;
- eventual periodic verification do canal, se necessária.

A4 high continua exigindo event-driven surveillance no profile authoritative.

Event-driven:

> não significa zero governança temporal.

---

## 12. Cadence de reassessment

Reassessment de policy/profile é relógio próprio.

Inputs:

- mudança das dimensões A/B;
- source observability;
- signal frequency;
- capacidade;
- maintenance-level change;
- dependency changes;
- desempenho observado da cadence.

Não reutilizar automaticamente a periodicidade de busca.

---

# PARTE D — THRESHOLDS TEMPORAIS

## 13. Classes calibráveis

O bloco poderá calibrar, separadamente:

1. due/recurrence;
2. grace;
3. overdue escalation;
4. stale policy/profile;
5. warning lead time.

`unresolved signal` não cria relógio duplicado:

> deve ser representado pelos SLA-1–SLA-3 quando aplicável.

Materiality/currentness:

> não recebem threshold temporal automático neste bloco.

---

## 14. Overdue não é breach científico

Overdue cadence:

- é estado operacional;
- preserva atraso mesmo após execução tardia;
- pode gerar escalation candidate conforme rule;
- não muda CurrencyState.

SLA breach:

- ocorre quando effective due é ultrapassado;
- first breach é history-preserving;
- não equivale a material change.

---

# PARTE E — CALIBRAÇÃO DE SLA

## 15. Cada clock é calibrado separadamente

Nenhum “SLA global”.

Clocks:

- SLA1 detection → triage;
- SLA2 triage → materiality;
- SLA3 materiality → decision;
- SLA4 decision → workflow start;
- SLA5 workflow start → scientific completion;
- SLA6 scientific completion → review/publication endpoint.

---

## 16. Sequência metodológica para SLA

### Passo S1 — confirmar applicability

Antes de duração:

- clock aplicável?;
- start causal existe?;
- endpoint existe?;
- timestamp precision é suficiente?;
- WorkflowRound existe para SLA4–6?;
- rule pode ser selecionada deterministicamente?

Se não:

> não calibrar duração para aquele contexto.

### Passo S2 — escolher time basis

#### elapsed_time

Usar quando obrigação corre continuamente.

#### business_calendar

Usar somente quando a obrigação realmente é contratada em horas/dias úteis de um calendário governado.

Não usar calendário comercial para esconder delay de obrigação contínua.

#### fixed_deadline

Usar quando existe deadline externo/governança com fonte explícita.

Não converter date-only em timestamp inventado.

### Passo S3 — definir estrato

Usar somente filtros que tenham significado causal e suporte físico:

- response_class;
- signal_class;
- trigger_class;
- decision_type;
- materiality_outcome;
- endpoint.

Target-specific variation já pode ser absorvida porque SLARule é policy-bound.

Se evidência demonstrar necessidade de estratificador não suportado fisicamente:

> marcar `UNSUPPORTED_RULE_STRATIFIER`;

não codificar o estratificador em JSON/rationale para contornar schema.

### Passo S4 — construir distribuição operacional

Para casos históricos comparáveis, medir:

- wall time;
- accountable time quando reconstruível;
- pause candidates;
- endpoint precision;
- censura/casos incompletos;
- capacidade/contexto.

Não transformar automaticamente percentil histórico em SLA.

### Passo S5 — gerar candidatos

Candidatos devem satisfazer:

- need envelope;
- external constraints;
- endpoint precision;
- feasibility assessment.

### Passo S6 — replay e stress

Avaliar candidatos contra casos históricos e cenários plausíveis:

- breach frequency contrafactual;
- elapsed/accountable duration;
- backlog pressure;
- capacity conflict;
- response-class separation;
- efeito de pauses;
- fixed-deadline collisions;
- endpoint availability.

### Passo S7 — decisão

A duração escolhida deve ser:

- suficientemente curta para a necessidade documentada;
- prospectivamente executável sob capacidade adequada;
- não ajustada silenciosamente para acomodar capacidade insuficiente.

Se necessidade exigir resposta mais rápida do que a capacidade sustentável:

> **CALIBRATION_CAPACITY_CONFLICT** + governance/resource escalation.

---

## 17. Response class não contém duração

`standard | expedited | urgent | immediate`:

- permanece classe qualitativa;
- pode selecionar SLARule;
- não possui duração universal.

É legítimo que duas policies tenham durações distintas para a mesma response_class.

---

## 18. Warning

Warning deve ser calibrado a partir de:

- tempo necessário para ação corretiva antes do due;
- operational handoff;
- risco de breach.

Não usar um percentual universal do SLA.

Warning:

> não redefine due.

---

## 19. Breach e overdue escalation

Breach ocorre no effective due.

Um threshold adicional de escalation pós-breach pode existir quando justificado.

Ele:

- não move o first breach;
- não transforma atraso em materiality;
- não pode ser recalibrado retroativamente em instância aberta.

---

# PARTE F — CALENDÁRIO

## 20. SLACalendarVersion real

Calendário operacional real deve possuir:

- timezone;
- weekly schedule;
- exceptions/holidays;
- effective_from;
- versioning;
- owner/governance provenance.

Mudança de calendário:

> nova version.

SLA Instance congela a versão usada.

---

## 21. Regra anti-capacity laundering

Calendário não pode ser usado para “descontar” períodos em que o OES deveria estar operacionalmente disponível.

Exemplo conceitual:

- obrigação 24/7 de safety não deve ser transformada em business-calendar apenas porque equipe trabalha em horário comercial.

Isso é:

> **CALENDAR_CAPACITY_LAUNDERING — prohibited**.

---

# PARTE G — GOVERNANÇA DA CALIBRAÇÃO

## 22. Calibration Dossier

Todo valor normativo futuro deve nascer de um Calibration Dossier auditável.

Conteúdo mínimo:

- calibration object;
- target/policy/clock/source scope;
- governing UpdateRiskProfile UUID;
- data window;
- basis types + locators/references;
- source-latency observations;
- operational observations;
- external constraints;
- candidate rules consideradas;
- replay/stress results;
- rejected candidates + rationale;
- selected candidate;
- feasibility conclusion;
- capacity conflict, se houver;
- scientific/methodological rationale;
- operational rationale;
- effective_at;
- reassessment triggers;
- responsible actors/authority.

O dossier não é AssuranceRecord.

---

## 23. Authority

Calibração mistura dois domínios.

### Scientific/methodological need

Deve apoiar-se em:

- authoritative UpdateRiskProfile;
- human-qualified scientific/methodological judgment quando necessário.

### Operational feasibility/calendar

Deve apoiar-se em:

- owner/institutional authority;
- B5/capacity basis;
- real calendar/source facts.

Regra:

> capacidade operacional não pode unilateralmente relaxar need envelope.

A ativação normativa exige que ambos os domínios estejam documentados, mesmo quando a decisão final é registrada por um único objeto de policy/rule.

---

## 24. Estados metodológicos de decisão

- `approved_for_normative_activation`;
- `provisional_requires_reassessment`;
- `capacity_conflict`;
- `insufficient_evidence`;
- `rejected`.

Nenhum estado é inferido automaticamente.

`provisional_requires_reassessment`:

> ainda exige autorização explícita antes de qualquer regra ativa.

---

# PARTE H — BACKTEST E PROSPECÇÃO

## 25. Replay histórico

Replay deverá preservar:

- timestamps originais;
- source detection original;
- pauses apenas quando realmente reconstruíveis;
- casos incompletos;
- missingness.

Não imputar tempos convenientes para melhorar performance.

---

## 26. Sensitivity analysis

Antes de selecionar valor:

- comparar múltiplos candidatos;
- identificar regiões em que pequenas mudanças de parâmetro produzem grande mudança de workload/breach;
- identificar candidatos dominados;
- documentar trade-offs.

Não existe função objetivo única de score.

---

## 27. Prospective review

Após ativação futura, recalibrar quando houver:

- risk profile reassessment;
- mudança de source latency/observability;
- signal frequency change;
- capacity change;
- repeated breach/overdue;
- alteração de workflow;
- calendar change;
- external rule change;
- rebaseline/new target;
- explicit governance request.

Repeated breach:

> não justifica automaticamente alongar SLA.

Primeiro avaliar:

- capacidade;
- processo;
- regra inadequada;
- mudança do need envelope.

---

# PARTE I — LIMITES FÍSICOS ENCONTRADOS

## 28. CadencePolicy payload ainda não é contrato numérico fechado

`maintenance.update_policy.cadence_policy_payload`:

- existe;
- é JSON object;
- não possui ainda schema físico fechado para interval/grace/anchor/source-specific obligations.

Logo:

> valores normativos de cadence não devem ser ativados até existir validator/contrato físico determinístico.

---

## 29. SLA Rule não possui resolver canônico implementado

O schema possui:

- filters;
- selection_precedence;
- uniqueness.

Mas não existe ainda função canônica que:

1. receba contexto;
2. avalie filtros;
3. selecione deterministicamente a primeira rule válida;
4. detecte fallback ausente/ambíguo.

Logo:

> SLARules reais não devem ser ativadas até esse resolver existir e ser testado.

---

## 30. nominal_due_at ainda pode ser informado manualmente

`maintenance.sla_instance` exige `nominal_due_at`, mas o guard atual:

- verifica `nominal_due_at >= start_at`;
- não recalcula o due a partir de target_duration/calendar/fixed deadline.

Logo:

> hoje seria possível criar instância com due diferente da rule.

Antes de SLA normativo:

- criar deterministic due calculator;
- validar nominal_due_at contra rule;
- congelar serializer canônico da rule.

---

## 31. Business calendar arithmetic ainda precisa ser fechado

O schema valida shape do calendário.

Mas a operação de:

> start + target_duration segundo calendar version

precisa ser determinística e testada.

Não admitir cálculo externo opaco como fonte autoritativa.

---

## 32. Warning/breach/escalation payloads ainda são JSON aberto

Antes de números nesses payloads:

- fechar shape;
- validar unidades;
- validar relação warning < due quando aplicável;
- preservar first breach;
- impedir threshold que altere currentness.

---

## 33. Estratificadores não suportados

O schema atual não possui, por exemplo:

- `round_type_filter`.

Metodologia não autoriza adicionar automaticamente esse filtro.

Regra:

> somente se a análise de calibração demonstrar heterogeneidade material não representável pelos filtros existentes, abrir decisão física específica.

Não esconder novo selector em JSON.

---

## 34. Calibration Dossier ainda não possui linkage físico canônico

Rationale textual isolada é insuficiente para provenance de uma calibração normativa complexa.

Antes de valores reais deve ser definido:

- onde o dossier vive;
- como UpdatePolicy/SLARule aponta para ele;
- como basis externas/OES são vinculadas;
- como supersession é preservada.

---

# PARTE J — M3 / AUTOMAÇÃO

## 35. M3

A metodologia pode analisar cenários futuros compatíveis com continuous/hybrid.

Mas:

> **nenhum valor calibrado autoriza M3 enquanto o blocker existir.**

Permanece:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

---

## 36. Scheduler / notifications / auto-escalation

Este documento não autoriza:

- scheduler;
- notification delivery;
- auto-escalation activation.

A calibração precisa existir antes.

Mesmo após calibração:

> automação exigirá gate próprio.

---

# PARTE K — RESULTADO

## 37. Estado metodológico

> **TEMPORAL_CALIBRATION_METHODOLOGY = CANDIDATE_FOR_ADVERSARIAL_GATE**

> **NUMERIC_CADENCE = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_AUTHORIZED**

> **REAL_SLA_CALENDARS = NOT_AUTHORIZED**

> **NORMATIVE_SLA_RULES = NOT_AUTHORIZED**

> **SCHEDULER = NOT_AUTHORIZED**

> **NOTIFICATIONS = NOT_AUTHORIZED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 38. Próximo passo exato

> **Executar gate adversarial da metodologia, atacando falsa precisão, capacity laundering, ausência de provenance, resolver SLA, due calculation, calendar arithmetic, cadence JSON aberto, retroatividade e M3. Nenhum número deve ser definido antes do PASS do gate.**
