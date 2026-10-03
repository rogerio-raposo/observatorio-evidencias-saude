# 26 — PoC-S1: Validação do Schema Mínimo

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** PoC criada; validação estática concluída; execução PostgreSQL pendente  
**Data:** 3 de outubro de 2026  
**Base:** OES-P1 — Documento 25

## 1. Finalidade

Registrar a primeira prova de conceito física do OES e separar claramente:

- o que foi implementado;
- o que foi verificado;
- o que ainda não foi executado;
- quais condições são necessárias antes de promover o desenho físico.

---

# 2. Artefatos da PoC

## Schema

`database/poc-s1.sql`

Contém o núcleo experimental:

- `core.entity`;
- `core.entity_version`;
- Question/Investigation;
- Study/Report/StudyReportLink;
- Outcome/Result/ResultSource;
- Synthesis/SynthesisContribution;
- Certainty/CertaintyDomain;
- Product e links;
- Provenance;
- Artifact metadata;
- Dependency projection;
- views de versão vigente.

## Smoke test

`database/poc-s1-smoke.sql`

Constrói uma cadeia mínima:

`Question → Investigation → Study/Report → Result → Synthesis → Certainty → Product`

e testa consultas de:

- versões vigentes;
- lineage canônico por relações de domínio;
- lineage derivado por dependency edges;
- proveniência Result → Report.

O teste termina com `ROLLBACK`.

---

# 3. Validação estática do schema

A checagem estrutural do arquivo `poc-s1.sql` encontrou:

- **32 tabelas**;
- **5 views**;
- **64 referências FK/REFERENCES**;
- **0 referências a tabelas inexistentes**;
- **0 tabelas CREATE duplicadas**;
- balanço de parênteses: **válido**;
- bloco transacional BEGIN/COMMIT: **presente**;
- unique index para versão `current`: **presente**;
- ProvenanceRecord: **presente**;
- DependencyEdge: **presente**;
- **9 triggers de subtipo**: presentes;
- supersessão de versão restrita à mesma entity por FK composta: presente;
- provenance append-only com supersessão/invalidação explícita: presente;
- delimitador da função PL/pgSQL validado estaticamente: presente.

## Interpretação

Esses testes verificam consistência estrutural básica do texto SQL.

Eles **não demonstram** que o DDL foi aceito por um servidor PostgreSQL.

---

# 4. Validação estática do smoke test

A checagem de `poc-s1-smoke.sql` encontrou:

- **30 statements INSERT**;
- **30 alvos distintos de INSERT**;
- **0 alvos de INSERT inexistentes no schema**;
- **0 tabelas/views inexistentes em FROM/JOIN**;
- **101 literais UUID identificados**;
- **0 UUIDs malformados**;
- balanço de parênteses: **válido**;
- CTE recursiva de lineage: **presente**;
- `ROLLBACK` final: **presente**.

---

# 5. O que não foi testado

O ambiente disponível nesta etapa não possui:

- `postgres`;
- `psql`;
- `initdb`;
- Docker;
- Podman.

Portanto, não foi possível executar de forma honesta:

- criação real dos schemas;
- validação do DDL pelo parser PostgreSQL;
- constraints em runtime;
- transações;
- unique partial index;
- CTE recursiva;
- comportamento de rollback;
- performance;
- plano de execução.

---

# 6. Gate de execução

Criado:

> **GATE F2-B — EXECUÇÃO DA PoC-S1 EM POSTGRESQL: PENDENTE**

O Gate F2-B exige, no mínimo:

1. instância PostgreSQL descartável;
2. execução limpa de `database/poc-s1.sql`;
3. execução de `database/poc-s1-smoke.sql`;
4. confirmação dos resultados esperados;
5. testes negativos de constraints;
6. teste de versionamento;
7. teste de retração/impact lineage;
8. registro da versão do PostgreSQL utilizada;
9. registro dos erros/correções;
10. reexecução do zero após correções.

---

# 7. Testes negativos obrigatórios

A próxima execução real deverá provar que o banco rejeita:

## 7.1 Segunda versão current simultânea

Para a mesma entity:

- versão 1 = current;
- tentativa de versão 2 = current sem superseder a anterior.

Esperado:

**violação do unique partial index.**

## 7.2 FK inexistente

Tentar SynthesisContribution com Result version inexistente.

Esperado:

**FK violation.**

## 7.3 Result sem valor

Tentar ResultVersion com:

- `reported_value = NULL`;
- `derived_value = NULL`.

Esperado:

**CHECK violation.**

## 7.4 CI invertido

`ci_lower > ci_upper`.

Esperado:

**CHECK violation.**

## 7.5 No evidence + certeza final

`evidence_state = no_evidence` e `final_level` preenchido.

Esperado:

**CHECK violation.**

---

# 8. Teste de versionamento obrigatório

Cenário:

1. Result v1 = current;
2. Result v2 criado;
3. v1 → superseded;
4. v2 → current;
5. Synthesis v2 passa a apontar para Result v2;
6. Certainty v2 é gerada;
7. Product v2 é gerado;
8. Product v1 permanece auditável.

Esperado:

- lineage histórico preservado;
- lineage vigente utiliza v2;
- nenhuma versão anterior é sobrescrita.

---

# 9. Teste de retração obrigatório

Cenário:

1. Report alimenta Result;
2. Result alimenta Synthesis;
3. Synthesis alimenta Certainty;
4. Certainty alimenta Product;
5. Report recebe relação `retraction_of`/estado de retração em extensão completa.

A PoC mínima deverá demonstrar pelo menos a localização do caminho afetado:

`Report → Result → Synthesis → Certainty → Product`

Resultado esperado:

lista de objetos que exigem reavaliação, sem alteração automática da conclusão.

---

# 10. Avaliação da PoC até aqui

## Confirmado

- OES-P1 pode ser materializado em DDL coerente em nível estático;
- registry global simplifica referências a versões;
- lineage pode ser representado pelas relações de domínio;
- dependency projection é compatível com reconstrução do caminho;
- provenance mantém vínculo de Result com Report;
- separação entre identidade e versão é fisicamente representável.

## Ainda não confirmado

- validade sintática completa no PostgreSQL;
- comportamento transacional;
- adequação de performance;
- ergonomia de escrita/leitura;
- necessidade real da dependency projection;
- custo dos joins de versão;
- política final de triggers/functions;
- migração futura dos payloads JSONB.

---

# 11. Decisão

> **OES-P1 permanece candidato. Não promover a schema-base nem selecionar PostgreSQL como stack definitiva antes do GATE F2-B.**

A indisponibilidade de PostgreSQL local é limitação de validação desta etapa, não evidência contra o desenho.

---

# 12. Próxima etapa

Há duas trilhas permitidas em paralelo:

### Trilha A — execução da PoC

Executar PoC-S1 em PostgreSQL descartável quando houver ambiente disponível.

### Trilha B — continuar especificação sem assumir resultado do Gate

Pode-se avançar em:

- plano formal de testes do Gate F2-B;
- política de IDs;
- política de versionamento;
- política de provenance;
- desenho de migrações;
- extensão do schema para Search/Screening/RiskAssessment.

Não se deve:

- promover OES-P1 a definitivo;
- iniciar implementação de produção;
- automatizar ingestão ampla.

---

**Fim do registro PoC-S1.**
