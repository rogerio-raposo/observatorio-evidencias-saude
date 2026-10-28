# OES — PF-I04/P4-A31 | Decisão de canal transacional

**Data:** 2026-10-27. **Estado:** `CHANNEL_FEASIBILITY_REVIEWED / GITHUB_ACTIONS_PSQL_PREFERRED / OPERATIONAL_HOLD`.
**Checkpoint:** CP325, GitHub main HEAD verificado `7079330f701b0c0c2f515cd58dbe10b1df5d6896` (identical no Freshness Gate). **Nenhum SQL Neon, nenhum GRANT/REVOKE/SET ROLE, nenhuma mudança GitHub nesta atividade.**

## 1. Evidências efetivamente verificadas

1. **Ambiente desta conversa:** `command -v psql` não retornou executável; `psql --version`: `command not found`. `pg_config` instalado retorna PostgreSQL 17.11, mas isso não instala o cliente `psql`. Nenhum driver Python `psycopg`, `psycopg2`, `asyncpg` ou `pg8000` foi encontrado. Não houve conexão, leitura de segredos nem acesso à máquina do responsável.
2. **Repositório GitHub:** `main` contém `.github/workflows/f4-neon-pg18-schema-rehearsal.yml`, que usa PostgreSQL 18 como serviço CI e instala `postgresql-client` caso `psql` falte; `.github/workflows/oes-pf-i04-p3b-django-migrate.yml` e `.github/workflows/oes-qprep-django-auth-readonly.yml` demonstram padrões de `workflow_dispatch`, segredo temporário e guarda de ausência da credencial. A presença dos arquivos **não certifica** que um novo workflow já esteja pronto nem que a conexão atual ao Neon funcione.
3. **Canal Neon MCP:** `run_sql` executa uma instrução por chamada e não fornece continuidade de sessão entre chamadas; `run_sql_transaction` executa uma lista como transação gerenciada e não contém, no contrato consultado, promessa inequívoca de preservar o ROLLBACK explícito de A29. Não adaptar o A29 automaticamente ao MCP.
4. **Documentação oficial:** PostgreSQL 18 `psql` https://www.postgresql.org/docs/18/app-psql.html — `-X`, `-f`, `ON_ERROR_STOP`, `ON_ERROR_ROLLBACK`; evitar `-1` quando o SQL contém transação própria. Neon conexão direta https://neon.com/docs/get-started/connect-neon — usar conexão não pooled para recursos dependentes de sessão.

## 2. Decisão operacional

Preferir **novo workflow GitHub Actions exclusivamente manual** (`workflow_dispatch`), com `psql` e conexão **DIRECT** ao banco sintético, restrito à branch e ao commit revisados, reaproveitando padrões do repositório. Este caminho permite acompanhamento, logs e auditoria sem presumir que `psql` esteja instalado no computador do responsável. A opção `psql` local permanece alternativa caso o usuário comprove o ambiente, mas não é o padrão recomendado nesta etapa.

**Esta decisão não autoriza criação ou habilitação do workflow mutante, credenciais ou execução.** Próxima atividade P4-A32: preparar *somente* contrato/implementação do workflow fail-closed, **sem disparo**, sob escopo GitHub específico.

## 3. Contrato mínimo para eventual workflow A32 (candidato; não executar)

- `workflow_dispatch` somente, sem `push`, `pull_request`, `schedule` ou acionamento automático; `permissions: contents: read`; verificar `github.repository`, `github.ref==refs/heads/main`, HEAD/revisão aprovada e `concurrency` com `cancel-in-progress: false`.
- Ubuntu hosted runner com `psql` instalado/verificado; usar endpoint Neon **DIRECT** exato e branch sintética `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, papel `oes_sandbox_owner`. O host direto deve ser reconfirmado **antes** do gate; o host historicamente referido em outro workflow não é prova de destino atual.
- Credencial **descartável**, configurada pelo responsável via GitHub Actions Secret somente após gate próprio; nunca imprimir, persistir em artefatos/logs, inserir URL com senha no Git, nem reutilizar credenciais antigas. Exigir segredo presente, falhar fechado; remover após o ensaio.
- Arquivo imutável A29 preservado no CP325: `OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql`, SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`; transação `BEGIN` → `ROLLBACK` sem COMMIT, só membership temporária, sem GRANT de objetos. Verificar SHA antes de conexão.
- Executar **exatamente uma vez** com `psql -X -v ON_ERROR_STOP=on -v ON_ERROR_ROLLBACK=off -f ...`; não usar `psql -1`, não ativar pipeline, não adicionar segunda tentativa. Exigir quatro marcadores A29 e o mesmo `pg_backend_pid` (contagens 1→2→2→1), `ROLLBACK` final, status de saída e ausência de erros.
- Postflight SQL SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509` deve ser uma **segunda sessão**, separadamente autorizada; confirmar SUMMARY/PASS, 0 mismatches, total de linhas completo, OID 155649 intacto, grantor cloud_admin, sem auto-associação e runtime inalterado.
- Se erro ou resultado parcial/incerto: HOLD, não repetir ensaio; executar no máximo diagnóstico READ ONLY sob gate apropriado. Sem Django, dados de usuário, Q0, HTTP, deploy ou serviços pagos. Todo log deve omitir credenciais e preferir sumarização redigida a dumps completos.

## 4. Fronteira e ponto de retomada

**P4-A31 concluída como avaliação de viabilidade.** Prova de conexão/execução ao Neon ainda não realizada. A implantação efetiva de um novo workflow e sua execução requerem gates nominais independentes, e não decorrem de `Prossiga`.

Próximo passo **P4-A32: desenhar um único workflow estritamente manual e fail-closed para o ensaio A29, inicialmente incapaz de executar SQL por padrão**, com controles de SHA/branch/credencial/rollback e sem disparo. Persistir o presente parecer no próximo checkpoint proporcional, não alterar CP325 nesta atividade.

Gates globais inalterados: Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, Marco B `OPEN`, G2-P2B operacional `NO-GO`, E9 `NO-GO`, readiness `NOT_READY`, PF-I04/P4 `NOT_AUTHORIZED`.
