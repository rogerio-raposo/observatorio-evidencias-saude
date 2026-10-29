# OES — Composição mínima do ensaio Q0 com identidade atestada

Data: 2026-10-29.

No candidato existente `applications/oes_web/scripts/q0_rollback_transaction_candidate.py` foi introduzida `prepare_persisted_service_trial_readonly()`. Essa função atesta a identidade sintética persistida usando `oes_auth_readonly`, gera identificadores sintéticos frescos, constrói o `SyntheticQ0Trial` canônico e valida o vínculo ator–ensaio. A função não conecta o escritor nem chama os cinco INSERTs.

Dois testes offline cobrem o vínculo correto e a rejeição de ator não canônico, sem acesso a banco. O método `run_connected` mantém `raise PreparationHold`; o workflow conectado mantém `if: false`. Nenhum marcador Git será integrado ao fluxo operacional. O módulo antigo `run_q0_rollback_once.py` permanece fora do caminho adotado.

**Importante:** a composição está preparada, mas a passagem dessa função para `_perform_rollback_only` ainda não foi conectada ao ponto de entrada. Não declarar ensaio operacional nem PASS integrado antes da revisão final e do CI. O último CI previamente comprovado tem 296/296 PASS (40962844354), anterior a estes dois testes.

Próximo passo proporcional: validar a pequena alteração offline, revisar o wrapper manual isolado e realizar o ensaio já autorizado com ROLLBACK, leitor independente e registro de uma única tentativa administrativa, sem prometer unicidade técnica absoluta. Não executar DML sem o caminho revisado. Marco B OPEN, executor Q0 geral HARD HOLD, E9 NO-GO, Fase 5 NOT_STARTED. CP343 ainda vigente.
