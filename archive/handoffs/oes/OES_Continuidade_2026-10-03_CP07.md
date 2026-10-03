# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade Arquitetural

**Data do checkpoint:** 2026-10-03  
**Checkpoint:** CP07  
**Checkpoint anterior:** CP06  
**Status:** artefato de continuidade; **não normativo**  
**Escopo:** projeto OES — transição para modelo de dados  
**Ponteiro operacional de continuidade:** `archive/handoffs/oes/README.md`

---

# 1. Marco do CP07

Estado formal:

> **Fase 1 — Base metodológica inicial: CONSOLIDADA COMO DOCUMENTAÇÃO VIVA**  
> **Fase 2 — Modelo de Dados da Evidência: EM DESENVOLVIMENTO**  
> **Documento 20 — Modelo Conceitual de Dados: CONSOLIDADO COMO DOCUMENTO VIVO**

Base documental do checkpoint:

`main @ cdfab00969ff1b1be6e4463d205aeb0bfb26d091`

---

# 2. Novo artefato desde CP06

- `docs/architecture/20-modelo-conceitual-dados.md`

Também foram atualizados:

- `docs/architecture/README.md`
- `docs/README.md`
- `README.md`
- `CHANGELOG.md`

---

# 3. Entidades conceituais centrais

- Question — OES-Q
- Investigation — OES-I
- Search — OES-S
- Study — OES-ST
- Report — OES-RP
- Result — OES-RS
- Risk of Bias Assessment — OES-RB
- Synthesis — OES-SY
- Certainty Assessment — OES-CE
- Product — OES-P

Identificadores permanecem provisórios até o modelo lógico.

---

# 4. Separações arquiteturais obrigatórias

Preservar:

- Question × Investigation;
- Study × Report × Result;
- entidade científica × record operacional;
- Risk of Bias × Certainty;
- Synthesis × Product;
- valor relatado × valor derivado;
- objeto persistente × versão;
- evidência × apresentação.

---

# 5. Relações centrais

- Question 1:N Investigation;
- Investigation 1:N Search;
- Search N:M Report por Search Hit/Retrieval Record;
- Study 1:N Report;
- Study 1:N Result;
- Report N:M Result;
- Study/Result 1:N Risk of Bias Assessment conforme instrumento;
- Result N:M Synthesis por Synthesis Contribution;
- Synthesis 1:N Certainty Assessment ao longo do versionamento;
- Investigation N:M Product.

---

# 6. Objetos intermediários já identificados

- Search Hit / Retrieval Record;
- Report–Study Link;
- Result Source / Provenance Link;
- Synthesis Contribution.

Esses objetos não deverão ser eliminados se carregarem informação metodológica relevante.

---

# 7. Ficha de Evidência

Status:

> **candidata a unidade persistente central do conhecimento**

Ela não substitui entidades científicas.

Estrutura candidata:

`Question + Investigation vigente + sínteses + certeza + aplicabilidade + conclusão + data de corte + versão`

A decisão final sobre tratá-la como Product subtype ou Knowledge Object próprio permanece aberta.

---

# 8. Requisitos transversais

## Proveniência

Dados críticos deverão manter origem, localização, transformação, responsável, data e versão.

## Versionamento

Versões publicadas não serão sobrescritas silenciosamente.

## Imutabilidade histórica

Correções e atualizações deverão manter relação explícita com estados anteriores.

---

# 9. Invariantes para implementação futura

1. Study e Report não podem ser colapsados.
2. Result precisa de proveniência.
3. valor derivado não substitui o relatado.
4. Search precisa permanecer auditável.
5. Synthesis precisa possuir identidade própria.
6. Certainty Assessment precisa possuir identidade própria.
7. Ficha de Evidência não pode substituir Study/Synthesis.
8. histórico de versões não pode ser apagado.
9. data de corte deve ser preservada.
10. tecnologia não poderá redefinir retroativamente a metodologia.

---

# 10. Questões abertas prioritárias

- hierarquia Question/subquestion;
- Outcome como entidade reutilizável;
- vocabulários controlados para população/intervenção/exposição/comparador;
- representação de revisões sistemáticas externas;
- guideline/HTA/documentos regulatórios;
- dados qualitativos e Review Findings;
- natureza arquitetural da Ficha de Evidência;
- entidade de monitoramento;
- granularidade obrigatória de proveniência;
- regras de estado current/archived/superseded.

---

# 11. Ponto exato de retomada

## Modelo lógico de dados

Próxima tarefa:

1. validar e normalizar entidades do Documento 20;
2. resolver questões abertas que afetam cardinalidade;
3. definir atributos mínimos e chaves;
4. formalizar entidades associativas;
5. definir esquema de versionamento;
6. definir regras de identidade/deduplicação;
7. produzir primeiro modelo lógico ainda independente de SGBD específico.

Não escolher stack tecnológica antes desse fechamento.

---

# 12. Regra de retomada

1. consultar o ponteiro operacional;
2. ler este CP07;
3. executar Freshness Gate;
4. consultar `STATE.md`, Documento 20 e Documentos 13–15;
5. apresentar Diagnóstico de Continuidade;
6. retomar no modelo lógico de dados.

---

**Fim do CP07**
