# 36 — Plano e Desenho da PoC-S5: Métodos Especializados Mínimos

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Plano de prova arquitetural — pré-implementação  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 15, 21, 25, 33 e 35  
**Critérios-alvo do Documento 25:** 8, 9, 10 e remanescente do 15

## 1. Finalidade

Validar que o candidato físico OES-P1 representa adequadamente os métodos especializados explicitamente previstos no Modelo Lógico:

- Network Meta-Analysis;
- modelos de predição;
- síntese qualitativa com GRADE-CERQual.

A PoC-S5 testa estrutura, identidade, versionamento, proveniência, integridade e lineage.

Não implementa motores estatísticos ou analíticos completos.

## 2. Princípio de escopo

Somente serão criados objetos já previstos no Modelo Lógico ou dependências físicas indispensáveis para representá-los corretamente.

### Dependências mínimas adicionais

NMA exige:

- StudyGroup;
- mapeamento StudyGroup → SynthesisNode;
- contraste entre nós;
- Result com referência estruturada aos grupos comparados.

PredictionModel exige:

- identidade/versionamento do modelo;
- papéis dos Studies;
- Result explicitamente associado ao modelo.

CERQual exige:

- ReviewFinding;
- FindingContribution;
- CertaintyAssessment vinculado ao ReviewFinding.

## 3. Migration proposta

Criar:

`database/005_poc_s5_specialized_methods.sql`

### 3.1 StudyGroup

- `evidence.study_group`;
- `evidence.study_group_version`;
- `evidence.group_component`.

ResultVersion receberá:

- `group_a_entity_uuid`;
- `group_b_entity_uuid`.

Invariant:

> grupos referenciados por um Result devem pertencer ao mesmo Study do Result.

### 3.2 NMA

Criar:

- `synthesis.node`;
- `synthesis.node_version`;
- `synthesis.node_mapping`;
- `synthesis.contrast`.

Invariant:

> os dois nós de um Contrast devem pertencer à mesma Synthesis da versão do contraste.

### 3.3 PredictionModel

Criar:

- `evidence.prediction_model`;
- `evidence.prediction_model_version`;
- `evidence.prediction_model_identifier`;
- `evidence.prediction_model_study_role`.

Adicionar a `evidence.result`:

- `prediction_model_entity_uuid`.

Papéis permitidos na PoC:

- development;
- internal_validation;
- external_validation;
- updating;
- impact_evaluation.

### 3.4 Qualitativa / CERQual

Criar:

- `synthesis.review_finding`;
- `synthesis.review_finding_version`;
- `synthesis.finding_contribution`.

Adicionar a `appraisal.certainty_assessment_version`:

- `review_finding_version_uuid`.

Invariant:

> framework CERQual exige ReviewFinding explícito.

## 4. S5-A — cenário NMA

Criar rede mínima conectada de três nós:

- Treatment A;
- Control;
- Treatment B.

Dois Studies fornecerão comparações diretas:

- Study A: Treatment A vs Control;
- Study B: Treatment A vs Treatment B.

A estrutura deverá demonstrar:

- quatro StudyGroups;
- três SynthesisNodes;
- quatro NodeMappings;
- três Contrasts, incluindo contraste indireto B vs Control;
- dois Results contribuindo à NMA;
- lineage Report → Result → NMA Synthesis → Certainty → Product.

O objetivo não é recalcular uma NMA real; `result_summary` poderá conter valores de fixture explicitamente identificados como dados de validação estrutural.

## 5. S5-B — cenário PredictionModel

Criar:

- um Study de desenvolvimento;
- um Study de validação externa;
- um PredictionModel;
- versão inicial e versão atualizada do modelo;
- identificador do modelo;
- papéis development e external_validation;
- Results de performance vinculados ao modelo;
- Synthesis de performance;
- Certainty/Confidence record;
- Product.

Lineage:

`Report → Result de performance → Synthesis → Certainty → Product`

## 6. S5-C — cenário qualitativo/CERQual

Criar:

- dois Studies qualitativos;
- dois Reports;
- uma Synthesis qualitativa;
- um ReviewFinding;
- duas FindingContributions;
- CertaintyAssessment com `framework='GRADE-CERQual'`;
- quatro domínios:
  - methodological_limitations;
  - coherence;
  - adequacy;
  - relevance;
- Product.

Lineage:

`Report → ReviewFinding → CERQual → Product`

## 7. Testes

### S5-T01 — instalação

Migration 005 aplica após baseline + 002 + 003 + 004.

### S5-T02 — integridade StudyGroup/Result

Results NMA aceitam grupos do próprio Study.

### S5-T03 — rejeição de grupo cruzado

Result não pode referenciar StudyGroup de outro Study.

### S5-T04 — estrutura NMA

Rede deve conter pelo menos:

- 3 Nodes;
- 4 mappings;
- 3 Contrasts;
- 2 Studies contribuintes.

### S5-T05 — integridade Contrast

Contrast com Node de outra Synthesis deve ser rejeitado.

### S5-T06 — lineage NMA

Report deve alcançar Product NMA via dependency graph.

### S5-T07 — versionamento PredictionModel

Modelo deve preservar v1 superseded + v2 current.

### S5-T08 — papéis de PredictionModel

Devem coexistir development e external_validation.

### S5-T09 — Results de performance

Pelo menos dois Studies devem produzir Results vinculados ao mesmo PredictionModel.

### S5-T10 — lineage PredictionModel

Report de validação deve alcançar Product de predição.

### S5-T11 — CERQual sem ReviewFinding

Inserção deve falhar.

### S5-T12 — FindingContribution

ReviewFinding deve receber contribuição de dois Studies.

### S5-T13 — componentes CERQual

Certainty deve registrar os quatro componentes e confiança final.

### S5-T14 — lineage qualitativo

Report qualitativo deve alcançar Product CERQual.

### S5-T15 — cobertura especializada consolidada

Products das três trilhas devem existir e ser reconstruíveis.

### S5-T16 — rebuild do zero

Baseline + migrations + fixtures devem reproduzir todo o estado S5.

### S5-T17 — reaplicação de migration

Migration 005 duplicada deve falhar de forma detectável.

## 8. Critério de PASS

PoC-S5 = PASS somente se S5-T01–T17 passarem e:

- nenhuma invariant anterior for relaxada;
- F2-B e S4 continuarem verdes em regressão;
- lineage funcionar nas três trilhas;
- rebuild completo passar.

## 9. Consequência esperada

Se PASS:

- critério 8 — NMA → VALIDADO;
- critério 9 — predição → VALIDADO;
- critério 10 — qualitativa/CERQual → VALIDADO;
- critério 15 — lineage completo → VALIDADO.

A matriz poderá alcançar:

> **15 VALIDADO / 0 PARCIAL / 0 NÃO VALIDADO**

Nesse caso será autorizada uma decisão explícita sobre promoção de OES-P1 a **baseline arquitetural da Fase 2**, ainda separada de escolha de stack de produção.

---

**Próxima ação:** implementar migration 005 e a bateria S5 sem ampliar o escopo além deste documento.
