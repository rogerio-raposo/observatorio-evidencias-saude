# Documento 296 — Consulta documental N2: decisão e encerramento editorial restrito

**Data:** 2026-10-25. **Status:** fechamento técnico-editorial delimitado, sem promoção científica ou operacional. **Antecedente:** Doc. 295 / CP290.

## Decisão funcional
Responsável aprovou expressamente **Alternativa A — consulta documental controlada** como primeiro uso funcional prioritário do OES, centrado em Ficha de Evidência N2 documental já existente. Aprovação é de prioridade, não de publicação externa, implementação web, captura factual ou operação científica. F2 preparação de investigação e F3 produção/atualização permanecem futuras.

## Auditoria M1-A6–M1-A7
Template `templates/evidence-sheet.md` (declara v0.2, input EvidenceSheetView v0.1), renderizador Python e mapa de apresentação já existiam. Artefato do Caso Real 01 dCBT-I (run 37229070210, artifact 11313491459), publicado A2 no modelo OES conforme Doc. 67, permitiu inspeção documental; A3 não ocorreu. Identificados problemas de apresentação E01 objetos estruturados como JSON, E02 linhas vazias em tabelas Markdown, E03 papéis das sínteses pouco distinguíveis e E04 contagens de estudos da fonte externa versus modelados no OES. E05 reorganização visual ampla diferida.

## Autorização, implementação e rastreabilidade
Responsável autorizou implementar **somente E01–E04 com regressões**, preservando gates e contratos. Commits:
- `be0e71fb9696300a92a4d9c119ea0d67890afefc`: primeiras correções editoriais + suíte.
- `26946d801321a4d724df310ba52f02a3d4ddc92a`: correção de normalização de tabela/teste.
- `aec3898af64174b8ce2909503005211896da15f2`: formatos conhecidos de contexto/população/comparação.
- `50926dcfa4f63698bc1442ff0954c998809d8972`: escopo de asserção de tabela.
- `f82ee42ddc83455cce4adf798d0f195d2ae0e9a2`: workflow offline isolado `.github/workflows/oes-n2-editorial-offline.yml`.
Arquivos funcionais: `scripts/render_evidence_sheet_reference.py`, `templates/evidence-sheet.md`, `templates/evidence-sheet-presentation-map.json`; suíte `tests/test_evidence_sheet_editorial_n2.py`. Mudanças limitadas a apresentação e testes, sem alteração de contrato científico, SQL/Neon, captura, credentials, roles ou implantação.

## Verificação e interpretação limitada
- Workflow **OES N2 editorial offline regression**, run **40225338793**, SHA `f82ee42ddc83455cce4adf798d0f195d2ae0e9a2`, **completed/success**, comprova suíte isolada. Não representa execução exaustiva dos doze critérios ER-T01–ER-T12 nem validação científica independente.
- Workflow amplo PostgreSQL run **40221429351**, SHA `26946d801321a4d724df310ba52f02a3d4ddc92a`: **failure** em `TOPI-B1R1-PRE-DAY19-READINESS` por `ACTIVATION_WINDOW = FAIL / EXPIRED_NOT_EXECUTED` (data da primeira oportunidade 2026-10-19; run em 2026-10-25); F3-TEMPLATE e RC01 anteriores a essa etapa **success**. Não reescrever relógio nem relaxar gate histórico, e não anunciar CI integral como PASS.
- **Fechamento técnico-editorial restrito E01–E04:** aceita-se implementação + suíte offline PASS no escopo verificado. Não equivale a prontidão de publicação externa, usabilidade validada com consultantes, demonstração HTTP F1, revisão A3, atualização científica ou validação global da CI.

## Estado transversal e próxima atividade
Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`; Fase 5 `NOT_STARTED`; piloto amplo (Marco B) aberto; pesquisadores ainda ausentes. Próximo: propor **roteiro de avaliação funcional controlada da consulta da Ficha N2 já renderizada**, incluindo critérios observáveis de clareza e proveniência, sem criar interface Django nem nova ciência. Qualquer disponibilização externa exige autorização específica.
