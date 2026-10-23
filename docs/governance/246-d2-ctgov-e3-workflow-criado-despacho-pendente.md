# Documento 246 — D2-CTGOV-E3: workflow mínimo aprovado, criado, aguardando único despacho

**OES | 2026-10-23 | D2_CTGOV_E3_WORKFLOW_CREATED / WORKFLOW_DISPATCH_PENDING / NO_SOURCE_RESPONSE_OBSERVED**

## 1. Autoridade expressa e fronteira

Após a [proposta Documento 245](245-d2-ctgov-e3-decisao-rota-github-actions-proposta.md) para uma consulta pública única via GitHub Actions, o proprietário declarou **“Workflow aprovado.”** A manifestação aprova o pacote `APPROVED — OES / D2-CTGOV-E3 / ONE_SHOT_GITHUB_ACTIONS_PUBLIC_GET`, incluindo criação do arquivo manual e **uma única execução posterior** exclusivamente desse workflow. Não autoriza CI recorrente, execução de outros workflows, consulta adicional, banco, gastos adicionais, análise científica ou alteração da Ficha N2.

**Freshness Gate:** ponto inicial `4139978911d15bd433d288db54e89efc6f44b986` contra `main` **identical**. A revisão documental do repositório mostrou que workflows antigos com gatilho `push` possuem filtros de caminho restritos, sem evidência de que a inclusão do arquivo específico `d2-ctgov-single-public-get.yml` acionaria outra CI. A política não depende de presumir que nenhum job possa existir fora do escopo inspecionado.

## 2. Entrega técnica efetivamente realizada

Arquivo novo:
`.github/workflows/d2-ctgov-single-public-get.yml`

Commit de criação:
`aaebd17b4246c2623c36954d8bedc01795eb4912`.

Contrato implementado neste arquivo:
- Apenas `workflow_dispatch` com `permissions: contents: read`, grupo `concurrency` isolado e timeout 5 minutos, runner `ubuntu-latest`.
- Um passo Python 3 com biblioteca padrão `urllib.request`, sem checkout, pacotes, segredos, banco ou artefatos persistentes.
- **Uma única instrução de abertura HTTP:** `GET https://clinicaltrials.gov/api/v2/studies` com os parâmetros **literais** do Documento 242/245: `query.cond=Insomnia`, `query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"`, `sort=@relevance`, `pageSize=20`, `countTotal=true`, `format=json`.
- Desabilita redirecionamento, não possui retry, fallback nem lookups opcionais `/studies/{nctId}`.
- Valida `HTTP 200`, Content-Type JSON, resposta de até 2 MB, objeto `studies` de até 20 registros, NCTs sintaticamente plausíveis/únicos, `totalCount` se presente e `nextPageToken` se presente; grava no **log e resumo do job** UTC do executor, URL efetivamente codificada, status HTTP observado, indicadores de paginação e IDs NCT.
- `PASS_TECHNICAL_QUERY_ONLY` e `PARTIAL_FIRST_PAGE_ONLY` não equivalem a validação científica, recall, materialidade ou currentness; falha de DNS/TLS/redirecionamento/HTTP/schema resulta `STOP_INDETERMINATE` e erro de job.

**Releitura independente do arquivo no GitHub:** Freshness Gate passou após o commit; gatilho manual único, leitura, bloqueio de redirecionamentos, limite 20, ausência de checkout e ausência de segredos confirmados em texto. A revisão não substitui execução do workflow nem prova ainda o funcionamento da API.

## 3. Limitação instrumental: despacho pendente

**Resultado no contexto atual:** `WORKFLOW_CREATED_DISPATCH_PENDING`. A conexão GitHub disponível suporta criação/leitura do YAML, comparação de SHA e consulta posterior a execuções/jobs/logs, **mas não expõe uma ação de workflow_dispatch**. Não realizar POST por mecanismo não autorizado, nem registrar run fictício. **Nenhum job desta atividade foi disparado pelo assistente e nenhum JSON/HTTP de ClinicalTrials.gov foi coletado.**

**Procedimento já autorizado ao proprietário, exatamente uma vez:**
1. Abrir [GitHub Actions — OES D2-CTGOV-E3 single public GET](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/workflows/d2-ctgov-single-public-get.yml).
2. Escolher **Run workflow**, branch **main**, e confirmar **Run workflow** apenas uma vez; se o botão não aparecer, registrar impedimento, não usar outro workflow.
3. Fornecer link da execução `https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/<ID>`. O assistente poderá verificar `conclusion`, passos e logs **daquela execução**, sem rerun.

**Critério de STOP:** uma execução total. Não reenviar diante de falha de DNS/HTTP/schema, nem modificar a consulta por inferência. Nenhuma alteração de stack/Neon/SQL, novos custos, `ProductVersion`, Ficha N2, GRADE, `assurance`, `currentness`, M3 ou Fase 5.

## 4. Estados preservados

Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY` (Doc. 240, condições C1–C6); readiness operacional `NOT_READY`; Fase 5 `NOT_STARTED`; D2 factual parcial; CP263 era vigente antes da criação deste checkpoint. BRG-03/06/07/08 bloqueados, BRG-09 parcial; SA-05/06/07/08/10 abertos/diferidos, 36 migrations `UNREVIEWED`; branch experimental preservada e nenhum banco tocado.

**STOP — workflow criado e verificado, execução aguardando disparo manual único pelo proprietário.**
