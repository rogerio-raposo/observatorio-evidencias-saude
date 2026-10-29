# OES — Marco B — Desenho do ensaio integrado Django–Q0 com rollback obrigatório

**Data:** 2026-10-29. **Estado:** desenho documental, não executável. **Base:** [revisão de prontidão](OES_DJANGO_Q0_INTEGRATION_READINESS_2026-10-29.md).
**Gates:** Marco B OPEN; executor Django Q0 HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED.

## Objetivo e fronteira

Demonstrar, em autorização futura e única, que a composição Django ORM consegue percorrer cinco operações sintéticas Q0 dentro de UMA transação PostgreSQL do alias `oes_q0_writer`, com rollback forçado antes da saída e inspeção independente posterior pela identidade `oes_pg_a4_reader`. Isso **não** demonstrará persistência, commit, login operacional nem autorização para uma API.

Neon restrito a project `weathered-boat-65779510`, branch experimental `br-gentle-hall-b6jaxehf`, database `oes_sandbox`. Não tocar `production`, `oes_app`, papéis, grants, migrations ou credenciais administrativas. Preservar a autenticação em `django_auth`.

## Pré-condições que exigirão novo gate nominal

1. Aprovação explícita de um único ensaio conectado **INSERT transitório + rollback obrigatório**, distinto da autorização anterior para provisionamento de identidade. Nenhuma execução fica autorizada por este documento.
2. Reconhecer que os testes SQLite `force_login` apenas simulam autenticação. Para o ensaio, usar uma representação de principal sintético **interna e não exposta por HTTP**, derivada exclusivamente do vínculo persistido; não alegar login real.
3. Validar novamente, na própria execução, identidade, branch e alias escritor, `transaction_read_only=off`, ausência de transação externa, privilégio mínimo SELECT/INSERT nas cinco tabelas e ausência de UPDATE/DELETE. Usar `oes_qprep_login`; não usar owner/migrator.
4. Validar alias reconciliador independente, sessão fresca `transaction_read_only=on`, papel `oes_pg_a4_reader`, cinco tabelas SELECT; confirmar distinção das credenciais e endpoint direto.
5. Gerar previamente identificadores sintéticos específicos da tentativa: request ID, question ID, dois UUIDs e fingerprint. Verificar ausência de recibo e de registros para as chaves. Nunca reutilizar identificadores de outros ensaios.
6. Garantir que apenas o ator obtido de `PreparerIdentity.actor_uuid` seja empregado na autoria e no recibo. Não aceitar UUID escolhido pelo chamador nem registrar valores sensíveis em logs.

## Ordem da unidade de trabalho

1. Entrar em `transaction.atomic(using="oes_q0_writer", savepoint=False)` com conexão e repositório vinculados ao mesmo alias.
2. Obter locks transacionais de request e question; rejeitar duplicidades antes da primeira escrita.
3. Inserir, na ordem compatível com FKs, os cinco registros canônicos: `core.entity`, `investigation.question`, `core.entity_version`, `investigation.question_version`, `investigation.question_command_receipt`.
4. Verificar dentro da transação todas as chaves, autoria, versão 1, estado Q0 e fingerprint do recibo.
5. Executar `transaction.set_rollback(True, using="oes_q0_writer")` obrigatoriamente em `finally`, mesmo após validação positiva. Nenhum branch de commit permitido.
6. Encerrar a transação, fechar a conexão escritora e abrir **nova sessão independente somente leitura**; consultar a ausência dos cinco registros e do recibo em todas as chaves relevantes. Qualquer falha ou leitura incompleta produz HOLD, nunca PASS.
7. Registrar unicamente `PASS_ROLLBACK_ZERO_RESIDUES` ou `HOLD` com categorias não identificáveis. Não imprimir senhas, UUID, username, payload ou texto da pergunta.

## Critérios de aceitação e parada

**PASS somente se:** preflights completos; exatamente cinco tentativas ORM dentro da transação; invariantes internas positivas; rollback forçado; reconciliação por sessão independente mostra zero resíduos em todas as cinco tabelas e no recibo.

**HOLD:** qualquer identidade/alias errado, divergência de ACL, duplicidade, exceção, integridade inválida, transação externa, rollback não confirmado, insuficiência de leitura, resultado incerto ou tentativa de repetição. Nenhuma compensação DELETE, reexecução automática ou ampliação de privilégio.

## Observação arquitetural

A receita `_rollback_recipe` e o `DjangoQ0Repository` atuais são dormentes e não devem ser desbloqueados diretamente. Implementação operacional futura deverá ser uma entrada isolada de ensaio único, revisada e testada sem banco primeiro. **Sem ativação de `execute_connected_q0`, sem HTTP write, sem deploy ou DML agora.**

**Próxima decisão:** aprovar separadamente apenas a preparação de uma implementação offline inerte do ensaio, ou posteriormente conceder gate nominal estrito para INSERT transitório e rollback. Este documento não concede nenhum deles.
