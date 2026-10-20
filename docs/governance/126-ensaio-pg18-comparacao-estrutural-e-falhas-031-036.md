# 126 — Ensaio PostgreSQL 18: fotografias estruturais e falhas nas migrations 031–036

**OES — Fase 4 | 2026-10-19 | modo alto**  
**Status:** PG18_SYNTHETIC_SCHEMA_FAULT_OBSERVATIONS_VERIFIED — POSTCONDITIONS_NOT_VALIDATED — NO_NEON_WRITE.  
**Entrada:** Documento 125 / CP169 / HEAD `f928807e76b74dc32b65fe3a707c72232c721c55`.

## 1. Governança e Freshness Gate

Comparação do HEAD CP169 vs branch `main`: `identical`, zero divergências, ponteiro e CP169 conferidos. Nenhuma aprovação de create-branch, DDL ou migração Neon. O ensaio usa exclusivamente PostgreSQL 18 descartável no GitHub Actions, credenciais fictícias do serviço, sem secrets externos.

Foram criados:
- `scripts/oes_f4_pg18_031_036_fault_rehearsal.py` — ferramenta experimental restrita por `GITHUB_ACTIONS=true`, repositório OES, `PGHOST=127.0.0.1`, `PGPORT=5432`, `PGUSER=postgres`, `PGDATABASE=oes_f4_fault_synthetic`; proíbe `DATABASE_URL` e `PGSERVICE`. NÃO é runner de migrations.
- `.github/workflows/f4-pg18-031-036-fault-rehearsal.yml` — job em `postgres:18` descartável, `contents: read`, checkpoint SHA de CI, artifact `if: always()`, acionamento `push` apenas por mudanças do próprio workflow/harness/manifesto.
- Nenhum arquivo SQL histórico, catálogo principal, política 30, infraestrutura Neon ou protocolo de operações reais foi alterado.

## 2. Provas CI, com falha inicial preservada

**Primeira execução:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39349451906; commit `96178dc9cf09bed274ecdf4d4285587330a4629e`, job `118389922941`, **completed/failure**. Após instalar a base 001–030, o comparador tentou acessar `maintenance.contract_epoch` antes da criação desta tabela (em 031). Erro do **instrumento de fotografia**, não da migration 031. Artifact `12232437798` preservado. Corrigiu-se prospectivamente a consulta para tratar a ausência pré-031 e incluir o seed de `contract_epoch` apenas quando a tabela existir. Não ocultar este erro.

**Execução corrigida:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39349564581; commit `46af0a575e30d640dedd97edf84315ebc5f6f310`, job `118390284507`, **completed/success**. Servidor PostgreSQL 18 conforme `server-version.txt`; cliente conforme `client-version.txt`. O log e o `checks.tsv` do artifact confirmam **29 de 29 verificações PASS** e `PG18_031_036_FAULT_OBSERVATIONS_ONLY`.

Artifact `f4-pg18-031-036-fault-observations` ID `12233090040`, 25 arquivos ZIP; download íntegro (teste interno ZIP OK), SHA-256 dos bytes **`6aea06318fb097c66066a75e13b8e03ae23ff52c6c7cf07a9bfffb9009431a3e`** conferido com digest GitHub. `stage-report.json`, `checks.tsv`, `commit.txt`, `031-before.json` até `036-after.json` e fotografias de rollback/falha são evidências em commit específico.

## 3. Método delimitado

1. Banco `oes_f4_fault_synthetic` recebeu, via `psql -X -v ON_ERROR_STOP=1 -f`, as migrations 001–030.
2. Bancos independentes foram clonados pelo comando PostgreSQL `CREATE DATABASE ... TEMPLATE`; um banco `oes170live` recebeu 031–036 na ordem. Antes/depois de cada entrada foram recolhidos inventários do catálogo com `pg_class`, `pg_attribute`, `pg_constraint`, `pg_index`, `pg_trigger`, `pg_proc` e seed técnico `maintenance.contract_epoch` quando existente.
3. A comparação é de **identidade e definição de objetos catalogados, com MD5 por definição**, não prova criptográfica de identidade completa do banco, nem validação de semântica, conteúdo de tabelas arbitrárias ou origem dos objetos. O ZIP usa SHA-256 independente para integridade de transporte.
4. Para 031–033, cópias do **estado anterior** receberam um wrapper artificial que injeta erro `SELECT 1/0` imediatamente antes de seu `COMMIT` interno. Conferiu-se erro esperado e equivalência do inventário estrutural antes/depois da tentativa.
5. Para 034 e 036, cópias de **estado já integralmente instalado** foram usadas em uma **reexecução negativa controlada**, interrompendo após `DROP TRIGGER` e antes do `CREATE TRIGGER`; assim observou-se, de modo deliberado, o risco de guarda ausente em recuperação ou replay inadequados.
6. Para 035, cópia do estado pré-035 executou somente a primeira função e erro induzido antes da segunda, demonstrando persistência de definição parcial no modo autocommit testado.

## 4. Resultados e implicações de reconciliação

| Ordinal | Objetos catalogados adicionados/modificados/removidos na instalação normal | Falha artificial | Classificação do cenário |
|---|---:|---|---|
| 031 | 533 / 3 / 2 | Erro antes de `COMMIT`: inventário estrutural e seed técnico retornaram ao estado anterior | `ROLLED_BACK_SAME_CATALOG_IN_TEST` |
| 032 | 478 / 6 / 0 | Erro antes de `COMMIT`: inventário estrutural e seed técnico retornaram ao anterior | `ROLLED_BACK_SAME_CATALOG_IN_TEST` |
| 033 | 572 / 0 / 0 | Erro antes de `COMMIT`: inventário estrutural retornou ao anterior | `ROLLED_BACK_SAME_CATALOG_IN_TEST` |
| 034 | 2 / 0 / 0 | Interrupção após `DROP TRIGGER` em cópia já instalada deixou trigger ausente | `PARTIAL_OR_DRIFT_CONFIRMED` |
| 035 | 2 / 0 / 0 | Primeira função presente e segunda ausente após erro intermediário | `PARTIAL_OR_DRIFT_CONFIRMED` |
| 036 | 2 / 0 / 0 | Interrupção após `DROP TRIGGER` em cópia já instalada deixou trigger ausente | `PARTIAL_OR_DRIFT_CONFIRMED` |

Os valores “objetos” incluem registros de catálogo (colunas, constraints, índices, relações, triggers, funções e seed), **não equivalem a número de tabelas** nem a número de registros científicos.

Os resultados reforçam a proibição de *blind replay* após falha: a mera existência/ausência de trigger ou função não basta para classificar uma migração integralmente aplicada, nem para autorizar reparo automático. A classificação final de uma tentativa exige contexto de execução, recibos/intenções anteriores, integridade dos arquivos e pós-condições revisadas.

## 5. Limitações que impedem promoção operacional

- **Zero pós-condições aprovadas** no catálogo principal `database/f4-reconciliation-postconditions-draft.json` (36/36 `UNREVIEWED`); nenhuma flag automatizada habilitada.
- Os dados de base estavam essencialmente sem fixtures científicas. **Não foi testado o `grandfathering` de 032 sobre registros sintéticos preexistentes**, nem as constraints relevantes desses fixtures.
- O resultado “rollback” de 031–033 significa **equivalência do inventário observado** após falha; não prova reversão semântica de qualquer DML preexistente fora de `contract_epoch`.
- A fragmentação das functions/guards e a identidade de definições não constituem testes comportamentais de cronologia, readiness, medidas e proveniência.
- Nenhum teste de `SIGKILL` entre commits, recuperação de rede, menor privilégio, ledger operacional, runner de produção, backup independente, aplicação no Neon ou segundo executor foi realizado neste bloco.
- Falhas artificiais em 034/036 foram provocadas em **replay negativo sobre cópias já instaladas**. Não constituem evidência de que a primeira instalação íntegra das migrations falhou.
- Nenhuma alteração Neon, branch de teste, role, ledger, schema ou arquivo canônico de SQL.

**BRG-04/05** continuam com evidências em commits históricos. **BRG-06/07** mantêm prova sintética, sem implementação ou autorização operacional. **BRG-03/08/09** pendentes. `B1R1=EXPIRED_NOT_EXECUTED`; `PHASE_5=NOT_STARTED`.

## 6. Próximo passo técnico

Em modo alto, preparar fixture **estritamente sintético e consistente** para linhas preexistentes de `maintenance.update_policy`, `maintenance.sla_rule`, `maintenance.sla_calendar_version` antes de 032, e medir contagens/identidade do grandfathering e seu rollback. Complementar com análise de assinaturas e testes comportamentais 034–036, sempre no PG18 descartável. Evitar promover catálogo de reconciliação antes de revisão técnica especializada e autorização explícita.

**Fim do Documento 126.**