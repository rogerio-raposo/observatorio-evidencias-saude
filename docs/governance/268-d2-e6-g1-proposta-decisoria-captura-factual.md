# Documento 268 — D2-E6-G1: proposta decisória, sem autorização executiva

**OES | 2026-10-24 | Base CP273, Documentos 255 e 267 | HEAD de preparação `9cde5b46a89d1a9479209df4b25eb92cc00b7d9e` | `E6_G1_PROPOSAL_PREPARED / NOT_APPROVED / FACTUAL_CAPTURE_BLOCKED`**

## 1. Objeto estrito da futura decisão
Deliberar **uma única captura factual** de metadados públicos no endpoint de estudos da API v2 ClinicalTrials.gov, com guarda de **até sete dias** em GitHub Actions artifact potencialmente acessível ao público. **Esta minuta não autoriza a captura, o upload, o desbloqueio do workflow, execução conectada ou commit de evidência.**

A operação proposta utiliza método GET único, sem retry/redirect/paginação, timeout 20 s, no máximo 2.000.000 bytes e 20 estudos, exigindo HTTP 200 e JSON. Resultado `PARTIAL_FIRST_PAGE_ONLY` quando pertinente; jamais alegar busca exaustiva.

**URL literal de referência, idêntica ao contrato do teste offline:**

```text
https://clinicaltrials.gov/api/v2/studies?query.cond=Insomnia&query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&sort=%40relevance&pageSize=20&countTotal=true&format=json
```

Antes de qualquer futura execução, verificar HEAD do commit efetivamente despachado e igualdade literal URL/código.

## 2. Evidência técnica e controles
- [GitHub Actions 40113643586](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40113643586), revisão `9cde5b46a89d1a9479209df4b25eb92cc00b7d9e`: **39/39 testes offline PASS**, incluindo igualdade completa da URL e ordem dos parâmetros.
- [Run 40112908037](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112908037): 38/38 testes de preupload PASS; Documento 267 registra histórico.
- Captura controlada por `tools/d2_e5_preservation/e6_capture.py`; classificação conservadora `HOLD`, integridade SHA-256, proveniência, preservação dos bytes, rótulos `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED / TEMPORARY_ARTIFACT` e passo bloqueante `--verify-upload` imediatamente antes do artifact.
- `.github/workflows/d2-e6-a2-gated-capture.yml`: **job `if: ${{ false }}` confirmado** nesta preparação. Nenhuma consulta factual realizada aqui. Um simples input no dispatch não equivale à autorização do proprietário.

## 3. Condições externas e governança
NLM informa que a API v2 é mecanismo oficial de acesso programático aos registros, conforme:
- https://www.nlm.nih.gov/pubs/techbull/ma24/ma24_clinicaltrials_api.html
- https://www.nlm.nih.gov/pubs/techbull/ja25/ja25_clinical_trials_screen-scraping.html
- https://data.nih.gov/data-sources/clinicaltrialsgov-api

Os **termos específicos** e possíveis direitos sobre material de terceiros devem ser conferidos a partir de https://clinicaltrials.gov/about-site/terms-conditions antes do aceite final. O acesso automatizado público é documentado, mas **não constitui autorização irrestrita para qualquer reutilização ou garantia de ausência de informação pessoal**. A página dinâmica de termos não foi recuperada integralmente nesta verificação; portanto, **TERMS_FULL_REVIEW_PENDING**.

A política vigente, revisada no Documento 255, exige **validação automatizada e revisão humana apenas por exceção**. Não há inspeção humana integral obrigatória de cada JSON. Respostas inesperadas/duvidosas são `HOLD` **antes** do upload, sem corpo em logs; se o bloqueio não puder ser resolvido, não publicar artifact. `ALLOW` é técnico, não certificação científica.

**PUBLIC_ARTIFACT_EXPOSURE_ACCEPTANCE: APPROVED_BY_OWNER (2026-10-24).** O proprietário declarou expressamente: «Decido pela aceitação da exposição pública do artifact temporário». A decisão abrange exclusivamente o artifact temporário de dados brutos do ensaio E6-G1 no repositório GitHub público, potencialmente acessível por terceiros antes de E6-G2, inclusive com contatos já públicos na fonte. Expiração/exclusão posterior não revogam downloads. A aceitação não constitui autorização de GET, desbloqueio, nem aprovação jurídica irrestrita de redistribuição; `TERMS_FULL_REVIEW_PENDING` permanece.

### Registro técnico da fonte e proveniência (verificado em 2026-10-24)
O pacote E6 já registra em `manifest.json`: `source_name` (ClinicalTrials.gov API v2), `requested_url_exact`, `requested_parameters`, datas UTC de início/fim, `source_http_status`, `response_content_type`, `raw_sha256`, `repository_commit_sha`, `github_run_id`, `run_attempt` e `nct_ids_in_return_order`. O conteúdo `response.raw.json` permanece preservado em bytes. A rastreabilidade **técnica da observação** é suficiente para o escopo de captura E6-G1, sem infraestrutura adicional de catálogo de fontes.

Esses atributos são produzidos pelo processo de captura e não constituem autenticação independente da fonte, verificação clínica ou ligação automática de cada campo à estrutura relacional de proveniência do PostgreSQL. A reconciliação de identidades, a proveniência por informação e as decisões científicas pertencem a gates posteriores.

## 4. Condições para apresentação de pedido executivo E6-G1
1. Confirmar termos aplicáveis e limites para redistribuição/reuso do pacote bruto, inclusive eventuais conteúdos de terceiros, sem alegar liberação universal.
2. **ATENDIDO:** aceite explícito do proprietário quanto à potencial exposição pública temporária, com escopo e cautelas acima.
3. Congelar URL, revisão `main`, duração de retenção (7 dias), falha fechada e plano de tratamento de exceções.
4. Submeter **pedido separado de autorização E6-G1 para um GET factual único**. Somente depois, nova autorização/atividade delimitada para desbloquear o job e execução única, com Freshness Gate.
5. E6-G2 de incorporação/arquivamento factual durável segue independente e não autorizado.

## 5. Restrições inalteradas
D2 `PARTIAL`; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`; CP273 vigente; Neon e fixtures PG-A4 não tocados; nenhum acesso a produção, mudança de permissões, GET factual, postagem pública, commit factual ou serviço pago.

## 6. Diligência adicional sobre reutilização (2026-10-24)

Consulta às fontes oficiais disponíveis:
- A NLM descreve a API como recurso **público para extração estruturada**, preferível a screen scraping: https://www.nlm.nih.gov/pubs/techbull/ja25/ja25_clinical_trials_screen-scraping.html .
- O catálogo oficial federal https://catalog.data.gov/dataset/clinicaltrials-gov classifica o acesso ao conjunto como **public**, e fornece uma referência de licença no catálogo; tal metadado não substitui o texto específico e vigente dos termos do ClinicalTrials.gov.
- A página oficial https://clinicaltrials.gov/about-site/terms-conditions foi localizada, porém seu conteúdo integral não pôde ser recuperado pelo mecanismo de leitura consultado. Não declarar análise integral dos termos concluída com base em resumos de terceiros.
- Referências secundárias reproduzem recomendações de atribuição a ClinicalTrials.gov, identificação da data de processamento dos registros pela fonte, transparência sobre modificações e cautela com direitos de terceiros. **Esses detalhes ainda exigem confirmação direta** no texto aplicável antes de tratar redistribuição como juridicamente liberada.

**Lacuna técnica específica de atribuição:** o manifesto atual contém `started_at_utc` e `completed_at_utc` (observação realizada pelo OES), mas **não armazena comprovadamente a data de processamento dos dados pelo ClinicalTrials.gov**, que é um conceito diferente. Não afirmar que a rastreabilidade técnica já satisfaz toda obrigação de atribuição para redistribuição. Uma eventual melhoria terá escopo/autorizações próprios e não pode efetuar um segundo GET sem gate específico.

**Resultado:** `TERMS_FULL_REVIEW_PENDING` mantido; `PUBLIC_ARTIFACT_EXPOSURE_ACCEPTANCE: APPROVED_BY_OWNER` mantido; `E6_G1_NOT_APPROVED` e `FACTUAL_CAPTURE_BLOCKED` mantidos. A diligência não executou consulta ao endpoint factual de estudos.

## 7. Proporcionalidade da data de atualização da fonte (2026-10-24)

Distinguem-se: (a) `started_at_utc`/`completed_at_utc`, observação efetiva pelo OES; (b) `LastUpdatePostDate` ou campo equivalente em `statusModule`, associado a atualizações publicadas de **cada estudo** quando presente no JSON; e (c) `dataTimestamp` da visão de conjunto da API, indicado para consulta no endpoint **distinto** `/api/v2/version`. Não confundir nenhum desses conceitos nem inferir `dataTimestamp` do horário de captura. Documentação técnica oficial da API v2: https://www.nlm.nih.gov/pubs/techbull/ma24/ma24_clinicaltrials_api.html ; definição de atualizações por estudo: https://clinicaltrials.gov/expert-search ; referência de uso do endpoint version: https://clinicaltrials.gov/data-api .

**Decisão proporcional de preparação:** não adicionar GET de versão ao primeiro ensaio E6-G1; o contrato aprovado para deliberação permanece **um GET único** em `/api/v2/studies`. A proveniência existente (fonte, URL exata, parâmetros, horários OES, execução e SHA-256) identifica a observação bruta para fins técnicos, mas **não atesta o instante de processamento da base pela fonte** nem sana uma obrigação contratual de atribuição ainda não confirmada. Em coleta recorrente, comparação histórica ou paginação multirrequisição, avaliar novo gate e `dataTimestamp` explícito.

**Termos e gate:** a revisão integral de termos continua pendente; este parecer não afirma inexistência de requisitos de atribuição. A decisão do proprietário sobre exposição pública do artifact temporário já foi registrada, mas não equivale à aprovação executiva E6-G1. `if: ${{ false }}` permanece, nenhum GET executado.

**STOP — documento deliberativo apenas.**
