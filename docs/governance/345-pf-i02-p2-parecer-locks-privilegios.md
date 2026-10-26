# Documento 345 — PF-I02 / P2 — Parecer de compatibilidade de locks PostgreSQL
**Data:** 2026-10-26. **Natureza:** revisão estática e de documentação oficial; **nenhum SQL conectado**. Base: CP310, Docs.343–344, CI 40278044271 (140/140 PASS offline), ACL W2a.

## Constatação decisiva
A cláusula composta `FOR SHARE OF q FOR UPDATE OF ev` é sintaticamente admitida pelo PostgreSQL: múltiplas cláusulas locking por tabelas distintas são permitidas (SQL SELECT: https://www.postgresql.org/docs/17/sql-select.html).
Contudo, em PostgreSQL, **tanto SELECT FOR SHARE quanto SELECT FOR UPDATE exigem UPDATE em pelo menos uma coluna da tabela bloqueada**, além de SELECT (https://www.postgresql.org/docs/17/ddl-priv.html). O G1 confirmou que `oes_qprep_writer` **não possui UPDATE em qualquer coluna de `investigation.question`**. Logo mudar `FOR UPDATE OF q` para `FOR SHARE OF q` não resolve a incompatibilidade de privilégio. O adaptador offline atual é **NO-GO para ensaio conectado com o papel W2a existente**.

## Alternativas delimitadas para decisão futura
A. Reprojetar a serialização com lock consultivo transacional pela identidade global da pergunta, executado **antes** da leitura de responsabilidade e da versão; coordenar necessariamente quaisquer futuras transferências/revogações de responsabilidade por esse mesmo lock. `FOR UPDATE OF ev` permanece candidato, com as permissões de coluna de `core.entity_version`; avaliar riscos de colisão de hash, deadlocks e identidade invariável. Sem prova conectada e sem política de mutação do responsável, esta é somente hipótese.
B. Papel com UPDATE estritamente de coluna em `investigation.question`, a ser proposto somente após revisão dos riscos de alteração indevida do responsável, sem concessão automática; controle SQL adicional pode ser necessário.
C. Abstração SQL privilegiada cuidadosamente delimitada (função `SECURITY DEFINER`, por exemplo) somente se os mecanismos anteriores forem insuficientes e após revisão formal, sem ativação agora.

## Gate
Manter G2 NO-GO. Primeiro decidir a alternativa de autorização/serialização, corrigir o SQL offline e demonstrar invariantes de escopo/revogação e testes sintéticos, seguidos de CI. Nenhuma concessão, SET ROLE, SQL conectado, credencial, Django real, HTTP write, E9 ou deploy autorizado nesta atividade.
**Status:** `POSTGRES_LOCK_SYNTAX_ACCEPTED / WRITER_ACL_INCOMPATIBLE / G2_BLOCKED`. CP310 vigente; Marco B aberto; readiness NOT_READY; Fase 5 NOT_STARTED.
