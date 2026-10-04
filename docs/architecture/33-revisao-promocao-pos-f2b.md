# 33 — Revisão de Promoção Arquitetural Pós-F2-B

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — revisão de promoção arquitetural  
**Data:** 4 de outubro de 2026

## 1. Finalidade

Avaliar o candidato físico OES-P1 após o GATE F2-B, confrontando as evidências efetivamente produzidas com os 15 critérios de promoção estabelecidos no Documento 25.

Objetivos:

- impedir promoção prematura;
- evitar expansão indiscriminada do schema;
- distinguir validação estrutural de requisito de produção;
- identificar o menor conjunto de PoCs ainda necessário;
- estabelecer caminho objetivo para fechamento da Fase 2.

## 2. Fontes de decisão

Esta revisão considera:

- Documento 21 — Modelo Lógico;
- Documento 22 — Validação por Casos de Uso;
- Documento 23 — GATE F2-A;
- Documento 25 — OES-P1 e critérios de promoção;
- Documento 27 — Plano F2-B;
- Documento 30 — Política de Migrações;
- Documento 31 — PoC-S2;
- Documento 32 — Resultado do GATE F2-B;
- F2B Test Run 2026-10-04 / run 37187885839;
- baseline e migrations em `database/`.

## 3. Escala de classificação

### VALIDADO

Existe prova de runtime suficientemente direta do critério no escopo arquitetural pretendido.

### PARCIALMENTE VALIDADO

A estrutura existe e/ou parte relevante foi executada, mas o cenário exigido pelo Documento 25 não foi exercitado integralmente.

### NÃO VALIDADO

O cenário ainda não possui implementação/execução suficiente para sustentar promoção.

### FORA DO ESCOPO IMEDIATO

Critério não necessário para decisão de baseline arquitetural neste momento. Essa classificação só pode ser usada quando não contrariar os critérios explícitos do Documento 25.

---

# PARTE I — MATRIZ DOS 15 CRITÉRIOS

## 4. Matriz consolidada

| # | Critério do Documento 25 | Estado | Evidência / lacuna |
|---|---|---|---|
| 1 | criação de Question/Investigation | **VALIDADO** | fixtures F2-B criam Question, Investigation e vínculo versionado; cadeia executada em PostgreSQL |
| 2 | ingestão de SearchHits | **VALIDADO** | PoC-S2 + fixtures + T18/T19 |
| 3 | deduplicação | **VALIDADO** | DedupCluster preserva dois SearchHits/raw payloads; T18 PASS |
| 4 | Study com múltiplos Reports | **VALIDADO** | PoC-S4: Study A ligado a 2 Reports; S4-T02 PASS |
| 5 | Report com múltiplos Studies | **VALIDADO** | PoC-S4: Report X ligado a 2 Studies; S4-T03 PASS |
| 6 | Result com proveniência | **VALIDADO** | ResultSource + provenance.record + T11/T12 |
| 7 | síntese quantitativa | **VALIDADO** | PoC-S4: Synthesis v1 combinou Results de 2 Studies distintos; S4-T04 PASS |
| 8 | NMA | **VALIDADO** | PoC-S5: StudyGroup, Nodes, NodeMappings, Contrasts, 2 Studies contribuintes e lineage até Product; S5-T02–T06 PASS |
| 9 | predição | **VALIDADO** | PoC-S5: PredictionModel versionado, roles, Results de performance em 2 Studies e lineage até Product; S5-T07–T10 PASS |
| 10 | qualitativa/CERQual | **VALIDADO** | PoC-S5: ReviewFinding, 2 FindingContributions, 4 domínios CERQual e lineage até Product; S5-T11–T14 PASS |
| 11 | certainty | **VALIDADO** | CertaintyAssessment + CertaintyDomain executados; regra `no_evidence` testada em T09 |
| 12 | Product/Ficha | **VALIDADO** | ProductVersion + links a Investigation/Synthesis/Certainty executados |
| 13 | nova versão por atualização | **VALIDADO** | T10 valida cadeia v1→v2 Result/Synthesis/Certainty/Product preservando histórico |
| 14 | retração e impact analysis | **VALIDADO** | PoC-S4: ReportRelation, versões corrected/retracted e impact traversal até Product; S4-T07–T13 PASS |
| 15 | reconstrução completa de lineage | **VALIDADO** | F2-B + S4 + S5 demonstram lineage no núcleo, retração/impacto, NMA, predição e Qualitativa/CERQual |

## 5. Resultado quantitativo da revisão

Dos 15 critérios:

- **15 VALIDADO**;
- **0 PARCIALMENTE VALIDADO**;
- **0 NÃO VALIDADO**;
- **0 FORA DO ESCOPO IMEDIATO**.

A categoria “fora do escopo imediato” não foi usada porque todos os 15 itens foram explicitamente definidos como critérios de promoção pelo Documento 25.

---

# PARTE II — INTERPRETAÇÃO

## 6. O que o F2-B demonstrou

O F2-B removeu dúvidas estruturais centrais sobre:

- identidade e versionamento;
- FKs e tipagem;
- provenance;
- lineage;
- Search/Screening/Dedup;
- RiskAssessment;
- Certainty;
- Product;
- rebuild;
- rollback;
- migrations incrementais.

Isso justifica tratar OES-P1 como:

> **candidato físico tecnicamente viável e validado em seu núcleo transversal.**

## 7. O que ainda impede promoção

A promoção integral passa a depender apenas do Grupo B de lacunas. O Grupo A foi fechado pela PoC-S4.

### Grupo A — Relações e propagação

Inclui:

- Study com múltiplos Reports;
- Report com múltiplos Studies;
- síntese quantitativa multiestudo;
- retração/correção documental;
- impact analysis;
- lineage através dessas alterações.

### Grupo B — Métodos especializados

Inclui:

- NMA;
- predição;
- qualitativa/CERQual;
- lineage e versionamento desses componentes.

Essas lacunas não justificam reescrever o núcleo já validado.

---

# PARTE III — MENOR CONJUNTO DE PoCs ADICIONAIS

## 8. PoC-S4 — Multiplicidade, síntese multiestudo e retração

### Objetivo

Validar o Grupo A sem ampliar o modelo além do necessário.

### Cenários obrigatórios

1. um Study com pelo menos dois Reports;
2. um Report que represente/relacione informação de mais de um Study quando metodologicamente legítimo;
3. dois ou mais Results de Studies distintos alimentando uma Synthesis;
4. correção de um Report;
5. retração/invalidação de um Report;
6. reconstrução de impacto até:
   - Result;
   - Synthesis;
   - Certainty;
   - Product;
7. nova versão dos objetos afetados, preservando histórico;
8. rebuild completo do cenário.

### Componentes físicos candidatos

- `ReportRelation`;
- eventuais extensões de `StudyReportLink`;
- fixtures multiestudo;
- testes de impact analysis;
- projeção de dependências reconstruível.

### Critérios de promoção cobertos

- 4;
- 5;
- 7;
- 14;
- parte restante do 15.

---

## 9. PoC-S5 — Métodos especializados mínimos

### Objetivo

Validar que OES-P1 acomoda os três métodos especializados explicitamente exigidos pelo Documento 25 sem deformar o núcleo relacional.

### Trilhas

#### S5-A — NMA

Implementar o mínimo necessário de:

- SynthesisNode;
- SynthesisNodeMapping;
- SynthesisContrast;
- contribuição/resultados;
- lineage.

Não é necessário implementar motor estatístico completo de NMA nesta fase. O objetivo é validar representação, identidade, versionamento e proveniência.

#### S5-B — Predição

Implementar o mínimo necessário de:

- PredictionModel;
- PredictionModelIdentifier;
- PredictionModelStudyRole;
- resultados de performance vinculados;
- RiskAssessment/Certainty quando aplicável;
- lineage.

#### S5-C — Qualitativa/CERQual

Implementar o mínimo necessário de:

- ReviewFinding;
- FindingContribution;
- synthesised finding;
- Certainty/Confidence compatível com CERQual;
- provenance e lineage.

### Critérios de promoção cobertos

- 8;
- 9;
- 10;
- parte restante do 15.

---

# PARTE IV — O QUE NÃO É REQUISITO DE PROMOÇÃO ARQUITETURAL

## 10. Requisitos de produção

Os itens abaixo são importantes, mas não deverão bloquear indevidamente a decisão de baseline arquitetural se os 15 critérios científicos/estruturais forem satisfeitos:

- autenticação/autorização completa;
- alta disponibilidade;
- disaster recovery;
- observabilidade de produção;
- tuning de performance em escala real;
- SLO/SLA;
- deployment multiambiente;
- política final de backup;
- hardening de segurança operacional;
- seleção definitiva de cloud/provider.

Esses itens pertencem a decisão de **produção**, não à prova de adequação do modelo físico ao domínio científico.

## 11. Requisitos que permanecem transversais

Mesmo antes de produção, continuam obrigatórios:

- migrations versionadas;
- rollback/rebuild;
- proveniência;
- histórico;
- integridade;
- testes de invariantes;
- separação canônico/derivado;
- auditabilidade.

---

# PARTE V — DECISÃO DE PROMOÇÃO

## 12. OES-P1

Estado após esta revisão:

> **NÃO PROMOVIDO. MANTIDO COMO CANDIDATO FÍSICO VALIDADO.**

Justificativa:

- núcleo transversal é tecnicamente viável;
- F2-B passou;
- 8 dos 15 critérios ainda não estão integralmente validados, sendo 5 parciais e 3 ausentes;
- a maior parte das lacunas pode ser testada por apenas duas PoCs adicionais.

## 13. OES-H1

Permanece:

> **ARQUITETURA CANDIDATA PREFERENCIAL PARA A FASE 2.**

Não é arquitetura de produção definitiva.

## 14. PostgreSQL

Permanece:

> **REFERÊNCIA DE IMPLEMENTAÇÃO VALIDADA PARA PROVA ARQUITETURAL.**

A escolha de produção deverá ocorrer em gate próprio posterior, considerando também requisitos operacionais.

---

# PARTE VI — CRITÉRIO DE FECHAMENTO DA FASE 2

## 15. Condição proposta

A Fase 2 poderá ser considerada tecnicamente pronta para decisão de fechamento quando:

1. PoC-S4 estiver concluída;
2. PoC-S5 estiver concluída;
3. todos os 15 critérios do Documento 25 estiverem classificados como VALIDADO, ou qualquer exceção estiver formalmente reclassificada por decisão metodológica explícita;
4. lineage/rebuild permanecerem íntegros após as extensões;
5. não houver defeito estrutural crítico aberto;
6. documentação e modelo lógico estiverem sincronizados;
7. houver decisão explícita sobre promoção do baseline arquitetural.

Isso não equivale a prontidão de produção.

---

# PARTE VII — PRÓXIMO PASSO

## 16. Ponto exato

Desenvolver:

> **PoC-S4 — Multiplicidade Study/Report, Síntese Multiestudo e Retração/Impact Analysis**

Princípio:

> **expandir somente o necessário para fechar critérios 4, 5, 7, 14 e 15.**

Nenhuma funcionalidade de interface, automação ampla ou infraestrutura de produção deverá ser introduzida nessa PoC.

---

**Decisão:** OES-P1 permanece candidato; duas PoCs controladas são suficientes, em princípio, para completar a avaliação de promoção arquitetural.


## 17. Atualização pós-PoC-S4

A PoC-S4 foi executada no GitHub Actions run **37188934837** e recebeu **PASS** em S4-T01–T15.

Registro:

`docs/architecture/35-resultado-poc-s4.md`

Consequência:

- critérios 4, 5, 7 e 14 promovidos para **VALIDADO**;
- critério 15 permanece **PARCIALMENTE VALIDADO**;
- critérios 8, 9 e 10 permanecem **NÃO VALIDADO**;
- próxima etapa exclusiva: **PoC-S5 — Métodos Especializados Mínimos**.


## 18. Atualização pós-PoC-S5

A PoC-S5 foi executada no GitHub Actions run **37189646452** e recebeu **PASS** em S5-T01–T17, com regressões F2-B e S4 também aprovadas.

Registro:

`docs/architecture/37-resultado-poc-s5.md`

Decisão subsequente:

`docs/architecture/38-decisao-promocao-fechamento-fase2.md`

Consequência:

- critérios 8, 9, 10 e 15 promovidos para **VALIDADO**;
- matriz final: **15/15 VALIDADO**;
- OES-P1 promovido a **baseline arquitetural da Fase 2**;
- Fase 2 encerrada no nível de baseline arquitetural;
- transição autorizada para Fase 3 — Produtos do Observatório.
