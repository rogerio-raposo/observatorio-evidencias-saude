# 182 — Alerta de Evidência: Resultado da Validação do Projection Hardening

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Alerta de Evidência  
**Data:** 6 de outubro de 2026  
**Status:** **PASS TÉCNICO DO HARDENING**  
**Dependências:** Documentos 177–181; migrations 024–025

---

## 1. Decisão

> **EVIDENCE_ALERT_PROJECTION_HARDENING = TECHNICALLY_VALIDATED.**

Migration 025:

`database/025_evidence_alert_projection_hardening.sql`

## 2. Hardening validado

- AlertSource não aceita INSERT depois de publicação;
- affected dimensions não aceitam INSERT depois de publicação;
- source_context fica selado em versão publicada;
- ProductVersion do Alert publicado preserva material fields e só permite transições históricas controladas;
- todas as AlertSources são revalidadas dinamicamente;
- Monitor source/context drift é detectado;
- EntityVersion source exige `maintenance_alert_source` dependency ativa;
- source dependency drift é detectado;
- publishability incorpora hardening errors.

## 3. Fixture

Alert A/C agora são montados em `under_review` e só depois de context, sources, dimensions, dependencies e assurance são marcados `published`.

## 4. Testes

- ALT-H01–H12 = PASS;
- ALT-H13 = migration 025 idempotent re-apply PASS;
- AL-T01–T30 permanecem PASS.

## 5. Run intermediário #134

Run `37560438457` = failure.

Causa:

- AL-T14/15 antigos testavam unicidade inserindo em Alert A já publicado;
- o novo sealing corretamente bloqueou o INSERT antes da constraint de unicidade.

Correção:

- AL-T14/15 foram movidos para Alert B `under_review`, preservando sua finalidade específica;
- ALT-H03/04 ficaram responsáveis pelos testes de sealing.

Falha classificada como harness/regression-test adaptation, sem alteração científica.

## 6. Run final #135

- run **37560513048**;
- run number **135**;
- HEAD validado `bb1cd11c1882583b001597044dda94ac34b966af`;
- conclusão **success**;
- rebuild-through-025 = PASS.

Artifact:

- id **11456149431**;
- name `oes-s5-evidence-37560513048`;
- digest `sha256:1606e2b0379910b9100a285fba0dd62d250d07bec70aaa1374d45c797e30fb3b`.

## 7. Próxima etapa

> **Reexecutar Projection Readiness Gate PR-ALT-01–04.**

---

**Resultado:** hardening técnico validado; decisão READY permanece separada.