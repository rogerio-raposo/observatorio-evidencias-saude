# 127 — Prova sintética PG18 de grandfathering da migration 032 com registros preexistentes

**OES — Fase 4 | 2026-10-19 (America/Recife) | modo alto**  
**Status:** SYNTHETIC_032_GRANDFATHERING_BEHAVIOR_VERIFIED_PINNED_COMMIT_ONLY — NOT_A_RECONCILIATION_APPROVAL — NO_NEON_WRITE.  
**Base:** Documento 126 / CP170 / HEAD de entrada `238b2a11cf26c94958e075ad852575419958b38e`.

## 1. Freshness Gate, autorização e ambiente

Na entrada, o `main` era idêntico ao HEAD CP170 (zero drift); README/ponteiro e checkpoint CP170 consultados. Não existiu autorização para criar branch, role, tabela, ledger ou aplicar SQL no Neon. O teste é restrito ao PostgreSQL 18 **efêmero de GitHub Actions**, sem segredos/host Neon. `B1R1=EXPIRED_NOT_EXECUTED`; Fase 5 não iniciada.

## 2. Fontes inspecionadas e fixture

A migration `database/032_temporal_calibration_prerequisites.sql` usa wrapper `BEGIN/COMMIT`. Seu fragmento `database/032a_temporal_calibration_core.sql` consulta se existe `maintenance.contract_epoch.contract_code='TEMPORAL_CALIBRATION_V01'` **antes** de inserir o marcador estrutural `migration_id='032'` com `ON CONFLICT DO NOTHING`. Quando não existe, cria `maintenance.temporal_contract_grandfathered_object` e copia os identificadores preexistentes de `maintenance.update_policy`, `maintenance.sla_rule` e `maintenance.sla_calendar_version`, com `reason_code='pre_v01_existing_row'`. Quando o marcador já existe, não faz essa população retroativa.

**Arquivos novos:**
- `tests/fixtures/f4-grandfathering-032/seed.sql`: somente dados artificiais para uma `ProductVersion` referenciada por `core.entity` e `core.entity_version`, uma `update_policy` M0/none, uma `sla_calendar_version` e uma `sla_rule` (SLA1, `elapsed_time`). Os inserts mantêm FKs, checks e triggers **ativos** e não representam produto/serviço real, validação humana, cronograma normativo nem medição científica.
- `scripts/oes_f4_pg18_032_grandfather_test.py`: harness com travas de destino CI-only, PostgreSQL 18 local e banco exato `oes_f4_032_synthetic`. Instala 001–031 em DB temporário, semeia fixture sintética, clona quatro bancos e compara comportamento da migration 032 por cenários. Proíbe URLs/conexões externas e não é runner operacional.
- `.github/workflows/f4-pg18-032-grandfather-synthetic.yml`: gatilho automático restrito a seus arquivos, `contents:read`, `postgres:18` descartável, logs/artifact mesmo sob falha.

**Dados artificiais preexistentes auditados:** `update_policy` UUID `33333333-3333-4333-8333-000000000171`, `sla_calendar_version` UUID `44444444-4444-4444-8444-000000000171` e `sla_rule` UUID `55555555-5555-4555-8555-000000000171`. São identificadores de teste, sem correspondência com dados factuais.

## 3. Evidência GitHub Actions

- Run: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39350571819.
- Commit fixado: `a060f7055063bf83ce8e880193b08f9c941e46f3`.
- Job `synthetic-grandfather-032`: **118393517271**, `completed/success`.
- PostgreSQL server: **18.6**; `psql` conforme `psql-version.txt` no artifact.
- **19 de 19 checks PASS**, com log contendo `SYNTHETIC_032_GRANDFATHERING_PASS_LIMITED`.
- Artifact `f4-pg18-032-grandfather-synthetic`, ID **12233056788**, baixado, ZIP testado sem entradas corrompidas. SHA-256 ZIP calculado independentemente **`4191c4936b523b7ea9e2d7e176a14770b5daa6eb618dd6832a23f340b899b339`**, coincidente com o digest informado pelo GitHub.
- Os dez arquivos do ZIP incluem `checks.tsv`, `result.json`, `grandfather-rows.txt`, `baseline-source.json`, versão, commit, digest do fixture e log.

## 4. Resultados por cenário

| Cenário | Expectativa comprovada |
|---|---|
| Pré-032 com três objetos artificiais existentes | FK/check/trigger aceitam as três linhas; `temporal_contract_grandfathered_object` ainda não existe |
| Instalação regular 032 | Três vínculos de grandfathering criados, com `object_type`, UUID, `migration_id='032'`, `reason_code='pre_v01_existing_row'` exatos; `grandfathered_at` não nulo |
| Preservação da origem | As três UUIDs e os campos-fonte selecionados permaneceram iguais; um marcador `contract_epoch` 032/versão 0.1 foi criado |
| Erro deliberado `SELECT 1/0` antes de `COMMIT` | A criação da tabela de grandfathering e o marcador 032 foram desfeitos; as três linhas originais permaneceram; o inventário estrutural comparado coincidiu com o pré-032 |
| Marcador estrutural 032 preinserido artificialmente | O `first_install` ficou falso e **não inseriu** linhas de grandfathering, embora as três linhas-fontes existissem; não há reparo automático implícito |

**Interpretação importante:** um marcador `TEMPORAL_CALIBRATION_V01` preexistente não comprova que o grandfathering foi realizado corretamente. A prova reproduz um caso em que o marcador suprime os inserts. Em eventual reconciliação, marcador e entradas mapeadas precisam ser verificados **conjuntamente** com histórico de tentativas e estado estrutural, sem inferir `applied` automaticamente.

## 5. Limites e proibições

- A fixture contém apenas **um** registro de cada tipo, sem supersessões reais, muitos históricos, duplicatas ou grandes volumes. Não é prova exaustiva de compatibilidade de dados existentes.
- A equivalência de linhas-fonte usa campos selecionados e a prova estrutural usa catálogo de banco; não constitui verificação total de toda semântica de DML, proveniência, triggers, funções ou integridade de uma operação real.
- A verificação do rollback ocorreu na mesma transação até o erro induzido; não testa queda de energia, commit incerto, falha de rede, concorrência, restore independente ou execução no Neon.
- A variante com marcador artificial preexistente é **controle negativo**, não sugestão de operação autorizada nem remediação.
- Nenhuma decisão metodológica ou cadência normativa foi preenchida pela fixture; o valor artificial de SLA é somente para viabilizar a FK/trigger do ensaio.
- Catálogo principal `database/f4-reconciliation-postconditions-draft.json`: **36 `UNREVIEWED`, 0 pós-condições aprovadas, 0 permissões de replay/reconciliação/execução automática**.
- BRG-06/07: ledger/runner operacionais ausentes; BRG-03 (ACL/TLS), BRG-08 (backup) e BRG-09 (billing owner) pendentes; branch Neon de teste não criada.

## 6. Próximo passo

Manter modo alto. Planejar e executar **somente em PostgreSQL 18 descartável** testes comportamentais controlados das funções/triggers 034–036, incluindo evidência de proteção ativa e de falha intermediária, com fixtures e condições verificáveis. Não promover catálogo de reconciliação sem revisão independente especializada e autorização específica.

**Fim do Documento 127.**