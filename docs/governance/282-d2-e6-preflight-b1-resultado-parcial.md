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

## Atestação complementar fornecida pelo proprietário — 2026-10-24

O proprietário executou no Neon SQL Editor a consulta somente leitura de ACL proposta para o ambiente experimental e apresentou o resultado estruturado com três papéis. **A origem deste registro é o resultado fornecido pelo proprietário, não uma nova execução direta pelo conector.**

| Papel | LOGIN | INHERIT | USAGE schema | INSERT | SELECT | Associações como membro |
|---|---|---|---|---|---|---|
| `oes_e6_capture_login` | false | false | false | false | false | false |
| `oes_e6_writer` | false | false | true | true | false | false |
| `oes_e6_verifier` | false | false | true | false | true | false |

Os resultados correspondem às expectativas da matriz de privilégio mínimo, e a combinação `NOLOGIN` + ausência de membership para o login de captura mantém a desativação observável. A coluna `possui_associacoes` indica exclusivamente se o papel é **membro** de outro papel; não verifica concessões recebidas por terceiros, embora isso não seja necessário para a matriz específica acima.

**B1 concluída no escopo de atestação de ACL por SQL Editor**, preservando o registro de que cinco consultas diretas pelo conector haviam sido bloqueadas. Esta atestação não comprova autenticação simultânea de escritor e verificador, INSERT efetivo, leitura independente, invalidação da senha temporária antiga nem encerramento de sessões prévias. B2 exige decisão operacional própria.

**Estado atualizado:** `B1_ACL_ATTESTED_BY_OWNER_PASS / B2_NOT_AUTHORIZED / E6_G1_FACTUAL_BLOCKED`.
