# 130 — Matriz provisória de suficiência de evidências para reconciliação das migrations 034–036

**OES — Fase 4 | 2026-10-19 (America/Recife) | modo alto**  
**Classificação:** DRAFT_EVIDENCE_REQUIREMENTS_VALIDATED_STATICALLY — ZERO_POSTCONDITIONS_APPROVED — NO_SQL_OR_NEON.  
**Base:** CP173 / Documento 129 / HEAD de entrada `9d39071800343151b917ea7d00862f12f8c00f4a`.

## 1. Continuidade, escopo e fronteiras

O Freshness Gate comparou o HEAD CP173 com o `main`: `identical`, ahead=0, behind=0. O ponteiro canônico apontava CP173 e o checkpoint foi consultado. Foram relidos a política canônica `docs/architecture/30-politica-migracoes.md`, o Documento 129 e os SQL 034–036. O catálogo principal das 36 migrations foi conferido **36/36 `UNREVIEWED`, zero pós-condições aprovadas, todas as flags automáticas `false`**.

Esta entrega é **exclusivamente documental e de validação estática**. Não usa PostgreSQL, SQL real, Neon, fontes científicas, dados clínicos, billing ou credenciais. Não atualiza a política 30, não cria runner e não converte experimentos sintéticos anteriores em prova de prontidão.

## 2. Objetivo e modelo de suficiência

Foi criada a matriz `docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json`, com **três migrations e 36 requisitos obrigatórios ainda `NOT_COLLECTED`**, assim distribuídos:

| Ordinal | Migration | Requisitos | Evidência aprovada |
|---|---|---:|---:|
| 034 | `034_temporal_observation_activation_chronology.sql` | 12 | 0 |
| 035 | `035_temporal_observation_activation_preflight.sql` | 12 | 0 |
| 036 | `036_temporal_first_measurement_semantics.sql` | 12 | 0 |

Oito eixos comuns a cada migration: (1) identidade exata e hash do arquivo e dependências; (2) ledger/intenção prévia, tentativas, commit/recibo e incerteza; (3) catálogo PostgreSQL, dependências, proprietário e ACL; (4) integridade de registros históricos; (5) segregação real de privilégios; (6) auditoria DDL e janelas em que triggers possam ter sido desabilitados; (7) evidência de backup/restore independente; (8) revisão independente especializada com aprovação do titular do projeto quando necessária.

Quatro eixos específicos por migration:

- **034:** fingerprint e assinatura da função `assert_temporal_epoch_activation_chronology`; trigger efetivamente habilitado e ligado à tabela/função/evento esperado; coerência histórica entre epoch, `started_at`, primeira oportunidade, autoridade no instante e desvios; interpretação fail-closed após `DROP TRIGGER`/erro/replay.
- **035:** definições/assinaturas das duas funções de preflight como conjunto lógico; comportamento read-only `FAIL/WAIT/PASS` com dados controlados; identificação de estado misto após commit parcial; dependências das funções auxiliares, fontes e permissões.
- **036:** fingerprint/assinatura da função de primeira medição; trigger habilitado e ligado a `temporal_measurement_event` para `BEFORE INSERT`; integridade histórica da sequência de eventos concluídos por epoch_source, novelty e atribuição; recuperação de registro inválido inserido com trigger desabilitado.

A matriz registra exigências, **não resultados de inspeção**. Os campos `verification` permanecem `NOT_COLLECTED`; `evidence_artifact`, `independent_reviewer` e `reviewed_sha256` estão nulos. `fully_applied_verified=false`, `automatic_replay_allowed=false`, `automatic_reconciliation_allowed=false`, `operational_runner_authorized=false` e `neon_write_authorized=false`.

## 3. Decisão provisória fail-closed

Enquanto faltar qualquer prova ou houver drift/commit incerto:

1. **NÃO inferir `applied` por existência de função ou trigger.** Conferir definição completa e comportamento, inclusive efeitos pretéritos.
2. **NÃO considerar `tgenabled='O'` prova retroativa** de que linhas históricas respeitam guards; a contraprova do Documento 129 demonstrou registros inválidos persistindo após reabilitação.
3. **NÃO repetir SQL automaticamente** quando houver intenção prévia ou commit incerto. Usar estado `uncertain_requires_reconciliation` e revisão deliberada.
4. **NÃO aprovar ausência de risco só porque o guard está ativo hoje**. Necessários logs externos de DDL, concessões de privilégios e eventuais alterações administrativas, com escopo de auditoria e retenção aprovados.
5. **NÃO confundir ausência de evidência com ausência de alterações.** Se logs, backup/restore, histórico ou identidade de arquivo não estiverem verificáveis, bloquear promoção.
6. **NÃO presumir atomicidade de 034–036**. Os Documentos 126–129 demonstraram cenários de confirmação parcial e comportamento vulnerável à remoção administrativa dos guards.

Nenhum item acima constitui implantação de proteção real. Uma matriz preenchida e revisada **ainda exigirá decisão normativa e autorização específica**, inclusive revisão humana de especialidade PostgreSQL/segurança e conteúdo metodológico OES.

## 4. Validador, testes e prova de CI

Artefatos criados:
- `scripts/oes_f4_temporal_sufficiency_matrix_lint.py`: valida somente a conformidade fail-closed dos 3 registros/36 requisitos, identidade com manifesto de 36, ausência de promoção no catálogo principal e campos de bloqueio. Não consulta qualquer banco.
- `tests/test_oes_f4_temporal_sufficiency_matrix_lint.py`: 12 testes, incluindo 11 cenários de manipulação documental/negativa e controle positivo que declara explicitamente **zero aprovação**.
- `.github/workflows/f4-temporal-034-036-sufficiency-matrix-static.yml`: GitHub Actions sem serviço PostgreSQL, `contents:read`, checkout fixado sem credenciais persistentes, Python 3.13 e gatilho `push` somente nos próprios arquivos/manifesto/catálogo. Upload do artifact inclusive em falhas.

**Run:** https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39357315282  
**Job:** `118414984671`; **`completed/success`**.  
**HEAD do ensaio:** `bce4b359c5658ce94342b457cd79b06f3bab6b32`.  
**Teste:** `Ran 12 tests`, `OK` e marcador `DRAFT_EVIDENCE_MATRIX_BLOCKED_NO_OPERATIONAL_PASS` nos logs.

Artifact `f4-temporal-sufficiency-matrix-draft`, ID **12235633344**, ZIP recuperado/aberto sem erro, SHA-256 **`6db9387eb7b10476d03ba5403f6b145510f4bbda699da8163b9459c8c7959537`** calculado e coincidente com digest GitHub. `status.json`: `migrations=3`, `requirements=36`, `operational_postconditions_validated=0`, `independent_reviews_performed=0`, `sql_executed=false`, `neon_accessed=false`, `neon_write_authorized=false`. Digest SHA-256 do `status.json`: `1953f250b6842ada9c7d216b66e1727b0fb055a123c195fdd243b4e8f1732590`.

## 5. Lacunas e limites do resultado

- A CI comprova que o documento **não foi artificialmente promovido** e que campos e exigências definidos estão presentes; não comprova se as exigências são exaustivas, juridicamente adequadas ou metodologicamente suficientes. O verificador não é parser SQL nem inspeciona `pg_catalog`.
- Nenhuma função/trigger operacional foi inspecionada neste checkpoint, nenhuma identidade `pg_get_functiondef` real conferida, nenhum histórico de DDL obtido, nenhuma ACL real testada, nenhum backup configurado.
- `BRG-03`: isolamento de roles, TLS, credenciais, DDL audit e acesso ao Neon sem prova. `BRG-06/07`: ledger/runner com fencing operacional não implementados. `BRG-08`: backup e restore independente ausentes. `BRG-09`: owner billing pendente.
- As 36 migrations continuam `UNREVIEWED`; esta matriz **não** altera nem substitui `database/f4-reconciliation-postconditions-draft.json`. Não há revisão humana independente.
- Não houve mudança no Neon, criação de branch, migration, dados científicos, reabertura de B1R1 ou início da Fase 5.

## 6. Continuidade

Próximo gate recomendado: elaborar **plano de prova para segregação de roles e auditoria DDL, somente em PostgreSQL 18 descartável**, incluindo negativa de `ALTER TABLE ... DISABLE TRIGGER` para runtime/migrator de privilégio reduzido, identificação de proprietário do schema e logging de alterações privilegiadas. O desenho deve contemplar revisão humana posterior e não habilitar acesso ao Neon por `Prossiga` genérico.

**Fim do Documento 130.**
