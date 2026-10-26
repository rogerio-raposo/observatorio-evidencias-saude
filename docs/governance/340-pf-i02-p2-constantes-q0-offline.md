# Documento 340 — PF-I02-P2: reconciliação de constantes canônicas de Q0 (OFFLINE ONLY)
**Data:** 2026-10-26. **Base:** CP308, Doc.339, `database/poc-s1.sql`, `database/f3-real-case-01-dcbti.sql`, Docs.309/319/326. **Sem autorização para SQL conectado, DML, grants ou escrita HTTP.**

## Constantes fundamentadas no repositório
- `core.entity.entity_type = 'Question'`: trigger `tr_question_entity_type` em `database/poc-s1.sql` exige exatamente `Question`; fixture versionada `database/f3-real-case-01-dcbti.sql` insere `Question`.
- `core.entity_version.version_status = 'current'`: permitido pelo CHECK no schema `database/poc-s1.sql`, usado na fixture; Doc.319 registra Q0 versão 1 current e Q1 versão 2 current após superseder a primeira.
- `core.entity_version.change_type = 'initial'`: valor efetivamente usado para versão 1 na fixture; o schema impõe apenas NOT NULL, logo **convenção empírica, não enumeração obrigatória por constraint**.
- `investigation.question_version.preparation_stage='q0_draft'`, `normalized_text=NULL`, `original_text` literal: alteração verificada Doc.317 e ensaio Doc.319.
- Identificadores de entidade e versão: UUIDs distintos e vinculados de ponta a ponta, geração proposta no adaptador via `uuid.uuid4()` com mocks determinísticos, **sem envolver banco**; não afirmar que método de geração foi homologado institucionalmente.

## Transação e conflitos — riscos remanescentes
1. A factory injetada entrega apenas context manager de cursor; não há prova no contrato atual de que gerencia uma única transação atômica com rollback em qualquer exceção e commit único. Exigir essa propriedade como pré-condição para conectividade; fake com efeito de rollback nos testes.
2. `current_question` filtra por responsável: nunca tratar `None` como prova de inexistência global de `oes_id`. A chave UNIQUE no banco é barreira final, com tratamento de violação sem divulgação do registro alheio.
3. `register_q0` deve inserir nas quatro tabelas; `save_receipt` na quinta tabela **no mesmo contexto transacional**, com `responsible_actor_id=actor_id`. Métodos não serão acionáveis conectadamente sem gate de escrita.
4. `change_type='initial'` é precedente concreto mas a semântica futura de outras transições continua em revisão.
5. Reforçar restrição de validação dos parâmetros (identificadores, UUID, fingerprint e estado); não extrapolar escopo W1 para usuários reais.

## Decisão técnica proposta
As três constantes deixam de ser pendência indeterminada: podem ser usadas na implementação **offline** de Q0 com testes parametrizados. Ainda não há autorização para executar qualquer INSERT real. `register_q0` e `save_receipt` permanecem HOLD na versão corrente até implementação/testes e revisão do isolamento de conexão.

Marco B aberto; readiness NOT_READY; Fase 5 NOT_STARTED; E9 NO-GO; CP308 até próximo checkpoint.
