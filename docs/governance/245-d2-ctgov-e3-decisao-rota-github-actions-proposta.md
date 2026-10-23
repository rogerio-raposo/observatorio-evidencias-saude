# Documento 245 — D2-CTGOV-E3: seleção proposta de rota independente GitHub Actions

**OES | 2026-10-23 | CP263 CONTINUA VIGENTE | GITHUB_ACTIONS_SINGLE_GET_PROPOSED / OWNER_OPERATIONAL_APPROVAL_PENDING**

## 1. Mandato, evidência e decisão

O proprietário solicitou **“Prossiga com o encaminhamento recomendado”** após CP263, cujo próximo ato era **comparar** uma execução controlada de consulta pública ClinicalTrials.gov por ambiente GitHub Actions, export oficial manual e diferimento para seleção de stack. Esta autorização **não** é autorização específica para adicionar ou executar um novo workflow, nem autoriza repetir as tentativas HTTP anteriores.

**Freshness Gate inicial:** `main` no SHA `4e4e029d68dfdca9cfea117753f2219570c271b2`, `identical`.

Antecedentes: [Doc. 242](242-d2-clinicaltrials-preflight-api-v2-prioridade-aprovada.md) fixa os parâmetros e o limite de 20 registros; [Doc. 243](243-d2-ctgov-e1-consulta-conectada-indeterminada-stop.md) registra falha do mecanismo de abertura de URL; [Doc. 244](244-d2-ctgov-e2-http-direto-dns-stop.md) registra `curl exit 6` sem DNS no executor efêmero. Nenhuma das duas falhas oferece diagnóstico de status HTTP do ClinicalTrials.gov.

**Evidência de infraestrutura disponível:** workflow já existente `.github/workflows/d2-e2-single-ncbi-probe.yml`, disparado manualmente via `workflow_dispatch`, permissões `contents: read`, timeout 5 min, sem credenciais persistidas; [execução histórica 39977371270](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/39977371270) conferida por API GitHub nesta atividade: `completed/success`, `event=workflow_dispatch`, início `2026-10-23T15:20:08Z`, final `2026-10-23T15:20:18Z`. Isso comprova **saída conectada ao NCBI naquele job**, **não** acesso ou DNS para ClinicalTrials.gov.

## 2. Comparação proporcional

| Rota | Benefício decisório | Custo e risco | Julgamento |
|---|---|---|---|
| **A. Única ação manual GitHub Actions** | Observar DNS, status HTTP e JSON de origem via executor comprovadamente apto a consultar o NCBI, com logs auditáveis | Um pequeno arquivo de workflow somente manual, sem servidor persistente nem banco; consome minutos/quotas de Actions; dados em logs podem ser públicos conforme configurações; conectividade com CTgov ainda incerta | **Preferida**, condicionada a aprovação explícita de novo workflow e disparo único |
| **B. Export oficial de ClinicalTrials.gov pelo proprietário** | Obtém registros mesmo que ferramentas conectadas desta sessão falhem | Trabalho manual; exige registrar a estratégia, filtros, horário, total e versão para proveniência; export parcial é aceitável se declarado | **Fallback** se a rota A for inviável, sem testar múltiplos canais |
| **C. Diferir ClinicalTrials.gov; planejar stack/vertical slice** | Evita insistir em acesso instrumental; avança na aplicação | Renuncia, por ora, à reconciliação interfontes; não pode ser descrito como piloto multifonte realizado | **Fallback racional** diante de mais uma falha ou baixa utilidade |

**Recomendação:** **A**, com corte de escopo adicional para **um GET somente** — zero consultas complementares `/studies/{nctId}` nesta execução — para maximizar valor diagnóstico e minimizar gastos/iterações.

## 3. Contrato candidato de workflow mínimo — implementação ainda não autorizada

**Local candidato:** `.github/workflows/d2-ctgov-single-public-get.yml`. **Não modificar** o workflow NCBI já executado. `on: workflow_dispatch` como **único gatilho** (sem `push`/`schedule`/`pull_request`); `permissions: contents: read`; `concurrency` de grupo exclusivo `oes-d2-ctgov-e3-single` com não cancelamento; `runs-on: ubuntu-latest`; `timeout-minutes: 5`. Um único passo com Python 3 disponível no runner e biblioteca padrão `urllib.request`, **sem checkout e sem instalação de dependências, autenticação, tokens de terceiros, segredos, deploy ou upload automático de artefatos**.

**Request único literal**, codificado a partir destes parâmetros; sem fallback, retries ou redirects automáticos que causem GETs adicionais (tratar redirecionamento como STOP):

```text
GET https://clinicaltrials.gov/api/v2/studies
query.cond=Insomnia
query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"
sort=@relevance
pageSize=20
countTotal=true
format=json
```

**Registro mínimo de prova a escrever somente no resumo/log do job:** data/hora UTC do runner; URL completa codificada (consulta pública); status da conexão e código HTTP real se observado; `Content-Type`; classificação `PASS/PARTIAL/STOP`; se JSON válido: `returned_count` de até 20 registros, `totalCount` apenas se presente, presença de `nextPageToken` e IDs NCT (sem dados de pacientes ou dump JSON completo). Limitar bytes de leitura/armazenamento em memória; falhar fechado se formato/campos básicos não forem reconhecidos. O workflow deve ser inspecionado antes do despacho; nenhum campo científico será julgado elegível por código. **HTTP `000`, erro DNS, timeout e erro TLS** não podem ser reportados como `0` estudos.

**Custos e segurança:** usar apenas o consumo ordinário de minutos já habilitados do GitHub Actions; nenhuma contratação/upgrade de plano. Confirmar ausência de custo novo conhecido ou parar se quotas/plano não forem verificáveis. Logs e summaries não devem conter segredos; qualquer dado exposto será metadado público mínimo. A workflow file persistirá na `main` caso venha a ser aprovada; isto não é implantação de OES.

**Critério de parada:** uma execução somente. Falha da resolução DNS, TLS, 3xx, HTTP 4xx/5xx, esquema incompatível, tamanho excessivo, indisponibilidade ou divergência do literal = `STOP/INDETERMINATE`, sem nova consulta por outro mecanismo e sem alterar parâmetros sem autorização. Status `PASS` é somente **acesso técnico/proveniência na consulta literal**, não cobertura científica. O experimento não atualizará Ficha N2, GRADE, `currentness`, `assurance`, produto, Neon/SQL, M3 ou Fase 5.

## 4. Proposta de autorização específica — NÃO CONCEDIDA NESTE ATO

```text
APPROVED — OES / D2-CTGOV-E3 / ONE_SHOT_GITHUB_ACTIONS_PUBLIC_GET
Autorizar criar, exclusivamente na branch main, um workflow manual mínimo
d2-ctgov-single-public-get.yml, com contents:read, sem segredos,
sem checkout, sem novos pacotes e sem acionamento automático.
Após conferir o arquivo e novo Freshness Gate, autorizar apenas um
workflow_dispatch desse workflow para uma consulta GET pública
ClinicalTrials.gov API v2, uma página de até 20 registros, com os
parâmetros literais do Documento 245 e sem retries, redirects ou NCT
lookups. Registrar em logs apenas HTTP/status, UTC, limites de
paginação e IDs públicos recuperados; STOP se falhar.
Nenhum outro workflow ou CI será acionado. Não autorizar gastos novos,
Neon/SQL, código de aplicação, Ficha N2, GRADE, ProductVersion,
currentness, assurance, M3 ou Fase 5. Preservar C1–C6.
```

Caso a capacidade de despacho automático não esteja acessível, a aprovação para **criação** do workflow não deve ser interpretada como sucesso da sua **execução**: disponibilizar o link para disparo manual pelo titular e verificar o resultado somente quando houver execução efetiva.

## 5. Estado e próximo passo

**Resultado desta atividade:** `D2_CTGOV_E3_ROUTING_DECISION_PREPARED / OWNER_SPECIFIC_CI_AUTHORIZATION_PENDING`. Documento de deliberação **não aprova** nem executa CI; CP263 permanece vigente, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, D2 global parcial. A experiência prévia com NCBI sustenta a escolha de meio, não o resultado de CTgov.

**Próxima decisão:** aprovação expressa da autorização do §4, ajuste pontual ou diferimento. **STOP.**
