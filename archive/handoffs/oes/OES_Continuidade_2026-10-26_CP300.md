# OES — CP300 | Ensaio sintético Q0→Q1 transacional verificado

**Data:** 2026-10-26. **Anterior:** CP299. **Documento central:** `docs/governance/319-pf-i02-i01-d0-resultado-ensaio-q0-q1.md`.

## Marco
PF-I02-I01-D0 autorizado explicitamente e executado somente no Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, como teste sintético sob `oes_sandbox_owner`. T1 inseriu Q0 isolada versão 1 `q0_draft`; T2 criou Q1 versão 2 `q1_proposed` com supersessão e mesmo Q0 preservado. Verificador READ ONLY: 2 versões, 1 current, Q0 MD5 igual, E9 não criado. Cleanup transacional por IDs exatos em quatro tabelas e pós-verificação READ ONLY com zero resíduos. **`SYNTHETIC_Q0_Q1_T1_T2_VERIFIED_AND_CLEANED`**.

## Fronteiras
Não houve implementação HTTP, autenticação real, usuário operacional independente, idempotência durável nem teste de concorrência simultânea; não foram alterados grants, roles, schema, deployment, workflow factual, E9 ou dados não sintéticos. Teste sintético não encerra PF-I02 nem Marco B. Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`, A3 ausente.

## Próximo passo
Retomar integração Django/PostgreSQL do piloto, priorizando identidade humana, papel técnico mínimo e mecanismo de auditoria/idempotência sem repetir ensaio administrativo encerrado. Necessárias novas autorizações por gate conectado e implementação de escrita HTTP. Protocolo: Freshness Gate, atividades delimitadas por `Prossiga`, persistência material em main.
