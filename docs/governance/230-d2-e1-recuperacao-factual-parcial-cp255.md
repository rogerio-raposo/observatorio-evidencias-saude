# Documento 230 — D2-E1: encerramento restrito da primeira recuperação factual (CP255)

**OES | 2026-10-23 | D2_E1_PARTIAL_RETRIEVAL_SEARCH_REPRODUCIBILITY_NOT_VERIFIED | FACTUAL_READ_ONLY_REPORTED**

## 1. Autorização e alcance

Após CP254, proprietário aprovou em conversa `D2-E1 / FIRST_FACTUAL_RETRIEVAL_READ_ONLY`: consulta PubMed pública, limitada ao PICO dCBT-I da Ficha N2 `OES-P-2026-000401`, baseline 2026-10-04, exame preliminar de até 20 referências, sem qualquer modificação da Ficha, execução de aplicação, infraestrutura, persistência factual no banco ou gate. **O uso de ChatGPT Work foi explicitamente rejeitado** e não será sugerido como dependência de continuidade.

## 2. Resultado relatado na conversa

O assistente relatou identificação individual das quatro referências-semente do Documento 48 (PMIDs 33328044, 41343796, 40075149, 42240717). Relatou também triagem exploratória de cinco registros, com destaque para **Shaffer et al. 2026, PMID 42841437, DOI 10.1093/sleep/zsag264**, publicação eletrônica informada em 2026-10-07, como **candidato para exame**, sem avaliação de impacto ou de duplicação de estudos primários. Esses elementos constituem **relato da recuperação em conversa**, não um export completo, validado, de resultados PubMed. Não atribuir a este checkpoint nova conferência bibliográfica independente.

A API E-utilities e a interface de resultados com parâmetros estruturados **não ficaram acessíveis pelo mecanismo utilizado** nas tentativas relatadas. Logo, consulta integral reproduzível, hit count bruto, cobertura, recall e lista completa ordenada **não foram obtidos**. Identificar referências individualmente não constitui PASS de sensibilidade da estratégia combinada. Não inferir inexistência de novos estudos elegíveis nem alteração da conclusão clínica.

**Estado factual de D2-E1:** `PARTIAL_RETRIEVAL / SEARCH_REPRODUCIBILITY_NOT_VERIFIED`. Tentativas repetidas pelo mesmo caminho ficam encerradas neste escopo; impedimento instrumental, não prova de inviabilidade científica do OES.

## 3. Limites científicos e de governança

Não houve triagem exaustiva, avaliação independente da síntese de Shaffer, verificação de sobreposição integral com Hwang/OES, avaliação de materialidade, nova certeza GRADE, nova ProductVersion, alteração de currentness, conclusão, assurance ou gate. A Ficha N2 segue no estado anterior A2 interno, sem expert review. O demonstrador D1 segue encerrado apenas em memória/sintético.

Não houve SQL/Neon, código de aplicação, CI, implantação, custos, nem nova stack. O presente commit guarda **somente relatório de estado/limitações**, não registros bibliográficos factuais importados para banco ou produto.

## 4. Continuidade proporcional sem Work

Evitar novo ciclo de pesquisa incompleta por mecanismos que não oferecem consulta literal e export verificável. A alternativa preferencial será obter, **mediante autorização específica**, export nativo do PubMed (`PMID`/CSV ou outro formato disponível) por navegador comum do proprietário ou outro mecanismo autorizado que entregue consulta, filtros, contagem, data e identificadores. A disponibilização de export pode permitir conferência documental local, sem ChatGPT Work, desenvolvimento de conector ou stack de produção.

Esta alternativa **não foi executada** neste checkpoint. Sua preparação não constitui autorização para coleta adicional, upload obrigatório de dados, revisão científica ou persistência operacional. Se o próximo mecanismo não estiver disponível, registrar o impedimento e decidir pelo diferimento de D2-E1, não repetir tentativas idênticas.

## 5. Estados preservados

D2-P0 preparação aprovada/CP254; D2-E1 autorização restrita utilizada e atividade **encerrada como parcial**, não validada. D1 `CLOSED_SYNTHETIC_IN_MEMORY_DEMONSTRATOR_ONLY`; A2-G4 diferido/não aceito; A2-G5/runtime não autorizado; branch de preservação `preservation/oes-d1-t2-a2-g4-cp247-unvalidated` em `96f16ec908b3f0f28199d841c90da471aa9e0ce1` intacta; SA-05/06/07/08/10 abertos/diferidos; Fase 4 `NOT_READY`, Fase 5 `NOT_STARTED`; 36 migrations `UNREVIEWED`.

**STOP — CP255 documental, sem promoção técnica/científica.**
