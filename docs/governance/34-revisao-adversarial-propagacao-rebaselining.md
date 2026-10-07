# 34 — Revisão Adversarial da Arquitetura de Propagação e Re-baselining

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — primeira passagem adversarial**  
**Dependências:** Documento 33; Documentos 05–09, 16–32; docs/architecture/28–29; migrations 004, 021–030  
**Objeto:** revisão adversarial da arquitetura candidata de propagation/re-baselining antes de qualquer contrato físico

---

## 1. Finalidade

Testar o Documento 33 contra:

- semântica de identidade/versionamento;
- provenance/dependency;
- UpdatePolicy e UpdateSignal;
- MonitorTarget;
- UpdateRiskProfile;
- Priority/Escalation;
- SLA Rule/Instance;
- workflow;
- currentness/assurance;
- M3;
- concorrência e auditabilidade.

Esta revisão não autoriza migration.

---

## 2. Resultado da primeira passagem

> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = REVISE**

O núcleo arquitetural do Documento 33 é válido, em especial:

- separar propagation de re-baselining;
- proibir retargeting in-place;
- preservar história;
- manter currentness e assurance ortogonais;
- manter M3 bloqueado.

Entretanto, a primeira passagem encontrou lacunas que podem produzir implementação ambígua ou incompatível com os contratos físicos vigentes.

Antes de PASS/PASS_WITH_ARCHITECTURAL_DECISIONS, o Documento 33 deve incorporar as correções das seções 3–22.

---

## 3. AR-F4-PR01 — dependente mantível × objeto intermediário

### Ataque

O Documento 33 permite PropagationCandidate genérico sobre qualquer version_uuid, mas a disposition open_update_signal não distingue:

- ProductVersion;
- InvestigationVersion elegível;
- Evidence Monitor InvestigationVersion;
- Report/Result/Synthesis/Certainty e outros objetos intermediários.

A migration 027 só permite UpdateSignal ligado a UpdatePolicy, e UpdatePolicy não pode ter como target InvestigationVersion de tipo evidence_monitoring.

### Decisão

Definir explicitamente:

- **maintainable target** = ProductVersion ou InvestigationVersion elegível a UpdatePolicy;
- **intermediate dependency object** = objeto versionado sem UpdatePolicy próprio.

Somente maintainable target com policy ativa pode receber open_update_signal.

Objeto intermediário deve usar rota de domínio:

- method_review_required;
- new_version_workflow_required;
- dependency_correction_required;
- governance_review_required;
- ou continuar propagation downstream.

### Resultado

> **REVISE_REQUIRED**

---

## 4. AR-F4-PR02 — candidato mantível sem UpdatePolicy

### Ataque

Um dependente pode ser cientificamente mantível, mas não possuir UpdatePolicy ativa.

A migration 027 rejeita UpdateSignal sem policy ativa.

### Decisão

Adicionar disposition explícita:

> **maintenance_policy_required**

Nenhuma policy pode ser criada automaticamente.

A abertura de policy exige decisão de governança própria; somente após policy ativa poderá existir novo UpdateSignal.

### Resultado

> **REVISE_REQUIRED**

---

## 5. AR-F4-PR03 — fonte do novo UpdateSignal

### Ataque

O contrato atual de update_signal_source não possui source_type propagation_candidate.

Além disso, source_type=entity_version rejeita EntityVersion invalidada/archived, justamente um cenário frequente de propagation por invalidation/retraction.

Usar o upstream diretamente como source pode perder o julgamento intermediário e violar o contrato vigente.

### Decisão

O futuro contrato físico deverá definir adapter explícito para propagation, preferencialmente uma referência estruturada ao PropagationCandidate/Assessment.

A causalidade original deve continuar visível.

O novo signal deverá preservar o tipo causal aplicável:

- correction;
- retraction;
- expression_of_concern;
- methodology_change;
- regulatory_change;
- ou outro tipo vigente coerente.

Não criar um signal_type genérico “propagation” que apague a natureza causal.

### Resultado

> **REVISE_REQUIRED**

---

## 6. AR-F4-PR04 — cardinalidade em múltiplos caminhos

### Ataque

Um mesmo impacted_version pode ser alcançado por múltiplos dependency paths.

Criar um PropagationCandidate por path produziria duplicação de caso.

### Decisão

Baseline candidata:

> um PropagationCandidate por par (PropagationAssessment, impacted_version_uuid).

Os caminhos são 1:N e devem ser congelados separadamente ou em coleção imutável equivalente.

Cada path deve preservar:

- sequência de version_uuid;
- dependency types;
- profundidade;
- timestamp/snapshot basis.

### Resultado

> **REVISE_REQUIRED**

---

## 7. AR-F4-PR05 — ciclos e profundidade

### Ataque

Dependency graph pode conter ciclos acidentais ou relações recursivas.

A PoC existente provenance.report_impact já usa:

- visited path;
- prevenção de revisita;
- limite de profundidade.

O Documento 33 apenas cita “cyclic dependency traversal” como caso adversarial, sem regra operacional.

### Decisão

Traversal futura deve:

- possuir cycle guard explícito;
- não revisitar version_uuid no mesmo path;
- ter limite de profundidade configurado/contratual;
- registrar issue quando ciclo/limite impedir conclusão íntegra;
- nunca interpretar truncamento como “sem impacto”.

### Resultado

> **REVISE_REQUIRED**

---

## 8. AR-F4-PR06 — dependency_edge stale/divergente

### Ataque

dependency_edge é projeção auxiliar regenerável, não fonte primária.

Uma projection stale pode omitir um dependente e produzir no_action_supported incorreto.

### Decisão

Antes de resolução authoritative de escopo negativo, o futuro contrato deverá ter estado de validação de lineage, por exemplo:

- validated_against_canonical_relations;
- projection_only_unverified;
- projection_divergence_detected;
- incomplete_or_unknown.

Se houver divergência/incompletude:

> no_action_supported authoritative fica bloqueado para conclusões que dependam de completude do grafo.

### Resultado

> **REVISE_REQUIRED**

---

## 9. AR-F4-PR07 — old/new target e versões intermediárias

### Ataque

“same entity” é necessário, mas não suficiente.

Pode haver salto A1 → A4 com A2/A3 intermediárias.

Tratá-lo como transição direta apaga lineage.

### Decisão

RebaselineDecision deve exigir:

- mesma entity_uuid;
- tipo/subtipo compatível;
- cadeia de supersession/version lineage auditável.

Salto de versões é permitido apenas com:

- chain snapshot;
- identificação das versões intermediárias;
- rationale explícito;
- ausência de reinterpretar o salto como supersession direta.

### Resultado

> **REVISE_REQUIRED**

---

## 10. AR-F4-PR08 — estado da nova versão

### Ataque

Uma decisão pode ser preparada enquanto new target ainda é draft, mas não deve ativar manutenção formal sobre versão não current.

Também pode ocorrer A2 ser substituída por A3 durante o handover.

### Decisão

Separar:

- **planned rebaseline**;
- **activated rebaseline**.

Ativação exige new target current.

Se new target deixar de ser current antes da ativação:

- decisão em andamento deve ser superseded/invalidated conforme contrato futuro;
- nova decisão deve ser criada para o novo target;
- proibido seguir automaticamente “latest version”.

### Resultado

> **REVISE_REQUIRED**

---

## 11. AR-F4-PR09 — finalização old policy → new policy

### Ataque

O Documento 33 exige nova policy, mas não fecha o handover.

Pode surgir estado ambíguo com policy antiga ainda ativa e policy nova já operacional.

### Decisão

O contrato futuro deve distinguir estágio transitório de readiness final.

Para handover concluído quando manutenção continua:

- old policy não permanece operationally governing o target antigo como se ainda fosse current;
- new policy deve estar ativa no new target;
- lineage old-policy → new-policy é separada de supersedes_update_policy_uuid;
- helper deve sinalizar rebaseline incompleto.

Não reescrever a policy antiga.

### Resultado

> **REVISE_REQUIRED**

---

## 12. AR-F4-PR10 — ordenação M2/M3 e Monitor

### Ataque

Migration 027 exige que policy M2/M3 aponte para governing Monitor cujo MonitorTarget seja exatamente o target da policy.

Logo, não é possível ativar new policy M2/M3 antes do novo Monitor estar corretamente materializado.

### Decisão

Ordem causal mínima:

1. new target current;
2. decisão de rebaseline;
3. novo Monitor ProductVersion configurado para new target, quando M2/M3;
4. MonitorTarget/definition/state coerentes;
5. nova UpdatePolicy M2/M3;
6. demais objetos operacionais prospectivos.

Sem target antigo como Monitor transitório da policy nova.

### Resultado

> **REVISE_REQUIRED**

---

## 13. AR-F4-PR11 — lineage do Monitor

### Ataque

Nem toda nova vigilância é necessariamente uma nova versão da mesma entidade Monitor.

Pode ser:

- continuação do mesmo Monitor;
- substituição por outro Monitor;
- encerramento sem sucessor.

### Decisão

RebaselineDecision deve distinguir monitor_disposition:

- continue_same_monitor_lineage;
- replace_with_new_monitor_entity;
- stop_monitoring;
- not_applicable;
- pending.

Quando same lineage:

- usar versionamento normal de ProductVersion do Monitor;
- preservar old cycles;
- nunca mover Search/EvidenceEvent/CandidateAssessment.

### Resultado

> **REVISE_REQUIRED**

---

## 14. AR-F4-PR12 — coverage carry-forward

### Ataque

“preservar coverage debt” é correto, mas insuficiente.

A transição precisa separar evidência já incorporada ao novo target de evidência posterior ainda pendente.

### Decisão

Coverage disposition deverá distinguir ao menos:

- incorporated_through_new_target_cutoff;
- post_cutoff_pending_assessment;
- known_gap_carried_forward;
- source_recheck_required;
- no_carry_forward_supported.

O novo target evidence_cutoff_date é a referência científica inicial.

Old Monitor completed_at não pode virar baseline automático.

### Resultado

> **REVISE_REQUIRED**

---

## 15. AR-F4-PR13 — UpdateRiskProfile no novo target

### Ataque

Migration 030 exige profile físico para novas PriorityAssessments e define carry-forward com lineage guards.

O Documento 33 não explicita readiness quando novo target ainda não possui profile aplicável.

### Decisão

Novo target nunca reutiliza old profile UUID.

Para new target, profile disposition deve ser:

- reassessment_required;
- carry_forward_authorized;
- new_assessment_required;
- not_applicable;
- pending.

Readiness deve bloquear PriorityAssessment nova quando o contrato vigente exigir profile e ele ainda não existir.

### Resultado

> **REVISE_REQUIRED**

---

## 16. AR-F4-PR14 — SLA Rules são policy-bound

### Ataque

O Documento 33 protege SLA Instances, mas não fecha SLA Rules.

Migration 029 estabelece:

- sla_rule.update_policy_uuid obrigatório;
- supersedes_sla_rule_uuid preserva mesma policy e rule_code.

Logo, rule da old policy não pode ser “migrada” para new policy por supersession.

### Decisão

New policy precisa de:

- novas SLA Rules explicitamente aprovadas/adotadas;
- ou estado explícito not_configured/pending.

Old rules permanecem históricas.

Calendário versionado pode ser referenciado novamente se ainda válido, mas isso não autoriza copiar duration/deadline sem calibração/governança.

### Resultado

> **REVISE_REQUIRED**

---

## 17. AR-F4-PR15 — SLA Instance aberta no handover

### Ataque

Uma obrigação antiga pode estar open ou breached quando surge new target.

Criar new instance e apagar/encerrar a antiga sem regra fabricaria desempenho.

### Decisão

Cada old SLA Instance aberta precisa de disposition explícita:

- finish_on_old_obligation;
- terminate_or_cancel_with_rationale;
- supersede_operational_obligation_with_linkage;
- open_new_obligation_independently;
- governance_review_required.

Nunca:

- copiar original_start_at/due_at;
- apagar first breach;
- rebase só para remover breach.

### Resultado

> **REVISE_REQUIRED**

---

## 18. AR-F4-PR16 — old signals e workflow

### Ataque

UpdateSignal é imutável e policy-bound.

WorkflowRound pode estar em andamento no old target e, em alguns casos, justamente produzir a nova versão.

### Decisão

Old signal nunca muda de policy.

Se new target requer manutenção, cria-se novo signal quando aplicável.

RebaselineDecision deve poder citar como transition basis:

- UpdateDecision;
- WorkflowRound;
- result ProductVersion/InvestigationVersion;
- governance decision.

continue_old_target_workflow só é válido quando o objeto histórico continua legitimamente sendo resolvido; não pode masquerar como manutenção da new target.

### Resultado

> **REVISE_REQUIRED**

---

## 19. AR-F4-PR17 — Priority/Escalation históricas

### Ataque

Uma implementação pode tentar “carregar” resposta prioritária ou escalation ativa para a nova versão.

### Decisão

PriorityAssessment e EscalationCase históricos nunca são retargeteados.

Novo target exige nova avaliação contextual.

É permitido usar o caso antigo como provenance/basis explícito, sem transformar seu estado em estado corrente do novo target.

### Resultado

> **PASS_WITH_CLARIFICATION**

---

## 20. AR-F4-PR18 — concorrência durante re-baselining

### Ataque

Enquanto A1→A2 está em preparação, A2 pode ser substituída por A3.

Um campo “latest target” mutável produziria history rewrite.

### Decisão

RebaselineDecision é append-preserving.

Mudança de alvo antes da ativação:

- supersede/invalidar decisão pendente de A1→A2;
- criar nova decisão;
- preservar chain e rationale;
- nunca atualizar new_target_version_uuid in-place.

### Resultado

> **REVISE_REQUIRED**

---

## 21. AR-F4-PR19 — authority operacional × científica

### Ataque

Owner pode ter legitimidade operacional, mas não deve autorizar sozinho carry-forward que dependa de julgamento científico/metodológico.

### Decisão

Authority deve ser classificada por domain:

- operational;
- scientific;
- methodological;
- mixed.

Owner pode authoritative somente no domínio puramente operacional autorizado.

Scientific/methodological/mixed authoritative exige fronteira humana qualificada compatível com contratos vigentes.

### Resultado

> **REVISE_REQUIRED**

---

## 22. AR-F4-PR20 — M3 e automação

### Ataque

Uma arquitetura de re-baselining completa pode ser interpretada como o último requisito de M3 e remover blocker automaticamente.

### Decisão

Não.

Propagation/re-baselining é apenas uma condição necessária.

Permanece:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL**

O futuro M3 readiness gate continua separado e deverá incluir todos os domínios já definidos nos Documentos 05, 18, 20, 27 e posteriores.

### Resultado

> **PASS**

---

## 23. Achados preservados como PASS

Permanecem corretos no Documento 33:

1. propagation e re-baselining são fluxos distintos;
2. dependency discovery não é scientific impact;
3. impact não altera CurrencyState automaticamente;
4. assurance permanece separada;
5. UpdatePolicy não deve usar cross-target supersession;
6. MonitorTarget não deve sofrer UPDATE;
7. old cycles/sources permanecem históricos;
8. UpdateRiskProfile old target não é retargeteado;
9. Alerts não são movidos;
10. auto-propagation científica permanece proibida;
11. scheduler/notifications/auto-escalation/numeric SLA estão fora do escopo.

---

## 24. Correções obrigatórias no Documento 33

Antes do recheck final, incorporar:

1. classificação maintainable/intermediate;
2. maintenance_policy_required;
3. adapter/source explícito para propagation→UpdateSignal;
4. cardinalidade candidate + multiple paths;
5. cycle/depth guard;
6. lineage validation status;
7. chain snapshot para skipped versions;
8. planned × activated rebaseline;
9. finalização old/new policy;
10. ordem causal M2/M3;
11. monitor disposition/lineage;
12. coverage partitions;
13. risk-profile readiness;
14. SLA Rules cross-policy;
15. open SLA Instance disposition;
16. workflow/result como transition basis;
17. concurrency;
18. authority domain.

---

## 25. Estado após primeira passagem

> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = REVISE**

> **MIGRATION_031 = NOT_AUTHORIZED**

> **PHYSICAL_CONTRACT = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 26. Próximo passo exato

> **Corrigir o Documento 33 conforme AR-F4-PR01–PR20 e executar recheck adversarial antes de qualquer contrato físico.**
