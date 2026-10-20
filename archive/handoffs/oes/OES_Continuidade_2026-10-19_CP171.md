# OES — Continuidade CP171

**Data:** 2026-10-19 (America/Recife)  
**Checkpoint:** CP171  
**Anterior:** CP170  
**HEAD de entrada:** `238b2a11cf26c94958e075ad852575419958b38e`  
**Modo:** alto  
**Estado:** grandfathering da migration 032 testado com três registros sintéticos preexistentes, rollback e marcador preexistente negativo, exclusivamente PG18 efêmero. Neon intocado.

## 1. Freshness Gate

Ponteiro CP170 e conteúdo do checkpoint consultados. Comparação de `main` com HEAD CP170 na entrada: `identical`, zero drift. A continuação em modo alto é autorizada somente para ensaios sintéticos, sem criação de recursos ou DDL Neon.

## 2. Entregas

**Documento 127:** `docs/governance/127-grandfathering-032-pg18-registros-sinteticos-preexistentes.md`.

- `tests/fixtures/f4-grandfathering-032/seed.sql`: fixture com `core.entity` / `core.entity_version` / `product.product_version` artificiais, uma `maintenance.update_policy`, uma `maintenance.sla_calendar_version` e uma `maintenance.sla_rule`. Respeita constraints, FKs e triggers ativos. Nada científico ou normativo.
- `scripts/oes_f4_pg18_032_grandfather_test.py`: instala 001–031 em PostgreSQL 18 descartável e, com cópias isoladas, examina aplicação 032, rollback por falha antes de COMMIT e caso negativo de marcador `TEMPORAL_CALIBRATION_V01` preexistente.
- `.github/workflows/f4-pg18-032-grandfather-synthetic.yml`: workflow CI automático restrito, PG18 contêiner local, `contents:read`, sem credenciais/hosts Neon.

## 3. Prova

- Run GitHub Actions `39350571819`, job `118393517271`: **completed/success**.
- Commit testado: `a060f7055063bf83ce8e880193b08f9c941e46f3`.
- Servidor PostgreSQL **18.6**; resultado `SYNTHETIC_032_GRANDFATHERING_PASS_LIMITED`.
- **19/19 verificações PASS** em `checks.tsv` e logs.
- Artifact `12233056788`, ZIP baixado e íntegro, SHA-256 `4191c4936b523b7ea9e2d7e176a14770b5daa6eb618dd6832a23f340b899b339` confirmado independentemente contra GitHub.
- Três fontes preexistentes foram mantidas; três entradas exatas grandfathered com marcador 032 e reason `pre_v01_existing_row`; erro induzido antes de COMMIT reverteu tabela de grandfathering e marker 032, mantendo fontes e snapshot estrutural. Controle negativo: marker artificial preexistente impede copiar fontes, mesmo existentes.

## 4. Interpretação

A lógica `first_install` de 032 depende da ausência do marcador do contrato. Portanto, **marker presente sem registros grandfathered não é prova de migração aplicada** e não deve autorizar recibo ou replay. O teste usa 1 linha por tipo, não suporta generalização para históricos arbitrários ou dados reais. Nenhuma pós-condição foi aprovada operacionalmente.

## 5. Gates mantidos

- `BRG_04 = HISTORICAL_STATIC_INVENTORY_VERIFIED_PINNED_COMMIT_ONLY`
- `BRG_05 = PG18_SCHEMA_INSTALL_AND_SYNTHETIC_031_036_FAULT_OBSERVATIONS_HISTORICAL`
- `BRG_06 = LEDGER_SYNTHETIC_MODEL_ONLY_NOT_OPERATIONAL`
- `BRG_07 = SUPERVISOR_SYNTHETIC_MODEL_ONLY_NOT_OPERATIONAL`
- `GRANDFATHERING_032 = SYNTHETIC_THREE_ROW_BEHAVIOR_PASS_PINNED_COMMIT_ONLY`
- `POSTCONDITION_CATALOG = 36_UNREVIEWED_ZERO_APPROVED`
- `BRG_03 = ACL_TLS_SECRETS_NOT_VERIFIED`
- `BRG_08 = INDEPENDENT_BACKUP_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## 6. Retomada e stop

Após próximo `Prossiga`: confirmar HEAD, revisar cenários de teste comportamental das funções/triggers das migrations 034–036 em PostgreSQL 18 descartável, sem dados científicos e sem Neon. Confrontar efeitos antes/depois e comportamento de guards, não inferindo integralidade de migration por função/trigger isolados. Modo alto para decisões de política de reconciliação e prevenção de replay. Especialistas humanos deverão validar antes de qualquer aprovação operacional.

**STOP — pausa obrigatória após reconciliação README, STATE e CHANGELOG.**

**Fim CP171.**