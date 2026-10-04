# STATE — Estado Atual do Projeto OES

**Última atualização:** 4 de outubro de 2026  
**Fase:** Fase 2 — Modelo de Dados da Evidência  
**Status geral:** em desenvolvimento

## 1. Fonte canônica e continuidade

Este repositório é a fonte canônica do Observatório de Evidências em Saúde — OES.

As conversas podem desenvolver e revisar conteúdo, mas decisões persistentes devem ser consolidadas no repositório.

O `STATE.md` é um painel vivo.

Continuidade formal:

- ponteiro: `archive/handoffs/oes/README.md`;
- template: `archive/continuity/OES_Template_Abertura_Continuidade.md`;
- checkpoint vigente: **CP13 — 2026-10-04**.

## 2. Documentação consolidada

### Governança / fundamentos

- 00 — Documento de Concepção
- 01 — Escopo Científico e Taxonomia das Perguntas
- 02 — Arquitetura de Níveis de Investigação e Produtos
- 03 — Entrada, Triagem e Roteamento Metodológico

### Metodologia

- 10 — Busca e Recuperação
- 11 — Elegibilidade, Triagem e Seleção
- 12 — Risco de Viés e Qualidade Metodológica
- 13 — Extração e Estruturação de Dados
- 14 — Síntese de Evidências
- 15 — Certeza/Confiança no Corpo de Evidências

### Arquitetura e dados

- 20 — Modelo Conceitual
- 21 — Modelo Lógico
- 22 — Validação por Casos de Uso
- 23 — Checagem de Integridade
- 24 — Alternativas de Persistência
- 25 — Primeiro Desenho Físico Candidato
- 26 — PoC-S1
- 27 — Plano Formal de Testes F2-B
- 28 — Identidade e Versionamento
- 29 — Proveniência e Lineage
- 30 — Política de Migrações
- 31 — PoC-S2 Search/Screening/RiskAssessment
- 32 — Resultado do GATE F2-B e Decisão Pós-PoC
- F2B Test Run 2026-10-04 / run 37187885839

## 3. Gates

### GATE F2-A

**APROVADO.**

Modelo lógico candidato autorizado para prova física, com reservas metodológicas já documentadas.

### GATE F2-B

**PASS — 4 de outubro de 2026.**

Execução final:

- GitHub Actions run: **37187885839**
- commit: `de168908d8fe311e64c07937dc70df36af39d910`
- PostgreSQL server: **18.6**
- T01–T19: **PASS**
- rebuild do zero: **PASS**
- artifact: **11297272424**
- digest: `sha256:5381605d34064f95a2d4444e34d275b8c89ceb28a19cc915db104da9362c1d7c`

## 4. Arquitetura candidata

### OES-H1

**Status:** arquitetura candidata preservada.

### OES-P1

**Status:** candidato físico **validado no escopo do F2-B**.

O PASS do F2-B não promove OES-P1 a schema definitivo.

### PostgreSQL

**Status:** referência de implementação validada para PoC; nenhuma decisão definitiva de stack de produção.

## 5. Invariantes arquiteturais já confirmadas

- identidade estável separada de versão;
- no máximo uma versão `current` por entidade;
- supersessão dentro da mesma identidade;
- integridade de subtipos e FKs;
- Study/Report/Result separados;
- raw/source value separado de derived value;
- provenance como dado de primeira classe;
- correção de provenance history-preserving;
- dependency edge como projeção derivada;
- SearchHit preservado após deduplicação;
- Screening target tipado;
- RiskAssessment target tipado;
- cadeia Search → Product reconstruível;
- rebuild a partir de artefatos versionados;
- rollback transacional validado.

## 6. Fases

- Fase 0 — Concepção e fundamentos: base inicial consolidada;
- Fase 1 — Manual Metodológico: base inicial dos Documentos 10–15 consolidada;
- Fase 2 — Modelo de Dados da Evidência: **em desenvolvimento, F2-A e F2-B aprovados**;
- Fases 3–7: ainda não iniciadas formalmente.

## 7. Limites atuais

Ainda não constituem decisões finais:

- schema definitivo;
- stack tecnológica de produção;
- fechamento da Fase 2;
- NMA física completa;
- PredictionModel completo;
- qualitativa/CERQual física completa;
- ApplicabilityAssessment;
- monitoramento operacional;
- autenticação/autorização;
- backup/HA;
- migration ledger de ambiente persistente;
- política de CI/concurrency definitiva.

## 8. Próxima etapa

**Revisão de Promoção Arquitetural Pós-F2-B.**

Objetivos:

1. mapear os 15 critérios de promoção do Documento 25;
2. classificar cada um como validado, parcialmente validado, não validado ou fora do escopo imediato;
3. vincular evidências concretas;
4. identificar o menor conjunto de PoCs adicionais;
5. separar critérios de baseline arquitetural de requisitos de produção;
6. definir caminho para fechamento da Fase 2.

Até essa revisão, evitar expansão do schema sem vínculo explícito com uma lacuna de promoção.

## 9. Checkpoint vigente

**CP13 — 2026-10-04**

Arquivo:

`archive/handoffs/oes/OES_Continuidade_2026-10-04_CP13.md`

Cobertura principal:

- PoC-S2;
- migration PoC-S3 de provenance;
- execução real do F2-B;
- T01–T19 PASS;
- rebuild PASS;
- decisão de manter OES-P1 como candidato físico validado;
- ponto de retomada na revisão de promoção pós-F2-B.

