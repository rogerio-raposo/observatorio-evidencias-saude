# Documento 295 — Pós-P3: macroatividades e reutilização do percurso funcional N2

**Data:** 2026-10-25.  
**Status:** consolidação diagnóstica M1-A1–M1-A4, **não decisão de implementação**.  
**Base canônica:** Documento 294 (P3 aprovado); Docs. 287–290; arquitetura Fase 3.

## 1. Contexto e restrições
O responsável aprovou a suficiência **técnico-demonstrativa restrita** P1/P2/P3, Documento 294. Piloto OES amplo não encerrado; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`. Pesquisadores não vinculados; avaliação científica externa diferida, nunca simulada.

## 2. M1-A1 — macroatividades remanescentes (classificação analítica)
- Demonstrador sintético P1/P2/P3: tecnicamente suficiente no escopo restrito; não reabrir sem necessidade comprovada.
- Definição de primeiro uso funcional: **prioridade imediata de análise**.
- Stack definitiva e arquitetura operacional: decidir após requisitos funcionais; requisitos diferidos exigem revisão na escolha/implantação da stack, conforme Docs. 287–288.
- Integração operacional, persistência/readback unificados, captura factual: não homologados; gates aplicáveis preservados, sem autorização.
- Governança científica: preparar documentalmente; execução externa depende de pesquisadores qualificados.
- Operação/implantação e validação ampla: posteriores e não iniciadas como capacidade homologada.
As categorias M1–M6 utilizadas na análise são apenas identificadores auxiliares, não novas fases canônicas.

## 3. M1-A2 — produtos, usuários e fluxos
A Fase 3 formalizou **9/9 produtos** conforme `docs/products/188-encerramento-fase-3.md`: Evidence Scan N0, Resposta N1, Ficha N2, Síntese Rápida N3, Revisão N4, Mapa, Overview, Monitor e Alerta. Formalização não significa nove produtos prontos para produção. Papéis funcionais preliminares: consultante, analista/pesquisador, revisor independente, governança e técnico-operacional; não são usuários cadastrados ou permissões implementadas.

Percurso conceitual: pergunta → roteamento metodológico → registro de fontes/estudos → avaliação e síntese humana competente → produto versionado → manutenção/atualização. A IA não substitui revisão humana independente; alerta não atualiza automaticamente conclusão.

## 4. M1-A3 — proposta de percurso F1
**Ficha de Evidência N2** é candidata a unidade persistente central, conforme Docs. 40–41. Separar:
- F1: consulta de Ficha N2 documental existente, preservando identificação, versão, pergunta, evidência, certeza, referências, data de corte, limitações, assurance e estado de atualização.
- F2: preparação de pergunta e proposta de roteamento; atividade futura.
- F3: avaliação, síntese e atualização científica; etapas futuras com requisitos humanos/operacionais.
Critérios propostos F1-AC01–08: identidade/versão; pergunta/data; fontes/resultados sem inferência; Study≠Report; transparência A0–A3; estado de atualização sem afirmação fictícia; isolamento P1/P2; nenhuma exigência de GET factual/SQL conectado/deploy para apresentação documental. **Não aprovados como contrato de implementação**.

## 5. M1-A4 — reutilização N2 e impedimento de duplicação
Artefatos existentes: `docs/products/44-evidence-sheet-view.md` (projeção `product.evidence_sheet_view(product_version_uuid)`), `templates/evidence-sheet.md`, `scripts/render_evidence_sheet_reference.py`, `scripts/validate_evidence_sheet_render.py`. Documento 47 registra validação histórica do template **v0.1** (run 37196822297); o template atual declara **v0.2**, de modo que o PASS histórico não equivale a revalidação desta versão. Documentos 58/67 registram Caso Real 01 dCBT-I em pré-publicação e posteriormente A2/`published` no modelo OES, run 37229070210, **sem A3**. Documento 188 comprova encerramento da formalização da Fase 3.

O pequeno aplicativo `applications/oes_web` contém catálogo documental, detalhes e `/synthetic-path/`, mas nenhuma rota específica da Ficha N2 foi identificada na revisão. A apresentação N2 histórica em template/renderer é distinta de uma aplicação HTTP de consulta; nenhuma integração dinâmica foi comprovada. **Não recriar template ou página Django apenas para repetir capacidades já demonstradas.**

## 6. Conclusão e próxima decisão funcional
**Recomendação, não aprovação de produto:** privilegiar reaproveitamento do N2 existente e selecionar objetivo do primeiro uso efetivo, distinguindo (a) consulta a acervo já documentado e (b) operação para criar/atualizar evidência. Somente após essa escolha definir se há lacuna funcional que justifique interface, API ou stack. Não selecionar arquitetura antes do problema.

Próxima atividade: elaborar **comparação explícita de alternativas de primeiro uso funcional**, com usuário, valor, alcance, dependências, riscos, custo proporcional e gatilho de participação científica; propor decisão, sem código ou operação. Não interpretar este documento como autorização de F1, nova publicação externa, integração factual, Neon/SQL, grants/credenciais, workflow habilitado, serviços pagos ou Fase 5.
