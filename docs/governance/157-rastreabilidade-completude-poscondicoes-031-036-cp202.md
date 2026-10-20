# 157 — Rastreabilidade de pós-condições 031–036 (CP202)
**OES | 2026-10-20 | Fase 4 | DRAFT_ONLY**
Base: CP201, Documentos 152–156 e `database/f4-reconciliation-postconditions-draft.json`. Consolidação A1–A3, sem execução SQL/Neon/CI, coleta factual, gasto ou aprovação.

## Correspondência entre identificadores originais e catálogo
- Ordinal 31 / `database/031_propagation_rebaseline_contract.sql` / Documento 152: M031-TAB, M031-FUN, M031-TRG-DIRECT, M031-TRG-DYNAMIC, M031-FK, M031-ADAPT-COL, M031-ADAPT-FK, M031-ADAPT-CHECK, M031-ADAPT-LEGACY, M031-GUARDS, M031-TX (11).
- Ordinal 32 / `database/032_temporal_calibration_prerequisites.sql` / Documento 153: M032-TAB, M032-FUN, M032-TRG, M032-CONSTRAINT-TRG, M032-ALTER, M032-FK, M032-GUARD, M032-DEFERRED, M032-TX (9).
- Ordinal 33 / `database/033_non_normative_temporal_observation.sql` / Documento 154: M033-TAB, M033-FUN, M033-TRG, M033-VIEW, M033-FK, M033-RECEIPT (6).
- Ordinal 34 / `database/034_temporal_observation_activation_chronology.sql` / Documento 155: M034-FUN, M034-TRG, M034-WINDOW, M034-AUTH-AT-START, M034-DEVIATION, M034-ROLLBACK (6).
- Ordinal 35 / `database/035_temporal_observation_activation_preflight.sql` / Documento 155: M035-FUN, M035-CHECKS, M035-STATUS-PRECEDENCE, M035-ACTIVATION-WINDOW, M035-AUTH-AS-OF, M035-ZERO-PRESTART, M035-READONLY (7).
- Ordinal 36 / `database/036_temporal_first_measurement_semantics.sql` / Documento 155: M036-FUN, M036-TRG, M036-FIRST, M036-SUBSEQUENT, M036-FAILURE, M036-SOURCE-SCOPE, M036-CONCURRENCY (7).

**Total: 46 identificadores originais, todos propostos.** Nenhum incorporado às listas de pós-condições do catálogo; entradas 31–36 `UNREVIEWED`, `postconditions=[]`, `review_evidence=[]`, execução não autorizada. Fronteiras textuais: 031–033 `INTERNAL_BEGIN_COMMIT_OBSERVED`; 034–036 `NO_WRAPPER_BEGIN_COMMIT_OBSERVED`. Não comprovam atomicidade.

## Associação candidata G1-E01–E06
G1-E01 identidade; E02 estrutura; E03 transações; E04 comportamento; E05 concorrência; E06 auditoria. Migração 031: E01/E02/E03/E04/E06. 032: E01/E02/E03/E04/E06. 033: E01/E02/E06 com E03–E05 ainda não individualizados. 034: E01–E04/E06. 035: E01/E02/E04/E06. 036: E01/E02/E04/E05/E06. Todas associações são candidatas; não alteram catálogo.

## Detalhamentos candidatos, não normativos
1. M031-GUARDS-INSERT — inserção inválida.
2. M031-GUARDS-IMMUTABILITY — imutabilidade de snapshots.
3. M031-ADAPT-LEGACY-BASELINE — CHECK anterior/posterior.
4. M032-DEFERRED-COMMIT — falha na confirmação.
5. M033-EPOCH-LIFECYCLE — transições permitidas/proibidas.
6. M033-EVENT-APPEND — validação de tentativas e oportunidades.
7. M033-EVENT-CONCURRENCY — concorrência de `attempt_no`.
8. M033-IMMUTABILITY — linhas históricas.
9. M034-AUTH-HISTORICAL — autoridade em `started_at`.
10. M035-PREFLIGHT-INTEGRATION — exigência operacional externa de preflight.
11. M035-TOCTOU — mudança entre preflight e ativação.
12. M036-FIRST-CONCURRENCY — primeira conclusão concorrente por fonte.

**Correção:** a A3 na conversa anterior indicou onze, mas enumerou doze itens. Contagem verificada: **12 candidatos**. Não se altera nem renumera nenhum dos 46 IDs existentes.

## Critérios e limites
Cada requisito futuro precisa de SHA da fonte, objeto/DDL, condição observável, teste ou consulta versionada, resultado esperado, ambiente, instante, executor, evidência e revisão independente. Ensaios de SQL — inclusive consultas somente leitura —, rollback, concorrência e alterações de papéis exigem autorização específica. Pré-flight é consultivo e não valida ativação. Nenhum cenário foi executado.

36 migrações UNREVIEWED; zero pós-condições aprovadas; 36 requisitos de 034–036 NOT_COLLECTED; 12 roles pendentes; BRG-03/06/07/08 BLOCKED; BRG-04/05 apenas históricos; BRG-09 parcial; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado; Fase 4 NOT_READY; Fase 5 NOT_STARTED. Autoridade: PREPARE_G1_DOCUMENTARY_ONLY.

**Retomada:** próximo bloco A1 deverá detalhar critérios para riscos de 033 e integração 034–035 sem modificar catálogo nem executar SQL. STOP.
