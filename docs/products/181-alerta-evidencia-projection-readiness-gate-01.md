# 181 — Alerta de Evidência: Projection Readiness Gate 01

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **Projection Readiness = NOT_READY**  
**Dependências:** Documentos 177–180; migration 024; AL-T01–T30

---

## 1. Finalidade

Revisar adversarialmente se o contrato persistido do Alerta suporta uma `EvidenceAlertView` determinística, histórica e auditável sem interpretação externa nem mutação silenciosa de versões publicadas.

## 2. Resultado

> **NOT_READY**

O contrato científico e a migration 024 permanecem tecnicamente válidos, mas quatro pontos de hardening devem ser resolvidos antes da View.

## 3. PR-ALT-01 — INSERT pós-publicação em AlertSource

Estado: **BLOCKER**.

`maintenance.alert_source` bloqueia UPDATE/DELETE, porém ainda permite acrescentar novas linhas a um AlertVersion já publicado.

Isso permite mudar materialmente a base comunicacional de uma versão publicada sem nova ProductVersion.

Requisito:

> depois de `ProductVersion.status='published'` ou `publication_date IS NOT NULL`, nenhum novo AlertSource poderá ser inserido.

A montagem inicial deverá ocorrer antes da publicação formal.

## 4. PR-ALT-02 — INSERT pós-publicação em affected dimensions

Estado: **BLOCKER**.

`maintenance.alert_affected_dimension` bloqueia UPDATE/DELETE, mas ainda permite novas dimensões depois da publicação.

Isso viola a decisão de que mudança material de dimensão exige nova Alert ProductVersion.

Requisito:

> bloquear INSERT de nova dimensão em AlertVersion já publicada.

## 5. PR-ALT-03 — drift de todas as fontes

Estado: **BLOCKER**.

O publication gate da migration 024 revalida dinamicamente a fonte primary, mas não todas as supporting sources.

Uma fonte supporting pode tornar-se:

- CandidateAssessment superseded;
- EvidenceEvent invalidated/superseded;
- EntityVersion invalidated/archived;
- Artifact inativo;

sem issue específica equivalente no gate.

Requisito:

> helper dinâmico deve avaliar todas as AlertSources e produzir issues por source UUID.

Fonte supporting materialmente inválida não pode desaparecer da auditoria apenas porque a primary continua válida.

## 6. PR-ALT-04 — dependency lineage de EntityVersion source

Estado: **BLOCKER**.

O contrato declara que source EntityVersion deve possuir edge:

> `maintenance_alert_source`

mas migration 024 não exige dinamicamente essa edge no publication gate.

Requisito:

> EntityVersion AlertSource deve exigir dependency edge ativa source-version → AlertVersion.

## 7. Hardening adicional — source_context version-preserving

`product.investigation_link(role='source_context')` é uma relação material do AlertVersion.

Após publicação, a versão não deve permitir:

- novo source_context;
- DELETE de source_context;
- UPDATE que altere o contexto.

Isso será endurecido com trigger especializado e condicionado ao `product_type='evidence_alert'`, sem alterar a semântica dos outros produtos.

## 8. Montagem antes da publicação

Para tornar o lock consistente, a fixture deverá seguir ordem explícita:

1. criar Alert ProductVersion em `under_review`, sem publication_date;
2. inserir source_context;
3. inserir `maintenance.evidence_alert`;
4. inserir sources/dimensions/dependencies;
5. inserir assurance;
6. somente então marcar ProductVersion `published` e definir publication_date.

Alert B permanece under_review.

Esse fluxo torna o estado publicado efetivamente selado.

## 9. Source validity helper

Migration 025 deverá criar helper candidato:

> `maintenance.evidence_alert_source_issues(alert_product_version_uuid)`

com issues determinísticas para todas as sources.

Exemplos:

- `ALERT_SOURCE_CANDIDATE_NOT_ACTIVE`;
- `ALERT_SOURCE_EVENT_NOT_ACTIVE`;
- `ALERT_SOURCE_ENTITY_INVALID`;
- `ALERT_SOURCE_ARTIFACT_NOT_ACTIVE`;
- `MISSING_ALERT_SOURCE_DEPENDENCY`.

## 10. Product hardening helper

Criar:

> `product.evidence_alert_projection_hardening_issues(product_version_uuid)`

agregando:

- source issues;
- source-context cardinality/state;
- target/dependency consistency;
- published-seal invariants relevantes à projeção.

`product.evidence_alert_is_publishable(...)` deverá incorporar esses errors sem mudar warnings científicos/comunicacionais existentes.

## 11. Testes de hardening

Migration 025 deverá adicionar testes ALT-H01–H12, no mínimo:

1. source insert permitido antes de publicação;
2. source insert bloqueado depois de publicação;
3. dimension insert bloqueado depois de publicação;
4. source_context insert bloqueado depois de publicação;
5. source_context delete/update bloqueados depois de publicação;
6. supporting CandidateAssessment superseded detectado;
7. supporting EvidenceEvent invalidado detectado;
8. EntityVersion invalidated detectada;
9. Artifact inativo detectado;
10. EntityVersion source sem dependency detectada;
11. edge correta resolve issue;
12. Alert A e C permanecem publishable após hardening.

Idempotência e rebuild continuam obrigatórios.

## 12. O que não muda

Não mudar:

- classification;
- urgency;
- human verification requirement;
- assurance A0–A3;
- lifecycle;
- target semantics;
- ausência de Alert CurrencyState;
- ausência de scientific conclusion;
- fronteira Fase 3 × Fase 4.

## 13. Decisão

> **EVIDENCE_ALERT_PROJECTION_READINESS = NOT_READY.**

Migration 025 fica reservada ao hardening acima.

A EvidenceAlertView será candidata apenas após novo gate explícito.

---

**Resultado:** contrato 024 tecnicamente PASS; projeção ainda bloqueada por integridade histórica e source-lineage dinâmica.