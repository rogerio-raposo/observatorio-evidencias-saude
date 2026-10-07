# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — PASS Técnico do UpdateRiskProfile Físico

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP99  
**Checkpoint anterior:** CP98  
**Status:** artefato de continuidade; não normativo  
**Escopo:** fechamento técnico da migration 030 e da normalização física do UpdateRiskProfile

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_030 = PASS**

> **F4_RP_T01_T87 = PASS**

> **REBUILD_THROUGH_030 = PASS**

> **FULL_REGRESSIONS_AFTER_030 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

A Fase 3 permanece encerrada. A Fase 5 não foi iniciada.

## 2. Freshness Gate de abertura

A implementação retomou a partir do CP98, em modo médio.

Foi confirmado:

- HEAD inicial: `66034cb351c391e149422b6d1aff025278cddb06`;
- checkpoint vigente: CP98;
- migration 030 autorizada e ainda inexistente;
- nenhum commit concorrente;
- escopo mecânico suficientemente fechado para implementação em modo médio.

## 3. Migration 030

Arquivo:

`database/030_update_risk_profile_contract.sql`

Implementação final inclui:

1. `maintenance.update_risk_profile`;
2. `maintenance.update_risk_profile_dimension`;
3. `maintenance.update_risk_profile_dimension_basis`;
4. `maintenance.update_risk_profile_trigger`;
5. `maintenance.update_policy_risk_profile_basis`;
6. validators de dimensão/cadence/feasibility;
7. guards de authority/verification;
8. carry-forward lineage/temporal guards;
9. deferred completeness/dominance validation;
10. serializer canônico;
11. adoção física por novos PriorityAssessments;
12. PriorityBasis `risk_profile`;
13. SLA snapshot do profile usado na prioridade inicial;
14. issue/readiness helpers;
15. M3 blocker preservado.

## 4. Fixtures

Arquivo:

`database/f4-risk-profile-fixtures.sql`

Estado:

> **SYNTHETIC / TEST-ONLY**

Não são dados reais nem defaults normativos.

Profile sintético principal:

`f6000000-0000-0000-0000-000000000001`

Foi usado para testar:

- A1–A5;
- B1–B5;
- authority diferenciada;
- B5 owner-only;
- provenance;
- serializer;
- governing policy basis;
- PriorityAssessment/PriorityBasis/SLA.

Profiles auxiliares preservam cenários de regressão:

- policy 2 proposal;
- A1 high;
- B5 unavailable.

## 5. Adoção por PriorityAssessment

Após migration 030:

- coluna `update_risk_profile_uuid` existe;
- histórico anterior permanece nullable/grandfathered;
- novos INSERTs exigem profile físico;
- authoritative scientific/mixed exige profile authoritative;
- snapshot precisa ser exatamente o serializer canônico.

Não houve backfill fabricado de profiles históricos.

## 6. Serializer

Função:

`maintenance.update_risk_profile_snapshot(profile_uuid)`

Só serializa profile:

- com 10 dimensões;
- outputs mínimos completos;
- shape válido.

Proposal incompleto:

> não é serializer-eligible.

## 7. PriorityBasis

Adicionado:

> `source_type='risk_profile'`

com:

- FK para UpdateRiskProfile;
- locator XOR;
- consistência com o profile da PriorityAssessment.

Legacy snapshot basis continua válido historicamente.

## 8. SLA integration

Quando uma nova SLA Instance nasce de `start_priority_assessment_uuid` com profile físico:

> `rule_snapshot_payload.update_risk_profile_uuid`

deve congelar o profile usado.

Novo profile posterior:

> não recalcula instância histórica.

## 9. F4-RP SQL suite

Arquivo:

`database/f4-risk-profile-tests.sql`

Resultado:

> **F4-RP-T01–T84 = PASS**

Cobertura:

- estrutura/target;
- lineage;
- dimensions;
- authority/verification;
- provenance;
- carry-forward;
- recommendations;
- non-compensation;
- feasibility;
- triggers;
- policy basis;
- serializer;
- Priority/SLA integration;
- currentness/assurance invariants;
- M3 blocker.

## 10. T85

> **F4-RP-T85 = PASS**

Migration 030:

- reaplicada idempotentemente;
- T01–T84 permaneceram verdes.

## 11. T86

> **F4-RP-T86 = PASS**

Rebuild-from-zero through migration 030 completado.

Incluiu:

- baseline;
- F2-B/S4/S5;
- F3 Products;
- Monitor;
- Alert;
- F4 Update Protocol;
- UpdateRiskProfile;
- Operational Control.

## 12. T87

> **F4-RP-T87 = PASS**

Regressões completas após migration 030:

- F4-UP;
- F4-OC;
- F2-B;
- S4;
- S5;
- F3 Products;
- Monitor;
- Alert.

## 13. Compatibilidade F4-OC

Após migration 030:

- F4-OC-T01–T69 = PASS;
- F4-OC-T70 = PASS;
- rebuild compatibility = PASS;
- F4-OC-T72 = PASS.

A adaptação dos testes F4-OC não relaxou os cenários originais.

Variantes de risco são representadas por profiles físicos sintéticos correspondentes.

## 14. Run canônica

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

Período:

- created: 2026-10-07T12:04:31Z;
- completed: 2026-10-07T12:05:17Z.

## 15. Artifact

Artifact ID:

> **11480858194**

Nome:

`oes-s5-evidence-37618433929`

Digest:

`sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`

Expiração:

> 2026-11-06T12:05:10Z

## 16. Runs diagnósticas

Runs #153–#160 não são evidência de PASS.

Classificações:

- #153 — workflow/install order error;
- #154 — implementation error detectado por T35;
- #155 — test setup error;
- #156 — workflow/test order error;
- #157 — test brittleness;
- #158 — F4-RP T01–T84 já PASS; falha posterior de test editing em F4-OC;
- #159 — test editing error;
- #160 — test editing error.

Detalhes completos:

`docs/governance/32-resultado-validacao-update-risk-profile.md`

## 17. Documento 32

Arquivo:

`docs/governance/32-resultado-validacao-update-risk-profile.md`

Resultado:

> **PASS — migration 030 e contrato físico UpdateRiskProfile tecnicamente validados**

## 18. M3

Permanece:

> `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

A run #161 contém explicitamente:

> `M3 Phase-4 blocker preserved after UpdateRiskProfile normalization`

Nenhuma mudança de readiness M3 foi autorizada.

## 19. Limites preservados

A migration 030 não:

- cria risk score;
- cria numeric cadence;
- cria numeric SLA;
- altera UpdatePolicy automaticamente;
- cria backfill authoritative;
- muda CurrencyState;
- promove Assurance;
- cria UpdateSignal;
- cria Alert;
- cria scheduler;
- ativa auto-escalation;
- publica;
- propaga ciência automaticamente.

## 20. Technical HEAD × HEAD documental

Technical HEAD da run canônica:

`dc9ced9f91817441d0b87063c55057cde1c3c3b7`

Após a run verde foram feitos apenas commits documentais para:

- Documento 32;
- atualizar Documentos 30–31;
- README;
- database README;
- STATE;
- CHANGELOG;
- continuidade/checkpoint.

Logo:

> a run #161 permanece evidência técnica canônica.

## 21. Estado do repositório antes do CP99

HEAD imediatamente antes da criação deste checkpoint:

`dc9a22c787e9e6f62896821f2c1ef5191638507d`

Mensagem:

`Log UpdateRiskProfile technical PASS`

Após criação/ativação do CP99 haverá commits documentais adicionais.

## 22. Próximo passo

> **AINDA NÃO SELECIONADO.**

Dívidas restantes da Fase 4 incluem, entre outras:

- calibração normativa de SLA durations;
- calendários operacionais reais;
- configuração de SLA Rules reais;
- scheduler;
- notification channels;
- auto-escalation;
- propagation/re-baselining;
- M3 readiness;
- operação humana real;
- eventual hardening adicional identificado por auditoria futura.

Nenhuma dessas frentes será iniciada automaticamente.

## 23. Disciplina de modo

O próximo modo deve ser definido somente após a escolha explícita da dívida.

- arquitetura/metodologia difícil de reverter → modo alto;
- implementação mecânica já especificada → modo médio.

## 24. Regra de visibilidade

Durante trabalho longo:

- atualizações curtas e frequentes;
- se a interface perder mensagens, reconciliar pelo GitHub;
- não presumir que ausência visual significa ausência de commits.

## 25. Regra de parada

Após ativação do CP99:

> **parar e aguardar instrução explícita do usuário.**

**Fim do CP99**
