# OES — CP279: preparação G2, preflight de ACL e regressão 87/87

**Data:** 2026-10-24. **Anterior:** CP278. **HEAD-base:** `d9780153a7d73e96bca3533362f5a088210d9dd8`. **Escopo:** fechamento documental das atividades preparatórias G2-P1/P2/P3 e decisão de prontidão, sem autorização de execução operacional.

## G2-P1 — preflight conectado somente leitura autorizado

Autorização: `APPROVED — OES / D2-E6 / G2_P1_CURRENT_READ_ONLY_CATALOG_ACL_PREFLIGHT / br-gentle-hall-b6jaxehf / metadata and bounded counts only / no raw payload / no DDL or DML / no role or credential changes / no factual GET / no workflow enablement / no paid services / fail closed`.

Consultas efetivamente executadas no Neon: branch `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`, DB `oes_sandbox`, `current_user=session_user=oes_sandbox_owner`. Tabela `oes_raw_private.source_observation`: **0 linhas**. Consulta delimitada a `provenance.record` por `provenance_uuid='a4300000-0000-4000-8000-000000000001'`: **1 linha**, confirmando a presença atual do quarto invariante histórico PG-A4. A consulta não retornou dados brutos.

ACL: `oes_e6_capture_login` `NOLOGIN/NOINHERIT` e sem USAGE/INSERT/SELECT/membership; `oes_e6_writer` `NOLOGIN/NOINHERIT`, USAGE+INSERT e sem SELECT; `oes_e6_verifier` `NOLOGIN/NOINHERIT`, USAGE+SELECT e sem INSERT. Consulta não encontrou concessões feitas por `oes_sandbox_owner` para os três papéis. Catálogo confirmou **16 colunas**, `raw_payload bytea NOT NULL`, sem consultar valores. Esses resultados são fotografia do instante da consulta, não promessa de ausência de drift futuro.

## G2-P2 — desenho proporcional, sem execução

Proposta: driver `psycopg 3`, *não instalado nem integrado*; duas sessões autenticadas separadamente por identidades efêmeras de menor privilégio e papéis efetivos `oes_e6_writer`/`oes_e6_verifier`; TLS; conexão não autocommit; um INSERT sintético parametrizado, verificação restrita de SHA-256, tamanho e ID, limpeza por papel especificamente autorizado do ID sintético, revogação grantor-aware, invalidação das credenciais e encerramento das sessões. Rejeitar erro após commit como HOLD (registro possivelmente persistido): sem retry automático. Verificar defaults das duas colunas obrigatórias adicionais, compatibilidade de bytes `bytea` e lifecycle de conexões antes da operação.

## G2-P3 — preparação em código e evidência CI

Commit `d9780153a7d73e96bca3533362f5a088210d9dd8`: `tools/d2_e5_preservation/e6_g2_identity_gate_offline.py` e `tools/d2_e5_preservation/tests/test_e6_g2_identity_gate_offline.py`; somente mocks/conexões injetadas, sem driver, rede ou credenciais. Gate valida metadados declarados pela sessão (DB, login, papel, USAGE, INSERT e SELECT) antes de chamar o roundtrip offline. Oito testes novos. GitHub Actions [40135713382](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40135713382), job `120996673027`, commit `d9780153a7d73e96bca3533362f5a088210d9dd8`, resultado `success`, logs `Ran 87 tests in 0.209s` e `OK`; **87/87 PASS**. Isso não comprova isolamento/autenticação efetivos de Postgres com sessões reais.

## Avaliação formal de prontidão e fronteiras

**Preparação G2:** `G2_PREPARATION_VALIDATED / CI_87_OF_87_PASS`. **Prontidão operacional:** `NOT_READY_FOR_CONNECTED_APP_TRIAL`, pois duas identidades autênticas independentes ainda não existem/foram comprovadas, driver não está integrado, plano de limpeza/credenciais não está operacionalizado e nenhuma autorização de mutação foi concedida.

- `G2-I1_NOT_AUTHORIZED`: provisionamento e posterior remoção/inativação de credenciais transitórias demandam aprovação explícita própria, lista de operações e rollback delimitados. Não reutilizar credencial antiga nem usar o owner como substituto de duas autenticações.
- `G2-I2_NOT_AUTHORIZED`: somente após G2-I1 satisfatório poderá ser solicitado ensaio de aplicação Python com um registro exclusivamente sintético, verificação privada e limpeza; autorização independente.
- `E6_G1_FACTUAL_BLOCKED`, workflow `.github/workflows/d2-e6-a2-gated-capture.yml` com `if: ${{ false }}`. Sem JSON bruto público, serviços pagos, consultas factuais ou mudança em produção.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; D2 `PARTIAL`; readiness operacional geral `NOT_READY`; Fase 5 `NOT_STARTED`.

## Retomada

Usar template canônico `archive/continuity/OES_Template_Abertura_Continuidade.md` → `archive/handoffs/oes/README.md` → CP279 → Freshness Gate. Próxima atividade recomendada, **somente desenho não modificador**, é delimitar gate G2-I1 e decidir se custo/complexidade de novas identidades transitórias é justificável ou se alternativa de aplicação estritamente sintética, com prova inferior devidamente rotulada, reduz atrito. Não executar G2-I1 ou I2 sem aprovação formal. Uma atividade por `Prossiga`, checkpoint proporcional após 3–5 atividades. **STOP.**
