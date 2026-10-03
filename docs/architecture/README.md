# Arquitetura do OES

Este diretório abriga o modelo conceitual, o futuro modelo lógico de dados e, em fase posterior, a arquitetura tecnológica do Observatório.

## Documento atual

- [20 — Modelo Conceitual de Dados do OES](20-modelo-conceitual-dados.md)

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

## Próxima etapa

Desenvolver o modelo lógico de dados a partir do Documento 20.
