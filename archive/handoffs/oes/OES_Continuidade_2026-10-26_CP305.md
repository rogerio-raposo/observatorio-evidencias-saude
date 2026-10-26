# OES — CP305 | Encerramento técnico restrito W2a
**Data:** 2026-10-26. **Anterior:** CP304. **Escopo:** W2a criação do papel NOLOGIN, grants mínimos, verificações de catálogo e reconciliação da membership administrativa. **Documento material:** 335. **Ponteiro:** `archive/handoffs/oes/README.md`.

## Conclusões verificadas
- O projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox` recebeu, mediante aprovação específica, `CREATE ROLE oes_qprep_writer NOLOGIN` e os GRANTs do CP304 em uma transação concluída.
- Preflight e postflight READ ONLY: papel anteriormente ausente e agora criado; cinco tabelas Q0/Q1/ledger; atributos NOLOGIN, NOINHERIT e não administrativos; SELECT/INSERT nas cinco tabelas; UPDATE exclusivamente `core.entity_version(version_status,valid_to)`. Negativas de DELETE, TRUNCATE, UPDATE geral, UPDATE `version_uuid` e CREATE nos schemas confirmadas por funções de catálogo. Nenhum SET ROLE ou DML de aplicação.
- Associação `oes_sandbox_owner` → `oes_qprep_writer` registrada com `ADMIN TRUE, INHERIT FALSE, SET FALSE`, grantor `cloud_admin`. Compatível com auto-membership PostgreSQL em CREATE ROLE por CREATEROLE, conforme documentação oficial; não constitui associação reversa ou prova de privilégios administrativos do writer. A origem Neon específica não foi auditada. Não houve REVOKE nem cleanup.
- **Classificação delimitada:** `W2A_CLOSED_TECHNICAL_RESTRICTED_ROLE_AND_ACL_ONLY`. A divergência administrativa passa de HOLD investigativo para observação aceita em escopo laboratorial, sem ampliar prontidão operacional. Doc.335 contém parecer completo.

## Limites
Não testados: login independente, uso Django, SET ROLE, DML, funções/sequências de escrita, integridade conectada Q0→Q1, idempotência, concorrência, isolamento entre preparadores, política RLS, fluxos HTTP e recuperação pós-commit. `oes_qprep_writer` permanece criado no ambiente sintético. Nenhuma operação no Neon autorizada além das já concluídas. O owner nunca deve ser identidade runtime.

## Invariantes
Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; E9 NO-GO; A3 ausente; sem pesquisadores vinculados, nenhuma captura factual nova, implantação ou serviço pago.

## Ponto exato de retomada
Aplicar Freshness Gate. **Não repetir W2a**. A próxima atividade, após `Prossiga`, é reavaliar proporcionalmente a sequência PF-I02 posterior, priorizando porta SQL/integridade sintética offline e condições mínimas do eventual gate conectado (W2b/W3), sem execução nem credenciais/SET ROLE/DML até aprovação nominal. Não iniciar etapa seguinte automaticamente após checkpoint.
