# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Primeira Temporal Observation Plan Instance

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP113  
**Checkpoint anterior:** CP112  
**Status:** artefato de continuidade; não normativo  
**Escopo:** seleção/especificação da TOPI-N2-DCBTI-01, gate target-specific e pacote de authority para Phase A

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **FIRST_TEMPORAL_OBSERVATION_PLAN_TARGET = N2_RC01_DCBTI_PRODUCTVERSION_1**

> **FIRST_TEMPORAL_OBSERVATION_PLAN_INSTANCE = TOPI_N2_DCBTI_V01**

> **TARGET_SPECIFIC_GATE = PASS_FOR_AUTHORITY_REQUEST_ONLY**

> **PHASE_A_SPECIFICATION = PASS**

> **AUTHORITY_DECISION = PENDING**

> **PHASE_A_EXECUTION = NOT_AUTHORIZED**

> **PHASE_B = BLOCKED**

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 5 não foi iniciada.

## 2. Freshness Gate de entrada

Na retomada do CP112 foi confirmado:

- branch `main`;
- HEAD inicial `8ed80b47c66b3c29dbd34f43e99ea1cd2ced32e3`;
- CP112 vigente;
- nenhum avanço concorrente;
- arquitetura transversal + instância target-specific = PASS_WITH_ARCHITECTURAL_DECISIONS;
- primeira instância autorizada apenas para seleção/especificação.

## 3. Documento 54 — seleção e instância

Arquivo:

`docs/governance/54-primeira-temporal-observation-plan-instance-n2-dcbti.md`

Commit:

`d7d4a6f7ed5a85979cd77c60515f6b8193029f32`

Target selecionado:

- Product `OES-P-2026-000401`;
- ProductVersion `81000000-0000-0000-0000-000000000701`;
- N2/evidence_sheet;
- A2/published;
- Investigation `OES-I-2026-000401`;
- M1.

## 4. Seleção N2 versus N1

N2 foi selecionado sem score total.

Fatores dominantes:

- maior information gain;
- três source ecosystems reais históricos versus um no N1;
- melhor stress-test de source scope e storage semantics;
- melhor capacidade de testar bibliographic source versus registry;
- menor risco de overfitting da primeira instância à PubMed;
- authority feasibility equivalente ao N1.

Trade-off:

- N2 tem maior complexidade/custo;
- isso não domina nesta etapa porque execução ainda não começou.

## 5. Arquitetura da instância

Plan:

> **TOPI-N2-DCBTI-01 v0.1**

Phase A:

- source characterization;
- source-access/data-governance review;
- semantic storage confirmation;
- UpdateRiskProfile evidence preparation;
- characterization effort observation.

Phase B:

> **BLOCKED_PENDING_PHASE_A_RESULT_AND_PLAN_AMENDMENT**

## 6. Candidate sources

Candidates iniciais:

- PubMed/MEDLINE;
- BVS/LILACS;
- ClinicalTrials.gov.

Estado:

> **ADDITIONAL_RELEVANT_SOURCES = UNASSESSED**

Nenhuma claim de completeness.

Production source não foi tratado como future surveillance source por herança automática.

## 7. Measurement schedule

> **NOT_SELECTED**

Razão:

source behavior ainda não foi caracterizado.

Qualquer schedule futuro deverá ser:

- non-normative;
- justificado após Phase A;
- especificado em amendment v0.2;
- re-gated;
- autorizado explicitamente antes da execução.

## 8. Storage semantics

Consolidado:

- Search científica real → `investigation.search` quando semanticamente correta;
- SearchHit/Screening somente para fatos reais;
- source liveness/latency/access probe → artifact/log;
- operator effort/capacity → artifact/log;
- pre-calibration measurement != CadenceObservation;
- nenhuma migration nova nesta etapa.

## 9. UpdateRiskProfile

Phase A pode preparar evidence inputs A1–A5/B1–B5.

Estado:

> **UPDATE_RISK_PROFILE = EVIDENCE_PREPARATION_ONLY**

Nenhum rating authoritative sem authority científica/metodológica apropriada.

## 10. Documento 55 — gate target-specific

Arquivo:

`docs/governance/55-gate-target-specific-topi-n2-dcbti-01.md`

Commit:

`a44779996323b33a8e12e41431e99b33d520959d`

Resultado:

> **PASS_FOR_AUTHORITY_REQUEST_ONLY**

Passes:

- target selection;
- shadow-M2 guard;
- source-scope discipline;
- anti-anchoring;
- storage semantics;
- latency semantics;
- risk-profile boundary;
- review/stopping rule;
- event model;
- replay design;
- capacity boundary.

Execution blockers:

1. `MISSING_EXPLICIT_PHASE_A_EXECUTION_AUTHORITY`;
2. `SOURCE_ACCESS_AND_DATA_GOVERNANCE_REVIEW = PENDING`;
3. start boundary ainda não satisfeita.

## 11. Falha de persistência intermediária

A primeira tentativa de criar o Documento 55 foi bloqueada pela camada de segurança da ferramenta.

Antes de repetir:

- HEAD foi reconsultado;
- arquivo foi verificado como ausente;
- nenhum commit concorrente foi encontrado.

A segunda tentativa, com conteúdo equivalente e mais compacto, foi persistida com sucesso.

Nenhuma duplicação ocorreu.

## 12. Documento 56 — authority package

Arquivo:

`docs/governance/56-pacote-decisao-authority-phase-a-topi-n2-dcbti-01.md`

Commit:

`84f4d71379c4b4bbd6106dfc841d06dee31aae30`

Status:

> **AWAITING_EXPLICIT_OWNER_DECISION**

Decisão exigida:

- APPROVED;
- REVISE;
- ou REJECTED.

A decisão deve ser explicitamente vinculada à:

> **Phase A / Documento 56 / TOPI-N2-DCBTI-01**

Mensagem genérica como “prossiga” ou “ok” não vale como approval.

## 13. Escopo de eventual APPROVED

Uma aprovação do Documento 56 autoriza somente Phase A:

- consulta a documentação/interfaces das candidate sources;
- source characterization;
- locators/retrieval times;
- source-access/data-governance review;
- storage mapping confirmation;
- evidence preparation para UpdateRiskProfile;
- effort de characterization.

Não autoriza:

- Phase B;
- repeated measurement schedule;
- cadence;
- Monitor;
- UpdatePolicy;
- Calibration Dossier;
- normative values;
- scheduler;
- notifications;
- auto-escalation;
- migration nova.

## 14. CI / evidência técnica

Bloco documental/metodológico.

Nenhuma migration, View, validator, template ou workflow alterado.

Nenhum novo run técnico necessário.

## 15. Commits do bloco

- Documento 54: `d7d4a6f7ed5a85979cd77c60515f6b8193029f32`;
- Documento 55: `a44779996323b33a8e12e41431e99b33d520959d`;
- Documento 56: `84f4d71379c4b4bbd6106dfc841d06dee31aae30`;
- STATE: `b7ebadd9b109b8e1d0457f6ed1e81d925f93e1f8`;
- CHANGELOG: `f36e47c2d8b0a7c007a932632ffc2a0cc239073f`.

## 16. Próximo passo exato

> **Aguardar decisão humana explícita do proprietário sobre o Documento 56.**

A resposta deve ser uma das formas abaixo, explicitamente vinculada à Phase A:

- `APPROVED — Phase A / Documento 56 / TOPI-N2-DCBTI-01`;
- `REVISE — Phase A / Documento 56 / TOPI-N2-DCBTI-01`;
- `REJECTED — Phase A / Documento 56 / TOPI-N2-DCBTI-01`.

Se APPROVED:

1. executar novo Freshness Gate;
2. confirmar target current;
3. registrar authority decision;
4. iniciar somente Phase A;
5. não executar Phase B.

## 17. Disciplina de modo

A decisão arquitetural de alta complexidade deste bloco está concluída.

> **Após a decisão de authority, modo médio é suficiente para a execução documental/operacional da Phase A, salvo se surgir nova decisão arquitetural, methodological authority complexa ou lacuna física relevante.**

## 18. Regra de parada

Após ativação do CP113:

> **parar e aguardar a decisão explícita do Documento 56.**

## 19. HEAD antes da criação do CP113

`f36e47c2d8b0a7c007a932632ffc2a0cc239073f`

**Fim do CP113**
