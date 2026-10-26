# Documento 336 — PF-I02-P2-A5: política experimental de responsável único

**Data:** 2026-10-26. **Decisão:** APPROVED / SYNTHETIC_SINGLE_RESPONSIBLE_POLICY_ONLY. **Base:** CP306; código W1/W1B; CI 40271463247 (109/109 PASS).

## Autorização nominal
`APPROVED — OES / PF-I02-P2-A5 / SYNTHETIC_SINGLE_RESPONSIBLE_POLICY_ONLY / experimental Q0-Q1 / initial creator as responsible / current responsibility revalidated on Q1 and replay / preserve immutable ledger / no Neon / no SQL execution / no DDL or DML / no roles or grants / no credentials / no HTTP write / no E9 / no paid services / fail closed`.

## Regra aprovada, exclusivamente sintética
- Ao registrar Q0, o criador autenticado e autorizado por `evidence.prepare_question` é o responsável inicial daquela pergunta, no modelo experimental.
- Q1 e a leitura necessária para sua preparação exigem permissão geral e coincidência com o responsável **vigente**; ausência, divergência ou estado incerto => HOLD sem revelar conteúdo alheio.
- Replay idempotente deve confirmar responsabilidade vigente, não apenas existência e fingerprint do recibo. Revogação impede novos Q1 e replay, preservando recibos anteriores sem alteração.
- Ator de comando (ledger) e responsável atual são conceitos distintos; ledger é trilha imutável de comandos, não fonte de autorização atual.
- Transferências, delegação, equipes, política institucional real e autenticação independente não são abrangidas.

## Limite técnico
A regra no Fake W1B ainda não constitui persistência PostgreSQL. `investigation.question` é apenas local candidato para armazenar vínculo; nenhum campo existente foi confirmado em catálogo nesta decisão. **Nenhuma migração, implementação SQL ou concessão de acesso está aprovada.** Sem isolamento RLS comprovado, não usar o desenho como prontidão multiusuário.

## Próximo gate
Preflight de catálogo PostgreSQL **READ ONLY**, com autorização nominal separada, para determinar se `investigation.question` ou vínculo existente suporta o responsável atual; consulta apenas de metadados, sem SELECT de dados de usuários ou perguntas. Se não houver campo, preparar opções proporcionais de persistência antes de submeter DDL específico. Manter W2b/W3, HTTP e E9 bloqueados.

**Invariantes:** Marco B aberto; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; readiness NOT_READY; Fase 5 NOT_STARTED; A3 ausente e sem pesquisadores vinculados.
