# OES — PF-I04/P4-A22 | Parecer independente do pacote SQL v2

**Data:** 2026-10-27. **Tipo:** auditoria documental e validação estática, estritamente não mutante. **Resultado:** `STATIC_REVIEW_PASS_WITH_RESERVATIONS / OPERATIONAL_HOLD`. **Checkpoint de referência:** CP322. **Freshness Gate:** GitHub `main` idêntico ao commit `3186476599a750d5e9eaeb184b6b59f3c8af50a8` no início da atividade.

## 1. Fontes inspecionadas

Arquivos sob `/mnt/data/oes_p4_a21/`:

1. `OES_PF-I04_P4-A21_TRANSACAO_V2_CANDIDATA_HOLD.sql` — 353 linhas, SHA-256 `eca84d2a954490efdd71277e7179435768fe071c59b5488d50ca648ecf61d89f`.
2. `OES_PF-I04_P4-A21_POSTFLIGHT_INDEPENDENTE_CANDIDATO.sql` — 75 linhas, SHA-256 `fd74a88984cd2efdf010f77a746e3fef4c9455bdfce4a0edf618f65610cbfce7`.
3. `OES_PF-I04_P4-A21_REVISAO_V2_CANDIDATA.md` — SHA-256 `1227bf487f5cbdba7579cd3e307fa892dcf4f35b13e45ac402c43dae4b88825d`.

O arquivo `OES_PF-I04_P4-A21_PACOTE_V2_HOLD.zip` passou na verificação de integridade e seus três membros correspondem byte a byte aos arquivos acima.

## 2. Confirmado por inspeção estática

- **Trava efetiva no fluxo previsto:** `RAISE EXCEPTION` incondicional nas linhas 20–25 da transação, **antes** do primeiro GRANT da linha 137; se a transação respeitar a semântica PostgreSQL, não se chega ao bloco mutante mantendo a trava.
- `BEGIN`/`COMMIT` delimitam o arquivo; timeouts e `search_path=pg_catalog` explícitos (linhas 14–18).
- Preflight exige DB e identidade de executor, atributos dos papéis, associação original OID 155649 com `cloud_admin`, opções `ADMIN=true/INHERIT=false/SET=false`, inventário das nove tabelas e oito sequências Django, propriedade das cinco tabelas Q0 e ausência de direitos anteriores (linhas 27–132).
- A sequência proposta inclui concessão de associação temporária por concedente, `SET LOCAL ROLE`, GRANTs sobre sete tabelas de leitura, sessão CRUD, UPDATE da coluna `last_login`, `SET LOCAL ROLE NONE`, USAGE do schema e REVOKE com `RESTRICT` (linhas 135–198).
- Antes do COMMIT, o arquivo avalia direitos individuais de oito operações por tabela, quatro direitos por coluna, três direitos por sequência, e ACLs/concedentes de tabelas, colunas e schema (linhas 202–350). Não usa chamada de múltiplos privilégios com semântica de qualquer-um na matriz principal.
- O arquivo de postflight independente contém consultas `SELECT` catalogais para atributos, memberships, schemas, tabelas, colunas, sequências e ACLs (linhas 5–75). Não contém DDL, DML ou mudanças de role.

## 3. Pendências e riscos

### A22-R01 — bloqueante: postflight independente é descritivo, não decisório
O arquivo de postflight (linhas 5–75) não possui comparação automática integral contra a matriz esperada, nem status consolidado `PASS/HOLD`, nem contagem e detalhamento obrigatório das divergências. Os resultados devem ser manualmente interpretados. Recomenda-se substituir/complementar por um conjunto de consultas READ ONLY que produza uma linha por expectativa com `actual`, `expected`, `pass`, seguida de um resumo que somente indique PASS quando todas as linhas correspondam, inclusive OID/grantor/ACL, esquema, privilégios positivos e negativos, sequências e Q0.

### A22-R02 — bloqueante: nenhuma validação sintática no parser PostgreSQL 18
Nenhum binário PostgreSQL/`psql` ou parser PostgreSQL 18 estava disponível na revisão local. A inspeção visual e a documentação oficial apoiam a plausibilidade de `GRANT ... WITH ADMIN FALSE, INHERIT FALSE, SET TRUE`, `GRANTED BY`, `SET LOCAL ROLE NONE` e `REVOKE ... RESTRICT`, mas **não** garantem que a transação passe no parser ou seja aceita pelo executor Neon. Não remover HOLD.

### A22-R03 — bloqueante: canal e transação não ensaiados
A proposta pressupõe uma sessão/backend único com transação indivisível. Não houve execução contra Neon, nem ensaio autorizado de falha/rollback, nem validação do comportamento de múltiplas instruções no SQL Editor. Não é seguro presumir essa propriedade. Uma futura prova de canal deve ser isolada, sintética e aprovada nominalmente.

### A22-R04 — alto: semântica de associação autoconcedida e cleanup não comprovada no destino
A autorização administrativa original `cloud_admin`/OID 155649 é real e confirmada em P4-A18. O comportamento de uma segunda associação concedida por `oes_sandbox_owner`, seguida de `REVOKE ... GRANTED BY oes_sandbox_owner RESTRICT`, **não foi ensaiado**. É essencial provar preservação do OID original e impossibilidade de SET após a limpeza. Não substituir `RESTRICT` por `CASCADE` sem revisão e gate.

### A22-R05 — moderado: completude da auditoria de ambiente
A auditoria contratual cobre os objetos Django e Q0 delimitados, mas não é auditoria geral de funções, triggers, políticas RLS, privilégios de TEMPORARY ou extensões. Isso não invalida o Bloco A; exige que o objetivo do parecer continue restrito ao universo declarado. Alterações concorrentes por outro administrador entre verificações e commit não estão formalmente prevenidas.

### A22-R06 — moderado: dependência funcional Django separada
O Bloco A permite SELECT de `auth_user`, inclusive leitura de hash para verificação de senha, mas não UPDATE em `password` (rotina de upgrade de hash), o que continua dependente de decisão explícita. Nenhuma prova de login/session backend foi realizada. Ter os GRANTs não habilita Django, HTTP nem Q0.

## 4. Decisão e próximo gate

- **A22 não autoriza executar, editar para remover HOLD ou conectar ao Neon.** O SQL P4-A19 continua superado; o SQL P4-A21 continua candidato bloqueado.
- **Próxima atividade recomendada P4-A23:** preparar e revisar uma *matriz verificadora independente* e reproduzível, ainda READ ONLY e sem execução, que compare os direitos efetivos/ACLs de todas as operações relevantes e devolva `PASS/HOLD` inequívoco; especificar um ensaio sintético separado para a semântica do GRANT de associação e do cleanup, mediante autorização futura.
- Antes de qualquer mutação: Freshness Gate, autorização nominal separada, prova de canal e parser, execução transacional indivisível, rollback explícito e postflight separado.
- Gates permanecem Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`; Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; PF-I04/P4 `NOT_AUTHORIZED`.

## 5. Referências normativas consultadas

- https://www.postgresql.org/docs/18/sql-grant.html
- https://www.postgresql.org/docs/18/sql-revoke.html
- https://www.postgresql.org/docs/18/sql-set-role.html
- https://www.postgresql.org/docs/18/functions-info.html
- https://www.postgresql.org/docs/18/role-attributes.html

**Sem Neon, sem GRANT/REVOKE/SET ROLE, sem GitHub write nesta atividade.**