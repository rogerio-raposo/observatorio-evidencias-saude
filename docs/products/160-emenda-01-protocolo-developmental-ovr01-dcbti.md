# 160 — Emenda 01 ao Protocolo Developmental OVR-01: Currentness com Last-Search Date Não Verificável

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** Overview de Revisões  
**Caso:** OVR-01 — dCBT-I totalmente automatizada  
**Data:** 6 de outubro de 2026  
**Status:** emenda formal prospectiva ao Documento 149  
**Aplicação:** exclusivamente rota developmental interna A0/A1  
**Publicação:** não autorizada por esta emenda  
**Dependências:** Documentos 149–159; migration 019; CP69

---

## 1. Finalidade

Formalizar, antes de qualquer persistência real do OVR-01, o tratamento metodológico de uma Review elegível cuja data exata da última busca não pôde ser verificada nas fontes legitimamente acessíveis.

A situação concreta é:

> **Gao et al. 2026 — last-search date = não verificável no estado atual das fontes.**

A emenda evita dois erros simétricos:

1. inventar ou inferir uma data não observada;
2. impedir indefinidamente um produto developmental interno apesar de a arquitetura conseguir representar explicitamente a incerteza.

---

## 2. Fato que não é alterado

O status científico de C2 permanece:

> **C2 = BLOCKED / NOT_VERIFIED.**

Esta emenda:

- não converte C2 em PASS;
- não presume a data da busca;
- não usa data de submissão, aceite ou publicação como proxy;
- não afirma currentness conhecida para Gao;
- não reduz os requisitos da rota formal/publicável.

A ausência da informação permanece uma limitação explícita do corpus.

---

## 3. Base arquitetural

A migration 019 já permite representar, sem violação de schema:

- `last_search_date = NULL`;
- `currentness_status = 'unclear'`;
- `currentness_rationale` obrigatória quando currentness não é `current`.

O publication gate preserva:

> **MISSING_LAST_SEARCH_DATE — error**

para ReviewItem ativo sem `last_search_date`.

Logo, a infraestrutura diferencia corretamente:

> **persistência developmental honesta** ≠ **publicabilidade**.

---

## 4. Escopo da emenda

A Emenda 01 aplica-se somente ao:

- OVR-01;
- estado developmental interno;
- assurance A0 inicial;
- eventual A1 após verificação metodológica por IA;
- `publishable=false`;
- `publication_date=NULL`.

Não se aplica a:

- rota formal do Overview;
- publicação;
- A2;
- A3;
- qualquer declaração de revisão humana inexistente;
- qualquer outro caso futuro sem decisão metodológica própria.

---

## 5. Regra substitutiva para C2 na autorização de persistência developmental

Para o OVR-01 developmental, a ausência de `last_search_date` em Gao deixa de ser blocker absoluto de **persistência**, desde que todas as condições abaixo sejam simultaneamente satisfeitas:

1. `last_search_date = NULL`;
2. `currentness_status = 'unclear'`;
3. `currentness_rationale` registre explicitamente que a data exata da última busca não foi verificável nas fontes acessíveis;
4. nenhuma data aproximada seja inferida;
5. a proveniência da tentativa de verificação permaneça registrada;
6. `MISSING_LAST_SEARCH_DATE` continue ativo como publication issue/error;
7. `publishable=false`;
8. `publication_date=NULL`;
9. nenhuma promoção para A2/A3 seja permitida por esta exceção;
10. a rota formal continue bloqueada.

Esta regra é uma exceção controlada de persistência developmental, não uma redefinição de C2.

---

## 6. Currentness de Gao

A representação autorizada é:

```text
last_search_date = NULL
currentness_status = unclear
currentness_rationale =
  "Exact last-search date could not be verified in the accessible
   primary/public bibliographic sources; no date was inferred."
```

Uma implementação poderá usar redação equivalente, desde que preserve integralmente o significado.

---

## 7. Publication blocker obrigatório

Enquanto `last_search_date` permanecer ausente:

> **OVR-01 não pode ser publicado.**

O publication gate deve continuar produzindo:

> **MISSING_LAST_SEARCH_DATE — error**

A presença desse erro, no contexto developmental A0/A1, é:

- esperada;
- declarada;
- não mascarada;
- não convertida em warning apenas para facilitar publicação.

---

## 8. Relação com o Documento 149

O Documento 149 permanece canônico para o protocolo developmental, exceto no ponto específico em que C2 era tratado como condição absoluta pré-persistência.

A partir desta emenda, a leitura correta é:

> **C2 continua obrigatório para publicabilidade e permanece epistemicamente NOT_VERIFIED; para persistência developmental A0/A1, pode ser representado como missing/unclear sob as salvaguardas desta Emenda 01.**

Nenhuma outra regra do Documento 149 é alterada.

---

## 9. Relação com os Documentos 150 e 159

O Documento 150 permanece correto ao registrar:

> **C2 = BLOCKED / NOT_VERIFIED.**

O Documento 159 permanece correto ao registrar:

> **READY_WITH_AMENDMENT_REQUIRED.**

Esta Emenda 01 satisfaz exatamente a condição documental exigida pelo Documento 159 antes de qualquer micro-gate de persistência.

---

## 10. Condições que permanecem vinculantes

A autorização eventual de persistência continua condicionada ao conjunto já fechado em C1–C12, incluindo:

- corpus analítico Hwang 2025 + Gao 2026 + Nazari 2025;
- membership completeness estrutural completa, com incerteza de identidade documentada;
- nenhuma identidade humana ficticiamente verificada;
- overlap strategy `include_all_separate_estimates`;
- CCA somente derivado pelo banco após memberships legítimas;
- comparadores preservados sem colapso indevido;
- Hwang ROBIS = unclear;
- Gao ROBIS = unclear;
- Nazari ROBIS = high;
- certainty = NULL quando não reportada;
- materialização rastreável de Nazari;
- nenhuma nova meta-analysis.

---

## 11. Micro-gate obrigatório

Esta emenda:

> **não autoriza por si só a persistência do OVR-01.**

O passo imediatamente posterior é um micro-gate que deve verificar:

1. validade prospectiva da emenda;
2. compatibilidade com migration 019;
3. preservação do publication blocker;
4. manutenção de todas as demais condições C1–C12;
5. ausência de entidades OVR-01 criadas antes da emenda;
6. escopo exato da primeira persistência A0.

Somente se esse micro-gate resultar em autorização explícita poderá ocorrer persistência real.

---

## 12. Rota formal

A rota formal permanece:

> **NOT_READY.**

Nenhuma disposição desta emenda altera requisitos de:

- busca formal;
- controles humanos;
- completeness formal;
- assurance A3;
- publicação.

---

## 13. Decisão

> **EMENDA 01 APROVADA PARA USO PROSPECTIVO NO OVR-01 DEVELOPMENTAL.**

C2 permanece:

> **BLOCKED / NOT_VERIFIED.**

A persistência ainda depende do micro-gate seguinte.

---

**Resultado final:** a ausência de last-search date de Gao passa a ser representável de forma explícita e auditável na rota developmental A0/A1, sem inferência e sem enfraquecer o publication gate ou a rota formal.
