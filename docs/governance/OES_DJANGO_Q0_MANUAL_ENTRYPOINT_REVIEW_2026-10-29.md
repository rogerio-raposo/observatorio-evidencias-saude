# OES — Entrada manual restrita para o ensaio sintético Django–Q0

Data: 2026-10-29. Base comprovada: Actions 40964431457, 301/301 testes PASS; atestação Neon READ ONLY Actions 40962343481, PASS.

## Implementação

O arquivo `applications/oes_web/scripts/q0_manual_rollback_trial.py` representa um único ponto de entrada manual futuro. Exige dispatch manual, primeira tentativa, repositório e branch aprovados, SHA exato fornecido na revisão, opção literal de ensaio sintético com rollback, configuração multi-alias e credenciais distintas já existentes. Sem entrada de ator ou identificador de questão. A execução chama a composição `review_and_execute_isolated_trial()` que atesta o ator via leitor auth, gera uma questão sintética e invoca a receita de cinco INSERTs em transação revertida e reconciliação independente.

A saída pública contém apenas `PASS_ROLLBACK_ZERO_RESIDUES` ou `HOLD_Q0_MANUAL_ROLLBACK_INCONCLUSIVE`. A função de verificação de gate é testável offline. Não incorporar a `run_connected` geral e não usar o script histórico `run_q0_rollback_once.py`.

## Situação operacional

**NÃO EXECUTADO.** O workflow `.github/workflows/oes-django-q0-single-rollback-hold.yml` permanece inalterado, job conectado com `if: false` e nenhuma credencial. Nenhum marcador Git foi consumido. O novo CLI é invocável em Python apenas com todos os pré-requisitos explicitamente configurados, mas ainda não possui workflow ligado; manter restrito. O novo CI está pendente.

## Verificação final antes de ligar o workflow

1. Confirmar CI offline do novo CLI e da composição; não repetir provisionamento.
2. Revisar se os secrets necessários ainda existem sem revelar seus valores; confirmar SHA fixado e risco de rerun sob controle operacional.
3. Revisar a atestação e o encerramento da transação, e inspecionar eventuais exceções de fechamento do escritor/leitor; falha ou dúvida => HOLD.
4. Habilitar apenas um workflow manual restrito, sem retry, sem HTTP write, sem migrations ou mudanças no Neon. Executar uma única vez conforme a autorização concedida, sem alegar garantia matemática de one-shot.

Marco B OPEN; Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED. CP343 vigente.
