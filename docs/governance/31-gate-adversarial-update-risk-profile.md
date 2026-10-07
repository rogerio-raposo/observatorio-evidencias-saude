# 31 — Gate Adversarial do Contrato Físico UpdateRiskProfile

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — correções requeridas antes de migration 030**  
**Dependência:** Documento 30  
**Objeto:** identidade, dimensões, authority, provenance, carry-forward e integração com migration 029

---

## 1. Finalidade

Tentar invalidar o contrato físico candidato antes de autorizar persistência.

O gate testa:

- duplicação de conceito;
- autoridade científica/operacional;
- carry-forward;
- provenance;
- target lineage;
- integração com PriorityAssessment;
- integração com UpdatePolicy;
- invariantes de currentness/assurance/M3;
- ausência de score automático.

---

## 2. Resultado inicial

> **REVISE**

O modelo header + dimensions é adequado, mas há blockers físicos a resolver.

---

## 3. AR-F4-RP01 — dimensão como primeira classe

### Ataque

Persistir somente dez colunas no header impediria:

- autoridade distinta;
- carry-forward por dimensão;
- rationale específica;
- provenance específica.

### Estado

Documento 30 usa linhas dimensionais.

### Resultado

> **PASS**

---

## 4. AR-F4-RP02 — provenance dimensional em JSON

### Ataque

`basis_payload` com arrays de IDs reais ainda não produz integridade referencial.

Isso repete o problema já evitado em PriorityBasis.

### Decisão

Criar quinta estrutura candidata:

> `maintenance.update_risk_profile_dimension_basis`

Com:

- profile_uuid;
- dimension_code;
- source_type;
- locator XOR;
- external_reference_payload quando necessário;
- observation;
- rationale;
- sequence_no.

Source types v0.1:

- monitor_cycle;
- candidate_assessment;
- update_signal;
- alert_product_version;
- entity_version;
- artifact;
- external_reference.

Quando existir objeto OES:

> FK real obrigatória.

### Resultado

> **REVISE_REQUIRED**

---

## 5. AR-F4-RP03 — authority do profile composto

### Ataque

Se owner puder criar profile authoritative sozinho, as dimensões científicas podem estar human-qualified, mas a recomendação composta M0–M3/cadence ainda seria uma síntese metodológica potencialmente criada apenas por governança.

### Decisão

Profile header authoritative exige:

- `profiled_by` human_reviewer ou human_expert;
- verification humana.

B5 continua:

> owner authoritative.

Logo profile authoritative exige, no mínimo:

- qualificação científica no header;
- declaração institucional de B5 por owner.

Isso não cria Assurance A2.

### Resultado

> **REVISE_REQUIRED**

---

## 6. AR-F4-RP04 — A1 authority

A1 é criticidade da decisão/uso, não uma conclusão científica isolada.

Owner pode assess A1 authoritative.

Mas profile composto continua científico/metodológico e exige reviewer/expert no header.

### Resultado

> **PASS_WITH_ARCHITECTURAL_DECISION**

---

## 7. AR-F4-RP05 — B5 owner-only

### Ataque

Pode tornar authoritative profile impossível se não houver owner real.

### Análise

Isso é desejável.

O OES não deve declarar capacidade institucional sustentável autoritativamente sem responsável humano de governança.

Ausência de owner:

> profile permanece proposal/incomplete.

Não fabricar owner.

### Resultado

> **PASS**

---

## 8. AR-F4-RP06 — trigger locators

### Ataque

Vários UUIDs opcionais sem `source_type` podem formar combinações incoerentes.

### Decisão

Adicionar:

- `source_type`;
- locator XOR;
- external_reference_payload somente para external_reference;
- source_type/locator consistency.

Initial baseline pode usar:

> source_type='none'.

### Resultado

> **REVISE_REQUIRED**

---

## 9. AR-F4-RP07 — policy basis lifecycle

### Ataque

Link sem UUID próprio/supersession não permite trocar governing profile sem apagar história.

### Decisão

`update_policy_risk_profile_basis` deve possuir:

- `update_policy_risk_profile_basis_uuid` PK;
- record_status;
- supersedes UUID;
- unique governing active per policy.

### Resultado

> **REVISE_REQUIRED**

---

## 10. AR-F4-RP08 — snapshot adoption

### Ataque

Se migration 030 apenas adicionar profile FK opcional, novos PriorityAssessments poderão continuar indefinidamente snapshot-only e a normalização não produzirá efeito.

### Decisão

Compatibilidade:

- linhas existentes antes da migration permanecem grandfathered snapshot-only;
- **novos INSERTs** após migration 030 devem possuir `update_risk_profile_uuid`;
- proposal pode referenciar profile proposal/authoritative;
- authoritative scientific/mixed exige profile authoritative;
- snapshot deve ser exatamente o serializer canônico do profile.

Não backfill histórico.

### Resultado

> **REVISE_REQUIRED**

---

## 11. AR-F4-RP09 — policy adoption

### Ataque

Obrigar imediatamente todo UpdatePolicy existente a possuir governing profile fabricaria provenance.

### Decisão

- políticas históricas permanecem sem link fabricado;
- novas policies poderão ser submetidas a readiness/gate que exige governing profile;
- migration 030 não deve backfill governing link;
- não criar profile retroativo só para preencher policy.

Não impor FK obrigatória retroativa.

### Resultado

> **PASS_WITH_ARCHITECTURAL_DECISION**

---

## 12. AR-F4-RP10 — carry-forward lineage

Documento 30 exige:

- mesmo entity_uuid;
- mesmo tipo;
- target version diferente;
- source authoritative.

Correto.

Acrescentar:

- profile carry_forward `effective_at >= source_profile.effective_at`;
- dimensão carried_forward deve apontar ao source profile definido pelo header no carry-forward entre versões;
- reassessment same-target deve apontar ao profile supersedido.

### Resultado

> **PASS_WITH_CLARIFICATION**

---

## 13. AR-F4-RP11 — exactly ten dimensions

Authoritative profile não pode existir parcialmente.

Como header e child rows são escritos na mesma transação:

> constraint trigger deferred é apropriado.

### Resultado

> **PASS**

---

## 14. AR-F4-RP12 — proposal completeness

### Ataque

Exigir dez dimensões até para proposal impediria construção incremental.

### Decisão

Proposal:

- pode ser incompleto;
- issue helper deve listar dimensões ausentes;
- não pode ser usado como authoritative basis.

Authoritative:

> exatamente dez.

### Resultado

> **PASS_WITH_CLARIFICATION**

---

## 15. AR-F4-RP13 — recommendation × cadence

Compatibilidade M0–M3/cadence reutiliza domínio já vigente em UpdatePolicy.

Isso reduz drift sem duplicar uma segunda escala.

### Resultado

> **PASS**

---

## 16. AR-F4-RP14 — A1/A4 high × M0

### Ataque

Seria isso um algoritmo automático?

### Análise

Não.

É regra de não compensação já estabelecida:

- criticidade alta não elimina vigilância;
- A4 high exige capacidade event-driven.

M0/none contradiz essas invariantes.

### Resultado

> **PASS**

---

## 17. AR-F4-RP15 — feasibility ceiling

### Ataque

Usar ordem adequate > strained > insufficient > unavailable poderia parecer score.

### Análise

O contrato não soma valores.

A regra é somente:

> B5 define teto de viabilidade.

Aceitável.

### Resultado

> **PASS**

---

## 18. AR-F4-RP16 — M3 recommendation

### Ataque

Transformar A1/A2/A3 em algoritmo obrigatório para M3 criaria classification automática prematura.

### Decisão

Não criar algoritmo.

Hard guards somente:

- B5 adequate;
- feasibility adequate;
- cadence continuous/hybrid.

A1/A2/A3 permanecem contexto humano com rationale.

M3 segue bloqueado.

### Resultado

> **PASS**

---

## 19. AR-F4-RP17 — currentness

Profile não possui CurrencyState e não altera currentness.

### Resultado

> **PASS**

---

## 20. AR-F4-RP18 — assurance

Human-qualified risk profile não equivale a AssuranceRecord nem independent expert review.

### Resultado

> **PASS**

---

## 21. AR-F4-RP19 — priority drift

### Ataque

Se profile é supersedido, PriorityAssessment antiga poderia parecer usar o novo profile.

### Estado esperado

PriorityAssessment deve conter:

- FK para profile efetivamente usado;
- snapshot canônico congelado.

Supersession posterior do profile:

> não muda a prioridade histórica.

### Resultado

> **PASS_AFTER_SNAPSHOT_ADOPTION_RULE**

---

## 22. AR-F4-RP20 — SLA retroatividade

SLA Instance deve congelar o profile UUID/rule snapshot usado.

Profile novo:

> não recalcula instância.

### Resultado

> **PASS**

---

## 23. AR-F4-RP21 — trigger ≠ signal

Capacity/source observability/dependency changes podem justificar profile reassessment sem criar scientific UpdateSignal.

Correto.

### Resultado

> **PASS**

---

## 24. AR-F4-RP22 — Monitor/Alert

Monitor/Alert podem ser basis/trigger.

Não podem:

- definir dimensão automaticamente;
- criar authoritative profile;
- mudar recommendation automaticamente.

### Resultado

> **PASS**

---

## 25. AR-F4-RP23 — target supersession

Profile de target supersedido continua histórico.

Não retarget.

Novo target:

> initial ou explicit carry-forward.

### Resultado

> **PASS**

---

## 26. AR-F4-RP24 — migration boundary

Nenhuma migration 030 deve ser autorizada enquanto os pontos RP02/RP03/RP06/RP07/RP08 não forem corrigidos.

### Resultado

> **BLOCKED_PENDING_REVISION**

---

## 27. Correções obrigatórias

Documento 30 deve:

1. criar `update_risk_profile_dimension_basis`;
2. usar FKs reais/locator XOR para sources OES;
3. restringir profile header authoritative a reviewer/expert;
4. manter B5 authoritative owner-only;
5. tipar sources de reassessment trigger;
6. adicionar PK/supersession ao policy basis;
7. definir grandfathering snapshot-only;
8. exigir profile FK em novos PriorityAssessment INSERTs após migration 030;
9. exigir snapshot = serializer canônico para novos rows;
10. reforçar regras de carry-forward temporal/source;
11. explicitar proposal incompleto permitido.

---

## 28. Estado

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = REVISE**

> **MIGRATION_030 = NOT_AUTHORIZED**

> **RISK_SCORE = NOT_DEFINED**

> **NUMERIC_CADENCE = NOT_DEFINED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 29. Próximo passo

> **Aplicar as correções ao Documento 30 e reexecutar este gate.**
