# OES — Decisão de governança sobre a autorização do primeiro ensaio persistente Q0

**Data:** 2026-11-08 (America/Recife).  
**Status:** decisão expressamente aprovada pelo responsável nesta conversa; registrada para continuidade, **não é autorização operacional de execução**.  
**Escopo:** somente o **primeiro ensaio sintético de commit persistente Q0 geral** na branch experimental Neon já delimitada.  
**Base canônica de referência nesta documentação:** `484b49b1c956f3e4078af44025d1b8c82602dd4e`.  
**Documentos anteriores:** CP346, Documento 362 e estratégia ChatGPT–Codex–GitHub, preservados.

## 1. Decisão aprovada

Exclusivamente para o primeiro ensaio sintético persistente do Q0 geral, **não se exige consumo atômico e durável da autorização operacional**. Em substituição, exige-se controle administrativo por autorização nominal, vinculada ao SHA exato e a um manifesto sintético previamente revisado, para **uma única tentativa manual supervisionada**, sem reexecução automática. Toda interpretação de resultado exige reconciliação independente D3 e preservação de evidências.

O responsável aceita expressamente que essa forma de controle **não impede tecnicamente** um segundo despacho enquanto a autorização administrativa continuar configurada. Não descrever a propriedade como *exactly-once* ou uso único técnico. Assegurar exclusão das variáveis temporárias após a execução por procedimento operacional próprio; não pressupor exclusão antes de confirmação.

A decisão não representa exceção à idempotência do Q0, à transação PostgreSQL, ao recibo, à autenticação, ao princípio do menor privilégio, à reconciliação independente ou ao tratamento fail-closed. Esses controles permanecem obrigatórios e independentes.

## 2. Controles obrigatórios do eventual primeiro ensaio

- Autorização operacional **separada e posterior**, nominal e vinculada ao SHA imutável aprovado, ao repositório/branch, banco experimental, modo, identidade sintética e manifesto fixo.
- Despacho manual `workflow_dispatch`; execução limitada administrativamente à primeira tentativa (`run_attempt=1`), sem `Re-run jobs` ou retry automático.
- O manifesto não pode receber novos `request_id`, `question_id`, texto ou fingerprint após autorização; mudança exige revisão/decisão nova.
- Revisão da ativação **restrita** da construção ORM canônica, de maneira que o construtor geral permaneça bloqueado fora do ensaio e não exista via HTTP de escrita.
- Identidade persistida, preflight de sessões e privilégios, fronteira transacional, captura do xid e cinco registros Q0 pela composição canônica D1/D2/D3.
- Reconciliação D3 independente e classificação `PERSISTED`, `ABSENT` ou `INDETERMINATE`, sem transformar ausência de recibo ou timeout em sucesso/ausência; se incerto, HOLD e **nenhuma segunda tentativa automática**.
- Retirada das variáveis temporárias de aprovação após a execução e verificação/registro documental do encerramento da janela operacional.
- O controle administrativo **não é** mecanismo técnico de impedir concorrência ou reuso; esse risco residual é conscientemente aceito somente neste ensaio isolado.

## 3. Limites expressos

**Não autorizado por esta decisão:** conexão ou INSERT PostgreSQL; despacho; alteração de credenciais, roles, grants, migração ou secrets; liberação do construtor ORM geral; ativação do HTTP POST Q0 (permanece 423); abertura de E9, Fase 5, deploy, dados reais ou extensão a pesquisadores. Não reativar o executor excepcional do PR #25 nem criar outro mecanismo paralelo de autorização.

A recuperação READ ONLY D3, caso exigida operacionalmente, terá escopo e autorização próprios; não se confunde com a permissão de escrita.

## 4. Distinguir os três controles

| Controle | Finalidade |
| --- | --- |
| Aprovação operacional de tentativa única (administrativa) | Limitar o despacho humano a um ensaio autorizado, sem garantia técnica de consumo único |
| Idempotência Q0 (request ID, fingerprint e recibo) | Proteger a integridade e evitar duplicação lógica na persistência |
| Reconciliação independente D3 | Classificar evidência pós-transação, inclusive perda de confirmação, sem retry ou promoção indevida |

O controle administrativo não substitui os outros dois.

## 5. Continuidade do desenvolvimento

Codex preparou localmente `codex/oes-q0-general-first-persistent-commit` com três arquivos novos (CLI, workflow manual e testes), 124 testes PASS relatados, incluindo 14 novos; **não houve commit Git nem publicação** desse patch. A primeira versão permaneceu bloqueada por fonte porque não vinculou suficientemente autorização administrativa à construção ORM restrita e exigia consumo durável. O responsável encaminhou ao Codex instruções para **corrigir a mesma branch**, preservando a composição canônica e dispensando somente a garantia de consumo durável.

A revisão independente deverá exigir patch/diff completo, testes, avaliação dos gates, invariantes e ausência de alternativa de persistência. Publicação/merge de software dependem de decisão apropriada; **nenhum despacho conectado ou liberação de escrita deriva da aprovação documental**.

## 6. Evidência conectada antecedente

Atestação Django Q0 READ ONLY no GitHub Actions [#42483719306](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42483719306), em `484b49b1c956f3e4078af44025d1b8c82602dd4e`, execução 1, preflight e diagnóstico **SUCCESS**, marcador `Q0_DJANGO_RO_ATTESTATION_PASS`. Verificações de alias e metadados READ ONLY **não** equivalem a commit Q0 real.

A exclusão das variáveis da atestação `OES_Q0_DJANGO_RO_APPROVED_SHA` e `OES_Q0_DJANGO_RO_AUTHORIZATION` foi recomendada, **mas não está confirmada pelo responsável neste registro**. Não afirmar revogação concluída sem evidência.

**Gates preservados:** Marco B OPEN; Q0 geral HARD HOLD; E9 NO-GO; Fase 5 NOT_STARTED; Fase 4 encerrada apenas metodológica/documentalmente.

**STOP:** documento de governança, não autorização para gravação ou despacho.
