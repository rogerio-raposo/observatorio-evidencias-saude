# Documento 284 — Ensaio conectado sintético B2, resultado e limpeza

**OES | 2026-10-24 | Branch Neon:** `br-gentle-hall-b6jaxehf` | **Banco:** `oes_sandbox` | **HEAD-base GitHub:** `fba65ab35244418738299eb98bb2b7fbd3274feb`

**Autorização:** `APPROVED — OES / D2-E6 / B2_SINGLE_SYNTHETIC_CONNECTED_SET_ROLE_TRIAL / br-gentle-hall-b6jaxehf / temporary SET grants only if needed / one synthetic INSERT / private verifier hash check / precise cleanup and grantor-aware revoke / no factual GET / no public JSON / no workflow enablement / no paid services / fail closed`

## Pré-voo

`current_user=session_user=oes_sandbox_owner`, `current_database()=oes_sandbox`. Contagem inicial da tabela `oes_raw_private.source_observation`: **0**. As associações preexistentes do owner aos papéis `oes_e6_writer` e `oes_e6_verifier` eram ambas do grantor `cloud_admin`, com `SET FALSE / INHERIT FALSE / ADMIN TRUE`. Colunas da tabela verificadas pelo catálogo, sem leitura de `raw_payload` factual.

## Execução autorizada

1. Concessões temporárias de `SET TRUE, INHERIT FALSE, ADMIN FALSE` ao owner para os dois papéis foram aplicadas em transação. Catálogo confirmou dois novos grants do grantor `oes_sandbox_owner` e preservação dos grants `cloud_admin`.
2. Em transação posterior, `SET LOCAL ROLE oes_e6_writer` e **um INSERT** da observação `SYNTH-B2-20261024-01`, com bytes da fixture JSON puramente sintética já conhecida (18 bytes), proveniência sintética e SHA-256 calculado no PostgreSQL. Transação retornou sem erro.
3. Em **transação distinta**, `SET LOCAL ROLE oes_e6_verifier` e consulta delimitada por ID retornaram `current_user=oes_e6_verifier`, `session_user=oes_sandbox_owner`, `payload_bytes=18`, `octet_length(raw_payload)=18`, SHA-256 armazenado = SHA-256 recalculado `a8198524f58e72b56283ab71ebddada22840f108b46ef7165bb3fca9919c5558` e `integrity_pass=true`. A consulta não retornou bytes brutos.
4. Em nova transação, `DELETE` dirigido exclusivamente ao ID sintético e `REVOKE ... GRANTED BY oes_sandbox_owner` de ambos os grants temporários; operação retornou sem erro.
5. Pós-limpeza: tabela privada com **0 linhas**; exatamente os dois grants históricos do grantor `cloud_admin` com `SET FALSE / INHERIT FALSE / ADMIN TRUE`; papéis `oes_e6_capture_login`, `oes_e6_writer`, `oes_e6_verifier` com `rolcanlogin=false` e `rolinherit=false`.

## Invariantes da fixture e ressalva

Consultas finais confirmaram `evidence.study=2`, `evidence.report=2` e `evidence.study_report_link=3`, idênticos às contagens históricas. `evidence.result_source=0` e outras tabelas de resultados consultadas também retornaram zero. A contagem histórica de **1 registro de proveniência** pertence a referência anterior que não foi identificada de modo inequívoco nesta conferência; **não declarar validado esse quarto invariante** até localizar a tabela específica e seu baseline. Não presumir perda de dados, nem afirmar preservação integral sem identificação da fonte.

## Limites do aceite

- O teste mostrou alternância de **papéis efetivos distintos sob uma única sessão administrativa**, como escolhido pelo proprietário; NÃO demonstrou autenticações independentes.
- As negações cruzadas já foram demonstradas no Documento 272, mas não repetidas nesta bateria positiva.
- O INSERT sintético utilizou SQL Neon em vez de uma aplicação conectada via driver; não valida integração de workflow.
- Nenhum GET factual, secret, workflow de captura, novo login, serviço pago ou artifact público foi usado; não houve exposição de JSON bruto.
- A senha temporária antiga não foi reutilizada nem invalidada nesta atividade; o login continua desabilitado.
- Se o tratamento de transações ou a limpeza precisar de nova validação, não reexecutar automaticamente a inserção já comprovada.

**Estado:** `B2_SYNTHETIC_INSERT_PASS / PRIVATE_READBACK_HASH_PASS / TEMP_GRANTS_REVOKED / RAW_ROWS_ZERO / FIXTURE_3_OF_4_INVARIANTS_CONFIRMED / CONNECTED_APP_INTEGRATION_PENDING / E6_G1_BLOCKED`.

**STOP — encerramento restrito da atividade autorizada, sem liberação factual.**
