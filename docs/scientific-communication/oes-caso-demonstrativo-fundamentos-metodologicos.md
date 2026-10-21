# OES — Caso demonstrativo e fundamentos metodológicos para avaliação por pesquisadores

**Versão editorial:** 1.0 — 21 de outubro de 2026  
**Natureza:** material de apoio ao diálogo científico, derivado do Documento 167.  
**Limite:** síntese fiel aos registros internos do OES; não houve nova autenticação dos artigos originais nem revisão científica especializada independente.

## 1. Por que um observatório de evidências?

Sínteses científicas refletem o conhecimento disponível em uma data determinada. Para interpretar novas pesquisas é necessário explicitar pergunta, fontes, seleção, avaliação crítica, síntese, limites e decisões de atualização. O **Observatório de Evidências em Saúde (OES)** pretende reunir essas etapas em processos transparentes e rastreáveis, com ferramentas computacionais que **não substituem a responsabilidade científica humana**.

## 2. Caso demonstrativo: terapia cognitivo-comportamental digital para insônia

**Pergunta estruturada:** em adultos com insônia, a terapia cognitivo-comportamental digital totalmente automatizada (dCBT-I), comparada com educação digital sobre sono ou higiene do sono, reduz a gravidade da insônia após o tratamento?

A Ficha de Evidência **OES-P-2026-000401** documenta seleção de fontes, avaliação de risco de viés, adoção crítica de síntese publicada, estudos adicionais considerados em atualização narrativa e julgamento provisório GRADE.

**Resultado documentado pelo OES:** a evidência indica provavelmente menor gravidade da insônia após a intervenção, com direção de benefício consistente, mas magnitude variável.

**Estimativa quantitativa externa, não produzida pelo OES:** conforme o Documento 52, Hwang et al. (2025) relataram, em subgrupo de dez comparações, diferença média padronizada **SMD −0,93 (IC95% −1,07 a −0,79; I² 68%)**. Esses valores são atribuídos à publicação de origem conforme o registro interno; não foram recalculados neste material. Não converter automaticamente a diferença padronizada em pontos do índice de gravidade da insônia, nem interpretar o valor como resultado de nova meta-análise do OES.

**Certeza da evidência:** o processo OES registrou **GRADE moderada, provisória**, para o desfecho gravidade da insônia no pós-tratamento. A avaliação foi **assistida por IA e não foi submetida a revisão científica especializada independente**. O julgamento não deve ser extrapolado a segurança, outros desfechos, aplicabilidade brasileira ou aconselhamento clínico individual.

**Corte de evidências:** 4 de outubro de 2026. A atualização foi narrativa e **não reivindica a exaustividade de revisão sistemática N4**.

## 3. Estado da Ficha e alcance das verificações

O registro histórico mostra progressão do **rascunho A1 / under_review** (Documento 54) para **aprovação de governança do proprietário e publicação editorial interna A2** (Documento 67).

**A2 não significa revisão por pares, publicação científica em periódico, garantia A3 ou validação independente.** O Documento 67 registra resultados de testes de software históricos; esses testes dão suporte ao comportamento técnico verificado, mas **não demonstram correção científica independente**.

A documentação permite examinar correspondência entre pergunta, seleção, avaliações, síntese, incertezas e decisões. A revisão externa desejada deve justamente verificar criticamente tais elementos.

## 4. Acompanhamento das evidências: Monitor M2

O OES implementou estruturas de dados e projeções para organizar ciclos, ocorrências, candidatos e avaliações de impacto, com histórico de decisões. O fluxo conceitual é:

1. Definir alvo e fontes previstas.
2. Registrar ciclos e ocorrências.
3. Examinar candidatos e seu impacto potencial.
4. Preservar avaliações e decisões.
5. Representar o histórico de atualização de forma rastreável.

Há verificações técnicas históricas com **dados sintéticos**. O **alvo sintético do Monitor não é a Ficha real dCBT-I**. Não se demonstrou, até a data de referência, monitoramento factual contínuo com PubMed ou ClinicalTrials.gov, integração efetiva com o caso real, interface pública operacional ou o regime M3.

## 5. O que foi demonstrado e o que permanece pendente

**Documentado:** arquitetura metodológica e técnica, nove famílias de produtos formalizadas, exemplos internos N1/N2 em A2 e componentes/testes históricos do monitor sintético.

**Pendente:** avaliação científica independente; demonstração integrada de acompanhamento factual; validação da aplicabilidade; implantação institucional; regime M3. Na data de referência, a Fase 4 estava **NOT_READY** para operação factual e a Fase 5 **NOT_STARTED**.

Os resultados técnicos, editoriais e de governança **não devem ser confundidos com evidência de eficácia clínica do próprio observatório** ou prontidão operacional.

## 6. Pontos para avaliação crítica por pesquisadores

Propõe-se discutir a pertinência das perguntas clínicas, estratégias de busca, critérios de elegibilidade, instrumentos de risco de viés (incluindo RoB 2 e ROBIS, quando cabíveis), consistência da síntese e do GRADE, transferibilidade de achados, critérios para reconhecer mudanças materiais e requisitos para uma futura estratégia de atualização.

A interlocução inicial **não pressupõe endosso, recrutamento ou compromisso de desenvolvimento**. As decisões sobre validação e eventuais etapas futuras dependerão dos pesquisadores e das autorizações pertinentes.

## Referências documentais para exame

- [Documento 52 — Síntese atualizada do caso](../products/52-caso-real-01-sintese-atualizada.md): atribuição da estimativa externa e atualização narrativa.
- [Documento 53 — Avaliação GRADE](../products/53-caso-real-01-grade-gravidade-insomnia.md): julgamento provisório e limites.
- [Documento 54 — Draft histórico](../products/54-caso-real-01-draft-ficha.md): estado A1 anterior.
- [Documento 58 — Validação ponta a ponta](../products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md): verificação histórica.
- [Documento 67 — Aprovação interna A2](../products/67-caso-real-01-resultado-validacao-a2-publicacao.md): estado final interno.
- [Documento 167 — Texto-base de governança](../governance/167-apresentacao-editorial-d0-cp212.md): narrativa original e controles de precisão.
- [Documento 168 — Apresentação executiva original](../governance/168-apresentacao-executiva-oes-d0-cp213.md): versão sintética de origem.
- [STATE.md](../../STATE.md): estado corrente do projeto, que deve ser consultado antes de apresentações posteriores.

**Nota de escopo:** documento descritivo para avaliação científica inicial. Os números atribuídos a Hwang et al. (2025) derivam da documentação interna e necessitam conferência bibliográfica direta antes de citação científica externa como dado verificado independentemente.
