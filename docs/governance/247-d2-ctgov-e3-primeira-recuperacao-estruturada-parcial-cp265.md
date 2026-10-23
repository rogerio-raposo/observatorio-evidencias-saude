# Documento 247 — D2-CTGOV-E3: primeira recuperação conectada estruturada em fonte ClinicalTrials.gov, parcial

**OES | 2026-10-23 | CP265 | D2_CTGOV_E3_CONNECTED_RETRIEVAL_PASS_FIRST_PAGE_PARTIAL / SCIENTIFIC_APPRAISAL_NOT_PERFORMED**

## 1. Autorização, método e fonte primária da evidência

O proprietário aprovou `D2-CTGOV-E3/ONE_SHOT_GITHUB_ACTIONS_PUBLIC_GET` ao declarar **“Workflow aprovado.”**. O arquivo de workflow foi criado no commit `aaebd17b4246c2623c36954d8bedc01795eb4912`; o [Documento 246](246-d2-ctgov-e3-workflow-criado-despacho-pendente.md) preserva o momento anterior ao despacho. Após o proprietário fornecer o link da execução, a verificação factual foi feita **pelo conector GitHub**, sem novas consultas ao ClinicalTrials.gov.

**Evidência principal:** [GitHub Actions run 40021883998](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40021883998), workflow `OES D2-CTGOV-E3 single public GET` (`.github/workflows/d2-ctgov-single-public-get.yml`), `head_sha=546c14219ae20a60c110372d96868dcb5602fccf`, branch `main`, gatilho `workflow_dispatch`, `run_attempt=1`, `status=completed`, `conclusion=success`. Criado/iniciado `2026-10-23T20:47:07Z`, atualizado/concluído `2026-10-23T20:47:15Z`.

**Job verificado:** `clinicaltrials-one-get`, id `120648218066`, `completed/success`. Etapa `One public GET with fail-closed JSON summary` em `completed/success`; logs do job lidos e cotejados com o YAML canônico. **Uma invocação do fluxo manual e um ponto de chamada GET no programa, sem retries/redirects/fallback/lookups NCT implementados**. Logs não contêm contagem de requisições recebidas pelo servidor, nem são prova de que a fonte não teve tráfego auxiliar fora do fluxo; o contrato da rotina permitia um único GET, e a execução não apresentou sinal de retry.

## 2. Requisição literal e resultado observável

```text
GET https://clinicaltrials.gov/api/v2/studies?query.cond=Insomnia&query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&sort=%40relevance&pageSize=20&countTotal=true&format=json
```

| Campo extraído do JSON de execução nos logs | Valor observado |
|---|---|
| `started_at_utc` da chamada | `2026-10-23T20:47:12.448752+00:00` |
| `completed_at_utc` da chamada | `2026-10-23T20:47:12.942393+00:00` |
| `source_http_status` | `200` |
| `response_content_type` | `application/json` |
| `response_bytes` | `630386` |
| `returned_count` | `20` |
| `total_count` | `87` **na consulta literal** (não em toda a base/na PICO completa) |
| `next_page_token_present` | `true` — outras páginas **não consultadas** |
| `status` produzido pela rotina | `PARTIAL_FIRST_PAGE_ONLY` |
| Job e workflow GitHub | `success` — execução técnica sem erro |

**Interpretação obrigatória:** houve `PASS` de acesso técnico, resposta JSON e extração da primeira página. O estado `PARTIAL_FIRST_PAGE_ONLY` indica que **20 de 87 resultados reportados** pela consulta textual delimitada foram examinados **somente para extração automática de NCT**. **67 resultados adicionais indicados pela contagem não foram recuperados nesta execução.** Isso não demonstra sensibilidade/recall da estratégia para dCBT-I nem completude bibliográfica/científica. O JSON integral de `630386` bytes foi lido em memória no runner mas **não armazenado nem disponibilizado integralmente no log**; apenas campos e identificadores agregados foram persistidos no GitHub Actions. Não reivindicar acesso a dados completos de intervenção, desfecho ou referências de cada estudo.

## 3. Os 20 identificadores NCT retornados, em ordem reportada

01. `NCT07836491`
02. `NCT03613519`
03. `NCT07128927`
04. `NCT04986904`
05. `NCT03493958`
06. `NCT03279055`
07. `NCT04661306`
08. `NCT06067139`
09. `NCT00716872`
10. `NCT03390114`
11. `NCT04721067`
12. `NCT04986007`
13. `NCT04564807`
14. `NCT03213132`
15. `NCT01438697`
16. `NCT02410564`
17. `NCT05565833`
18. `NCT03327519`
19. `NCT04468776`
20. `NCT03002402`

**Confronto mínimo exclusivamente com identidades já documentadas:** `NCT03613519` — Zhou 2022; `NCT03213132` — Ritterband/OASIS 2025 (ambos no [Documento 234](234-d2-e3-a2-triagem-focal-pico-estudos-shaffer.md)). A primeira página inclui também `NCT04564807` de Verlinden 2023 já classificado pelo OES como contextual, mostrando que **não** se deve inferir elegibilidade a partir da busca textual. `NCT03366870` — Nazem 2023 — **não aparece na primeira página**; essa ausência local não constitui evidência de ausência na base, inelegibilidade, ou falha global de recuperação. O status de novidade, relação a publicações, elegibilidade, deduplicação por ensaio e materialidade dos demais IDs **não foi avaliado**.

**Valor metodológico estrito:** prova de conectividade da segunda fonte factual, identificação NCT estruturada e reidentificação de controles históricos já citados. **Não** prova nova evidência clínica nem altera o estado de nenhuma revisão ou produto.

## 4. Estado do experimento e fronteiras de autorização

**Resultado final da operação aprovada:** `D2_CTGOV_E3_CONNECTED_RETRIEVAL_PASS_FIRST_PAGE_PARTIAL` com `run_attempt=1`, `HTTP_200`, `TOTAL_QUERY_87`, `RETURNED_20`, `NEXT_PAGE_AVAILABLE` e `NO_SCIENTIFIC_PROMOTION`. O único despacho autorizado está **consumido**: não executar `rerun`, consulta de segunda página, lookup individual ou novo filtro com a mesma autorização.

Os insucessos anteriores foram de meios distintos, não de fonte: [Doc. 243](243-d2-ctgov-e1-consulta-conectada-indeterminada-stop.md) acesso de ferramenta de URL sem resposta de origem, [Doc. 244](244-d2-ctgov-e2-http-direto-dns-stop.md) resolução DNS no executor efêmero. Esta execução bem-sucedida do runner GitHub **superou o bloqueio instrumental desta trilha para uma consulta**, sem provar disponibilidade contínua da API.

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; D2 factual **globalmente parcial**; Fase 5 `NOT_STARTED`; readiness operacional `NOT_READY`; M3 `BLOCKED`. A Ficha N2 `OES-P-2026-000401` A2 interna, baseline 2026-10-04, GRADE, RoB, `ProductVersion`, `CurrencyState`, assurance, currentness, comparadores/desfechos e gates científicos **permanecem inalterados**. Sem revisão humana independente, nenhuma conclusão de elegibilidade material, nenhuma mudança no Doc. 49 e nenhuma escrita Neon/SQL. 36 migrations `UNREVIEWED`; BRG-03/06/07/08 `BLOCKED`, BRG-09 parcial, SA-05/06/07/08/10 abertos/diferidos. Condições C1–C6 do [Documento 240](240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md) preservadas.

## 5. Próximo incremento candidato — nova decisão, não execução

Recomenda-se **uma conciliação documental, sem novas chamadas HTTP**, dos 20 IDs extraídos com os estudos/relatórios já inventariados no OES, separando `known`, `possibly_related`, `unknown_to_checked_inventory`, com incertezas. Essa conferência **não** pode concluir eligibilidade material, novelty científica, relação PMID/DOI ou atualização de conclusão apenas por coincidência de NCT, e deve explicitar que **somente os 20 identificadores**, não os detalhes integrais dos registros, foram conservados. Se a meta seguinte exigir verificar intervenções ou artigos associados, solicitar expressamente **outra consulta delimitada** (ou export autorizado) e avaliar se o benefício justifica isso antes de ampliar custos/infra.

**Proposta operacional:** `D2_CTGOV_E3_COMPLETED_PARTIAL_FIRST_PAGE_ONLY / D2_GLOBAL_STILL_PARTIAL`. Nenhuma autorização implícita de ampliar para os 67 registros restantes nem de ativar a Fase 5.

**STOP — primeira recuperação ClinicalTrials.gov executada e verificada; análise científica material e novas requisições não autorizadas.**
