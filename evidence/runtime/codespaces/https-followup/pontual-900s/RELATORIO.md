# OES — ensaio pontual HTTPS com limite de 900 segundos

## Resultado e escopo

**Conectividade HTTPS pontual demonstrada**, segundo a saída sanitizada do JavaScript fornecida pelo responsável: uma requisição GET relativa à raiz recebeu HTTP 200 e confirmou o marcador `oes-https-diagnostic`. A matriz de cabeçalhos não foi executada. O resultado não comprova remoção/sobrescrita de X-Forwarded-Proto, não estabelece garantia universal do ingresso e não autoriza trusted_proxy ou liberação operacional.

Base da main: `174872af652ff1d98833e7d3fe1aef15e5696e53`.
Branch de entrega: `evidence/oes-codespaces-https-followup`.
Antecessor publicado: `466e5e910e4de4a09b569c8ab096e9ce057abc3b`, cujos arquivos não foram sobrescritos. Os resultados 401 anteriores permanecem históricos; este resultado positivo não redefine sua causa.

## Preliminares e autorização

O despacho autorizou um único ensaio de conectividade, limite externo de 900 segundos, sem matriz completa ou reinício. A porta 8000 já estava encaminhada como Private por declaração do responsável no despacho; o executor não inspecionou a interface diretamente.

Antes do início, o executor constatou porta livre, leu integralmente `oes_https_probe.js`, confirmou uma única chamada fetch relativa a `/`, ausência de destinos externos ou leitura de credenciais/armazenamento, arquivo fora do índice e não versionado. A única alteração local era esse script previamente solicitado. Nenhuma alteração inesperada ou arquivo staged foi observado. A sintaxe havia sido verificada previamente com node --check, sem executar o JavaScript no terminal.

O script utiliza a sessão normal do navegador por comportamento padrão de same-origin fetch. Não lê, extrai, imprime ou copia cookies, tokens, credenciais, cabeçalhos de autorização, localStorage ou sessionStorage. Não se afirma ausência de cookies enviados automaticamente pelo navegador. Redirecionamentos são recusados; cache no-store; timeout de cinco segundos. A saída contém somente horários UTC do navegador, duração, status, confirmação booleana do marcador e classificação estática, sem corpo completo, URL ou cabeçalhos.

SHA-256 do script inspecionado: `0bc215c276b2933bef94a12d6b95e3737ad4a544fdd6fa9f2ae0e3e6e20d8af0`.
O script permanece não versionado e não integra esta publicação.

## Execução observada pelo executor

Reutilizado o mesmo coletor Python padrão dos ensaios anteriores, alterando o limite externo para timeout 900s. Ambiente limpo por env -i, execução isolada -I -B, bind em 127.0.0.1:8000; sem Django, Gunicorn, aplicação, secrets operacionais, PostgreSQL, Neon ou SQL. Logs de acesso desabilitados. GET retorna o marcador e os quatro cabeçalhos selecionados via get_all(), sem exportação de seus valores nesta evidência. Cache-Control: no-store.

- `2026-11-17T19:08:47Z`: horário UTC registrado imediatamente antes do comando de início; em seguida, mensagem de inicialização do coletor. Esse é o horário registrado de início, não medição de precisão do instante do bind.
- `2026-11-17T19:09:07.462023+00:00`: uma validação local em loopback, sem proxy, recebeu HTTP 200 e confirmou o marcador. Somente após essa validação o responsável foi avisado para abrir a origem HTTPS e executar o script uma vez após confirmar o marcador.
- `2026-11-17T19:13:20Z`: registrado horário de solicitação de parada; lsof confirmou o processo Python do coletor ainda em LISTEN exclusivamente em 127.0.0.1:8000.
- Após identificar o processo, o executor enviou SIGTERM. O processo terminou com exit 143, compatível com o encerramento solicitado, antes do limite de 900 segundos.
- `2026-11-17T19:13:37Z`: ss não mostrou listener TCP na porta 8000.

Não foram feitos testes HTTPS externos pelo terminal nem repetição automática do teste do navegador.

## Resultado fornecido pelo responsável

O JSON abaixo foi informado pelo responsável como saída da execução única do script no navegador; não é captura direta de navegador pelo executor:

```json
{
  "diagnostic": "oes-https-single-probe",
  "startedAtUtc": "2026-11-17T19:11:50.678Z",
  "responseReceivedAtUtc": "2026-11-17T19:11:51.357Z",
  "finishedAtUtc": "2026-11-17T19:11:51.359Z",
  "durationMs": 680,
  "httpStatus": 200,
  "markerConfirmed": true,
  "outcome": "COLLECTOR_MARKER_CONFIRMED"
}
```

O intervalo do teste informado pelo navegador situa-se entre a validação local e a observação posterior do mesmo processo Python ativo, sem reinício. Em conjunto com HTTP 200 e marcador confirmado, há evidência de atividade do coletor durante a requisição bem-sucedida. Os horários do navegador não foram auditados nem sincronizados independentemente com o relógio do ambiente; não existem logs por requisição para correlação adicional.

A confirmação do marcador na resposta fetch é expressa no JSON. A confirmação visual prévia na navegação foi solicitada como pré-condição, mas não foi recebida em mensagem separada; não é tratada como inspeção independente pelo executor. A origem foi operada pelo responsável conforme o procedimento; URL privada não é publicada.

## Classificação perante o contrato P2

Êxito limitado à conectividade HTTPS pontual desta requisição. Não é aceite operacional PF-08 completo, prova da política de proxy, autenticação exaustiva, inacessibilidade sem autorização ou verificação de cabeçalhos forjados. O ensaio não enviou valores sintéticos de X-Forwarded-Proto, X-Forwarded-Host ou Forwarded. As propriedades de remoção/sobrescrita permanecem não testadas nesta execução.

Referências: `docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md` e `docs/governance/OES_CODESPACES_PREPARATION.md`. Preservar STOP operacional enquanto a cadeia de confiança e prevenção de acesso direto forjado não estiverem demonstradas. Nenhuma alteração de autenticação, validador, TLS_TERMINATION ou configuração Django foi feita.

## Encerramento e condições de STOP

Servidor encerrado após o resultado, sem reinício e antes do prazo máximo; ausência de listener confirmada pelo executor. A remoção do encaminhamento foi solicitada. Em instrução posterior explícita, o responsável decidiu que a porta não seria removida agora e autorizou concluir o encerramento. Portanto, o encaminhamento permanece configurado por decisão do responsável; não se declara remoção nem fechamento completo do recurso na plataforma. O encerramento do servidor e a ausência de listener não equivalem à remoção do encaminhamento. Nenhum novo uso do encaminhamento ou reinício foi realizado.

Nenhuma falha de requisição foi informada neste teste. Continuam condições de STOP: página sem marcador, HTTP não 200, falha/timeout, porta ocupada, exposição Public/Organization, manipulação de credenciais, exposição inesperada ou término de 900 segundos. Nenhuma nova tentativa automática é autorizada pelo resultado.

## Publicação e preservação

Novos arquivos específicos sob `evidence/runtime/codespaces/https-followup/pontual-900s/`, preservando relatórios anteriores. A autorização de publicação existente para o diagnóstico complementar foi utilizada conforme o despacho deste ensaio. Antes da preparação, a branch remota coincidia com o antecessor e main remota permanecia na base aprovada. O script local não é incluído no commit. Os filtros de workflows da base, já inspecionados, não abrangem estes caminhos na branch de evidência; nenhum workflow_dispatch foi solicitado. Não se atestam políticas externas não presentes no repositório.

Sanitização: sem URLs privadas completas, identificadores do Codespace, credenciais, tokens, cookies, autorização, logs autenticados ou dados pessoais. Revisão integral e validações estruturais/diff exigidas antes da publicação. Sem PR, merge ou alteração de main.

Preservados CP348 vigente, Marco B OPEN, Q0 HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 5 NOT_STARTED e núcleo P1/D3. Nenhuma atividade posterior ao ensaio pontual foi iniciada.
