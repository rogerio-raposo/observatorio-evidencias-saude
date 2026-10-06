# Produtos do OES

Este diretório contém a arquitetura e as especificações dos produtos do Observatório de Evidências em Saúde.

## Arquitetura comum

- [40 — Taxonomia e Arquitetura dos Produtos do OES](40-taxonomia-arquitetura-produtos.md)

## Taxonomia oficial inicial

### Produtos de investigação

- OES — Evidence Scan — N0;
- OES — Resposta de Evidência — N1;
- OES — Ficha de Evidência — N2;
- OES — Síntese Rápida de Evidências — N3;
- OES — Revisão de Evidências — N4.

### Produtos analíticos transversais

- OES — Mapa de Evidências;
- OES — Overview de Revisões.

### Produtos de manutenção

- OES — Monitor de Evidências;
- OES — Alerta de Evidência.

A **Ficha de Evidência** é a unidade persistente central preferencial do OES para perguntas focais reutilizáveis.

Monitor e Alerta pertencem à dimensão de manutenção M0–M3 e não criam novo nível de profundidade.

## Marco concluído — Ficha de Evidência

A trilha inicial da **Ficha de Evidência — N2** foi especificada, implementada e validada com um caso real ponta a ponta. O Caso Real 01 atingiu **A2**, estado `published` e `publishable=true`, preservando disclosure explícito de ausência de revisão especializada independente.

Referência de fechamento: [Documento 67](67-caso-real-01-resultado-validacao-a2-publicacao.md).

## Resposta de Evidência — N1

A trilha inicial da **Resposta de Evidência — N1** foi especificada, implementada e validada ponta a ponta.

Documentos principais:

- [68 — Especificação Científica e Funcional](68-especificacao-resposta-evidencia.md)
- [70 — Contrato de Dados](70-contrato-dados-resposta-evidencia.md)
- [72 — EvidenceResponseView](72-evidence-response-view.md)
- [73 — Especificação do Template Operacional](73-especificacao-template-resposta-evidencia.md)
- [83 — Resultado da Validação A1](83-caso-real-n1-resultado-validacao-a1.md)
- [84 — Aprovação de Governança do Proprietário](84-caso-real-n1-aprovacao-governanca-proprietario.md)
- [85 — Resultado da Validação A2 e Publicação](85-caso-real-n1-resultado-validacao-a2-publicacao.md)

Caso Real N1-01:

- Product `OES-P-2026-000501`;
- assurance **A2**;
- estado `published`;
- `publication_date=2026-10-05`;
- `publishable=true`;
- expert independent review não realizada e explicitamente declarada.

A validação final ocorreu no run **37362554094**, com regressões e rebuild em PASS.

## Evidence Scan — N0

A trilha inicial do **Evidence Scan — N0** foi especificada, implementada e validada ponta a ponta.

Documentos principais:

- [86 — Especificação Científica e Funcional](86-especificacao-evidence-scan.md)
- [88 — Contrato de Dados](88-contrato-dados-evidence-scan.md)
- [90 — Contrato de Renderização](90-evidence-scan-view-contrato-renderizacao.md)
- [91 — Especificação do Template Operacional](91-especificacao-template-evidence-scan.md)
- [92 — Resultado da Validação do Template](92-resultado-validacao-template-evidence-scan.md)
- [97 — Verificação Metodológica Adversarial do Caso Real](97-caso-real-n0-verificacao-metodologica-adversarial.md)
- [98 — Resultado da Validação A1 e Fechamento](98-caso-real-n0-resultado-validacao-a1.md)

Caso Real N0-01:

- Product `OES-P-2026-000601`;
- assurance **A1**;
- estado `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- uso: **artefato interno de roteamento**;
- maturity `partially_synthesized`;
- routing `N2` com reformulação da pergunta.

A validação final ocorreu no run **37382201584**, com RN0-T01–T13, RN0-A1-T01–T08, renderização A0/A1 e rebuild em PASS.

## Síntese Rápida de Evidências — N3

A camada científica, arquitetural, de dados e de apresentação da **Síntese Rápida — N3** foi validada tecnicamente. O primeiro caso real também validou o comportamento de bloqueio metodológico, sem fabricar assurance.

Documentos principais:

- [99 — Especificação Científica e Funcional](99-especificacao-sintese-rapida-n3.md)
- [100 — Revisão de Coerência e Arquitetura](100-sintese-rapida-n3-revisao-coerencia-arquitetura.md)
- [101 — Contrato de Dados](101-contrato-dados-sintese-rapida-n3.md)
- [102 — Resultado da Validação do Contrato](102-resultado-validacao-contrato-sintese-rapida-n3.md)
- [103 — Contrato de Renderização](103-rapid-evidence-synthesis-view-contrato-renderizacao.md)
- [104 — Especificação do Template Operacional](104-especificacao-template-sintese-rapida-n3.md)
- [105 — Resultado da Validação do Template](105-resultado-validacao-template-sintese-rapida-n3.md)
- [111 — Primeira Verificação Metodológica Adversarial do Caso Real](111-caso-real-n3-verificacao-metodologica-adversarial-01.md)
- [113 — Segunda Verificação Metodológica Adversarial](113-caso-real-n3-verificacao-metodologica-adversarial-02.md)
- [114 — Encerramento Experimental do Caso Real](114-caso-real-n3-encerramento-experimental.md)

Caso Real N3-01:

- tema: ambient AI scribes e carga de documentação clínica;
- Product `OES-P-2026-000701`;
- ProductVersion atual = 2;
- assurance **A0**;
- estado `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- primeira adversarial review = **REVISE**;
- segunda adversarial review = **REVISE**;
- bloqueio final: cobertura bibliográfica insuficiente para o padrão N3;
- controles humanos qualificados e A3 ausentes.

O caso demonstrou que technical PASS, appraisal/synthesis completos e uma conclusão cientificamente plausível não autorizam elevação de assurance quando o método de busca não satisfaz o padrão canônico.

Validação final:

- run **37413884319** = success;
- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- rebuild PASS.

Condição de reabertura:

> executar uma segunda base bibliográfica relevante e reproduzível antes de nova tentativa de elevação de assurance.

## Revisão de Evidências — N4

A especificação científica, arquitetura inicial e contrato técnico da **Revisão de Evidências — N4** foram consolidados e validados.

Documentos principais:

- [115 — Especificação Científica e Funcional](115-especificacao-revisao-evidencias-n4.md)
- [116 — Revisão de Coerência e Decisão Arquitetural](116-revisao-evidencias-n4-revisao-coerencia-arquitetura.md)
- [117 — Contrato de Dados](117-contrato-dados-revisao-evidencias-n4.md)
- [118 — Resultado da Validação Técnica](118-resultado-validacao-contrato-revisao-evidencias-n4.md)
- [119 — Contrato de Renderização](119-evidence-review-view-contrato-renderizacao.md)
- [120 — Especificação do Template Operacional](120-especificacao-template-revisao-evidencias-n4.md)
- [121 — Resultado da Validação do Template/Renderização](121-resultado-validacao-template-revisao-evidencias-n4.md)
- [122 — Infrastructure Readiness Gate Pré-Caso Real](122-n4-infrastructure-readiness-gate-pre-caso-real.md)

Implementação:

- migration 015;
- `investigation.reviewer_assignment`;
- EvidenceReviewView `oes.evidence_review_view/0.1`;
- Infrastructure Readiness Gate;
- publication gate N4;
- suporte a ROB-ME em nível de Synthesis;
- fixture formal sintética A3;
- template Markdown/presentation map/renderer/validator;
- disclosure `audit.synthetic_fixture`;
- ER4-T01–T27 PASS;
- F3-ER4-TEMPLATE PASS;
- rebuild PASS.

A validação do contrato ocorreu no run **37417796591**, com artifact **11391167525** e digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

A validação da apresentação ocorreu no run **37418624629**, com artifact **11391724857** e digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`.

Limite operacional:

> **nenhum Caso Real N4 formal está autorizado na configuração humana/infrastrutural atual.**

O PASS é técnico/arquitetural e utiliza atores humanos explicitamente sintéticos para provar o contrato.

Infrastructure Readiness Gate real:

- resultado agregado **NOT_READY**;
- cobertura bibliográfica = not_ready;
- equipe metodológica = not_ready;
- governança/A3 = not_ready;
- nenhuma Investigation N4 real foi aberta;
- nenhum Caso Real N4 formal foi iniciado.

## Mapa de Evidências

A especificação científica, a decisão arquitetural, o contrato de dados v0.1 e a implementação técnica inicial do **Mapa de Evidências** foram consolidados e validados.

Documentos principais:

- [123 — Especificação Científica e Funcional](123-especificacao-mapa-evidencias.md)
- [124 — Revisão de Coerência e Decisão Arquitetural Inicial](124-mapa-evidencias-revisao-coerencia-arquitetura.md)
- [125 — Contrato de Dados](125-contrato-dados-mapa-evidencias.md)
- [126 — Resultado da Validação Técnica](126-resultado-validacao-contrato-mapa-evidencias.md)
- [127 — EvidenceMapView: Contrato de Renderização](127-evidence-map-view-contrato-renderizacao.md)
- [128 — Resultado da Validação do Projection Readiness](128-resultado-validacao-evidence-map-view-readiness.md)
- [129 — Especificação do Template Operacional](129-especificacao-template-mapa-evidencias.md)
- [130 — Resultado da Validação do Template/Renderização](130-resultado-validacao-template-mapa-evidencias.md)
- [131 — Readiness Gate Pré-Caso Real](131-mapa-evidencias-readiness-gate-pre-caso-real.md)
- [132 — MAP-01: Protocolo](132-caso-real-map01-ambient-ai-scribes-protocolo.md)
- [133 — MAP-01: Inventário do Corpus e MapItems](133-caso-real-map01-inventario-corpus-mapitems.md)
- [134 — MAP-01: Codebook v0.1](134-caso-real-map01-codebook-v01.md)
- [135 — MAP-01: Correção Arquitetural de Source Corpus](135-map01-correcao-arquitetural-source-corpus.md)
- [136 — Resultado da Validação de Source Corpus](136-resultado-validacao-source-corpus-mapa.md)
- [137 — MAP-01: Resultado e Encerramento](137-caso-real-map01-resultado-encerramento.md)

Implementação validada:

- migration 016;
- schema `mapping`;
- sete estruturas especializadas;
- `mapping.evidence_map_cells()`;
- publication gate do Mapa;
- EvidenceMapView `oes.evidence_map_view/0.1`;
- fixture formal sintética A3;
- EM-T01–T22 PASS;
- rebuild through migration 016 PASS;
- regressões N0–N4 PASS.

Validação:

- run **37464023391** = success;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`;
- artifact **11413512318**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

Limite:

> **o PASS é técnico e sintético; nenhum Caso Real do Mapa foi iniciado e nenhum formal gap claim real foi autorizado.**

## Próxima etapa

**Caso Real MAP-01 — ambient AI scribes: mapa exploratório do corpus N3-01.**

O Documento 131 concluiu:

- rota exploratória/structured non-exhaustive = **READY_WITH_DOCUMENTED_CONDITIONS**;
- rota formal systematic map/EGM = **NOT_READY**.

Fica autorizado apenas o MAP-01 interno A1, com `descriptive_mapping_review + structured_non_exhaustive + apparent_only`, reutilizando o corpus N3-01 sem reabrir ou elevar a assurance do produto N3.

Pré-persistência concluída:

- protocolo MAP-01;
- inventário formal = 17 MapItems;
- codebook v0.1;
- decisão arquitetural inicial de reutilizar a InvestigationVersion N3-01 como primary foi **superada** pelo Documento 135;
- MAP-01 terá Question/Investigation próprias;
- N3-01 será ligada como `source_corpus`;
- Search/Screening não serão duplicados.

Migration 018 validada em PASS no Documento 136.

O Documento 137 encerrou o MAP-01 como **A1 interno / não publicável**, após persistência real, verificação metodológica por IA, renderização e rebuild em PASS.

Próximo passo naquele marco histórico: iniciar a **Especificação Científica e Funcional do Overview de Revisões**.

Essa etapa foi posteriormente concluída nos Documentos 138–140; a próxima etapa vigente é a **migration 019**.

O N4 e a rota formal do Mapa permanecem deferidos até mudança real das condições de readiness.


## Overview de Revisões

- [138 — Especificação Científica e Funcional](138-especificacao-overview-revisoes.md)
- [139 — Revisão de Coerência e Decisão Arquitetural](139-overview-revisoes-revisao-coerencia-arquitetura.md)
- [140 — Contrato de Dados v0.1](140-contrato-dados-overview-revisoes.md)
- [141 — Resultado da Validação Técnica do Contrato](141-resultado-validacao-contrato-overview-revisoes.md)
- [142 — Contrato de Renderização e Projection Readiness](142-overview-view-contrato-renderizacao.md)
- [143 — Resultado do Projection Readiness Gate](143-resultado-projection-readiness-overview-revisoes.md)
- [144 — Especificação do Template Operacional](144-especificacao-template-overview-revisoes.md)
- [145 — Resultado da Validação do Template Operacional](145-resultado-validacao-template-overview-revisoes.md)
- [146 — Readiness Gate Pré-Caso Real](146-overview-readiness-gate-pre-caso-real.md)
- [147 — Qualificação do Corpus Candidato OVR-01 / N3-01](147-qualificacao-corpus-candidato-ovr01-n3.md)
- [148 — Qualificação do Corpus Candidato OVR-01 / dCBT-I](148-qualificacao-corpus-candidato-ovr01-dcbti.md)
- [149 — Protocolo Developmental OVR-01 / dCBT-I](149-protocolo-developmental-ovr01-dcbti.md)

### Estado

- unidade principal = systematic review;
- v0.1 formal limitado a reviews quantitativas de intervenções;
- ROBIS como default de risk of bias da review;
- overlap deve ser representado em nível de Study;
- CCA e métricas de overlap serão derivadas;
- double counting é proibido;
- supplemental primary studies ficam fora do corpus analítico formal v0.1;
- formal Overview exige A3 + controles humanos qualificados.

### Arquitetura

- OES-P1 reutiliza Study/StudyVersion para systematic reviews;
- Reports/updates usam StudyReportLink + ReportRelation;
- Results, ROBIS, Synthesis, Certainty, Search/Screening e assurance permanecem canônicos;
- schema especializado `overview` terá sete estruturas para corpus, membership, overlap e concordância;
- CCA/pairwise overlap permanecem derivados;
- formal Overview = Investigation depth N4 + A3 + qualified human controls;
- nenhum template antes de PASS técnico do contrato/view.

### Estado técnico

O Documento 141 registra:

- migration 019 = PASS;
- fixture formal sintética A3 = PASS;
- CCA esperado 0,4 = PASS;
- OV-T01–T33 = PASS;
- `OverviewOfReviewsView` = PASS;
- rebuild/regressões = PASS;
- run **37502184404** = success;
- artifact **11430003081**;
- digest `sha256:94759585098f90d0227a3d4435056807c18e72af1e01a558e7a5dad3267afee3`.

### Projection Readiness

O Documento 142 identificou lacunas auditáveis na projeção inicial. A migration 020 as resolveu de forma aditiva e o Documento 143 registra:

> **Projection Readiness Gate = READY para especificação do template operacional.**

Validação:

- OVR-T01–T12 = PASS;
- migration 020 idempotente = PASS;
- rebuild/regressões = PASS;
- run **37503751486** = success;
- artifact **11430083884**;
- digest `sha256:f599426adb3afd5cc28066c00eb0de73c6d18dd734f622d58e9f0f5f9be418a5`.

### Template Operacional

O Documento 144 definiu a especificação e o Documento 145 registra:

> **Camada de apresentação do Overview v0.1 = PASS.**

Validação:

- template + presentation map + renderer + validator = PASS;
- cenários adversariais = PASS;
- run **37506526884** = success;
- artifact **11431539311**;
- digest `sha256:4ddfff2d14f9b8892611199cdade932f7825d2615f76610518a63499c2a58770`.

### Readiness pré-caso real

O Documento 146 concluiu:

- rota developmental interna A0/A1 = **READY_WITH_DOCUMENTED_CONDITIONS**;
- rota formal publicável A3 = **NOT_READY**;
- nenhum OVR-01 está autorizado ainda;
- o corpus candidato deve ser qualificado antes de criar Product/Investigation.

### Qualificação do primeiro corpus candidato

O Documento 147 concluiu:

> **subconjunto secundário do N3-01 = UNSUITABLE para OVR-01.**

Motivo determinante: apenas uma systematic review inequivocamente elegível sob o contrato v0.1; a segunda candidata é uma rapid review e não deve ser reclassificada artificialmente.

Nenhum Product/Investigation OVR-01 foi criado e o N3-01 permanece inalterado.

### Segundo corpus candidato

O Documento 148 concluiu:

> **dCBT-I totalmente automatizada = SUITABLE_WITH_CONDITIONS para OVR-01 developmental.**

O corpus já possui duas systematic reviews como Study/StudyVersion, Reports, ResultVersions e Syntheses externas distintas.

Condições obrigatórias antes da persistência de ReviewItems/membership:

- study list de Gao;
- last-search date de Gao;
- reconciliação de Study identities Hwang × Gao;
- inventário de membership/overlap;
- escopo/comparador do cluster;
- decisão prospectiva sobre terceira review;
- ROBIS de Gao;
- nenhuma nova meta-analysis.

### Protocolo developmental OVR-01

O Documento 149 definiu:

- pergunta review-level própria;
- eligibility de Reviews;
- discovery não exaustivo anti-cherry-picking;
- currentness;
- membership/overlap;
- famílias de comparadores;
- estratégia inicial `include_all_separate_estimates`;
- ROBIS/OutcomeEvidence/certainty;
- política prospectiva para Nazari;
- C1–C12 como condições pré-persistência.

### Fechamento C1–C4

O Documento 150 registra:

- C1 — Gao study list = **PASS**;
- C2 — Gao last-search date = **BLOCKED / NOT_VERIFIED**;
- C3 — Nazari screening = **PASS / ELIGIBLE**;
- C4 — inventário definitivo = **PASS**;
- corpus analítico v1 = Hwang 2025 + Gao 2026 + Nazari 2025;
- nenhum OVR-01 real criado.

### C5–C6 preparatórios

Os Documentos 151–152 estabeleceram:

- unidade de overlap = primary Study/trial, não Report;
- codebook de merge/split/aliases;
- GoodNight = uma Study com múltiplos Reports;
- Eigl 2023 e Hinterberger 2024 = **Studies distintas**; hipótese de same Study superseded;
- Lorenz 2018/2019, Glozier 2018/2019, Hagatun 2017/2019 e Maurer 2024/2025 = aliases bibliográficos resolvidos;
- matriz preliminar Hwang × Gao × Nazari;
- overlaps triplos confirmados e prováveis;
- CCA permanece proibido até a matriz completa.

Estado:

- C2 = **BLOCKED / NOT_VERIFIED**;
- C5 = **IN_PROGRESS**;
- C6 = **IN_PROGRESS**.

### Próxima etapa

**Resolver aliases/multiple Reports e expandir a matriz até Study-level completeness suficiente para fechar C5–C6; depois classificar C7/C8.**


### Listas completas Hwang/Nazari

O Documento 154 registra:

- Hwang = 29 artigos;
- GoodNight colapsa três Reports em uma Study;
- Hwang = 27 Study candidates provisórios;
- Nazari = 49 linhas de artigo;
- cinco multiple-report clusters confirmados em Nazari;
- Nazari = máximo provisório de 44 Study candidates após esses clusters;
- pelo menos 17 overlaps Study-level Hwang × Nazari confirmados;
- Chan 2023 (Hwang) e Chan 2024 (Nazari) = Studies distintas.

C5/C6 permanecem em progresso; CCA continua bloqueado.


### Fechamento C5–C6

O Documento 155 registra:

- Hwang = 27 Study candidates;
- Gao = 15;
- Nazari = 44;
- união = 59;
- occurrences = 86;
- C5 = **PASS_WITH_DOCUMENTED_UNCERTAINTY**;
- C6 = **PASS**;
- CCA não calculado;
- C2 continua bloqueado.

Próxima etapa: classificar C7 membership completeness e C8/CCA readiness sem persistir entidades reais.
