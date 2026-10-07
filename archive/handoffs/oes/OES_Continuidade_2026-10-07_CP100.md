# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Arquitetura de Propagation/Re-baselining

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP100  
**Checkpoint anterior:** CP99  
**Status:** artefato de continuidade; não normativo  
**Escopo:** seleção da dívida pós-CP99, arquitetura transversal de propagation/re-baselining e gate adversarial

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **MIGRATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada.  
A Fase 5 não foi iniciada.

## 2. Freshness Gate desta retomada

Freshness Gate de abertura confirmou:

- HEAD inicial: `10db24caab6fcd0b610915855ca0ae859a052b7b`;
- checkpoint vigente inicial: CP99;
- CP99 integralmente lido e reconciliado;
- STATE e CHANGELOG coerentes;
- commits posteriores ao technical HEAD do CP99 eram apenas documentais;
- nenhuma alteração concorrente identificada.

Validação técnica canônica herdada do CP99:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37618433929** (#161);
- technical HEAD: `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- job: `postgres-s5`;
- job ID: **112782351104**;
- conclusion: **success**;
- artifact: **11480858194**;
- digest: `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`.

Nenhuma mudança técnica de banco/workflow ocorreu neste bloco; portanto nenhuma nova run foi necessária para validar os documentos arquiteturais.

## 3. Dívida selecionada

Após CP99, a dívida selecionada foi:

> **propagation/re-baselining transversal.**

Racional:

- já era obrigação explícita do Documento 05;
- foi deliberadamente mantida aberta na auditoria dos Documentos 22–24;
- continuava pendente após migrations 029–030;
- é pré-requisito de segurança para eventual living/M3;
- podia ser arquitetada sem fabricar numeric SLA, scheduler, notifications ou operação humana.

Modo alto foi apropriado por se tratar de decisão arquitetural difícil de reverter.

## 4. Documento 33

Criado:

`docs/governance/33-arquitetura-propagacao-rebaselining.md`

Estado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS — aprovado após Documento 34**

Princípio central:

> dependency discovery não é scientific impact; impact potencial não é currentness; re-baselining não é retargeting in-place; propagation não é automatic write.

## 5. Separação dos dois fluxos

### Propagation

Fan-out de impacto:

- origem versionada;
- traversal de dependencies;
- candidates downstream;
- avaliação local;
- sem alteração científica automática.

### Re-baselining

Transição de manutenção entre versões da mesma entidade:

- old target histórico;
- new target explícito;
- policy/Monitor/profile/coverage/SLA handover controlado;
- sem retargeting in-place.

Os fluxos podem coexistir, mas permanecem semanticamente distintos.

## 6. Invariantes centrais

1. `provenance.dependency_edge` continua projeção auxiliar/regenerável;
2. PropagationCandidate aponta para version_uuid concreto;
3. currentness continua decidido localmente;
4. Assurance permanece eixo separado;
5. `supersedes_update_policy_uuid` continua same exact target;
6. cross-target policy lineage será estrutura própria;
7. MonitorTarget permanece imutável;
8. new target M2/M3 exige novo Monitor ProductVersion/binding explícito;
9. UpdateRiskProfile não muda de target;
10. signals/assessments/decisions não são movidos;
11. Priority/Escalation históricos não são retargeteados;
12. SLA Rules/Instances permanecem policy/target-bound;
13. workflow milestones não são copiados;
14. Alerts não são movidos;
15. M3 blocker permanece.

## 7. Documento 34 — primeira passagem

Criado:

`docs/governance/34-revisao-adversarial-propagacao-rebaselining.md`

Primeira passagem:

> **REVISE**

Foram identificados blockers em:

- maintainable target × intermediate dependency object;
- target mantível sem UpdatePolicy;
- propagation→UpdateSignal source adapter;
- multiple dependency paths;
- cycle/depth guards;
- lineage validation;
- skipped versions;
- planned × activated rebaseline;
- policy handover;
- M2/M3 ordering;
- Monitor lineage;
- coverage carry-forward;
- UpdateRiskProfile readiness;
- SLA Rules cross-policy;
- open SLA Instance;
- workflow transition basis;
- concurrency;
- authority domain.

## 8. Hardening do Documento 33

As correções AR-F4-PR01–PR20 foram incorporadas.

### Maintainable targets

Somente:

- ProductVersion elegível;
- InvestigationVersion elegível;

podem entrar em fluxo local de UpdatePolicy/UpdateSignal.

Objetos intermediários usam rotas de domínio e/ou continuam propagation.

### Missing policy

Target mantível sem policy usa:

> `maintenance_policy_required`

sem criação automática.

### Propagation source adapter

O contrato futuro deverá possuir linkage estruturado propagation→UpdateSignal.

Não usar genericamente EntityVersion quando isso viola o lifecycle da origem.

Não criar signal_type genérico que apague a causa.

### Multiple paths

Baseline:

> um PropagationCandidate por assessment + impacted version.

Paths são 1:N e congelados.

### Traversal

Exige:

- cycle guard;
- no revisit;
- depth limit;
- issue em truncamento/ciclo;
- nunca concluir “no impact” de traversal incompleta.

### Lineage validation

Estado mínimo conceitual:

- validated_against_canonical_relations;
- projection_only_unverified;
- projection_divergence_detected;
- incomplete_or_unknown.

`no_action_supported` authoritative depende de lineage suficientemente validado.

## 9. Re-baselining same-entity

Exige:

- mesma entity_uuid;
- tipo/subtipo compatível;
- chain auditável;
- temporalidade coerente.

Skipped versions:

- precisam aparecer na chain snapshot;
- não podem ser representadas como supersession direta inexistente.

Estados conceituais:

- planned;
- activated.

Activation exige new target current.

Se o target mudar durante handover:

- não existe follow-latest automático;
- decisão pendente é superseded/invalidated;
- nova decisão append-preserving é criada.

## 10. UpdatePolicy

Duas relações distintas:

1. same-target supersession — `supersedes_update_policy_uuid`;
2. cross-target rebaseline lineage — estrutura futura separada.

Handover completo:

- old policy histórica;
- new policy ativa no new target;
- incomplete handover deve aparecer em helper/readiness.

## 11. Monitor

Para M2/M3:

1. new target current;
2. RebaselineDecision preparada;
3. novo Monitor ProductVersion;
4. novo Monitor precisa estar **current** para activation;
5. MonitorDefinition/MonitorTarget/estado coerentes;
6. só então new UpdatePolicy M2/M3.

Monitor disposition mínima:

- continue_same_monitor_lineage;
- replace_with_new_monitor_entity;
- stop_monitoring;
- not_applicable;
- pending.

Old cycles/Search/EvidenceEvents/CandidateAssessments nunca são movidos.

## 12. Coverage

Partitions candidatas:

- incorporated_through_new_target_cutoff;
- post_cutoff_pending_assessment;
- known_gap_carried_forward;
- source_recheck_required;
- no_carry_forward_supported.

New target evidence_cutoff_date é baseline científico inicial.

Old Monitor completed_at não redefine baseline.

Coverage debt é preservado.

## 13. UpdateRiskProfile

New target não reutiliza old profile UUID.

Disposition candidata:

- reassessment_required;
- carry_forward_authorized;
- new_assessment_required;
- not_applicable;
- pending.

Carry-forward continua subordinado aos guards da migration 030.

## 14. SLA

### SLA Rule

Rule é policy-bound.

Logo:

- old rule não é retargeteada;
- `supersedes_sla_rule_uuid` não cruza policy;
- new policy precisa de novas rules ou estado explícito não configurado;
- calendário pode ser novamente adotado se válido;
- nenhuma duração/deadline é copiada por default.

### SLA Instance

Old obligation aberta recebe disposition explícita.

Preservar:

- original start;
- original due;
- rule snapshot;
- first breach;
- pause history;
- closure rationale.

Rebase para apagar breach continua proibido.

## 15. Workflow, Priority, Escalation e Alert

RebaselineDecision pode citar:

- UpdateDecision;
- WorkflowRound;
- result ProductVersion/InvestigationVersion;
- governance decision.

Não mover:

- old signal;
- PriorityAssessment;
- EscalationCase;
- WorkflowMilestone;
- Alert.

Novo target exige novos objetos quando aplicável.

## 16. Authority

Domínio explícito:

- operational;
- scientific;
- methodological;
- mixed.

Owner sozinho:

> somente decisão puramente operacional dentro de autoridade definida.

Scientific/methodological/mixed authoritative:

> exige boundary humana qualificada conforme contratos vigentes.

## 17. Documento 34 — recheck final

Após hardening:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Autorizado:

> **especificar o Contrato Físico v0.1 de Propagation/Re-baselining.**

Não autorizado:

- migration;
- scheduler;
- notifications;
- auto-escalation;
- numeric SLA calibration;
- numeric cadence;
- automatic currentness;
- auto-retarget;
- auto-rebaseline;
- M3 unblock.

## 18. Commits do bloco

Commits principais, em ordem:

- `5acdc7c64921c68f1fea8abdf4cc5c32f7ae5831` — Define Phase 4 propagation and re-baselining architecture;
- `e89d5d6114d173d90f70d1822beece643be769c9` — Record Phase 4 propagation architecture in state;
- `4572559c93776f496df859cde918cea4211372ae` — Log Phase 4 propagation architecture;
- `71c20fd0742a52a9db17aab118d9e93b57070816` — Adversarial review Phase 4 propagation architecture;
- `cba466ac842a155d9f148393be96cecc579fd116` — Harden Phase 4 propagation architecture after adversarial review;
- `a9d99e7eb5e82e94dba0eb5fa3a3c0747f32c4ea` — Require current Monitor at rebaseline activation;
- `926d932d610b3ec73402e144cfa85aada14306ce` — Pass adversarial gate for propagation architecture;
- `f3f8b4af7844d47300d6ff144e0f7bc604afaad5` — Finalize propagation architecture after adversarial gate;
- `770ebccd7c7cc391f65294513a7135f82ccfc44e` — Record propagation adversarial gate in state;
- `ffed2e79f61b3975d44b68ee3b25f7f69dfba18e` — Log propagation adversarial gate.

## 19. Estado do repositório antes do CP100

HEAD imediatamente antes da criação deste checkpoint:

`ffed2e79f61b3975d44b68ee3b25f7f69dfba18e`

Nenhum commit concorrente foi identificado durante o bloco.

## 20. Próximo passo exato

> **Especificar o Contrato Físico v0.1 de Propagation/Re-baselining, incluindo estruturas, validators, issue/readiness helpers e plano mínimo de testes; depois executar novo gate adversarial/físico antes de autorizar qualquer migration.**

## 21. Disciplina de modo

O próximo bloco ainda envolve decisões de contrato de dados difíceis de reverter.

> **Recomenda-se manter modo alto durante a especificação e o gate do contrato físico.**

Quando o contrato físico estiver fechado e restar implementação mecânica já especificada:

> poderá ser usado modo médio.

## 22. Regra de parada

Após ativação do CP100:

> **parar e aguardar instrução explícita do usuário antes de iniciar o Contrato Físico v0.1.**

**Fim do CP100**
