# Documento 243 — D2-CTGOV-E1: primeira consulta pública conectada, transporte inacessível e STOP

**OES | 2026-10-23 | D2_CTGOV_E1_STOP_TOOL_URL_INACCESSIBLE / SOURCE_RESPONSE_NOT_OBSERVED / NO_SCIENTIFIC_INFERENCE**

## 1. Autoridade específica e escopo aprovado

Após o [Documento 242](242-d2-clinicaltrials-preflight-api-v2-prioridade-aprovada.md), o proprietário declarou **“Aprovada a primeira consulta conectada”**. Interpretada como autorização para a consulta pública do ClinicalTrials.gov API v2 delimitada no Doc. 242 §7, em leitura, uma única página de até 20 registros, `countTotal=true`, `sort=@relevance`, formato JSON; até três lookups NCT conhecidos seriam **opcionais e somente dentro do escopo** de resposta bem-sucedida e limite total de quatro GET. Sem código/CI/SQL/Neon, alteração científica, integração de produto, custo ou publicação.

**Freshness Gate inicial:** `main` no SHA `ca23827ce961368a47951576640f19a9a9e0bd32`, compare `identical` antes de tentativa conectada. CP261 vigente. Fonte de consulta: endpoint público `https://clinicaltrials.gov/api/v2/studies`.

## 2. Requisição autorizada, forma literal e observação

```text
GET https://clinicaltrials.gov/api/v2/studies?query.cond=Insomnia&query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&sort=%40relevance&pageSize=20&countTotal=true&format=json
```

Correspondência à proposta: `query.cond=Insomnia`, `query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"`, `sort=@relevance`, `pageSize=20`, `countTotal=true`, `format=json`. Nenhum `pageToken`.

**Observação factual do mecanismo de acesso:** a URL foi submetida à ferramenta de abertura de recursos públicos; esta retornou **“URL ... is not accessible via this tool”**, sem conteúdo JSON nem resposta HTTP. Um primeiro endereçamento por esse mesmo mecanismo continha separadores `&` codificados como `%26` (URL não equivalente) e também falhou no nível da ferramenta. A representação correta, com separadores `&`, foi tentada uma vez, sem sucesso. **Não** foi efetuada nova requisição de dados em outro mecanismo, não houve lookups por `NCT03613519`, `NCT03366870` ou `NCT03213132` e não houve terceira tentativa. Trata-se de **duas tentativas de abertura em ferramenta**, nenhuma delas comprovada como request HTTP recebido pelo serviço externo. Não afirmar contagem zero de solicitações recebidas pelo servidor: o tráfego de rede da ferramenta não foi exposto.

**Campos de observação:** `HTTP_status=NOT_OBSERVED`; `source_UTC_response_time=NOT_OBSERVED`; `tool_invocation_date=2026-10-23` (somente data da atividade, **não** timestamp de resposta da fonte); `response_body=NOT_OBSERVED`; `totalCount=UNKNOWN`; `returned_count=UNKNOWN` (não é 0); `nextPageToken=UNKNOWN`; `NCT_identifiers=NOT_RETRIEVED`; `PMID_DOI_links=NOT_RETRIEVED`; `source_availability=NOT_DETERMINED`. O mecanismo de abertura pode normalizar parâmetros da URL, mas isso **não é prova de aceitação pela API**.

## 3. Classificação, limites inferenciais e condição de parada

**Resultado:** `STOP / INDETERMINATE / URL_INACCESSIBLE_VIA_AVAILABLE_RETRIEVAL_TOOL`.

- Não classificar como `HTTP_4XX`, `HTTP_5XX` ou indisponibilidade confirmada do ClinicalTrials.gov: nenhum status originário da API foi exposto.
- Não afirmar consulta v2 validada, incompatibilidade sintática, `totalCount=0`, ausência de registros novos, elegibilidade, cobertura, sensibilidade, deduplicação por ensaio ou mudança material da evidência.
- Nenhum estudo foi agregado; Zhou/Nazem/OASIS permanecem **controles planejados**, não recuperados nesta atividade. Nenhuma afirmação clínica foi alterada.
- Limite de STOP do Doc. 242 acionado por ferramenta incapaz de acessar o endpoint; sem retries adicionais, busca alternativa, código Python, execução CI, `curl`, Neon/SQL, conexão paga ou persistência factual operacional.
- Condições **C1–C6** do encerramento da Fase 4 preservadas; o piloto B1R1 histórico não foi reativado. A Fase 5 continua `NOT_STARTED`, `M3 BLOCKED`, readiness operacional `NOT_READY`, D2 factual parcial.

## 4. Próxima deliberação proporcional — não autorizada por inferência

A distinção factual é **limitação do canal de acesso**, não prova de inviabilidade da API pública. Antes de continuar D2-CTGOV, solicitar decisão explícita do proprietário por **um mecanismo alternativo único com capacidade verificável de GET JSON público** (por exemplo, execução pontual de utilitário HTTP/cliente mínimo em ambiente autorizado, ou export nativo oficial fornecido pelo titular). O próximo ato deve limitar a uma consulta, uma página e os mesmos parâmetros ou ajuste sintático previamente aprovado, com status HTTP/UTC/body mínimo verificáveis; não converter isso em arquitetura de conector ou stack de produção.

Também é legítimo **diferir D2-CTGOV** e seguir para a definição do primeiro incremento funcional/stack sem fingir que o ensaio multifonte foi realizado. Qualquer script/CI/novo GET/serviço externo exige autorização específica compatível; não interpretar o `Prossiga` genérico como licença para tentar indefinidamente.

**STOP — tentativa autorizada encerrada como tecnicamente indeterminada pelo mecanismo; sem resultados científicos novos.**
