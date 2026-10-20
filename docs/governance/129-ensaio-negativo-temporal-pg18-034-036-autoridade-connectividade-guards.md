# 129 — Ensaio negativo temporal PostgreSQL 18: autoridade, oportunidades, conectividade e triggers 034–036

**OES — Fase 4 | 2026-10-19 (America/Recife) | modo alto**  
**Estado:** PG18_TEMPORAL_NEGATIVE_COVERAGE_27_OF_27_PASS_SYNTHETIC_ONLY — CRITICAL_ADMIN_BYPASS_NEGATIVE_CONTROL — NO_NEON_WRITE.  
**Base:** Documento 128 / CP172 / HEAD de entrada `f2f89ed65eff43ca38b482506c7106048b805aa4`.

## 1. Continuidade e fronteira de autorização

Freshness Gate CP172 vs `main` = `identical`, ahead=0, behind=0; ponteiro canônico apontava CP172, checkpoint consultado. Foi preservada a regra de **um checkpoint por `Prossiga`**, com PostgreSQL 18 exclusivamente descartável, dados científicos inexistentes e nenhuma autorização implícita para alterações no Neon. A instalação das 36 migrations ocorreu **somente** no serviço local efêmero da CI.

Artefatos adicionados:
- `scripts/oes_f4_pg18_034_036_negative_coverage.py`: programa Python CI-only com allowlist estrita de `PGHOST=127.0.0.1`, `PGPORT=5432`, `PGDATABASE=oes_f4_temporal_neg_synthetic`, `PGUSER=postgres`, repositório `rogerio-raposo/observatorio-evidencias-saude`, `GITHUB_ACTIONS=true`. Recusa `DATABASE_URL`, `PGSERVICE` e `PGSERVICEFILE`. Não é runner nem reconciliador.
- `.github/workflows/f4-pg18-034-036-negative-coverage.yml`: serviço descartável `postgres:18`, `contents:read`, gatilho `push` exclusivamente nos arquivos do ensaio, artifact `if:always()`, sem Neon.
- Os arquivos de SQL históricos 001–036, a política de migrações 30, o catálogo principal e o fixture canônico de CP172 **não foram alterados**. Variantes foram derivadas do fixture sintético `tests/fixtures/f4-temporal-034-036/seed.sql` dentro da CI, em bancos clonados independentes.

## 2. Evidência de execução

Run: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39356550539  
Job `temporal-negative`: **118412553302**, `completed/success`.  
Commit testado: **`b5f0eb3c0b3d95b7e864c3fdbbfb05dfc7baf997`**.  
Versão do servidor: PostgreSQL **18** (ver `server-version.txt` do artifact).

Artifact `f4-pg18-034-036-negative-coverage`, ID **12235317764**, ZIP recuperado, `testzip()` sem erros, nove arquivos. SHA-256 dos bytes ZIP **`dec06e6b79afe9eb34902e804578eb10aa28fe04d19dab774f4dd6a3ae5fec34`**, igual ao digest informado pelo GitHub. `checks.tsv`: **27/27 PASS**. `result.txt`: `PG18_TEMPORAL_NEGATIVE_COVERAGE_ONLY`. `commit.txt` corresponde ao commit do run. `expected-errors.log` reúne seis erros SQL deliberados e validados como **rejeições esperadas**.

## 3. Cenários negativos e interpretação

| Cenário sintético | Controle exercitado | Resultado |
|---|---|---|
| Sem autoridade para a epoch | Fonte artificial sem INSERT de authority; consulta `temporal_activation_preflight` e tentativa de passar draft → authorized | `AUTHORITY_STATE=FAIL`; estado global `FAIL`; lifecycle recusa com `operational execution authority state is missing` |
| Duas decisões contraditórias no mesmo instante | Duas linhas artificiais `approved` e `rejected`, mesmo domínio/epoch/`decided_at` | Função de autoridade retorna `conflict`; preflight `FAIL`; autorização recusada |
| Fonte que exige conectividade mas está bloqueada | `runtime_connectivity_required=true` e frozen `runtime_connectivity_status='blocked'` desde INSERT do fixture | Preflight `RUNTIME_CONNECTIVITY=FAIL`; autorização recusada |
| Oportunidade não materializada | Payload congelado exige duas oportunidades; fixture insere somente uma, sem contornar trigger de imutabilidade | Preflight `OPPORTUNITY_SET=FAIL`; autorização recusada por conjunto incompleto |
| Trigger 034 desabilitado em cópia administrativa | Trigger `tr_temporal_epoch_activation_chronology` ativo primeiro recusa `started_at` igual à primeira oportunidade; depois foi desabilitado com `ALTER TABLE` por usuário privilegiado do **banco descartável** | A transição inválida passou enquanto trigger estava desabilitado; reabilitá-lo **não corrigiu** a epoch já ativa |
| Trigger 036 desabilitado em cópia administrativa | Trigger `tr_temporal_event_first_measurement_semantics` ativo primeiro recusa primeira conclusão com `zero_new`; depois foi desabilitado artificialmente | Primeiro evento inválido foi persistido; reabilitar trigger **não corrige** retroativamente a linha |
| Desvio material posterior ao `started_at` | Deviation artificial com `recorded_at` posterior ao instante de ativação e `materiality='invalidating'` | Função 034 permitiu ativação naquele `started_at`, pois filtra desvios `recorded_at <= started_at` |

**A prova de desativação de triggers é controle negativo em clone descartável, não recomendação de uso ou falha explorável por role normal.** Ela demonstra o risco caso um administrador privilegiado modifique guards sem governança; por isso a separação de privilégios, monitoramento de DDL e inspeção de dados são gates independentes.

**Observação:** o preflight de cenários em `draft` também pode indicar `EPOCH_STATUS=FAIL`. Os testes verificaram que o campo relevante (autoridade, conectividade ou conjunto de oportunidades) estava `FAIL` e que a tentativa de autorização foi recusada pela condição específica; não atribuíram exclusividade causal a todo o estado agregado.

## 4. Lacunas não resolvidas

1. `tgenabled='O'` e definição textual do trigger não bastam para provar correção de **todos os dados preexistentes**; uma base adulterada pode manter registros que nunca foram validados.
2. O comportamento de desvio material **posterior** ao instante de ativação é conforme o filtro temporal observado; **não** significa que desvios posteriores sejam admissíveis para execução posterior, fechamento da epoch ou governança.
3. Nenhuma fonte real, SearchHit, ClinicalTrials, medição científica ou dado clínico foi acessado. A autoridade permanece **inteiramente fictícia** e não foi concedida por humano.
4. Não foram demonstrados monitoramento operacional de DDL, ACLs com least privilege, TLS, logs externos imutáveis, reconciliação manual aprovada, testes concorrentes com vários runners, backup/restore, manutenção de autoridade após alteração futura, nem replay seguro.
5. A prova de parcialidade sob falha entre `DROP TRIGGER` e `CREATE TRIGGER` do Documento 126 permanece vigente. O presente ensaio não modifica essas migrations.
6. **Catálogo principal:** `database/f4-reconciliation-postconditions-draft.json` ainda tem **36/36 `UNREVIEWED`, zero pós-condições aprovadas e todas as flags automáticas `false`**.

## 5. Estado dos gates

- `BRG-04/05`: provas históricas estáticas/PG18 específicas de commits fixados, sem promoção operacional.
- `BRG-06`: ledger sintético testado; ledger operacional ausente.
- `BRG-07`: supervisor sintético testado; runner/fencing operacional não aprovado.
- `BRG-03`: segregação de privilégios, autenticação/TLS, auditoria DDL e segredos pendentes.
- `BRG-08`: backup independente + restore pendentes.
- `BRG-09`: consulta de consumo/billing pelo titular pendente.
- `NEON_TEST_BRANCH=NOT_CREATED`; `NEON_SCHEMA_MIGRATION=NOT_STARTED`; `B1R1_ACTIVATION_WINDOW=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

## 6. Continuidade sugerida

Antes de propor pós-condições formais para 034–036, desenvolver **matriz de suficiência de evidências**, distinguindo estado atual de triggers, impressões digitais da função, catálogo de dependências e exame de dados históricos; avaliar permissões administrativas e auditoria de alterações de schema; solicitar revisão humana independente em PostgreSQL/segurança e metodologia. Nenhuma promoção para `fully_applied_verified` sem autorização técnica específica.

**Fim do Documento 129.**