# 43 — Resultado da Validação do Contrato da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** PASS  
**Data:** 4 de outubro de 2026  
**Contrato:** Documento 42  
**GitHub Actions run:** 37191456703  
**Commit testado:** `7649546e3e86c4989e26e6c3a381d15e04e22f82`

---

# 1. Resultado

A extensão física do contrato da Ficha de Evidência foi executada em PostgreSQL 18.6.

> **Contrato físico da Ficha de Evidência = PASS**

Foram aprovados:

- migration 006;
- regressão F2-B;
- regressão S4;
- regressão S5;
- testes específicos da Ficha;
- gate de publicação;
- rebuild do zero;
- detecção de reaplicação da migration.

---

# 2. Ambiente

- PostgreSQL server: **18.6**
- serviço: `postgres:18`
- GitHub Actions run: **37191456703**
- conclusão: **success**

---

# 3. Artefatos principais

| Arquivo | SHA-256 |
|---|---|
| `database/006_product_evidence_sheet_contract.sql` | `e3ab7f0ae573e798dc894744aa79e90ad05c0fb59bfe5fe5f232350836585f1b` |
| `database/f3-evidence-sheet-fixtures.sql` | `b349a37eab51058909d62d1b51bfc7b9b3fb4d7923ca3d42265605c5e3dfe43d` |
| `database/f3-evidence-sheet-tests.sql` | `2d72ee41c827ee4c17f39cf034185bcbb547a056e65e05ccec3042786e4ae19b` |
| `database/f3-evidence-sheet-rebuild-check.sql` | `f19e226cd192ad6914455710cf68be47b7ced0e57d174c1bebdd3a8a700f12a3` |

---

# 4. Capacidades adicionadas

## 4.1 Limitations summary

`ProductVersion` recebeu:

`limitations_summary`

Resultado:

> persistência validada.

## 4.2 Estado de atualidade

Criado:

`product.currency_state`

com:

- histórico por supersessão;
- apenas um registro ativo por ProductVersion;
- view `product.current_currency_state`.

Resultado:

> histórico + projeção corrente validados.

## 4.3 Classes de mudança

Criado:

`product.version_change_class`

Resultado:

> múltiplas classes simultâneas validadas.

## 4.4 Revisão humana

Criado:

`product.review_record`

Resultado:

> revisão aprovada e rejeição bloqueante validadas.

## 4.5 Investigation primária

Criado índice que limita a uma Investigation `primary` por ProductVersion.

Resultado:

> invariant validada.

## 4.6 Gate de publicação

Criadas:

- `product.evidence_sheet_publication_issues(...)`
- `product.evidence_sheet_is_publishable(...)`

O gate é avaliativo.

Ele:

- não publica automaticamente;
- retorna issues;
- separa erro bloqueante de warning;
- mantém a transição editorial como ação explícita.

---

# 5. Testes específicos

## F3-FE-T02

Limitations summary persistido.

> PASS

## F3-FE-T03

Estado editorial inválido rejeitado.

> PASS

## F3-FE-T04

Segundo CurrencyState ativo rejeitado.

> PASS

## F3-FE-T05

Histórico de atualidade preservado.

> PASS

## F3-FE-T06

Múltiplas classes de mudança coexistem.

> PASS

## F3-FE-T07

ReviewRecord aprovado persistido.

> PASS

## F3-FE-T08

Segunda Investigation primary rejeitada.

> PASS

## F3-FE-T09

Ficha incompleta expôs **4 issues bloqueantes**.

> PASS

## F3-FE-T10

Ficha completa retornou `publishable=true`.

> PASS

## F3-FE-T11

ReviewRecord `rejected` ativo bloqueou publicação; após supersessão, deixou de bloquear.

> PASS

## F3-FE-T12

Cutoff inconsistente foi detectado e, após restauração, publishability foi recuperada.

> PASS

## F3-FE-T16

Rebuild do zero preservou:

- 1 CurrencyState;
- 2 classes de mudança;
- 1 revisão aprovada;
- Ficha publishable.

> PASS

## F3-FE-T17

Reaplicação acidental da migration 006 foi detectada.

> PASS

---

# 6. Regressões

## F2-B

> PASS

## PoC-S4

> PASS

## PoC-S5

S5-T02–T15:

> PASS

S5-T17:

> PASS

S5 rebuild:

> PASS

Consequência:

> a extensão da camada de produtos não quebrou o baseline arquitetural da Fase 2.

---

# 7. Artifact

- Artifact ID: **11299032774**
- Nome: `oes-s5-evidence-37191456703`
- Digest: `sha256:2e3508b0d876e13e2f6efb367da8e8b308c943560e3d5e978fa293a8a4f851c1`
- Tamanho: 7234 bytes
- retenção configurada: 30 dias

O registro documental preserva os metadados essenciais além da vida útil do artifact.

---

# 8. Decisões confirmadas

1. O contrato científico do Documento 41 é implementável.
2. A Ficha pode ser validada fisicamente antes de renderização.
3. Estado editorial e atualidade permanecem separados.
4. Atualidade possui histórico próprio.
5. Mudanças científicas podem ter múltiplas classes.
6. Revisão humana é auditável.
7. Gate de publicação pode ser executado sem duplicar dados científicos.
8. N/M continuam derivados da Investigation.
9. Result/Synthesis/Certainty continuam canônicos fora do ProductVersion.
10. ProductRelation não é necessária para a primeira Ficha.
11. ApplicabilityAssessment formal pode continuar adiado.
12. O template não precisará criar campos científicos improvisados.

---

# 9. Próxima etapa

Com o contrato científico e físico aprovados, a próxima etapa será definir:

> **EvidenceSheetView — contrato de renderização da Ficha de Evidência**

Objetivos:

- definir o objeto de saída derivado;
- mapear cada seção do template;
- formalizar ordenação de outcomes/achados;
- formalizar mensagens para estados de certainty;
- formalizar apresentação de atualidade/versionamento;
- manter audit links;
- preparar o template operacional.

Após o EvidenceSheetView:

1. criar template;
2. executar validação estrutural;
3. testar com um caso real.

---

**Resultado final:** PASS.
