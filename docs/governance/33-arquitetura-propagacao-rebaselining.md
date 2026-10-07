# 33 — Arquitetura Transversal de Propagação de Mudanças e Re-baselining

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISED_AFTER_ADVERSARIAL — READY_FOR_DOCUMENT_34_RECHECK — NOT_AUTHORIZED_FOR_MIGRATION**  
**Dependências:** Documentos 05–09, 16–32; docs/architecture/28–29; migrations 004, 021–030  
**Objeto:** propagação controlada de impacto, re-baselining de targets versionados, rebinding de Monitor e preservação histórica das obrigações operacionais

---

## 1. Finalidade

Definir a arquitetura transversal para dois problemas ainda abertos da Fase 4:

1. **propagação de impacto** — quando uma mudança upstream pode afetar versões dependentes;
2. **re-baselining** — quando uma mesma entidade científica passa a possuir nova versão e a camada de manutenção precisa decidir explicitamente como continuar.

Este bloco não autoriza migration.

---

## 2. Princípio central

> **Descoberta de dependência não é impacto científico; impacto potencial não é mudança de currentness; re-baselining não é retargeting in-place; propagação não é reescrita automática.**

Consequências:

- provenance/dependency identifica candidatos;
- avaliação qualificada decide se existe impacto;
- currentness continua sendo decidida pelos mecanismos próprios do Protocolo de Atualização;
- objetos históricos continuam ancorados no target/policy/version que os originou;
- nova versão científica exige decisão explícita para policy, Monitor e obrigações futuras;
- nenhum objeto downstream é reescrito silenciosamente.

---

## 3. Baseline físico que deve ser preservado

### 3.1 Versionamento

A política arquitetural de identidade/versionamento estabelece:

- identidade estável;
- versões imutáveis;
- supersession explícita;
- no máximo uma versão current por entidade;
- correção por nova versão, não por edição in-place.

Logo, propagation/re-baselining deve operar sobre **version_uuid concretos**.

### 3.2 Dependency lineage

provenance.dependency_edge é projeção auxiliar regenerável das relações canônicas.

Pode ser usada para:

- descoberta de dependentes;
- travessia de impacto;
- produção de snapshot de caminho.

Não pode ser usada como:

- fonte manual de verdade para “corrigir” lineage;
- autorização automática de mudança downstream.

### 3.3 UpdatePolicy

maintenance.update_policy:

- aponta para uma ProductVersion ou InvestigationVersion exata;
- é append-preserving;
- sua supersession atual preserva o target version exato;
- M2/M3 exige governing Monitor com target correspondente;
- em target superseded gera issue de coerência.

Decisão:

> **não enfraquecer a regra atual para permitir que supersedes_update_policy_uuid atravesse versões científicas.**

Mudança de target version deverá usar mecanismo de re-baselining separado.

### 3.4 MonitorTarget

maintenance.monitor_target é imutável dentro de um Monitor ProductVersion.

Decisão:

> **um Monitor ProductVersion existente nunca será retargeteado in-place.**

Se vigilância continuar sobre nova target version, deverá existir novo Monitor ProductVersion configurado para o novo target.

### 3.5 UpdateRiskProfile

Após migration 030:

- profile é físico;
- target é versão exata;
- reassessment/carry-forward é history-preserving;
- carry-forward entre versões exige mesma lineage entity;
- PriorityAssessment posterior usa profile físico correspondente ao target/policy.

Logo, re-baselining não pode transplantar silenciosamente um profile antigo para nova versão.

---

## 4. Dois fluxos independentes

### 4.1 Fluxo A — propagation

Responde:

> **quais objetos dependentes podem ter sido afetados por uma mudança upstream e qual avaliação cada um requer?**

É fan-out.

### 4.2 Fluxo B — re-baselining

Responde:

> **como a manutenção de uma mesma entidade continua quando o target científico muda de versão?**

É transição same-entity.

Os dois fluxos podem coexistir, mas não devem ser colapsados.

Exemplo:

- nova ProductVersion A2 substitui A1;
- A2 pode exigir re-baselining da própria maintenance policy de A;
- simultaneamente, versões B1, C3 e D2 que dependem de A1 podem entrar em propagation assessment.

---

## 5. Eventos gatilho de propagation

Candidatos mínimos:

- nova versão que supersede versão anterior;
- invalidation de versão;
- correção material;
- retraction/expression of concern qualificada em upstream;
- mudança de certainty/synthesis/result com dependentes;
- mudança do dependency graph que revele dependência antes não representada.

O evento gatilho:

- não altera downstream;
- não cria CurrencyState;
- não cria nova conclusão;
- apenas abre necessidade de avaliação.

---

## 6. Unidade conceitual: PropagationAssessment

Futuro contrato físico deverá ser capaz de representar uma avaliação de propagação history-preserving.

Campos conceituais mínimos:

- propagation_assessment_uuid;
- origin_version_uuid;
- replacement_version_uuid opcional;
- origin_event_class;
- triggered_at;
- dependency_snapshot_at;
- scope_depth;
- rationale;
- initiated_by;
- actor_type;
- verification metadata;
- authority_status = proposal | authoritative;
- record_status;
- supersedes_propagation_assessment_uuid opcional.

### 6.1 origin_version_uuid

É sempre core.entity_version.version_uuid.

Permite origem em:

- Report;
- Result;
- Synthesis;
- Certainty;
- InvestigationVersion;
- ProductVersion;
- outros tipos versionados já pertencentes ao grafo.

### 6.2 replacement_version_uuid

Quando houver transição de versão da mesma entidade:

- deve referir version_uuid da mesma entity_uuid;
- deve ser temporalmente posterior;
- não é obrigatório para invalidation sem sucessor conhecido.

### 6.3 Authority

Automação/IA pode:

- detectar evento;
- atravessar grafo;
- montar candidates;
- produzir proposal.

Automação/IA não pode, sozinha:

- declarar impacto científico authoritative;
- alterar currentness;
- decidir publicação;
- propagar conclusão.

---

## 7. Unidade conceitual: PropagationCandidate

Cada dependente candidato precisa de registro próprio.

Campos conceituais mínimos:

- propagation_candidate_uuid;
- propagation_assessment_uuid;
- impacted_version_uuid;
- dependency_path_snapshot;
- dependency_type_snapshot;
- impact_domain;
- assessment_status;
- disposition;
- rationale;
- assessed_by;
- actor_type;
- verification metadata;
- authority_status;
- assessed_at;
- record_status;
- supersedes_propagation_candidate_uuid opcional.

### 7.1 impacted_version_uuid

É versão concreta.

Não persistir apenas entity_uuid porque:

- o conteúdo dependente é versionado;
- versões históricas podem ter dependências diferentes;
- currentness e manutenção pertencem ao contexto da versão.

### 7.2 dependency_path_snapshot

Deve congelar, no mínimo:

- sequência de version_uuid;
- tipos de dependência;
- timestamp da travessia;
- indicação de que dependency_edge é projeção auxiliar.

O snapshot não transforma dependency_edge em fonte primária de verdade.

---

## 8. Domínios de impacto

impact_domain mínimo:

- scientific_content;
- methodological;
- certainty;
- applicability;
- safety_integrity;
- currentness_review;
- maintenance;
- operational_only;
- mixed;
- unknown_pending_review.

Regra:

> impact_domain não substitui MaterialityAssessment nem UpdateDecision.

---

## 9. Disposition de propagation

Disposições conceituais mínimas:

- no_action_supported;
- reassessment_required;
- maintenance_policy_required;
- open_update_signal;
- method_review_required;
- new_version_workflow_required;
- rebaseline_required;
- dependency_correction_required;
- governance_review_required;
- unresolved.

Regras:

1. no_action_supported exige rationale;
2. open_update_signal abre o fluxo normal da Fase 4 no target downstream;
3. rebaseline_required apenas marca necessidade de Fluxo B;
4. new_version_workflow_required não cria versão automaticamente;
5. unresolved não pode ser tratado como ausência de impacto.

---

## 10. Relação com UpdateSignal

Propagation não substitui UpdateSignal.

Quando um dependente ProductVersion/InvestigationVersion precisa de avaliação de currentness/update:

> criar um novo UpdateSignal para a UpdatePolicy do dependente, preservando linkage com o PropagationCandidate.

Não:

- reutilizar signal upstream;
- mover signal entre policies;
- copiar MaterialityAssessment;
- copiar UpdateDecision.

---

## 11. Relação com PriorityAssessment

PropagationCandidate pode ser input de prioridade futura, mas:

- não define response_class por si só;
- dependency reach é input, não score;
- safety/integrity pode justificar floor via regras já existentes;
- prioridade deve ser nova avaliação contextual.

Nenhuma PriorityAssessment histórica é alterada.

---

## 12. Fluxo de re-baselining

Re-baselining só é aplicável quando há transição entre versões da **mesma entidade científica**.

Condições mínimas:

- old target e new target possuem mesma entity_uuid;
- tipos compatíveis;
- new target é posterior;
- transição/version lineage é auditável.

Re-baselining entre entidades distintas é proibido.

---

## 13. Unidade conceitual: RebaselineDecision

Futuro contrato físico deverá ser capaz de representar:

- rebaseline_decision_uuid;
- old target version;
- new target version;
- transition basis;
- old UpdatePolicy;
- new UpdatePolicy opcional até materialização;
- old governing Monitor opcional;
- new governing Monitor opcional;
- policy disposition;
- monitor disposition;
- risk profile disposition;
- cadence disposition;
- coverage disposition;
- open work disposition;
- SLA disposition;
- rationale;
- decided_by;
- actor_type;
- verification metadata;
- authority_status;
- decided_at;
- record_status;
- supersedes_rebaseline_decision_uuid opcional.

---

## 14. UpdatePolicy no re-baselining

A regra atual é correta:

> supersedes_update_policy_uuid preserva exact target version.

Portanto, quando new target version surge:

1. policy antiga pode ser encerrada/superseded como registro do target antigo;
2. nova policy deve ser criada para o novo target;
3. a relação old-policy → new-policy deve ser registrada por **lineage de re-baselining própria**;
4. não usar supersedes_update_policy_uuid para atravessar targets.

Isso preserva semântica e evita reinterpretar uma policy histórica como se tivesse governado a nova versão.

---

## 15. Monitor no re-baselining

Como MonitorTarget é imutável:

1. Monitor antigo permanece ligado ao target antigo;
2. se vigilância continuar, criar novo Monitor ProductVersion;
3. novo Monitor ProductVersion recebe novo MonitorTarget;
4. sua baseline cutoff deve obedecer ao contrato vigente do Monitor;
5. ciclos antigos permanecem no Monitor antigo;
6. Searches/EvidenceEvents/CandidateAssessments antigos não são movidos.

A relação entre Monitor antigo e novo pode usar o versionamento normal do ProductVersion quando pertencem à mesma entidade Monitor, complementada por RebaselineDecision.

---

## 16. Coverage baseline

Para nova target version:

- evidence_cutoff_date do novo target define o baseline aplicável ao novo Monitor conforme contrato atual;
- histórico de cobertura do Monitor anterior permanece histórico;
- não assumir que “último ciclo concluído” é automaticamente o novo baseline;
- carry-forward de informação sobre cobertura exige decisão explícita e deve distinguir:
  - cobertura já incorporada ao novo target;
  - cobertura posterior ao cutoff que ainda precisa ser avaliada;
  - gaps conhecidos;
  - sources que precisam ser rechecadas.

Não apagar coverage debt.

---

## 17. UpdateRiskProfile no re-baselining

Para novo target:

- profile antigo não muda de target;
- novo profile pode ser:
  - reassessed;
  - carry_forward;
  - new assessment;
- carry_forward deve obedecer aos guards da migration 030;
- dimensões carregadas preservam source_profile/source_dimension e rationale.

RebaselineDecision pode apontar o disposition; o profile físico continua sendo a fonte de verdade da avaliação de risco.

---

## 18. Cadence

Cadence antiga não é herdada automaticamente.

Opções conceituais:

- reassess_required;
- carry_forward_authorized;
- changed;
- not_applicable.

Mesmo carry-forward exige:

- policy nova;
- rationale;
- base temporal prospectiva;
- ausência de schedule drift silencioso.

---

## 19. Open UpdateSignals

Signals antigos pertencem à policy/target antiga.

No re-baselining:

- não trocar update_policy_uuid;
- não trocar target por UPDATE;
- não mover assessments/decisions.

Disposition mínimo por signal aberto:

- resolve_on_old_target;
- invalidate_as_target_superseded;
- continue_old_target_workflow;
- create_new_signal_candidate_on_new_target;
- governance_review_required.

Novo signal, quando necessário, é novo registro.

---

## 20. UpdateDecision e CurrencyState

Re-baselining:

- não copia UpdateDecision;
- não copia linkage para CurrencyState;
- não altera CurrencyState do novo target;
- não converte currentness da versão antiga em currentness da nova.

A nova versão científica começa com seus próprios fatos de versionamento/publicação e recebe manutenção/currentness segundo contratos aplicáveis.

---

## 21. Priority e escalation

PriorityAssessment e EscalationCase históricos:

- permanecem ligados ao caso/policy/signal original;
- não são retargeteados;
- podem gerar rationale para nova avaliação no target novo;
- não são copiados como estado corrente.

Capacidade ou pressão operacional não legitima transferência automática.

---

## 22. SLA

SLA Instance histórica:

- preserva original target;
- preserva rule snapshot;
- preserva breach;
- preserva pause/rebase history.

Nova target version:

- não herda deadline silenciosamente;
- usa nova obrigação quando aplicável;
- eventual relação causal com obrigação anterior precisa ser explícita.

Proibido:

> rebase apenas para apagar breach ou fazer parecer que a nova versão sempre foi o target original.

---

## 23. WorkflowRound e milestones

Workflow científico iniciado para old target:

- continua sendo histórico do old target;
- não muda de target;
- pode terminar normalmente ou ser encerrado/invalidado conforme decisão explícita;
- novo target requer novo round quando houver trabalho aplicável.

Milestones não são copiados.

---

## 24. Alerts

Alert ligado à versão antiga:

- permanece histórico;
- não é “movido” para nova versão;
- pode ser marcado como incorporado apenas com linkage rastreável;
- nova comunicação, se necessária, deve seguir contrato de Alert.

PropagationCandidate não cria Alert automaticamente.

---

## 25. Re-baselining de InvestigationVersion

As mesmas regras se aplicam a InvestigationVersion:

- mesma entity_uuid;
- nova version_uuid;
- nova UpdatePolicy;
- nenhum CurrencyState artificial;
- propagation pode abrir avaliação de impacto;
- Monitor, quando aplicável, requer novo binding explícito.

---

## 26. Propagação para dependentes

Para cada impacted_version:

1. congelar caminho de dependência;
2. verificar se a versão ainda é relevante/current;
3. classificar domínio de impacto;
4. decidir disposition;
5. quando necessário, abrir UpdateSignal próprio;
6. seguir MaterialityAssessment/UpdateDecision;
7. registrar resolução.

Não executar breadth-first “write propagation”.

A travessia pode ser automática; a alteração científica não.

---

## 27. Dependente superseded/archived/invalidated

Se impacted_version não estiver current:

- não ignorar silenciosamente;
- registrar candidate;
- disposition pode ser no_action_supported por irrelevância operacional;
- se a versão histórica ainda sustenta outro objeto ativo, lineage deve ser avaliada;
- invalidated pode exigir prioridade maior para dependentes ainda ativos.

---

## 28. Deduplicação

Múltiplos upstream events podem atingir o mesmo impacted_version.

Não colapsar eventos apenas por target.

É permitido consolidar processamento operacional se:

- todas as origens ficam preservadas;
- cada caminho permanece auditável;
- uma avaliação compartilhada declara explicitamente seu escopo.

---

## 29. Lifecycle e imutabilidade

PropagationAssessment, PropagationCandidate e RebaselineDecision devem ser append-preserving.

Correção:

- supersede;
- append;
- preservar versões anteriores.

Nunca editar retroativamente:

- caminho congelado;
- rationale authoritative;
- actor;
- timestamp;
- target old/new;
- disposition histórica.

---

## 30. Fronteira de authority

### 30.1 System/AI

Pode:

- detectar;
- traversar;
- deduplicar candidates;
- calcular path;
- sugerir disposition;
- preparar proposal.

Não pode sozinho:

- produzir authoritative scientific impact;
- declarar no_action_supported em questão científica material;
- alterar currentness;
- decidir carry-forward científico;
- decidir publication;
- ativar M3.

### 30.2 Owner

Pode:

- decidir aspectos puramente operacionais dentro de autoridade definida;
- registrar capacidade;
- aprovar mobilização/coordenação operacional.

Owner sozinho não substitui human_reviewer/human_expert em impacto científico.

### 30.3 Human reviewer/expert

É exigido quando disposition authoritative depende de julgamento científico/metodológico conforme os gates já vigentes.

---

## 31. M3

Este bloco é requisito de segurança para operação living, mas:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece BLOCKED.**

Antes de M3 formal, o gate futuro deverá confirmar, entre outros pontos:

- propagation assessment representável;
- re-baselining representável;
- target atual sem rebinding silencioso;
- policy/Monitor coerentes com versão atual;
- coverage baseline explícito;
- risk profile aplicável;
- SLA/history preservados.

A aprovação deste Documento 33 não remove o blocker.

---

## 32. Scheduler, notifications e auto-escalation

Fora do escopo.

Este bloco não define:

- scheduler;
- notification channels;
- mensageria;
- auto-escalation;
- auto-retarget;
- auto-rebaseline;
- numeric SLA;
- cadence numérica.

Esses itens exigem blocos próprios.

---

## 33. Consequências para contrato físico futuro

Uma migration futura poderá precisar representar, de forma aditiva:

1. PropagationAssessment;
2. PropagationCandidate;
3. snapshot imutável dos caminhos;
4. linkage PropagationCandidate → UpdateSignal novo;
5. RebaselineDecision;
6. lineage old-policy → new-policy separado de supersession same-target;
7. linkage old-Monitor → new-Monitor;
8. dispositions de carry-forward/reassessment;
9. issue/readiness helpers;
10. blockers explícitos para retarget/rebinding silencioso.

Nenhuma dessas estruturas está autorizada ainda.

---

## 34. Alternativas rejeitadas

### 34.1 Atualizar target da UpdatePolicy in-place

Rejeitado por violar imutabilidade e história.

### 34.2 Permitir supersedes_update_policy_uuid atravessar versões

Rejeitado porque altera a semântica atual de supersession same-target.

### 34.3 Atualizar MonitorTarget

Rejeitado porque MonitorTarget é imutável por design.

### 34.4 Copiar signals/assessments/decisions

Rejeitado porque cria falsa continuidade causal.

### 34.5 Alterar CurrencyState downstream automaticamente

Rejeitado porque dependency impact não é currentness.

### 34.6 Usar dependency_edge como registro authoritative de decisão

Rejeitado porque dependency_edge é projeção regenerável, não judgment record.

---

## 35. Casos adversariais obrigatórios

O gate do próximo documento deverá testar pelo menos:

1. new version sem mesmo entity_uuid;
2. policy rebaseline usando supersedes_update_policy_uuid indevidamente;
3. MonitorTarget retarget in-place;
4. dependency_edge stale/divergente;
5. impacted version superseded;
6. multiple paths para mesmo candidate;
7. multiple origins para mesmo impacted version;
8. AI authoritative scientific disposition;
9. owner-only scientific carry-forward;
10. old signal movido para new policy;
11. old SLA deadline copiado para new target;
12. old breach apagado por rebase;
13. PriorityAssessment retargeteada;
14. Alert movido;
15. risk profile transplantado sem carry-forward válido;
16. coverage baseline usando completed_at antigo automaticamente;
17. M3 unblock implícito;
18. propagation que altera currentness;
19. rebaseline cross-entity;
20. cyclic dependency traversal;
21. invalidated upstream com downstream current;
22. new target sem policy;
23. M2/M3 new policy sem governing Monitor correspondente;
24. new Monitor com baseline cutoff divergente do target;
25. old/new policy lineage sem reinterpretação histórica.

---

## 36. Testes conceituais mínimos antes de migration

Antes de qualquer contrato físico:

- old/new target same-entity;
- propagation candidate preserva version UUID concreto;
- path snapshot preserva trilha;
- no_action exige rationale;
- scientific authoritative exige boundary humana;
- new UpdateSignal é independente do upstream;
- new policy não usa cross-target supersedes;
- old policy permanece histórica;
- new Monitor ProductVersion requerido para novo target em M2/M3;
- old cycles permanecem imutáveis;
- coverage debt preservado;
- risk profile carry-forward usa migration 030;
- SLA breach histórico preservado;
- Priority/Escalation históricos preservados;
- CurrencyState não sofre write automático;
- Assurance não sofre promoção;
- Alert não é recriado automaticamente;
- M3 blocker permanece.

---

## 37. Gate de saída deste bloco

Resultado permitido:

- PASS;
- PASS_WITH_ARCHITECTURAL_DECISIONS;
- REVISE;
- NOT_READY.

Somente PASS/PASS_WITH_ARCHITECTURAL_DECISIONS poderá autorizar especificação de contrato físico.

---

## 38. Estado

> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = REVISED_READY_FOR_RECHECK**

> **PROPAGATION_AUTO_WRITE = NOT_AUTHORIZED**

> **CROSS_TARGET_POLICY_SUPERSESSION = NOT_AUTHORIZED**

> **MONITOR_RETARGET_IN_PLACE = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 39. Próximo passo exato

> **Executar o recheck adversarial do Documento 34 sobre as correções incorporadas abaixo, antes de qualquer contrato físico ou migration.**


---

## 40. Hardening incorporado após a primeira passagem do Documento 34

Esta seção integra as correções obrigatórias AR-F4-PR01–PR20.

Em caso de leitura ambígua de seções anteriores, as regras abaixo são a interpretação normativa desta versão revisada.

### 40.1 Maintainable target × intermediate dependency object

PropagationCandidate continua genérico sobre `core.entity_version.version_uuid`, mas dois grupos são distintos:

**maintainable target**

- ProductVersion elegível a UpdatePolicy;
- InvestigationVersion elegível a UpdatePolicy;
- possui ou pode vir a possuir política de manutenção própria.

**intermediate dependency object**

- Report;
- Result;
- Synthesis;
- Certainty;
- ou outro objeto versionado sem UpdatePolicy própria.

`open_update_signal` somente é permitido para maintainable target com UpdatePolicy ativa.

InvestigationVersion `evidence_monitoring` não é target elegível a UpdatePolicy e, portanto, não recebe UpdateSignal próprio por esta rota.

Objeto intermediário usa rota de domínio:

- `method_review_required`;
- `new_version_workflow_required`;
- `dependency_correction_required`;
- `governance_review_required`;
- ou continuation of propagation downstream.

### 40.2 Maintainable target sem policy

Quando o target é mantível, mas não há UpdatePolicy ativa:

> `disposition = maintenance_policy_required`.

Isso:

- não cria policy automaticamente;
- não cria UpdateSignal;
- abre necessidade de decisão de governança.

Somente após a policy aplicável estar ativa poderá ser criado novo UpdateSignal.

### 40.3 Adapter propagation → UpdateSignal

O contrato físico vigente não possui `source_type='propagation_candidate'`.

Além disso, `source_type='entity_version'` não é suficiente para todos os casos, porque uma origem invalidada/archived pode ser precisamente o evento que disparou propagation.

Logo, futuro contrato físico deverá criar linkage estruturado entre o novo UpdateSignal e a avaliação/candidate de propagation, sem falsificar um source existente.

O signal downstream deverá preservar a causalidade real por signal_type vigente quando possível, por exemplo:

- correction;
- retraction;
- expression_of_concern;
- methodology_change;
- regulatory_change.

Não criar signal_type genérico `propagation` que apague a causa.

### 40.4 Cardinalidade de candidate e paths

Baseline:

> uma linha conceitual de PropagationCandidate por `(propagation_assessment_uuid, impacted_version_uuid)`.

Um candidate pode possuir 1:N dependency-path snapshots.

Cada path precisa congelar:

- path sequence de version_uuid;
- dependency_type por aresta;
- depth;
- snapshot timestamp/basis.

Múltiplos paths não criam candidates duplicados.

Múltiplos origin events permanecem avaliações distintas, mesmo quando alcançam o mesmo impacted_version.

### 40.5 Cycle/depth guard

Traversal deve ser cycle-safe:

- não revisitar version_uuid já existente no mesmo path;
- aplicar limite de profundidade explicitamente configurado/contratual;
- registrar issue quando cycle/depth limit impedir avaliação íntegra;
- nunca converter traversal truncada em `no_action_supported`.

### 40.6 Lineage validation status

Como `provenance.dependency_edge` é projeção auxiliar, a avaliação precisa declarar a confiabilidade do snapshot de lineage.

Domínio conceitual mínimo:

- `validated_against_canonical_relations`;
- `projection_only_unverified`;
- `projection_divergence_detected`;
- `incomplete_or_unknown`.

Quando a disposição depende de completude negativa do grafo:

> `no_action_supported` authoritative exige lineage suficientemente validado.

Projection divergence/incompletude abre issue e bloqueia falsa conclusão de ausência de impacto.

### 40.7 Cadeia old target → new target

Rebaseline exige:

- mesma `entity_uuid`;
- tipo/subtipo compatível;
- cadeia versionada auditável;
- temporalidade coerente.

Se houver salto, por exemplo A1 → A4:

- congelar chain A1→A2→A3→A4 ou lineage equivalente;
- registrar versões intermediárias;
- justificar o salto;
- não representar A1→A4 como supersession direta inexistente.

### 40.8 Planned × activated rebaseline

Rebaseline possui ao menos dois estágios conceituais:

- `planned`;
- `activated`.

Planejamento pode ocorrer antes de toda infraestrutura estar pronta.

Ativação exige:

- new target `current`;
- precondições de policy/Monitor/profile aplicáveis satisfeitas;
- authority adequada.

Se o new target for superseded/invalidated antes da ativação:

- a decisão pendente não segue automaticamente a versão mais nova;
- ela deve ser superseded/invalidated conforme contrato futuro;
- nova decisão é anexada para o target subsequente.

### 40.9 Handover de UpdatePolicy

A relação histórica possui dois eixos distintos:

1. `supersedes_update_policy_uuid` — somente same exact target version;
2. rebaseline policy lineage — old target policy → new target policy.

Para handover concluído quando manutenção continua:

- old policy permanece histórica;
- new policy fica ativa no new target;
- helper/readiness deve detectar handover incompleto;
- cross-target supersession continua proibida.

Nenhum campo material da old policy é reescrito.

### 40.10 Ordem causal para M2/M3

Como UpdatePolicy M2/M3 exige governing Monitor com target idêntico:

1. new target deve estar current;
2. RebaselineDecision é preparada;
3. novo Monitor ProductVersion é criado/configurado quando M2/M3;
4. MonitorDefinition/MonitorTarget e estado aplicável ficam coerentes;
5. somente então a new UpdatePolicy M2/M3 pode ser ativada;
6. objetos operacionais prospectivos passam a usar a new policy.

A new policy nunca usa o Monitor antigo como binding transitório para target diferente.

### 40.11 Monitor disposition e lineage

`monitor_disposition` mínimo:

- `continue_same_monitor_lineage`;
- `replace_with_new_monitor_entity`;
- `stop_monitoring`;
- `not_applicable`;
- `pending`.

Quando há continuação da mesma entidade Monitor:

- usar versionamento normal de ProductVersion;
- old Monitor ProductVersion permanece histórico;
- old cycles/Search/EvidenceEvents/CandidateAssessments não são movidos.

Quando há nova entidade Monitor, registrar replacement/coordination explicitamente sem fabricar same-entity lineage.

### 40.12 Coverage partitions

Coverage disposition deve separar ao menos:

- `incorporated_through_new_target_cutoff`;
- `post_cutoff_pending_assessment`;
- `known_gap_carried_forward`;
- `source_recheck_required`;
- `no_carry_forward_supported`.

`evidence_cutoff_date` do new target é a referência científica inicial.

`completed_at` do Monitor anterior não redefine automaticamente baseline.

Coverage debt não desaparece na transição.

### 40.13 Risk-profile readiness

New target não reutiliza old profile UUID.

`risk_profile_disposition` mínimo:

- `reassessment_required`;
- `carry_forward_authorized`;
- `new_assessment_required`;
- `not_applicable`;
- `pending`.

Quando o contrato vigente exigir profile para PriorityAssessment:

> ausência de profile aplicável no new target é issue/readiness blocker, não licença para snapshot informal.

Carry-forward continua sujeito aos guards físicos da migration 030.

### 40.14 SLA Rules no novo target/policy

SLA Rule é policy-bound.

Como `supersedes_sla_rule_uuid` preserva `update_policy_uuid`, rule da old policy:

- não é retargeteada;
- não é superseded cross-policy;
- permanece histórica.

New policy precisa de:

- novas SLA Rules aprovadas/adotadas;
- ou estado explícito `not_configured/pending`.

SLACalendarVersion pode ser reutilizada quando ainda válida e explicitamente adotada.

Nenhuma duração/deadline é copiada por default.

### 40.15 SLA Instance aberta durante handover

Cada obrigação old-policy ainda aberta deve receber disposition explícita:

- `finish_on_old_obligation`;
- `terminate_or_cancel_with_rationale`;
- `supersede_operational_obligation_with_linkage`;
- `open_new_obligation_independently`;
- `governance_review_required`.

Preservar:

- original start;
- original due;
- rule snapshot;
- first breach;
- pause history;
- closure rationale.

Proibido rebase apenas para apagar breach.

### 40.16 Workflow como transition basis

RebaselineDecision pode citar, conforme o caso:

- UpdateDecision;
- WorkflowRound;
- result ProductVersion;
- result InvestigationVersion;
- governance decision.

Isso é especialmente importante quando o próprio workflow old-target produz a nova versão.

Milestones continuam históricos e não são copiados.

`continue_old_target_workflow` só é válido para obrigação legitimamente referente ao old target e não pode masquerar como manutenção do new target.

### 40.17 Priority e escalation

PriorityAssessment e EscalationCase:

- nunca são retargeteados;
- nunca são copiados como estado vigente;
- podem ser citados como provenance/basis para nova avaliação.

Novo target exige nova PriorityAssessment/Escalation quando aplicável.

### 40.18 Concorrência

Se A1→A2 estiver em preparação e A2 for substituída por A3:

- não atualizar `new_target_version_uuid` da decisão existente;
- supersede/invalidar decisão pendente conforme regra futura;
- criar A1/A2→A3 conforme o fato causal real;
- preservar cadeia e rationale.

Nenhuma regra “follow latest automatically” é permitida.

### 40.19 Authority domain

Toda disposition authoritative deve declarar domínio:

- `operational`;
- `scientific`;
- `methodological`;
- `mixed`.

Owner sozinho pode resolver somente decisão puramente operacional dentro de autoridade definida.

Scientific/methodological/mixed authoritative exige human_reviewer/human_expert conforme os contratos existentes.

Carry-forward de cadence, coverage ou risk profile não deve ser classificado artificialmente como operacional quando depender de julgamento científico/metodológico.

### 40.20 M3

Propagation/re-baselining completa é condição necessária, não suficiente, para M3.

Permanece:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL**

Rebaseline incompleto deverá ser blocker futuro de readiness M3.

A aprovação arquitetural deste bloco não remove o blocker.

---

## 41. Estado pós-hardening

> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = REVISED_READY_FOR_RECHECK**

> **PROPAGATION_PHYSICAL_CONTRACT = NOT_AUTHORIZED_UNTIL_DOCUMENT_34_RECHECK**

> **MIGRATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

