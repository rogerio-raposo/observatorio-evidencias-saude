# OES — PF-I04/P4-A29 | Contrato do ensaio transacional ROLLBACK-ONLY

**Data:** 2026-10-27. **Atividade:** exclusivamente elaboração e revisão documental. **Checkpoint:** CP324. **Neon:** não acessado. **GitHub:** sem gravação nesta atividade. **Status:** `OFFLINE_CANDIDATE / OPERATIONAL_HOLD / CHANNEL_NOT_PROVEN`.

## 1. Finalidade limitada

Demonstrar, num futuro gate nominal independente, que a associação original `oes_django_migrator`→`oes_sandbox_owner`, OID **155649**, concedente **`cloud_admin`**, `ADMIN=true`, `INHERIT=false`, `SET=false`, não impede a criação de associação transitória **separada** pelo concedente `oes_sandbox_owner` com `ADMIN=false`, `INHERIT=false`, `SET=true`; comprovar `SET LOCAL ROLE` / restauração / REVOKE exclusivamente da concessão temporária; terminar obrigatoriamente com `ROLLBACK` e atestar externamente a baseline.

Esta prova **não** concede privilégios em objetos, nem atesta conectividade Django, nem autoriza executar o SQL administrativo A21 (que segue com HOLD incondicional). Não cria novos papéis nem senhas.

## 2. Artefatos e imutabilidade

1. `OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql` — várias instruções, **contém GRANT e REVOKE de membership**, `SET LOCAL ROLE`, quatro relatórios de evidência e **termina com ROLLBACK**; **não é READ ONLY**, embora o estado final esperado seja igual ao inicial.
2. `OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql` — uma consulta `WITH ... SELECT` exclusivamente catalogal, projetada para ser executada **após encerramento da transação, em sessão independente**, se houver autorização nominal específica.

Os SHA-256 dos dois arquivos estão registrados no manifesto do pacote e deverão ser incorporados literalmente ao futuro gate. Não alterar bytes/espacos/terminador após aprovação; qualquer mudança exige nova identificação e revisão.

## 3. Pré-condições obrigatórias antes de qualquer teste conectado

- **Projeto:** `weathered-boat-65779510`. **Branch sintética:** `br-gentle-hall-b6jaxehf`. **Banco:** `oes_sandbox`. **Executor:** `oes_sandbox_owner`. Nunca branch default/produção.
- **Freshness Gate:** CP324 (ou sucessor vigente), HEAD de `main` verificado; baseline v3 P4-A27 `SUMMARY/HOLD` **64/946** e `PUBLIC=0` no escopo.
- **Autorização nominal expressa** abrangendo exatamente os SHA-256, mutações *transitórias* de membership, `SET LOCAL ROLE`, `REVOKE ... GRANTED BY ... RESTRICT`, `ROLLBACK` obrigatório e postflight independente. `Prossiga` não basta.
- **Canal comprovado:** uma única sessão/backend PostgreSQL e um único bloco transacional, sem autocommit por statement nem transação automaticamente confirmada pelo executor. **Não presumir** essa capacidade no Neon SQL Editor ou nas ferramentas MCP. A ação `run_sql` do plugin descreve execução de uma instrução, e `run_sql_transaction` descreve uma transação gerenciada (potencialmente confirmada ao terminar), portanto **não são aprovadas automaticamente para este ensaio**. Exigir validação do canal antes de enviar GRANT. Um cliente PostgreSQL com sessão estável e `ON_ERROR_STOP`/desconexão após falha pode ser avaliado documentalmente, sem expor credenciais.
- **Abortar antes de enviar qualquer SQL** se não houver garantia da sessão e da política de rollback. Nenhuma execução automática/repetição, nenhuma configuração de CI.

## 4. Sequência SQL exata projetada

1. `BEGIN`, limites locais de timeout e `search_path=pg_catalog`.
2. `DO` preflight: PostgreSQL 18, identidades, papel migrador `NOLOGIN`, runtime sem associação, associação única OID 155649 com `cloud_admin` e `SET=false`, runtime sem USAGE e sem direitos de referência Django. Em caso de desvio, `RAISE EXCEPTION`.
3. Primeira saída: marcador `A29_PRE` com `pg_backend_pid()`, `session_user`, `current_user`, `membership_count=1`.
4. `GRANT oes_django_migrator TO oes_sandbox_owner WITH ADMIN FALSE, INHERIT FALSE, SET TRUE GRANTED BY oes_sandbox_owner`.
5. Checagem de **duas associações separadas** (original intacta + nova `grantor=oes_sandbox_owner`), `SET=true`, marcador `A29_TEMP_GRANT`, contagem 2.
6. `SET LOCAL ROLE oes_django_migrator`, verificação `current_user=migrator` e `session_user=owner`, marcador `A29_MIGRATOR` (mesmo `backend_pid`).
7. `SET LOCAL ROLE NONE`; verificar recuperação de `current_user=owner`.
8. `REVOKE oes_django_migrator FROM oes_sandbox_owner GRANTED BY oes_sandbox_owner RESTRICT`; confirmar associação original OID 155649, ausência da concessão temporária, `SET=false`, marcador `A29_CLEAN`, contagem 1.
9. Única finalização: `ROLLBACK` explícito; **nenhum COMMIT** e nenhum GRANT em objeto Django/Q0.
10. **Somente após a conclusão:** segunda execução independente e READ ONLY do arquivo de postflight, com autorização própria, exigindo `SUMMARY/PASS` e contagens completas. Caso o rollback fique incerto, apenas diagnóstico independente previamente aprovado, nunca novo GRANT.

## 5. Aceite e falha controlada

- Os **quatro marcadores** precisam estar completos e compartilhar o mesmo `backend_pid`; contagens de associações **1→2→2→1**, e identidades `owner→owner→migrator→owner` respectivamente.
- Confirmar que todas as asserções `DO` completaram, `ROLLBACK` foi confirmado pelo cliente, sem `COMMIT` nem aviso de operação autocommit.
- Em uma *nova sessão*, a consulta de postflight deve devolver uma linha `SUMMARY` com status **PASS**, `0 mismatches`, total de checks equivalente ao número de linhas de detalhe recebidas, seguida de checks individuais todos conformes. Preservar erros e resultados sem dados sensíveis.
- Divergência, resultado parcial/truncado, bloqueio de `RESTRICT`, associação original alterada, mudança persistente ou evento de commit incerto => **HOLD**, inspeção independente e sem repetição automática.
- Um `SUMMARY/PASS` isolado no postflight **não comprova que o ensaio tenha sido executado**, pois a baseline já é válida antes do teste. Prova conjunta: marcadores transacionais + confirmação `ROLLBACK` + postflight independente.
- O postflight demonstra os invariantes nomeados, não prova que nenhum outro privilégio global foi alterado por terceiros concorrentes; não é substituto da auditoria v3 ou de ensaios da aplicação.

## 6. Limites metodológicos

- O SQL foi submetido a revisão lexical de instruções/ordem e leitura da documentação oficial PostgreSQL 18; **não foi parseado nem executado por PostgreSQL**, seja local seja no Neon. A interpretação de `GRANT` e `REVOKE` com múltiplos grantors continua hipótese testável, não fato empiricamente comprovado neste ambiente.
- Sem seleção de registros Django/Q0, sem ALTER ROLE, sem CREATE ROLE, sem INSERT, sem usuário real, sem web, sem deploy ou serviços pagos.
- **Nenhum gate operacional é alterado:** Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.

## 7. Próxima decisão

**P4-A30:** avaliar **somente o canal transacional** e preparar proposta de autorização nominal com hashes imutáveis; se não for possível garantir sessão/rollback, HOLD e escolha de canal diferente. Nenhuma execução no Neon até nova autorização expressa.

## Referências oficiais

- PostgreSQL 18 GRANT: https://www.postgresql.org/docs/18/sql-grant.html
- PostgreSQL 18 REVOKE: https://www.postgresql.org/docs/18/sql-revoke.html
- PostgreSQL 18 SET ROLE: https://www.postgresql.org/docs/18/sql-set-role.html
- PostgreSQL 18 pg_auth_members: https://www.postgresql.org/docs/18/catalog-pg-auth-members.html
- PostgreSQL 18 ROLLBACK: https://www.postgresql.org/docs/18/sql-rollback.html
