# OES — Marco B — Prontidão para ensaio Django–Q0

**Data:** 2026-10-29. **Natureza:** avaliação documental; nenhuma autorização de DML ou ativação de executor.

## Evidência consolidada

- Provisionamento único sintético: Actions 40903228787, PASS_POST_COMMIT.
- Verificação independente da identidade e permissão: Actions 40905200153, PASS_READ_ONLY.
- Sessões simuladas e vínculo persistido de ator: Actions 40938530923, 273/273 testes offline PASS, SHA 8bc940e5d98a1f65a33d2c21e6652364fede858e.
- Preflights prévios dos aliases de autenticação, escritor e leitor: PASS conectado exclusivamente em leitura.
- O piloto SQL sintético anterior não comprova commit da composição ORM Django atual.

## Fronteiras técnicas identificadas por inspeção

1. execute_connected_q0 e _review_authenticated_q0_composition geram HOLD incondicional.
2. DjangoQ0Repository.__init__ gera HOLD incondicional.
3. A receita _rollback_recipe usa transaction.atomic sobre o alias e marca rollback obrigatoriamente. Não representa ensaio de commit.
4. O submit_authenticated_question_command obtém ator persistido de PreparerIdentity; há testes SQLite de não substituição do identificador.
5. O preparador sintético usa senha inutilizável; o force_login só comprova simulação de sessão no Django test client.

## Condições mínimas antes de um eventual gate conectado

- Definir explicitamente o escopo do ensaio: rollback-only ou commit único; nunca inferir autorização de commit a partir de autorização de rollback.
- Confirmar ator originado do vínculo persistido, sem UUID livre fornecido pelo cliente.
- Estabelecer uma única transação no alias oes_q0_writer e cinco registros esperados com recibo persistido.
- Garantir verificações preflight, no interior da transação e pós-transação por oes_synthetic_reader em sessão nova READ ONLY.
- Se commit incerto, não repetir nem compensar automaticamente. Exigir reconciliação independente.
- Preservar impossibilidade de ativação por HTTP e a proibição de implantar ou usar dados reais.
- Solicitar gate nominal separado antes de alterações executáveis e antes de DML.

## Encaminhamento

A preparação de identidade e autorização offline é suficiente. O próximo passo é aprovar ou recusar um desenho único de ensaio sintético Django–Q0, com escopo e critérios de parada. Nenhuma credencial, GRANT, migração, endpoint ou escrita está autorizada por este documento.

**Estado:** CP342 vigente; Marco B OPEN; executor Q0 HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED.
