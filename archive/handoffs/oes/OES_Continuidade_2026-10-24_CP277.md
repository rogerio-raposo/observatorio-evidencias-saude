# OES — CP277: G1 reader offline e validação de regressão

**Data:** 2026-10-24. **Anterior:** CP276. **HEAD-base:** `78a2d3a9bef2c203c9a9b2f3e6068610e061dcd8` (commit do leitor). Checkpoint operacional imutável; template e ponteiro canônicos permanecem vigentes.

## Evidência consolidada

**G1-A1 / Autorização expressa:** `APPROVED — OES / D2-E6 / G1_MINIMAL_OFFLINE_PYTHON_POSTGRES_INTEGRATION / synthetic-only / injected connections and mocks / no Neon / no network / no credentials / no SQL execution against database / no factual GET / no workflow enablement / no public raw JSON / no paid services / fail closed`. O escopo é código e testes locais/CI offline, não conectado.

**G1-A2 / Implementação:** commit `78a2d3a9bef2c203c9a9b2f3e6068610e061dcd8`, arquivos `tools/d2_e5_preservation/e6_private_reader_offline.py` e `tools/d2_e5_preservation/tests/test_e6_private_reader_offline.py`. Leitor faz `SELECT observation_id, payload_sha256, payload_bytes, raw_payload FROM oes_raw_private.source_observation WHERE observation_id = %s`, com parâmetros DB-API, conexão previamente injetada, retorno privado de tupla validada e `PersistenceHold` sanitizado. NÃO instancia driver, conecta, autentica ou verifica grants efetivos; a conexão privada é responsabilidade de G2. Não imprime JSON bruto.

**G1-A3 / Revisão:** cinco testes locais relatados como PASS com reprodução do módulo, inspecionada compatibilidade estrutural da tupla com `verify_private_readback()`. Não confundir com teste integrado real do leitor no orquestrador; este permanece pendente.

**G1-A4 / CI comprovada:** run [40133419311](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40133419311), job `120989797624`, branch `main`, commit `78a2d3a9bef2c203c9a9b2f3e6068610e061dcd8`, `workflow_dispatch`, conclusão `success`. Logs: `Ran 68 tests in 0.038s`, `OK`, 5 métodos de `test_e6_private_reader_offline` com `ok`. Total = 63 baselines anteriores + 5 testes novos, sem falhas/erros. Essa evidência não comprova acesso conectado ao banco nem que identidades PostgreSQL independentes funcionem.

## Estado e limites

- `G1_OFFLINE_READER_REGRESSION_PASS_68_OF_68`; **G1 permanece em andamento**. Pendências: ajustar explicitamente proveniência/timestamps e integrar o leitor privado ao orquestrador por mock, com regressão proporcional após alterações materiais.
- `G2_CONNECTED_SYNTHETIC_NOT_AUTHORIZED`; nenhuma criação de login, concessão, segredo, SQL/Neon ou serviço pago nesta sequência.
- E6-G1 factual `NOT_AUTHORIZED`; workflow `.github/workflows/d2-e6-a2-gated-capture.yml` continua `if: ${{ false }}`, caminho `upload-artifact` factual incompatível com Documento 269; não habilitar, não gravar raw JSON em artefatos públicos.
- PG-A4 provenance: quarto invariante histórico refere-se a `provenance.record`, não a `evidence.result_source`; presença atual ainda não reatestada, sem exigir repetição do B2.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; D2 `PARTIAL`; prontidão `NOT_READY`; Fase 5 `NOT_STARTED`.

## Retomada

Aplicar `archive/continuity/OES_Template_Abertura_Continuidade.md` em Modo Continuidade, ler `archive/handoffs/oes/README.md`, CP277 e STATE/CHANGELOG e executar Freshness Gate. A próxima atividade autorizável por um `Prossiga` é **G1-A5: planejamento mínimo e/ou ajuste de compatibilidade de proveniência com código offline** conforme escopo aprovado, preservando G2 desconectado. Apenas uma atividade por comando; checkpoint proporcional após 3–5 atividades ou decisão de risco. STOP.
