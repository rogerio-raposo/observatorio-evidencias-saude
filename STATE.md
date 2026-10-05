# STATE — Estado Atual do Projeto OES

**Última atualização:** 5 de outubro de 2026  
**Fase atual:** Fase 3 — Produtos do Observatório  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP34 — 2026-10-05**.

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

Documentos 99–102:

- 99 — especificação científica e funcional;
- 100 — revisão de coerência e decisão arquitetural;
- 101 — contrato de dados;
- 102 — resultado da validação técnica: **PASS**.

Implementação validada:

- migration 014;
- `investigation.method_decision`;
- `investigation.quality_control_record`;
- RapidEvidenceSynthesisView `oes.rapid_evidence_synthesis_view/0.1`;
- publication gate N3;
- fixture experimental;
- RS-T01–T15 PASS;
- F3-RS-T16 duplicate migration detection PASS;
- rebuild through migration 014 PASS.

Governança validada:

- N3 formal exige A3;
- A3 não substitui controles qualificados de etapa;
- controles por IA são transparentes, mas não satisfazem human-qualified controls;
- fixture A2 estruturalmente completa permanece `publishable=false`;
- RS-T11 demonstra que gate abre somente com qualified human controls + A3;
- configuração atual do OES permite desenvolvimento/validação N3, mas não publicação formal.

Run final:

- **37384225722** = **success**;
- commit validado `44d50afa11d385ef26f56f860676859fb40d4f3c`;
- artifact **11375884187**;
- digest `sha256:1d880f2490142ba5fb4c0a815741a7aee01f74bb06b0b969fb352d6883443e78`.

Taxonomia restante da Fase 3:

- Revisão de Evidências — N4;
- Mapa de Evidências;
- Overview de Revisões;
- Monitor de Evidências;
- Alerta de Evidência.

## 9. Próxima etapa

**Síntese Rápida de Evidências — N3: contrato de renderização.**

Definir estrutura de apresentação, rapid restrictions, protocol deviations, quality controls, missing controls, Synthesis/Certainty, assurance e o estado experimental bloqueado antes de criar o template operacional.

## 10. Checkpoint vigente

**CP34 — 2026-10-05**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-05_CP34.md`

Ponto exato de retomada:

> **Fase 3 — formalizar o contrato de renderização da Síntese Rápida de Evidências — N3.**
