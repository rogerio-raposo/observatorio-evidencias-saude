# Documento 318 — PF-I02-I01-D0: autorização proposta para ensaio sintético Q0→Q1

**Data:** 2026-10-26. **Estado:** `PROPOSED_NOT_AUTHORIZED`. **Base:** Doc. 317/CP299. Nenhuma DML autorizada por este documento.

## Escopo fechado
Um conjunto **exclusivamente sintético** e identificável, com Q0 literal de teste e Q1 proposta, no projeto Neon `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`. Excluir `production`, Django HTTP, usuários reais, consultas factuais, E9, produtos e ciência. **Não equivale a autenticação independente**: ensaio administrativo sob owner, quando aprovado, exige gate separado para role técnica de menor privilégio.

## Procedimento sujeito a aprovação
1. **Preflight transacional READ ONLY:** confirmar alvo, role, schema pós-Doc317, dados de teste ausentes, zero conflitos para IDs/UUIDs sintéticos reservados, constraints, dependências de FK e plano de cleanup. Não ler payloads não sintéticos. `SET LOCAL lock_timeout='2s'`, `statement_timeout='10s'` na etapa autorizada.
2. **Transação T1 — Q0:** inserir apenas entidades `core.entity`, `investigation.question`, `core.entity_version`, `investigation.question_version`, com `preparation_stage='q0_draft'` e `normalized_text=NULL`. Salvar valores literais/digest conhecidos e evidência do estado. Não criar Investigation nem outras entidades.
3. **Transação T2 — Q1:** bloquear entidade e comparar versão esperada; marcar versão anterior `superseded` e inserir versão 2, com `original_text` idêntico e `normalized_text` proposta, `preparation_stage='q1_proposed'`, `supersedes_version_uuid` correto; validar unicidade, autoria técnica identificada e ausência de segundo `current`. Não afirmar idempotência persistente ou auditoria de usuário humano: ainda não existem mecanismos para comprová-las.
4. **Verificador privado read-only:** verificar identidade, versões, estados, Q0 original, Q1 proposta, digest, número de registros e ausência de abertura E9; não publicar textos ou JSON brutos.
5. **Limpeza precisa e verificável:** excluir **somente** IDs sintéticos reservados na ordem referencial inversa (`investigation.question_version`, `core.entity_version`, `investigation.question`, `core.entity`) e confirmar contagens zero. Cleanup é DML separado, precisa estar autorizado explicitamente. Se alguma etapa ficar incerta, interromper, registrar HOLD e não tentar DELETE amplo ou replay.
6. **Falhas:** rollback de transações ainda abertas; se commit pode ter ocorrido, verificar por leitura antes de qualquer repetição, preservar evidências e executar cleanup somente se inequívoco. Não prometer rollback após commit.

## Critérios de aceite restrito
T1 e T2 consistentes, vínculo de supersessão, Q0 literal íntegro, Q1 atribuída somente à nova versão, leitura privada, cleanup zero dos IDs de teste e dados alheios inalterados. Testes de concorrência real, idempotência durável, permissão SQL independente, login Django e escrita HTTP continuam fora do aceite.

## Fronteiras explícitas
Nada de criar/alterar roles/grants, credenciais, schema, branches, workflows, despesas, deploy ou E9. Proibir INSERT/UPDATE/DELETE fora das quatro tabelas e do conjunto sintético reservado. Se constraints impedirem a execução sem mudança de schema, HOLD; não modificar esquema por conveniência.

## Decisão solicitada
`APPROVED — OES / PF-I02-I01-D0 / ONE_SYNTHETIC_Q0_Q1_TRANSACTION_AND_PRECISE_CLEANUP / project weathered-boat-65779510 / branch br-gentle-hall-b6jaxehf / database oes_sandbox / preflight READ ONLY / synthetic four-table DML only / exact-ID cleanup / private verification / no role or grant changes / no Django HTTP / no E9 / no factual GET / no paid services / fail closed`

**Invariantes:** Marco B aberto; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; A3 não realizada.
