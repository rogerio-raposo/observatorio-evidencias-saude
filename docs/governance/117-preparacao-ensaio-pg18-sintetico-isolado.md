# 117 — Preparação de ensaio isolado das migrations no PostgreSQL 18

**OES / Fase 4 / 2026-10-19 / Modo médio**  
**Status:** PG18_REHEARSAL_WORKFLOW_PREPARED_ONLY — RUN_NOT_EXECUTED — NO_NEON_MUTATION.  
**Entrada:** Documento 116 / CP160 / HEAD `255663e154067ecca3f5073ec96ad69d084f4e6b`.

## Freshness Gate
Comparação `main` com HEAD CP160 = identical; ponteiro CP160 e checkpoint integral conferidos.

## Decisão técnica de preparação

O workflow histórico `.github/workflows/validate-s5.yml` já utiliza serviço `postgres:18`. O novo `.github/workflows/f4-neon-pg18-schema-rehearsal.yml` é **independente**, manual (`workflow_dispatch`), com somente `contents: read`, checkout sem credenciais persistidas, banco temporário `oes_f4_synthetic`, credencial artificial da própria job e ausência de secret, token, host ou SQL Neon.

O workflow proposto:
1. confirma a versão do servidor PostgreSQL 18 e registra a versão real do `psql`;
2. executa o verificador offline de 36 entrypoints e 14 includes no HEAD da job, recolhendo SHA-256;
3. aplica as 36 entradas sequencialmente via `psql -X -v ON_ERROR_STOP=1 -f`, com logs por arquivo, parada no primeiro erro e sem fixtures;
4. verifica somente contagens estruturais, incluindo epochs estruturais, sem inferir resultados científicos;
5. envia artifacts e logs em sucesso ou falha (`if: always()`).

**As operações SQL são exclusivamente no PostgreSQL descartável do runner GitHub Actions.** O workflow não cria tabelas, migrations nem branch no Neon. Não foi executado neste checkpoint e seus resultados são desconhecidos.

## Limites e controles

- O primeiro resultado da CI poderá indicar falhas de compatibilidade ou pressupostos não satisfeitos; não há PASS antecipado.
- A série de 36 migrations não é atomicamente una; wrappers 031–033 têm seus próprios BEGIN/COMMIT; logs são obrigatórios.
- `maintenance.contract_epoch` contém DML estrutural; não afirmar ensaio DDL-only. Sem fixtures científicas ou temporais.
- A job não implementa ledger `ops.schema_migration`, nem testa concorrência, crash recovery, restore ou invariantes de não reexecução. BRG-06/07 seguem pendentes.
- Utiliza credencial postgres do contêiner somente na CI, não representa prova de menor privilégio Neon. BRG-03 segue pendente.
- Artifact pode conter saídas SQL sintéticas e hashes; a publicação não deve incluir segredos externos.
- BRG-04 mantém prova histórica específica do SHA `55ef8051054652b3823de743293524f317a33ec6`; a job futura deverá fornecer prova no novo HEAD.
- Nenhum serviço pago aprovado; manter quota Free e nenhuma alteração do Neon.

## Passo seguinte

Obter run do novo workflow manual e recuperar job, logs/artifact; verificar se 36 migrations PASS, versão PG18 e `inventory.json`. Se falhar, classificar erro e planejar correção prospectiva sem editar artefatos congelados. Não extrapolar para `OPERATIONAL_DATABASE_READY`.

**B1R1 = EXPIRED_NOT_EXECUTED; PHASE_5 = NOT_STARTED.**

**Fim do Documento 117.**