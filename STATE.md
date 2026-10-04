# STATE — Estado Atual do Projeto OES

**Última atualização:** 4 de outubro de 2026  
**Fase atual:** Fase 3 — Produtos do Observatório  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP23 — 2026-10-04**.

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

Documento 40 — **Taxonomia e Arquitetura dos Produtos do OES** consolidado como base inicial.

Documento 41 — **Especificação Científica e Funcional da Ficha de Evidência** consolidado.

Documento 42 — **Contrato de Dados da Ficha de Evidência** consolidado.

Documento 43 — **Resultado da Validação do Contrato da Ficha**: PASS.

Documento 44 — **EvidenceSheetView: Contrato de Renderização da Ficha** consolidado.

Documento 45 — **Resultado da Validação do EvidenceSheetView**: PASS.

Documento 46 — **Especificação do Template Operacional da Ficha de Evidência** consolidado.

Documento 47 — **Resultado da Validação do Template Operacional da Ficha**: PASS estrutural/operacional.

Template `oes.evidence_sheet.template/0.1` validado contra `oes.evidence_sheet_view/0.1`.

Documento 48 — protocolo do Caso Real 01.

Documentos 49–54 — busca, ROBIS, RoB 2, síntese atualizada, GRADE provisório e draft científico concluídos.

Documento 55 — representação canônica de síntese externa adotada + atualização OES.

Documento 56 — reconciliação de continuidade/hardening.

Documento 57 — validação da reconciliação: PASS.

Documento 58 — **Resultado da Validação Ponta a Ponta do Caso Real 01**: PASS em pré-publicação.

Migrations canônicas da camada de renderização: 007 → 008 provenance → 009 study-type counts.

Caso Real 01 materializado no baseline como Ficha `under_review`; RC01-T01–T10 PASS; preview Markdown validado; publication gate bloqueado como esperado.

Taxonomia:

- Evidence Scan;
- Resposta de Evidência;
- Ficha de Evidência;
- Síntese Rápida;
- Revisão de Evidências;
- Mapa de Evidências;
- Overview de Revisões;
- Monitor de Evidências;
- Alerta de Evidência.

A **Ficha de Evidência** é a unidade persistente central preferencial para perguntas focais reutilizáveis.

## 9. Próxima etapa

**Gate de Revisão Humana do Caso Real 01.**

Objetivos:

- preparar pacote de revisão dos julgamentos materiais;
- revisar ROBIS;
- revisar RoB 2;
- revisar GRADE provisório;
- revisar interpretação da heterogeneidade;
- revisar conclusão;
- revisar aplicabilidade ao Brasil;
- revisar linguagem de segurança;
- revisar clareza do preview;
- registrar decisão humana somente após revisão real.

Até lá, a Ficha permanece `under_review` e `publishable=false`.

## 10. Checkpoint vigente

**CP23 — 2026-10-04**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-04_CP23.md`

Ponto exato de retomada:

**Fase 3 — Gate de Revisão Humana do Caso Real 01.**
