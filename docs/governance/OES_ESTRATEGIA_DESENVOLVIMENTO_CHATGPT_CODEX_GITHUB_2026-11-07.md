# OES — Estratégia de desenvolvimento ChatGPT–Codex–GitHub

**Data:** 2026-11-07 (America/Recife)  
**Estado:** orientação operacional adotada pelo responsável e formalizada para continuidade entre conversas.  
**Escopo:** desenvolvimento de software, revisão e persistência; não altera autorização científica, operacional ou de infraestrutura.  
**Prevalência:** complementar ao Documento 362, aos gates vigentes e ao checkpoint corrente; nunca os substitui.

## 1. Finalidade

Usar o **ChatGPT** para coordenar decisões, preparar escopos e instruções delimitadas, revisar independentemente os resultados e registrar continuidade; o **Codex** para inspeção e implementação em ambiente de desenvolvimento isolado, com testes locais proporcionais; o **GitHub** como fonte canônica de código, decisões, diffs, PRs e checkpoints.

A estratégia foi exercitada nos incrementos do demonstrador Django: [PR #14](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/14) (navegação), [PR #15](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/15) (prévia sintética Q0→Q1→Q2) e [PR #16](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/16) (clareza e usabilidade), todos integrados após revisão do diff e autorização expressa de merge.

## 2. Procedimento padrão por incremento

1. **Freshness Gate:** conferir HEAD atual de `main`, `STATE.md`, `archive/handoffs/oes/README.md`, checkpoint vigente, Documento 362 e decisões específicas aplicáveis. Não assumir que o contexto de conversa corresponde à versão mais recente.
2. **Delimitação no ChatGPT:** definir objetivo observável, componentes a reutilizar, critérios de aceitação, testes proporcionais, restrições e o que **não** é autorizado. Redigir prompt copiável ao Codex.
3. **Execução no Codex:** inspeção estática ou implementação em branch isolada; relatar arquivos, SHA, testes e resultados, capturas quando úteis, limitações e acessos utilizados. Evitar arquitetura paralela, verificadores redundantes e novos gates por microatividade.
4. **Publicação separada:** implementação local **não** equivale a publicação. Push e abertura de PR exigem autorização delimitada; verificar antes os gatilhos automáticos do repositório, preservando workflows conectados desabilitados.
5. **Revisão independente no ChatGPT:** analisar diff real do PR, contratos e invariantes, testes e limites. Evidência de teste **relatada** pelo Codex não equivale a teste **reexecutado** nem a CI GitHub aprovada. Destacar bloqueadores reais; não atrasar entrega por refinamentos cosméticos opcionais.
6. **Merge separado e autorizado:** somente após decisão explícita do responsável, conferir SHA exato, atualidade da `main` e proteções/verificações aplicáveis; preferir merge verificável e confirmar conteúdo na `main`. Não transformar autorização de publicação em autorização de merge.
7. **Persistência e continuidade:** atualizar `STATE.md` e ponteiro de continuidade por marco material; criar checkpoint quando necessário para retomada entre conversas, não a cada microatividade. Referenciar commits/PRs e os limites das evidências.

## 3. Divisão de responsabilidades

- **ChatGPT — coordenação e revisão:** priorização proporcional, prompts de tarefas, análise independente, controle de escopo, decisão recomendada e manutenção de estado/pointers. Não alegar que viu ou executou testes quando apenas recebeu relatório.
- **Codex — desenvolvimento:** leitura do repositório, edição em ambiente isolado, testes offline e inspeção visual, produção de diff/commit/PR quando autorizado. Não decidir sozinho sobre promoção de gates, execução conectada, merge ou publicação científica.
- **Responsável — autorizações:** aprova publicação, merge e qualquer procedimento de risco moderado/alto no escopo próprio. `Prossiga` não amplia autorizações.
- **GitHub — verdade persistida:** `main`, arquivos canônicos, histórico, PRs, testes auditáveis e checkpoint. Uma conversa ou branch local não substitui publicação.

## 4. Controles e limites permanentes

- Aplicar proporcionalidade do Documento 362; reutilizar implementação existente e priorizar avanço funcional demonstrável.
- Preservar as distinções entre demonstração offline, evidência sintética conectada, persistência operacional, revisão científica e implantação.
- Não introduzir mudanças em `.github/workflows/`, Neon, SQL mutante, segredos, grants, autenticação de usuários reais, endpoints de escrita, deploy, gastos, ingestão factual ou promoção científica sem autorização específica e sem atender aos bloqueios existentes.
- Se a plataforma bloquear uma operação por segurança, **não contornar a restrição trocando o canal de execução**; registrar o impedimento e avançar em atividades independentes. O caso OpenAI #18651432, relativo ao workflow Django–Q0, permanece sem desfecho técnico comprovado nesta data.
- Manter **Marco B OPEN, Q0 executor geral HARD HOLD, E9 NO-GO e Fase 5 NOT_STARTED**. Fase 4 encerrada apenas metodológica/documentalmente; sem pesquisadores disponíveis para revisão científica independente.
- Evidência de Codex local e capturas Chromium devem ser qualificadas pelo seu alcance. Pull request/merge, por si, não comprova execução conectada ou qualidade científica.

## 5. Retomada em nova conversa

Ler primeiro `archive/handoffs/oes/README.md` e o checkpoint indicado; conferir `STATE.md` e `main` por Freshness Gate; carregar este documento como **regra de execução técnica**. Reconstituir brevemente o que está concluído, o que depende de autorização e o próximo incremento prioritário. Continuar a usar prompts prontos para colar no Codex, com publicação, revisão e merge como decisões separadas.

**Não há obrigação de usar Codex para toda atividade:** tarefas pequenas de análise ou documentação podem ser feitas diretamente no ChatGPT e persistidas no GitHub, respeitando o escopo e as proteções da ferramenta.
