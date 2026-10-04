# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-04  
**Checkpoint:** CP14  
**Checkpoint anterior:** CP13  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** Fase 2 — revisão de promoção arquitetural pós-F2-B  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP14

Estado formal:

> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **GATE F2-A — APROVADO**  
> **GATE F2-B — PASS**  
> **OES-H1 — ARQUITETURA CANDIDATA PREFERENCIAL**  
> **OES-P1 — CANDIDATO FÍSICO VALIDADO, NÃO PROMOVIDO**  
> **Revisão dos 15 critérios de promoção — CONCLUÍDA**

Base documental anterior à criação deste checkpoint:

`main @ f152cca755ab772bb2df2fef16dda6147b64c87c`

---

# 2. Documentos centrais desde CP13

- `docs/architecture/32-resultado-gate-f2b.md`
- `docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md`
- `docs/architecture/33-revisao-promocao-pos-f2b.md`

---

# 3. Resultado da revisão dos critérios de promoção

Critérios do Documento 25:

- **7 VALIDADO**
- **5 PARCIALMENTE VALIDADO**
- **3 NÃO VALIDADO**
- **0 FORA DO ESCOPO IMEDIATO**

## Validados

1. Question/Investigation;
2. ingestão de SearchHits;
3. deduplicação;
6. Result com provenance;
11. Certainty;
12. Product/Ficha;
13. nova versão por atualização.

## Parcialmente validados

4. Study com múltiplos Reports;
5. Report com múltiplos Studies;
7. síntese quantitativa multiestudo;
14. retração e impact analysis;
15. reconstrução completa de lineage.

## Não validados

8. NMA;
9. predição;
10. qualitativa/CERQual.

---

# 4. Decisão arquitetural

OES-P1:

> **NÃO PROMOVIDO. MANTIDO COMO CANDIDATO FÍSICO VALIDADO.**

Motivo:

- núcleo transversal aprovado;
- F2-B aprovado;
- lacunas restantes são delimitadas e podem ser cobertas por duas PoCs adicionais;
- não há justificativa para reescrever o núcleo validado.

OES-H1:

> permanece arquitetura candidata preferencial.

PostgreSQL:

> permanece referência de implementação validada para prova arquitetural; não é decisão definitiva de stack.

---

# 5. Plano mínimo restante

## PoC-S4

**Multiplicidade Study/Report, Síntese Multiestudo e Retração/Impact Analysis**

Cobrir:

- critério 4;
- critério 5;
- critério 7;
- critério 14;
- parte remanescente do critério 15.

Cenários mínimos:

1. Study com ≥2 Reports;
2. Report vinculado legitimamente a >1 Study;
3. ≥2 Studies contribuindo para uma Synthesis;
4. correção documental;
5. retração/invalidação;
6. impact analysis até Product;
7. nova versão dos derivados afetados;
8. rebuild do cenário.

## PoC-S5

**Métodos especializados mínimos**

Trilhas:

- S5-A — NMA;
- S5-B — PredictionModel;
- S5-C — Qualitativa/CERQual.

Cobrir:

- critérios 8, 9 e 10;
- remanescente especializado de lineage.

---

# 6. Separação de promoção e produção

Não bloquear a adequação arquitetural por requisitos que pertencem a produção, como:

- HA;
- disaster recovery;
- SLO/SLA;
- cloud/provider;
- autenticação/autorização completa;
- performance em escala real;
- deployment multiambiente.

Continuam obrigatórios durante a prova arquitetural:

- migrations;
- integridade;
- versionamento;
- provenance;
- lineage;
- rollback/rebuild;
- testes de invariantes.

---

# 7. Ponto exato de retomada

## PoC-S4 — Multiplicidade Study/Report, Síntese Multiestudo e Retração/Impact Analysis

Próxima tarefa:

1. definir o design mínimo da PoC-S4;
2. mapear entidades/migrations necessárias;
3. não introduzir funcionalidades fora dos critérios 4, 5, 7, 14 e 15;
4. definir testes antes da implementação;
5. implementar por migration incremental;
6. executar em PostgreSQL descartável;
7. reavaliar a matriz de promoção.

---

# 8. Regra para retomada

Antes de continuar:

1. consultar o ponteiro;
2. ler este CP14;
3. aplicar Freshness Gate;
4. consultar Documentos 25, 32 e 33;
5. confirmar que não houve promoção prematura de OES-P1;
6. iniciar o design da PoC-S4.

---

**Fim do CP14**
