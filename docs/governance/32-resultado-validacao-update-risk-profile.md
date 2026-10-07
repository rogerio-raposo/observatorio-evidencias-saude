# 32 — Resultado da Validação Técnica do UpdateRiskProfile Físico

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 7 de outubro de 2026  
**Status:** **PASS — migration 030 e contrato físico UpdateRiskProfile tecnicamente validados**  
**Dependências:** Documentos 30–31; migrations 027–030  
**Escopo:** normalização física do UpdateRiskProfile

---

## 1. Resultado

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_030 = PASS**

> **F4_RP_T01_T87 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A validação confirma a implementação física do contrato aprovado nos Documentos 30–31, sem ampliar o escopo metodológico.

---

## 2. Migration 030

Arquivo:

`database/030_update_risk_profile_contract.sql`

Implementa:

1. `maintenance.update_risk_profile`;
2. `maintenance.update_risk_profile_dimension`;
3. `maintenance.update_risk_profile_dimension_basis`;
4. `maintenance.update_risk_profile_trigger`;
5. `maintenance.update_policy_risk_profile_basis`;
6. validators/guards de dimensão, cadence, feasibility, authority e carry-forward;
7. deferred completeness/dominance guard;
8. serializer `maintenance.update_risk_profile_snapshot(uuid)`;
9. adoção física por novos PriorityAssessments;
10. integração PriorityBasis `source_type='risk_profile'`;
11. freeze do profile UUID em SLA Instance quando há PriorityAssessment de início;
12. issue/readiness helpers;
13. preservação explícita do blocker M3.

---

## 3. Fixtures

Arquivo:

`database/f4-risk-profile-fixtures.sql`

As fixtures são:

> **SYNTHETIC / TEST-ONLY**

Não constituem:

- profile real;
- score;
- policy normativa;
- cadence normativa;
- SLA normativo;
- backfill histórico.

O profile sintético principal:

`f6000000-0000-0000-0000-000000000001`

é usado para validar:

- dez dimensões A1–A5/B1–B5;
- authority diferenciada;
- provenance dimensional;
- serializer;
- governing policy basis;
- integração com PriorityAssessment/PriorityBasis/SLA.

---

## 4. Integração com controle operacional

`database/f4-operational-control-fixtures.sql` foi adaptado para:

- referenciar o profile físico;
- gerar `risk_profile_snapshot` pelo serializer canônico;
- usar PriorityBasis `risk_profile`;
- congelar `update_risk_profile_uuid` no snapshot das SLA Instances aplicáveis.

Nenhum snapshot histórico real foi backfillado.

---

## 5. Suíte F4-RP

Arquivo:

`database/f4-risk-profile-tests.sql`

Resultado:

> **F4-RP-T01–T84 = PASS**

Cobertura:

- target XOR e lineage;
- one-active-authoritative;
- proposals;
- immutability;
- reassessment;
- carry-forward;
- dez dimensões;
- value domains;
- authority/verification;
- B5 owner authority sem falsa scientific verification;
- provenance/locator XOR;
- recommendation/cadence;
- A1/A4 non-compensation;
- B5 feasibility ceiling;
- M3 recommendation guards;
- reassessment triggers;
- policy/profile basis;
- serializer/adoption;
- PriorityAssessment;
- PriorityBasis;
- SLA snapshot;
- currentness/assurance invariants;
- ausência de auto-policy/auto-signal/auto-alert;
- M3 blocker.

---

## 6. T85 — migration 030 idempotency

> **F4-RP-T85 = PASS**

A migration 030 foi reaplicada e:

- permaneceu idempotente;
- F4-RP-T01–T84 permaneceram verdes;
- as cinco estruturas físicas continuaram presentes.

---

## 7. T86 — rebuild-from-zero

> **F4-RP-T86 = PASS**

O rebuild canônico foi executado from zero through migration 030, incluindo:

- baseline;
- F2-B/S4/S5;
- F3 Products;
- Monitor;
- Alert;
- F4 Update Protocol;
- F4 UpdateRiskProfile;
- F4 Operational Control;
- respectivas fixtures/testes.

Log canônico:

> `F4-RP-T86 PASS — rebuild-from-zero through migration 030 + UpdateRiskProfile/operational-control fixtures/tests completed`

---

## 8. T87 — regressões completas

> **F4-RP-T87 = PASS**

Permaneceram verdes após migration 030:

- F4-UP;
- F4-OC;
- F2-B;
- S4;
- S5;
- F3 Products;
- Evidence Monitor;
- Evidence Alert.

Log canônico:

> `F4-RP-T87 PASS — F4-UP/F4-OC/F2-B/S4/S5/F3/Monitor/Alert regressions remain green after migration 030`

---

## 9. Compatibilidade F4-OC

Após a normalização física:

> **F4-OC-T01–T69 = PASS**

> **F4-OC-T70 = PASS**

> **F4-OC-T71/rebuild compatibility = PASS**

> **F4-OC-T72 = PASS**

A adaptação da suíte F4-OC preservou a intenção original dos testes:

- novas PriorityAssessments usam profile físico;
- variações de A1/A3/B5 são representadas por profiles sintéticos específicos;
- não foi relaxada a obrigatoriedade de profile físico para novos inserts.

---

## 10. Run canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37618433929** (#161)

Technical HEAD:

`dc9ced9f91817441d0b87063c55057cde1c3c3b7`

Job:

> `postgres-s5`

Job ID:

> **112782351104**

Conclusão:

> **success**

Criada:

> 2026-10-07T12:04:31Z

Concluída:

> 2026-10-07T12:05:17Z

---

## 11. Artifact canônico

Artifact ID:

> **11480858194**

Nome:

`oes-s5-evidence-37618433929`

Digest:

`sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`

Expiração:

> 2026-11-06T12:05:10Z

---

## 12. Evidência de M3

A run #161 registrou explicitamente:

> `M3 Phase-4 blocker preserved after UpdateRiskProfile normalization`

Portanto:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece preservado.**

Migration 030 não autoriza M3 formal.

---

## 13. Runs diagnósticas

As runs anteriores não constituem evidência de PASS.

### #153 — 37617013171

HEAD:

`861529e19eb24917d0f38c2d3dac02a4f4d998da`

Classificação:

> **WORKFLOW / INSTALL ORDER ERROR**

A fixture F4-OC já referenciava `update_risk_profile_uuid` antes de a migration 030 ser instalada no workflow.

Corrigido pela integração da 030 ao S5.

### #154 — 37617498479

HEAD:

`bbe08812e020ea3017b41d649eeb7acf40931948`

Classificação:

> **IMPLEMENTATION ERROR**

T35 demonstrou que profile `initial` ainda aceitava dimensão `carried_forward` devido à ordem do trigger.

O guard foi corrigido.

### #155 — 37617629854

HEAD:

`4228e1bd13006888709bfaacb3a592060f917622`

Classificação:

> **TEST SETUP ERROR**

T59–T61 usavam profile `initial` para testar triggers de reassessment.

Os testes foram corrigidos para `reassessment`.

### #156 — 37617761447

HEAD:

`c1ce6ac08056e1d4be14482c8fba6f4d7d25ee1e`

Classificação:

> **WORKFLOW / TEST ORDER ERROR**

T73 dependia da PriorityAssessment sintética criada pelas fixtures F4-OC, mas a suíte F4-RP executava antes dessas fixtures.

A ordem foi corrigida.

### #157 — 37617907992

HEAD:

`af875411b39b98f57d4edfa20a8857317cbc2716`

Classificação:

> **TEST BRITTLENESS**

T82 dependia de contagem absoluta de UpdateSignals.

Foi substituído por teste de invariância: criar profile não altera a contagem existente.

### #158 — 37618038777

HEAD:

`789e5934164589721791c1556bf7cf474fa2ef3e`

Resultado relevante:

> **F4-RP-T01–T84 PASS**

Falha posterior:

> **TEST EDITING ERROR** na adaptação F4-OC.

Delimitadores de `expect_error` foram corrompidos.

### #159 — 37618101436

HEAD:

`789e5934164589721791c1556bf7cf474fa2ef3e`

Classificação:

> **TEST EDITING ERROR**

Repetiu a falha de delimitador na suíte F4-OC.

### #160 — 37618379049

HEAD:

`a6618c9f0b02771b4ce4dbbd137ddcf8c9274b1f`

Classificação:

> **TEST EDITING ERROR**

Tentativa intermediária ainda mantinha delimitadores incorretos.

A correção final adotou delimitadores nomeados PostgreSQL `$sql$ ... $sql$`.

### #161 — 37618433929

> **CANONICAL PASS**

---

## 14. Invariantes preservadas

Migration 030 não:

- cria risk score;
- cria cadence numérica;
- cria SLA duration;
- muda UpdatePolicy automaticamente;
- faz backfill autoritativo fabricado;
- altera CurrencyState;
- promove Assurance;
- cria UpdateSignal;
- cria Alert;
- cria scheduler;
- ativa auto-escalation;
- publica;
- remove blocker M3.

---

## 15. Estado final

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_030 = PASS**

> **F4-RP-T01–T87 = PASS**

> **REBUILD_THROUGH_030 = PASS**

> **FULL_REGRESSIONS_AFTER_030 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

---

## 16. Próximo passo

Este documento não seleciona automaticamente uma nova dívida da Fase 4.

Próxima retomada:

1. Freshness Gate;
2. confirmar checkpoint pós-PASS;
3. selecionar explicitamente a próxima dívida;
4. decidir modo conforme reversibilidade;
5. não iniciar Fase 5.
