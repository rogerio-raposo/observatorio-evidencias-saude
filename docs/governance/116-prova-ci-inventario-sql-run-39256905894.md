# 116 — Prova CI do inventário SQL sintético OES (run 39256905894)

**Projeto:** OES | **Fase:** 4 | **Data:** 2026-10-19 | **Modo:** médio  
**Status:** **STATIC_INVENTORY_CI_PASS_PINNED_COMMIT_ONLY — NO_SQL_EXECUTION — NO_NEON_MUTATION**  
**Checkpoint de entrada:** CP159 / Documento 115, HEAD `dd4c5ea8e68defa10e64df29c6931ead3509cf8b`.

## Prova primária

- GitHub Actions run: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39256905894
- Job `inventory`: ID `118074372781`, `status=completed`, `conclusion=success`.
- Steps `Run unit tests on synthetic fixtures`, `Inventory real SQL files without executing them` e `upload-artifact`: `success`.
- Log: `Ran 7 tests in 0.067s`, `OK` e `OFFLINE_INVENTORY_PASS 228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6 55ef8051054652b3823de743293524f317a33ec6`.
- Artifact `f4-neon-offline-inventory`, ID `12186719617`; ZIP reportado pelo GitHub com digest `sha256:9af246c91503b6155c879666e8e64679eb2d310fdb675654c01f4b2d12d14971`. ZIP recuperado pela integração e seus quatro arquivos internos examinados.
- `commit.txt` confirma `55ef8051054652b3823de743293524f317a33ec6` e `python-version.txt` confirma Python 3.13.16.
- `inventory.json`: `status=STATIC_INVENTORY_VALIDATED_ONLY`, `entry_count=36`, `fragment_count=14`, `sql_executed=false`, `neon_accessed=false`.
- SHA-256 agregado do inventário: `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`.
- SHA-256 dos bytes de `inventory.json`: `5694be45dd10c39131e6a74270bbf66cbb30ee21aba7bd47c91e96d2f2ea2504`, coincidindo com `inventory-file-sha256.txt`.
- SHA-256 do manifesto: `0b73466a374b933f1125c1d513aa4f952ad4141be92ac854f6cff35b641bd6df`; workflow S5: `7a0ab97499b09ac91608bbf18593389b7701096213dad4cda64940686e620a42`.
- O inventário contém SHA-256 individual de todos os 36 entrypoints e 14 fragmentos. Guardar e revisar esse artifact para reprodutibilidade; SHA de commit testado não é HEAD atual e não deve ser confundido com novo deploy.

## Decisão BRG-04

**BRG-04 = STATIC_CI_VERIFIED_FOR_COMMIT_55ef8051054652b3823de743293524f317a33ec6_ONLY.** O escopo aprovado é inventário de caminhos, ordenação e hashes de bytes, sem teste de carga de schema. Qualquer alteração futura dos arquivos SQL, manifesto, workflow de referência ou ferramenta exige nova prova vinculada ao commit aplicável. Não equivale a liberar BRG-01, 03, 05, 06, 07, 08, 09 ou migrations.

## Restrições

- Nenhum teste `psql` ou PostgreSQL 18 foi executado por este workflow; apenas Python.
- Ledger `ops.schema_migration` permanece não criado; runner ainda não implementado; atomicidade e recuperação pendentes.
- Branch `oes-schema-test` inexistente; nenhuma escrita Neon autorizada por esta prova.
- Sem backup independente, uso científico factual, novo Epoch, reabertura B1R1 ou início da Fase 5.
- B1R1 = `EXPIRED_NOT_EXECUTED`.

**Próximo passo:** planejar ensaio `psql`/PostgreSQL 18 em ambiente sintético isolado, depois avaliar ledger/locks/rollback em modo alto, antes de qualquer autorização para infra Neon.

**Fim do Documento 116.**