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

A trilha inicial da **Resposta de Evidência — N1** foi especificada, implementada e validada ponta a ponta.

Documentos principais:

- [68 — Especificação Científica e Funcional](68-especificacao-resposta-evidencia.md)
- [70 — Contrato de Dados](70-contrato-dados-resposta-evidencia.md)
- [72 — EvidenceResponseView](72-evidence-response-view.md)
- [73 — Especificação do Template Operacional](73-especificacao-template-resposta-evidencia.md)
- [83 — Resultado da Validação A1](83-caso-real-n1-resultado-validacao-a1.md)
- [84 — Aprovação de Governança do Proprietário](84-caso-real-n1-aprovacao-governanca-proprietario.md)
- [85 — Resultado da Validação A2 e Publicação](85-caso-real-n1-resultado-validacao-a2-publicacao.md)

Caso Real N1-01:

- Product `OES-P-2026-000501`;
- assurance **A2**;
- estado `published`;
- `publication_date=2026-10-05`;
- `publishable=true`;
- expert independent review não realizada e explicitamente declarada.

A validação final ocorreu no run **37362554094**, com regressões e rebuild em PASS.

## Próxima especificação

**Evidence Scan — N0.**

A especificação científica e funcional deve preceder contrato de dados, template ou automação específica desse produto.
