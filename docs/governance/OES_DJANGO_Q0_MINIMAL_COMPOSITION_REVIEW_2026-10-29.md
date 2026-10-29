# OES — Composição mínima do candidato Django–Q0

Data: 2026-10-29. Evidência de base: Actions 40964111444, 299/299 PASS; atestação Neon READ ONLY 40962343481, PASS.

## Alteração

Em `scripts/q0_rollback_transaction_candidate.py`, foi criada a função interna `review_and_execute_isolated_trial()` que encadeia, sem entrada externa de ator: (1) `prepare_persisted_service_trial_readonly()` e (2) `_perform_rollback_only(trial=trial, verified_actor=actor)`. A receita existente mantém cinco INSERTs ORM transitórios, `set_rollback(True)`, fechamento da conexão escritora e reconciliação independente READ ONLY. Dois testes offline cobrem a passagem exata do ator e a interrupção antes da receita quando falha a atestação.

## Limites e riscos

**NÃO EXECUTADO.** O ponto de entrada público `run_connected` continua rejeitando chamadas; o workflow de ensaio mantém `connected-trial if: false`, sem credenciais de escrita. A nova função interna possui efeitos conectados se chamada diretamente por código Python com aliases habilitados: não tratá-la como API pública, não importá-la em views, rotas, serviços produtivos ou jobs não revisados. A composição ainda não está CI-validada.

Antes de disponibilizar execução manual, revisar o script mínimo de entrada e verificar configuração de quatro aliases, ausência de transação externa, identificadores e conta de destino, comportamento diante de rollback incerto, fontes de segredos e a garantia de que nenhum caminho faça commit. Não executar o script legado `run_q0_rollback_once.py`, que possui outro contrato de ator. Evitar novo mecanismo de referência Git: a tentativa única será operacional, nominalmente rastreada e sem retry.

## Próximo passo

Executar CI offline na branch main, esperar 301/301 testes se nenhum outro teste for incluído. Depois implementar o wrapper de execução manual estritamente restrito, submetê-lo à revisão final e realizar a única tentativa previamente autorizada, sem ampliar o escopo.

CP343 vigente; Marco B OPEN, executor Q0 geral HARD HOLD, E9 NO-GO, Fase 5 NOT_STARTED.
