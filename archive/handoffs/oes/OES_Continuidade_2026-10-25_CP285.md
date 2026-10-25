# OES — CP285 / Reavaliação do piloto e auditoria funcional do Django

**Data:** 2026-10-25. **Anterior:** CP284. **HEAD pré-checkpoint:** `359a8d3cd5f8883db4fd8d4f8cba766f462ea81f`. **Natureza:** handoff preventivo de continuidade, sem encerrar esta conversa.

## 1. Decisão estratégica / prioridade
- Aplicar Documento 288: **priorizar a demonstração científica e funcional do OES**, evitar o ciclo de experimentos isolados de autenticação, SQL conectado ou workarounds de stack ainda não decidida.
- Macroatividades **essenciais**: percorrer um sinal; diferenciar identidade documentada e não identificada no inventário delimitado; distinguir Study de Report; consultar vínculos e fontes documentadas; explicitar proveniência, incertezas e limites; validar apresentação.
- **Integração condicional**: roundtrip PostgreSQL conectado somente se necessário à demonstração ou gate especificamente aprovado; não tratar 99/99 offline como prova de SQL conectado.
- **Diferir à definição da stack**: autenticação definitiva, arquitetura de deploy, recuperação operacional e mecanismos não essenciais; inventariar/reavaliar antes de liberação operacional. Dupla autenticação removida do piloto pelo Documento 287, demais controles de segurança mantidos.
- Factual GET, automação de captura factual e divulgação privada **permanecem bloqueados**.

## 2. Preflight administrativo Neon executado sob aprovação explícita
- Projeto `oes-sandbox`, branch `br-gentle-hall-b6jaxehf`, DB `oes_sandbox`. Apenas metadados de papéis e ACL; sem leitura raw, escrita, mudança de papéis ou credenciais.
- `oes_e6_capture_login`: NOLOGIN, sem INSERT/SELECT; `oes_e6_writer`: NOLOGIN, INSERT e não SELECT; `oes_e6_verifier`: NOLOGIN, SELECT e não INSERT; `oes_pg_a4_reader`: LOGIN, sem acesso à raw; `oes_sandbox_owner`: LOGIN e INSERT/SELECT/DELETE, porém privilégios administrativos amplos.
- **Não utilizar owner como login de aplicação por conveniência**. Nenhuma identidade específica de aplicação com LOGIN e INSERT+SELECT mínimo foi localizada. Não modificar ACL sem autorização. Limpeza conectada, TLS e roundtrip real não comprovados.

## 3. Auditoria funcional Django por inspeção
- Projeto `applications/oes_web`, sem deploy nem homologação científica.
- Rotas: `/` catálogo; `/signals/NCT01438697/` identidade documentada; `/signals/NCT07836491/` identidade indeterminada no inventário.
- Fontes documentais nas fixtures: Docs. 247, 248 e `docs/products/154`. O primeiro exemplo associa Ritterband 2017 e Shaffer 2020 a **um mesmo estudo**; o segundo não produz alegação de estudo novo, inelegível ou excluído. Marcos retrospectivos são documentais, **não eventos executados pela aplicação**.
- Serviços e domínio impedem vínculo Study/Report inventado e exigem proveniência e limitação. Templates exibem fontes, trajetória e limitações; CSS responsivo com foco visível; validador Playwright bloqueia HTTP externo e testa desktop 1440, tablet 810 e mobile 390 px.
- Critérios de suficiência propostos: usuário localizar sinal, entender estado documental, separar estudo/relatório, acessar fonte, compreender incertezas e não confundir com revisão científica independente.
- Avaliação **por inspeção do código**, sem execução de navegador nesta atividade.

## 4. Refinamento editorial efetivamente publicado
- Autorização: `DJANGO_MINIMAL_DOCUMENTARY_PRESENTATION_REFINEMENT`.
- Commit `359a8d3cd5f8883db4fd8d4f8cba766f462ea81f` — arquivos alterados exclusivamente:
  - `applications/oes_web/evidence/templates/evidence/signal_catalog.html`: guia de leitura para dois estados.
  - `applications/oes_web/evidence/templates/evidence/signal_detail.html`: percurso sinal → identidade → estudo/relatórios quando documentados → fontes/limites; distinção explícita quando não reconciliado.
  - `applications/oes_web/evidence/static/evidence/styles.css`: estilo mínimo do guia.
- Fixtures, serviços, domínio, rotas, workflows e requisitos não alterados. **CI após o commit ainda pendente**; apenas checagens estruturais antes da publicação, não declarar PASS de regressão.
- Workflows manuais pré-existentes:
  - [Django vertical slice](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/workflows/oes-django-vertical-slice-validation.yml)
  - [Django real browser Chromium](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/workflows/oes-django-real-browser-validation.yml)

## 5. Evidências anteriores preservadas
- D2-I-A: Django 39/39 PASS, Actions 40190923646 (offline).
- D2-I-B: Django 50/50 PASS, Actions 40192039182 (offline).
- D2-I-C: Python E6 99/99 PASS, Actions 40194548767 (offline single-identity simulated).
- Essas execuções precedem o commit editorial `359a8d3cd5f8883db4fd8d4f8cba766f462ea81f` e **não** provam seu comportamento visual.

## 6. Limites institucionais
- Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, readiness `NOT_READY`, Fase 5 `NOT_STARTED`.
- Nenhum factual GET, nenhuma conexão/escrita SQL sem aprovação específica, nenhuma exposição de raw JSON, nenhum serviço pago, nenhuma mudança de papéis/ACL/credenciais, nenhum workflow factual habilitado.
- Template canônico: `archive/continuity/OES_Template_Abertura_Continuidade.md`. Ponteiro: `archive/handoffs/oes/README.md`. `STATE.md` e `CHANGELOG.md` como contexto atualizado.

## 7. Ponto exato de retomada
**Validar o commit editorial atual nos dois workflows Django existentes**, verificar commit dos runs e logs/testes, e somente então avaliar o encerramento técnico restrito do refinamento visual e os próximos itens funcionais. Se a CI exigir acionamento manual, orientar uso do GitHub Actions no Android. Não modificar código ou dizer que passou sem evidência.

## 8. Protocolo de trabalho
Freshness Gate no início e antes de publicar; um `Prossiga` = uma atividade; checkpoints a cada 3–5 atividades ou antecipados por risco/transição; mensagens de progresso contínuas; autorizações conectadas separadas e explícitas. Não depender de memória da conversa. Esta conversa permanece aberta.
