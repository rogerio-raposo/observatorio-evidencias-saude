# 28 — Gate Adversarial de Coerência Física do Contrato Operacional Integrado

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **REVISE — contrato lógico requer hardening antes de autorizar migration 029**  
**Dependência:** Documento 27  
**Objeto:** triage + priority/escalation + SLA + workflow round/milestone

---

## 1. Finalidade

Testar se o Documento 27 já pode ser traduzido em migration física sem:

- duplicação de verdade;
- seleção ambígua de regra;
- clocks divergentes;
- lifecycle manipulável;
- circularidade;
- autoridade indevida;
- perda de causalidade.

---

## 2. Resultado inicial

> **REVISE**

A integração conceitual está correta, mas o contrato ainda possui blockers físicos.

---

## 3. AR-F4-O01 — âncora UpdatePolicy

Criar outra tabela `operational_plan` duplicaria:

- target;
- versionamento;
- regime;
- governance payload.

Documento 27 reutiliza UpdatePolicy.

**Resultado:** PASS.

---

## 4. AR-F4-O02 — triage autoritativa

### Achado

O modelo diferencia proposal/authoritative e protege invalid/out_of_scope.

### Risco

`invalid_signal` exige que o UpdateSignal termine invalidated, mas uma FK/trigger imediata pode criar problema de ordem transacional:

- inserir triage primeiro → signal ainda active;
- invalidar signal primeiro → ainda não existe triage.

### Decisão

Contrato deve admitir consistência transacional por:

- constraint trigger deferred; ou
- função/transaction helper autoritativa.

Issue helper também deve detectar drift:

> authoritative invalid_signal + signal ainda active.

**Resultado:** REVISE_WITH_IMPLEMENTATION_RULE.

---

## 5. AR-F4-O03 — PriorityAssessment único vigente

Um único PriorityAssessment vigente por UpdateSignal evita conflito de fila.

Stage fica no snapshot histórico.

**Resultado:** PASS.

---

## 6. AR-F4-O04 — PriorityBasis polymorphic locator

### Achado

Documento 27 lista locators candidatos, mas não define:

- `source_type`;
- locator XOR;
- coerência source_type/locator.

### Decisão

PriorityBasis deverá possuir:

- `source_type`;
- exatamente um locator quando source estruturado;
- `snapshot_payload` quando source não possuir tabela física;
- `source_type='snapshot'` para risk/feasibility/dependency sem FK canônica.

Não usar UUID genérico sem integridade.

**Resultado:** REVISE_REQUIRED.

---

## 7. AR-F4-O05 — Escalation authority_status redundante

### Achado

`escalation_case.status` já distingue:

- candidate;
- active;
- acknowledged;
- resolved.

Um segundo `authority_status` pode criar estados contraditórios:

- candidate + authoritative;
- active + proposal.

### Decisão

Remover `authority_status` de escalation_case.

Autoridade de activation deve ser representada por:

- activated_by;
- activation_actor_type;
- activated_at.

**Resultado:** REVISE_REQUIRED.

---

## 8. AR-F4-O06 — Escalation transitions

Definir transições permitidas:

- candidate → active | cancelled_invalidated;
- active → acknowledged | resolved | cancelled_invalidated;
- acknowledged → resolved | cancelled_invalidated.

Não permitir:

- resolved → active;
- cancelled → active;
- acknowledged → candidate.

**Resultado:** REVISE_REQUIRED.

---

## 9. AR-F4-O07 — SLA Rule selector ambiguity

### Blocker

Documento 27 reconhece a ambiguidade, mas não escolhe mecanismo.

Sem resolução determinística, duas rules podem casar com a mesma obligation.

### Decisão

Introduzir:

> `selection_precedence integer > 0`

com unique:

> UpdatePolicy + clock_code + selection_precedence entre rules ativas.

Semântica:

- número menor = avaliado primeiro;
- não é priority score;
- não é peso científico;
- primeira rule cujos filtros fechados casam vence.

A existência de duas rules ativas com a mesma precedência é proibida.

Rule set deve possuir fallback explícito quando aplicável.

**Resultado:** REVISE_REQUIRED.

---

## 10. AR-F4-O08 — endpoint matrix

### Blocker

`endpoint_type` livre permite:

- SLA-1 → publication;
- SLA-3 → triage.

### Decisão

Matriz obrigatória:

- SLA1 → triage;
- SLA2 → materiality;
- SLA3 → update_decision;
- SLA4 → workflow_started;
- SLA5 → scientific_completed;
- SLA6 → review_disposition | publication.

`not_applicable` pertence à SLA Instance, não ao endpoint da Rule.

**Resultado:** REVISE_REQUIRED.

---

## 11. AR-F4-O09 — time_basis determinística

Regras:

### elapsed_time

- target_duration obrigatório e > 0;
- calendar NULL;
- fixed payload vazio/NULL.

### business_calendar

- target_duration obrigatório e > 0;
- calendar version obrigatória;
- fixed payload vazio/NULL.

### fixed_deadline

- target_duration NULL;
- fixed_deadline_rule_payload não vazio e determinístico;
- non-pausable por default;
- calendar apenas se a norma explicitamente exigir transformação calendar-aware.

Rule operacional ativa sem representação determinística:

> proibida.

**Resultado:** REVISE_REQUIRED.

---

## 12. AR-F4-O10 — calendar JSON

### Risco

`weekly_schedule_payload` e `exception_dates_payload` sem shape fechado podem tornar due não reproduzível.

### Decisão

Para v0.1, definir schema lógico fechado:

`weekly_schedule_payload`:

- timezone herdado do calendar;
- weekdays 1–7;
- para cada dia: lista ordenada de intervals `HH:MM-HH:MM`;
- intervals não podem se sobrepor.

`exception_dates_payload`:

- date;
- mode = closed | custom;
- custom intervals quando mode=custom;
- rationale opcional.

Migration futura deve possuir validator functions.

**Resultado:** REVISE_REQUIRED.

---

## 13. AR-F4-O11 — effective_due_at

### Blocker

Persistir `effective_due_at` como campo livre e, simultaneamente, declarar que ele deriva do ledger cria duas fontes de verdade.

### Decisão

Persistir:

- nominal_due_at;
- first_breached_at;
- start/end facts.

Derivar:

> `maintenance.sla_effective_due_at(instance_uuid)`

a partir de:

- rule snapshot;
- calendar snapshot;
- pauses válidas.

Pode existir View/projection materializada futura, mas não campo autoritativo livre.

**Resultado:** REVISE_REQUIRED.

---

## 14. AR-F4-O12 — wall/accountable elapsed

Documento 27 já declara deriváveis, embora os liste entre campos.

### Decisão

Remover da persistência mínima.

Expor por helper/view.

**Resultado:** REVISE_REQUIRED.

---

## 15. AR-F4-O13 — SLA Instance uniqueness

### Blocker

Sem chave de obrigação, podem surgir duas SLA-3 ativas para o mesmo signal.

### Decisão

Cardinalidade:

- SLA1–SLA3: no máximo uma instância vigente por UpdateSignal + clock;
- SLA4–SLA6: no máximo uma instância vigente por WorkflowRound + clock.

Rebase:

- supersede a instância anterior;
- mantém mesma obligation identity;
- exige reason/actor/timestamp;
- não apaga first breach histórico.

**Resultado:** REVISE_REQUIRED.

---

## 16. AR-F4-O14 — workflow_round antes de SLA-4

SLA-4 precisa identificar qual workflow deveria começar.

Logo:

> WorkflowRound planned deve existir antes/ao iniciar SLA-4.

Cadeia:

UpdateDecision authoritative
→ WorkflowRound planned
→ SLA-4
→ workflow_started milestone.

Isso evita SLA-4 sem objeto causal.

**Resultado:** PASS_WITH_CLARIFICATION.

---

## 17. AR-F4-O15 — WorkflowRound result

Result ProductVersion/InvestigationVersion é opcional.

Quando ambos forem permitidos, deve haver:

- no máximo um result primário;
- tipo compatível com target/round;
- nenhum auto-create.

Para `review_revision`, parent round obrigatório.

Para retrabalho aberto por review disposition, exigir:

- `opened_by_workflow_milestone_uuid`.

**Resultado:** REVISE_REQUIRED.

---

## 18. AR-F4-O16 — Milestone adapter

### Blocker

Documento 27 possui vários locator UUIDs, mas não `adapter_type` nem XOR.

### Decisão

Adicionar:

`adapter_type`:

- native_event;
- product_review;
- assurance_record;
- method_decision;
- product_version;
- investigation_version;
- artifact.

Regra:

- structured adapter → exatamente um locator correspondente;
- native_event → nenhum locator estruturado obrigatório, salvo result/reference específica;
- source_type/locator mismatch proibido.

**Resultado:** REVISE_REQUIRED.

---

## 19. AR-F4-O17 — milestone authority

### Scientific workflow started

Pode ser native_event, mas baseline authoritative requer:

- human_reviewer;
- human_expert;
- owner somente para mobilização operacional quando o start científico tiver confirmação humana explícita.

System pode registrar evento somente quando adapta uma fonte estruturada qualificante; não inventa start.

### scientific_workflow_completed

Como afirma prontidão científica para review:

> authoritative native event exige human_reviewer/human_expert.

AI/system pode proposal, não conclusão autoritativa.

### review_disposition

Autoridade vem do objeto adaptado.

### publication

É adapter operacional para publicação já ocorrida.

**Resultado:** REVISE_REQUIRED.

---

## 20. AR-F4-O18 — publication timestamp precision

ProductVersion possui `publication_date date`, não timestamp.

Não fabricar hora.

### Decisão

Publication milestone pode registrar:

- occurred_at preciso quando o sistema editorial possui timestamp auditável;
- senão `occurred_date` + precision=`date`.

SLA com granularidade menor que a precisão disponível:

> não pode usar esse endpoint sem fonte temporal mais precisa.

Evidence Alert possui `issued_at` e pode fornecer precisão maior no seu domínio, embora Alert não seja target científico normal do UpdatePolicy.

**Resultado:** REVISE_REQUIRED.

---

## 21. AR-F4-O19 — review adapter matrix

Os produtos atuais não usam exatamente a mesma governance chain:

- Evidence Sheet usa `product.review_record`;
- outros produtos usam combinações de ReviewRecord, AssuranceRecord e controles N3/N4;
- publication gate final pertence à função especializada do produto.

### Decisão

O contrato precisa de matriz de adapters por endpoint, não “um review universal”.

Baseline:

#### review_disposition

Pode adaptar:

- product.review_record;
- product.assurance_record;
- investigation.method_decision, apenas para workflow metodológico;
- objeto especializado futuro validado por gate.

#### publication

Deve adaptar:

- ProductVersion;
- e verificar função publishability especializada quando existir.

Não usar Assurance approval como sinônimo de publication.

**Resultado:** REVISE_REQUIRED.

---

## 22. AR-F4-O20 — pause lifecycle

### Achado

Pause possui ended_at, mas contrato geral diz material fields imutáveis.

### Decisão

`sla_pause` é stateful limitado:

- open → closed;
- ended_at/closed_by/closed_at preenchidos uma única vez;
- demais campos imutáveis;
- correção semântica = supersede + append.

**Resultado:** REVISE_REQUIRED.

---

## 23. AR-F4-O21 — compliance status temporal

Sem scheduler, `within_target` persistido pode ficar stale após due.

### Decisão

Separar:

- persisted execution events;
- persisted first_breached_at quando breach é materializado;
- derived current compliance helper.

Se compliance_status persistido existir:

- incluir `evaluated_at`;
- readiness/issue helper detecta stale evaluation;
- nenhuma conclusão científica depende dele.

Preferência v0.1:

> derivar current compliance; persistir fatos terminais e first breach.

**Resultado:** REVISE_REQUIRED.

---

## 24. AR-F4-O22 — risk profile sem tabela física

Snapshot JSON evita pseudo-FK.

Risco:

- drift vocabular.

### Decisão

Snapshot deve declarar:

- schema_version;
- assessed_at;
- A1–A5;
- B1–B5;
- rationale/reference.

Validator futuro obrigatório.

Isso é aceitável como ponte.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 25. AR-F4-O23 — Priority × SLA circularity

Com:

- start_priority_assessment_uuid na SLA Instance;
- triggering_sla_instance_uuid apenas em PriorityAssessment posterior;

o ciclo temporal pode ser guardado.

Regra física:

> triggering SLA deve ter created/start anterior ao PriorityAssessment que o referencia.

**Resultado:** PASS_WITH_GUARD.

---

## 26. AR-F4-O24 — Escalation × Priority circularity

Priority pode abrir candidate.

Escalation ativa pode gerar nova PriorityAssessment.

Não permitir:

- atualizar assessment original;
- self-cycle direto.

**Resultado:** PASS_WITH_GUARD.

---

## 27. AR-F4-O25 — currentness/assurance

Contrato mantém ambos externos/read-only.

**Resultado:** PASS.

---

## 28. AR-F4-O26 — M3

Contrato operacional completo não remove blocker automaticamente.

**Resultado:** PASS.

---

## 29. AR-F4-O27 — duração numérica

Schema pode suportar interval.

Nenhuma rule numérica default deve ser inserida pela migration.

**Resultado:** PASS.

---

## 30. AR-F4-O28 — auto-escalation

Candidate mecânico pode ser futuro.

Active automática continua proibida.

**Resultado:** PASS.

---

## 31. Correções obrigatórias

Antes de autorização física, Documento 27 deve:

1. definir consistência transacional de invalid triage;
2. fechar PriorityBasis source_type/locator XOR;
3. remover authority_status redundante de escalation;
4. fechar transitions da escalation;
5. adicionar selection_precedence determinística à SLA Rule;
6. fechar endpoint matrix;
7. fechar time_basis matrix;
8. fechar schema de calendar payload;
9. tornar effective_due derivado;
10. remover elapsed derivados da persistência;
11. definir unicidade das SLA obligations;
12. definir metadata de rebase;
13. exigir WorkflowRound planned para SLA-4;
14. adicionar opened_by_milestone em revision rounds;
15. adicionar milestone adapter_type + XOR;
16. fechar authority dos milestones;
17. preservar precisão temporal de publication;
18. definir adapter matrix;
19. fechar lifecycle de pause;
20. preferir compliance derivado;
21. versionar risk snapshot;
22. adicionar guards temporais de circularidade.

---

## 32. Estado

Até as correções:

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = REVISE**

> **MIGRATION_029 = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 33. Próximo passo

> **Aplicar as correções ao Documento 27 e reexecutar este gate antes de qualquer migration.**
