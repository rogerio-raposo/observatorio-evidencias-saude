# 83 — Caso Real N1: Resultado da Validação do Estado A1

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Caso:** N1-01 — música gravada e ansiedade perioperatória  
**Status:** **PASS — A1 atingido; owner approval pendente**  
**Data:** 5 de outubro de 2026  
**GitHub Actions run final:** **37360679960**  
**Commit final testado:** `336079bd82c142ff5b4c4403779f6c81629c9410`  
**Artifact:** **11367105407**

---

# 1. Resultado

Após materialização do caso real, validação do estado A0, primeira verificação adversarial, correções versionadas e segunda verificação adversarial, a ProductVersion 2 atingiu:

> **A1 — AI methodological verification passed**

A1 não equivale a:

- owner governance approval;
- expert independent review;
- publicação;
- certainty formal;
- recomendação clínica.

---

# 2. Histórico adversarial

## Primeira passagem

Resultado:

> **REVISE**

Issues materiais:

1. duas meta-análises estavam apresentadas como uma faixa única de SMD;
2. a atualização pós-cutoff precisava ser explicitamente descrita como checagem seletiva e não exaustiva.

O resultado `revise` foi preservado na ProductVersion 1.

## Correção

Foi criada:

> **ProductVersion 2**

A ProductVersion 1 tornou-se `superseded`.

A versão 2:

- apresenta Stoop e Yu separadamente;
- não cria intervalo quantitativo OES;
- qualifica a atualização pós-cutoff como seletiva;
- preserva pergunta, routing, ROBIS e limitações.

## Segunda passagem

Resultado:

> **PASSED**

Materializado como AI methodological verification ativa na ProductVersion 2.

---

# 3. Conclusão científica atual

> **Sínteses sistemáticas recentes apontam redução média dos escores de ansiedade perioperatória com intervenções de música gravada em comparação ao cuidado usual ou ausência de música. Na meta-análise de Stoop et al. 2026, o efeito agrupado foi SMD aproximadamente -0,73 (IC95% -0,94 a -0,53). Em outra meta-análise de 2026, Yu et al. reportaram SMD -0,50 (IC95% -0,60 a -0,39) na análise principal. As duas sínteses apontam direção favorável, mas as magnitudes não devem ser tratadas como uma única faixa porque diferem em composição e decisões analíticas. A magnitude e a relevância clínica exatas permanecem incertas por limitações metodológicas dos ensaios, heterogeneidade e possível viés de publicação. Na checagem seletiva OES de estudos posteriores ao cutoff da síntese decisiva, os estudos localizados mantiveram direção geral favorável e não foi identificado sinal que exigisse rerroteamento; essa checagem não pretende completude.**

---

# 4. Certeza/confiança

> **Não avaliada formalmente pelo OES nesta Resposta de Evidência.**

Não foi criado CertaintyAssessment artificial.

A ausência de certainty formal permanece exposta no produto.

---

# 5. Appraisal da fonte decisiva

Stoop et al. 2026:

> **ROBIS OES global: high risk of bias**

Principais razões para cautela:

- desfecho autorreferido;
- ausência prática de cegamento;
- limitações dos ensaios primários;
- possível publication/small-study bias;
- NNT transformado;
- extrapolação da publicação sobre comparação farmacológica não adotada pelo OES.

A fonte permanece decisiva, mas não definitiva.

---

# 6. Versionamento

Product:

`OES-P-2026-000501`

Histórico:

- ProductVersion 1 — superseded;
- ProductVersion 2 — current / under_review.

Correção material não sobrescreveu silenciosamente a versão anterior.

---

# 7. Assurance atual

## ProductVersion 1

AI methodological verification:

- decision: `revise`;
- preservada historicamente.

## ProductVersion 2

AI methodological verification:

- decision: `passed`;
- status: `active`;
- independent_flag: `false`.

Owner governance approval:

> **ausente**

Expert independent review:

> **não realizada**

Derivação:

> **A1**

---

# 8. Publication gate

Estado:

- `under_review`;
- `publication_date = NULL`;
- `publishable=false`.

Após A1, os bloqueios materiais esperados permanecem:

- `MISSING_OWNER_APPROVAL`;
- `MISSING_PUBLICATION_DATE`.

Warnings permanecem visíveis, incluindo:

- ausência de expert independent review;
- ausência de certainty formal;
- busca N1 seletiva em uma única fonte bibliográfica principal no registro operacional.

---

# 9. Validação técnica final

Run:

**37360679960**

Conclusão:

> **success**

Confirmado:

- RN1-T01–T12: PASS;
- RN1-R1-T01–T09: PASS;
- RN1-A1-T01–T09: PASS;
- RN1-TEMPLATE-A1: PASS;
- Evidence Response contract: PASS;
- EvidenceResponseView: PASS;
- regressões F2-B/S4/S5: PASS;
- trilha Evidence Sheet N2: PASS;
- Caso Real 01 N2: PASS;
- rebuild through migration 012: PASS.

Artifact:

- ID **11367105407**;
- nome `oes-s5-evidence-37360679960`.

---

# 10. Falhas intermediárias preservadas

## Falha temporal de versionamento

Um run intermediário detectou que um `valid_to` fixo podia preceder o `valid_from` gerado no runtime.

Correção:

- transição de versão passou a usar `CURRENT_TIMESTAMP`;
- constraint temporal foi preservada.

## Falha de validador transitória

Após materializar A1, um run intermediário ainda usava a expectativa antiga de A0 no renderer.

Correção:

- validador atualizado para exigir A1 no preview atual;
- nenhum gate foi relaxado.

Essas falhas são parte da trilha de validação e não foram ocultadas.

---

# 11. Próxima etapa

A próxima transição possível é:

> **Owner Governance Approval**

O proprietário deverá avaliar:

- se a pergunta é a pretendida;
- se a conclusão é compreensível;
- se incertezas e limitações estão visíveis;
- se a natureza seletiva N1 está clara;
- se está claro que a metodologia foi assistida por IA;
- se está claro que não houve expert review;
- se a resposta evita recomendação indevida;
- se autoriza publicação interna no OES sob A2.

O proprietário não deverá validar tecnicamente ROBIS, meta-análise ou certainty.

---

**Resultado final:** A1 validado; owner approval pendente.
