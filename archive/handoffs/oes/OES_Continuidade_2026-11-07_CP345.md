# CP345 — Continuidade OES — 2026-11-07

**Antecessor:** [CP344](OES_Continuidade_2026-10-29_CP344.md).  
**Estado:** checkpoint vigente de continuidade após consolidação do demonstrador Django e formalização da estratégia ChatGPT–Codex–GitHub.  
**Escopo:** persistência documental e estado técnico; **não** autoriza execução conectada, novas permissões, workflow habilitado, validação científica ou início da Fase 5.

## 1. Entregas comprovadas desde CP344

- **PR #14 — Navegação integrada Django:** [merge](https://github.com/rogerio-raposo/observatorio-evidencias-saude/commit/6d747014dbbef0b5745ecbf7c3049bd283e08e37); 11 arquivos alterados; menu comum, orientação inicial, retorno e responsividade. Codex relatou **48 testes offline PASS** e Chromium em 390/810/1440 px; revisão independente do diff feita, testes não reexecutados na revisão.
- **PR #15 — Demonstração sintética Q0→Q1→Q2:** [merge](https://github.com/rogerio-raposo/observatorio-evidencias-saude/commit/358c2feaef8f8aa4c1dae389a33fd54c5ce8ca21); 5 arquivos; página GET de exemplo fixo, contratos `QuestionCommand` e `Q2RoutingProposal`, sem UoW, gravação ou encaminhamento científico. Codex relatou **173 testes offline PASS** e Chromium em três larguras; diff revisado independentemente.
- **PR #16 — Clareza e usabilidade:** [merge](https://github.com/rogerio-raposo/observatorio-evidencias-saude/commit/f30771bb5762e7ec2b49ca63978e7bbf8daee621); 9 arquivos; índice e hierarquia da ficha N2, renderização Markdown estritamente limitada com `html.escape`, linguagem e mensagens HOLD diferenciadas. Snapshot, hash e conteúdo histórico preservados; Codex relatou **175 testes offline PASS** e Chromium em três larguras; diff e renderizador revisados sem execução independente de testes.
- Avaliação heurística e inspeção Chromium **relatadas pelo Codex**, sem usuários reais/leitores de tela ou teste científico; o demonstrador é adequado à **apresentação preliminar guiada**, não a operação científica/produção. Nenhum dos relatórios locais constitui evidência de CI GitHub aprovada.
- **Nova regra de trabalho documentada:** [Estratégia ChatGPT–Codex–GitHub](../../docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md) (**atenção:** para acesso direto a partir do repositório, caminho canônico `docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md`). Desenvolvimento em branch isolada, testes locais proporcionais, publicação autorizada, PR e revisão independente, merge por autorização separada, persistência nos ponteiros.

## 2. Estado que permanece do CP344

- No Neon experimental: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`; produção/`oes_app` intocados.
- Identidade sintética persistida e atestação **READ ONLY** [Actions 40962343481](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40962343481) PASS; **não repetir provisionamento**.
- Ensaio Django–Q0 com cinco INSERTs **transitórios**, rollback obrigatório e leitura independente está preparado em código, mas **não executado conectado sob a autorização nominal existente**. CLI isolado existe; workflow `.github/workflows/oes-django-q0-single-rollback-hold.yml` permanece **desabilitado com `if: false`**. Não confundir preparação offline com persistência PostgreSQL ou prova de commit.
- Validação histórica [Actions 40964845881](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40964845881) **303/303 PASS offline** no SHA histórico `d4a02a64f3ccd111d6b3dc344cd25222104c808c`, distinta dos testes locais posteriores.
- Alteração do workflow foi recusada por configuração de segurança OpenAI; chamado **#18651432** encaminhado ao suporte, sem regra específica ou liberação confirmada. **Não reproduzir a operação bloqueada por outro canal.** Continuar tarefas independentes.
- A decisão [Documento 362](../../docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md) mantém governança proporcional: nada de marcadores Git de consumo, rulesets, terceiro executor, repetição de provisionamento ou novos microgates sem necessidade funcional.

## 3. Gates e decisões inalterados

- **Fase 4:** encerrada somente no âmbito metodológico/documental; prontidão operacional não reconhecida.
- **Marco B:** OPEN.
- **Django Q0 executor geral:** HARD HOLD; autorização nominal única para ensaio rollback-only **não consumida**.
- **E9:** NO-GO.
- **Fase 5:** NOT_STARTED.
- **Pesquisadores:** indisponíveis; não alegar revisão científica independente.
- Sem novos gastos, serviços pagos, SQL mutante, privilégio, deploy, HTTP write ou coleta factual autorizados por este checkpoint.

## 4. Prioridade de retomada

1. Aplicar **Freshness Gate** na `main`: ler `archive/handoffs/oes/README.md`, este CP345, `STATE.md`, Documento 362 e estratégia Codex; conferir HEAD e diferenças posteriores.
2. Considerar **concluído o ciclo preliminar de interface Django (PRs #14–#16)** e fazer **reavaliação consolidada das macroatividades**: o que está finalizado, bloqueado e executável independentemente, com foco em próximos resultados demonstráveis e sem abrir nova infraestrutura.
3. Adotar o protocolo ChatGPT–Codex–GitHub para novos incrementos: escopo + prompt, branch local isolada, testes, autorização de push/PR, revisão de diff, autorização separada de merge, atualização proporcional do estado.
4. Tratar Django–PostgreSQL conectado como **pendência independente**, não pré-condição universal do desenvolvimento; reavaliar apenas com informação nova e autorização aplicável. Não presumir resolução do chamado OpenAI.
5. Após marcos materiais, registrar evidências verificáveis e limites; não gerar checkpoint por microatividade.

## 5. Nota de rastreabilidade

O fechamento do ciclo visual é **técnico-demonstrativo restrito**: não valida usabilidade com usuários reais, segurança de produção, qualidade científica ou integração PostgreSQL. Registros posteriores em `main` podem alterar o HEAD; a retomada deve atualizar a fotografia pelo Freshness Gate, nunca assumir este checkpoint como HEAD imutável.
