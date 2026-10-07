# 21 — Revisão Adversarial da Arquitetura Transversal de SLA

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS**  
**Objeto:** Documento 20 pós-hardening  
**Dependências:** Documentos 05–09 e 16–20; migrations 002, 014, 021–027

---

## 1. Finalidade

Executar revisão adversarial da arquitetura transversal de SLA antes de:

- definir prioridade global;
- fixar durações;
- criar contrato físico;
- criar migration 028;
- automatizar escalation.

O gate verifica se os relógios podem ser usados sem:

- confundir SLA com cadence;
- apagar atraso por normalização tardia;
- permitir IA encerrar autoridade científica;
- manipular pausa/rebase;
- perder breach histórico;
- transformar breach em currentness;
- conflitar com Alert/Monitor;
- criar circularidade SLA × prioridade.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Estados:

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_PRIORITY_ARCHITECTURE**

> **NOT_READY_FOR_MIGRATION_028**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

A semântica dos seis relógios está aprovada.

A persistência física deve esperar:

1. arquitetura de prioridade;
2. definição do milestone transversal de triage;
3. definição/adaptação dos milestones de workflow científico;
4. novo gate físico.

---

## 3. AR-F4-S01 — SLA × cadence

### Risco

Reutilizar cadence como prazo de resposta.

### Decisão

Cadence determina quando vigiar/reavaliar.

SLA determina intervalo entre eventos operacionais.

Exemplos proibidos:

- `monitor_cycle.planned_at` como prazo de MaterialityAssessment;
- cadence due como deadline de UpdateDecision.

**Resultado:** PASS.

---

## 4. AR-F4-S02 — seis relógios

O modelo separa:

1. detecção → triage;
2. triage → MaterialityAssessment;
3. materiality → UpdateDecision;
4. UpdateDecision → workflow start;
5. workflow start → scientific completion;
6. scientific completion → review/publication endpoint.

Cada relógio possui start/end próprios.

**Resultado:** PASS.

---

## 5. AR-F4-S03 — late normalization

### Teste

- evento detectado em D0;
- UpdateSignal criado em D1.

Usar D1 como SLA start apagaria atraso operacional.

### Decisão

SLA-1 usa a primeira detecção/identificação auditável pelo OES dentro da cadeia causal.

UpdateSignal criado posteriormente não reinicia o clock.

**Resultado:** PASS.

---

## 6. AR-F4-S04 — evento anterior à SLA Rule

### Teste

- evento detectado em D0;
- obrigação de SLA passa a vigorar em D2;
- signal normalizado em D3.

### Decisão

Preservar:

- source_detected_at = D0;
- pre_policy_age = D0→D2;
- SLA contractual time inicia quando rule vigente + eligibility coexistem.

Não criar breach retroativo por período em que não havia obrigação normativa.

Não apagar idade pré-policy.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 7. AR-F4-S05 — fonte temporal upstream

Mapeamentos aceitos como baseline:

- Alert → `detected_at`;
- EvidenceEvent → `detected_at`;
- SearchHit → `imported_at`;
- CandidateAssessment de EvidenceEvent → EvidenceEvent.detected_at;
- CandidateAssessment de SearchHit → SearchHit.imported_at;
- ausência de origem melhor → UpdateSignal.detected_at.

Não usar publication date/event_date como service clock start por default.

**Resultado:** PASS.

---

## 8. AR-F4-S06 — triage físico inexistente

### Achado

Migration 027 não possui registro transversal de triage do UpdateSignal.

Alert lifecycle `triage` não equivale ao milestone transversal.

### Consequência

SLA-1/SLA-2 estão semanticamente definidos, mas não podem ser implementados de forma transversal ainda.

**Resultado:** PASS conceitual / PHYSICAL GAP.

---

## 9. AR-F4-S07 — autoridade de triage

### Risco

IA invalidar/out-of-scope um signal científico e impedir avaliação humana.

### Decisão

- IA/sistema pode sugerir triage;
- encaminhamento para avaliação pode ser automatizável futuramente;
- fechamento autoritativo que suprima avaliação material exige regra de autoridade;
- duplicate precisa apontar para objeto já coberto;
- routed_elsewhere precisa de destino/rationale.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 10. AR-F4-S08 — MaterialityAssessment qualificante

### Risco

Assessment realizado em D0 e verificado humanamente em D1 ser contabilizado como concluído em D0.

### Decisão

Quando verificação é parte do endpoint:

> `materiality_qualified_at = max(assessed_at, verified_at)`

Assessment AI-only não satisfaz o clock destinado à cadeia autoritativa.

**Resultado:** PASS.

---

## 11. AR-F4-S09 — UpdateDecision qualificante

### Risco

Decisão registrada em D0 e humanamente verificada em D1 encerrar SLA-3 em D0.

### Decisão

> `decision_qualified_at = max(decided_at, verified_at)`

Proposal não encerra SLA-3.

SLA-4 inicia no decision_qualified_at quando aplicável.

**Resultado:** PASS.

---

## 12. AR-F4-S10 — assessment superseded

Migration 027 corrige MaterialityAssessment por supersessão.

Se assessment for superseded antes da decisão:

- SLA-3 não reinicia silenciosamente;
- novo assessment qualificante assume a cadeia;
- tempo decorrido permanece.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 13. AR-F4-S11 — occurred × qualified × recorded

Foram separados:

- occurred_at;
- qualified_at;
- recorded_at.

Isso permite distinguir:

- evento científico;
- obtenção de autoridade/verificação;
- latência documental.

Estruturas legadas sem recorded_at separado usarão o melhor timestamp canônico disponível sem inventar retrospectivamente um segundo relógio.

**Resultado:** PASS.

---

## 14. AR-F4-S12 — rule snapshot

Cada SLA Instance congela a rule aplicável no start.

Mudanças posteriores de:

- UpdatePolicy;
- risk profile;
- prioridade;
- SLA Rule;
- target version;

não recalculam silenciosamente a obrigação.

**Resultado:** PASS.

---

## 15. AR-F4-S13 — basis temporal

São semanticamente válidas:

- elapsed_time;
- business_calendar;
- fixed_deadline.

Business calendar exige:

- timezone;
- dias/janelas;
- feriados;
- versão do calendário congelada na instância.

Fixed deadline é não-pausável por default.

**Resultado:** PASS.

---

## 16. AR-F4-S14 — nominal_due × effective_due

### Decisão

Preservar:

- nominal_due_at;
- effective_due_at.

Effective due pode refletir apenas:

- business calendar;
- pausas válidas autorizadas.

Nominal due nunca é sobrescrito.

**Resultado:** PASS.

---

## 17. AR-F4-S15 — pause gaming

### Risco

Criar pausa retroativa para transformar breach em on-time.

### Decisão

- pause precisa ser permitida pela rule;
- deve ser prospectivamente autorizada ou baseada em evento externo independente auditável;
- pausa tardia não remove breach automaticamente;
- correção retroativa exige revisão explícita;
- pause iniciada depois do first breach não altera o primeiro breach.

**Resultado:** PASS.

---

## 18. AR-F4-S16 — capacidade como pausa

Falta de capacidade, backlog ou equipe reduzida:

> não são pause automáticas.

Devem aparecer como:

- feasibility problem;
- escalation;
- capacity/governance issue.

Isso preserva o princípio:

> capacidade não reduz criticidade nem apaga obrigação.

**Resultado:** PASS.

---

## 19. AR-F4-S17 — safety non-pausable

Rules ligadas a safety/integrity podem ser:

> non_pausable.

Quando pause for admissível, precisa de razão externa/normativa expressamente prevista.

**Resultado:** PASS.

---

## 20. AR-F4-S18 — estado operacional × compliance

Um único status foi rejeitado.

Dois eixos são necessários:

### execution_status

- pending;
- running;
- paused;
- satisfied;
- cancelled_invalidated;
- terminated_by_authority;
- not_applicable.

### compliance_status

- not_started;
- within_target;
- satisfied_on_time;
- breached_open;
- breached_then_satisfied;
- not_applicable.

Isso permite:

> paused + breach histórico.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 21. AR-F4-S19 — breach histórico

Ao primeiro breach:

- first_breached_at é preservado;
- rule snapshot é preservada;
- incidente/escalation pode ser aberto.

Conclusão tardia:

> breached_then_satisfied.

Não reclassificar como satisfied_on_time.

**Resultado:** PASS.

---

## 22. AR-F4-S20 — breach × currentness

Combinações válidas incluem:

- breached + current;
- breached + under_evaluation;
- on-time + outdated;
- on-time + update_recommended.

Logo:

> SLA compliance e CurrencyState são eixos independentes.

**Resultado:** PASS.

---

## 23. AR-F4-S21 — breach × scientific authority

Breach pode produzir:

- issue;
- warning;
- escalation operacional;
- pedido de capacidade/revisão.

Não pode produzir automaticamente:

- MaterialityAssessment;
- UpdateDecision;
- CurrencyState;
- assurance;
- publication;
- M3 activation.

**Resultado:** PASS.

---

## 24. AR-F4-S22 — Alert urgency

Alert já possui:

- informational/relevant/critical;
- routine/priority/urgent.

Esses valores não contêm duração temporal.

Decisão:

- podem ser inputs de SLA Rule resolution;
- não definem prazo universal;
- Alert critical/urgent não muda currentness;
- Alert lifecycle triage não substitui UpdateSignal triage.

**Resultado:** PASS.

---

## 25. AR-F4-S23 — Monitor

Monitor fornece timestamps upstream reais.

Decisão:

- EvidenceEvent/SearchHit podem definir origem de SLA-1;
- CandidateAssessment não substitui MaterialityAssessment;
- Monitor maintenance_decision não substitui UpdateDecision;
- cycle lateness continua cadence;
- pós-signal delay pertence ao SLA.

**Resultado:** PASS.

---

## 26. AR-F4-S24 — SLA-4 applicability

SLA-4 é natural para:

- scientific_update_incremental;
- scientific_update_broad.

Não é automático para:

- reroute_method;
- suspend_current_use.

Esses casos exigem follow-up obligation explícita.

**Resultado:** PASS.

---

## 27. AR-F4-S25 — workflow milestones

### Achado

Não existe milestone transversal canônico para:

- scientific_workflow_started;
- scientific_workflow_completed.

Consequência:

- SLA-4/5 não estão fisicamente implementáveis de forma transversal;
- adapters por workflow ou estrutura comum serão necessários.

**Resultado:** PASS conceitual / PHYSICAL GAP.

---

## 28. AR-F4-S26 — review_disposition × publication

A SLA Rule escolhe seu endpoint.

### review_disposition

`revise` pode satisfazer o tempo até decisão daquele review round.

Se revise abrir trabalho adicional:

> novo workflow/review round.

### publication

- revise não encerra SLA;
- rejection produz terminalidade explícita;
- approval não é sinônimo de publication.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 29. AR-F4-S27 — múltiplos rounds

SLA-4/5/6 não podem ser uma única linha global por UpdateSignal.

Cada workflow/review round precisa de identidade causal.

Nova instância não apaga a anterior.

**Resultado:** PASS.

---

## 30. AR-F4-S28 — target supersession

Supersession do target:

- não transfere SLA automaticamente;
- não apaga clock antigo;
- exige encerramento/rebase explícito;
- nova versão pode abrir nova obrigação.

**Resultado:** PASS.

---

## 31. AR-F4-S29 — rebase

Rebase permitido apenas com razão legítima e autoridade.

Preservar:

- original_start;
- original_due;
- original_rule;
- original_breach;
- rebase event;
- new rule/due.

Rebase para apagar breach é proibido.

**Resultado:** PASS.

---

## 32. AR-F4-S30 — priority ↔ SLA circularity

### Achado

SLA Rule selection depende parcialmente de prioridade.

A prioridade futura também deverá considerar atraso/breach.

Se ambos forem definidos apenas um pelo outro, haverá circularidade.

### Decisão

O próximo bloco deve definir prioridade a partir de inputs independentes, incluindo:

- safety/integrity;
- criticidade;
- materiality;
- currentness;
- dependency reach;
- operational delay;
- capacity.

Breach poderá modificar prioridade depois, mas não ser sua única origem.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 33. AR-F4-S31 — prioridade antes da migration

Como a seleção de SLA Rule precisa de precedência/priority semantics ainda não consolidadas:

> **não implementar contrato físico de SLA antes do bloco de prioridade.**

Isso evita congelar:

- classes;
- regras de resolução;
- escalations;

que teriam de ser redesenhadas depois.

**Resultado:** NOT_READY_FOR_MIGRATION_028.

---

## 34. AR-F4-S32 — durações universais

Nenhuma duração foi definida.

Exemplos externos de frequência/tempo:

> não serão transformados em SLA default sem justificativa específica do OES.

Durações poderão futuramente variar por:

- clock;
- risk profile;
- signal;
- materiality;
- decision;
- produto/domínio;
- rule específica.

**Resultado:** PASS.

---

## 35. AR-F4-S33 — automação

Automação futura pode calcular:

- due;
- elapsed;
- warning;
- breach;
- métricas;
- incidentes operacionais.

Não pode, por SLA:

- concluir ciência;
- verificar humano;
- alterar currentness;
- publicar;
- promover assurance;
- ativar M3.

**Resultado:** PASS.

---

## 36. AR-F4-S34 — M3

Arquitetura de SLA não remove:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

Um processo com SLAs completos ainda não é, por isso, living evidence formalmente operacional.

**Resultado:** PASS.

---

## 37. Estado pós-gate

| Componente | Estado |
|---|---|
| seis clocks | PASS |
| SLA × cadence | PASS |
| upstream origin | PASS |
| pre-policy age | PASS_WITH_ARCHITECTURAL_DECISION |
| triage semantics | PASS |
| triage físico | GAP |
| qualification timestamps | PASS |
| rule snapshot | PASS |
| elapsed/business/fixed basis | PASS |
| pause semantics | PASS |
| state × compliance | PASS_WITH_ARCHITECTURAL_DECISION |
| breach history | PASS |
| rebase | PASS |
| Alert integration | PASS |
| Monitor integration | PASS |
| workflow milestones | GAP |
| multiple review rounds | PASS |
| currentness independence | PASS |
| automation boundary | PASS |
| numeric durations | NOT_DEFINED |
| priority architecture | NEXT_REQUIRED_BLOCK |
| migration 028 | NOT_AUTHORIZED |
| M3 formal | BLOCKED |

---

## 38. Decisão

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_PRIORITY_ARCHITECTURE**

> **NOT_READY_FOR_MIGRATION_028**

O bloco de SLA semântico está concluído.

---

## 39. Próximo passo exato

> **Definir a arquitetura transversal de prioridade e escalation, com precedência explícita entre safety/integrity, criticidade, materialidade, currentness, dependências, SLA breach e capacidade.**

Esse bloco deverá:

1. reutilizar Alert `reassessment_priority` sem presumir equivalência automática;
2. evitar score agregado prematuro;
3. definir regras de dominância;
4. resolver conflito entre urgência científica e capacidade;
5. definir como breach modifica prioridade sem criar circularidade;
6. distinguir prioridade de triage, prioridade de atualização e prioridade de publicação;
7. somente depois decidir o contrato físico conjunto de priority/SLA.

Nenhuma migration nova deve ser iniciada antes desse gate.
