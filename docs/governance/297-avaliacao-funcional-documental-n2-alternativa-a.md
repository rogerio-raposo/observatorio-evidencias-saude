# Documento 297 — Avaliação funcional documental N2 e encerramento restrito da Alternativa A

**Data:** 2026-10-25. **Origem:** Doc. 296 / CP291. **Escopo:** consulta documental interna à Ficha N2 dCBT-I já existente.

## M1-A9 — Roteiro proporcional
Oito tarefas: T01 pergunta, T02 conclusão, T03 distinção de sínteses, T04 certeza, T05 limitações, T06 fontes/proveniência, T07 assurance A2 versus A3 e T08 legibilidade/navegação. Duas camadas: A verificação documental interna, B consulta observada por pessoas quando disponíveis. Camada A não demonstra compreensão empírica por usuários e tampouco revisão científica independente.

## M1-A10 — Linha de base documental histórica
Artefato 11313491459 do workflow 37229070210 (Caso Real 01, produto OES-P-2026-000401): T01, T02, T04, T05, T06, T07 **PASS documental estrutural**; T03 e T08 **PARTIAL** devido à diferenciação das sínteses e legibilidade do Markdown antigo. São constatações de presença/estrutura, não testes humanos.

## M1-A11 — Reprodução com código atual
CI dedicada `.github/workflows/oes-n2-editorial-offline.yml` ampliada para recuperar **somente** o JSON e Markdown históricos do artefato preservado, renderizar localmente com template atual e comparar invariantes. Commit inicial `d6d908af67a13b9218285158522a64d682e4eb7e`: run 40226336905 FAIL por caminho de importação Python; correção `4d88db3e46e5dcb4f08774b9fe1a271a7a55e920`: run **40226403431 completed/success**, reproduziu Markdown integral, executou validações estruturais, preservou conclusão/assurance A2/publication gate, diferenciou papéis, tratou campos descritivos conhecidos e normalizou tabela. Sem SQL, Neon, GET factual científico ou serviços pagos.

## Parecer decisório
**Alternativa A concluída exclusivamente como primeiro uso funcional documental interno verificável**, com **GO documental interno restrito**. Evidência suficiente para circulação e inspeção internas sob governança existente; NÃO autorização de publicação externa, implantação, produção operacional, validade científica independente, teste com usuários reais, A3 nem encerramento do Marco B. A CI offline cobre afirmações específicas do workflow, não todos os critérios ER-T01–ER-T12 de maneira exaustiva. Permanece restrição de pesquisadores indisponíveis.

## Próxima macroatividade recomendada
Avaliar o primeiro fluxo de **preparação documental de uma nova questão/investigação (F2)**, sem iniciar busca factual, coleta, nova síntese ou exigir pesquisadores inexistentes. Reutilizar contratos de Question/Investigation; primeiro inventariar os percursos existentes e lacunas funcionais concretas. A prioridade de F2 após encerramento restrito de A é recomendação para exame, não nova autorização de implementação.

## Invariantes
Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`; Fase 5 `NOT_STARTED`. Piloto amplo Marco B permanece aberto. Não modificar gates, identidades, roles/grants, credenciais, DB, interfaces públicas ou operação conectada sem autorização específica.
