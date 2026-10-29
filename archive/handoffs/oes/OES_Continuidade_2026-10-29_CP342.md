# OES — CP342 — 2026-10-29

Anterior: CP341. Marco B OPEN; Q0 conectado HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED.

## Encerramento do ensaio administrativo sintético

- CI offline: 268/268 PASS, [run 40902960370](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40902960370).
- Primeira tentativa administrativa [40902356790](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40902356790): HOLD antes da conexão, faltava secret.
- Provisionamento único autorizado: [run 40903228787](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40903228787), SUCCESS e PASS_POST_COMMIT, com reconciliação independente reportada. Commit da execução: 4c56aa35d56359345180ff24ff63841a47f9e56e.
- Responsável confirmou exclusão do secret temporário OES_AUTH_MIGRATOR_PASSWORD. Essa exclusão não significa revogação de credencial PostgreSQL.
- Não reexecutar o workflow de provisionamento nem criar outro usuário sem novo gate.

## Próximo controle

Workflow READ ONLY postcommit em .github/workflows/oes-django-synthetic-preparer-postcommit-read-only.yml: verificação direta das invariantes do único usuário, identidade, senha inutilizável, permissão direta e contrato de autorização em memória. Não autoriza HTTP, escrita Q0 ou login real. **Validado conectado READ ONLY:** [Actions 40905200153](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40905200153), SHA `60f519e4bfac97baeb096432102b8bc1b3063c5c`, `PASS_READ_ONLY: one synthetic identity, exact direct permission, unusable password, policy contract`. As consultas independentes verificaram identidade e vínculo direto, flags e senha inutilizável; o contrato de autorização foi ensaiado com objetos em memória. Não constitui autenticação Django real por sessão nem Q0 integrado.

**Encerramento formal restrito:** frente de provisionamento e validação cadastral sintética encerrada tecnicamente. Não promove Marco B, E9, Fase 5 nem autoriza reexecução.
