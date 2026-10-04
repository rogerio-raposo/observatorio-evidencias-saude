# 38 — Decisão de Promoção do Baseline Arquitetural e Fechamento da Fase 2

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** decisão arquitetural consolidada  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 23, 25, 27, 32, 33, 35 e 37

## 1. Questão de decisão

Após GATE F2-A, GATE F2-B, PoC-S4 e PoC-S5, o candidato OES-P1 possui evidência suficiente para deixar de ser apenas candidato e tornar-se o baseline arquitetural do Modelo de Dados da Evidência?

## 2. Evidência acumulada

### GATE F2-A

Modelo lógico candidato aprovado.

### GATE F2-B

- T01–T19 PASS;
- identidade;
- versionamento;
- FKs;
- provenance;
- lineage;
- Search/Screening/Dedup;
- RiskAssessment;
- Certainty;
- Product;
- rollback;
- rebuild.

### PoC-S4

- S4-T01–T15 PASS;
- Study ↔ Report N:M;
- síntese multiestudo;
- correction/retraction;
- impact analysis;
- lineage histórico e pós-retração.

### PoC-S5

- S5-T01–T17 PASS;
- regressão F2-B PASS;
- regressão S4 PASS;
- NMA;
- PredictionModel;
- Qualitativa/CERQual;
- lineage especializado;
- rebuild.

## 3. Critérios de promoção do Documento 25

Resultado final:

> **15 / 15 VALIDADO**

Nenhum critério permanece parcial ou não validado.

## 4. Condições de fechamento da Fase 2

As condições definidas no Documento 33 foram satisfeitas:

1. PoC-S4 concluída — sim;
2. PoC-S5 concluída — sim;
3. 15 critérios validados — sim;
4. lineage/rebuild íntegros — sim;
5. defeito estrutural crítico aberto — nenhum identificado nas baterias;
6. documentação sincronizável com o estado executado — sim;
7. decisão explícita de promoção — este documento.

## 5. Decisão

> **OES-P1 É PROMOVIDO A BASELINE ARQUITETURAL DA FASE 2.**

A arquitetura de persistência de referência passa a ser:

> **OES-H1 — núcleo relacional canônico + estruturas documentais controladas + object storage + projeções derivadas**

com baseline físico:

> **OES-P1 — registry global + versionamento + entidades tipadas + núcleo relacional + JSONB controlado + provenance + dependency projection**

## 6. Significado de baseline

“Baseline arquitetural” significa:

- referência canônica para próximas fases;
- novas extensões devem partir desse modelo;
- mudanças estruturais posteriores exigem migration e justificativa;
- divergências deverão ser explicitamente registradas;
- modelos alternativos não devem surgir como fontes paralelas de verdade.

Não significa imutabilidade.

## 7. PostgreSQL

PostgreSQL foi validado como implementação de referência da prova arquitetural.

Status:

> **VALIDADO PARA DESENVOLVIMENTO/PoC; NÃO SELECIONADO AINDA COMO STACK DE PRODUÇÃO DEFINITIVA.**

A seleção tecnológica final deverá considerar requisitos operacionais em fase apropriada.

## 8. Schema de produção

Não existe ainda “schema final de produção”.

O conjunto:

- baseline;
- migrations 002–005;
- invariantes;
- testes;
- fixtures;

constitui referência executável do baseline arquitetural atual.

## 9. Reservas metodológicas preservadas

A promoção não cristaliza prematuramente:

- ApplicabilityAssessment ainda não operacionalizado metodologicamente;
- nomenclatura final dos produtos;
- protocolo de monitoramento/atualização;
- automação e IA;
- requisitos de produção.

Esses temas pertencem às fases seguintes e deverão evoluir por extensão controlada.

## 10. Fechamento da Fase 2

> **FASE 2 — MODELO DE DADOS DA EVIDÊNCIA: CONCLUÍDA NO NÍVEL DE BASELINE ARQUITETURAL.**

Documentos 20–38 constituem o registro da evolução e validação da fase.

## 11. Próxima fase

Conforme o Documento de Concepção:

> **FASE 3 — PRODUTOS DO OBSERVATÓRIO**

Objetivo:

padronizar:

- Ficha de Evidência;
- Resposta de Evidência;
- Síntese Rápida;
- Revisão de Evidências;
- Mapa de Evidências;
- Monitor de Evidências.

## 12. Regra de transição

A Fase 3 deverá começar pela arquitetura dos produtos, não por interface visual ou automação.

Primeira tarefa recomendada:

> definir a taxonomia oficial dos produtos, seus objetivos, requisitos mínimos, níveis de profundidade compatíveis e relação com as entidades persistentes do baseline OES-P1.

---

**Decisão final:** OES-P1 promovido a baseline arquitetural; Fase 2 encerrada; transição autorizada para Fase 3.
