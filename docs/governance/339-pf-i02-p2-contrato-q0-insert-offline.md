# Documento 339 — PF-I02-P2: contrato de INSERT Q0 offline (DESIGN ONLY)
**Data:** 2026-10-26. Base: CP308, Docs. 316/330/336/338; CI 40273976214 (117/117 PASS). Nenhuma execução SQL ou alteração Neon autorizada nesta atividade.

## Sequência transacional candidata
Após autenticação e autorização global Django, transação atômica injetada:
1. `lock_request(actor_id,request_id)`; buscar recibo para idempotência, revalidar responsabilidade vigente em replay.
2. Diante de ausência de recibo, verificar **existência global da identidade oes_id**, não apenas `current_question(question_id,actor_id)`, que esconde entidades de outros responsáveis. Se existente: HOLD/CONFLICT sem revelar dados. Conflitos de concorrência precisam depender de `UNIQUE(core.entity.oes_id)` e rollback completo.
3. Gerar em Python dois UUIDs distintos (entidade e versão), apenas para entrada sintética, não atribuir UUID via consulta da base nem interpolação SQL.
4. INSERT `core.entity(entity_uuid,oes_id,entity_type,created_by)`; `entity_type` requer confirmar literal canônico na documentação/modelo antes de implementar.
5. INSERT `investigation.question(entity_uuid,responsible_actor_id)` com responsabilidade inicial idêntica ao ator autenticado.
6. INSERT `core.entity_version(version_uuid,entity_uuid,version_no,version_status,created_by,change_type,...)` com `version_no=1`; `version_status`/ `change_type` requerem confirmação de semântica; campos adicionais/validade devem respeitar defaults e constraints reais.
7. INSERT `investigation.question_version(version_uuid,entity_uuid,original_text,normalized_text,preparation_stage)` com `normalized_text=NULL`, `preparation_stage='q0_draft'`.
8. INSERT `investigation.question_command_receipt(actor_id,request_id,fingerprint_sha256,question_entity_uuid,question_id,resulting_version_uuid,resulting_version_no,command_kind,justification)` com `version_no=1`, `command_kind='REGISTER_Q0'`, `justification=''`.
9. Confirmar somente ao final da transação; qualquer erro, conflito, ausência de garantia de atomicidade ou resultado incerto => HOLD sem retry cego.

## Riscos identificados
- `current_question()` é filtrado por responsável e não identifica colisões globais de oes_id; fazer consulta independente e tratar UNIQUE, sem divulgar estado alheio.
- Sem RLS: consultas e writer técnicos não provam segregação multiusuário.
- Ainda falta confirmação da convenção para `entity_type`, `change_type`, `version_status` e formato de exceções/conflitos, para não inventar valores de domínio.
- Falta comprovar que a conexão injetada gerencia rollback e commit únicos com bloqueio mantido até o fim.
- `register_q0()`, `propose_q1()`, `save_receipt()` permanecem em HOLD até implementação offline e testes; nenhuma escrita conectada foi habilitada.

## Aceite para próximo incremento
Implementar `register_q0` + `save_receipt` somente após resolver constantes acima e documentar política de geração de UUID/transação; testes mock devem inspecionar parâmetros, ordem das quatro tabelas+ledger, duplicidade, rollback, ator distinto e replay. Sem Neon, SQL conectado, GRANT, Django runtime, HTTP ou E9.
