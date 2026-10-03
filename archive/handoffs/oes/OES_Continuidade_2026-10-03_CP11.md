# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — PoC Física

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP11  
**Checkpoint anterior:** CP10  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** PoC-S1 do desenho físico OES-P1  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

---

# 1. Marco

> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **GATE F2-A: APROVADO**  
> **OES-H1: CANDIDATA**  
> **OES-P1: CANDIDATO**  
> **PoC-S1: CRIADA E ESTATICAMENTE VALIDADA**  
> **GATE F2-B — EXECUÇÃO EM POSTGRESQL: PENDENTE**

Base documental:

`main @ 9444109a11ff5015dcc0e4538816573e9cee81c8`

---

# 2. Artefatos novos

- `database/poc-s1.sql`
- `database/poc-s1-smoke.sql`
- `database/README.md`
- `docs/architecture/26-poc-s1-validacao.md`

---

# 3. Resultado da validação estática

Schema:

- 32 tabelas;
- 5 views;
- 63 referências;
- 0 referências a tabelas inexistentes;
- 0 CREATE TABLE duplicados;
- estrutura textual balanceada.

Smoke:

- 30 INSERTs;
- 30 alvos válidos;
- 0 FROM/JOIN ausentes;
- UUIDs bem formados;
- lineage recursivo presente;
- ROLLBACK presente.

---

# 4. Limitação explícita

Não existe no ambiente atual:

- PostgreSQL server;
- psql;
- initdb;
- Docker;
- Podman.

Logo:

> **não afirmar que o DDL executou com sucesso.**

A PoC permanece candidata até execução real.

---

# 5. Gate F2-B

Para aprovação, executar:

1. schema do zero;
2. smoke test;
3. testes negativos;
4. versionamento;
5. retração/impact lineage;
6. rollback;
7. registro de versão PostgreSQL;
8. correções;
9. reexecução limpa.

---

# 6. Ponto exato de retomada

Enquanto F2-B aguarda ambiente PostgreSQL, seguir **Trilha B**:

1. plano formal de testes F2-B;
2. política de identidade e IDs;
3. política de versionamento;
4. política de proveniência;
5. desenho de migrações;
6. extensão controlada para Search/Screening/RiskAssessment.

Não promover OES-P1 ou PostgreSQL a decisão definitiva.

---

# 7. Regra de retomada

1. consultar pointer;
2. ler CP11;
3. executar Freshness Gate;
4. consultar STATE e Documentos 20–26;
5. verificar se F2-B já foi executado;
6. se não, prosseguir Trilha B.

---

**Fim do CP11**
