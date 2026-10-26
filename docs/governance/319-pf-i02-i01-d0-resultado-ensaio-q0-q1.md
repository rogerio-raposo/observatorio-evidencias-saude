# Documento 319 — PF-I02-I01-D0: resultado do ensaio Q0→Q1 sintético

**Data:** 2026-10-26. **Autorização:** APPROVED — OES / PF-I02-I01-D0 / ONE_SYNTHETIC_Q0_Q1_TRANSACTION_AND_PRECISE_CLEANUP / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / preflight READ ONLY / synthetic four-table DML only / exact-ID cleanup / private verification / no role or grant changes / no Django HTTP / no E9 / no factual GET / no paid services / fail closed.

## Ambiente e segurança
Projeto `weathered-boat-65779510`; branch exclusivamente sintética `br-gentle-hall-b6jaxehf`; banco `oes_sandbox`; papel técnico de execução `oes_sandbox_owner`. Sem acesso à branch `production`. Freshness Gate antes da execução: `main` idêntico ao commit `7a38dc630333c644e8986a206d6a167d0c53c92c`.

Preflight READ ONLY comprovou banco, papel, `transaction_read_only=on`, zero registros de Question Version e inexistência de colisão do ID `OES-Q-2026-009991`, UUID de entidade `90000000-0000-0000-0000-000000009991` e versões `91000000-0000-0000-0000-000000009991`/`...9992`.

## Execução
- **T1**: uma transação inseriu `core.entity`, `investigation.question`, `core.entity_version` versão 1 `current` e `investigation.question_version` `q0_draft` com Q0 literal sintética e `normalized_text=NULL`. Verificação privada READ ONLY confirmou Q1 ausente e MD5 Q0 `b4e57c64e1292de1386df517fe94a758`.
- **T2**: nova transação bloqueou entidade, marcou versão 1 `superseded`, criou versão 2 `current` com `supersedes_version_uuid` apontando para versão 1, `preparation_stage='q1_proposed'` e Q1 sintética. Verificação privada READ ONLY confirmou duas versões, **exatamente uma `current`**, mesmo digest do Q0 nas duas, Q1 apenas na segunda, e zero Investigation criada para a entidade.
- **Cleanup**: transação controlada excluiu `question_version`, depois `entity_version` mais nova e antiga, `question` e `entity` por UUIDs/ID exatos, em ordem referencial; nenhuma remoção ampla. Postflight READ ONLY confirmou **zero resíduos** nas quatro tabelas para IDs reservados. Não houve leitura nem mudança de dados de outros casos.

## Parecer e limitações
**`SYNTHETIC_Q0_Q1_T1_T2_VERIFIED_AND_CLEANED`**. Comprova operações e integridade básica de versionamento sob owner administrativo, sem novos dados factuais. MD5 é evidência de igualdade, não garantia de segurança. **Não** comprova idempotência durável, concorrência simultânea adversarial, autenticação humana Django, papel independente de menor privilégio, auditoria operacional completa ou endpoint HTTP. Nenhum GRANT/role, schema, workflow, E9, serviço pago ou deployment foi alterado.

## Próxima fronteira
Priorizar integração funcional PF-I02-I01-D com autenticação real e papel técnico autorizado, revisando apenas lacunas que impedem escrita HTTP segura. Respeitar o gate conectado diferido no Doc. 285, sem repetir T1/T2 administrativa por rotina. Marco B aberto; E9 NO-GO; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; pesquisadores não vinculados e A3 ausente.
