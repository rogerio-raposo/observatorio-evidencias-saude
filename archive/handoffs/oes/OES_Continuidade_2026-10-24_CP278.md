# OES — CP278: encerramento técnico restrito de G1 offline

**Data:** 2026-10-24. **Checkpoint anterior:** CP277. **HEAD-base testado:** `ef26b03cbbf9f038c31eb2ee146d45f10b0453ca`. **Natureza:** checkpoint de continuidade operacional, sem promoção científica nem autorização conectada.

## Evidências de implementação e regressão

- **G1-A5:** `tools/d2_e5_preservation/e6_private_capture_provenance_offline.py` e `tests/test_e6_private_capture_provenance_offline.py`, commit `56b38a783e4f3df234ee778fff3638d9180bcd96`. Conversão explícita de timestamps ISO 8601 com fuso para `datetime` UTC-aware, inserção de `source_name='ClinicalTrials.gov API v2'`, `activity_id` definido, validação fail-closed via `prepare_observation()`. Apenas contrato offline, nenhuma modificação do capturador factual legado.
- **G1-A6:** GitHub Actions [40133870873](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40133870873), commit G1-A5, **73 testes PASS / 0 FAIL / 0 ERROR**, incluindo cinco casos de proveniência.
- **G1-A7:** `tools/d2_e5_preservation/e6_private_roundtrip_injected_offline.py` e `tests/test_e6_private_roundtrip_injected_offline.py`, commit `ef26b03cbbf9f038c31eb2ee146d45f10b0453ca`. Composição de `synthetic_private_roundtrip` e `read_private_observation` via objetos injetados; seis testes de recuperação, consulta parametrizada, separação de objetos, erros de escrita, negação de leitura e byte corruption. Nenhum driver, conexão real ou credencial. Identidade efetiva separada ainda não atestada; testar objetos distintos não comprova logins separados.
- **G1-A8:** GitHub Actions [40135045815](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40135045815), job `120994679254`, branch `main`, HEAD `ef26b03cbbf9f038c31eb2ee146d45f10b0453ca`, conclusão `success`, log `Ran 79 tests in 0.761s` / `OK`. Os seis testes novos constam individualmente com `ok`. Somente prova de regressão Python offline.

## Deliberação e limites

**Resultado:** `G1_CLOSED_TECHNICAL_RESTRICTED_SYNTHETIC_OFFLINE_ONLY / CI_79_OF_79_PASS`. Abrange construção parametrizada de INSERT, adaptação explícita de proveniência, leitor privado, orquestração com conexão injetada e tratamento sanitizado de falhas. **Não** prova conexão Postgres real, autenticação independente, controle efetivo de ACL no banco, recuperação após falha de leitura pós-commit, idempotência conectada, ou execução factual. HOLD após commit pode indicar registro existente e exige investigação antes de qualquer repetição.

**G2 conectado sintético:** `NOT_AUTHORIZED`. Necessária avaliação separada de identidade mínima, driver, tratamento privado dos bytes, rede, catálogo/ACL, rollback, limpeza e aprovações. Não repetir B2 nem testes já comprovados sem risco novo identificado.

**E6-G1 factual:** `NOT_AUTHORIZED`; workflow `.github/workflows/d2-e6-a2-gated-capture.yml` permanece `if: ${{ false }}`; não executar, não ligar upload público de JSON bruto, não pedir credenciais ou abrir GET por inferência. Política Doc 269 vigente. Nenhum SQL, Neon, DDL/DML, role/grant ou serviço pago executado nesta consolidação.

**Fixture PG-A4:** quarto invariante histórico vem de `provenance.record`, não `evidence.result_source`; não reatestado atualmente, sem evidência de perda. Fase 4 encerrada somente metodológica/documentalmente, D2 parcial, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.

## Retomada

Template `archive/continuity/OES_Template_Abertura_Continuidade.md` → ponteiro `archive/handoffs/oes/README.md` → CP278 → Freshness Gate. Sob próximo `Prossiga`, **uma atividade documental**: identificar o menor desenho de G2 conectado sintético e requisitos/risco de autorização sem executar conexões ou alterar credenciais. Qualquer G2 operacional exige autorização expressa própria. Persistir marcos em lotes proporcionais de 3–5 atividades. **STOP CP278.**
