# OES — Auditoria do marcador Git de tentativa única

Data: 2026-10-29. Evidência anterior: CI 296/296 PASS em Actions 40962844354; atestação de identidade conectada READ ONLY PASS em 40962343481.

## Resultado: NO-GO para consumo operacional

O mecanismo de `refs/tags/oes-q0-rollback-single-attempt-20261029` foi testado offline, mas **não foi criada a referência** e não foram verificados os rulesets efetivos nem as permissões de exclusão do repositório. A ferramenta GitHub atualmente disponível nesta sessão não oferece leitura de rulesets ou das configurações de tag. A tentativa de consultar a API pública não forneceu resposta acessível. Portanto, não afirmar que a referência está protegida.

Uma criação condicional com nome fixo barra repetições enquanto a referência existe; **não é proteção contra remoção posterior, mudança de regras ou bypass administrativo**. O simples `contents: write` pode ter direitos além do necessário. `concurrency` só serializa.

## Procedimento para auditoria por administrador (sem alterações)

1. Abrir GitHub > repositório > Settings > Rules > Rulesets; observar regras aplicáveis a tags, enforcement ativo e eventuais bypasses. Registrar evidência do estado aplicado especificamente ao nome `oes-q0-rollback-single-attempt-20261029`.
2. Confirmar que nenhuma identidade ou token disponível no job operacional consegue excluir/atualizar a referência após sua criação e que o job escritor científico não possui `contents: write`. Se a regra também impedir a criação inicial, o mecanismo fica NO-GO.
3. Verificar quem pode modificar/desabilitar a regra ou executar um workflow revisado, incluindo rerun. Registrar limitação administrativa residual.
4. Separar jobs: pré-verificações READ ONLY; job consumidor sem segredos de banco, com permissão mínima de criação da referência; job transacional sem capacidade de alteração de referências. A passagem entre jobs deve provar o consumo ligado ao mesmo run/attempt e SHA aprovado, e falhar fechado para re-run, corridas ou resultado incerto.
5. Uma resposta 201 por si só não comprova perpetuidade; qualquer erro ou incerteza após solicitação de criação consome a possibilidade de nova tentativa sem conciliação externa explícita. Não repetir automaticamente.

## Decisão proporcional

**Não criar tag, não mudar proteções e não habilitar credenciais nem DML neste incremento.** O candidato de consumo único permanece inerte. A próxima atividade é comprovar efetivamente as proteções do repositório e só então integrar o controle com isolamento de credenciais. Não expandir novamente a suíte offline sem necessidade.

Marco B OPEN; Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED; CP343 vigente. A autorização nominal anterior permanece não consumida.
