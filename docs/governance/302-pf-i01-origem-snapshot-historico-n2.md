# Documento 302 — PF-I01: origem do snapshot histórico N2 e condições de empacotamento

**Data:** 2026-10-25. **Natureza:** parecer de fonte documental / preparação, sem implementação.
**Base:** Documento 301, CP295.

## Fonte confirmada
Workflow histórico GitHub Actions **37229070210**, artefato **11313491459** (`oes-s5-evidence-37229070210`). Metadados consultados na API de artifacts: `expired=false`, `created_at=2026-10-04T19:39:18Z`, `expires_at=2026-11-03T19:39:17Z`, ZIP 28551 bytes no retorno. A disponibilidade foi verificada em 2026-10-25, **não garante retenção futura**.

O workflow `.github/workflows/oes-n2-editorial-offline.yml` já recupera `rc01-evidence-sheet-view.json` e `rc01-evidence-sheet-preview.md` desse artefato. O run **40226403431 completed/success** recompôs a apresentação atual utilizando JSON histórico e renderizador/template atuais. Os nomes de membros são corroborados pelo workflow; seu conteúdo binário **não foi inspecionado nesta atividade**.

## Decisão de origem para PF-I01
**Fonte preferencial:** congelar como entrada do piloto o JSON histórico correspondente ao artifact 11313491459, com origem, SHA-256 real calculado sobre bytes exatos, versão/commit do template/renderizador, identidade e assurance verificados e aprovação específica de incorporação. **Não utilizar o artifact remoto como dependência de tempo de requisição Django**. Não considerar o Markdown histórico antigo como equivalente à versão editorial atual.

## Gate documental antes da incorporação
1. Baixar e inspecionar ZIP, nomes e bytes dos arquivos permitidos antes do vencimento de retenção; conferir identidade `OES-P-2026-000401`, vínculos Q–I–P e disclosure A2.
2. Calcular digest SHA-256 do JSON literal e da projeção renderizada, registrar tamanhos, datas e proveniência. Recusar material inesperado ou divergente; nenhum dado factual novo.
3. Fixar snapshot versionado no local de menor exposição apropriado ao piloto, sujeito a decisão de sensibilidade/restrições e revisão de diffs. Não persistir arquivo desconhecido sem inspeção.
4. Validar renderização com template atual e testes negativos; somente então autorizar camada Django GET-only.
5. Nenhum download no processamento HTTP; sem SQL conectado, busca factual, workflow científico habilitado, A3 presumido, publicação externa ou serviço pago.

## Riscos e fronteiras
A expiração prevista do artifact é **2026-11-03T19:39:17Z**: risco de perda da fonte após esta data. O CI de reprodução não substitui inspeção e fixação local dos bytes antes de desenvolver PF-I01. A expressão “snapshot imutável” exige digest e preservação material comprovados, não apenas link GitHub Actions.

Marco B aberto; E9 NO-GO; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; pesquisadores indisponíveis, A3 não demonstrada.

## Próxima atividade
Obter os bytes do artifact 11313491459 em ambiente de inspeção seguro, verificar conteúdo/digests e propor caminho versionado. Essa próxima atividade **não** está autorizada a alterar Django ou disponibilizar dados externamente.
