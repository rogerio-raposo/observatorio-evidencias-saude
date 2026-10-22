# Documento 214 — D1/T2-A2: autorização e evidências da criação estrutural A2-G2/E (CP239)

**OES | 2026-10-22 | A2-G2/E_COMPLETED_STRUCTURAL_ONLY | A2-G3–G5/T2-A2 NOT_AUTHORIZED**

## 1. Autoridade e Freshness Gate
Após a revisão adversarial E-R1–E-R5 e apresentação da DDL corrigida, o proprietário declarou **“Modo médio. Aprovado.”**, aprovação expressa e contextual da proposta **`APPROVED — OES / D1-T2-A2 / A2-G2-E / SYNTHETIC_POSTGRESQL_MINIMAL_STRUCTURE_ONLY`**. O `Prossiga` posterior autorizou executar somente o preflight, as quatro operações DDL previamente delimitadas e a pós-verificação. HEAD GitHub `53377c6e50358f6bb09d7743cb3d0057a1e657d3` e ponteiro CP238 confirmados `identical`. Esta publicação ocorre posteriormente, sem novas operações Neon.

## 2. Ambiente e sequência executada
Alvo único: Neon `oes-d1-t2-a2-synthetic`, projeto `tiny-pond-20086371`, branch `synthetic-main` (`br-divine-grass-b63wlpcb`), banco `oes_t2a2_synthetic`. Papel explicitamente selecionado `oes_t2a2_owner`; papel legado `oes_t2a2_runtime` **não utilizado**. Preflight SQL de leitura, na transação `REPEATABLE READ, READ ONLY`, confirmou `session_user=current_user=oes_t2a2_owner`, CREATE efetivo true, banco correto, namespace ausente.

Execução DDL subsequente por `run_sql_transaction` sob owner com `SET LOCAL lock_timeout='1s'`, `SET LOCAL statement_timeout='5s'`, `SET LOCAL search_path=pg_catalog` e quatro comandos: (1) `CREATE SCHEMA oes_t2a2_proto AUTHORIZATION oes_t2a2_owner`; (2) `CREATE TABLE oes_t2a2_proto.scenario`; (3) `CREATE TABLE oes_t2a2_proto.event`; (4) `CREATE TABLE oes_t2a2_proto.receipt`. Resposta: sete resultados vazios sem erro. Nenhum `IF NOT EXISTS`, inserção, ALTER ROLE, GRANT/REVOKE, DDL adicional, DROP, CI ou tests de aplicação.

## 3. DDL executada — inventário estrutural fiel

**scenario:** `scenario_id TEXT PRIMARY KEY` não vazio, `revision BIGINT NOT NULL CHECK >=1`, `state JSONB NOT NULL` objeto e `state->'synthetic' = true`, `synthetic BOOLEAN NOT NULL CHECK IS TRUE`. **Não há CHECK de array state.events** (incompatível com o repositório genérico).

**event:** `scenario_id TEXT NOT NULL`, `sequence BIGINT NOT NULL CHECK >=1`, `kind TEXT NOT NULL` não vazio, `payload JSONB NOT NULL` objeto; PK composta (scenario_id,sequence), FK `event_scenario_fk` apontando para `scenario(scenario_id)`; sem ON DELETE CASCADE.

**receipt:** `scenario_id TEXT NOT NULL`, `request_id TEXT NOT NULL` não vazio, `fingerprint TEXT NOT NULL` não vazio (**sem CHECK regex SHA-256**, preservando fingerprint genérico), `response JSONB NOT NULL` aceitando escalares JSON, `revision BIGINT NOT NULL CHECK >=1`; PK composta (scenario_id,request_id), FK `receipt_scenario_fk`. Nenhum trigger, função, view, fixture, índice adicional ou migration histórica foi criado.

## 4. Pós-verificação independente de leitura
`run_sql_transaction` sob owner, `REPEATABLE READ READ ONLY`, timeouts 5s/1s, confirmou:

| Critério | Evidência | Parecer |
|---|---|---|
| Identidade | banco `oes_t2a2_synthetic`, role `oes_t2a2_owner`, read_only=on | PASS |
| Schema | `oes_t2a2_proto`, owner `oes_t2a2_owner`, `nspacl=NULL` | PASS |
| Tabelas regulares | `scenario`, `event`, `receipt`, relkind=r, owner correto | PASS |
| Índices | `scenario_pkey`, `event_pk`, `receipt_pk`, relkind=i | PASS |
| Constraints | PK/FK/CHECK/NOT NULL identificados para três tabelas | PASS estrutural |
| Conteúdo | `COUNT(*)=0` em cada tabela | PASS: três tabelas vazias |
| ACL schema | `PUBLIC` USAGE=false, CREATE=false; `oes_t2a2_app` USAGE=false, CREATE=false | PASS de isolamento atual |
| ACLs explícitas | schema/tabelas `acl=NULL` | Observação; NULL não equivale a inexistência de privilégios padrão |

Os resultados são evidências pós-commit de existência e integridade declarativa inicial. Não comprovam invariantes semânticas entre state/event/receipt, atomicidade de comandos de aplicação, replay, durabilidade pós-reinício ou ausência de dependências externas não inspecionadas.

## 5. Riscos preservados e decisões não concedidas
`oes_t2a2_owner` possui privilégios administrativos elevados observados em P2 (CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS e membership `neon_superuser`). Seu uso excepcional na DDL não comprova menor privilégio institucional nem autoriza novas operações administrativas. `oes_t2a2_app` permanece sem USAGE/CREATE no schema e sem GRANTs sobre as tabelas; A2-G3 ainda não autorizado. `oes_t2a2_runtime` continua proibido. `oes-sandbox` permanece fora do escopo. A observabilidade TLS permanece restrita: N1-E3 provou cliente Psycopg→endpoint com verify-full, não TLS completo até backend nem TLS explícito no plugin SQL.

`A2-G2/E_COMPLETED_STRUCTURAL_ONLY` encerra **apenas** a criação de objetos vazios. A2-G3 (permissões), A2-G4 (adaptador), A2-G5 (testes) e implementação T2-A2 **`NOT_AUTHORIZED`**. F01–F07 `DOCUMENTARILY_ADDRESSED_NOT_OPERATIONALLY_VALIDATED`; L1–L4 e O-01–O-10 pendentes. T1 36 PASS e T2-A1 75 PASS somente históricos; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`, 36 migrações `UNREVIEWED`. Sem dados reais, buscas factuais, promoção científica/operacional ou serviços pagos.

## 6. Próxima atividade
Preparar **documentalmente** a proposta restrita A2-G3 para USAGE do schema, SELECT/INSERT nas três tabelas e UPDATE apenas em `scenario` para `oes_t2a2_app`, avaliando explicitamente privilégios efetivos, `PUBLIC`, owner, identidade SQL da execução, rollback, pós-verificação e inexistência de DELETE/TRUNCATE/UPDATE de event/receipt. **Não executar GRANT/REVOKE/SQL ou CI sem aprovação independente. STOP.**
