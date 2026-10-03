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
- **F2-B — Execução da PoC-S1 em PostgreSQL:** pendente.

## Estado de execução

PoC-S1 + migration PoC-S2 estão documental e estaticamente preparadas. **F2-B continua pendente de execução real em PostgreSQL.**

## Próxima etapa

Executar F2-B quando houver ambiente PostgreSQL descartável. Evitar expansão relevante adicional do schema antes dessa execução.
