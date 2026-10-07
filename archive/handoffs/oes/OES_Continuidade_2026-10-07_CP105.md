# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Contrato Físico de Calibração Temporal

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP105  
**Checkpoint anterior:** CP104  
**Status:** artefato de continuidade; não normativo  
**Escopo:** contrato físico v0.1 dos pré-requisitos de calibração temporal e gate final

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate e reconciliação

A retomada partiu do CP104.

Confirmado inicialmente:

- HEAD: `537f5a3349e92f27e69cec76e50770e6c02f443c`;
- CP104 vigente;
- sem commits concorrentes.

O bloco produziu:

- Documento 41;
- Documento 42;
- hardening do Documento 41.

Após falha persistente de escrita do conector, o usuário realizou upload manual dos Documentos 41A e 43.

Reconciliação posterior confirmou:

- Documento 41A commit: `3af8f9e1e07a68ca12b29b5d17bf991f7059123f`;
- Documento 43 commit: `1cc02552a57a3fb52559b11c2443b12f3d024902`;
- ambos os uploads foram adicionados em sequência correta sobre `88c068986622c6dd692d1ebb6d5667bcd5d4edd9`;
- Git blob SHA remoto de ambos coincide exatamente com os arquivos locais entregues para upload;
- nenhum outro arquivo foi alterado nesses commits de upload.

## 3. Documentos do bloco

### Documento 41

`docs/governance/41-contrato-fisico-pre-requisitos-calibracao-temporal.md`

Define o contrato físico candidato e seu hardening.

### Documento 41A

`docs/governance/41a-anexo-a-auditabilidade-calibracao-temporal.md`

Integra:

- target current na ativação;
- cadence observations com timestamp causal;
- recurring due congelado;
- resolver sem future leakage;
- due calculation snapshot;
- accountable pause duration congelada;
- warning derivado;
- candidate precision.

### Documento 42

`docs/governance/42-gate-fisico-pre-requisitos-calibracao-temporal.md`

Primeira passagem:

> **REVISE**

### Documento 43

`docs/governance/43-recheck-final-contrato-fisico-calibracao-temporal.md`

Resultado final:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

## 4. Arquitetura física consolidada

O contrato autoriza especificar/implementar infraestrutura para:

1. TemporalCalibrationDossier;
2. authority/basis/candidate/evaluation;
3. CadenceContract;
4. CadenceObligation;
5. CadenceObservation;
6. UpdatePolicy cadence binding;
7. SLACalendar calibration linkage/hardening;
8. FixedDeadlineSource;
9. SLARule calibration/filter hardening;
10. historical/as-of rule resolution;
11. causal start context;
12. canonical SLA resolver;
13. canonical rule snapshot;
14. calendar add/subtract/open-seconds;
15. nominal due calculator;
16. SLAInstance due calculation snapshot;
17. SLAPause due-extension/accountable-duration hardening;
18. warning/breach/escalation/pause payload validators;
19. readiness helpers;
20. explicit technical grandfather registry.

## 5. Decisões arquiteturais críticas

Preservado:

- nenhuma função de score universal;
- hybrid cadence = composição de event-driven + recurring obligations;
- continuous/M3 excluído do CadenceContract v0.1;
- causal filter matrix impede future leakage;
- resolver usa rule-set historical/as-of;
- ausência de rule ≠ not_applicable;
- raw causal start separado de contractual start;
- calendar/date-only sem defaults implícitos;
- business calendar não pode fazer capacity laundering;
- pause overlap proibido;
- pause pós-breach não move due;
- grandfathering não pode ser obtido por backdating;
- due/recurrence facts históricos são congelados;
- timezone database futura não reclassifica fatos históricos.

## 6. Migration 032

Autorizada somente em escopo estrito de infraestrutura.

Nome candidato:

`database/032_temporal_calibration_prerequisites.sql`

Deve incluir:

- schema/guards/helpers necessários;
- synthetic fixtures;
- **F4-TCAL-PH-T01–T230**;
- idempotency;
- rebuild-through-032;
- regressions completas;
- integração S5.

## 7. Explicitamente não autorizado

Migration 032 não poderá inserir:

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
- auto-escalation;
- auto-currentness;
- assurance promotion;
- publication automation;
- M3 unblock;
- fabricated human/expert/owner approvals;
- fabricated historical calibration dossiers.

## 8. Estado técnico

Último PASS técnico canônico permanece:

- workflow: OES PoC-S5 PostgreSQL Validation;
- run ID: 37644296649 (#167);
- technical HEAD: `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- conclusion: success;
- artifact ID: 11494595216;
- digest: `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`.

Nenhuma migration 032 foi criada neste checkpoint.

## 9. Commits principais do bloco

- `0e0cabcffc6cf126f5191fdb6090c8046da71da7` — Documento 41;
- `9dae57c021ece0d9692ad37392bd87bf2e1acef1` — Documento 42;
- `88c068986622c6dd692d1ebb6d5667bcd5d4edd9` — hardening Documento 41;
- `3af8f9e1e07a68ca12b29b5d17bf991f7059123f` — upload manual Documento 41A;
- `1cc02552a57a3fb52559b11c2443b12f3d024902` — upload manual Documento 43;
- `f8f9963c8926219732603413340bcc1a6acbec22` — STATE;
- `2e38b9525aed0be1976e62c4c89e671292ee44fc` — CHANGELOG.

## 10. Estado antes do CP105

HEAD imediatamente antes da criação deste checkpoint:

`2e38b9525aed0be1976e62c4c89e671292ee44fc`

## 11. Próximo passo exato

> **Após a pausa obrigatória, executar novo Freshness Gate e implementar migration 032 + fixtures sintéticas + F4-TCAL-PH-T01–T230, integrar ao S5 e validar camada específica → idempotência → rebuild-through-032 → regressões → S5 canônico.**

Se surgir nova decisão arquitetural não coberta pelos Documentos 39–43:

> **parar a implementação e retornar ao modo alto antes de improvisar.**

## 12. Disciplina de modo

O contrato arquitetural está fechado.

A implementação agora é majoritariamente mecânica:

> **modo médio é suficiente para iniciar a migration 032**, salvo aparecimento de nova decisão arquitetural.

## 13. Regra de parada

Após ativação do CP105:

> **parar e aguardar instrução explícita do usuário antes de iniciar migration 032.**

**Fim do CP105**
