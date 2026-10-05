# STATE — Estado Atual do Projeto OES

**Última atualização:** 4 de outubro de 2026  
**Fase atual:** Fase 3 — Produtos do Observatório  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP30 — 2026-10-05**.

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

Documento 04 — **Governança de Garantia Metodológica, Aprovação e Revisão**: vigente como regra transversal A0–A3 para distinguir verificação por IA, aprovação do proprietário e revisão especializada independente.

Documento 40 — **Taxonomia e Arquitetura dos Produtos do OES** consolidado como base inicial.

Documento 41 — **Especificação Científica e Funcional da Ficha de Evidência** consolidado.

Documento 42 — **Contrato de Dados da Ficha de Evidência** consolidado.

Documento 43 — **Resultado da Validação do Contrato da Ficha**: PASS.

Documento 44 — **EvidenceSheetView: Contrato de Renderização da Ficha** consolidado.

Documento 45 — **Resultado da Validação do EvidenceSheetView**: PASS.

Documento 46 — **Especificação do Template Operacional da Ficha de Evidência** consolidado.

Documento 47 — **Resultado da Validação do Template Operacional da Ficha**: PASS estrutural/operacional.

Template `oes.evidence_sheet.template/0.2` validado contra `oes.evidence_sheet_view/0.1`, com disclosure de assurance A0–A3.

Documento 48 — protocolo do Caso Real 01.

Documentos 49–54 — busca, ROBIS, RoB 2, síntese atualizada, GRADE provisório e draft científico concluídos.

Documento 55 — representação canônica de síntese externa adotada + atualização OES.

Documento 56 — reconciliação de continuidade/hardening.

Documento 57 — validação da reconciliação: PASS.

Documento 58 — **Resultado da Validação Ponta a Ponta do Caso Real 01**: PASS em pré-publicação.

Documento 59 — **Pacote de Revisão Especializada Independente do Caso Real 01**: preservado; expert review não realizado.

Documento 60 — **Validação Técnica do antigo Gate de Revisão Humana**: permanece como evidência histórica; HRG-T01–T06 PASS.

Documento 61 — **Redesenho do Modelo de Garantia e Aprovação**: aplicado ao Caso Real 01.

Documento 62 — **Validação Técnica do Modelo A0–A3**: PASS.

Documento 63 — **Primeira Verificação Metodológica Adversarial**: REVISE; identificou e corrigiu premissa incorreta sobre Hwang/Somzz.

Documento 64 — **Segunda Verificação Metodológica Adversarial**: PASSED.

Documento 65 — **Resultado da Validação do Estado A1**: PASS; verificação metodológica adversarial ativa em `passed`.

Documento 66 — **Aprovação de Governança do Proprietário**: **APPROVED**; owner governance approval explicitamente registrada.

Documento 67 — **Resultado da Validação A2 e Publicação**: **PASS**; run 37229070210.

Documento 68 — **Especificação Científica e Funcional da Resposta de Evidência**: consolidado.

Documento 69 — **Resposta de Evidência N1: Revisão de Coerência e Decisão Arquitetural Inicial**: consolidado.

Documento 70 — **Contrato de Dados da Resposta de Evidência — N1**: consolidado.

Documento 71 — **Resultado da Validação do Contrato da Resposta de Evidência — N1**: **PASS**; run 37356428107.

Documento 72 — **EvidenceResponseView**: contrato de renderização N1 formalizado.

Documento 73 — **Especificação do Template Operacional da Resposta de Evidência — N1**: consolidado.

Documento 74 — **Resultado da Validação do Template Operacional da Resposta de Evidência — N1**: **PASS**; run 37357423887.

Template `oes.evidence_response.template/0.1` validado contra `oes.evidence_response_view/0.1`, incluindo estado A2/publicável e comportamento preview/não publicável.

Migration 012 — **Evidence Response N1 contract**: PASS. Nenhuma nova tabela ou coluna; funções/projeções específicas N1 sobre OES-P1.

Resposta de Evidência N1 validada com fixture sem Synthesis link e sem Certainty link obrigatórios; provenance direta ProductVersion → ReportVersion, assurance A2, publication gate próprio e `EvidenceResponseView` candidata em PASS técnico. ER-T01–T14 PASS; regressões N2 preservadas.

Migrations canônicas da camada da Ficha: 007 EvidenceSheetView → 008 provenance → 009 study-type counts → 010 assurance governance → 011 assurance-aware view.

Caso Real 01 materializado como Ficha `published`, assurance **A2**, `publication_date=2026-10-04`, `publishable=true`; ausência de expert review preservada como warning explícito; RC01-T01–T10, AG-T01–T07 e AV-T01–T02 PASS.

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

**Caso Real N1 — validação ponta a ponta da Resposta de Evidência.**

A trilha técnica N1 está completa: especificação, contrato de dados, publication gate, EvidenceResponseView, template, renderer e validator passaram tecnicamente.

A próxima etapa deverá selecionar uma pergunta focal de criticidade compatível com N1, executar busca estruturada seletiva em fontes reais, realizar appraisal proporcional, construir provenance real e validar a saída pelo template N1 antes de qualquer owner governance approval.

## 10. Checkpoint vigente

**CP28 — 2026-10-04**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-05_CP30.md`

Ponto exato de retomada:

**Fase 3 — Caso Real N1: seleção, busca, appraisal proporcional e validação ponta a ponta.**
