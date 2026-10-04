# 56 — Caso Real 01: Resultado da Validação Ponta a Ponta da Ficha de Evidência

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Nível:** N2  
**Status:** PASS estrutural/operacional; revisão científica humana pendente  
**Data:** 4 de outubro de 2026  
**GitHub Actions run final:** 37213165321  
**Commit testado:** `d9a2de71c9efed0722f9bf9698a42a374e8cd981`

---

# 1. Resultado

O primeiro Caso Real da Ficha de Evidência percorreu com sucesso a cadeia OES até a geração de um preview Markdown auditável.

> **Caso Real 01 — PASS estrutural/operacional ponta a ponta**

A cadeia validada foi:

`Question → Investigation N2 → Search → Screening → Study/Report → Result → Appraisal → Synthesis → Certainty → ProductVersion → Publication Gate → EvidenceSheetView → Markdown Preview`

A validação **não equivale à publicação científica da Ficha**.

O produto permanece:

- `under_review`;
- sem `publication_date`;
- sem revisão humana aprovada;
- `publishable = false`.

Esse bloqueio é deliberado e metodologicamente correto.

---

# 2. Pergunta validada

> Em adultos com insônia, dCBT-I totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia no pós-tratamento?

Produto:

`OES-P-2026-000401`

ProductVersion:

`81000000-0000-0000-0000-000000000701`

Roteamento:

- profundidade: **N2**;
- manutenção inicial: **M1**;
- data de corte: **2026-10-04**.

---

# 3. Evidência materializada

O dataset canônico do caso real representa diretamente seis unidades de evidência:

## Revisões sistemáticas

1. Hwang et al. 2025 — síntese comparador-específica adotada;
2. Gao et al. 2026 — triangulação externa corroborativa.

## RCTs

3. Sweetman et al. 2024;
4. SleepioRx / CrEDIT 2025;
5. SHUTi OASIS 2025;
6. Somzz 2024.

A contagem de Studies diretamente modelados no OES permanece conceitualmente distinta do `k` reportado por uma meta-análise externa.

No caso Hwang:

- Study diretamente modelado no OES: 1 revisão sistemática;
- `k` reportado no subgrupo focal: 10 estudos.

---

# 4. Syntheses representadas

## 4.1 Estimativa quantitativa adotada

Origem:

`adopted_external`

Fonte:

Hwang et al. 2025.

Estimativa:

- SMD = -0,93;
- IC95% -1,07 a -0,79;
- k=10;
- I²=68%.

Regra explícita:

> **não recalculada pelo OES.**

## 4.2 Síntese corroborativa externa

Fonte:

Gao et al. 2026.

Uso:

- confirmação da direção;
- triangulação da magnitude;
- observação de efeitos menores em parte dos estudos mais recentes.

Não substitui a estimativa comparador-específica de Hwang.

## 4.3 Atualização narrativa OES

Origem:

`oes_update`

Função:

- integrar RCTs recentes;
- preservar direção;
- descrever variação de magnitude;
- evitar pooling incompleto ou dupla contagem.

Regra:

> **nenhuma nova meta-análise foi calculada pelo OES.**

---

# 5. Appraisal representada

## ROBIS

Hwang 2025:

> **unclear risk of bias**

Questão central:

- inconsistência entre cutoff declarado e presença de publicação posterior na revisão.

## RoB 2

Quatro RCTs decisivos:

- Sweetman — algumas preocupações;
- SleepioRx — algumas preocupações;
- SHUTi OASIS — algumas preocupações;
- Somzz — algumas preocupações.

Todas as avaliações permanecem marcadas para:

> **revisão humana obrigatória.**

---

# 6. GRADE provisório

Outcome:

> gravidade da insônia no pós-tratamento.

Ponto inicial:

> alta certeza — RCTs.

Julgamentos provisórios:

- risk of bias: rebaixar 1;
- inconsistency: não rebaixar para a conclusão direcional;
- indirectness: não rebaixar;
- imprecision: não rebaixar;
- publication bias: não rebaixar.

Resultado provisório:

> **MODERADA**

Significado operacional:

> há confiança moderada de que a dCBT-I totalmente automatizada reduz a gravidade da insônia em comparação com educação digital sobre sono, mas a magnitude exata do benefício varia e permanece mais incerta que sua direção.

Essa classificação:

- não está publicada;
- não recebeu aprovação humana;
- não poderá ser promovida silenciosamente.

---

# 7. Publication gate

O Caso Real 01 foi construído para testar também um produto cientificamente completo, porém ainda não aprovado para publicação.

O gate retornou:

> **publishable = false**

Bloqueios esperados:

- `MISSING_APPROVED_REVIEW`;
- `MISSING_PUBLICATION_DATE`.

Esses bloqueios foram mantidos deliberadamente.

Não foram utilizados:

- revisão humana fictícia;
- data de publicação fictícia;
- bypass do gate.

---

# 8. EvidenceSheetView

O caso real foi projetado pelo:

`product.evidence_sheet_view(uuid)`

A projeção preservou:

- Product identity;
- Question;
- Investigation N2/M1;
- buscas;
- unidades de evidência por tipo;
- três Syntheses com papéis distintos;
- ROBIS/RoB 2;
- GRADE provisório;
- limitações;
- aplicabilidade;
- atualidade;
- referências;
- provenance;
- audit trail;
- publication issues.

---

# 9. Hardening revelado pelo caso real

O caso real identificou necessidades que a fixture sintética não exercitava plenamente.

## Migration 008

`database/008_evidence_sheet_provenance_references.sql`

Função:

> tornar `references[]` consciente de provenance/lineage.

Isso permite recuperar Reports que sustentam a Ficha por dependência científica, não apenas por ResultSource direto.

## Migration 009

`database/009_evidence_sheet_view_evidence_counts.sql`

Função:

> expor contagens por `study_type`.

Isso evita apresentar uma revisão sistemática materializada como se fosse um estudo primário.

### Natureza das migrations

008/009 são:

- compatíveis;
- idempotentes;
- de projeção;
- sem nova entidade científica canônica.

O modelo científico OES-P1 não precisou de nova entidade para representar:

> **síntese externa adotada + atualização narrativa OES.**

---

# 10. Arquivos canônicos do Caso Real 01

## Dataset

`database/f3-real-case-01-dcbti.sql`

SHA-256 validado:

`3c76de30af3d5f4d74982ef414eb9590cce8b4f1544842f2929f2c2e31a99ecf`

## Testes

`database/f3-real-case-01-tests.sql`

SHA-256:

`ea9042deeafd9c7b38e5a71232ba31e9e3604e1947e1183f2ff5503a00013bc8`

## Rebuild check

`database/f3-real-case-01-rebuild-check.sql`

SHA-256:

`185e2e7551b8c05b4002e2eaad14994ed3e2cf2439e00ed3617d7ac53baccfae`

---

# 11. Testes RC01

## RC01-T01

Meta-análise externa permanece explicitamente adotada e não recalculada.

> PASS

## RC01-T02

Atualização com RCTs permanece narrativa e sem pooling estatístico OES.

> PASS

## RC01-T03

Contagem de Studies diretamente modelados permanece distinta do `k=10` da meta-análise externa.

> PASS

## RC01-T04

GRADE provisório moderado está vinculado à atualização OES.

> PASS

## RC01-T05

Publication gate bloqueia corretamente publicação sem revisão humana e data de publicação.

> PASS

## RC01-T06

Papéis de síntese:

- source;
- primary;
- corroborative.

permanecem distintos.

> PASS

## RC01-T07

ROBIS/RoB 2 estão representados e marcados para revisão humana.

> PASS

## RC01-T08

Lineage Report → Result → Synthesis → Certainty/Product é reconstruível.

> PASS

## RC01-T09

Hit counts brutos indisponíveis permanecem `NULL`; registros materiais capturados são explícitos.

> PASS

## RC01-T10

Rebuild do zero reconstrói o preview real não publicável.

> PASS

---

# 12. Render Markdown real

O workflow produziu:

- `rc01-evidence-sheet-view.json`;
- `rc01-evidence-sheet-preview.md`;
- logs de validação.

O preview:

- contém aviso **PREVIEW — NÃO PUBLICÁVEL**;
- expõe publication issues;
- preserva estimativa adotada;
- informa que a meta-análise não foi recalculada pelo OES;
- apresenta atualização narrativa separadamente;
- expõe certainty provisória;
- mantém auditabilidade.

Resultado:

> **Real N2 Evidence Sheet blocked preview PASS**

---

# 13. Regressões

No mesmo run:

- F2-B regression: PASS;
- S4 regression: PASS;
- S5-T01–T17: PASS;
- F3-FE-T01–T17: PASS;
- F3-VIEW-T01–T17: PASS;
- F3-PROV-T01–T06: PASS;
- F3-TEMPLATE: PASS;
- RC01-T01–T10: PASS;
- migrations 008/009 idempotentes: PASS;
- rebuild through migration 009: PASS.

---

# 14. Evidência de execução

GitHub Actions:

- run: **37213165321**;
- commit: `d9a2de71c9efed0722f9bf9698a42a374e8cd981`;
- conclusão: **success**.

Artifact:

- ID: **11307386757**;
- nome: `oes-s5-evidence-37213165321`;
- digest: `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`;
- tamanho: 24972 bytes;
- retenção: 30 dias.

---

# 15. O que foi validado

O caso demonstrou que o OES consegue:

1. receber pergunta clínica focal;
2. estruturá-la em N2;
3. registrar busca sem inventar contagens;
4. materializar revisão e estudos primários;
5. distinguir Study de Report;
6. adotar criticamente meta-análise externa;
7. atualizar a evidência sem fingir novo pooling;
8. registrar ROBIS e RoB 2;
9. criar GRADE próprio;
10. preservar provenance/lineage;
11. construir ProductVersion;
12. bloquear publicação quando revisão humana falta;
13. gerar EvidenceSheetView;
14. renderizar preview legível;
15. reconstruir tudo do zero.

---

# 16. O que ainda NÃO foi validado

Este PASS não significa:

- aprovação humana da GRADE;
- aprovação humana da conclusão;
- publicação científica da Ficha;
- recomendação clínica;
- validação de segurança como outcome;
- validação de todos os tipos de pergunta do OES;
- maturidade definitiva do template.

O produto continua experimental/em desenvolvimento.

---

# 17. Próxima etapa

A próxima etapa deve ser:

> **Revisão Humana Metodológica do Caso Real 01**

Essa etapa deverá revisar explicitamente:

1. ROBIS de Hwang;
2. RoB 2 dos quatro RCTs;
3. decisão de não executar nova meta-análise;
4. downgrade por risk of bias;
5. não downgrade por inconsistency;
6. não downgrade por indirectness;
7. não downgrade por imprecision;
8. julgamento de publication bias;
9. certainty final;
10. redação da conclusão;
11. principais limitações;
12. aplicabilidade.

Até essa revisão:

> **o gate deve permanecer bloqueado.**

---

**Resultado final:** PASS estrutural/operacional ponta a ponta; validação científica humana ainda pendente.
