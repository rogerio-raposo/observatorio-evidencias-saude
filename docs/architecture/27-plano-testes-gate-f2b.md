# 27 — Plano Formal de Testes do GATE F2-B

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Plano de validação — execução pendente  
**Data:** 3 de outubro de 2026  
**Objeto:** PoC-S1 / OES-P1

## 1. Objetivo

Definir evidências mínimas para aprovar ou reprovar a execução física da PoC-S1.

O Gate F2-B valida o **candidato**, não transforma PostgreSQL ou OES-P1 em decisões definitivas.

---

## 2. Ambiente de teste

Registrar obrigatoriamente:

- versão exata do PostgreSQL;
- sistema operacional/container;
- encoding;
- locale;
- timezone;
- parâmetros não default relevantes;
- hash dos arquivos SQL;
- data/hora;
- executor.

Preferência:

- instância descartável;
- banco vazio;
- sem extensões não declaradas.

---

## 3. Sequência

### T01 — instalação limpa

1. criar banco vazio;
2. executar `database/poc-s1.sql`;
3. registrar stdout/stderr;
4. confirmar COMMIT;
5. listar schemas/tabelas/views/triggers/índices.

**Aceite:** zero erros não esperados.

### T02 — smoke test

Executar:

`database/poc-s1-smoke.sql`

Validar:

- current_entity_count = 9;
- lineage canônico retorna a cadeia esperada;
- dependency projection retorna profundidades 1–4;
- provenance resolve Result → Report;
- transação termina em ROLLBACK.

### T03 — segunda versão current

Tentar inserir segunda versão `current` da mesma entity sem superseder a anterior.

**Esperado:** unique violation.

### T04 — supersession cruzada

Tentar fazer uma versão de Entity A superseder versão de Entity B.

**Esperado:** FK violation.

### T05 — subtipo incompatível

Criar registry `entity_type = Report` e tentar inserir em `evidence.study`.

**Esperado:** trigger exception.

### T06 — FK inexistente

Tentar Contribution para ResultVersion inexistente.

**Esperado:** FK violation.

### T07 — Result sem valor

`reported_value = NULL` e `derived_value = NULL`.

**Esperado:** CHECK violation.

### T08 — intervalo invertido

`ci_lower > ci_upper`.

**Esperado:** CHECK violation.

### T09 — ausência de evidência

`evidence_state = no_evidence` com `final_level` preenchido.

**Esperado:** CHECK violation.

### T10 — versionamento completo

Executar cadeia v1 → v2:

- Result;
- Synthesis;
- Certainty;
- Product.

Verificar:

- v1 permanece consultável;
- somente v2 fica current;
- links de Product v1 permanecem em versões v1;
- Product v2 aponta para versões v2.

### T11 — provenance imutável

Criar provenance incorreta e depois corrigi-la segundo a política de provenance.

**Esperado:** correção por novo registro/supersessão, não UPDATE destrutivo do histórico.

### T12 — impacto de Report

Criar caminho:

`Report → Result → Synthesis → Certainty → Product`

e localizar todos os dependentes.

**Esperado:** lineage completo e determinístico.

### T13 — rollback

Provocar erro no meio de transação com múltiplas inserções.

**Esperado:** nenhuma alteração parcial.

### T14 — reconstrução do zero

Dropar banco e repetir T01–T13 a partir apenas dos artefatos versionados.

**Esperado:** resultados equivalentes.

---

## 4. Testes de consistência pós-execução

Consultas deverão confirmar:

- nenhuma versão current duplicada;
- nenhum version_uuid ligado a identity incompatível;
- nenhum link órfão;
- nenhum Result sem Study;
- nenhum Product link órfão;
- nenhum Artifact link órfão;
- nenhuma dependency edge órfã.

---

## 5. Evidências do gate

Salvar como artefatos:

- log de instalação;
- log do smoke;
- log de testes negativos;
- versão PostgreSQL;
- hashes SHA-256 dos SQLs;
- queries executadas;
- resultados;
- lista de correções;
- reexecução final.

---

## 6. Classificação do gate

### PASS

- T01–T14 aprovados;
- nenhum erro estrutural crítico;
- correções incorporadas e reexecutadas;
- evidências arquivadas.

### CONDITIONAL PASS

Somente para limitação não estrutural claramente isolada, com:

- workaround documentado;
- risco aceito;
- teste específico;
- decisão explícita.

Não autoriza schema definitivo.

### FAIL

Qualquer falha em:

- integridade;
- versionamento histórico;
- provenance;
- lineage;
- transação;
- reprodutibilidade.

---

## 7. Saída

O resultado do Gate deverá produzir:

- `F2B_Test_Run_<data>_<id>.md`;
- artifacts de log;
- atualização do CHANGELOG;
- checkpoint específico;
- decisão de manter, revisar ou descartar OES-P1.

---

**F2-B permanece pendente até execução real.**
