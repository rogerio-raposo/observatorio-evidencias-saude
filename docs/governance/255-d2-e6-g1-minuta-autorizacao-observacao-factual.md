# Documento 255 — D2-E6-G1: minuta de autorização de observação factual controlada

**OES | 2026-10-24 | CP270 | `D2_E6_G1_AUTHORIZATION_DRAFT_PREPARED / NOT_APPROVED / WORKFLOW_BLOCKED`**

## Objeto e limite decisório

Minuta **não executiva** para eventual aprovação de **uma única** recuperação factual de metadados públicos na API v2 ClinicalTrials.gov, destinada a capturar bytes brutos e submetê-los aos validadores E5-A3/E5-A5, com guarda **temporária** para revisão antes de qualquer publicação. Uma nova observação não reconstrói a resposta histórica E3. Este documento não autoriza GET, mudança de `if: false`, workflow dispatch, novas fontes, download público de artifact nem commit de JSON factual.

## Referência congelada para deliberação

- Branch de referência: `main`; **HEAD examinado:** `16945a04f6ad9fe67da53b9360df13c4151c948a`. O SHA da **revisão realmente executada** deve ser reconfirmado após eventual autorização/desbloqueio e antes do despacho.
- Código de aquisição: `tools/d2_e5_preservation/e6_capture.py`; workflow: `.github/workflows/d2-e6-a2-gated-capture.yml`, atualmente **`if: ${{ false }}`**. Não tentar despachar enquanto bloqueado.
- **Método:** GET único, **sem** retry, redirect, paginação, lookups NCT, fallback nem PubMed; timeout de 20 segundos, 2.000.000 bytes brutos, 20 estudos no máximo, resposta HTTP 200 e content-type `application/json`. Apenas a primeira página, sem pretensão de completude.
- **URL codificada exata, derivada dos parâmetros em ordem e do `urlencode(..., quote_via=quote)` do código:**

```text
https://clinicaltrials.gov/api/v2/studies?query.cond=Insomnia&query.term=SHUTi%20OR%20%22internet%20cognitive%20behavioral%20therapy%22%20OR%20%22digital%20cognitive%20behavioral%20therapy%22&sort=%40relevance&pageSize=20&countTotal=true&format=json
```

- Pares efetivos: `query.cond=Insomnia`; `query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"`; `sort=@relevance`; `pageSize=20`; `countTotal=true`; `format=json`.
- Nenhum serviço pago, alteração de Neon, SQL, Django, implantação ou promoção científica.

## Evidências antecedentes e condições

1. 27/27 testes offline/sintéticos PASS na execução `40069936004`, envolvendo E5-A3, E5-A5 e E6-A2. Não comprova conectividade.
2. Artifact exclusivamente sintético de E6-A3, run `40084945270`, gerado, disponibilizado e recuperado; três arquivos e digest conferidos. **Não** é evidência factual.
3. O job factual possui trava verificável `if: false`; preenchimento de texto pelo operador **não constitui autorização**. Para uma futura execução, a aprovação substantiva deve indicar consulta exata e commit, seguida de **alteração isolada e autorizada** do workflow que possibilite **uma única** execução, com novo Freshness Gate. Preferir proteção que evite repetição inadvertida.
4. A captura futura deve reter `response.raw.json` original, `manifest.json` e `summary.json`, com proveniência observada, SHA-256 e preflight; log sem corpo integral. Upload como GitHub Actions artifact com `retention-days: 7`, `if-no-files-found: error`, checagem posterior de ID/tamanho/digest do ZIP e do SHA-256 do JSON bruto.
5. O GitHub Actions artifact é **temporário**, acessível conforme permissões e políticas do repositório; não é guarda durável. **Antes do despacho** definir pessoa responsável, acesso, calendário de inspeção integral do JSON, prazo até expiração e alternativa em caso de indisponibilidade ou reprovação para publicação. Se a revisão integral não for viável, **não executar**.
6. Após a captura, analisar **todo o JSON**, eventuais campos inesperados, dados pessoais e termos de reutilização, além da pertinência de disponibilização pública. Classificar `HOLD/REJECT` ou `APPROVED_FOR_PUBLIC_REPOSITORY`. Essa decisão é independente do sucesso de transporte e da aprovação E6-G1.
7. E6-G2 exige **nova aprovação específica** antes de qualquer commit factual. Arquivamento durável só será declarado após commit atômico dos três arquivos e recuperação/verificação posterior do conteúdo.

## Gates de execução e falha fechada

**Gate E6-G1 — ainda não submetido à aprovação executiva.** Antes de solicitar a autorização: reconfirmar SHA `main`, código e URL exata; confirmar operação única, permissões, política de retenção, responsável pela revisão, prazo e plano caso o JSON não possa ser publicado. Caso qualquer elemento divergir, **STOP** e revisar minuta.

A eventual aprovação de E6-G1 autorizará **apenas a captura/retensão temporária específica**, não publicação, novo GET adicional, inferências de elegibilidade, BRG/SA, Fase 5 ou ações fora do contrato.

**Critérios futuros:** `CAPTURE_TECHNICAL_PASS` se e somente se HTTP e schema válidos, bytes/manifesto/summary consistentes, artifact acessível e hashes conferidos; caso contrário `STOP_INDETERMINATE` ou `FAIL_CLOSED`. `PARTIAL_FIRST_PAGE_ONLY` não é avaliação de exaustividade.

## Estado e próximo passo

`D2_E6_G1_AUTHORIZATION_DRAFT_PREPARED / NOT_APPROVED / FACTUAL_WORKFLOW_BLOCKED`. A próxima atividade será revisão crítica da minuta e verificação dos pré-requisitos humanos/de publicação, antes de pedir autorização específica. CP270 vigente; D2 `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`.
