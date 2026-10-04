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

### Produtos

- [40 — Taxonomia e Arquitetura dos Produtos do OES](docs/products/40-taxonomia-arquitetura-produtos.md)
- [41 — Especificação Científica e Funcional da Ficha de Evidência](docs/products/41-especificacao-ficha-evidencia.md)

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

A PoC-S5 recebeu **PASS**, com regressões F2-B e S4 também aprovadas. A matriz de promoção atingiu **15/15 critérios validados**. OES-P1 foi promovido a **baseline arquitetural da Fase 2**, que está concluída. A Fase 3 está em desenvolvimento. O Documento 41 consolidou a especificação científica da **Ficha de Evidência**. A próxima etapa é definir seu **Contrato de Dados de Produto** e avaliar as extensões mínimas necessárias do baseline OES-P1 antes de criar o template operacional.

---

**Projeto iniciado:** 3 de outubro de 2026.


## Continuidade entre conversas

O mecanismo formal está documentado em:

- [Template canônico de abertura e continuidade](archive/continuity/OES_Template_Abertura_Continuidade.md)
- [Ponteiro para o checkpoint vigente](archive/handoffs/oes/README.md)

Checkpoints são snapshots operacionais imutáveis e não normativos. O ponteiro indica qual CP está vigente.
