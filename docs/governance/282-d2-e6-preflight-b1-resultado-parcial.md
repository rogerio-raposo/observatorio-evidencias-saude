# Documento 282 — Resultado parcial do pré-voo B1 somente leitura

**OES | 2026-10-24 | HEAD-base `57da9e3bcaf001372678440cce1c4bb1df4cfb8c` | Etapa B1 autorizada / B2 não autorizada**

## Autorização e escopo

O proprietário autorizou explicitamente `STAGE_B_READ_ONLY_PREFLIGHT_ONLY` na branch Neon experimental `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, sem alterações de papéis, credenciais, gravação, acesso a `raw_payload`, GET factual ou desbloqueio de workflow.

## Execução e observações

Foram apresentadas seis consultas independentes ao conector Neon, todas restritas a metadados e cardinalidade:

- Identificação de banco e identidade da sessão: **bloqueada pelas configurações de segurança da ferramenta**, sem retorno SQL.
- Metadados básicos dos papéis `oes_e6_capture_login`, `oes_e6_writer`, `oes_e6_verifier`: **bloqueada**, sem retorno.
- Associações de papéis em `pg_auth_members`: **bloqueada**, sem retorno.
- Privilégios de USAGE/INSERT/SELECT na tabela privada: **bloqueada**, sem retorno.
- Catálogo de colunas de `oes_raw_private.source_observation`: **bloqueada**, sem retorno.
- `SELECT count(*)::integer AS synthetic_private_rows FROM oes_raw_private.source_observation`: **retorno efetivo `synthetic_private_rows=0`**.

Não atribuir as cinco rejeições a uma negação SQL de privilégio: foram bloqueios anteriores à execução pela ferramenta. Os registros anteriores nos Documentos 271–276 permanecem históricos, mas não substituem nova confirmação de ACL.

## Conclusão e decisão

**B1 parcial:** tabela privada vazia confirmada, mas identidade, relações de papéis, catálogo e ACL **não verificados nesta atividade**. Não é seguro declarar o ensaio positivo B2 pronto. Não contornar bloqueios nem reativar credenciais como alternativa.

**Estado:** `B1_PARTIAL / PRIVATE_ROWS_ZERO / ACL_NOT_REVERIFIED / B2_NOT_AUTHORIZED / E6_G1_BLOCKED`.

**STOP — aguardar decisão sobre como obter evidência de ACL por via autorizada, mantendo B2 bloqueada.**

## Disposição técnica proporcional após revisão documental

A revisão dos Documentos 271, 272 e 276 encontrou evidência histórica suficiente de constraints, testes ACL negativos com roles efetivas e limpeza das memberships temporárias, além de desativação comprovada do login de captura. **Não repetir a bateria histórica para resolver apenas a limitação atual da ferramenta.** O ponto ainda não verificável é a configuração **presente** de ACL/roles, e sua eventual mudança desde esses registros, antes de qualquer ensaio positivo.

Encaminhamento mínimo: obter confirmação contemporânea **somente leitura** por via aprovada e controlada pelo proprietário (por exemplo, consulta pontual de metadados no SQL Editor, sem senha, sem payload e sem resultados sensíveis). Se obtida, registrar apenas as propriedades necessárias: LOGIN desabilitado, membership do login ausente, writer INSERT/sem SELECT, verifier SELECT/sem INSERT e USAGE adequado no schema, identificando branch e banco. Não há necessidade de nova identidade, objeto, grants ou secrets para essa constatação. Caso não seja possível verificar por via permitida, manter `B1_PARTIAL` e `B2_NOT_AUTHORIZED`, sem contornar bloqueios.

**Estado:** `HISTORICAL_ACL_EVIDENCE_REUSED / CURRENT_ACL_READ_ONLY_ATTESTATION_PENDING / B2_NOT_AUTHORIZED / E6_G1_BLOCKED`.
