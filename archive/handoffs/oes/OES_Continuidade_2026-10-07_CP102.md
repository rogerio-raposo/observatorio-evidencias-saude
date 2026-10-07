# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — PASS técnico de Propagation/Re-baselining

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP102  
**Checkpoint anterior:** CP101  
**Status:** artefato de continuidade; não normativo  
**Escopo:** implementação e validação técnica da migration 031

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_031 = PASS**

> **F4_PRB_T01_T145 = PASS**

> **MIGRATION_031_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_031 = PASS**

> **GLOBAL_REGRESSIONS_AFTER_031 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada.  
A Fase 5 não foi iniciada.

## 2. Estado de retomada e Freshness Gate

A implementação foi retomada do CP101 em modo médio.

Freshness Gate confirmou:

- HEAD inicial: `17c6c7fc7cb823d2e5f961cd1f1e2f01b39c72e9`;
- checkpoint vigente inicial: CP101;
- nenhuma divergência entre README/STATE/CHANGELOG/CP101;
- nenhum commit concorrente.

## 3. Migration 031

Migration lógica:

`database/031_propagation_rebaseline_contract.sql`

Fragmentos internos:

- `database/031a_propagation_core.sql`;
- `database/031b_propagation_signal_adapter.sql`;
- `database/031c_rebaseline_core.sql`;
- `database/031d_propagation_rebaseline_helpers.sql`;
- `database/031e_rebaseline_child_validators.sql`.

A fragmentação decorre apenas de limite de transporte do conector GitHub.

Os fragments são carregados pela migration lógica dentro de uma única transação.

## 4. Contrato implementado

A migration 031 implementa:

- contract epoch técnico;
- PropagationAssessment;
- PropagationCandidate;
- immutable path snapshots;
- PropagationCandidate → UpdateSignalSource adapter;
- RebaselineDecision;
- normalized rebaseline version chain;
- policy handover;
- Monitor handover;
- risk-profile handover;
- coverage handover;
- SLA rule/instance handover;
- old/new signal disposition;
- workflow handover;
- consistency/immutability validators;
- propagation/rebaseline issue helpers.

## 5. Fixtures e testes

Fixtures:

`database/f4-propagation-rebaseline-fixtures.sql`

Suite:

`database/f4-propagation-rebaseline-tests.sql`

Resultado:

> **F4-PRB-T01–T145 = PASS**

A suíte inclui:

- authority boundaries;
- target classification;
- no-action/path completeness;
- structured signal adapter;
- same-entity rebaseline;
- normalized chain;
- activation uniqueness;
- child target validators;
- currentness orthogonality;
- SLA history preservation;
- M3 blocker.

## 6. Idempotência

Migration 031 reaplicada:

> **PASS**

Também confirmado:

- `contract_epoch.effective_at` preservado;
- schema não duplica constraints;
- suite PRB permanece verde.

## 7. Rebuild

Rebuild-from-zero:

- migrations 001–031;
- fixtures;
- suites anteriores;
- PRB fixtures/tests.

Resultado:

> **REBUILD_THROUGH_031 = PASS**

## 8. Regressões

Permaneceram verdes:

- F2-B;
- S4;
- S5;
- F3 Products;
- Evidence Monitor;
- Evidence Alert;
- F4 Update Protocol;
- F4 Operational Control;
- F4 UpdateRiskProfile.

Resultado:

> **GLOBAL_REGRESSIONS_AFTER_031 = PASS**

## 9. Run canônico

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Evidência:

- run ID: **37644296649**;
- run number: **#167**;
- technical HEAD: `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- job: `postgres-s5`;
- job ID: **112870931087**;
- conclusion: **success**;
- artifact ID: **11494595216**;
- artifact name: `oes-s5-evidence-37644296649`;
- artifact size: **242298 bytes**;
- digest: `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`.

## 10. Runs intermediárias

Runs #163–#166:

- diagnósticas/intermediárias;
- falhas locais de fixture metadata/column alignment e wiring progressivo;
- não são evidência canônica de PASS.

O run #167 substitui essas runs como evidência técnica.

## 11. Correções locais relevantes

Durante a implementação foram corrigidos:

- verification metadata incompleto em fixture;
- column alignment do RebaselineDecision fixture;
- wiring do fragmento 031e;
- negativos de child-target validators.

Nenhuma dessas correções exigiu reabrir o contrato arquitetural.

## 12. Limites preservados

Não foram introduzidos:

- numeric SLA calibration;
- numeric cadence;
- real operational calendar;
- scheduler;
- notifications;
- auto-escalation;
- auto-propagation;
- auto-rebaseline;
- automatic UpdatePolicy/Monitor/UpdateSignal creation;
- automatic currentness write;
- assurance promotion;
- publication automation;
- fabricated human/expert review;
- fabricated historical backfill.

Permanece:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL**

## 13. Commits principais da implementação

- `f05dec0097e1c4ea61479207da1cf7ec8f12a949` — propagation core;
- `64b87641ec721e840c875ce0b79cd22af6ab4e97` — signal adapter;
- `d797747b7e98145e121307ac26fb16cc275e8068` — rebaseline core;
- `c7b40e61139528f4a372a3e3e0ef01a387e9fd54` — readiness helpers;
- `af6221cb2e4cf65cb2ed0fdd3640da6682d17116` — logical migration 031;
- `6d93ad29ab6b116edffe8516a110ddbb53286d4e` — synthetic fixtures;
- `86346ddb16a764dba5f1cfe37c675530609b55ef` — F4-PRB suite;
- `62b6e3f3b7dd92b6b1fd32bc563f87c1654ce5a1` — S5 integration;
- `697a8e79b982e954ccc6d20b20e1dfa3506e0e2b` — child validators;
- `5455ee025fbbfe6ff9bb303efd963334a00bb49d` — fragment 031e wiring;
- `4e60e000c94f2e096640169bd70b02ac6bec293b` — child-validator tests;
- `c59c9b6bae30e5e803af5b8a57c5ef32c417156a` — S5 031e wiring;
- `5da1d932f9509214db6a658a2ed5ca830ec7b6c1` — final technical HEAD;
- `0cef70ee6b402b419b5d4c7b9b5bd77ac788a6e2` — Documento 37;
- `d34beed50a24a6023f7c1e8fa7a1d7fe2944d218` — database README PASS;
- `3f4ea7e44c39ad45e4c0566ed70bb0acd4c84e50` — STATE PASS;
- `262e823222ed13461f7ed4d0bb0e9b84390e5bd1` — CHANGELOG PASS.

## 14. Estado antes do CP102

HEAD imediatamente antes da criação deste checkpoint:

`262e823222ed13461f7ed4d0bb0e9b84390e5bd1`

Technical HEAD validado pelo S5:

`5da1d932f9509214db6a658a2ed5ca830ec7b6c1`

A diferença posterior é exclusivamente documental.

## 15. Próximo passo exato

> **Após a pausa obrigatória do checkpoint, selecionar explicitamente a próxima dívida ainda aberta da Fase 4 com novo Freshness Gate.**

Não iniciar automaticamente:

- M3 readiness;
- scheduler;
- notifications;
- numeric SLA/cadence;
- Fase 5.

## 16. Disciplina de modo

A implementação mecânica encerrou.

A próxima dívida ainda não foi selecionada.

Se a seleção envolver decisão metodológica/arquitetural difícil de reverter:

> **recomendar modo alto antes de executá-la.**

## 17. Regra de parada

Após ativação do CP102:

> **parar e aguardar instrução explícita do usuário.**

**Fim do CP102**
