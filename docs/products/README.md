# Produtos do OES

Este diretório contém a arquitetura e as especificações dos produtos do Observatório de Evidências em Saúde.

## Arquitetura comum

- [40 — Taxonomia e Arquitetura dos Produtos do OES](40-taxonomia-arquitetura-produtos.md)

## Taxonomia oficial inicial

### Produtos de investigação

- OES — Evidence Scan — N0;
- OES — Resposta de Evidência — N1;
- OES — Ficha de Evidência — N2;
- OES — Síntese Rápida de Evidências — N3;
- OES — Revisão de Evidências — N4.

### Produtos analíticos transversais

- OES — Mapa de Evidências;
- OES — Overview de Revisões.

### Produtos de manutenção

- OES — Monitor de Evidências;
- OES — Alerta de Evidência.

A **Ficha de Evidência** é a unidade persistente central preferencial do OES para perguntas focais reutilizáveis.

Monitor e Alerta pertencem à dimensão de manutenção M0–M3 e não criam novo nível de profundidade.

## Marco concluído — Ficha de Evidência

A trilha inicial da **Ficha de Evidência — N2** foi especificada, implementada e validada com um caso real ponta a ponta. O Caso Real 01 atingiu **A2**, estado `published` e `publishable=true`, preservando disclosure explícito de ausência de revisão especializada independente.

Referência de fechamento: [Documento 67](67-caso-real-01-resultado-validacao-a2-publicacao.md).

## Resposta de Evidência — N1

A trilha inicial de especificação e contrato N1 está registrada em:

- [68 — Especificação Científica e Funcional da Resposta de Evidência](68-especificacao-resposta-evidencia.md)
- [69 — Revisão de Coerência e Decisão Arquitetural Inicial](69-resposta-evidencia-revisao-coerencia-arquitetura.md)
- [70 — Contrato de Dados da Resposta de Evidência](70-contrato-dados-resposta-evidencia.md)
- [71 — Resultado da Validação do Contrato da Resposta de Evidência](71-resultado-validacao-contrato-resposta-evidencia.md)

O contrato N1 passou tecnicamente sem exigir nova tabela ou coluna e sem tornar Synthesis/Certainty obrigatórios.

## Próxima especificação

**Contrato de renderização EvidenceResponseView.**

O template operacional N1 somente será criado após a formalização dessa projeção.
