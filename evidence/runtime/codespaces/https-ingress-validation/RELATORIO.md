# OES — Homologação HTTPS, Etapa A

## Histórico — tentativa inicial

**Resultado: INCONCLUSIVO.** O STOP preliminar impediu iniciar o coletor. A campanha não produziu tráfego de teste nem nova evidência sobre a transformação dos cabeçalhos no ingresso. A Etapa B segue pendente.

## Identificação e Freshness Gate

Verificação em 2026-11-18 UTC, CP349, branch `codex/oes-https-ingress-validation`. Base aprovada e HEAD observado da `main` remota: `3ee2b1a733ee412078c5f5859f5aeb30d5fa915d`. O checkout original estava em `e0f4a3e0138ca7e33bee89ce6b3335fef8324fb3`, em uma branch histórica com arquivos locais não rastreados. A leitura canônica foi feita na base remota obtida e o relatório foi preparado em worktree isolada.

Foram consultados o registro vigente de [STATE](../../../../STATE.md), o [ponteiro de continuidade](../../../../archive/handoffs/oes/README.md), o [CP349](../../../../archive/handoffs/oes/OES_Continuidade_2026-11-17_CP349.md), o [Documento 362](../../../../docs/governance/362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md), a [estratégia de trabalho](../../../../docs/governance/OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md), [AGENTS.md](../../../../AGENTS.md), a [decisão HTTPS](../../../../docs/governance/OES_CODESPACES_HTTPS_ARCHITECTURAL_DECISION_DRAFT.md) e a [preparação Codespaces](../../../../docs/governance/OES_CODESPACES_PREPARATION.md).

A API do GitHub confirmou o [PR #44](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/44) integrado no SHA da base. O PR relata 104 testes offline PASS, incluindo cobertura de esquema, listas, redirect HTTPS, Host, CSRF, cookies e HTTP mutante 423. Esses resultados foram reaproveitados sem reexecução. Seu alcance é o comportamento offline da aplicação.

## Ambiente e verificações executadas

| Verificação | Observação |
| --- | --- |
| Ambiente e recurso existente | Variáveis de contexto Codespaces presentes. A API autenticada retornou estado `Available` e máquina de 2 vCPUs para o Codespace atual. Nenhum recurso foi criado ou redimensionado. |
| Ferramentas | Python 3.12.11, Git 2.50.1 e curl 7.88.1. GitHub CLI indisponível. Consultas administrativas feitas pela API, com saída restrita aos campos necessários. |
| Elegibilidade e cobrança | A API retornou HTTP 403 na consulta individual de consumo. Titularidade da cobrança, franquia restante, política de bloqueio e ausência de custo adicional não puderam ser confirmadas. A disponibilidade do recurso comprova existência, sem demonstrar essas condições. |
| Porta e encaminhamento | A visibilidade efetiva e a configuração atual de encaminhamento não puderam ser verificadas. A configuração versionada do Gunicorn prevê `127.0.0.1:8000`, sem confiança automática nos cabeçalhos encaminhados. |
| Custódia | Observação passiva do socket TCP local mostrou zero listeners na porta 8000. A observação não determinou quem poderia executar processos ou alcançar o loopback durante um ensaio. |
| Credenciais | Ausentes do ambiente consultado as quatro variáveis operacionais nominais do OES e `DATABASE_URL`. A verificação se limitou à presença dos nomes. Nenhuma credencial operacional foi criada ou usada. |

**STOP aplicado antes de iniciar o coletor** por falta de confirmação administrativa de privacidade, custódia e condições de cobrança. A investigação da falha conhecida do sandbox permaneceu fora do ensaio.

## Ingresso, privacidade e cabeçalhos

| Caso | Resultado desta campanha |
| --- | --- |
| Acesso HTTPS autorizado e correlação com o backend | Não executado após STOP. |
| Restrição a cliente sem autorização | Não executada após STOP. A visibilidade atual ficou indeterminada. |
| `Host`, `X-Forwarded-Proto`, `X-Forwarded-Host`, `X-Forwarded-Port` e `Forwarded` | Nenhuma requisição nova. Não há observações atuais dos valores enviados, recebidos ou transformados. |
| Acesso direto ao coletor | Não executado após STOP. Não houve coletor nesta campanha. |

O [ensaio pontual histórico](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/evidence/oes-codespaces-https-followup/evidence/runtime/codespaces/https-followup/pontual-900s/RELATORIO.md) relata HTTP 200 com marcador. Na [matriz histórica](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/evidence/oes-codespaces-https-followup/evidence/runtime/codespaces/https-followup/header-matrix-900s/RELATORIO.md), 14 de 14 casos tiveram HTTP 200 e marcador. O coletor registrou uma ocorrência de `X-Forwarded-Proto` com `https`, uma de `X-Forwarded-Host` com valor redigido e ausência de `Forwarded`. O `Host` recebido diferiu do host da origem do navegador. A matriz não estabeleceu o tratamento de `X-Forwarded-Port`.

Os casos históricos descrevem os valores solicitados no JavaScript e os observados no coletor. O envio efetivo dos campos na rede não foi confirmado. O padrão é compatível com normalização ao longo do caminho observado, mas a camada responsável permanece indeterminada. A hipótese de influência externa sobre `X-Forwarded-Proto` continua aberta.

## Fronteira de confiança e pendências

A [revisão histórica da topologia](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/review/oes-codespaces-https-topology/docs/governance/OES_CODESPACES_HTTPS_TOPOLOGY_REVIEW_DRAFT.md) distingue o ingresso gerenciado da escuta local. O bind em loopback limita as interfaces de escuta. Processos com acesso ao mesmo loopback ainda podem alcançar um serviço ativo e fornecer seus próprios cabeçalhos. A política `Private` protege a entrada gerenciada. A confiança no backend também depende da custódia dos processos locais. A campanha atual não mediu acesso direto nem confirmou essa custódia.

Para retomar a Etapa A, o responsável pela conta precisa confirmar elegibilidade, franquia e consumo, titularidade e condições de cobrança, visibilidade `Private` e encaminhamento atual na aba Ports, além da custódia do ambiente. Para avaliar a passagem à Etapa B, ainda é necessária evidência correlacionada de ingresso autorizado, restrição de acesso sem autorização quando verificável, proveniência do esquema entregue ao coletor e alcance da fronteira local. A Etapa B exige decisão própria.

## Encerramento

Nenhum coletor ou processo temporário de teste foi iniciado. A última inspeção retornou zero listeners TCP na porta 8000. O último estado administrativo observado do Codespace foi `Available`, com visibilidade final da porta indeterminada. O Codespace preexistente não foi parado nem excluído. A confirmação de visibilidade, o acompanhamento de consumo e eventual parada administrativa ficam com o responsável pelo recurso.

O diff contém apenas este relatório. Nenhum gate foi promovido. Marco B OPEN, Q0 geral HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY, Fase 5 NOT_STARTED, P1/P2/D3, `_require_release()` em HOLD, HTTP mutante 423 e ausência de retry automático foram preservados. A Etapa B não foi executada.

## Retomada — 2026-11-18 UTC

**Resultado geral: INCONCLUSIVO.** O ingresso autorizado, a restrição do cliente anônimo no caso observado e a fronteira local foram verificados. O comportamento do ingresso diante de valores de esquema fornecidos pelo cliente continua indeterminado.

### Base e condições administrativas

CP349, Codespace existente, Python 3.12.11 e GitHub CLI 2.83.2 temporária com checksum oficial conferido. A `main` remota coincidiu com a base `3ee2b1a733ee412078c5f5859f5aeb30d5fa915d`. A retomada partiu do commit `502680b71f40cc527dda6bd33cb83cb51794c5e6` na branch do PR #45. A evidência offline do PR #44 e a matriz de navegador foram reaproveitadas sem reexecução.

O responsável declarou uso exclusivamente pessoal, porta 8000 configurada como `Private`, consumo de novembro integralmente compensado pela franquia e ausência de dados de cobrança cadastrados. Autorizou a retomada. A consulta de cobrança anterior não foi repetida. A campanha reutilizou o encaminhamento existente e não alterou a capacidade ou as configurações do recurso.

### Método e matriz

O comando documentado de listagem de portas confirmou `Private` imediatamente antes de iniciar o coletor, com o coletor ativo e após encerrá-lo. O coletor HTTP sintético escutou somente em `127.0.0.1:8000`, com ambiente vazio e sem persistência. O cliente HTTPS validou TLS, não seguiu redirecionamentos e, no caso autorizado, utilizou a autenticação de encaminhamento do GitHub descrita na documentação. As requisições usaram caminhos distintos para correlação. A saída limitou-se a contagens, comparações, valores conhecidos de esquema e status. [Listagem de portas](https://cli.github.com/manual/gh_codespace_ports) · [Encaminhamento no Codespaces](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace?tool=cli)

| Caso | Envio do cliente | Observação | Classificação |
| --- | --- | --- | --- |
| Controle local | HTTP direto, `Host` do loopback, sem cabeçalhos encaminhados | HTTP 200 com marcador. Um `Host` igual ao endereço local. Ausentes `X-Forwarded-Proto`, `X-Forwarded-Host`, `X-Forwarded-Port` e `Forwarded`. | PASS para verificar a capacidade de um processo local de alcançar o coletor. |
| HTTPS sem autenticação | `Host` da origem HTTPS, sem autenticação e sem cabeçalhos encaminhados | HTTP 302, sem marcador e sem registro correspondente no coletor. | PASS para a restrição observada nesta tentativa. |
| HTTPS autenticado normal | `Host` da origem HTTPS, autenticação de encaminhamento e ausência deliberada de cabeçalhos encaminhados | HTTP 200 com marcador e registro correspondente. Um `Host` distinto da origem e do endereço local. Uma ocorrência de `X-Forwarded-Proto=https`, uma de `X-Forwarded-Host` igual ao host de origem, uma de `X-Forwarded-Port=443` e nenhuma de `Forwarded`. | PASS para conectividade e observação dos campos no caso normal. |
| Esquema divergente ou múltiplo | Sem nova execução desses casos no ingresso. | A matriz histórica não verificou o que o navegador efetivamente enviou. | INCONCLUSIVO para a proveniência do esquema sob entrada controlada pelo cliente. |

O caso normal demonstra que os três campos encaminhados foram acrescentados entre o cliente e o coletor no caminho gerenciado observado. O ponto interno de inserção ou reescrita não foi instrumentado. A diferença de `Host` é material para a futura validação do host convencional no Django, cuja resposta operacional permanece indeterminada. O caso normal não permite determinar a política para valores preexistentes enviados pelo cliente.

### Fronteira local e encerramento

O processo cliente local alcançou diretamente o único listener observado, via loopback, sem passar pelo HTTPS gerenciado. O coletor também observou par loopback no caso autorizado via ingresso. Assim, a observação do endereço do par, por si só, não identifica o caminho da requisição. A custódia declarada reduz o risco administrativo, sem estabelecer isolamento entre processos.

Ao fim, o coletor foi encerrado, a porta encaminhada permanecia `Private` e a inspeção encontrou zero listeners TCP na porta 8000. O Codespace existente permaneceu em uso para publicação. A Etapa B permanece pendente de evidência suficiente de proveniência do esquema e de avaliação da divergência de `Host`. Nenhum gate foi promovido.

## Ensaio complementar — 2026-11-18 UTC

**Etapa A: FAIL.** A hipótese de compatibilidade do `Host` convencional (H2) foi **REFUTADA** para o caminho exercitado e o contrato nominal. A hipótese de influência indevida do cliente sobre o esquema (H1) permanece **INCONCLUSIVA**. A tentativa de homologação foi interrompida após a incompatibilidade material de H2.

### Base e método

O Freshness Gate confirmou a `main` remota em `3ee2b1a733ee412078c5f5859f5aeb30d5fa915d` e a branch `codex/oes-https-ingress-validation` em `22a7826f1c9f46eb94d4af394ac7836fdd774d41` antes do ensaio e da publicação. Foram consultados o CP349, os três documentos canônicos, as duas tentativas deste relatório e os testes de Host do PR #44.

No Codespace existente, um coletor Python temporário, com ambiente vazio, escutou somente em `127.0.0.1:8000`. A GitHub CLI confirmou a porta `Private` antes e durante a execução. Um cliente autenticado fez uma requisição HTTPS normal com validação TLS e identificador aleatório, sem cabeçalhos encaminhados definidos pelo cliente. HTTP 200 com marcador e registro do coletor confirmou a correlação. Os valores de autoridade foram comparados em memória. A evidência persistida contém apenas propriedades e resultados da comparação.

### Resultados

| Hipótese e caso | Observação | Classificação |
| --- | --- | --- |
| H1 — esquema ausente no cliente | O cliente não definiu `X-Forwarded-Proto`. O coletor registrou uma ocorrência com `https`. Há evidência de inserção no caminho exercitado para esse caso. A camada interna responsável não foi instrumentada. | Caso normal observado. |
| H1 — influência de valores divergentes, múltiplos ou duplicados | Esses casos não foram executados neste ensaio. A matriz histórica de navegador não confirmou a transmissão efetiva. Substituição, concatenação e preservação diante de entrada do cliente continuam indeterminadas. | **INCONCLUSIVA** |
| H2 — comparação das autoridades | A origem HTTPS nominal usou o hostname esperado, sem porta explícita. O coletor recebeu um único `Host`, sintaticamente válido, em minúsculas, sem ponto final, com porta explícita 8000 e hostname diferente da origem mesmo após a normalização do Django. `X-Forwarded-Host` coincidiu com o hostname nominal. | Diferença material de hostname confirmada. |
| H2 — validação Django offline | Em processo isolado, `HttpRequest.get_host()` do Django 5.2.19 aceitou o controle nominal e levantou `DisallowedHost` para a autoridade capturada, com `ALLOWED_HOSTS` limitado ao hostname nominal e `USE_X_FORWARDED_HOST=False`. O campo encaminhado nominal estava presente em ambos os casos. | Hipótese de compatibilidade **REFUTADA**. |

O resultado offline demonstra a rejeição na validação nativa do Host. Os testes integrados do PR #44 registram HTTP 400 para Host inválido no fluxo testado. Nenhuma resposta do Django operacional foi observada no Codespace. O achado se limita ao caminho e à configuração nominal exercitados.

### STOP e encerramento

O coletor foi encerrado e seu processo recolhido. A inspeção final encontrou zero listeners TCP na porta 8000 e confirmou novamente `Private`. O encaminhamento preexistente permaneceu configurado. A campanha não ativou Django operacional, não conectou ao banco e não promoveu gates.

Uma eventual Etapa B depende de decisão arquitetural autorizada sobre o Host, evidência suficiente sobre a proveniência do esquema, revisão independente e autorização posterior.
