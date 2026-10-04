# 65 — Caso Real 01: Resultado da Validação do Estado A1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** Real 01 — dCBT-I totalmente automatizada  
**Status:** PASS — A1 atingido; owner approval ainda pendente  
**Data:** 4 de outubro de 2026  
**GitHub Actions run:** 37226199396  
**Commit testado:** `860988a16ff9890cf5b8c203e7a648f7d1ba8bb7`

---

# 1. Resultado

Após o redesenho de garantia A0–A3 e duas passagens metodológicas adversariais, o Caso Real 01 atingiu:

> **A1 — ai_methodological_reviewed**

A primeira passagem resultou em:

> **REVISE**

A segunda passagem, após correções rastreáveis, resultou em:

> **PASSED**

Esse histórico foi preservado no banco:

- primeira assurance record: superseded / revise;
- segunda assurance record: active / passed.

A1 não equivale a:

- owner approval;
- expert review;
- publicação.

---

# 2. Erro material detectado pela primeira passagem

A primeira verificação adversarial identificou que o appraisal ROBIS anterior havia inferido incorretamente que Somzz 2024 fazia parte da meta-análise Hwang após o cutoff declarado.

A verificação direta demonstrou:

- Somzz aparece como referência bibliográfica;
- não aparece entre os estudos incluídos apresentados na Tabela 1;
- a alegação de inclusão pós-cutoff não era sustentada.

Consequências:

- ROBIS Domain 2 corrigido;
- justificativa temporal incorreta removida;
- Somzz passou a ser tratado como atualização pós-cutoff;
- flag de possível overlap removida;
- justificativa de não-pooling foi corrigida.

Esse achado demonstra que a verificação A1 teve função real de controle e não apenas confirmação automática.

---

# 3. Segunda passagem adversarial

Após as correções, a segunda passagem revisou:

- pergunta/PICO;
- busca;
- elegibilidade;
- ROBIS;
- RoB 2;
- síntese;
- GRADE;
- conclusão;
- segurança;
- aplicabilidade;
- rastreabilidade.

Resultado:

> **PASSED**

Não foi encontrado erro metodológico material não resolvido incompatível com avanço para A1.

---

# 4. Estado científico após A1

Pergunta:

> Em adultos com insônia, dCBT-I totalmente automatizada, comparada à educação digital sobre sono/higiene do sono, reduz a gravidade da insônia no pós-tratamento?

Conclusão candidata:

> **A evidência indica provavelmente que a dCBT-I totalmente automatizada reduz a gravidade da insônia no pós-tratamento em comparação com educação digital sobre sono/higiene do sono. A direção do benefício é consistente nas fontes decisivas, mas a magnitude varia entre estudos.**

GRADE OES:

> **moderada**

A certainty permanece atribuída pelo processo metodológico OES assistido por IA e não por expert review.

---

# 5. Assurance atual

Registros do Caso Real 01:

## AI methodological verification — primeira passagem

- decision: `revise`;
- status: `superseded`;
- motivo: erro material ROBIS/Somzz.

## AI methodological verification — segunda passagem

- decision: `passed`;
- status: `active`;
- independent_flag: `false`.

Derivação:

> **A1**

Não existem:

- owner governance approval ativa;
- expert independent review aprovada.

---

# 6. Publication gate

O Caso Real 01 permanece:

- `under_review`;
- `publishable=false`;
- sem `publication_date`.

Após A1, os bloqueios esperados são:

- ausência de owner governance approval;
- ausência de publication_date.

A ausência de expert review não é bloqueio para N2 padrão:

> gera disclosure/warning, não error.

---

# 7. EvidenceSheetView

O EvidenceSheetView representa corretamente:

- `assurance_level = A1`;
- histórico das duas verificações metodológicas;
- `expert_independent_reviewed = false`;
- disclosure de garantia;
- publication issues;
- lineage.

Teste:

> **AV-T02 PASS**

---

# 8. Validação do modelo A0–A3

No mesmo run:

- AG-T01–T07: PASS;
- AV-T01–T02: PASS;
- RC01-T01–T10: PASS;
- F3-TEMPLATE: PASS;
- migrations 008/009/011: idempotência de projeção validada;
- migration 010: reaplicação duplicada corretamente detectada;
- rebuild through migration 011: PASS.

---

# 9. Evidência de execução

GitHub Actions:

- run: **37226199396**;
- conclusão: **success**;
- commit: `860988a16ff9890cf5b8c203e7a648f7d1ba8bb7`.

Artifact:

- ID: **11311923205**;
- nome: `oes-s5-evidence-37226199396`;
- digest: `sha256:4450a1eb9cd4e46012b8fecf55fa132a7b13e80af0472a10eaf8d859d12aeeb6`;
- tamanho: 28654 bytes;
- retenção: 30 dias.

---

# 10. Próxima etapa

A próxima transição é:

> **Owner Governance Approval**

O proprietário deverá avaliar somente:

- aderência da pergunta ao objetivo;
- clareza da conclusão;
- visibilidade da incerteza;
- visibilidade das limitações;
- transparência de que a metodologia foi assistida por IA;
- transparência de que não houve expert review;
- ausência de recomendação clínica/normativa indevida;
- autorização para publicação interna no OES sob garantia A2.

O proprietário **não deverá avaliar tecnicamente** ROBIS, RoB 2, GRADE ou meta-análise.

Se:

`owner_governance_approval = approved`

o nível derivado passa a:

> **A2**

A publicação continuará exigindo fechamento editorial e `publication_date`.

---

**Resultado final:** A1 validado; owner approval pendente.
