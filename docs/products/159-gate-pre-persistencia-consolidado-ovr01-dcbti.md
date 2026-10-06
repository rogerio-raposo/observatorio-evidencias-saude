# 159 — Gate Pré-Persistência Consolidado — OVR-01 dCBT-I

**Data:** 6 de outubro de 2026  
**Status:** **READY_WITH_AMENDMENT_REQUIRED**  
**Dependências:** Documentos 149–158; migrations 019–020; CP68

## 1. Finalidade

Consolidar C1–C12 e decidir se o Caso Real developmental OVR-01 pode avançar para persistência.

Decisões possíveis:

- READY_TO_PERSIST;
- READY_WITH_AMENDMENT_REQUIRED;
- NOT_READY_TO_PERSIST.

## 2. Resultado

> **READY_WITH_AMENDMENT_REQUIRED**

Motivo:

- C1 e C3–C12 estão fechados em estados compatíveis com a rota developmental;
- C2 permanece BLOCKED / NOT_VERIFIED;
- o protocolo atual exige C2 antes de persistir ReviewItem;
- o contrato técnico permite representar honestamente essa incerteza sem fabricar a data;
- portanto é necessária emenda explícita antes da persistência.

## 3. Estado C1–C12

| Condição | Estado |
|---|---|
| C1 Gao study list | PASS |
| C2 Gao last-search date | **BLOCKED / NOT_VERIFIED** |
| C3 Nazari screening | PASS |
| C4 Review inventory | PASS |
| C5 Study identity reconciliation | PASS_WITH_DOCUMENTED_UNCERTAINTY |
| C6 membership matrix | PASS |
| C7 membership completeness | PASS |
| C8 overlap/CCA readiness | READY_WITH_DOCUMENTED_CONDITIONS |
| C9 comparator stratification | PASS |
| C10 ROBIS | PASS_WITH_DOCUMENTED_LIMITATIONS |
| C11 source provenance | PASS_WITH_PREPARED_NAZARI_MATERIALIZATION |
| C12 certainty provenance | PASS_WITH_DOCUMENTED_LIMITATION |

## 4. C2 — tentativas realizadas

A data exata da última busca de Gao foi procurada em fontes públicas verificáveis, incluindo:

- PubMed;
- publisher page/preview;
- materiais indexados;
- buscas direcionadas por método/search date.

Foi possível confirmar:

- systematic review/meta-analysis;
- 15 RCTs;
- N=3507;
- publicação e método estatístico geral.

Não foi possível confirmar:

> **a data exata da última busca bibliográfica.**

Não foi usada inferência por:

- publication date;
- manuscript received date;
- latest included trial;
- latest reference year.

## 5. Semântica do contrato técnico

A migration 019 define:

- `last_search_date` como nullable;
- `currentness_status` obrigatório, incluindo `unclear`;
- rationale obrigatória quando currentness não é `current`.

Logo, o estado epistemicamente correto para Gao pode ser:

- `last_search_date = NULL`;
- `currentness_status = 'unclear'`;
- `currentness_rationale` = data de busca não verificável nas fontes acessíveis.

## 6. Publication gate

A mesma migration 019 gera:

> `MISSING_LAST_SEARCH_DATE` — error

quando ReviewItem ativo não possui last_search_date.

Portanto:

> **permitir Gao com data ausente em developmental OVR-01 não torna o produto publicável.**

O blocker ficará explicitamente preservado pelo gate.

## 7. Compatibilidade com a rota developmental

O Documento 146 autorizou rota developmental interna com:

- A0 inicial;
- under_review;
- publication_date NULL;
- publishable=false;
- blockers explícitos;
- nenhuma simulação de controles humanos.

Nesse contexto, representar currentness como `unclear` é metodologicamente preferível a:

- inventar data;
- excluir uma Review elegível apenas porque a data não está acessível;
- ou reduzir silenciosamente requisitos do produto.

## 8. Por que uma emenda é necessária

O Documento 149 e o Documento 150 trataram C2 como condição pré-persistência obrigatória.

Avançar sem alterar esse protocolo seria:

> **bypass metodológico.**

Logo, antes de qualquer persistência real, deve existir uma emenda formal que:

1. preserve a tentativa documentada de recuperar a data;
2. permita `last_search_date=NULL` somente na rota developmental;
3. exija `currentness_status='unclear'`;
4. exija rationale explícita;
5. preserve `MISSING_LAST_SEARCH_DATE` como publication blocker;
6. proíba publicação enquanto a data permanecer ausente;
7. não se aplique à rota formal.

## 9. Demais condições para persistência

Após a emenda, a persistência developmental deverá ainda respeitar:

- Hwang/Gao/Nazari como Reviews analíticas;
- membership completeness `complete` como cobertura estrutural;
- identity verification AI-only/unverified;
- nenhum human_verified;
- overlap strategy `include_all_separate_estimates`;
- CCA somente derivado pelo banco;
- Hwang estimate comparator-specific;
- Gao/Nazari estimates mixed-control;
- Hwang ROBIS unclear;
- Gao ROBIS unclear;
- Nazari ROBIS high;
- certainty NULL quando não reportada;
- Nazari Report/Result/ResultSource/ROBIS materializados de forma rastreável;
- nenhuma nova meta-analysis.

## 10. CCA

O gate não autoriza cálculo manual de CCA.

Após persistência legítima das memberships:

> usar `overview.overlap_metrics` e validar suas contagens contra 86 occurrences / 59 Study candidates como controle.

## 11. Assurance

Estado inicial obrigatório:

> **A0**

Eventual A1 somente após verificação metodológica real por IA.

Não criar:

- owner approval automático;
- human expert review;
- A2;
- A3.

## 12. Decisão operacional

Neste exato momento:

> **AINDA NÃO PERSISTIR OVR-01.**

Próximo passo obrigatório:

> **emendar formalmente o protocolo developmental para tratamento de last-search date não verificável.**

Somente depois da emenda:

> executar novo micro-gate e, se consistente, autorizar a persistência developmental A0.

## 13. Rota formal

Permanece:

> **NOT_READY**

A emenda developmental não relaxa o Overview formal.

## 14. Próxima etapa

> **Criar a Emenda 01 ao Protocolo OVR-01: currentness desconhecida por last-search date não verificável, com blocker de publicação obrigatório.**

---

**Resultado final:** gate consolidado = **READY_WITH_AMENDMENT_REQUIRED**; nenhuma entidade real OVR-01 autorizada antes da Emenda 01.
