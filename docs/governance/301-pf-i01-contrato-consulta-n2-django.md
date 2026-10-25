# Documento 301 — PF-I01: contrato restrito de consulta N2 no Django

**Data:** 2026-10-25. **Natureza:** especificação para decisão de implementação, não autorização de código. **Base:** Documento 300 / CP295 e inventário M2-A8.

## Objetivo e usuário
Oferecer no Django existente consulta **GET-only**, interna e documental, de uma única Ficha N2 histórica já preservada: `OES-P-2026-000401` (dCBT-I). Usuário inicial: pessoa responsável pela governança e inspeção técnica do piloto; não presumir pesquisadores ou acesso público.

## Contrato de entrada e origem
Fonte permitida: artefato histórico N2 já preservado no repositório ou snapshot de CI existente com identidade e versão verificáveis. A reprodução editorial histórica foi testada no run 40226403431; o primeiro corte não deve depender de download da API GitHub em tempo de requisição. A seleção de artefato empacotado/verificado e sua proveniência exata será explicitada antes da codificação. Não usar `signals.json` ou recibo P2 como substitutos científicos da ficha.

Projeção: reutilizar `templates/evidence-sheet.md`, `templates/evidence-sheet-presentation-map.json` e `scripts/render_evidence_sheet_reference.py`, sem reproduzir conclusões ou inventar relações Q–I–P. Contrato `docs/products/44-evidence-sheet-view.md` e ligações de `database/f3-real-case-01-dcbti.sql` são referências de estrutura, não autorização de SQL conectado.

## Superfície
Rota candidata: `GET /evidence-sheets/OES-P-2026-000401/` (a aprovação de caminho é parte da futura autorização). Isolada das rotas `/`, `/signals/<nct>/` e `/synthetic-path/`; nenhuma delas deve mudar sem motivo comprovado. Métodos mutantes negados. Informação não comprovada ou artefato inválido resulta em HOLD/erro sanitizado, nunca ficha aparentemente válida.

## Campos visíveis mínimos
ID e versão do produto; pergunta histórica Q1 vinculada; identificador da investigação histórica; profundidade N2/manutenção M1; corte temporal; resultado/conclusão original sem edição; distinção de sínteses primária/fonte/corroborativa; certeza e limitações; referências/proveniência; assurance **A2, não A3**; estado de atualização e escopo de circulação interna.

## Critérios de aceite PF-I01-AC
- AC01: GET permitido somente para identificador e versão históricos aprovados; desconhecidos não revelam dados.
- AC02: origem do snapshot imutável ou pinada por digest/verificação, sem dependência de rede por requisição.
- AC03: identidade Q→I→P corresponde exatamente a vínculos já documentados; vínculo ausente/divergente gera HOLD.
- AC04: conteúdo principal e campos científico-editoriais reproduzem artefato preservado, sem síntese nova.
- AC05: A2 e ausência de A3 expostas sem ambiguidade; sem sugestão de validação humana.
- AC06: data de corte, limitações, proveniência e estado de atualização visíveis.
- AC07: POST/PUT/PATCH/DELETE não executam escrita; respostas sanitizadas sem segredo, SQL ou traceback.
- AC08: testes Django offline para sucesso, IDs ausentes, payload inválido, proveniência divergente, assurance incoerente e métodos negados.
- AC09: regressões das três rotas existentes e renderização N2 preservadas; não reabrir P1/P2 sem necessidade.
- AC10: nenhuma chamada PostgreSQL/Neon, GET factual, workflow científico, serviço pago ou deploy.

## Implementação futura mínima (não autorizada por este documento)
Candidatos: `applications/oes_web/evidence/urls.py`, `views.py`, pequena camada de leitura documental isolada, template Django somente se necessário e testes em `evidence/tests/`. Preferir artefato gerado/validado offline em vez de acoplar diretamente à execução de SQL. Evitar autenticação simulada; a decisão sobre proteger acesso de um piloto local, público ou autenticado precede implantação e leitura por terceiros. A configuração de desenvolvimento `DEBUG=True` e secret estático **não** é utilizável em produção.

## Gates antes de implementar
1. Fixar origem, integridade e estratégia de entrega do snapshot histórico.
2. Revisar minimização de campos e forma de apresentação; sem divulgação externa.
3. Aprovar expressamente escopo e testes AC01–AC10, com execução offline.
4. Avaliar resultado e segurança antes de ampliar usuários, persistência ou autenticação.

## Continuidade
PF-I01 especificado, **não implementado**. Marco B aberto; E9 NO-GO; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; readiness `NOT_READY`; Fase 5 `NOT_STARTED`. Pesquisadores não vinculados, sem A3. Próximo passo: revisão breve do contrato e escolha da origem do snapshot para autorização delimitada da implementação.
