# 23 — Checagem de Integridade do Modelo de Dados

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — checagem de consistência  
**Data:** 3 de outubro de 2026  
**Escopo:** Documentos 20–22 versus base metodológica 10–15

## 1. Finalidade

Verificar se o modelo conceitual/lógico preserva as decisões metodológicas do OES antes de qualquer modelo físico.

A checagem avalia:

- consistência interna;
- cobertura metodológica;
- cardinalidades;
- identidade;
- proveniência;
- versionamento;
- separação de constructos;
- extensibilidade.

---

# PARTE I — RESULTADO GLOBAL

## 2. Status

**Resultado:** APROVADO COMO MODELO LÓGICO CANDIDATO, COM RESERVAS EXPLÍCITAS.

Não foram encontrados conflitos críticos que impeçam a evolução para um desenho físico candidato.

Persistem interfaces metodológicas ainda não fechadas que **não deverão ser cristalizadas pela tecnologia**.

---

# PARTE II — INVARIANTES METODOLÓGICOS

## 3. Study × Report × Result

### Requisito metodológico

Os três objetos devem permanecer distintos.

### Verificação

- Study possui identidade própria;
- Report possui identidade própria;
- StudyReportLink resolve N:M;
- Result pertence a Study;
- ResultSource preserva origem documental.

### Status

**PASS**

---

## 4. Valor relatado × valor derivado

### Requisito

Valores originais e transformados não podem ser colapsados.

### Verificação

- Result contém reported_value e derived_value;
- DerivationRecord preserva método/parâmetros;
- ResultSource preserva fonte.

### Status

**PASS**

---

## 5. Busca auditável

### Requisito

Busca, plataforma, estratégia e captura devem ser reconstruíveis.

### Verificação

- Search possui estratégia e execução;
- SearchHit preserva ocorrência bruta;
- DedupCluster não apaga hits.

### Status

**PASS**

---

## 6. Triagem e elegibilidade

### Requisito

Report e Study podem ser unidades distintas de decisão.

### Verificação

ScreeningDecision utiliza target tipado:

- report;
- study.

### Status

**PASS**

---

## 7. Risco de viés × certeza

### Requisito

Constructos distintos.

### Verificação

- RiskAssessment e RiskAssessmentDomain são objetos próprios;
- CertaintyAssessment e CertaintyDomainJudgement são objetos próprios;
- relações ocorrem por síntese/investigação, não por colapso das entidades.

### Status

**PASS**

---

## 8. Síntese explícita

### Requisito

Síntese não pode ser inferida apenas de Results.

### Verificação

- Synthesis possui identidade própria;
- SynthesisContribution registra participação de Results;
- SynthesisStatistic armazena estatísticas;
- SynthesisNode/Contrast suportam redes.

### Status

**PASS**

---

## 9. Certeza por unidade adequada

### Requisito

GRADE por outcome/synthesis; CERQual por review finding.

### Verificação

- CertaintyAssessment aponta para Synthesis/outcome;
- CERQual aponta para ReviewFinding;
- FindingContribution preserva estudos contribuintes.

### Status

**PASS**

---

## 10. Proveniência

### Requisito

Dados críticos devem ser rastreáveis.

### Verificação

- ResultSource;
- DerivationRecord;
- ProvenanceRecord;
- versionamento.

### Status

**PASS**

---

## 11. Versionamento

### Requisito

Atualização não pode sobrescrever silenciosamente estado publicado.

### Verificação

Contrato comum prevê:

- entity_id;
- version_no;
- status;
- valid_from/valid_to;
- supersedes_version_id.

### Status

**PASS**

---

# PARTE III — MÉTODOS ESPECIALIZADOS

## 12. Network meta-analysis

### Verificação

- StudyGroup;
- GroupComponent;
- SynthesisNode;
- SynthesisNodeMapping;
- SynthesisContrast.

### Status

**PASS APÓS REFINAMENTO DO DOCUMENTO 22**

---

## 13. Diagnóstico

### Verificação

DiagnosticResultDetail representa:

- threshold;
- TP/FP/FN/TN;
- sensibilidade/especificidade;
- teste índice;
- padrão de referência.

### Status

**PASS APÓS REFINAMENTO**

---

## 14. Predição

### Verificação

PredictionModel possui identidade própria entre desenvolvimento e validações.

### Status

**PASS APÓS REFINAMENTO**

---

## 15. Qualitativa

### Verificação

ReviewFinding + FindingContribution + CertaintyAssessment/CERQual.

### Status

**PASS**

---

# PARTE IV — PRODUTOS E CONHECIMENTO

## 16. Ficha de Evidência

### Decisão atual

Modelada inicialmente como Product subtype.

### Integridade

A modelagem não substitui:

- Question;
- Investigation;
- Study;
- Synthesis;
- Certainty.

### Status

**PASS PROVISÓRIO**

A decisão deverá ser reavaliada na Fase 3 — Produtos do Observatório.

---

# PARTE V — LACUNAS E RESERVAS

## 17. Aplicabilidade

### Achado

A metodologia separa explicitamente:

- certeza;
- indirectness;
- aplicabilidade ao Brasil/contexto.

O modelo lógico ainda não possuía objeto próprio.

### Decisão

Reservar:

**ApplicabilityAssessment — OES-AP**

sem fixar nesta fase:

- categorias;
- score;
- domínios;
- thresholds.

A especificação operacional dependerá de protocolo metodológico próprio ou da formalização da camada de aplicabilidade.

### Regra

`Product.applicability_summary` será representação derivada, não fonte autoritativa do julgamento.

### Status

**RESERVA METODOLÓGICA**

---

## 18. Conclusão OES

A conclusão atualmente aparece em Product.

Não será criada entidade autônoma antes de formalização da política de linguagem/interpretação dos produtos.

### Status

**ADIADO**

---

## 19. Monitoramento e atualização

Estados M0–M3 existem metodologicamente, mas entidades operacionais de monitoramento pertencem à Fase 4.

### Status

**ADIADO COM EXTENSION POINT**

---

## 20. Vocabulários controlados

Concept e ConceptMapping existem logicamente.

Ainda não foram escolhidos:

- terminologias;
- estratégia de sincronização;
- política de mapeamento.

### Status

**ADIADO**

---

## 21. Polimorfismo de targets

Objetos como RiskAssessment e ProvenanceRecord usam target tipado.

Isso é aceitável no modelo lógico, mas o modelo físico deverá escolher mecanismo que preserve integridade referencial.

### Status

**RISCO DE IMPLEMENTAÇÃO, NÃO FALHA CONCEITUAL**

---

## 22. Revisões, guidelines, HTA e regulatórios

- systematic review pode ser Study;
- guideline/HTA/regulatory document pode existir como Report sem Study subjacente;
- ReportRelation suporta atualizações/correções.

### Status

**PASS PROVISÓRIO**

Deverá ser reavaliado em casos de overview/umbrella review.

---

# PARTE VI — CONSISTÊNCIA ENTRE DOCUMENTOS

## 23. Documento 20 × Documento 21

- separações conceituais preservadas;
- cardinalidade Study ↔ Report harmonizada em N:M;
- entidades especializadas do Documento 21 não contradizem o modelo conceitual.

**PASS**

## 24. Documento 21 × Documento 22

Todos os refinamentos críticos detectados na primeira bateria foram incorporados ao Documento 21.

**PASS**

## 25. Documentos 13–15 × Modelo lógico

### Documento 13 — Extração

Cobertura:

- Study/Report/Result;
- reported/derived;
- proveniência;
- múltiplas fontes;
- versionamento.

**PASS**

### Documento 14 — Síntese

Cobertura:

- Synthesis ID;
- contribuições;
- modelo/software;
- heterogeneidade;
- NMA;
- achados qualitativos.

**PASS**

### Documento 15 — Certeza

Cobertura:

- Certainty Assessment;
- domínios;
- revisão independente;
- GRADE/CERQual;
- NMA;
- versionamento.

**PASS**, com ApplicabilityAssessment reservado separadamente.

---

# PARTE VII — GATES PARA MODELO FÍSICO

## 26. Condições cumpridas

- entidades centrais definidas;
- cardinalidades principais definidas;
- casos de uso testados;
- proveniência modelada;
- versionamento modelado;
- deduplicação modelada;
- métodos especializados essenciais representados.

## 27. Condições que permanecem abertas, mas não bloqueiam desenho físico candidato

- método final de aplicabilidade;
- vocabulários controlados;
- Product/Ficha de Evidência definitivo;
- monitoramento;
- arquitetura de atualização;
- stack tecnológica.

## 28. Restrições ao desenho físico

O primeiro desenho físico:

1. será candidato e reversível;
2. não poderá fixar categorias metodológicas ainda abertas;
3. deverá suportar extensão;
4. deverá preservar IDs estáveis;
5. deverá preservar histórico;
6. deverá permitir proveniência por campo crítico;
7. não deverá escolher tecnologia por conveniência antes de comparar requisitos.

---

# PARTE VIII — DECISÃO DE GATE

## 29. Gate arquitetural

> **GATE F2-A — MODELO LÓGICO CANDIDATO: APROVADO**

Autorizado:

- elaborar primeiro desenho físico candidato;
- comparar estratégias relacionais/documentais/híbridas;
- testar representação sem compromisso de implementação.

Não autorizado ainda:

- congelar schema final;
- selecionar stack definitiva;
- iniciar automação ampla;
- cristalizar aplicabilidade, produtos ou monitoramento ainda não formalizados.

---

# PARTE IX — PRÓXIMA ETAPA

Desenvolver o **primeiro desenho físico candidato**, acompanhado de análise de alternativas arquiteturais.

Deverá responder:

- quais entidades exigem integridade relacional forte;
- quais campos requerem flexibilidade documental;
- como armazenar versões;
- como implementar proveniência;
- como consultar grafos de dependência;
- como representar targets tipados;
- como evitar duplicação;
- como preservar evolução futura.

---

**Fim da checagem de integridade.**
