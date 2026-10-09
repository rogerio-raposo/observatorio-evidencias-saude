# 101 — Decisão Arquitetural de Escopo dos Contratos Offline de Resposta (PubMed / ClinicalTrials.gov)

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 4 — Protocolo de Atualização  
**Data:** 9 de outubro de 2026  
**Modo:** alto (decisão de escopo metodológico e arquitetural)  
**Status:** **SCOPE_DEFINED_NON_NORMATIVE — IMPLEMENTATION_NOT_STARTED — CI_NOT_RUN**  
**Dependências:** Documentos 51–53, 69, 78–80, 82–90, 94–100; CP144.  
**Escopo:** simulação estritamente offline de requests/responses das interfaces *já congeladas* do Epoch B1R1, sem execução real.

## 1. Decisão

**Aprovar para desenvolvimento exclusivamente um par de validadores determinísticos e offline** de request identity, parsing, integridade, cardinalidade e completude técnica de resposta das fontes PubMed ESearch e ClinicalTrials.gov API v2, usando apenas fixtures artificiais.

Não desenvolver nesta etapa um cliente de rede, executor de Opportunities, coletor operacional, scheduler, parser que grave diretamente no banco ou autorretificador de parâmetros. O trabalho é um hardening de ensaio, **não** extensão dos contratos congelados nem autorização factual de B1R1.

Os validadores recebem metadados sintéticos da request e payloads artificiais previamente existentes no disco da CI. Não fazem HTTP, DNS, ESearch, /studies, EFetch, ESummary ou chamada de conectividade. Um `PASS` local/CI indica apenas que um caso de teste artificial foi interpretado conforme o contrato.

## 2. Freshness Gate e evidências controladoras

No gate de 9/10:

- HEAD `main`: `3c33ca6ff8edbc0744b16b0a5111bb70686aa3ab`;
- CP144, `STATE.md`, `CHANGELOG.md` e ponteiro coerentes; sem commits posteriores ao CP144 no momento da verificação;
- Documento 100: ISE-T01–T24 = 24/24 PASS na CI 245, **sem** demonstrar qualquer parsing de API factual;
- B1R1 permanece `authorized_non_normative`, `started_at=NULL`, sem MeasurementEvents/Resolutions factuais.

Arquivos congelados de referência (Git blob SHA-1, não recalcular nem reescrever como resultado do teste):

| Arquivo sob `artifacts/topi-n2-dcbti-01/phase-b/` | Git blob SHA-1 |
|---|---|
| `pubmed-interface-v2.json` | `8f61b25c3bca5bb4f4da38867371955aec0e05e4` |
| `pubmed-query-v1.txt` | `6f783b731884e95ae92d8239366d9e404dc44310` |
| `clinicaltrials-interface-v2.json` | `621ed0252c028a33b666494f49a70a62e570a15c` |
| `clinicaltrials-query-v2.txt` | `e02987ce16c10cbb915499621de05fbfaee49930` |
| `measurement-design-b1r1.md` | `b3dfe5f2c6509cd66941e5c8d422a7a8c49cdfcd` |

A fonte canônica da **request B1R1** são esses artifacts e os Documentos 82/88/94/95, não defaults dinâmicos de bibliotecas nem resultados de pesquisa externa. Documentação oficial da NCBI/ClinicalTrials.gov é referência explicativa, não alteração do frozen design. Observação de incompatibilidade futura implica `STOP`/drift assessment, nunca modificação silenciosa.

## 3. Fronteira 1 — identidade da request congelada

### PubMed

- GET `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`;
- `db=pubmed`, `term` = conteúdo integral de `pubmed-query-v1.txt`, `retmode=json`, `retmax=10000`;
- não adicionar `reldate`, `mindate`, `maxdate`, `datetype`, `retstart`, `sort` ou outros parâmetros não congelados;
- validar identidade da request sobre sua representação normalizada e o artifact integral, não interpretar variantes científicas da query como equivalentes sem autorização.

### ClinicalTrials.gov

- GET `https://clinicaltrials.gov/api/v2/studies`;
- `query.cond=insomnia`, `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`, `format=json`, `pageSize=10`;
- página inicial sem `pageToken`; próximas páginas com `pageToken` igual ao último `nextPageToken` recebido;
- ordem dos parâmetros e percent-encoding equivalentes não mudam o escopo; o token de paginação não é filtro científico;
- qualquer filtro adicional, `sort` ad hoc, mudança de endpoint/query ou parâmetro de escopo inesperado é `REQUEST_CONTRACT_DRIFT`;
- não acrescentar `countTotal`, `fields` ou `pageSize` alternativo apenas para facilitar validação.

Comparar requests somente a metadados artificiais em memória/disco, **não** enviar requests geradas. Não expor tokens privados, segredos ou credenciais em logs.

## 4. Fronteira 2 — validação offline de ESearch JSON

Envelope esperado: objeto com `esearchresult`; `count` inteiro não negativo, admitindo forma textual decimal; `idlist` array de PMIDs textuais não vazios. Outros metadados podem existir, mas não substituem essas provas.

`complete` técnico **somente se**:

1. payload JSON estruturado e sem indicador de erro da source;
2. request sintética corresponde ao contrato congelado;
3. `count` é válido e `count <= 10000`;
4. `idlist` tem exatamente `count` entradas e cada PMID é semanticamente válido;
5. IDs únicos, sem duplicações ou inconsistências;
6. qualquer `retstart`/`retmax` de resposta, quando fornecido, é coerente com o cenário congelado, sem inferir completude por ausência de metadado.

`count=0` + `idlist=[]` válido significa **zero comprovado**, não falha. `count=10000` é limite permitido; `count=10001` é excedente **não concluído**. Lista truncada, erro da source, identificador repetido, cardinalidade divergente ou JSON inválido **não** podem gerar `complete`. Nenhuma segmentação ou segunda consulta automática.

Quando `count` existir mas a recuperação falhar, preservar o valor observado separadamente no relatório de diagnóstico, porém não afirmar `raw_result_count_status=known` como cardinalidade operacional concluída sem prova de completude — aplicar o runbook vigente.

Não usar ESearch como prova de datas de criação/publicação quando campos temporais não foram de fato devolvidos.

## 5. Fronteira 3 — validação offline de ClinicalTrials.gov API v2

Envelope esperado por página: `studies` array, com cada registro identificável por `protocolSection.identificationModule.nctId`, e `nextPageToken` ausente na última página. Campos textuais/temporais adicionais são opcionais, quando disponíveis, e não autorizam inferência.

Validar:

1. página inicial sem token de request;
2. cada token `nextPageToken` seguinte utilizado **exatamente uma vez** na request simulada da próxima página;
3. nenhuma página ou token esperado omitido, trocado, repetido ou em ciclo;
4. JSON de todas as páginas parseado com sucesso;
5. NCT IDs não vazios e únicos no conjunto materializado; duplicação de ID dentro ou entre páginas é anomalia a tornar a completude **não afirmável** até investigação, sem `dedup` silencioso;
6. término comprovado por **ausência** de `nextPageToken` ao final, não por quantidade de páginas ou tamanho inferior a `pageSize`;
7. campos de record `BriefTitle`, `OverallStatus`, `StudyFirstPostDate`, `ResultsFirstPostDate`, `LastUpdatePostDate` extraídos **quando presentes** e sem horários fictícios.

A implementação deverá documentar/testar os paths JSON concretos do schema v2 (incluindo os `*DateStruct.date`) com fixtures artificiais. Ausência de um campo temporal opcional não deve virar data inventada nem erro de cardinalidade. `NCTId` ausente/inválido é, diferentemente, blocker de identificação.

`totalCount`, se presente em fixture, pode auxiliar controle de coerência, mas não é solicitado pela request congelada e não é prova isolada de completude. `raw_result_count` somente pode ser proposto como cardinalidade dos identificadores materializados se todas as páginas e identities estiverem íntegros. Sem isso: **UNKNOWN ≠ ZERO**.

Se uma página intermediária falhar, o relatório pode listar IDs efetivamente observados na fixture e evidência da falha, mas não rotular o conjunto como completo. Um token repetido deve encerrar a avaliação offline em vez de entrar em loop.

## 6. Contrato de saída — relatório de diagnóstico, não MeasurementEvent

Definir um resultado local estável, proposto como `oes.temporal_offline_source_parse_report/0.1`, **sem persistência de banco**:

- `schema_version` e `synthetic_test_only: true`;
- `source_code`, `fixture_id` e `frozen_interface_blob_sha`;
- `request_contract_match`: `match|mismatch|indeterminate`;
- `parse_state`: `valid|invalid`;
- `retrieval_completeness`: `complete|incomplete|indeterminate`;
- `observed_source_count`: número textual/campo de origem se houver, preservado sem promovê-lo a número final;
- `derived_complete_cardinality`: inteiro **apenas se** retrieval completa e IDs íntegros, senão `null`;
- `identifier_set`: lista artificial e unicidade documentada;
- `minimal_records`: campos artificiais disponíveis, sem inferência de datas;
- `page_trace`: sequência sintética de tokens, checks e anomalias para ClinicalTrials.gov;
- `issues`: códigos estáveis e descrições explicativas;
- `evidence_paths`: referências a fixtures artificiais, sem arquivos factuais ou URLs solicitadas.

**Proibição explícita:** este relatório não pode conter `MeasurementEvent` factual, `execution_started_at`, `execution_status` decidido automaticamente, `OpportunityResolution`, `source_record_artifact_uuid` factual ou claim de ready-for-calibration. A categoria `retrieval_completeness` é **diagnóstico técnico da fixture**, não decisão operacional da tentativa real.

Separar duas camadas: `offline_parse_report` (máquina, fixtures) e futura interpretação factual, humana/operacional do runbook (somente após execução real, com timestamps, evidências e authorization).

## 7. Matriz mínima proposta de testes

**PubMed — OFF-P01–P12:** resposta vazia válida; um ID; 10.000 IDs gerados em memória; `count=10001`; lista menor/maior que `count`; duplicação; count não numérico/negativo; JSON inválido; resposta de erro; request drift; determinismo do relatório.

**ClinicalTrials.gov — OFF-C01–C16:** zero resultados com término; página única; duas páginas; múltiplas páginas; página faltante; ciclo de token; token vazio/inválido; NCT duplicado na página; NCT repetido entre páginas; payload conflitante; NCT ID ausente; página JSON malformada; falha na segunda página após primeira página válida; falha já na primeira; `pageToken` trocado ou filtro científico adicionado; campos temporais opcionais ausentes.

**Transversais — OFF-X01–X06:** freeze SHA preservados; nenhuma rede executada; nenhum write em PostgreSQL; relatório marcado sintético; erro não promovido a `completed`; execução reproduzível sem relógio factual nem autorização operacional.

Total de **34 casos propostos**; nenhum deles é PASS nesta decisão. Se um caso evidenciar interpretação ambígua do contrato existente, **STOP e retorno ao modo alto**, sem mudar enum ou aceitar heurística silenciosa.

## 8. Implementação e CI — fronteira técnica aprovada

Implementação candidata em Python 3 com biblioteca padrão (`json`, `unittest`, `pathlib`, `urllib.parse` somente para normalização **local**, nunca `urlopen`):

- `scripts/temporal_source_offline_contracts.py`: biblioteca pura de validação; nenhuma função que efetue HTTP;
- `scripts/validate_temporal_source_offline_contracts.py`: harness de testes determinísticos, sem dependência do banco;
- `tests/fixtures/f4-temporal-sources-offline/`: payloads e envelopes artificiais minimizados; fixtures de 10.000 PMIDs podem ser geradas em memória;
- `.github/workflows/validate-s5.yml`: etapa `F4-OFFLINE-SOURCE-CONTRACTS`, executada sem necessidade de serviços externos, e configuração `push.paths` para os novos arquivos.

A integração à CI deverá comprovar os 34 casos, as comparações com blobs congelados, ausência de rede e não alteração do estado B1R1; preservar as etapas existentes, ISE 24/24, prontidão pré-19/10, regressões e rebuild. Prova de CI somente após execução e inspeção dos logs e artifact reais.

**Não é necessário novo schema SQL ou migration.** Não alterar `pubmed-interface-v2.json`, `clinicaltrials-interface-v2.json`, queries v1/v2, schedules, measurement design, Documento 88 ou runbooks históricos somente para acomodar fixture.

## 9. Segurança epistemológica e ordem operacional

- Fixture sintética não é fato externo, medição científica, duração operacional ou evidência normativa.
- Não converter parse `complete` em `MeasurementEvent completed` sem request factual, identificação da Opportunity, guard de authority, timestamp e evidência contemporânea.
- Não criar `Search`, `SearchHit`, `MonitorCycle`, `UpdateSignal`, `Calibration Dossier` ou `CadenceObservation` reais.
- Não testar source access executando query target-specific antes de 19/10.
- B1R1 continua com activation apenas em **2026-10-19 08:00–09:00 America/Recife** sob live preflight `PASS`, seguido de Opportunities reais a partir de 09:00/10:30 quando aplicável.
- Divergência material de API descoberta posteriormente deve ser tratada como drift e devolvida à governança, não auto-normalizada.

## 10. Resultado e próximo passo

> **F4_OFFLINE_SOURCE_SCOPE = APPROVED_FOR_SYNTHETIC_DEVELOPMENT**  
> **F4_OFFLINE_SOURCE_IMPLEMENTATION = NOT_STARTED**  
> **F4_OFFLINE_SOURCE_CI_PROOF = NOT_AVAILABLE**  
> **FROZEN_INTERFACE_ARTIFACTS = UNCHANGED**  
> **B1R1_ACTIVATION = NOT_STARTED**  
> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**  
> **PHASE_5 = NOT_STARTED**

**Próximo bloco exato:** em **modo médio**, implementar os validadores e os 34 testes offline, integrar CI, executar/inspecionar evidência real da CI, demonstrar não mutação, documentar resultado e criar checkpoint. Antes de escrita, Freshness Gate. Pausa obrigatória até instrução `Prossiga`.

**Fim do Documento 101**
