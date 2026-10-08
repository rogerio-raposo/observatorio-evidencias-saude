# 64 — Decisão de Autorização e Boundary Técnico da Migration 033

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo Transversal de Atualização  
**Data:** 8 de outubro de 2026  
**Status:** **AUTHORIZED_FOR_IMPLEMENTATION — INFRASTRUCTURE_ONLY**  
**Modo:** alto  
**Dependências:** Documentos 61–63; CP116  
**Objeto:** decidir se a candidate migration 033 deve ser implementada e fixar seu boundary técnico antes de qualquer SQL

## 1. Decisão

À luz do PASS físico do Documento 63 e da lacuna material já demonstrada:

> **MIGRATION_033 = AUTHORIZED_FOR_IMPLEMENTATION**

A autorização é estritamente de infraestrutura.

Ela não autoriza:

- materialização real da TOPI-N2-DCBTI-01;
- source rows reais;
- authority real;
- Observation Epoch real;
- measurement opportunities reais;
- measurement events reais;
- measurement schedule real;
- Phase B;
- qualquer valor temporal normativo.

## 2. Razão para implementar

Sem a camada 033, repeated pre-calibration measurement só poderia ser representada por objetos semanticamente inadequados ou por Artifacts sem estrutura relacional suficiente.

O Documento 63 confirmou que a lacuna é material para:

- planned opportunity identity;
- attempts/retries;
- explicit opportunity resolution;
- item-level observations;
- item-level source timepoints;
- source debt;
- target/source/epoch consistency;
- authority resolution;
- target drift;
- missingness;
- replay;
- readiness evidence.

Logo a migration possui justificativa arquitetural independente da escolha futura de qualquer schedule.

## 3. Estratégia de arquivos

Adotar o padrão já usado pelas migrations 031 e 032:

> **master lógico + fragments internos**

Arquivo master:

`database/033_non_normative_temporal_observation.sql`

Fragments:

1. `database/033a_temporal_observation_core.sql`
2. `database/033b_temporal_measurement_core.sql`
3. `database/033c_temporal_observation_guards.sql`
4. `database/033d_temporal_observation_helpers_views.sql`
5. `database/033e_temporal_observation_issue_validators.sql`

Racional:

- tamanho do contrato;
- menor risco de transport/edit failure;
- coesão por responsabilidade;
- review técnico mais simples;
- coerência com 031/032.

O master deve:

- declarar dependency 001–032;
- abrir `BEGIN`;
- garantir schema `maintenance`;
- incluir fragments via `\ir`;
- encerrar `COMMIT`.

## 4. Boundary do fragment 033a — plan/source/epoch

Responsabilidade:

- `temporal_observation_plan`;
- `temporal_observation_source`;
- `temporal_observation_epoch`;
- `temporal_observation_epoch_source`;
- `temporal_observation_authority`;
- tipos/checks/índices básicos;
- immutable family fields;
- source semantics payload shape básico;
- finite opportunity-set schedule shape básico.

Não incluir:

- opportunity/event/item;
- readiness views;
- real plan rows.

## 5. Boundary do fragment 033b — opportunity/event/item

Responsabilidade:

- `temporal_measurement_opportunity`;
- `temporal_measurement_event`;
- `temporal_measurement_opportunity_resolution`;
- `temporal_measurement_item`;
- `temporal_measurement_item_timepoint`;
- `temporal_measurement_event_artifact`;
- `temporal_observation_deviation`;
- índices relacionais.

Não incluir:

- real opportunities/events;
- schedule timestamps;
- source-specific seed.

## 6. Boundary do fragment 033c — guards / lifecycle

Responsabilidade:

- recursive forbidden temporal-key validator;
- schedule payload validator;
- source semantics validator;
- effort payload validator;
- plan/source immutability;
- authority consistency;
- authority-state resolver;
- epoch activation/lifecycle guards;
- target-current guard;
- event append/retry guard;
- opportunity resolution guard;
- item/timepoint validators;
- Artifact liveness guards;
- Search semantic guard;
- deviation consistency;
- deferred/closure constraints quando necessário.

Escolha para cross-row consistency:

> **usar DEFERRABLE INITIALLY DEFERRED constraint triggers quando a integridade precisa ser verdadeira no COMMIT e não pode ser avaliada no INSERT do parent.**

Usar explicit closure/issue validators quando a regra representa readiness/completion e não integridade estrutural imediata.

Não enfraquecer invariantes por ordem de INSERT.

## 7. Boundary do fragment 033d — helpers / views

Responsabilidade:

- opportunity status resolver;
- item latency derived helper;
- opportunity-set versus frozen schedule helper;
- replay view;
- readiness-evidence view;
- source-debt exposure;
- effort summaries;
- descriptive missingness metrics.

Proibições:

- nenhuma função retorna READY/NOT READY;
- nenhuma função calcula compliance;
- nenhuma função calcula overdue/breach;
- nenhuma função gera next due;
- nenhuma função cria opportunities automaticamente;
- nenhum scheduler.

## 8. Boundary do fragment 033e — issue validators

Responsabilidade:

- `temporal_observation_plan_issues(uuid)`;
- `temporal_observation_epoch_issues(uuid)`;
- `temporal_measurement_event_issues(uuid)`;
- issue classes TNO definidas no Documento 61;
- artifact/source/authority/target drift;
- source debt hidden;
- retry conflict;
- search mismatch;
- schedule mismatch;
- normative leakage.

Issues são diagnóstico.

Eles não executam remediation automática.

## 9. Marker / contract_epoch

Decisão:

> **NÃO reutilizar maintenance.contract_epoch.**

Migration 033 não criará row em `maintenance.contract_epoch`.

Também não criará uma nova tabela de marker apenas por simetria.

A existência das tabelas/funções e a migration chain são suficientes nesta versão.

Se marker não normativo persistido se tornar necessário, isso será nova decisão.

## 10. Test files

Criar:

1. `database/f4-temporal-observation-fixtures.sql`
2. `database/f4-temporal-observation-smoke-tests.sql`
3. `database/f4-temporal-observation-tests.sql`

### fixtures

Devem ser:

> **SYNTHETIC_TEST_ONLY**

Podem conter:

- Product/Investigation sintéticos;
- Artifacts sintéticos;
- plan/source/epoch sintéticos;
- authorities sintéticas claramente marcadas;
- opportunities/events/items sintéticos.

Não podem usar:

- TOPI-N2 real;
- ProductVersion real `81000000-...`;
- owner decision real;
- real PubMed/NCT observations;
- real measurement schedule.

### smoke

Validar:

- 12 tabelas root;
- helpers essenciais;
- views;
- ausência de normative links;
- ausência de seed real.

### full tests

Implementar:

> **TNO-T01–T90**

Podem ser divididos internamente por seções, mas o primeiro boundary usa um único arquivo de teste para manter uma suite canônica.

Se o tamanho ultrapassar limites de transporte/manutenção durante implementação, a divisão A/B será permitida sem mudar a semântica do boundary.

## 11. Idempotência

A migration 033 deve re-aplicar sem:

- duplicar tabelas/índices/triggers;
- alterar rows existentes;
- criar seed;
- mudar opportunity/event data;
- recriar source semantics reais;
- produzir contract marker temporal normativo.

Padrão esperado:

- `CREATE TABLE IF NOT EXISTS`;
- `CREATE OR REPLACE FUNCTION`;
- `DROP TRIGGER IF EXISTS` + `CREATE TRIGGER`;
- criação defensiva de constraints/índices onde necessário.

Idempotency test deve comparar counts antes/depois.

## 12. Rebuild

Rollback operacional do projeto continua sendo:

> **rebuild-from-zero**

Não criar down migration destrutiva.

O rebuild deve instalar:

001–032 → 033

e então executar:

- smoke 033;
- fixtures/tests 033;
- regressions canônicas F2-B/S4/S5/F3/F4 já existentes.

## 13. CI canônica

Modificar:

> `.github/workflows/validate-s5.yml`

Não criar workflow paralelo nesta etapa.

Razões:

- validate-s5 já é a cadeia canônica de regressão integral;
- 029–032 já estão integradas nela;
- workflow paralelo aumentaria risco de duas definições de “PASS”.

## 14. Alterações obrigatórias no validate-s5.yml

Adicionar os novos arquivos em:

### path trigger

- 033 master;
- 033a–033e;
- fixtures;
- smoke;
- tests.

### hash evidence

Incluir todos os novos SQL no `sha256sum`.

### installation

Após 032:

> `psql -v ON_ERROR_STOP=1 -f database/033_non_normative_temporal_observation.sql`

### smoke

Executar imediatamente após installation 033.

### fixtures/tests

Carregar fixtures sintéticas e executar full suite TNO.

### idempotency

Reaplicar master 033 e provar:

- object count estável;
- row counts estáveis;
- no seed drift;
- tests continuam PASS.

### rebuild

Adicionar 033 ao rebuild-from-zero.

### regressions

Certificar que suites existentes continuam PASS depois da 033.

### evidence artifact

Logs da 033 devem integrar o artifact S5 existente.

## 15. CI output names

Usar prefixo:

> **F4-TNO**

Sugestão:

- `F4-TNO-033.log`;
- `F4-TNO-smoke.log`;
- `F4-TNO-fixtures.log`;
- `F4-TNO-tests.log`;
- `F4-TNO-IDEM-033.log`;
- `F4-TNO-rebuild.log`.

Summary final deverá declarar:

> **F4-TNO-T01–T90 PASS**

somente se a suite realmente passar.

## 16. No-seed guarantee

Migration 033 e fragments não podem conter `INSERT` em:

- temporal_observation_plan;
- temporal_observation_source;
- temporal_observation_epoch;
- temporal_observation_authority;
- temporal_measurement_opportunity;
- temporal_measurement_event;
- temporal_measurement_opportunity_resolution;
- temporal_measurement_item;
- temporal_measurement_item_timepoint;
- temporal_measurement_event_artifact;
- temporal_observation_deviation.

Também não podem conter timestamps/opportunity sets reais.

Tests devem provar as root tables vazias imediatamente após migration 033 antes de fixtures.

## 17. Normative isolation guarantee

Migration/tests devem provar que a 033 não:

- altera UpdatePolicy;
- cria CadenceContract;
- cria CadenceObligation;
- cria CadenceObservation;
- cria SLARule/SLAInstance;
- cria MonitoringCycle;
- cria UpdateSignal;
- altera CurrencyState;
- altera assurance;
- cria scheduler/notification tables.

## 18. Measurement schedule

Permanece:

> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

A migration cria capacidade de armazenar um finite opportunity set.

Ela não escolhe:

- número de opportunities;
- timestamps;
- intervalo;
- duração do epoch;
- periodicidade.

## 19. Phase B

Permanece:

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

A implementação física não constitui approval operacional.

## 20. Autorização

Com este documento:

> **MIGRATION_033 = AUTHORIZED_FOR_IMPLEMENTATION**

Boundary:

> **INFRASTRUCTURE_ONLY / SYNTHETIC_TESTS_ONLY / ZERO_REAL_SEED**

A implementação deverá parar e reportar se descobrir incompatibilidade arquitetural não coberta pelo contrato 61/63.

## 21. Próximo passo exato

Após checkpoint:

> **implementar migration 033 master + fragments, fixtures/smoke/full tests e integração do validate-s5.yml dentro deste boundary; executar CI e somente promover a migration se o conjunto técnico passar.**

Para essa implementação:

> **modo médio é suficiente**, salvo se surgir nova decisão de schema/lifecycle que exceda o contrato já aprovado.

**Fim do Documento 64**
