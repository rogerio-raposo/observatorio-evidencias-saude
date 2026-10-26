# OES — CP307 | Política sintética de responsabilidade aprovada
**Data:** 2026-10-26. **Anterior:** CP306.

## Decisão nova
Documento 336 registra aprovação expressa `PF-I02-P2-A5 / SYNTHETIC_SINGLE_RESPONSIBLE_POLICY_ONLY`. Criador de Q0 é responsável inicial apenas no laboratório sintético; Q1 e replay exigem revalidação da responsabilidade vigente e permissão geral. Revogação impede novas operações/replay, mas preserva ledger imutável. Sem delegação, atribuição coletiva ou política institucional de pesquisadores; ator do ledger não é autorização vigente.

## Evidência herdada
CP306: CI Django offline [40271463247](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40271463247), 109/109 PASS (9 P2). Adaptador SQL ainda parcial e fail closed. W2a role/ACL encerrado estritamente; Neon sandbox contém role NOLOGIN e grants aprovados. Não converter resultado offline em prova conectada.

## Limites
A política aprovada não autorizou Neon, SQL, catálogo conectado, DDL/DML, mudanças em papel/grants, LOGIN, credenciais, integração HTTP ou E9. Não há fonte de responsabilidade persistente confirmada; `investigation.question` é hipótese de localização, não campo verificado. Ausência de RLS impede alegar segregação multiusuário. Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Marco B aberto; readiness NOT_READY; Fase 5 NOT_STARTED; A3 ausente; não há pesquisadores vinculados.

## Ponto exato de retomada
Aplicar Freshness Gate. Solicitar **aprovação nominal específica para preflight de catálogo READ ONLY no Neon sandbox** visando localizar coluna/relação de responsabilidade em Question (sem dados de linhas/usuários) e definir se há necessidade de DDL. Não executar inspeção conectada somente com `Prossiga`. Sem autorização, continuar somente análise documental/offline.
