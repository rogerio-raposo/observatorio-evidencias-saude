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

## 3. Verificação documental do histórico de consultas — 2026-10-24

Fonte oficial: https://neon.com/docs/get-started/query-with-neon-sql-editor (seção «View the query history»). O SQL Editor do Neon mantém **histórico de consultas do projeto** e permite reabrir o texto executado; consultas salvas no histórico são limitadas a 9 KB de texto. **Não há base para afirmar que escrever a senha em `CREATE ROLE ... PASSWORD '...'` ou `ALTER USER ... PASSWORD '...'` neste editor seja sigiloso.** É inadequado presumir que o histórico não retém a senha ou usar truncamento de histórico como mecanismo de proteção.

A documentação https://neon.com/docs/manage/roles confirma que papéis criados por SQL não recebem `neon_superuser` automaticamente, enquanto a criação via Console/CLI/API concede participação nessa função. Assim, não substituir silenciosamente a rota SQL por criação via API para obtenção de senha.

**Revisão do procedimento:** a seção 1 com marcador de senha é exclusivamente histórica/de preparação e **não deve ser executada pelo usuário no SQL Editor do Neon** enquanto não houver método validado para não expor credenciais em histórico/logs. A opção mais compatível é um cliente SQL confiável com entrada interativa de senha ou mecanismo externo que mantenha o segredo fora do texto de SQL persistido; a disponibilidade prática desse cliente para o usuário **ainda não foi confirmada**. O conector atual também não fornece canal comprovadamente secreto de provisionamento e transferência da senha. Não pedir ao usuário que envie senha ao chat.

**Resultado:** `NEON_SQL_EDITOR_PASSWORD_HISTORY_RISK_CONFIRMED / MIN_PRIVILEGE_SQL_ROLE_SUPPORTED / SAFE_SECRET_HANDOFF_NOT_VERIFIED / NO_ROLE_CREATED / E6_G1_BLOCKED`. Sem alterações no Neon ou no workflow.


## 4. Alternativa verificada: \password do psql — 2026-10-24

**Fonte primária:** documentação oficial PostgreSQL 18, https://www.postgresql.org/docs/18/app-psql.html , seção de meta-comandos, entrada \`\\password [ username ]\`; referência complementar Neon https://neon.com/docs/manage/roles . O meta-comando pede a senha interativamente, cifra antes de enviar ao servidor e evita a senha em texto puro no comando SQL/histórico; isso não dispensa proteger o terminal, a própria senha, a conexão e o computador utilizado.

**Substituição recomendada do procedimento da seção 1, que não deve ser executado com senha literal no SQL Editor:**

1. Pela interface administrativa SQL autenticada, com branch e banco exatos conferidos e depois de preflight, criar apenas \`CREATE ROLE oes_e6_capture_login NOLOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;\`. Conferir ausência de privilégios extras antes de prosseguir; não deixar LOGIN ativo sem senha.
2. Usar **cliente oficial psql em ambiente confiável**, já conectado administrativamente ao mesmo branch/banco, e executar interativamente \`\\password oes_e6_capture_login\`. Nenhuma senha deve ser enviada pelo chat nem escrita em arquivo, CLI, SQL ou repositório. O cliente deverá ser instalado/operado pelo proprietário, se disponível; esse pré-requisito ainda não foi demonstrado.
3. Somente após senha definida e verificação de grants, conceder \`oes_e6_writer\` com \`ADMIN FALSE, INHERIT FALSE, SET TRUE\` e alterar login para \`LOGIN\` durante o teste autenticado autorizado.
4. Executar os testes sintéticos negativos e positivos estritamente aprovados e **desativar \`NOLOGIN\` e revogar a associação temporária** ao término. Confirmar papel sem login, membership restaurada, tabela privada sem registros e fixture PG-A4 intacta.
5. Não chamar \`\\password\` na ferramenta SQL genérica do conector ou no Neon SQL Editor: trata-se de meta-comando **exclusivo do cliente psql**, não de SQL executável pelo servidor. A operação de criação da identidade e de senha não foi realizada nesta análise.

**Gate prático ainda pendente:** disponibilidade de psql e canal administrativo confiável no ambiente do proprietário, sem expor connection string com senha em terminal/logs. Se não estiver disponível, não criar infra ou serviço pago por inferência: retomar decisão arquitetural proporcional.

**Estado:** \`INTERACTIVE_PSQL_PASSWORD_METHOD_VERIFIED / EXECUTION_ENVIRONMENT_UNCONFIRMED / NO_ROLE_CREATED / E6_G1_BLOCKED\`.
