# 58 — Caso Real 01: Resultado da Materialização e Preview End-to-End

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Status:** PASS técnico/científico de materialização; publicação permanece bloqueada  
**Data:** 4 de outubro de 2026  
**GitHub Actions run:** 37213165321  
**Commit testado:** `d9a2de71c9efed0722f9bf9698a42a374e8cd981`

---

# 1. Resultado

O primeiro caso real da Ficha de Evidência foi materializado no baseline OES-P1 e executado ponta a ponta até o preview Markdown.

> **CASO REAL 01 — MATERIALIZAÇÃO E PREVIEW = PASS**

A execução confirmou simultaneamente:

- Question/Investigation N2 real;
- Search registrado;
- Study/Report/Result reais;
- síntese externa adotada sem simular recálculo OES;
- atualização narrativa OES separada;
- ROBIS/RoB 2 registrados;
- GRADE provisório moderado;
- ProductVersion `under_review`;
- publication gate bloqueado como planejado;
- EvidenceSheetView real;
- preview Markdown;
- provenance/lineage;
- rebuild do zero.

---

# 2. Estado científico preservado

Pergunta:

> Em adultos com insônia, dCBT-I totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia no pós-tratamento?

Conclusão draft:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente, mas a magnitude varia entre estudos.**

GRADE OES provisório:

> **moderada**

Esse julgamento permanece:

> **pendente de revisão humana antes de publicação.**

---

# 3. Síntese externa adotada

Hwang et al. 2025 foi representada como:

- Study do tipo `systematic_review`;
- Report;
- Result externo;
- Synthesis `adopted_external`.

Estimativa focal preservada:

- SMD = -0,93;
- IC95% -1,07 a -0,79;
- k reportado = 10;
- I² = 68%.

A estrutura registra explicitamente:

> `recalculated_by_oes = false`

e o preview comunica:

> **Meta-análise publicada adotada criticamente; não recalculada pelo OES.**

---

# 4. Atualização OES

Os RCTs decisivos foram materializados como Studies primários separados.

A atualização foi representada por:

- Synthesis `narrative_update`;
- `synthesis_origin = oes_update`;
- quatro Results contribuintes;
- `included_main_analysis = false` para esses Results;
- nenhum pooling novo.

Teste RC01-T02 confirmou:

> **RCT update is narrative and not statistically pooled.**

---

# 5. Separação entre k publicado e Studies modelados

O caso real confirmou a necessidade de distinguir:

- número de Studies diretamente modelados no OES;
- número de estudos subjacentes a uma meta-análise externa.

O EvidenceSheetView, após migrations 008/009, preserva:

- contagem de unidades diretamente modeladas;
- `study_type_counts`;
- `reported_study_count = 10` no payload da síntese-base.

Teste RC01-T03:

> **PASS**

Consequentemente, a Ficha não apresenta o número de Studies diretamente modelados como se fosse o k total da meta-análise publicada.

---

# 6. Appraisal

Foram materializados:

- 1 avaliação ROBIS da revisão Hwang;
- 4 avaliações RoB 2 dos RCTs decisivos.

Todas permanecem:

- em estado de draft/revisão;
- com `verification_status = requires_human_review`.

Teste RC01-T07:

> **PASS**

Isso preserva a regra de que julgamento assistido por IA não equivale a revisão humana concluída.

---

# 7. Certainty

A CertaintyAssessment OES:

- framework: GRADE;
- inicial: high;
- final provisório: moderate;
- synthesis alvo: atualização OES;
- estado: under_review;
- cinco domínios GRADE registrados.

Teste RC01-T04:

> **PASS**

---

# 8. Publication gate

O ProductVersion real foi materializado como:

- `product_type = evidence_sheet`;
- `status = under_review`;
- `publication_date = NULL`;
- sem `review_record approved`.

Resultado esperado:

> **publishable = false**

Issues bloqueantes confirmadas:

- `MISSING_APPROVED_REVIEW`;
- `MISSING_PUBLICATION_DATE`.

Teste RC01-T05:

> **PASS**

Isso demonstra que o sistema não converte automaticamente um draft cientificamente estruturado em publicação.

---

# 9. Search e transparência de ausência de dados

A busca real registrou estratégias, fontes e data de execução.

Como o ambiente utilizado não expôs de forma confiável o hit count bruto de todas as bases:

- `result_count` permaneceu NULL;
- seis registros materiais capturados foram representados como SearchHits;
- nenhum número bruto foi inventado.

Teste RC01-T09:

> **PASS**

---

# 10. Provenance e lineage

Foi reconstruída cadeia desde Report de RCT até Product:

`Report → Result → Synthesis update → Certainty/Product`

Teste específico com SleepioRx:

> **RC01-T08 PASS**

As migrations 008/009 também preservaram referências provenance-aware e contagens por tipo de Study.

---

# 11. Preview Markdown

A Ficha real foi renderizada como:

> **PREVIEW — NÃO PUBLICÁVEL**

O preview contém:

- título;
- pergunta;
- conclusão draft;
- síntese-base externa;
- atualização OES;
- k publicado;
- certainty provisória;
- limitações;
- aplicabilidade;
- base de evidências;
- referências;
- auditoria;
- gate bloqueado.

A validação confirmou explicitamente a presença da nota de não recálculo da meta-análise.

Resultado:

> **RC01 real N2 Evidence Sheet blocked preview = PASS**

---

# 12. Testes RC01

- RC01-T01 — síntese externa adotada, não recalculada: **PASS**
- RC01-T02 — update narrativo, sem pooling OES: **PASS**
- RC01-T03 — Studies modelados ≠ k publicado: **PASS**
- RC01-T04 — GRADE moderado provisório: **PASS**
- RC01-T05 — publication gate bloqueado: **PASS**
- RC01-T06 — roles source/primary/corroborative preservados: **PASS**
- RC01-T07 — ROBIS/RoB 2 e review status: **PASS**
- RC01-T08 — lineage Report → Product: **PASS**
- RC01-T09 — hit count não inventado: **PASS**
- RC01-T10 — rebuild do caso real: **PASS**

> **RC01-T01–T10 = PASS**

---

# 13. Regressões no mesmo run

Também permaneceram aprovados:

- F2-B;
- S4;
- S5-T01–T17;
- Evidence Sheet contract;
- F3-VIEW-T01–T17;
- F3-PROV-T01–T06;
- F3-TEMPLATE;
- publication gate;
- rebuild through migration 009.

Conclusão:

> o Caso Real 01 não exigiu quebra ou contorno do baseline arquitetural.

---

# 14. Ambiente e artifact

PostgreSQL:

> **18.6**

Artifact:

- ID: **11307386757**
- nome: `oes-s5-evidence-37213165321`
- digest: `sha256:78b143a5def1b79d280736fb9b8415464621082c41b5964381db5ed143617fa5`
- tamanho: 24972 bytes
- expiração informada: 3 de novembro de 2026

O artifact inclui logs e o preview produzido no run.

---

# 15. Conclusão arquitetural

O primeiro caso real confirma que a cadeia:

`Pergunta → Investigação → busca → evidência → appraisal → síntese → certainty → Product → gate → EvidenceSheetView → Markdown`

é operacionalmente executável no baseline atual.

Também confirma que o OES consegue representar corretamente:

> **síntese externa adotada + atualização OES sem novo pooling**

sem apagar provenance ou inflar artificialmente a contagem de estudos.

---

# 16. Limite do PASS

Este PASS não autoriza publicação científica final.

Permanecem bloqueantes:

1. revisão humana dos julgamentos ROBIS/RoB 2 relevantes;
2. revisão humana do GRADE;
3. revisão humana da conclusão;
4. registro de `review_record approved`;
5. atribuição de `publication_date`.

Até isso ocorrer:

> **a Ficha deve permanecer `under_review` e não publicável.**

---

# 17. Próxima etapa

Preparar um **Pacote de Revisão Humana do Caso Real 01** contendo:

- pergunta e escopo;
- síntese-base;
- atualização;
- ROBIS;
- RoB 2;
- GRADE domínio a domínio;
- conclusão draft;
- pontos explícitos que exigem confirmação/contestação;
- formulário de decisão do revisor;
- regra de registro no `review_record`.

A preparação do pacote não será tratada como revisão humana concluída.

---

**Resultado final:** materialização, preview e rebuild do Caso Real 01 = **PASS**; publicação permanece corretamente bloqueada.
