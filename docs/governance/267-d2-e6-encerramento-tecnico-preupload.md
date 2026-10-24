# Documento 267 — D2-E6: encerramento técnico restrito dos controles pré-upload

**OES | 2026-10-24 | Referência CP272 | revisão testada `59c9f34ce725c64df82177a33d61b07ed7a9568b` | `D2_E6_PREUPLOAD_OFFLINE_CLOSED_RESTRICTED`**

## Evidências
- [Run 40112281012](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112281012): 32/32 testes sintéticos PASS, incluindo bloqueio `HOLD` de campos inesperados.
- [Run 40112626355](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112626355): 36/36 PASS, incluindo rótulos `RAW_SOURCE_DATA`, `NOT_SCIENTIFICALLY_REVIEWED`, `TEMPORARY_ARTIFACT`, integridade e verificação pré-upload.
- [Run 40112908037](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112908037): `completed/success` na revisão `59c9f34ce725c64df82177a33d61b07ed7a9568b`, **38/38 testes PASS**, inclusive aceitação sintética de `resultsSection` e `documentSection` e preservação do JSON bruto.
- Código: `tools/d2_e5_preservation/e6_capture.py` e testes em `tools/d2_e5_preservation/tests/test_e6_capture.py`. Workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` permanece com `if: ${{ false }}`, com passo de verificação **antes** de `actions/upload-artifact@v4`.

## Parecer proporcional
**Encerrados apenas os controles técnicos pré-upload no escopo offline/sintético testado.** Rotulagem do manifesto/resumo, identificação do artifact, revalidação de estrutura, hashes e `HOLD` têm evidência de CI. O JSON bruto não é modificado intencionalmente.

**Não comprovado:** compatibilidade exaustiva com todos os campos/versões da API v2, ausência de dados pessoais/sensíveis, adequação legal de reutilização, avaliação científica, disponibilidade da fonte e eficácia operacional conectada. Regras de campos conhecidos podem produzir falsos `HOLD` diante de evolução de esquema; bloqueio conservador deve ser preservado, com revisão antes de nova alteração.

## Gates remanescentes
E6-G1 `NOT_APPROVED` e captura factual `BLOCKED`; o sucesso offline **não** autoriza GET nem desbloqueio do workflow. Antes de propor E6-G1: definir responsável e prazo para inspeção integral do JSON, aceitar expressamente eventual exposição pública do artifact temporário em repositório público, conferir fonte/termos e revisão canônica da URL/HEAD exatos, conforme Documento 255. E6-G2 para publicação durável permanece distinto e não aprovado.

Nenhuma alteração no Neon, nos dados artificiais retidos, nas 36 migrations `UNREVIEWED`, no estado `NOT_READY` de prontidão operacional, D2 `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, ou Fase 5 `NOT_STARTED`.

**Próximo passo:** decisão documental/humana E6-G1, sem qualquer execução factual inferida. STOP.
