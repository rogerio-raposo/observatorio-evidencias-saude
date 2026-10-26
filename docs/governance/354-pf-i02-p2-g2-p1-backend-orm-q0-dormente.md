# Documento 354 — G2-P1 — Backend ORM Q0 dormente, código somente
Data: 2026-10-26. Autorização: usuário aprovou nominalmente G2-P1 de código somente após Doc.353.
Base: CP311, G2-P0 Doc.353 (READ ONLY concluído), CI anterior 40284472284 165/165 PASS.

## Mudanças
- `question_orm_q0_repository_dormant.py`: mantém os cinco INSERTs Q0 em modelos Django e adiciona planos de leitura via `scoped_current_question`, `request_receipt`, verificação de responsabilidade e locks consultivos por requisição e `question_id`.
- O advisory lock de pergunta usa `oes:question:<question_id>`, alinhado ao experimento SQL anterior; não usa `FOR UPDATE` em `investigation.question`, incompatível com os grants atuais.
- A classe `DjangoQ0Repository` continua rejeitando incondicionalmente a construção tanto com quanto sem alias; **não foi criada factory conectada**, nem associada a settings, URLs ou workflows de escrita.
- Testes offline revisados para conferir rejeição do construtor, identidade dos locks e presença de consultas. Nenhuma conexão em CI.

## Limites
Implementação de código **não é autorização de execução**. `transaction.atomic` conectado, revalidação de escopo com o lock correspondente, integridade transacional de ponta a ponta, grants de identidade runtime, replay conectado, defaults no PostgreSQL e rollback factual não foram demonstrados. Não está apto para app em produção.
Após novos testes, verificar **CI** antes de declarar validação do incremento.
G2-P2 NO-GO; sem Neon adicional, SET ROLE, DML, DDL, roles/grants, HTTP write, deploy, E9 ou usuários reais.

## Estado
`G2_P1_CODE_PREPARED / CI_PENDING / G2_P2_NO_GO / CP311_ACTIVE`.
