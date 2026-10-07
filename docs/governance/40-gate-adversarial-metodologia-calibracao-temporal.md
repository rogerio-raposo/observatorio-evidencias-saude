# 40 — Gate Adversarial da Metodologia de Calibração Temporal

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — após hardening e recheck**  
**Dependência:** Documento 39  
**Objeto:** atacar a metodologia antes de qualquer valor normativo

---

## 1. Resultado da primeira passagem

> **TEMPORAL_CALIBRATION_METHODOLOGY = REVISE**

> **NUMERIC_CADENCE = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_AUTHORIZED**

> **REAL_SLA_CALENDARS = NOT_AUTHORIZED**

> **NORMATIVE_SLA_RULES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A estrutura por envelopes é adequada, mas exige hardening antes de PASS.

---

## 2. AR-F4-TC01 — Need envelope não pode virar mapping implícito

### Ataque

A1/A2/A3/A4/A5 poderiam ser convertidos tacitamente em tabela do tipo:

> high = X dias.

Isso recriaria score/mapping automático sob outro nome.

### Decisão

As dimensões:

- informam direção;
- criam floors qualitativos;
- restringem contextos;
- exigem rationale.

Elas:

> **não determinam número por função automática.**

Valor temporal continua decisão calibrada com evidence dossier.

**Resultado:** REVISE_REQUIRED.

---

## 3. AR-F4-TC02 — “menor carga” pode virar função objetivo oculta

### Ataque

Selecionar “o schedule de menor carga” pode fazer custo dominar risco.

### Decisão

Usar análise de dominância/Pareto:

1. eliminar candidatos que não satisfazem need/external constraints;
2. eliminar candidatos source-ineffective;
3. eliminar candidatos inviáveis;
4. entre candidatos não dominados, governance seleciona com rationale.

Não existe scalar utility function universal.

**Resultado:** REVISE_REQUIRED.

---

## 4. AR-F4-TC03 — Source latency não é cadence target

### Ataque

Latência observada poderia ser copiada diretamente como frequência.

### Decisão

Source latency:

- limita ganho possível;
- informa polling redundancy;
- não determina intervalo sozinho.

Event channels, volatility e need continuam independentes.

**Resultado:** REVISE_REQUIRED.

---

## 5. AR-F4-TC04 — Suficiência sem N mínimo universal

### Ataque

`sufficient_for_calibration` pode esconder amostra pequena.

### Decisão

Não definir N universal nesta metodologia.

O dossier deve registrar:

- volume de casos;
- missingness;
- censura;
- período;
- representatividade;
- estabilidade temporal;
- mudança estrutural.

A decisão de suficiência deve possuir rationale explícita.

**Resultado:** PASS_WITH_CLARIFICATION.

---

## 6. AR-F4-TC05 — Replay não pode otimizar apenas passado observado

### Ataque

Survivorship bias e casos incompletos podem favorecer targets irreais.

### Decisão

Replay deve incluir:

- casos completos;
- casos censurados;
- missing timestamps;
- falhas de canal;
- outliers operacionais;
- períodos de capacidade tensionada.

Missingness não será imputada para melhorar desempenho.

**Resultado:** REVISE_REQUIRED.

---

## 7. AR-F4-TC06 — Priority ↔ SLA circularity

### Ataque

response_class seleciona SLA; breach posterior pode gerar nova PriorityAssessment.

Sem ordem temporal, a breach poderia retroagir e selecionar outra rule para a mesma instance.

### Decisão

Para uma SLA Instance:

- rule selection usa PriorityAssessment/start context anterior à instance;
- rule snapshot congela seleção;
- breach posterior pode ser basis de **nova** PriorityAssessment;
- nova prioridade não recalcula instance existente.

**Resultado:** REVISE_REQUIRED.

---

## 8. AR-F4-TC07 — Provisional rule não cabe hoje em SLARule ativa

### Ataque

`provisional_requires_reassessment` poderia ser inserido como SLARule real e tratado como “teste”.

O schema não possui proposal state de SLARule.

### Decisão

Provisional calibration:

> permanece fora das tabelas normativas ativas.

Somente `approved_for_normative_activation` pode originar policy/rule real.

**Resultado:** REVISE_REQUIRED.

---

## 9. AR-F4-TC08 — Cadence JSON aberto

### Ataque

`cadence_policy_payload` aceita qualquer object.

Inserir `{"days":30}` seria sintaticamente válido, mas semanticamente não governado.

### Decisão

Antes de numeric cadence:

- shape fechado;
- units;
- anchor;
- grace;
- source scope;
- satisfaction event;
- timezone/calendar semantics;
- fallback/event channel;
- validator.

Pode ser JSON fechado ou estrutura normalizada; decisão física posterior.

**Resultado:** PHYSICAL_BLOCKER.

---

## 10. AR-F4-TC09 — Source-specific cadence não tem obrigação física fechada

### Ataque

Multiple-source cadence exige saber qual fonte estava due.

MonitorCycle agregado pode não representar todas as obrigações source-specific.

### Decisão

Antes de ativar source-specific numeric cadence:

> definir obrigação temporal física source-scoped ou provar que MonitorCycle agregado é suficiente para o caso.

**Resultado:** PHYSICAL_BLOCKER.

---

## 11. AR-F4-TC10 — SLARule resolver ausente

### Ataque

Schema possui filters/precedence, mas nenhuma função canônica de seleção foi encontrada.

### Decisão

Antes de normative rules:

- resolver determinístico;
- closed filter matching;
- fallback validation;
- ambiguity detection;
- canonical selection trace.

**Resultado:** PHYSICAL_BLOCKER.

---

## 12. AR-F4-TC11 — filtros parcialmente abertos

### Ataque

`trigger_class_filter`, `decision_type_filter` e `materiality_outcome_filter` são text sem domain CHECK específico na SLARule.

### Decisão

Normative resolver deve validar contra domínios canônicos reais.

Não permitir typo/filter impossível como rule operacional.

**Resultado:** PHYSICAL_BLOCKER.

---

## 13. AR-F4-TC12 — round_type heterogeneity

### Ataque

SLA4–6 podem variar materialmente por `workflow_round.round_type`, mas SLARule não possui round_type_filter.

### Decisão

Não adicionar filtro por hipótese.

Durante calibração:

- testar heterogeneidade;
- se não material, filtros atuais podem bastar;
- se material e necessária à regra, abrir mudança física explícita.

Não codificar round_type em rationale/JSON.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 14. AR-F4-TC13 — nominal_due_at não é derivado da rule

### Ataque

SLAInstance aceita nominal_due_at manual.

Logo um caller pode usar rule de 24h e informar due de 72h.

### Decisão

Antes de normative SLA:

- função canônica de nominal due;
- INSERT guard comparando due informado/derivado ou derivação interna;
- serializer canônico da rule snapshot.

**Resultado:** PHYSICAL_BLOCKER.

---

## 15. AR-F4-TC14 — business-calendar arithmetic

### Ataque

Calendar shape é validado, mas não existe evidência de arithmetic autoritativa:

> start + target_duration em calendário.

### Decisão

Antes de business-calendar SLA:

- função determinística;
- timezone handling;
- intervals crossing days;
- closed/custom exception dates;
- DST behavior quando timezone possuir DST;
- test vectors.

**Resultado:** PHYSICAL_BLOCKER.

---

## 16. AR-F4-TC15 — fixed deadline provenance

### Ataque

Payload valida source_type/date/rationale, mas não garante locator forte para a fonte declarada.

### Decisão

Normative fixed deadline exige:

- structured source locator;
- precision preservation;
- rule source immutability/auditability;
- no invented timestamp.

**Resultado:** PHYSICAL_BLOCKER.

---

## 17. AR-F4-TC16 — calendário fora da vigência

### Ataque

SLARule pode apontar para calendar version cuja vigência não cubra a rule.

### Decisão

Normative business-calendar rule exige:

- calendar effective at rule effective_at;
- policy para calendar supersession;
- instance congela versão original.

**Resultado:** PHYSICAL_BLOCKER.

---

## 18. AR-F4-TC17 — warning/breach/escalation JSON aberto

### Ataque

Valores podem entrar em payloads sem unit/relationship validation.

### Decisão

Antes de números:

- schema fechado;
- warning não move due;
- breach ocorre no due;
- escalation threshold adicional preserva first breach;
- nenhuma regra altera currentness.

**Resultado:** PHYSICAL_BLOCKER.

---

## 19. AR-F4-TC18 — repeated breach pode virar SLA laundering

### Ataque

Muitos breaches poderiam justificar alongar SLA até que performance “fique verde”.

### Decisão

Repeated breach primeiro exige decomposição:

- capacity;
- process;
- source;
- endpoint;
- rule realism;
- need change.

Alongamento só é permitido se o **need envelope também sustentar** o novo target.

**Resultado:** REVISE_REQUIRED.

---

## 20. AR-F4-TC19 — business calendar como capacity laundering

### Ataque

Retirar noites/fins de semana de uma obrigação contínua pode mascarar incapacidade.

### Decisão

Calendar basis deve ser propriedade da obrigação, não da escala de trabalho disponível.

Safety/validity 24/7:

> não pode ser convertida em business calendar apenas por limitação de staffing.

**Resultado:** PASS.

---

## 21. AR-F4-TC20 — Calibration Dossier sem lineage físico

### Ataque

Rationale text em UpdatePolicy/SLARule não preserva todas as bases.

### Decisão

Antes de normative activation:

- contrato de Calibration Dossier;
- structured basis;
- linkage para UpdateRiskProfile/policy/rule;
- supersession;
- effective_at;
- authority.

**Resultado:** PHYSICAL_BLOCKER.

---

## 22. AR-F4-TC21 — external requirement não é automaticamente OES SLA

### Ataque

Prazo externo pode ter finalidade diferente do clock OES.

### Decisão

External normative basis só domina quando:

- aplicabilidade ao target/context é demonstrada;
- start/end semânticos são compatíveis;
- precision é preservada;
- conflito com outros requisitos é resolvido.

**Resultado:** REVISE_REQUIRED.

---

## 23. AR-F4-TC22 — currentness/assurance

### Ataque

Cadence curta/SLA rápido poderia ser usado como proxy de atualidade/qualidade.

### Decisão

Preservar:

- no automatic CurrencyState;
- no Assurance promotion;
- no scientific conclusion change.

**Resultado:** PASS.

---

## 24. AR-F4-TC23 — M3

### Ataque

Calibrar continuous/hybrid poderia ser interpretado como living readiness.

### Decisão

Até gate M3:

- apenas análise não operacional;
- nenhuma policy/rule M3 nova é legitimada pela metodologia;
- blocker permanece.

**Resultado:** PASS.

---

## 25. AR-F4-TC24 — scheduler/notifications

### Ataque

Com números disponíveis, automação poderia ser considerada “mecânica”.

### Decisão

Mesmo depois dos números:

> scheduler/notifications exigem gate próprio.

**Resultado:** PASS.

---

# PARTE B — CORREÇÕES OBRIGATÓRIAS

## 26. Hardening requerido no Documento 39

Adicionar explicitamente:

1. need dimensions não mapeiam automaticamente para números;
2. seleção por Pareto/dominância, não minimum-cost scalar;
3. source latency não é interval target;
4. replay inclui censura/missingness/falhas;
5. prioridade usada na rule selection é snapshot pré-instance;
6. provisional calibration fica fora de rules ativas;
7. repeated breach não relaxa SLA automaticamente;
8. external deadline exige semantic applicability;
9. normative activation depende de physical blockers resolvidos.

---

## 27. Physical blockers antes de valores reais

Contrato posterior deverá resolver pelo menos:

- cadence payload/schema;
- source-scoped cadence obligation, quando necessária;
- Calibration Dossier + structured basis;
- canonical SLA rule resolver;
- filter-domain validators;
- canonical rule snapshot;
- nominal due calculator;
- business-calendar arithmetic;
- fixed-deadline source lineage;
- calendar effective-window guard;
- warning/breach/escalation payload schemas.

---

## 28. Estado

> **TEMPORAL_CALIBRATION_METHODOLOGY = REVISE**

> **TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = NOT_YET_SPECIFIED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 29. Próximo passo exato

> **Aplicar o hardening ao Documento 39 e reexecutar este gate. Somente PASS/PASS_WITH_ARCHITECTURAL_DECISIONS poderá autorizar a especificação do contrato físico de calibração — ainda sem valores normativos.**


---

# PARTE C — RECHECK PÓS-HARDENING

## 30. Resultado do recheck

O Documento 39 incorporou as correções obrigatórias da primeira passagem.

Resultado:

> **TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 31. TC01–TC03 — need, Pareto e source latency

Confirmado:

- A1–A5 não mapeiam automaticamente para números;
- nenhum score temporal foi criado;
- seleção usa eliminação por constraints + dominância/Pareto;
- source latency limita ganho observacional, mas não determina cadence.

**Resultado:** PASS.

---

## 32. TC04–TC05 — suficiência, censura e missingness

Confirmado:

- nenhum N mínimo universal;
- dossier deverá registrar volume, período, missingness, censura, outliers e estabilidade;
- replay inclui casos desfavoráveis;
- não é permitido imputar/excluir dados para melhorar performance aparente.

**Resultado:** PASS.

---

## 33. TC06 — Priority ↔ SLA temporal ordering

Confirmado:

- seleção de rule usa contexto disponível antes da SLA Instance;
- start PriorityAssessment/rule snapshot ficam congelados;
- breach posterior pode gerar nova avaliação;
- nova prioridade não recalcula instance existente.

**Resultado:** PASS.

---

## 34. TC07 — provisional calibration

Confirmado:

- `provisional_requires_reassessment` não vira SLARule ativa;
- somente `approved_for_normative_activation` poderá gerar policy/rule real;
- isso ainda depende dos blockers físicos.

**Resultado:** PASS.

---

## 35. TC08–TC09 — cadence physical prerequisites

Confirmado como blocker físico explícito:

- cadence payload/schema fechado ainda precisa ser especificado;
- source-scoped obligation deve existir quando cycle agregado não provar cobertura;
- nenhum número pode entrar no JSON aberto atual.

**Resultado:** PASS_WITH_PHYSICAL_PREREQUISITE.

---

## 36. TC10–TC12 — SLA selection/filtering

Confirmado:

- canonical resolver é pré-requisito;
- filter domains deverão ser fechados/validados;
- round_type não será adicionado preventivamente;
- heterogeneidade deverá ser testada antes de qualquer extensão física.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 37. TC13–TC17 — due/calendar/fixed deadline/threshold payloads

Confirmado como pré-requisito físico:

- canonical rule snapshot;
- nominal due calculator;
- equality guard;
- business-calendar arithmetic determinística;
- fixed-deadline lineage;
- calendar effective-window;
- warning/breach/escalation schemas fechados.

Nenhum desses itens recebeu valor numérico.

**Resultado:** PASS_WITH_PHYSICAL_PREREQUISITES.

---

## 38. TC18–TC21 — anti-laundering e external constraints

Confirmado:

- repeated breach não alonga SLA automaticamente;
- capacity shortage não relaxa need envelope;
- business calendar não pode mascarar obrigação contínua;
- prazo externo só domina quando start/end/aplicabilidade/precision são semanticamente compatíveis.

**Resultado:** PASS.

---

## 39. TC20 — Calibration Dossier

Confirmado:

- provenance física estruturada é obrigatória antes de activation normativa;
- rationale textual isolada é insuficiente;
- dossier deve ligar basis, UpdateRiskProfile, policy/rule, effective_at, authority e supersession.

**Resultado:** PASS_WITH_PHYSICAL_PREREQUISITE.

---

## 40. TC22–TC24 — currentness, assurance, M3 e automação

Confirmado:

- nenhuma mudança automática em CurrencyState;
- nenhuma Assurance promotion;
- nenhum scientific conclusion change;
- M3 continua bloqueado;
- scheduler/notifications continuam dependentes de gate próprio mesmo após futura calibração.

**Resultado:** PASS.

---

## 41. Decisão final

A metodologia está suficientemente fechada para orientar a próxima etapa.

Autoriza-se exclusivamente:

> **especificar o contrato físico dos pré-requisitos de calibração temporal.**

Não se autoriza:

- numeric cadence;
- numeric grace;
- numeric stale thresholds;
- numeric SLA durations;
- real SLA calendars;
- normative SLARules;
- migration 032;
- scheduler;
- notifications;
- auto-escalation;
- M3.

---

## 42. Escopo da próxima especificação física

O contrato físico deverá tratar, no mínimo:

1. Calibration Dossier;
2. structured calibration basis;
3. cadence schema/obligation contract;
4. source-scoped cadence support quando necessário;
5. canonical SLA rule resolver;
6. filter-domain validation;
7. canonical rule snapshot;
8. nominal due calculator;
9. business-calendar arithmetic;
10. fixed-deadline lineage;
11. calendar effective-window validation;
12. warning/breach/escalation schemas;
13. issue/readiness helpers;
14. test plan;
15. explicit M3 blocker preservation.

---

## 43. Estado final do gate

> **TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 44. Próximo passo exato

> **Especificar o contrato físico v0.1 dos pré-requisitos de calibração temporal e submetê-lo a novo gate adversarial/físico antes de qualquer migration ou valor normativo.**

