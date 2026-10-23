# Documento 242 — D2-ClinicalTrials/P0: prioridade aprovada e preflight mínimo documental da API v2

**OES | 2026-10-23 | POST_F4_PRIORITY_APPROVED / CLINICALTRIALS_V2_PREFLIGHT_DOCUMENTARY_ONLY / CONNECTED_EXECUTION_NOT_AUTHORIZED**

## 1. Deliberação já concedida e fronteira do ato

O proprietário manifestou **“Prioridade aprovada.”** após a proposta do [Documento 241](241-prioridades-pos-fase4-d2-multifonte-delimitado.md): `APPROVED — OES / POST-F4-PRIORITY / D2_MULTISOURCE_READ_ONLY_FIRST`. O `Prossiga` subsequente autoriza **somente o preflight documental mínimo**, a fixação de parâmetros candidatos e a preparação de futura autorização separada. **Não é aprovação de primeira consulta conectada**, de execução de script/CI, uso de banco, serviço pago, coleta persistente, deduplicação autoritativa ou alteração de produto.

Fonte de verdade: Fase 4 [Doc. 240](240-decisao-final-gate-f4-encerramento-metodologico-documental-cp261.md) `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, `OPERATIONAL_NOT_READY`; Fase 5 `NOT_STARTED`. D2 factual parcial (Docs. 229–236); ligação NCT/PMID no inventário da Ficha N2, [Doc. 49](../products/49-caso-real-01-busca-triagem-inicial.md). Baseline científico N2: **2026-10-04**. B1R1 histórico `EXPIRED_NOT_EXECUTED`: a prova pública aqui proposta é **outro experimento**, não o seu restart nem seu `MeasurementEvent`.

## 2. Fundamentação técnica externa — leitura da documentação, sem requisições de dados

**Documentação pública consultada, exclusivamente descritiva:**
- Fonte oficial: [ClinicalTrials.gov API](https://clinicaltrials.gov/data-api/api), [About the API](https://clinicaltrials.gov/data-api/about-api) e [Study Data Structure](https://clinicaltrials.gov/data-api/about-api/study-data-structure).
- Parâmetros da API v2: [referência pública de operações e parâmetros](https://learn.microsoft.com/en-us/connectors/clinicaltrials/) (`GET /studies`, `query.cond`, `query.term`, `query.intr`, `pageSize`, `countTotal`, `sort`, `pageToken`). As páginas oficiais são renderizadas dinamicamente no leitor consultado; a descrição de operações e sintaxe foi cotejada com referência secundária e [anotações técnicas da API v2](https://trialredline.com/guides/clinicaltrials-gov-api).
- Endpoints públicos previstos pela API **v2**: `GET https://clinicaltrials.gov/api/v2/studies` para busca e `GET https://clinicaltrials.gov/api/v2/studies/{nctId}` para recuperar um estudo identificado. **Endpoints documentados, não testados em ambiente real nesta atividade.**
- O resultado JSON da busca é organizado em `studies`, possivelmente `totalCount` se solicitado, e `nextPageToken` se houver outra página. Não interpretar `totalCount` ou a primeira página como cobertura científica suficiente.
- Os campos dos registros (por exemplo, `protocolSection.identificationModule.nctId`, `conditionsModule`, `armsInterventionsModule`, `referencesModule`) são **expectativas de esquema a confirmar na primeira resposta real autorizada**. Não inventar valores ausentes.

**Nenhuma chamada** a `/api/v2/studies` ou `/api/v2/studies/{nctId}` foi efetuada no preflight. Não se declara versão de backend, esquema dinâmico, hit count, horário de resposta, status de registros ou funcionalidade efetivamente testados.

## 3. Requisição candidata literal — descoberta, limitada a uma página

**Solicitação primária proposta** (**não enviada**):

```text
Method: GET
Host: https://clinicaltrials.gov
Path: /api/v2/studies
Query:
  query.cond = Insomnia
  query.term = SHUTi OR "internet cognitive behavioral therapy" OR "digital cognitive behavioral therapy"
  sort = @relevance
  pageSize = 20
  countTotal = true
  format = json
```

**Interpretação:** condição insônia + expressão textual de dCBT-I/SHUTi. **A semântica e a aceitação da expressão Essie/aspas devem ser verificadas na execução autorizada**; esta proposta não reivindica que a sintaxe já tenha passado em teste real. Usar biblioteca HTTP/encoder para codificar espaços, aspas e operadores na URL definitiva, gravando a string efetivamente transmitida. Uma consulta restrita por termos não garante sensibilidade; títulos, intervenções e nomes dos braços podem não conter os termos esperados. `sort=@relevance` seleciona uma ordenação candidata; documentar ordem e repetibilidade, sem assumir que os primeiros 20 são representativos. Não impor `RECRUITING`, `COMPLETED` ou filtros temporais de publicação: ensaios concluídos são pertinentes e `StudyFirstPostDate`/`LastUpdatePostDate` **não equivalem** à data de publicação de artigos.

**Limite e paginação:** uma página, **até 20** estudos; registrar `totalCount` e `nextPageToken`, mas **não seguir** páginas adicionais no mesmo escopo. Se houver mais resultados, declarar `FIRST_PAGE_ONLY / COVERAGE_INCOMPLETE`, não “ausência de outros estudos”. Se a expressão tiver erro de sintaxe HTTP 4xx, **STOP** e solicitar aprovação de ajuste, em vez de usar estratégias de contorno improvisadas.

## 4. Controles dirigidos de identidade, separados da descoberta

Três ensaios de referência previamente documentados pelo OES e fontes primárias:
- **Zhou 2022:** `NCT03613519`; dois braços SHUTi, um controle compartilhado; [Doc. 234](234-d2-e3-a2-triagem-focal-pico-estudos-shaffer.md).
- **Nazem 2023:** `NCT03366870`; SHUTi versus educação sobre insônia.
- **Ritterband/OASIS 2025:** `NCT03213132`; braço autoguiado e outro com suporte de engajamento, mesmo RCT.

**Proposta de até três lookups complementares por ID, apenas se autorizados**, usando `GET /api/v2/studies/{nctId}`, omitindo a chamada se o registro integral já vier na primeira página. **Máximo proposto de quatro chamadas GET totais** (uma busca + até três detalhes), sem retries automáticos, sem rodar CLI/CI e sem disparar as três consultas neste preflight. Os três IDs são *controles de vínculo*, não uma amostra probabilística nem verificação de recall bibliográfico. Caso algum ID retorne 404 ou não possua vínculo a PMID, registrar incerteza em vez de forçar casamento.

## 5. Critérios verificáveis de uma eventual execução e relatório

**Oráculo PASS delimitado (técnico/documental, jamais científico):** a chamada autorizada devolve resposta interpretável e vinculada à requisição literal; IDs NCT únicos extraídos; atributos mínimos disponíveis; contagem `totalCount` somente se presente; página/token e horário UTC observados; vínculos com IDs OES marcados com base explícita; eventuais duplicações por referências separadas de duplicação do ensaio; nenhuma alteração de produto/gate. PASS **não** exige encontrar estudo novo nem todos os três IDs na busca textual, desde que controles dirigidos e lacunas sejam honestamente relatados.

**Oráculo PARTIAL:** `totalCount > returned_count` ou `nextPageToken` presente, campos científicos incompletos, estudos elegíveis incertos, lookup não encontrado, referências PMID/DOI ausentes; considerar um PASS **parcial de acesso/proveniência**, não de cobertura. Registrar ausência versus não consultado.

**Oráculo STOP/INDETERMINATE:** não autorização; HTTP 401/403/404/429/5xx, erro de schema/JSON, paginação opaca, número de chamadas ultrapassado, mudanças de parâmetros não previstas, falha de fonte/custos ou impossibilidade de atribuir NCT. **Sem retry automático ou novas fontes** neste experimento; documentar falha, não fabricar observações.

**Prova mínima:** fonte e versão/documentação consultada; endpoint, parâmetros codificados exatos e UTC; status HTTP, tamanho/contagem quando reportados, `returned_count`, `totalCount`, `nextPageToken` (presença/ausência), lista de IDs examinados, motivo de match, vínculo `study` vs `report`, classificação provisória (`known_in_OES`, `new_to_checked_inventory`, `linked_publication`, `out_of_scope_provisional`, `unresolved`) e razão das limitações. Se extrair PMID/DOI de campo do registro, confirmar de que se trata de referências submetidas ao registro, não necessariamente prova de publicação ou participação no estudo. Não reportar contagens não retornadas.

**Artefato futuro:** relatório textual pequeno de proveniência com dados exclusivamente públicos e sem segredo, eventualmente JSON/CSV delimitado **somente após autorização para registro de saída**; não persistir no banco nem no produto. O próprio GitHub é persistente: limitar o arquivo ao mínimo necessário, sem dump bruto irrestrito.

## 6. Condições científicas, de segurança e escalonamento

Este preflight **não é** uma busca sistemática, uma avaliação de atualização científica, um epoch temporal, currentness, M3, ou a primeira medição autoritativa do piloto antigo. O `UpdateSignal` de um novo NCT ou data recente não é por si materialidade. Invalidação científica autoritativa requer revisor humano habilitado (C1); owner/IA não simulam revisão especializada (C2); editoria e versão preservam histórico (C3); nenhuma promoção automática (C4); segurança/BRG/SA/migrations voltam a ser exigíveis antes dos atos técnicos a que se aplicam (C5); divulgar limites (C6).

**F4** `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; **D1** demonstrador sintético restrito encerrado; **D2** factual global parcial, D2-E3 documental restrito encerrado; **Fase 5** `NOT_STARTED`; 36 migrations `UNREVIEWED`; nenhuma nova CI, Neon/SQL, stack, serviço pago, especialista, alteração de GRADE/Ficha N2/assurance/currentness.

## 7. Pacote candidato à autorização operacional específica — NÃO APROVADO

```text
APPROVED — OES / D2-CTGOV-E1 / SINGLE_BOUNDED_PUBLIC_API_READ_ONLY
Autorizar exclusivamente uma consulta GET pública ClinicalTrials.gov
API v2 /studies com os parâmetros literais do Documento 242,
uma página de até 20 registros, countTotal, JSON e sort=@relevance.
Autorizar opcionalmente até três lookups GET por NCT já conhecido
(NCT03613519, NCT03366870 e NCT03213132), apenas se o registro
completo não aparecer na primeira página; máximo quatro GET no total.
Autorizar somente leitura e relatório mínimo de proveniência
e vínculo bibliográfico, com UTC e status/erros; sem retry ou
ampliação de consulta não aprovados. Se houver erro de sintaxe,
fonte indisponível ou ambiguidade relevante, STOP e relatório parcial.
Não autorizar código/CI, Neon/SQL, persistência factual operacional,
serviços pagos, mudança de Ficha, currentness, ProductVersion,
assurance/GRADE, M3 ou Fase 5. Preservar C1–C6 e CP261.
```

O texto acima é **proposta, não autorização concedida**. O `Prossiga` do proprietário nesta atividade executa somente a **preparação documental**. Não pedir nova aprovação do mesmo planejamento. O próximo ato é uma **decisão do proprietário sobre o pacote conectado**, ou a revisão pontual dos seus parâmetros; somente após aprovação específica poderá haver consulta à API.

**Resultado:** `D2_CTGOV_PREFLIGHT_DOCUMENTARY_COMPLETE / OWNER_CONNECTED_PROBE_DECISION_PENDING / NO_API_CALL_PERFORMED`. **STOP — sem execução conectada.**
