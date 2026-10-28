# OES — Checkpoint de continuidade CP332 — 2026-10-28

**Anterior:** CP331 (`archive/handoffs/oes/OES_Continuidade_2026-10-28_CP331.md`). **Natureza:** snapshot operacional, não normativo. **Fonte de verdade:** documentação canônica, STATE, Documento 362 e decisão Django First (Documento 347). **Branch:** main.

## Base e atividades A1–A5 após CP331

- Freshness Gate inicial: main em `1b916b696e08fe191cc3f462d2d736d900350a3b`, igual ao HEAD de CP331. CP331 lido; resultado do preflight administrativo já constava na seção final de `docs/governance/oes-auth-single-database-architecture-2026-10-28.md`; nenhuma reauditoria ou alteração canônica necessária.
- A1: retomada, revisão do contrato G2-P2-B e confirmação de que ACLs catalogais de `oes_auth_migrator` para quatro INSERT, quatro DELETE e quatro sequências já estavam documentadas; nenhuma execução DML conectada.
- A2: módulo `applications/oes_web/config/auth_pg_g2_p2b_offline.py` e três testes SQLite acrescentados; commits `6ba5d433` e `03eedaf0`. CI 40744588262 FAILURE: guard do SQLite não aceitava URI interna de banco de testes Django; a falha não envolveu Neon.
- A3: guard reconhece SQLite de teste em memória; associação via `user.user_permissions.add(permission)` nativa. Commits `78f81f7` e `52122a5` (inclusão do módulo no filtro de CI). CI [40745400376](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40745400376) SUCCESS.
- A4: revisão da separação de responsabilidades; decisão técnica de conservar uma unidade ORM transacional Django-first, sem construir adaptador SQL paralelo. Apenas análise, sem alteração.
- A5: commit `1a05f8e2ee5a947a9763290414f06cb6c8718ed7` separa `_provision_transaction` da entrada pública `provision_offline`. O guard bloqueia PostgreSQL na entrada pública; a unidade interna não é um endpoint autorizado. CI [40745725023](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40745725023) SUCCESS. Não existe executor, workflow nem credencial conectada de G2-P2-B; execução PostgreSQL ainda não validada.

## Estado e limites

- Arquitetura: database único por ambiente, `oes_sandbox`, schema `django_auth` segregado dos científicos; projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`.
- Baseline histórica G2-P2-A: 44 permissões, zero usuários, zero vínculos, zero identidades e zero sessões; permissão `evidence.prepare_question` ausente. **Reconfirmar antes de qualquer DML.**
- G2-P2-B conectado: **HOLD**. O escopo sintético previsto é criar permissão, um usuário não administrador, vínculo explícito e PreparerIdentity com UUID estável, usando Django ORM/transaction.atomic, credencial protegida, verificação e limpeza posterior sujeitas a aprovação.
- Validade informada das credenciais de `oes_auth_migrator` e `oes_auth_trial_login`: 2026-10-31 23:59:59 UTC. Não inferir que expiração remove ACL/ownership.
- Nenhum DML Neon, GRANT, alteração de role, segredo, workflow conectado, escrita HTTP, deploy ou serviço pago nesta sequência A1–A5. Workflow B2-M1 e G2-P1 permaneciam desabilitados na consulta anterior.
- Fase 4: `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; Fase 5 NOT_STARTED; nenhum pesquisador real.

## Ponto exato de retomada

1. Freshness Gate no GitHub; conferir HEAD e ponteiro CP332.
2. Revisão técnica dirigida do núcleo ORM: confirmar que o contrato de baseline de produção deve ser revalidado `inside atomic`, com contagem exata (44 permissões) no ambiente conectado e proteção de concorrência; evitar copiar indiscriminadamente a baseline de SQLite. Assegurar ausência de rota de execução conectada sem autorização.
3. Preparar desenho mínimo de orquestração conectada sob papel `oes_auth_migrator`, com credencial efêmera, preflight/postflight, recuperação, sem habilitar o workflow ou realizar DML. **Propor autorização nominal somente quando houver pacote verificável.**
4. Não repetir auditoria catalogal nem expandir governança artificialmente. Uma atividade delimitada por `Prossiga`, checkpoint proporcional por risco ou lote. Nenhuma escrita Neon sem autorização específica. Falhas = HOLD/fail closed.

**Checkpoint anterior CP331 permanece imutável.** Este snapshot não promove gates. Ponteiro: `archive/handoffs/oes/README.md`.
