# 156 — Classificação C7 e Readiness C8 para OVR-01 dCBT-I

**Data:** 6 de outubro de 2026  
**Status:** fechamento preparatório C7–C8; sem CCA calculado  
**Dependências:** Documentos 149–155; migration 019; CP66

## 1. Finalidade

Classificar membership completeness (C7) e avaliar se a matriz preparatória está pronta para futura derivação canônica de overlap/CCA (C8), mantendo separadas:

- cobertura da lista de Studies;
- confiança de identidade;
- verification status;
- publication readiness.

## 2. Semântica da migration 019

`overview.review_item.membership_completeness` admite:

- complete;
- partial;
- unknown.

A função `overview.overlap_metrics` deriva CCA somente quando o cluster possui membership completeness `complete` e os requisitos aritméticos são satisfeitos.

Entretanto, o publication gate verifica separadamente:

- low-confidence Study identity;
- membership não human-verified;
- overlap verification humana qualificada.

Portanto:

> **complete membership não significa human-verified membership nem formal publication readiness.**

## 3. Evidência documental de cobertura

O Documento 155 contabiliza todas as linhas-fonte conhecidas:

- Hwang: 29 artigos -> 27 Study candidates;
- Gao: 15 linhas/trials -> 15 Study candidates;
- Nazari: 49 linhas -> 44 Study candidates;
- nenhuma linha-fonte conhecida permanece sem destino na matriz;
- aliases prioritários foram normalizados;
- multiple Reports confirmados foram colapsados;
- randomizações distintas críticas foram separadas.

## 4. C7 — Hwang

Todas as 29 linhas/artigos da Review foram contabilizadas e convertidas em 27 Study candidates.

Classificação preparatória:

> **membership_completeness = complete**

Qualificadores:

- identidade reconciliada por IA;
- ainda sem human verification;
- confidence deverá ser atribuída individualmente na futura persistência.

## 5. C7 — Gao

Os 15 trials do forest plot foram todos mapeados a 15 Study candidates.

Classificação preparatória:

> **membership_completeness = complete**

Qualificadores:

- last-search date continua desconhecida, mas isso é dimensão de currentness, não membership coverage;
- identidade ainda não human-verified.

## 6. C7 — Nazari

As 49 linhas da Tabela 1 foram todas reconciliadas em 44 Study candidates após cinco clusters confirmados de multiple Reports.

Classificação preparatória:

> **membership_completeness = complete**

Qualificadores:

- reconciliação AI-assisted;
- future confidence/verification permanece linha a linha;
- complete não implica ausência absoluta de risco residual de linkage.

## 7. Resultado C7

> **C7 = PASS — structural/documentary membership completeness = complete para Hwang, Gao e Nazari.**

Esse PASS é limitado à cobertura do corpus reportado pelas Reviews.

Não significa:

- human verification;
- formal overlap verification;
- publication readiness;
- A3.

## 8. Audit semantics

Mesmo com `review_item.membership_completeness='complete'`, a futura auditoria formal deverá permanecer bloqueada enquanto:

- memberships forem `unverified` ou `ai_verified` em vez de `human_verified`/`human_consensus`;
- não existir quality control humano independente de overlap;
- qualquer identity confidence low persistir;
- demais requisitos formais não forem satisfeitos.

Logo:

> o booleano auditável de publicação não deve ser confundido com o campo estrutural de completeness.

## 9. C8 — readiness para overlap/CCA

A matriz tem os elementos estruturais necessários para futura derivação canônica:

- três Reviews analíticas;
- lista Study-level completa de cada Review;
- 86 occurrences;
- 59 Study candidates únicos no estado preparatório;
- overlaps pairwise e triple identificáveis;
- aliases/multiple Reports já tratados nos clusters conhecidos.

Resultado:

> **C8 = READY_WITH_DOCUMENTED_CONDITIONS**

Condições:

1. materializar/reutilizar Study entities canônicas;
2. atribuir identity confidence linha a linha;
3. atribuir verification status sem simular humanos;
4. persistir ReviewItems com completeness `complete` somente após rechecagem contra o Documento 155;
5. persistir memberships uma vez por Study/Review;
6. deixar a função `overview.overlap_metrics` derivar o CCA;
7. validar o resultado derivado contra as contagens de input antes de qualquer apresentação.

## 10. CCA

> **Nenhum valor de CCA é calculado ou declarado neste documento.**

A fórmula canônica está na migration 019, mas o valor futuro deverá ser produzido pelo banco após materialização do conjunto de memberships.

Isso evita transformar uma matriz preparatória em verdade persistida prematuramente.

## 11. Pairwise overlap

Os counts preparatórios podem ser usados como controles de futura validação:

- Hwang × Gao: 6 Study candidates compartilhados;
- Hwang × Nazari: 17;
- Gao × Nazari: 9;
- triple intersection: 5.

Esses números são checks de input da matriz, não métricas canônicas persistidas.

## 12. C2 permanece independente

Gao last-search date:

> **BLOCKED / NOT_VERIFIED**

Isso impede currentness final de Gao e mantém aberto o gate pré-persistência, embora não altere C7.

## 13. Estado das condições C1–C12

- C1 = PASS;
- C2 = BLOCKED / NOT_VERIFIED;
- C3 = PASS;
- C4 = PASS;
- C5 = PASS_WITH_DOCUMENTED_UNCERTAINTY;
- C6 = PASS;
- C7 = PASS;
- C8 = READY_WITH_DOCUMENTED_CONDITIONS;
- C9 = pendente;
- C10 = pendente;
- C11 = pendente;
- C12 = pendente.

## 14. Persistência real

Continua proibido criar:

- Question OVR-01;
- Investigation OVR-01;
- Product OVR-01;
- ReviewItems;
- primary-study memberships;
- CCA/pairwise canônicos.

Motivos:

- C2 ainda bloqueado;
- C9–C12 ainda não fechados;
- gate pré-persistência do Documento 149 ainda aberto.

## 15. Próxima etapa

> **Fechar C9–C12: estratificação de comparadores, ROBIS de Gao, source provenance de cada OutcomeEvidence e certainty provenance; em paralelo, continuar tentativa legítima de resolver C2.**

Depois disso:

> executar o gate pré-persistência consolidado antes de qualquer entidade real do OVR-01.

**Resultado:** C7 = PASS; C8 = READY_WITH_DOCUMENTED_CONDITIONS; CCA não calculado.
