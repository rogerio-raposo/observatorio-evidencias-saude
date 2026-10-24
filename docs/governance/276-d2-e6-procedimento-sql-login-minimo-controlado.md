# Documento 276 — Procedimento SQL controlado para identidade E6 do piloto

**OES — 2026-10-24 | CP274 | Base Documento 275 | HEAD `2de1a91bd3626b03a725d0d1b83e702445fd9318` | SOMENTE INSTRUÇÃO; NENHUMA EXECUÇÃO**

## 1. Fronteira autorizada
O proprietário aprovou somente a criação e teste **sintético** de `oes_e6_capture_login` na branch experimental Neon `br-gentle-hall-b6jaxehf`, database `oes_sandbox`, sob condição `controlled-credential / verify-and-disable`. Não há autorização de GET factual, GitHub Secret, disparo/desbloqueio de workflow nem uso permanente da credencial.

**Procedimento proposto para execução manual no Neon SQL Editor, e somente após confirmação do usuário sobre o canal de senha segura:**

1. Selecionar e conferir branch `br-gentle-hall-b6jaxehf` e banco `oes_sandbox`. Gerar senha aleatória de alta entropia por gerenciador externo à conversa; não copiar senha para chat, arquivo no repositório, print ou log. A senha em comando SQL pode ficar no histórico do SQL Editor — avaliar esse risco antes de executar.
2. Confirmar por `SELECT` que `oes_e6_capture_login` não existe, que `oes_e6_writer` existe e que a ACL mantém somente `USAGE/INSERT` para writer.
3. Usar SQL de criação em transação com placeholder **não executável como está**:

```sql
-- SUBSTITUIR O MARCADOR SOMENTE NO EDITOR PRIVADO, COM SENHA GERADA FORA DO CHAT.
-- ATENÇÃO: NÃO executar este modelo com o marcador literal.
BEGIN;
CREATE ROLE oes_e6_capture_login WITH LOGIN NOINHERIT
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
  PASSWORD 'SUBSTITUIR_LOCALMENTE_POR_SEGREDO_FORTE';
GRANT oes_e6_writer TO oes_e6_capture_login
  WITH ADMIN FALSE, INHERIT FALSE, SET TRUE;
COMMIT;
```

4. Em conexão administrativa, conferir atributos e permissões sem revelar hash de senha:

```sql
SELECT rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole,
       rolreplication, rolinherit
FROM pg_roles
WHERE rolname='oes_e6_capture_login';

SELECT m.admin_option, m.inherit_option, m.set_option
FROM pg_auth_members m
JOIN pg_roles parent ON parent.oid=m.roleid
JOIN pg_roles member ON member.oid=m.member
WHERE parent.rolname='oes_e6_writer'
  AND member.rolname='oes_e6_capture_login';
```

5. Teste autenticado somente depois de decidir canal seguro de uso da senha. Em sessão com login do papel, verificar que `SELECT` e `INSERT` sem `SET ROLE` não funcionam no schema privado. Usar `SET LOCAL ROLE oes_e6_writer` em transação sintética apenas, demonstrando `INSERT` permitido e `SELECT/UPDATE/DELETE` negados. Evitar SQL de teste que exponha bytes; limpar todos os registros sintéticos criados sob operador autorizado e confirmar 0 linhas.
6. **Desativação obrigatória após teste:** `ALTER ROLE oes_e6_capture_login NOLOGIN;` seguida de revogação da associação transitória `REVOKE oes_e6_writer FROM oes_e6_capture_login;` após verificação da procedência do grant e confirmação de nenhum vínculo anterior. Verificar atributos/grants finais. Não presumir que desativar o papel exclua uma senha armazenada; plano posterior de rotação/revogação deve ser documentado. Não excluir roles existentes ou tocar na fixture PG-A4.

## 2. Riscos e critério STOP
A inclusão da senha literal em um comando no SQL Editor pode deixar histórico consultável. Esta proposta NÃO afirma que a interface escolhida fornece sigilo perfeito. Caso não se consiga aceitar esse risco e comprovar que o segredo não será armazenado em logs/histórico compartilhado, interromper e escolher mecanismo alternativo; nunca transmitir credencial pelo chat ou por ferramenta que a exponha.

O SQL acima é material de preparação, **não autorização para execução imediata nem instrução para contornar regras do banco**. Se houver drift de branch, papel preexistente, membership divergente ou privilégio inesperado, STOP. Não utilizar o proprietário Neon como login operacional. Para E6-G1, o job GitHub permanece `if: ${{ false }}`.

**Estado:** `SQL_ROLE_CREATION_PROCEDURE_PREPARED / CREDENTIAL_CHANNEL_NOT_CONFIRMED / NO_ROLE_CREATED / E6_G1_BLOCKED`.
