# Documento 323 — PF-I02-W2: matriz mínima de privilégios e pré-condições de writer independente

**Data:** 2026-10-26. **Estado:** `W2_DESIGN_ONLY / NO_ROLE_OR_GRANT_AUTHORIZED`. Base: CP300, Docs. 285, 309, 317, 319–322.

## Conclusão executiva
O D0 comprovou Q0→Q1 apenas sob `oes_sandbox_owner`, e W1 mostrou uma interface de comando injetável, **sem implementação de Unit of Work durável, auditoria e idempotência**. Portanto, há base para especificar a matriz de privilégio mínimo, mas **não para conceder privilégios de escrita HTTP e anunciar W2 pronto**. Separar W2a (papel/grants no sandbox, após SQL e autorização própria) de W2b (autenticação técnica independente e verificador, mediante autorização própria). Não criar duas stacks de autenticação humana.

## Alvo permitido para futura autorização
Somente `weathered-boat-65779510` / `br-gentle-hall-b6jaxehf` / `oes_sandbox` (sintético). Branch `production` excluída. Novo papel candidato `oes_qprep_writer`, `LOGIN` somente após política e mecanismo de entrega de credenciais autorizados. Nunca role owner em Django; nunca reciclar `oes_pg_a4_reader` ou papel E6. Papel de verificação deve ter leitura apenas do conjunto aprovado, independente do writer.

## Matriz candidata — NÃO EXECUTAR GRANTS
| Objeto | SELECT | INSERT | UPDATE | DELETE | DDL |
|---|---|---|---|---|---|
| `core.entity` | somente campos de identidade necessários | entidade Question nova | NÃO | NÃO | NÃO |
| `core.entity_version` | versão/estado/autor necessários | versões Q0/Q1 | somente `version_status`, `valid_to` sob contrato | NÃO | NÃO |
| `investigation.question` | `entity_uuid` necessário | nova Question | NÃO | NÃO | NÃO |
| `investigation.question_version` | versões Q0/Q1 necessárias | versões Q0/Q1 | NÃO | NÃO | NÃO |
| `investigation.investigation*` | NÃO | NÃO | NÃO | NÃO | NÃO |
| Produto, captura E6, evidence/synthesis | NÃO | NÃO | NÃO | NÃO | NÃO |

Permissões de `CONNECT` e `USAGE` nos schemas `core`/`investigation` são candidatas necessárias; sem `CREATE`. O acesso `SELECT` amplo por tabela pode expor Question alheia: exigir política de escopo e, se necessário, RLS/função controlada antes da integração HTTP. A negativa de acesso à tabela `investigation.investigation` deve ser testada **efetivamente**, inclusive via grupos, `PUBLIC`, ownership, funções, sequências e atributos de roles. Ausência de `GRANT` direto não prova ausência de acesso efetivo.

## Verificações antes do SQL exato
1. Inspecionar em transação `READ ONLY` catálogos de schemas, membership, `PUBLIC`, triggers, funções e RLS; conferir migração Q0-only preservada e preexistência do papel-alvo (fail closed).
2. Definir se `created_by` e `change_note` mais um registro transacional são suficientes: por ora, **não há** trilha completa nem chave idempotente persistida. Resolver por alteração mínima aprovada, sem criar Question paralela.
3. Delimitar transação de criação Q0 e proposta Q1: lock da entidade, revisão esperada, atualização controlada, trilha e recibo estável, tratamento de commit incerto. Não reutilizar transação administrativa D0 como endpoint.
4. Planejar provisionamento seguro: credencial não logada nem commitada, TLS, rotação, revogação, session management e recovery; especificar exato grantor e rollback de grants.
5. Autorizar separadamente criação/configuração de role, grants exatos e prova independente com fixture sintética e limpeza; sem automação factual ou pagamento.
6. Apenas após W2 e W1 serem realmente integráveis, solicitar W3 e acesso HTTP restrito.

## Próxima decisão proporcional
Preparar **um pacote SQL de provisionamento W2a com lista exata e checks negativos**, mas condicioná-lo à solução mínima de auditoria/idempotência e escopo de leitura. Não gastar recursos com novos ensaios administrativos Q0→Q1. Os contratos G1/G2/G3 continuam válidos; W1 ainda `HTTP_AND_DURABLE_UOW_PENDING`.

## Invariantes
Marco B aberto, E9 NO-GO, A3 ausente, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`. Nenhum SQL, role, credencial, grant ou Django HTTP foi executado nesta atividade.
