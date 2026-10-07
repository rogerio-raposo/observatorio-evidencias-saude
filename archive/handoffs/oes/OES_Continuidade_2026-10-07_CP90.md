# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Contrato Transversal de Atualização v0.1

**Data do checkpoint:** 2026-10-07  
**Checkpoint:** CP90  
**Checkpoint anterior:** CP89  
**Status:** artefato de continuidade; não normativo  
**Escopo:** Fase 4 — contrato de dados e primeira implementação física do Protocolo Transversal de Atualização

## 1. Marco

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_027 = PASS**

A Fase 3 permanece encerrada e não foi reaberta.

## 2. Documentos consolidados neste bloco

### Documento 07

`docs/governance/07-contrato-dados-protocolo-atualizacao.md`

Status:

> **PASS — contrato físico v0.1 validado**

### Documento 08

`docs/governance/08-gate-coerencia-fisica-protocolo-atualizacao.md`

Resultado:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Autorizou migration 027 somente no escopo das sete estruturas aditivas do contrato.

### Documento 09

`docs/governance/09-resultado-validacao-protocolo-atualizacao.md`

Resultado:

> **PASS — contrato físico v0.1 validado**

## 3. Implementação

Migration:

`database/027_transversal_update_protocol_contract.sql`

Fixtures:

`database/f4-update-protocol-fixtures.sql`

Testes:

`database/f4-update-protocol-tests.sql`

Workflow atualizado:

`.github/workflows/validate-s5.yml`

## 4. Estruturas físicas

Sete estruturas novas no schema `maintenance`:

1. `update_policy`;
2. `update_signal`;
3. `update_signal_source`;
4. `materiality_assessment`;
5. `materiality_dimension`;
6. `update_decision`;
7. `update_decision_currency_state`.

Nenhuma tabela científica existente foi alterada por ALTER TABLE.

## 5. Decisões arquiteturais preservadas

1. `investigation_version.maintenance_level` registra roteamento histórico;
2. `update_policy.effective_maintenance_level` registra regime operacional efetivo;
3. ProductVersion e InvestigationVersion continuam targets distintos;
4. Monitor/Alert não são targets da UpdatePolicy transversal;
5. policy autoritativa não pode ser criada por IA/sistema;
6. M0/M1 não possuem Monitor governante;
7. M2/M3 exigem Monitor governante;
8. signal científico/currentness e signal operacional permanecem separados;
9. signal operacional não confirma sozinho mudança científica material;
10. Alert pode ser source, mas não determina materialidade/currentness;
11. IA pode criar proposal, mas não UpdateDecision autoritativa;
12. decisão autoritativa exige verificação humana também do assessment;
13. InvestigationVersion não recebe CurrencyState artificial;
14. Currentness segue matriz materiality × currency action;
15. múltiplos signals coerentes podem resolver para o mesmo CurrencyState;
16. UpdateDecision não cria versão científica;
17. assurance não é promovido;
18. dependency_edge não é usado para UUIDs operacionais não-versionados.

## 6. M3 permanece bloqueado

A migration 027 permite representar UpdatePolicy M3.

Entretanto:

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

O blocker existente permanece:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

Foi validado que a existência de policy M3 não torna o Monitor M3 formalmente publicável.

## 7. Validação técnica

Bateria:

> **F4-UP-T01–T63 = PASS**

Idempotência:

> **F4-UP-IDEM = PASS**

Rebuild-from-zero through 027:

> **PASS**

Regressões:

- F2-B = PASS;
- S4 = PASS;
- S5 = PASS;
- produtos F3 = PASS;
- Monitor = PASS;
- Alert = PASS.

## 8. Evidência canônica

Workflow:

> **OES PoC-S5 PostgreSQL Validation**

Run:

> **37570978847**

Job:

> `postgres-s5`

HEAD técnico validado:

> `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`

Conclusion:

> **success**

Artifact:

> **11460960487**

Artifact name:

> `oes-s5-evidence-37570978847`

Digest:

> `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`

## 9. Limites ainda não resolvidos

Não foram definidos/implementados:

- thresholds quantitativos;
- durações numéricas de SLA;
- score global de prioridade;
- scheduler;
- notification channels;
- auto-classification;
- auto-escalation;
- propagation automática;
- Monitor re-baselining;
- M3 readiness;
- resulting scientific version linkage especializado;
- auto-publication;
- auto-update científico.

## 10. Commits principais desde CP89

- `8fee86883ca2f4ebfd903c51b9ae0eacd03d34bc` — Define Phase 4 update protocol data contract
- `38c27a0c81a98e03b8b259beb91f240b72636f1c` — Harden Phase 4 update data contract
- `b3297011bd6e0b53af1c46010f44a6d1c0de0d51` — Resolve Phase 4 data contract integrity risks
- `55c1f9ce94662a315051490786727a9ed6738dcb` — Tighten Phase 4 currentness and monitor policy rules
- `6cb02b80d40f128eaee1d6825d5242fd421927f4` — Finalize Phase 4 signal and materiality mappings
- `63c124ee9bbe290d7bc27c3d6c7ff78f6b7dc8d4` — Approve Phase 4 update data contract
- `84bb5dc0b668c950fe5ff49818c1864732b2feef` — Implement Phase 4 transversal update contract
- `a719b77d27b11ebbe3bfdfbc22eaad7882836901` — Add Phase 4 update protocol fixtures
- `6838e80dfed2ba2102603ad6e881330ec4ea9626` — Add Phase 4 update protocol tests
- `98a4eaa5fff5099dae32710218f4e0a3bb62ccba` — Fix Phase 4 update protocol T44 setup
- `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9` — Validate Phase 4 update protocol in S5
- `69fa92bfcee63176d348e867e61ef17b30d9d0f5` — Record Phase 4 update protocol technical PASS
- `c742ec6c62e9f8c9cd4986ad843f980a8ea85afe` — Mark Phase 4 update contract technically validated
- `9a3178bc3ae99357693fb6377152df5513c012dc` — Document Phase 4 update protocol technical PASS

## 11. Ponto exato de retomada

> **Definir a arquitetura transversal de perfis de risco operacional/científico que parametrizará cadence, thresholds, SLAs e prioridade.**

A sequência recomendada é:

1. perfis de criticidade/volatilidade;
2. cadence;
3. thresholds temporais;
4. relógios/classes de SLA;
5. priorização/escalonamento;
6. M3 readiness;
7. propagation/re-baselining.

Não fixar números universais antes de fechar o modelo de risco.

## 12. Disciplina de modo

A implementação mecânica da migration 027 foi concluída e validada.

O próximo passo volta a ser uma decisão metodológica transversal difícil de reverter porque definirá como criticidade, volatilidade, currentness e materialidade governam cadence/SLA/prioridade.

> **Modo alto é apropriado para iniciar o próximo bloco arquitetural.**

**Fim do CP90**
