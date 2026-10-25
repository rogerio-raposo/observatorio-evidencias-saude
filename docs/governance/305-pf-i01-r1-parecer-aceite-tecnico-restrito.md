# Documento 305 — PF-I01-R1: parecer de aceite técnico restrito

**Data:** 2026-10-25. **Base:** Docs. 301 e 304, CP296. **Escopo:** revisão read-only do código atualizado e CI 40243932508.

## Evidência
Run `40243932508`, SHA `a7815f01e0a90914d7b7585519c49a140a3bd352`, `completed/success`. Implementação R1 alterou exclusivamente leitor histórico, view, template e testes Django: estrutura HTML escapada (cabeçalhos/tabelas), IDs/versões Q–I–P fixos, vínculo primário histórico, condições de linhagem e assurance, testes negativos. Snapshot permanece fixo sob SHA-256 conhecido; nenhuma consulta factual, DB conectado ou escrita.

## Matriz AC01–AC10
| Critério | Parecer | Reserva |
|---|---|---|
| AC01 | PASS técnico restrito | Somente produto e versão histórica fixos; nenhum catálogo genérico |
| AC02 | PASS técnico restrito | Snapshot pinado por SHA-256, sem rede na requisição |
| AC03 | PASS documental restrito | Comparação com valores/vínculos históricos fixos, não resolução dinâmica de relações no PostgreSQL |
| AC04 | PASS técnico-documental limitado | Reuso do renderizador; não houve nova auditoria científica nem comparação integral visual de caracteres na página |
| AC05 | PASS técnico restrito | A2 visível e aviso explícito de A3 não realizada |
| AC06 | PASS documental limitado | Campos constam da projeção; legibilidade empírica por usuário não comprovada |
| AC07 | PASS técnico restrito | Rotas mutantes 404; HOLD sanitizado |
| AC08 | PASS técnico restrito para mutações testadas | Testes de ID, ausência, adulteração, Q/link/A2/linhagem; não todas as variações imagináveis |
| AC09 | PASS técnico restrito | CI de regressão Django no SHA correto; sem auditoria visual de browser |
| AC10 | PASS por delimitação do código | Leitura apenas de arquivos locais; sem SQL, GET factual ou deploy |

## Parecer
**PF-I01 — CLOSED_TECHNICAL_RESTRICTED_OFFLINE_GET_ONLY**: aceita-se o incremento apenas como consulta documental interna, offline, GET-only e alimentada por snapshot N2 congelado. Não constitui homologação operacional, avaliação humana de usabilidade/acessibilidade, revisão científica independente, integração PostgreSQL ou encerramento do Marco B. O renderizador Markdown→HTML é propositalmente limitado e não substitui um motor editorial completo; futuras extensões de formato exigirão testes próprios. Não declarar cobertura exaustiva dos critérios nem chamar essa rota de sistema público.

## Continuidade
Próxima prioridade: **escolher contrato de fluxo preparatório Q0/Q1/Q2 no piloto** e avaliar controles mínimos de identidade, autenticação, versão e persistência antes de autorizar escrita. Não construir nova UI ou schema automaticamente. E9 NO-GO; A3 não realizada; readiness NOT_READY; Fase 5 NOT_STARTED; Marco B aberto.
