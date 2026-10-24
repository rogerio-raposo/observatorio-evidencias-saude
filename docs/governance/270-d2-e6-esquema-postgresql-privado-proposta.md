# Documento 270 — Esquema mínimo proposto para JSON bruto privado no PostgreSQL (D2-E6)

**2026-10-24 | Somente desenho documental | Base: Documento 269 | HEAD de referência: `66d2e6c66080d3f777b6f83a7216f54264bba36c`**

**Estado:** `PG_RAW_DESIGN_PROPOSED / NO_SQL_EXECUTED / IMPLEMENTATION_NOT_APPROVED / E6_G1_BLOCKED`.

## 1. Escopo e limites
Uma observação factual controlada, JSON original de até 2.000.000 bytes, gravado exclusivamente em armazenamento PostgreSQL privado do **piloto**. Preservar exatamente os bytes observados e a ligação a fonte, parâmetros, SHA-256 e execução. A solução deverá permitir futura migração para object storage privado, sem compromisso arquitetural de uso permanente do PostgreSQL. Sem leitura pública, sem artifact de JSON, sem nova infraestrutura e sem modificar a fixture sintética PG-A4.

Abaixo está um **rascunho não executável automaticamente**. Identidades, propriedade, schema e permissões exigem preflight de catálogo e aprovação própria. Nenhum SQL foi enviado ao Neon.

## 2. DDL de referência — não executar sem gate

```sql
-- DOCUMENTARY PROPOSAL ONLY: do not run against any environment without approval.
CREATE SCHEMA oes_raw_private;

-- Ownership and roles must be decided separately. Never rely on the default
-- privileges of the role that executes the migration.
REVOKE ALL ON SCHEMA oes_raw_private FROM PUBLIC;

CREATE TABLE oes_raw_private.source_observation (
    observation_id text PRIMARY KEY,
    activity_id text NOT NULL,
    repository_commit_sha text NOT NULL,
    github_run_id bigint NOT NULL CHECK (github_run_id > 0),
    run_attempt integer NOT NULL CHECK (run_attempt > 0),
    source_name text NOT NULL CHECK (source_name = 'ClinicalTrials.gov API v2'),
    requested_url_exact text NOT NULL,
    started_at_utc timestamptz NOT NULL,
    completed_at_utc timestamptz NOT NULL,
    source_http_status integer NOT NULL CHECK (source_http_status = 200),
    response_content_type text NOT NULL,
    payload_sha256 char(64) NOT NULL
        CHECK (payload_sha256 ~ '^[0-9a-f]{64}$'),
    payload_bytes integer NOT NULL
        CHECK (payload_bytes BETWEEN 1 AND 2000000),
    raw_payload bytea NOT NULL,
    scientific_review_status text NOT NULL
        DEFAULT 'NOT_SCIENTIFICALLY_REVIEWED'
        CHECK (scientific_review_status = 'NOT_SCIENTIFICALLY_REVIEWED'),
    created_at_utc timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_observation_time
        CHECK (completed_at_utc >= started_at_utc),
    CONSTRAINT raw_byte_length_matches
        CHECK (octet_length(raw_payload) = payload_bytes),
    CONSTRAINT unique_run_observation
        UNIQUE (github_run_id, run_attempt, observation_id)
);

REVOKE ALL ON ALL TABLES IN SCHEMA oes_raw_private FROM PUBLIC;

-- Example of required extra guard: DB-side SHA-256 verification is not
-- included here (would require a reviewed extension/function design).
-- The approved writer must verify SHA-256 before insert and after private read.
-- No GRANT statements until identities/owners are confirmed.
```

**Nota de integridade:** `char(64)` aceita somente digest hexadecimal minúsculo pelo CHECK, mas o banco, neste rascunho, **não prova** que o valor corresponde ao `raw_payload`. A aplicação verifica SHA-256 dos bytes originais antes de gravar e na recuperação; avaliar verificação adicional em banco sem incluir extensão por antecipação. Evitar gravar JSON em texto ou `jsonb` como substituto dos bytes originais. O desenho também não implementa imutabilidade irrestrita: writer sem `UPDATE/DELETE` é requisito de privilégios, e administrador permanece privilegiado.

## 3. Matriz de privilégios alvo

| Identidade | Schema USAGE | INSERT | SELECT do payload | UPDATE/DELETE | DDL |
|---|---|---|---|---|---|
| Papel proprietário/migrador, segregado | conforme administração | administrativo | administrativo | administrativo | SIM |
| Papel técnico de gravação E6 (novo, mínimo) | SIM | SIM | **NÃO** por padrão | NÃO | NÃO |
| Papel de verificação privada (novo, se necessário) | SIM | NÃO | SIM apenas no âmbito controlado | NÃO | NÃO |
| `oes_pg_a4_reader` (existente) | NÃO | NÃO | NÃO | NÃO | NÃO |
| `PUBLIC` e usuários anônimos | NÃO | NÃO | NÃO | NÃO | NÃO |
| CI de testes offline | NÃO | NÃO | NÃO | NÃO | NÃO |

Antes da implementação, validar regras de ownership, associação de roles, credenciais, `search_path`, privilégios efetivos e **default privileges**. O schema é uma barreira lógica, não substitui isolamento de papéis; não conceder `USAGE` ao leitor PG-A4. A aplicação não deve usar papel proprietário ou superusuário para escrita. Se a verificação após gravação exigir `SELECT`, usar papel separado ou mecanismo pontual autorizado; não conferir leitura ampla ao writer por conveniência.

## 4. Sequência de pré-implantação e ensaio sintético

1. Consultar catálogo do **branch experimental explicitamente escolhido** com acesso read-only para confirmar inexistência de conflitos de schema/nome, grants e propriedade, mantendo a fixture sintética.
2. Revisar nomes, transações, política de imutabilidade lógica, erros, rollback e fronteira de credenciais; confirmar capacidade de uso sem serviço pago.
3. Aprovar separadamente migração DDL e criação de papéis com GRANTs mínimos; somente então executar em branch autorizado.
4. Com **bytes sintéticos**, comprovar limite 2 MB, igualdade de byte a byte/SHA-256, recusa de duplicata e rollback em erro, rejeição de leitura pelo papel PG-A4, e ausência de conteúdo bruto em logs e artifacts.
5. Adaptar e testar o workflow mantendo `if: ${{ false }}` e sem `actions/upload-artifact` para pacote bruto factual. Não tomar 39 testes offline do caminho anterior como evidência do caminho novo.
6. **Somente em gate executivo posterior E6-G1**, deliberar um GET factual, com URL/commit congelados e preflight de segurança.

## 5. Retenção e migração

JSON mantido até validação e encerramento documental do piloto, com decisão de retenção ou descarte registrada. Sem prazo universal e sem acesso público. Um identificador estável `observation_id` e o `payload_sha256` independem de `bytea`; uma futura migração para serviço de objetos privado deverá demonstrar migração reversível, paridade dos bytes, acesso controlado e atualização auditável da referência física. **Não implementar camada de object storage antecipadamente.**

## 6. Preflight de catálogo somente leitura — 2026-10-24

Alvo confirmado explicitamente: projeto `weathered-boat-65779510` (`oes-sandbox`), branch experimental `br-gentle-hall-b6jaxehf`, database `oes_sandbox`. Três consultas `SELECT` ao catálogo executadas pelo conector Neon sob `oes_sandbox_owner`; sem transação de alteração, DDL, DML, criação de papéis ou captura externa.

**Resultados:**
- `oes_raw_private`: inexistente (`pg_namespace` = 0), portanto sem conflito de schema; objetos associados = 0.
- 37 tabelas não sistêmicas visíveis; schemas existentes `appraisal`, `artifact`, `core`, `evidence`, `investigation`, `product`, `provenance`, `public`, `synthesis`.
- Para os schemas de aplicação existentes, `PUBLIC` sem `USAGE`; `public` com `USAGE` (padrão distinto).
- `oes_pg_a4_reader` existe, `LOGIN=true`, `INHERIT=false`, `SUPERUSER=false`, `CREATEROLE=false`, `CREATEDB=false`, não membro direto de `oes_sandbox_owner` e sem `CREATE` no schema `public`.
- `oes_sandbox_owner` existe e possui `CREATEROLE` e `CREATEDB`, mas não `SUPERUSER`.
- Identidades planejadas `oes_e6_writer` e `oes_e6_verifier` **não existem**; nomes provisórios, ainda não aprovados.

**Avaliação:** `READ_ONLY_CATALOG_PREFLIGHT_PASS_FOR_NAME_CONFLICT_AND_ROLE_BASELINE`. Isso **não** equivale a auditoria exaustiva de ACL efetiva, herança complexa de privilégios, default privileges, teste de acesso negativo ou prova de ausência de exposição. Essas validações devem preceder a autorização da migração e da primeira escrita factual. Nenhum objeto do banco foi modificado; fixture PG-A4 não recebeu operações DML.

**Gate seguinte:** preparar revisão detalhada das permissões-alvo e dos testes sintéticos da proposta, sem executar migração ou captura até autorização separada.

**STOP — proposta aguardando avaliação, não autorização de SQL ou consulta factual.**
