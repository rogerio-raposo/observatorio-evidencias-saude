# STATE — Estado Atual do Projeto OES

**Última atualização:** 20 de outubro de 2026  
**Fase atual:** Fase 4 — Protocolo de Atualização  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP193 — 2026-10-20**.

### Nota de leitura do STATE cumulativo

Este arquivo preserva snapshots históricos acumulados de marcos anteriores. Portanto:

- o **estado corrente** é o declarado no topo desta seção e no ponteiro `archive/handoffs/oes/README.md`;
- referências posteriores no corpo a “checkpoint vigente” ou “próximo passo” de CPs antigos são **snapshots históricos**, não instruções atuais;
- em caso de divergência aparente, prevalecem: ponteiro atual → checkpoint atual → Freshness Gate.


## 2. Estado das fases

- Fase 0 — Concepção e fundamentos: base inicial consolidada;
- Fase 1 — Manual Metodológico: base inicial dos Documentos 10–15 consolidada;
- Fase 2 — Modelo de Dados da Evidência: **concluída no nível de baseline arquitetural**;
- Fase 3 — Produtos do Observatório: **concluída**;
- Fase 4 — Protocolo de Atualização: **em desenvolvimento**;
- Fases 5–7: ainda não iniciadas formalmente.

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

## 9. Monitor de Evidências — estado atual

Documentos:

- 165 — Especificação Científica e Funcional;
- 166 — revisão de coerência científica/arquitetural = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- 167 — Contrato de Dados v0.1 = **READY_FOR_IMPLEMENTATION**;
- 168 — Resultado da Validação Técnica = **PASS**.

Arquitetura consolidada:

> **Monitor = Product próprio + Investigation própria de manutenção que herda N do alvo + camada especializada `maintenance`, reutilizando Search/SearchHit, currency_state, version_change_class e provenance existentes.**

Implementação:

- migration `database/021_evidence_monitor_contract.sql`;
- schema `maintenance`;
- estruturas:
  - `monitor_definition`;
  - `monitor_target`;
  - `monitor_state`;
  - `monitor_cycle`;
  - `cycle_search`;
  - `evidence_event`;
  - `candidate_assessment`;
  - `cycle_currency_state`;
- fixture M2 formal/A2;
- fixture M3 estruturalmente completa e formalmente bloqueada até Fase 4;
- MON-T01–T32 = **PASS**;
- MON-T33 migration 021 idempotent re-apply = **PASS**;
- rebuild-from-zero through migration 021 = **PASS**.

Semântica preservada:

- Monitor não é N5;
- M2/M3 permanecem dimensão de manutenção;
- Search do Monitor não contamina a Investigation científica histórica;
- ciclo rotineiro não cria ProductVersion científica;
- baseline cutoff da Monitor ProductVersion é estático;
- cutoffs posteriores pertencem aos ciclos;
- Monitor Product currency e target scientific currency são distintos;
- decisão de cycle pode gerar novo `product.currency_state` sem nova ProductVersion;
- target conclusion não é alterada silenciosamente;
- assurance do target não é herdada;
- Monitor M2 formal v0.1 exige mínimo A2;
- expert independent review ausente é warning em M2 v0.1;
- M3 formal permanece bloqueado por `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`;
- Alert completo e thresholds transversais permanecem fora desta etapa/Fase 4.

Validação final:

- workflow **OES PoC-S5 PostgreSQL Validation**;
- run **37553271462** (#122);
- HEAD validado `d7ca356c8cc4d58552a9e52868fce92f27eaad9e`;
- conclusão = **success**;
- artifact **11453871816**;
- digest `sha256:71dd0b68c92ce3d30832862545ac45efbfb94cba51580d77f2673f12a94fbaf8`.

Readiness:

- scientific/functional = PASS;
- architecture = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data contract = PASS;
- migration/fixtures/tests/rebuild = PASS;
- **Projection Readiness = NOT_READY** — Documento 169;
- template readiness = NOT_EVALUATED.

## 10. Próxima etapa da Fase 3

> **Implementar hardening de Projection Readiness do Monitor na migration 022.**

Documento 169 identificou cinco blockers materiais antes de uma EvidenceMonitorView segura:

1. cardinalidade múltipla de impactos não normalizada;
2. source policy parcialmente interpretada;
3. exceções de cobertura via MethodDecision não integradas;
4. semântica temporal cycle/Search incompleta, incluindo drift dinâmico de Search;
5. vínculo Cycle → CurrencyState ainda regravável.

A migration 022 fica reservada ao hardening desses pontos. A EvidenceMonitorView passa a ser candidata para migration 023, somente após novo Projection Readiness Gate = READY.

Nenhum template deverá ser criado enquanto o gate permanecer NOT_READY.

## 11. Checkpoint de continuidade

O checkpoint vigente é **CP88 — 2026-10-06**.

Ponto exato de retomada:

> **Especificar e implementar o hardening de Projection Readiness na migration 022, antes de qualquer EvidenceMonitorView.**


### Monitor de Evidências — Projection Readiness hardening

Documento 170 — **PROJECTION_HARDENING_SPEC_READY**.

Decisões:

- migration 022 = hardening semântico, não View;
- adicionar `maintenance.candidate_impact` para cardinalidade 1:N de impactos;
- adicionar `maintenance.monitor_source_requirement` como fonte machine-readable de requisitos;
- `candidate_assessment.impact_class` permanece como primary impact summary legado;
- SourceRequirement integra exceções via `investigation.method_decision`;
- source coverage deverá distinguir `fulfilled` de `exception_applied`;
- temporal consistency será derivada por helper específico;
- Search drift será revalidado dinamicamente;
- todos os cycles completed serão considerados no hardening gate;
- `cycle_currency_state` será imutável;
- `product.evidence_monitor_is_publishable()` passará a exigir também ausência de hardening errors;
- EvidenceMonitorView permanece candidata à migration 023 após novo Projection Readiness Gate.

Próxima etapa:

> **Implementar migration 022 + atualizar fixture + MONH-T01–T24 + regressões/rebuild.**


### Monitor de Evidências — hardening técnico

Documento 171 — **EVIDENCE_MONITOR_PROJECTION_HARDENING = TECHNICALLY_VALIDATED**.

Implementação:

- migration `database/022_evidence_monitor_projection_hardening.sql`;
- `maintenance.candidate_impact`;
- `maintenance.monitor_source_requirement`;
- source requirement status com `fulfilled` / `exception_applied` / `satisfied`;
- exceções reutilizando `investigation.method_decision`;
- temporal/Search hardening dinâmico;
- avaliação de todos os completed cycles;
- `cycle_currency_state` imutável;
- `product.evidence_monitor_projection_hardening_issues(...)`;
- publishability endurecida.

Validação:

- MON-T01–T32 = PASS;
- MONH-T01–T22 = PASS;
- MON-T33 = PASS — chain 021→022 re-apply;
- MONH-T23 = PASS — migration 022 re-apply;
- MONH-T24 = PASS — rebuild-through-022;
- run final **37555588465** (#125) = **success**;
- HEAD validado `a66ea298b30ffacda10ce16fe2bc0974362b87fe`;
- artifact **11453649661**;
- digest `sha256:002f0a0fdde28bb20bdba9e86263b275bd140d2aec2ae1e67e69f74579089bf6`.

Projection Readiness permanece formalmente:

> **NOT_READY até novo gate explícito.**

Próxima etapa:

> **Reexecutar adversarialmente PR-MON-01–05 e decidir READY/NOT_READY antes da EvidenceMonitorView.**


### Monitor de Evidências — Projection Readiness Gate 02

Documento 172 — **EVIDENCE_MONITOR_PROJECTION_READINESS = READY**.

Resultado adversarial:

- PR-MON-01 múltiplos impactos = RESOLVED;
- PR-MON-02 source policy machine-readable = RESOLVED;
- PR-MON-03 source exceptions via MethodDecision = RESOLVED;
- PR-MON-04 temporal/Search drift = RESOLVED;
- PR-MON-05 Cycle→CurrencyState imutável = RESOLVED.

Correção pós-CP79:

- temporal/gap exceptions agora exigem `stage='search'`;
- decisão accepted em estágio incorreto não satisfaz a exceção;
- run final pós-correção **37555981343** (#127) = **success**;
- HEAD validado `06ea4b203b3d2d3a1425f7f4c7fe3c4a1d764aed`;
- artifact **11454409428**;
- digest `sha256:c2cc76b684d1e89f5a4ae4aadf8067d6c1a659b62384242f7ebc9a48cb69e4ad`.

Autorizado:

> `database/023_evidence_monitor_view_rendering_readiness.sql`

Próxima etapa:

> **Implementar EvidenceMonitorView 0.1 + testes de projeção + idempotência + rebuild.**

Template readiness permanece NOT_EVALUATED. Caso Real, Alert e Fase 4 continuam não autorizados.


### Monitor de Evidências — EvidenceMonitorView 0.1

Documento 173 — **EVIDENCE_MONITOR_VIEW_0_1 = PASS**.

Implementação:

- migration `database/023_evidence_monitor_view_rendering_readiness.sql`;
- schema de projeção `oes.evidence_monitor_view/0.1`;
- `product.evidence_monitor_target_projection(...)`;
- `maintenance.monitor_cycle_projection(...)`;
- `product.evidence_monitor_view(...)`;
- funções read-only / STABLE;
- nenhuma Search, CurrencyState, ProductVersion ou Alert é criada pela View.

Semântica de projeção validada:

- target ProductVersion e InvestigationVersion permanecem explicitamente distintos;
- Monitor editorial status, operational status, Monitor currency e target currency permanecem quatro dimensões separadas;
- baseline cutoff permanece separado do latest completed cycle cutoff;
- Searches/SearchHits vêm dos registros canônicos;
- source requirements projetam `fulfilled`, `exception_applied` e `satisfied` separadamente;
- CandidateAssessments preservam múltiplos `CandidateImpact`;
- EvidenceEvent permanece distinto de CandidateAssessment;
- histórico Cycle→CurrencyState preserva estados superseded/active;
- Monitor assurance e target assurance não são colapsados;
- AI verification não é apresentada como human verification;
- blocker M3/Fase 4 permanece explícito.

Validação:

- MONV-T01–T17 = **PASS**;
- MONV-T18 migration 023 idempotent re-apply = **PASS**;
- MONV-T19 rebuild-through-023 = **PASS**;
- workflow **OES PoC-S5 PostgreSQL Validation**;
- run **37556593132** (#128) = **success**;
- HEAD validado `613a9ced4ad43a3eb890a2b5db35acf51a08127e`;
- artifact **11454488440**;
- digest `sha256:6043e52ac33800ec5d944b1a4633bfe5049a9c8ecff2613eb577aadea2916630`.

Readiness atual:

- scientific/functional = PASS;
- architecture = PASS;
- data contract = PASS;
- projection hardening = PASS;
- Projection Readiness = READY;
- EvidenceMonitorView 0.1 = PASS;
- **template/presentation = NOT_YET_SPECIFIED**;
- Caso Real do Monitor = NOT_AUTHORIZED;
- Alert = NOT_IMPLEMENTED;
- Fase 4 = NOT_STARTED.

Próxima etapa:

> **Definir o contrato de renderização e a Especificação do Template Operacional do Monitor de Evidências.**

A camada de apresentação deverá consumir exclusivamente a `EvidenceMonitorView` e preservar explicitamente Monitor × target × currentness × cycles × assurance × exceptions.


### Monitor de Evidências — camada de apresentação concluída

Documentos 174–176 concluídos.

Estado:

> **MONITOR_DE_EVIDENCIAS = FORMALIZED_IN_PHASE_3**

Apresentação:

- `templates/evidence-monitor.md`;
- `templates/evidence-monitor-presentation-map.json`;
- `scripts/render_evidence_monitor_reference.py`;
- `scripts/validate_evidence_monitor_render.py`.

Validação final:

- run **37558043092** (#130) = **success**;
- HEAD validado `40762d00f874599716fcbb86271bea4084ca19ef`;
- artifact **11455658237**;
- digest `sha256:6d80f9f80622713717d373d99ea200481f8926c295587e223a15a2f179bde0e3`.

Run #129 falhou apenas porque o template acessava resulting target currency em target InvestigationVersion; correção tornou esse bloco condicional sem alterar contrato científico/View.

Caso Real do Monitor não é requisito para a formalização taxonômica da Fase 3.

Próxima etapa:

> **Especificação Científica e Funcional do Alerta de Evidência — último produto da taxonomia da Fase 3.**

Fase 4 permanece explicitamente não iniciada.


### Alerta de Evidência — especificação científica e decisão arquitetural

Documentos 177–178 concluídos.

Estado:

> **EVIDENCE_ALERT_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

Decisões principais:

- Alert formal = Product/ProductVersion com `product_type='evidence_alert'`;
- **não cria Investigation nova**;
- exatamente um `product.investigation_link(role='source_context')`;
- target especializado = exatamente um ProductVersion ou InvestigationVersion;
- `maintenance.evidence_alert` 1:1 com Alert ProductVersion;
- `maintenance.alert_source` 1:N, exatamente uma primary source;
- `maintenance.alert_affected_dimension` 1:N;
- classification `informational|relevant|critical` é persistida, não calculada;
- reassessment priority `routine|priority|urgent` é qualitativa, sem SLA;
- lifecycle `triage|evaluation|incorporated|discarded` é versionado;
- incorporated exige linkage rastreável;
- discarded exige rationale;
- Alerta não cria `product.currency_state` próprio;
- `conclusion_text` do Alert ProductVersion permanece NULL;
- assurance reutiliza A0–A3;
- publicação formal v0.1 exige A2 + human verification explícita do Alerta;
- target assurance/currentness permanecem separados;
- critical não gera A3 obrigatório, prazo ou auto-update na Fase 3;
- Fase 4 permanece não iniciada.

Próxima etapa:

> **Contrato de Dados v0.1 do Alerta de Evidência; depois migration 024 + fixtures + testes.**


### Alerta de Evidência — Contrato de Dados v0.1

Documento 179 concluído.

Estado:

> **EVIDENCE_ALERT_DATA_CONTRACT = READY**

Migration autorizada:

> `database/024_evidence_alert_contract.sql`

Escopo 024:

- `maintenance.evidence_alert`;
- `maintenance.alert_source`;
- `maintenance.alert_affected_dimension`;
- integrity/versioning guards;
- publication issues;
- publishability helper;
- fixtures/tests.

EvidenceAlertView permanece posterior a Projection Readiness explícito.

Fase 4 permanece não iniciada.


### Alerta de Evidência — contrato técnico PASS / Projection Readiness NOT_READY

Documento 180 — **EVIDENCE_ALERT_CONTRACT_0_1 = TECHNICALLY_VALIDATED**.

Validação:
- run **37559879675** (#132) = success;
- HEAD validado `180b11324ed19dbf51aa8a902dec4c51f6587025`;
- AL-T01–T29 = PASS;
- AL-T30 = PASS;
- rebuild-through-024 = PASS;
- artifact **11456436623**;
- digest `sha256:28974dd66cf678abd3ae3f154e8853894489379bc1293c84ae70980d3fc7886d`.

Documento 181 — **EVIDENCE_ALERT_PROJECTION_READINESS = NOT_READY**.

Blockers:
1. AlertSource ainda aceita INSERT pós-publicação;
2. affected dimensions ainda aceitam INSERT pós-publicação;
3. supporting sources não são todas revalidadas dinamicamente;
4. EntityVersion AlertSource não exige `maintenance_alert_source` dependency;
5. source_context deverá ser selado após publicação.

Próxima etapa:
> **migration 025 de projection hardening + ALT-H tests, antes de qualquer EvidenceAlertView.**

Fase 4 permanece não iniciada.


### Alerta de Evidência — Projection Readiness READY

Documentos 182–183 concluídos.

Estado:

> **EVIDENCE_ALERT_PROJECTION_HARDENING = TECHNICALLY_VALIDATED**

> **EVIDENCE_ALERT_PROJECTION_READINESS = READY**

Hardening 025:
- sealing pós-publicação de AlertSource/dimensions/source_context;
- ProductVersion publicado history-preserving;
- all-source dynamic validation;
- EntityVersion source lineage obrigatório;
- hardening issues integrados à publishability.

Validação:
- run **37560513048** (#135) = success;
- HEAD validado `bb1cd11c1882583b001597044dda94ac34b966af`;
- ALT-H01–H13 = PASS;
- rebuild-through-025 = PASS;
- artifact **11456149431**;
- digest `sha256:1606e2b0379910b9100a285fba0dd62d250d07bec70aaa1374d45c797e30fb3b`.

Autorizado:
> `database/026_evidence_alert_view_rendering_readiness.sql`

Fase 4 permanece não iniciada.


### Alerta de Evidência — EvidenceAlertView 0.1

Documento 184 concluído.

Estado:

> **EVIDENCE_ALERT_VIEW_0_1 = PASS**

Validação final:

- migration 026 = PASS;
- EAV-T01–T15 = PASS;
- EAV-T16 idempotent re-apply = PASS;
- EAV-T17 rebuild-through-026 = PASS;
- run **37560891043** (#138) = success;
- HEAD validado `7e41436bb02b47b039356c9ec51aa5d3708a2615`;
- artifact **11456283842**;
- digest `sha256:9513fab7aa3209c8fc4cc008f7b26b687b31d167cbd51ed68a60bae6289740d6`.

Próxima etapa:

> **Contrato de renderização + Template Operacional do Alerta de Evidência.**

Fase 4 permanece não iniciada.


### Alerta de Evidência — camada de apresentação concluída

Documentos 185–187 concluídos.

Estado:

> **ALERTA_DE_EVIDENCIA = FORMALIZED_IN_PHASE_3**

Apresentação:

- `templates/evidence-alert.md`;
- `templates/evidence-alert-presentation-map.json`;
- `scripts/render_evidence_alert_reference.py`;
- `scripts/validate_evidence_alert_render.py`.

Validação final:

- run **37561515491** (#141) = **success**;
- HEAD validado `7d525fc978ee623f17a981b9bf42cdf18686c51e`;
- artifact **11456897850**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`;
- presentation = PASS;
- migration 024/025/026 re-apply = PASS;
- rebuild-through-026 = PASS;
- regressões globais = PASS.

Runs #139 e #140 falharam exclusivamente por defeitos de template/validator e foram corrigidos sem alteração do contrato científico ou da View.

### Fase 3 — Gate de Encerramento

Documento 188 — **PASS**.

Estado consolidado:

> **PHASE_3_PRODUCTS = COMPLETE**

> **PROJECT_STATE = PHASE_3_COMPLETE / PHASE_4_NOT_STARTED**

Taxonomia:

1. Evidence Scan — formalizado;
2. Resposta de Evidência — formalizada;
3. Ficha de Evidência — formalizada;
4. Síntese Rápida de Evidências — formalizada;
5. Revisão de Evidências — formalizada;
6. Mapa de Evidências — formalizado;
7. Overview de Revisões — formalizado;
8. Monitor de Evidências — formalizado;
9. Alerta de Evidência — formalizado.

Critério do encerramento:

- arquitetura/contratos/gates/projeções/apresentação de referência concluídos para os nove produtos;
- rebuild e regressões globais verdes;
- blockers específicos de rotas/casos reais continuam preservados;
- encerramento não implica readiness de produção;
- encerramento não implica A3 universal;
- encerramento não torna M3 operacional.

Fronteira obrigatória:

> **Fase 4 não foi iniciada e não deve ser iniciada sem consentimento explícito do usuário, em nova conversa.**

### Fase 4 — início formal e baseline conceitual do Protocolo de Atualização

Autorização explícita do usuário recebida em nova conversa após Freshness Gate completo.

Documentos:

- Documento 05 — `docs/governance/05-protocolo-transversal-atualizacao.md`;
- Documento 06 — `docs/governance/06-revisao-adversarial-protocolo-atualizacao.md`.

Estado:

> **PROJECT_STATE = PHASE_4_IN_PROGRESS**

> **PHASE_4_UPDATE_PROTOCOL_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

Decisões consolidadas:

- versão científica, currentness, manutenção e estado operacional/comunicacional permanecem distintos;
- ProductVersion recebe CurrencyState; InvestigationVersion não recebe CurrencyState artificial;
- signal operacional é distinto de signal científico/currentness;
- cadence vencida/ciclo incompleto não altera currentness automaticamente;
- atualização científica material exige versionamento history-preserving do alvo apropriado;
- Alert não é atualização científica;
- Monitor não é síntese;
- propagação abre impact assessment, sem reescrever dependentes;
- M3 permanece ortogonal a N0–N4;
- automação autoritativa permanece não autorizada sem gate específico.

M3:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece ativo.**

Documento metodológico não remove o blocker técnico. Desbloqueio exigirá contrato físico, migration, testes, idempotência, rebuild, regressões e gate explícito.

Estado técnico:

- nenhuma migration/View/template/workflow alterada na abertura da Fase 4;
- última validação técnica continua sendo S5 run **37561515491** (#141) = success;
- HEAD técnico validado `7d525fc978ee623f17a981b9bf42cdf18686c51e`;
- artifact **11456897850**;
- digest `sha256:257b26162a577f24cede0c21befd437b1cad4dc6c5847d39ef29e2755d85e099`.

Readiness:

- conceptual update protocol = PASS_WITH_ARCHITECTURAL_DECISIONS;
- data contract = NOT_YET_SPECIFIED;
- migration de Fase 4 = NOT_AUTHORIZED;
- thresholds numéricos = NOT_DEFINED;
- SLAs numéricos = NOT_DEFINED;
- M3 formal operacional = BLOCKED.

Próximo passo exato:

> **Especificar o Contrato de Dados v0.1 do Protocolo Transversal de Atualização, começando por maintenance policy/version, update signal, materiality assessment e update decision; antes de qualquer migration, executar gate de coerência física.**

### CP89

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-06_CP89.md`;
- ponteiro de continuidade movido para CP89;
- Fase 4 formalmente iniciada;
- Documentos 05–06 consolidados;
- retomada movida para Contrato de Dados v0.1;
- M3 formal continua bloqueado.

### Fase 4 — Contrato Transversal de Atualização v0.1 tecnicamente validado

Documentos:

- Documento 07 — Contrato de Dados v0.1;
- Documento 08 — Gate de Coerência Física = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- Documento 09 — Resultado da Validação Técnica = **PASS**.

Implementação:

- migration `027_transversal_update_protocol_contract.sql`;
- fixtures `f4-update-protocol-fixtures.sql`;
- testes `f4-update-protocol-tests.sql`;
- sete estruturas aditivas no schema `maintenance`;
- nenhuma tabela científica existente alterada por `ALTER TABLE`.

Validação:

- F4-UP-T01–T63 = **PASS**;
- F4-UP-IDEM = **PASS**;
- rebuild-through-027 = **PASS**;
- regressões F2-B/S4/S5 = **PASS**;
- regressões Monitor/Alert e demais produtos F3 = **PASS**.

Evidência canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run **37570978847** = **success**;
- HEAD técnico validado `d56ea65c024d60c60ec77d1ab4fe9dc7be1c5fa9`;
- artifact **11460960487**;
- digest `sha256:edbdc9dfd6bbe4cd5c5321d796fa5f912b6e28bea9d39346af70aac18e00875b`.

Estado:

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_027 = PASS**

M3:

> **M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL permanece ativo.**

A existência de UpdatePolicy M3 foi validada sem desbloquear publicação formal de Monitor M3.

Não definidos/autorizados neste marco:

- thresholds quantitativos;
- SLAs numéricos;
- score global de prioridade;
- scheduler;
- notifications;
- auto-classification;
- auto-escalation;
- propagation automática;
- Monitor re-baselining;
- M3 readiness;
- auto-publication;
- auto-update científico.

Próximo passo exato:

> **Definir a arquitetura transversal de perfis de risco operacional/científico que parametrizará cadence, thresholds, SLAs e prioridade, sem ainda fixar números universais.**

### CP90

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP90.md`;
- ponteiro de continuidade movido para CP90;
- contrato físico v0.1 da Fase 4 tecnicamente validado;
- migration 027 = PASS;
- retomada movida para perfis de risco operacional/científico.

### Fase 4 — Perfis de risco e política temporal consolidados

Documentos:

- 16 — Perfis de Risco Operacional e Científico para Atualização;
- 17 — Revisão Adversarial dos Perfis de Risco;
- 18 — Política Transversal de Cadence e Thresholds Temporais;
- 19 — Revisão Adversarial da Política Temporal.

Estado:

> **PHASE_4_UPDATE_RISK_PROFILE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHASE_4_CADENCE_TEMPORAL_POLICY = PASS_WITH_ARCHITECTURAL_DECISIONS**

Decisões consolidadas:

- risco científico/decisório e capacidade operacional permanecem separados;
- score agregado aditivo não é autorizado;
- taxonomia paralela R0–R3 foi rejeitada;
- recomendação de manutenção usa M0–M3 sem ativação automática;
- cadence, cobertura, processamento, reassessment de policy/profile e duração da atualização científica permanecem semanticamente separados;
- M1 periódico não cria Monitoring Cycle por default;
- M2 periódico usa Monitor governante;
- overdue/gap são estados operacionais e não mudam currentness automaticamente;
- M3 formal permanece bloqueado.

Correção de inventário:

- `investigation.method_decision` existe desde a migration 014;
- permanece distinta de `maintenance.update_decision`;
- a correção não altera o PASS técnico da migration 027.

Próximo passo exato:

> **Definir a arquitetura transversal de SLA como contratos operacionais entre eventos claramente definidos, sem fixar durações universais antes do gate semântico.**

### CP92 — reconciliação e disciplina de interação

- CP91 reconciliado com o estado documental;
- README principal e CHANGELOG alinhados aos Documentos 16–19;
- template canônico atualizado com pausa obrigatória após checkpoints;
- após cada checkpoint formal, o trabalho deve parar e aguardar instrução explícita do usuário antes do bloco seguinte;
- nenhuma migration 028 foi criada;
- nenhum bloco de SLA foi iniciado neste checkpoint.

### Fase 4 — Arquitetura Transversal de SLA consolidada

Documentos:

- 20 — Arquitetura Transversal de SLA do Protocolo de Atualização;
- 21 — Revisão Adversarial da Arquitetura Transversal de SLA.

Estado:

> **PHASE_4_SLA_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_PRIORITY_ARCHITECTURE**

> **MIGRATION_028 = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

Decisões consolidadas:

- SLA mede obrigação operacional, não estado científico;
- seis clocks mínimos foram definidos;
- late normalization não reinicia SLA-1;
- evento pré-policy preserva pre_policy_age sem breach retroativo;
- MaterialityAssessment e UpdateDecision usam timestamps qualificantes quando verificação humana ocorre depois;
- rule snapshot é congelada no início da SLA Instance;
- nominal_due_at e effective_due_at permanecem separados;
- pause não apaga breach e não é substituto de backlog/capacidade baixa;
- execution_status e compliance_status são eixos distintos;
- breached_then_satisfied preserva atraso histórico;
- Alert priority/classification pode informar SLA sem duração embutida;
- Monitor fornece timestamps upstream, mas cycle lateness continua pertencendo à cadence;
- SLA-4/5/6 exigem identidade causal por workflow/review round;
- triage transversal e milestones de workflow permanecem gaps físicos;
- currentness não deriva de SLA compliance;
- automação de breach/escalation não possui autoridade científica.

Próximo passo exato:

> **Definir a arquitetura transversal de prioridade e escalation antes de qualquer migration 028.**

### CP93

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP93.md`;
- ponteiro movido para CP93;
- arquitetura transversal de SLA aprovada com decisões arquiteturais;
- nenhuma migration 028 criada;
- nenhuma duração universal de SLA definida;
- retomada movida para prioridade/escalation;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Auditoria retrospectiva e hardening corretivo

Documentos:

- 22 — Auditoria Retrospectiva da Fase 4 até CP93;
- 23 — Gate de Coerência Física Corretivo pós-Auditoria;
- 24 — Resultado da Validação Corretiva pós-Auditoria.

Estado:

> **RETROSPECTIVE_AUDIT_CORRECTIVE_BLOCK = CLOSED_PASS**

> **PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING**

> **MIGRATION_028_CORRECTIVE_HARDENING = PASS**

> **F4_UP_PLAN_MIRRORED_REQUIREMENTS = P01–P63 PASS**

Decisões e correções:

- migration 027 foi preservada historicamente;
- migration 028 foi usada somente para hardening corretivo;
- `signal_type='other'` passou a respeitar fronteira scientific_currentness × operational;
- nova UpdateDecision exige UpdateSignal ativo;
- novo linkage para CurrencyState exige UpdateDecision ativa;
- issue helpers de policy/signal/materiality/decision foram ampliados;
- suíte histórica T01–T63 permanece verde;
- suíte P01–P63 passa a espelhar explicitamente os 63 requisitos mínimos do Documento 07;
- a run #143 falhou por erro de desenho do teste P62 e não é evidência de PASS;
- a run #144 é a evidência canônica do hardening.

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37576434417** (#144);
- technical HEAD: `3f36b5dd4103e15834adde107fedeeb1c81fb084`;
- conclusion: **success**;
- artifact: **11462802190**;
- digest: `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- T01–T63 = PASS;
- P01–P63 = PASS;
- migration 027 idempotency = PASS;
- migration 028 idempotency = PASS;
- rebuild-through-028 = PASS;
- F2-B/S4/S5 regressions = PASS;
- Monitor/Alert regressions = PASS.

Limites preservados:

- M3 formal continua bloqueado por `M3_TRANSVERSAL_UPDATE_POLICY_NOT_OPERATIONAL`;
- prioridade/escalation ainda não foi iniciada;
- nenhuma duração numérica universal de SLA foi definida;
- nenhum contrato físico adicional de prioridade/SLA foi autorizado;
- triage transversal e milestones de workflow continuam gaps físicos;
- notifications, propagation/re-baselining e M3 readiness continuam pendentes.

Próximo passo exato:

> **Definir a arquitetura transversal de prioridade e escalation, somente após o checkpoint corretivo e nova instrução explícita do usuário.**

### CP94 — auditoria retrospectiva e hardening corretivo

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP94.md`;
- ponteiro movido para CP94;
- bloco corretivo da auditoria encerrado em **CLOSED_PASS**;
- `PHASE_4_UPDATE_DATA_CONTRACT = TECHNICALLY_VALIDATED_AFTER_AUDIT_HARDENING`;
- migration 028 corretiva = PASS;
- T01–T63 = PASS;
- P01–P63 = PASS;
- rebuild-through-028 = PASS;
- regressões F2-B/S4/S5 e Monitor/Alert = PASS;
- run canônico **37576434417** (#144) = success;
- artifact **11462802190**;
- digest `sha256:82ada290239676067daf13ec1412c0b10c1612c4a402b53f66d45ede9e097c92`;
- run #143 preservada como falha de desenho do teste P62, não evidência de regressão;
- M3 formal permanece bloqueado;
- prioridade/escalation ainda não iniciada;
- próximo passo: arquitetura transversal de prioridade e escalation;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Arquitetura transversal de prioridade e escalation

Documentos:

- 25 — Arquitetura Transversal de Prioridade e Escalation;
- 26 — Revisão Adversarial da Arquitetura Transversal de Prioridade e Escalation.

Estado:

> **PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT_DESIGN**

> **MIGRATION_029 = NOT_AUTHORIZED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **NUMERIC_PRIORITY_WEIGHTS = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Decisões consolidadas:

- prioridade é avaliada por case/UpdateSignal/target version, não como atributo permanente do Product/Investigation;
- response_class transversal = standard | expedited | urgent | immediate;
- response_class não contém duração de SLA;
- priority e escalation são eixos independentes;
- safety/integrity e validity/use podem criar dominance floors;
- `suspend_current_use` implica floor immediate + rota de current-use governance, sem executar retirada/publicação;
- `material_change_confirmed` isolado e `update_recommended` isolado são strong modifiers, não floors universais;
- priority authoritative baseada em materialidade científica exige qualificação humana apropriada;
- Alert classification/reassessment_priority é input local/comunicacional, sem equivalência automática;
- SLA breach é operational pressure modifier e não retroage SLA Rule snapshot;
- capacity/cost não reduzem prioridade;
- dependency reach aumenta coordenação/propagation assessment, não materiality;
- queue aggregation futura deve ser derivada e manter linkage para casos causais;
- escalation candidate pode ser automático; active escalation exige autoridade humana na baseline;
- nenhum score aditivo ou peso numérico foi autorizado;
- target supersession/invalidation pertence a lifecycle/reassessment, não dominance gate.

Referências metodológicas consideradas:

- Cochrane Handbook Chapter IV;
- Cochrane Handbook Chapter 22;
- Cochrane Interactive Learning Module 14 (2026);
- NICE PMG49 (2025);
- WHO living-guidelines approach.

Próximo passo exato:

> **Definir o contrato de dados integrado do plano operacional da Fase 4 — triage + PriorityAssessment + escalation + SLA Rule/Instance + pause ledger + milestones mínimos de workflow/review — sem migration; depois executar gate físico próprio.**

### CP95 — arquitetura transversal de prioridade e escalation

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP95.md`;
- ponteiro movido para CP95;
- `PHASE_4_PRIORITY_ESCALATION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- response_class = standard | expedited | urgent | immediate;
- priority e escalation permanecem eixos independentes;
- priority authoritative científica exige qualificação humana apropriada;
- Alert priority/classification permanece input, sem equivalência automática;
- SLA breach permanece operational pressure modifier;
- capacity não reduz priority;
- dependency reach não vira materiality;
- priority score/pesos numéricos não definidos;
- auto-escalation não autorizada;
- migration 029 não autorizada;
- M3 formal permanece bloqueado;
- último PASS técnico continua sendo run **37576434417** (#144), pois o bloco CP95 foi documental/arquitetural;
- próximo passo: contrato de dados integrado do plano operacional da Fase 4, ainda sem migration;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Contrato operacional integrado

Documentos:

- 27 — Contrato de Dados Integrado do Plano Operacional da Fase 4;
- 28 — Gate Adversarial de Coerência Física do Contrato Operacional Integrado.

Estado:

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_MIGRATION_029**

> **MIGRATION_029_SCOPE = OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**

> **NUMERIC_SLA_DURATIONS = NOT_DEFINED**

> **PRIORITY_SCORE = NOT_DEFINED**

> **AUTO_ESCALATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Estruturas autorizadas para a futura migration 029:

- update_triage;
- priority_assessment;
- priority_basis;
- escalation_case;
- escalation_reason;
- escalation_route;
- sla_calendar_version;
- sla_rule;
- sla_instance;
- sla_pause;
- workflow_round;
- workflow_milestone;
- validators/guards/readiness/helpers estritamente necessários.

Decisões consolidadas:

- UpdatePolicy continua a âncora; não criar OperationalPlan duplicado;
- triage invalid_signal usa constraint deferred para consistência transacional;
- PriorityBasis usa source_type + locator XOR + snapshot;
- escalation lifecycle possui transições fechadas e activation humana;
- SLA Rule usa rule_code + selection_precedence determinística;
- clock→endpoint e time_basis matrices estão fechadas;
- calendário e fixed deadline possuem shapes fechados/validáveis;
- effective_due/current compliance são derivados, não campos autoritativos livres;
- SLA obligations têm cardinalidade definida por signal/round;
- WorkflowRound planned ancora SLA-4;
- WorkflowRound status não duplica scientific/review/publication milestones;
- WorkflowMilestone usa adapter_type + locator XOR + precisão timestamp/date;
- publication permanece subordinada ao gate especializado do product_type;
- UpdateRiskProfile ainda é snapshot bridge versionado, não pseudo-FK;
- nenhum número/default SLA foi autorizado;
- migration 029 não pode inserir regras SLA normativas arbitrárias;
- F4-OC-T01–T72 será a suíte mínima espelhada da implementação.

Próximo passo exato:

> **Implementar migration 029 + F4-OC-T01–T72 + integração S5 e executar validação canônica completa antes de qualquer PASS técnico.**

### CP96 — contrato operacional integrado

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP96.md`;
- ponteiro movido para CP96;
- `INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READY_FOR_MIGRATION_029`;
- migration 029 autorizada em escopo **OPERATIONAL_CONTROL_INFRASTRUCTURE_ONLY**;
- migration 029 ainda não implementada;
- nenhuma duração SLA numérica foi definida;
- nenhum priority score/peso foi definido;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- último PASS técnico continua sendo run **37576434417** (#144), through migration 028;
- próximo passo: implementar migration 029 + F4-OC-T01–T72 + S5/idempotência/rebuild/regressões;
- modo médio é seguro para a implementação mecânica; se surgir nova decisão arquitetural, parar e recomendar modo alto;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Validação técnica do controle operacional integrado

Documento:

- 29 — Resultado da Validação Técnica do Controle Operacional Integrado da Fase 4.

Estado:

> **INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_029 = PASS**

> **F4_OC_T01_T72 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37580906483** (#150);
- technical HEAD: `ae45918bb8cbf1ab929aec2e1af53f7239f75323`;
- conclusion: **success**;
- artifact: **11464672034**;
- digest: `sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`;
- F4-OC-T01–T69 = PASS;
- T70 migration 029 idempotency = PASS;
- T71 rebuild-through-029 = PASS;
- T72 regressões completas = PASS;
- F4-UP-T01–T63 = PASS;
- F4-UP-P01–P63 = PASS;
- M3 blocker preservado.

Runs #145–#149 foram diagnósticas/falhas não canônicas, classificadas no Documento 29 como erros de implementação/test setup/test isolation/test editing, e não são evidência de PASS.

Limites preservados:

- nenhuma duração SLA normativa;
- nenhum priority score/peso;
- auto-escalation não autorizada;
- scheduler não implementado;
- notification channels não implementados;
- propagation/re-baselining não implementados;
- UpdateRiskProfile físico ainda não normalizado;
- M3 readiness ainda não autorizada;
- operação humana real não iniciada.

Próximo passo:

> **ser definido no checkpoint pós-PASS; nenhum novo bloco funcional é iniciado automaticamente.**

### CP97 — PASS técnico do controle operacional integrado

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP97.md`;
- ponteiro movido para CP97;
- `INTEGRATED_OPERATIONAL_CONTROL_DATA_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_029 = PASS`;
- F4-OC-T01–T72 = PASS;
- run canônico **37580906483** (#150) = success;
- technical HEAD `ae45918bb8cbf1ab929aec2e1af53f7239f75323`;
- artifact **11464672034**;
- digest `sha256:ec4546afc64fb5eb86b69d966905fc583cfbe43e4586abc922b57eb48e67a43c`;
- rebuild-through-029 = PASS;
- regressões completas = PASS;
- F4-UP-T01–T63/P01–P63 permanecem verdes;
- M3 formal permanece bloqueado;
- nenhum SLA normativo/score/auto-escalation foi introduzido;
- próximo bloco da Fase 4 ainda não foi selecionado;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint permanece vigente.


### Fase 4 — Normalização física do UpdateRiskProfile

Documentos:
- 30 — Contrato Físico Candidato do UpdateRiskProfile;
- 31 — Gate Adversarial do Contrato Físico UpdateRiskProfile.

Estado:
> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READY_FOR_MIGRATION_030**

> **MIGRATION_030_SCOPE = UPDATE_RISK_PROFILE_NORMALIZATION_ONLY**

Decisões:
- profile = header versionado + 10 dimensões auditáveis;
- provenance dimensional normalizada com FKs reais/locator XOR;
- profile authoritative exige reviewer/expert no header;
- B5 authoritative exige owner, sem fabricar owner como verifier científico;
- proposal incompleto pode existir, mas não alimenta PriorityAssessment;
- carry-forward explícito por dimensão e mesma lineage entity_uuid;
- UpdatePolicy continua soberana;
- snapshots históricos de PriorityAssessment não serão backfillados;
- novos PriorityAssessment após migration 030 deverão referenciar profile físico + serializer canônico;
- M3 continua bloqueado;
- migration 030 ainda não implementada.

Próximo passo:
> **implementar migration 030 + F4-RP-T01–T87 + validação canônica completa.**

### CP98 — contrato físico do UpdateRiskProfile

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP98.md`;
- ponteiro movido para CP98;
- `UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READY_FOR_MIGRATION_030`;
- migration 030 autorizada apenas como `UPDATE_RISK_PROFILE_NORMALIZATION_ONLY`;
- migration 030 ainda não implementada;
- F4-RP-T01–T87 definido como plano mínimo futuro;
- snapshots históricos permanecem grandfathered, sem backfill fabricado;
- novos PriorityAssessment após migration 030 deverão usar profile físico + serializer canônico;
- risk score/numeric cadence/numeric SLA continuam não definidos;
- auto policy change não autorizado;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37580906483** (#150), through migration 029;
- próximo passo: implementar migration 030 + testes + validação canônica;
- modo médio seguro para implementação mecânica; nova decisão arquitetural exige parada e modo alto;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Validação técnica do UpdateRiskProfile físico

Documento:

- 32 — Resultado da Validação Técnica do UpdateRiskProfile Físico.

Estado:

> **UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_030 = PASS**

> **F4_RP_T01_T87 = PASS**

> **REBUILD_THROUGH_030 = PASS**

> **FULL_REGRESSIONS_AFTER_030 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Validação canônica:

- workflow: **OES PoC-S5 PostgreSQL Validation**;
- run: **37618433929** (#161);
- technical HEAD: `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- job id: **112782351104**;
- conclusion: **success**;
- artifact: **11480858194**;
- digest: `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`;
- F4-RP-T01–T84 = PASS;
- T85 migration 030 idempotency = PASS;
- T86 rebuild-through-030 = PASS;
- T87 regressões completas = PASS;
- F4-OC-T01–T72 permanecem compatíveis/verdes;
- F4-UP, F2-B, S4, S5, F3 Products, Monitor e Alert permanecem verdes;
- M3 blocker preservado.

Runs #153–#160 foram diagnósticas e não canônicas, classificadas no Documento 32 como erros de instalação/implementação/setup/order/brittleness/test editing.

Limites preservados:

- nenhum risk score;
- nenhuma cadence numérica;
- nenhum SLA normativo novo;
- nenhum auto-policy change;
- nenhum backfill autoritativo fabricado;
- nenhum auto-signal/auto-alert;
- scheduler/notifications não implementados;
- M3 readiness não autorizado.

Próximo passo:

> **ainda não selecionado; deverá ser escolhido explicitamente após o checkpoint pós-PASS.**

### CP99 — PASS técnico do UpdateRiskProfile físico

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP99.md`;
- ponteiro movido para CP99;
- `UPDATE_RISK_PROFILE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_030 = PASS`;
- F4-RP-T01–T87 = PASS;
- rebuild-through-030 = PASS;
- regressões completas = PASS;
- run canônico **37618433929** (#161) = success;
- technical HEAD `dc9ced9f91817441d0b87063c55057cde1c3c3b7`;
- artifact **11480858194**;
- digest `sha256:2fa282d226fd78cce87a7240658bf0f1a37b18afef6d29014335b170316183d7`;
- F4-OC e F4-UP permanecem verdes;
- M3 formal permanece bloqueado;
- nenhum risk score/numeric cadence/numeric SLA/auto-policy change foi introduzido;
- próxima dívida da Fase 4 ainda não selecionada;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Propagação de mudanças e re-baselining

Documento:
- 33 — Arquitetura Transversal de Propagação de Mudanças e Re-baselining.

Estado:
> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = CANDIDATE_FOR_ADVERSARIAL_GATE**

Decisões estruturais candidatas:
- dependency discovery não equivale a impacto científico;
- propagation não altera currentness automaticamente;
- re-baselining é separado de propagation;
- UpdatePolicy não pode usar supersession cross-target;
- MonitorTarget não pode ser retargeteado in-place;
- novo target M2/M3 exige novo Monitor ProductVersion/binding explícito;
- UpdateRiskProfile, signals, Priority, SLA, workflow e Alerts históricos permanecem ancorados no target original;
- M3 blocker permanece preservado.

Próximo passo:
> **executar revisão adversarial específica do Documento 33 antes de qualquer contrato físico ou migration.**

### Fase 4 — Gate adversarial de propagation/re-baselining

Documentos:
- 33 — Arquitetura Transversal de Propagação de Mudanças e Re-baselining;
- 34 — Revisão Adversarial da Arquitetura de Propagação e Re-baselining.

Estado:
> **PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **MIGRATION = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Hardening consolidado:
- maintainable targets separados de objetos intermediários do dependency graph;
- target mantível sem policy usa `maintenance_policy_required`;
- propagation→UpdateSignal exige adapter estruturado futuro, sem apagar causalidade;
- um candidate por assessment + impacted version, com 1:N path snapshots;
- cycle/depth guard e lineage validation obrigatórios;
- rebaseline exige same entity + chain versionada auditável;
- planned e activated rebaseline separados;
- policy cross-target lineage é separada de `supersedes_update_policy_uuid`;
- novo M2/M3 exige novo Monitor ProductVersion current e target coerente antes da policy;
- coverage, UpdateRiskProfile, SLA Rules/Instances, workflow, Priority/Escalation e Alerts preservam história;
- authority operacional separada de scientific/methodological/mixed;
- nenhum currentness/assurance/M3 update automático.

Próximo passo:
> **especificar o Contrato Físico v0.1 de Propagation/Re-baselining e submetê-lo a novo gate antes de qualquer migration.**

### CP100 — arquitetura de propagation/re-baselining

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP100.md`;
- ponteiro movido para CP100;
- `PHASE_4_PROPAGATION_REBASELINE_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY`;
- Documento 33 hardenizado após primeira passagem adversarial REVISE;
- Documento 34 recheck final = PASS_WITH_ARCHITECTURAL_DECISIONS;
- cross-target policy supersession continua proibida;
- MonitorTarget retarget in-place continua proibido;
- new M2/M3 target exige novo Monitor ProductVersion current e coerente;
- propagation→UpdateSignal exige adapter estruturado futuro;
- lineage validation, multiple paths, cycle/depth guard e concurrency estão explicitados;
- UpdateRiskProfile/SLA/workflow/Priority/Escalation/Alert históricos não são retargeteados;
- nenhuma migration autorizada;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37618433929** (#161) do CP99;
- próximo passo: Contrato Físico v0.1 + novo gate, ainda em modo alto;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint permanece vigente.

### Fase 4 — Contrato Físico candidato de Propagation/Re-baselining

Documento:
- 35 — Contrato Físico v0.1 de Propagation/Re-baselining.

Estado:
> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = CANDIDATE_FOR_PHYSICAL_GATE**

> **F4_PRB_T01_T128 = TEST_PLAN_CANDIDATE**

> **MIGRATION_031 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Estruturas candidatas:
- PropagationAssessment/Candidate/Path/PathStep;
- adapter estruturado PropagationCandidate → UpdateSignalSource;
- RebaselineDecision;
- handover explícito de UpdatePolicy, Monitor, UpdateRiskProfile, coverage, SLA Rules/Instances, signals e workflow;
- issue/readiness helpers;
- grandfathering sem backfill fabricado.

Próximo passo:
> **executar gate adversarial/físico do Documento 35 antes de qualquer migration.**

### Fase 4 — Gate físico de Propagation/Re-baselining

Documentos:
- 35 — Contrato Físico v0.1 de Propagation/Re-baselining;
- 36 — Gate Adversarial/Físico do Contrato de Propagation/Re-baselining.

Estado:
> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_PRB_T01_T145 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_031 = AUTHORIZED_IN_STRICT_SCOPE**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Decisões físicas consolidadas:
- target classes fechadas em maintainable_product / maintainable_investigation / nonmaintainable_version;
- propagation path normalizado e no_action bloqueado por lineage incompleto;
- version chain de rebaseline normalizada em child steps com FKs;
- RebaselineDecision append-preserving com activation authoritative única por old target;
- policy handover cross-target separado de supersession same-target;
- new M2/M3 policy exige novo Monitor current/coerente;
- profile readiness condicional preserva guard da migration 030;
- target supersession não invalida UpdateSignal;
- PropagationCandidate → UpdateSignalSource exige adapter completo;
- contract epoch técnico reservado apenas a grandfathering;
- SLA cross-policy não reutiliza supersession FK;
- SLA Instance handover não contorna lifecycle/first-breach guards;
- migration 031 não pode criar automação científica, numeric SLA/cadence ou remover blocker M3.

Próximo passo:
> **implementar migration 031 + fixtures sintéticas + F4-PRB-T01–T145 + integração S5; depois validar idempotência, rebuild-through-031 e regressões completas.**

Disciplina de modo:
> **a etapa arquitetural de alta complexidade terminou; modo médio é suficiente para a implementação mecânica já especificada.**

### CP101 — contrato físico de propagation/re-baselining

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP101.md`;
- ponteiro movido para CP101;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `F4_PRB_T01_T145 = APPROVED_MINIMUM_TEST_PLAN`;
- `MIGRATION_031 = AUTHORIZED_IN_STRICT_SCOPE`;
- migration 031 ainda não implementada;
- M3 formal permanece bloqueado;
- último PASS técnico continua run **37618433929** (#161);
- próximo passo: implementação migration 031 + fixtures/testes/S5;
- modo médio suficiente enquanto o escopo permanecer mecânico;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint preservada.


### Fase 4 — PASS técnico de Propagation/Re-baselining

Documento:
- 37 — Resultado da Validação Técnica de Propagation/Re-baselining.

Estado:
> **PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED**

> **MIGRATION_031 = PASS**

> **F4_PRB_T01_T145 = PASS**

> **MIGRATION_031_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_031 = PASS**

> **GLOBAL_REGRESSIONS_AFTER_031 = PASS**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Evidência canônica:
- S5 run **37644296649** (#167) = success;
- technical HEAD `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- job `postgres-s5` / **112870931087** = success;
- artifact **11494595216**;
- digest `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`.

Implementação:
- migration lógica 031 + fragments 031a–031e;
- fixtures sintéticas PRB;
- F4-PRB-T01–T145;
- adapter PropagationCandidate → UpdateSignalSource;
- child handover validators;
- idempotência/rebuild/regressões integradas no S5.

Runs #163–#166:
- diagnósticas/intermediárias;
- falhas locais de fixture/wiring;
- não são evidência canônica de PASS.

Limites preservados:
- sem numeric SLA/cadence;
- sem scheduler/notifications;
- sem auto-propagation/auto-rebaseline;
- sem automatic currentness/assurance;
- sem backfill/revisão humana fabricados;
- M3 continua bloqueado.

Próximo passo:
> **criar checkpoint técnico pós-PASS e, somente após nova autorização do usuário, selecionar explicitamente a próxima dívida aberta da Fase 4.**

### CP102 — PASS técnico de propagation/re-baselining

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP102.md`;
- ponteiro movido para CP102;
- `PROPAGATION_REBASELINE_PHYSICAL_CONTRACT = TECHNICALLY_VALIDATED`;
- `MIGRATION_031 = PASS`;
- F4-PRB-T01–T145 = PASS;
- migration 031 idempotency = PASS;
- rebuild-through-031 = PASS;
- regressões completas = PASS;
- S5 run canônico **37644296649** (#167) = success;
- technical HEAD `5da1d932f9509214db6a658a2ed5ca830ec7b6c1`;
- artifact **11494595216**;
- digest `sha256:1934c9068c24dc17ea505fd353901270eef3ab3a8cc48cbd74cba0de5132922a`;
- M3 formal permanece bloqueado;
- próxima dívida da Fase 4 ainda não selecionada;
- Fase 5 não iniciada;
- pausa obrigatória após checkpoint preservada.


### Fase 4 — seleção do próximo bloco após CP102

Documento:
- 38 — Seleção da Próxima Dívida da Fase 4.

Decisão:
> **NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION**

> **TEMPORAL_CALIBRATION = SELECTED_NOT_STARTED**

> **PRIORITY_SCORE = DELIBERATELY_NOT_REQUIRED_FOR_BASELINE**

Racional:
- scheduler depende de cadence/thresholds normativos;
- breach/overdue normativo depende de SLA duration + calendar;
- notifications dependem de eventos/thresholds definidos;
- M3 readiness depende de cadence/SLA operacionais coerentes;
- priority score aditivo foi deliberadamente rejeitado pela arquitetura aprovada.

Limites:
- nenhum número de cadence/threshold/SLA foi definido;
- scheduler não iniciado;
- notifications não iniciadas;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Disciplina de modo:
> **HIGH_MODE_RECOMMENDED_BEFORE_TEMPORAL_CALIBRATION**

Próximo passo:
> **em modo alto, definir primeiro a metodologia de calibração temporal; somente depois considerar valores normativos.**

### CP103 — seleção do próximo bloco da Fase 4

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP103.md`;
- ponteiro movido para CP103;
- `NEXT_PHASE_4_BLOCK = TEMPORAL_CALIBRATION`;
- `TEMPORAL_CALIBRATION = SELECTED_NOT_STARTED`;
- priority score permanece deliberadamente dispensável no baseline;
- nenhum valor numérico foi definido;
- scheduler/notifications não iniciados;
- auto-escalation não autorizada;
- M3 formal permanece bloqueado;
- modo alto recomendado antes da metodologia de calibração;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


### Fase 4 — metodologia de calibração temporal

Documentos:
- 39 — Metodologia de Calibração Temporal da Fase 4;
- 40 — Gate Adversarial da Metodologia de Calibração Temporal.

Estado:
> **TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **MIGRATION_032 = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Metodologia fechada:
- calibração por envelopes independentes, sem score;
- A1–A5 não mapeiam automaticamente para números;
- seleção por constraints + dominância/Pareto;
- source latency não determina cadence isoladamente;
- replay inclui censura/missingness/falhas;
- PriorityAssessment usado na seleção SLA é snapshot pré-instance;
- calibração provisional não vira rule ativa;
- repeated breach não relaxa SLA automaticamente;
- external deadline exige compatibilidade semântica;
- capacity/calendar laundering proibidos.

Pré-requisitos físicos autorizados apenas para especificação:
- Calibration Dossier + structured basis;
- cadence schema/obligation contract;
- source-scoped cadence support quando necessário;
- canonical SLA rule resolver;
- filter-domain validation;
- canonical rule snapshot;
- nominal due calculator;
- business-calendar arithmetic;
- fixed-deadline lineage;
- calendar effective-window;
- warning/breach/escalation schemas;
- issue/readiness helpers e test plan.

Nenhum valor numérico, calendário real ou SLARule normativa foi autorizado.

Próximo passo:
> **especificar contrato físico v0.1 dos pré-requisitos de calibração temporal e submetê-lo a novo gate antes de qualquer migration ou valor normativo.**

### CP104 — metodologia de calibração temporal

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP104.md`;
- ponteiro movido para CP104;
- `TEMPORAL_CALIBRATION_METHODOLOGY = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `TEMPORAL_CALIBRATION_PHYSICAL_PREREQUISITES = AUTHORIZED_FOR_SPECIFICATION_ONLY`;
- nenhum valor temporal normativo autorizado;
- migration 032 não autorizada;
- scheduler/notifications/auto-escalation não autorizados;
- M3 formal permanece bloqueado;
- último PASS técnico continua S5 #167;
- próximo passo: contrato físico v0.1 dos pré-requisitos + novo gate;
- modo alto recomendado;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


### Fase 4 — contrato físico de calibração temporal

Documentos:
- 41 — Contrato Físico v0.1 dos Pré-requisitos de Calibração Temporal;
- 41A — Anexo A de auditabilidade;
- 42 — Gate Adversarial/Físico;
- 43 — Recheck Final.

Estado:
> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN**

> **MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

Decisões consolidadas:
- Calibration Dossier/authority/basis/candidate/evaluation;
- cadence contract/obligation/observation normalizados;
- hybrid por composição de obligations;
- continuous excluído do CadenceContract v0.1;
- source-scope proof;
- causal SLA filter matrix;
- historical/as-of SLARule resolution;
- raw causal start versus contractual start;
- due/calendar arithmetic determinística;
- fixed-deadline lineage;
- pause extension/accountable duration auditável;
- grandfathering por registry técnico explícito, não por backdating;
- due/occurrence snapshots históricos;
- nenhum valor real autorizado.

Uploads manuais reconciliados:
- Documento 41A: commit `3af8f9e1e07a68ca12b29b5d17bf991f7059123f`;
- Documento 43: commit `1cc02552a57a3fb52559b11c2443b12f3d024902`;
- blob SHAs remotos coincidem com os arquivos entregues localmente.

Próximo passo:
> **após CP105 e novo Freshness Gate, implementar migration 032 + fixtures sintéticas + F4-TCAL-PH-T01–T230 e integrar ao S5; parar se surgir nova decisão arquitetural.**

### CP105 — contrato físico de calibração temporal

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP105.md`;
- ponteiro movido para CP105;
- `TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `F4_TCAL_PH_T01_T230 = APPROVED_MINIMUM_TEST_PLAN`;
- `MIGRATION_032 = AUTHORIZED_IN_STRICT_INFRASTRUCTURE_SCOPE`;
- valores normativos permanecem não autorizados;
- scheduler/notifications/auto-escalation permanecem não autorizados;
- M3 formal permanece bloqueado;
- próximo passo: implementar migration 032 + fixtures/testes e validar tecnicamente;
- modo médio suficiente para implementação mecânica; voltar a alto se surgir nova decisão arquitetural;
- Fase 5 não iniciada;
- pausa obrigatória preservada.


### Fase 4 — migration 032 implementada e validada

Documento técnico:
- `docs/governance/44-resultado-tecnico-migration-032-validacao-temporal-v01.md`.

Estado:
> **TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = IMPLEMENTED_AND_TECHNICALLY_VALIDATED**

> **F4_TCAL_PH_T01_T230 = PASS**

> **MIGRATION_032_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_032 = PASS**

> **S5_CANONICAL = PASS**

Validação canônica:
- HEAD técnico: `657c69024fafb6c2e6311d47091d5897730668fd`;
- run ID: `37690201061`;
- job ID: `113028117278`;
- artifact ID: `11512707774`;
- artifact: `oes-s5-evidence-37690201061`;
- size: `250711` bytes;
- digest: `sha256:bb145efb29d7c30e607136defa09c828711162e27ac71a307df229449980f826`.

Restrições preservadas:
- `NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED`;
- scheduler/notifications/auto-escalation não autorizados;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após CP106 e novo Freshness Gate, retornar ao nível metodológico/governança em modo alto para decidir qual deve ser o próximo bloco da Fase 4; não iniciar calibração normativa automaticamente.**


### CP106 — migration 032 validada

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP106.md`;
- ponteiro movido para CP106;
- `TEMPORAL_CALIBRATION_PHYSICAL_CONTRACT = IMPLEMENTED_AND_TECHNICALLY_VALIDATED`;
- `F4_TCAL_PH_T01_T230 = PASS`;
- `MIGRATION_032_IDEMPOTENCY = PASS`;
- `REBUILD_THROUGH_032 = PASS`;
- `S5_CANONICAL = PASS`;
- valores temporais normativos continuam não autorizados;
- scheduler/notifications/auto-escalation continuam não autorizados;
- M3 formal continua bloqueado;
- Fase 5 não iniciada;
- próximo passo volta ao nível metodológico/governança;
- modo alto recomendado para decidir o próximo bloco da Fase 4;
- pausa obrigatória preservada.


### Fase 4 — seleção do próximo sub-bloco pós-CP106

Documento:
- `docs/governance/45-inventario-pos-cp106-selecao-evidence-readiness-calibracao-temporal.md`.

Decisão:
> **TEMPORAL_CALIBRATION_TRACK = CONTINUES**

> **NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS**

> **NEXT_PHASE_4_SUBBLOCK = TEMPORAL_CALIBRATION_EVIDENCE_READINESS**

> **REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

Dependências preservadas:
- scheduler permanece dependente de obrigações temporais normativas aprovadas;
- notifications permanecem dependentes de eventos/thresholds aprovados;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Racional:
- infraestrutura física da calibration v0.1 já está validada;
- fixtures temporais/operacionais disponíveis são explicitamente sintéticas;
- não há no estado canônico base real suficiente para sustentar genericamente `sufficient_for_calibration`;
- casos reais de produtos científicos não equivalem automaticamente a histórico real de MonitorCycle, source latency, SLA operacional, capacity ou calendário institucional.

Próximo passo:
> **em modo alto, especificar o Protocolo de Evidence Readiness para Calibração Temporal v0.1 e submetê-lo a gate adversarial, ainda sem valores normativos.**


### CP107 — seleção do Evidence Readiness temporal

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP107.md`;
- ponteiro movido para CP107;
- `TEMPORAL_CALIBRATION_TRACK = CONTINUES`;
- `NORMATIVE_TEMPORAL_CALIBRATION = BLOCKED_PENDING_REAL_EVIDENCE_READINESS`;
- `NEXT_PHASE_4_SUBBLOCK = TEMPORAL_CALIBRATION_EVIDENCE_READINESS`;
- `REAL_CALIBRATION_DOSSIER = NOT_YET_AUTHORIZED`;
- `NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED`;
- nenhum novo migration autorizado;
- scheduler/notifications permanecem deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: Protocolo de Evidence Readiness v0.1 + gate adversarial, em modo alto;
- pausa obrigatória preservada.


### Fase 4 — protocolo de Evidence Readiness temporal

Documentos:
- `docs/governance/46-protocolo-evidence-readiness-calibracao-temporal-v01.md`;
- `docs/governance/47-gate-adversarial-evidence-readiness-calibracao-temporal.md`.

Estado:
> **TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **READINESS_ASSESSMENT_ON_REAL_CONTEXT = AUTHORIZED_UNDER_PROTOCOL**

> **FIRST_REAL_READINESS_ASSESSMENT = AUTHORIZED_FOR_SELECTION_AND_EXECUTION**

> **REAL_CALIBRATION_DOSSIER = CONDITIONALLY_AUTHORIZED_ONLY_AFTER_CONTEXT_SPECIFIC_READY**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **NO_NEW_MIGRATION = AUTHORIZED**

Hardening consolidado:
- prova positiva de realidade/admissibilidade;
- human verification para READY;
- blocker-set dominance;
- cohort/window/denominator/representativeness;
- persistência obrigatória de fonte externa material;
- lifecycle non-normative de measurement schedule;
- rationale/verificação para R7;
- source behavior separado de observed/OES detection latency;
- drift invalidation;
- fixed-deadline applicability por autoridade competente;
- pilot inference sem generalização automática;
- prospective observation sob data governance;
- reassess boundary obrigatório.

Próximo passo:
> **após checkpoint, em modo alto, selecionar o primeiro exact real context e executar somente o Evidence Readiness Assessment, sem calibração numérica.**


### CP108 — Evidence Readiness temporal validado

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP108.md`;
- ponteiro movido para CP108;
- `TEMPORAL_CALIBRATION_EVIDENCE_READINESS_PROTOCOL = PASS_WITH_ARCHITECTURAL_DECISIONS`;
- `READINESS_ASSESSMENT_ON_REAL_CONTEXT = AUTHORIZED_UNDER_PROTOCOL`;
- `FIRST_REAL_READINESS_ASSESSMENT = AUTHORIZED_FOR_SELECTION_AND_EXECUTION`;
- `REAL_CALIBRATION_DOSSIER = CONDITIONALLY_AUTHORIZED_ONLY_AFTER_CONTEXT_SPECIFIC_READY`;
- `NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED`;
- nenhum novo migration autorizado;
- scheduler/notifications continuam deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: selecionar e executar o primeiro exact real context de Evidence Readiness, em modo alto, sem calibração numérica;
- pausa obrigatória preservada.


### Fase 4 — primeiro Evidence Readiness Assessment real

Documento:
- `docs/governance/48-primeiro-evidence-readiness-assessment-real-n1-cadence.md`.

Contexto:
> **N1_01_PRODUCTVERSION_2_CADENCE_POLICY_AGGREGATE**

Resultado:
> **FIRST_REAL_READINESS_ASSESSMENT = COMPLETED**

> **PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE**

> **READY_FOR_CALIBRATION = NO**

> **REAL_CALIBRATION_DOSSIER_FOR_CONTEXT = NOT_AUTHORIZED**

> **TEMPORAL_OBSERVATION_PLAN = NOT_YET_SPECIFIED**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Blockers materiais:
- ausência de UpdateRiskProfile real para o target;
- source characterization insuficiente;
- ausência de história longitudinal de surveillance/cadence;
- ausência de human authority específica para readiness/maintenance;
- feasibility/capacity não estabelecida;
- replay longitudinal atualmente inviável.

Princípio validado:
> produto real/publicado + searches reais não equivalem a base temporal operacional suficiente para calibration.

Próximo passo:
> **após checkpoint, decidir em modo alto entre especificar um Temporal Observation Plan não normativo para N1-01 ou executar um segundo real-context readiness assessment antes de iniciar observação prospectiva.**


### CP109 — primeiro Evidence Readiness real

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP109.md`;
- ponteiro movido para CP109;
- `FIRST_REAL_READINESS_ASSESSMENT = COMPLETED`;
- contexto = N1-01 / ProductVersion 2 / cadence / policy_aggregate;
- `PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE`;
- `READY_FOR_CALIBRATION = NO`;
- Calibration Dossier real para o contexto = não autorizado;
- Temporal Observation Plan = ainda não especificado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications continuam deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir em modo alto entre observation plan não normativo para N1-01 ou segundo readiness assessment real;
- pausa obrigatória preservada.


### Fase 4 — reconciliação do primeiro readiness e seleção do segundo contexto real

Documento:
- `docs/governance/49-reconciliacao-selecao-segundo-evidence-readiness-real.md`.

Reconciliação:
> **FIRST_REAL_READINESS_ASSESSMENT_RESULT = PRESERVED**

> **DOCUMENT_48_SELECTION_RATIONALE = PARTIALLY_CORRECTED**

Foi identificada e reconciliada divergência factual na seção comparativa do Documento 48: o Caso Real N2/dCBT-I não permaneceu em pré-publicação. CP28 e Documentos 66–67 confirmam A2, `published`, owner governance approval e publication gate PASS.

A divergência não invalida os blockers específicos do primeiro assessment N1-01.

Decisão:
> **OPTION_B = SELECTED**

> **SECOND_REAL_READINESS_CONTEXT = N2_RC01_PRODUCTVERSION_1_CADENCE_POLICY_AGGREGATE**

> **SECOND_REAL_READINESS_ASSESSMENT = SELECTED_NOT_EXECUTED**

> **TEMPORAL_OBSERVATION_PLAN_N1_01 = DEFERRED_PENDING_SECOND_ASSESSMENT**

O N2 selecionado é Product `OES-P-2026-000401`, ProductVersion `81000000-0000-0000-0000-000000000701`, N2/evidence_sheet, A2/published, com quatro Search rows reais em PubMed/MEDLINE, BVS/LILACS e ClinicalTrials.gov.

Restrições preservadas:
- nenhum Calibration Dossier real autorizado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications permanecem deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, executar o segundo Evidence Readiness Assessment real no N2/dCBT-I, cadence / policy_aggregate, sem calibração numérica nem observação prospectiva.**


### CP110 — reconciliação do readiness e segundo contexto real

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP110.md`;
- ponteiro de continuidade movido para CP110;
- resultado do primeiro readiness N1-01 preservado;
- justificativa comparativa do Documento 48 parcialmente corrigida pelo Documento 49;
- N2/dCBT-I A2/published selecionado como segundo contexto real;
- `SECOND_REAL_READINESS_ASSESSMENT = SELECTED_NOT_EXECUTED`;
- `TEMPORAL_OBSERVATION_PLAN_N1_01 = DEFERRED_PENDING_SECOND_ASSESSMENT`;
- nenhum valor temporal normativo autorizado;
- nenhum Calibration Dossier real autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications continuam deferidos;
- auto-escalation permanece não autorizada;
- M3 formal permanece bloqueado;
- Fase 5 não iniciada;
- próximo passo: executar, em modo alto, o segundo Evidence Readiness Assessment real no N2/dCBT-I;
- pausa obrigatória preservada.


### Fase 4 — segundo Evidence Readiness Assessment real

Documento:
- `docs/governance/50-segundo-evidence-readiness-assessment-real-n2-cadence.md`.

Contexto:
> **SECOND_REAL_READINESS_CONTEXT = N2_RC01_PRODUCTVERSION_1_CADENCE_POLICY_AGGREGATE**

Resultado:
> **SECOND_REAL_READINESS_ASSESSMENT = COMPLETED**

> **PRIMARY_READINESS_STATE = INSUFFICIENT_EVIDENCE**

> **READY_FOR_CALIBRATION = NO**

> **REAL_CALIBRATION_DOSSIER_FOR_N2 = NOT_AUTHORIZED**

Evidência real relevante:
- ProductVersion N2 A2/published;
- 4 searches reais;
- PubMed/MEDLINE, BVS/LILACS e ClinicalTrials.gov;
- 6 SearchHits persistidos;
- 6 ScreeningDecisions;
- provenance/currency/assurance reais.

Blockers materiais:
- `INSUFFICIENT_NEED_EVIDENCE`;
- `NEEDS_SOURCE_CHARACTERIZATION`;
- `NEEDS_PROSPECTIVE_OBSERVATION`;
- `NEEDS_HUMAN_AUTHORITY`;
- `FEASIBILITY_NOT_ESTABLISHED`;
- `REPLAY_NOT_CURRENTLY_FEASIBLE`.

Comparação N1/N2:
- blockers centrais recorrentes nos dois contexts;
- source diversity do N2 não elevou cadence readiness;
- déficit passa a ser interpretado, com cautela, como parcialmente transversal ao estado operacional atual do OES;
- terceiro readiness assessment imediato não selecionado.

Estado:
> **TWO_REAL_CONTEXTS_ASSESSED = YES**

> **THIRD_IMMEDIATE_READINESS_ASSESSMENT = NOT_SELECTED**

> **TEMPORAL_EVIDENCE_ACQUISITION_DESIGN = NEXT_DECISION**

Restrições preservadas:
- nenhum Calibration Dossier real;
- nenhum valor temporal normativo;
- nenhum novo migration;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 formal bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, decidir e especificar o escopo metodológico do próximo bloco de aquisição de evidência temporal não normativa, escolhendo entre plano transversal reutilizável + instância piloto versus plano inicialmente específico de um target.**


### CP111 — segundo Evidence Readiness real

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP111.md`;
- ponteiro de continuidade movido para CP111;
- segundo readiness assessment real concluído no N2/dCBT-I;
- resultado = **INSUFFICIENT_EVIDENCE**;
- READY_FOR_CALIBRATION = **NO**;
- dois contexts reais A2/published agora avaliados;
- blockers temporais centrais recorrentes em N1/N2;
- diversidade de fontes de produção não substitui source characterization temporal ou longitudinal observation;
- terceiro readiness assessment imediato não selecionado;
- próximo problema = desenho de aquisição temporal não normativa;
- nenhum Calibration Dossier real autorizado;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir em modo alto entre plano transversal reutilizável + instância piloto e plano inicialmente target-specific;
- pausa obrigatória preservada.


### Fase 4 — arquitetura de aquisição de evidência temporal não normativa

Documentos:
- `docs/governance/51-arquitetura-aquisicao-evidencia-temporal-nao-normativa-v01.md`;
- `docs/governance/52-gate-adversarial-arquitetura-aquisicao-evidencia-temporal.md`;
- `docs/governance/53-recheck-final-arquitetura-aquisicao-evidencia-temporal.md`.

Decisão:
> **TEMPORAL_EVIDENCE_ACQUISITION_ARCHITECTURE = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **ARCHITECTURE_CHOICE = REUSABLE_TRANSVERSAL_PROTOCOL_PLUS_TARGET_INSTANCE**

> **FIRST_OBSERVATION_INSTANCE = AUTHORIZED_FOR_SELECTION_AND_SPECIFICATION_ONLY**

> **REAL_PROSPECTIVE_OBSERVATION = NOT_AUTHORIZED**

Arquitetura:
- protocolo transversal reutilizável;
- instância target/source-specific;
- Observation Epoch versionado;
- measurement schedule explicitamente não normativo;
- M1 pilot não é Monitor;
- Search só pode registrar Search semanticamente real;
- pre-calibration measurement não é CadenceObservation;
- semantic storage mapping obrigatório;
- latency endpoints e precision explícitos;
- candidate source universe separado de production-search sources;
- authority humana explícita exigida para execução;
- outcome de measurement event multidimensional;
- pilot effort separado de sustainable capacity;
- drift partitioning;
- Result Package deve retornar a novo Evidence Readiness antes de Calibration Dossier;
- physical contract novo apenas se houver lacuna material comprovada.

Gate:
- Documento 52 first pass = **REVISE**;
- Documento 51 hardenizado;
- Documento 53 recheck = **PASS_WITH_ARCHITECTURAL_DECISIONS**.

Estado físico:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = DEFERRED_PENDING_INSTANCE_NEED**

Restrições:
- nenhum source check real autorizado;
- nenhuma measurement schedule em execução;
- nenhum UpdateRiskProfile aprovado fabricado;
- nenhum Calibration Dossier;
- nenhum valor temporal normativo;
- nenhum novo migration;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, selecionar entre N1-01 e N2/dCBT-I o primeiro exact target da Temporal Observation Plan Instance e especificar a instância completa, sem executar observação real.**


### CP112 — arquitetura de aquisição temporal não normativa

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP112.md`;
- ponteiro de continuidade movido para CP112;
- arquitetura de aquisição temporal = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- escolha = protocolo transversal reutilizável + instância target/source-specific;
- primeira instância = autorizada apenas para seleção/especificação;
- observação prospectiva real = não autorizada;
- semantic storage mapping, Observation Epoch e authority humana explícita obrigatórios;
- M1 pilot não é Monitor;
- pre-calibration measurement não é CadenceObservation;
- physical contract novo fica deferido até lacuna material comprovada;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- scheduler/notifications deferidos;
- auto-escalation não autorizada;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: selecionar N1-01 ou N2/dCBT-I e especificar a primeira Temporal Observation Plan Instance, em modo alto, sem execução;
- pausa obrigatória preservada.


### Fase 4 — seleção e especificação da primeira Temporal Observation Plan Instance

Documentos:
- `docs/governance/54-primeira-temporal-observation-plan-instance-n2-dcbti.md`;
- `docs/governance/55-gate-target-specific-topi-n2-dcbti-01.md`;
- `docs/governance/56-pacote-decisao-authority-phase-a-topi-n2-dcbti-01.md`.

Seleção:
> **FIRST_TEMPORAL_OBSERVATION_PLAN_TARGET = N2_RC01_DCBTI_PRODUCTVERSION_1**

> **FIRST_TEMPORAL_OBSERVATION_PLAN_INSTANCE = TOPI_N2_DCBTI_V01**

Racional:
- maior information gain multi-source;
- melhor stress-test de semantic storage e source-specific latency;
- custo operacional maior, mas ainda sem execução;
- authority feasibility semelhante ao N1;
- menor risco de overfitting a um único source ecosystem.

Plano:
- Phase A = source characterization + source-access/data-governance review + semantic storage confirmation + UpdateRiskProfile evidence preparation;
- Phase B = bloqueada até Phase A Result Package + amendment v0.2 + recheck;
- measurement schedule = NOT_SELECTED;
- nenhum intervalo experimental definido antes de source characterization.

Gate target-specific:
> **TARGET_SPECIFIC_GATE = PASS_FOR_AUTHORITY_REQUEST_ONLY**

> **PHASE_A_SPECIFICATION = PASS**

> **PHASE_A_EXECUTION = BLOCKED_PENDING_EXPLICIT_AUTHORITY**

Blockers de execução:
- explicit Phase A execution authority ausente;
- source-access/data-governance review ainda pendente;
- start boundary não satisfeito.

Authority package:
> **AUTHORITY_DECISION = PENDING**

Documento 56 exige decisão explícita APPROVED / REVISE / REJECTED vinculada à Phase A / TOPI-N2-DCBTI-01.

Restrições:
- nenhuma source interaction real antes da decisão;
- Phase B bloqueada;
- nenhum Monitor/MonitoringCycle;
- nenhum cadence/UpdatePolicy/Calibration Dossier;
- nenhum valor temporal normativo;
- nenhum scheduler/notifications/auto-escalation;
- nenhum novo migration;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **obter decisão humana explícita sobre o Documento 56.**


### CP113 — primeira TOPI e authority decision

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP113.md`;
- ponteiro movido para CP113;
- N2/dCBT-I selecionado como primeiro target;
- TOPI-N2-DCBTI-01 v0.1 especificada;
- target-specific gate = **PASS_FOR_AUTHORITY_REQUEST_ONLY**;
- Phase A specification = PASS;
- Documento 56 criado para decisão explícita de authority;
- `AUTHORITY_DECISION = PENDING`;
- Phase A execution = não autorizada;
- Phase B bloqueada;
- measurement schedule = não selecionada;
- nenhuma source interaction real autorizada antes da decisão;
- nenhum valor temporal normativo/migration nova autorizado;
- Fase 5 não iniciada;
- próximo passo: aguardar APPROVED / REVISE / REJECTED explicitamente vinculado à Phase A / Documento 56 / TOPI-N2-DCBTI-01;
- alta complexidade arquitetural deste bloco encerrada; modo médio suficiente após decisão, salvo nova questão complexa;
- pausa obrigatória preservada.


### Fase 4 — authority registrada e Phase A da TOPI-N2-DCBTI-01 concluída

Documentos:
- `docs/governance/57-registro-decisao-authority-phase-a-topi-n2-dcbti-01.md`;
- `docs/governance/58-topi-n2-dcbti-phase-a-characterization-package.md`.

Authority:
> **AUTHORITY_DECISION = APPROVED_FOR_PHASE_A**

> **PHASE_A_OPERATIONAL_EXECUTION_AUTHORITY = GRANTED**

Decisão explícita do owner:
`Approved - phase A / documento 56 / TOPI-N2-DCBTI-01`.

Phase A:
> **PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS**

Source characterization:
- PubMed = `SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_CONTROLS`;
- BVS/LILACS = `PARTIAL`;
- ClinicalTrials.gov = `SUFFICIENT_FOR_PHASE_B_DESIGN_WITH_RUNTIME_CONNECTIVITY_CHECK`.

Achados:
- PubMed possui E-utilities e datas CRDT/EDAT úteis para observability; updates de corpus são documentados como diários, sem implicar latency individual fixa;
- BVS/LILACS possui IAHx/FI-Admin e modelo com creation/change dates, mas acesso programático público reproduzível não foi estabelecido nesta Phase A;
- ClinicalTrials.gov possui API v2 REST/OpenAPI/JSON e posting-date fields adequados para observar processo registral;
- falhas de abertura por ferramenta foram classificadas como `TOOL_MEDIATED / FAILURE_ATTRIBUTION_UNKNOWN`, nunca como source outage.

Data governance:
- PubMed = PASS_WITH_CONTROLS;
- BVS/LILACS = metadata characterization permitida, Phase B access unresolved;
- ClinicalTrials.gov = PASS_WITH_CONTROLS.

UpdateRiskProfile:
> **EVIDENCE_PREPARATION_ONLY**

Nenhum rating A1–A5/B1–B5 foi declarado authoritative.

Measurement:
> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B = NOT_AUTHORIZED**

Physical contract:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = NOT_REQUIRED_FOR_PHASE_A**

Necessidade de event object específico para Phase B = unresolved.

Restrições:
- nenhuma repeated prospective measurement executada;
- nenhuma cadence/Monitor/UpdatePolicy/Calibration Dossier;
- nenhum valor temporal normativo;
- nenhum novo migration;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, especificar Plan Amendment v0.2 da TOPI-N2-DCBTI-01 com source inclusion, Phase B event model, storage mapping e eventual measurement schedule non-normative; depois novo target-specific gate e nova authority antes de Phase B.**


### CP114 — TOPI Phase A characterization

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP114.md`;
- ponteiro movido para CP114;
- owner approval da Phase A registrada no Documento 57;
- Phase A Characterization Package = Documento 58;
- `PHASE_A = COMPLETED_WITH_SOURCE_SPECIFIC_LIMITATIONS`;
- PubMed = sufficient for Phase B design with controls;
- BVS/LILACS = partial / programmatic path unresolved;
- ClinicalTrials.gov = sufficient for Phase B design with runtime connectivity check;
- UpdateRiskProfile = evidence-preparation only;
- measurement schedule = NOT_SELECTED;
- Phase B = NOT_AUTHORIZED;
- nenhum valor temporal normativo autorizado;
- nenhum novo migration autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: Plan Amendment v0.2;
- modo alto recomendado novamente para source inclusion / schedule / possible physical-event decision;
- pausa obrigatória preservada.


### Fase 4 — TOPI Plan Amendment v0.2 e boundary da Phase B

Documentos:
- `docs/governance/59-topi-n2-dcbti-plan-amendment-v02-phase-b-boundary.md`;
- `docs/governance/60-recheck-target-specific-topi-v02-phase-b-boundary.md`.

Plan Amendment:
> **PLAN_VERSION = V0_2_CANDIDATE_RECHECKED**

Source inclusion:
> **PHASE_B_INCLUDED_SOURCES = PUBMED_MEDLINE + CLINICALTRIALS_GOV**

> **BVS_LILACS_PHASE_B_STATUS = DEFERRED_SOURCE_DEBT**

Event model:
> **PHASE_B_EVENT_MODEL = SOURCE_SPECIFIC_NON_NORMATIVE_MEASUREMENT_EVENT**

Physical finding:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = AUTHORIZED_FOR_SPECIFICATION_ONLY**

A lacuna física foi confirmada porque:
- `artifact.artifact` normaliza metadata de arquivo, não event semantics;
- `investigation.search` só é válido para Search científica real;
- `maintenance.evidence_event` exige MonitoringCycle;
- `maintenance.cadence_observation` exige CadenceObligation;
- repeated experimental measurement requer planned opportunities, missingness, source-specific outcomes, failure attribution e replay estruturado.

Measurement schedule:
> **MEASUREMENT_SCHEDULE = DEFERRED_PENDING_PHYSICAL_CONTRACT**

Nenhum número foi selecionado.

Recheck:
> **TOPI_N2_DCBTI_V02_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

O PASS autoriza somente specification do physical contract e test plan.

Restrições:
- Phase B authority não solicitada;
- Phase B execution não autorizada;
- migration não autorizada;
- cadence/UpdatePolicy/Calibration Dossier não autorizados;
- normative temporal values não autorizados;
- scheduler/notifications/auto-escalation não autorizados;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, especificar contrato físico v0.1 de ObservationEpoch/TemporalMeasurementEvent não normativos, com constraints, lifecycle, replay/readiness views e test plan; depois gate adversarial antes de qualquer migration.**


### CP115 — TOPI v0.2 / Phase B boundary

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-07_CP115.md`;
- ponteiro movido para CP115;
- Plan Amendment v0.2 rechecked = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- PubMed + ClinicalTrials.gov = included candidates da Phase B;
- BVS/LILACS = deferred source debt;
- event model = source-specific non-normative measurement event;
- physical gap = confirmed;
- non-normative physical contract = authorized for specification only;
- measurement schedule = deferred pending physical contract;
- Phase B authority = not requested;
- Phase B execution = not authorized;
- migration = not authorized;
- nenhum valor temporal normativo autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: contrato físico v0.1 de ObservationEpoch/TemporalMeasurementEvent + test plan + gate adversarial;
- modo alto permanece recomendado;
- pausa obrigatória preservada.


### Fase 4 — contrato físico v0.1 de aquisição temporal não normativa

Documentos:
- `docs/governance/61-contrato-fisico-aquisicao-temporal-nao-normativa-v01.md`;
- `docs/governance/62-gate-adversarial-contrato-fisico-aquisicao-temporal-v01.md`;
- `docs/governance/63-recheck-final-contrato-fisico-aquisicao-temporal-v01.md`.

First pass:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = REVISE**

Hardening incorporado:
- execution/item/timepoint separation;
- OpportunityResolution append-only;
- count/novelty semantics;
- direct failure-evidence locator;
- recursive anti-normative JSON guard;
- data-driven runtime connectivity;
- source time-semantics registry;
- retry closure;
- no early completion;
- target drift;
- authority resolver;
- frozen measurement Investigation;
- baseline/novelty semantics;
- latency derived from item timepoints;
- strict effort payload;
- Artifact liveness;
- finite frozen opportunity set;
- explicit source debt;
- no reuse of `maintenance.contract_epoch`;
- migration/fixture separation.

Final recheck:
> **NON_NORMATIVE_OBSERVATION_PHYSICAL_CONTRACT = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **PHYSICAL_SCHEMA = READY_FOR_MIGRATION_DECISION**

> **TEST_PLAN = READY_FOR_IMPLEMENTATION_IF_MIGRATION_AUTHORIZED**

Root physical objects:
- temporal_observation_plan;
- temporal_observation_source;
- temporal_observation_epoch;
- temporal_observation_epoch_source;
- temporal_observation_authority;
- temporal_measurement_opportunity;
- temporal_measurement_event;
- temporal_measurement_opportunity_resolution;
- temporal_measurement_item;
- temporal_measurement_item_timepoint;
- temporal_measurement_event_artifact;
- temporal_observation_deviation.

Test plan:
> **TNO-T01–T90 specified**

Migration:
> **MIGRATION_033 = ELIGIBLE_FOR_SEPARATE_AUTHORIZATION**

> **MIGRATION_033 = NOT_YET_AUTHORIZED**

Measurement:
> **MEASUREMENT_SCHEDULE = NOT_SELECTED**

> **PHASE_B_AUTHORITY = NOT_REQUESTED**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

Restrições:
- zero seed real;
- nenhum numeric schedule;
- nenhum normative temporal value;
- nenhum Monitor/CadenceContract/UpdatePolicy binding;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, decidir autorização e boundary técnico da candidate migration 033, incluindo decomposição de arquivos, testes/fixtures, CI e no-seed guarantee.**


### CP116 — contrato físico v0.1 final PASS

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP116.md`;
- ponteiro movido para CP116;
- contrato físico v0.1 = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- physical schema = ready for migration decision;
- test plan TNO-T01–T90 = ready if migration authorized;
- migration 033 = eligible for separate authorization;
- migration 033 ainda não autorizada;
- schedule = finite frozen opportunity-set contract, mas nenhum timestamp real selecionado;
- measurement schedule = NOT_SELECTED;
- Phase B authority = not requested;
- Phase B execution = not authorized;
- nenhum normative temporal value autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: decidir migration 033 e boundary técnico em modo alto;
- implementação mecânica poderá voltar a modo médio após autorização/boundary;
- pausa obrigatória preservada.


### Fase 4 — autorização e boundary técnico da migration 033

Documento:
- `docs/governance/64-autorizacao-boundary-tecnico-migration-033.md`.

Decisão:
> **MIGRATION_033 = AUTHORIZED_FOR_IMPLEMENTATION**

Boundary:
> **INFRASTRUCTURE_ONLY / SYNTHETIC_TESTS_ONLY / ZERO_REAL_SEED**

Decomposição autorizada:
- `033_non_normative_temporal_observation.sql`;
- `033a_temporal_observation_core.sql`;
- `033b_temporal_measurement_core.sql`;
- `033c_temporal_observation_guards.sql`;
- `033d_temporal_observation_helpers_views.sql`;
- `033e_temporal_observation_issue_validators.sql`.

Testes autorizados:
- `f4-temporal-observation-fixtures.sql`;
- `f4-temporal-observation-smoke-tests.sql`;
- `f4-temporal-observation-tests.sql`.

CI:
- integrar ao workflow canônico `.github/workflows/validate-s5.yml`;
- adicionar path triggers, hashes, install 033, smoke, synthetic fixtures/tests, idempotency, rebuild e regressions;
- logs prefixados `F4-TNO`.

Decisões técnicas:
- master + fragments, coerente com migrations 031/032;
- não criar workflow paralelo;
- não reutilizar `maintenance.contract_epoch`;
- rollback operacional = rebuild-from-zero;
- no-seed guarantee obrigatória;
- normative isolation guarantee obrigatória.

Restrições preservadas:
- measurement schedule = NOT_SELECTED;
- Phase B authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- nenhum real TOPI row/authority/opportunity/event;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, implementar migration 033 + tests + validate-s5 integration e executar CI.**

Modo:
> **modo médio suficiente para implementação mecânica dentro do boundary aprovado; retornar ao modo alto se surgir nova decisão arquitetural/schema/lifecycle.**


### CP117 — autorização da migration 033

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP117.md`;
- ponteiro movido para CP117;
- migration 033 = **AUTHORIZED_FOR_IMPLEMENTATION**;
- boundary = infrastructure-only / synthetic-tests-only / zero-real-seed;
- master + fragments 033a–033e autorizados;
- fixtures/smoke/full tests autorizados;
- integração no `validate-s5.yml` autorizada;
- maintenance.contract_epoch não será reutilizado;
- measurement schedule continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value autorizado;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: implementação técnica da 033 em modo médio;
- pausa obrigatória preservada.


### Fase 4 — implementação parcial da migration 033 bloqueada por decisão de schema

Documento:
- `docs/governance/65-blocker-migration-033-frozen-opportunity-set.md`.

Implementação já persistida:
- 033 master;
- 033a core;
- 033b measurement core;
- 033c guards;
- authority resolver hardening.

Estado:
> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = BLOCKED_PENDING_SCHEMA_DECISION**

Blocker:
- o contrato exige finite frozen opportunity set;
- `artifact.artifact` guarda metadados/locator/hash, não o conteúdo JSON;
- PostgreSQL não consegue provar que Opportunity rows correspondem exatamente aos timestamps do Artifact;
- count-only ou validação externa isolada enfraqueceriam replay/integridade.

Opções registradas:
- A: `opportunity_set_payload jsonb` estruturado em EpochSource;
- B: ampliar Artifact para conteúdo consultável;
- C: nova tabela filha de frozen schedule design;
- D: validação externa apenas — não recomendada.

Recomendação ainda não aprovada:
> **Opção A** como menor expansão arquitetural.

Boundary:
- não continuar 033d/033e;
- não criar fixtures/tests/CI;
- não alterar schema para resolver blocker em modo médio;
- measurement schedule continua NOT_SELECTED;
- Phase B continua não autorizada;
- nenhum valor temporal normativo autorizado.

Próximo passo:
> **modo alto: decidir persistência/enforcement do frozen opportunity set; depois retomar implementação.**


### CP118 — blocker de schema na migration 033

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP118.md`;
- ponteiro movido para CP118;
- migration 033 parcialmente implementada, ainda não validada;
- 033 master/033a/033b/033c persistidos;
- frozen opportunity-set enforcement = unresolved;
- Documento 65 registra opções A–D;
- implementação suspensa antes de 033d/033e/fixtures/tests/CI;
- measurement schedule continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value autorizado;
- próximo passo requer modo alto;
- pausa obrigatória preservada.


### Fase 4 — decisão de schema do frozen opportunity set

Documentos:
- `docs/governance/66-decisao-schema-frozen-opportunity-set-migration-033.md`;
- `docs/governance/67-recheck-decisao-schema-frozen-opportunity-set.md`.

Decisão:
> **SCHEMA_DECISION = PASS_WITH_ARCHITECTURAL_DECISIONS**

> **FROZEN_OPPORTUNITY_SET_CANONICAL_STORE = MEASUREMENT_SCHEDULE_PAYLOAD**

> **SCHEDULE_DEFINITION_ARTIFACT_ROLE = PROVENANCE_ONLY**

> **NEW_TABLE_REQUIRED = NO**

> **NEW_COLUMN_REQUIRED = NO**

O payload canônico usa schema lógico:
> `oes.temporal_opportunity_set/0.1`

Regras:
- finite opportunity set;
- timestamps concretos;
- sem recurrence generator;
- sem opportunity_count redundante;
- opportunity numbers positivos, únicos e contíguos;
- planned_for com offset explícito/Z;
- forbidden temporal keys recursivos;
- payload imutável via EpochSource.

Lifecycle corrigido:
- EpochSource + payload + Opportunity rows em `draft`;
- authorization exige igualdade payload↔rows;
- authority precisa ser posterior/simultânea ao design freeze;
- nenhuma Opportunity nova após saída de draft;
- activation permanece etapa separada.

Artifact:
- `schedule_definition_artifact_uuid` = provenance/rationale;
- não controla lista de timestamps;
- não há dependência do conteúdo externo do Artifact para enforcement.

Test plan:
> **TNO-T01–T100**

Supersession documental:
- Documento 66/67 supersedem apenas as partes do Documento 61/63 relativas ao frozen opportunity set/Artifact;
- sem rewrite retroativo.

Estado da migration:
> **MIGRATION_033 = PARTIALLY_IMPLEMENTED_NOT_VALIDATED**

> **MIGRATION_033_IMPLEMENTATION = AUTHORIZED_TO_RESUME_AFTER_CHECKPOINT**

Restrições:
- measurement schedule real continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, retornar a modo médio e corrigir 033c; depois concluir 033d/033e, fixtures, TNO-T01–T100, validate-s5 integration e CI.**


### CP119 — frozen opportunity-set schema decision

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP119.md`;
- ponteiro movido para CP119;
- schema decision = **PASS_WITH_ARCHITECTURAL_DECISIONS**;
- canonical frozen opportunity set = `measurement_schedule_payload`;
- schedule Artifact = provenance-only;
- nenhuma tabela/coluna nova necessária;
- Opportunity materialization = draft;
- authority freshness guard obrigatório;
- test plan = TNO-T01–T100;
- migration 033 = partially implemented/not validated;
- implementation autorizada a retomar após checkpoint;
- measurement schedule real continua NOT_SELECTED;
- Phase B authority/execution continuam não autorizadas;
- nenhum normative temporal value autorizado;
- próximo passo: modo médio, corrigir 033c e concluir implementação/CI;
- pausa obrigatória preservada.


### Fase 4 — migration 033 tecnicamente validada

Documento:
- `docs/governance/68-resultado-tecnico-migration-033-observacao-temporal-nao-normativa.md`.

Resultado:
> **MIGRATION_033 = TECHNICALLY_VALIDATED**

> **NON_NORMATIVE_TEMPORAL_OBSERVATION_INFRASTRUCTURE = AVAILABLE_NOT_ACTIVATED_FOR_REAL_TOPI**

> **F4_TNO_TESTS = TNO_T01_TO_T100_PASS**

> **MIGRATION_033_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_033 = PASS**

> **ZERO_REAL_SEED = PASS**

> **NORMATIVE_ISOLATION = PASS**

Implementado:
- 033 master;
- 033a–033e;
- synthetic fixtures;
- smoke tests;
- TNO-T01–T100;
- integração no `validate-s5.yml`.

CI promovida:
- workflow: OES PoC-S5 PostgreSQL Validation;
- run: `37802083791`;
- run number: `214`;
- validated HEAD: `6b9efb3a2439aa700fe8b38334995cf008327fb5`;
- conclusion: `success`;
- artifact ID: `11560209688`;
- artifact: `oes-s5-evidence-37802083791`;
- digest: `sha256:fc2909171dfa16f94cccae8cc5bd739b11c6091c4b04bb3ad78136af4ecd0c6b`.

Invariantes:
- frozen opportunity set canônico = `measurement_schedule_payload`;
- schedule Artifact = provenance-only;
- Opportunity materialization = draft;
- authority freshness guard ativo;
- latency derivada de item timepoints;
- source debt preservado;
- nenhum scheduler/recurrence generator;
- nenhuma ligação causal normativa 032.

Restrições:
- TOPI real ainda não materializada;
- measurement schedule real = NOT_SELECTED;
- Phase B authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada.

Próximo passo:
> **após checkpoint, em modo alto, definir o desenho experimental finito da Phase B da TOPI-N2-DCBTI-01 antes de qualquer materialização/authority real.**


### CP120 — migration 033 technical PASS

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP120.md`;
- ponteiro movido para CP120;
- migration 033 = TECHNICALLY_VALIDATED;
- infrastructure = available, not activated for real TOPI;
- TNO-T01–T100 = PASS;
- idempotency = PASS;
- rebuild-through-033 = PASS;
- prior regressions = PASS;
- zero-real-seed = PASS;
- normative isolation = PASS;
- promoted CI run = 37802083791 / run 214;
- validated HEAD = `6b9efb3a2439aa700fe8b38334995cf008327fb5`;
- evidence artifact = `11560209688`;
- digest = `sha256:fc2909171dfa16f94cccae8cc5bd739b11c6091c4b04bb3ad78136af4ecd0c6b`;
- TOPI-N2 real materialization = NOT_AUTHORIZED;
- measurement schedule = NOT_SELECTED;
- Phase B authority/execution = NOT_AUTHORIZED;
- nenhum normative temporal value;
- M3 bloqueado;
- Fase 5 não iniciada;
- próximo passo: modo alto para desenho experimental finito da Phase B;
- pausa obrigatória preservada.


### Fase 4 — desenho experimental finito da Phase B / TOPI-N2-DCBTI-01

Documentos:
- `docs/governance/69-desenho-experimental-finito-phase-b-topi-n2-dcbti.md`;
- `docs/governance/70-recheck-desenho-experimental-phase-b-topi-n2-dcbti.md`;
- `docs/governance/71-pacote-authority-preparacao-phase-b-topi-n2-dcbti.md`.

Decisão:
> **PHASE_B_EXPERIMENTAL_DESIGN = FINITE_IRREGULAR_SOURCE_SPECIFIC_OPPORTUNITY_SET**

> **TOPI_N2_DCBTI_V02_FINAL_DESIGN = READY_FOR_PREPARATION_AUTHORITY_REQUEST**

Candidate Epoch:
- code: `B1`;
- start boundary: `2026-10-19T08:00:00-03:00`;
- review boundary: `2026-11-10T18:00:00-03:00`;
- timezone: `America/Recife`.

PubMed:
- included candidate;
- 8 finite opportunities;
- planned at 09:00 -03 on 2026-10-19, 10-20, 10-22, 10-26, 10-29, 11-03, 11-06, 11-09;
- measurement strategy = fixed union of historical review + RCT discovery scopes;
- no relative date query;
- first successful event = epoch baseline acquisition, not scientific novelty.

ClinicalTrials.gov:
- included candidate;
- 6 finite opportunities;
- planned at 10:30 -03 on 2026-10-19, 10-22, 10-27, 10-30, 11-04, 11-09;
- query semantics preserved from historical case;
- actual API request/parameterization must be frozen after connectivity verification.

BVS/LILACS:
> **DEFERRED_SOURCE_DEBT**

Architectural ordering:
1. preparation authority;
2. minimal runtime connectivity probes;
3. Artifact/query/interface freeze;
4. real draft materialization;
5. design_frozen_at;
6. new Phase B execution authority package;
7. owner decision after freeze;
8. authority row;
9. authorized_non_normative;
10. active;
11. measurement execution.

Reason:
- `runtime_connectivity_status` is immutable in EpochSource;
- execution authority must satisfy `decided_at >= design_frozen_at`.

Recheck:
> **TOPI_N2_DCBTI_PHASE_B_DESIGN_RECHECK = PASS_WITH_ARCHITECTURAL_DECISIONS**

Current authority package:
> **DOCUMENT_71 = AWAITING_EXPLICIT_OWNER_DECISION**

Current restrictions:
- generic `Prossiga` is not authority;
- runtime connectivity probes = NOT_AUTHORIZED;
- real TOPI draft materialization = NOT_AUTHORIZED;
- design_frozen_at = NOT_ESTABLISHED;
- Phase B execution authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- normative temporal values = NOT_AUTHORIZED;
- M3 blocked;
- Phase 5 not started.

Schedule expiry:
- if preparation + draft freeze + later execution authority are not completed before first planned opportunity, do not slide dates;
- classify candidate schedule as expired_not_executed and re-version/re-gate.

Next step:
> **aguardar explicit owner decision on Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01.**


### CP121 — Phase B finite design / preparation authority pending

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP121.md`;
- ponteiro movido para CP121;
- Phase B design = finite irregular source-specific;
- PubMed = 8 opportunities;
- ClinicalTrials.gov = 6 opportunities;
- BVS/LILACS = deferred source debt;
- target-specific recheck = PASS_WITH_ARCHITECTURAL_DECISIONS;
- Documento 71 = AWAITING_EXPLICIT_OWNER_DECISION;
- preparation authority = PENDING;
- runtime connectivity probes = NOT_AUTHORIZED;
- real TOPI draft materialization = NOT_AUTHORIZED;
- design_frozen_at = NOT_ESTABLISHED;
- Phase B execution authority = NOT_REQUESTED;
- Phase B execution = NOT_AUTHORIZED;
- normative temporal values = NOT_AUTHORIZED;
- M3 blocked;
- Phase 5 not started;
- next step = explicit owner decision on Phase B preparation / Documento 71 / TOPI-N2-DCBTI-01;
- generic Prossiga is not authority;
- mandatory pause preserved.


### Fase 4 — Phase B preparation concluída; execution authority pendente

Documentos:
- `docs/governance/72-registro-authority-preparacao-phase-b-topi-n2-dcbti.md`;
- `docs/governance/73-resultado-probes-conectividade-preparacao-phase-b-topi-n2-dcbti.md`;
- `docs/governance/74-resultado-preparacao-phase-b-topi-n2-dcbti.md`;
- `docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md`.

Estado:
> **PREPARATION_AUTHORITY = APPROVED_AND_EXECUTED**

> **RUNTIME_CONNECTIVITY = VERIFIED_FOR_B1_INTERFACES**

> **REAL_TOPI_DRAFT_MATERIALIZATION = COMPLETED**

> **TOPI_PREP_TESTS = TOPI_PREP_T01_TO_T30_PASS**

> **OBSERVATION_EPOCH_B1 = DRAFT_FROZEN**

> **DESIGN_FROZEN_AT = 2026-10-08T13:12:23-03:00**

> **PHASE_B_EXECUTION_AUTHORITY = AWAITING_EXPLICIT_OWNER_DECISION**

> **PHASE_B_EXECUTION = NOT_AUTHORIZED**

> **MEASUREMENT_EVENT_COUNT = 0**

Connectivity evidence:
- run `37806308031` / run 215 = success;
- PubMed E-utilities = VERIFIED;
- ClinicalTrials.gov API v2 = VERIFIED;
- no target-specific query executed;
- evidence artifact `11563182298`;
- digest `sha256:7f01b41e7156993c547e936e53d7cf161490d5768b120de5051c4722fd74284f`.

Draft validation:
- run `37807367640` / run 216 = success;
- validated HEAD `f1034c439082ffdf3f2fbba345daf00b2e2c4a35`;
- TOPI-PREP-T01–T30 = PASS;
- rebuild = PASS;
- evidence artifact `11563323408`;
- digest `sha256:3516f2de565655628ab74ecfe5ad0d48fe33658b7ceb9561e61e1802259b12c8`.

Physical identity:
- Plan UUID `b3100000-0000-0000-0000-000000000001`;
- Epoch B1 UUID `b3120000-0000-0000-0000-000000000001`;
- PubMed EpochSource `b3130000-0000-0000-0000-000000000001`;
- ClinicalTrials.gov EpochSource `b3130000-0000-0000-0000-000000000002`;
- PubMed opportunities = 8;
- ClinicalTrials.gov opportunities = 6;
- BVS/LILACS = deferred source debt.

Execution boundary:
- Documento 75 awaits explicit owner decision;
- generic `Prossiga` is not execution authority;
- no transition to authorized_non_normative;
- no transition to active;
- no MeasurementEvent;
- no OpportunityResolution;
- no normative temporal values;
- M3 blocked;
- Phase 5 not started.

Next step:
> **await explicit owner decision: APPROVED / REVISE / REJECTED — Phase B execution / Documento 75 / TOPI-N2-DCBTI-01 / Epoch B1.**


### CP122 — B1 draft frozen / execution authority pending

- criado `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP122.md`;
- ponteiro movido para CP122;
- preparation authority = APPROVED_AND_EXECUTED;
- runtime connectivity PubMed/ClinicalTrials.gov = VERIFIED;
- real TOPI Plan v2 + Epoch B1 draft materialization = COMPLETED;
- TOPI-PREP-T01–T30 = PASS;
- rebuild reproducibility = PASS;
- design_frozen_at = `2026-10-08T13:12:23-03:00`;
- Plan UUID = `b3100000-0000-0000-0000-000000000001`;
- Epoch B1 UUID = `b3120000-0000-0000-0000-000000000001`;
- PubMed opportunities = 8;
- ClinicalTrials.gov opportunities = 6;
- BVS/LILACS = deferred source debt;
- Documento 75 = AWAITING_EXPLICIT_OWNER_DECISION;
- Phase B execution authority = PENDING;
- Phase B execution = NOT_AUTHORIZED;
- MeasurementEvent count = 0;
- no normative temporal values;
- M3 blocked;
- Phase 5 not started;
- generic Prossiga is not execution authority;
- mandatory pause preserved.


### Fase 4 — Phase B execution authority validada; B1 autorizado e não ativo

Documentos:
- `docs/governance/75-pacote-authority-execucao-phase-b-topi-n2-dcbti.md` — owner decision recorded;
- `docs/governance/76-resultado-authority-execucao-phase-b-topi-n2-dcbti.md`.

Estado:
> **PHASE_B_EXECUTION_AUTHORITY = APPROVED_AND_VALIDATED**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Owner decision:
- decided_at `2026-10-08T13:31:42-03:00`;
- design_frozen_at `2026-10-08T13:12:23-03:00`;
- authority freshness = PASS.

Physical authority:
- authority UUID `b3150000-0000-0000-0000-000000000001`;
- Plan UUID `b3100000-0000-0000-0000-000000000001`;
- Epoch UUID `b3120000-0000-0000-0000-000000000001`;
- domain `operational_execution`;
- decision `approved`;
- actor type `owner`;
- decision Artifact UUID `b3000000-0000-0000-0000-000000000012`.

Activation hardening:
- migration `034_temporal_observation_activation_chronology.sql`;
- active transition requires persisted `started_at` before first Opportunity;
- authority must already be approved at `started_at`;
- material/invalidating deviation blocks activation;
- existing table constraint requires `started_at >= start_boundary_at`;
- B1 factual activation interval = `2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`;
- this is experimental operational chronology, not cadence/SLA.

Validation:
- TACT-T01–T08 = PASS;
- TOPI-AUTH-T01–T15 = PASS;
- migration 034 idempotency = PASS;
- rebuild-through-034 = PASS;
- TOPI authority rebuild = PASS;
- prior regressions = PASS.

Canonical CI:
- workflow run `37815729503`;
- run number `218`;
- validated HEAD `01c7a72d630fb5fb5c8f6eda8c87fdddc8268bb1`;
- conclusion `success`;
- evidence artifact ID `11567660235`;
- digest `sha256:736cb0f552d944bd1e8506a79e48f7dba1f69278bde01ea3d1b5fd554a007fa0`.

Current temporal boundary:
- start boundary `2026-10-19T08:00:00-03:00`;
- first PubMed Opportunity `2026-10-19T09:00:00-03:00`;
- activation on 2026-10-08 = NOT_ALLOWED.

Next act:
> **at/after start boundary and before first Opportunity, execute a live activation preflight; only if all preconditions pass may B1 transition to active.**

Still blocked:
- early activation;
- MeasurementEvent before real opportunity execution;
- schedule mutation/extension;
- Monitor/M2;
- UpdatePolicy/CadenceContract/SLA;
- normative temporal values;
- M3 formalization;
- Phase 5.


### CP123

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP123.md`;
- B1 permanece `authorized_non_normative`;
- `started_at` permanece NULL;
- zero MeasurementEvent;
- próxima ação operacional somente na janela de 19/10/2026 entre 08:00 e 09:00 -03, após preflight;
- modo alto recomendado para ativação e primeiro measurement;
- pausa obrigatória preservada.


### Fase 4 — activation preflight do B1 validado

Documento:
- `docs/governance/77-runbook-activation-preflight-b1-topi-n2-dcbti.md`.

Infraestrutura:
- migration `035_temporal_observation_activation_preflight.sql`;
- função read-only `maintenance.temporal_activation_preflight(epoch, as_of)`;
- função agregadora `maintenance.temporal_activation_preflight_state(epoch, as_of)`.

Resultado:
> **LIVE_PREFLIGHT_IMPLEMENTATION = VALIDATED**

> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **ACTIVATION_NOW = WAIT / NOT_IN_ACTIVATION_WINDOW**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

Validação determinística:
- APF-T01–T13 = PASS;
- as-of 2026-10-08 14:47 -03 = WAIT;
- as-of 2026-10-19 08:00 -03 = PASS;
- as-of 2026-10-19 08:30 -03 = PASS;
- as-of 2026-10-19 09:00 -03 = FAIL / EXPIRED_NOT_EXECUTED;
- preflight = read-only / zero mutation.

Canonical CI:
- run `37819755672` / run 219 = success;
- validated HEAD `830fcad1e79b237c5c672c5bf8e19aad66d2711f`;
- evidence artifact `11568343046`;
- digest `sha256:73f147fca89833f944b1bbb55fda324afa005bd0f17e9ea3b29fdc46810d906b`;
- rebuild-through-035 = PASS;
- prior regressions = PASS.

Activation discipline:
- factual activation interval remains `2026-10-19T08:00:00-03:00 <= started_at < 2026-10-19T09:00:00-03:00`;
- activation SQL must be created only after live preflight PASS;
- started_at must be the actual observed activation timestamp, never pre-authored;
- activation itself creates zero MeasurementEvent;
- first actual measurement remains PubMed Opportunity #1 at 2026-10-19 09:00 -03.

Mode:
- HIGH required for live activation + first real measurement;
- no normative temporal values;
- M3 blocked;
- Phase 5 not started.


### CP124 — activation preflight ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP124.md`;
- B1 = `authorized_non_normative`;
- live preflight implementation = VALIDATED;
- current preflight state = WAIT / NOT_IN_ACTIVATION_WINDOW;
- activation SQL = NOT_YET_CREATED;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- run 219 / `37819755672` = success;
- evidence artifact = `11568343046`;
- digest = `sha256:73f147fca89833f944b1bbb55fda324afa005bd0f17e9ea3b29fdc46810d906b`;
- next valid act = live preflight on 2026-10-19 between 08:00 and 09:00 -03;
- high mode required;
- mandatory pause preserved.


### Fase 4 — contrato do primeiro measurement real e harness sintético

Documento:
- `docs/governance/78-contrato-primeiro-measurement-real-harness-sintetico-b1.md`.

Decisão:
> **FIRST_REAL_MEASUREMENT_CONTRACT = SPECIFIED**

> **SYNTHETIC_POST_ACTIVATION_HARNESS = PLANNED_NOT_IMPLEMENTED**

> **NEW_SCHEMA_MIGRATION_REQUIRED = NO**

Semântica consolidada:
- activation permanece separada de measurement;
- primeira successful observation por source = `OBSERVED_EPOCH_BASELINE_ACQUISITION`;
- aggregate `novelty_state = not_applicable`;
- `new_identifier_count = NULL`;
- `new_to_epoch` é propriedade estrutural do epoch, não scientific novelty;
- missed Opportunity não cria MeasurementEvent;
- failure attribution permanece evidence-based;
- nenhuma execução temporal cria UpdateSignal automaticamente;
- nenhuma alteração automática de conclusion/currentness/assurance;
- B1 real não pode ser usado no harness sintético.

Plano técnico:
- suite proposta `FM-T01–T24`;
- arquivo proposto `database/f4-temporal-first-measurement-tests.sql`;
- harness exclusivamente sintético;
- CI sem network call real;
- prova final obrigatória de zero mutation no B1 real.

Estado corrente:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **PHASE_B_EXECUTION_STARTED = NO**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo passo:
> **em modo médio, implementar FM-T01–T24, integrar ao S5 e validar em CI, sem tocar no B1 real.**


### CP125 — first measurement contract specified

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP125.md`;
- Documento 78 = SPECIFIED;
- first real measurement contract = SPECIFIED;
- synthetic post-activation harness = PLANNED_NOT_IMPLEMENTED;
- FM-T01–T24 = planned;
- new schema migration = NOT_REQUIRED;
- B1 permanece `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- próxima ação = implementação sintética em modo médio;
- qualquer necessidade de migration/semântica nova retorna a modo alto;
- pausa obrigatória preservada.


### Fase 4 — hardening físico da semântica do primeiro measurement

Documento:
- `docs/governance/79-hardening-semantica-primeiro-measurement.md`.

Decisão:
> **FIRST_MEASUREMENT_SEMANTICS_HARDENING = REQUIRED**

> **MIGRATION_036_REQUIRED = YES**

> **FM_T06_AND_FM_T08 = BLOCKED_UNTIL_036**

Escopo de supersessão:
- Documento 78 permanece vigente como contrato metodológico;
- Documento 79 supersede apenas a conclusão técnica `NEW_SCHEMA_MIGRATION_REQUIRED = NO`;
- nova conclusão: `NEW_SCHEMA_MIGRATION_REQUIRED = YES — MIGRATION 036`.

Motivo:
- schema atual permite `novelty_state=not_applicable` com `new_identifier_count` não-NULL;
- não existe guard que diferencie primeira successful observation por source de successful observations subsequentes;
- completed event não é obrigado hoje a usar `failure_attribution=not_applicable`.

Hardening definido:
- baseline aggregate é source-specific;
- primeiro completed event por epoch_source exige `novelty_state=not_applicable`, `new_identifier_count=NULL`, `failure_attribution=not_applicable`;
- completed events subsequentes da mesma source não podem usar `not_applicable`;
- partial/failed/indeterminate não estabelecem successful baseline;
- implementation deve ser aditiva em migration 036;
- migrations 033–035 não serão reescritas.

Estado real preservado:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo passo:
> **após checkpoint, modo médio: implementar migration 036 + FM-T01–T24 + integração S5 + idempotência/rebuild/regressões.**


### CP126 — first measurement semantics hardening required

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP126.md`;
- Documento 79 = ARCHITECTURAL_DECISION / IMPLEMENTATION_PENDING;
- Documento 78 permanece vigente como contrato metodológico;
- conclusão `NEW_SCHEMA_MIGRATION_REQUIRED = NO` do Documento 78 foi supersedida;
- migration 036 = REQUIRED;
- baseline aggregate = source-specific;
- FM-T06/FM-T08 bloqueados até hardening;
- B1 permanece `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- próximo passo = modo médio para migration 036 + FM-T01–T24 + S5 + rebuild/regressões;
- pausa obrigatória preservada.


### Fase 4 — migration 036 e first-measurement harness validados

Documento:
- `docs/governance/80-resultado-migration-036-first-measurement-fm.md`.

Resultado:
> **MIGRATION_036 = TECHNICALLY_VALIDATED**

> **FM_T01_TO_T24 = PASS**

> **MIGRATION_036_IDEMPOTENCY = PASS**

> **REBUILD_THROUGH_036 = PASS**

> **REAL_B1_NON_MUTATION = PASS**

CI canônica:
- run `37829798269` / run 222 = success;
- validated HEAD `59225572679ebb0e446956a030f54e700614419a`;
- artifact `11572917207`;
- digest `sha256:a5d01a58f60e1a4424c24753d9a65290a18443408525ebfd2e53081d1e03f347`.

Semântica enforced:
- primeiro completed por epoch_source = baseline aggregate;
- `novelty_state=not_applicable`;
- `new_identifier_count=NULL`;
- `failure_attribution=not_applicable`;
- completed subsequente não pode usar `not_applicable`;
- partial/failed/indeterminate não estabelecem successful baseline.

Estado real preservado:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **PHASE_B_EXECUTION_STARTED = NO**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo ato operacional irreversível:
> **live activation preflight em 2026-10-19, 08:00–09:00 -03, modo alto.**


### CP127 — migration 036 / first-measurement harness validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP127.md`;
- migration 036 = TECHNICALLY_VALIDATED;
- FM-T01–T24 = PASS;
- F4-FM-IDEM = PASS;
- F4-FM-REBUILD = PASS;
- Documento 80 registra o resultado técnico;
- run 222 / `37829798269` = success;
- evidence artifact `11572917207`;
- digest `sha256:a5d01a58f60e1a4424c24753d9a65290a18443408525ebfd2e53081d1e03f347`;
- B1 permanece `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- nenhuma source query real foi executada;
- próximo ato irreversível = live activation preflight em 2026-10-19, 08:00–09:00 -03, modo alto;
- pausa obrigatória preservada.


### Fase 4 — pre-execution readiness do B1 auditado

Documento:
- `docs/governance/81-auditoria-readiness-pre-execucao-b1.md`.

Resultado:
> **B1_PRE_EXECUTION_PACKAGE = READY**

> **PRE_EXECUTION_READINESS = PASS**

> **WAIT_FOR_ACTIVATION_WINDOW = YES**

Auditoria confirmou:
- frozen Plan/design/source/query/interface/schedule artifacts presentes;
- activation path validado;
- first-measurement path validado;
- migration 036 + FM-T01–T24 = PASS;
- deferred BVS/LILACS debt continua visível;
- nenhum scheduler/cron de activation;
- B1 permanece sem mutation.

Gap operacional corrigido:
- S5 artifact retention = 30 → 60 dias;
- run 223 / `37830560002` = success;
- validated HEAD `da18477e1f754e9c27794c851d6be2909c63e039`;
- artifact `11573131877`;
- digest `sha256:8eb1763d0b21a06628766a89c26019a7e1e8eb2beaa549ae8616b63f4dc1247d`;
- expiry `2026-12-07T19:16:09Z`;
- retenção cobre review boundary de 2026-11-10.

Estado real:
> **OBSERVATION_EPOCH_B1 = AUTHORIZED_NON_NORMATIVE**

> **started_at = NULL**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **PHASE_B_EXECUTION_STARTED = NO**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Próximo ato:
> **aguardar janela de 2026-10-19 08:00–09:00 -03; live activation preflight em modo alto.**


### CP128 — B1 pre-execution readiness PASS

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP128.md`;
- Documento 81 = PRE_EXECUTION_READINESS_PASS;
- B1_PRE_EXECUTION_PACKAGE = READY;
- run 223 / `37830560002` = success;
- evidence artifact `11573131877`;
- digest `sha256:8eb1763d0b21a06628766a89c26019a7e1e8eb2beaa549ae8616b63f4dc1247d`;
- expiry `2026-12-07T19:16:09Z`;
- S5 retention = 60 days;
- retention covers B1 review boundary;
- B1 remains `authorized_non_normative`;
- started_at = NULL;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- next irreversível act = 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — defeito de parametrização ClinicalTrials.gov reconciliado arquiteturalmente

Documento:
- `docs/governance/82-reconciliacao-parametrizacao-clinicaltrials-b1.md`.

Resultado:
> **CLINICALTRIALS_EXACT_REQUEST_PARAMETERIZATION = NOT_ACTUALLY_FROZEN**

> **CP128_PRE_EXECUTION_READY_CLAIM = SUPERSEDED_BY_DOCUMENT_82**

> **CURRENT_B1_ACTIVATION_GOVERNANCE_STATUS = BLOCKED**

> **CORRECTIVE_ARCHITECTURE = REPLACEMENT_EPOCH_B1R1_UNDER_PLAN_V2**

Decisão arquitetural:
- não corrigir artifact congelado in place;
- não usar runbook suplementar como substituto de design freeze;
- não criar Plan v3 neste momento;
- invalidar B1 somente após corrective preparation authority explícita;
- preparar replacement Epoch `B1R1` sob Plan v2;
- preservar start/review boundaries e os mesmos 14 timestamps;
- ClinicalTrials.gov normalized parameters candidatos:
  - `query.cond=insomnia`;
  - `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
  - `format=json`;
  - `pageSize=10`;
  - paginação completa via page token;
- nenhuma query target-specific foi executada.

Authority:
> **CORRECTIVE_PREPARATION_AUTHORITY = REQUIRED**

Formulação requerida:
> **APPROVED — corrective preparation / Documento 82 / TOPI-N2-DCBTI-01 / replace B1 with B1R1**

Enquanto não houver essa decisão:
> **CURRENT_B1 = AUTHORIZED_NON_NORMATIVE_BUT_GOVERNANCE_BLOCKED**

> **CURRENT_B1_ACTIVATION = PROHIBITED**

> **B1R1 = NOT_YET_CREATED**

> **MEASUREMENT_EVENT_COUNT = 0**

> **OPPORTUNITY_RESOLUTION_COUNT = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**


### CP129 — ClinicalTrials request freeze defect / corrective authority required

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP129.md`;
- Documento 82 = CORRECTIVE_PREPARATION_AUTHORITY_REQUIRED;
- current B1 = authorized_non_normative but governance-blocked;
- current B1 activation = PROHIBITED;
- CP128 global readiness claim superseded for execution readiness;
- exact ClinicalTrials.gov request parameterization was not actually frozen before EpochSource materialization;
- selected corrective architecture = replacement Epoch `B1R1` under Plan v2;
- candidate normalized mapping = `query.cond=insomnia` + `query.term=(digital CBT OR digital CBT-I OR internet CBT-I)`;
- same boundaries and same 14 timestamps must be preserved;
- current B1 has not been invalidated;
- B1R1 has not been created;
- corrective preparation authority = REQUIRED;
- authority from Documento 75 does not transfer to B1R1;
- MeasurementEvent count = 0;
- OpportunityResolution count = 0;
- next action = await explicit owner corrective preparation decision;
- mandatory pause preserved.


### Fase 4 — corrective preparation B1R1 concluída

Authority:
- Documento 83 = APPROVED / corrective preparation executed.

Resultado:
> **ORIGINAL_B1 = INVALIDATED_WITHOUT_EXECUTION**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_DESIGN_FROZEN_AT = 2026-10-08T19:48:20-03:00**

> **B1R1_EXECUTION_AUTHORITY = PENDING**

> **B1R1_ACTIVATION = NOT_AUTHORIZED**

Corrective connectivity:
- run 224 / `37855302262` = success;
- PubMed E-utilities = VERIFIED;
- ClinicalTrials.gov API v2 = VERIFIED;
- apiVersion = 2.0.5;
- no target-specific query;
- artifact `11583468584`;
- digest `sha256:c0d933ca42961e1f0605751544e603dac33039b1c3d1476dbe187c65925f2e52`.

Corrective materialization:
- Documento 84;
- B1R1 Epoch UUID `b3120000-0000-0000-0000-000000000002`;
- PubMed EpochSource `b3130000-0000-0000-0000-000000000003`;
- ClinicalTrials.gov EpochSource `b3130000-0000-0000-0000-000000000004`;
- same boundaries and same 14 timestamps;
- B1R1-T01–T24 = PASS;
- run 229 / `37855834411` = success;
- validated HEAD `cea4c1a67b7de4537bdf95485146199c86989a48`;
- artifact `11583902320`;
- digest `sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`;
- rebuild = PASS.

Request freeze:
- PubMed interface v2 frozen;
- ClinicalTrials query v2 frozen;
- ClinicalTrials interface v2 frozen;
- logical scientific scope unchanged;
- no schedule sliding.

Novo authority gate:
- Documento 85 = PENDING OWNER DECISION;
- formulação requerida:
  `APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1`.

Estado corrente:
> **B1 = INVALIDATED**

> **B1R1 = DRAFT_FROZEN**

> **B1R1_EXECUTION_AUTHORITY = PENDING**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**


### CP130 — corrective preparation B1R1 PASS

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP130.md`;
- Documento 83 = corrective preparation authority APPROVED/EXECUTED;
- Documento 84 = corrective preparation PASS;
- Documento 85 = execution authority package PENDING OWNER DECISION;
- original B1 = invalidated without execution;
- B1R1 = draft_frozen;
- B1R1 UUID = `b3120000-0000-0000-0000-000000000002`;
- design_frozen_at = `2026-10-08T19:48:20-03:00`;
- run 224 = corrective connectivity PASS;
- run 229 = B1R1-T01–T24 + rebuild PASS;
- run 229 artifact = `11583902320`;
- digest = `sha256:77066bb64d4fa3110686027f552f69366702a4c72d53e45e188c7df6d7ff89e2`;
- B1R1 execution authority = PENDING;
- B1R1 activation = NOT_AUTHORIZED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next action = await explicit owner decision on Documento 85;
- mandatory pause preserved.


### Fase 4 — execution authority do B1R1 aprovada e validada

Documentos:
- `docs/governance/85-pacote-authority-execucao-b1r1.md`;
- `docs/governance/86-decisao-authority-execucao-b1r1.md`;
- `docs/governance/87-resultado-authority-execucao-b1r1.md`.

Decisão:
> **B1R1_EXECUTION_AUTHORITY = APPROVED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **B1R1_ACTIVATION = NOT_STARTED**

Owner decision:
- exact approval: `APPROVED — B1R1 execution / Documento 85 / TOPI-N2-DCBTI-01 / Epoch B1R1`;
- decided_at = `2026-10-08T20:26:21-03:00`;
- design_frozen_at = `2026-10-08T19:48:20-03:00`;
- authority ordering = PASS.

Physical authority:
- authority UUID `b3150000-0000-0000-0000-000000000002`;
- decision Artifact UUID `b3000000-0000-0000-0000-000000000017`;
- domain = `operational_execution`;
- decision = `approved`.

Validation:
- B1R1-AUTH-T01–T20 = PASS;
- deterministic preflight:
  - current state = WAIT;
  - 2026-10-19 08:00 -03 = PASS;
  - 2026-10-19 08:30 -03 = PASS;
  - 2026-10-19 09:00 -03 = FAIL;
- run 232 / `37859791833` = success;
- validated HEAD `bfcd493a74e095d1c28974c7a033c5dbf0a08b39`;
- artifact `11585626965`;
- digest `sha256:ea7b831fa6b0d8c2547bb5763e8c0cf0072c6dcabac4e279dd4d7bf10266a0a6`;
- rebuild = PASS.

Current state:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1 started_at = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

> **M3_FORMAL_OPERATIONALIZATION = BLOCKED**

> **PHASE_5 = NOT_STARTED**

Next irreversible act:
> **live activation preflight for B1R1 on 2026-10-19 in the 08:00–09:00 -03 interval, high mode.**


### CP131 — B1R1 execution authority approved / activation pending

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP131.md`;
- Documento 85 = authority package;
- Documento 86 = owner APPROVED decision record;
- Documento 87 = APPROVED_AND_VALIDATED / ACTIVATION_PENDING;
- B1 = invalidated;
- B1R1 = authorized_non_normative;
- B1R1 authority UUID = `b3150000-0000-0000-0000-000000000002`;
- B1R1 started_at = NULL;
- B1R1-AUTH-T01–T20 = PASS;
- run 232 / `37859791833` = success;
- evidence artifact `11585626965`;
- digest `sha256:ea7b831fa6b0d8c2547bb5763e8c0cf0072c6dcabac4e279dd4d7bf10266a0a6`;
- rebuild ends with B1 invalidated and B1R1 authorized_non_normative / zero execution;
- activation remains pending the 2026-10-19 08:00–09:00 -03 window;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- M3 remains blocked;
- Phase 5 not started;
- mandatory pause preserved.


### Fase 4 — runbook operacional das medições reais do B1R1 concluído

Documento:
- `docs/governance/88-runbook-operacional-medicoes-reais-b1r1.md`.

Resultado:
> **B1R1_REAL_MEASUREMENT_RUNBOOK = READY**

Escopo coberto:
- preflight imediato por Opportunity;
- request PubMed congelada;
- request ClinicalTrials.gov congelada;
- completude/paginação;
- baseline semantics source-specific;
- raw/materialized/new counts;
- MeasurementItem/item_state;
- timepoints;
- execution Artifacts;
- failure attribution;
- execution status;
- retries;
- OpportunityResolution;
- deviations;
- effort payload;
- transação/pós-validação;
- anti-backfill;
- clock discipline;
- scientific triage boundary;
- primeira Opportunity PubMed e ClinicalTrials.gov.

Nenhuma mudança metodológica/schema:
> **NEW_ARCHITECTURAL_DECISION = NO**

> **NEW_MIGRATION_REQUIRED = NO**

Estado operacional preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**

Próximo ato irreversível:
> **19/10/2026, 08:00–09:00 -03: live activation preflight do B1R1 em modo alto.**


### CP132 — B1R1 real measurement runbook ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP132.md`;
- Documento 88 = READY_FOR_REAL_OPPORTUNITY_EXECUTION / ACTIVATION_STILL_PENDING;
- B1R1 real measurement runbook = READY;
- no new architectural decision;
- no new migration;
- PubMed and ClinicalTrials.gov real execution paths operationally specified;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- no target-specific source query executed;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — protocolo de review/encerramento do B1R1 pré-especificado

Documento:
- `docs/governance/89-protocolo-review-encerramento-b1r1.md`.

Resultado:
> **B1R1_REVIEW_PROTOCOL = PRE_SPECIFIED**

> **B1R1_REVIEW = NOT_STARTED**

> **B1R1_EPOCH_COMPLETION = NOT_ALLOWED_BEFORE_REVIEW_BOUNDARY**

Escopo:
- Opportunity accounting;
- missingness descritiva;
- attempts/retries;
- failure attribution;
- source-specific completeness;
- identifier history;
- aggregate novelty history;
- source timepoints;
- descriptive latency;
- effort;
- deviations;
- deferred source debt;
- cohort/window/denominator;
- evidence cutoff;
- reassessment triggers;
- physical closure preparation;
- review artifact minimum content;
- Evidence Readiness boundary;
- anti-minimum-N;
- anti-favorable-stopping;
- anti-automatic-extension.

Nenhuma decisão normativa:
> **READINESS_ASSESSMENT = NOT_STARTED**

> **CALIBRATION_DOSSIER = NOT_OPEN**

> **NORMATIVE_TEMPORAL_VALUES = NOT_AUTHORIZED**

Estado operacional preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP133 — B1R1 review/closure protocol pre-specified

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP133.md`;
- Documento 89 = PRE-SPECIFIED / REVIEW_NOT_STARTED;
- B1R1 review protocol = PRE_SPECIFIED;
- B1R1 review = NOT_STARTED;
- physical completion before review boundary remains prohibited;
- no hidden minimum-N;
- no favorable stopping;
- no automatic extension;
- no automatic READY_FOR_CALIBRATION;
- no Calibration Dossier opened;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — decision tables de contingência do B1R1 pré-especificadas

Documento:
- `docs/governance/90-decision-tables-contingencias-b1r1.md`.

Resultado:
> **B1R1_CONTINGENCY_TABLES = PRE_SPECIFIED**

Cobertura:
- activation WAIT/PASS/FAIL;
- activation expiry;
- target/authority/artifact/connectivity blockers;
- PubMed HTTP/JSON/count/idlist contingencies;
- ClinicalTrials.gov pagination/schema/token contingencies;
- duplicate/reobserved/updated identifiers;
- timepoint missing/date-only;
- retries;
- missed/failed/indeterminate closure;
- partial-without-closure escalation;
- execution delay;
- query/interface/source-scope drift;
- data-governance incidents;
- failure evidence constraints;
- incidental scientific findings;
- mixed source outcomes;
- review-boundary blockers;
- mode escalation rule.

Nenhuma expansão física:
> **NEW_SCHEMA = NO**

> **NEW_MIGRATION = NO**

> **NEW_AUTHORITY = NO**

> **B1R1_STATE_MUTATION = NO**

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP134 — B1R1 contingency decision tables ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP134.md`;
- Documento 90 = PRE-SPECIFIED / CONTINGENCY_READY;
- B1R1 contingency tables = PRE_SPECIFIED;
- no new schema/migration/authority;
- partial-without-completion remains unresolved unless a physically valid closure path exists;
- any need for new closure state returns to high mode;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — runbook de live activation do B1R1 concluído

Documento:
- `docs/governance/91-runbook-live-activation-b1r1.md`.

Resultado:
> **B1R1_ACTIVATION_RUNBOOK = READY**

> **DOCUMENT_91_SUPERSEDES_DOCUMENT_77_OPERATIONALLY_FOR_ACTIVATION**

Documento 77:
> **HISTORICAL_B1_ACTIVATION_RUNBOOK**

Cobertura:
- Freshness Gate;
- hora factual America/Recife;
- live preflight B1R1;
- checks individuais obrigatórios;
- controlling artifacts;
- connectivity/material drift;
- opportunity equality;
- material deviations;
- zero prestart events/resolutions;
- activation artifact factual;
- SQL factual somente pós-PASS;
- post-activation validation;
- checkpoint pós-activation;
- expiry behavior às 09:00;
- handoff para primeira PubMed Opportunity.

Estado atual:
> **LIVE_PREFLIGHT = NOT_YET_RUN**

> **ACTIVATION = NOT_STARTED**

> **ACTIVATION_SQL = NOT_YET_CREATED**

> **ACTIVATION_ARTIFACT = NOT_YET_CREATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP135 — B1R1 live activation runbook ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP135.md`;
- Documento 91 = READY_FOR_LIVE_PREFLIGHT / ACTIVATION_NOT_YET_ALLOWED;
- Documento 91 supersede Documento 77 apenas operacionalmente para activation futura;
- Documento 77 permanece histórico;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- live preflight = NOT_YET_RUN;
- activation = NOT_STARTED;
- activation SQL/Artifact factual = NOT_YET_CREATED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — pacote operacional do dia 19 validado

Documento:
- `docs/governance/92-pacote-operacional-dia-19-b1r1.md`.

Read-only live preflight capture:
- `database/f4-topi-n2-dcbti-b1r1-live-preflight-readonly.sql`;
- transaction mode = READ ONLY;
- termina em ROLLBACK;
- sem mutation de Epoch/Event/Resolution.

Resultado:
> **DAY_19_OPERATOR_PACKET = READY**

> **LIVE_PREFLIGHT_CAPTURE_SQL = READY_READ_ONLY**

> **LIVE_PREFLIGHT_CAPTURE_MUTATION = ZERO_BY_CONSTRUCTION_AND_CI_PROOF**

CI:
- run 233 / `37861733122` = success;
- validated HEAD `8e2659ee425c0decde9915b5e43f9efd592692ef`;
- artifact `11586227719`;
- digest `sha256:7e10af6697bd692cf8e078e2916de03f5b4f0a2b25f71e7eebab4c78529b6957`;
- expiry `2026-12-07T23:52:17Z`;
- TOPI-B1R1-LIVE-PREFLIGHT-READONLY = PASS;
- rebuild = PASS.

Estado real preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP136 — day-19 operator packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP136.md`;
- Documento 92 = READY_FOR_DAY_OF_EXECUTION / NO_FACTUAL_ACTIVATION_PRECREATED;
- read-only live preflight capture = READY;
- TOPI-B1R1-LIVE-PREFLIGHT-READONLY = PASS;
- run 233 / `37861733122` = success;
- artifact `11586227719`;
- digest `sha256:7e10af6697bd692cf8e078e2916de03f5b4f0a2b25f71e7eebab4c78529b6957`;
- zero-mutation proof = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — templates de activation e pós-validação do B1R1 prontos

Documento:
- `docs/governance/93-template-activation-checkpoint-b1r1.md`.

Read-only post-activation capture:
- `database/f4-topi-n2-dcbti-b1r1-post-activation-readonly.sql`.

Resultado:
> **ACTIVATION_ARTIFACT_TEMPLATE = READY**

> **POST_ACTIVATION_CHECKPOINT_TEMPLATE = READY**

> **POST_ACTIVATION_READONLY_CAPTURE = READY**

> **FACTUAL_ACTIVATION_DATA = NONE**

CI:
- run 234 / `37862383146` = success;
- validated HEAD `f1c84729c2061a17a317e5c4b62a24456165aa97`;
- artifact `11587035724`;
- digest `sha256:34a8cb17bd339e9cba9986ea11a9e16af672434815c65f672a6255e4500f276d`;
- expiry `2026-12-07T23:59:52Z`;
- TOPI-B1R1-LIVE-PREFLIGHT-READONLY = PASS;
- TOPI-B1R1-POST-ACTIVATION-READONLY = PASS;
- rebuild = PASS.

Estado real preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **ACTIVATION_SQL_FACTUAL = NOT_CREATED**

> **ACTIVATION_ARTIFACT_FACTUAL = NOT_CREATED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP137 — B1R1 activation templates ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-08_CP137.md`;
- Documento 93 = TEMPLATE_ONLY / NO_FACTUAL_ACTIVATION_DATA;
- activation Artifact template = READY;
- post-activation checkpoint template = READY;
- post-activation read-only capture = READY;
- run 234 / `37862383146` = success;
- artifact `11587035724`;
- digest `sha256:34a8cb17bd339e9cba9986ea11a9e16af672434815c65f672a6255e4500f276d`;
- both read-only captures = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- factual activation SQL/Artifact = NOT_CREATED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible act remains 2026-10-19 live activation preflight in high mode;
- mandatory pause preserved.


### Fase 4 — pacote da primeira measurement PubMed do B1R1 pronto

Documento:
- `docs/governance/94-pacote-primeira-measurement-pubmed-b1r1.md`.

Read-only precheck:
- `database/f4-topi-n2-dcbti-b1r1-first-pubmed-precheck-readonly.sql`.

Resultado:
> **FIRST_PUBMED_OPERATOR_PACKET = READY**

> **FIRST_PUBMED_PRECHECK_READONLY = READY**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **FIRST_MEASUREMENT_EVENT = NOT_CREATED**

CI:
- run 236 / `37864644053` = success;
- validated HEAD `acac8e1a3dd9dc0eac67c9ba4abf8f0d283e78f0`;
- artifact `11586984803`;
- digest `sha256:e66154c429e25defcb1da91ee96e3bdbc2b38fba16cc74c85e858f724f3292a8`;
- expiry `2026-12-08T00:25:42Z`;
- TOPI-B1R1-FIRST-PUBMED-PRECHECK = PASS;
- pre-activation result = NOT_READY;
- baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP138 — first PubMed measurement packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP138.md`;
- Documento 94 = READY_FOR_FIRST_REAL_PUBMED_OPPORTUNITY / NO_SOURCE_QUERY_EXECUTED;
- first PubMed precheck read-only = READY;
- run 236 / `37864644053` = success;
- artifact `11586984803`;
- digest `sha256:e66154c429e25defcb1da91ee96e3bdbc2b38fba16cc74c85e858f724f3292a8`;
- pre-activation state = NOT_READY;
- baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real source query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 activation then first PubMed measurement in high mode;
- mandatory pause preserved.


### Fase 4 — pacote da primeira measurement ClinicalTrials.gov do B1R1 pronto

Documento:
- `docs/governance/95-pacote-primeira-measurement-clinicaltrials-b1r1.md`.

Read-only precheck:
- `database/f4-topi-n2-dcbti-b1r1-first-clinicaltrials-precheck-readonly.sql`.

Resultado:
> **FIRST_CLINICALTRIALS_OPERATOR_PACKET = READY**

> **FIRST_CLINICALTRIALS_PRECHECK_READONLY = READY**

> **CLINICALTRIALS_TARGET_QUERY = NOT_EXECUTED**

> **FIRST_CLINICALTRIALS_MEASUREMENT_EVENT = NOT_CREATED**

CI:
- run 237 / `37865221303` = success;
- validated HEAD `42a69dd48b3fcd3d8ffa252017ab120793cb6ede`;
- artifact `11588041164`;
- digest `sha256:b001ccb1edcc18a91d7327c9c3298b6355d3a4560e9b50924c2ab07b57a9ef54`;
- expiry `2026-12-08T00:32:24Z`;
- TOPI-B1R1-FIRST-CLINICALTRIALS-PRECHECK = PASS;
- pre-activation result = NOT_READY;
- source-specific baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP139 — first ClinicalTrials.gov measurement packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP139.md`;
- Documento 95 = READY_FOR_FIRST_REAL_CLINICALTRIALS_OPPORTUNITY / NO_SOURCE_QUERY_EXECUTED;
- first ClinicalTrials.gov precheck read-only = READY;
- run 237 / `37865221303` = success;
- artifact `11588041164`;
- digest `sha256:b001ccb1edcc18a91d7327c9c3298b6355d3a4560e9b50924c2ab07b57a9ef54`;
- pre-activation state = NOT_READY;
- source-specific baseline-if-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real PubMed query = NOT_EXECUTED;
- first real ClinicalTrials.gov query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 activation then first real source measurements in high mode;
- mandatory pause preserved.


### Fase 4 — template de persistência e post-readout das primeiras measurements pronto

Documento:
- `docs/governance/96-template-persistencia-postreadout-primeiras-measurements-b1r1.md`.

Read-only post-readout:
- `database/f4-topi-n2-dcbti-b1r1-first-measurements-postreadout-readonly.sql`.

Resultado:
> **FIRST_MEASUREMENTS_PERSISTENCE_TEMPLATE = READY**

> **FIRST_MEASUREMENTS_POSTREADOUT_READONLY = READY**

> **FACTUAL_MEASUREMENT_DATA = NONE**

> **MEASUREMENT_EVENT_SQL_FACTUAL = NOT_CREATED**

CI:
- run 240 / `37865666856` = success;
- validated HEAD `1b2de6cbdc460aa8fa858a2c23503cadaa327367`;
- artifact `11587648764`;
- digest `sha256:e6a6d891c257172a3aafb47e1caf3a31ec77e0636a68f344f6f06b1dd252047d`;
- expiry `2026-12-08T00:37:43Z`;
- TOPI-B1R1-FIRST-MEASUREMENTS-POSTREADOUT = PASS;
- planned/zero-attempt baseline visible;
- zero mutation = PASS;
- rebuild = PASS.

Intermediário não canônico:
- run 239 falhou apenas por nome incorreto de coluna no read-only deviation query;
- nenhuma mutation ocorreu;
- corrigido em commit `1b2de6cbdc460aa8fa858a2c23503cadaa327367`;
- run 240 supersede tecnicamente o run 239.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP140 — first measurements persistence/post-readout ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP140.md`;
- Documento 96 = TEMPLATE_ONLY / NO_FACTUAL_MEASUREMENT_DATA;
- first measurements persistence template = READY;
- first measurements post-readout read-only = READY;
- run 240 / `37865666856` = success;
- artifact `11587648764`;
- digest `sha256:e6a6d891c257172a3aafb47e1caf3a31ec77e0636a68f344f6f06b1dd252047d`;
- zero mutation = PASS;
- rebuild = PASS;
- run 239 remains non-canonical intermediate read-only failure;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real source query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 in high mode;
- mandatory pause preserved.


### Fase 4 — pacote das Opportunities subsequentes do B1R1 pronto

Documento:
- `docs/governance/97-pacote-opportunities-subsequentes-b1r1.md`.

Read-only readiness matrix:
- `database/f4-topi-n2-dcbti-b1r1-subsequent-opportunities-readiness-readonly.sql`.

Resultado:
> **SUBSEQUENT_OPPORTUNITY_OPERATOR_PACKET = READY**

> **SUBSEQUENT_OPPORTUNITY_READINESS_MATRIX = READY_READ_ONLY**

> **SUBSEQUENT_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **FACTUAL_SUBSEQUENT_MEASUREMENT_SQL = NOT_CREATED**

CI:
- run 241 / `37866002057` = success;
- validated HEAD `bf0ae05b06d2ae4f0e8eea4297147b39c2d496dc`;
- artifact `11588596135`;
- digest `sha256:bc27df73f525774bd43c5484b841d3d72f245c23836820904e4d80ebf7236cff`;
- expiry `2026-12-08T00:41:47Z`;
- TOPI-B1R1-SUBSEQUENT-READINESS = PASS;
- 12 subsequent opportunities visible;
- all NOT_READY in current pre-activation state;
- baseline-if-no-prior-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP141 — subsequent opportunities packet ready

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP141.md`;
- Documento 97 = READY_FOR_SUBSEQUENT_OPPORTUNITIES / NO_SOURCE_QUERY_EXECUTED;
- subsequent opportunity readiness matrix = READY_READ_ONLY;
- run 241 / `37866002057` = success;
- artifact `11588596135`;
- digest `sha256:bc27df73f525774bd43c5484b841d3d72f245c23836820904e4d80ebf7236cff`;
- 12 subsequent Opportunities visible;
- all NOT_READY in current pre-activation state;
- baseline-if-no-prior-completed semantics visible;
- zero mutation = PASS;
- rebuild = PASS;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first/subsequent real source queries = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 in high mode;
- mandatory pause preserved.


### Fase 4 — audit de prontidão pré-19/10 validado

Documento:
- `docs/governance/98-audit-prontidao-pre-dia19-b1r1.md`.

Read-only audit:
- `database/f4-topi-n2-dcbti-b1r1-pre-day19-readiness-readonly.sql`.

Resultado:
> **PRE_DAY19_READINESS_AUDIT = READY_READ_ONLY**

> **PRE_DAY19_PREPARATION_STATUS = PREPARATION_READY**

> **ACTIVATION_WINDOW_CURRENT_STATE = WAIT**

> **ACTIVATION_ALLOWED_NOW = NO**

CI:
- run 244 / `37926218841` = success;
- validated HEAD `a60ed2f5ab63efaf3354b8511ef3922a888cb25c`;
- artifact `11613929240`;
- digest `sha256:822f753a91f4aefc00f92d5f2c3c1623ed0a0d89694e3144ab5e08d78eaf80d0`;
- expiry `2026-12-08T11:51:21Z`;
- TOPI-B1R1-PRE-DAY19-READINESS = PASS;
- preparation ready = PASS;
- activation window WAIT = PASS;
- zero mutation = PASS;
- rebuild = PASS.

Intermediário não canônico:
- run 243 falhou apenas por uso do nome `check_state` em vez de `check_status` na leitura do preflight;
- nenhuma mutation ocorreu;
- corrigido em `a60ed2f5ab63efaf3354b8511ef3922a888cb25c`;
- run 244 supersede tecnicamente o run 243.

Estado preservado:
> **B1 = INVALIDATED**

> **B1R1 = AUTHORIZED_NON_NORMATIVE**

> **B1R1_STARTED_AT = NULL**

> **ACTIVATION = NOT_STARTED**

> **FIRST_REAL_SOURCE_QUERY = NOT_EXECUTED**

> **MEASUREMENT_EVENT_COUNT_B1_PLUS_B1R1 = 0**

> **OPPORTUNITY_RESOLUTION_COUNT_B1_PLUS_B1R1 = 0**


### CP142 — pre-day19 readiness validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP142.md`;
- Documento 98 = PRE-DAY19 READINESS AUDIT / PREPARATORY ONLY;
- pre-day19 readiness audit = READY_READ_ONLY;
- preparation status = PREPARATION_READY;
- activation window current state = WAIT;
- activation allowed now = NO;
- run 244 / `37926218841` = success;
- artifact `11613929240`;
- digest `sha256:822f753a91f4aefc00f92d5f2c3c1623ed0a0d89694e3144ab5e08d78eaf80d0`;
- zero mutation = PASS;
- rebuild = PASS;
- run 243 remains non-canonical intermediate read-only failure;
- B1 remains invalidated;
- B1R1 remains authorized_non_normative;
- started_at = NULL;
- activation = NOT_STARTED;
- first real source query = NOT_EXECUTED;
- MeasurementEvent count across B1+B1R1 = 0;
- OpportunityResolution count across B1+B1R1 = 0;
- next irreversible sequence remains 2026-10-19 in high mode;
- mandatory pause preserved.


### Fase 4 — desenho do harness integrado sintético pré-19/10 (Documento 99)

- documento: `docs/governance/99-desenho-harness-integrado-sintetico-pre-dia19-b1r1.md`;
- design sintético dual-source (preflight → activation sintética → attempts/retry → items/timepoints/artifacts → resolutions → replay/review) definido em modo alto;
- harness de integração ainda NÃO implementado nem executado;
- nenhuma nova migration, authority factual ou query real;
- tests propostos ISE-T01–T24 não são PASS;
- estado pre-day19 do CP142 preservado.

> **F4_ISE_DESIGN = DEFINED_NON_NORMATIVE**
> **F4_ISE_IMPLEMENTATION = NOT_STARTED**
> **F4_ISE_CI_PROOF = NOT_AVAILABLE**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP143 — integrated synthetic harness design

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP143.md`;
- Documento 99 = DESIGN_DEFINED / SYNTHETIC_ONLY / NOT_IMPLEMENTED;
- próximo bloco: SQL sintético com ROLLBACK + CI, modo médio após Prossiga e Freshness Gate;
- run 244 permanece evidência pré-existente, não prova do futuro harness;
- B1R1 permanece authorized_non_normative, started_at NULL, zero events/resolutions, activation em WAIT;
- pausa obrigatória preservada.


### Fase 4 — harness integrado sintético dual-source validado (Documento 100)

- arquivo: `database/f4-temporal-integrated-synthetic-harness-tests.sql`;
- CI: `.github/workflows/validate-s5.yml`, step `F4-ISE`;
- cobertura ISE-T01–T24 = 24/24 PASS;
- run 245 / `37933007291` = success, commit validado `af5595d14647df51d076d64081bec1d6a5328c22`;
- job `postgres-s5` = 113828097739, success;
- artifact 11616374106; digest `sha256:ccccba178c51d71f21c56c878c02c333e677e4ae76e14ce087faececd2fe7bb4`;
- ROLLBACK e ausência de resíduos sintéticos = PASS;
- fingerprints B1/B1R1 e contagens operacionais/normativas pré/pós = iguais;
- PRE_DAY19_PREPARATION_STATUS continua PREPARATION_READY, activation window WAIT;
- nenhuma source query factual, nenhum event/resolution B1/B1R1 criado;
- Documento 99 permanece histórico: o estado NOT_IMPLEMENTED nele descreve a época do desenho, não o presente.

> **F4_ISE_IMPLEMENTATION = DONE**
> **F4_ISE_TECHNICAL_VALIDATION = PASS**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP144 — integrated synthetic harness validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP144.md`;
- Documento 100 registra PASS técnico real do harness sintético;
- próximo bloco opcional: decisão em modo alto para contratos offline PubMed/ClinicalTrials.gov;
- próximo ato factual irreversível do B1R1: 19/10/2026 08h–09h America/Recife, sujeito a Freshness Gate/live PASS;
- pausa obrigatória preservada.


### Fase 4 — escopo dos contratos offline de resposta definido (Documento 101)

- documento: `docs/governance/101-decisao-escopo-contratos-offline-respostas-pubmed-clinicaltrials-b1r1.md`;
- decisão em modo alto: desenvolvimento sintético offline de validadores de identidade de request, JSON, cardinalidade, unicidade, paginação, campos mínimos e fail-closed para PubMed ESearch / ClinicalTrials.gov API v2;
- output será relatório técnico `oes.temporal_offline_source_parse_report/0.1`, sem escrita factual ou `MeasurementEvent`;
- matriz OFF-P01–P12, OFF-C01–C16, OFF-X01–X06 = 34 casos propostos, **não executados**;
- interfaces e queries congeladas inalteradas;
- run 245 continua prova do harness ISE anterior, não deste escopo;
- nenhuma source request target-specific, nenhuma activation, nenhum evento B1R1.

> **F4_OFFLINE_SOURCE_SCOPE = APPROVED_FOR_SYNTHETIC_DEVELOPMENT**
> **F4_OFFLINE_SOURCE_IMPLEMENTATION = NOT_STARTED**
> **F4_OFFLINE_SOURCE_CI_PROOF = NOT_AVAILABLE**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP145 — offline source contracts scope decision

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP145.md`;
- próximo bloco em modo médio: implementação dos validadores offline/34 testes e CI, sujeito a Freshness Gate;
- B1R1 mantém PREPARATION_READY, ACTIVATION_WINDOW WAIT e janela factual 19/10;
- pausa obrigatória preservada.


### Fase 4 — contratos offline de fontes validados (Documento 102)

- biblioteca `scripts/temporal_source_offline_contracts.py` e testes `scripts/validate_temporal_source_offline_contracts.py` implementados;
- cenário estritamente offline/sintético: PubMed ESearch + ClinicalTrials.gov API v2;
- 12 testes PubMed, 16 ClinicalTrials.gov e 6 transversais = 34/34 PASS;
- run 248 / `37935448109`, commit validado `6db14ba5107062bec6afa69607c4ff23b23acf7a`, success;
- job `113836220414`, success;
- artifact 11617672877 / digest `sha256:77e26b176458ec70f82333c1ea5149269b2a4ec641c7eb580741876dff7c494d`;
- S5 F4-ISE e rebuild PASS; B1R1 readiness PASS (activation WAIT, zero mutation);
- run 246 falhou na configuração YAML antes dos jobs, reparada; run 247 é intermediária e não canônica;
- frozen artifacts e queries B1R1 inalterados; sem HTTP target-specific, DB writes ou eventos factuais;
- Documento 101 permanece snapshot histórico da decisão original.

> **F4_OFFLINE_SOURCE_IMPLEMENTATION = DONE**
> **F4_OFFLINE_SOURCE_CI_PROOF = PASS**
> **F4_OFFLINE_SOURCE_CASES = 34_OF_34_PASS**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP146 — offline source contracts validated

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP146.md`;
- Documento 102 = TECHNICALLY_VALIDATED / SYNTHETIC_OFFLINE_ONLY;
- próximo bloco opcional: gate adversarial read-only de fronteira parser/decisão factual em modo alto, somente após Prossiga;
- próximo ato factual B1R1 ainda reservado para 19/10/2026 sob Freshness Gate e live PASS;
- pausa obrigatória preservada.


### Fase 4 — hardening dos contratos offline validado (Documento 103)

- corrigida identidade física dos cinco artefatos congelados via SHA de bytes em disco, não somente pelo SHA declarado;
- corrigida a proveniência das fixtures em memória, sem referência a JSON ausente;
- adicionados OFF-A01–A10; total offline 44/44 PASS;
- run 252 / `37939324857`, job `113849349502`, commit `dbcc79f69bb3ed07306cee5fc05b25eed9bfb2e1`, success;
- artifact `11621145703` / sha256:0aff81c4bf96f477630e40a14f24f040a7820650c5d82d8d1f446b3db50ffb29;
- F4-ISE 24/24 e regressões/rebuild PASS, PRE_DAY19_READY WAIT e zero mutation;
- Documento 103: `docs/governance/103-resultado-hardening-identidade-proveniencia-contratos-offline-b1r1.md`;
- nenhuma mutation B1R1, nenhuma fonte científica consultada; sem ponte automática parser→MeasurementEvent factual.

> **F4_OFFLINE_SOURCE_HARDENING = VALIDATED_SYNTHETIC_ONLY**
> **F4_OFFLINE_SOURCE_CASES = 44_OF_44_PASS**
> **F4_FROZEN_CONTRACT_ATTESTATION = PASS**
> **B1R1_ACTIVATION = NOT_STARTED**
> **PHASE_5 = NOT_STARTED**

### CP147 — offline identity and provenance hardening

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-09_CP147.md`;
- próximo ato factual irreversível segue em 19/10/2026, com live preflight e modo alto;
- pausa obrigatória preservada.

### Fase 4 — impedimento de infraestrutura na janela do B1R1 (Documento 104)

- em 19/10/2026, às 08:00:32 e 08:07:32 America/Recife, relógio factual confirmou janela aberta nos instantes observados;
- Freshness Gate confirmou CP147, HEAD `d53640c76d69755f3c48ae0a39109c545f9b4bef`, run 252 e os cinco blobs congelados;
- o usuário declarou inexistência de instância PostgreSQL operacional persistente;
- o único PostgreSQL identificado no processo técnico é o serviço efêmero dos workflows GitHub Actions;
- live preflight SQL em instância operacional: **NÃO EXECUTADO**; nenhum agregado ou controle individual físico foi observado;
- nenhuma ativação/consulta científica/mutation efetuada; não atribuir estado factual da CI ao ambiente operacional;
- instrução conservadora: não retroagir `started_at`, não mudar os 14 timestamps, não inventar dados experimentais;
- Documento 104 define contenção e requisitos para infraestrutura persistente e futura decisão sobre novo experimento.

> **F4_OPERATIONAL_INFRASTRUCTURE = BLOCKED_NO_PERSISTENT_POSTGRES**  
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **ACTIVATION_WINDOW = OPEN_AT_2026-10-19T08:07:32-03:00_ONLY**  
> **ACTUAL_OPERATIONAL_EVENT_COUNT = NOT_VERIFIABLE_WITHOUT_DATABASE**  
> **PHASE_5 = NOT_STARTED**

### CP148 — bloqueio de infraestrutura registrado

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP148.md`;
- próxima atividade, só após `Prossiga`: gate arquitetural do PostgreSQL persistente, em modo alto, sem deployment automático;
- expiração B1R1 **não** antecipada: exigir verificação factual posterior a 09:00 para declaração final;
- pausa obrigatória.

### Fase 4 — gate arquitetural do banco operacional persistente (Documento 105)

- Freshness Gate confirmou CP148, HEAD `d92a426fcdecfc3392244f8625631d26486a9c09`, sem alterações posteriores e impedimento de datastore persistente não resolvido;
- arquitetura de referência **condicional** para piloto não normativo: PostgreSQL gerenciado persistente + object storage para Artifacts + executor autenticado;
- manter OES-H1/OES-P1, PostgreSQL para core transacional e CI/synthetic completamente segregada;
- shortlist não vinculante: Neon (planos pagos condicionados), Supabase Pro ou superior, AWS RDS; VM autogerida não preferida no piloto;
- **ODB-01–ODB-12** definidos como gates obrigatórios de owner, custo, segurança, migrations, dados, backup/restore e executor;
- nenhum provedor, plano, região, orçamento, credencial, implantação ou novo Epoch aprovado;
- relógio Recife consultado 19/10 às 08:14:15 confirmou janela ainda aberta *naquele instante*; preflight real não executado e nenhuma activation;
- Documento 105: `docs/governance/105-gate-arquitetura-banco-operacional-persistente-oes.md`.

> **PERSISTENT_OPERATIONAL_DB_ARCHITECTURE = APPROVED_WITH_CONDITIONS**
> **PREFERRED_CLASS = MANAGED_POSTGRES_PLUS_OBJECT_STORAGE**
> **PROVIDER_PLAN_REGION_BUDGET = PENDING_OWNER_DECISION**
> **OPERATIONAL_DEPLOYMENT = NOT_AUTHORIZED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

### CP149 — arquitetura candidata de persistência operacional

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP149.md`;
- próximo passo em modo alto, somente após `Prossiga`: seleção responsável de provedor/plano e autorização própria de infraestrutura;
- pausa obrigatória.

### Fase 4 — seleção condicional de infraestrutura gratuita (Documento 106)

- Freshness Gate CP149 confirmado; nenhum commit posterior material identificado antes da decisão;
- preferência do owner: serviço gratuito sempre que satisfizer integralmente ODB-01–ODB-12, sem compromisso de dispêndio;
- **Neon Free** selecionado como candidato prioritário **não contratado/não provisionado**: 1 GB DB, 100 CU-h/mês, restore 6 horas/1 GB e autosuspend após 5 min;
- object storage Neon Free 5 GB em beta é candidato inicial para objetos, insuficiente como cópia independente;
- cópia externa de `pg_dump` e dos artifacts com teste `pg_restore` obrigatório, ainda não implementada; Cloudflare R2 Standard free-tier opcional com necessidade de cadastro de cobrança/risco, não aprovado;
- Supabase Free permanece opção secundária, com 500 MB e risco de pausing, sem backup automático;
- fornecedor/region/security e autorização do owner pendentes, sem acesso factual, sem contrato, sem novos epochs;
- Documento 106: `docs/governance/106-selecao-condicional-piloto-postgresql-gratuito-oes.md`.

> **FREE_FIRST_PRIORITY = APPROVED_AS_USER_PREFERENCE**
> **PREFERRED_CANDIDATE = NEON_FREE**
> **INDEPENDENT_BACKUP = MANDATORY_AND_NOT_CONFIGURED**
> **PROVIDER_OWNER_APPROVAL = PENDING**
> **OPERATIONAL_DEPLOYMENT = NOT_AUTHORIZED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_LIVE_PREFLIGHT = NOT_EXECUTED**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

### CP150 — free-first candidate

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP150.md`;
- próximo bloco: autorização operacional e pacote de configuração Neon Free, modo alto, sem provisionamento automático;
- pausa obrigatória.

### Fase 4 — pacote de autorização de sandbox Neon Free (Documento 107)

- Freshness Gate CP150 / HEAD `b6fe5a242e2e4c5f5ae1ee52f5478c629416fb8d`, sem alterações materiais posteriores à entrada;
- Neon Free mantido como candidato para **sandbox sintético**, ainda sem conta/projeto provisionado;
- região candidata `aws-sa-east-1` / São Paulo: PostgreSQL disponível; Object Storage Neon **indisponível nessa região**;
- informação do Documento 106 sobre Neon Object Storage "beta" **superada** pela GA desde setembro/2026; manter Documento 106 imutável como snapshot histórico;
- formulário textual de autorização específica proposto; `Prossiga` genérico não autoriza aceitar termos ou provisionar recursos;
- conexão segura `sslmode=verify-full`, uso de credenciais fora do repositório/chat e segregação total da CI;
- backup independente e restore/Artifacs (ODB-07/08) não configurados; opções: cópias locais criptografadas em destinos distintos, ou R2 sujeito a risco financeiro e aprovação própria;
- status ODB-01–12: nenhuma comprovação factual de banco operacional; sem criação de Epoch, consulta científica ou mutation;
- Documento 107: `docs/governance/107-pacote-autorizacao-neon-free-sandbox-oes.md`.

> **NEON_FREE_SANDBOX_AUTHORIZATION_PACKAGE = READY**
> **NEON_FREE_SANDBOX = NOT_PROVISIONED**
> **REGION_CANDIDATE = aws-sa-east-1 / UNAPPROVED**
> **NEON_OBJECT_STORAGE_SAO_PAULO = UNAVAILABLE_AS_PUBLISHED**
> **NEON_OBJECT_STORAGE_GA_STATUS = GA_AS_OF_SEPT_2026**
> **BACKUP_INDEPENDENT = NOT_CONFIGURED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

### CP151 — pacote de autorização preparado

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP151.md`;
- próxima etapa: aprovação do owner para sandbox Neon Free/região específica, com testes sintéticos sem despesas;
- pausa obrigatória.

### Fase 4 — autorização específica de Neon Free sandbox (Documento 108)

- proprietário autorizou exatamente `APPROVED — Neon Free sandbox / Documento 107 / OES / synthetic-only / aws-sa-east-1 / no paid services`;
- escopo aprovado: sandbox sintético gratuito na região São Paulo, sem cartão, plano pago, PHI, query científica ou activation de Epoch;
- verificações GitHub CP151 `72bbfc330a23d085d45acc33b7d9f8bb104adede` sem drift; integração Neon disponível, porém **não instalada** neste ChatGPT;
- Documento 108 registra decisão e roteiro manual; script SQL read-only `database/f4-neon-free-sandbox-connectivity-readonly.sql` preparado para primeiro teste;
- nenhum provisionamento efetivo de projeto Neon, nenhuma conexão PostgreSQL, nenhuma migration, nenhum SQL executado;
- backup independente e restore seguem sem configuração, ODB-08 bloqueante; ODB integral não passou;
- próximo bloco condicionado à ação do proprietário no console Neon ou conexão explícita, em modo médio e após `Prossiga`.

> **NEON_FREE_OWNER_SCOPE_APPROVAL = APPROVED**  
> **APPROVED_REGION = aws-sa-east-1**  
> **NEON_FREE_SANDBOX = NOT_PROVISIONED_BY_OES**  
> **NEON_PLUGIN_CONNECTION = NOT_INSTALLED**  
> **NEON_SANDBOX_CONNECTIVITY_TEST = PREPARED_NOT_EXECUTED**  
> **BACKUP_INDEPENDENT = NOT_CONFIGURED**  
> **OPERATIONAL_DB_READINESS = NOT_READY**  
> **B1R1_ACTIVATION = NOT_PERFORMED**  
> **PHASE_5 = NOT_STARTED**

### CP152 — autorização reconhecida, aguardando ação de cadastro

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP152.md`;
- modo médio recomendado após projeto criado; pausa obrigatória.

### CP153 — Primeira conexão Neon Free / Documento 109

- projeto Neon `oes-sandbox` na região aprovada `aws-sa-east-1` observado efetivamente pela integração; PostgreSQL 18.6 e banco `oes_sandbox`;
- branch default `production` apenas nome do provedor, não produção OES;
- `SELECT` read-only executado com sucesso: clock PostgreSQL `2026-10-19T11:59:14.637Z`, role `oes_sandbox_owner`, sem mutation;
- chamada com `BEGIN; SELECT; ROLLBACK` falhou devido a prepared statement de múltiplos comandos, sem side effects;
- Documento 109 em `docs/governance/109-resultado-conectividade-readonly-neon-free-sandbox.md`;
- role owner requer segregação e privilégios mínimos; backup externo, migration ledger e object storage pendentes;
- B1R1 **não ativado** e nenhum measurement factual executado.

> **NEON_FREE_SANDBOX = OBSERVED_ACCESSIBLE**
> **SANDBOX_CONNECTION_READ_ONLY = PASS**
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**
> **OPERATIONAL_DB_READINESS = NOT_READY**
> **B1R1_ACTIVATION = NOT_PERFORMED**
> **PHASE_5 = NOT_STARTED**

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP153.md`; STOP até `Prossiga`.

### Fase 4 — inventário Neon Free read-only e expiração B1R1 (Documento 110)

- `oes-sandbox` (São Paulo, PostgreSQL 18.6) auditado via SELECT; apenas schema `public`, 0 tabelas e 0 funções de aplicação, `plpgsql` presente; database `oes_sandbox` ~7536 kB;
- role `oes_sandbox_owner` com poderes administrativos, sem role read-only segregada; servidor reportou `ssl=off`, sem conclusão automática sobre TLS externo;
- timestamp PostgreSQL `2026-10-19T12:05:22.721Z` e relógio Recife `2026-10-19T09:05:48-03:00` comprovaram fim da janela, sem preflight/activation válida B1R1; **EXPIRED_NOT_EXECUTED** conforme Documento 91;
- nenhuma migration/DDL/write/fixture ou query científica executada neste checkpoint;
- Documento 110 `docs/governance/110-inventario-readonly-neon-free-e-expiracao-b1r1.md` define preparação de sequência migrations, ledger e branch de teste futura, sem criação ainda;
- ODB-03, ODB-05–10, backup/restore e prontidão operacional continuam bloqueados.

> **NEON_SANDBOX_READONLY_INVENTORY = PASS**
> **B1R1_ACTIVATION_WINDOW = EXPIRED_NOT_EXECUTED**
> **OPERATIONAL_DATABASE_READY = NO**
> **INDEPENDENT_BACKUP = NOT_CONFIGURED**
> **PHASE_5 = NOT_STARTED**

### CP154 — inventoried sandbox and B1R1 expiry

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP154.md`;
- próximo passo após `Prossiga`: preparar plano de migrations sintéticas e branch de teste, modo médio;
- pausa obrigatória.

### Fase 4 — preparação de sequência de migrations para branch Neon sintética (Documento 111)

- Freshness Gate CP154 `678a0d8fb007b733e7aa2be10db42d5faceafc7f` consistente; `oes-sandbox` segue sem tabelas de aplicação;
- extraída sequência canônica de 36 arquivos `psql -f` do workflow S5; wrappers 031/032/033 carregam 14 fragmentos por `\ir`;
- manifesto `database/f4-neon-sandbox-schema-migration-manifest.txt` versionado, não executado; Documento 111 fixa gate BRG-01–BRG-10;
- Neon executor `run_sql` não processa `\ir`; preparação exige cliente psql ou executor compatível e hash SHA256 do checkout imutável;
- nenhum branch Neon, role, schema, migration ledger ou seed criado; nenhum dado factual ou source request;
- B1R1 expirado permanece intocado; backup externo ainda não configurado; readiness operacional bloqueado.

> **MIGRATION_SEQUENCE_DOCUMENTED = 36_ENTRY_FILES_14_SUBFRAGMENTS**
> **NEON_TEST_BRANCH = NOT_CREATED**
> **NEON_SCHEMA_MIGRATION = NOT_STARTED**
> **OPERATIONAL_DATABASE_READY = NO**
> **PHASE_5 = NOT_STARTED**

### CP155 — sequência e controles preparados

- checkpoint vigente: `archive/handoffs/oes/OES_Continuidade_2026-10-19_CP155.md`; pausa obrigatória.



### Fase 4 — Revisão estática do pacote de branch Neon (Documento 112 / CP156)

- Freshness Gate do CP155 confirmou HEAD `097d35b7fc38f81396285798cf314def9bd81aed`, sem drift;
- os 36 arquivos de entrada e os 14 fragmentos `\\ir` foram lidos no GitHub; inspeção estática com limitações, não teste de execução;
- confirmado DML estrutural 031a/032a (epochs, grandfathering), limites transacionais distintos 031–036 e DROP/CREATE TRIGGER em 034;
- proposta de ledger, runner `psql` e gates BRG-01–BRG-10 **não implementados**; SHA-256 de bytes e compatibilidade PG18 ainda pendentes;
- API Neon read-only: projeto `oes-sandbox` na região aprovada e apenas branch default `production`; não criar branch por autorização implícita;
- plano Free publicamente anunciado não substitui checagem factual de saldo, billing e cotas na conta;
- pacote de autorização `create-branch-only` **PREPARED_NOT_APPROVED**, separado de futura autorização de migrations;
- Neon schema/ledger/test branch **NOT_STARTED/NOT_CREATED**, backup independente pendente, B1R1 `EXPIRED_NOT_EXECUTED`, Fase 5 não iniciada;
- próximo passo: pré-gate `psql`/ledger sintético local/CI e quota read-only, sem writes no Neon; pausa obrigatória.


### Fase 4 — Pré-gate offline de migrations Neon e contrato de ledger (Documento 113 / CP157)

- Freshness Gate CP156/HEAD `cd7855c1fa366716569e35acbd5f81337b866caa` = identical;
- `scripts/oes_neon_migration_preflight.py` e `tests/test_oes_neon_migration_preflight.py` versionados: leitura do manifesto S5 36 entradas + 14 fragmentos, HEAD obrigatório, hashes SHA-256 e saída JSON fail-closed; nenhuma conexão SQL;
- 7/7 testes unitários sintéticos locais = OK, código GitHub conferido por Git blob SHA; nenhum teste dos 50 SQL reais em checkout integral e nenhum workflow CI disparado para essa prova;
- cliente `psql` indisponível no ambiente local; runner PostgreSQL 18 e ledger permanecem não implementados;
- contrato lógico de ledger e tratamento de estado incerto após falhas entre commit SQL e ledger preparados no Documento 113, não autorizados/implantados;
- API Neon somente leitura: assinatura `free_v3`, limite 10 branches, uma branch default `production`, projeto lógico até 1 GiB; consumo/billing do titular ainda pendente;
- Documento 113 esclarece prospectivamente notação de `\\ir`/diretiva `\ir`, sem alterar CP156;
- autorização para `oes-schema-test` = PREPARED_NOT_APPROVED; branch, roles, schema, ledger e migrations não criados;
- B1R1 permanece EXPIRED_NOT_EXECUTED; Fase 5 não iniciada; backup independente não configurado;
- próximo passo: prova do preflight no checkout integral e ensaio de runner/ledger em PostgreSQL 18 sintético sem Neon, sujeitos a disponibilidade e novo `Prossiga`; pausa obrigatória.


### Fase 4 — CI offline preparada e PostgreSQL 18 bloqueado (Documento 114 / CP158)

- Freshness Gate CP157/HEAD `3ecb187d04edc75a9b957bef5c252d746607d76e` = identical;
- workflow `.github/workflows/f4-neon-offline-preflight.yml` registrado: checkout fixado, unit tests sintéticos, inventário SHA-256 de 36+14 arquivos, captura de artifact; sem segredos, conexões ou SQL Neon;
- 7/7 testes unitários locais em árvore artificial OK; **nenhum run CI/log/artifact verificado** deste novo workflow, portanto hashes reais dos 50 SQL ainda não comprovados;
- checkout integral local bloqueado por DNS; PG17.11 local identificado, `psql` ausente; **nenhum teste de runner/ledger PostgreSQL 18 executado**;
- ledger = desenho lógico sem tabela/runner; política de locks e recuperação ainda pendente;
- autorização branch `oes-schema-test` não concedida; zero mutation Neon, sem backup independente, B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada;
- próximo bloco: confirmação de run CI e digest real, depois estudo sintético de runner/ledger PG18; pausa obrigatória.

### Fase 4 — Verificação CI sem acesso a run identificável (Documento 115 / CP159)

- Freshness Gate CP158/HEAD `94175cafebd9d960d4cb5341090f02cff4ae146e` = identical, zero drift;
- novo workflow de inventário offline permanece registrado, porém run_id, resultado CI, logs e artifact SHA-256 reais não recuperados nesta etapa;
- integração GitHub permite jobs/logs/artifacts a partir de run_id, mas não enumeração geral de runs; endpoint público indisponível neste ambiente;
- execução CI: DESCONHECIDA, não se conclui que ocorreu nem que não ocorreu, e não se declara PASS;
- Documento 115 documenta meios de obtenção de run_id e critérios de prova; CP159 congela o estado;
- sem execução PostgreSQL 18 de ledger, sem branch/schema/migration Neon, B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada;
- pausa obrigatória até novo `Prossiga`.


### Fase 4 — Prova CI offline do inventário confirmada (Documento 116 / CP160)

- run GitHub Actions `39256905894`: job `inventory` completed/success, 7/7 testes unitários, inventário de 36 entrypoints + 14 fragmentos, artifact `12186719617` recuperado;
- commit testado: `55ef8051054652b3823de743293524f317a33ec6`; checksum SHA-256 agregado `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`;
- `inventory.json` verificado contra checksum: `5694be45dd10c39131e6a74270bbf66cbb30ee21aba7bd47c91e96d2f2ea2504`; BRG-04 STATIC_CI_VERIFIED somente no commit testado;
- evidência não autoriza nem prova migrations PG18, runner/ledger, segurança, billing ou backup; sem write Neon, branch ainda não criada, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo passo: ensaio PG18 exclusivamente sintético em CI/local, avaliação de locks/ledger e falhas; pausa obrigatória CP160.


### Fase 4 — Preparação de ensaio PostgreSQL 18 sintético (Documento 117 / CP161)

- Freshness Gate CP160/HEAD `255663e154067ecca3f5073ec96ad69d084f4e6b` = identical;
- publicado workflow manual `.github/workflows/f4-neon-pg18-schema-rehearsal.yml`, contêiner PG18 descartável em GitHub Actions e credenciais somente sintéticas de job;
- preparação inclui pré-gate SHA-256 em checkout fixado, execução das 36 migrations sem fixtures, logs separados e paragem no primeiro erro; **não houve execução ou resultado verificado**;
- Documento 117 descreve escopo e limitações; BRG-05 ainda pendente, BRG-06 ledger somente desenho, BRG-07 runner CI preparado/não testado;
- nenhuma criação de branch, role, schema, migração ou operação no Neon; B1R1 EXPIRED_NOT_EXECUTED; Fase 5 não iniciada;
- próximo bloco: conferir run manual PG18 e artifacts; pausa obrigatória.


### Fase 4 — CI PG18 automática autorizada (Documento 118 / CP162)

- Owner autorizou acionamento automático apenas da CI sintética; workflow PG18 recebeu gatilho push main limitado ao seu próprio arquivo, preservando execução manual;
- alteração aplicada no commit `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`;
- run/job/artifact de PG18 ainda não confirmado; nenhum PASS de compatibilidade declarado;
- nenhuma alteração Neon, branch, ledger ou migration; B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; pausa obrigatória.


### Fase 4 — Prova PG18 sintética 36/36 (Documento 119 / CP163)

- run GitHub Actions `39261597847`, job `118090362879`, completed/success, HEAD de teste `0f56b7f69bc5e3abba0fdb235d88cd3ac1e619e5`;
- PostgreSQL servidor 18.6, cliente psql 16.15; 36 migrations PASS, 14 fragmentos conferidos; artifact `12190502582`; digest de inventário `228583f1cffc9774829b94eb0747537a3939ecf5334034f66bca990576c11ae6`;
- 275 funções (schemas selecionados), dois registros estruturais contract_epoch; BRG-05 passa apenas para sequência sintética no commit fixado;
- ledger/locks/recuperação, menor privilégio, backup, Neon Free billing pendentes; sem operações Neon, B1R1 expirado sem execução, Fase 5 não iniciada;
- próximo bloco requer avaliação de ledger e falhas sintéticas, recomendado modo alto; STOP.


### Fase 4 — Falhas transacionais e advisory locks em ledger sintético PG18 (Documento 120 / CP164)

- Freshness Gate CP163 HEAD `4a2d9d2e60c2b86ca789944dd69a343c8fb4ee01` = identical;
- criados `tests/fixtures/f4-ledger-synthetic/bootstrap.sql`, `scripts/oes_pg18_ledger_synthetic_test.sh`, `.github/workflows/f4-pg18-ledger-synthetic.yml` com CI apenas PG18 descartável, sem Neon;
- run `39263916981` / job `118098438290` completed/success no SHA `2acabe21102774bae5ce86d15858dc434e905bf5`; PostgreSQL 18.6 / psql 16.15, **17/17** testes sintéticos PASS;
- artifact `12191953694` e ZIP SHA-256 `6eefdb6ed5986330b05cc03cda2e53abff8a3ca46a17fea12fbe475ddc81622f` conferidos; rollback e recibo atômicos no teste, commit-gap, drift, retry bloqueado, append-only e lock de duas sessões;
- BRG-06 modelo sintético verificado/ledger operacional NÃO criado; BRG-07 primitiva lock verificada, **não** há guardião de lock cobrindo 36 subprocessos nem testes de kill/recovery;
- nenhuma branch/role/schema/ledger/migration no Neon, backup independente não configurado, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: guardião de lock e injeção de falhas sintéticas, modo alto, pausa obrigatória após CP164.


### Fase 4 — Guardião persistente de lock PG18 e contraprova após crash (Documento 121 / CP165)

- Freshness Gate CP164/main = identical, HEAD `2ad4da0fbd725273ed253d88fd3ccc29ed2a2ff8`; modo alto;
- criados script `scripts/oes_pg18_guardian_synthetic_test.py` e workflow `.github/workflows/f4-pg18-guardian-synthetic.yml` para PostgreSQL 18 exclusivamente descartável, sem Neon;
- run `39266423818` FAILED: lock não liberado prontamente com query `pg_sleep` ativa após SIGKILL do cliente; run `39266711331` FAILED por newline de stdin incorreto;
- run corrigido `39266780706` SUCCESS, 15/15 testes, PostgreSQL 18.6 e psql 16.15, commit `064d970ddbc1e4a4830a44472074eaec5734698b`, artifact `12193207877`, ZIP SHA-256 `867f2189872cbdd3accf12851f6d4d1843a63bbea7b1a5bf4e7f7c62a39f6175`;
- a sessão ociosa conserva lock em dois subprocessos sequenciais e o libera após SIGKILL, mas um subprocesso SQL em voo **pode concluir commit após morte do guardião**. Intenção durável `prepared` impediu replay e estado `uncertain` persistiu; prova negativa não autoriza runner operacional;
- BRG-06/07 = modelo sintético comprovado com limitação, ledger operacional/supervisor/guarda de subprocessos/reconciliação por pós-condições ainda pendentes; BRG-03/08/09 pendentes;
- nenhum Neon write, branch, role, schema, ledger, migration, backup independente ou operação factual. B1R1 EXPIRED_NOT_EXECUTED; Fase 5 não iniciada;
- próximo bloco: supervisor de processo e falhas induzidas no PG18 sintético, modo alto; STOP CP165.


### Fase 4 — Supervisor PG18 sintético: concorrência, cancelamento e reconciliação (Documento 122 / CP166)

- Freshness Gate CP165/HEAD `2ebd3a56da271a4d98859d6b0e5c9db5c40a8ea3` = identical, 0 drift; modo alto;
- novos artefatos `tests/fixtures/f4-supervisor-synthetic/postconditions.json`, `scripts/oes_pg18_supervisor_synthetic_test.py` e `.github/workflows/f4-pg18-supervisor-synthetic.yml`, exclusivamente PostgreSQL 18 efêmero e sem Neon;
- harness visa testar índice parcial de claim `prepared` sob concorrência, guardião ocioso, SQL confirmado sem recibo, cancelamento de transação ainda aberta, bloqueio de repetição, recusa de novo subprocesso após perda do guardião e pós-condições conservadoras;
- run CI automático `39278420804` no SHA `7bba5cbd3a5c1cf9d628049b2b00643f8d21b226`, job `118148257964` permaneceu `queued` nas consultas: **NÃO há teste executado/comprovado, artifact ou PASS neste bloco**;
- Documento 122 e CP166 registrados; BRG-06/07 permanecem modelos de prova sintética e NÃO autorizam runner/ledger operacional;
- nenhuma branch/role/schema/migration/ledger Neon, backup independente ausente, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próxima retomada: consultar run 39278420804 e artifacts, diagnosticar falhas se houver; modo alto, pausa obrigatória.


### Fase 4 — Evidência sintética supervisor PG18 recuperada (Documento 123 / CP167)

- Freshness Gate CP166/main = identical, HEAD entrada `ab9e7ff7ab64ab8125e073f3f5764ab5257526d6`, modo alto;
- run PG18 sintético `39278420804`, commit `7bba5cbd3a5c1cf9d628049b2b00643f8d21b226`, logs completos e artifact `12199766445` recuperados e auditados; **25/25 controles PASS**, PostgreSQL 18.6, psql 16.15;
- hash SHA-256 ZIP `57dc8e2ba0af83bbfb352735989e48e965cdeafc7111e0725c5a795abadfea9e`; `claim-results.json=[true,false]`, pós-condições de commit sem recibo e de transação cancelada verificadas; replay/applied automáticos recusados;
- **metadados GitHub do run/job passaram de queued para in_progress, com conclusion=null na última leitura**, embora logs e artifact comprovem execução do harness; não alegar conclusão administrativa `completed/success`;
- Documento 123 e CP167 registrados; BRG-06/07 modelo sintético comprovado, **ledger e runner operacionais não liberados**; segurança ACL/TLS, backup, billing pendentes;
- nenhuma criação/alteração de branch, SQL, ledger ou schema Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco modo alto, pausa obrigatória.


### Fase 4 — Desenho fail-closed e catálogo de reconciliação das 36 migrations (Documento 124 / CP168)

- Freshness Gate CP167/HEAD `0d884ab84e449398ec0367a08364cfde1e5cb8f8` = identical; run supervisor anterior `39278420804` passou a `completed/success`, fechando inconsistência de metadados CP167;
- Documento 124 criado: distinção entre advisory lock cooperativo e fencing real; política **proposta/não normativa** de intent durável, claim exclusivo, supervisão e reconciliação, sem modificar a política canônica 30;
- catálogo `database/f4-reconciliation-postconditions-draft.json` com 36/36 migrations na ordem do manifesto, todas UNREVIEWED, 0 pós-condições, 0 autorizações automáticas; observações documentais de fronteiras SQL 031–036;
- linter offline `scripts/oes_f4_reconciliation_catalog_lint.py`, 11 unit tests sintéticos e CI `.github/workflows/f4-reconciliation-catalog-static.yml` criados;
- CI run `39282514522` no commit `52f796f3b500e550335c06a33c761369804fd3e6`: logs mostram 11/11 testes OK e artifact `12201766282` com digest ZIP `208b607dfd72d6ddde9710cef0da0fea093e562fd92a2e76d3e82a3e0f832e8b` conferido; metadados administrativos ainda queued/conclusion=null na última consulta, não declarar run success;
- Nenhum SQL foi executado pela CI documental, nenhuma modificação Neon; BRG-06/07 ainda não operacionais, BRG-03/08/09 pendentes, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: revisar pós-condições reais 031–036 em modo alto e somente sintético/offline; STOP CP168.


### Fase 4 — Revisão estática de pós-condições 031–036, sem liberação operacional (Documento 125 / CP169)

- Freshness Gate CP168/main `d213a618ce6fa87c8008c8e5da30a3ff219048fa` = identical; run anterior `39282514522` confirmado completed/success (11 testes OK);
- inspeção de 031–036 e 14 fragmentos: 031/032/033 wrappers transacionais; 032 contém grandfathering e seed técnico, 034/036 DROP/CREATE trigger sem wrapper, 035 duas substituições de função;
- publicados `docs/governance/reconciliation/f4-031-036-source-candidates.json` (6 candidatos NÃO validados), `scripts/oes_f4_031_036_source_review.py`, 8 testes e workflow estático próprio;
- run CI `39297500185`, commit `feb2b9f115e94a09c975b98f61d7a5ffda53438d`, job `118213715729` completed/success, 8/8 testes, artifact `12209110983`, SHA ZIP `ff1c7b237c5b5c1246b60bdb2f3cae19073acb88e5b793b254559169873551f1`;
- Documentação 125 e CP169; scanner prova somente integridade textual de 20 fontes. Catálogo principal 36 UNREVIEWED/0 pós-condições validadas, nenhuma autorização de execução/replay/reconciliação automática;
- BRG-06/07 operacionais pendentes; nenhuma branch ou SQL Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco PG18 descartável para comparação pré/pós e falhas induzidas, modo alto, STOP.


### Fase 4 — Prova sintética PG18 de falhas estruturais 031–036 (Documento 126 / CP170)

- Freshness Gate CP169/main = identical, HEAD entrada `f928807e76b74dc32b65fe3a707c72232c721c55`; modo alto;
- publicado `scripts/oes_f4_pg18_031_036_fault_rehearsal.py` e `.github/workflows/f4-pg18-031-036-fault-rehearsal.yml`; PG18 descartável em GitHub Actions sem Neon;
- primeira CI `39349451906` FAILED por consulta antecipada do comparador ao objeto `maintenance.contract_epoch` inexistente antes de 031; corrigida prospectivamente; não classificar como erro da migration;
- run corrigido `39349564581`, job `118390284507`, completed/success, 29/29 checks PASS no commit `46af0a575e30d640dedd97edf84315ebc5f6f310`; artifact `12233090040`, ZIP SHA-256 `6aea06318fb097c66066a75e13b8e03ae23ff52c6c7cf07a9bfffb9009431a3e` conferido;
- 031–033: rollback de inventário estrutural em erro induzido antes do commit; 034/036: replay negativo deixou trigger ausente após DROP e falha antes do CREATE; 035: primeira função persistiu, segunda ausente após erro;
- **zero pós-condições operacionalmente validadas, catálogo principal 36 UNREVIEWED**; não houve fixture de registros preexistentes para grandfathering 032, nem prova integral de DML/semântica;
- Documento 126 e CP170 registrados; BRG-06/07 e BRG-03/08/09 operacionais ainda pendentes; nenhuma migração/branch/SQL Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: grandfathering 032 em PG18 descartável, modo alto, pausa obrigatória.


### Fase 4 — Grandfathering 032 com fontes sintéticas preexistentes (Documento 127 / CP171)

- Freshness Gate CP170/main idêntico ao HEAD `238b2a11cf26c94958e075ad852575419958b38e`; modo alto, sem mudança Neon;
- fixture com três fontes preexistentes constraint-consistentes: `update_policy`, `sla_calendar_version` e `sla_rule`, vinculadas a core/product artificiais; harness PG18 descartável e workflow CI sintético publicados;
- run `39350571819` job `118393517271`, completed/success, commit `a060f7055063bf83ce8e880193b08f9c941e46f3`, servidor PG18.6, **19/19 verificações PASS**;
- artifact `12233056788` ZIP SHA-256 `4191c4936b523b7ea9e2d7e176a14770b5daa6eb618dd6832a23f340b899b339` conferido com GitHub; 3 entradas grandfathered na primeira instalação, fontes preservadas, rollback antes COMMIT retorna ao estado estrutural anterior;
- controle negativo: marcador `TEMPORAL_CALIBRATION_V01` artificialmente preexistente suprime grandfathering, logo marker isolado não comprova migration integral;
- Documento 127/CP171 publicados; **catálogo 36 UNREVIEWED, zero pós-condições aprovadas**, BRG-06/07 operacionais não implantados, BRG-03/08/09 pendentes;
- sem Neon branch, SQL ou registro científico; B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada; próximo bloco funções/triggers 034–036 em PG18 descartável, modo alto e pausa obrigatória.


### Fase 4 — Testes comportamentais temporais 034–036 em PG18 (Documento 128 / CP172)

- Freshness Gate CP171/main `e8219a04ab322eb51d401ce37177e5f5e33b1cba` = identical, sem drift, modo alto;
- fixture de plano, fonte, epoch, oportunidades e autoridade **artificiais**, harness `scripts/oes_f4_pg18_034_036_behavior_test.py` e workflow `.github/workflows/f4-pg18-034-036-temporal-behavior.yml` publicados, somente CI PG18 descartável;
- primeiro run `39355352898` FAILED porque fixture reutilizou calendário pré-032 não aceito pelo schema 036; corrigido sem modificar SQL de migration;
- run corrigido `39355448709`, job `118409046787`, completed/success, SHA `d0c378a99b36f331bc1f5df627cd024448a421e1`, PostgreSQL 18.6, **30/30 PASS**;
- artifact `12235255740` ZIP SHA-256 `a9326e8d6d5aa3a2f282460ed3465be295767f6d2d513c4f2d1986523b8e2442` conferido; 034 recusou cronologia inválida/desvio material e aceitou ativação sintética válida; 035 comprovou FAIL/WAIT/PASS sem DML; 036 verificou primeiro e subsequente eventos com novelty/attribution;
- Documento 128/CP172; autoridade artificial não equivale a aprovação científica/humana; catálogo principal **36 UNREVIEWED, 0 pós-condições operacionais aprovadas**, BRG-06/07 não operacionais;
- nenhuma branch, SQL, role, migration, ledger ou alteração Neon; BRG-03/08/09 pendentes, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco lacunas de cenários negativos, modo alto, STOP.


### Fase 4 — Cobertura negativa temporal 034–036 sob PG18 descartável (Documento 129 / CP173)

- Freshness Gate CP172/main = identical, HEAD `f2f89ed65eff43ca38b482506c7106048b805aa4`, 0 drift, modo alto;
- novos `scripts/oes_f4_pg18_034_036_negative_coverage.py` e `.github/workflows/f4-pg18-034-036-negative-coverage.yml`, sete bancos sintéticos para diferentes estados e nenhum acesso Neon;
- run `39356550539`, job `118412553302`, completed/success, commit `b5f0eb3c0b3d95b7e864c3fdbbfb05dfc7baf997`, **27/27 verificações PASS**, artifact `12235317764`, ZIP SHA256 `dec06e6b79afe9eb34902e804578eb10aa28fe04d19dab774f4dd6a3ae5fec34` conferido;
- autoridade ausente/conflitante, conectividade obrigatória bloqueada e oportunidade faltante recusadas pelos guards/preflight;
- contraprova crítica em **superusuário CI sintético**: desabilitar triggers 034 e 036 permite gravar estados inválidos, não corrigidos retroativamente pela reabilitação; requer segregação de roles, auditoria DDL e validação dos dados históricos, **sem afirmar risco de exploração por usuário comum**;
- desvio material gravado depois de `started_at` não bloqueou ativação naquele instante; nenhuma decisão de governança para o futuro foi inferida;
- Documento 129/CP173; catálogo principal 36 UNREVIEWED, zero pós-condições aprovadas, sem ledger/runner operacionais, nenhuma operação Neon, B1R1 EXPIRED_NOT_EXECUTED e Fase 5 não iniciada;
- próximo bloco: matriz de suficiência de evidências e separação de privilégios, modo alto, pausa obrigatória.


### Fase 4 — Matriz provisória de suficiência de evidências 034–036 (Documento 130 / CP174)

- Freshness Gate CP173/main `9d39071800343151b917ea7d00862f12f8c00f4a` = identical, sem drift;
- publicada matriz `docs/governance/reconciliation/f4-034-036-evidence-sufficiency-matrix-draft.json`: **3 migrations, 36 requisitos NOT_COLLECTED**, 0 validações operacionais e 0 revisões independentes. Exige identificação/hash do SQL, ledger/intenção/recibo, dependências, integridade histórica, roles, auditoria DDL, backup/restore e aprovação humana;
- validador estático `scripts/oes_f4_temporal_sufficiency_matrix_lint.py`, 12 testes e workflow read-only próprios, nenhum SQL executado;
- run `39357315282`, job `118414984671`, completed/success, commit testado `bce4b359c5658ce94342b457cd79b06f3bab6b32`, **12/12 testes PASS**;
- artifact `12235633344` SHA-256 ZIP `6db9387eb7b10476d03ba5403f6b145510f4bbda699da8163b9459c8c7959537` conferido; saída `STATIC_DRAFT_MATRIX_BLOCKED_ONLY`, 0 pós-condições aprovadas, nenhuma permissão de execução/replay/reconciliação automática;
- Documento 130 e CP174 registrados; **catálogo principal 36 UNREVIEWED**, BRG-03/06/07/08/09 pendentes, ausência de qualquer mudança Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco recomendado: teste sintético de ACL/DDL e segregação de roles em PG18 descartável, modo alto, pausa obrigatória.


### Fase 4 — Segregação de roles e auditoria DDL transacional em PostgreSQL 18 sintético (Documento 131 / CP175)

- Freshness Gate CP174/main = identical, HEAD `8c8a54937f9ef1a697c309d4e7876dd473ff8a8c`, sem drift, modo alto;
- publicados `scripts/oes_f4_pg18_acl_ddl_audit_synthetic.py` e `.github/workflows/f4-pg18-acl-ddl-audit-synthetic.yml`, restritos a PG18 descartável e roles artificiais, sem Neon;
- runs `39358068414` e `39358143142` FAILED por comparação incorreta do resultado booleano convertido em texto no harness; as permissões e denials já executadas permaneceram coerentes; correções prospectivas;
- run `39358223730`, job `118417944949`, completed/success no commit `b53897af4e12052c122f5ab1d1c879f1a32c52d1`, **38/38 verificações PASS**, servidor PostgreSQL 18.6;
- artifact `12236325916`, ZIP SHA256 `44107e32b45fcf7b4698572d736e38005370348d6465d3bd320c2544ec23a408` conferido; runtime e migrator de privilégio limitado foram impedidos de alterar/desabilitar objetos 034–036 no contêiner;
- superusuário sintético desabilitou e reabilitou guard 034; event trigger de auditoria em banco registrou duas alterações DDL **confirmadas**, mas não preservou evento em transação revertida; trilha interna não é log externo independente;
- Documento 131/CP175; **BRG-03 ainda sem confirmação Neon/TLS/segredos/DDL externo**, BRG-06/07 operacionais não liberados, BRG-08/09 pendentes; catálogo principal 36 UNREVIEWED, 0 pós-condições aprovadas;
- nenhum SQL/branch/role/ledger Neon, B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada; próximo bloco modelo offline de roles/auditoria externa, modo alto, pausa obrigatória.


### Fase 4 — Modelo-alvo provisório de roles e auditoria DDL externa (Documento 132 / CP176)

- Freshness Gate CP175/main `0d81a9eff96ba545075c4bfe9c5071414f45510c` = identical, ahead/behind 0, modo alto;
- modelo documental `docs/governance/security/f4-target-roles-external-audit-draft.json`: **6 papéis**, **12 requisitos de segurança não satisfeitos**, **4 alternativas de auditoria sem escolha operacional**, tudo fail-closed;
- PostgreSQL ownership e possibilidade de `SET ROLE` de membro impedem garantir que migrator elevado à propriedade não possa desabilitar guards apenas por `REVOKE`; requer elevação controlada, hashes, supervisor, auditoria externa e revisão especializada; tais controles ainda não existem;
- exportação Neon de logs PG para OTLP publicamente descrita, mas disponibilidade Free e eventual cobrança **não verificadas**; nenhuma ativação de serviço pago e nenhuma suposição de auditoria completa a partir de GitHub Actions ou event trigger transacional;
- validador estático e 16 testes publicados; run `39361692980`, job `118429107779`, completed/success no SHA `fd75b3a41a1cdf9fe23ec1cb2626bb349efdd431`, **16/16 PASS**;
- artifact `12236864111`, ZIP SHA256 `d91577ca76868f4612eda88a5a6cb7c9083d243f12afd5574b1490133a8e902c` validado, status: 6/12/4, 36 migrations UNREVIEWED, 36 requisitos de matriz 034–036 NOT_COLLECTED, nenhum SQL/Neon/serviço pago;
- Documento 132 e CP176; BRG-03/06/07/08/09 não liberados; nenhuma branch, role, DDL ou ledger Neon; B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco: somente experimento PG18 descartável de papéis LOGIN, `SET/INHERIT`, elevação e simulação de recibos de logs externos; modo alto, pausa obrigatória.


### Fase 4 — LOGIN, SET/INHERIT e recibos CI fora da transação (Documento 133 / CP177)

- Freshness Gate CP176/main `1bed3de41ebc9dd5a670e867d38bc3c2e6825669` identical, modo alto; data do novo checkpoint 2026-10-20;
- harness `scripts/oes_f4_pg18_login_roles_external_receipt_sim.py` e workflow descartável publicados: autenticação LOGIN de três roles sintéticas, proprietária NOLOGIN, opções `SET/INHERIT`, alteração de owner somente em banco PG18 CI, teste de trigger 034;
- run inicial `39404590522` FAILED por falta de USAGE no schema pela role proprietária artificial; corrigido sem modificar migrations SQL históricas;
- run `39404695131`, job `118567684999`, completed/success no commit `39ad812f55fd7b79c70f80766f0a85c3e9ea713c`, **41/41 PASS**, artifact `12256624023` ZIP SHA256 `e40f13a2254d9e8d41e14b87b3c758f6e2f1a0200e1f35a3d96d6aee240c014f` conferido;
- migrator com membership `SET FALSE/INHERIT FALSE` não pôde assumir owner; credencial com `SET TRUE` pôde, após `SET ROLE`, desabilitar e reabilitar trigger 034 no banco descartável, provando risco de elevação;
- oito recibos JSONL simulados fora da **transação PG**, armazenados no próprio runner CI; rollback preservou recibo no filesystem; cinco corrupções simuladas detectadas. Não há imutabilidade, independente, cobertura SQL direta/fora do wrapper ou coletor externo;
- Documento 133/CP177, catálogo 36 UNREVIEWED/0 pós-condições aprovadas, matriz 034–036 36 NOT_COLLECTED, BRG-03/06/07/08/09 operacionais pendentes, nenhum Neon nem serviço pago; B1R1 EXPIRED_NOT_EXECUTED, Fase 5 não iniciada;
- próximo bloco `ADMIN FALSE`, membership transitiva e limites de comprovantes fora da transação em PG18 descartável, modo alto; pausa obrigatória.


### Fase 4 — ADMIN FALSE, membership transitiva e limites de recibos (Documento 134 / CP178)

- Freshness Gate CP177/main em 73280fd0fdc7f0dd440feee0f741299d1d34e476: identical, ahead/behind 0, modo alto.
- Harness sintético e workflow PG18 descartável publicados. Run 39410126403, job 118585562919, commit técnico 909922efd400b237181445c5a206f97b3fcc19e9: completed/success, 40/40 PASS confirmados em logs e checks.tsv.
- Artifact 12259205919, 11 arquivos, ZIP íntegro testzip()=None, SHA256 4577ddde26943d00c05e7dc9b4143ab288d106aa4692ee5e04a1e641f3be5c46 igual ao digest GitHub.
- Seis memberships artificiais ADMIN FALSE; delegações diretas sem ADMIN negadas. Cadeia SET TRUE transitiva possibilitou SET ROLE owner e alteração temporária do trigger 034; cadeia INHERIT TRUE com SET FALSE possibilitou DDL de owner sem SET ROLE; rollback preservou o trigger.
- Recibo incompleto simulado foi rejeitado, mas não prova execução de SQL; SQL direto fora do wrapper alterou trigger sem novos recibos; adulteração simultânea de JSONL e anchor SHA256 foi aceita pelo verificador local. Recibos no mesmo runner NÃO são auditoria externa independente/imutável.
- BRG-03/06/07/08/09 operacionais seguem bloqueados; BRG-04/05 continuam evidências limitadas a commits. 36 migrations UNREVIEWED, zero pós-condições aprovadas e 36 requisitos 034–036 NOT_COLLECTED; 12 controles de roles não satisfeitos.
- Sem SQL/branch/migration Neon, sem serviço pago. B1R1 EXPIRED_NOT_EXECUTED, Fase 5 NOT_STARTED. Documento 134 e CP178. STOP; próximo checkpoint requer novo Prossiga.


### Fase 4 — Proporcionalidade e priorização científico-funcional (Documento 135 / CP179)

- Freshness Gate CP178/main `e78821cc4f377bb51b8640fda7d9c1cd9b538585` identical, ahead/behind=0. Modo alto; decisão somente documental.
- Três camadas analíticas: D0 desenho/testes efêmeros, D1 piloto persistente (não autorizado), D2 operação real e automação autoritativa (não autorizadas). Nenhum BRG ou gate alterado.
- Prioridade imediata: inventário de suficiência científico-funcional do protocolo de atualização, casos manuais/assistidos, revisão humana e lacunas. Novos testes PG18 só se houver decisão dependente e hipótese material nova; achados CP175–178 mantidos em escopo sintético.
- BRG-03/06/07/08/09 bloqueados; BRG-04/05 históricos. 36 migrations UNREVIEWED, zero pós-condições de reconciliação aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos, flags automáticas desabilitadas.
- Sem Neon SQL/branch/migration/role, sem CI nova, sem serviço pago. B1R1 EXPIRED_NOT_EXECUTED; Fase 5 NOT_STARTED; revisão especializada exigível onde aplicável. STOP.


### Fase 4 — Inventário de suficiência científico-funcional (Documento 136 / CP180)

- Freshness Gate CP179/main `cabd12b4ede5a82bcb60cfef4054e2ae88dbe38b` = identical, 0 ahead/behind; modo alto; escopo exclusivamente D0 documental.
- Documento 136: 14 domínios SF-01–SF-14 classificados sem confundir especificação, validação técnica sintética e suficiência científica real; percurso de referência manual/assistido, doze casos candidatos AT-01–AT-12 e lacunas G1–G6.
- RESULTADO = INVENTORY_COMPLETED_WITH_MATERIAL_GAPS; prontidão para encerramento documental da Fase 4 = NOT_READY_FOR_PHASE_4_DOCUMENTAL_CLOSURE. Nenhum caso AT declarado testado/validado neste CP.
- N1/N2 readiness temporal = INSUFFICIENT_EVIDENCE; valores de cadence/SLA normativos NÃO autorizados; B1R1 EXPIRED_NOT_EXECUTED; M3 formal BLOCKED; nenhum início de Fase 5.
- BRG-03/06/07/08/09 bloqueados; BRG-04/05 provas históricas. 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles de roles não satisfeitos. Sem Neon SQL/branch/role/migration, sem CI ou serviços pagos novos.
- Próximo ponto mediante novo Prossiga: especificar/confrontar cenários integrados D0, preservar revisão humana qualificada e bloqueios operacionais; pausa obrigatória.


### Fase 4 — Doze cenários adversariais de aceitação documental (Documento 137 / CP181)

- Freshness Gate CP180/main `98886a7cb2d710c88fba9f58bd2decb054a0aedd`: identical, ahead/behind=0; modo alto; escopo exclusivamente D0 documental.
- Documento 137: AT-01–AT-12 **especificados e confrontados textualmente**, 9 leituras coerentes condicionais, 3 ressalvas adversariais AT-05/09/12; **zero cenários integrados executados**, nenhuma validação científica humana, nenhum PASS empírico.
- G1 parcialmente especificada; G2–G6 permanecem com dependências humanas, temporais, operacionais e de runbook. PHASE_4_DOCUMENTAL_CLOSURE=NOT_READY.
- BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos, 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles pendentes.
- Neon intocado, nenhuma CI/PG18/SQL/serviço pago; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado, Fase 5 NOT_STARTED. Próximo somente após Prossiga: runbook e matriz de aceitação D0. STOP.


### Fase 4 — Runbook manual/assistido, aceitação e piloto empírico estratégico (Documento 138 / CP182)

- Freshness Gate CP181/main `148355f845d4c3307738b251924db43cd80c14a1`: identical, ahead/behind=0; modo alto; somente D0/documentação.
- Documento 138: runbook R0–R8; matriz AT-01–AT-12 com evidências e oráculos, **12 especificados, zero executados**; template de registro futuro e STOP por ausência de autoridade, ciência, integridade ou recuperação.
- **Duas frentes de planejamento preservadas:** (1) suficiência científico-funcional documental (G1–G6 ainda pendentes, sem encerramento da Fase 4); (2) piloto empírico futuro PubMed/ClinicalTrials.gov com nove dependências PILOT-01–PILOT-09 e sequência proposta E0–E5, sem autorização de execução.
- `F4_EMPIRICAL_FIRST_MEASUREMENTS = STRATEGIC_PENDING_WITH_BLOCKERS`, `NEW_EPOCH = NOT_AUTHORIZED`, B1R1 `EXPIRED_NOT_EXECUTED`, preflight e medições históricas não executados; pacotes Docs 91/94/95 preservados, não reaproveitados como autoridade válida de execução.
- Neon Free com prova de SELECT histórica apenas, não banco operacional factual aprovado. BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos; 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles não satisfeitos.
- Nenhum SQL/branch/role/migration Neon, nenhuma nova CI/PG18, nenhum request target-specific PubMed/ClinicalTrials, nenhum serviço pago. M3 bloqueado; Fase 5 não iniciada. Próximo candidato CP183 somente após Prossiga: matriz proporcional de mínimo readiness do piloto, documentação sem ações operacionais. STOP.


### Fase 4 — Gate mínimo de retomada do piloto factual (Documento 139 / CP183)

- Freshness Gate CP182/main `9e762b1edfd96262b9782d9fe87c1a508da46051` identical, 0 ahead/behind; modo **médio** documental. Alto somente quando riscos, custos, segurança ou autorização operacional justificarem.
- Documento 139: P-A consulta interface sem persistência (alternativa não selecionada), P-B medições factuais persistidas PubMed/ClinicalTrials (objetivo estratégico mantido, não autorizado), 12 ODBs NOT_READY e trilha G0–G5.
- BRG-03/06/07/08/09 bloqueados; BRG-04/05 históricos; 36 migrations UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles não satisfeitos. Neon Free SELECT histórico PASS apenas, não factual ready.
- B1R1 EXPIRED_NOT_EXECUTED, novo epoch NOT_AUTHORIZED, M3 bloqueado, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED; nenhum Neon, PG18, CI, request de fontes ou gastos neste CP. Próximo candidato CP184 G0 somente após Prossiga. STOP.


### Fase 4 — Pacote de decisão G0 do proprietário (Documento 140 / CP184)

- Freshness Gate CP183/main `dba90c228bc2920f35ef687af368e0bd9a43beda` identical, 0 ahead/behind; modo **médio**, apenas documentação.
- Documento 140: pacote G0 para piloto futuro P-B PubMed/ClinicalTrials.gov, dez dimensões delimitadoras e seis decisões G0-D1..D6 **PENDING_OWNER**; modelo de deliberação não assinado, sem decisão financeira/operacional inferida. P-A interface não persistente continua alternativa não selecionada.
- Neon Free somente sandbox synthetic-only, SELECT histórico; factual use não autorizada. BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos, 36 migrations UNREVIEWED, 0 pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 controles de roles pendentes.
- B1R1 EXPIRED_NOT_EXECUTED; sem novo epoch, cadastro, branch/migration/role SQL Neon, consulta PubMed/ClinicalTrials.gov, MeasurementEvent, gasto ou autenticação. M3 bloqueado, Fase 4 documental NOT_READY e Fase 5 NOT_STARTED.
- CP185 candidato condicionado a novo Prossiga: revisão proporcional de dependências e um único próximo ato preparatório; recomendar **modo alto** antes de aprovação G0 substantiva. STOP.


### Fase 4 — Priorização de ato único para prontidão do piloto (Documento 141 / CP185)

- Freshness Gate CP184/main `c657e6ec1f5d2542ed828d35922046cc52b5d9bf` identical, zero ahead/behind, modo médio; análise apenas documental.
- Documento 141 seleciona **conferência futura read-only pelo titular** de plano, quotas e riscos de billing Neon Free; **não executada**, G0-D1–D6 PENDING_OWNER. Nenhum dado sensível solicitado, nenhum painel aberto pelo assistente, nenhum ato de cobrança autorizado. Alternativas PG18 repetitivo, mutações Neon ou novo epoch diferidas/bloqueadas.
- BRG-03/06/07/08/09 bloqueados, BRG-04/05 históricos; 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles pendentes. B1R1 EXPIRED_NOT_EXECUTED; `NEW_EPOCH=NOT_AUTHORIZED`; Fase 4 documental NOT_READY, M3 bloqueado, Fase 5 NOT_STARTED.
- Nenhum Neon/SQL/CI/PG18, consulta PubMed/ClinicalTrials ou gasto. CP186 candidato só após Prossiga: obter dados não sensíveis do titular e avaliar lacuna BRG-09; alto apenas antes de decisão substantiva G0. STOP.


### Fase 4 — Observação API Neon Free e lacuna de billing (Documento 142 / CP186)

- Freshness Gate CP185/main `8c8eae2f554a1a050bea5d511c89d49dc47d8c6e` identical, 0 ahead/behind; modo médio. `describe_project` via integração Neon read-only: plano `free_v3`, 1 GiB limite lógico por branch, limite de 10 branches, contadores compute/transferência com contexto limitado. Nenhuma informação sensível publicada.
- BRG-09=PENDING_OWNER_FINANCIAL_CONFIRMATION, G0-D5=PENDING_OWNER; API não comprova cartão, fatura, serviços pagos, custo zero garantido ou cobranças futuras. Próximo ato é resumo manual não sensível pelo titular, sem dados bancários.
- Nenhum SQL/branch/role/migration/CI/PG18, nenhuma query PubMed/ClinicalTrials ou gasto. BRG-03/06/07/08 bloqueados, BRG-04/05 históricos; 36 migrations UNREVIEWED, 0 pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles insatisfeitos. B1R1 EXPIRED_NOT_EXECUTED, NEW_EPOCH NOT_AUTHORIZED, M3 BLOCKED, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.
- CP187 candidato sob novo Prossiga: confrontar somente evidência do titular quando existir; alto antes de autorização de custos/risco. STOP.


### Fase 4 — Declarações financeiras do proprietário reconciliadas (Documento 143 / CP187)

- Freshness Gate CP186/main `3c236159ab6ceb0c7c02f48542688b70f39f8be7` identical, ahead/behind 0; modo médio, registro documental sem operações.
- Respostas do owner: Free=SIM, serviços pagos=NAO, método de pagamento=NAO, alertas de cobrança/cota=NAO; declaração sem horário de inspeção certificado. API Neon CP186 `free_v3` confirma plano, não certifica negativos financeiros. `BRG-09_OWNER_FINANCIAL_DECLARATION=RECEIVED`; `BRG-09_OPERATIONAL_GATE=NOT_APPROVED`; G0-D5 informational complete, decisão pending.
- BRG-03/06/07/08 bloqueados, 04/05 históricos; 36 migrations UNREVIEWED, 0 pós-condições, 36 evidências 034–036 NOT_COLLECTED, 12 controles roles pendentes. B1R1 expirado, novo epoch não autorizado; nenhuma escrita Neon, custo, consulta PubMed/ClinicalTrials, CI ou PG18. M3 blocked, Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.
- CP188 candidato somente com novo Prossiga: consolidar decisão G0, sem repetir perguntas já respondidas. Avisar se alto for necessário para aprovação substantiva. STOP.


### Fase 4 — Consolidação da proposta G0 (Documento 144 / CP188)

- Freshness Gate CP187/main `cea01ebe0aa3fb3721369e1aa80d233d01046e03` identical, 0 ahead/behind; modo médio e documental.
- Documento 144 integra seis pendências G0-D1–D6, informação de Neon Free API e declaração titular de CP187. `G0_OWNER_DECISION=NOT_GRANTED`, `PREPARE_G1_DOCUMENTARY_ONLY=PROPOSED_NOT_AUTHORIZED`; não repetir coleta financeira sem nova justificativa.
- BRG-03/06/07/08 bloqueados; 04/05 históricos; 09 evidência parcial e gate operacional não aprovado. 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles não satisfeitos. B1R1 expirado, novo epoch não autorizado, sem Neon SQL/branch/migrations/roles, CI ou fonte real. M3 BLOCKED; Fase 4 documental NOT_READY; Fase 5 NOT_STARTED.
- CP189 candidato: apresentar deliberação owner objetiva (preparar G1 documental, adiar P-B ou ajustar escopo); alto se decisão de risco/custo/custódia efetiva. STOP.


### Fase 4 — Mandato limitado G1 documental (Documento 145 / CP189)

- Freshness Gate CP188/main `ee1f7c4c98bbdead73452f093e6d0a924aa64f4b` identical 0 ahead/behind, modo médio.
- Proprietário aprovou expressamente `APPROVED — CP189 / PREPARE_G1_DOCUMENTARY_ONLY / OES / zero paid services / no Neon SQL, branches, roles or migrations / no new epoch / no source queries`. Documento 145 formaliza escopo e seis pacotes de planejamento; nenhuma implantação/consulta de fonte/SQL autorizada. G0-D1–D5 ainda pendentes; G0-D6 restrito à preparação documental.
- BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 evidência parcial; 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles não satisfeitas. B1R1 expirado; M3 bloqueado; Fase 4 documental NOT_READY, Fase 5 NOT_STARTED.
- Próximo CP190 candidato inventário G1-MIG **estático**, novo Prossiga obrigatório. STOP.


### Fase 4 — Inventário estático G1-MIG (Documento 146 / CP190)

- Freshness Gate CP189/main `8a799c86caf900bcf9d149620ee19d91de97c37e` identical, ahead/behind 0, modo médio, somente documentação.
- Manifesto 36 entrypoints = catálogo 36 registros UNREVIEWED, zero pós-condições e flags de execução/replay falsas; 031/032/033 incluem 14 SQL subordinados `\\ir`. Documento 146 classifica oito grupos e papel de 033–036. Nenhum subset de instalação ou order de migrations foi aprovado para P-B.
- BRG-03/06/07/08 bloqueados, BRG-04/05 históricos, BRG-09 parcial. 36 evidências 034–036 NOT_COLLECTED e 12 roles insatisfeitos. Nenhum Neon/SQL/CI/PG18, source query ou custo; B1R1 expirado, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED.
- CP191 candidato, somente após Prossiga: closure detalhada dos wrappers e 033–036. STOP.


### Fase 4 — Closure estática de wrappers e camada temporal (Documento 147 / CP191)

- Freshness Gate CP190/main `53cbd7dad1d21594fe66ba60b589f421d4179de9` identical 0 ahead/behind; modo médio. Documento 147: wrappers 031–033 incluem 14 SQL subordinados, objetos de propagation/rebaseline, calibration/cadence/SLA, observation/measurement e hardening 034–036 mapeados; closure de 001–030 não validada.
- Migrações 36 UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 controles roles pendentes; BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. Sem SQL/Neon/PG18/CI, sources reais, custo ou epoch. B1R1 expirado, M3 bloqueado, Fase 4 NOT_READY, Fase 5 NOT_STARTED. CP192 candidato só sob Prossiga. STOP.


### Fase 4 — Dependências prévias parciais G1-MIG (Documento 148 / CP192)

- Freshness Gate CP191/main `9904f4af48dafbc53441c005b4c7531f3ce5e449` identical, 0 ahead/behind, modo médio. Documento 148 identifica produtores 001/002/027/029/030 de objetos usados por 031–036; as migrations 003–026/028 não foram varridas, `monitor_cycle` ainda não tem produtor confirmado. `REDUCED_INSTALLATION_PLAUSIBILITY=UNDETERMINED`.
- 36 migrations UNREVIEWED, 0 pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles insatisfeitas; BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. Sem SQL, Neon, CI, PG18, dados PubMed/ClinicalTrials, custo ou novo epoch. B1R1 EXPIRED_NOT_EXECUTED, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. CP193 candidato só após Prossiga. STOP.


### Fase 4 — Produtores 021–028 e arestas temporais (Documento 149 / CP193)

- Freshness Gate CP192/main `a7ef8c1a2ae1cde8a3280b302850b34ae0471c17` identical, ahead/behind zero; modo médio, análise estática de oito arquivos SQL.
- `monitor_cycle` confirmado como CREATE TABLE em 021; `update_policy`, `update_signal` e `update_decision` produzidos por 027. Necessidade de 022–026/028 para subset P-B ainda indeterminada; closure 003–020 e funções dinâmicas não validada. Documento 149 publicado.
- 36 migrations UNREVIEWED, zero pós-condições, 36 requisitos 034–036 NOT_COLLECTED, 12 roles insatisfeitas; BRG-03/06/07/08 bloqueados, 04/05 históricos, 09 parcial. Sem Neon/SQL/CI/PG18, queries científicas, custo ou epoch. B1R1 EXPIRED_NOT_EXECUTED, M3 BLOCKED, Fase 4 NOT_READY, Fase 5 NOT_STARTED. CP194 candidato só após Prossiga. STOP.
