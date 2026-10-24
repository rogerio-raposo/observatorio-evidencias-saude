# Documento 253 — D2-E5-A2: contrato mínimo de preservação factual ClinicalTrials.gov

**OES | 2026-10-23 America/Recife | CP268 | `D2_E5_A2_CONTRACT_SPECIFIED / NO_COLLECTION / IMPLEMENTATION_NOT_AUTHORIZED`**

## Objetivo e autoridade

Após E5-A1, o proprietário determinou prosseguir com E5-A2: especificar como preservar **uma observação futura, separadamente autorizada** da API ClinicalTrials.gov v2, sem executar consulta, alterar código, acionar CI, publicar dados clínicos novos ou promover conclusão científica. O corpo JSON histórico da E3 (630.386 bytes, 20 de 87 resultados da consulta literal) **não foi arquivado** nem está recuperável como artifact da run 40021883998. Os 20 NCTs e os metadados agregados persistidos nos Docs. 247–248 são o registro histórico disponível; futuras respostas não podem substituir aquela observação.

## Reutilização e separação de contratos

Reutilizar **conceitualmente** os controles de `.github/workflows/d2-ctgov-single-public-get.yml`: `workflow_dispatch`, `contents: read`, GET único, sem retry/redirecionamento/fallback/lookups, timeout 20 segundos, teto de 2.000.000 bytes, no máximo 20 registros, validação de JSON e NCT único. A execução E3 já consumiu sua autorização; **não reutilizar essa autorização para despachar novamente**.

O artefato `artifacts/topi-n2-dcbti-01/phase-b/clinicaltrials-interface-v2.json` preserva um **contrato de interface preexistente**, com parâmetros `pageSize=10` e consulta normalizada distinta. Não modificá-lo e **não alegar equivalência semântica** com os parâmetros literais da E3 (`pageSize=20`, query.cond=Insomnia, query.term com SHUTi/digital CBT-I, `sort=@relevance`). Um eventual novo despacho deverá especificar literalmente URL e parâmetros, com novo ato de autorização.

## Pacote mínimo de uma futura observação

Produzir, em diretório isolado e temporário do runner, **dois arquivos de evidência e um resumo não sensível**:

1. `response.raw.json`: sequência **exata de bytes** recebidos por HTTP 200, respeitando teto de 2 MB; não reformatar, substituir, mesclar páginas nem alterar ordem.
2. `manifest.json`: metadados de proveniência, integridade e classificação, sem interpretação clínica.
3. `summary.json`: resultado técnico conciso nos logs/summary, **sem despejar o JSON inteiro**.

Campos obrigatórios do manifesto:
- `schema_version`, `activity_id`, `observation_id`, `repository_commit_sha`, `github_run_id`, `run_attempt`, `source_name`, `api_version_if_observed` (não inventar versão), `method=GET`, `requested_url_exact`, `requested_parameters` (pares efetivos, preservados), `started_at_utc`, `completed_at_utc`, `source_http_status`, `response_content_type`, `response_bytes`, `raw_sha256`, `returned_count`, `total_count_if_provided`, `next_page_token_present`, `nct_ids_in_return_order`, `scope_status`, `scientific_appraisal_performed=false`, `limitations`.
- Não incluir o valor de `nextPageToken` em logs públicos ou metadados permanentes; registrar apenas sua presença (sem considerar esse token um critério de elegibilidade).
- Datas e status dos registros, se extraídos para apresentação estruturada, devem conservar os valores fornecidos pela fonte e a indicação explícita de campo ausente. A versão antiga define `NCTId`, `BriefTitle`, `OverallStatus`, `StudyFirstPostDate`, `ResultsFirstPostDate`, `LastUpdatePostDate` como atributos mínimos *desejados*; não tratá-los como universalmente preenchidos.
- O manifesto deve distinguir **integridade de bytes** de autenticação/autenticidade da fonte; SHA-256 não comprova que a resposta reflete uma versão atual ou cientificamente correta da base.

## Aceitação e falha fechada

Sucesso técnico apenas se: GET autorizado e único; HTTP 200 + JSON; até 2 MB; `studies` lista de até 20 objetos; IDs NCT válidos e sem duplicações; `totalCount` válido se fornecido; presença do indicador de paginação reconhecida; arquivo bruto gravado sem transformação; `sha256(response.raw.json)==manifest.raw_sha256`; manifesto/JSON disponíveis e consistentes no pacote publicado. `PARTIAL_FIRST_PAGE_ONLY` é **resultado admissível e restrito**, jamais completude de busca. Se houver falha de captura, schema, escrita, hash, upload ou retenção verificável, **não declarar preservação bem-sucedida**. A ausência de registro retornado não constitui prova de inelegibilidade/novidade.

Evitar logar conteúdo de registros integralmente. Sem segundo GET para verificação, sem consultar URLs de referências e sem chamar PubMed. Nenhum modelo persistente, Neon/SQL ou adjudicação.

## Retenção e durabilidade

**GitHub Actions artifact é evidência temporária, não arquivo permanente.** Propor upload com `retention-days: 7`, `if-no-files-found: error`, permissão mínima `contents: read`, e verificar pós-execução a existência do artifact, seu tamanho e digest do ZIP, além da conferência do SHA-256 do JSON bruto dentro do pacote. A validade da retenção está sujeita a políticas do repositório e limites da plataforma; não presumir garantia de arquivamento até a data solicitada.

**Gate antes de qualquer futura execução conectada:** aprovar explicitamente destino durável, política de preservação e eventual publicação. Padrão mínimo proposto: armazenar permanentemente no GitHub apenas o manifesto *sem dados pessoais*, hash, identificação de run e apontador para evidência; **decidir separadamente se o JSON integral público pode/deve ser versionado**, considerando tamanho, licenças/termos aplicáveis, integridade, potencial conteúdo pessoal e crescimento do repositório. Se a durabilidade integral for requisito e ainda não tiver destino autorizado, classificar o resultado apenas `TEMPORARY_ARTIFACT_PRESERVED`, nunca `DURABLY_ARCHIVED`. Se a política exigir preservação integral permanente antes da coleta, não executar até esse destino estar definido.

## Encaminhamento e gates

E5-A2 estabelece **apenas contrato documental**. Etapa seguinte candidata E5-A3: preparar implementação mínima e testes **offline/sintéticos** da geração de manifesto, hash e invariantes, separados de eventual despacho real; execução de nova consulta requer decisão explícita posterior que detalhe parâmetros literais, limites, retenção e autoridade. Não alterar o workflow E3 retroativamente.

Preservar D2 global `PARTIAL`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`, readiness `NOT_READY`, M3 `BLOCKED`, CP268, Django estabilizado, BRG/SA e 36 migrations `UNREVIEWED`.

**STOP — E5-A2 especificado, nenhuma fonte consultada nem execução autorizada.**
