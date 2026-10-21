# OES — Plano editorial visual do manuscrito científico

> **Atualização de execução editorial — 21 de outubro de 2026.** O conjunto-base planejado encontra-se **incorporado ao manuscrito editorial v0.54**: Figuras 1–7 em SVG com legendas e textos alternativos, e Quadro 1 em tabela Markdown acessível. A conferência estrutural está documentada na [auditoria editorial consolidada](oes-auditoria-editorial-elementos-visuais-v054.md), realizada sobre o manuscrito v0.54. A integração **não constitui validação científica independente, aprovação externa, prova de paginação do manuscrito completo ou liberação operacional**. Permanecem pendentes correções editoriais pontuais e prova de composição integral antes de circulação externa. A data factual do manuscrito continua **20 de outubro de 2026**.

> **Registro histórico preservado:** as declarações abaixo sobre figuras ainda não produzidas, a referência à versão **0.46** e a situação original ao encerrar o plano descrevem **somente o momento da elaboração inicial deste planejamento**. Não representam o estado editorial atual nem devem ser interpretadas como reversão da integração realizada.

**Status:** proposta editorial de planejamento; figuras **não produzidas, não inseridas nem aprovadas**.
**Data de referência:** 20 de outubro de 2026.
**Manuscrito de referência:** [Fundamentos científicos, arquitetura metodológica e modelo de desenvolvimento](oes-fundamentos-arquitetura-modelo-desenvolvimento.md), versão editorial **0.46**, `main`, HEAD inicial `ff912e95570f1fc47f2b02bc91d9e98f868afae8`.
**Público:** pesquisadores em saúde que ainda não conhecem a arquitetura e a trajetória do OES.
**Escopo deste registro:** definir localização, função, desenho lógico, conteúdo mínimo, legenda, acessibilidade e critérios de aceite. Não alterar o manuscrito, as fontes canônicas, os *gates* ou o estado operacional.

## 1. Decisão editorial

A inserção de elementos visuais é recomendada quando **substituir explicações repetidas**, **tornar relações ou decisões inequívocas** ou **impedir interpretações indevidas sobre validação e operação**. Não há indicação de acrescentar gráficos quantitativos de desempenho sem dados observacionais comparáveis e método de mensuração adequado.

**Conjunto-base: oito elementos visuais (sete figuras e um quadro)**, cobrindo panorama, taxonomias, processo de produção, portfólio, atualização, trajetória, tipos de verificação e casos. **Até dois elementos opcionais** somente se testes de leitura mostrarem lacuna real: proveniência científica de dados (Cap. 8) e síntese crítica final (Cap. 16). Nenhuma figura é requisito de conformidade científica.

As tabelas já existentes no manuscrito devem ser preservadas quando oferecem definições precisas: N0–N4 (§4.2), A0–A3 (§7.3), estados de atualidade (§10.2), fases (§12.1), indicadores (§13.6), resultados (§14.1) e marcos do observatório mínimo viável (§15). Uma figura nova deve acrescentar **estrutura relacional ou fluxo**, não copiar o conteúdo dessas tabelas.

## 2. Conjunto-base de figuras — especificação

### Figura 1 — Visão de conjunto: da pergunta ao produto de evidências
- **Inserção:** Capítulo 1, ao término do primeiro bloco explicativo da §1.4 — *Apresentação do OES*.
- **Tipo:** diagrama conceitual horizontal, com leitura linear e uma dimensão transversal de garantia.
- **Conteúdo:** necessidade/pergunta → investigação com método proporcional → objetos científicos rastreáveis → síntese e interpretação → produto de evidências; **manutenção e reavaliação quando aplicáveis**, não para todo produto. Indicar, em faixa transversal, fontes, proveniência, revisão e limitações.
- **Mensagem central:** o OES organiza um processo científico apoiado por arquitetura informacional; **não** é apenas ferramenta de busca ou gerador automático de conclusões.
- **Legenda sugerida:** “Figura 1 — Organização conceitual proposta para o OES. Os blocos representam funções metodológicas, não serviços operacionais comprovadamente disponíveis. A revisão especializada independente e a operação factual contínua permanecem pendentes.”
- **Não representar:** monitoramento automatizado em produção, A3 obtido, fluxo executado de ponta a ponta para todos os nove produtos.
- **Prioridade:** P1.

### Figura 2 — Três dimensões independentes: investigação N, manutenção M e garantia A
- **Inserção:** §4.5 — *Independência entre profundidade e manutenção*, com remissão à tabela A0–A3 da §7.3.
- **Tipo:** três eixos ou três painéis paralelos **não hierarquizados**; setas de influência opcionais, sem sugerir progressão automática.
- **Conteúdo:** N0–N4 = modalidade/profundidade e finalidade da investigação; M0–M3 = compromisso de acompanhamento; A0–A3 = verificações e aprovações efetivamente obtidas. Uma mesma pergunta/produto pode ter combinações justificadas, sujeitas às políticas específicas. N, M e A são categorias **internas do OES**.
- **Mensagem central:** um nível N mais elevado **não** gera automaticamente M3 ou A3; A2 é aprovação interna, A3 requer revisor independente humano qualificado; M3 permanece bloqueado.
- **Legenda sugerida:** “Figura 2 — Independência conceitual entre profundidade investigativa (N), manutenção (M) e garantia (A). As categorias são específicas do OES; o diagrama não constitui uma escala universal de qualidade nem indica estados alcançados por todos os produtos.”
- **Não representar:** cubo de 5×4×4 combinações como se todas estivessem permitidas, validadas ou implementadas.
- **Prioridade:** P1.

### Figura 3 — Fluxo metodológico de produção e revisão da evidência
- **Inserção:** após a introdução da §5.1, como orientação para o conjunto da Seção 5; remissão desde a §9.1, evitando segundo fluxograma redundante.
- **Tipo:** fluxograma com pontos de decisão/retorno.
- **Conteúdo:** pergunta/protocolo → busca identificável → seleção → extração → avaliação crítica → síntese pertinente → certeza/confiança quando aplicável → interpretação → revisão segundo requisitos do produto → publicação ou correção/bloqueio; proveniência ligada a todas as fases.
- **Mensagem central:** a apresentação de um produto depende da execução verificável dos procedimentos apropriados e da decisão de garantia; um `PASS` técnico isolado não basta.
- **Legenda sugerida:** “Figura 3 — Percurso metodológico de referência para uma investigação no OES. A extensão de cada etapa depende da pergunta e da modalidade; trajetos abreviados não autorizam afirmações de completude, e determinados produtos exigem revisão humana independente.”
- **Não representar:** busca exaustiva ou meta-análise como obrigatórias para N0/N1; IA aprovando a si própria como revisão independente.
- **Prioridade:** P1.

### Figura 4 — Nove produtos e suas funções no sistema
- **Inserção:** §6.1 — *Conceito e função dos produtos científicos*.
- **Tipo:** mapa de famílias de produtos, com três agrupamentos e relações de derivação **não obrigatórias**.
- **Conteúdo:** cinco produtos investigativos N0–N4; dois produtos analíticos transversais (Mapa e Overview); dois de manutenção/comunicação temporal (Monitor e Alerta). Uma camada inferior mostra objetos e evidências compartilhados; ligações pontilhadas representam reutilização possível, não sequência obrigatória.
- **Mensagem central:** produto, investigação e acompanhamento temporal têm finalidades distintas; reutilização preserva fonte e versão.
- **Legenda sugerida:** “Figura 4 — Portfólio conceitual de nove produtos do OES. As relações indicam possíveis reutilizações de objetos científicos, não um encadeamento obrigatório, disponibilidade pública ou validação científica integral.”
- **Não representar:** uma pirâmide de qualidade entre os nove produtos ou MAP/OVR como níveis N adicionais.
- **Prioridade:** P1.

### Figura 5 — Decisão de atualizar: sinal, materialidade e versão científica
- **Inserção:** §10.4 — *Avaliação da relevância das novas informações*; remissão à tabela de `currentness` da §10.2.
- **Tipo:** fluxograma decisório com bifurcação e uma alça de retorno.
- **Conteúdo:** fonte/sinal potencial → verificação de pertinência e proveniência → avaliação de materialidade → decisão documentada (sem alteração científica; reavaliação adicional; atualização necessária) → revisão/garantia → **nova versão científica quando aprovada**, preservando a anterior. Indicar possíveis falhas e cobertura incompleta sem inferir “nenhuma evidência nova”.
- **Mensagem central:** Monitor e Alerta detectam e comunicam sinais; **não** atualizam automaticamente conclusões. M3 bloqueado no estado documentado.
- **Legenda sugerida:** “Figura 5 — Fluxo decisório de atualização proposto pelo OES. As transições dependem de avaliação e autorização; esta representação não atesta vigilância factual contínua nem funcionamento de M3.”
- **Não representar:** transições automáticas da máquina de estados que não estejam previstas no Documento 05; salto de `under_evaluation` para publicação sem revisão.
- **Prioridade:** P1.

### Figura 6 — Trajetória do desenvolvimento e estado de cada fase
- **Inserção:** §12.1 — *Abordagem incremental*, imediatamente após a tabela de fases (sem repetir sua descrição integral).
- **Tipo:** linha de desenvolvimento em oito fases, com **categorias de estado escritas** em cada fase. Evitar gráfico de progresso ou porcentagens sem base.
- **Conteúdo:** Fase 0: base inicial consolidada; Fase 1: protocolos iniciais consolidados; Fase 2: baseline arquitetural concluída; Fase 3: concluída em seu escopo; Fase 4: **em desenvolvimento / NOT_READY para operação factual**; Fases 5–7: **não iniciadas formalmente**. Fonte de estado: `STATE.md` e CP213, na data de referência.
- **Mensagem central:** conclusão de fase documental ou técnica não constitui validação independente nem operação sustentada; numeração expressa programa de desenvolvimento.
- **Legenda sugerida:** “Figura 6 — Trajetória documentada do OES até 20 de outubro de 2026. Os estados indicam marcos formais específicos e não porcentagens de maturidade ou eficácia científica.”
- **Não representar:** Fases 5–7 executadas, Fase 4 concluída, B1R1 como medição factual realizada.
- **Prioridade:** P1; alta sensibilidade temporal, atualizar somente mediante decisão canônica.

### Figura 7 — O que cada tipo de verificação demonstra — e não demonstra
- **Inserção:** §13.1 — *Dimensões de validação*, com remissão à §13.5 e à tabela de garantia da §7.3.
- **Tipo:** matriz conceitual de “objeto verificado → evidência produzida → limite inferencial”.
- **Conteúdo:** revisão documental; testes de engenharia/PoC; revisão adversarial assistida por IA; aprovação de governança A2; revisão especializada independente A3; liberação operacional. Marcar distintamente **realizado em escopos delimitados**, **não demonstrado/pendente** e **não iniciado**.
- **Mensagem central:** testes técnicos, aprovação interna, revisão científica e prontidão operacional são dimensões não substituíveis.
- **Legenda sugerida:** “Figura 7 — Alcance inferencial dos controles do OES. A aprovação documental ou técnica não certifica qualidade de sínteses científicas; A2 não equivale à revisão independente exigida para A3.”
- **Não representar:** A3 cumprido em produtos não submetidos a revisão humana independente, ou todos os critérios de aceitação operacional satisfeitos.
- **Prioridade:** P1.

### Quadro 1 — Casos documentados: produto, resultado e limite
- **Inserção:** §14.2 — *Exemplos de aplicação*, **antes** da descrição individual dos casos.
- **Tipo:** quadro-síntese comparativo; preferencialmente tabela acessível, não “placar” ou ranking de desempenho.
- **Conteúdo mínimo:** N0 (A1, não publicável); N1 (A2, publicação interna); N2 (A2, publicação interna, certeza provisória); N3 (A0 experimental, bloqueado); N4 (real formal não iniciado; gate NOT_READY, **não atribuir garantia artificial**); MAP-01 (A1 interno, sob revisão); OVR-01 (A1 interno, sob revisão); Monitor/Alerta (testes técnicos/sintéticos, sem vigilância factual contínua, M3 bloqueado). Colunas: objeto, uso demonstrado, estado/garantia quando cabível, limite científico.
- **Mensagem central:** existe diversidade de evidência sobre o **desenvolvimento**, não um conjunto homogêneo de produtos validados.
- **Legenda sugerida:** “Quadro 1 — Casos e percursos documentados no OES até 20 de outubro de 2026. Estados A e M referem-se a controles internos específicos; a representação não constitui comparação de eficácia nem aprovação científica independente.”
- **Não representar:** N4 como caso factual executado, M2 sintético como monitoramento real ou contagem de revisões como ensaios primários independentes.
- **Prioridade:** P1.

## 3. Figuras opcionais — somente mediante necessidade editorial confirmada

### Figura opcional 8 — Proveniência: estudo, relatório, resultado e produto
- **Possível inserção:** §8.2 ou §8.3, sem tentar reproduzir o esquema PostgreSQL.
- **Tipo:** grafo conceitual mínimo com Study, Report, Result, Synthesis, Investigation e ProductVersion, com ligações semanticamente verificáveis na documentação de arquitetura.
- **Valor incremental:** impedir confusão entre unidade científica e publicação e esclarecer reutilização.
- **Legenda sugerida:** “Figura 8 — Exemplo simplificado de relações de proveniência no OES. A figura não substitui o modelo canônico de dados nem esgota suas entidades e invariantes.”
- **Decisão:** produzir somente se uma leitura de teste indicar dificuldade real com o Capítulo 8; otherwise, preferir referência a figuras anteriores.

### Quadro opcional 2 — Contribuições, limitações e agenda de avaliação
- **Possível inserção:** §16.5, na passagem de síntese final.
- **Tipo:** três colunas textuais enxutas; sem gráfico de desempenho.
- **Valor incremental:** explicitar a distinção entre contribuição conceitual documentada, limitações comprovadas e questões ainda não avaliadas.
- **Legenda sugerida:** “Quadro 2 — Síntese crítica das contribuições documentadas, limitações atuais e questões de investigação futura. Não representa avaliação independente ou validação da replicabilidade do modelo.”
- **Decisão:** incluir apenas se reduzir efetivamente a redundância da conclusão, em vez de repeti-la.

## 4. Regras de composição e terminologia

1. **Uma mensagem por figura:** enunciado no texto e legenda devem especificar o que o visual mostra e **o que não demonstra**, especialmente se houver estados operacionais ou níveis de garantia.
2. **N, M, A e D são taxonomias próprias do OES:** não usar eixos de maturidade universais, certificações ou codificação de “aprovado” com cor sem rótulo textual. D0/D1/D2 não devem ser misturados aos eixos científicos N/M/A.
3. **Rastreabilidade factual:** números, datas, estados e transições devem existir no manuscrito, `STATE.md`, CP213 ou documentos metodológicos citados. Não inventar taxas de sucesso, tempos, custos, percentuais ou métricas de desempenho.
4. **Distinção de planos:** fluxos conceituais devem ser marcados **propostos**; fases e resultados devem usar **estado documentado em 20/10/2026**; resultados científicos de terceiros não podem ser redesenhados como análises originais do OES.
5. **Simplicidade tipográfica:** português brasileiro, acrônimos definidos, poucos elementos por plano, rótulos curtos, texto mínimo legível em A4 e exportação vetorial. Evitar ícones ilustrativos, clipart, gráficos de pizza, semáforos genéricos e blocos de aparência promocional.
6. **Acessibilidade e reuso:** texto alternativo descritivo, leitura em preto e branco, contraste suficiente, sem dependência exclusiva de cor; fonte editável versionada ao lado do SVG (preferir Mermaid para fluxos simples ou SVG editável para diagramas mais complexos). Se for gerado PDF, validar o resultado renderizado.
7. **Integração científica:** figura deve ser chamada pelo texto (“Figura 3”) no parágrafo pertinente, com numeração contínua. Quadro 1 (casos) e eventual Quadro 2 usam série própria, para não conflitar com as tabelas já existentes. Definir estilo editorial final antes de numeração definitiva.
8. **Controle de escopo:** nenhuma figura pode causar modificação de `STATE.md`, CP213, *gates*, banco de dados, CI, produtos científicos ou autorizações operacionais. A inserção visual altera **apenas a apresentação do manuscrito** e, se necessário, novos arquivos de figuras.

## 5. Ordem e aceite

**Primeira entrega visual recomendada:** Figura 1 (visão geral), como protótipo de linguagem gráfica e verificação de legibilidade por leitor externo; revisar antes de replicar estilo.

**Sequência:** Figura 2 (dimensões) → Figura 7 (tipos de validação) → Quadro 1 (casos) → Figura 3 (produção) → Figura 5 (atualização) → Figura 4 (portfólio) → Figura 6 (trajetória). O conjunto-base é editorial, não condição de pesquisa nem autorização para desenvolvimento operacional.

Para cada figura, uma atividade delimitada por “Prossiga”: (a) especificação fiel e fonte; (b) versão editável do esquema; (c) inspeção de semântica, acessibilidade e legibilidade; (d) inserção no manuscrito **somente após aprovação de seu conteúdo**, Freshness Gate e verificação de alterações. Agrupar commits quando proporcional ao risco, conforme protocolo de continuidade; não criar checklists ou checkpoints excessivamente granulares.

**Critérios finais de aceite:** clareza para leitores externos; ausência de declarações não comprovadas; fidelidade às categorias, aos gates e ao estado factual; nenhuma figura redundante com tabela existente; legibilidade em tela e A4; texto alternativo; arquivos-fontes rastreáveis; referências bibliográficas e numeração íntegra; confirmação de HEAD e diff.

**Situação ao encerrar este plano:** nenhum elemento visual foi criado, adicionado ao manuscrito ou considerado cientificamente aprovado. Esta é uma decisão de arquitetura editorial proposta para orientar as próximas atividades.
