# Documento 330 — PF-I02: pacote integrado de migração do ledger e revisão de grants

**Data:** 2026-10-26. **Estado:** `PROPOSED_FOR_REVIEW / NO_DDL_OR_GRANTS_AUTHORIZED`. Fonte canônica CP301, Docs. 323–329. **Este documento não aprova execução SQL.**

## Decisão de arquitetura
Uma única tabela adicional `investigation.question_command_receipt` acompanha transacionalmente `core.entity`, `core.entity_version`, `investigation.question` e `investigation.question_version`. Nenhuma segunda tabela de perguntas ou migração E9. O ledger armazena IDs, fingerprint, autor, tipo, justificativa de Q1 e versão resultante, mas não duplica Q0/Q1.

## DDL candidato consolidado — REVIEW ONLY
```sql
-- Executar apenas após autorização nominal específica, preflight e rollback revisado.
BEGIN;
SET LOCAL lock_timeout='2s';
SET LOCAL statement_timeout='10s';
CREATE TABLE investigation.question_command_receipt (
  actor_id text NOT NULL CHECK (length(actor_id) BETWEEN 1 AND 128),
  request_id text NOT NULL CHECK (length(request_id) BETWEEN 1 AND 128),
  fingerprint_sha256 varchar(64) NOT NULL
    CHECK (fingerprint_sha256 ~ '^[0-9a-f]{64}$'),
  question_entity_uuid uuid NOT NULL,
  question_id text NOT NULL,
  resulting_version_uuid uuid NOT NULL,
  resulting_version_no integer NOT NULL CHECK (resulting_version_no > 0),
  command_kind text NOT NULL CHECK (command_kind IN ('REGISTER_Q0','PROPOSE_Q1')),
  justification text NOT NULL DEFAULT '',
  committed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id,request_id),
  FOREIGN KEY (question_entity_uuid) REFERENCES investigation.question(entity_uuid),
  FOREIGN KEY (resulting_version_uuid,question_entity_uuid)
    REFERENCES core.entity_version(version_uuid,entity_uuid),
  CHECK ((command_kind='REGISTER_Q0' AND resulting_version_no=1 AND justification='')
    OR (command_kind='PROPOSE_Q1' AND resulting_version_no>1 AND length(trim(justification))>0))
);
COMMIT;
```

**Integridade:** FK composta impede vincular versão de outra entidade. `question_id` deve ser verificado na Unit of Work contra `core.entity.oes_id`: no DDL proposto ele não tem FK própria; não declarar essa igualdade garantida somente pelo banco. A versão numérica no recibo é validada pelo serviço e por checagem posterior; a FK composta não certifica `version_no`. Considerar FK composta adicional incluindo versão se a revisão exigir integridade declarativa e índice correspondente — isso é novo gate DDL, não ajuste automático. `justification` fica no ledger, imutável para writer, com retenção definida antes de uso real.

## Porta PostgreSQL a implementar posteriormente
`transaction.atomic()` na conexão writer aprovada, timeout transacional, serialização de `(actor_id,request_id)` e PK do ledger; obter escopo antes de replay e escrita; Q0 cria quatro registros e recibo; Q1 trava entidade, confere revisão, fecha versão anterior, cria posterior e recibo; cada operação só confirma após commit único. Falha incerta: HOLD e consulta reconciliadora por chave, sem retry cego. Rejeitar E9. A porta fake offline não comprova essas garantias.

## Grants candidatos — NÃO EXECUTAR
`oes_qprep_writer` inicialmente `NOLOGIN` sem atributos administrativos. `CONNECT` ao banco e `USAGE` em `core`/`investigation` dependem de preflight efetivo. Nas quatro tabelas existentes: SELECT/INSERT estritamente necessários e UPDATE somente `core.entity_version(version_status,valid_to)`. Na nova tabela: SELECT/INSERT necessários, **sem UPDATE/DELETE/TRUNCATE**, sem acesso a `investigation.investigation*`, E6 ou produtos. Verificar alternativas de SELECT por coluna/API controlada antes de qualquer uso de runtime. `CREATE TABLE` não autoriza automaticamente `GRANT`; etapas e aprovações distintas.

## Bloqueios antes de qualquer mudança conectada
1. Preflight READ ONLY: branch, database, owner, existência da tabela e role, dependências, grants PUBLIC, memberships, trigger, RLS, contagens e políticas de retenção. Fail closed se houver divergências.
2. Separar autorização de DDL do ledger, autorização de CREATE ROLE/GRANT, habilitação de LOGIN/segredos e teste de escrita conectado; nenhum pacote global concede todas.
3. Resolver isolamento de leitura por registro para identidade técnica compartilhada, e autenticação humana persistente; o fato de RLS estar atualmente desabilitado impede proclamar segregação multiusuário.
4. Definir e testar porta SQL real com ledger e idempotência/concorrência, controles negativos e cleanup sintético, sem usar owner como identidade de runtime.
5. Rollback antes de commit é transacional; depois de commit não remover tabela contendo recibos sem retenção e decisão de recuperação. `DROP TABLE CASCADE` proibido.

## Próximo gate sugerido
Autorizar **apenas** a migração sintética DDL do ledger, quando os checks da etapa 1 estiverem satisfeitos, sem DML, role/grant ou conexão Django. Mesmo após essa migração W2 continuará pendente.

**Invariantes:** Marco B aberto, E9 NO-GO, A3 ausente, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
