# Documento 244 — D2-CTGOV-E2: HTTP direto autorizado, DNS indisponível, STOP

**OES | 2026-10-23 | D2_CTGOV_E2_DIRECT_HTTP_DNS_FAILURE / NO_SOURCE_HTTP_RESPONSE / STOP**

## 1. Autoridade, encadeamento e delimitação

Após a primeira tentativa conectada D2-CTGOV-E1 sem resposta de origem, registrada no [Documento 243](243-d2-ctgov-e1-consulta-conectada-indeterminada-stop.md) e no CP262, o proprietário autorizou expressamente **“Execução http autorizada”**. O contexto inequívoco era a recomendação de **uma única requisição HTTP direta** aos mesmos parâmetros do preflight [Documento 242](242-d2-clinicaltrials-preflight-api-v2-prioridade-aprovada.md), com capacidade de observar status/corpo, **sem CI, código novo de aplicação, Neon/SQL, persistência de observações clínicas, custos ou modificação de produto**. Este documento registra **a única tentativa de execução HTTP direta** realizada sob essa nova autorização; não concede uma autorização contínua para novos mecanismos ou retries.

**Freshness Gate imediatamente anterior:** HEAD `427d94da3921e8ed4e7e39c0494142c9187f8f92` idêntico à `main`; CP262 confirmado vigente.

## 2. Requisição exata tentada (nenhuma resposta da fonte)

```text
GET https://clinicaltrials.gov/api/v2/studies?query.cond=Insomnia&query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&sort=%40relevance&pageSize=20&countTotal=true&format=json
Accept: application/json
```

**Cliente de execução:** `curl` em ambiente de execução efêmero; opções essenciais: `--request GET --retry 0 --max-redirs 0 --connect-timeout 8 --max-time 22 --dump-header ... --output ...`. Não foram construídos/alterados código do produto, script no repositório ou workflow CI. URL coerente com Doc. 242; nenhuma mudança da expressão, paginação, limite, ordenação ou fonte.

**Observações reais do comando:**

| Campo | Valor observado |
|---|---|
| Início, relógio UTC do executor | `2026-10-23T20:33:01Z` |
| Fim, relógio UTC do executor | `2026-10-23T20:33:01Z` |
| Mensagem de erro do cliente | `curl: (6) Could not resolve host: clinicaltrials.gov` |
| Exit code `curl` | `6` (falha de resolução DNS no ambiente de execução) |
| `curl` http_code | `000` — **valor interno de ausência de resposta**, **não HTTP status da API** |
| Content-Type/resposta JSON | Não observados |
| Bytes transferidos reportados | `0` |
| Redirects reportados | `0` |
| `totalCount` | `UNKNOWN`, não `0` |
| `returned_count` | `UNKNOWN`, não `0` |
| `nextPageToken` | `UNKNOWN` |
| NCT/PMID/DOI | `NOT_RETRIEVED` |
| UTC da fonte | `NOT_OBSERVED`; horários acima são **somente do executor** |

**Importante:** tentativa de chamar `curl` efetivamente realizada, mas **nenhum request HTTP comprovadamente recebido pela fonte**. Falha de DNS é propriedade observada **deste ambiente**; não revela disponibilidade real da API, status da rede externa do provedor, validade do parâmetro Essie ou composição de resultados. Sem bytes de resposta, não calcular checksum de uma resposta inexistente. Não salvar no GitHub cabeçalhos/JSON inventados; arquivos temporários do executor não constituem dados científicos.

## 3. Critério de interrupção e preservações

**Resultado:** `STOP / INDETERMINATE / DIRECT_HTTP_DNS_RESOLUTION_FAILED / NO_SOURCE_RESPONSE_OBSERVED`.

- **Uma tentativa HTTP direta somente**, sem repetição, sem novos endereços, sem uso de proxy alternativo e sem consultas opcionais aos controles `NCT03613519`, `NCT03366870`, `NCT03213132`.
- Os resultados prévios de PubMed/NCBI no D2 permanecem distintos; **não** tratar falha CTgov como dado negativo sobre ensaios.
- Não modificar [Documento 49](../products/49-caso-real-01-busca-triagem-inicial.md), Ficha N2 `OES-P-2026-000401`, GRADE, `ProductVersion`, `CurrencyState`, currentness, assurance, semânticas, gates nem prazo de baseline.
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`, M3 `BLOCKED`; D2 factual ainda parcial; D1 sintético restrito; BRG/SA/36 migrations inalterados. B1R1 histórico `EXPIRED_NOT_EXECUTED`.

## 4. Deliberação recomendada, não executada

Há agora **dois insucessos técnicos distintos**: E1 — ferramenta de abertura de URL sem resposta HTTP; E2 — cliente `curl` com falha DNS no ambiente de execução. Não há evidência de problema no endpoint nem ganho em repetir o mesmo método. **Evitar uma terceira tentativa improvisada**.

**Próximo `Prossiga`:** avaliar a menor via independente, com prova de DNS/rede/HTTP antes de execução científica, e pedir autorização específica se a via for CI/GitHub Actions ou ambiente externo; alternativa é export nativo oficial fornecido pelo titular ou **diferimento de D2-CTGOV e avanço de planejamento de stack/vertical slice**. Não abrir novo epoch, nuvem ou executor somente por pressão para “fazer a chamada funcionar”. Considerar a evidência D2 já obtida via NCBI ao decidir o benefício marginal. STOP.

**Estado final da tentativa:** `D2_CTGOV_E2_STOP_DNS_IN_EXECUTOR / CTGOV_SOURCE_AVAILABILITY_UNVERIFIED`.
