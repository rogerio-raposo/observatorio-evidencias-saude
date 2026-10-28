# OES — PF-I04/P4-A30 | Decisão sobre canal e autorização do ensaio A29

**Data de referência:** 2026-10-27. **Natureza:** validação documental/contratual do canal, sem execução conectada. **Checkpoint vigente:** CP324; branch `main` verificada idêntica a `bdc9dfb5d587919fb26438093f2759e1dd7a8211`. **Decisão:** `CHANNEL_DESIGN_PASS / LOCAL_EXECUTION_ENV_NOT_VERIFIED / ROLE_TRIAL_HOLD`.

## 1. Evidências fixas e escopo

- Projeto Neon exclusivamente sintético: `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, sessão `oes_sandbox_owner`. Não acessar branch de produção.
- Script A29 transacional ROLLBACK-ONLY: `OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql`, SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17` (171 linhas, verificado no container). Contém **GRANT/REVOKE de membership**, `SET LOCAL ROLE` e asserções de catálogos, sem GRANT em objetos Django/Q0; único terminador `ROLLBACK`.
- Script A29 postflight catalogal: `OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql`, SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509` (191 linhas, verificado no container). Uma consulta `WITH ... SELECT` de catálogos, nova sessão.
- Associação originária `oes_django_migrator` → `oes_sandbox_owner`: OID **155649**, grantor `cloud_admin`, ADMIN true / INHERIT false / SET false; deve permanecer intacta. Runtime continua sem grants.
- Última validação conectada A27: `SUMMARY/HOLD`, 64 mismatches em 946 checks, nenhuma ACL PUBLIC nos objetos examinados. Não repetir automaticamente.

## 2. Comparação de canais

| Canal | Documentação/contrato disponível | Julgamento para A29 |
|---|---|---|
| Neon MCP `run_sql` | Executa **uma** instrução SQL por chamada | **NO-GO** para sequência A29; chamadas independentes não demonstram uma sessão/transação |
| Neon MCP `run_sql_transaction` | Executa **várias instruções em uma transação gerenciada**, cuja conclusão bem-sucedida pode produzir COMMIT implícito; a ferramenta não promete interpretar com segurança `BEGIN`/`ROLLBACK` do arquivo A29 | **NO-GO para A29 inalterado**; requer protocolo/ensaio independente antes de adaptar, sem pressupor rollback |
| Neon SQL Editor | Documentação confirma múltiplas instruções e abas de resultado, mas não prova de modo suficiente as garantias exigidas de sessão e rollback com erro/interrupção | **NO-GO até prova específica do canal** |
| `psql` por conexão PostgreSQL **direta** | Um processo `psql -f` mantém uma conexão para instruções sequenciais, suporta `BEGIN`/`ROLLBACK`, `-X`, `ON_ERROR_STOP` e log; PostgreSQL descarta transações abertas quando a conexão termina | **Canal preferencial, DOCUMENTALMENTE ADEQUADO**, sujeito a validação local de instalação, endpoint, permissões, credenciais e logs; não executado nesta atividade |

**Avisos importantes sobre `psql`:** usar endpoint *direct*, sem sufixo `-pooler`, sem transação gerenciada ou autocommit obrigatório externo; evitar `psql -1`, pois essa opção envolve o script em transação própria que pode terminar em COMMIT. O arquivo A29 já traz `BEGIN` e `ROLLBACK`; não envolvê-lo em wrapper com COMMIT. Configurar `ON_ERROR_STOP=on`, `ON_ERROR_ROLLBACK=off` e `-X` (sem configurações locais ocultas). Ao ocorrer qualquer erro, deixar o processo encerrar a conexão, abortando automaticamente a transação ainda aberta; seguir para inspeção independente, não tentar continuar manualmente a transação.

## 3. Roteiro de execução candidata (NÃO AUTORIZADO NESTA ETAPA)

**Pré-condição:** aprovação nominal exata abaixo, verificação local da presença de `psql`, serviço de conexão configurado fora do repositório, endpoint DIRECT e arquivo SQL com SHA correto. Nunca compartilhar senhas, URL com senha ou `.pgpass` neste chat/GitHub/logs. Não criar usuários ou senhas. Nome de serviço abaixo é apenas um **apelido local a configurar** para o endpoint direto do banco sintético.

Script com um único processo `psql` e uma conexão PostgreSQL, em shell Linux/macOS (ilustrativo):

```sh
# Executar APENAS após aprovação nominal do gate e validação do ambiente.
set -o pipefail
sha256sum OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql
# Exigir identidade exata: 550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17
psql -X -v ON_ERROR_STOP=on -v ON_ERROR_ROLLBACK=off \
  -d 'service=oes_a29_direct' \
  -f OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql \
  > oes_a29_trial_output.log 2>&1
status=$?
# status=0 + ultima resposta ROLLBACK + quatro marcadores completos obrigatorios.
# Não repetir se status nao for zero ou marcadores estiverem incompletos.
```

Verificar log íntegro: `A29_PRE`, `A29_TEMP_GRANT`, `A29_MIGRATOR`, `A29_CLEAN`; mesma identificação `pg_backend_pid()`, contagens exatamente `1 → 2 → 2 → 1`, identidade efetiva correta e resposta final `ROLLBACK`, sem mensagens de erro. **Nunca usar apenas exit code 0 como prova de rollback.** Não adicionar `COMMIT` nem substituir `ROLLBACK` por `COMMIT`.

Postflight **em novo processo / nova sessão**, somente após sua própria autorização nominal:

```sh
sha256sum OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql
# Exigir identidade exata: 8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509
psql -X -v ON_ERROR_STOP=on \
  -d 'service=oes_a29_direct' \
  -f OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql \
  > oes_a29_postflight_output.log 2>&1
```

Confirmar exatamente uma linha SUMMARY com `PASS`, zero mismatches, todas as linhas de detalhe completas, associação original OID 155649 intacta, grantor cloud_admin, nenhum self-grant, `oes_runtime` sem novas permissões. Se erro, resultado parcial ou divergência: `HOLD` e inspeção (sem repetição automática do ensaio).

**Não executado em P4-A30:** esses comandos são apenas orientações para uso humano local futuro. O `psql` não está instalado no container de trabalho atual; a instalação/configuração da máquina do responsável não foi examinada. Não temos acesso à sessão `psql` local nem pretendemos obter credenciais no chat.

## 4. Proposta de autorização nominal do teste (AINDA NÃO CONCEDIDA)

`APPROVED — OES / PF-I04/P4-A31 / SINGLE_A29_ROLE_MEMBERSHIP_ROLLBACK_ONLY_PSQL_DIRECT / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / executor oes_sandbox_owner / A29 SQL SHA256 550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17 only / local psql direct single backend and single transaction / ON_ERROR_STOP on / ON_ERROR_ROLLBACK off / GRANT temporary SET membership to owner by owner only / SET LOCAL ROLE migrator then NONE / REVOKE only self-granted membership RESTRICT / ROLLBACK mandatory / four PID and count markers / no COMMIT / no object grants / no role creation or password operations / no Django Q0 data reads / no HTTP or deploy / no paid services / fail closed`

Essa aprovação **não** autoriza outras ferramentas, outra versão SQL ou uso do Neon SQL Editor/MCP `run_sql_transaction`. Em caso de dúvida sobre conexão direta ou autenticação, manter HOLD e não iniciar.

## 5. Proposta de autorização separada para postflight independente (AINDA NÃO CONCEDIDA)

`APPROVED — OES / PF-I04/P4-A31-POST / SINGLE_A29_INDEPENDENT_POSTFLIGHT_CATALOG_READ_ONLY / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / executor oes_sandbox_owner / A29 postflight SQL SHA256 8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509 / new session after rollback or after uncertain outcome / catalogs and privilege functions only / no Django Q0 data reads / no grants or membership changes / no DDL or DML / no credentials or deploy / fail closed`

## 6. Critério de decisão

- **A30 está concluída somente como análise contratual do canal**, não como prova técnica de execução.
- Canal preferido para futura execução: `psql` local com conexão direta e sessão única, somente após confirmação do ambiente e autorização nominal.
- `run_sql_transaction` e SQL Editor não são equivalentes automaticamente ao procedimento rollback-only. Não testar adaptações sem novo gate e novo artefato.
- Próximo passo operacional requer execução humana local no canal comprovado, ou revisão de um canal automatizado com garantias equivalentes. **O assistente não dispõe de controle da máquina local do usuário nem de suas credenciais e não pode alegar ter executado o teste.**
- `CP324` segue vigente; nenhuma consulta ou mutação Neon e nenhuma atualização GitHub nesta atividade. Gates: Marco B OPEN; G2-P2B NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.

## Referências

- PostgreSQL 18 `psql`: https://www.postgresql.org/docs/18/app-psql.html
- PostgreSQL 18 `ROLLBACK`: https://www.postgresql.org/docs/18/sql-rollback.html
- Neon SQL Editor: https://neon.com/docs/get-started/query-with-neon-sql-editor
- Neon conexão direta/pooled: https://neon.com/blog/pgbouncer-the-one-with-prepared-statements
- Neon MCP server: https://github.com/neondatabase/mcp-server-neon
