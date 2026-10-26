# Documento 325 — PF-I02-W2: decisão integrada sobre isolamento, auditoria e idempotência

**Data:** 2026-10-26. **Natureza:** avaliação de arquitetura e metadados READ ONLY; não autoriza SQL mutante, contas, grants, deploy nem dados de pessoas. Base: CP300, Docs. 321–324.

## Inspeção factual (branch sintética)
Neon `weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox`. Transação com `transaction_read_only=on`. `oes_qprep_writer` **não existe**; `core.entity`, `core.entity_version`, `investigation.question` e `investigation.question_version` têm RLS desabilitada; trigger de usuário identificado `investigation.question.tr_question_entity_type` chama `core.assert_entity_type`. Esses resultados não comprovam privilégio efetivo de futura role, nem política de acesso por usuário. Nenhuma tabela foi alterada.

## Escolha arquitetural mínima
**Separar prova estrutural de privilégio W2a e runtime com dados submetidos por usuários.** Para W2a exclusivamente sintético e NOLOGIN, um SELECT de tabela suficientemente delimitado pode testar ACLs, mas **não** será convertido em privilégio de runtime até implementação verificável de isolamento por registro. Não presumir que `created_by` sozinho isola linhas. Uma sessão Django autenticada não transforma um login técnico compartilhado em identidade de cada usuário dentro do PostgreSQL.

**Isolamento humano:** opção preferida para o piloto inicial é um preparador operacional autorizado e acesso restrito ao seu escopo; mesmo assim, escopo de leitura e permissões devem ser verificáveis no serviço. Antes de permitir mais usuários ou registros sensíveis, aplicar fronteira no banco (RLS com contexto de usuário confiável e restrições anti-spoofing, ou funções SECURITY DEFINER extremamente delimitadas e auditadas), e testar leitura cruzada. Não ativar RLS global no schema compartilhado sem análise de impacto e gate DDL separado.

**Auditoria/idempotência durável:** aproveitar `core.entity_version` para histórico (autor, supersession, mudança), mas introduzir **um único ledger mínimo de comando/recibo** ligado ao ID da pergunta, ator, request_id e fingerprint, com unicidade (ator, request_id) e resultado/status de commit. O ledger deve integrar a **mesma transação** de Q0 ou Q1, nunca arquivo paralelo nem log de CI. Um conflito entre fingerprint e chave existente deve ser recusado; um retry idêntico recupera recibo; falha após commit exige reconciliação por chave em transação de leitura antes de refazer. O estado de HOLD e a semântica de rollback são explícitos. Esquema, RLS/policy e permissões do ledger **não foram aprovados nem implementados**.

**Concorrência:** lock da entidade/versão corrente, comparação de `expected_version`, índice único `ux_entity_version_current`, e recibo transacional devem ser testados conjuntamente. Sem lock/revisão/ledger durável, os mocks W1 não comprovam idempotência ou concorrência.

## Revisão do pacote W2a (Doc. 324)
O bloco SQL do Doc. 324 continua **candidato de laboratório, NÃO APROVADO para aplicação/runtime**. Preflight adicional antes de qualquer CREATE ROLE: verificar ACL de `PUBLIC`, memberships, esquema e EXECUTE do trigger/função, pois uma tabela com ACL nula não implica negativa efetiva. Negativas em Investigation/E9 e produtos são obrigatórias. A concessão direta de SELECT em quatro tabelas não deve alcançar o runtime sem aprovação da política de isolamento.

## Decisão proposta e continuidade
**Fechar a discussão conceitual:** a próxima entrega útil é **o design executável mínimo do ledger de comandos e controle de leitura**, junto ao Unit of Work transacional Django/PostgreSQL, revisado em um único pacote com migração e testes negativos, sem novo ensaio isolado. Até lá W2a e W2b não estão aptos à execução segura como runtime. Solicitar aprovação específica para esse design/código offline, sem DDL e sem inventar uma segunda stack.

Marco B aberto; E9 NO-GO; A3 ausente; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
