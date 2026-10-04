# Observatório de Evidências em Saúde (OES)

O **Observatório de Evidências em Saúde — OES** é um projeto para identificar, avaliar criticamente, sintetizar, atualizar e comunicar evidências científicas relevantes em saúde de forma transparente, rastreável e metodologicamente explícita.

> **Princípio estrutural:** metodologia antes da automação.

## Estado do projeto

**Fase atual:** Fase 3 — Produtos do Observatório. A taxonomia e arquitetura comum dos produtos foi consolidada no Documento 40.

**Painel de estado vivo:** [STATE.md](STATE.md)

**Continuidade formal:** [archive/handoffs/oes/README.md](archive/handoffs/oes/README.md)

O STATE.md registra o estado corrente do projeto. A retomada formal entre conversas usa o mecanismo **snapshot + pointer**: template canônico → ponteiro → checkpoint vigente → Freshness Gate → Diagnóstico de Continuidade.

O repositório passa a ser a **fonte canônica do projeto**. As conversas de desenvolvimento são utilizadas para elaboração e revisão; as decisões consolidadas devem ser registradas aqui.

## Documentos atuais

### Concepção e arquitetura metodológica

- [00 — Documento de Concepção](docs/governance/00-documento-de-concepcao.md)
- [01 — Escopo Científico e Taxonomia das Perguntas](docs/governance/01-taxonomia-perguntas.md)
- [02 — Arquitetura de Níveis de Investigação e Produtos](docs/governance/02-niveis-investigacao-produtos.md)
- [03 — Protocolo de Entrada, Triagem e Roteamento Metodológico](docs/governance/03-roteamento-metodologico.md)

### Metodologia

- [10 — Protocolo de Busca e Recuperação de Evidências](docs/methodology/10-busca-recuperacao-evidencias.md)
- [11 — Protocolo de Elegibilidade, Triagem e Seleção](docs/methodology/11-elegibilidade-triagem-selecao.md)
- [12 — Protocolo de Avaliação de Risco de Viés e Qualidade Metodológica](docs/methodology/12-avaliacao-risco-vies.md)
- [13 — Protocolo de Extração e Estruturação de Dados](docs/methodology/13-extracao-dados.md)
- [14 — Protocolo de Síntese de Evidências](docs/methodology/14-sintese-evidencias.md)
- [15 — Protocolo de Avaliação da Certeza/Confiança no Corpo de Evidências](docs/methodology/15-certeza-evidencia.md)

### Produtos

- [40 — Taxonomia e Arquitetura dos Produtos do OES](docs/products/40-taxonomia-arquitetura-produtos.md)
- [41 — Especificação Científica e Funcional da Ficha de Evidência](docs/products/41-especificacao-ficha-evidencia.md)
- [42 — Contrato de Dados da Ficha de Evidência](docs/products/42-contrato-dados-ficha-evidencia.md)
- [43 — Resultado da Validação do Contrato da Ficha](docs/products/43-resultado-validacao-contrato-ficha.md)
- [44 — EvidenceSheetView: Contrato de Renderização da Ficha](docs/products/44-evidence-sheet-view.md)
- [45 — Resultado da Validação do EvidenceSheetView](docs/products/45-resultado-validacao-evidence-sheet-view.md)
- [46 — Especificação do Template Operacional da Ficha de Evidência](docs/products/46-especificacao-template-ficha-evidencia.md)
- [47 — Resultado da Validação do Template Operacional da Ficha](docs/products/47-resultado-validacao-template-ficha.md)
- [48 — Caso Real 01: dCBT-I — Protocolo Inicial N2](docs/products/48-caso-real-01-dcbti-protocolo-n2.md)
- [49 — Caso Real 01: Registro de Busca N2 e Triagem Inicial](docs/products/49-caso-real-01-busca-triagem-inicial.md)
- [50 — Caso Real 01: Appraisal ROBIS de Hwang 2025](docs/products/50-caso-real-01-appraisal-robis-hwang.md)
- [51 — Caso Real 01: RoB 2 dos RCTs de Atualização](docs/products/51-caso-real-01-rob2-rcts-atualizacao.md)
- [52 — Caso Real 01: Síntese Atualizada](docs/products/52-caso-real-01-sintese-atualizada.md)
- [53 — Caso Real 01: GRADE do Desfecho Principal](docs/products/53-caso-real-01-grade-gravidade-insomnia.md)
- [54 — Caso Real 01: Draft Científico da Ficha](docs/products/54-caso-real-01-draft-ficha.md)
- [55 — Caso Real 01: Decisão Arquitetural para Síntese Adotada + Atualização OES](docs/products/55-caso-real-01-decisao-arquitetural-sintese-adotada.md)
- [56 — Caso Real 01: Reconciliação e Hardening do EvidenceSheetView](docs/products/56-caso-real-01-reconciliacao-hardening-view.md)
- [57 — Resultado da Reconciliação e Hardening do EvidenceSheetView](docs/products/57-resultado-reconciliacao-evidence-sheet-view.md)
- [58 — Caso Real 01: Resultado da Materialização e Preview End-to-End](docs/products/58-caso-real-01-resultado-materializacao-preview.md)
- [59 — Caso Real 01: Pacote de Revisão Humana](docs/products/59-caso-real-01-pacote-revisao-humana.md)
- [58 — Resultado da Validação Ponta a Ponta do Caso Real 01](docs/products/58-resultado-validacao-ponta-a-ponta-caso-real-01.md)

### Arquitetura e dados

- [20 — Modelo Conceitual de Dados do OES](docs/architecture/20-modelo-conceitual-dados.md)
- [21 — Modelo Lógico de Dados do OES](docs/architecture/21-modelo-logico-dados.md)
- [22 — Validação Arquitetural por Casos de Uso](docs/architecture/22-validacao-arquitetural-casos-uso.md)
- [23 — Checagem de Integridade do Modelo de Dados](docs/architecture/23-checagem-integridade-modelo-dados.md)
- [24 — Alternativas Arquiteturais de Persistência](docs/architecture/24-alternativas-arquiteturais-persistencia.md)
- [25 — Primeiro Desenho Físico Candidato](docs/architecture/25-primeiro-desenho-fisico-candidato.md)
- [26 — PoC-S1: Validação do Schema Mínimo](docs/architecture/26-poc-s1-validacao.md)
- [27 — Plano Formal de Testes do GATE F2-B](docs/architecture/27-plano-testes-gate-f2b.md)
- [28 — Política de Identidade e Versionamento](docs/architecture/28-politica-identidade-versionamento.md)
- [29 — Política de Proveniência e Lineage](docs/architecture/29-politica-proveniencia-lineage.md)
- [30 — Política de Migrações do Modelo de Dados](docs/architecture/30-politica-migracoes.md)
- [31 — PoC-S2: Validação de Search, Screening e Risk Assessment](docs/architecture/31-poc-s2-validacao.md)
- [32 — Resultado do GATE F2-B e Decisão Pós-PoC](docs/architecture/32-resultado-gate-f2b.md)
- [33 — Revisão de Promoção Arquitetural Pós-F2-B](docs/architecture/33-revisao-promocao-pos-f2b.md)
- [34 — Plano e Desenho da PoC-S4](docs/architecture/34-plano-poc-s4.md)
- [35 — Resultado da PoC-S4](docs/architecture/35-resultado-poc-s4.md)
- [36 — Plano e Desenho da PoC-S5](docs/architecture/36-plano-poc-s5.md)
- [37 — Resultado da PoC-S5](docs/architecture/37-resultado-poc-s5.md)
- [38 — Decisão de Promoção do Baseline e Fechamento da Fase 2](docs/architecture/38-decisao-promocao-fechamento-fase2.md)
- [F2-B Test Run — 2026-10-04 — Run 37187885839](docs/architecture/F2B_Test_Run_2026-10-04_37187885839.md)

## Arquitetura documental prevista

```text
observatorio-evidencias-saude/
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── governance/
│   │   ├── 00-documento-de-concepcao.md
│   │   ├── 01-taxonomia-perguntas.md
│   │   ├── 02-niveis-investigacao-produtos.md
│   │   └── 03-roteamento-metodologico.md
│   ├── methodology/
│   │   ├── 10-busca-recuperacao-evidencias.md
│   │   ├── 11-elegibilidade-triagem-selecao.md
│   │   ├── 12-avaliacao-risco-vies.md
│   │   ├── 13-extracao-dados.md
│   │   ├── 14-sintese-evidencias.md
│   │   └── 15-certeza-evidencia.md
│   ├── products/
│   └── architecture/
│       ├── 20-modelo-conceitual-dados.md
│       ├── 21-modelo-logico-dados.md
│       ├── 22-validacao-arquitetural-casos-uso.md
│       ├── 23-checagem-integridade-modelo-dados.md
│       ├── 24-alternativas-arquiteturais-persistencia.md
│       ├── 25-primeiro-desenho-fisico-candidato.md
│       ├── 26-poc-s1-validacao.md
│       ├── 27-plano-testes-gate-f2b.md
│       ├── 28-politica-identidade-versionamento.md
│       ├── 29-politica-proveniencia-lineage.md
│       ├── 30-politica-migracoes.md
│       ├── 31-poc-s2-validacao.md
│       └── 32-resultado-gate-f2b.md
├── templates/
└── references/
```

Arquivos previstos ainda não desenvolvidos **não são criados como documentos substantivos** até que sua metodologia seja discutida e consolidada.

## Fluxo conceitual atual

```text
Pergunta
  ↓
Entrada e registro
  ↓
Normalização científica
  ↓
Classificação metodológica
  ↓
Roteamento de profundidade (N0–N4)
  ↓
Roteamento de manutenção (M0–M3)
  ↓
Busca e recuperação
  ↓
Elegibilidade e seleção
  ↓
Avaliação crítica
  ↓
Extração
  ↓
Síntese
  ↓
Certeza/confiança
  ↓
Aplicabilidade
  ↓
Produto OES
  ↓
Monitoramento e atualização
```

## Convenção de desenvolvimento

Os documentos são **vivos** durante a fase de desenvolvimento. O histórico Git registra cada alteração. Versões formais (`v0.1`, `v0.2`, `v1.0`) deverão ser atribuídas somente em marcos deliberadamente aprovados.

Alterações metodológicas relevantes devem:

1. ser justificadas;
2. preservar rastreabilidade;
3. ser registradas no `CHANGELOG.md` quando consolidadas;
4. manter coerência entre documentos dependentes.

## Gate arquitetural

**GATE F2-A — Modelo Lógico Candidato: APROVADO**, com reservas explícitas para aplicabilidade, produtos, monitoramento e vocabulários.

## Arquitetura candidata

**OES-H1** é a arquitetura de referência e **OES-P1** é o baseline arquitetural da Fase 2. Nenhuma stack de produção foi escolhida definitivamente.

## Gate físico

**GATE F2-B — PASS.** PoC-S4 — PASS. PoC-S5 — PASS. Os 15 critérios de promoção do Documento 25 foram validados.

## Próxima etapa

A PoC-S5 recebeu **PASS**, com regressões F2-B e S4 também aprovadas. A matriz de promoção atingiu **15/15 critérios validados**. OES-P1 foi promovido a **baseline arquitetural da Fase 2**, que está concluída. A Fase 3 está em desenvolvimento. O Documento 41 consolidou a especificação científica da **Ficha de Evidência**. O contrato científico e físico da Ficha foi validado em PostgreSQL 18.6, com regressões F2-B/S4/S5 verdes. O **EvidenceSheetView** foi validado em PostgreSQL 18.6 com F3-VIEW-T01–T16 PASS e regressões anteriores verdes. O Template Operacional inicial da Ficha de Evidência foi validado estruturalmente contra o EvidenceSheetView real da fixture. O **Caso Real 01** já possui busca N2, ROBIS, RoB 2, síntese atualizada, GRADE provisório e draft científico. Após reconciliação da atividade paralela, migrations 008–009 e EvidenceSheetView hardening receberam PASS. O Caso Real 01 foi materializado e validado ponta a ponta como Ficha `under_review`, com preview real e publication gate corretamente bloqueado. A próxima etapa é o **Gate de Revisão Humana do Caso Real 01**.

---

**Projeto iniciado:** 3 de outubro de 2026.


## Continuidade entre conversas

O mecanismo formal está documentado em:

- [Template canônico de abertura e continuidade](archive/continuity/OES_Template_Abertura_Continuidade.md)
- [Ponteiro para o checkpoint vigente](archive/handoffs/oes/README.md)

Checkpoints são snapshots operacionais imutáveis e não normativos. O ponteiro indica qual CP está vigente.
