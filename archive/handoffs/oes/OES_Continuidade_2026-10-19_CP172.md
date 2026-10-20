# OES — Continuidade CP172

**Data:** 2026-10-19 (America/Recife)  
**Checkpoint:** CP172  
**Anterior:** CP171  
**HEAD de entrada:** `e8219a04ab322eb51d401ce37177e5f5e33b1cba`  
**Modo:** alto  
**Estado:** teste comportamental sintético PG18 das migrations 034–036 confirmado em execução corrigida, 30/30 PASS; nenhuma mutação Neon.

## 1. Freshness Gate

Branch `main` no início = `identical` ao HEAD CP171, 0 drift. Ponteiro README indicava CP171; checkpoint lido. Foi mantida a exigência de um checkpoint por `Prossiga`, sem aprovação implícita de operações Neon.

## 2. Entrega e evidência

**Documento 128:** `docs/governance/128-ensaio-comportamental-pg18-temporal-034-036.md`.

- `tests/fixtures/f4-temporal-034-036/seed.sql`: produto artificial, plano/fonte, epoch em draft, duas oportunidades congeladas e registro de autoridade **falso exclusivamente para o cenário CI** — não é aprovação humana.
- `scripts/oes_f4_pg18_034_036_behavior_test.py`: harness PG18 exclusivamente descartável/CI-only; instala 001–036, executa testes positivos e negativos para cronologia 034, preflight 035 e novidade/primeira medição 036; não é executor de migrations operacionais.
- `.github/workflows/f4-pg18-034-036-temporal-behavior.yml`: workflow automático de teste somente quando os arquivos do ensaio mudam, `contents:read`, PG18 efêmero e upload de evidência.

**Primeiro run** `39355352898`, commit `85bb17b81fac44f3a59f4cd7b61ba7cd9eb694a4`: `completed/failure`. Após instalar 36 migrations, o fixture de 034–036 reutilizava uma versão de calendário/SLA de teste pré-032 que não passa pelas regras após 036. **Falha do fixture, não prova de defeito das migrations.** Corrigido prospectivamente, mantendo o run no histórico.

**Segundo run** `39355448709`, commit testado `d0c378a99b36f331bc1f5df627cd024448a421e1`, job `118409046787`, `completed/success`, PostgreSQL 18.6; artifact `12235255740`. ZIP recuperado e testado íntegro com SHA-256 `a9326e8d6d5aa3a2f282460ed3465be295767f6d2d513c4f2d1986523b8e2442`, igual ao GitHub. `checks.tsv` contém **30/30 PASS**, logs/relatórios conferidos.

## 3. Resultados

- **034:** trigger ativo e vinculado à função; ausência de started_at, started_at igual à primeira oportunidade e desvio material recusados; ativação cronologicamente válida passou em cenário artificial.
- **035:** epoch inexistente e draft falharam; autoridade artificial + duas oportunidades coerentes permitiram `WAIT` antes da janela, `PASS` dentro da janela e `FAIL` na primeira oportunidade. Preflight não escreveu eventos.
- **036:** primeiro evento concluído requereu `novelty_state=not_applicable` e `new_identifier_count=NULL`; eventos posteriores recusam `not_applicable`, aceitam `zero_new` com contagem 0; conclusão exige `failure_attribution=not_applicable`.
- Nenhuma pessoa validou os dados/autoridade do fixture; as datas de 2030 são artificiais e não renovam B1R1.

## 4. Limites e invariantes

A validação comprova ramos selecionados de funções/triggers em PostgreSQL 18 efêmero, **não** integridade científica, cobertura exaustiva, replay seguro, reconciliação automática, backup ou Neon. A prova de parcialidade de 034/036 em caso de erro entre DROP/CREATE do Documento 126 permanece importante.

- `BRG_04 = HISTORICAL_STATIC_INVENTORY_VERIFIED_PINNED_COMMIT_ONLY`
- `BRG_05 = HISTORICAL_PG18_SCHEMA_INSTALL_PLUS_SYNTHETIC_BEHAVIOR_PINNED_COMMITS`
- `BRG_06 = LEDGER_SYNTHETIC_ONLY_OPERATIONAL_NOT_IMPLEMENTED`
- `BRG_07 = SUPERVISOR_SYNTHETIC_ONLY_OPERATIONAL_NOT_APPROVED`
- `TEMPORAL_034_036_BEHAVIOR = SYNTHETIC_SELECTED_BRANCHES_30_OF_30_PASS`
- `POSTCONDITION_CATALOG = 36_UNREVIEWED_0_APPROVED_NO_AUTO_FLAGS`
- `BRG_03 = ACL_TLS_SECRETS_NOT_VERIFIED`
- `BRG_08 = INDEPENDENT_BACKUP_NOT_CONFIGURED`
- `BRG_09 = OWNER_BILLING_CONSOLE_PENDING`
- `BRANCH_AUTHORIZATION = PREPARED_NOT_APPROVED`
- `NEON_TEST_BRANCH = NOT_CREATED`
- `NEON_SCHEMA_MIGRATION = NOT_STARTED`
- `B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED`
- `PHASE_5 = NOT_STARTED`

## 5. Próximo bloco e parada

Após `Prossiga` e novo Freshness Gate, examinar lacunas de cobertura comportamental e negativa (autoridade ausente/conflitante, fonte não materializada, conexão bloqueada, guardas desabilitados, desvio tardio). Se testar, manter PostgreSQL 18 descartável, sem promover nenhuma pós-condição à categoria operacional. É requerida revisão humana especializada antes de qualquer liberação do ledger, runner, política de segurança ou Neon.

**STOP — pausa obrigatória após reconciliar ponteiro, STATE e CHANGELOG.**

**Fim CP172.**