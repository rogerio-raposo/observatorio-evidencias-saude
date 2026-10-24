# Documento 280 — Gate de integração sintética E6 com persistência e verificação privada

**OES | 2026-10-24 | CP274 | HEAD-base `6c68b91bc921b73e90a6142cad16b5d57ba5a7a9`**  
**Estado: PROPOSAL_ONLY / OWNER_APPROVAL_PENDING / E6_G1_FACTUAL_BLOCKED**

## Decisão arquitetural

O adaptador offline foi encerrado restritamente pelo Documento 279 (18/18 testes específicos e 57/57 na CI, run 40125394727). O próximo objetivo **não é recriar o adaptador nem reabrir testes já aprovados**, mas comprovar a junção dos componentes com dados sintéticos e a recuperação privada independente.

A implementação não deverá usar como transporte o artifact público previsto no workflow histórico. O workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` permanece com `if: ${{ false }}`, e seu caminho de artifact **não pode ser executado**.

## Gate proposto em duas fronteiras

**A — Integração de código, sem rede (autorização solicitada agora):**
- Introduzir um orquestrador **sintético e offline**, separado do capturador factual, que reutilize `prepare_observation` e `persist_observation` e aceite dependências injetadas. Não alterar `e6_capture.py` ou workflow factual nesta fronteira.
- Modelar verificação independente com interface que receba somente observação, comprimento, hash e bytes privados e compare SHA-256 calculado sobre bytes recuperados. Não retornar JSON bruto em saída, logs ou artifacts.
- Cobrir com mocks a separação de writer sem SELECT e verifier sem INSERT, rollback, duplicidade, falha de readback, hash divergente e resultado fail-closed. Não implementar autenticação ou credenciais nos mocks.
- Reutilizar a CI offline existente para os novos testes; registrar HEAD exato e resultado. Não criar arquitetura genérica de storage nem novas tabelas.

**B — Ensaio sintético conectado (NÃO autorizado por este documento):**
- Submeter decisão separada para executar INSERT positivo e leitura de verificação sob identidades **efetivas e distintas**, com permissões mínimas, somente na branch `br-gentle-hall-b6jaxehf` / banco `oes_sandbox`.
- Propor antes do ensaio o tratamento da identidade `oes_e6_capture_login`, atualmente `NOLOGIN` e sem membership, com senha descartável anterior não reutilizável, e uma via específica de verificação privada sem conceder SELECT ao escritor.
- Exigir limpeza comprovada, fixture PG-A4 intacta, nenhum dado factual e desativação/revogação pós-teste.

## Não autorizado

GET da ClinicalTrials.gov, reativação de login ou uso da senha antiga, criação de secrets, grants ou roles no Neon, alterações ao workflow factual ou seu desbloqueio, publicação de JSON, uso de serviço pago, produção e promoção científica/operacional.

## Evidências para aceite de A

Revisão do diff e testes novos identificados; CI offline PASS na revisão exata; ausência de conexão, segredos e artifacts de JSON; workflow factual comprovadamente bloqueado; documentação das lacunas conectadas sem confundi-las com o fechamento offline anterior.

## Decisão solicitada

`APPROVED — OES / D2-E6 / SYNTHETIC_OFFLINE_INTEGRATION_AND_PRIVATE_READBACK_MOCKS_ONLY / no Neon / no credentials / no factual GET / no public JSON / keep factual workflow disabled / no paid services / fail closed`

**STOP — A depende de aprovação explícita; B permanece bloqueada.**

## Etapa A — implementação offline autorizada, 2026-10-24

O proprietário aprovou explicitamente `SYNTHETIC_OFFLINE_INTEGRATION_AND_PRIVATE_READBACK_MOCKS_ONLY`, sem Neon, credenciais, GET ou alteração do workflow factual. Persistidos `tools/d2_e5_preservation/e6_private_roundtrip_offline.py` (commit `fa1be11d3bec020204e2c381874c1d6863115b66`) e `tools/d2_e5_preservation/tests/test_e6_private_roundtrip_offline.py` (commit `1b77ef2ce178e8854fbd0346abab417aee188a24`). Fluxo integra `prepare_observation`/`persist_observation`, chama uma interface de leitura independente injetada e compara ID, SHA-256, comprimento e bytes recuperados **sem devolvê-los**. Tratamento de falha após commit declara HOLD com possível registro persistido, sem prometer rollback impossível. Mocks simulam writer sem SELECT, verifier sem INSERT, falha de escrita/rollback, leitura negada, hash/bytes/ID adulterados e resultado sanitizado.

**Evidência pendente:** testes novos **ainda não executados na CI**, nem validados contra PostgreSQL real. A suíte anterior 57/57 PASS aplica-se à revisão anterior, não aos novos arquivos. Workflow factual continua `if: ${{ false }}` e não foi modificado. Nenhuma operação Neon, credencial ou GET nesta etapa.

**Estado:** `OFFLINE_SYNTHETIC_INTEGRATION_CODE_PERSISTED / NEW_TESTS_CI_PENDING / CONNECTED_GATE_NOT_APPROVED / E6_G1_BLOCKED`.
