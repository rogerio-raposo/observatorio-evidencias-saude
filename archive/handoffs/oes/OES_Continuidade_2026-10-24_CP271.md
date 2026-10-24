# OES — CP271: primeiro ensaio PostgreSQL sintético em Neon

**Data:** 2026-10-24. **Checkpoint anterior:** CP270. **HEAD anterior ao registro:** `d612672ab97ddeb6aa69324aa1fb31393cae6f6e`. **Status:** `PG_A3_SQL_SYNTHETIC_BASELINE_003_AND_BEHAVIORAL_TEST_PASS_LIMITED / PG_A4_NOT_AUTHORIZED`.

## 1. Marco e cadeia documental

Este checkpoint consolida as atividades PG-A1–PG-A3 após CP270. Documentos: `docs/governance/256-pg-a1-prioridade-inventario-integracao-postgresql.md` (inventário); `257-pg-a2-desenho-minimo-study-report-proveniencia.md` (primeiro slice Study/Report/proveniência); `258-pg-a3-gate-ensaio-sintetico-postgresql-neon.md` (gate); `259-pg-a3-revisao-proporcionalidade-minuta-g0-g1.md` (separação das autorizações); `260-pg-a3-g0-execucao-verificada-g1-pendente.md` (criação da branch e limites). O Documento 227 mantém o adaptador artesanal D1-T2-A2/A2-G4 diferido; não ressuscitar essa implementação.

## 2. Evidência operacional — Neon, alvo controlado

- Projeto existente: `oes-sandbox` / `weathered-boat-65779510`; região `aws-sa-east-1`, Neon Free, PostgreSQL **18.6** no teste.
- Branch experimental **não principal**: `oes-pg-a3-synthetic-20261024`, ID `br-gentle-hall-b6jaxehf`; origem `production`, ID `br-wild-field-b6qg7k3p`. Não alterar a origem por inferência.
- Endpoint exclusivo: `ep-wispy-dream-b6021bw0`, 0,25–0,25 CU, conexão direta sem pooler; última consulta administrativa mostrou `idle`/suspenso, não apagado.
- Baseline `database/poc-s1.sql`, Git blob `887d61a3da77ac1fa7fa654085ef2a856627caca`, SHA-256 do UTF-8 recuperado `2d856f3fe29c4b600086a8996b14b74524b974471111f44c3244061b901e36e5`: **66 instruções de conteúdo** aplicadas em uma transação; confirmação por catálogo: **8 schemas, 32 tabelas e 5 views**, incluindo `evidence.study`, `evidence.report`, `provenance.record`.
- `database/003_poc_s3_provenance_guard.sql`, blob `411d9b218be050057745a8389eeec251a2318a2d`, SHA-256 `98723e581b9c329cf8534ffe7501bcdc522fd73aa1f381656571feae4d344e3b`: 3 instruções transacionais aplicadas; conferidos no catálogo triggers `tr_provenance_guard_update` e `tr_provenance_guard_delete`.
- Migrações 002 e 004–036 **não aplicadas**. Os 36 arquivos de migrations permanecem **UNREVIEWED** para promoção operacional. Os hashes relatados foram calculados sobre textos UTF-8 recebidos via conector GitHub; recalcular diante de nova transferência/execução.

## 3. Evidência comportamental e limites

Bateria transacional **inteiramente sintética** executada na branch isolada com quatro entidades (2 Study, 2 Report), versões, 3 vínculos (incluindo N:M) e um registro de proveniência. Foram testados:
- inserção tipada e versionada; associação Study–Report;
- rejeição de segunda versão corrente (unique_violation);
- rejeição de entidade de tipo incorreto pelo trigger;
- rejeição de vínculo sem Report existente (foreign_key_violation);
- rejeição de UPDATE material e DELETE de proveniência pelos guards da migration 003.

Um bloco PL/pgSQL usou exceção sentinela controlada para reverter a subtransação contendo todas as fixtures após validar as expectativas. Consulta independente posterior confirmou **0 entidades de teste, 0 vínculos de teste e 0 registros de proveniência de teste remanescentes**, com **2 triggers** preservados. A execução retornou sem exceção inesperada.

**Limites de inferência:** testes restritos não constituem suite completa; não demonstram concorrência, falha de conexão/COMMIT incerto, recuperação, idempotência, avaliação SA/BRG, segurança de produção, compatibilidade geral Django ou qualidade científica. A branch e o schema experimental continuam existentes e não foram descartados. Nenhuma integração Django nem nova consulta a dados reais.

## 4. Estado global e preservação de gates

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; D1 demonstrador sintético restrito; D2 `PARTIAL`; E6-G1 `NOT_APPROVED`, workflow factual `if: false`; M3 `BLOCKED`; BRG/SA pendentes; Fase 5 `NOT_STARTED`. CP271 **não promove** qualquer componente a operação ou ciência; PostgreSQL do Neon permanece prova sintética delimitada. Projeto separado `oes-d1-t2-a2-synthetic` preservado, sem alteração.

## 5. Retomada segura

Próximo `Prossiga`: **avaliação read-only, proporcional e não redundante de PG-A3-G2** (evidências, lacunas do ensaio e critérios para autorizar PG-A4 Django somente leitor). Não iniciar integração, escrever código, criar usuários, apagar branch ou aplicar migrations sem aprovação específica. Revalidar HEAD, branch e estado do ambiente antes de cada ato. Protocolo uma atividade por `Prossiga`; checkpoints a cada 3–5 atividades ou por marco; STOP. A trilha E6 permanece bloqueada independentemente da maturidade PG.

**STOP — CP271.**
