# OES — D2-E6-A1: protocolo de preparação para uma observação factual controlada

**Data:** 2026-10-24 | **Checkpoint de referência:** CP269 | **Classificação:** `D2_E6_A1_FACTUAL_OBSERVATION_PROTOCOL_PREPARED / NO_CONNECTED_EXECUTION`

## Autoridade e escopo

O proprietário aprovou **exclusivamente a preparação técnica e documental**. Este documento **não autoriza** nova consulta HTTP, workflow dispatch, coleta de dados, persistência de conteúdo factual, alteração de código, publicação de JSON ou promoção científica/operacional. A autorização E3, já consumida, não se renova. Não há pesquisadores disponíveis para adjudicação científica; isso não impede planejamento técnico não adjudicativo.

## Linha de base e parâmetros literais propostos (não executados)

Referência histórica: `.github/workflows/d2-ctgov-single-public-get.yml`, que executou uma leitura E3 **sem preservar o corpo**. Propor, para decisão futura separada, uma consulta com os **mesmos parâmetros literais** de E3; futura observação será nova coleta com seu próprio instante e não substituição da E3:

- Método: `GET`; origem: `https://clinicaltrials.gov/api/v2/studies`.
- Parâmetros **na ordem**: `query.cond=Insomnia`; `query.term=SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"`; `sort=@relevance`; `pageSize=20`; `countTotal=true`; `format=json`.
- Serialização de referência: `urllib.parse.urlencode(params, quote_via=quote)`. A URL completa exata **deve ser produzida e conferida literalmente no gate de autorização da execução**, jamais inferida desta descrição nem substituída por consulta normalizada `pageSize=10`.
- Uma única requisição sem retry, redirecionamento, paginação adicional, busca por NCT ou fallback; timeout 20s; HTTP 200 e `application/json`; máximo 2.000.000 bytes e 20 estudos. Nenhuma consulta PubMed.

## Sequência de execução proposta — requer autorizações posteriores

**Gate E6-G1 — autorização da coleta.** Aprovar a URL codificada exata, parâmetro literal, finalidade, limite de uma requisição, ambiente, custos nulos e retenção temporária; verificar HEAD e código antes de dispatch. Se discordância, STOP.

**E6-R1 — captura isolada.** Em futura execução autorizada, realizar GET único e guardar no runner a sequência de bytes `response.raw.json` sem transformação, com horários e cabeçalhos observados. Não transmitir registros integrais aos logs. Aplicar validadores E5-A3 e E5-A5 em sequência efetiva, com manifesto/summary produzidos a partir de proveniência **real**, e não placeholders sintéticos. Validar resposta, NCT, totalCount, hash e limites. A existência de código não é comprovação da integração — registrar sua execução.

**E6-R2 — armazenamento transitório e revisão.** Se houver êxito de captura, disponibilizar pacote isolado via artifact temporário de GitHub Actions (retenção solicitada: 7 dias, `if-no-files-found: error`), documentar ID, tamanho, digest do artifact e SHA-256 bruto. **O artifact é temporário, nunca equivalente a arquivo durável.** Revisão humana do **JSON integral**, campos imprevistos, termos de reutilização, risco de identificação e adequação de publicação; registrar decisão `APPROVED_FOR_PUBLIC_REPOSITORY` ou `REJECTED/HOLD`. Antes dessa decisão **não commitar o JSON**. A aprovação genérica da política E5-A4 não substitui aprovação específica de publicação factual.

**Gate E6-G2 — autorização de publicação.** Só após revisão integral documentada, verificar unicidade de observation_id e destino, hashes e integridade do pacote, política GitHub pública, HEAD atual e novo Freshness Gate. Aprovar explicitamente commit de pacote identificado. Se revisão não puder ocorrer antes da expiração do artifact, classificar `TEMPORARY_ARTIFACT_PRESERVED` e **não** declarar durabilidade; suspender novas coletas até resolver retenção ou destinação segura.

**E6-R3 — publicação atômica e leitura posterior.** Um único commit dos três arquivos (`response.raw.json`, `manifest.json`, `summary.json`) em `artifacts/d2/clinicaltrials-gov/observations/<observation-id>/`, sem sobrescrita; em seguida recuperar pela revisão publicada e verificar SHA-256 e associação ao commit. Git versionado fornece rastreabilidade, não garantia de inviolabilidade administrativa.

## Dependência de implementação

O workflow E3 atual **não** gera pacote nem faz upload; não deve ser disparado como se cumprisse E6. Será necessária uma **alteração técnica mínima, separadamente autorizada e revisada**, para fazer GET + geração E5-A3 + preflight E5-A5 + artifact temporário; não anexar publicação automática. Não introduzir banco, Neon, Django, nova arquitetura de serviços ou dependências pagas.

## Critérios de aceitação e interrupção

- `CAPTURE_TECHNICAL_PASS`: somente se resposta válida, bytes guardados, proveniência real, execução integrada observada e pacote temporário verificável.
- `PUBLICATION_REVIEW_APPROVED`: somente mediante inspeção efetiva do JSON integral e autorização específica; nenhuma inferência a partir de hash ou publicidade da API.
- `DURABLY_ARCHIVED_VERIFIED`: somente após commit atômico autorizado, recuperação dos três arquivos e conferência de seus hashes e identidade.
- `PARTIAL_FIRST_PAGE_ONLY`: admissível para resultados incompletos, nunca completude de busca ou avaliação de elegibilidade.
- Qualquer falha de rede, 200/content-type, tamanho, schema, NCT duplicado, proveniência, artifact ausente, conteúdo não aprovado, colisão/HEAD divergente ou hash divergente aciona `STOP/FAIL_CLOSED`; sem retry automático nem alegar sucesso.
- Nenhuma conclusão clínica, revisão independente, avaliação de risco de viés, seleção científica, GRADE, BRG/SA ou promoção para Fase 5.

## Próxima decisão

Priorizar uma **avaliação de implementação mínima E6-A2** que reutilize os componentes existentes, antes de autorizar qualquer execução conectada. Preservar CP269, D2 `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 bloqueado e demais gates.
