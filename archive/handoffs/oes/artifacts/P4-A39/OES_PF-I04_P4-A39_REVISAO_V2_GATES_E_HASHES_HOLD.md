# OES — PF-I04/P4-A39 | Postflight v2 e fortalecimento de setup/cleanup

**Data:** 2026-10-28. **CP vigente:** CP327. **Resultado:** `OFFLINE_STATIC_CORRECTION_PASS / PG18_UNTESTED / OPERATIONAL_HOLD`. **Freshness Gate:** `main` idêntica ao commit `439de012bc3c1a684556cb6cdd7096478f497864` antes deste registro. Nenhuma operação conectada Neon, nenhum SQL executado, nenhum segredo cadastrado, nenhuma remoção de `if:false`.

## 1. Fontes novas preservadas integralmente
Diretório `archive/handoffs/oes/artifacts/P4-A39/`. Hashes SHA-256 calculados sobre os bytes UTF-8 efetivos e Git blobs lidos após publicação:
1. `OES_P4_A39_POSTFLIGHT_V2_CATALOG_READ_ONLY_HOLD.sql` — SHA-256 **`fac7b3146f56e9f69375cc2f6330d335cc29c961d87ca5c3d02243e0d75fca5d`**, Git blob **`9399eb5791ce08ef13777bd4690d32936b2b88d6`**; 100 linhas, 1 consulta `WITH ... SELECT`, 26 checks + 1 SUMMARY; nenhum DDL/DML/GRANT.
2. `OES_P4_A39_SETUP_V2_SYNTHETIC_TARGET_HOLD.sql` — SHA-256 **`236ab6ae232bc6080453345957f6a5e7711911ed50471078a5e53e94ff8f6daa`**, Git blob **`0880ae2b0d2acea5ed9a8df0db742a75a4becaa5`**; 82 linhas, 10 comandos superiores, BEGIN→COMMIT, CREATE ROLE e GRANT persistentes.
3. `OES_P4_A39_CREDENTIAL_LOCKDOWN_HOLD.sql` — SHA-256 **`ff9782bfbc2bdec1503187d69f0b12b1c10a53d7cc08176a79ab15ef7a11baa7`**, Git blob **`7ba836de09fc12faf0f7eb09aa7ffd2bcc375014`**; 37 linhas, 8 comandos superiores, `ALTER ROLE oes_p4_trial_login WITH NOLOGIN PASSWORD NULL` em transação própria com COMMIT.
4. `OES_P4_A39_CLEANUP_V2_SYNTHETIC_TARGET_HOLD.sql` — SHA-256 **`83d76fabcf489ba4ac49151f19c799dadade3a956f9f5113da1a3b8ec843954c`**, Git blob **`fba1fc09a903b1524641d26ce8a00c7b081f2b2a`**; 75 linhas, 9 comandos superiores, exige trial `NOLOGIN` já confirmado, revoga apenas membership owner→trial do alvo e DROP ROLE do alvo sintético, BEGIN→COMMIT; não ALTER ROLE, não CASCADE.

Os originais A37 preservados em P4-A38 e os workflows A32/A35 **NÃO FORAM ALTERADOS**. Nenhum dos quatro candidatos A39 foi executado, portanto nenhuma alegação de validação no parser/engine PostgreSQL 18.

## 2. Correções e fundamento
- **A38-R01:** postflight v2 inventaria TODAS as associações `pg_auth_members` cujo `roleid=target` ou `member=target`, exige respectivamente contagens 1/0 e que o trial tenha exatamente uma associação (o alvo pelo owner), sem self-grant, e flags exatas do grant owner.
- **Dependências/ownership/ACL:** verifica `pg_shdepend` para referências ao alvo em toda a branch, excetuando **somente** entradas da classe `pg_auth_members`, que documentam membership esperada e são verificadas por `pg_auth_members` explicitamente. PostgreSQL 18 registra dependências compartilhadas também de memberships; exigir zero indiscriminado no `pg_shdepend` daria falso HOLD. Ver também `pg_db_role_setting` para configuração vinculada ao alvo. A ausência de dependências explícitas não prova ausência de privilégios inerentes a PUBLIC. Essa é triagem proporcional, não auditoria universal de privilégios.
- **A38-R02:** postflight v2 exige banco, `session_user` e `current_user` `oes_sandbox_owner`, PostgreSQL versão 18, estados de trial/target e proteção do OID 155649. **SQL não prova endpoint/branch Neon**; verificar por metadados e host DIRECT fora da consulta.
- **A38-R03 e falha atômica do cleanup:** caso ALTER ROLE/password NULL e DROP ROLE estivessem juntos, falha no DROP faria rollback da revogação da credencial. Agora LOCKDOWN tem COMMIT próprio e ocorre **antes** do cleanup. A limpeza subsequente só opera se a role já estiver `NOLOGIN`; falha nela **não reativa** a senha. `NOLOGIN` não fecha sessões existentes: o cleanup exige zero conexões como trial. `pg_roles` não apresenta a senha, portanto PASSWORD NULL é sustentado pelo resultado inequívoco do ALTER ROLE+COMMIT, não por consulta a `pg_authid` ou coleta do hash.
- **A38-R04:** setup reforçado exige alvo inexistente e trial sem memberships nos dois sentidos antes de criar; target flags restritas, sem dependências explícitas, settings e associações inesperadas; GRANT sintético somente sobre `oes_p4_trial_target`. ADMIN permite delegar a própria role sintética, logo janela aberta entre setup e lockdown ainda representa risco e exige procedimento de execução breve, sem serviços pagos e com senha descartável.
- **A38-R05:** A35 segue configurado para owner/A29 e bloqueado; **não executar A37/A39 por ele**. Necessário workflow novo, gate por SHA, identidade trial, endpoint e logs. A37 trial original SHA-256 `0ade6935a8d4a368c660f2c94de6a34b4a7d27f768aa87b8d5c8edf964c71b35` permanece candidato imutável e não executado.

## 3. Verificação estrutural OFFLINE
- Postflight: 26 labels únicos (e SUMMARY exige exatamente 26 / 0 failures); estimativa 27 linhas completas. Check de 0 sessões do trial, papéis owner/migrator sem SET/USAGE, runtime sem membership e target sem dependência de objeto não membership.
- SETUP: 10 instruções superiores; três DO delimitados; início BEGIN e último comando COMMIT.
- LOCKDOWN: 8 instruções superiores; dois DO; ALTER ROLE NOLOGIN/PASSWORD NULL + COMMIT próprios, não DROP ROLE.
- CLEANUP: 9 instruções superiores; dois DO; exige `NOLOGIN` prévio, zero conexões e ausência de dependência fora da membership esperada; não altera senha, não utiliza CASCADE.
- Nenhuma leitura de `pg_authid` nem de dados Django/Q0; sem autenticação/conexão ao Neon. Scanner lexical não equivale a parser PostgreSQL; PG18/Neon pode impor permissões ou semântica adicionais. Em erro = HOLD, nunca alterar script autorizado silenciosamente ou repetir automaticamente.

## 4. Gates e ordenação proposta, TODOS HOLD
1. **SETUP V2**: aprovação nominal específica para criar alvo sintético NOLOGIN e conceder apenas ADMIN TRUE INHERIT FALSE SET FALSE de target a trial, persistente (COMMIT); pré-verificação de branch real, role executor e segurança do segredo.
2. **TRIAL A37**: aprovação nominal separada para único script ROLLBACK-only em sessão trial, com quatro marcadores A37, um PID, contagem 1→2→2→1, `ROLLBACK` terminal; nunca COMMIT. SQL ainda não testado no mecanismo PG18.
3. **POSTFLIGHT V2**: aprovação nominal própria para um SELECT catalogal (26 checks + SUMMARY) em **nova sessão owner**, inclusive se trial falhou ou resultado ficou incerto. `SUMMARY/PASS` isolado não prova trial. Se falha, HOLD e plano de contenção, não retentar trial.
4. **LOCKDOWN**: aprovação nominal autônoma para desabilitar login e apagar senha no PostgreSQL (não só GitHub Secret), mesmo em contingência se necessário. No plano normal, imediatamente após postflight; em incidente pode ser antecipado sob gate de segurança específico.
5. **CLEANUP V2**: aprovação nominal autônoma para revogar apenas a membership sintética e remover somente o alvo com `DROP ROLE` (RESTRICT implícito), quando login já estiver NOLOGIN, sem sessões ativas e inventário sem terceiros/dependências; `ROLLBACK` automático em erro.
6. **PÓS-CLEANUP**: preparar/verificar sob gate independente um SELECT que prove target ausente, trial NOLOGIN, zero memberships trial, zero sessões trial e OID 155649 intacto. O atributo password não é exposto pela view pública; evidência de COMMIT do LOCKDOWN + NOLOGIN e senha expirada/revogada. Remover segredo GitHub. **Este SELECT ainda não foi criado ou autorizado.**

## 5. Incertezas que impedem a execução
- Falta teste PG18 sintético descartável para validar syntax, `GRANTED BY`, dependências da membership e a execução do setup/trial/rollback/cleanup. Este é o próximo passo de maior benefício, **sem conectar ao Neon**.
- O alvo ainda não foi criado. A role trial conhecida permanece sem membership pela última consulta fornecida pelo responsável; seu estado atual não foi revalidado ao vivo nesta atividade. A senha do trial tem validade original até 2026-10-31 03:30:53 UTC; não criar ou armazenar segredo antes de gate.
- Exigir controle explícito de janela temporal e de scripts para não deixar ADMIN sintético exposto sem plano de lockdown, e impedir rerun/segundo dispatch.
- O ensaio sintético A37 **não equivale** ao experimento administrativo A29/associação OID 155649. Fase 5 NOT_STARTED; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED.

## 6. Próxima atividade
**P4-A40 — validação offline em instância PostgreSQL 18 descartável**, sem Neon/segredos ou administração de papéis reais, para detectar problemas de parser, semântica de pg_shdepend/membership e eventuais condições de impossibilidade do ensaio. É necessário adaptar expectativas de OID 155649 apenas na fixture exclusivamente sintética (não alterar os arquivos canônicos como substituição silenciosa) e produzir evidência do SQL efetivamente testado. Qualquer deploy/Neon/PG real continua exigindo novos gates independentes.
