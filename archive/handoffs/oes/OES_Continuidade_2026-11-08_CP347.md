# CP347 — OES | Continuidade Q0 geral e decisão de autorização administrativa

**Data:** 2026-11-08 (America/Recife).  
**Estado:** checkpoint documental de continuidade, sujeito à publicação na `main`.  
**Antecessor:** [CP346](OES_Continuidade_2026-11-07_CP346.md) preservado como histórico.  
**Referência canônica verificada antes deste registro:** `main` `484b49b1c956f3e4078af44025d1b8c82602dd4e`.  
**Decisão determinante:** [autorização administrativa da primeira tentativa sintética](../../../docs/governance/OES_Q0_PRIMEIRO_ENSAIO_PERSISTENTE_AUTORIZACAO_ADMINISTRATIVA_2026-11-08.md).

## 1. Estado consolidado desde CP346

- PRs [#22](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/22), [#23](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/23) e [#24](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/24): composição D1/D2/D3 integrada, sem abertura da escrita operacional.
- PR [#25](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/25): preparação sintética excepcional one-shot dormente, **fora do caminho crítico**.
- PR [#26](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/26): entrada REGISTER_Q0, formulário Django, rota e testes integrados; métodos HTTP mutantes retornam 423.
- PR [#27](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/27): prontidão de construção ORM restrita pós-preflight/xid e recuperação D3 READ ONLY isolada, mantendo bloqueios por fonte.
- PR [#28](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/28): configuração isolada auth/reader READ ONLY, CLI de atestação de metadados e workflow manual integrados; `main` SHA `484b49b1c956f3e4078af44025d1b8c82602dd4e`.
- Neon experimental: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`; inspeções conectadas somente SELECT confirmaram PostgreSQL 18.6, identidades efetivas e privilégios requeridos dos papéis `oes_auth_trial_login`, `oes_pg_a4_reader` e `oes_qprep_login`. Nenhuma gravação durante o preflight.
- GitHub Actions [#42483719306](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42483719306): atestação Django READ ONLY via `workflow_dispatch`, `run_attempt=1`, SHA `484b49b1c956f3e4078af44025d1b8c82602dd4e`, preflight SUCCESS e `readonly-attestation` SUCCESS; marcador `Q0_DJANGO_RO_ATTESTATION_PASS`. Comprova metadados de conexões Django, **não** persistência Q0.
- Autorização para esse despacho concluída em uma run; **não foi confirmada exclusão das variáveis temporárias** `OES_Q0_DJANGO_RO_APPROVED_SHA` e `OES_Q0_DJANGO_RO_AUTHORIZATION`. Verificar antes de nova operação.

## 2. Decisão de governança expressamente aprovada

O responsável **dispensou apenas para o primeiro ensaio sintético persistente Q0** a exigência de consumo **atômico e durável** da autorização de uso único. Em lugar dela, aprovou uma **única tentativa manual supervisionada**, com autorização operacional nominal vinculada ao SHA e a manifesto imutável, sem reexecução automática, com reconciliação independente D3 e revogação posterior das variáveis temporárias. O risco residual de uma segunda execução administrativa antes da revogação foi **explicitamente aceito** e não deve ser ocultado ou descrito como exactly-once.

Ver decisão integral: [registro de governança](../../../docs/governance/OES_Q0_PRIMEIRO_ENSAIO_PERSISTENTE_AUTORIZACAO_ADMINISTRATIVA_2026-11-08.md).

**Essa aprovação é metodológica/documental, NÃO é autorização para execução PostgreSQL ou ativação de gate.** A autorização operacional específica para o primeiro commit ainda não foi dada.

## 3. Estado do incremento Codex ainda local

- Branch local: `codex/oes-q0-general-first-persistent-commit`, com base `484b49b1c956f3e4078af44025d1b8c82602dd4e`.
- Primeira versão: três arquivos novos (CLI restrito, workflow manual, testes), **124 testes PASS relatados pelo Codex (14 novos)**, sem conexão, commit Git ou PR.
- Manifesto sintético reservado `reserved-manifest.json` foi enviado na conversa; **não se encontra persistido no repositório por este checkpoint**; não presumir disponibilidade de seus identificadores na próxima conversa. Preservar valores exatos por referência ao trabalho local do Codex; não inventar ou regenerar.
- Revisão independente concluiu: integração inicial NÃO recomendada na forma recebida, devido à falta de vínculo verificável entre autorização operacional e construção ORM restrita, além da dependência desnecessária de consumo durável.
- Instrução entregue ao responsável para correção pelo Codex **na mesma branch**, aproveitando composição canônica D1/D2/D3 e mantendo HTTP 423. A versão corrigida ainda não foi recebida nem revisada.

## 4. Próximo passo sem retrabalho

1. Receber patch incremental corrigido e relatório de testes/gates da mesma branch Codex; executar Freshness Gate contra `main`.
2. Revisar isolamento da ativação ORM restrita, SHA/manifesto/contexto administrativo, recuperação sem writer, idempotência, preflight/xid, no retry e preservação de HTTP 423.
3. Não exigir mecanismo novo de consumo durável; a decisão do item 2 já foi tomada. Não incorporar executor paralelo do PR #25.
4. Se tecnicamente satisfatório, avaliar publicação e merge do incremento com controles proporcionais e autorização delimitada; **separar de qualquer autorização de despacho conectado**.
5. Futuro ensaio de commit, somente com nova autorização operacional nominal, parâmetros verificados, disponibilidade de credenciais, janela supervisionada, reconciliação D3 e plano de revogação.

## 5. Acordos de trabalho e limites

ChatGPT coordena, revisa e registra; Codex implementa/testa em ambiente isolado; GitHub `main` é fonte canônica. Atualização de software deve passar por patch/testes, PR verificado e merge autorizado. O responsável aceitou **uma autorização única e condicional para publicação + merge** de um incremento offline já revisado, desde que diff, SHA e gates permaneçam correspondentes; diante de divergência material, interromper e pedir nova decisão. Isso não unifica autorizações operacionais conectadas.

`Prossiga` não autoriza SQL conectado, dispatch, novos grants/secrets, ativação HTTP ou deploy. Sem pesquisadores reais, sem dados reais, sem serviços pagos.

**Gates:** Marco B OPEN; Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY. CP346 e documentos anteriores permanecem históricos, não substituídos em conteúdo.
