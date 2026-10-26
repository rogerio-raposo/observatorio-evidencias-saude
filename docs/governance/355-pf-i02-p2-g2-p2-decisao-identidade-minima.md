# Documento 355 — PF-I02/P2 — Decisão preparatória G2-P2 e identidade mínima
Data: 2026-10-26. Referências: CP312, Docs 352–354, CI 40285338405 (167/167 PASS). **Situação: proposta para decisão; G2-P2 NÃO AUTORIZADO.**

## Diagnóstico
G2-P0 confirmou catálogo e grants por inspeção administrativa: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, database `oes_sandbox`. Sessão efetiva `oes_sandbox_owner`; o alvo `oes_qprep_writer` permanece `NOLOGIN`, sem UPDATE de tabela e com UPDATE de coluna apenas em `core.entity_version.version_status` e `valid_to`. Portanto, grants observados **não equivalem** a ensaio com identidade mínima. G2-P1 compilou e testou offline o código, mas o construtor do repositório ORM está bloqueado e nenhuma factory/writer Django existe.

## Decisão recomendada — reduzir risco antes de escrever
**G2-P2A (separável de P2B): preflight estrito de identidade e capacidade, READ ONLY.** Após aprovação nominal própria, identificar a sessão de teste e avaliar por catálogo se ela pode operar como papel limitado **sem conceder** roles/grants nem usar a conta administrativa como writer. Permitir consultas de metadados apenas, registrando `session_user`, `current_user`, `rolcanlogin`, membresia, `has_schema_privilege`, `has_table_privilege`, `has_column_privilege`, `pg_has_role(...,'SET')` quando aplicável, sem expor tokens/credenciais. Não executar `SET ROLE` no preflight. Se a identidade mínima não puder ser estabelecida: HOLD, não substituir por `oes_sandbox_owner`.

**G2-P2B (nova autorização própria, NÃO incluída):** um único ensaio sintético Q0 com Django `transaction.atomic(using=alias_aprovado)`, na mesma conexão de todos os advisory locks, leituras de escopo e cinco INSERTs ORM, com rollback intencional. Verificar dentro da transação os cinco objetos e relações UUID, versão inicial `current`, `q0_draft`, recibo `REGISTER_Q0`; em seguida provocar rollback explícito e verificar ausência residual por identificador sintético exclusivo em leitura permitida. Não testar commit durável, Q1, revogação, HTTP write, E9, usuário real ou deploy. Não criar persistência temporária fora da transação.

## Gates formais de abortar
1. Divergência entre projeto, branch, database, identidade runtime ou permissões mínimas; necessidade de role/grant, credencial nova ou alias writer persistente.
2. Backend ORM dormente ainda sem implementação verificável de `transaction.atomic`, locks e revalidação de escopo sob mesmo alias; nenhum bypass ad hoc do `__init__`.
3. Dúvida sobre UPDATE grants, chave composta, CHECKs, defaults, triggers ou tratamento de `IntegrityError`.
4. Erro de conexão, timeout, commit incerto ou ausência de verificação residual restrita: HOLD sem retry automático.
5. Qualquer proposta de leitura de conteúdo real, nova infraestrutura paga ou ampliação além de uma pergunta sintética.

## Autorizações independentes
- **P2A**: somente catálogo/identidade READ ONLY, explicitando o destino acima. Não habilita SET ROLE, DML, DDL, alteração de grant ou P2B.
- **P2B**: requer outro termo formal após P2A, com identidade de execução validada, SHA do código, número máximo de linhas (5), identificador exclusivo, plano de rollback, procedimento de verificação e consentimento explícito para SQL conectado. A execução exige aplicativo conectado de forma controlada, não apenas o plugin Neon SQL.
- O preflight G2-P0 já concluído não substitui P2A, e o sucesso de G2-P1 não implica autorização P2B.

## Proposta de próximo ato
Solicitar aprovação **apenas de G2-P2A**, restrita ao catálogo/identidade, sem executar nenhuma mutação. CP312 permanece vigente. Sem mudança dos gates globais.

**Estado:** `G2_P2A_PROPOSED_NOT_AUTHORIZED / G2_P2B_NO_GO / CP312_ACTIVE / E9_NO_GO`. Marco B OPEN; readiness NOT_READY; Fase 5 NOT_STARTED.
