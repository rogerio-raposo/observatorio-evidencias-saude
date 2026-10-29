# CP344 — Continuidade OES — 2026-10-29

**Antecessor:** CP343. **Estado:** checkpoint de continuidade vigente após atualização dos ponteiros, sujeito ao Freshness Gate. **Ponto exato de retomada:** revisão final da execução manual isolada de um ensaio sintético Django–Q0, sem acionar a escrita até revisão e CI do workflow operacional.

## Evolução comprovada desde CP343

- Provisionamento da única identidade sintética e vínculo Django concluído antes de CP343; **não repetir**. Identidade de serviço persistida verificada em PostgreSQL Neon exclusivamente READ ONLY: Actions [40962343481](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40962343481) **PASS_READ_ONLY_SYNTHETIC_SERVICE_IDENTITY**. Alias `oes_auth_readonly` isolado; não confundir com login real.
- Validação atual mais recente: GitHub Actions [40964845881](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40964845881), commit `d4a02a64f3ccd111d6b3dc344cd25222104c808c`, **303/303 PASS offline** (298 Django + 5 SQLite). Antes: [40964431457](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40964431457) 301/301 PASS; [40964111444](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40964111444) 299/299 PASS; [40962844354](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40962844354) 296/296 PASS.
- Receita em `applications/oes_web/scripts/q0_rollback_transaction_candidate.py`: cinco INSERTs ORM transientes nas cinco tabelas sintéticas, `transaction.atomic(savepoint=False)`, `set_rollback(True)` em finally, fechamento escritor e reconciliação independente com leitor `oes_synthetic_reader`; método `run_connected` ainda rejeita.
- `prepare_persisted_service_trial_readonly()` deriva ator `oes:actor:<uuid>` do vínculo READ ONLY e gera trial sintético canônico. `review_and_execute_isolated_trial()` o passa à receita transacional, **não está ligado a workflow habilitado**.
- Novo CLI `applications/oes_web/scripts/q0_manual_rollback_trial.py` valida evento manual, primeira tentativa, branch, SHA revisado e presença de variáveis/segredos antes de chamar composição. Seu próprio ponto de entrada é invocável em ambiente configurado, portanto requer proteção no workflow. Testes offline PASS; **não houve execução conectada de INSERT nesta autorização**.
- Workflow `.github/workflows/oes-django-q0-single-rollback-hold.yml` continua com job `connected-trial if: false`, sem secrets científicos.
- Documentos relevantes: `docs/governance/OES_DJANGO_Q0_PROPORTIONAL_SIMPLIFICATION_DECISION_2026-10-29.md`, `OES_DJANGO_Q0_MINIMAL_COMPOSITION_REVIEW_2026-10-29.md`, `OES_DJANGO_Q0_MANUAL_ENTRYPOINT_REVIEW_2026-10-29.md`, `OES_DJANGO_Q0_SINGLE_ROLLBACK_EXECUTION_PROTOCOL_2026-10-29.md`.

## Decisão de proporcionalidade

O responsável identificou excesso de controles auxiliares e aprovou simplificar. Não incorporar `q0_single_use_git_ref_gate.py`, marcador/tag Git, rulesets ou um terceiro executor ao caminho operacional; conservar o candidato transacional recente. Tentativa única é **controle operacional** (um dispatch manual nominal, sem retry), **não garantia matemática** contra outro despacho administrativo; registrar risco residual. Não reexecutar provisão/admin ou preflights históricos; evitar microgates e testes redundantes. Documento canônico 362 orienta governança proporcional.

## Ponto exato de retomada — executar apenas após prontidão

1. Conferir estado da branch `main`, `README.md`, `STATE.md`, template canônico e Documentos 362 e de integração; aplicar Freshness Gate.
2. Fazer revisão curta, técnica e concreta do CLI, do fechamento/rollback do writer, da conciliação do reader e dos secrets exigidos; **não assumir disponibilidade dos segredos sem checagem**. Fixar SHA aprovado e confirmar aderência do contexto de workflow. Não imprimir valores.
3. Integrar CLI ao **workflow manual específico**, sem retry, sem ambiente produtivo, sem migração, deploy ou endpoint HTTP. A execução conectada só deve ser habilitada quando o runner completo e escopo estiverem revisados/validados; a autorização nominal existente não é uma aprovação genérica para alterações de privilégios ou outras operações.
4. Na única execução autorizada, classificar PASS somente se cinco operações internas confirmadas, ROLLBACK realizado e leitor independente comprovar zero resíduos. Qualquer incerteza = HOLD; não repetir automaticamente. Registrar run, SHA e status não sensível e atualizar checkpoint.

## Gates e acordos

**Autorização explícita anterior:** um único ensaio Django–Q0 sintético conectado com cinco INSERTs transitórios, ROLLBACK obrigatório e reconciliação READ ONLY; **não consumida**. Não usar `Prossiga` como autorização para ampliar escopo, executar migrações, alterar roles/grants/secrets ou promover gates.

Neon experimental project `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`. Produção e `oes_app` intocados. **Marco B OPEN; Q0 executor geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED; pesquisadores ainda indisponíveis.** Persistir commits e checkpoints, usar documentação como autoridade, distinguir teste offline de evidência PostgreSQL.
