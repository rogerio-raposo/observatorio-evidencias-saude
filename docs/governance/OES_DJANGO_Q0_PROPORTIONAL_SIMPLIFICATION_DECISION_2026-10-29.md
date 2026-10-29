# OES — Decisão de simplificação proporcional do ensaio Django–Q0

Data: 2026-10-29. Base comprovada: 296/296 testes offline PASS (Actions 40962844354), identidade sintética em sessão Neon READ ONLY PASS (Actions 40962343481). Os controles adicionais publicados depois disso ainda não têm CI posterior confirmado.

## Problema identificado

Foi introduzida complexidade desproporcional para controlar um único ensaio sintético reversível. O sistema passou a depender de um marcador Git, regras de proteção de tags e separação de jobs apenas para obter unicidade técnica estrita, apesar do objetivo original ser comprovar cinco INSERTs ORM transitórios seguidos por ROLLBACK e reconciliação READ ONLY. Isso atrasa a evidência que interessa e cria novas superfícies de erro.

## Decisão de escopo

1. **Não usar** `q0_single_use_git_ref_gate.py` no caminho operacional. Mantê-lo inerte, sem executar sua função de consumo; nenhum tag deve ser criado. Não é necessário apagá-lo neste incremento.
2. **Não ampliar** mais o aparato de workflows, branches, rulesets ou grants. A restrição de uma única tentativa será operacional: um único despacho manual nominal e sem retry; registrar explicitamente o risco residual de repetição administrativa, em vez de afirmar garantia matemática.
3. Usar o candidato isolado `scripts/q0_rollback_transaction_candidate.py` como **única base a integrar**, não o script histórico `run_q0_rollback_once.py`. O último contém ator sintético literal `oes_synthetic_q0` e não representa o vínculo persistido que já foi comprovado no Neon; permanece legado bloqueado por controles próprios. Não reativá-lo.
4. Proveniência: derivar `oes:actor:<uuid>` da consulta READ ONLY `preparer_identity.synthetic_service_readonly.attest_synthetic_identity_readonly()`, sem parâmetro externo, e passar o mesmo ator à preparação canônica do trial. A função não deve ser confundida com login Django de usuário real.
5. Uma transação no alias escritor experimental, **cinco INSERTs ORM**, `transaction.atomic(..., savepoint=False)`, `set_rollback(True)` obrigatório, nenhum commit científico, e reconciliação após fechamento do escritor em alias leitor independente. Fail-closed para falha ou incerteza.
6. Antes de executar: revisar o ponto de entrada isolado e sua disponibilidade de credenciais, fixar o SHA do código revisado, comprovar CI e verificar se qualquer segredo transitório existe. Não declarar pronto só porque o módulo interno já contém INSERTs.
7. Sem alterações em roles, grants, produção, migrations, HTTP, E9, fase 5 ou objetos reais. Sem repetir provisioning ou readbacks já comprovados.
8. Autorização nominal anterior permanece circunscrita a **uma execução sintética rollback-only**, ainda não consumida. A aceitação de risco residual não autoriza expansão de escopo.

## Critério objetivo de saída

Um único log GitHub Actions com SHA revisado, identidade experimental verificada, contagem 5/5 dentro da transação, ROLLBACK executado, leitor independente atestando zero resíduos, classificação PASS ou HOLD e nenhuma reexecução automática. Um FAIL não autoriza repetição. Se não for possível provar a ausência de commit, o resultado será HOLD.

## Estado nesta decisão

Nenhum INSERT conectado realizado neste incremento, nenhuma referência Git consumida, nenhum workflow escritor habilitado. O marco B continua OPEN, executor Q0 geral HARD HOLD, E9 NO-GO, Fase 5 NOT_STARTED. CP343 permanece checkpoint histórico até atualização separada dos ponteiros.
