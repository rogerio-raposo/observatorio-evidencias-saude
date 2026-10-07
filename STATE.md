# STATE — Estado Atual do Projeto OES

**Última atualização:** 6 de outubro de 2026  
**Fase atual:** Fase 3 — Produtos do Observatório  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP74 — 2026-10-06**.

## 2. Estado das fases

- Fase 0 — Concepção e fundamentos: base inicial consolidada;
- Fase 1 — Manual Metodológico: base inicial dos Documentos 10–15 consolidada;
- Fase 2 — Modelo de Dados da Evidência: **concluída no nível de baseline arquitetural**;
- Fase 3 — Produtos do Observatório: **em desenvolvimento**;
- Fases 4–7: ainda não iniciadas formalmente.

## 3. Arquitetura

### OES-H1

**Arquitetura de referência.**

Núcleo relacional canônico + estruturas documentais controladas + object storage + projeções derivadas.

### OES-P1

**Baseline arquitetural da Fase 2.**

Foi promovido após:

- GATE F2-A PASS;
- GATE F2-B PASS;
- PoC-S4 PASS;
- PoC-S5 PASS;
- 15/15 critérios de promoção validados.

### PostgreSQL

**Implementação de referência validada para desenvolvimento/PoC.**

Não constitui escolha definitiva de stack de produção.

## 4. Evidência técnica principal

### F2-B

- run 37187885839;
- T01–T19 PASS.

### PoC-S4

- run 37188934837;
- S4-T01–T15 PASS.

### PoC-S5

- run 37189646452;
- regressão F2-B PASS;
- regressão S4 PASS;
- S5-T01–T17 PASS;
- artifact 11297653844;
- digest `sha256:ba8aed9373dfde8c5ee14c67f91084b2158c3b76bc98560fbc5a22555b133719`.

## 5. Matriz de promoção do Documento 25

> **15 VALIDADO / 0 PARCIAL / 0 NÃO VALIDADO**

## 6. Decisão de fechamento da Fase 2

Documento:

`docs/architecture/38-decisao-promocao-fechamento-fase2.md`

Decisão:

- OES-P1 promovido a baseline arquitetural;
- Fase 2 concluída;
- schema de produção não congelado;
- stack de produção não escolhida;
- evolução futura deve ocorrer por migrations controladas.

## 7. Reservas metodológicas/operacionais

Ainda não finalizados:

- templates individuais dos produtos;
- ApplicabilityAssessment operacional;
- protocolo de atualização/monitoramento;
- automação e IA;
- infraestrutura de produção;
- autenticação/autorização;
- backup/HA.

## 8. Fase 3 — estado atual

Documento 04 — **Governança de Garantia Metodológica, Aprovação e Revisão**: vigente como regra transversal A0–A3.

Documento 40 — **Taxonomia e Arquitetura dos Produtos do OES**: consolidado.

### Ficha de Evidência — N2

Documentos 41–67: trilha inicial especificada, implementada e validada ponta a ponta.

Estado do Caso Real 01:

- Product `OES-P-2026-000401`;
- assurance **A2**;
- `publication_date=2026-10-04`;
- `published`;
- `publishable=true`;
- expert independent review não realizada;
- run final **37229070210** = PASS.

### Resposta de Evidência — N1

Documentos 68–85: trilha inicial especificada, implementada e validada ponta a ponta.

Estado do Caso Real N1-01:

- Product `OES-P-2026-000501`;
- ProductVersion atual = 2;
- assurance **A2**;
- `publication_date=2026-10-05`;
- `published`;
- `publishable=true`;
- expert independent review ausente;
- primeira verificação adversarial = REVISE;
- segunda verificação = PASSED;
- run final **37362554094** = PASS.

### Evidence Scan — N0

Documentos 86–98: trilha inicial especificada, implementada e validada ponta a ponta.

Arquitetura/contrato:

- migration 013;
- EvidenceScanView `oes.evidence_scan_view/0.1`;
- publication gate N0;
- template Markdown próprio;
- presentation map;
- renderer/validator;
- nenhuma nova tabela/coluna;
- Synthesis/Certainty/RiskAssessment não obrigatórios;
- scan formal persistente exige A2;
- scan interno pode encerrar em A1.

Validação técnica do contrato/template:

- ES-T01–T15 PASS;
- F3-ES-TEMPLATE PASS;
- migration 013 idempotente;
- rebuild through migration 013 PASS.

Caso Real N0-01 — GenAI/LLMs e apoio à saúde mental:

- Question `OES-Q-2026-000601`;
- Investigation `OES-I-2026-000601`;
- Product `OES-P-2026-000601`;
- ProductVersion 1;
- depth `N0`;
- maintenance `M0`;
- maturity `partially_synthesized`;
- seis fontes centrais;
- duas buscas exploratórias;
- três controvérsias;
- três gaps aparentes;
- três candidate questions;
- routing `N2`;
- `requires_question_reformulation=true`;
- AI methodological verification = `passed`;
- owner governance approval = ausente;
- expert independent review = ausente;
- assurance final = **A1**;
- editorial status = `under_review`;
- publication_date = NULL;
- publishable = `false`;
- uso = artefato interno de roteamento.

Validação final do caso real N0:

- run **37382201584** = **success**;
- commit validado `eb503c571557b5b7078b6f148e9ca9c0651da2a4`;
- artifact **11374937122**;
- digest `sha256:be56277103192065dedf555423191d3d2f8fca149f7f568a6c8f54c0b67b8b18`;
- RN0-T01–T13 PASS;
- RN0-A1-T01–T08 PASS;
- RN0-TEMPLATE-A0 PASS;
- RN0-TEMPLATE-A1 PASS;
- rebuild A1 PASS.

Produtos com trilha inicial consolidada:

1. **Ficha de Evidência — N2** — caso real A2/published;
2. **Resposta de Evidência — N1** — caso real A2/published;
3. **Evidence Scan — N0** — caso real A1/interno, não publicado.

### Síntese Rápida de Evidências — N3

Documentos 99–114:

- 99 — especificação científica e funcional;
- 100 — revisão de coerência e decisão arquitetural;
- 101 — contrato de dados;
- 102 — resultado da validação técnica: **PASS**;
- 103 — contrato de renderização;
- 104 — especificação do template operacional;
- 105 — resultado da validação do template: **PASS**;
- 106–110 — Caso Real N3-01: protocolo, busca/seleção, appraisal, síntese/GRADE/SoF e validação técnica A0;
- 111 — primeira verificação adversarial: **REVISE**;
- 112 — busca suplementar corretiva;
- 113 — segunda verificação adversarial: **REVISE**;
- 114 — encerramento experimental controlado.

Implementação validada:

- migration 014;
- `investigation.method_decision`;
- `investigation.quality_control_record`;
- RapidEvidenceSynthesisView `oes.rapid_evidence_synthesis_view/0.1`;
- publication gate N3;
- template/presentation map/renderer/validator;
- validator dedicado do Caso Real N3;
- RS-T01–T15 PASS;
- F3-RS-TEMPLATE PASS;
- rebuild through migration 014 PASS.

Governança N3 consolidada:

- N3 formal exige A3;
- A3 não substitui controles humanos qualificados de etapa;
- AI quality controls são transparentes e não satisfazem qualified human controls;
- technical PASS não equivale a methodological PASS;
- adversarial `revise` não eleva assurance;
- busca N3 deve ser sistemática, reproduzível, documentada e proporcionalmente abrangente;
- padrão inicial: pelo menos duas bases bibliográficas relevantes, salvo exceção metodologicamente defensável.

### Caso Real N3-01 — ambient AI scribes

Product:

- `OES-P-2026-000701`;
- ProductVersion 1 = superseded;
- ProductVersion 2 = current;
- depth `N3`;
- maintenance `M1`;
- editorial status `under_review`;
- assurance **A0**;
- `publishable=false`;
- `publication_date=NULL`.

Corpo experimental:

- três estudos randomizados/comparativos principais;
- 11 Results estruturados;
- 10 appraisals;
- quatro SynthesisVersion narrativas;
- GRADE experimental: 3 LOW + 1 VERY LOW;
- seis AI quality controls, todos `qualified=false`.

Primeiro adversarial:

- resultado **REVISE**;
- motivo: cobertura insuficiente/não duplicação após falha do Europe PMC;
- correção: ProductVersion 2 com terminologia ampliada, terceira Search, 20 hits, 34 screening decisions e 13 referências.

Segundo adversarial:

- resultado **REVISE**;
- motivo: arquitetura de busca ainda insuficiente para N3;
- PubMed foi a única base bibliográfica executada de forma reproduzível;
- Europe PMC indisponível via API/interface;
- OpenAlex direto indisponível;
- publisher/DOI/citation chasing não equivale a segunda base bibliográfica;
- nova busca adversarial continuou encontrando estudos elegíveis, tornando a exceção de uma base não defensável.

Estado final:

> **A0 experimental / metodologicamente bloqueado / não publicável.**

Não criar ProductVersion 3 sem segunda base bibliográfica relevante e reproduzível.

Validação técnica final:

- run **37413884319** = **success**;
- commit validado `f2ba21eaaa2d3c43a95ceb908dd0b097b8e9a1b4`;
- artifact **11389784878**;
- digest `sha256:c4b53864e60be656a1e3de9039b8480746bbeff8f9fcf5b76257989a47a73b58`;
- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- regressões e rebuild PASS.

### Revisão de Evidências — N4

Documentos 115–122:

- 115 — especificação científica e funcional;
- 116 — revisão de coerência e decisão arquitetural;
- 117 — contrato de dados;
- 118 — resultado da validação técnica do contrato: **PASS**;
- 119 — contrato de renderização;
- 120 — especificação do template operacional;
- 121 — resultado da validação do template/renderização: **PASS**;
- 122 — Infrastructure Readiness Gate pré-caso real: **NOT_READY**.

Implementação validada:

- migration 015;
- `investigation.reviewer_assignment`;
- extensão de `appraisal.assert_risk_target_type()` para alvo `Synthesis` em ROB-ME;
- EvidenceReviewView `oes.evidence_review_view/0.1`;
- publication gate N4;
- Infrastructure Readiness Gate;
- fixture formal sintética A3;
- template Markdown N4;
- presentation map;
- renderer/validator;
- disclosure `audit.synthetic_fixture`;
- ER4-T01–T27 PASS;
- F3-ER4-TEMPLATE PASS;
- rebuild through migration 015 PASS.

Governança N4 consolidada:

- N4 formal exige A3 + controles humanos qualificados específicos do protocolo;
- A3 não substitui search peer review, dupla seleção, dupla extração, appraisal, certainty ou statistical review;
- IA não satisfaz reviewer assignment humano;
- uma única base bibliográfica não é suficiente para N4 formal;
- protocolo prospectivo e reprodutibilidade são obrigatórios;
- ROB-ME pode ser representado em nível de Synthesis;
- Caso Real N4 formal permanece proibido na configuração humana atual.

Validação técnica final do contrato:

- run **37417796591** = **success**;
- commit validado `a255bf2a33b1cfba1214c7d9daaca234a7f6987e`;
- artifact **11391167525**;
- digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

Validação final do template/renderização:

- run **37418624629** = **success**;
- commit validado `4bd35271e94dfb05bf572fe76b49fa5c5af47bac`;
- artifact **11391724857**;
- digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`;
- F3-ER4-TEMPLATE validation PASS;
- cenário adversarial A3 + `publishable=false` corretamente renderizado como gate bloqueado;
- regressões e rebuild PASS.

Readiness real N4:

- cobertura bibliográfica = `not_ready`;
- equipe metodológica = `not_ready`;
- estatística = `ready_with_documented_conditions`;
- ferramentas/artefatos = `ready`;
- governança/A3 = `not_ready`;
- resultado agregado = **NOT_READY**;
- nenhuma Investigation N4 real foi aberta;
- nenhuma busca definitiva N4 foi iniciada;
- Caso Real N4 permanece deferido até mudança real das condições humanas/infrastruturais.

### Mapa de Evidências

Documentos 123–137:

- 123 — Especificação Científica e Funcional;
- 124 — Revisão de Coerência e Decisão Arquitetural Inicial;
- 125 — Contrato de Dados v0.1;
- 126 — Resultado da Validação Técnica: **PASS**;
- 127 — EvidenceMapView: Contrato de Renderização;
- 128 — Resultado da Validação do Projection Readiness: **READY**;
- 129 — Especificação do Template Operacional;
- 130 — Resultado da Validação do Template/Renderização: **PASS**;
- 131 — Readiness Gate Pré-Caso Real: **exploratório READY_WITH_DOCUMENTED_CONDITIONS / formal NOT_READY**;
- 132 — MAP-01: protocolo pré-especificado;
- 133 — MAP-01: inventário formal de 17 MapItems;
- 134 — MAP-01: codebook v0.1;
- 135 — MAP-01: correção arquitetural — Question/Investigation próprias + N3-01 como `source_corpus`;
- 136 — source_corpus: validação técnica **PASS**;
- 137 — MAP-01: resultado e encerramento controlado — **A1 interno / não publicável**.

Implementação validada:

- migration 016;
- schema `mapping`;
- `framework`, `framework_version`, `dimension`, `category`, `map_item`, `assignment`, `cell_scope`;
- `mapping.evidence_map_cells()` para derivação de células, contagens e gaps;
- publication gate do Mapa;
- EvidenceMapView `oes.evidence_map_view/0.1`;
- fixture formal sintética `evidence_gap_map + systematic_comprehensive + formal_within_scope`;
- dupla classificação humana sintética + consenso;
- qualified search/screening/classification controls sintéticos;
- assurance A3 sintético;
- EM-T01–T22 PASS;
- rebuild through migration 016 PASS;
- regressões N0–N4 PASS.

Validação técnica:

- run **37464023391** = **success**;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`;
- artifact **11413512318**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

Decisões preservadas:

- OES-P1 permanece como núcleo científico;
- células, contagens, concentrações e gaps são derivados;
- gap formal exige coverage e CellScope compatíveis;
- A3 não contorna controles metodológicos de etapa;
- fixture sintética não constitui evidência real;
- nenhum Caso Real do Mapa foi iniciado.

Estado técnico:

> **Contrato de dados e EvidenceMapView = PASS técnico.**

Estado de apresentação:

> **Contrato de renderização definido; Projection Readiness Gate = READY.**

Implementação aditiva validada:

- migration 017;
- EvidenceMapView 0.1 ampliada;
- `product.evidence_map_reference_reports()`;
- synthetic fixture disclosure;
- conclusão;
- protocolo/codebook;
- reviewer assignments;
- method controls;
- lineage/invalidation;
- references via Study–Report linkage;
- EMV-T01–T11 PASS;
- rebuild through migration 017 PASS.

Validação:

- run **37466183355** = success;
- commit validado `0cd132d215bf156dee51c1ce49e3dd2a2c2adde2`;
- artifact **11414726018**;
- digest `sha256:44ee38666b3d502bae5936adb388cdd49660b0f763990eb23b00b2a01bd420c6`.

Camada de apresentação:

- `templates/evidence-map.md`;
- `templates/evidence-map-presentation-map.json`;
- `scripts/render_evidence_map_reference.py`;
- `scripts/validate_evidence_map_render.py`;
- fixture formal PASS;
- cenário A3 + gate bloqueado PASS;
- cenário apparent gap PASS;
- F3-MAP-TEMPLATE PASS;
- rebuild through migration 017 PASS.

Validação final da apresentação:

- run **37467388595** = success;
- commit validado `5b3e7b30d8b0104501fb167e5ab0077fca6119d7`;
- artifact **11415721992**;
- digest `sha256:889f31280259bf1f90439957d12652567d0a3542a465c379623d3810840b7afe`.

Readiness pré-Caso Real:

- rota A — exploratória / structured non-exhaustive = **READY_WITH_DOCUMENTED_CONDITIONS**;
- rota B — systematic map / EGM formal = **NOT_READY**;
- candidato autorizado: MAP-01 — ambient AI scribes, reutilizando o corpus N3-01;
- MAP-01 deve ser novo Product interno A1;
- subtype `descriptive_mapping_review`;
- coverage `structured_non_exhaustive`;
- gaps `apparent_only`;
- sem novos ReviewerAssignments humanos;
- sem alteração do N3-01.

Pré-persistência MAP-01:

- protocolo concluído;
- 5 StudyVersions elegíveis;
- 8 ReportVersions contextuais elegíveis;
- 4 SynthesisVersions elegíveis;
- total = 17 MapItems;
- 20 CellScope previstos;
- codebook v0.1 fechado;
- `descriptive_mapping_review`;
- `structured_non_exhaustive`;
- `apparent_only`;
- counting unit = `study`;
- decisão anterior de reutilizar N3-01 como primary Investigation foi superada pelo Documento 135;
- MAP-01 terá Question/Investigation próprias;
- N3-01 será ligada ao Product com role `source_corpus`;
- Search/Screening canônicos permanecerão na N3-01 e serão herdados pela EvidenceMapView sem duplicação.

Source-corpus support:

- migration 018 = PASS;
- EvidenceMapView preserva pergunta da primary MAP Investigation;
- Searches/Screening podem ser herdados via `source_corpus` em mapas não sistemáticos;
- systematic/formal map continua exigindo Search na primary Investigation;
- EMVSC-T01–T05 PASS;
- rebuild through migration 018 PASS;
- run **37479566944** = success;
- artifact **11420063123**;
- digest `sha256:c7dc99be7781200e0ad603b0d03f9e90e3022ed7eafabd32be5138f41c29024b`.

MAP-01 real:

- Product `OES-P-2026-001401`;
- 17 MapItems;
- 67 assignments finais IA/unverified;
- 20 CellScope;
- 13 referências;
- 3 Searches + 20 SearchHits + 34 ScreeningDecisions herdados via `source_corpus`;
- MAP01-T01–T15 PASS;
- AI methodological second pass = passed;
- assurance final = **A1**;
- owner approval ausente;
- expert review ausente;
- `publishable=false`;
- MAP01-A1-T01–T07 PASS;
- MAP01-RENDER-A1 PASS;
- run **37487017809** = success;
- artifact **11423951911**;
- digest `sha256:ae81f09905853a395b0bf4ba03e5209938d1cb7e6175390531d117e49f0a46e8`;
- rebuild through migration 018 + MAP-01 A1 PASS;
- N3-01 permaneceu inalterado em A0.

Estado final:

> **MAP-01 concluído — A1 interno / não publicável.**

Próxima etapa naquele marco histórico:

> **iniciar a Especificação Científica e Funcional do Overview de Revisões.**

Essa etapa foi posteriormente concluída nos Documentos 138–140; o ponto vigente de retomada é o registrado no CP51.

Produtos exercitados até aqui:

1. **Ficha de Evidência — N2** — caso real A2/published;
2. **Resposta de Evidência — N1** — caso real A2/published;
3. **Evidence Scan — N0** — caso real A1/interno;
4. **Síntese Rápida N3** — contrato/template validados; caso real experimental corretamente bloqueado em A0;
5. **Revisão de Evidências N4** — especificação, contrato, gate, view e template validados com fixture formal sintética A3; readiness real = **NOT_READY**, sem abertura de Caso Real formal.

Taxonomia restante da Fase 3:

- Overview de Revisões;
- Monitor de Evidências;
- Alerta de Evidência.


### Overview de Revisões

Documentos **138–164**: trilha inicial especificada, implementada, exercitada em caso real developmental e encerrada de forma controlada.

Arquitetura/contrato:

- unidade principal = systematic review;
- migration 019 = PASS;
- migration 020 = PASS;
- `OverviewOfReviewsView` = PASS;
- OV-T01–T33 = PASS;
- OVR-T01–T12 = PASS;
- template/presentation map/renderer/validator = PASS;
- rota developmental interna A0/A1 = suportada;
- rota formal publicável exige Investigation N4 + A3 + qualified human controls.

Caso Real OVR-01 — dCBT-I:

- Product = `OES-P-2026-001601`;
- rota = developmental interna;
- ReviewItems = Hwang 2025 + Gao 2026 + Nazari 2025;
- memberships = **27 / 15 / 44**;
- occurrences = **86**;
- unique primary Study candidates = **59**;
- pairwise overlap derivado pelo banco = **6 / 17 / 9**;
- CCA permanece exclusivamente derivado por `overview.overlap_metrics`;
- Gao mantém `last_search_date=NULL` e `currentness_status='unclear'`, sem inferência;
- comparadores permanecem separados;
- nenhuma nova meta-analysis OES foi criada;
- certainty review-level não foi inventada;
- ROBIS e memberships permanecem AI-assisted/unverified.

Trilha adversarial:

- Documento 162 = primeira passagem adversarial, decisão **REVISE**;
- achados: Search execution não sustentada, regra retrospectiva `minimum_bibliographic_sources=2` e drift da Question;
- achados corrigidos e protegidos por OVR01-T15–T16;
- Documento 163 = segunda passagem adversarial, decisão **PASS**;
- Documento 164 = encerramento controlado da trilha developmental.

Estado final:

- assurance = **A1**;
- `ai_methodological_verification=passed`;
- editorial status = `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- owner approval = ausente;
- expert independent review = ausente;
- human verification = ausente;
- rota formal = **NOT_READY**.

Validação final:

- OVR01-T01–T16 = **PASS**;
- OVR01-A1-T01–T09 = **PASS**;
- OVR01-RENDER-A1 = **PASS**;
- regressões integradas = **PASS**;
- rebuild-from-zero = **PASS**;
- run **37549135468** (#117) = **success**;
- HEAD validado = `ecc04933dd5ba116345dc4dcf8d352a646b6aed7`;
- artifact **11452420926**;
- digest `sha256:4dff568129b92a6a4565c33c015afbbe7bec2cc872333b4f99b2701b9c9151a6`.

Publication blockers formais permanecem, incluindo:

- `MISSING_LAST_SEARCH_DATE`;
- `MISSING_OWNER_APPROVAL`;
- `MISSING_EXPERT_INDEPENDENT_REVIEW`;
- `ASSURANCE_BELOW_REQUIRED_LEVEL`;
- `UNVERIFIED_REVIEW_APPRAISAL`;
- `UNVERIFIED_MEMBERSHIP`;
- `MISSING_OVERLAP_CONTROL`;
- `UNVERIFIED_OUTCOME_EVIDENCE`.

Marco:

> **OVR-01 = DEVELOPMENTAL_A1_INTERNAL_VALIDATED — concluído / não publicável.**

## 9. Próxima etapa da Fase 3

> **Iniciar a Especificação Científica e Funcional do Monitor de Evidências.**

Segundo o Documento 40:

- Monitor de Evidências é produto/processo de manutenção;
- pertence à dimensão **M2/M3**;
- não cria um novo nível N;
- deve estar vinculado a Investigation e/ou produto científico persistente;
- deve vigiar novas evidências capazes de modificar Results, Synthesis, Certainty, aplicabilidade, conclusão ou estado de atualidade.

O **Alerta de Evidência** permanece produto/evento posterior ao Monitor.

## 10. Checkpoint vigente

**CP73 — 2026-10-06**.

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-06_CP73.md`

Ponto exato de retomada após consolidação do novo checkpoint:

> **Especificação Científica e Funcional do Monitor de Evidências.**


### Monitor de Evidências

Documento 165 — **Especificação Científica e Funcional inicial concluída**.

Decisões vigentes:

- Monitor é produto/processo de manutenção, não N5;
- opera em M2/M3;
- possui alvo científico rastreável;
- Monitoring Cycle é distinto de ProductVersion científica;
- ausência de mudança material não cria automaticamente nova ProductVersion;
- `product.currency_state` deve ser reutilizado para currentness;
- mudanças materiais continuam usando versionamento do produto monitorado;
- Monitor não altera conclusão silenciosamente;
- Monitor e Alerta de Evidência permanecem distintos;
- assurance do alvo não valida automaticamente cada ciclo;
- IA não pode fabricar Search execution, referências ou verificação humana;
- thresholds temporais/quantitativos gerais permanecem reservados à Fase 4;
- nenhuma migration está autorizada antes da revisão arquitetural.

Próxima etapa:

> **Revisão de coerência científica e arquitetural do Monitor contra OES-P1, Product/Investigation, Search, provenance, currency_state, version_change_class e fronteira Fase 3 × Fase 4.**


### Monitor de Evidências — revisão arquitetural

Documento 166 — **PASS_WITH_ARCHITECTURAL_DECISIONS**.

Decisão consolidada:

> **Monitor = Product próprio + Investigation própria de manutenção que herda N do alvo + camada especializada `maintenance` para target/cycle/candidate/event, reutilizando Search/SearchHit, currency_state, version_change_class e provenance existentes.**

Regras:

- Search do Monitor não será anexada à Investigation científica histórica do alvo;
- Monitor terá target linkage explícito;
- `provenance.dependency_edge` complementa, mas não substitui, o vínculo operacional;
- Monitoring Cycle é registro operacional append-preserving, não ProductVersion;
- `investigation.search`, `search_hit` e dedup existentes serão reutilizados;
- candidate assessment especializado cobrirá hits ainda não resolvidos e eventos;
- eventos de retratação/correção terão representação própria;
- currentness continuará em `product.currency_state`;
- mudança científica continuará usando ProductVersion + `version_change_class`;
- Alert não será implementado nesta etapa;
- Monitor assurance é próprio do processo e não é herdado automaticamente do alvo.

Readiness:

- scientific/functional = PASS;
- architectural coherence = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data-contract readiness = READY;
- migration readiness = NOT_YET.

Próxima etapa:

> **Contrato de Dados v0.1 do Monitor de Evidências.**


### Monitor de Evidências — Contrato de Dados v0.1

Documento 167 — **DATA_CONTRACT_V0_1_READY_FOR_IMPLEMENTATION**.

Contrato:

- `product_type='evidence_monitor'`;
- `investigation_type='evidence_monitoring'`;
- schema especializado `maintenance`;
- oito estruturas v0.1:
  1. `monitor_definition`;
  2. `monitor_target`;
  3. `monitor_state`;
  4. `monitor_cycle`;
  5. `cycle_search`;
  6. `evidence_event`;
  7. `candidate_assessment`;
  8. `cycle_currency_state`;
- Search/SearchHit/dedup/currency/version_change/provenance permanecem canônicos;
- Product/Investigation cutoff do Monitor = cutoff basal do alvo;
- latest surveillance cutoff é derivado dos cycles;
- Monitor M2 formal v0.1 exige mínimo A2;
- M3 é representável, mas permanece formalmente bloqueado até a Fase 4;
- nenhuma conclusão científica do target é sobrescrita pelo Monitor.

Próxima etapa:

> **Implementar migration 021 + fixture sintética M2/M3 + testes de contrato + regressões/rebuild.**
