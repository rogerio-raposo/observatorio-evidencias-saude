# Documentação do OES

Este diretório contém a documentação canônica do Observatório de Evidências em Saúde.

## Organização

### governance/

Fundamentos conceituais, escopo, taxonomia e regras de orquestração metodológica.

1. [00 — Documento de Concepção](governance/00-documento-de-concepcao.md)
2. [01 — Escopo Científico e Taxonomia das Perguntas](governance/01-taxonomia-perguntas.md)
3. [02 — Arquitetura de Níveis de Investigação e Produtos](governance/02-niveis-investigacao-produtos.md)
4. [03 — Protocolo de Entrada, Triagem e Roteamento Metodológico](governance/03-roteamento-metodologico.md)

### methodology/

Protocolos que definem como a evidência é localizada, selecionada, avaliada, extraída e sintetizada.

- [10 — Busca e Recuperação de Evidências](methodology/10-busca-recuperacao-evidencias.md)
- [11 — Elegibilidade, Triagem e Seleção](methodology/11-elegibilidade-triagem-selecao.md)
- [12 — Avaliação de Risco de Viés e Qualidade Metodológica](methodology/12-avaliacao-risco-vies.md)
- [13 — Extração e Estruturação de Dados](methodology/13-extracao-dados.md)
- [14 — Síntese de Evidências](methodology/14-sintese-evidencias.md)
- [15 — Certeza/Confiança no Corpo de Evidências](methodology/15-certeza-evidencia.md)

### products/

Arquitetura e especificações dos produtos do OES.

- [40 — Taxonomia e Arquitetura dos Produtos do OES](products/40-taxonomia-arquitetura-produtos.md)
- [41 — Especificação Científica e Funcional da Ficha de Evidência](products/41-especificacao-ficha-evidencia.md)
- [42 — Contrato de Dados da Ficha de Evidência](products/42-contrato-dados-ficha-evidencia.md)
- [43 — Resultado da Validação do Contrato da Ficha](products/43-resultado-validacao-contrato-ficha.md)
- [44 — EvidenceSheetView: Contrato de Renderização da Ficha](products/44-evidence-sheet-view.md)
- [45 — Resultado da Validação do EvidenceSheetView](products/45-resultado-validacao-evidence-sheet-view.md)
- [46 — Especificação do Template Operacional da Ficha de Evidência](products/46-especificacao-template-ficha-evidencia.md)
- [47 — Resultado da Validação do Template Operacional da Ficha](products/47-resultado-validacao-template-ficha.md)
- [48 — Caso Real 01: dCBT-I — Protocolo Inicial N2](products/48-caso-real-01-dcbti-protocolo-n2.md)
- [49 — Caso Real 01: Registro de Busca N2 e Triagem Inicial](products/49-caso-real-01-busca-triagem-inicial.md)
- [50 — Caso Real 01: Appraisal ROBIS de Hwang 2025](products/50-caso-real-01-appraisal-robis-hwang.md)
- [51 — Caso Real 01: RoB 2 dos RCTs de Atualização](products/51-caso-real-01-rob2-rcts-atualizacao.md)
- [52 — Caso Real 01: Síntese Atualizada](products/52-caso-real-01-sintese-atualizada.md)
- [53 — Caso Real 01: GRADE do Desfecho Principal](products/53-caso-real-01-grade-gravidade-insomnia.md)
- [54 — Caso Real 01: Draft Científico da Ficha](products/54-caso-real-01-draft-ficha.md)
- [55 — Caso Real 01: Decisão Arquitetural para Síntese Adotada + Atualização OES](products/55-caso-real-01-decisao-arquitetural-sintese-adotada.md)
- [56 — Caso Real 01: Reconciliação e Hardening do EvidenceSheetView](products/56-caso-real-01-reconciliacao-hardening-view.md)
- [57 — Resultado da Reconciliação e Hardening do EvidenceSheetView](products/57-resultado-reconciliacao-evidence-sheet-view.md)
- [58 — Resultado da Validação Ponta a Ponta do Caso Real 01](products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md)
- [59 — Caso Real 01: Pacote de Revisão Humana](products/59-caso-real-01-pacote-revisao-humana.md)
- [60 — Caso Real 01: Validação Técnica do Gate de Revisão Humana](products/60-caso-real-01-validacao-tecnica-gate-revisao-humana.md)

Próxima etapa: Gate de Revisão Humana do Caso Real 01.

### architecture/

Modelo conceitual, modelo lógico e, futuramente, arquitetura computacional.

- [20 — Modelo Conceitual de Dados do OES](architecture/20-modelo-conceitual-dados.md)
- [21 — Modelo Lógico de Dados do OES](architecture/21-modelo-logico-dados.md)
- [22 — Validação Arquitetural por Casos de Uso](architecture/22-validacao-arquitetural-casos-uso.md)
- [23 — Checagem de Integridade do Modelo de Dados](architecture/23-checagem-integridade-modelo-dados.md)
- [24 — Alternativas Arquiteturais de Persistência](architecture/24-alternativas-arquiteturais-persistencia.md)
- [25 — Primeiro Desenho Físico Candidato](architecture/25-primeiro-desenho-fisico-candidato.md)
- [26 — PoC-S1: Validação do Schema Mínimo](architecture/26-poc-s1-validacao.md)
- [27 — Plano Formal de Testes do GATE F2-B](architecture/27-plano-testes-gate-f2b.md)
- [28 — Política de Identidade e Versionamento](architecture/28-politica-identidade-versionamento.md)
- [29 — Política de Proveniência e Lineage](architecture/29-politica-proveniencia-lineage.md)
- [30 — Política de Migrações do Modelo de Dados](architecture/30-politica-migracoes.md)
- [31 — PoC-S2: Validação de Search, Screening e Risk Assessment](architecture/31-poc-s2-validacao.md)
- [32 — Resultado do GATE F2-B e Decisão Pós-PoC](architecture/32-resultado-gate-f2b.md)
- [33 — Revisão de Promoção Arquitetural Pós-F2-B](architecture/33-revisao-promocao-pos-f2b.md)
- [34 — Plano e Desenho da PoC-S4](architecture/34-plano-poc-s4.md)
- [35 — Resultado da PoC-S4](architecture/35-resultado-poc-s4.md)
- [36 — Plano e Desenho da PoC-S5](architecture/36-plano-poc-s5.md)
- [37 — Resultado da PoC-S5](architecture/37-resultado-poc-s5.md)
- [38 — Decisão de Promoção e Fechamento da Fase 2](architecture/38-decisao-promocao-fechamento-fase2.md)
- [F2-B Test Run — 2026-10-04 — Run 37187885839](architecture/F2B_Test_Run_2026-10-04_37187885839.md)

## Regra editorial

A documentação do repositório é a fonte canônica. Conversas podem desenvolver e revisar conteúdo, mas decisões persistentes devem ser consolidadas aqui.
