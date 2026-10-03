# 22 — Validação Arquitetural por Casos de Uso

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — primeira bateria de validação  
**Data:** 3 de outubro de 2026  
**Base validada:** Documentos 20 e 21

## 1. Finalidade

Testar o modelo conceitual e lógico do OES contra cenários metodologicamente representativos antes de qualquer desenho físico ou escolha de tecnologia.

Critérios de avaliação:

- identidade correta das entidades;
- cardinalidade;
- proveniência;
- versionamento;
- deduplicação;
- atualização;
- suporte a métodos especializados;
- ausência de perda de informação metodológica.

Classificação dos achados:

- **PASS:** modelo representa o cenário sem alteração estrutural;
- **PASS WITH REFINEMENT:** cenário é representável, mas exige refinamento explícito;
- **FAIL:** estrutura atual é insuficiente e exige nova entidade/relação.

---

# CASO 1 — ENSAIO RANDOMIZADO COM PROTOCOLO, ARTIGO PRINCIPAL E FOLLOW-UP

## Cenário

Um único ensaio possui:

- registro prospectivo;
- protocolo publicado;
- artigo principal;
- follow-up de longo prazo;
- múltiplos outcomes e timepoints.

## Teste

Representação:

`Study → StudyIdentifier + múltiplos Reports → múltiplos Results`

Proveniência:

`ResultSource` diferencia artigo principal e follow-up.

## Resultado

**PASS**

O modelo suporta o cenário.

---

# CASO 2 — UM REPORT DESCREVE DOIS STUDIES

## Cenário

Uma publicação apresenta resultados de dois estudos independentes.

## Teste

A relação N:M via `StudyReportLink` representa corretamente:

`Study A ↔ Report X ↔ Study B`

## Achado

O modelo conceitual corrigido já suporta a identidade, mas `ScreeningDecision` estava restrito a Report.

Após desambiguação, elegibilidade pode diferir por Study.

## Resultado

**PASS WITH REFINEMENT**

### Correção necessária

Generalizar `ScreeningDecision` para target:

- Report;
- Study.

Alternativamente, separar `EligibilityDecision`.

Decisão adotada: **target tipado em ScreeningDecision**, preservando estágio e motivo.

---

# CASO 3 — COORTE COM MÚLTIPLOS OUTCOMES E TIMEPOINTS

## Cenário

Uma coorte reporta mortalidade, hospitalização e qualidade de vida em 30 dias, 6 meses e 1 ano.

## Teste

`Outcome + OutcomeOperationalization + Result`

permite múltiplas combinações.

## Resultado

**PASS**

Requisito adicional:

- Result deve possuir timepoint estruturado, não apenas texto livre.

---

# CASO 4 — REVISÃO SISTEMÁTICA USADA COMO UNIDADE DE EVIDÊNCIA

## Cenário

Uma Resposta de Evidência N1/N2 adota criticamente uma revisão sistemática recente.

## Teste

A revisão pode ser representada como:

- Study com `study_type = systematic_review`;
- um ou mais Reports;
- pooled estimates como Results;
- ROBIS como RiskAssessment;
- eventual Synthesis OES classificada como adoção/integração de síntese externa.

## Resultado

**PASS WITH REFINEMENT**

Adicionar a Synthesis:

- `synthesis_origin`: de novo cálculo / adopted_external / updated_external / narrative;
- `source_study_id`, quando uma síntese externa é adotada.

---

# CASO 5 — NETWORK META-ANALYSIS

## Cenário

Estudos com múltiplos braços alimentam uma rede A–B–C–D.

## Teste

`Result.group_a/group_b` em texto livre não é suficiente.

A rede exige:

- braços/grupos estruturados;
- mapeamento dos braços para nós da rede;
- contrastes da síntese.

## Resultado

**FAIL**

### Correções necessárias

Criar:

- `StudyGroup`;
- `GroupComponent`;
- `SynthesisNode`;
- `SynthesisContrast`.

Result deverá referenciar IDs de grupos quando aplicável.

---

# CASO 6 — ACURÁCIA DIAGNÓSTICA

## Cenário

Estudo avalia teste índice em diferentes thresholds contra padrão de referência.

## Teste

Result genérico pode armazenar sensibilidade/especificidade, mas não representa de forma robusta:

- TP;
- FP;
- FN;
- TN;
- threshold;
- index test;
- reference standard.

## Resultado

**PASS WITH REFINEMENT**

### Correção necessária

Criar extensão:

`DiagnosticResultDetail`

vinculada a Result.

---

# CASO 7 — MODELO DE PREDIÇÃO COM DESENVOLVIMENTO E VALIDAÇÃO EXTERNA

## Cenário

Um modelo é desenvolvido em Study A e validado externamente em Studies B, C e D.

## Teste

Representar o modelo apenas como texto em Result causa duplicação e impede identidade persistente do modelo.

## Resultado

**FAIL**

### Correções necessárias

Criar:

- `PredictionModel`;
- `PredictionModelIdentifier`, quando houver;
- vínculo `Result.prediction_model_id`;
- papel do estudo: development/internal_validation/external_validation/impact.

---

# CASO 8 — SÍNTESE QUALITATIVA + CERQual

## Cenário

Vários estudos qualitativos sustentam Review Finding.

## Teste

`ReviewFinding` existe, mas falta relação explícita entre achado e estudos/reports contribuintes.

## Resultado

**PASS WITH REFINEMENT**

### Correção necessária

Criar:

`FindingContribution`

com Study/Report, papel, adequacy/relevance notes quando necessário.

---

# CASO 9 — ATUALIZAÇÃO DE FICHA DE EVIDÊNCIA

## Cenário

Ficha v1 utiliza evidência até janeiro; nova evidência em junho altera magnitude e certeza.

## Teste

Product possui ID estável + versionamento + relações com Investigation/Synthesis/Certainty.

## Resultado

**PASS**

Requisito:

- versão da Ficha deve apontar explicitamente para as versões vigentes de Synthesis e Certainty usadas.

---

# CASO 10 — GUIDELINE OU HTA SEM STUDY DIRETO

## Cenário

Documento de guideline/HTA é usado como fonte contextual ou comparativa.

## Teste

Report pode existir sem StudyReportLink.

RiskAssessment pode usar target_type Report.

## Resultado

**PASS**

Requisito:

- `report_type` deve incluir guideline, HTA e regulatory_document.

---

# CASO 11 — CORREÇÃO, RETRAÇÃO E EXPRESSÃO DE PREOCUPAÇÃO

## Cenário

Artigo recebe correção; posteriormente é retratado.

## Teste

Status/versionamento de Report isolado não representa adequadamente a relação documental.

## Resultado

**PASS WITH REFINEMENT**

### Correção necessária

Criar:

`ReportRelation`

com tipos:

- correction_of;
- retraction_of;
- expression_of_concern_for;
- update_of;
- supplement_to.

Mudanças devem disparar avaliação de impacto em Results/Syntheses/Products.

---

# CASO 12 — NOVA EVIDÊNCIA ALTERA CERTEZA, MAS NÃO A ESTIMATIVA PRINCIPAL

## Cenário

Novo estudo aumenta precisão; estimativa permanece semelhante, mas certeza sobe de baixa para moderada.

## Teste

Versionamento separado de Synthesis e Certainty suporta a mudança.

## Resultado

**PASS**

Requisito:

- CertaintyAssessment novo pode apontar para nova versão da Synthesis mesmo se a estimativa materialmente não mudar;
- Product version deve registrar mudança de certeza.

---

# CASO 13 — ATUALIZAÇÃO FORMAL VERSUS NOVA INVESTIGAÇÃO

## Cenário

Uma pergunta é atualizada após novo corte temporal.

Pode ser:

- nova versão da mesma Investigation viva; ou
- nova Investigation derivada da anterior.

## Teste

Question 1:N Investigation permite ambas, mas falta relação semântica entre Investigations.

## Resultado

**PASS WITH REFINEMENT**

### Correção necessária

Criar:

`InvestigationRelation`

tipos:

- update_of;
- extends;
- reanalysis_of;
- supersedes;
- derived_from.

---

# CASO 14 — RESULTADO COM BRAÇOS NÃO COMPARATIVOS

## Cenário

Estudo de prevalência ou prognóstico possui um único grupo observacional.

## Teste

Result não pode exigir sempre group_a/group_b.

## Resultado

**PASS WITH REFINEMENT**

Regra:

- referências a grupos serão opcionais conforme desenho;
- Result poderá referenciar zero, um ou dois/múltiplos StudyGroups conforme tipo.

---

# CASO 15 — DADO EXTRAÍDO DE FIGURA E POSTERIORMENTE CORRIGIDO

## Cenário

Valor é digitalizado de gráfico; depois é obtido do autor.

## Teste

Reported/derived + DerivationRecord + ResultSource + versionamento.

## Resultado

**PASS**

Requisito:

- nova fonte não apaga derivação anterior;
- versão anterior permanece auditável.

---

# SÍNTESE DOS ACHADOS

## 16. Resultado global

O modelo lógico é estruturalmente adequado, mas a validação detectou lacunas importantes antes do modelo físico.

### Novas entidades necessárias

1. StudyGroup;
2. GroupComponent;
3. SynthesisNode;
4. SynthesisContrast;
5. DiagnosticResultDetail;
6. PredictionModel;
7. PredictionModelIdentifier;
8. FindingContribution;
9. ReportRelation;
10. InvestigationRelation.

### Refinamentos necessários

- ScreeningDecision com target tipado;
- Result com referências estruturadas a StudyGroup;
- Synthesis com origem;
- Report types ampliados;
- timepoint estruturado;
- vínculos de Product para versões específicas;
- regras de impacto para correções/retrações.

---

# 17. Decisão

> **O modelo físico não deverá ser iniciado antes de incorporar os refinamentos desta validação e executar uma segunda checagem de integridade.**

---

# 18. Próxima etapa

1. atualizar Documento 21;
2. alinhar Documento 20 quando houver impacto conceitual;
3. executar checagem de integridade entre Documentos 20–22;
4. somente depois elaborar o primeiro desenho físico candidato.

---

**Fim da primeira bateria de validação arquitetural.**
