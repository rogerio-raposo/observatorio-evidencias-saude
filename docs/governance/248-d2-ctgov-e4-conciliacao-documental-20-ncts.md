# Documento 248 — D2-CTGOV-E4: conciliação documental restrita de 20 identificadores NCT

**OES | 2026-10-23 | AFTER_CP265 | D2_CTGOV_E4_SCOPED_DOCUMENTARY_IDENTITY_CROSSWALK_COMPLETE / NO_FURTHER_NETWORK / D2_GLOBAL_PARTIAL**

## 1. Autoridade e método

Após [CP265](../../archive/handoffs/oes/OES_Continuidade_2026-10-23_CP265.md), o proprietário determinou **“Prossiga”**. O ato autoriza **uma atividade documental delimitada**: cotejar os **20 IDs NCT registrados nos logs da única execução autorizada** [GitHub Actions 40021883998](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40021883998) e no [Documento 247](247-d2-ctgov-e3-primeira-recuperacao-estruturada-parcial-cp265.md) com inventários científicos já persistidos. Não autoriza nova consulta ClinicalTrials.gov, PubMed, segunda página, lookup individual NCT, repetição de workflow, appraisal ou atualização de Ficha.

**Freshness Gate inicial:** `main` no SHA `c717e1f8e21bab53d7d8adbece3f3931b9983c6b`, compare `identical`. CP265 permaneceu vigente no início da atividade.

**Corpus documental efetivamente verificado:** [Docs. products/48](../products/48-caso-real-01-dcbti-protocolo-n2.md), [49](../products/49-caso-real-01-busca-triagem-inicial.md), [52](../products/52-caso-real-01-sintese-atualizada.md); [Docs. governance/232](232-d2-e3-a1-shaffer-triagem-dirigida-preliminar.md), [233](233-d2-e3-a1-reconciliacao-suplemento-shaffer.md), [234](234-d2-e3-a2-triagem-focal-pico-estudos-shaffer.md), [235](235-d2-e3-a3-avaliacao-metodologica-focal-zhou-nazem.md), [236](236-d2-e3-encerramento-restrito-rastreabilidade-shaffer-cp259.md) e [products/148–163](../products/154-reconciliacao-listas-artigos-clusters-reports-ovr01-dcbti.md) (preparação OVR dCBT-I, especialmente o Documento 154, que preserva clusters study/report). **Este é um corpus intencionalmente delimitado, não varredura de todos os arquivos do repositório.** Um teste de busca por código do GitHub retornou zero até para um ID comprovadamente presente nos documentos; esse índice não foi utilizado como evidência de ausência.

**Dado disponível da fonte externa:** o runner consumiu `630386` bytes de JSON e imprimiu **apenas NCTs, totalCount e paginação**; o conteúdo integral dos registros **não foi arquivado** nos logs. Portanto esta revisão compara **identificadores**, não títulos, intervenções, datas, status, `referencesModule`, elegibilidade, múltiplos relatórios ou materialidade clínica.

## 2. Matriz de 20 IDs em ordem literal de retorno

`KNOWN_DOCUMENTED` = mesmo ID NCT está expressamente associado a estudo/ensaio em documento científico OES anterior ao Documento 247. `NOT_IDENTIFIED_IN_SCOPED_INVENTORY` = ID não localizado no **corpus delimitado acima**, **não** evidência de novidade, inelegibilidade ou ausência no restante do OES/ClinicalTrials.gov. Nenhuma relação `POSSIBLY_RELATED` foi atribuída por semelhança verbal ou conjectura sem metadados verificáveis.

| Ordem | ID NCT | Classe documental | Vínculo previamente conhecido / limite | Evidência preexistente |
|---:|---|---|---|---|
| 01 | `NCT07836491` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 02 | `NCT03613519` | **KNOWN_DOCUMENTED** | Zhou 2022 — Direct PICO candidate, one trial with shared control | Docs. 49, 233, 234, 235 |
| 03 | `NCT07128927` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 04 | `NCT04986904` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 05 | `NCT03493958` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 06 | `NCT03279055` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 07 | `NCT04661306` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 08 | `NCT06067139` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 09 | `NCT00716872` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 10 | `NCT03390114` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 11 | `NCT04721067` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 12 | `NCT04986007` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 13 | `NCT04564807` | **KNOWN_DOCUMENTED** | Verlinden 2023 — INDIRECT_CONTEXTUAL; selected high-alcohol-use population | Doc. 234 |
| 14 | `NCT03213132` | **KNOWN_DOCUMENTED** | Ritterband/OASIS 2025 — Direct PICO candidate already known; autoguided vs online education and separate engagement-support arm | Docs. 232, 234 |
| 15 | `NCT01438697` | **KNOWN_DOCUMENTED** | Ritterband 2017 / Shaffer 2020 — Known trial and secondary report; same Study, not two RCTs | Doc. 232; Doc. products/154 |
| 16 | `NCT02410564` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 17 | `NCT05565833` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 18 | `NCT03327519` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 19 | `NCT04468776` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |
| 20 | `NCT03002402` | **NOT_IDENTIFIED_IN_SCOPED_INVENTORY** | No NCT-to-study match located in the inspected historical scientific inventory; identity, trial design and novelty **NOT_ASSESSED** | — |

**Total conferido:** 20 IDs únicos, **4/20 `KNOWN_DOCUMENTED`** e **16/20 `NOT_IDENTIFIED_IN_SCOPED_INVENTORY`**. **Zero** IDs confirmados como novos ensaios elegíveis a partir deste cruzamento; **zero** IDs rejeitados cientificamente; **zero** relações novas entre estudo e publicação verificadas pela API nesta etapa. Uma categoria "não identificada" não é uma categoria científica de exclusão.

## 3. Vínculos conhecidos e riscos concretos de dupla contagem

1. **`NCT03613519` — Zhou et al. 2022, PMID 35442432.** Um ensaio randomizado, dois braços de SHUTi (padrão e adaptação) comparados a **um controle compartilhado**. Não converter em dois RCTs e não duplicar o controle em futura análise.
2. **`NCT03213132` — Ritterband/OASIS 2025, PMID 40681664.** Um ensaio com braços autoguiado, apoio escalonado de engajamento e educação do sono; publicação complementar de 2026 é relato do mesmo estudo, não RCT adicional. O contraste autoguiado segue prioritário no protocolo N2, mas não foi reapreciado aqui.
3. **`NCT04564807` — Verlinden et al. 2023, PMID 38099849.** Já classificado `INDIRECT_CONTEXTUAL` por recrutamento de população com consumo elevado de álcool; estar na primeira página CTgov **não revoga** essa caracterização nem habilita pooling.
4. **`NCT01438697` — Ritterband et al. 2017, PMID 27902836; relatório secundário Shaffer 2020.** Documento 232 relaciona o RCT primário e análise cognitiva de 2018 ao mesmo estudo; o [Documento products/154](../products/154-reconciliacao-listas-artigos-clusters-reports-ovr01-dcbti.md) relaciona **Ritterband 2017 / Shaffer 2020** como um mesmo cluster study/report. **A quarta correspondência estava preservada na documentação antiga e não havia sido destacada no confronto inicial de apenas três controles do CP265.** Não representar esta recuperação como identificação de novo ensaio.

**Controle adicional conhecido que NÃO apareceu:** `NCT03366870` — Nazem 2023, PMID 37999953, consta no [Doc. 49](../products/49-caso-real-01-busca-triagem-inicial.md) e no [Doc. 234](234-d2-e3-a2-triagem-focal-pico-estudos-shaffer.md), mas **não** integra os 20 IDs desta primeira página. Não contar como um dos 20 nem inferir ausência no registro, ausência entre os 87 hits ou falha de sensibilidade da base; a busca foi uma página ordenada por relevância e há paginação.

## 4. Parecer integrado e limites

**Resultado documental:** `D2_CTGOV_E4_20_IDS_RECONCILED_AGAINST_SCOPED_OES_CORPUS / 4_KNOWN / 16_UNRESOLVED_IN_SCOPED_INVENTORY`.

A execução CTgov E3 estabeleceu **prova técnica** de fonte adicional com identificadores estruturados (`HTTP 200`, `20/87` na consulta literal, próxima página existente). A conciliação E4 reforça **prova de rastreabilidade** para quatro ensaios já documentados e preserva a distinção study/report. Não completa piloto científico multifonte, não mede sensibilidade/recall, não confirma 16 novos estudos, não fornece datas nem IDs PMID/DOI para os 16. A ausência de corpo JSON arquivado torna **impossível julgar identidade clínica ou elegibilidade dos 16** sem novas evidências. Tratar `known` como vínculo documental prévio, **não** como conferência independente da fonte atual por atributos do ensaio.

**Nada foi executado externamente nesta atividade**: zero GET, zero consulta ao ClinicalTrials.gov/PubMed, zero rerun/CI, zero novos artefatos factuais de fonte, zero Neon/SQL. A autorização E3 do único workflow está consumida. Sem revisão científica humana independente, sem mudança de `ProductVersion`, currentness, assurance, RoB/GRADE, Ficha N2, ou publicação.

**Estados inalterados:** Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, D2 factual global parcial, `M3 BLOCKED`, readiness operacional `NOT_READY`, BRG/SA/36 migrations segundo CP265. Documento 247 e snapshots de estado anteriores permanecem históricos, **não devem ser reescritos retroativamente**.

## 5. Encaminhamento proporcional — proposta de decisão, sem nova execução

A prova técnica interfontes já foi demonstrada com NCBI e CTgov. **Antes de fazer outro GET**, requerer que nova execução responda a uma dúvida científica discriminante: por exemplo, verificar **um subconjunto previamente justificado** dos 16 IDs ainda sem identidade, com metadados/proveniência, não apenas expandir para a página seguinte por rotina. Isso exige critério de escolha, escopo exato e aprovação separada. Alternativamente, **encerrar restritamente a subatividade de integração técnica D2-CTGOV-E3/E4** e avançar à definição do primeiro **vertical slice** de aplicação, mantendo D2 científico global aberto. A prova do primeiro GET e os quatro matches podem informar arquitetura `Study ↔ Report ↔ Source` sem construir novo conector nem redefinir stack por impulso.

**Recomendação:** não ampliar a coleta automaticamente. Solicitar ao proprietário uma escolha explícita entre (A) investigação científica dirigida dos IDs indeterminados mediante novo preflight e autorização, ou (B) reconhecer o marco de integração técnica alcançado e priorizar definição do primeiro incremento funcional/stack, sem declarar D2 global concluído. A alternativa B maximiza utilidade incremental se a meta imediata for demonstrar aplicação em funcionamento; a alternativa A é apropriada apenas com uma pergunta científica definida.

**Próximo `Prossiga`: formular uma comparação final das duas alternativas com um gatilho claro de mudança de prioridade, sem executar busca, stack, implantação ou novas edições científicas por inferência.** Não reabrir uma nova rodada de inventários dos mesmos 20 IDs sem dado novo.

**STOP — conciliação documental restrita completa; CP265 segue vigente por checkpoint proporcional.**
