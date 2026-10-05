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

## Evidence Scan — N0

A trilha inicial do **Evidence Scan — N0** foi especificada, implementada e validada ponta a ponta.

Documentos principais:

- [86 — Especificação Científica e Funcional](86-especificacao-evidence-scan.md)
- [88 — Contrato de Dados](88-contrato-dados-evidence-scan.md)
- [90 — Contrato de Renderização](90-evidence-scan-view-contrato-renderizacao.md)
- [91 — Especificação do Template Operacional](91-especificacao-template-evidence-scan.md)
- [92 — Resultado da Validação do Template](92-resultado-validacao-template-evidence-scan.md)
- [97 — Verificação Metodológica Adversarial do Caso Real](97-caso-real-n0-verificacao-metodologica-adversarial.md)
- [98 — Resultado da Validação A1 e Fechamento](98-caso-real-n0-resultado-validacao-a1.md)

Caso Real N0-01:

- Product `OES-P-2026-000601`;
- assurance **A1**;
- estado `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- uso: **artefato interno de roteamento**;
- maturity `partially_synthesized`;
- routing `N2` com reformulação da pergunta.

A validação final ocorreu no run **37382201584**, com RN0-T01–T13, RN0-A1-T01–T08, renderização A0/A1 e rebuild em PASS.

## Síntese Rápida de Evidências — N3

A camada científica, arquitetural e de dados inicial da **Síntese Rápida — N3** está validada tecnicamente.

Documentos principais:

- [99 — Especificação Científica e Funcional](99-especificacao-sintese-rapida-n3.md)
- [100 — Revisão de Coerência e Arquitetura](100-sintese-rapida-n3-revisao-coerencia-arquitetura.md)
- [101 — Contrato de Dados](101-contrato-dados-sintese-rapida-n3.md)
- [102 — Resultado da Validação do Contrato](102-resultado-validacao-contrato-sintese-rapida-n3.md)

Estado:

- migration 014 validada;
- RS-T01–T15 PASS;
- fixture experimental A2 permanece não publicável sem qualified human controls/A3;
- caminho formal A3 comprovado em teste transacional;
- configuração atual do OES não autoriza publicação formal N3.

## Próxima especificação

**Contrato de Renderização da Síntese Rápida — N3.**

A apresentação deverá manter visíveis rapid restrictions, protocol deviations, quality controls, missing controls e bloqueios formais.
