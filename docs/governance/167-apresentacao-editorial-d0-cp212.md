# 167 — Apresentação editorial D0 para interlocução com pesquisadores (CP212)

**OES | 2026-10-20 | DOCUMENTAL_ONLY | preparação editorial aprovada sob Documento 165**
**Estado:** material proposto para apresentação externa, NÃO submetido a revisão científica independente. Não há autorização de operação/consulta factual/execução D1.

## Propósito e limites de comunicação
Apresentar em linguagem científica acessível a motivação, exemplo real de produto, componentes sintéticos de acompanhamento, maturidade e convite a avaliação crítica. Esta narrativa editorial é apoiada nos Documentos 52, 53, 54, 58, 67, 165 e 166 e no STATE. A auditoria realizada verificou coerência **com as fontes internas**, não autenticou artigos originais. Não reproduzir números externos desacompanhados de atribuição.

## Parte 1 — Por que um Observatório?
Sínteses e avaliações de evidências em saúde representam o conhecimento disponível em determinada data. Novos estudos podem reforçar ou modificar interpretações. Atualizações transparentes exigem identificar fontes, registrar seleção, avaliar qualidade e reconsiderar conclusões. O **Observatório de Evidências em Saúde (OES)** pretende apoiar essas tarefas com métodos explícitos, histórico e rastreabilidade, sem substituir julgamento de pesquisadores.

## Parte 2 — Resultado existente: Ficha N2 sobre dCBT-I
**Pergunta:** em adultos com insônia, a terapia cognitivo-comportamental digital totalmente automatizada, em comparação com educação digital sobre sono/higiene do sono, reduz a gravidade da insônia após o tratamento?

O OES estruturou uma Ficha de Evidência (produto `OES-P-2026-000401`) com busca/seleção, avaliação de viés, síntese publicada adotada criticamente, estudos adicionais em atualização narrativa e atribuição provisória de certeza GRADE. Conforme Documento 67, a conclusão **registrada pelo OES** é que a evidência indica provavelmente redução da gravidade, com direção de benefício consistente e magnitude variável.

**Estimativa de referência EXTERNA, não calculada pelo OES:** Hwang et al. (2025), subgrupo com 10 comparações, SMD −0,93, IC95% −1,07 a −0,79, I² 68%, conforme Documento 52. Não converter SMD automaticamente em pontos de ISI; não combinar métricas de ensaios heterogêneos; OES não realizou nova meta-análise. Foram considerados estudos adicionais na atualização narrativa; a revisão não alegou exaustividade de revisão sistemática N4.

**Certeza GRADE atribuída no processo OES:** moderada para gravidade da insônia no pós-tratamento; julgamento **provisório**, assistido por IA e **sem revisão científica especializada independente** (Documento 53). Não extrapolar para segurança, outros desfechos ou aplicação ao Brasil. **Corte de evidências:** 04/10/2026.

**Situação editorial:** Ficha registrada como `published` no fluxo **interno** do OES sob garantia `A2 — owner_governance_approved` (Documento 67). Isto **não** significa publicação em periódico, peer review, garantia A3 ou homologação científica por terceiros.

## Parte 3 — Rastreabilidade e transparência
É possível acompanhar a pergunta, os estudos selecionados, os julgamentos de risco de viés, a síntese adotada e as incertezas declaradas. A documentação mostra progressão de draft histórico `A1/under_review` (Documento 54) ao estado editorial interno A2 (Documento 67). Testes de software históricos do Caso N2 constam do workflow OES PoC-S5, run `37229070210`, classificado PASS no Documento 67; não foram reexecutados nesta revisão. **Teste de software verifica comportamento do sistema, não correção científica independente.**

Apresentação em três níveis: conclusão compreensível; métodos e ressalvas acessíveis; trilha técnica completa disponível sob demanda.

## Parte 4 — Acompanhamento: o Monitor M2
Além das fichas, o OES contém um **Monitor de Evidências** implementado em contrato de dados e projeções e exercitado em cenários **sintéticos**. O fluxo conceitual é: definir alvo e fontes previstas → registrar ciclo e ocorrências → avaliar candidatos/impacto → preservar decisões e estados → representar histórico em visualização estruturada. As fixtures, testes e projeções nos arquivos `database/f3-evidence-monitor-fixtures.sql`, `database/f3-evidence-monitor-tests-a.sql`, `database/f3-evidence-monitor-tests-b.sql`, `database/f3-evidence-monitor-view-tests.sql`, migrations 021–023 e workflow histórico constituem suporte técnico.

**Separação essencial:** o alvo sintético M2 **não** é a Ficha real dCBT-I; ainda não foi demonstrado que o Monitor acompanhe factualmente essa Ficha, nem operação contínua com PubMed/ClinicalTrials.gov. Sem afirmar interface pública existente, monitoramento real ou execução presente.

## Parte 5 — O que existe, o que falta, como colaborar
**Existente/documentado:** baseline arquitetural Fase 2; nove produtos formalizados na Fase 3; exemplos N1/N2 com registro editorial interno A2; estruturas/projeções/testes históricos do Monitor sintético. **Não validado ou não autorizado:** revisão científica independente; demonstração integrada operacional factual; piloto de fontes externas D2; implantação institucional e M3. Fase 4 `NOT_READY` e Fase 5 `NOT_STARTED`.

A contribuição desejada de pesquisadores é **avaliação crítica sem endosso antecipado**: adequação de perguntas, buscas, elegibilidade, ROBIS/RoB 2/GRADE, aplicabilidade, critérios de impacto e necessidades prioritárias para atualização; propor correções antes de reivindicar confiança científica externa. Nenhum especialista foi convocado ou designado por este documento.

## Fala resumida opcional
“O OES produziu uma Ficha rastreável sobre dCBT-I, com síntese crítica e incertezas declaradas. Ela atingiu um estado de publicação interna sob aprovação de governança, sem revisão científica independente. Em paralelo, implementamos e testamos historicamente um Monitor com dados sintéticos para organizar ciclos, ocorrências e avaliações. Queremos agora submeter a proposta a pesquisadores, ouvir críticas e definir com eles quais passos de validação e integração têm maior valor.”

## Controle de precisão editorial
1. Escrever **publicação interna A2**, nunca usar “publicação científica” sem qualificador.
2. Atribuir a estimativa quantitativa **a Hwang et al. (2025)**, não ao OES.
3. Qualificar “GRADE moderada” como **julgamento provisório OES/IA**, sem validação especializada independente.
4. Distinguir **Monitor sintético historicamente testado** de monitoramento factual contínuo não demonstrado.
5. Não confundir Documento 54 (draft antigo) com Documento 67 (estado interno final). Sem orientação clínica individual.
6. Declarações respaldadas por documentação do OES; os artigos originais não foram reavaliados nesta rodada.

## Referências de auditoria
- `docs/products/52-caso-real-01-sintese-atualizada.md` — estimativa-base atribuída e atualização narrativa.
- `docs/products/53-caso-real-01-grade-gravidade-insomnia.md` — certeza provisória, domínio de aplicação e limitações.
- `docs/products/54-caso-real-01-draft-ficha.md` — histórico A1.
- `docs/products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md` — validação histórica pré-publicação.
- `docs/products/67-caso-real-01-resultado-validacao-a2-publicacao.md` — estado editorial interno A2 e run de CI.
- `docs/governance/166-roteiro-demonstracao-documental-d0-cp211.md` — roteiro técnico integral.
- `docs/governance/165-decisao-prioridade-d0-d1-cp210.md` — autorização de prioridade documental.

## Próximo passo e autoridade
Documento editorial preparado, não convertido em apresentação externa diagramada nem aprovado cientificamente. **Próximo Prossiga:** nova A1, avaliar se a versão editorial D0 está pronta para ser entregue ao intermediário que poderá apresentá-la a pesquisadores, identificando somente lacunas críticas de comunicação e formato; não iniciar contatos. Modo médio. `PREPARE_G1_DOCUMENTARY_ONLY`; D1 documentação apenas, D2 diferido; nenhuma mudança de gates. 36 migrations UNREVIEWED, zero pós-condições aprovadas, 36 requisitos 034–036 NOT_COLLECTED, 12 papéis pendentes; BRG-03/06/07/08 BLOCKED; 04/05 históricos; 09 parcial; B1R1 EXPIRED_NOT_EXECUTED; M3 bloqueado; Fase 4 NOT_READY; Fase 5 NOT_STARTED. STOP.
