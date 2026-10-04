# 55 — Caso Real 01: Decisão Arquitetural para Síntese Externa Adotada + Atualização OES

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — validação científica ponta a ponta da Ficha  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Data:** 4 de outubro de 2026  
**Status:** decisão arquitetural consolidada

---

# 1. Problema observado no caso real

O Caso Real 01 não exige que o OES recalcule uma meta-análise do zero.

A estratégia metodológica definida foi:

> **adotar criticamente uma meta-análise externa comparador-específica e atualizá-la com RCTs recentes sem produzir um novo pooling artificial.**

Isso exige representar de forma transparente três níveis distintos:

1. a revisão sistemática publicada;
2. a estimativa quantitativa publicada nessa revisão;
3. a síntese interpretativa produzida pelo OES após atualização.

---

# 2. Regra já prevista pelo modelo lógico

O Documento 21 já estabelece que:

> `study_type = systematic_review`

é permitido quando uma revisão sistemática for unidade de análise do OES.

Portanto:

- Hwang et al. 2025 será representada como **Study** do tipo `systematic_review`;
- seu artigo será representado como **Report**;
- a estimativa comparador-específica publicada será representada como **Result**;
- ResultSource preservará a localização documental;
- ROBIS será ligado à revisão como unidade avaliada.

Não é necessário criar nova entidade canônica para “revisão externa”.

---

# 3. Representação da estimativa publicada

O subgrupo de Hwang será materializado como Result:

- Study: Hwang 2025;
- Outcome: gravidade da insônia;
- estimand: efeito pós-tratamento;
- measure: standardized_mean_difference;
- reported_value: -0,93;
- CI: -1,07 a -0,79;
- método: random-effects meta-analysis publicada;
- k=10 registrado no payload;
- I²=68% registrado no payload.

Esse Result significa:

> **resultado publicado de uma revisão sistemática externa.**

Ele não significa:

> meta-análise executada pelo OES.

---

# 4. Representação dos RCTs de atualização

Cada RCT materialmente relevante será representado como Study primário próprio.

Cada efeito extraído será um Result próprio com provenance documental.

Prioridade inicial:

- Sweetman 2024;
- SleepioRx 2025;
- SHUTi OASIS 2025.

Somzz 2024 será representado como Study elegível, mas sua contribuição incremental à síntese OES será marcada cautelosamente até a questão de possível dupla contagem com Hwang ser resolvida.

---

# 5. Synthesis OES

Criar uma Synthesis própria do OES com:

## synthesis_type

`adopted_meta_analysis_with_directed_update`

## synthesis_origin

`external_synthesis_adopted_and_updated`

## method

> critical adoption of comparator-specific published meta-analysis plus directed qualitative update with newer RCTs; no repooling.

## model

`no_new_pooling`

## result_summary

Deverá conter separadamente:

- base_estimate;
- base_source;
- update_direction;
- magnitude_interpretation;
- repooled=false;
- rationale_for_no_repooling.

---

# 6. SynthesisContribution

Contribuições terão papéis distintos.

## Revisão sistemática

`published_base_estimate`

## RCTs novos

`update_directional_evidence`

## Somzz, enquanto a duplicação permanecer incerta

`eligible_possible_overlap`

com:

- `included_main_analysis=false`;
- nota explícita sobre possível sobreposição com a síntese-base.

---

# 7. Regra de lineage

Lineage deverá reconstruir:

`Hwang Report → Hwang aggregate Result → OES Synthesis → OES Certainty → ProductVersion`

e, paralelamente:

`New RCT Report → New RCT Result → OES Synthesis → OES Certainty → ProductVersion`

Assim, o leitor consegue distinguir:

- o que foi publicado externamente;
- o que foi extraído pelo OES;
- o que foi interpretado pelo OES;
- o que não foi recalculado.

---

# 8. ROBIS

Hwang deverá possuir RiskAssessment próprio:

- framework: ROBIS;
- target: Study Hwang;
- global judgement: unclear risk of bias;
- domínios documentados conforme Documento 50.

O ROBIS não será convertido em Result.

---

# 9. RoB 2

Cada RCT decisivo deverá possuir RiskAssessment próprio.

Esses RiskAssessments não serão colapsados em um score.

A síntese textual do corpo poderá dizer:

> os estudos novos foram globalmente classificados como “algumas preocupações”.

---

# 10. GRADE

O GRADE do Caso Real 01 será uma CertaintyAssessment própria do OES vinculada à Synthesis atualizada.

Framework:

`GRADE`

Estado:

`evidence_available`

Initial level:

`high`

Final level provisório:

`moderate`

Domínios:

- risk_of_bias: downgrade 1;
- inconsistency: downgrade 0;
- indirectness: downgrade 0;
- imprecision: downgrade 0;
- publication_bias: downgrade 0.

Status editorial/científico:

> provisório até revisão humana.

---

# 11. Lacuna identificada no EvidenceSheetView

O `EvidenceSheetView 0.1` atualmente fornece:

- `study_count`;
- `included_studies[]`.

Em um produto que usa:

- 1 systematic review como unidade de análise;
- novos primary studies;

`study_count` sozinho pode ser interpretado incorretamente como número de estudos primários.

Exemplo:

> study_count = 4

poderia significar:

- 1 revisão sistemática contendo 10 RCTs;
- 3 RCTs novos.

Isso não equivale a “quatro RCTs”.

---

# 12. Decisão de correção

A fonte canônica não precisa mudar.

A correção deve ocorrer apenas na projeção.

Adicionar ao `evidence_base`:

`study_type_counts`

Formato:

```json
[
  {"study_type":"systematic_review","count":1},
  {"study_type":"primary_study","count":3}
]
```

Opcionalmente, também expor:

- `primary_study_count`;
- `systematic_review_count`.

A primeira implementação deverá preferir `study_type_counts`, pois preserva extensibilidade.

---

# 13. Regra de apresentação

Quando houver mais de um tipo de Study:

não mostrar apenas:

> Studies: 4

Mostrar:

> Unidades de evidência no OES: 4  
> — revisões sistemáticas: 1  
> — estudos primários: 3

E declarar, quando conhecido:

> a revisão sistemática-base sintetizou 10 comparações no subgrupo focal.

Esse último número pertence ao Result/Synthesis payload e não deve ser confundido com o número de Study identities materializadas individualmente no OES.

---

# 14. Impacto arquitetural

Esta correção:

- não cria nova entidade;
- não altera Study/Report/Result;
- não altera Synthesis;
- não altera certainty;
- não altera publication gate;
- não exige migration de dados canônicos;
- exige apenas evolução compatível do EvidenceSheetView/template.

---

# 15. Próxima etapa

1. evoluir o EvidenceSheetView para expor contagens por study_type;
2. ajustar o template;
3. validar regressões;
4. inserir o Caso Real 01 no baseline;
5. gerar preview under_review;
6. verificar publication gate.

---

**Decisão final:** revisão sistemática externa será Study quando unidade de análise; sua estimativa publicada será Result; a atualização OES será Synthesis própria e explicitamente não repooled.
