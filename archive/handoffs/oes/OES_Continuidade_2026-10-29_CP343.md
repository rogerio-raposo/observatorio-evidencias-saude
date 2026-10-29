# CP343 — Continuidade OES — 2026-10-29

**Antecessor:** CP342. **Ponto de retomada:** resolver os bloqueadores de revisão do candidato transacional isolado, sem habilitar o runner antes de CI específico.

## Evidência desde CP342

- Provisionamento sintético único e verificação READ ONLY permanecem concluídos (ver CP342). Não repetir.
- Django/SQLite offline: Actions [40950780938](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40950780938), commit b6a05349f0041907569ea2c59623c987e96426b7, **282/282 PASS** (277 testes principais e 5 SQLite).
- Contratos de rollback, isolamento de identidades e tratamento de falhas simuladas integrados. Candidato scripts/q0_rollback_transaction_candidate.py contém receita interna de cinco inserts/rollback/reconciliação, mas run_connected permanece HOLD.
- Autorização explícita do responsável para **um único ensaio sintético Django–Q0 com INSERT transitório + rollback obrigatório e reconciliação READ ONLY**, não consumida. Não houve DML conectado sob essa autorização.
- Protocolo novo: docs/governance/OES_DJANGO_Q0_SINGLE_ROLLBACK_EXECUTION_PROTOCOL_2026-10-29.md, incluindo **NO-GO de execução até corrigir bloqueadores reais**.

## Bloqueadores finais

1. Confirmar origem do verified_actor em identidade persistida autenticada, não só igualdade com trial.
2. Reforçar fail-closed para fronteiras de transação e sessão leitora, inclusive falha de encerramento e ausência de sessão independente.
3. Testes offline específicos para sucesso integral mock, falha no quinto INSERT, resíduos, reader indisponível e autenticação irregular.
4. CI offline da revisão e workflow manual de uma só tentativa com SHA fixo; avaliar disparo somente depois de fechamento técnico documentado. Nenhum acesso público, commit científico, retry ou DELETE compensatório.

## Gates

Marco B OPEN; Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED; pesquisadores ausentes. Neon experimental project weathered-boat-65779510, branch br-gentle-hall-b6jaxehf, DB oes_sandbox. Produção e oes_app intocados. Não repetir ações existentes, evitar novos testes preparatórios redundantes, não habilitar serviços pagos.

## Acordos

Continuar por pequenos incrementos reais, persistir no GitHub, Freshness Gate, não pedir autorizações já concedidas dentro do mesmo perímetro; autorização conectada não dispensa os controles de prontidão. Prossiga permite preparação offline, **não bypass de HARD HOLD**.
