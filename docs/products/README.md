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

A camada científica, arquitetural, de dados e de apresentação da **Síntese Rápida — N3** foi validada tecnicamente. O primeiro caso real também validou o comportamento de bloqueio metodológico, sem fabricar assurance.

Documentos principais:

- [99 — Especificação Científica e Funcional](99-especificacao-sintese-rapida-n3.md)
- [100 — Revisão de Coerência e Arquitetura](100-sintese-rapida-n3-revisao-coerencia-arquitetura.md)
- [101 — Contrato de Dados](101-contrato-dados-sintese-rapida-n3.md)
- [102 — Resultado da Validação do Contrato](102-resultado-validacao-contrato-sintese-rapida-n3.md)
- [103 — Contrato de Renderização](103-rapid-evidence-synthesis-view-contrato-renderizacao.md)
- [104 — Especificação do Template Operacional](104-especificacao-template-sintese-rapida-n3.md)
- [105 — Resultado da Validação do Template](105-resultado-validacao-template-sintese-rapida-n3.md)
- [111 — Primeira Verificação Metodológica Adversarial do Caso Real](111-caso-real-n3-verificacao-metodologica-adversarial-01.md)
- [113 — Segunda Verificação Metodológica Adversarial](113-caso-real-n3-verificacao-metodologica-adversarial-02.md)
- [114 — Encerramento Experimental do Caso Real](114-caso-real-n3-encerramento-experimental.md)

Caso Real N3-01:

- tema: ambient AI scribes e carga de documentação clínica;
- Product `OES-P-2026-000701`;
- ProductVersion atual = 2;
- assurance **A0**;
- estado `under_review`;
- `publication_date=NULL`;
- `publishable=false`;
- primeira adversarial review = **REVISE**;
- segunda adversarial review = **REVISE**;
- bloqueio final: cobertura bibliográfica insuficiente para o padrão N3;
- controles humanos qualificados e A3 ausentes.

O caso demonstrou que technical PASS, appraisal/synthesis completos e uma conclusão cientificamente plausível não autorizam elevação de assurance quando o método de busca não satisfaz o padrão canônico.

Validação final:

- run **37413884319** = success;
- RN3-T01–T16 PASS;
- RN3-R1-T01–T10 PASS;
- RN3-ADV2-T01–T06 PASS;
- RN3-TEMPLATE-A0 PASS;
- rebuild PASS.

Condição de reabertura:

> executar uma segunda base bibliográfica relevante e reproduzível antes de nova tentativa de elevação de assurance.

## Revisão de Evidências — N4

A especificação científica, arquitetura inicial e contrato técnico da **Revisão de Evidências — N4** foram consolidados e validados.

Documentos principais:

- [115 — Especificação Científica e Funcional](115-especificacao-revisao-evidencias-n4.md)
- [116 — Revisão de Coerência e Decisão Arquitetural](116-revisao-evidencias-n4-revisao-coerencia-arquitetura.md)
- [117 — Contrato de Dados](117-contrato-dados-revisao-evidencias-n4.md)
- [118 — Resultado da Validação Técnica](118-resultado-validacao-contrato-revisao-evidencias-n4.md)
- [119 — Contrato de Renderização](119-evidence-review-view-contrato-renderizacao.md)
- [120 — Especificação do Template Operacional](120-especificacao-template-revisao-evidencias-n4.md)
- [121 — Resultado da Validação do Template/Renderização](121-resultado-validacao-template-revisao-evidencias-n4.md)
- [122 — Infrastructure Readiness Gate Pré-Caso Real](122-n4-infrastructure-readiness-gate-pre-caso-real.md)

Implementação:

- migration 015;
- `investigation.reviewer_assignment`;
- EvidenceReviewView `oes.evidence_review_view/0.1`;
- Infrastructure Readiness Gate;
- publication gate N4;
- suporte a ROB-ME em nível de Synthesis;
- fixture formal sintética A3;
- template Markdown/presentation map/renderer/validator;
- disclosure `audit.synthetic_fixture`;
- ER4-T01–T27 PASS;
- F3-ER4-TEMPLATE PASS;
- rebuild PASS.

A validação do contrato ocorreu no run **37417796591**, com artifact **11391167525** e digest `sha256:d96eb2f8b5807587395a80d7ac7a8ee5b0cfc231c1c794d5508acc3aa7c9f55a`.

A validação da apresentação ocorreu no run **37418624629**, com artifact **11391724857** e digest `sha256:a2d0c3dc12758a14fc13a2ac4ca50a3868ac9ceeac615ec34c6b417ee37b44ba`.

Limite operacional:

> **nenhum Caso Real N4 formal está autorizado na configuração humana/infrastrutural atual.**

O PASS é técnico/arquitetural e utiliza atores humanos explicitamente sintéticos para provar o contrato.

Infrastructure Readiness Gate real:

- resultado agregado **NOT_READY**;
- cobertura bibliográfica = not_ready;
- equipe metodológica = not_ready;
- governança/A3 = not_ready;
- nenhuma Investigation N4 real foi aberta;
- nenhum Caso Real N4 formal foi iniciado.

## Mapa de Evidências

A especificação científica, a decisão arquitetural, o contrato de dados v0.1 e a implementação técnica inicial do **Mapa de Evidências** foram consolidados e validados.

Documentos principais:

- [123 — Especificação Científica e Funcional](123-especificacao-mapa-evidencias.md)
- [124 — Revisão de Coerência e Decisão Arquitetural Inicial](124-mapa-evidencias-revisao-coerencia-arquitetura.md)
- [125 — Contrato de Dados](125-contrato-dados-mapa-evidencias.md)
- [126 — Resultado da Validação Técnica](126-resultado-validacao-contrato-mapa-evidencias.md)
- [127 — EvidenceMapView: Contrato de Renderização](127-evidence-map-view-contrato-renderizacao.md)

Implementação validada:

- migration 016;
- schema `mapping`;
- sete estruturas especializadas;
- `mapping.evidence_map_cells()`;
- publication gate do Mapa;
- EvidenceMapView `oes.evidence_map_view/0.1`;
- fixture formal sintética A3;
- EM-T01–T22 PASS;
- rebuild through migration 016 PASS;
- regressões N0–N4 PASS.

Validação:

- run **37464023391** = success;
- commit validado `9403f1a36bbcc2c486afa393146b528f72b7a08f`;
- artifact **11413512318**;
- digest `sha256:a531328905b4dba42fc249c92eaa8f2331e975ed9dfa418779e7523ae45f8d3a`.

Limite:

> **o PASS é técnico e sintético; nenhum Caso Real do Mapa foi iniciado e nenhum formal gap claim real foi autorizado.**

## Próxima etapa

**Mapa de Evidências: fechar o Projection Readiness Gate da EvidenceMapView.**

O Documento 127 definiu o contrato de renderização e identificou extensões aditivas necessárias antes do template: synthetic fixture, conclusão canônica, metadados de protocolo/codebook, reviewer/method controls, lineage/invalidation e referências alcançáveis por Study MapItems.

Não reabrir a migration 016. Implementar migration aditiva subsequente e validar a projeção ampliada antes da especificação do template operacional.

O N4 permanece deferido até que o Infrastructure Readiness Gate possa retornar estado compatível com execução formal.
