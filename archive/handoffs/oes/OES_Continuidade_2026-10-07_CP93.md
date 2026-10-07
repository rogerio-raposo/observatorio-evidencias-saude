# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Arquitetura Transversal de SLA

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP93  
**Checkpoint anterior:** CP92  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Fase 4 — arquitetura transversal de SLA, sem durações universais e sem migration nova

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **MIGRATION_028 = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada.

## 2. Freshness Gate de abertura

A retomada confirmou:

- HEAD inicial do bloco: `ecdb3fa9e0ce4f8126cb8005756bf49e15a8f477`;
- checkpoint vigente: CP92;
- STATE/CHANGELOG/pointer coerentes;
- nenhuma migration 028 existente;
- próximo passo confirmado: arquitetura transversal de SLA.

Nenhuma divergência material foi encontrada.

## 3. Documento 20 — Arquitetura Transversal de SLA

Arquivo:

`docs/governance/20-arquitetura-transversal-sla.md`

Status:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Princípio central:

> SLA mede obrigação operacional entre eventos auditáveis; não mede verdade científica, materialidade, currentness, assurance ou publicação.

Seis clocks mínimos:

1. detecção → triage;
2. triage → MaterialityAssessment;
3. MaterialityAssessment → UpdateDecision;
4. UpdateDecision → início do workflow científico;
5. início → conclusão da atualização científica;
6. conclusão científica → review disposition/publication, conforme regra.

## 4. Origem temporal e late normalization

SLA-1 não pode iniciar apenas no momento de criação tardia do UpdateSignal quando o OES já havia detectado a fonte antes.

Origem preferencial:

- Alert → `evidence_alert.detected_at`;
- EvidenceEvent → `evidence_event.detected_at`;
- SearchHit → `search_hit.imported_at`;
- CandidateAssessment → timestamp upstream apropriado;
- signal direto → `update_signal.detected_at`.

Publication/event date externa não é service clock start por default.

## 5. Evento pré-policy

Se o OES detectou um evento antes de existir obrigação de SLA:

- preservar source_detected_at;
- preservar pre_policy_age;
- iniciar tempo contratual apenas quando SLA Rule vigente + eligibility coexistirem.

Não:

- criar breach retroativo por obrigação inexistente;
- apagar a idade pré-policy.

## 6. Authority/qualification timestamps

### Materiality

Quando verificação humana é necessária:

> `materiality_qualified_at = max(assessed_at, verified_at)`

Assessment AI-only pode ser intermediate milestone, mas não fecha o clock autoritativo.

### Decision

Quando autoridade/verificação humana é necessária:

> `decision_qualified_at = max(decided_at, verified_at)`

Proposal não encerra SLA-3.

SLA-4 inicia em decision_qualified_at quando aplicável.

## 7. Triage

A arquitetura define triage transversal, mas migration 027 ainda não possui registro físico correspondente.

Disposições conceituais:

- accepted_for_materiality;
- duplicate_or_already_covered;
- invalid_signal;
- out_of_scope;
- routed_elsewhere.

IA/sistema pode auxiliar/encaminhar, mas não deve encerrar autoritativamente signal científico/currentness de modo que suprima avaliação material sem regra de autoridade apropriada.

Estado:

> **TRIAGE_TRANSVERSAL_PHYSICAL_MILESTONE = GAP**

## 8. Rule snapshot

Cada SLA Instance futura deverá congelar:

- SLA Rule/version;
- target;
- clock;
- duration/deadline rule;
- calendar basis/version;
- pause policy;
- escalation policy;
- risk/priority inputs usados na resolução.

Mudança posterior de policy/profile/prioridade/target não recalcula silenciosamente a instância.

## 9. Basis temporal

Foram aceitas semanticamente:

- elapsed_time;
- business_calendar;
- fixed_deadline.

Business calendar exige timezone e calendário versionado.

Fixed deadline:

> não-pausável por default.

## 10. nominal_due_at × effective_due_at

Devem coexistir:

- nominal_due_at;
- effective_due_at.

Nominal due nunca é sobrescrito.

Effective due só pode refletir:

- calendário declarado;
- pausas válidas e autorizadas.

## 11. Pause

Pause:

- precisa ser permitida pela rule;
- não equivale a backlog/capacidade baixa;
- deve ser autorizada prospectivamente ou sustentada por evento externo auditável;
- não apaga breach;
- pause iniciada após first_breached_at não altera o primeiro breach;
- safety/integrity pode ser non_pausable.

## 12. Estado operacional × compliance

Foram separados dois eixos.

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

Isso permite representar corretamente:

> paused + breach histórico.

## 13. Breach

Ao primeiro breach:

- preservar `first_breached_at`;
- preservar rule snapshot;
- permitir issue/escalation operacional.

Resolução tardia:

> `breached_then_satisfied`

Nunca converter retrospectivamente para `satisfied_on_time`.

Breach não altera:

- materiality;
- CurrencyState;
- assurance;
- Alert classification;
- publication;
- M3.

## 14. SLA-4/5/6

### SLA-4

Aplicação natural:

- scientific_update_incremental;
- scientific_update_broad.

Reroute/suspend exigem obrigação explícita.

### SLA-5

Depende de milestones transversais de workflow científico que ainda não existem de forma padronizada.

### SLA-6

A rule escolhe:

- review_disposition; ou
- publication.

`revise` pode encerrar o clock de review daquele round, mas abre novo workflow/review round quando houver retrabalho.

Para endpoint publication:

- revise não encerra;
- approval não é publication;
- rejection exige terminalidade explícita.

## 15. Múltiplos rounds

SLA-4/5/6 não podem ser uma única linha global por signal.

Cada workflow/review round precisa de identidade causal própria.

Histórico anterior permanece.

## 16. Monitor e Alert

### Alert

- classification e reassessment_priority continuam sem duração embutida;
- podem ser inputs de SLA;
- Alert triage não substitui triage transversal;
- critical/urgent não muda currentness automaticamente.

### Monitor

- fornece timestamps upstream;
- CandidateAssessment não substitui MaterialityAssessment;
- maintenance_decision do cycle não substitui UpdateDecision;
- cycle lateness pertence à cadence;
- pós-signal delay pertence ao SLA.

## 17. Prioridade × SLA

A revisão detectou risco de circularidade.

SLA Rule selection depende parcialmente de prioridade.

Prioridade futura também deverá considerar breach/atraso.

Decisão:

> prioridade deve ser definida a partir de inputs independentes e breach deve atuar como modificador posterior, não como única origem.

Por isso:

> **priority architecture deve preceder o contrato físico de SLA.**

## 18. Documento 21 — revisão adversarial

Arquivo:

`docs/governance/21-revisao-adversarial-arquitetura-sla.md`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Estado:

> **READY_FOR_PRIORITY_ARCHITECTURE**

> **NOT_READY_FOR_MIGRATION_028**

Gaps físicos principais:

1. triage transversal;
2. SLA Rule/version;
3. SLA Instance;
4. pause ledger;
5. incident/escalation;
6. workflow started/completed;
7. review/publication adapters;
8. rule snapshot/rebase;
9. occurred/qualified/recorded timestamps;
10. workflow/review round identity.

## 19. Referências externas consideradas

Foram mantidos princípios de:

- Cochrane Handbook — prospective/living evidence;
- NICE PMG49 — surveillance proporcional e targeted;
- WHO living-guidelines approach.

Nenhum exemplo externo de frequência/prazo foi adotado como SLA universal do OES.

## 20. Estado técnico

Não houve alteração técnica neste bloco.

Último PASS técnico permanece:

- migration 027;
- F4-UP-T01–T63 = PASS;
- F4-UP-IDEM = PASS;
- rebuild-through-027 = PASS;
- S5 run **37570978847** = success;
- HEAD técnico validado `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- artifact **11460960487**;
- digest `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

## 21. Limites preservados

Ainda não definidos/implementados:

- classes/durações numéricas de SLA;
- prioridade transversal;
- regras físicas de escalation;
- scheduler;
- notification channels;
- migration 028;
- auto-classification;
- auto-escalation;
- propagation;
- Monitor re-baselining;
- M3 readiness;
- auto-publication;
- auto-update científico.

## 22. Próximo passo exato

> **Definir a arquitetura transversal de prioridade e escalation.**

O próximo bloco deverá:

1. separar prioridade de triage, atualização e publicação;
2. definir dominância de safety/integrity;
3. integrar criticidade, materiality, currentness e dependency reach;
4. tratar breach como modificador, sem circularidade;
5. preservar capacidade como feasibility, não compensador de risco;
6. reutilizar Alert `reassessment_priority` sem equivalência automática;
7. evitar score agregado prematuro;
8. somente depois decidir o contrato físico conjunto priority/SLA.

## 23. Disciplina de modo

O próximo bloco continua arquitetural/metodológico e transversal.

> **Modo alto é apropriado.**

## 24. Regra de parada

Após ativação deste checkpoint:

> **parar e aguardar instrução explícita do usuário antes de iniciar prioridade/escalation.**

**Fim do CP93**
