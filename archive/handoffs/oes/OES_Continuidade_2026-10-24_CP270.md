# OES — CP270: continuidade em 2026-10-24

**Anterior:** CP269. **HEAD antes deste checkpoint:** `20458dcb844cbb0731131578da329d8c6dbc4dbf`. A branch `main` e o ponteiro `archive/handoffs/oes/README.md` são fontes de continuidade; sempre verificar o HEAD atual.

## Marcos pós-CP269

- E6-A1: Documento 254, protocolo de futura observação factual controlada, sem aprovação para execução.
- E6-A2: código mínimo `e6_capture.py` e workflow de captura, 27/27 testes sintéticos PASS em run `40069936004`, sem comprovar consulta real.
- E6-A3: após identificação de insuficiência da confirmação textual, proprietário aplicou `if: ${{ false }}` ao job factual; bloqueio confirmado em `.github/workflows/d2-e6-a2-gated-capture.yml`.
- E6-A3: workflow independente `.github/workflows/d2-e6-a3-synthetic-artifact.yml` executado com sucesso em run `40084945270`, commit `20458dcb844cbb0731131578da329d8c6dbc4dbf`. Artifact `12556772199`, nome `oes-e6-a3-synthetic-40084945270`, tamanho ZIP 1.783 bytes, digest ZIP SHA-256 `2bb494a7704e46401aa9c0612154a27ebf91ed221e26626f5edc3aa639a8076a`, expiração registrada 2026-10-31 10:11 UTC. Arquivo ZIP efetivamente recuperado: `response.raw.json` 207 bytes, `manifest.json` 1.941, `summary.json` 396; SHA-256 bruto `b4e549b09a40f172e0b971820ad372d0734862f1b00b6f0691048e0775f0c696` confirmado no manifesto e resumo; todos sintéticos. Classificação `D2_E6_A3_SYNTHETIC_ARTIFACT_TRANSPORT_AND_INTEGRITY_PASS`.
- E5: política GitHub versionado para piloto aprovada, prova de commit sintético anterior A6 demonstrada, sem comprovação de armazenamento factual durável; recuperação histórica E3 sem JSON bruto permanente e não substituível.

## Gates e restrições atuais

Fase 4 encerrada **somente metodológica/documentalmente**; D2 `PARTIAL`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`; BRG/SA pendentes, 36 migrations `UNREVIEWED`, Django sintético documental sem promoção de produção. Não há avaliação científica por pesquisadores. **Consulta ClinicalTrials.gov não autorizada**, workflow factual bloqueado. Artifact sintético não é arquivo durável. Não presumir aprovação de publicação de JSON real pela política E5-A4.

## Ponto exato de retomada

Próximo `Prossiga`: **avaliar, sem executar**, os pré-requisitos e o formato mínimo de autorização E6-G1 para uma única coleta, incluindo URL codificada literal, SHA do código, escopo de GET único, revisão do JSON integral após captura, retenção e gate de publicação E6-G2. Não desbloquear workflow nem despachar consulta por inferência. Avançar por uma atividade por `Prossiga`, STOP; Freshness Gate antes e imediatamente antes da escrita, checkpoint após marco ou 3–5 atividades, mensagens de progresso, modo médio para análise e alto para alteração de risco.

**STOP — CP270 documenta transporte sintético e mantém bloqueio factual.**
