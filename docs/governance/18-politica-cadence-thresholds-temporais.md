# 18 — Política Transversal de Cadence e Thresholds Temporais

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — aprovado após Documento 19**  
**Dependências:** Documentos 05–09 e 16–19; migrations 014, 021–022 e 027

---

## 1. Finalidade

Definir a semântica transversal de tempo para manutenção de evidências antes da definição de SLAs.

Este documento separa:

1. cadence de vigilância;
2. vigilância orientada por evento;
3. janela de cobertura;
4. latência da fonte;
5. atraso operacional;
6. reassessment de profile/policy;
7. thresholds temporais de escalation.

Não define:

- calendário universal;
- frequência universal por M;
- SLA em horas/dias;
- scheduler;
- notification channel;
- auto-escalation;
- M3 readiness;
- mudança automática de currentness.

---

# 2. Princípio central

> **Tempo operacional não é estado científico.**

Uma obrigação vencida pode demonstrar:

- dívida operacional;
- lacuna de processo;
- risco de atraso;
- necessidade de escalonamento.

Ela não demonstra, por si só:

- materialidade científica;
- mudança de conclusão;
- necessidade de atualização;
- outdated.

Currentness continua dependente de:

> UpdateSignal → MaterialityAssessment → UpdateDecision.

---

# 3. Quatro relógios distintos

## 3.1 Relógio de vigilância

Pergunta:

> quando uma fonte ou conjunto de fontes deve ser consultado novamente?

Produz:

- due time;
- cycle/check esperado;
- eventual signal operacional `cadence_due`.

Não é SLA de decisão científica.

---

## 3.2 Relógio de processamento

Pergunta:

> após informação relevante ser detectada, quando deve ser triada/avaliada?

Começa em evento observável, por exemplo:

- detecção pelo Monitor;
- ingestão de Alert;
- notificação regulatória;
- registro de UpdateSignal.

Esse relógio pertence ao bloco de SLA, não à cadence de busca.

---

## 3.3 Relógio de reassessment de policy/profile

Pergunta:

> quando a própria intensidade de manutenção precisa ser revista, mesmo sem signal científico novo?

Pode ser acionado por:

- data prospectiva;
- mudança de capacidade;
- mudança de observabilidade;
- mudança de pipeline;
- mudança de uso;
- drift entre policy e operação real.

Não implica reexecução completa da síntese.

---

## 3.4 Relógio de atualização científica

Pergunta:

> uma vez autorizada atualização científica, quanto tempo decorre até nova versão científica válida?

É distinto dos três relógios anteriores.

Seu atraso:

- não reescreve a conclusão antiga;
- pode manter target under_evaluation/update_recommended/outdated conforme decisão já registrada;
- pertence ao SLA de workflow científico.

---

# 4. Cadence não é janela de cobertura

O OES distinguirá:

### cadence

Quando executar vigilância.

### coverage window

Qual período de evidência a execução pretende cobrir.

Exemplo conceitual:

- um ciclo estava previsto para dia D;
- foi executado depois de D;
- sua busca cobre todo o intervalo desde a janela anterior.

Nesse caso:

> existe atraso operacional, mas pode não existir gap de cobertura.

O inverso também é possível:

- ciclo executado “no prazo”;
- estratégia ou janela deixa intervalo descoberto.

Nesse caso:

> não há atraso, mas existe problema de cobertura.

Esses estados nunca serão colapsados.

---

# 5. Compatibilidade com o Monitor existente

As migrations 021–022 já possuem:

- `monitor_cycle.window_start_date`;
- `monitor_cycle.window_end_date`;
- `planned_at`;
- `started_at`;
- `completed_at`;
- checagem de gaps;
- checagem temporal de Search;
- exceções documentadas por `investigation.method_decision`.

A política da Fase 4:

> **não substitui essa semântica.**

Ela acrescentará, quando fisicamente implementada:

- regra prospectiva de quando um novo ciclo/check é devido;
- tolerância explicitamente autorizada;
- detecção de atraso;
- regra de reassessment da própria cadence.

---

# 6. Unidade de cadence

Cadence poderá existir em mais de um nível.

## 6.1 Cadence do Monitor/ciclo

Define a expectativa principal de execução do Monitoring Cycle.

Adequada quando fontes são processadas em conjunto.

## 6.2 Cadence por classe de fonte

Necessária quando diferentes fontes possuem comportamentos distintos, por exemplo:

- bibliographic;
- registry;
- regulatory;
- validity;
- citation chaining;
- event-only.

Uma fonte regulatória pode exigir vigilância event-driven forte enquanto busca bibliográfica permanece periódica.

## 6.3 Cadence de reassessment

Define quando profile/policy precisa ser revisto.

Não é ciclo de busca.

---

# 7. Modos de cadence

O domínio físico já existe em `maintenance.update_policy.cadence_mode`.

## 7.1 none

Sem vigilância ativa periódica.

Compatível com:

- M0.

Eventuais demandas externas ainda podem iniciar reassessment explícito, mas a policy não promete vigilância ativa.

## 7.2 event_driven

Execução ocorre por gatilho/evento, não por relógio periódico principal.

Compatível com:

- M1.

Exemplos de canal:

- safety/regulatory;
- integrity/retraction;
- demanda explícita de governança.

Event-driven não significa “sem política”: fontes/eventos esperados devem estar definidos.

## 7.3 periodic

Execução segundo regra temporal prospectiva.

Compatível com:

- M1;
- M2.

Semântica por regime:

- em M1, `periodic` significa **reassessment periódico** do target/policy para decidir se busca/atualização deve ser aberta; não cria Monitoring Cycle nem promete surveillance ativa contínua;
- em M2, `periodic` significa **vigilância ativa prospectiva** executada pelo Monitor governante em Monitoring Cycles.

## 7.4 hybrid

Combina componente temporal + event-driven.

Compatível com:

- M1;
- M2;
- M3.

Semântica:

- M1 = reassessment periódico + gatilhos event-driven;
- M2 = Monitoring Cycles periódicos + gatilhos event-driven;
- M3 = processo living contínuo com mecanismos temporais/event-driven explicitados.

## 7.5 continuous

Caracteriza living surveillance.

Compatível apenas com:

- M3.

No OES:

> continuous não significa polling infinitamente frequente.

Significa processo living com vigilância frequente compatível com disponibilidade/latência das fontes e incorporação tempestiva quando material.

M3 continua formalmente bloqueado.

---

# 8. Regra temporal deve ser explícita por policy

Não haverá default universal.

Uma policy com componente periódico deverá registrar, de forma machine-readable em implementação futura:

- referência temporal;
- frequência/intervalo;
- timezone explícito para regras de calendário;
- semântica de calendário quando relevante (elapsed interval × calendar rule);
- regra para finais de semana/feriados se aplicável;
- next_due_at ou regra determinística equivalente;
- tolerance/grace;
- comportamento diante de pausa;
- comportamento diante de atraso;
- regra para retomada;
- condição de reassessment da cadence.

Uma policy event-driven deverá registrar:

- classes de evento;
- fontes/canais observados;
- requisito de observabilidade;
- condição de detecção;
- fallback se o canal ficar indisponível.

---

# 9. Frequência por policy, não por taxonomia global

OES poderá usar intervalos concretos em uma policy individual.

Exemplos possíveis, apenas ilustrativos:

- semanal;
- mensal;
- trimestral;
- semestral;
- anual;
- cron expression;
- intervalo ISO 8601;
- regra baseada em data/evento.

Mas:

> **nenhum desses intervalos será default universal de M1, M2 ou M3.**

A escolha deverá ser justificada por:

- criticidade;
- volatilidade;
- sensibilidade;
- exposição safety/integrity;
- observabilidade;
- latência;
- carga;
- capacidade.

---

# 10. Source latency

Cadence deve respeitar a realidade das fontes.

Definições:

### source availability latency

Tempo entre ocorrência/publicação do evento e disponibilidade na fonte monitorada.

### ingestion latency

Tempo entre disponibilidade na fonte e captura pelo OES.

### processing latency

Tempo entre captura e triagem/materiality assessment.

Cadence de busca atua principalmente sobre:

> ingestion latency.

Ela não reduz source availability latency.

Consequência:

> executar busca diária em fonte atualizada mensalmente não produz currentness diário.

---

# 11. Multiple-source cadence

Quando uma policy possui múltiplas fontes:

- cada classe poderá ter cadence própria;
- o ciclo agregado não deve mascarar fonte atrasada;
- event-only source não precisa compartilhar intervalo periódico;
- completeness deve considerar requisitos de fonte já normalizados no Monitor.

A futura implementação deverá conseguir responder:

> qual fonte estava devida, quando, e se foi executada dentro da regra aplicável?

---

# 12. Âncora temporal e prevenção de schedule drift

A regra de due date deverá partir de referência explícita.

Modos conceituais:

### fixed_anchor

O calendário é ancorado em referência fixa/prospectiva, por exemplo:

- `effective_at` da policy;
- data de cutoff/publicação;
- calendário institucional explícito.

Atraso de uma execução:

> **não desloca automaticamente os próximos vencimentos.**

Esse deve ser o padrão quando a intenção é manter frequência estável.

### rolling_anchor

O próximo due é calculado a partir de evento anterior realizado, por exemplo:

- `completed_at` do último ciclo elegível;
- `executed_at` da última execução elegível da fonte.

Rolling só pode ser usado quando a policy justificar que a obrigação é realmente “X após a última execução”, e não “a cada X no calendário”.

Sem essa distinção, um ciclo atrasado poderia redefinir a base e apagar atraso futuro.

### event_anchor

O relógio nasce de evento externo explícito.

Não permitir:

> due date inferida de “agora menos X” sem fonte normativa registrada.

Mudança de âncora:

> exige nova UpdatePolicy por supersessão quando altera o regime operacional efetivo.

Regra de calendário:

- timestamps persistidos continuam em `timestamptz`;
- regra do tipo “todo dia X às HH:MM” precisa declarar timezone da policy;
- mudança de horário sazonal/calendário não pode ser resolvida por inferência silenciosa.

---

# 13. Due, planned_at, grace e overdue

Para Monitoring Cycle agregado:

> `monitor_cycle.planned_at` materializa o **instante nominal planejado de início** do ciclo.

O contrato atual também exige:

> `started_at >= planned_at`.

Portanto, `planned_at` não deve ser reinterpretado como simples “último instante aceitável”.

A regra futura deve distinguir:

- `planned_at` = instante nominal/abertura programada;
- `grace_until` = limite superior aceitável para início sem atraso formal;
- `started_at` = início real.

Não criar outro timestamp nominal equivalente a `planned_at` sem necessidade demonstrada.

Conclusão do ciclo:

> pertence ao relógio de processamento/completion SLA e não será inferida de `planned_at`.

Para source-specific cadence sem ciclo próprio, futuro contrato poderá precisar de obrigação temporal especializada.

O OES adota três conceitos distintos.

## 13.1 scheduled_at / planned_at

Instante nominal em que a obrigação temporal se abre.

No Monitor agregado:

> usar `monitor_cycle.planned_at`.

Para regras não materializadas em MonitorCycle, futuro contrato poderá usar nome equivalente, mas não deve criar duplicação quando `planned_at` já existe.

## 13.2 grace_until

Limite operacional tolerado pela policy sem caracterizar atraso formal.

Grace:

- deve ser explícita;
- não deve ser maior que a própria lógica de cadence de modo a esvaziá-la;
- não muda a janela de cobertura.

## 13.3 overdue

Estado operacional derivado quando:

> current time > grace_until

e a obrigação ainda não foi satisfeita.

Preferência arquitetural:

> **overdue deve ser computado a partir de regra + relógio + evidência de satisfação, não mantido como boolean mutável que possa ficar stale.**

Overdue:

- gera issue;
- pode gerar escalation;
- não gera outdated automaticamente.

---

# 14. Atraso sem perda de cobertura

Quando obrigação periódica fica overdue mas a execução tardia cobre integralmente o período esperado:

registrar:

- atraso;
- execução tardia;
- cobertura completa.

Não registrar falsamente:

- cycle gap;
- missing evidence period.

Atraso continua relevante para performance/SLA.

---

# 15. Gap de cobertura

Gap existe quando intervalo de evidência esperado não foi coberto.

A migration 022 já possui mecanismos para Monitor:

- `UNEXPLAINED_CYCLE_WINDOW_GAP`;
- `SEARCH_OUTSIDE_CYCLE_WINDOW`;
- MethodDecision de exceção temporal.

A política transversal reutiliza essa semântica.

Regra:

> gap e overdue são problemas diferentes e podem coexistir ou ocorrer isoladamente.

---

# 16. Satisfação da obrigação temporal

A policy futura deverá definir o que satisfaz cada obrigação.

Para MonitorCycle agregado, candidato padrão:

- `started_at` deve ocorrer em ou após `planned_at`;
- início até `grace_until` satisfaz a obrigação sem overdue;
- início após `grace_until` satisfaz a execução, mas preserva histórico de atraso;
- ciclo concluído não é requisito da cadence de início, mas de processamento/completion.

Para source-specific cadence, satisfação pode exigir:

- Search completed;
- evento de consulta à fonte;
- registro explícito de source check sem resultados.

Não usar simples criação de registro vazio para fingir execução.

Uma obrigação satisfeita tardiamente:

> continua historicamente atrasada; não pode ser reclassificada retroativamente como on_schedule.

Execução antecipada:

- no Monitor atual, `started_at < planned_at` é inválido;
- em futuros mecanismos não-Monitor, execução antes do scheduled instant não satisfaz automaticamente a próxima obrigação fixa;
- fixed_anchor não é deslocado por execução antecipada;
- eventual “early fulfillment” exige regra prospectiva explícita e não pode criar janela descoberta.

# 17. Pausa operacional

Policy/Monitor pode entrar em estado operacional incompatível com execução normal.

Uma pausa deve registrar:

- início;
- razão;
- autoridade;
- expectativa de retomada quando conhecida;
- tratamento do relógio;
- tratamento da cobertura acumulada.

Dois modos futuros:

### clock_paused

O relógio de obrigação é suspenso por decisão explícita de governança.

### clock_continues

A obrigação continua acumulando atraso durante a pausa.

A escolha deve ser prospectiva e justificável.

Pausa nunca apaga janela científica descoberta.

---

# 18. Exceção temporal

Exceção não é simples edição do relógio.

Para Monitor, exceções metodológicas já usam:

> `investigation.method_decision`.

Exemplos existentes:

- `monitor_cycle_window_gap_exception`;
- `monitor_search_temporal_exception`.

A Fase 4 preserva esse padrão.

Uma futura exceção à cadence/threshold deverá:

- apontar para target/policy/cycle/source;
- registrar regra violada;
- rationale;
- ator;
- resolução;
- período de validade;
- não falsificar status “on time”.

Limite de competência:

- exceções específicas do Monitor continuam em `investigation.method_decision`, ligadas à Monitor InvestigationVersion;
- não estender MethodDecision artificialmente a obrigações transversais sem InvestigationVersion adequada;
- exceções transversais gerais podem exigir registro especializado posterior se o gate físico demonstrar necessidade.

---

# 19. Thresholds temporais

O OES não adotará um único “prazo máximo”.

Threshold temporal é uma regra que transforma diferença temporal em estado operacional.

Classes:

## 19.1 threshold de due

Determina quando obrigação nasce.

## 19.2 threshold de grace

Determina tolerância operacional explícita.

## 19.3 threshold de overdue escalation

Determina quando atraso exige escalonamento adicional.

## 19.4 threshold de stale policy/profile

Determina quando policy/profile precisa de reassessment mesmo sem signal científico.

## 19.5 threshold de unresolved signal

Pertence ao bloco de SLA:

> tempo máximo aceitável sem triagem/materiality/decision.

Não será definido numericamente neste documento.

---

# 20. Classes qualitativas de atraso

Antes de números, o OES reconhece estados semânticos:

### not_open

O instante nominal de início ainda não chegou.

### within_grace

A obrigação foi aberta em `planned_at`, mas ainda está dentro da tolerância operacional.

### satisfied_on_time

A execução iniciou entre `planned_at` e `grace_until`.

### overdue

Grace vencida; execução/obrigação ainda pendente.

### satisfied_late

A obrigação foi executada após `grace_until`; o fato de ter sido satisfeita não apaga o atraso histórico.

### escalation_overdue

Atraso pendente ultrapassou threshold adicional de escalonamento definido pela policy.

### suspended_by_authority

Relógio explicitamente pausado por decisão válida.

### not_applicable

Não existe obrigação temporal para aquele objeto/regra.

Esses estados são operacionais.

Não equivalem a currentness.

---

# 21. Escalation overdue

`escalation_overdue` significa:

> atraso operacional pendente suficientemente importante para exigir escalonamento segundo regra temporal explícita.

Não significa:

> `material_change_confirmed`.

Quando a obrigação é finalmente cumprida:

- o estado corrente deixa de ser escalation_overdue;
- o histórico deve registrar `satisfied_late` e duração real do atraso;
- a resolução não apaga incidentes/escalonamentos já registrados.

---

# 22. Reassessment de cadence

A cadence deve ser reavaliada quando:

- profile científico muda;
- B1/B2 observabilidade/latência muda;
- B3 carga se altera de forma relevante;
- B5 capacidade muda;
- Monitor apresenta repetidos gaps;
- yield de signals muda materialmente;
- nova fonte torna-se disponível;
- fonte crítica deixa de existir;
- target recebe nova versão;
- policy muda de M;
- Alert/safety pattern demonstra inadequação do intervalo.

Mudança de cadence:

> exige nova UpdatePolicy por supersessão quando altera a regra operacional efetiva.

Não editar policy ativa silenciosamente.

Supersessão não apaga obrigações históricas:

- atraso ocorrido sob policy anterior permanece auditável;
- incidentes/escalonamentos permanecem vinculados à regra vigente no momento;
- nova policy não pode “resetar” retroativamente um overdue;
- outstanding obligation deve ser explicitamente resolvida, transferida ou encerrada por regra de transição futura.

---

# 23. Cadence × M0

M0:

- cadence_mode = none;
- não há obrigação periódica de surveillance;
- demandas/eventos externos podem iniciar reassessment extraordinário;
- ausência de surveillance ativa deve ser transparente.

---

# 24. Cadence × M1

M1:

- event_driven, periodic ou hybrid;
- Monitor governante é proibido pelo contrato 027;
- componente periodic = reassessment programado, não Monitoring Cycle;
- reassessment pode decidir abrir busca ad hoc, reroteamento ou nova policy;
- event-driven deve identificar fontes/classes de evento.

M1 não promete vigilância ativa contínua e não deve ser representado como “M2 sem Monitor”.

---

# 25. Cadence × M2

M2:

- periodic ou hybrid;
- Monitor governante obrigatório;
- ciclo prospectivo deve ser definível antes da execução;
- coverage windows devem permanecer contínuas ou ter exceção documentada;
- overdue deve ser rastreável separadamente de gap.

M2 pode possuir fonte event-driven adicional.

---

# 26. Cadence × M3

M3:

- continuous ou hybrid;
- Monitor governante obrigatório;
- frequência deve ser coerente com source latency e capacidade;
- detecção e incorporação devem ser suficientemente tempestivas para justificar caráter living;
- critérios de saída/rebaixamento precisam existir no futuro contrato M3.

Mas:

> **M3 permanece não operacional.**

Nenhuma cadence, por si só, desbloqueia M3.

---

# 27. Event-driven surveillance

Event-driven não é ausência de cadence.

É uma política de latência baseada em evento.

Deve distinguir:

### push

Fonte envia evento/notificação.

### pull

OES consulta fonte em intervalo curto para detectar evento.

### external notice

Signal entra por comunicação externa validável.

A policy deve registrar qual mecanismo existe.

Se o “event-driven” depender de polling:

> o intervalo de polling é parte da regra temporal e deve ser explícito.

Se depender de push externo:

> a saúde/disponibilidade do canal deve ser observável; “nenhum evento recebido” não prova que a fonte estava operacional.

---

# 28. Cadence e automação

Automação pode:

- calcular o próximo `planned_at`/scheduled instant conforme a âncora;
- calcular `grace_until`;
- detectar overdue;
- abrir `cadence_due`;
- calcular source-specific due;
- emitir issue operacional;
- preparar proposta de escalation.

Automação não pode:

- tornar target outdated por atraso;
- inventar exceção;
- encerrar gap como coberto;
- alterar UpdatePolicy;
- mudar M;
- desbloquear M3;
- produzir decisão científica autoritativa.

---

# 29. Signal temporal

O contrato 027 já possui:

> `signal_type='cadence_due'`

classe:

> operational / temporal_operational.

Uso recomendado:

- registrar evento relevante de vencimento quando necessário à cadeia de decisão;
- não gerar um signal novo para cada tick do scheduler;
- não usar como substituto de issue operacional simples.

Regra de parcimônia:

> overdue técnico pode existir apenas como issue; UpdateSignal deve ser criado quando o atraso precisa entrar no fluxo de materiality/governance.

---

# 30. Cadence_due × materiality

Um cadence_due pode levar a:

- no_material_change;
- potentially_material;
- validity_or_use_threat;
- insufficient_to_decide.

Não pode, sozinho:

> material_change_confirmed.

Essa restrição já está implementada na migration 027 para signal operacional.

---

# 31. Threshold temporal × currentness

Atraso poderá sustentar `under_evaluation` somente quando:

1. atraso/gap foi formalmente identificado;
2. houve UpdateSignal quando necessário;
3. MaterialityAssessment concluiu que a lacuna ameaça sustentação de currentness;
4. UpdateDecision autoritativa aplicou a ação correspondente.

Nunca:

> `overdue → outdated` diretamente.

---

# 32. Threshold temporal × Alert

Alert urgency e cadence são independentes.

- Alert urgent pode exigir resposta imediata mesmo se ciclo periódico não estiver devido;
- cadence overdue pode não justificar Alert;
- Alert critical não redefine automaticamente periodicidade futura.

Depois da resolução:

> o evento pode justificar reassessment da cadence/policy.

---

# 33. Threshold temporal × MethodDecision

`investigation.method_decision` continua sendo registro de exceções metodológicas/temporais específicas do Monitor.

`maintenance.update_decision` continua sendo decisão de atualização/currentness.

Exemplo:

- MethodDecision pode aceitar uma Search fora da janela por razão metodológica válida;
- UpdateDecision pode decidir se a lacuna/atraso afeta currentness.

As duas decisões:

> são complementares, não substitutas.

---

# 34. Re-baselining temporal

Quando nova ProductVersion/InvestigationVersion se torna target:

- policy antiga permanece histórica;
- nova policy precisa de referência temporal própria;
- Monitor ligado à versão anterior não é retargeteado silenciosamente;
- coverage baseline deve ser explicitamente definido;
- carry-forward de cadence precisa de decisão explícita.

Não usar completed_at da versão anterior como referência automática sem regra.

---

# 35. Métricas operacionais candidatas

Podem ser calculadas futuramente:

- scheduled/planned instant (`planned_at` quando MonitorCycle);
- timezone/calendar basis da regra;
- actual_started_at;
- actual_completed_at;
- lateness duration;
- source ingestion lag;
- processing lag;
- uncovered duration;
- cycle completion rate;
- source completion rate;
- repeated overdue count.

Essas métricas:

- não são thresholds universais;
- não são score científico;
- não alteram currentness sozinhas.

---

# 36. Referências metodológicas orientadoras

A arquitetura foi confrontada com princípios atuais:

1. Cochrane Handbook, Chapter 22 — living systematic reviews usam vigilância frequente e devem explicitar métodos de busca e frequência de atualização prospectivamente;
2. Cochrane Handbook, Chapter IV — living updating é apropriado sobretudo quando a pergunta é importante, nova evidência é frequente e pode impactar achados, com necessidade de recursos;
3. NICE PMG49 (2025) — surveillance deve ser proporcional e direcionada, combinando reactive monitoring, tracking prospectivo e revisões planejadas;
4. WHO living-guidelines approach — combina continuous surveillance com atualização rápida das sínteses/recomendações priorizadas.

Essas fontes não autorizam um intervalo universal no OES.

---

# 37. Implicações para futuro contrato físico

Uma extensão física futura poderá precisar representar:

- cadence rule;
- source-specific cadence;
- due calculation;
- grace/tolerance;
- pause state;
- temporal issue;
- escalation threshold;
- policy/profile reassessment due;
- exception linkage.

Antes disso deve haver gate específico.

---

# 38. Testes conceituais obrigatórios antes de migration

1. ciclo atrasado + cobertura completa ≠ gap;
2. fixed_anchor não desliza devido a execução tardia;
3. rolling_anchor exige justificativa explícita;
4. `planned_at` é instante nominal e `started_at < planned_at` permanece inválido no Monitor atual;
5. `grace_until` é limite superior de início sem overdue;
6. completion SLA é relógio separado;
7. M1 periodic gera reassessment, não Monitoring Cycle;
8. ciclo pontual + janela incompleta = gap;
9. source latency > cadence não cria falsa atualidade;
10. M1 event-driven sem periodic funciona;
11. M2 periodic exige regra prospectiva;
12. M2 hybrid aceita evento antes do scheduled instant;
13. M3 policy não remove blocker;
14. overdue não altera currentness;
15. gap não altera currentness sem assessment;
16. cadence_due operacional não confirma material change;
17. policy reassessment é relógio distinto;
18. pause não apaga coverage debt;
19. MethodDecision temporal exception não substitui UpdateDecision;
20. supersessão de policy recalcula referência prospectivamente;
21. obrigação satisfeita tardiamente preserva histórico de atraso;
22. push channel indisponível não conta como vigilância válida;
23. no universal default é inferido por M.

---

# 39. Próximo passo exato

> **Definir a arquitetura transversal de SLAs como contratos operacionais entre eventos claramente definidos, preservando a separação entre breach operacional e estado científico.**
