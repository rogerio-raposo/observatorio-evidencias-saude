# OES — Política transversal de documentos de apresentação (MD → DOCX)

**Aprovada pelo proprietário:** 21 de outubro de 2026.  
**Âmbito:** todos os documentos destinados à apresentação, leitura ou circulação científica, técnica, institucional ou de divulgação, independentemente do diretório. Não se aplica obrigatoriamente a SQL, código, YAML, dados estruturados, CI, contratos técnicos e outros artefatos que exijam formato nativo. Exceções justificadas dependem de autorização específica.

## Fluxo de trabalho obrigatório

1. **Fonte canônica:** redigir, revisar e versionar conteúdo em Markdown (MD) no GitHub. Confirmar HEAD, versão e conteúdo antes da conversão.
2. **Formato para apresentação:** gerar DOCX **diretamente do MD**, não de PDFs ou provas intermediárias. Preservar textos, referências, tabelas, links, imagens e hierarquia de títulos em estilos editáveis do Word.
3. **Figuras:** uma única **legenda visível** por figura. Manter o **texto alternativo nas propriedades de acessibilidade**, sem transformá-lo em segunda legenda; preservar gráficos vetoriais (SVG), quando viável, com fallback compatível.
4. **Quadros e tabelas:** manter estruturas nativas editáveis; padronizar título, fonte e sequência numérica no documento; não rasterizar tabelas para solucionar paginação.
5. **Acabamento manual:** preparar o DOCX para revisões humanas no Microsoft Word, inclusive margens, tamanho dos elementos, quebra de página, orientação, contraste, acessibilidade e paginação. **Desativar a hifenização automática por padrão** e evitar hifens ou separações silábicas artificiais.
6. **PDF somente no Word:** eventual exportação final para PDF será realizada **pelo usuário no próprio Microsoft Word**, depois da revisão. O assistente **não deve gerar PDF como fluxo padrão** nem executar sucessivas provas automáticas; exceções exigem solicitação/autorização explícita.
7. **Fidelidade e rastreabilidade:** conferir DOCX versus MD para evitar omissões e duplicações; registrar versão, commit/blob e limites conhecidos. O DOCX é **derivado editável**, não substitui a fonte canônica.
8. **Correções posteriores:** alterações científicas, factuais, metodológicas ou editoriais substantivas feitas no Word devem ser **reconciliadas com o MD** antes de estabelecer a próxima versão canônica. Ajustes puramente visuais podem permanecer no DOCX.

## Responsabilidade e aceite

O assistente prepara conteúdo canônico e DOCX fiel; o proprietário ou revisores realizam/validam o acabamento manual e decidem eventual circulação e exportação. Revisão editorial ou visual **não equivale** a validação científica independente, A3, liberação de gates ou prontidão operacional.

**Aceite mínimo:** texto integral; títulos por estilos; legendas sem duplicação; alternativas acessíveis; quadros/tabelas editáveis, identificados e numerados; referências preservadas; hifenização automática desativada; fonte/versionamento rastreáveis; nenhuma alteração científica silenciosa.

## Transição

Aplicação **prospectiva** a toda nova entrega de apresentação e à próxima revisão de documentos existentes. Não converter retroativamente todos os documentos nem apagar relatórios ou provas PDF históricos: são registros, não fontes canônicas. O manuscrito científico adotou esse fluxo com o DOCX editorial **0.57**. Estilos particulares de periódicos ou instituições podem complementar, sem contrariar, esta política.

Esta política rege exclusivamente a **produção editorial e apresentação**. Mantêm-se integralmente as regras de [governança científica](../governance/04-governanca-garantia-revisao.md), o [STATE.md](../../STATE.md), os protocolos, os requisitos de revisão independente, os gates e as decisões operacionais.
