# Documento 255 — D2-E6-G1: minuta de autorização de observação factual controlada

**OES | 2026-10-24 | CP270 | `E6_G1_NOT_READY_PUBLIC_ARTIFACT_EXPOSURE / FACTUAL_CAPTURE_BLOCKED`**

## Política vigente — revisão humana por exceção (revisão autorizada em 2026-10-24; CP273)

**Decisão metodológica:** a captura e a preservação temporária de JSON bruto da API pública ClinicalTrials.gov **não exigem inspeção humana integral e prévia de cada resposta**. Aplicam-se validações técnicas automatizadas, classificação conservadora `ALLOW/HOLD` e **revisão humana por exceção** quando houver campos inesperados, erro de integridade, indício relevante de conteúdo sensível ou pessoal fora da política admitida, alteração material de esquema/termos ou dúvida sobre exposição/reutilização. `ALLOW` significa apenas aceitação técnica para a destinação previamente autorizada, nunca validação científica nem garantia de ausência de dados pessoais.

A revisão humana excepcional deve ocorrer **antes de disponibilizar** conteúdo classificado `HOLD`; se não houver solução tempestiva, não enviar artifact e registrar `STOP/HOLD`. Não registrar conteúdo bruto em logs. Dados permitidos pela política podem incluir contatos pessoais publicamente fornecidos pela fonte; a decisão de disponibilizar artifact em repositório público deve reconhecer explicitamente essa circunstância. Retirada ou expiração posterior não revoga downloads prévios.

**Gates distintos:** E6-G1 requer autorização específica do responsável pelo projeto para o GET único, URL e revisão exatas, e aceitação prévia da possível exposição pública do artifact temporário. E6-G2 permanece obrigatório e separado para incorporação ou arquivamento factual durável e publicação científica; a análise científica de elegibilidade, qualidade e interpretação é humana/metodológica segundo suas próprias regras, não se confunde com a triagem técnica de JSON.

**Controles já demonstrados:** Documento 267; [CI 40112908037](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40112908037) 38/38 testes sintéticos PASS em validação de estrutura, `HOLD`, integridade, rótulos e rechecagem pré-upload. A cobertura não comprova compatibilidade exaustiva da API nem segurança irrestrita. Continuam pendentes a decisão expressa sobre exposição pública, conferência aplicável de termos/URL/HEAD, e aprovação específica E6-G1. O teste de igualdade da URL completa indicado na auditoria histórica ainda carece de evidência específica, não inferir PASS.

**Limite da autorização recebida:** esta revisão é **somente documental**. Não autoriza GET, workflow dispatch, alteração de `if: ${{ false }}`, publicação nem alteração do Neon. Estado `E6_G1_NOT_APPROVED / FACTUAL_CAPTURE_BLOCKED`.

### Leitura histórica das seções abaixo
As referências anteriores a “revisão integral de todo o JSON”, responsável nominal por sua leitura, prazo de 48 horas ou impedimento automático por ausência dessa revisão representam **política superada por esta decisão**. Conservam valor de histórico, mas não são condições vigentes de E6-G1. A auditoria estática ao fim deste documento é um snapshot pré-hardening, atualizado materialmente pelo Documento 267.

## Decisão metodológica revisada — publicidade de dados brutos (2026-10-24; histórico, subordinado à política vigente acima)

**Parecer vigente: `E6_G1_PUBLIC_RAW_ARTIFACT_OPTION_ACCEPTABLE_CONDITIONALLY / NOT_APPROVED / WORKFLOW_BLOCKED`.** O conteúdo previsto provém do endpoint público de metadados do ClinicalTrials.gov. **Publicidade da origem não equivale a validação científica pelo OES, nem dispensa verificar o conteúdo exato e as condições de reutilização.** A exigência anterior de repositório privado como condição absoluta foi retirada por falta de necessidade demonstrada neste piloto. O repositório GitHub público existente pode hospedar o artifact temporário **somente após aprovação específica E6-G1 que aceite expressamente sua exposição potencial ao público**.

### Fronteiras técnicas e científicas

- `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED / TEMPORARY_ARTIFACT` identifica dados brutos de origem, sem interpretação, elegibilidade, endosso científico ou divulgação institucional de conclusões. Os rótulos devem constar **também no arquivo de manifesto e na descrição/identificação do pacote**, não apenas na documentação. A resposta `response.raw.json` deve permanecer inalterada.
- Antes de qualquer disponibilização pública, executar validações automáticas de fonte/endpoint, estrutura, limites de tamanho e quantidade, ausência de credenciais adicionadas pelo OES e inspeção conservadora dos campos. **Validação de esquema não prova ausência de dados pessoais ou sensíveis.** Se surgirem campos não previstos ou qualquer dúvida material sobre dados pessoais, sigilo ou condições de reutilização, impedir o upload e classificar `HOLD`, sem despejar o JSON em logs. A segurança dessas validações exige teste sintético antes de desbloquear E6.
- O artifact em repositório público **pode ser baixado antes de E6-G2**; expiração ou exclusão posterior não desfaz downloads já realizados. A aprovação de E6-G1 deverá reconhecer esse fato. E6-G2 controla **publicação durável, incorporação científica ou promoção institucional**, e não o primeiro acesso ao arquivo temporário.
- Em `REJECT/HOLD` após upload, cessar promoção/arquivamento público, registrar o ocorrido e deliberar descarte/retirada quando cabível; não afirmar confidencialidade retroativa. Se o JSON não puder ser revisto dentro dos sete dias, `STOP_INDETERMINATE`, sem nova coleta ou declaração de durabilidade.
- Não exigir repositório privado de staging como padrão; reavaliar ambiente restrito somente se a fonte, o esquema, o conteúdo inesperado ou requisitos legais o exigirem. O PostgreSQL/armazenamento definitivo será decidido na etapa arquitetural apropriada, sem criar infraestrutura provisória desnecessária.

### Pendências para E6-G1

`PUBLIC_ARTIFACT_EXPOSURE_ACCEPTANCE: PENDING`; revalidação dos controles pré-upload: `PENDING`; tratamento de exceções `HOLD`: revisão humana quando acionada, sem inspeção integral obrigatória; confirmação de termos aplicáveis: `PENDING`; nova autorização do dono com URL e commit exatos: `NOT_GRANTED`. A aprovação geral da atualização documental **não** é autorização de captura, desbloqueio ou publicação.

O workflow factual permanece com `if: ${{ false }}`. Não executar consulta por inferência.

## Objeto e limite decisório

Minuta **não executiva** para eventual aprovação de **uma única** recuperação factual de metadados públicos na API v2 ClinicalTrials.gov, destinada a capturar bytes brutos e submetê-los aos validadores E5-A3/E5-A5, com guarda **temporária** e validação automatizada, sujeita a revisão humana **por exceção** antes da exposição em caso de `HOLD`. Uma nova observação não reconstrói a resposta histórica E3. Este documento não autoriza GET, mudança de `if: false`, workflow dispatch, novas fontes, download público de artifact nem commit de JSON factual.

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
5. O GitHub Actions artifact é **temporário**, acessível conforme permissões e políticas do repositório; não é guarda durável. **Antes do despacho** aceitar expressamente a exposição pública potencial do artifact, confirmar prazo de retenção e prever fluxo de tratamento de exceções `HOLD`. Não se exige revisão humana integral rotineira.
6. Após a captura, executar controles técnicos automatizados e encaminhar **somente exceções `HOLD`** para revisão humana antes de qualquer disponibilização. A decisão de aceitar eventual exposição pública deve ter ocorrido antes de E6-G1. Classificar `HOLD/REJECT` ou aceitação técnica para o artifact temporário. Essa decisão é independente do sucesso de transporte e da aprovação E6-G1.
7. E6-G2 exige **nova aprovação específica** antes de qualquer commit factual. Arquivamento durável só será declarado após commit atômico dos três arquivos e recuperação/verificação posterior do conteúdo.

## Gates de execução e falha fechada

**Gate E6-G1 — ainda não submetido à aprovação executiva.** Antes de solicitar a autorização: reconfirmar SHA `main`, código e URL exata; confirmar operação única, permissões, política de retenção, aceite da exposição pública potencial e procedimento de decisão humana para exceções `HOLD`. Caso qualquer elemento divergir, **STOP** e revisar minuta.

A eventual aprovação de E6-G1 autorizará **apenas a captura/retensão temporária específica**, não publicação, novo GET adicional, inferências de elegibilidade, BRG/SA, Fase 5 ou ações fora do contrato.

**Critérios futuros:** `CAPTURE_TECHNICAL_PASS` se e somente se HTTP e schema válidos, bytes/manifesto/summary consistentes, artifact acessível e hashes conferidos; caso contrário `STOP_INDETERMINATE` ou `FAIL_CLOSED`. `PARTIAL_FIRST_PAGE_ONLY` não é avaliação de exaustividade.

## Estado e próximo passo

`D2_E6_G1_AUTHORIZATION_DRAFT_PREPARED / NOT_APPROVED / FACTUAL_WORKFLOW_BLOCKED`. A próxima atividade será revisão crítica da minuta e verificação dos pré-requisitos humanos/de publicação, antes de pedir autorização específica. CP270 vigente; D2 `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`.

## Auditoria estática pré-upload — controles existentes e lacunas (2026-10-24)

**Escopo da auditoria:** leitura do código e dos testes versionados em `main`, HEAD `b7a53d43da4fa60fa99e2dd3c08777311f97097f`, sem execução de teste adicional, workflow, requisição HTTP ou dados factuais. Resultado: `E6_G1_PREUPLOAD_STATIC_AUDIT_COMPLETE / LIMITED_GAPS_IDENTIFIED / GATE_NOT_READY`. A prova histórica da suíte permanece a execução sintética 27/27 PASS (`40069936004`), não reexecutada nesta auditoria.

### Cobertura já existente — não duplicar

| Controle | Implementação efetivamente encontrada | Limite da demonstração |
|---|---|---|
| Fonte e transporte | `e6_capture.py` constrói URL estática por `urlencode(..., quote_via=quote)`, método GET, `Accept: application/json`, `NoRedirect`, timeout 20s, uma chamada de `open()`, nenhuma rotina explícita de retry/paginação; `preserve.py` exige HTTPS e `clinicaltrials.gov/api/v2/studies` | `package_evidence()` valida domínio/caminho, **não igualdade com a query exata**; teste de E6 confere apenas nomes e `pageSize=20` |
| Limites e estrutura | `capture_once()` recusa HTTP distinto de 200, content-type não JSON ou corpo acima de 2.000.000 B; `preserve._validate()` exige objeto JSON com lista `studies`, até 20, identificadores NCT válidos/únicos, `totalCount` coerente e tipo do page token | Esquema é mínimo, não inventário/whitelist de todos os campos da resposta |
| Integridade e proveniência | `preserve.package_evidence()` grava bytes idênticos em `response.raw.json`, SHA-256 e manifesto, com execução, commit, horário, URL e contagens; staging não sobrescreve destino; `archive_preflight.prepare_archival_plan()` reabre os três arquivos, compara hashes/NCT/contagens/identidade, impede symlinks e colisões locais | Proveniência de resposta é fornecida pelo chamador; não equivale a autenticação independente da origem; nenhum commit factual autorizado |
| Escopo científico | Manifesto e resumo trazem `scientific_appraisal_performed: false`; preflight retorna `content_review: REQUIRED_NOT_PERFORMED` e `durably_archived: false` | Ainda **não há** os rótulos literais `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED` exigidos na política atual |
| Gating de execução | Job factual protegido por `if: ${{ false }}`; o fluxo não faz commit de evidência | Futura alteração desse guard deve ser aprovada separadamente; texto `owner_approval` não constitui evidência de autorização |

### Lacunas materiais restritas antes de E6-G1

1. **Inventário mínimo de conteúdo antes do upload público.** A validação estrutural aceita campos adicionais arbitrários em cada registro e no JSON raiz. Não existe revisão automática explícita de chaves inesperadas ou salvaguarda específica para conteúdo fora do escopo. É necessária uma **regra proporcional e testável**, adequada ao esquema real de metadados do ClinicalTrials.gov, que classifique `ALLOW/HOLD` e impeça upload ao ocorrer dúvida material. Não prometer identificação completa de dados pessoais por inspeção automatizada; os dados da fonte pública podem incluir contatos nominalmente identificáveis. A aprovação E6-G1 deve aceitar conscientemente a exposição pública dos campos permitidos.
2. **Rotulagem efetiva do pacote e do artifact.** O atributo booleano `scientific_appraisal_performed: false` já existe, mas é insuficiente para satisfazer literalmente a política `RAW_SOURCE_DATA / NOT_SCIENTIFICALLY_REVIEWED` no manifesto e na identificação do artifact. Ajustar com mínima alteração em produtor/validador e testes; **sem modificar os bytes do `response.raw.json`**.
3. **Gate antes do `upload-artifact`.** Atualmente, qualquer JSON que passe por `package_evidence()` e `prepare_archival_plan()` é automaticamente enviado como artifact pelo workflow factual assim que o job for liberado. Necessário tornar a política de conteúdo e rotulagem um bloqueio verificável **antes** do upload, com teste positivo e negativo puramente sintéticos.
4. **Contrato exato da URL.** Acrescentar assertiva sintética de igualdade da URL completa e ordem/valores dos parâmetros, para detectar drift no `e6_capture.py`; distinguir URL construída no chamador de validação genérica apenas de host e path pelo `preserve.py`. Não introduzir motor de políticas de URL.

**Não classificar como lacunas**: duplicar controles de 2 MB/20 NCT/hash, criar banco ou staging privado, construir detector universal de informações pessoais, repetir consulta ou ampliar para fontes externas.

### Sequência recomendada e autorização

Preparar proposta de **uma correção técnica pequena**, separadamente autorizada, incluindo rotulagem, filtro/decisão pré-upload proporcional e 2–4 testes sintéticos direcionados (URL exata, campos inesperados/HOLD, rotulagem e falha fechada). **Não executar coleta factual nem desbloquear `if: false`.** Rever E6-G1 após demonstração sintética e aceitação explícita da publicidade temporária. E6-G2 continua exclusivamente responsável pela eventual publicação durável e promoção científica.
