# Documento 272 — Pedido de autorização para SET ROLE sintético transitório (D2-E6)

**OES — 2026-10-24 | Base CP274 e Documentos 269–271 | HEAD de preparação:** `38867d1788816b50e7a97d18b8d1e7a026181f62`  
**Status:** `PROPOSAL_ONLY / TEMPORARY_ROLE_MEMBERSHIP_NOT_APPROVED / E6_G1_FACTUAL_BLOCKED`.

## 1. Finalidade e alcance proposto
Solicitar autorização expressa para um **teste transitório de permissões PostgreSQL**, usando apenas a branch experimental Neon `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`, banco `oes_sandbox`. Objetivo: verificar de maneira efetiva o bloqueio de SELECT para o escritor `oes_e6_writer` e de INSERT para o verificador `oes_e6_verifier` via `SET LOCAL ROLE` em transações de teste, sem criar senhas nem contas com LOGIN.

**Não autoriza:** coleta factual, alteração do workflow, abertura de API, mudança de privilégios sobre dados existentes, novo serviço, branch principal, dados reais, serviços pagos ou publicação de JSON.

## 2. Condições obrigatórias
1. Freshness Gate GitHub e read-only preflight Neon de identidade administrativa atual, existência de papéis, `pg_auth_members`, `pg_has_role(...,'SET')`, grants no schema privado e contagem de linhas, antes de qualquer mudança.
2. Se e somente se houver suporte confirmado no PostgreSQL Neon, permitir ao administrador `oes_sandbox_owner` **associação temporária com opção SET mas sem herança** aos dois papéis exclusivamente para testes. A sintaxe concreta de `GRANT role ... WITH SET TRUE, INHERIT FALSE` deve ser conferida para PostgreSQL 18 antes da execução; não ampliar CREATE, LOGIN, ownership ou permissões de tabelas. Não prosseguir se o mecanismo de associação segura não estiver disponível.
3. Testar com `SET LOCAL ROLE` em transações curtas e exclusivamente com dados sintéticos. Leitura como writer deve falhar; escrita como verifier deve falhar. Se usar testes positivos, registrar bytes sintéticos e remoção controlada sem resíduos; nunca inserir dado factual.
4. **Revogação incondicional da associação temporária** após os testes, incluindo qualquer falha. Confirmar `pg_has_role(owner,role,'SET') = false` e ausência da membership recém-criada. Não deixar vinculação administrativa persistente; em caso de impossibilidade de revogar, STOP e registrar incidente em vez de declarar PASS.
5. Testar que a fixture PG-A4 permanece intocada (2 estudos, 2 relatórios, 3 vínculos, 1 proveniência) e a tabela privada permanece vazia. Não imprimir bytes ou segredos em logs ou artifacts.

## 3. Risco residual e gate
A concessão temporária de membership é uma alteração de controle de acesso no banco e exige aprovação distinta, mesmo no ambiente sintético; `Prossiga` por si só **não** equivale a essa autorização. Reverter concessões e comprovar estado pós-teste faz parte obrigatória da atividade futura. Não considerar mero teste de ACL em catálogo equivalente a teste negativo sob role efetiva.

**Forma sugerida de decisão:**

`APPROVED — OES / D2-E6 / TEMPORARY_SET_ROLE_MEMBERSHIP_SYNTHETIC_ONLY / br-gentle-hall-b6jaxehf / verify-and-revoke / no factual GET / no public JSON / no paid services / fail closed`

Esta minuta não implementa, executa nem aprova automaticamente o procedimento.

**STOP — aguardando autorização explícita.**
