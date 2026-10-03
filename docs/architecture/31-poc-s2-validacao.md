# 31 — PoC-S2: Validação de Search, Screening e Risk Assessment

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Migração criada e estaticamente validada; execução PostgreSQL pendente  
**Data:** 3 de outubro de 2026  
**Migration ID:** OES-DBM-2026-0002  
**Dependência:** PoC-S1

## 1. Finalidade

Registrar a extensão controlada do desenho físico candidato para:

- Search;
- SearchHit;
- DedupCluster;
- ScreeningDecision;
- RiskAssessment;
- RiskAssessmentDomain.

A extensão foi criada como migração separada:

`database/002_poc_s2_search_screening_risk.sql`

---

## 2. Estruturas adicionadas

### Busca e recuperação

- `investigation.search`;
- `investigation.dedup_cluster`;
- `investigation.search_hit`.

### Triagem

- `investigation.screening_decision`.

### Avaliação crítica

- `appraisal.risk_assessment`;
- `appraisal.risk_assessment_version`;
- `appraisal.risk_assessment_domain`.

---

## 3. Funções e triggers

### Screening

Função:

`investigation.assert_screening_target_type()`

Alvos permitidos:

- Report;
- Study.

Trigger:

`tr_screening_target_type`

### Risk Assessment

Identidade de RiskAssessment usa:

`core.assert_entity_type('RiskAssessment')`

Target da avaliação usa:

`appraisal.assert_risk_target_type()`

Alvos permitidos nesta PoC:

- Study;
- Result;
- Report.

Triggers:

- `tr_risk_assessment_entity_type`;
- `tr_risk_target_type`.

---

## 4. Invariantes adicionadas

1. Search pertence a uma Investigation version.
2. SearchHit pertence a uma Search.
3. SearchHit bruto não é apagado pela deduplicação.
4. DedupCluster pode apontar para Report canônico.
5. ScreeningDecision só pode avaliar Report ou Study.
6. exclusão exige motivo.
7. decisão adjudicada pode referenciar decisão anterior.
8. RiskAssessment possui identidade OES própria.
9. RiskAssessmentVersion pertence à identidade correta.
10. alvo de RiskAssessment é limitado a tipos suportados.
11. domínios pertencem a uma versão da avaliação.

---

## 5. Validação estática

Resultado:

- **7 tabelas** novas;
- **17 REFERENCES**;
- **0 referências a tabelas ausentes** considerando baseline + migração;
- **3 triggers**;
- **2 funções PL/pgSQL**;
- dollar tags das funções: válidas na checagem textual;
- balanço de parênteses: válido;
- BEGIN/COMMIT: presentes.

Isso não substitui execução real no PostgreSQL.

---

## 6. Novos testes de runtime para F2-B

### T15 — ordem da migração

- executar baseline;
- executar migration 002;
- repetir migration 002 acidentalmente.

Esperado:

- primeira execução: sucesso;
- segunda execução: falha controlada/identificável, demonstrando necessidade do migration ledger em ambiente persistente.

### T16 — Screening target

Casos:

- Report: aceitar;
- Study: aceitar;
- Result: rejeitar;
- exclusão sem motivo: rejeitar.

### T17 — Risk target

Casos:

- Study: aceitar;
- Result: aceitar;
- Report: aceitar;
- Product: rejeitar.

Também testar entity_type incorreto para a própria RiskAssessment.

### T18 — deduplicação sem perda de SearchHit

Criar dois SearchHits no mesmo DedupCluster.

Esperado:

- ambos permanecem;
- cluster aponta para Report canônico;
- nenhum raw_payload é descartado.

### T19 — rebuild completo

Em banco vazio:

1. executar PoC-S1;
2. executar migration 002;
3. carregar fixtures;
4. validar Search → Screening → Study/Report → Result → Synthesis → Certainty → Product.

Esperado:

cadeia operacional e científica reconstruível.

---

## 7. Questões ainda fora da PoC-S2

- ExtractionRecord;
- StudyGroup/NMA;
- diagnóstico;
- PredictionModel;
- ReviewFinding/CERQual;
- ApplicabilityAssessment;
- ReportRelation/retração formal;
- MergeDecision;
- migration ledger;
- autenticação/autorização.

---

## 8. Gate

> A PoC-S2 não possui gate independente. Seus testes passam a compor o **GATE F2-B**.

O Gate permanece pendente de execução PostgreSQL real.

---

## 9. Próxima etapa documental permitida

Enquanto F2-B estiver pendente:

1. migration ledger;
2. ReportRelation + eventos de impacto;
3. MergeDecision;
4. extensão especializada somente se necessária para testar as invariantes centrais.

Evitar ampliar a PoC indefinidamente antes da primeira execução real.

---

**Fim da validação estática da PoC-S2.**
