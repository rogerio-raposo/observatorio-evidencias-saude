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
4. **Publicação controlada:** implementação local **não** equivale a publicação. Push e abertura de PR exigem autorização delimitada, que pode ser conjunta com a autorização de merge quando o responsável a conceder **expressamente** no mesmo despacho. Conferir antes os gatilhos automáticos do repositório, preservando workflows conectados desabilitados. A autorização conjunta não dispensa a verificação técnica do PR antes de executar o merge.
5. **Revisão independente no ChatGPT:** analisar diff real do PR, contratos e invariantes, testes e limites. Evidência de teste **relatada** pelo Codex não equivale a teste **reexecutado** nem a CI GitHub aprovada. Destacar bloqueadores reais; não atrasar entrega por refinamentos cosméticos opcionais. Antes de exigir correções, observar o **Princípio do Contraditório Técnico Fundamentado** (seção 2.1).
6. **Merge autorizado e condicionado às verificações:** executar somente mediante autorização expressa, específica para merge, concedida isoladamente ou **junto com a publicação** no mesmo despacho. Mesmo com autorização conjunta, conferir PR/diff, SHA exato, atualidade da `main`, ausência de mudanças inesperadas, proteções e verificações aplicáveis antes de integrar; interromper se houver bloqueio ou alteração material e solicitar nova decisão. Confirmar o conteúdo na `main` após o merge. Nunca presumir autorização de merge a partir de uma autorização exclusivamente de publicação.
7. **Persistência e continuidade:** atualizar `STATE.md` e ponteiro de continuidade por marco material; criar checkpoint quando necessário para retomada entre conversas, não a cada microatividade. Referenciar commits/PRs e os limites das evidências.


### 2.1. Princípio do Contraditório Técnico Fundamentado (2026-11-10)

**Finalidade.** Assegurar que revisões independentes elevem a qualidade do software sem impor correções desnecessárias, complexidade adicional ou ciclos excessivos de desenvolvimento. Um apontamento de revisão é uma hipótese técnica que deve ser examinada, não uma ordem de modificação automaticamente procedente.

1. **Direito e dever de contestação.** O Codex deve examinar criticamente os apontamentos do ChatGPT e pode concordar, contestar ou propor alternativa fundamentada; o ChatGPT deve reavaliar as próprias conclusões e reconhecer expressamente erros ou excessos de interpretação. Nenhuma conclusão prevalece pela autoridade de sua origem.
2. **Classificação após contraditório.** Cada achado material receberá uma das classificações: **CONFIRMADO** (evidência suficiente do defeito), **PARCIALMENTE PROCEDENTE** (problema real, mas caracterização, gravidade ou solução requer ajuste), **NÃO PROCEDENTE** (implementação atende ao contrato ou a crítica é equivocada) ou **INCONCLUSIVO** (evidência insuficiente). Distinguir defeito demonstrado, risco plausível, limitação de teste e melhoria opcional.
3. **Fundamentação e limites da evidência.** Examinar contrato, fluxo real do código, semântica dos frameworks, invariantes e testes disponíveis. Testes simulados não comprovam comportamento conectado. Quando uma questão material permanecer inconclusiva, preservar os controles de segurança, classificar a pendência e não promover gates.
4. **Proporcionalidade.** Corrigir problemas confirmados ou suficientemente demonstrados; não modificar código apenas para atender crítica considerada improcedente. Consolidar correções relacionadas na mesma branch e no mesmo ciclo de implementação/revisão, quando seguro. Evitar novas rodadas sem fato novo, risco material ou evidência adicional relevante.
5. **Divergência persistente.** Registrar as fundamentações de ChatGPT e Codex, as consequências e alternativas; recomendar a solução mais simples que preserve contratos, invariantes e evidências. Submeter divergência material não resolvida à decisão do responsável, sem flexibilização automática de controles.
6. **Governança preservada.** O contraditório não autoriza push, PR, merge, SQL conectado, alterações de privilégios, execução de workflows, implantação, liberação operacional ou científica. Continuam exigidas as autorizações próprias previstas nesta estratégia e no Documento 362.
7. **Continuidade.** Esta regra é parte permanente da estratégia ChatGPT–Codex–GitHub, aplicável ao P1 em revisão e aos incrementos posteriores, inclusive em novas conversas. Sua aplicação ocorre dentro da revisão já prevista; **não institui um microgate ou ciclo administrativo adicional**.

## 3. Divisão de responsabilidades

- **ChatGPT — coordenação, revisão e publicação:** priorização proporcional, prompts de tarefas, análise independente, controle de escopo e manutenção de estado/pointers. Quando houver acesso adequado às entregas e autorização expressa, pode aplicar patch consolidado, publicar branch, abrir PR e executar merge após os controles acima, sem exigir passagem administrativa pelo Codex. Não alegar que viu ou executou testes quando apenas recebeu relatório.
- **Codex — desenvolvimento:** leitura do repositório, edição em ambiente isolado, testes offline, inspeção visual e entrega de patch/relatório. Pode publicar diff/commit/PR se isso fizer parte do despacho autorizado, mas não é obrigatório utilizá-lo para a publicação quando o ChatGPT puder fazê-la diretamente. Não decidir sozinho sobre promoção de gates, execução conectada, merge ou publicação científica.
- **Responsável — autorizações:** aprova publicação, merge e qualquer procedimento de risco moderado/alto no escopo próprio. Pode autorizar **publicação e merge em um único despacho explícito**, mantidas as verificações intermediárias e a interrupção diante de bloqueador material. `Prossiga` não amplia autorizações.
- **GitHub — verdade persistida:** `main`, arquivos canônicos, histórico, PRs, testes auditáveis e checkpoint. Uma conversa ou branch local não substitui publicação.

## 4. Controles e limites permanentes

- Aplicar proporcionalidade do Documento 362; reutilizar implementação existente e priorizar avanço funcional demonstrável.
- Preservar as distinções entre demonstração offline, evidência sintética conectada, persistência operacional, revisão científica e implantação.
- Não introduzir mudanças em `.github/workflows/`, Neon, SQL mutante, segredos, grants, autenticação de usuários reais, endpoints de escrita, deploy, gastos, ingestão factual ou promoção científica sem autorização específica e sem atender aos bloqueios existentes.
- Quando uma operação sofrer recusa de segurança da plataforma, respeitar a recusa efetiva: não repetir mecanicamente nem neutralizar controles. **Esclarecimento do responsável (2026-11-07) sobre o chamado OpenAI #18651432:** a orientação do suporte para não repetir ou buscar outro canal aplicava-se à produção de evidências diagnósticas adicionais (gravações de tela), não estabelecendo proibição geral de implementação local pelo Codex ou edição legítima no GitHub. Desenvolvimento isolado e testes offline podem ser autorizados separadamente; publicação, alteração de workflow, merge e execução conectada exigem seus próprios gates e podem sofrer restrições efetivas da plataforma. O chamado permanece sem resolução técnica confirmada.
- Manter **Marco B OPEN, Q0 executor geral HARD HOLD, E9 NO-GO e Fase 5 NOT_STARTED**. Fase 4 encerrada apenas metodológica/documentalmente; sem pesquisadores disponíveis para revisão científica independente.
- Evidência de Codex local e capturas Chromium devem ser qualificadas pelo seu alcance. Pull request/merge, por si, não comprova execução conectada ou qualidade científica.

## 5. Retomada em nova conversa

Ler primeiro `archive/handoffs/oes/README.md` e o checkpoint indicado; conferir `STATE.md` e `main` por Freshness Gate; carregar este documento como **regra de execução técnica**. Reconstituir brevemente o que está concluído, o que depende de autorização e o próximo incremento prioritário. Continuar a usar prompts prontos para colar no Codex, com publicação, revisão e merge como decisões separadas.

**Não há obrigação de usar Codex para toda atividade:** tarefas pequenas de análise ou documentação podem ser feitas diretamente no ChatGPT e persistidas no GitHub, respeitando o escopo e as proteções da ferramenta.
