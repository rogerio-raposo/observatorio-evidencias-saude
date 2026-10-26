# Documento 350 — PF-I02/P2 — Suficiência e menor incremento transacional Django-first
**Data:** 2026-10-26. **Base:** CP311, Doc.347–349; CI 40282697352 SUCCESS 150/150 no SHA `80dad29fbfe60b4e227b815619fc680fd73370b0`. **Escopo:** análise estática somente; nenhum SQL conectado, migração, alteração de credenciais, concessão de privilégios ou ativação de writer.

## Diagnóstico de suficiência
O mapeamento `models.py` e o blueprint `question_orm_transaction_offline.py` **compilam** consultas, mas não as avaliam ou convertem em gravações. A consulta `scoped_current_question` foi corrigida para localizar `question_version` pela dupla `(entity_uuid,version_uuid)` e expor `q0_original_text`; ainda não existe orquestrador ORM capaz de comparar o original com o comando em transação real.

Requisitos ausentes para a primeira implementação transacional: (1) registrar os quatro registros Q0 e recibo na mesma `atomic`; (2) Q1 com leitura e revalidação sob mesma transação, atualização condicional da versão corrente, criação da próxima versão e seu detalhe e recibo; (3) replay com verificação atual do escopo, fingerprint e conflito sanitizado; (4) ordem de lock de request/pergunta e protocolo cooperante de responsabilidade; (5) handling de `IntegrityError`, rollback e resultado de commit incerto, sem retry cego.

## Riscos de mapeamento previamente à execução
- `managed=False` só impede gerenciamento da tabela por migrations: **não impede escrita do ORM**. A política fail-closed exige ausência de alias writer no estado atual e checagem de autorização em camada de aplicação e banco.
- Os modelos não representam todos os DEFAULTs PostgreSQL como `db_default`; em futuros INSERTs ORM deve-se verificar geração de colunas com defaults do servidor (por exemplo `created_at`, `valid_from`, `committed_at`), evitando envio explícito indevido de NULL. Testar SQL de INSERT offline antes de qualquer execução.
- Chaves estrangeiras compostas e trigger de `entity_type` permanecem no banco; sem garantias equivalentes automáticas no ORM. No ledger, PK composta é preservada, mas recibo não verifica em FK própria a igualdade `question_id=core.entity.oes_id`.
- O SQL de UPDATE condicional do ORM deve manter filtro de `version_uuid`, `entity_uuid`, número, status e `valid_to IS NULL`; `rowcount==1` obrigatório.
- Uma consulta filtrada por responsável não prova ausência global de um `oes_id`. A unicidade global do banco deve resolver colisão sem revelar entidades externas.
- Um SELECT compilado isoladamente não demonstra a semântica de locks PostgreSQL, privilégios UPDATE para `FOR UPDATE`, nem transação real.

## Incremento mínimo recomendado
**Única Unit of Work Django-first**, aproveitando `QuestionCommand`, fingerprint e regras existentes, com operações `register_q0`, `propose_q1`, `find_receipt`, `can_access_question` e `save_receipt`, sob fronteira `transaction.atomic(using=approved_alias)` somente quando autorizada. Priorizar modelos Django, queries explícitas apenas para advisory lock quando demonstrado necessário. Não duplicar o adaptador SQL experimental como backend permanente.

**Pré-G2:** codificar testes offline que validem geração de INSERT/UPDATE e fronteira de atomicidade sem invocar conexão; se a implementação não puder ser provada sem escrever no banco, manter HOLD e pedir gate próprio. **G2 NÃO AUTORIZADO**; sem identidade runtime, SQL conectado, HTTP write ou deploy.

## Conclusão
`DJANGO_FIRST_MINIMUM_TRANSACTIONAL_SCOPE_DEFINED / ORM_WRITER_UNIMPLEMENTED / G2_NO_GO`.
CP311 vigente; Marco B aberto; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; readiness NOT_READY; Fase 5 NOT_STARTED; E9 NO-GO; A3 ausente e sem pesquisadores vinculados.
