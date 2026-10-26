# Documento 326 — PF-I02: especificação implementável do ledger e Unit of Work Q0→Q1

**Data:** 2026-10-26. **Estado:** `DESIGN_READY_FOR_OFFLINE_IMPLEMENTATION_REVIEW`; não autoriza DDL/DML, criação de papéis, grants, uso de credenciais, ativação HTTP ou deploy. **Base:** CP300, Docs. 319, 321–325 e `evidence/question_preparation.py`.

## Decisão de simplificação
Reutilizar `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e o `QuestionCommand` já existente. Acrescentar **um** ledger transacional mínimo, sem segundo repositório de perguntas. Não reproduzir os ensaios administrativos Q0→Q1 já encerrados.

## Contrato do ledger (candidato SQL para revisão, NÃO EXECUTAR)
```sql
-- REVIEW ONLY — require separate schema/role approval
CREATE TABLE investigation.question_command_receipt (
    actor_id text NOT NULL,
    request_id text NOT NULL,
    fingerprint_sha256 char(64) NOT NULL,
    question_entity_uuid uuid NOT NULL REFERENCES investigation.question(entity_uuid),
    question_id text NOT NULL,
    resulting_version_uuid uuid NOT NULL REFERENCES core.entity_version(version_uuid),
    resulting_version_no integer NOT NULL CHECK (resulting_version_no > 0),
    command_kind text NOT NULL CHECK (command_kind IN ('REGISTER_Q0', 'PROPOSE_Q1')),
    committed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, request_id),
    CHECK (length(actor_id) > 0 AND length(request_id) > 0)
);
```

Somente recibos de comandos **confirmados na mesma transação** de escrita entram no ledger. Falhas negadas pré-commit têm registro de segurança sanitizado fora da tabela, conforme política posterior; não criar estado `pending` que sobreviva sem comando correspondente. O recibo deve ser imutável para o runtime: permitir INSERT/SELECT estritamente necessários e negar UPDATE/DELETE. `request_id` é de escopo do ator, nunca confiado como autorização. Retorno ao usuário contém somente `PREPARATORY_ONLY`, ID da pergunta, versão e referência de recibo autorizada; não retorna conteúdo bruto.

## Algoritmo da Unit of Work persistente
1. Validar usuário/sessão/permissão **antes** de conexão; validar campos, `request_id`, `question_id`, `expected_version` e fingerprint canônico W1; a autoria é derivada da sessão, nunca enviada no formulário.
2. Iniciar **uma** transação PostgreSQL com timeouts curtos. Serializar operações pela chave `(actor_id,request_id)` com mecanismo bloqueante transacional apropriado (por exemplo, lock consultivo transacional derivado sem colisões práticas, ou tentativa protegida por unique + conflito seguido de consulta segura); declarar o algoritmo escolhido antes do código. Duas requisições com mesma chave não podem executar duas escritas.
3. Consultar recibo existente: mesma fingerprint => recuperar recibo anterior, sem nova versão; fingerprint diferente => conflito sanitizado sem escrita. A verificação de permissão e escopo é obrigatória também para replay.
4. `REGISTER_Q0`: exige `expected_version=0` e `normalized_text IS NULL`; atribuir UUIDs no servidor, reservar ID OES único; inserir `core.entity`, `investigation.question`, `core.entity_version` versão 1, `investigation.question_version` `q0_draft` com Q0 literal. Não inventar Q1.
5. `PROPOSE_Q1`: exigir Q1 não vazia, justificativa, `expected_version>0`, e escopo autorizado da pergunta; bloquear `core.entity` por `FOR UPDATE`, comparar versão corrente, preservar Q0 byte/text exact, marcar versão anterior superseded e criar nova versão `current`, `q1_proposed`, vinculada por `supersedes_version_uuid`. Conflito obsoleto => sem escrita.
6. Inserir recibo na mesma transação com fingerprint, autor, IDs, versão resultante, tipo e timestamp. **Commit único**. Não armazenar Q0/Q1 no ledger.
7. Se confirmação de commit for incerta: `HOLD`; **não repetir automaticamente**. Reconciliação posterior apenas por consulta autorizada `(actor_id,request_id)` e fingerprint, distinguindo committed/absent/indeterminate.
8. E9, `investigation.investigation*`, produtos e captura fora do grafo de comandos; nenhum fallback para `oes_sandbox_owner`.

## Fronteira de leitura
A aplicação verifica autorização para o ID e para o ator antes de qualquer leitura ou replay. Isso **não prova isolamento no banco** se o papel técnico possuir SELECT amplo; enquanto não houver política DB validada, o piloto permanece sintético, restrito e com no máximo um preparador controlado. Ampliar para múltiplas pessoas exige decisão de RLS ou API SQL delimitada, com testes de leitura cruzada e anti-spoofing. O documento 324 não está homologado como grants runtime.

## Matriz de testes de aceite (ainda não executados)
- Anônimo/sem permissão: nenhuma conexão e nenhuma escrita.
- Q0 literal preservada; Q1 gera versão 2 sem mutação Q0; apenas um `current`.
- Duplo envio idêntico: mesmo recibo/versão, sem duplicidade; fingerprint divergente com mesmo request_id: conflito.
- Duas Q1 sobre a mesma versão: uma confirma, outra conflito; falha durante transação: rollback integral.
- Confirmação pós-commit perdida: HOLD e reconciliação por recibo; sem retry automático.
- Tentativa de acessar outra Question, solicitar E9, alterar `created_by` ou usar papel owner: negadas.
- Efeitos da DDL/trigger, privilégios negativos e limpeza de fixture sintética verificados apenas em gate conectado explicitamente autorizado.
- Regressões PF-I01/Django e nenhum dado clínico/factual externo.

## Ajustes necessários antes da execução
O contrato W1 já calcula fingerprint e valida recibo simples; a implementação precisa distinguir `REGISTER_Q0` de `PROPOSE_Q1`, validar `request_id` por limites/formato e garantir a semântica de replay com `expected_version` original. `user.pk` deve corresponder a identidade autenticada persistente, nunca `Mock` fora de testes. Definir concessão da permissão `evidence.prepare_question` real e armazenagem de sessões sob infraestrutura aprovada. A coluna `created_by` isolada não substitui auditoria da operação.

## Próxima atividade proporcional
Preparar **código offline da Unit of Work com porta PostgreSQL injetada e testes de transação simulada, incluindo ledger**, a partir desta especificação; não habilitar o endpoint ou criar schema até aprovação específica. Isso encerra a subdivisão de desenho e permitirá revisar SQL de W2a com as permissões definitivas para o ledger.

**Invariantes:** CP300 até atualização canônica, Marco B aberto, E9 NO-GO, A3 ausente, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
