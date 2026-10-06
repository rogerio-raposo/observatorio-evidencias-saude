# 146 — Overview de Revisões: Readiness Gate Pré-Caso Real

**Projeto:** Observatório de Evidências em Saúde — OES  
**Fase:** 3 — Produtos do Observatório  
**Produto:** OES — Overview de Revisões  
**Data:** 6 de outubro de 2026  
**Status do gate:** **ROTA DEVELOPMENTAL INTERNA = READY_WITH_DOCUMENTED_CONDITIONS / ROTA FORMAL PUBLICÁVEL = NOT_READY**  
**Escopo:** prontidão real antes da abertura de qualquer Caso Real do Overview  
**Dependências:** Documentos 138–145; migrations 019–020; CP57

---

# 1. Objetivo

Avaliar a prontidão real do OES para usar o produto Overview de Revisões após o fechamento técnico completo de:

- contrato científico;
- arquitetura;
- contrato de dados;
- publication gate;
- View;
- Projection Readiness;
- template;
- renderer;
- validator;
- CI/rebuild.

Este gate distingue:

1. **Rota A — developmental interna A0/A1**;
2. **Rota B — formal publicável A3**.

Nenhum Caso Real é criado neste documento.

---

# 2. Resultado agregado

| Dimensão | Rota A — developmental | Rota B — formal |
|---|---|---|
| Infraestrutura técnica | READY | READY |
| Corpus real candidato | A QUALIFICAR | A QUALIFICAR |
| Cobertura bibliográfica | READY_WITH_CONDITIONS | NOT_READY |
| Equipe humana qualificada | não obrigatória para A0/A1 interno, sem simulação | NOT_READY |
| Membership/overlap | pode iniciar incompleta, com disclosure | exige completa + human verification |
| ROBIS/OutcomeEvidence | pode iniciar incompleto, com blockers | exige completo/verificado |
| Assurance | A0/A1 real possível | A3 real indisponível |
| Publicação | proibida | bloqueada |

Resultado:

> **Rota A = READY_WITH_DOCUMENTED_CONDITIONS, porém depende de qualificação prévia de corpus candidato.**

> **Rota B = NOT_READY.**

---

# 3. Infraestrutura técnica

**Estado:** READY

Já validados:

- schema `overview`;
- ReviewItem;
- primary-study membership;
- clusters;
- overlap resolution;
- OutcomeEvidence;
- concordance;
- CCA/pairwise derivados;
- guards;
- publication gate;
- `OverviewOfReviewsView`;
- Projection Readiness;
- template;
- presentation map;
- renderer;
- validator;
- provenance;
- assurance;
- rebuild;
- regressões.

Conclusão:

> a infraestrutura técnica não é mais blocker.

---

# 4. Cobertura bibliográfica real

## 4.1 Rota formal

**Estado:** NOT_READY

Evidência operacional já demonstrada no projeto:

- PubMed/MEDLINE foi a única base bibliográfica reproduzivelmente executada no Caso Real N3-01;
- Europe PMC não ficou operacional de forma reproduzível;
- OpenAlex direto não ficou operacional;
- fontes suplementares não equivalem a segunda base bibliográfica;
- busca adversarial continuou encontrando evidência elegível.

Um Overview formal exige busca sistemática de **revisões sistemáticas**, e o publication gate exige que a cobertura declarada seja realmente cumprida.

Conclusão:

> não existe hoje garantia transversal de cobertura suficiente para um Overview formal.

## 4.2 Rota developmental interna

**Estado:** READY_WITH_DOCUMENTED_CONDITIONS

Uma investigação interna poderá:

- usar corpus conhecido/limitado;
- declarar cobertura não suficiente para publicação formal;
- manter status under_review;
- preservar publication blockers;
- não reivindicar completude.

---

# 5. Equipe metodológica humana

## 5.1 Formal

**Estado:** NOT_READY

Continuam ausentes no mundo real:

- search peer reviewer/information specialist qualificado;
- dois revisores humanos qualificados e independentes para screening quando exigido;
- verificação humana independente de ROBIS;
- data verifier humano para membership/overlap;
- expert independent reviewer para A3.

IA:

> **não substitui esses papéis.**

## 5.2 Developmental

A ausência desses atores não impede um produto interno A0/A1, desde que:

- nenhum ReviewerAssignment humano seja fabricado;
- nenhum `human_verified` seja criado;
- nenhuma A3 seja criada;
- publication gate permaneça fechado;
- limitações sejam explícitas.

---

# 6. Membership e overlap

A infraestrutura consegue:

- persistir membership;
- deduplicar Study identity;
- calcular CCA;
- calcular pairwise overlap;
- bloquear baixa confiança;
- representar incompletude.

Mas um Caso Real ainda precisa demonstrar que as Reviews candidatas fornecem informação suficiente para identificar seus primary Studies.

Para rota formal:

> **membership completa e human verified é requisito.**

Para rota developmental:

> partial/unknown é admissível apenas com disclosure e sem alegação formal de overlap completo.

---

# 7. Review identity e updates

A infraestrutura está READY para:

- multiple Reports;
- update lineage;
- uma Review Study entity com StudyVersion concreta;
- bloqueio de versões ativas duplicadas.

Em Caso Real, entretanto, será necessário validar:

- se Reports representam mesma Review ou Reviews independentes;
- se existe update/correction/retraction;
- qual versão concreta será usada.

Essa decisão não será inferida somente por título/ano.

---

# 8. ROBIS

Infraestrutura:

> READY.

Capacidade real:

> DEPENDENTE DO CASO.

Rota formal exige:

- ROBIS de todas as Reviews analíticas;
- human verification;
- qualified appraisal control.

Rota developmental poderá manter:

- ROBIS ausente ou AI-only;
- blockers explícitos;
- produto interno.

---

# 9. OutcomeEvidence e certainty

Infraestrutura:

> READY.

O Caso Real deverá demonstrar que as Reviews fornecem:

- outcome/comparison/timepoint relevante;
- Result/Synthesis rastreável;
- source location;
- primary-study set status;
- certainty reportada quando existir.

Certainty ausente:

> deve permanecer ausente.

Proibido:

- gerar certainty artificial;
- gerar global Overview certainty.

---

# 10. Currentness

Infraestrutura:

> READY.

Caso Real deverá conseguir recuperar:

- last search date;
- currentness status;
- rationale.

Publication date:

> não substitui last search date.

Review outdated poderá permanecer no corpus com disclosure conforme protocolo.

---

# 11. Statistical reanalysis

Nenhuma reanalysis é necessária para um primeiro Caso Real developmental.

Preferência inicial:

> **não criar nova meta-analysis.**

Usar:

- review-level estimates separados;
- `prioritize_review` quando overlap exigir, se metodologicamente justificável;
- concordance assessment somente quando comparabilidade for defensável.

Nova reanalysis exigiria:

- código;
- dataset;
- policy;
- statistical review qualificada para formalidade.

---

# 12. Assurance/governança

## 12.1 Developmental

Permitido:

- A0;
- eventual A1 após verificação metodológica real por IA;
- internal;
- under_review;
- publication_date=NULL;
- publishable=false.

Owner approval:

> não deve ser criado automaticamente para elevar assurance.

## 12.2 Formal

**NOT_READY**

Falta caminho humano real para:

- expert independent review;
- A3;
- qualified stage controls.

---

# 13. Corpus real candidato — ainda não qualificado

Neste checkpoint:

> **não existe corpus real formalmente selecionado e qualificado para OVR-01.**

O corpus N3-01 contém Reports secundários potencialmente relevantes, mas:

- sua busca não foi desenhada como busca sistemática de Reviews;
- sua cobertura é conhecida como não exaustiva;
- nem todo Report secundário está materializado como systematic-review Study;
- não está demonstrado que existam pelo menos duas Reviews elegíveis e comparáveis;
- membership completa de primary Studies não foi verificada;
- last search dates, ROBIS e certainty das Reviews não foram reconciliados para um Overview.

Portanto:

> **N3-01 não é automaticamente autorizado como corpus do OVR-01.**

Pode ser avaliado como candidato, mas somente em uma etapa de qualificação.

---

# 14. Qualificação mínima de corpus candidato

Antes de criar Investigation/Product real, o candidato deverá demonstrar:

1. pelo menos 2 systematic reviews elegíveis;
2. Reports integrais ou dados suficientes para identificação;
3. pergunta/escopo suficientemente relacionados para um cluster defensável;
4. last search date extraível;
5. lista de primary Studies recuperável ao menos parcialmente;
6. review-level Result/Synthesis relevante;
7. source location rastreável;
8. possibilidade de distinguir Reviews independentes de updates;
9. ausência de necessidade imediata de supplemental primary-study synthesis;
10. limitações de cobertura documentáveis.

Desejável:

- certainty reportada;
- study lists claramente identificáveis;
- reviews com ROBIS aplicável;
- uma Review mais atual que permita testar currentness/prioritization.

---

# 15. Rota A — developmental interna

**Estado:** READY_WITH_DOCUMENTED_CONDITIONS

Após um corpus candidato passar a qualificação mínima, fica permitido:

- criar novo Product `overview_of_reviews`;
- criar própria Question/Investigation;
- usar `depth_level=N3` ou N4 conforme profundidade real, sem rotular como formal apenas pelo depth;
- manter A0 inicial;
- manter under_review;
- manter publication_date NULL;
- manter publishable=false;
- permitir membership partial/unknown;
- permitir AI-only extraction/classification transparente;
- preservar blockers do gate.

Proibido:

- chamar de Overview formal/publicado;
- alegar search completeness;
- fabricar human controls;
- criar A3;
- ocultar overlap incompleto;
- criar global certainty;
- criar indirect comparison;
- realizar supplemental primary-study synthesis fora do contrato v0.1.

---

# 16. Rota B — formal publicável

**Estado:** NOT_READY

Blockers atuais:

1. cobertura bibliográfica transversal insuficiente;
2. equipe humana qualificada indisponível;
3. expert independent reviewer indisponível;
4. caminho real para A3 indisponível;
5. membership/overlap real completo ainda não demonstrado;
6. corpus real formal ainda não selecionado.

Não autorizado:

- publicação formal;
- A3 real;
- uso de IA como substituto humano;
- redução dos requisitos do gate.

---

# 17. Decisão operacional

Não abrir ainda OVR-01.

Próxima etapa autorizada:

> **qualificar candidatos de corpus real sem criar Product/Investigation.**

Primeiro candidato a ser examinado:

> **subconjunto de evidência secundária do corpus N3-01**, apenas como candidato de conveniência arquitetural, sem presunção de elegibilidade.

Se não houver pelo menos duas systematic reviews adequadas:

> descartar esse candidato e selecionar outro tema/corpus.

---

# 18. Saída esperada da qualificação de candidato

Documento curto deverá registrar:

- Reviews candidatas;
- tipo metodológico;
- Reports;
- updates;
- comparabilidade;
- last search dates;
- possibilidade de membership;
- Results/Syntheses disponíveis;
- certainty;
- gaps de informação;
- conclusão: suitable / suitable_with_conditions / unsuitable.

Somente:

> **suitable** ou **suitable_with_conditions**

poderá autorizar protocolo de OVR-01 developmental.

---

# 19. Próxima etapa

> **Executar a Qualificação de Corpus Candidato para OVR-01, começando pelo subconjunto secundário do N3-01, sem criar Investigation/Product real.**

---

**Resultado final:** infraestrutura real do Overview está pronta; rota developmental interna está condicionalmente disponível, rota formal permanece NOT_READY, e nenhum Caso Real está autorizado antes da qualificação de corpus.
