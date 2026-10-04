# Arquitetura do OES

Este diretório abriga o modelo conceitual, o futuro modelo lógico de dados e, em fase posterior, a arquitetura tecnológica do Observatório.

## Documento atual

- [20 — Modelo Conceitual de Dados do OES](20-modelo-conceitual-dados.md)
- [21 — Modelo Lógico de Dados do OES](21-modelo-logico-dados.md)
- [22 — Validação Arquitetural por Casos de Uso](22-validacao-arquitetural-casos-uso.md)
- [23 — Checagem de Integridade do Modelo de Dados](23-checagem-integridade-modelo-dados.md)
- [24 — Alternativas Arquiteturais de Persistência](24-alternativas-arquiteturais-persistencia.md)
- [25 — Primeiro Desenho Físico Candidato](25-primeiro-desenho-fisico-candidato.md)
- [26 — PoC-S1: Validação do Schema Mínimo](26-poc-s1-validacao.md)
- [27 — Plano Formal de Testes do GATE F2-B](27-plano-testes-gate-f2b.md)
- [28 — Política de Identidade e Versionamento](28-politica-identidade-versionamento.md)
- [29 — Política de Proveniência e Lineage](29-politica-proveniencia-lineage.md)
- [30 — Política de Migrações do Modelo de Dados](30-politica-migracoes.md)
- [31 — PoC-S2: Validação de Search, Screening e Risk Assessment](31-poc-s2-validacao.md)
- [32 — Resultado do GATE F2-B e Decisão Pós-PoC](32-resultado-gate-f2b.md)
- [33 — Revisão de Promoção Arquitetural Pós-F2-B](33-revisao-promocao-pos-f2b.md)
- [F2-B Test Run — 2026-10-04 — Run 37187885839](F2B_Test_Run_2026-10-04_37187885839.md)

## Entidades conceituais centrais

- Question — OES-Q;
- Investigation — OES-I;
- Search — OES-S;
- Study — OES-ST;
- Report — OES-RP;
- Result — OES-RS;
- Risk of Bias Assessment — OES-RB;
- Synthesis — OES-SY;
- Certainty Assessment — OES-CE;
- Product — OES-P.

A separação entre **Study**, **Report** e **Result** é uma decisão consolidada.

A **Ficha de Evidência** permanece candidata a unidade persistente central do conhecimento, mas não substitui as entidades científicas subjacentes.

## Camadas

O modelo separa:

1. entidades científicas persistentes;
2. registros operacionais;
3. produtos/objetos de conhecimento;
4. artefatos derivados.

## Princípios

- metodologia antes da automação;
- proveniência como requisito transversal;
- versionamento sem sobrescrita silenciosa;
- modelo conceitual independente da tecnologia.

## Gate atual

**GATE F2-A — Modelo Lógico Candidato: APROVADO**, com reservas metodológicas explícitas.

## Arquitetura candidata

- **OES-H1:** núcleo relacional + JSON/documentos controlados + object storage + projeções opcionais.
- **OES-P1:** registry global + versões + entidades tipadas + núcleo relacional + JSONB controlado + artifact/dependency projection.

## Gates

- **F2-A — Modelo Lógico Candidato:** aprovado.
- **F2-B — Execução física da PoC em PostgreSQL:** **PASS**.

## Estado de execução

PoC-S1 + migrations PoC-S2/PoC-S3 foram executadas em PostgreSQL 18.6. A bateria T01–T19, incluindo rebuild do zero, foi aprovada no run 37187885839. **OES-P1 permanece candidato físico validado, não schema definitivo.**

## Próxima etapa

Desenvolver a **PoC-S4 — Multiplicidade Study/Report, Síntese Multiestudo e Retração/Impact Analysis**, cobrindo os critérios 4, 5, 7, 14 e 15 do Documento 25.
