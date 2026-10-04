# 32 — Resultado do GATE F2-B e Decisão Pós-PoC

**Projeto:** Observatório de Evidências em Saúde — OES  
**Status:** Documento vivo — decisão arquitetural  
**Data:** 4 de outubro de 2026

## 1. Objeto

Registrar a decisão decorrente da execução real do GATE F2-B sobre o candidato físico OES-P1.

Registro técnico detalhado:

`docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md`

## 2. Resultado do gate

O GATE F2-B foi executado em PostgreSQL descartável no GitHub Actions.

- Run: **37187885839**
- Run number: **9**
- Commit: `de168908d8fe311e64c07937dc70df36af39d910`
- PostgreSQL: **18.6**
- T01–T19: **PASS**
- Rebuild do zero: **PASS**
- Artifact: **11297272424**
- Artifact digest: `sha256:5381605d34064f95a2d4444e34d275b8c89ceb28a19cc915db104da9362c1d7c`

Classificação:

> **GATE F2-B — PASS**

## 3. O que foi validado

O gate forneceu evidência de runtime para:

- criação limpa do baseline;
- aplicação incremental das migrations;
- integridade referencial;
- tipagem de entidades;
- unicidade de versão corrente;
- supersessão histórica;
- invariantes de Result e Certainty;
- correção history-preserving de provenance;
- lineage canônico e projeção;
- rollback;
- rebuild a partir dos artefatos versionados;
- Search, SearchHit e DedupCluster;
- ScreeningDecision;
- RiskAssessment;
- cadeia operacional end-to-end até Product.

## 4. O que o PASS não significa

O PASS não implica:

- PostgreSQL escolhido definitivamente como stack de produção;
- OES-P1 convertido em schema final;
- OES-H1 promovida automaticamente a arquitetura definitiva;
- encerramento da Fase 2;
- autorização para automação ampla;
- validação de todos os métodos especializados do OES.

## 5. Relação com os critérios de promoção do Documento 25

O Documento 25 exige validação mais ampla antes de decisão definitiva, incluindo cenários como:

- múltiplos Reports/Studies;
- NMA;
- predição;
- qualitativa/CERQual;
- retração e impact analysis;
- reconstrução de lineage em cenários ampliados.

O F2-B cobre um subconjunto estrutural decisivo, mas não todo esse conjunto.

Portanto, o resultado correto não é “promover definitivamente”, e sim:

> **manter OES-P1 como candidato físico validado e habilitado para a próxima rodada controlada de avaliação arquitetural.**

## 6. Decisão

### OES-P1

**Status pós-F2-B:** candidato físico validado.

### OES-H1

**Status:** arquitetura candidata preservada.

### PostgreSQL

**Status:** referência de implementação validada para PoC; não stack de produção aprovada.

## 7. Regra de continuidade

A expansão do schema deixa de estar bloqueada pelo F2-B, mas não fica irrestrita.

Qualquer nova extensão deverá:

- responder a lacuna identificada nos critérios de promoção;
- usar migration incremental;
- ter teste correspondente;
- preservar identidade/versionamento/provenance/lineage;
- evitar antecipar features de produção sem necessidade arquitetural.

## 8. Próxima etapa

**Revisão de Promoção Arquitetural Pós-F2-B.**

Objetivo:

produzir uma matriz dos 15 critérios de promoção do Documento 25 com estados:

- validado;
- parcialmente validado;
- não validado;
- fora do escopo da promoção arquitetural imediata.

A partir dessa matriz será definido o menor conjunto seguinte de PoCs e o critério de fechamento da Fase 2.

---

**Decisão final deste documento:** F2-B aprovado; OES-P1 mantido como candidato físico validado, sem promoção definitiva.
