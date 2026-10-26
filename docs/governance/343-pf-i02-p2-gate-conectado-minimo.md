# Documento 343 — PF-I02 / P2 — Gate conectado mínimo: decisão de prontidão
**Data:** 2026-10-26. **Natureza:** avaliação documental de prontidão, SEM AUTORIZAÇÃO para execução conectada. **Base:** CP310, Docs.335, 341–342, CI 40277043796 (140/140 PASS).

## Decisão de proporcionalidade
Não ligar Django nem introduzir LOGIN/segredos para resolver uma incerteza que é primeiramente de **SQL e privilégios de bloqueio**. Propor uma sequência curta de gates, com autorização nominal distinta a cada mudança de classe de risco:

**G0 — Fechado nesta avaliação: revisão estática e backlog delimitado.**
1. `SELECT ... FOR UPDATE OF q, ev` em Q1: `oes_qprep_writer` tem UPDATE limitado em `core.entity_version`, **nenhum UPDATE em `investigation.question`**. A suficiência de permissões para `FOR UPDATE OF q` é **não demonstrada e potencial bloqueio**. Não conceder UPDATE amplo para contornar.
2. `FOR SHARE OF q` usado na verificação de acesso/replay e na consulta `current_question` também requer confirmação da semântica de privilégios do PostgreSQL.
3. Dupla leitura versionada Q1: transações devem manter bloqueios relevantes até commit, revalidar versão/responsável, e não permitir que alteração de responsabilidade ocorra entre autorização e persistência.
4. `change_type='normalization_proposed'` é valor livre TEXT no schema, mas sem convenção homologada. A compatibilidade estrutural não prova semântica institucional.
5. O replay lê recibo e exige escopo vigente, mas não confirma por UUID a versão referenciada; reservar revisão antes de produção.
6. Unicidade global de `oes_id` deve gerar erro sanitizado e rollback, sem consulta não autorizada de entidade de terceiros.

**G1 — Se explicitamente aprovado depois: catálogo READ ONLY focal.** Consultar *somente metadados* de tabelas/índices/constraints e privilégios de UPDATE/SELECT dos objetos usados pelos locks na branch sintética já delimitada. Proibido consultar linhas de Questions/recibos, SQL de escrita, SET ROLE e credenciais. G1 não confirma permissões efetivas por tentativa de lock.

**G2 — Se e somente se G1 justificar autorização separada: ensaio conectado sintético mínimo.** Exige credencial/identidade de execução explicitamente autorizada, uma transação de alterações sintéticas delimitada, rollback/cleanup comprovados, escopo de casos/UUIDs fixos, erros sanitizados e proibição de usar owner como runtime. O role NOLOGIN atual não habilita conexão como aplicação; não inventar solução temporária com privilégios maiores. Se G2 não puder operar sem ampliar privilégios, HOLD e decisão arquitetural.

**G3 — Diferido:** Django connected UoW, HTTP de escrita, contas reais, isolamento multiusuário, E9 e deploy; todos fora do gate atual.

## Critério decisório
O próximo passo útil não é novo código Q0/Q1 nem repetição dos 140 testes offline. É **uma autorização G1 delimitada** para verificar o catálogo, se o usuário assim decidir. Qualquer resultado negativo mantém HOLD sem grants automáticos. O gate deve priorizar segurança, custo zero e aproveitamento de frameworks existentes na stack definitiva.

## Estado
`G0_DOCUMENTARY_READY / G1_SEPARATE_APPROVAL_REQUIRED / CONNECTED_NO_GO`.
CP310 vigente; Marco B aberto; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; readiness NOT_READY; Fase 5 NOT_STARTED; A3 ausente e E9 NO-GO.
