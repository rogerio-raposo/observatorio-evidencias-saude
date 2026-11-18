# OES — Homologação HTTPS, Etapa A

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
