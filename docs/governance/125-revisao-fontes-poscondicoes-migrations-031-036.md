# 125 — Revisão inicial das fontes e candidatos de pós-condições das migrations 031–036

**OES — Fase 4 | 2026-10-19 | modo alto**  
**Estado:** SOURCE_INVENTORY_VERIFIED_ONLY — CANDIDATES_UNVALIDATED — NO_SQL_EXECUTION — NO_NEON_MUTATION.  
**Entrada:** CP168 / Documento 124 / HEAD `d213a618ce6fa87c8008c8e5da30a3ff219048fa`.

## 1. Freshness Gate e controles anteriores

O HEAD CP168 confrontado com `main` estava `identical` e a navegação canônica apontava CP168. Política canônica 30 e Documento 124 foram preservados sem alterações. A CI anterior do catálogo das 36 migrations, run `39282514522`, job `118159411858`, teve confirmação administrativa `completed/success`, fechando a pendência do CP168; 11 unit tests estáticos estavam aprovados. Nenhum estado Neon foi alterado.

A auditoria atual é uma **revisão de código-fonte**, não ensaio de migração ou certificação de pós-condições. Foram lidos os seis entrypoints 031–036 e os 14 fragmentos referenciados pelos wrappers 031–033.

## 2. Classificação por arquivo (observações diretas do SQL)

| Ordinal | Estrutura observada | Risco e pós-condições candidatas — ainda não verificadas |
|---|---|---|
| **031** | Wrapper `BEGIN/COMMIT` com **5** `\ir`; cria tabelas de propagation/rebaseline, índices, funções, triggers; altera `maintenance.update_signal_source`; insere seed técnico em `maintenance.contract_epoch` com código `PROPAGATION_REBASELINE_V01` | Verificar definições e constraints, FKs/índices, enablement dos triggers, alterações de colunas preexistentes e valores exatos do seed (`migration_id='031'`). `IF NOT EXISTS` e `ON CONFLICT DO NOTHING` podem mascarar objeto/registro anterior incompatível |
| **032** | Wrapper `BEGIN/COMMIT` com **4** `\ir`; calibração temporal, cadence/SLA e deadline; altera `maintenance.update_policy`, `sla_calendar_version`, `sla_rule`, `sla_instance`, `sla_pause`; insere seed `TEMPORAL_CALIBRATION_V01` e pode gravar objetos estruturalmente grandfathered | Verificar funções, triggers, colunas e constraints antes/depois; inspecionar seed (`migration_id='032'`) e efeitos de grandfathering em banco **com dados sintéticos preexistentes**, não apenas vazio. Provar rollback transacional inclusive dos inserts |
| **033** | Wrapper `BEGIN/COMMIT` com **5** `\ir`; estruturas para planos, epochs, authorities, opportunities e measurements; diversos triggers de validação/imutabilidade, funções e views `temporal_measurement_replay_v` e `temporal_measurement_readiness_evidence_v` | Verificar relações, FKs/CHECK, indices, todas as definições e estado `tgenabled` dos guards, definição das views, dependências e rollback integral sob falha inserida no fragmento. Arquivos não contêm seed factual direto observado |
| **034** | `CREATE OR REPLACE FUNCTION maintenance.assert_temporal_epoch_activation_chronology()`; `DROP TRIGGER` seguido de `CREATE TRIGGER tr_temporal_epoch_activation_chronology`, em `maintenance.temporal_observation_epoch`; **sem wrapper transacional externo** | Uma falha após `DROP TRIGGER` pode deixar proteção ausente. Exigir comparação de definição/assinatura da função, trigger habilitado, timing, evento, tabela-alvo e comportamento de chronology em fixture, além de simulação de interrupção entre comandos |
| **035** | Substitui duas funções: `maintenance.temporal_activation_preflight` e `maintenance.temporal_activation_preflight_state`; **sem wrapper transacional externo** | No `psql -f` padrão, definições podem ser confirmadas separadamente. Testar falha entre as duas funções; comparar assinatura, volatilidade, tipo de retorno, definição e comportamentos sintéticos `PASS/WAIT/FAIL`/epoch ausente |
| **036** | `CREATE OR REPLACE FUNCTION maintenance.assert_temporal_first_measurement_semantics()`; `DROP TRIGGER` seguido de `CREATE TRIGGER tr_temporal_event_first_measurement_semantics` em `maintenance.temporal_measurement_event`; **sem wrapper externo** | Exigir fingerprint da função, definição completa do trigger `BEFORE INSERT` habilitado e testes sintéticos de primeiro/evento subsequente. Falha entre `DROP` e `CREATE` pode deixar guarda ausente |

**Nota importante:** os wrappers 031–033 têm controle de transação observado, mas a revisão de código não é prova de recuperação perante cada ponto de falha em ambiente populado. A prova de instalação sequencial 36/36 do Documento 119 permanece válida **somente para aquele ensaio em PG18 descartável**; ela não resolve drift, concorrência ou partial commits.

## 3. Artefatos novos e prova

- `docs/governance/reconciliation/f4-031-036-source-candidates.json`: **6 registros candidatos** em ordem, declarando includes, comandos marcadores, riscos e ensaios futuros. Marcado globalmente `SOURCE_REVIEW_CANDIDATES_UNVALIDATED`, `review_approved=false`, `automatic_replay_allowed=false`, `automated_reconciliation_allowed=false`, `neon_write_authorized=false`. É **documentação de hipóteses**, não catálogo operacional.
- `scripts/oes_f4_031_036_source_review.py`: scanner somente leitura dos 20 arquivos, com pré-verificação do catálogo principal; confere ordenação, fragmentos, limites BEGIN/COMMIT, presença textual de marcadores e calcula SHA-256 por arquivo. Não é parser SQL, não valida semântica ou presença efetiva de objetos no banco.
- `tests/test_oes_f4_031_036_source_review.py`: 8 testes negativos/positivos com SQL artificial ou mutações documentais, sem acesso a banco.
- `.github/workflows/f4-031-036-source-review.yml`: trigger automático restrito aos próprios caminhos, `contents:read`, Python/checkout, nenhuma conexão nem execução SQL.

**CI comprovada:** run https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39297500185; job `118213715729` `completed/success`; commit `feb2b9f115e94a09c975b98f61d7a5ffda53438d`; **8 testes OK** e `SOURCE_INSPECTION_ONLY_NOT_A_RECONCILIATION_PASS` nos logs.

**Artifact** `f4-031-036-source-only`, ID `12209110983`; ZIP recuperado e SHA-256 verificado `ff1c7b237c5b5c1246b60bdb2f3cae19073acb88e5b793b254559169873551f1`. `source.json`: 6 wrappers + 14 fragments; 20 checksums individuais, 6 avaliações das fronteiras de transação, `reviewed_migrations=0`, `postconditions_validated=0`, `sql_executed=false`, `neon_accessed=false`, `neon_write_authorized=false`. SHA-256 de `source.json` `4477747c219b1808600bdd5cb7ca5f9f8ce46b0500543f47195194f478825e88`, idêntico ao recibo interno do ZIP. Digest do catálogo de candidatos na serialização do scanner `b277c91a2f9f1a4c1b8356572e7bd1896a494b49317a2bd5ebf60c03e3e9ef1b`.

**O catálogo principal** `database/f4-reconciliation-postconditions-draft.json` permanece **36/36 `UNREVIEWED`, zero pós-condições validadas e todas as flags automáticas em `false`**.

## 4. Método de validação futura — ainda não executado

A prova por migration deverá, antes de qualquer promoção de `review_state`:

1. Criar uma base PG18 descartável e instalar dependências até a migration anterior. Capturar inventário **antes/depois** com `pg_class`, `pg_attribute`, `pg_constraint` (`convalidated` e `pg_get_constraintdef`), `pg_index` (`indisvalid`), `pg_trigger` (`tgenabled`, `pg_get_triggerdef`), `pg_proc` (`pg_get_functiondef` e assinaturas), `pg_views`/`pg_get_viewdef`; comparar versão de servidor e fingerprints com baseline específico do HEAD.
2. Para 031 e 032, verificar código, versão e migration ID exatos dos dois registros `maintenance.contract_epoch`, ausência de divergência em linhas preexistentes e efeitos das atualizações/seed técnico, especialmente o grandfathering de 032. Usar cenários artificialmente povoados que preservem constraints.
3. Para 033, verificar dependências e guards **em funcionamento**, não apenas existência de tabelas, views, funções e triggers. Confirmar ausência de dados factuais.
4. Para 034 e 036, injetar falha entre `DROP TRIGGER` e `CREATE TRIGGER` **em banco descartável**, provar comportamento parcial e definir reparo/forward-fix, sem ensaio contra Neon.
5. Para 035, injetar falha após a primeira função e antes da segunda e identificar possível mistura de versões.
6. Exigir quatro estados discrimináveis por migration: `not_applied`, `fully_applied_verified`, `partial_or_drift`, `indeterminate`. Estados `partial_or_drift` ou `indeterminate` devem impor `uncertain_requires_reconciliation`, sem reexecutar nem fabricar `applied`. A existência de uma tabela, trigger, função ou row isolada **nunca é prova suficiente**.
7. Registrar revisão independente de especialidade PostgreSQL/segurança e autorização explícita antes de publicar qualquer catálogo operacional com pós-condições e antes de habilitar flags.

Essas consultas e testes **não foram executados neste checkpoint**. Os candidatos não constituem especificação final das pós-condições, e o scanner apenas confirma padrões textuais.

## 5. Gates de segurança inalterados

- BRG-04/05: evidências anteriores em commits fixados; nenhuma extensão automática de escopo.
- BRG-06: ledger sintético testado, **ledger operacional não implantado**.
- BRG-07: supervisor sintético testado, **runner/fencing operacional não aprovado**.
- BRG-03: roles, ACL, autenticação TLS e segredos sem validação operacional.
- BRG-08: backup/restore independente pendente.
- BRG-09: billing/consumo real Neon no console titular pendente.
- Branch `oes-schema-test`: **não criada**, aprovação específica ainda ausente.
- B1R1: `EXPIRED_NOT_EXECUTED`; Fase 5: `NOT_STARTED`.

**Fim do Documento 125.**