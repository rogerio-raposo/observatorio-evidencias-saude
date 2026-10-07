# 18 — Política Transversal de Cadence e Thresholds Temporais

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **BASELINE CONCEITUAL CANDIDATA — requer revisão adversarial**  
**Dependências:** Documentos 05–09 e 16–17; migrations 014, 021–022 e 027

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

## 7.4 hybrid

Combina periodic + event-driven.

Compatível com:

- M1;
- M2;
- M3.

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
- timezone/calendário quando relevante;
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

# 12. Temporal reference point

A regra de due date deverá partir de referência explícita.

Referências candidatas:

- effective_at da policy;
- completed_at do último ciclo elegível;
- executed_at da última execução da fonte;
- data de publicação/cutoff do target;
- evento externo.

Não permitir:

> due date inferida de “agora menos X” sem fonte normativa registrada.

---

# 13. Due, grace e overdue

O OES adota três conceitos distintos.

## 13.1 due_at

Momento em que a execução estava programada.

## 13.2 grace_until

Limite operacional tolerado pela policy sem caracterizar atraso formal.

Grace:

- deve ser explícita;
- não deve ser maior que a própria lógica de cadence de modo a esvaziá-la;
- não muda a janela de cobertura.

## 13.3 overdue

Estado operacional quando:

> current time > grace_until

e a obrigação ainda não foi satisfeita.

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

# 16. Pausa operacional

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

# 17. Exceção temporal

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

---

# 18. Thresholds temporais

O OES não adotará um único “prazo máximo”.

Threshold temporal é uma regra que transforma diferença temporal em estado operacional.

Classes:

## 18.1 threshold de due

Determina quando obrigação nasce.

## 18.2 threshold de grace

Determina tolerância operacional explícita.

## 18.3 threshold de overdue escalation

Determina quando atraso exige escalonamento adicional.

## 18.4 threshold de stale policy/profile

Determina quando policy/profile precisa de reassessment mesmo sem signal científico.

## 18.5 threshold de unresolved signal

Pertence ao bloco de SLA:

> tempo máximo aceitável sem triagem/materiality/decision.

Não será definido numericamente neste documento.

---

# 19. Classes qualitativas de atraso

Antes de números, o OES reconhece estados semânticos:

### on_schedule

Obrigação ainda não venceu ou foi cumprida até grace.

### overdue

Grace vencida; execução/obrigação pendente.

### materially_overdue

Atraso ultrapassou threshold de escalation definido pela policy.

### suspended_by_authority

Relógio explicitamente pausado por decisão válida.

### not_applicable

Não existe obrigação temporal para aquele objeto/regra.

Esses estados são operacionais.

Não equivalem a currentness.

---

# 20. Materially overdue

`materially_overdue` significa:

> atraso operacional suficientemente importante para exigir escalonamento.

Não significa:

> material_change_confirmed.

A palavra “materially” aqui é operacional.

Para evitar ambiguidade em contrato físico futuro, nome recomendado:

> `escalation_overdue`

e não `materially_overdue`.

---

# 21. Reassessment de cadence

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

---

# 22. Cadence × M0

M0:

- cadence_mode = none;
- não há obrigação periódica de surveillance;
- demandas/eventos externos podem iniciar reassessment extraordinário;
- ausência de surveillance ativa deve ser transparente.

---

# 23. Cadence × M1

M1:

- event_driven, periodic ou hybrid;
- Monitor governante não é exigido pelo contrato 027;
- periodicidade, se houver, deve ser explícita;
- event-driven deve identificar fontes/classes de evento.

M1 não promete vigilância contínua.

---

# 24. Cadence × M2

M2:

- periodic ou hybrid;
- Monitor governante obrigatório;
- ciclo prospectivo deve ser definível antes da execução;
- coverage windows devem permanecer contínuas ou ter exceção documentada;
- overdue deve ser rastreável separadamente de gap.

M2 pode possuir fonte event-driven adicional.

---

# 25. Cadence × M3

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

# 26. Event-driven surveillance

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

---

# 27. Cadence e automação

Automação pode:

- calcular next_due_at;
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

# 28. Signal temporal

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

# 29. Cadence_due × materiality

Um cadence_due pode levar a:

- no_material_change;
- potentially_material;
- validity_or_use_threat;
- insufficient_to_decide.

Não pode, sozinho:

> material_change_confirmed.

Essa restrição já está implementada na migration 027 para signal operacional.

---

# 30. Threshold temporal × currentness

Atraso poderá sustentar `under_evaluation` somente quando:

1. atraso/gap foi formalmente identificado;
2. houve UpdateSignal quando necessário;
3. MaterialityAssessment concluiu que a lacuna ameaça sustentação de currentness;
4. UpdateDecision autoritativa aplicou a ação correspondente.

Nunca:

> `overdue → outdated` diretamente.

---

# 31. Threshold temporal × Alert

Alert urgency e cadence são independentes.

- Alert urgent pode exigir resposta imediata mesmo se ciclo periódico não estiver devido;
- cadence overdue pode não justificar Alert;
- Alert critical não redefine automaticamente periodicidade futura.

Depois da resolução:

> o evento pode justificar reassessment da cadence/policy.

---

# 32. Threshold temporal × MethodDecision

`investigation.method_decision` continua sendo registro de exceções metodológicas/temporais específicas do Monitor.

`maintenance.update_decision` continua sendo decisão de atualização/currentness.

Exemplo:

- MethodDecision pode aceitar uma Search fora da janela por razão metodológica válida;
- UpdateDecision pode decidir se a lacuna/atraso afeta currentness.

As duas decisões:

> são complementares, não substitutas.

---

# 33. Re-baselining temporal

Quando nova ProductVersion/InvestigationVersion se torna target:

- policy antiga permanece histórica;
- nova policy precisa de referência temporal própria;
- Monitor ligado à versão anterior não é retargeteado silenciosamente;
- coverage baseline deve ser explicitamente definido;
- carry-forward de cadence precisa de decisão explícita.

Não usar completed_at da versão anterior como referência automática sem regra.

---

# 34. Métricas operacionais candidatas

Podem ser calculadas futuramente:

- planned_due_at;
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

# 35. Referências metodológicas orientadoras

A arquitetura foi confrontada com princípios atuais:

1. Cochrane Handbook, Chapter 22 — living systematic reviews usam vigilância frequente e devem explicitar métodos de busca e frequência de atualização prospectivamente;
2. Cochrane Handbook, Chapter IV — living updating é apropriado sobretudo quando a pergunta é importante, nova evidência é frequente e pode impactar achados, com necessidade de recursos;
3. NICE PMG49 (2025) — surveillance deve ser proporcional e direcionada, combinando reactive monitoring, tracking prospectivo e revisões planejadas;
4. WHO living-guidelines approach — combina continuous surveillance com atualização rápida das sínteses/recomendações priorizadas.

Essas fontes não autorizam um intervalo universal no OES.

---

# 36. Implicações para futuro contrato físico

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

# 37. Testes conceituais obrigatórios antes de migration

1. ciclo atrasado + cobertura completa ≠ gap;
2. ciclo pontual + janela incompleta = gap;
3. source latency > cadence não cria falsa atualidade;
4. M1 event-driven sem periodic funciona;
5. M2 periodic exige regra prospectiva;
6. M2 hybrid aceita evento antes do due;
7. M3 policy não remove blocker;
8. overdue não altera currentness;
9. gap não altera currentness sem assessment;
10. cadence_due operacional não confirma material change;
11. policy reassessment é relógio distinto;
12. pause não apaga coverage debt;
13. MethodDecision temporal exception não substitui UpdateDecision;
14. supersessão de policy recalcula referência prospectivamente;
15. no universal default é inferido por M.

---

# 38. Próximo passo exato

> **Executar revisão adversarial da Política Transversal de Cadence e Thresholds Temporais. Somente após PASS/PASS_WITH_ARCHITECTURAL_DECISIONS definir os relógios/classes de SLA.**
