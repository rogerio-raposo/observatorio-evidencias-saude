# 20 — Arquitetura Transversal de SLA do Protocolo de Atualização

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — aprovado após Documento 21**  
**Dependências:** Documentos 05–09 e 16–21; migrations 002, 014, 021–027

---

## 1. Finalidade

Definir a arquitetura transversal de Service Level Agreements — SLAs — para o protocolo de atualização do OES.

O SLA neste contexto representa:

> **obrigação operacional explícita entre dois eventos auditáveis.**

O SLA não representa:

- verdade científica;
- materialidade;
- currentness;
- assurance;
- prioridade científica por si só;
- decisão de publicação;
- garantia de que a evidência não mudou.

Este documento define:

- seis relógios mínimos;
- eventos de início e fim;
- aplicabilidade;
- regra de origem temporal;
- política de pausa;
- breach;
- escalation;
- supersessão/rebase;
- relação com Alert, Monitor, risco e currentness;
- fronteira de automação.

Não define:

- durações universais;
- scheduler;
- canais de notificação;
- score global de prioridade;
- migration 028;
- auto-currentness;
- auto-publication;
- M3 readiness.

---

# 2. Princípio central

> **SLA mede desempenho/obrigação operacional; não mede estado científico.**

Consequências:

1. SLA breach não produz `outdated`;
2. SLA cumprido não produz `current`;
3. SLA urgente não confirma materiality;
4. SLA vencido pode exigir escalation;
5. currentness continua dependente de:
   `UpdateSignal → MaterialityAssessment → UpdateDecision`;
6. uma decisão científica pode existir mesmo após breach operacional;
7. o breach permanece auditável depois de resolução tardia.

---

# 3. SLA × cadence

Cadence responde:

> quando executar vigilância/reassessment?

SLA responde:

> depois que um evento relevante ocorreu, até quando uma obrigação operacional deve atingir outro evento?

Exemplo:

- cadence mensal define quando um ciclo é esperado;
- após detectar um signal, SLA-1 define o intervalo para triagem;
- após uma decisão de atualizar, SLA-4 define o intervalo para início do workflow científico.

Nunca reutilizar:

- `planned_at` do Monitor como deadline de triagem;
- cadence due como deadline de UpdateDecision;
- SLA breach como coverage gap.

---

# 4. Quatro objetos conceituais

## 4.1 SLA Rule

Regra prospectiva que define:

- clock_code;
- evento de início;
- evento de fim;
- aplicabilidade;
- basis temporal;
- política de pausa;
- política de escalation;
- inputs de criticidade/risco/prioridade;
- duração ou deadline quando futuramente parametrizada;
- vigência;
- rationale;
- autoridade.

## 4.2 SLA Instance

Instância concreta criada quando o evento de início ocorre.

Deve congelar:

> **a regra de SLA efetivamente aplicável naquele instante.**

Mudança posterior de policy não recalcula silenciosamente a obrigação.

## 4.3 SLA Pause Interval

Intervalo autorizado em que o relógio de serviço pode deixar de acumular tempo, se e somente se a regra permitir.

O tempo de parede continua sendo medido.

## 4.4 SLA Incident / Escalation

Registro append-preserving de:

- breach;
- warning/escalation;
- resolução;
- escalonamento humano/operacional.

Não altera a história do relógio.

---

# 5. Seis relógios mínimos

| Clock | Início | Fim | Finalidade |
|---|---|---|---|
| SLA-1 | detecção OES do signal elegível | triagem concluída | limitar atraso até primeira disposição operacional |
| SLA-2 | triagem aceita para avaliação | MaterialityAssessment qualificante concluído | limitar atraso de avaliação de materialidade |
| SLA-3 | materialidade qualificante concluída | UpdateDecision autoritativa | limitar atraso decisório |
| SLA-4 | UpdateDecision que exige workflow | workflow científico iniciado | limitar atraso para mobilizar atualização |
| SLA-5 | workflow científico iniciado | atualização científica concluída | limitar duração operacional do trabalho científico |
| SLA-6 | conclusão científica | revisão/governance disposition ou publicação, conforme regra | limitar atraso pós-ciência |

Cada relógio possui:

- evento inicial próprio;
- evento terminal próprio;
- política de aplicabilidade própria.

Nenhum clock deve inferir seu início a partir do relógio anterior quando o evento real estiver disponível.

---

# 6. SLA-1 — detecção → triagem

## 6.1 Início

O relógio inicia no primeiro instante auditável em que o OES recebeu/identificou o evento que deu origem ao UpdateSignal.

Regra:

> **normalização tardia não reinicia o relógio.**

### Origem temporal preferencial

Quando houver source rastreável:

- EvidenceAlert → `evidence_alert.detected_at`;
- EvidenceEvent → `evidence_event.detected_at`;
- SearchHit → `search_hit.imported_at`;
- CandidateAssessment originado em EvidenceEvent → `evidence_event.detected_at`;
- CandidateAssessment originado em SearchHit → `search_hit.imported_at`;
- signal direto sem timestamp upstream apropriado → `update_signal.detected_at`.

Não usar como início de SLA por default:

- data de publicação do estudo;
- `event_date` externo;
- `signal_date`;
- `search.executed_at` quando a identificação concreta só é demonstrada por `search_hit.imported_at`.

Essas datas podem medir latência da fonte/detecção, não tempo de serviço interno.

## 6.2 Fim

Triage concluída deve produzir disposição explícita:

- accepted_for_materiality;
- duplicate_or_already_covered;
- invalid_signal;
- out_of_scope;
- routed_elsewhere.

A disposição precisa cumprir uma regra de autoridade.

Baseline conceitual:

- IA/sistema pode classificar/sugerir triage;
- disposição que apenas encaminha para avaliação pode ser automatizável futuramente;
- IA/sistema **não deve encerrar autoritativamente um signal científico/currentness como invalid_signal ou out_of_scope** quando esse encerramento evitaria avaliação humana material;
- duplicate_or_already_covered exige linkage auditável ao objeto já coberto;
- routed_elsewhere exige destino/rationale.

A arquitetura atual não possui registro transversal de triage do UpdateSignal.

Portanto:

> **triage é um gap físico conhecido para contrato posterior.**

Não inferir triagem concluída apenas porque existe Alert lifecycle `triage`.

## 6.3 Efeito

- accepted_for_materiality → abre SLA-2;
- invalid/duplicate/out_of_scope → SLA-2 pode ser not_applicable;
- invalidation do signal deve preservar a conclusão de SLA-1.

---

# 7. SLA-2 — triagem → MaterialityAssessment

## 7.1 Início

Evento:

> triage aceita o signal para avaliação de materialidade.

## 7.2 Fim

MaterialityAssessment **qualificante** concluído.

Um assessment é qualificante quando satisfaz o grau de verificação exigido pela SLA Rule.

Default arquitetural:

- assessment AI-only pode ser milestone intermediário;
- para cadeia que poderá produzir UpdateDecision autoritativa, o SLA-2 não deve ser considerado concluído por assessment AI-only;
- `human_verified` ou `human_consensus` é o baseline para materialidade pronta para decisão autoritativa.

Isso preserva:

> IA pode auxiliar, mas não encerrar autoritativamente a avaliação científica.

## 7.3 Timestamp qualificante

`materiality_assessment.assessed_at` registra quando o assessment foi realizado.

Quando a qualificação exige verificação humana e `verified_at > assessed_at`:

> **o SLA-2 termina em `verified_at`, não em `assessed_at`.**

Conceitualmente:

```text
materiality_qualified_at =
  max(assessed_at, verified_at)
```

para assessments que exigem verificação.

Isso impede contabilizar como concluído um assessment que ainda não possuía a verificação necessária.

Implementação futura deverá preservar também:

- occurred_at/assessed_at;
- verified_at;
- recorded_at.

Atraso de documentação deve permanecer detectável.

---

# 8. SLA-3 — MaterialityAssessment → UpdateDecision

## 8.1 Início

`materiality_qualified_at` do MaterialityAssessment qualificante.

## 8.2 Fim

UpdateDecision:

- `authority_status='authoritative'`;
- human-verified/human-consensus;
- coerente com o assessment ativo.

Proposal:

> **não encerra SLA-3.**

Quando `verified_at > decided_at`:

> **o SLA-3 termina na qualificação autoritativa, isto é, em `max(decided_at, verified_at)`.**

Conceitualmente:

```text
decision_qualified_at =
  max(decided_at, verified_at)
```

Isso impede que uma decisão ainda não humanamente verificada satisfaça o relógio.

Motivo:

uma proposal de IA ou humano ainda não constitui decisão operacional autoritativa.

## 8.3 Terminalidade

Se o UpdateSignal for formalmente invalidado antes da decisão:

- SLA-3 pode terminar como `cancelled_invalidated`;
- isso não conta como `satisfied`;
- rationale e autoridade de cancelamento devem ser preservadas.

MaterialityAssessment, no contrato 027, é corrigido por supersessão, não por invalidation.

Se um assessment for superseded antes da UpdateDecision:

- o clock não é automaticamente cancelado;
- deve continuar a partir do novo assessment qualificante da mesma cadeia;
- a troca precisa preservar tempo já decorrido e não reiniciar silenciosamente SLA-3.

---

# 9. SLA-4 — UpdateDecision → início do workflow científico

## 9.1 Aplicabilidade

Aplica-se quando a UpdateDecision autoritativa cria obrigação explícita de trabalho científico subsequente.

Casos naturais:

- `scientific_update_incremental`;
- `scientific_update_broad`.

`reroute_method` pode abrir workflow metodológico correlato, mas:

> não deve ser automaticamente tratado como scientific update sem registro explícito.

`no_scientific_update`, `observe` e `currentness_only`:

> SLA-4 = not_applicable por default.

`suspend_current_use` exige disposição operacional urgente, mas não prova que um workflow científico foi aberto; sua aplicabilidade a SLA-4 deve ser explícita.

## 9.2 Início

`decision_qualified_at` da UpdateDecision autoritativa.

Não usar `decided_at` isoladamente quando a verificação humana qualificante ocorreu depois.

## 9.3 Fim

Evento explícito:

> scientific_workflow_started.

Não inferir início apenas por:

- criação de ticket;
- criação de draft;
- abertura automática de branch;
- proposta de IA.

O evento deve representar que o trabalho científico governado realmente começou.

## 9.4 Gap físico

Ainda não existe um evento transversal único para início de workflow científico entre todos os produtos.

Logo:

> **SLA-4 não é fisicamente implementável de forma transversal sem contrato adicional.**

---

# 10. SLA-5 — início → conclusão da atualização científica

## 10.1 Início

`scientific_workflow_started`.

## 10.2 Fim

`scientific_workflow_completed`:

> conteúdo científico da atualização atingiu estado completo para entrar em revisão/governance gate.

Não significa:

- aprovado;
- publicado;
- assurance promovido.

## 10.3 Versionamento

A conclusão científica normalmente deverá ser rastreável à futura:

- ProductVersion; ou
- InvestigationVersion;

quando a atualização resultar em mudança material.

SLA-5 não cria a versão automaticamente.

## 10.4 Gap físico

Não existe hoje um milestone transversal padronizado de workflow científico iniciado/concluído para todos os tipos de produto.

Portanto:

> implementar SLA-5 exige primeiro normalizar esses milestones ou definir adaptadores por workflow.

---

# 11. SLA-6 — conclusão científica → revisão/publicação

## 11.1 Finalidade

Medir atraso entre conclusão científica e disposição formal.

## 11.2 Início

`scientific_workflow_completed`.

## 11.3 Endpoint declarado pela regra

A SLA Rule deve escolher explicitamente um endpoint:

### review_disposition

Termina quando ocorre decisão formal de revisão/governança aplicável:

- approved;
- revise;
- rejected;
- outra disposição normativamente definida para aquele round.

`revise` satisfaz o clock de **tempo até disposição de revisão daquele round**, mas não significa conclusão do processo de publicação.

Se `revise` abrir novo trabalho científico:

> deve nascer novo workflow/review round com novas instâncias SLA-4/5/6 conforme aplicabilidade.

### publication

Termina quando a versão elegível é formalmente publicada/emitida.

Para rule cujo endpoint é `publication`:

- `revise` não encerra SLA-6;
- `rejected` deve produzir terminalidade explícita não-satisfied/terminated, conforme governança;
- aprovação intermediária não substitui publicação.

Não presumir que aprovação e publicação são o mesmo instante.

## 11.4 Aplicabilidade

Se determinado fluxo não possui publicação formal:

> endpoint = review_disposition ou not_applicable, conforme o produto.

A regra não pode trocar endpoint depois que a instância iniciou sem rebase explícito.

---

# 12. Origem temporal: occurred_at × qualified_at × recorded_at

Milestones futuros de SLA deverão distinguir, quando aplicável:

### occurred_at

Quando o evento substantivo ocorreu.

### qualified_at

Quando o evento passou a satisfazer requisitos de autoridade/verificação necessários para encerrar/iniciar determinado clock.

### recorded_at

Quando o evento foi persistido no OES.

Regras:

1. `recorded_at >= occurred_at`;
2. `qualified_at >= occurred_at` quando existir etapa posterior de verificação/autoridade;
3. backdating sem fonte/rationale não é permitido;
4. SLA usa o timestamp semanticamente exigido pelo clock:
   - occurred_at quando ocorrência basta;
   - qualified_at quando autoridade/verificação faz parte do endpoint;
5. atraso entre occurred_at e recorded_at permanece auditável como documentation latency;
6. created_at genérico não substitui automaticamente occurred_at;
7. estruturas legadas que não possuem `recorded_at` separado usam o melhor timestamp canônico existente, sem fabricar retroativamente documentation latency.

Isso reduz possibilidade de “melhorar” SLA apenas registrando eventos tarde com timestamps convenientes.

---

# 13. Regra de origem mais antiga auditável

Para SLA-1:

> usar o primeiro timestamp auditável de conhecimento/detecção pelo OES dentro da cadeia causal do signal.

Não usar o menor timestamp indiscriminadamente.

Exemplo:

- estudo publicado em D0;
- indexado em D5;
- importado pelo OES em D8;
- UpdateSignal criado em D9.

Início de SLA-1:

> D8, não D0 e não D9.

D0→D8 pertence a source availability/detection latency.

D8→triage pertence ao SLA operacional.

---

# 14. Rule snapshot, vigência e não retroatividade

## 14.1 Evento anterior à vigência da regra

Pode ocorrer:

- evento detectado em D0;
- SLA Rule/UpdatePolicy passa a vigorar em D2;
- signal é normalizado em D3.

O OES deve preservar:

- `source_detected_at = D0`;
- `pre_policy_age = D0 → D2`;
- `sla_start_at = D2`, se a obrigação passou a existir em D2 e o caso já era elegível.

Regra:

> **não criar breach retroativo por período anterior à obrigação normativa, mas também não apagar a idade pré-policy do evento.**

Se a rule exigir ato de aceitação posterior para tornar o caso elegível:

> `sla_start_at` será o primeiro instante em que rule vigente + eligibility estiverem simultaneamente satisfeitos.

Esse caso deve ser distinguível de late normalization sob policy já vigente.

## 14.2 Snapshot

Quando um SLA Instance nasce, deve congelar:

- SLA Rule/version;
- target;
- clock code;
- duration/deadline rule;
- calendar basis e calendar version;
- pause policy;
- escalation policy;
- priority/risk inputs usados na resolução.

Mudança posterior de:

- UpdatePolicy;
- risk profile;
- priority;
- SLA Rule;
- target version;

não altera retroativamente a instância.

Rebase só pode ocorrer por decisão explícita e deve preservar:

- regra original;
- due original;
- breach original;
- nova regra;
- rationale;
- ator;
- timestamp.

---

# 15. Basis temporal e deadlines

Uma SLA Rule futura deverá declarar uma basis.

## 15.1 elapsed_time

Tempo corrido absoluto.

Adequado quando:

- safety/integrity exige resposta contínua;
- fins de semana/feriados não devem suspender obrigação.

## 15.2 business_calendar

Tempo calculado segundo calendário operacional explícito.

Exige:

- timezone;
- dias úteis;
- janelas horárias;
- feriados/calendário versionado;
- snapshot da versão do calendário usada pela SLA Instance.

Não permitir “dias úteis” sem calendário identificado.

## 15.3 fixed_deadline

Deadline absoluto conhecido externamente.

Exemplos possíveis:

- obrigação regulatória;
- reunião decisória;
- data de guideline.

Deve preservar origem normativa do deadline.

## 15.4 nominal_due_at × effective_due_at

Quando a regra possuir duração/deadline:

### nominal_due_at

Deadline calculado sem pausas posteriores, segundo a rule snapshot original.

### effective_due_at

Deadline operacional após considerar apenas:

- business calendar declarado;
- pausas válidas e autorizadas quando a regra permitir suspensão.

Regras:

- `nominal_due_at` nunca é sobrescrito;
- `effective_due_at` precisa ser reconstruível pelo ledger de pausas/calendário;
- `fixed_deadline` é não-pausável por default;
- qualquer fixed deadline suspensível exige autorização normativa explícita;
- rebase não deve mascarar nominal_due_at nem breach histórico.

---

# 16. Pause semantics

Pause é exceção controlada.

Não é equivalente a:

- backlog;
- falta de pessoal;
- fim de semana;
- baixa prioridade;
- espera não documentada.

## 16.1 Condições candidatas válidas

Pause só existe se a SLA Rule declarar `pause_allowed=true`.

Dependendo do clock e da rule:

- informação externa indispensável indisponível;
- embargo/regra externa formal;
- dependência científica bloqueante explicitamente identificada;
- suspensão formal por autoridade;
- impossibilidade operacional extraordinária documentada.

## 16.2 Condições não válidas por default

- fila interna;
- férias previstas;
- carga alta;
- equipe reduzida;
- “aguardando tempo para revisar”;
- demora causada pelo próprio fluxo não documentada.

Capacidade insuficiente deve aparecer como:

> problema de feasibility/escalation, não pausa automática.

## 16.3 Restrições de segurança/integridade

Uma rule associada a safety/integrity de alta criticidade pode ser declarada:

> **non_pausable**

ou permitir somente razão externa/normativa muito específica.

Carga/capacidade interna nunca deve transformar automaticamente clock de safety em pausável.

## 16.4 Pause interval

Cada pausa precisa de:

- reason_code;
- rationale;
- authorized_by;
- authorized_at;
- started_at;
- ended_at ou estado aberto;
- clock(s) afetados;
- recorded_at.

Regra anti-gaming:

- pausa deve ser autorizada prospectivamente ou sustentada por evento externo independente com timestamp auditável;
- documentação tardia de uma pausa pode ser registrada, mas não deve apagar automaticamente breach já observado;
- correção retroativa de compliance exige revisão explícita e trilha de auditoria;
- pausa iniciada **após** `first_breached_at` não altera o fato nem o instante do primeiro breach;
- pause pós-breach pode afetar somente obrigações/escalations posteriores quando a rule permitir.

Pausa não apaga:

- wall-clock age;
- breach ocorrido antes da pausa;
- incident/escalation prévia.

---

# 17. Dois tempos devem coexistir

Para cada SLA Instance:

### wall_elapsed

Tempo real entre start e agora/end.

### accountable_elapsed

Tempo computável segundo:

- basis;
- pausas válidas;
- calendário.

Ambos devem permanecer consultáveis.

Motivo:

> uma obrigação pode estar “dentro do SLA ajustado” e ainda assim ter idade total operacionalmente relevante.

---

# 18. Estado operacional × estado de compliance

Um único campo de estado seria insuficiente.

Exemplo:

> uma instância pode estar pausada **e já ter sofrido breach antes da pausa**.

Portanto o modelo deve separar dois eixos.

## 18.1 execution_status

- pending;
- running;
- paused;
- satisfied;
- cancelled_invalidated;
- terminated_by_authority;
- not_applicable.

## 18.2 compliance_status

- not_started;
- within_target;
- breached_open;
- breached_then_satisfied;
- satisfied_on_time;
- not_applicable.

Regras:

- pause altera execution_status, não apaga compliance_status;
- satisfied depois de breach produz `breached_then_satisfied`;
- breach ocorrido permanece histórico;
- cancelled/terminated também precisam preservar se breach havia ocorrido antes.

Evitar:

> boolean `breached=true/false` como única representação.

---

# 19. Breach

Breach ocorre quando:

> accountable time/deadline excede a regra congelada sem milestone terminal qualificante.

Ao primeiro breach:

- registrar `first_breached_at`;
- preservar rule snapshot;
- abrir incidente/escalation conforme policy;
- não alterar currentness;
- não alterar materiality;
- não promover Alert;
- não iniciar update científico automaticamente.

Se o endpoint ocorrer depois:

> estado = `breached_then_satisfied`.

Nunca reclassificar retrospectivamente como `satisfied_on_time`.

---

# 20. Escalation

Escalation é resposta operacional ao risco de atraso/breach.

Pode ser acionada:

- antes do breach, como warning;
- no breach;
- após tempo adicional de breach;
- imediatamente por regra de safety/integrity.

Escalation pode:

- aumentar visibilidade;
- solicitar revisão humana;
- solicitar capacidade;
- escalar owner/governance;
- recomendar mudança de prioridade.

Escalation não pode, sozinha:

- mudar CurrencyState;
- declarar materiality;
- promover assurance;
- criar publicação;
- classificar Alert como critical;
- ativar M3.

---

# 21. Relação com risco

Inputs possíveis na resolução futura da SLA Rule:

- A1 criticidade;
- A3 sensibilidade;
- A4 exposição a safety/integrity;
- A5 dependency reach;
- B1 observabilidade;
- B2 latência;
- B3 carga;
- B4 custo;
- B5 capacidade;
- signal_class;
- signal_type;
- materiality outcome;
- decision_type;
- currentness vigente.

Regras:

- criticidade alta pode justificar obrigação mais estrita;
- safety/integrity pode dominar o tempo de resposta;
- capacidade baixa não alonga silenciosamente o SLA;
- se a obrigação necessária não é factível, registrar conflito de capacidade/governança.

Nenhuma fórmula numérica global é definida neste documento.

---

# 22. Relação com Alert

Evidence Alert possui hoje:

- `classification = informational|relevant|critical`;
- `reassessment_priority = routine|priority|urgent`.

O contrato do Alert explicitamente não embute duração temporal nesses valores.

A Fase 4 preserva isso.

Regras:

1. Alert `urgent` pode ser input para resolução de SLA;
2. Alert `critical` pode acionar regra de dominância safety/integrity;
3. nenhum deles define número universal;
4. UpdateSignal derivado de Alert usa a origem temporal auditável do Alert para SLA-1;
5. Alert lifecycle `triage` não é automaticamente o milestone transversal de triage do UpdateSignal;
6. Alert não muda currentness automaticamente.

---

# 23. Relação com Monitor

Monitor pode fornecer:

- EvidenceEvent.detected_at;
- SearchHit.imported_at;
- CandidateAssessment.assessed_at;
- MonitoringCycle timestamps.

Regras:

- SLA-1 usa a detecção/identificação upstream apropriada quando o Monitor é source;
- CandidateAssessment não substitui MaterialityAssessment;
- Monitor maintenance_decision não substitui UpdateDecision;
- atraso do MonitoringCycle continua pertencendo à política de cadence;
- atraso após signal pertence aos clocks de SLA.

---

# 24. Concurrency, ciclos e cardinalidade

Clocks não precisam ser estritamente sequenciais em tempo real.

Exemplo:

- triage e início da materiality assessment podem ocorrer quase simultaneamente;
- uma equipe pode preparar workflow enquanto decisão formal está em finalização.

Entretanto:

> um clock só termina quando seu milestone qualificante ocorre.

Preparação antecipada não permite declarar satisfação de SLA-4 antes de UpdateDecision autoritativa se a rule exigir essa decisão como start.

Duração zero é válida quando start/end realmente coincidem e são auditáveis.

Uma mesma cadeia de atualização pode produzir múltiplas instâncias de certos clocks.

Exemplos:

- revisão solicita alterações → novo ciclo de trabalho científico;
- nova disposição formal → novo round de review;
- workflow é reiniciado de forma auditável após término anterior.

Logo:

- SLA-4/5/6 não devem ser modelados como uma única linha global por UpdateSignal;
- cada instância precisa de identidade causal de workflow/review round;
- uma nova instância não apaga o desempenho da anterior.

---

# 25. Invalidation, supersession e target change

## 25.1 Signal invalidado

Clocks abertos podem terminar como:

`cancelled_invalidated`.

Histórico permanece.

## 25.2 Assessment superseded

SLA-2 associado ao assessment anterior não é apagado.

SLA-3 deve usar o assessment qualificante vigente conforme a cadeia causal.

Se supersessão ocorrer após decisão:

> abrir issue de coerência/impacto; não reescrever história.

## 25.3 Target superseded

Target científico superseded não transfere SLA automaticamente para nova versão.

É necessário:

- encerrar/reavaliar obrigação antiga;
- abrir/rebasear explicitamente obrigação na nova versão quando aplicável.

---

# 26. Rebase

Rebase de SLA é permitido somente quando:

- escopo/target muda legitimamente;
- regra normativa muda;
- erro de configuração é corrigido;
- autoridade explicitamente determina nova base.

Deve preservar:

- original_start_at;
- original_due_at;
- original_rule;
- original_breach;
- rebase_at;
- rebase_reason;
- rebase_authority;
- new_due_at/new_rule.

Proibido:

> rebase apenas para apagar breach.

---

# 27. Relação com currentness

SLA e currentness são ortogonais.

Exemplos:

### breached + current

Possível quando atraso operacional ocorreu, mas avaliação científica posterior conclui ausência de mudança material.

### on-time + outdated

Possível quando processo foi rápido e concluiu que a versão não deve ser tratada como atual.

### breached + under_evaluation

Possível quando avaliação está atrasada e existe signal aceito.

### on-time + update_recommended

Possível quando materialidade foi avaliada tempestivamente e atualização foi recomendada.

Não derivar um eixo do outro.

---

# 28. Relação com prioridade

Prioridade influencia SLA Rule selection, mas não é SLA.

O futuro bloco de prioridade deverá considerar:

- safety/integrity;
- criticidade;
- materiality;
- currentness;
- dependency reach;
- atraso/breach;
- capacidade.

Circularidade proibida:

> priority não pode ser definida apenas por SLA, enquanto SLA é definido apenas por priority.

É necessário um conjunto de inputs independentes e regra de precedência explícita.

---

# 29. Fronteira de automação

Automação pode:

- calcular due_at;
- calcular wall/accountable elapsed;
- detectar warning;
- detectar breach;
- abrir incidente operacional;
- notificar responsáveis;
- sugerir escalation;
- calcular métricas.

Automação não pode, apenas por SLA:

- criar MaterialityAssessment autoritativo;
- criar UpdateDecision autoritativa;
- alterar CurrencyState;
- promover assurance;
- declarar human verification;
- publicar;
- ativar M3;
- mudar conclusão científica.

---

# 30. Métricas permitidas

Métricas operacionais futuras podem incluir:

- median time-to-triage;
- median time-to-materiality;
- median time-to-decision;
- time-to-workflow-start;
- scientific workflow duration;
- time-to-governance disposition;
- breach rate;
- breached_then_satisfied rate;
- pause duration;
- documentation latency;
- wall_elapsed versus accountable_elapsed.

Essas métricas:

> avaliam desempenho operacional, não qualidade científica por si só.

---

# 31. Gaps físicos antes de implementação

Migration 027 já fornece:

- UpdateSignal.detected_at;
- MaterialityAssessment.assessed_at;
- UpdateDecision.decided_at.

Ainda faltam de forma transversal:

1. triage milestone do UpdateSignal;
2. SLA Rule/version;
3. SLA Instance;
4. pause ledger;
5. breach/escalation incident;
6. workflow started milestone;
7. workflow completed milestone;
8. review/publication endpoint normalizado entre produtos;
9. rule snapshot/rebase;
10. occurred_at × qualified_at × recorded_at para milestones novos;
11. identidade causal de workflow/review round;
12. nominal_due_at × effective_due_at;
13. policy/rule eligibility timestamp;
14. pre_policy_age auditável.

Portanto:

> **não autorizar migration 028 neste documento.**

---

# 32. Estratégia futura de contrato físico

Uma futura modelagem deverá preferir:

- estruturas genéricas de SLA apenas para semântica operacional comum;
- adaptadores explícitos para milestones de produtos/workflows;
- FKs reais sempre que o milestone já tiver entidade física canônica;
- ausência de UUID polimórfico opaco sem guard;
- append-preserving para breach/pause/rebase;
- issues helpers read-only;
- nenhuma FK que force objetos operacionais a se tornarem EntityVersion.

---

# 33. Referências metodológicas orientadoras

A arquitetura foi confrontada com princípios de atualização/surveillance:

1. **Cochrane Handbook, Chapter 22 — Prospective approaches to accumulating evidence.**  
   Reforça surveillance ativa, priorização de updates e explicitação prospectiva da frequência em living reviews.

2. **NICE PMG49 — Processes and methods for NICE-wide guidance surveillance (2025).**  
   Adota surveillance proporcional/targeted, reactive monitoring, tracking prospectivo e revisões planejadas conforme necessidade.

3. **WHO — living guidelines approach.**  
   Combina surveillance contínua, priorização de updates e incorporação rápida quando nova evidência relevante justifica mudança.

Essas referências sustentam proporcionalidade e transparência.

> **Nenhum exemplo externo de prazo é convertido em SLA universal do OES.**

---

# 34. Gate obrigatório antes de persistência física

A revisão adversarial deverá testar:

- SLA × cadence;
- origem temporal upstream;
- late normalization;
- evento anterior à vigência da SLA Rule;
- pre-policy age × SLA contractual time;
- triage gap;
- AI proposal × authoritative endpoint;
- pause gaming;
- pausa documentada retroativamente;
- pausa iniciada depois do breach;
- wall time × accountable time;
- nominal_due_at × effective_due_at;
- business calendar;
- paused + already breached;
- qualification timestamp após human verification;
- breach history;
- rebase;
- Alert urgency/classification;
- Monitor timestamps;
- currentness independence;
- target supersession;
- workflow milestone gaps;
- applicability de SLA-4/5/6;
- review_disposition revise × publication endpoint;
- múltiplos workflow/review rounds;
- circularidade prioridade ↔ SLA;
- fronteira de automação;
- compatibilidade com migration 027.

Resultados permitidos:

- PASS;
- PASS_WITH_ARCHITECTURAL_DECISIONS;
- REVISE;
- NOT_READY.

---

# 35. Próximo passo exato

> **Definir a arquitetura transversal de prioridade e escalation antes de qualquer migration 028, preservando a independência entre prioridade, SLA compliance e currentness.**
