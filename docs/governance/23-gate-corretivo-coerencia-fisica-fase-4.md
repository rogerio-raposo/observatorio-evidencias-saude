# 23 — Gate de Coerência Física Corretivo pós-Auditoria da Fase 4

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS — migration 028 corretiva autorizada no escopo abaixo**  
**Dependências:** Documentos 05–09, 16–22; migrations 014, 021–027  
**Objeto:** hardening corretivo do contrato físico v0.1 após auditoria retrospectiva

---

## 1. Finalidade

Decidir se os achados do Documento 22 justificam uma migration corretiva aditiva e qual o escopo exato permitido.

Este gate não reabre a arquitetura conceitual da Fase 4.

---

## 2. Resultado

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_CORRECTIVE_MIGRATION_028**

> **MIGRATION_028_SCOPE = UPDATE_PROTOCOL_AUDIT_HARDENING_ONLY**

> **PRIORITY_SLA_PHYSICAL_CONTRACT = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 3. Princípio de preservação histórica

Migration 027 já foi tecnicamente validada e pode ter sido aplicada.

Portanto:

> **não editar migration 027 para alterar seu comportamento histórico.**

A correção deverá ser aditiva em:

`database/028_transversal_update_protocol_audit_hardening.sql`

Ela poderá:

- substituir funções/triggers por versões mais estritas;
- substituir read-only issue helpers;
- adicionar guards/readiness helpers aditivos;
- adicionar índices somente se necessários.

Ela não poderá:

- remover dados;
- reinterpretar registros históricos silenciosamente;
- alterar conclusões científicas;
- criar prioridade/SLA físico.

---

## 4. AR-F4-A01 — UpdateDecision sobre signal invalidado

### Achado

O trigger de UpdateDecision não rejeita explicitamente signal invalidado após o assessment.

### Decisão

No INSERT de UpdateDecision:

> exigir `maintenance.update_signal.status='active'`.

Resultado esperado:

- decisões históricas permanecem;
- novo decision após invalidation é rejeitado;
- supersessão de decision também exige signal ainda ativo.

**Resultado:** HARDEN.

---

## 5. AR-F4-A02 — linkage em decision superseded

### Achado

O linkage CurrencyState exige authority, mas não decision ativa.

### Decisão

Novo linkage exige:

- `authority_status='authoritative'`;
- `record_status='active'`.

Supersessão posterior da decision:

> não invalida linkage histórico já criado.

**Resultado:** HARDEN.

---

## 6. AR-F4-A03 — issue helper de policy

`update_policy_issues` deverá continuar detectando:

- target não-current;
- Monitor não-current;
- M3 blocker.

E deverá também detectar, conforme estado atual:

- target ausente;
- target type proibido quando aplicável;
- M2/M3 sem Monitor;
- M0/M1 com Monitor;
- governing Monitor não-evidence_monitor;
- MonitorTarget ausente;
- governing Monitor com target divergente.

Helpers não modificam dados.

**Resultado:** HARDEN.

---

## 7. AR-F4-A04 — issue helper de signal/source

`update_signal_issues` deverá detectar:

- signal inexistente;
- policy inexistente/não ativa;
- mapping inválido;
- verification metadata inválida;
- primary source count;
- source type/locator incoerente;
- CandidateAssessment superseded;
- EvidenceEvent invalidado;
- EntityVersion invalidated/archived/missing;
- Artifact não-active;
- SearchHit fora de Monitor;
- Monitor-derived source fora do governing Monitor;
- Alert source não é Alert;
- Alert target drift.

**Resultado:** HARDEN.

---

## 8. AR-F4-A05 — issue helper de materiality

`materiality_assessment_issues` deverá detectar:

- assessment inexistente;
- signal inexistente/inactive;
- verification metadata inválida;
- confirmed outcome sem confirmed dimension;
- threat outcome sem threat dimension;
- potentially_material sem potential/uncertain;
- no_material_change com confirmed/threat;
- active assessment supersession incoerente quando detectável.

O helper não bloqueará assessment intermediário apenas por não ter dimensão ainda; registrará issue até completude.

**Resultado:** HARDEN.

---

## 9. AR-F4-A06 — issue helper de decision

`update_decision_issues` deverá detectar:

- decision inexistente;
- signal inexistente/inactive;
- assessment inexistente/superseded;
- signal/assessment mismatch;
- verification/authority incompatível;
- InvestigationVersion com currency action;
- ausência/incoerência de linkage CurrencyState quando action exigir linkage;
- linkage presente com `no_change`;
- target/status histórico incompatível.

Regra histórica importante:

> supersessão normal posterior do CurrencyState não deve gerar issue apenas porque `record_status` deixou de active depois do linkage.

A coerência histórica deve usar:

- target ProductVersion;
- `currency_status` esperado;
- existência do CurrencyState;

sem exigir que continue active no presente.

**Resultado:** HARDEN_WITH_HISTORICAL_RULE.

---

## 10. AR-F4-A07 — plan P01–P63

Criar:

`database/f4-update-protocol-plan-tests.sql`

Com labels:

> **F4-UP-P01–P63**

Cada Pxx corresponde exatamente ao item xx da seção 34 do Documento 07.

A suíte pode usar:

- fixtures existentes;
- transações/rollback;
- inserts temporários;
- helpers `expect_error`;
- checks read-only.

Não renumerar nem apagar T01–T63.

**Resultado:** REQUIRED.

---

## 11. AR-F4-A08 — requisitos que dependem do workflow

Itens 59–63 do plano original incluem:

- idempotência de migrations anteriores;
- idempotência da migration candidata;
- rebuild;
- regressões globais;
- Monitor/Alert.

Esses P59–P63 podem ser demonstrados por:

- checks SQL da suíte quando aplicável;
- passos explicitamente nomeados no workflow;
- assertions finais de workflow.

A evidência deve permitir rastrear requisito → step/log.

**Resultado:** REQUIRED.

---

## 12. AR-F4-A09 — transições M0–M3

Não criar tabela adicional de transition neste hardening.

Enquanto o contrato especializado não existir:

- `rationale` da policy supersedente deve documentar condição motivadora;
- `cadence_policy_payload` e/ou `governance_policy_payload` devem preservar impacto esperado;
- documentação deverá declarar que isso é requisito de uso, ainda não completamente normalizado.

A futura modelagem pode normalizar esses elementos.

**Resultado:** PASS_WITH_ARCHITECTURAL_DECISION.

---

## 13. AR-F4-A10 — não escopo

Migration 028 não pode implementar:

- prioridade global;
- SLA Rule/Instance;
- triage transversal;
- scientific workflow milestones;
- scheduler;
- notification channels;
- auto-escalation;
- propagation;
- Monitor re-baselining;
- M3 readiness;
- quantitative thresholds.

**Resultado:** PASS.

---

## 14. Validação obrigatória

Ordem mínima:

1. instalar baseline through 028;
2. carregar fixtures F4;
3. executar T01–T63;
4. executar P01–P63;
5. reexecutar migration 028;
6. P/T após reapply;
7. rebuild-from-zero through 028;
8. P/T no rebuild;
9. regressões F2-B/S4/S5;
10. regressões Monitor/Alert;
11. confirmar M3 blocker;
12. capturar artifact/digest.

Sem isso:

> não restaurar `TECHNICALLY_VALIDATED`.

---

## 15. Documentação a alinhar após PASS

Somente após nova validação:

- Documento 09 deve receber resultado corretivo;
- Documento 22 muda de REVISE para resolved/closed por referência ao resultado;
- Documento 23 registra PASS executado;
- `database/README.md`;
- `README.md`;
- `STATE.md`;
- `CHANGELOG.md`;
- novo checkpoint.

Documentos 16/18/20:

- corrigir metadata `Dependências`;
- adicionar `Validado por`.

---

## 16. Decisão

> **MIGRATION_028_CORRECTIVE_HARDENING = AUTHORIZED**

Somente no escopo deste gate.

> **PRIORITY_ESCALATION_BLOCK = PAUSED_UNTIL_CORRECTIVE_PASS**

---

## 17. Próximo passo exato

> **Implementar migration 028 corretiva + suíte P01–P63 + integração S5 e executar validação canônica completa.**
