# Documento 279 — Encerramento técnico restrito do adaptador offline PostgreSQL E6

**OES | 2026-10-24 | CP274 | Base: Documentos 269–278 | HEAD-base:** `32cde7f8f2a7223e9e646121301876e3952d4eca`

**Decisão técnica:** `OFFLINE_ADAPTER_CLOSED_RESTRICTED / CONNECTED_VALIDATION_PENDING / E6_G1_FACTUAL_BLOCKED`.

## 1. Objeto encerrado

Implementação e validação **offline** do adaptador mínimo `tools/d2_e5_preservation/e6_private_pg_offline.py` e testes `tools/d2_e5_preservation/tests/test_e6_private_pg_offline.py`, sem criação de conexão, credencial, serviço externo, operação Neon ou GET factual. O adaptador prepara INSERT parametrizado no esquema privado `oes_raw_private.source_observation`, verifica bytes/tamanho/SHA-256 e proveniência básica, rejeita autocommit, utiliza rollback em erro simulado e retorna metadados sanitizados marcados `PRIVATE_PERSISTED_UNVERIFIED`.

## 2. Evidência verificada

**GitHub Actions run 40125394727:** workflow `.github/workflows/d2-e5-a3-offline-tests.yml`, evento `workflow_dispatch`, revisão testada `2894fda7a973d499e563fedb982fcb9a6d25d551`, status `completed`, conclusão `success`, log `Ran 57 tests in 0.040s` / `OK`. Os **18 testes** de `test_e6_private_pg_offline` aparecem individualmente como `ok`; os outros **39** testes pertencem ao conjunto de preservação offline existente. Referência: https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40125394727 .

Verificação pré-fechamento: workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` mantém `if: ${{ false }}`. Repositório público contém código e documentação, **não** JSON bruto factual.

## 3. Limites explícitos — fora do encerramento

- Nenhuma integração real com driver PostgreSQL/Neon, identidade técnica conectada ou transação SQL validada por esta CI.
- Teste positivo sintético autenticado de INSERT permanece não concluído; recuperação independente com leitura restrita e comparação de hash pós-gravação permanece pendente.
- Capturador `e6_capture.py` e workflow factual seguem a arquitetura antiga de empacotamento/artifact público e **não podem ser executados**, mesmo que o job fosse desbloqueado, sem revisão e substituição autorizadas.
- Não foi autorizada criação de GitHub Secrets, novo login, reativação de credencial, captura factual E6-G1, migração produtiva, object storage nem serviço pago.
- Este documento não é aprovação de prontidão operacional, científica ou de fechamento de todo D2-E6.

## 4. Próximo encaminhamento proporcional

Preparar decisão específica sobre integração controlada do adaptador no caminho de execução **sintético** e desenho de verificação independente, eliminando upload público antes de eventual utilização conectada. Não repetir a bateria offline aprovada sem mudança material no código. Permanecer em regime de autorização progressiva e Freshness Gate.

**Estado canônico deste marco:** `OFFLINE_IMPLEMENTATION_TECHNICALLY_CLOSED_RESTRICTED / TESTS_18_OF_18_PASS / CONNECTED_INTEGRATION_NOT_APPROVED / E6_G1_FACTUAL_BLOCKED`.

**STOP — encerramento restrito; nenhum desbloqueio operacional.**
