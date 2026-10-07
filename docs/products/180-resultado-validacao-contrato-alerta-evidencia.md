# 180 — Alerta de Evidência: Resultado da Validação Técnica do Contrato v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **PASS TÉCNICO DO CONTRATO v0.1**  
**Dependências:** Documentos 177–179; migration 024

---

## 1. Decisão

> **EVIDENCE_ALERT_CONTRACT_0_1 = TECHNICALLY_VALIDATED.**

A migration 024, fixtures sintéticas, gates de publicação, testes adversariais, idempotência e rebuild-from-zero foram validados.

Isso não declara automaticamente:

> **Projection Readiness = READY.**

Um gate adversarial separado continua obrigatório antes da EvidenceAlertView.

## 2. Implementação

Migration:

`database/024_evidence_alert_contract.sql`

Estruturas:

- `maintenance.evidence_alert`;
- `maintenance.alert_source`;
- `maintenance.alert_affected_dimension`.

Funções/gates:

- `maintenance.alert_context_investigation(...)`;
- guards de consistência e imutabilidade;
- `product.evidence_alert_assurance_level(...)`;
- `product.evidence_alert_publication_issues(...)`;
- `product.evidence_alert_is_publishable(...)`.

## 3. Fixtures

`database/f3-evidence-alert-fixtures.sql` cobre:

- Alert A formal publicado, derivado do Monitor, human_verified, A2;
- Alert B AI-only/A1 bloqueado;
- Alert C direct-source critical, human_verified/A2, sem regra automática Fase 4;
- target ProductVersion e InvestigationVersion;
- múltiplas dimensões;
- source primária/supporting;
- warning de ausência de expert review;
- target currentness/assurance separadas.

## 4. Testes

- AL-T01–T15 = PASS — identidade, target/context, sources, dimensions, assurance e publication gate;
- AL-T16–T29 = PASS — verification semantics, lifecycle, imutabilidade, datas, source-context, dependency, provenance e fronteira Fase 4;
- AL-T30 = PASS — migration 024 reaplicada idempotentemente.

## 5. Run intermediário #131

Run `37559706071` = failure.

Causa:

- AL-T27 criou uma provenance invalidada para testar bloqueio dinâmico;
- o harness tentou apagar `provenance.record` para limpeza;
- o schema OES corretamente proíbe DELETE de provenance histórica.

Correção:

- AL-T27 passou a usar o Alert B como alvo descartável do cenário adversarial;
- nenhuma exclusão de provenance é tentada;
- o ROLLBACK transacional preserva a limpeza;
- nenhum guard de provenance foi relaxado.

Falha classificada como:

> **erro de harness, não falha científica nem do contrato do Alerta.**

## 6. Run final #132

Workflow: **OES PoC-S5 PostgreSQL Validation**

- run: **37559879675**;
- run number: **132**;
- HEAD validado: `180b11324ed19dbf51aa8a902dec4c51f6587025`;
- conclusão: **success**.

Artifact:

- id **11456436623**;
- name `oes-s5-evidence-37559879675`;
- size **210376 bytes**;
- digest `sha256:28974dd66cf678abd3ae3f154e8853894489379bc1293c84ae70980d3fc7886d`.

Confirmado:

- install through migration 024 = PASS;
- Evidence Alert step = PASS;
- AL-T01–T29 = PASS;
- AL-T30 = PASS;
- regressões anteriores = PASS;
- rebuild-from-zero through migration 024 = PASS.

## 7. Limites preservados

Migration 024 não implementa:

- thresholds quantitativos;
- SLA;
- auto-classification;
- auto-escalation;
- auto-publication;
- M3 transversal;
- canais/notificações;
- Fase 4.

## 8. Próxima etapa

> **Projection Readiness Gate adversarial da EvidenceAlertView.**

Somente após READY:

> implementar EvidenceAlertView em migration posterior.

---

**Resultado:** contrato físico v0.1 tecnicamente validado; readiness de projeção permanece decisão separada.