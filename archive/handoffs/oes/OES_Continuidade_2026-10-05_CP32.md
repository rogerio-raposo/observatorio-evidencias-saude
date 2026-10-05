# OBSERVATÓRIO DE EVIDÊNCIAS EM SAÚDE — OES
## Registro de Continuidade — Fase 3

**Data do checkpoint:** 2026-10-05  
**Checkpoint:** CP32  
**Checkpoint anterior:** CP31  
**Status:** artefato de continuidade; não normativo  
**Escopo:** especificação, arquitetura, contrato e validação técnica do Evidence Scan N0  
**Ponteiro operacional:** `archive/handoffs/oes/README.md`

## 1. Marco do CP32

> **Evidence Scan — N0: contrato científico/funcional + arquitetura + contrato de dados + EvidenceScanView = PASS técnico**

> **ES-T01–T15: PASS**

> **Migration 013: idempotente e sem nova tabela/coluna**

> **Próximo estágio: contrato de renderização do Evidence Scan N0**

Base técnica validada:

`main @ a1aa98eec809f25add578ebf15ba6b40739d54ca`

Run final:

- GitHub Actions **37366556793**;
- attempt **2**;
- conclusion **success**;
- artifact **11368729267**;
- digest `sha256:f734fceca49c384cf5671b81919d2991d54b2a167b03a420b2c4f19db42f4a3c`.

## 2. Documentos desde CP31

- Documento 86 — especificação científica e funcional do Evidence Scan N0;
- Documento 87 — revisão de coerência e decisão arquitetural;
- Documento 88 — contrato de dados do Evidence Scan N0;
- Documento 89 — resultado da validação técnica do contrato: PASS.

## 3. Decisões arquiteturais consolidadas

- N0 reutiliza OES-P1;
- nenhuma nova tabela;
- nenhuma nova coluna;
- Question/Investigation/Search/SearchHit/Report/Product são reutilizados;
- componentes específicos do scan usam provenance controlada;
- EvidenceScanView é projeção própria;
- publication gate N0 é próprio;
- Synthesis não é obrigatória;
- CertaintyAssessment não é obrigatória;
- RiskAssessment formal não é obrigatório;
- maturidade, controvérsia, lacuna e routing não viram novas entidades na v0.1;
- migration 013 é funcional/projetiva.

## 4. Assurance e regimes operacionais

Scan interno de roteamento:

- pode encerrar em A1;
- não é publicação formal persistente.

Evidence Scan formal persistente:

- exige A2;
- exige owner governance approval;
- exige publication_date;
- disclosure de ausência de expert review permanece obrigatório quando A3 não existir.

## 5. Exceção `insufficient`

Foi validado que um scan pode não possuir Report central quando:

- existem Search records concluídas;
- maturidade = `insufficient`;
- a conclusão é sustentada por base rastreável nas buscas;
- a linguagem permanece exploratória;
- não há afirmação de ausência definitiva de evidência.

Esse comportamento passou no ES-T12.

## 6. Provenance

A primeira tentativa de ES-T12 revelou corretamente que provenance material não pode ser reescrita.

A correção preservou o modelo append-preserving:

- registro anterior `active → superseded`;
- novo provenance.record;
- vínculo por `supersedes_provenance_uuid`.

ES-T12 e ES-T13 passaram após essa correção.

## 7. Validação técnica

PASS confirmado para:

- ES-T01–T14;
- ES-T15 rebuild;
- EvidenceScanView;
- migration 013 idempotente;
- regressões F2-B/S4/S5;
- Ficha N2;
- Resposta N1;
- assurance A0–A3;
- provenance;
- casos reais N1/N2.

## 8. Estado da Fase 3

Produtos com trilha técnica consolidada:

1. Ficha de Evidência — N2;
2. Resposta de Evidência — N1;
3. Evidence Scan — N0 — contrato técnico validado; renderização e caso real ainda pendentes.

## 9. Não reabrir automaticamente

- N0 é exploratório e não exaustivo;
- N0 não é Resposta N1 abreviada;
- N0 não é Mapa de Evidências;
- N0 não é scoping review;
- field maturity é julgamento operacional, não score;
- lacunas são aparentes/preliminares;
- scan formal persistente exige A2;
- scan interno pode terminar em A1;
- ausência de Report central só é válida na exceção `insufficient` controlada;
- provenance permanece append-preserving.

## 10. Ponto exato de retomada

> **Fase 3 — formalizar o contrato de renderização do Evidence Scan — N0.**

Ordem:

1. definir conteúdo obrigatório da apresentação;
2. definir ordem semântica;
3. representar não exaustividade;
4. representar maturidade/controvérsias/lacunas;
5. representar routing;
6. definir comportamento A1 interno versus A2 publicado;
7. definir comportamento `insufficient` sem Report central;
8. somente depois criar template operacional.

**Fim do CP32**