# Arquitetura do OES

Este diretório abriga o modelo conceitual, o futuro modelo lógico de dados e, em fase posterior, a arquitetura tecnológica do Observatório.

## Documento atual

- [20 — Modelo Conceitual de Dados do OES](20-modelo-conceitual-dados.md)
- [21 — Modelo Lógico de Dados do OES](21-modelo-logico-dados.md)
- [22 — Validação Arquitetural por Casos de Uso](22-validacao-arquitetural-casos-uso.md)
- [23 — Checagem de Integridade do Modelo de Dados](23-checagem-integridade-modelo-dados.md)
- [24 — Alternativas Arquiteturais de Persistência](24-alternativas-arquiteturais-persistencia.md)
- [25 — Primeiro Desenho Físico Candidato](25-primeiro-desenho-fisico-candidato.md)

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

## Próxima etapa

Executar a **PoC-S1** do schema mínimo para validar OES-P1, sem assumir stack de produção.
