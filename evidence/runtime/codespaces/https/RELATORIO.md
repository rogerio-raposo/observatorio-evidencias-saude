# OES — diagnóstico HTTPS isolado

Base aprovada: `174872af652ff1d98833e7d3fe1aef15e5696e53`.
Branch de entrega: `evidence/oes-codespaces-https`.

## Escopo e procedimento executado

Ensaio limitado ao ingresso do Codespaces existente, sem Django, Gunicorn, importação da aplicação, secrets ou PostgreSQL. Utilizado Python 3.12.11 padrão, em ambiente limpo via `env -i`, modo isolado `-I -B`, servidor `HTTPServer` vinculado a `127.0.0.1:8000` e limite externo `timeout 300s`, sem reinício automático.

O coletor respondeu a GET com JSON contendo marcador sintético, transporte local HTTP e apenas Host, X-Forwarded-Proto, X-Forwarded-Host e Forwarded, preservando listas/duplicatas. Logs de acesso foram suprimidos; respostas incluíram Cache-Control: no-store. Nenhum arquivo de requisição autenticada foi armazenado.

A sequência foi: confirmar porta livre; iniciar coletor; enviar os quatro cabeçalhos sintéticos pelo loopback; solicitar encaminhamento manual Private e observações do navegador; consultar endereço HTTPS calculado pelas variáveis não secretas da plataforma com curl sem credenciais; aguardar até o encerramento automático; verificar ausência de listener e solicitar remoção do encaminhamento. A URL calculada não foi confirmada na aba Ports pelo operador.

## Resultados efetivamente observados pelo executor

1. Antes do início, não havia listener TCP na porta 8000.
2. O coletor iniciou e foi observado em `127.0.0.1:8000`.
3. GET local retornou o marcador `oes-https-diagnostic` e exatamente os valores enviados: Host `oes-probe.invalid`; X-Forwarded-Proto `http`; X-Forwarded-Host `oes-probe.invalid`; Forwarded `proto=http;host=oes-probe.invalid`. Isso comprova funcionamento do coletor; não comprova tratamento pelo ingresso externo.
4. Uma consulta HTTPS sem credenciais ao endereço calculado pela plataforma terminou com curl exit 0, HTTP 404 e ausência do marcador. Redirecionamentos não foram seguidos, validação TLS não foi desabilitada e não houve stderr. A resposta não distingue barreira de autorização de encaminhamento inexistente ou indisponível.
5. O processo terminou com exit 124 do timeout, compatível com o limite de 300 segundos. Após o término, a consulta de listeners não mostrou a porta 8000.

## Verificações não realizadas ou sem confirmação

Não foram recebidas observações manuais até esta versão do relatório: visibilidade efetiva Private, URL real na aba Ports, acesso HTTPS autenticado ao coletor, teste em navegador sem sessão e resultados da matriz de cabeçalhos sintéticos através do ingresso. A remoção do encaminhamento foi solicitada e permanece sem confirmação; não se presume que tenha sido criado ou removido.

Foi fornecida ao operador uma matriz para baseline, X-Forwarded-Proto=http, https e lista `http, https`, X-Forwarded-Host sintético, Forwarded sintético e combinação. O código fornecido redigia hosts reais antes de exibir resultados. Nenhum resultado dessa matriz está sendo inferido.

Host forjado foi testado somente no loopback. O navegador não permite definir Host via fetch; o ensaio não manipulou autenticação para contornar essa limitação. Ausência de listener não equivale a remoção do encaminhamento na plataforma.

## Interpretação perante o contrato P2

Classificação: evidência técnica parcial de diagnóstico isolado; ingresso HTTPS privado e confiança no proxy INCONCLUSIVOS. Não constitui aceite operacional PF-08, implantação, prova conectada da aplicação ou autorização de liberação.

O teste local aceita valores forjados porque o coletor apenas os observa. Não demonstra falha nem proteção do ingresso Codespaces. O HTTP 404 externo não prova Visibility: Private. Não há prova de remoção/sobrescrita de cabeçalhos enviados pelo cliente, autenticidade do proxy, esquema confiável para WSGI ou adequação de trusted_proxy. Não selecionar trusted_proxy com base neste ensaio. Escolher wsgi tampouco comprova transporte confiável do esquema HTTPS.

Referências: `docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md` e `docs/governance/OES_CODESPACES_PREPARATION.md`, da base aprovada. As lacunas permanecem documentadas, sem alterar validadores, configurações, redirects, cookies ou gates.

## Encerramento e STOP

Servidor encerrado automaticamente, sem reinício; ausência de listener confirmada. Remoção do encaminhamento solicitada, pendente de confirmação do operador. Nenhuma atividade posterior ao diagnóstico foi iniciada.

A execução atingiu o limite temporal antes de obter as confirmações manuais. STOP para novas execuções automáticas e para qualquer promoção operacional baseada nesta evidência. Também são condições de STOP: porta Public/Organization; acesso não autorizado ao coletor; custos/políticas indefinidos; porta ocupada; necessidade de credenciais; exposição imprevista; controle do esquema confiável por cabeçalho forjado; cadeia de confiança não demonstrada. Não corrigir por relaxamento de proteção.

## Publicação e sanitização

Arquivos preparados exclusivamente com observações sanitizadas: sem URL privada completa, identificador do Codespace, sessão, credenciais, cookies, tokens, cabeçalhos de autorização, ambiente sensível, dados pessoais ou logs completos. Os únicos hosts publicados são loopback e o identificador sintético `oes-probe.invalid`.

Freshness Gate: árvore limpa antes da criação da branch; HEAD e main remota confirmados na base aprovada; branch de entrega ausente localmente/remotamente antes da criação. Na reconferência após o ensaio, main remota permaneceu na base e branch remota continuava ausente. Os gatilhos push dos workflows versionados foram inspecionados: seus filtros de branch/caminho não abrangem esta entrega de dois arquivos em `evidence/runtime/codespaces/https/`; nenhum workflow_dispatch foi solicitado. Isso não atesta políticas externas não presentes no repositório.

Preservados CP348, Marco B OPEN, Q0 HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 5 NOT_STARTED e núcleo P1/D3. Main, aplicação e gates não foram modificados. Sem PR ou merge.
