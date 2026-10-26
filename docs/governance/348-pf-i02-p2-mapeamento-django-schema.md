# Documento 348 — PF-I02 / P2 — Mapeamento mínimo Django ORM ↔ PostgreSQL canônico
**Data:** 2026-10-26. **Natureza:** análise estática de repositório. **Base:** CP310, Doc.347, `database/poc-s1.sql`, Doc.330 e evidências de catálogo G1/Doc.344. Sem Neon, conexão Django, criação de model, migration, DDL ou DML.

## Levantamento
- `applications/oes_web/evidence/` não possui `models.py` ou diretório de migrações específico no HEAD analisado. `config/settings.py` estabelece `DATABASES={}` por padrão; a única conexão opcional `oes_synthetic_reader` é READ ONLY e não pode ser reaproveitada como writer.
- `database/poc-s1.sql` é **schema experimental histórico**, não fotografia completa da branch atual: `investigation.question.responsible_actor_id`, `investigation.question_version.preparation_stage`, nulabilidade de `normalized_text` e `investigation.question_command_receipt` vieram de migrações sintéticas posteriores. Modelo ORM deve seguir o contrato real verificado em G1 e migrações canônicas, sem reconstruir o esquema histórico.

## Proposta de cinco modelos UNMANAGED (desenho, não código executável)
| Modelo candidato | Tabela física | Chave primária | Relações e restrições críticas |
|---|---|---|---|
| `OesEntity` | `core.entity` | `entity_uuid UUID` | `oes_id` global UNIQUE; `entity_type` e `created_by`; tipo `Question` validado por trigger em subtype |
| `OesEntityVersion` | `core.entity_version` | `version_uuid UUID` | `entity_uuid` FK para entity; UNIQUE `(entity_uuid,version_no)`; índice parcial versão corrente; `supersedes_version_uuid` FK **composta** com entity_uuid; status e intervalo temporal |
| `OesQuestion` | `investigation.question` | `entity_uuid UUID` | PK/FK para entity; `responsible_actor_id TEXT NULL` e CHECK de trim 1–128; trigger de tipo |
| `OesQuestionVersion` | `investigation.question_version` | `version_uuid UUID` | `entity_uuid` FK para question; FK **composta** `(version_uuid,entity_uuid)` para core.entity_version; Q0 e Q1 via `preparation_stage`/normalized_text |
| `OesQuestionCommandReceipt` | `investigation.question_command_receipt` | **PK composta** `(actor_id,request_id)` | FK para question; FK **composta** `(resulting_version_uuid,question_entity_uuid)` para version; fingerprint, command_kind, justification, resulting_version_no, committed_at |

## Convenções propostas
1. `Meta.managed = False` e `db_table` com identificação de schema PostgreSQL corretamente escapada/testada; não utilizar `db_table='core.entity'` sem verificar a geração do SQL (pode ser interpretado como um único identificador). Não assumir que `inspectdb` reproduz triggers/constraints complexas.
2. Django recente pode representar PK composta com `CompositePrimaryKey`, mas **verificar versão real instalada e limitações** antes de escolher. Não inventar surrogate key ou modificar ledger por conveniência do ORM.
3. Chaves estrangeiras compostas e trigger de tipo devem **permanecer garantidas no PostgreSQL**; não declarar que simples `ForeignKey` do Django traduz automaticamente as dependências compostas. Representações de `ForeignObject`/campos de ID requerem auditoria.
4. `transaction.atomic(using=writer_alias)`, `on_commit`, tratamento de `IntegrityError` e consultas com `select_for_update` são **candidatos**, não validação conectada; nenhum writer alias operacional foi autorizado.
5. Evitar `makemigrations`, `migrate`, `inspectdb` conectado, criação de usuários, registro/admin de objetos ou segunda fonte de verdade. Os modelos futuros devem ser de acesso restrito, sem endpoints operacionais.
6. Manter `QuestionCommand`, fingerprint e casos de aceite das 142 provas offline como referência funcional, mas não exigir reutilizar a porta SQL experimental.
7. Isolamento por preparador não é resolvido por ORM ou `managed=False`; RLS ausente, credenciais de escritor inexistentes, responsabilidade sintética e nenhuma pessoa pesquisadora vinculada.

## Critério para próximo incremento
Criar, **somente offline e em autorização que não habilite banco**, um protótipo de definição dos cinco modelos unmanaged **se** a versão Django suportar adequadamente PK composta e o mapeamento de schema. Antes, verificar requisitos de versão/versão CI e escolher entre modelo ORM puro e pequena camada SQL específica para ledger de PK composta. A definição desses modelos, por si, não constitui G2 nem prontidão para Django conectado.

**Resultado:** `DJANGO_SCHEMA_MAPPING_DESIGNED / NO_MODELS_CREATED / G2_NO_GO`. CP310 vigente; Marco B aberto; Fase 5 NOT_STARTED; readiness NOT_READY; E9 NO-GO.
