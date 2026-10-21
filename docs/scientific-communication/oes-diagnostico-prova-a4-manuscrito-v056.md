# OES — Diagnóstico para prova integral A4 do manuscrito 0.56

**Data:** 21 de outubro de 2026.  
**Natureza:** diagnóstico de preparação; **nenhum PDF produzido ou renderizado nesta etapa**.  
**Manuscrito examinado:** [versão editorial 0.56](oes-fundamentos-arquitetura-modelo-desenvolvimento.md), blob `2affc20eac49a8bc91cecf00243090fbd27f8d64`.  
**Auditoria anterior:** [Figuras 1–7 e Quadro 1](oes-auditoria-editorial-elementos-visuais-v054.md).  
**Data dos estados factuais:** 20 de outubro de 2026.

## Diagnóstico

**Recomendação:** gerar futuramente uma **prova de leitura integral em PDF A4**, claramente identificada como editorial e não aprovada cientificamente. Preferir um processo reprodutível Markdown → HTML/CSS de impressão ou DOCX → PDF, preservando texto pesquisável, links, hierarquia, figuras vetoriais e legendas. A escolha final do conversor depende de teste real.

| Componente | Inventário documental | Atenção na prova |
|---|---|---|
| Manuscrito | Versão 0.56; ~479 mil caracteres; 2.085 linhas de Markdown | Documento extenso: paginação integral e revisão de quebras |
| Figuras | Sete links SVG, Figuras 1–7 | Preservar proporção, títulos, legendas, contraste e legibilidade |
| Acessibilidade | Os sete links têm descrição alternativa | Testar PDF etiquetado e ordem de leitura; alt do Markdown não garante acessibilidade final |
| Tabelas | Nove blocos tabulares Markdown, total de 78 linhas estruturais | Examinar distribuição e quebra em todas as tabelas |
| Quadro 1 | Oito casos/percursos em quatro colunas extensas na §14.2 | **Risco principal:** texto muito estreito, fonte pequena, cortes e divisão indevida |
| Referências | 56 itens científicos | Conferir números, DOI, caracteres especiais, links e paginação |
| Estrutura | Capítulos 1–16 no manuscrito | Conferir hierarquia, remissões internas e sumário quando gerado |

Essas contagens são verificações da estrutura fonte, não aprovação tipográfica ou validação científica.

## Padrão inicial recomendado para a prova

- **Formato:** A4, orientação retrato como padrão; página paisagem pontual apenas se a tabela realmente exigir.
- **Margens:** cerca de 20–25 mm; texto de corpo em torno de 10,5–11 pt, com entrelinha confortável.
- **Figuras:** ajuste proporcional à largura útil, sem separar figura de legenda nem rasterizar sem necessidade.
- **Tabelas:** preservar cabeçalhos, bordas, colunas e quebras; evitar reduzir fonte abaixo de 9 pt para forçar encaixe.
- **Documentação:** capa/metadados identificando “PROVA EDITORIAL — NÃO VALIDADO CIENTIFICAMENTE”; links preservados e numeração de página.

## Checklist de prova efetiva — ainda não realizado

1. Gerar PDF completo e confirmar integridade dos 16 capítulos e 56 referências.
2. Renderizar as páginas do PDF em imagens e inspecionar legibilidade, cortes, sobreposições e quebras; examinar todas as páginas, com especial atenção às figuras, tabelas e referências.
3. Avaliar separação entre figura e legenda, escala dos sete SVG e preservação de caracteres e fontes.
4. Examinar o Quadro 1 em A4: se não couber legivelmente em retrato, testar página paisagem isolada ou reorganização tabular acessível.
5. Verificar remissões, hyperlinks e títulos em sumário, caso exista; no artefato de composição, transformar caminhos relativos ao GitHub em destinos utilizáveis.
6. Testar seleção de texto, estrutura e leitura lógica do PDF; descrever limitações de acessibilidade caso não seja possível produzir PDF etiquetado.
7. Registrar correções no fluxo de composição sem alterar silenciosamente a fonte científica ou estados de fases.

## Prioridades e decisões

**P1 — prova do Quadro 1:** risco elevado de truncamento ou letra ilegível em A4 retrato.  
**P1 — prova integral:** nenhuma página do PDF completo foi produzida nesta atividade.  
**P1 — fidelidade das figuras:** verificar SVG na saída paginada real.  
**P2 — referências e remissões:** conferir links e fluxo de leitura.  
**P2 — acessibilidade:** testar se o conversor mantém estrutura semanticamente navegável.

**Próxima atividade candidata:** criar a **primeira prova completa em PDF A4** a partir de uma revisão fixa do manuscrito e inspecionar a renderização. Tratar ajustes como composição editorial, sem extrapolar para revisão científica independente. Não distribuir externamente sem autorização.

**Limites:** relatório documental somente. Sem PDF, mudanças no manuscrito, `STATE.md`, CPs, banco, CI, Neon, *gates* ou serviços pagos.
