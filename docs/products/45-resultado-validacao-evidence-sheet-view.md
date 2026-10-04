# 45 — Resultado da Validação do EvidenceSheetView

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Status:** PASS  
**Data:** 4 de outubro de 2026  
**Contrato:** Documento 44  
**GitHub Actions run:** 37191973078  
**Commit testado:** `568591cfa0aceb332f4eca6ac33cee97fe3701ae`

---

# 1. Resultado

A projeção de renderização da Ficha de Evidência foi executada e validada em PostgreSQL 18.6.

> **EvidenceSheetView = PASS**

A execução validou:

- migration 007;
- função `product.evidence_sheet_view(uuid)`;
- contrato JSONB;
- identidade e versionamento;
- Question/Investigation primárias;
- N/M derivados;
- método/buscas;
- corpo de evidências;
- resultados prioritários;
- certainty;
- limitações/aplicabilidade/conclusão;
- atualidade e histórico;
- referências;
- audit trail;
- determinismo;
- rebuild;
- regressões das camadas anteriores.

---

# 2. Ambiente

- PostgreSQL server: **18.6**
- container: `postgres:18`
- GitHub Actions run: **37191973078**
- conclusão: **success**

Artifact:

- ID: **11298729618**
- nome: `oes-s5-evidence-37191973078`
- digest: `sha256:d3e53b35bccf3a89e5ee8621ff2d3fc5501d56b56e4a22b5aa8993e9897cbef9`
- tamanho: 8387 bytes
- retenção configurada: 30 dias

---

# 3. Artefatos principais

| Arquivo | SHA-256 |
|---|---|
| `database/007_evidence_sheet_view.sql` | `16b6ef54ae5225b640922d7fbc1d2a4ff6a2c5810d3f91d1363420abd7aa6fff` |
| `database/f3-evidence-sheet-view-tests.sql` | `77fae650a09d6520d275bd678b5b11207ec17793cfe754ab03d75b6f53bf4316` |
| `database/f3-evidence-sheet-view-rebuild-check.sql` | `446cc8720070368c8296dbfe5bffc0a3055a6ce70b38b8aedc5da35e74b8a1aa` |

---

# 4. Contrato validado

`product.evidence_sheet_view(product_version_uuid)`

retorna:

`jsonb`

com:

- `schema_version`;
- `identity`;
- `question`;
- `routing`;
- `method`;
- `evidence_base`;
- `priority_results`;
- `risk_of_bias`;
- `certainty_assessments`;
- `safety`;
- `limitations`;
- `applicability`;
- `conclusion`;
- `update_history`;
- `references`;
- `audit`.

Schema do contrato:

> `oes.evidence_sheet_view/0.1`

---

# 5. Testes do EvidenceSheetView

## F3-VIEW-T01/T02

JSONB válido e `schema_version` correto.

> PASS

## F3-VIEW-T03

Product ID e versão corretos.

> PASS

## F3-VIEW-T04/T05

Question e Investigation primárias corretas; N2/M1 derivados da Investigation.

> PASS

## F3-VIEW-T06

Resumo de busca correto.

> PASS

## F3-VIEW-T07

Study/Report contados separadamente e sem dupla contagem.

> PASS

## F3-VIEW-T08/T09

Synthesis prioritária correta e certainty GRADE moderada vinculada.

> PASS

## F3-VIEW-T10

Limitações, aplicabilidade e conclusão presentes.

> PASS

## F3-VIEW-T11

Estado de atualidade e classes de mudança expostos corretamente.

> PASS

## F3-VIEW-T12

Review, lineage e publishability expostos no bloco audit.

> PASS

## F3-VIEW-T13

Referências derivadas de ResultSource.

> PASS

## F3-VIEW-T14

Duas projeções sucessivas do mesmo estado produziram JSONB idêntico.

> PASS

## Produto inexistente

ProductVersion inexistente retorna `NULL`, sem inventar registro.

> PASS

## F3-VIEW-T16

Rebuild do zero produziu EvidenceSheetView válido e publishable.

> PASS

---

# 6. Idempotência da migration 007

A primeira execução integrada classificou incorretamente a reaplicação de `007_evidence_sheet_view.sql` como algo que deveria falhar.

Entretanto, a migration utiliza `CREATE OR REPLACE FUNCTION` e é deliberadamente idempotente.

O harness foi corrigido.

No run final:

> **reaplicação da migration 007 = PASS**

Classificação:

- comportamento esperado;
- não constitui falha de migration;
- não altera dados canônicos;
- mantém a projeção substituível de forma controlada.

---

# 7. Regressões

Na mesma execução:

- F2-B regression: **PASS**;
- PoC-S4 regression: **PASS**;
- PoC-S5 S5-T02–T15: **PASS**;
- migration 005 duplicate detection: **PASS**;
- Evidence Sheet contract F3-FE-T01–T17: **PASS**;
- migration 006 duplicate detection: **PASS**.

Consequência:

> a camada de renderização não rompeu nenhuma invariant do baseline científico/arquitetural anterior.

---

# 8. Rebuild

O rebuild executou:

1. baseline;
2. migrations 002–007;
3. fixtures F2-B;
4. fixtures S4;
5. fixtures S5;
6. fixture da Ficha;
7. checks S4;
8. checks S5;
9. check do contrato da Ficha;
10. check do EvidenceSheetView.

Resultados relevantes:

- S5 rebuild: PASS;
- F3-FE rebuild: PASS;
- F3-VIEW rebuild: PASS.

---

# 9. Decisões confirmadas

1. EvidenceSheetView é projeção, não fonte canônica.
2. JSONB é adequado ao contrato aninhado de renderização.
3. ProductVersion continua enxuto.
4. N/M continuam derivados da Investigation.
5. Question continua derivada da Investigation.
6. Results/Synthesis/Certainty continuam em suas entidades canônicas.
7. Atualidade e histórico chegam ao template sem duplicação.
8. Publication gate pode ser exposto diretamente.
9. Referências científicas podem ser derivadas de ResultSource.
10. A projeção é determinística.
11. Migration 007 é idempotente por desenho.
12. O template operacional pode ser desenvolvido sem introduzir novo armazenamento científico.

---

# 10. Próxima etapa

Com os Documentos 41–45 validados, fica autorizado desenvolver:

> **Especificação do Template Operacional da Ficha de Evidência**

O template deverá consumir apenas o EvidenceSheetView e componentes editoriais/visuais explicitamente permitidos.

A próxima etapa deverá definir:

- hierarquia visual;
- ordem das seções;
- camada de leitura rápida;
- camada de auditabilidade;
- regras de tabelas/cards de resultados;
- representação de certainty;
- representação de no-evidence;
- segurança/danos;
- limitações;
- aplicabilidade;
- atualidade;
- histórico;
- referências;
- alertas editoriais;
- regras de omissão/NA;
- saída Markdown inicial;
- futura equivalência para HTML/PDF/DOCX.

O template não poderá decidir ciência.

---

**Resultado final:** PASS.
