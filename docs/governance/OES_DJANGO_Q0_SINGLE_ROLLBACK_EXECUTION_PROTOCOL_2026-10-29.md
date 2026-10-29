# OES — Protocolo pré-operacional de ensaio único Django–Q0, rollback obrigatório

Data: 2026-10-29. Fonte de evidência: GitHub Actions 40950780938, commit b6a05349f0041907569ea2c59623c987e96426b7, 282/282 testes PASS **offline**. Escopo nominal autorizado pelo responsável: **um único ensaio conectado sintético com INSERTs transitórios, rollback obrigatório, reconciliação READ ONLY**. Autorização **não consumida**. O documento não habilita fluxo conectado nem constitui PASS operacional.

## Controle de escopo

Neon project weathered-boat-65779510; branch experimental br-gentle-hall-b6jaxehf; banco oes_sandbox. Writer Django alias oes_q0_writer, role oes_qprep_login. Leitor independente alias oes_synthetic_reader, role oes_pg_a4_reader, sessão read-only. Autenticação no alias default, role oes_auth_trial_login, schema django_auth. Não mudar produção, oes_app, schemas, roles, GRANT, migrações, credenciais, endpoint HTTP, deploy, E9 ou Fase 5. Apenas uma tentativa e sem retry automático.

## Avaliação crítica do candidato atual

Arquivo applications/oes_web/scripts/q0_rollback_transaction_candidate.py: método interno _perform_rollback_only implementa cinco inserts ORM, transaction.atomic(savepoint=False), set_rollback(True) em finally, leitura independente após fechamento do writer; run_connected sempre HOLD. **Ainda não está apto a dispatch.**

Bloqueadores concretos:
- verified_actor é argumento; validate_persisted_actor_trial confirma igualdade/formato, **não comprova consulta autenticada à associação PreparerIdentity**. A prova de proveniência deve acontecer em uma composição isolada, antes da transação, sem aceitar input de actor pelo usuário ou workflow.
- Validar explicitamente o ramo de falha/fechamento da transação: se o writer permanecer in_atomic_block ou o fechamento falhar, resultado HOLD com evidência de estado incerto; nenhum PASS.
- Reader fresco, alias distinto, vendor PostgreSQL, autocommit ativo, ausência de in_atomic_block e server-side current_user, database, transaction_read_only='on'; exigir mesma branch/host por configuração pinada. Conferir resíduos com as cinco tabelas e chaves sintéticas, inclusive oes_id alternativo.
- O teste offline após falha comprova apenas cenários simulados; faltam prova mock de sucesso completo, falha na operação quinta, resultado residual, falha na sessão e mismatch de identidade.
- O pré-check do writer exige usuário, database e modo read-write; conferir também transação externa antes do início e política de privilégios existente, sem executar GRANT.
- Identificadores e fingerprint deverão ser produzidos pelo fluxo sintético canônico, sem valores escolhidos externamente e sem reutilizar uma tentativa. Verificar que ORM mapeia exatamente cinco tabelas, sem side effects extras.

## Protocolo de execução futura

1. Freeze do commit do runner aprovado após CI offline; nenhum workflow deve apontar para main móvel.
2. Revisão de configuração exclusivamente sob secrets de autenticação, writer e leitor já previstos, sem impressões em logs.
3. Preflight nominal fail-closed: destino exato, três identidades separadas, autenticação sintética persistida e autorização somente para ensaio, ausência prévia de chaves.
4. Criar uma única transação no alias writer: locks, cinco INSERT ORM e verificação das cinco linhas dentro dela; rollback obrigatório em finally, inclusive em exceção.
5. Fechar writer antes de abrir sessão nova do leitor; reconciliar ausência dos cinco registros e identidade oes_id. Nunca usar DELETE compensatório.
6. Classificar: PASS_ROLLBACK_ZERO_RESIDUES somente se transação percorreu integralmente cinco operações, rollback confirmado e leitura independente atestou zero resíduos; HOLD_TRANSACTION_FAILED_ZERO_RESIDUES em falha com reconciliação positiva; HOLD_UNVERIFIED quando rollback/leitor/resíduos forem incertos; HOLD_RESIDUES quando houver qualquer linha remanescente.
7. Encerrar tentativa sem reexecução automática, remover secrets temporários se criados e publicar evidência não sensível (run, SHA, fase e categoria).
8. Manter executor Q0 geral HARD HOLD, Marco B OPEN, E9 NO-GO, Fase 5 NOT_STARTED independentemente de PASS sintético.

## Decisão atual

**NO-GO para execução conectada até correção dos bloqueadores e CI específico.** Não repetir provisionamento sintético ou ACL preflights históricos. Próxima ação: corrigir exclusivamente o candidato isolado e executar testes offline direcionados, seguindo uma única revisão antes de preparar o workflow manual.
