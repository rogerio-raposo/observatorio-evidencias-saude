# OES — PF-I04/P4-A33 | Encerramento da validação remota offline

**Estado:** `GITHUB_OFFLINE_VALIDATION_PASS / CONNECTED_ROLE_TRIAL_SKIPPED / NO_NEON`.
**Referência:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40622890545
**Data factual do run:** 2026-10-28 02:46:27 UTC (2026-10-27 23:46:27, America/Recife).
**Checkpoint vigente:** CP325 (não substituído).

## Evidência GitHub efetivamente verificada
- Run ID `40622890545`; `run_number=1`; `run_attempt=1`; disparo `workflow_dispatch`; branch `main`; `head_sha=01553be79f77b198673d45caddfa77f739b042a3`.
- Workflow `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml`, nome `OES PF-I04 P4-A32 rollback-only ROLE trial — HARD HOLD`.
- Run `status=completed`, `conclusion=success`.
- Job `122600872545`, `Verify immutable A29 SQL offline (no Neon, no secrets)`: `completed/success`; todos os seis passos têm conclusão success, incluindo os dois passos de validação.
- Job `122600915025`, `HARD HOLD — no database connection or mutating SQL`: `completed/skipped`.
- Logs do job offline consultados e confirmados literalmente:
  - `OFFLINE_PASS: A29 SQL identities and ROLLBACK verified; NO SQL CONNECTION`.
  - `HARD_HOLD_CONFIRMED: connected-role-trial is SKIPPED unconditionally`.
- Esses resultados demonstram que o YAML rodou no runner GitHub, o checkout dos arquivos A29 passou nas verificações de integridade e a trava efetivamente impediu o job conectado neste run. Nenhum fato de conexão Neon, alteração de membership, GRANT, REVOKE ou SET ROLE foi produzido. Ausência de alteração inferida da execução somente offline e do job conectado SKIPPED, não de consulta catalogal independente.

## Conclusão restrita
`PF-I04/P4-A33 = REMOTE_OFFLINE_PASS`. O ensaio A29 ROLLBACK-ONLY **NÃO EXECUTADO**; não existe prova empírica de atomicidade, grantor-aware revoke, SET LOCAL ROLE, nem postflight. Nenhum segredo cadastrado nesta atividade. O sucesso do workflow **não autoriza** remover `if: false`, efetuar qualquer teste mutante ou iniciar Django. Postflight A29 também não autorizado.

## Ponto seguinte
P4-A34: revisão proporcional do workflow e definição do gate nominal para ensaio transacional conectado **somente se** credenciais descartáveis, rollback garantido, formato de logs, independência do postflight e proibição de custos pagos estiverem controlados. Alternativamente, auditar as afirmações do workflow sem jamais remover `if: false`. P4-A34 começa como documentação/revisão; qualquer ativação exige nova aprovação explícita. CP325 segue vigente; checkpoint após número proporcional de atividades ou risco. Gates globais inalterados: Marco B OPEN, G2-P2B NO-GO, E9 NO-GO, readiness NOT_READY, P4 NOT_AUTHORIZED, Fase 5 NOT_STARTED.
