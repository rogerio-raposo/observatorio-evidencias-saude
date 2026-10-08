# 54 — Seleção e Especificação da Primeira Temporal Observation Plan Instance: N2 / dCBT-I

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **CANDIDATE_FOR_TARGET_SPECIFIC_GATE — NO_EXECUTION_AUTHORIZED**  
**Modo:** alto  
**Dependências:** Documentos 46–53; CP112  
**Objeto:** selecionar o primeiro exact target e especificar a primeira instância do protocolo de aquisição temporal não normativa

## 1. Decisão de seleção

> **FIRST_TEMPORAL_OBSERVATION_PLAN_TARGET = N2_RC01_DCBTI_PRODUCTVERSION_1**

> **FIRST_TEMPORAL_OBSERVATION_PLAN_INSTANCE = TOPI_N2_DCBTI_V01**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

O target selecionado é:

- Product: `OES-P-2026-000401`;
- ProductVersion UUID: `81000000-0000-0000-0000-000000000701`;
- ProductVersion: 1;
- product_type: `evidence_sheet`;
- status: `published`;
- assurance: A2;
- publication_date: `2026-10-04`;
- evidence_cutoff_date: `2026-10-04`;
- Investigation: `OES-I-2026-000401`;
- InvestigationVersion UUID: `81000000-0000-0000-0000-000000000002`;
- depth: N2;
- maintenance_level histórico: M1.

## 2. Comparação N1-01 versus N2/dCBT-I

A seleção foi feita sem score agregado.

### 2.1 Information gain

**N1-01**
- duas searches reais;
- um ecossistema de fonte principal: PubMed/MEDLINE;
- busca seletiva/non-exhaustive;
- bom caso para plano simples.

**N2/dCBT-I**
- quatro searches reais;
- três ecossistemas: PubMed/MEDLINE, BVS/LILACS e ClinicalTrials.gov;
- tipos de evidência distintos: reviews, RCTs, evidência regional e registry;
- maior capacidade de testar source-specific semantics, failure attribution, source-universe discipline e storage mapping.

Conclusão:

> **vantagem N2**

### 2.2 Source complexity

N1 é mais simples.

N2 possui complexidade moderadamente maior por combinar bibliographic databases e trial registry.

Para um primeiro piloto executável essa complexidade exigirá maior cuidado; para a fase atual de **especificação**, porém, ela funciona como stress-test útil da arquitetura transversal.

Conclusão:

> **vantagem operacional N1; vantagem metodológica N2**

### 2.3 Cost

N1 tende a ter menor custo operacional.

N2 tende a exigir mais source characterization e mais event classes.

Como nenhuma execução é autorizada neste bloco, o diferencial de custo não supera o ganho informacional de testar a arquitetura em um caso multi-source.

Conclusão:

> **vantagem N1, não dominante**

### 2.4 Semantic storage feasibility

Nos dois casos:

- Search científica real pode usar `investigation.search` quando semanticamente correta;
- liveness/latency/capacity probes não podem usar Search;
- pre-calibration measurement não pode usar CadenceObservation;
- artifacts/documentação são necessários para fatos sem objeto físico canônico.

N2 exerce melhor o semantic storage mapping porque inclui bibliographic source e registry.

Conclusão:

> **vantagem de teste N2**

### 2.5 Authority feasibility

Nenhum dos dois targets possui authority específica de execution/readiness.

Ambos exigem novo evidence record humano.

Conclusão:

> **empate; blocker comum**

### 2.6 Data-governance feasibility

Os dados pretendidos são predominantemente:

- bibliographic metadata;
- registry metadata;
- timestamps operacionais;
- query/source metadata;
- logs de execução;
- effort/capacity metadata.

Não há necessidade metodológica de coletar dados pessoais de pacientes.

Termos/licenças/acesso de cada fonte devem ser confirmados antes da execução.

Conclusão:

> **ambos viáveis em princípio; N2 exige mais source-specific review**

### 2.7 Risk of overfitting

N1 isolaria a primeira instância em um único source ecosystem.

N2 força a arquitetura a lidar desde o início com:

- source classes diferentes;
- coverage claims diferentes;
- latency semantics diferentes;
- source failure versus OES failure;
- candidate source universe não idêntico ao corpus histórico.

Conclusão:

> **vantagem N2**

## 3. Racional final

N2 é selecionado porque maximiza ganho metodológico sem criar execução adicional neste estágio.

A seleção:

- não declara N2 mais “importante” clinicamente;
- não promove N2 a M2;
- não transforma fontes históricas em surveillance universe;
- não autoriza números de cadence;
- não autoriza source checks.

## 4. Identidade da instância

Plan code:

> **TOPI-N2-DCBTI-01**

Plan version:

> **v0.1**

Architecture basis:

> Documento 51 hardenizado + Documento 53 PASS

Readiness basis:

> Documento 50 — `INSUFFICIENT_EVIDENCE`

Calibration object:

> **cadence readiness**

Readiness scope:

> **policy_aggregate**

Plan status inicial:

> **awaiting_target_specific_gate**

Execution status:

> **not_authorized**

## 5. Purpose

A instância existe para adquirir evidência real capaz de informar os blockers do Documento 50:

1. insufficient need evidence;
2. source characterization;
3. prospective observation;
4. human authority;
5. feasibility/capacity;
6. replay feasibility.

Ela não existe para:

- manter o produto “atualizado” por promessa operacional;
- operar surveillance contínua;
- cumprir cadence;
- satisfazer SLA;
- gerar overdue;
- alterar currentness;
- disparar alerts automaticamente.

## 6. Candidate source universe

Production sources do caso original são evidência de relevância histórica, não de cobertura futura.

### 6.1 Initial candidate source classes

Para este target, considerar inicialmente:

1. **bibliographic review/RCT discovery**
   - PubMed/MEDLINE;
2. **regional bibliographic discovery**
   - BVS/LILACS;
3. **trial/registry status discovery**
   - ClinicalTrials.gov.

### 6.2 Unknown/unassessed source space

A instância registra explicitamente:

> **ADDITIONAL_RELEVANT_SOURCES = UNASSESSED**

Nenhuma alegação de completude é feita.

Fontes adicionais não podem ser adicionadas silenciosamente ao epoch.

### 6.3 Inclusion rationale

As três fontes entram como candidates porque foram realmente usadas no caso N2 para finalidades diferentes e permitem avaliar classes operacionais distintas.

Isso não significa que devam compor uma futura cadence normativa.

## 7. Estrutura em fases

A instância é deliberadamente staged.

### Phase A — source characterization + authority/data-governance preparation

Finalidade:

- caracterizar as três fontes;
- mapear endpoints/timestamps;
- verificar interfaces/canais;
- fechar semantic storage mapping;
- preparar UpdateRiskProfile evidence inputs;
- registrar authority necessária;
- verificar termos/licenças/acesso;
- definir quais latencies são realmente observáveis;
- produzir proposal de measurement design para Phase B.

Phase A não contém cadence nem repeated surveillance.

### Phase B — prospective non-normative measurement

Estado:

> **BLOCKED_PENDING_PHASE_A_RESULT_AND_PLAN_AMENDMENT**

A Phase B somente pode ser especificada numericamente após Phase A.

Razão:

> escolher uma periodicidade experimental antes de conhecer source behavior introduziria anchoring e falsa precisão.

A futura amendment deverá:

- declarar measurement schedule = non-normative;
- definir observation epoch;
- justificar resolução temporal;
- definir review boundary;
- definir planned opportunities;
- passar por target-specific recheck;
- obter authority explícita antes da execução.

## 8. Observation Epoch model

### Epoch A0 — preparation/characterization epoch

Status atual:

> **specified_not_authorized**

Exact target:

`81000000-0000-0000-0000-000000000701`

Source candidates:

- PubMed/MEDLINE;
- BVS/LILACS;
- ClinicalTrials.gov.

Epoch A0 não executa surveillance.

Ele somente poderá produzir fatos de characterization realmente observados/documentados após autorização específica.

### Epoch B1 — prospective measurement epoch

Status:

> **not_yet_specified**

B1 não existe operacionalmente até amendment posterior.

## 9. Source characterization tasks

Para cada candidate source, Phase A deverá registrar, quando verificável:

- canonical source name;
- source class;
- access/interface type;
- official locator;
- retrieval date/time;
- version/effective date quando disponível;
- bibliographic/registry scope relevante;
- timestamp fields;
- timestamp semantics;
- timestamp precision;
- publication/indexing/update semantics;
- API/feed/web behavior;
- query reproducibility;
- pagination/result-count behavior;
- liveness/availability facts;
- observed access failures, se ocorrerem;
- rate/access constraints quando documentados;
- fallback possibilities;
- data-governance constraints.

Separar:

- documented source fact;
- observed source fact;
- inference.

## 10. Latency model

Nenhuma latency é presumida.

Possíveis classes:

- publication latency;
- indexing latency;
- source availability latency;
- OES detection latency;
- OES processing latency.

Cada eventual observation exige:

- start semantic;
- end semantic;
- timestamp sources;
- timezone;
- precision;
- observed/inferred;
- censoring/interval bounds.

Se endpoints não forem adequados:

> **LATENCY_NOT_OBSERVABLE**

## 11. UpdateRiskProfile preparation

Phase A prepara evidence inputs, sem produzir rating authoritative.

### A1 — criticidade da decisão
Reunir fatos sobre uso esperado e consequência de obsolescência.

### A2 — volatilidade
Reunir fatos sobre ritmo/estrutura de produção de reviews, RCTs e registry changes, sem converter frequência observada em cadence.

### A3 — sensibilidade da conclusão
Documentar quais classes de nova evidência poderiam materialmente modificar direção, magnitude ou confiança.

### A4 — safety/integrity exposure
Avaliar apenas com julgamento científico apropriado; não inferir de ausência/presença de signal.

### A5 — dependency reach
Mapear dependências downstream reais do ProductVersion.

### B1 — observabilidade
Caracterização source-specific.

### B2 — detection latency
Somente fatos observáveis; sem invented latency.

### B3 — surveillance burden
Pilot effort futuro pode informar, mas não fechar rating sozinho.

### B4 — incorporation cost
Avaliar separadamente do custo de observar.

### B5 — sustainable capacity
Não inferir de pilot effort.

Estado:

> **UPDATE_RISK_PROFILE = EVIDENCE_PREPARATION_ONLY**

## 12. Semantic storage mapping

### 12.1 Plan/epoch/authority/source characterization

Storage inicial:

> **Artifact/documentation in repository**

Não existe physical contract específico autorizado.

### 12.2 Scientific search

Pode usar `investigation.search` somente se:

- for uma Search científica realmente executada;
- tiver exact strategy;
- possuir purpose científico;
- estiver semanticamente vinculada à Investigation;
- não for apenas liveness/latency probe.

### 12.3 SearchHit / ScreeningDecision

Somente quando houver:

- retrieved scientific candidate;
- identidade real;
- decisão de screening realmente executada.

### 12.4 Source liveness / latency / access probe

Não usar:

- `investigation.search`;
- MonitoringCycle;
- CadenceObservation.

Storage:

> artifact/log documental auditável.

### 12.5 Operator effort / capacity observation

Não usar Search nem CadenceObservation.

Storage:

> artifact/log operacional auditável.

### 12.6 Incidental scientific finding

Preservar locator/provenance e encaminhar:

> candidate triage → canonical update workflow

Sem alterar produto automaticamente.

## 13. Event outcome model

Para cada measurement event futuro:

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

Atribuição causal exige evidência.

## 14. Authority package

### 14.1 Operational execution authority

Requer decisão humana explícita de owner/institutional authority para:

- exact target;
- Phase A scope;
- permitted sources;
- permitted access mode;
- storage/logging;
- execution boundary.

Status:

> **MISSING — EXECUTION_NOT_AUTHORIZED**

### 14.2 Scientific/methodological authority

Ratings/judgments que fechem A1–A5/B1–B5 ou afirmem sufficiency exigem human_reviewer/human_expert apropriado conforme Documento 46/47.

Status:

> **MISSING**

### 14.3 Data-governance authority

Quando termos/licenças ou dados tratados exigirem decisão institucional, registrar authority específica.

Status:

> **TO_BE_ASSESSED_IN_PHASE_A**

Owner publication approval dos Documentos 66–67 não satisfaz nenhum desses requisitos automaticamente.

## 15. Data-governance package

### Data minimization

Planejado coletar apenas:

- query/strategy metadata;
- source metadata;
- timestamps necessários;
- result-count/cardinality quando confiável;
- record identifiers/locators;
- execution outcome;
- failure metadata;
- operational effort;
- change/deviation log.

### Personal data

> **NOT_REQUIRED_BY_PLAN**

Não coletar dados pessoais de pacientes.

### Secrets

> **PROHIBITED_IN_AUDIT_ARTIFACTS**

### Source terms/licensing

> **MUST_BE_CHECKED_BEFORE_EXECUTION**

Nenhum direito de acesso/redistribuição é presumido neste documento.

### Retention

Artifacts metodológicos/auditáveis ficam sujeitos à política documental do repositório; payloads desnecessários não devem ser retidos.

## 16. Measurement schedule

Estado:

> **NOT_SELECTED**

Justificativa:

O objetivo da Phase A é justamente determinar:

- que resoluções temporais são observáveis;
- quais channels possuem comportamento documentável;
- quais endpoints são precisos;
- qual carga operacional é plausível.

Selecionar agora um intervalo experimental violaria o anti-anchoring do Documento 51/53.

Qualquer schedule futuro será:

> **NON_NORMATIVE**

e exigirá amendment + recheck.

## 17. Start boundary

Execução real da Phase A só pode começar quando todos os itens abaixo ocorrerem:

1. target-specific gate PASS;
2. operational execution authority humana explícita;
3. source access/data-governance review suficiente para os atos pretendidos;
4. storage mapping final para cada event class;
5. target ainda current;
6. nenhuma invalidation trigger ativa.

Antes disso:

> **START_BOUNDARY_NOT_MET**

## 18. Review boundary

Phase A termina quando:

- cada source candidate possuir characterization record suficiente para decidir observability; ou
- uma fonte for documentadamente `not_characterizable_under_current_access`; ou
- blocker de authority/access/governance impedir progressão; ou
- target/source/architecture sofrer mudança material.

Isso é boundary sem minimum-N e sem duração arbitrária.

## 19. Stop conditions

Interromper/invalidate se ocorrer:

- target supersession;
- target rebaseline;
- source/API/interface material change;
- terms/access change;
- authority withdrawal;
- data-governance issue;
- purpose drift toward persistent surveillance;
- need for M1→M2;
- storage semantic mismatch material;
- incident de segurança;
- impossibilidade de preservar provenance.

## 20. Drift rules

Mudança material de:

- target;
- source scope;
- query/strategy;
- interface;
- instrumentation;
- authority;
- operational model

exige:

- new plan version; ou
- new Observation Epoch; ou
- invalidation.

Nenhuma reescrita retroativa.

## 21. Replay design

Phase A deverá gerar audit trail suficiente para reconstruir:

- qual source fact foi consultado;
- quando;
- em qual locator;
- com qual interpretação;
- qual interface;
- qual status de execução;
- qual limitação.

Phase B deverá acrescentar event-level replay se autorizada.

## 22. Capacity design

Phase A pode medir apenas esforço de characterization/preparation.

Phase B, se autorizada, poderá medir pilot effort.

Nenhum deles, sozinho, prova sustainable capacity.

## 23. Incidental findings

Se Phase A ou futura Phase B revelar nova evidência potencialmente material:

1. registrar locator/provenance;
2. marcar como candidate finding;
3. encaminhar ao workflow canônico;
4. não alterar currentness;
5. não alterar conclusion;
6. não alterar assurance;
7. não transformar o plano em Monitor.

## 24. Expected Phase A Result Package

Ao término da Phase A:

> **TOPI-N2-DCBTI-01 Phase A Characterization Package**

deve conter:

- source characterization matrix;
- observed/documented/inferred fact separation;
- timestamp/latency observability matrix;
- source-access/data-governance findings;
- semantic storage map final;
- authority status;
- UpdateRiskProfile evidence-preparation matrix;
- operational effort observations;
- unresolved blockers;
- recommended Phase B measurement design;
- proposed non-normative schedule, se justificável;
- proposed review boundary;
- invalidation conditions;
- recommendation for amendment/recheck.

O pacote não é Evidence Readiness Assessment nem Calibration Dossier.

## 25. Post-Phase A chain

Fluxo obrigatório:

> **Phase A Result Package → Plan Amendment v0.2 → target-specific recheck → explicit execution authority for Phase B → prospective measurement → final Result Package → novo Evidence Readiness Assessment**

Somente se o novo Evidence Readiness resultar READY:

> Calibration Dossier poderá ser aberto.

## 26. Estado

> **FIRST_TEMPORAL_OBSERVATION_PLAN_TARGET = N2_RC01_DCBTI_PRODUCTVERSION_1**

> **FIRST_TEMPORAL_OBSERVATION_PLAN_INSTANCE = TOPI_N2_DCBTI_V01**

> **PLAN_STATUS = CANDIDATE_FOR_TARGET_SPECIFIC_GATE**

> **PHASE_A = SPECIFIED_NOT_AUTHORIZED**

> **PHASE_B = BLOCKED_PENDING_PHASE_A_AND_AMENDMENT**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **EXECUTION_AUTHORITY = MISSING**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **UPDATE_RISK_PROFILE = EVIDENCE_PREPARATION_ONLY**

> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_REQUIRED_AT_SPECIFICATION_STAGE**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **SCHEDULER = DEFERRED**

> **NOTIFICATIONS = DEFERRED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

## 27. Próximo passo

> **Executar gate target-specific da TOPI-N2-DCBTI-01.**

Nenhuma source interaction real deve ocorrer antes do gate e da authority explícita.

**Fim do Documento 54**
