# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-06  
**Checkpoint:** CP76  
**Checkpoint anterior:** CP75  
**Status:** artefato de continuidade; não normativo  
**Escopo:** validação técnica do contrato v0.1 do Monitor de Evidências

## 1. Marco

> **EVIDENCE_MONITOR_CONTRACT_V0_1 = TECHNICALLY_VALIDATED.**

Documento principal:

`docs/products/168-monitor-resultado-validacao-tecnica.md`

## 2. Implementação

Migration:

`database/021_evidence_monitor_contract.sql`

Fixture:

`database/f3-evidence-monitor-fixtures.sql`

Testes:

- `database/f3-evidence-monitor-tests-a.sql`;
- `database/f3-evidence-monitor-tests-b.sql`.

Schema:

> `maintenance`

Estruturas:

1. `monitor_definition`;
2. `monitor_target`;
3. `monitor_state`;
4. `monitor_cycle`;
5. `cycle_search`;
6. `evidence_event`;
7. `candidate_assessment`;
8. `cycle_currency_state`.

## 3. Semântica validada

- Monitor = Product próprio;
- Investigation própria de manutenção;
- depth N herdada do target;
- maintenance M2/M3;
- Search do Monitor isolada da Investigation científica histórica;
- Search/SearchHit continuam canônicos;
- Monitoring Cycle não é ProductVersion;
- baseline cutoff do Monitor é estático;
- cycle armazena janelas/cutoffs posteriores;
- Monitor Product currency e target scientific currency são dimensões distintas;
- CurrencyState pode ser renovado sem nova ProductVersion científica;
- target conclusion não é alterada silenciosamente;
- assurance do target não é copiada para o Monitor;
- target linkage + dependency edge são explícitos;
- Alert completo permanece fora desta etapa.

## 4. Hardening de lifecycle

A implementação foi corrigida para preservar finalização real de cycle:

- Search/Event/Candidate entram enquanto cycle está aberto;
- `completed` valida source coverage, candidates pendentes e events não avaliados;
- cycle terminal é materialmente imutável;
- Search não pode ser anexada depois do fechamento;
- CandidateAssessment não pode ser adicionado/superseded após fechamento;
- EvidenceEvent não pode ser adicionado após fechamento;
- CycleCurrencyState resultante é ligado após a conclusão.

## 5. M2 e M3

### M2

Fixture formal:

- target N2;
- Monitor N2/M2;
- assurance A2;
- expert independent review ausente;
- absence de expert review = warning;
- `publishable=true` quando demais gates satisfeitos.

### M3

M3 é tecnicamente representável.

Formalmente:

> `publishable=false`

por:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

A política living/update transversal permanece reservada à Fase 4.

## 6. Testes

- MON-T01–T12 = PASS;
- MON-T13–T32 = PASS;
- MON-T33 = PASS — migration 021 idempotent re-apply;
- regressões anteriores = PASS;
- rebuild-from-zero through migration 021 = PASS.

## 7. Evidência CI

Run final:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37553271462**;
- run number **122**;
- HEAD validado: `d7ca356c8cc4d58552a9e52868fce92f27eaad9e`;
- conclusão: **success**.

Artifact:

- id **11453871816**;
- name `oes-s5-evidence-37553271462`;
- digest `sha256:71dd0b68c92ce3d30832862545ac45efbfb94cba51580d77f2673f12a94fbaf8`.

Run #120 falhou somente por incompatibilidade técnica `min(uuid)`, corrigida por agregação UUID compatível.

Run #121 já havia validado o contrato integralmente; o run #122 é a evidência final limpa após correção do texto de status do rebuild.

## 8. Readiness

- scientific/functional = PASS;
- architecture = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data contract = PASS;
- migration 021 = PASS;
- fixtures/tests = PASS;
- idempotência = PASS;
- rebuild/regressions = PASS;
- Projection Readiness = **PENDING**;
- Template Readiness = **NOT_EVALUATED**.

## 9. Ponto exato de retomada

> **Executar o Projection Readiness Gate da EvidenceMonitorView.**

O gate deverá verificar se o modelo atual já consegue projetar deterministicamente:

- identity;
- Question;
- Monitor Investigation;
- plano;
- operational state;
- Monitor currency;
- target identity/depth/cutoff/editorial state/assurance/currency/conclusion;
- latest cycle;
- cycle history;
- Searches;
- EvidenceEvents;
- CandidateAssessments;
- resulting target CurrencyState;
- escalation recommendation;
- quality controls;
- audit/publication issues.

Se READY:

> autorizar migration aditiva 022 para `EvidenceMonitorView`.

Se NOT_READY:

> documentar as lacunas e corrigi-las antes de template.

## 10. Limites

Ainda não:

- iniciar Fase 4;
- definir thresholds transversais;
- definir cadências universais;
- implementar Alert completo;
- criar template do Monitor;
- abrir Caso Real do Monitor.

## 11. Protocolo anti-interrupção

Na retomada:

1. executar Freshness Gate;
2. ler Documentos 165–168;
3. ler migration 021;
4. conferir run 37553271462;
5. executar Projection Readiness antes de qualquer migration de View;
6. preservar separação Monitor × target × Alert × Fase 4.

**Fim do CP76**
