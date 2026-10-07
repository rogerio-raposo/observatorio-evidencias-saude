# 43 — Recheck Final do Contrato Físico de Calibração Temporal

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS_WITH_ARCHITECTURAL_DECISIONS**  
**Revisa:** Documentos 41, 41A e 42  
**Objeto:** recheck final do contrato físico dos pré-requisitos de calibração temporal

## 1. Resultado

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **SCHEDULER = NOT_AUTHORIZED**

> **NOTIFICATIONS = NOT_AUTHORIZED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A autorização da migration 032 limita-se à infraestrutura necessária para calibração e execução determinística futura. Nenhum valor normativo é autorizado por este gate.

## 2. Recheck dos achados do Documento 42

O hardening persistido no Documento 41 e as clarificações do Documento 41A fecham:

- lifecycle auditável do Calibration Dossier;
- authority scientific/methodological + operational;
- external applicability;
- candidate schemas fechados;
- candidate/object snapshot equality;
- exact-target/risk-profile consistency;
- cadence contract ↔ UpdatePolicy;
- hybrid por composição de obligations;
- exclusão de continuous/M3 do CadenceContract v0.1;
- recurrence anchors fechados;
- month-roll/DST policies;
- grace invariants;
- source-scope proof;
- causal SLA filter matrix;
- historical/as-of rule-set;
- raw causal start versus contractual start;
- resolver failure states;
- date-only fixed deadline sem default;
- calendar add/subtract open seconds;
- warning/escalation time basis;
- business-calendar pause arithmetic;
- overlap/post-breach pause guards;
- explicit grandfather registry;
- calendar effective window;
- calendar candidate equality;
- target current na ativação;
- cadence observations com timestamps causais;
- recurring due congelado;
- due-calculation snapshot;
- accountable pause duration congelada;
- warning derivado;
- candidate precision fechada.

Resultado:

> **AR-F4-TCPH01–TCPH26 = CLOSED**

## 3. Grandfathering final

Migration 032 deverá criar:

> `maintenance.temporal_contract_grandfathered_object`

e registrar somente objetos fisicamente existentes no momento da migration:

- UpdatePolicy;
- SLARule;
- SLACalendarVersion.

Esse registro é técnico.

Não cria:

- approval;
- Calibration Dossier;
- evidence basis;
- human review.

Nova row pós-migration não pode evadir v0.1 por effective_at retroativo.

No rebuild-from-zero:

- não fabricar grandfathering para fixtures inseridas depois;
- fixtures F4 sintéticas devem ser adaptadas ao contrato v0.1.

## 4. Synthetic values em testes

A proibição de valores normativos não impede números exclusivamente sintéticos de teste necessários para validar:

- due arithmetic;
- DST;
- month roll;
- warning;
- pause;
- resolver.

Esses valores devem:

- usar UUIDs/labels explícitos de fixture;
- nunca ser seed de produção;
- nunca ser descritos como policy OES real;
- ser revertíveis/recriáveis no rebuild.

## 5. Migration 032 — escopo autorizado

Nome candidato:

`database/032_temporal_calibration_prerequisites.sql`

Escopo estrito:

1. contract epoch + grandfather registry;
2. TemporalCalibrationDossier;
3. authority/basis/candidate/evaluation;
4. CadenceContract;
5. CadenceObligation;
6. CadenceObservation;
7. UpdatePolicy cadence binding/snapshot guard;
8. SLACalendar calibration linkage/hardening;
9. FixedDeadlineSource;
10. SLARule calibration linkage/filter guards;
11. historical rule-window helpers;
12. causal clock-start context;
13. canonical SLA resolver;
14. canonical rule snapshot;
15. business-calendar add/subtract/open-seconds;
16. nominal due calculator;
17. SLAInstance due-calculation snapshot guards;
18. SLAPause due-extension/accountable-seconds hardening;
19. warning/breach/escalation/pause payload validators;
20. cadence/SLA/readiness issue helpers;
21. synthetic fixtures;
22. **F4-TCAL-PH-T01–T230**;
23. idempotency;
24. rebuild-through-032;
25. regressions F4-PRB/F4-RP/F4-OC/F4-UP/F2-B/S4/S5/F3;
26. S5 integration.

## 6. Explicitamente proibido na migration 032

- real cadence interval;
- real SLA duration;
- real grace;
- real warning lead;
- real post-breach threshold;
- real institutional calendar;
- real normative SLARule;
- real calibrated UpdatePolicy;
- scheduler;
- notification delivery;
- automatic escalation;
- automatic UpdateSignal creation;
- automatic Currentness changes;
- assurance promotion;
- publication automation;
- M3 unblock;
- fabricated human/expert/owner approval;
- fabricated historical calibration dossier.

## 7. Readiness semantics

`temporal_operational_readiness` é operacional.

Não equivale a:

- scientific currentness;
- assurance;
- publication readiness;
- M3 readiness.

M3 continua emitindo:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`.

## 8. Decisão final

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE**

> **F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

## 9. Próximo passo exato

> **Registrar STATE/CHANGELOG e criar CP105. Somente após novo Freshness Gate e novo “Prossiga”, implementar migration 032 + fixtures/testes e integrar ao S5.**

Se a implementação revelar nova decisão arquitetural não coberta pelos Documentos 39–43:

> **parar e retornar ao modo alto antes de improvisar.**
