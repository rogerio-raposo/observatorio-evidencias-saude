# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP15  
**Checkpoint anterior:** CP14  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 2 — conclusão da PoC-S4 e transição para métodos especializados  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP15

Estado formal:

> **Fase 2 — EM DESENVOLVIMENTO**  
> **GATE F2-A — APROVADO**  
> **GATE F2-B — PASS**  
> **PoC-S4 — PASS**  
> **OES-P1 — CANDIDATO FÍSICO VALIDADO, NÃO PROMOVIDO**  
> **Matriz de promoção — 11 VALIDADO / 1 PARCIAL / 3 NÃO VALIDADO**

Base documental anterior à criação deste checkpoint:

`main @ 7a523b9209404a036c47cfdf746e1cccb8a708c4`

---

# 2. Resultado da PoC-S4

Run:

- GitHub Actions: **37188934837**
- commit: `c86a037526fa162ccb3d5773e9a1d1ad2efe1572`
- PostgreSQL: **18.6**
- S4-T01–T15: **PASS**
- rebuild: **PASS**

Artifact:

- ID: **11298153474**
- digest: `sha256:c37a2a57bc6b039461324576b06aa4c88f401773ca83dddfa5f9d3cae583cab5`

Documentos:

- `docs/architecture/34-plano-poc-s4.md`
- `docs/architecture/35-resultado-poc-s4.md`

---

# 3. Capacidades validadas em S4

- Study com múltiplos Reports;
- Report com múltiplos Studies;
- síntese quantitativa com múltiplos Studies;
- ReportRelation;
- correção documental;
- retração;
- versionamento Report v1→v2→v3;
- impact analysis derivado;
- atualização Result/Synthesis/Certainty/Product;
- coexistência de cadeia histórica e cadeia pós-retração;
- rebuild do zero;
- migration incremental detectável.

---

# 4. Matriz de promoção atual

## VALIDADO — 11

1. Question/Investigation;
2. SearchHits;
3. deduplicação;
4. Study com múltiplos Reports;
5. Report com múltiplos Studies;
6. Result com provenance;
7. síntese quantitativa;
11. certainty;
12. Product/Ficha;
13. nova versão por atualização;
14. retração e impact analysis.

## PARCIALMENTE VALIDADO — 1

15. reconstrução completa de lineage.

Motivo:

o lineage transversal e relacional foi demonstrado, mas ainda falta exercitá-lo nos métodos especializados.

## NÃO VALIDADO — 3

8. NMA;
9. predição;
10. qualitativa/CERQual.

---

# 5. Próxima etapa exclusiva

## PoC-S5 — Métodos Especializados Mínimos

A PoC-S5 deverá validar:

### S5-A — NMA

- SynthesisNode;
- SynthesisNodeMapping;
- SynthesisContrast;
- Results/contributions;
- provenance;
- lineage.

### S5-B — PredictionModel

- PredictionModel;
- PredictionModelIdentifier;
- PredictionModelStudyRole;
- Results de performance;
- provenance;
- lineage.

### S5-C — Qualitativa/CERQual

- ReviewFinding;
- FindingContribution;
- CertaintyAssessment compatível com CERQual;
- provenance;
- lineage.

---

# 6. Regra de escopo

A S5 não deve implementar motores analíticos completos.

Objetivo:

> validar a capacidade do modelo físico de representar, versionar, rastrear e reconstruir os métodos especializados previstos no modelo lógico.

Não introduzir:

- interface;
- motor estatístico completo;
- automação ampla;
- segurança de produção;
- infraestrutura de produção.

---

# 7. Ponto exato de retomada

1. definir o plano de testes da PoC-S5;
2. mapear somente entidades especializadas já previstas no Documento 21;
3. implementar migration incremental;
4. criar fixtures mínimas para NMA, predição e qualitativa/CERQual;
5. testar lineage em cada trilha;
6. executar rebuild;
7. atualizar a matriz de promoção;
8. decidir se OES-P1 pode ser promovido a baseline arquitetural da Fase 2.

---

**Fim do CP15**
