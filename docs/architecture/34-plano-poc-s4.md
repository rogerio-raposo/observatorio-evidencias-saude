# 34 — Plano e Desenho da PoC-S4: Multiplicidade, Síntese Multiestudo e Retração

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Plano de prova arquitetural — pré-implementação  
**Data:** 4 de outubro de 2026  
**Dependências:** Documentos 21, 22, 25, 30, 32 e 33  
**Critérios-alvo do Documento 25:** 4, 5, 7, 14 e 15

## 1. Finalidade

Validar, com a menor extensão física possível, as lacunas remanescentes do Grupo A identificadas na Revisão de Promoção Pós-F2-B:

1. Study com múltiplos Reports;
2. Report com múltiplos Studies;
3. síntese quantitativa com Results de múltiplos Studies;
4. correção/retração documental;
5. impact analysis até Product;
6. nova versão dos objetos derivados afetados;
7. lineage reconstruível após a mudança.

A PoC-S4 não introduzirá métodos especializados de NMA, PredictionModel ou qualitativa/CERQual; esses permanecem para PoC-S5.

## 2. Princípio de desenho

A PoC deverá preferir:

> **usar capacidades já existentes antes de criar novas tabelas.**

Já existem no candidato:

- `evidence.study_report_link` com cardinalidade N:M;
- `evidence.result_source`;
- `synthesis.contribution`;
- `core.entity_version`;
- `provenance.dependency_edge`;
- links versionados de Product.

A única lacuna física canônica diretamente identificada para os cenários S4 é:

> **`evidence.report_relation`**

O impact analysis será derivado do grafo de dependências e não armazenado como segunda fonte de verdade.

## 3. Migration proposta

Criar:

`database/004_poc_s4_report_relation_impact.sql`

### 3.1 evidence.report_relation

Campos mínimos:

- `relation_uuid uuid PRIMARY KEY`;
- `source_report_entity_uuid uuid NOT NULL FK → evidence.report`;
- `target_report_entity_uuid uuid NOT NULL FK → evidence.report`;
- `relation_type text NOT NULL`;
- `relation_date date`;
- `notes text`;
- `created_at timestamptz`;
- `status text`.

Tipos permitidos nesta PoC:

- `correction_of`;
- `retraction_of`;
- `expression_of_concern_for`;
- `update_of`;
- `supplement_to`.

Invariantes:

- source ≠ target;
- combinação source/target/type não se repete;
- ambas as pontas são Reports por FK tipada.

### 3.2 provenance.report_impact()

Criar função derivada:

`provenance.report_impact(report_entity_uuid)`

Objetivo:

- partir de todas as versões do Report alvo;
- caminhar recursivamente por `provenance.dependency_edge`;
- retornar versões downstream;
- informar profundidade e tipo de dependência;
- evitar ciclos por path visitado.

A função não grava estado canônico.

## 4. Cenário canônico S4

### Estudos

- Study A;
- Study B.

### Reports

- Report X — publicação que descreve Study A e Study B;
- Report A2 — follow-up adicional de Study A;
- Report C — correção de Report X;
- Report R — aviso de retração de Report X.

### Multiplicidade

Study A:

`Study A ↔ Report X`  
`Study A ↔ Report A2`

Report X:

`Study A ↔ Report X ↔ Study B`

### Resultados iniciais

- Result A v1 pertence a Study A e é extraído de Report X v1;
- Result B v1 pertence a Study B e é extraído de Report X v1.

### Síntese inicial

Synthesis v1 recebe:

- Result A v1;
- Result B v1.

O teste deverá demonstrar:

> `COUNT(DISTINCT Study) >= 2`

### Certainty e Product

- Certainty v1 referencia Synthesis v1;
- Product v1 referencia Synthesis v1 e Certainty v1.

## 5. Correção documental

Criar:

`Report C --correction_of--> Report X`

Report X recebe nova versão v2:

- v1 → superseded;
- v2 → current;
- publication/status identificam estado corrigido.

O histórico v1 permanece consultável.

A correção não deverá apagar Results anteriores.

## 6. Retração

Criar:

`Report R --retraction_of--> Report X`

Report X recebe nova versão v3:

- v2 → superseded;
- v3 → current;
- `publication_status='retracted'`.

O vínculo documental é registrado em `ReportRelation`.

## 7. Impact analysis

O impact analysis deve partir do **Report entity** alvo, abranger suas versões históricas e reconstruir os dependentes de Report X v1.

Caminho esperado:

`Report X v1 → Result A/B v1 → Synthesis v1 → Certainty v1 → Product v1`

A relação de retração informa qual Report foi afetado; o grafo informa quais versões downstream dependem de seu conteúdo.

## 8. Reavaliação pós-retração

Criar versões v2 de:

- Result A;
- Result B;
- Synthesis;
- Certainty;
- Product.

### Results v2

Devem preservar identidade e histórico, mas registrar estado inválido por retração da fonte.

Não apagar Result v1.

### Synthesis v2

Deve representar reanálise após invalidação das contribuições afetadas.

Para esta PoC é aceitável:

- nenhuma contribuição ativa de A/B;
- `result_summary` registrando ausência de evidência utilizável pós-retração.

### Certainty v2

- `evidence_state='no_evidence'`;
- `final_level=NULL`.

### Product v2

Deve apontar explicitamente para:

- Synthesis v2;
- Certainty v2.

Product v1 deve permanecer reconstruível com sua cadeia histórica original.

## 9. Dependency projection pós-retração

Adicionar edges para a cadeia v2 somente quando houver dependência semântica real.

A origem causal da reavaliação será representada por edge:

`Report X v3 → Result A/B v2`

tipo candidato:

`report_retraction_invalidates_result`

Depois:

`Result v2 → Synthesis v2 → Certainty v2 → Product v2`

## 10. Testes S4

### S4-T01 — Migration

Migration 004 aplica em instalação limpa de S1+S2+S3.

### S4-T02 — Study com múltiplos Reports

Study A deve ter pelo menos dois links ativos para Reports distintos.

### S4-T03 — Report com múltiplos Studies

Report X deve ter pelo menos dois links ativos para Studies distintos.

### S4-T04 — Síntese multiestudo

Synthesis v1 deve conter contribuições de pelo menos dois `study_entity_uuid` distintos.

### S4-T05 — Tipos de ReportRelation

Tipo fora do vocabulário permitido deve falhar.

### S4-T06 — Auto-relação

Report não pode relacionar-se consigo próprio.

### S4-T07 — Correção preserva histórico

Report X v1 permanece; v2 é current após a correção; v1 é superseded.

### S4-T08 — Retração preserva histórico

Report X v3 é current e retracted; v1/v2 permanecem históricas.

### S4-T09 — Relações correction/retraction

Report C e Report R devem apontar corretamente para Report X.

### S4-T10 — Impact analysis

`provenance.report_impact(Report X)` deve alcançar Results v1, Synthesis v1, Certainty v1 e Product v1.

### S4-T11 — Atualização pós-retração

Results/Synthesis/Certainty/Product v2 devem ser criados sem apagar v1.

### S4-T12 — Estado sem evidência

Certainty v2 deve aceitar `no_evidence + final_level NULL` e Product v2 deve apontar para a cadeia v2.

### S4-T13 — Lineage histórico e atual

Devem ser reconstruíveis simultaneamente:

- cadeia histórica v1;
- cadeia pós-retração v2.

### S4-T14 — Rebuild do zero

Baseline + migrations 002/003/004 + fixtures S4 devem reproduzir o cenário em banco limpo.

### S4-T15 — Reaplicação da migration

Reaplicação acidental da migration 004 deve falhar de modo detectável.

## 11. Critério de PASS

PoC-S4 = PASS somente se:

- S4-T01–T15 passarem;
- nenhuma FK/invariant estrutural for relaxada;
- histórico pré-retração permanecer reconstruível;
- impacto pós-retração for derivável;
- rebuild do zero passar;
- evidências forem arquivadas.

## 12. Decisão esperada

Se PASS:

- critérios 4, 5, 7 e 14 podem ser promovidos para **VALIDADO**;
- critério 15 pode ser reavaliado, mas somente será integralmente VALIDADO após PoC-S5 se métodos especializados ainda não tiverem lineage físico demonstrado.

---

**Próxima ação:** implementar migration 004, fixtures e testes S4 exatamente dentro deste escopo.
