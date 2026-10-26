# Documento 314 — PF-I02-I01-C: preflight conectado de catálogo (somente leitura)

**Data:** 2026-10-25 (America/Recife). **Base:** Doc. 313, CP298. **Escopo:** metadata de Neon e dois SELECTs de catálogo na branch sintética; sem qualquer DDL/DML/grant, dados científicos, criação de branches, serviços pagos ou deploy.

## Identificação do ambiente e alcance
Listagem de projetos indicou `tiny-pond-20086371` (D1/T2-A2 sintético) e `weathered-boat-65779510` (OES sandbox). Branches da segunda incluem `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`) e `br-wild-field-b6qg7k3p` (`production`). **Somente** a branch sintética `br-gentle-hall-b6jaxehf` foi consultada, banco `oes_sandbox`. Não consultar `production`.

Um SELECT confirmou `current_database()=oes_sandbox`, `current_user=oes_sandbox_owner`, `transaction_read_only=off`, e as relações `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e `investigation.investigation` existentes. **Importante:** execução SELECT não significa que a sessão tinha proteção transacional read-only; o papel observado é proprietário com `transaction_read_only=off`. Nenhuma escrita foi emitida. Futuras leituras devem preferir conexão de menor privilégio e `transaction_read_only=on` verificável.

Segundo SELECT, somente `information_schema.columns`, confirmou:
- `investigation.question_version.normalized_text`: `text NOT NULL`; `original_text`: `text NOT NULL`;
- `preparation_stage`: **ausente** na tabela;
- `core.entity_version`: `version_no`, `version_status`, `supersedes_version_uuid`, `created_by`, `change_note` disponíveis;
- demais campos Question e Entity coerentes com a estrutura da PoC inspecionada.
Não se consultaram linhas de Question, usuário, segredo ou payload científico; tampouco constraints/índices via catálogo completo, contagens de registros, roles/grants reais ou migrações.

## Resultado
A incompatibilidade **Q0-only** do Doc. 313 foi corroborada **no catálogo da branch sintética selecionada**. Esse achado **não** prova a estrutura da branch `production` nem autoriza aplicar a migração proposta. O alvo definitivo de persistência e política de credenciais ainda precisa de decisão específica.

## Próxima fronteira
Antes de qualquer DDL: escolher ambiente-alvo com autorização expressa, usar leitor limitado em modo comprovadamente read-only para análise completa de índices/constraints/migrações e aprovar SQL exato + plano de preservação/rollback, identidade técnica e custos. Não reaproveitar `oes_sandbox_owner` para a rota Django. I01-A `COMPLETED_OFFLINE_AUTH_SCAFFOLD_ONLY`, I01-B `DESIGNED_NOT_APPLIED`, I01-C apenas `CATALOG_PREFLIGHT_PARTIAL_READ_ONLY_QUERIES`, I01-D não iniciada.

Marco B aberto; E9 NO-GO; A3 ausente; readiness `NOT_READY`; Fase 5 `NOT_STARTED`.
