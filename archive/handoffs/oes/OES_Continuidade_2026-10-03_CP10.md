# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP10  
**Checkpoint anterior:** CP09  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** arquitetura candidata de persistência e primeiro desenho físico  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco

> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **GATE F2-A: APROVADO**  
> **OES-H1 — Arquitetura de Persistência: CANDIDATA PARA PROVA**  
> **OES-P1 — Primeiro Desenho Físico: CANDIDATO PARA PoC**

Base documental:

`main @ 513c0eba99da945bb7055847602cd20dd79b6445`

---

# 2. Novos documentos

- `docs/architecture/24-alternativas-arquiteturais-persistencia.md`
- `docs/architecture/25-primeiro-desenho-fisico-candidato.md`

---

# 3. OES-H1

Arquitetura candidata:

1. núcleo relacional canônico;
2. payloads documentais controlados;
3. object storage para bytes/artefatos;
4. projeções derivadas opcionais de grafo, busca e analytics.

Regra:

> uma única fonte canônica estruturada; projeções devem ser reconstruíveis.

---

# 4. OES-P1

Padrão físico candidato:

- `core.entity` — identidade global estável;
- `core.entity_version` — identidade de versão;
- entidades tipadas por domínio;
- tabelas associativas;
- provenance referenciando versões concretas;
- artifact metadata separado dos bytes;
- JSONB controlado;
- dependency projection derivada.

---

# 5. Decisões importantes

- referências genéricas críticas não usarão apenas `target_type + target_id`;
- o registry global permite FK real para versões;
- JSONB não substitui relações N:M;
- bytes não ficam nas tabelas de domínio;
- dependency graph não é fonte de edição;
- PostgreSQL é referência de prova, não stack definitiva.

---

# 6. Ponto exato de retomada

## PoC-S1 — Schema mínimo

Validar:

1. entity/entity_version;
2. Question/Investigation;
3. Study/Report/StudyReportLink;
4. Outcome/Result/ResultSource;
5. Synthesis/SynthesisContribution;
6. Certainty;
7. Product;
8. Provenance;
9. Artifact metadata;
10. lineage e update/retraction impact.

A PoC deve testar o modelo; não iniciar automação ampla.

---

# 7. Regra de retomada

1. consultar pointer;
2. ler CP10;
3. executar Freshness Gate;
4. consultar STATE e Documentos 20–25;
5. retomar PoC-S1.

---

**Fim do CP10**
