# Figura 6 — Desenvolvimento temporal do OES: protótipo editável

**Estado:** PROTÓTIPO EDITORIAL NÃO APROVADO — sem SVG, inspeção gráfica ou integração ao manuscrito.
**Data de referência dos estados:** **20 de outubro de 2026** (snapshot documental; não representa atualização automática do estado atual).
**Manuscrito-base:** [Fundamentos científicos, arquitetura metodológica e modelo de desenvolvimento](../oes-fundamentos-arquitetura-modelo-desenvolvimento.md), versão editorial **0.51**, §12.1.
**Local proposto de inserção:** imediatamente após a tabela de fases da §12.1, para evidenciar a diferença entre conclusão documental/técnica, desenvolvimento em curso e etapas ainda não iniciadas.
**Fontes principais:** [STATE.md](../../../STATE.md), [ponteiro de continuidade](../../../archive/handoffs/oes/README.md) e [CP213](../../../archive/handoffs/oes/OES_Continuidade_2026-10-20_CP213.md); nomenclatura das fases no [Documento 00](../../governance/00-documento-de-concepcao.md); especificação no [plano editorial visual](../oes-plano-editorial-visual-manuscrito.md).
**Função editorial:** apresentar uma trajetória de desenvolvimento em oito fases, com **estados nomeados**, sem simular medição de maturidade, progresso percentual, operação sustentada ou validação científica independente.

## Diagrama conceitual editável (Mermaid)

```mermaid
flowchart TB
    subgraph G1["Marcos documentados — fases 0 a 3"]
        direction LR
        F0["FASE 0 — Concepção e fundamentos<br/>BASE INICIAL CONSOLIDADA"]
        F1["FASE 1 — Manual Metodológico<br/>BASE INICIAL CONSOLIDADA<br/>Documentos 10–15"]
        F2["FASE 2 — Modelo de Dados<br/>BASELINE ARQUITETURAL CONCLUÍDA"]
        F3["FASE 3 — Produtos do Observatório<br/>CONCLUÍDA NO ESCOPO DEFINIDO"]
        F0 --> F1 --> F2 --> F3
    end

    subgraph G2["Etapa em desenvolvimento e fases previstas"]
        direction LR
        F4["FASE 4 — Protocolo de Atualização<br/>EM DESENVOLVIMENTO<br/>NOT_READY para operação factual"]
        F5["FASE 5 — Automação e IA<br/>NÃO INICIADA FORMALMENTE"]
        F6["FASE 6 — Validação<br/>NÃO INICIADA FORMALMENTE"]
        F7["FASE 7 — Operação contínua<br/>NÃO INICIADA FORMALMENTE"]
        F4 -. "sequência prevista" .-> F5
        F5 -.-> F6
        F6 -.-> F7
    end

    F3 --> F4

    classDef initial fill:#F3F6F9,stroke:#566B7E,color:#172D43,stroke-width:1.3px
    classDef concluded fill:#EBF1F5,stroke:#41586F,color:#172D43,stroke-width:1.5px
    classDef underway fill:#FFFFFF,stroke:#41586F,color:#172D43,stroke-width:2.2px
    classDef future fill:#FFFFFF,stroke:#7A8794,color:#34465B,stroke-width:1.2px,stroke-dasharray:5 4
    class F0,F1 initial
    class F2,F3 concluded
    class F4 underway
    class F5,F6,F7 future
```

**Convenção de leitura:** setas contínuas indicam a ordenação documental até a fase em desenvolvimento. As setas pontilhadas após a Fase 4 indicam **sequência planejada**, sem início formal, operação disponível, passagem de *gate* ou certeza de implantação. Os rótulos de estado são obrigatórios: a codificação visual isolada não define situação.

## Leitura científica e limites de interpretação

1. **Fases 0–1:** a expressão *base inicial consolidada* se refere à concepção e ao corpo inicial de protocolos. Não significa conclusão definitiva de todos os métodos nem revisão científica independente.
2. **Fase 2:** a conclusão ocorre no **nível de baseline arquitetural** (OES-P1), com testes e decisões técnicas próprios. Não é congelamento de esquema de produção, escolha definitiva de infraestrutura ou validação científica global.
3. **Fase 3:** o encerramento foi realizado **no escopo formal técnico/taxonômico**. Não transforma todos os produtos em saídas publicáveis ou independentemente validadas: há produtos internos A2, casos em revisão, N3 experimental A0 bloqueado e N4 formal não iniciado/NOT_READY, conforme a documentação específica.
4. **Fase 4:** permanece **em desenvolvimento**, e a prontidão para operação factual não foi estabelecida. Testes sintéticos de M2 não demonstram vigilância contínua com evidências reais; M3 permanece bloqueado. O registro CP213 identifica B1R1 como `EXPIRED_NOT_EXECUTED`, não medição factual executada.
5. **Fases 5–7:** **não iniciadas formalmente** na data de referência. A existência anterior de protótipos, scripts, verificações por IA ou experimentos não deve ser redescrita como abertura formal da Fase 5, início da validação independente na Fase 6 ou operação da Fase 7.
6. **Não há escala quantitativa implícita:** o tamanho e a posição dos blocos não representam duração, esforço, custos, progresso percentual, eficácia ou qualidade científica. A numeração indica fases propostas, não aumento automático de maturidade.
7. **Situação temporal:** os estados correspondem à documentação canônica referida a **20/10/2026**. Qualquer alteração factual futura deverá ser verificada em `STATE.md`, no ponteiro de continuidade e no histórico de Git antes da publicação ou reutilização.
8. **Escopo editorial:** a figura descreve o desenvolvimento do OES. Não autoriza execução de fases, alterações no Neon, liberação de *gates*, serviços pagos ou mudanças no projeto.

## Legenda científica proposta

**Figura 6 — Trajetória documental e técnica do desenvolvimento do Observatório de Evidências em Saúde (OES), segundo o estado registrado em 20 de outubro de 2026.** As fases 0 e 1 possuem bases iniciais consolidadas; a Fase 2 foi concluída no nível de baseline arquitetural; e a Fase 3, no escopo formal definido. A Fase 4 permanece em desenvolvimento, sem prontidão demonstrada para operação factual, enquanto as fases 5, 6 e 7 não foram formalmente iniciadas. As conexões representam a sequência planejada das fases, **não intervalos temporais medidos, progresso percentual, validação científica independente ou operação contínua demonstrada**. Fonte: `STATE.md`, CP213 e Documento 00 do OES.

## Texto alternativo proposto

“Diagrama da sequência de oito fases de desenvolvimento do OES. A Fase 0, concepção, e a Fase 1, manual metodológico, estão marcadas como bases iniciais consolidadas. A Fase 2, modelo de dados, está concluída como baseline arquitetural; a Fase 3, produtos, está concluída no escopo definido. A Fase 4, protocolo de atualização, está em desenvolvimento e não pronta para operação factual. As fases 5, automação e IA; 6, validação; e 7, operação contínua, estão marcadas como não iniciadas formalmente e unidas por conexões pontilhadas de planejamento. O diagrama não representa percentuais de avanço nem validação científica independente.”

## Conferências para a etapa de revisão semântica

- [ ] Confirmar que cada rótulo de fase corresponde literalmente à §12.1, ao `STATE.md` vigente e ao CP213 em sua data de referência.
- [ ] Conferir se as setas entre fases não sugerem progressão já executada, especialmente da Fase 4 para a Fase 5.
- [ ] Verificar se a finalização das fases 2–3 é descrita sem sobrestimar validação científica ou prontidão operacional.
- [ ] Verificar se M2 sintético, M3 bloqueado e B1R1 `EXPIRED_NOT_EXECUTED` permanecem inequivocamente distintos de operação factual.
- [ ] Avaliar legibilidade em A4 e leitura em preto e branco; considerar dividir a linha em dois segmentos sem alterar a ordem 0–7.
- [ ] Na fase vetorial posterior, criar SVG acessível com título e descrição, renderizar e inspecionar a imagem efetiva.
- [ ] Somente após revisões, integrar à §12.1 sem alterar as 56 referências ou as figuras anteriores.

**Limite desta entrega:** protótipo conceitual editável; sem modificação do manuscrito, `STATE.md`, continuidade operacional, *gates*, banco de dados ou serviços externos.
