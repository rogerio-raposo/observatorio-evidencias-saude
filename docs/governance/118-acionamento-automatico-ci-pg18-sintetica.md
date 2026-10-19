# 118 — Aprovação e configuração do acionamento automático da CI sintética PG18

**OES / Fase 4 / 2026-10-19 / modo médio**  
**Status:** CI_AUTO_TRIGGER_CONFIGURED — CI_RUN_NOT_VERIFIED — NO_NEON_MUTATION.

## Autorização e escopo

O owner declarou: **“Aprovado — acionamento automático da CI sintética”**. Aplicação estrita ao workflow `.github/workflows/f4-neon-pg18-schema-rehearsal.yml`, sem expansão para operações ou recursos Neon.

Freshness Gate CP161: HEAD `5b5aa79c503065a3545a427a4d4e0e3a527e0175`, main idêntica, zero commits externos.

## Alteração implementada

Commit `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`. O workflow manteve `workflow_dispatch` e recebeu:
```yaml
  push:
    branches:
      - main
    paths:
      - '.github/workflows/f4-neon-pg18-schema-rehearsal.yml'
```
Logo o disparo automático fica deliberadamente restrito a alterações do próprio workflow em `main`; mudanças nos SQL não disparam esta rotina por si só. Permanecem `contents: read`, contêiner PostgreSQL 18 descartável, credencial sintética da job e nenhuma conexão Neon.

## Verificação e limitações

Código YAML atualizado com sucesso e commit confirmado. A consulta pública à API de workflow runs não estava acessível nesta sessão; nenhum run_id/job/log/artifact pôde ser comprovado. A alteração **pode** ter iniciado o workflow pelo evento push, mas isso não permite inferir conclusão ou sucesso. `PG18_RUNTIME_VALIDATION = PENDING`. Há riscos técnicos de execução e nenhum PASS foi inventado.

## Proibições preservadas

Nenhuma criação de branch Neon, roles, schema, migration, ledger, backup ou SQL na infraestrutura Neon. B1R1 EXPIRED_NOT_EXECUTED; Fase 5 não iniciada. Decisões sobre ledger, bloqueios transacionais e custos permanecem no gate de autorização próprio.

## Continuidade

Descobrir o run GitHub Actions da alteração e inspecionar logs, passos e artifacts; caso a integração não consiga descobri-lo, solicitar uma URL verificável ou construir via CI um registro auditável sem ampliar permissões indevidamente. Não automatizar operações Neon.

**Fim do Documento 118.**