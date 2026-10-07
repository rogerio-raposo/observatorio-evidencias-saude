# 168 — Monitor de Evidências: Resultado da Validação Técnica do Contrato v0.1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Monitor de Evidências  
**Data:** 6 de outubro de 2026  
**Status:** **PASS TÉCNICO**  
**Dependências:** Documentos 165–167; migration 021; fixtures/tests do Monitor

---

## 1. Decisão

> **EVIDENCE_MONITOR_CONTRACT_V0_1 = TECHNICALLY_VALIDATED.**

A migration 021, fixtures M2/M3, guards, publication gate, idempotência e rebuild foram validados no workflow integrado S5.

Projection/readiness de View permanece etapa posterior.

---

## 2. Implementação validada

Migration:

`database/021_evidence_monitor_contract.sql`

Fixture:

`database/f3-evidence-monitor-fixtures.sql`

Testes:

- `database/f3-evidence-monitor-tests-a.sql`;
- `database/f3-evidence-monitor-tests-b.sql`.

Schema:

> `maintenance`

Estruturas validadas:

1. `maintenance.monitor_definition`;
2. `maintenance.monitor_target`;
3. `maintenance.monitor_state`;
4. `maintenance.monitor_cycle`;
5. `maintenance.cycle_search`;
6. `maintenance.evidence_event`;
7. `maintenance.candidate_assessment`;
8. `maintenance.cycle_currency_state`.

---

## 3. Semântica confirmada

Foi confirmado que:

- Monitor é Product próprio;
- possui Investigation própria de manutenção;
- herda o nível N do alvo;
- opera em M2/M3;
- Search do Monitor permanece fora da Investigation científica histórica;
- Search/SearchHit permanecem canônicos;
- Monitoring Cycle não é ProductVersion;
- baseline cutoff do Monitor permanece estático;
- cutoffs posteriores pertencem aos ciclos;
- currentness do Monitor e currentness do alvo permanecem distintos;
- cycle pode renovar CurrencyState sem nova ProductVersion científica;
- mudança científica do alvo não é executada silenciosamente pelo Monitor;
- target linkage e dependency edge permanecem explícitos;
- Alert completo não foi implementado;
- thresholds transversais da Fase 4 não foram antecipados.

---

## 4. Hardening de lifecycle

Durante a implementação foi identificado e corrigido um risco estrutural:

> **não permitir adicionar retrospectivamente Search/Event/Candidate a um ciclo já concluído.**

Estado validado:

- cycle inicia aberto;
- Searches/events/candidates são registrados enquanto `planned/running`;
- transição para `completed` valida:
  - cobertura declarada;
  - ausência de candidate pendente;
  - ausência de EvidenceEvent ativo não avaliado;
- após estado terminal:
  - ciclo é materialmente imutável;
  - Search não pode ser anexada;
  - CandidateAssessment não pode ser adicionada/superseded;
  - EvidenceEvent não pode ser adicionado;
- vínculo ao CurrencyState resultante é realizado após fechamento.

EvidenceEvent existente é append-preserving quanto a conteúdo material, admitindo apenas transição de status controlada.

---

## 5. Fixture M2

Fixture formal:

- Product = `evidence_monitor`;
- depth herdada = N2;
- maintenance = M2;
- target = ProductVersion científico N2;
- assurance Monitor = A2;
- expert independent review = ausente;
- publication gate = aberto;
- `publishable=true`.

Cycles:

### Cycle 1

- Search própria do Monitor;
- candidato irrelevante excluído;
- decisão = `no_update_needed`;
- target CurrencyState renovado como `current`;
- nenhuma nova ProductVersion do alvo.

### Cycle 2

- Search própria do Monitor;
- candidato científico retido para impacto;
- EvidenceEvent regulatório avaliado;
- decisão = `evaluate_update`;
- escalation = `evaluate_alert`;
- target CurrencyState = `under_evaluation`;
- nenhuma alteração automática da conclusão científica.

---

## 6. Fixture M3

Fixture M3 demonstra:

- schema e cycles são tecnicamente representáveis;
- source coverage é rastreável;
- assurance pode existir;
- contrato estrutural funciona.

Entretanto:

> **publishable=false**

por blocker explícito:

`M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`

Isso preserva a fronteira:

> **Fase 3 implementa o produto; Fase 4 definirá a política transversal living/update.**

---

## 7. Testes

### MON-T01–T12

Semântica positiva:

- M2 A2 formal publishable;
- assurance do target não é herdado;
- baseline/latest cutoff separados;
- Monitor currency ≠ target currency;
- CurrencyState histórico sem nova ProductVersion;
- Search isolada na Monitor Investigation;
- source policy declarada satisfeita;
- cycles sem erros;
- expert review não obrigatório para M2 v0.1, com warning;
- target under evaluation e alert candidacy transparentes;
- dependency edge explícita;
- M3 bloqueado até Fase 4.

Resultado:

> **PASS**

### MON-T13–T32

Guards adversariais:

- MonitorDefinition imutável;
- MonitorTarget imutável;
- terminal cycle imutável;
- Search não pode ser anexada após conclusão;
- Candidate/Event não podem ser anexados após conclusão;
- Search não pode pertencer a dois cycles;
- Search da Investigation científica do target não pode ser apropriada;
- incomplete cycle não pode declarar `no_update_needed`;
- Monitor pausado não inicia running cycle;
- IA não pode simular human verification;
- pending candidate bloqueia conclusão;
- EvidenceEvent não avaliado bloqueia conclusão;
- source policy da própria instância governa cobertura;
- A1 não publica M2 formal;
- target invalidation dinâmica é detectada;
- ausência de target dependency é detectada;
- provenance invalidada bloqueia publicação;
- CycleCurrencyState incompatível é rejeitado;
- somente um MonitorState ativo.

Resultado:

> **PASS**

### MON-T33

Migration 021 reexecutada no mesmo banco.

Resultado:

> **PASS — idempotent re-apply sem alteração da semântica do gate M2.**

---

## 8. Runs

### Run intermediário #120

Run:

`37553072027`

Resultado:

> **failure**

Causa:

- helper usava `min(uuid)`, função não disponível no PostgreSQL.

Correção:

- substituição por `array_agg(uuid)[1]` sob `count(*)=1`.

Não foi falha científica/metodológica.

### Run #121

Run:

`37553149201`

Resultado:

> **success**

Confirmou migration/tests/rebuild.

Foi detectada apenas inconsistência textual no resumo do workflow:

- linha ainda dizia “rebuild through migration 020” apesar da execução real incluir 021.

### Run final #122

Run:

> **37553271462**

Run number:

> **122**

HEAD validado:

`d7ca356c8cc4d58552a9e52868fce92f27eaad9e`

Conclusão:

> **success**

Confirmado:

- migration 021 = PASS;
- MON-T01–T12 = PASS;
- MON-T13–T32 = PASS;
- MON-T33 = PASS;
- regressões anteriores = PASS;
- rebuild-from-zero through migration 021 = PASS.

Artifact:

- id **11453871816**;
- name `oes-s5-evidence-37553271462`;
- size **194916 bytes**;
- digest `sha256:71dd0b68c92ce3d30832862545ac45efbfb94cba51580d77f2673f12a94fbaf8`.

---

## 9. Estado de readiness

Scientific/functional:

> **PASS**

Architecture:

> **PASS_WITH_ARCHITECTURAL_DECISIONS**

Data contract:

> **PASS**

Migration 021:

> **PASS**

Fixture/tests:

> **PASS**

Rebuild/regressions:

> **PASS**

Projection readiness:

> **PENDING**

Template readiness:

> **NOT_EVALUATED**

---

## 10. Próxima etapa

> **Executar o Projection Readiness Gate da EvidenceMonitorView.**

O gate deverá determinar se as estruturas atuais já permitem uma projeção determinística e auditável para:

- identidade;
- plano;
- estado operacional;
- Monitor currency;
- target identity/currency/assurance;
- latest cycle;
- cycle history;
- Searches;
- EvidenceEvents;
- CandidateAssessments;
- resulting target CurrencyState;
- escalation recommendation;
- assurance;
- publication issues.

Se READY:

> implementar View em migration aditiva 022.

Se NOT_READY:

> documentar lacunas antes de qualquer template.

---

**Resultado final:** contrato técnico do Monitor de Evidências v0.1 validado em PASS; próxima etapa = Projection Readiness Gate.
