# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Trilha B Arquitetural

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP12  
**Checkpoint anterior:** CP11  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** governança física da PoC enquanto F2-B permanece pendente  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco

> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **GATE F2-A: APROVADO**  
> **GATE F2-B: PENDENTE DE EXECUÇÃO POSTGRESQL**  
> **PoC-S1: CRIADA, ENDURECIDA E ESTATICAMENTE VALIDADA**  
> **Plano F2-B: FORMALIZADO**  
> **Política de Identidade/Versionamento: FORMALIZADA**  
> **Política de Provenance/Lineage: FORMALIZADA**

Base documental:

`main @ a9508df24bef6935b7e5d37bdaa3e0ecb44daacf`

---

# 2. Documentos consolidados desde CP11

- `docs/architecture/27-plano-testes-gate-f2b.md`
- `docs/architecture/28-politica-identidade-versionamento.md`
- `docs/architecture/29-politica-proveniencia-lineage.md`

---

# 3. Hardening da PoC-S1

Foram incorporados:

- FK de supersessão restrita à mesma entity;
- função `core.assert_entity_type()`;
- 9 triggers de subtipo;
- provenance append-only;
- supersessão/invalidação de provenance;
- motivo obrigatório para invalidação.

Estado estático atual:

- 32 tabelas;
- 5 views;
- 64 REFERENCES;
- 9 triggers;
- zero referências a tabelas inexistentes.

---

# 4. Regras de identidade

- UUID físico opaco;
- OES ID público estável;
- identificadores externos = aliases;
- identidade ≠ versão;
- no máximo uma versão current;
- merge/split auditáveis;
- histórico não sobrescrito.

---

# 5. Regras de provenance

- provenance e lineage são objetos de primeira classe;
- alvo = versão concreta;
- correção por novo registro/supersessão;
- dependency_edge = projeção regenerável;
- transformações devem preservar input/método/software;
- IA, quando usada, deve ter provenance compatível com criticidade.

---

# 6. Plano F2-B

14 blocos de teste:

- instalação;
- smoke;
- current uniqueness;
- supersession;
- subtype integrity;
- FK;
- Result validation;
- CI;
- no-evidence rule;
- version chain;
- provenance;
- impact lineage;
- rollback;
- rebuild from zero.

---

# 7. Ponto exato de retomada

Enquanto F2-B aguarda ambiente PostgreSQL:

1. formalizar política de migrações;
2. estender PoC de forma controlada para:
   - Search;
   - SearchHit;
   - DedupCluster;
   - ScreeningDecision;
   - RiskAssessment;
   - RiskAssessmentDomain;
3. validar estaticamente a extensão;
4. atualizar o plano F2-B se surgirem invariantes novas.

Não promover OES-P1 a definitivo.

---

# 8. Regra de retomada

1. consultar pointer;
2. ler CP12;
3. executar Freshness Gate;
4. verificar status F2-B;
5. se pendente, continuar migrações/PoC-S2;
6. se executado, avaliar evidências antes de promoção.

---

**Fim do CP12**
