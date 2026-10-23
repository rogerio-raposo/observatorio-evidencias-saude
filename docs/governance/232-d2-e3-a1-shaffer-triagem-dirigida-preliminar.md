# Documento 232 — D2-E3/A1: Triagem científica dirigida de Shaffer (2026)

**OES | 2026-10-23 | TARGETED_SHAFFER_ELIGIBILITY_AND_OVERLAP_SCREENING | PRELIMINARY / UNRESOLVED_OVERLAP**

## 1. Mandato e limites

Autorização expressa `APPROVED — OES / D2-E3-A1 / TARGETED_SHAFFER_ELIGIBILITY_AND_OVERLAP_SCREENING` em conversa. Análise dirigida de Shaffer et al. (2026), PMID 42841437, DOI 10.1093/sleep/zsag264, para o produto `OES-P-2026-000401`, baseline OES 2026-10-04. Não é revisão sistemática nova, nem appraisal formal, nova meta-análise, GRADE, modificação da Ficha, garantia, currentness ou promoção de gate. Sem execução de workflows, Neon, SQL, serviços pagos ou ChatGPT Work.

## 2. Fontes efetivamente examinadas

1. [Shaffer 2026 — PubMed PMID 42841437](https://pubmed.ncbi.nlm.nih.gov/42841437/): resumo indexado e metadados. Publicado 2026-10-07; revisão de estudos SHUTi com busca bibliográfica declarada até 2025-10-07.
2. [Shaffer — Oxford Academic](https://academic.oup.com/sleep/advance-article-abstract/doi/10.1093/sleep/zsag264/8875162): resumo conferido. **Texto integral em PDF restrito pela editora.** Página da editora anuncia `Supplementary_material_zsag264.zip`; arquivo ZIP não pôde ser inspecionado por esta interface (formato binário não recuperável). Não afirmar leitura de Tabelas de inclusão, lista dos 10 RCTs ou suplemento.
3. [Hwang et al. 2025 — npj Digital Medicine / PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11903857/): características dos estudos na Tabela 1 acessíveis por indexação textual; comparações SHUTi, controle e tempo.
4. [Ritterband et al. 2017 — PubMed PMID 27902836](https://pubmed.ncbi.nlm.nih.gov/27902836/); [Hagatun et al. 2017/2019 — PMID 28345961](https://pubmed.ncbi.nlm.nih.gov/28345961/); [SHUTi OASIS 2025 — PMID 40681664](https://pubmed.ncbi.nlm.nih.gov/40681664/); [mecanismos cognitivos de Ritterband 2017 — PMID 29778918](https://pubmed.ncbi.nlm.nih.gov/29778918/).
5. Documentos internos de baseline: `docs/products/48-caso-real-01-dcbti-protocolo-n2.md`, `49-caso-real-01-busca-triagem-inicial.md`, `52-caso-real-01-sintese-atualizada.md`; prova técnica de detecção `docs/governance/231-d2-e2-cliente-ncbi-e-prova-conectada-cp256.md`.

Não se realizou nova busca sistemática ampla, extração por dois revisores ou revisão quantitativa.

## 3. Triagem do registro Shaffer

- **Tipo e novidade da referência:** meta-análise publicada em 2026-10-07, posterior ao baseline OES; referência bibliográfica nova para a atualização.
- **Escopo da busca da própria meta-análise:** até **2025-10-07**, anterior ao baseline OES; uma publicação de 2026 não equivale a estudos primários publicados em 2026.
- **Corpo amplo:** 29 publicações de 25 estudos, total relatado N=14.166, incluindo populações médicas, psiquiátricas e demograficamente variadas.
- **Subconjunto comparável possível:** 10 RCTs de SHUTi versus educação online. Desfechos ISI, SOL e WASO; ISI no pós-tratamento é adequado conceitualmente. Magnitudes sumárias relatadas no resumo para ISI variam SMD -1,03 a -0,85 **através de timepoints**, não sendo uma estimativa pós-tratamento única comparável diretamente ao SMD -0,93 (k=10) de Hwang.
- **Aderência ao PICO:** temática **SIM**; elegibilidade definitiva da síntese como fonte comparador-específica **CONDICIONAL**, exigindo tabela dos dez estudos, definição do controle, população, braço autoguiado e timepoint.
- **Incrementalidade:** **NÃO RESOLVIDA**, dado que a composição dos dez RCTs e o vínculo entre 29 publicações/25 estudos não puderam ser recuperados da fonte primária.

## 4. Matriz dirigida de estudo/relatório (NÃO É LISTA DE INCLUSÃO DE SHAFFER)

As linhas abaixo são **referências independentes conferidas ou previamente documentadas no OES**. Nenhuma delas pode ser rotulada `incluída em Shaffer` sem leitura da tabela/suplemento da própria revisão.

| Estudo/relatório | Identificador | Comparação / desfecho | Consta na base OES ou Hwang? | Vínculo com Shaffer 2026 | Julgamento |
|---|---|---|---|---|---|
| Ritterband 2017, EUA, N=303 | PMID 27902836, NCT01438697 | SHUTi autoguiado vs educação online; ISI; ~9 semanas | **SIM Hwang Tabela 1**; ensaio pré-baseline e citado no Doc. 49 | **Não verificável** sem tabela Shaffer | **Candidato direto conhecido**, evitar dupla contagem |
| Hagatun 2017 (impresso 2019), Noruega, N=181 | PMID 28345961 | SHUTi vs educação web; ISI; 9 semanas | **SIM Hwang Tabela 1** | **Não verificável** | **Candidato direto conhecido**, não novo na síntese-base |
| Vedaa et al. 2020, Noruega, N=1.721 | PMID 33328044; NCT02558647 | SHUTi vs online patient education; ISI pós; 9 semanas | **SIM Hwang Tabela 1 e OES Docs. 48–49** | **Não verificável** | **Candidato direto conhecido**, não novo na base |
| Ritterband SHUTi OASIS 2025, N=311 | PMID 40681664; NCT03213132 | SHUTi OASIS sozinho vs educação online: braço aderente; ISI; subgrupo idosos 55–95; braço com apoio separado | **SIM atualização narrativa OES Docs. 49/52**; posterior ao corte Hwang | **Não verificável**; publicado antes do corte declarado Shaffer | **Candidato direto conhecido**, com indirectness etária |
| Glozier et al. 2019, N=87 | Referência de Hwang Tabela 1 | SHUTi vs educação online; ISI; homens com depressão | **SIM Hwang Tabela 1** | **Não verificável** | **Possível evidência indireta/população específica** |
| Ritterband et al. 2011, N=28 | Referência de Hwang Tabela 1 | SHUTi vs lista de espera, câncer | **SIM Hwang Tabela 1** | **Não verificável** | **Não aderente ao comparador principal** |
| Estudo de mecanismos cognitivos 2018 | PMID 29778918 | Nova análise de **303 participantes do mesmo ensaio Ritterband 2017** | Relatório correlato pré-baseline, não um novo RCT | **Não verificável** | **Mesmo estudo / outra publicação**, deduplicar pelo NCT01438697 |
| Somzz, Sweetman e SleepioRx | PMIDs 39058549, 39257295, 41343796 | dCBT-I vs educação digital em outras plataformas | **SIM atualização narrativa OES** | Não inferir inclusão em revisão **específica de SHUTi** | **Fora do recorte de plataforma Shaffer**, sem excluir do PICO geral |

**Distinção essencial:** confirmação de que um estudo consta na síntese Hwang ou nos documentos do OES **não** comprova sua inclusão em Shaffer. A tabela dos dez estudos específicos de Shaffer ficou indisponível. Mesmo assim, os exemplos verificam o risco de dupla contagem e demonstram que o universo comparável contém estudos antigos já conhecidos.

## 5. Parecer preliminar de decisão

- **Referência elegível para triagem temática / sinal de atualização documental:** `YES`.
- **Elegibilidade para substituição ou incorporação da estimativa quantitativa do produto:** `NOT_ESTABLISHED`.
- **Sobreposição estudo a estudo dos 10 RCTs com Hwang/OES:** `UNRESOLVED` (0/10 confirmados por tabela fonte de Shaffer; isto **não** significa zero estudos em comum).
- **Estudo primário realmente novo para o OES identificado por Shaffer:** `NOT_DEMONSTRATED`, não `ABSENT`.
- **Classificação integrada da triagem:** `UNRESOLVED`, com **pertinência temática confirmada e sobreposição potencial material**.
- **Materialidade científica, alteração de magnitude/conclusão, GRADE ou currentness:** `NOT_ASSESSED`.

A busca da revisão de Shaffer encerrou-se em 2025-10-07, enquanto a data da publicação da revisão é 2026-10-07. A nova publicação pode acrescentar uma síntese alternativa de ensaios antigos, sem obrigatoriamente acrescentar ensaios novos ao OES. Nenhuma comparação direta das SMDs é justificável antes de harmonizar população, braço de intervenção, comparadores, estudos e timepoints.

## 6. Impedimento e próximo critério de decisão

Para resolver `UNRESOLVED`, bastará **um** dos seguintes insumos verificáveis, sujeito a autorização aplicável: (i) ZIP suplementar da editora, com relação dos 25 estudos e identificação dos dez RCTs de controle educacional; (ii) texto integral obtido legitimamente contendo a tabela dos estudos; ou (iii) tabela fornecida pelos autores. Não contratar acesso nem tentar contornar paywall. Com esse insumo, reconciliar por PMID/DOI/NCT e separar estudos primários de publicações correlatas. Sem o insumo, **manter estado inconclusivo**, não reiniciar buscas amplas, novo CI ou construção de conector.

**Persistência:** este documento é parecer científico preliminar isolado, não altera a Ficha nem os gates. **CP256 continua vigente** até próximo checkpoint proporcional.

**STOP — D2-E3/A1 executada com sobreposição integral não resolvida.**
