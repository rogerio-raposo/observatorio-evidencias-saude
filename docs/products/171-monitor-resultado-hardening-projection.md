# 171 — Monitor de Evidências: Resultado da Validação Técnica do Projection Hardening

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS TÉCNICO DO HARDENING**  
**Dependências:** Documentos 165–170; migrations 021–022

---

## 1. Decisão

> **EVIDENCE_MONITOR_PROJECTION_HARDENING = TECHNICALLY_VALIDATED.**

A migration 022 e sua integração com a migration 021 foram validadas em CI, incluindo testes positivos, adversariais, idempotência e rebuild-from-zero.

Isso:

> **não declara Projection Readiness = READY automaticamente.**

O novo gate metodológico permanece obrigatório.

---

## 2. Implementação validada

Migration:

`database/022_evidence_monitor_projection_hardening.sql`

Fixture atualizada:

`database/f3-evidence-monitor-fixtures.sql`

Suíte:

`database/f3-evidence-monitor-projection-hardening-tests.sql`

Novas estruturas normalizadas:

- `maintenance.candidate_impact`;
- `maintenance.monitor_source_requirement`.

Helpers/guards principais:

- `maintenance.monitor_source_policy_issues(...)`;
- `maintenance.monitor_cycle_source_requirement_status(...)`;
- `maintenance.monitor_search_temporally_acceptable(...)`;
- `maintenance.monitor_cycle_temporal_issues(...)`;
- hardening de `maintenance.assert_monitor_cycle_lifecycle()`;
- `maintenance.guard_cycle_currency_state_mutation()`;
- `product.evidence_monitor_projection_hardening_issues(...)`;
- wrapper endurecido de `product.evidence_monitor_is_publishable(...)`.

---

## 3. Impactos múltiplos

A fixture demonstra um mesmo candidato científico com:

- `quantitative` como impacto primário;
- `certainty` como impacto secundário.

A tabela `candidate_impact` possui:

- cardinalidade 1:N;
- unicidade por classe;
- no máximo um primary;
- imutabilidade;
- inserção somente enquanto o cycle está aberto.

O fechamento do cycle exige, para candidatos `retained_for_impact`:

- pelo menos um impact normalizado;
- exatamente um primary;
- primary coerente com o resumo legado `candidate_assessment.impact_class`.

---

## 4. Source requirements

A fixture M2/M3 agora materializa requisitos normalizados:

- source name;
- source class;
- minimum distinct bibliographic sources.

`source_policy_payload` permanece descritivo/rico.

Obrigações machine-enforced v0.1 passam a ser representadas por:

> `maintenance.monitor_source_requirement`.

O helper de policy detecta campos obrigatórios legados declarados no JSON que não possuam normalização correspondente.

---

## 5. Source exceptions

Exceções reutilizam:

> `investigation.method_decision`

com:

- `decision_code='monitor_source_requirement_exception'`;
- stage `search`;
- cycle UUID;
- requirement code;
- rationale;
- resolution `accepted|mitigated`.

O status por requisito distingue:

- `fulfilled`;
- `exception_applied`;
- `satisfied`.

Assim:

> exceção aceita não é apresentada como execução efetivamente realizada.

---

## 6. Temporal/Search hardening

A migration 022 passa a detectar:

- cycle window anterior ao baseline;
- window posterior à data de conclusão;
- missing previous cycle link;
- gap temporal sem exceção;
- Search Investigation drift;
- Search não completed;
- Search fora da cycle window.

Exceções documentadas usam MethodDecision específico.

Search é revalidada dinamicamente:

> coerência não depende apenas do estado no momento do INSERT em `cycle_search`.

---

## 7. Histórico

`product.evidence_monitor_projection_hardening_issues(...)` percorre:

> **todos os completed cycles da Monitor ProductVersion.**

Assim, drift posterior de uma Search histórica volta a bloquear o produto sem reescrever o cycle original.

---

## 8. Cycle → CurrencyState

O vínculo:

`maintenance.cycle_currency_state`

passou a ser imutável.

Após criação:

- UPDATE = bloqueado;
- DELETE = bloqueado.

Correção de currentness requer:

> nova avaliação/cycle e nova CurrencyState.

---

## 9. Testes MONH

### MONH-T01–T05

Validam:

- múltiplos impacts;
- primary único;
- coerência com resumo legado;
- rejeição de classe duplicada;
- impossibilidade de anexar impact após cycle terminal.

Resultado:

> **PASS**

### MONH-T06–T10

Validam:

- requirement kind desconhecido rejeitado;
- requisitos normalizados avaliados;
- policy obrigatória não normalizada detectada;
- exceção accepted satisfaz sem fingir fulfilled;
- exceção open não satisfaz.

Resultado:

> **PASS**

### MONH-T11–T17

Validam:

- Search fora da window detectada;
- exceção temporal accepted;
- Investigation drift detectado;
- status drift detectado;
- pre-baseline window rejeitada;
- gap não explicado rejeitado;
- gap documentado accepted.

Resultado:

> **PASS**

### MONH-T18–T20

Validam:

- CycleCurrencyState UPDATE bloqueado;
- CycleCurrencyState DELETE bloqueado;
- drift histórico de Search chega ao gate do produto.

Resultado:

> **PASS**

### MONH-T21–T22

Validam:

- M2 formal continua publicável após hardening;
- blocker M3/Fase 4 permanece.

Resultado:

> **PASS**

### MONH-T23

Migration 022 reexecutada no mesmo banco.

Resultado:

> **PASS**

### MONH-T24

Rebuild-from-zero through migration 022, incluindo fixture e suíte de hardening.

Resultado:

> **PASS**

---

## 10. Regressão do contrato 021

A suíte anterior permaneceu verde:

- MON-T01–T32 = PASS.

O antigo MON-T33 foi ajustado para a realidade de cadeia de migrations:

> **reaplicar 021 → 022, nessa ordem, sem regredir o estado endurecido.**

Motivo:

- migrations posteriores podem substituir funções definidas por migrations anteriores;
- reaplicar apenas 021 depois da 022 não representa a ordem canônica de schema e poderia restaurar temporariamente funções pré-hardening.

Resultado:

> **MON-T33 PASS — migration chain 021→022 idempotent re-apply.**

---

## 11. Run intermediário #124

Run:

`37555494528`

Resultado:

> **failure**

Causa:

- testes adversariais legados MON-T19+ criavam cycles temporários com `cycle_no>1` sem `previous_cycle_uuid`;
- o novo hardening corretamente passou a bloquear esse estado antes de o teste chegar ao cenário pretendido.

Correção:

- fixtures temporárias dos testes foram alinhadas ao lifecycle endurecido;
- finalidade dos testes originais foi preservada.

Não foi falha do contrato científico.

---

## 12. Run final #125

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37555588465**

Run number:

> **125**

HEAD validado:

`a66ea298b30ffacda10ce16fe2bc0974362b87fe`

Conclusão:

> **success**

Confirmado:

- migration 022 = PASS;
- MON-T01–T32 = PASS;
- MONH-T01–T22 = PASS;
- MON-T33 = PASS;
- MONH-T23 = PASS;
- MONH-T24/rebuild-through-022 = PASS;
- regressões globais = PASS.

Artifact:

- id **11453649661**;
- name `oes-s5-evidence-37555588465`;
- size **196574 bytes**;
- digest `sha256:002f0a0fdde28bb20bdba9e86263b275bd140d2aec2ae1e67e69f74579089bf6`.

---

## 13. Estado após validação

Migration 021:

> PASS

Migration 022:

> PASS

Projection hardening técnico:

> PASS

Projection Readiness:

> **AINDA NÃO REDECLARADO**

Template readiness:

> NOT_EVALUATED

---

## 14. Próxima etapa

> **Reexecutar adversarialmente o Projection Readiness Gate contra PR-MON-01–05.**

Somente se os cinco blockers estiverem materialmente resolvidos:

> **Projection Readiness = READY**

e então:

> **autorizar migration 023 para EvidenceMonitorView 0.1.**

---

**Resultado final:** migration 022 tecnicamente validada; READY metodológico ainda depende de novo gate explícito.
