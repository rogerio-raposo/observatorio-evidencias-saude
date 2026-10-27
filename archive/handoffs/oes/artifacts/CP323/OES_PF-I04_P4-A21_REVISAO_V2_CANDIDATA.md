# OES — PF-I04/P4-A21: contrato transacional v2 (candidato DOCUMENTAL)

**Estado:** HOLD / NOT AUTHORIZED / NOT TESTED. Preparado em 2026-10-27, checkpoint vigente CP322. Freshness Gate main `3186476599a750d5e9eaeb184b6b59f3c8af50a8`.

## Escopo
- Apenas Bloco A Django Auth/sessions; os cinco objetos Q0 não recebem nenhum grant.
- OES Neon sandbox: project `weathered-boat-65779510`; branch `br-gentle-hall-b6jaxehf`; db `oes_sandbox`; executor `oes_sandbox_owner`.
- Papel runtime dedicado, sem poder administrativo; migrador continua NOLOGIN e proprietário das nove tabelas Django.
- Associação original `cloud_admin` OID `155649`, ADMIN true, INHERIT false, SET false preservada.

## Artefatos
1. `OES_PF-I04_P4-A21_TRANSACAO_V2_CANDIDATA_HOLD.sql`: contém **trava incondicional `RAISE EXCEPTION` antes dos GRANTs**, a ser substituída apenas por nova versão e autorização específica. Preflight fail closed; GRANT temporário do owner com SET TRUE; SET LOCAL ROLE; grants Django; restauração; REVOKE pelo concedente específico; matriz completa antes do commit. **Não executar.**
2. `OES_PF-I04_P4-A21_POSTFLIGHT_INDEPENDENTE_CANDIDATO.sql`: consulta catalogal independente sem acesso a dados de tabelas, exige autorização READ ONLY futura. **Não executado.**

## Concessões candidatas
- USAGE no schema oes_app; nenhuma CREATE.
- SELECT nas sete tabelas Auth/ContentTypes, sem outras operações, e UPDATE somente na coluna auth_user.last_login.
- SELECT/INSERT/UPDATE/DELETE em django_session (nenhuma sequência ou trigger/maintenance privilege).
- Sem django_migrations, sem auth_user.password UPDATE, sem quaisquer direitos Q0 ou schema core/investigation.

## Restrições e pendências
1. **HOLD incondicional:** mesmo se submetido ao editor SQL, o arquivo de transação abortará antes das concessões enquanto a trava permanecer. A proposta anterior P4-A19 é SUPERADA; somente v2 candidata para revisão, não considerada pronta para execução.
2. Validar em ambiente isolado e autorizado a semântica exata de GRANT role self, SET LOCAL ROLE, REVOKE GRANTED BY e as transações multi-statement do canal SQL Editor/Neon. A validação ainda não aconteceu.
3. Testar em separado falhas e rollback: erro antes e depois de SET ROLE, revogação com RESTRICT e commit incerto. Sem improvisação ou repetição automática.
4. Conferir que `SET LOCAL ROLE NONE` restaura a identidade e que `cloud_admin` OID 155649 não sofre efeitos.
5. Verificar se a autenticação Django moderna exige escrita de password para hash upgrade. Não adicionar até novo gate.
6. Nenhum script é autorização para GRANT/REVOKE/role/ALTER/SET ROLE, conexão Django, contas, HTTP, dados reais, produção ou serviços pagos.
7. Um postflight posterior em nova consulta/sessão é obrigatório; registros de auditoria devem permanecer sem segredos.

## Critérios mínimos de aceite
- Pós-commit: somente OID 155649 na relação owner→migrator, com grantor cloud_admin, ADMIN true/INHERIT false/SET false; nenhum membership para oes_runtime.
- Migrador NOLOGIN/sem CREATE, runtime LOGIN/NOINHERIT sem poderes adicionais; ownership Django e schemas preservado.
- Nove tabelas Django com ACL e privilégios efetivos exatos, oito sequências sem direitos; cinco Q0 sem novos direitos; coluna last_login UPDATE mas password UPDATE false.
- Exigir 11 linhas ACL de tabela diretamente atribuídas a runtime (7 SELECT auth + 4 session), 1 linha ACL de coluna (last_login UPDATE), 1 linha ACL de schema (USAGE oes_app). Concedentes: migrador para tabela/coluna, owner para schema; nenhum GRANT OPTION.
- Independent postflight READ ONLY; diffs de grants/roles não autorizados = HOLD.

**Gates:** Marco B OPEN; G2-P2B NO-GO; E9 NO-GO; readiness NOT_READY; P4 NOT_AUTHORIZED. Próxima ação é revisão do SQL em sandbox/testes de parser e gate separado. Nenhuma atualização GitHub feita nesta atividade.
