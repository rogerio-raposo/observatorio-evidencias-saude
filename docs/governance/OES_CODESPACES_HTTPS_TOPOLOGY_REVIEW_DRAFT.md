# OES — Revisão documental da topologia HTTPS e confiança no proxy

> **DRAFT — NÃO APROVADA — análise estática/documental.** Preparada em 2026-11-17 UTC. Não constitui decisão operacional, autorização de configuração, implantação, publicação ou liberação. Sujeita à revisão independente do ChatGPT.

## 1. Resumo executivo

**Conclusão:** há evidência suficiente de conectividade HTTPS pontual ao coletor e da conclusão da matriz de 14 casos naquele caminho. Há configuração versionada de uma aplicação privada única. **Ainda não há evidência suficiente de uma cadeia HTTPS confiável até o Django nem aceite integrado P2/PF-08.** Não é necessário criar um proxy adicional, middleware ou verificador próprio para explicar ou resolver a parte de tradução de esquema/host: a stack já possui mecanismos nativos. A confiança nas entradas desses mecanismos continua sendo uma condição distinta.

**Fatos:** na matriz, todos os casos retornaram HTTP 200 e marcador; X-Forwarded-Proto recebido foi somente https; X-Forwarded-Host foi presente e redigido; Forwarded ficou ausente; hostMatchesOrigin foi falso. Os ensaios usaram HTTPServer da biblioteca padrão, nunca Gunicorn/Django. A configuração Gunicorn desabilita o reconhecimento de esquema por cabeçalhos. O perfil privado exige redirect HTTPS e oferece dois modos de interpretação de esquema, sem liberar a aplicação.

**Inferências:** o caminho navegador–ingresso–coletor apresentou comportamento favorável de normalização, mas não se identificou a etapa responsável nem se provou o envio físico dos cabeçalhos pelo navegador. Com o transporte local HTTP e as opções versionadas atuais, selecionar wsgi não disponibiliza automaticamente um esquema HTTPS ao Django. Há risco fundamentado de redirect repetido ou rejeição de Host antes de qualquer jornada funcional; não foi observada uma falha WSGI real.

**Recomendação:** próximo incremento único, ainda sujeito a autorização: fechar documentalmente a fronteira de confiança e a regra de host canônico; escolher um único mecanismo nativo de esquema; preparar, somente se autorizado, a alteração mínima de configuração e sua revisão offline. Não repetir a matriz ou criar infraestrutura para substituir uma garantia documental ainda ausente. Se a garantia não puder ser fundamentada no ambiente existente, conservar STOP e submeter o impedimento ao responsável.

## 2. Método, Freshness Gate e fontes locais

### 2.1. Referências conferidas

- Main remota por consulta Git somente de leitura: `174872af652ff1d98833e7d3fe1aef15e5696e53`, coincidente com a referência inicial.
- HEAD local e branch remota `evidence/oes-codespaces-https-followup`: `24b629477a866b34d1504c7681d0e4da91ec3fe3`.
- Estado inicial: sem alterações versionadas; dois arquivos JavaScript locais já existentes e não versionados, oes_https_probe.js e oes_https_headers_probe.js. Não foram executados ou alterados nesta revisão.
- [STATE.md](../../STATE.md), início de [ponteiro OES](../../archive/handoffs/oes/README.md) e [CP348](../../archive/handoffs/oes/OES_Continuidade_2026-11-08_CP348.md): CP348 continua vigente; entradas antigas abaixo do ponteiro são históricas. O estado da main anterior aos ensaios não apaga as evidências posteriores preservadas na branch.
- [Contrato P2](OES_Q0_OPERATIONAL_CONTRACT_P2.md), [preparação Codespaces](OES_CODESPACES_PREPARATION.md), [estratégia ChatGPT–Codex–GitHub](OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md) e [Documento 362](362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md) consultados.

### 2.2. Evidências históricas lidas, não reexecutadas

| Evidência | Localização/commit | Alcance |
|---|---|---|
| Diagnóstico inicial | [relatório no commit b4a54962](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/b4a54962de84e65e6cb97032575bad838c2b3146/evidence/runtime/codespaces/https/RELATORIO.md) | Coletor local positivo; consulta externa 404 sem marcador, insuficiente para provar Private |
| Complementar interrompido | [RELATORIO.md](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/466e5e910e4de4a09b569c8ab096e9ce057abc3b/evidence/runtime/codespaces/https-followup/RELATORIO.md), commit 466e5e91 | Baseline 401; zero casos sintéticos; confirmações posteriores do responsável com procedência explícita |
| Pontual de 900 segundos | [RELATORIO.md](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/240209658390cfecbe543023ca71b3f8cd3903a7/evidence/runtime/codespaces/https-followup/pontual-900s/RELATORIO.md), commit 24020965 | Uma requisição HTTPS 200 com marcador; encerramento do coletor e encaminhamento mantido por decisão do responsável |
| Matriz de 900 segundos | [RELATORIO.md](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/24b629477a866b34d1504c7681d0e4da91ec3fe3/evidence/runtime/codespaces/https-followup/header-matrix-900s/RELATORIO.md), commit 24b62947 | 14/14 casos 200 com marcador; observações sanitizadas e limites do navegador |

Os três relatórios da branch de evidências consultada e, adicionalmente, o relatório inicial da outra branch foram consultados. Esta minuta não altera nem substitui suas conclusões históricas. O 401 anterior não teve causa demonstrada; o êxito posterior não a determina retroativamente.

### 2.3. Versões e alcance da inspeção

[requirements.txt](../../applications/oes_web/requirements.txt) declara Django >=5.2,<5.3 e Gunicorn >=23,<24; intervalos não são um lock nem prova de instalação. Consulta a metadados por importlib.metadata no Python padrão retornou ambos não instalados nesse interpretador. A busca limitada por metadados de ambientes locais usuais também não identificou uma instalação; não é inventário universal do computador. **Não se atesta uma versão Gunicorn instalada nem se instala pacote para suprir essa lacuna.**

A semântica Django usa documentação 5.2 e código oficial da série stable/5.2.x. Para a faixa Gunicorn declarada, usa-se o código e a documentação embutida da tag oficial 23.0.0, como referência estática compatível, não como versão instalada. Documentação Gunicorn corrente também foi consultada e distinguida da tag: por exemplo, a referência corrente documenta CIDR, enquanto o caminho de decisão 23.0.0 consultado compara o endereço do peer à lista. Não transportar opções novas automaticamente para 23.x. [Gunicorn atual — settings](https://gunicorn.org/reference/settings/#forwarded_allow_ips), [parser 23.0.0](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/http/message.py).

Nenhum framework, perfil operacional ou WSGI foi importado. Não houve servidor, requisição ao ingresso do projeto, consulta PostgreSQL/Neon, leitura de valores de secrets, modificação de encaminhamento ou teste conectado. As únicas consultas de rede foram Freshness Gate Git e documentação pública oficial.

## 3. Diagrama textual da topologia

```text
CAMINHO DOCUMENTADO / MODELO A SER HOMOLOGADO

Navegador do responsável
  | HTTPS + autenticação normal do GitHub
  v
Endpoint privado / ingresso gerenciado Codespaces
  | encaminhamento gerenciado; saltos e peer local não inventariados
  v
Socket loopback 127.0.0.1:8000
  | configuração operacional futura: Gunicorn sync
  v
Gunicorn -> ambiente WSGI -> Django config.settings_mb_oc1
                               | SecurityMiddleware / Host / CSRF / Auth
                               | _require_release(): HOLD incondicional
                               v
                        jornada operacional fechada

CAMINHO EFETIVAMENTE EXERCITADO NOS ENSAIOS
Navegador HTTPS -> serviço de encaminhamento -> 127.0.0.1:8000
                                               HTTPServer Python
                                               marcador + cabeçalhos
                                               (sem Gunicorn e sem Django)
```

A documentação GitHub descreve o encaminhamento, o endereço externo HTTPS e um protocolo de encaminhamento configurável, HTTP por padrão. **HTTPS na URL externa não prova TLS até o socket local.** Mudar Change Port Protocol para HTTPS exige um serviço compatível no destino; não transforma um servidor HTTP simples em TLS. A existência desse mecanismo é documental, não configuração observada nesta revisão. [GitHub — encaminhamento e protocolo](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace).

Private exige autenticação GitHub e é descrito como acessível ao criador do Codespace. A documentação também descreve isolamento de VM/rede e túneis TLS. Isso é uma proteção de plataforma útil, não autenticação dos processos no loopback nem substituto da autorização Django. [GitHub — segurança Codespaces](https://docs.github.com/en/codespaces/reference/security-in-github-codespaces).

**Alcance de 127.0.0.1:** o bind evita escuta nas interfaces externas daquele namespace de rede. Não impede o encaminhamento intencional da plataforma, outro processo com acesso ao mesmo loopback, código executado no ambiente ou outro túnel autorizado. Private protege o ingresso publicado; não protege o socket contra processos locais. Nenhum dos dois, sozinho, identifica criptograficamente o proxy ou prova que todo acesso passou por ele. Essa é uma consequência da fronteira de rede, não uma alegação de invasão observada.

Não há evidência de uma identidade/IP exclusivo do encaminhador perante o backend. A autorização para código/processos locais, extensões e ferramentas deve fazer parte da custódia do ambiente prevista em P2; a aceitação anterior da coexistência das três credenciais no processo não equivale a aceitar qualquer processo local como proxy confiável.

## 4. Matriz P2 versus evidências existentes

Classificações referem-se ao requisito e ao alcance indicado, não ao aceite geral. DEMONSTRADO pode ser prova estática de configuração ou execução histórica delimitada, conforme a coluna de evidência. NÃO APLICÁVEL significa apenas fora deste recorte de ingresso, nunca dispensado do P2.

| Requisito/condição | Classificação | Evidência e limite | Resolução proporcional |
|---|---|---|---|
| Uma aplicação/perfil privado e origem exata preparados | DEMONSTRADO | Builder e URLs versionados; origem/host são obrigatórios; não é implantação | Reutilizar perfil existente |
| Conectividade HTTPS ao coletor | DEMONSTRADO | Pontual e matriz 200/marcador relatados pelo responsável | Não repetir esse diagnóstico sem hipótese nova |
| Matriz de 14 casos concluída | DEMONSTRADO | JSON sanitizado, todos 200/marcador, no coletor | Preservar evidência e limites |
| Private efetivo na campanha | FAVORÁVEL, MAS INSUFICIENTE | Declaração do responsável + política GitHub; sem inspeção administrativa independente | Documentar custódia/política aplicável; não publicar URL |
| Negação de todos os acessos não autorizados ao ingresso | FAVORÁVEL, MAS INSUFICIENTE | Política oficial e falhas 401/404 históricas; não equivalem a teste negativo controlado na mesma condição positiva | Distinguir garantia de plataforma e evidência concreta; não inventar resultados |
| Bind loopback configurado e usado pelo coletor | DEMONSTRADO | Código Gunicorn e observações lsof/ss do coletor | Manter a restrição |
| Backend operacional alcançável somente por caminho confiável | NÃO DEMONSTRADO | Loopback acessível a processos locais; peer do encaminhador não atestado | Fundamentar a fronteira local e acessos permitidos |
| X-Forwarded-Proto normalizado no caminho exercitado | FAVORÁVEL, MAS INSUFICIENTE | Somente https nos 14 casos; sem captura do envio físico | Aceitar como evidência favorável, não política universal |
| Garantia gerenciada de strip/overwrite, inclusive listas | NÃO DEMONSTRADO | Fontes GitHub consultadas não especificam essa garantia | Buscar fundamento documental aplicável; manter STOP se ausente |
| Esquema HTTPS confiável no WSGI/Django real | NÃO DEMONSTRADO | Nenhum ensaio WSGI; configuração atual não traduz o esquema no Gunicorn | Escolher um mecanismo nativo após fechar confiança |
| Identidade/versão operacional instalada do servidor | NÃO DEMONSTRADO | Só faixa de requirements; pacotes ausentes no Python consultado | Identificar artefato/interpretador quando houver implantação autorizada |
| Origem HTTPS e host aprovados como valores exatos no builder | DEMONSTRADO | Validador exige relação host/origin e rejeita wildcard | Preservar validação; valor operacional não foi atestado |
| Host canônico efetivo até get_host() | NÃO DEMONSTRADO | Comparação bruta falsa; não há Host real sanitizadamente caracterizado | Decidir fonte nativa do host sem reconstruir valor ocultado |
| X-Forwarded-Host confiável e igual à origem aprovada | FAVORÁVEL, MAS INSUFICIENTE | Presente/redigido; sintéticos não aparecem; identidade desconhecida | Comparação privada com o valor aprovado, se necessária e autorizada; nenhuma publicação do endereço |
| CSRF de jornada na origem externa | NÃO DEMONSTRADO | Configuração exata existe; GET do coletor não exerceu POST/CSRF Django | Aproveitar middleware nativo; validar no aceite funcional autorizado |
| DEBUG=False e cookies Secure/HttpOnly/SameSite preparados | DEMONSTRADO | private_configuration versionada; não atesta cookies operacionais | Manter opções existentes |
| Sem loop de redirect na aplicação | NÃO DEMONSTRADO | Coletor não redireciona; modo wsgi/HTTP tem limitação estática | Corrigir fundamento do esquema antes de iniciar aplicação |
| Sessão/auth científica e persistência D1/D3 operacionais | NÃO APLICÁVEL | Fora do diagnóstico HTTPS; CP348 tem prova histórica restrita | Pendências P2 próprias permanecem, sem repetir CP348 |
| ACL/catálogo PostgreSQL, limites transacionais e backup/RPO/RTO | NÃO APLICÁVEL | Não foram inspecionados por esta revisão de ingresso | Não confundir aceite parcial HTTPS com aceite integrado |
| `_require_release()` incondicional e gates fechados | DEMONSTRADO | Código e governança atuais | Não alterar no incremento de ingresso |
| Proxy adicional/middleware próprio como requisito | NÃO APLICÁVEL | Necessidade não demonstrada; mecanismos nativos já existem | Não introduzir componente paralelo |
| Encerramento do coletor após matriz | DEMONSTRADO | Exit 143, ausência de listener às 19:42:03 UTC no relatório | Encaminhamento mantido por decisão, sem confundir as duas coisas |

## 5. Coletor HTTP versus Gunicorn/WSGI

### 5.1. Configuração versionada efetivamente lida

[gunicorn_codespaces.py](../../applications/oes_web/config/gunicorn_codespaces.py) fixa bind 127.0.0.1:8000, worker sync, um thread, config.wsgi:application, DJANGO_SETTINGS_MODULE=config.settings_mb_oc1, sem preload/reload/daemon, `forwarded_allow_ips = ''` e `secure_scheme_headers = {}`. Não declara certificado/chave TLS. Valida parâmetros explícitos de capacidade e chama o builder puro. Não se usou check-config/print-config, que poderiam carregar aplicação/configuração.

[mb_oc1.py](../../applications/oes_web/config/mb_oc1.py) prepara SECURE_SSL_REDIRECT=True e SECURE_PROXY_SSL_HEADER somente no modo trusted_proxy. Não define USE_X_FORWARDED_HOST ou USE_X_FORWARDED_PORT. [settings_mb_oc1.py](../../applications/oes_web/config/settings_mb_oc1.py) aplica os valores privados sobre settings e acrescenta proteção de frame. O perfil [session_test](../../applications/oes_web/config/settings_mb_oc1_session_test.py) é harness SQLite, não perfil operacional alternativo. [wsgi.py](../../applications/oes_web/config/wsgi.py) usa setdefault: o raw_env do comando Gunicorn previsto seleciona o perfil privado; importar outro perfil por conveniência não é procedimento aprovado.

### 5.2. Semântica Gunicorn de referência 23.0.0

Os defaults do produto não são os overrides OES. A tag 23.0.0 documenta forwarded_allow_ips com default 127.0.0.1,::1, variável FORWARDED_ALLOW_IPS e wildcard que desliga a checagem. secure_scheme_headers tem três indicadores convencionais; exige correspondência exata de valores. Conexões UNIX não passam pelo mesmo filtro de IP. Não se propõe trocar o socket. [Configuração oficial 23.0.0](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/config.py).

O parser condiciona a interpretação do esquema ao peer permitido, compara valores exatos e pode rejeitar indicadores contraditórios. Uma lista textual não é tratada como a regra do primeiro componente do Django. O esquema começa conforme TLS local. [Parser oficial 23.0.0](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/http/message.py).

**Consequência estática OES:** com o socket HTTP sem TLS configurado e secure_scheme_headers vazio, a matriz favorável não muda o esquema WSGI para https. forwarded_allow_ips não é firewall nem autenticação de processo local. Permitir loopback como peer não distingue um encaminhador de outro cliente no mesmo namespace.

O adaptador WSGI converte campos HTTP em HTTP_*, combina ocorrências de cabeçalhos e entrega o esquema calculado em wsgi.url_scheme. Host e X-Forwarded-Host não são automaticamente convertidos um no outro nesse caminho. [Adaptador oficial 23.0.0](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/http/wsgi.py).

**Ponto material:** desabilitar secure_scheme_headers impede a tradução de esquema no Gunicorn, mas não equivale a remover HTTP_X_FORWARDED_PROTO do ambiente entregue ao Django. O coletor get_all(), o parser Gunicorn e a representação WSGI são camadas distintas; observação de duplicatas no primeiro não prova sua interpretação nas demais.

### 5.3. wsgi versus trusted_proxy e redirects

O modo OES wsgi configura SECURE_PROXY_SSL_HEADER=None. Django WSGI consulta wsgi.url_scheme quando não há override de cabeçalho. [Handler WSGI Django 5.2](https://raw.githubusercontent.com/django/django/stable/5.2.x/django/core/handlers/wsgi.py). Portanto, sem tradução no servidor ou TLS local, o esquema esperado por análise é http, apesar do navegador HTTPS.

O modo trusted_proxy seleciona a tupla para HTTP_X_FORWARDED_PROTO. Django exige garantia de que o proxy descarta entradas do cliente, inclusive listas, e define o indicador segundo HTTPS original. Também documenta a preferência pelo primeiro componente da lista. A opção não autentica peers. [Django 5.2 — SECURE_PROXY_SSL_HEADER](https://docs.djangoproject.com/en/5.2/ref/settings/#secure-proxy-ssl-header).

**Limitação crítica da defesa por camadas:** o código Django lê o cabeçalho configurado antes do fallback WSGI, sem consultar forwarded_allow_ips do Gunicorn. Um cliente local que alcance o socket e forje esse campo pode influenciar trusted_proxy. Não se afirma ataque ocorrido; é uma condição estrutural da opção. [HttpRequest.scheme, Django 5.2](https://raw.githubusercontent.com/django/django/stable/5.2.x/django/http/request.py).

Com SecurityMiddleware primeiro e redirect obrigatório no perfil OES, esquema percebido como http pode gerar redirecionamento para a mesma origem externa HTTPS repetidamente; Host inválido também pode produzir rejeição antes da view. A ordem da cadeia é visível no código local. Não desativar redirect/cookies nem assumir que o gate da view impede esses efeitos de middleware. [Django 5.2 — SecurityMiddleware](https://docs.djangoproject.com/en/5.2/ref/middleware/#ssl-redirect).

## 6. Host, origem e significado de hostMatchesOrigin=false

**Fato:** o script calculou `h.Host.length === 1 && h.Host[0] === location.host`; o resultado foi falso 14 vezes. Não publicou Host nem valor real de X-Forwarded-Host.

**Não se pode concluir** que o domínio efetivo seja necessariamente outro, que seja localhost, que o encaminhamento esteja defeituoso ou que ALLOWED_HOSTS precise de wildcard. A expressão também falha quando há quantidade diferente de uma ocorrência, diferença de caixa, porta explícita ou outra representação textual. A matriz não distingue essas causas. Nem o valor original nem a igualdade entre valores redigidos podem ser reconstruídos.

A API get_host() aplica a validação de domínio; USE_X_FORWARDED_HOST é False por padrão e precisa de ativação explícita para preferir o host encaminhado. ALLOWED_HOSTS não configura CSRF, autentica proxy ou reescreve Host. [Django 5.2 — settings](https://docs.djangoproject.com/en/5.2/ref/settings/#use-x-forwarded-host), [API get_host()](https://docs.djangoproject.com/en/5.2/ref/request-response/#django.http.HttpRequest.get_host).

**Consequência OES:** o builder permite somente o host externo aprovado em ALLOWED_HOSTS e não ativa host encaminhado. Se o Host entregue ao Django não corresponder a esse domínio após a normalização nativa, a aplicação poderá rejeitá-lo. Se a diferença for apenas representação tolerada pela validação, não há incompatibilidade demonstrada. O fato observado é um sinal para decisão da fonte do host, não uma autorização para mudar configuração.

CSRF_TRUSTED_ORIGINS admite origens confiáveis na verificação de Origin; não substitui ALLOWED_HOSTS nem elimina token CSRF. O middleware compara Origin quando presente e, para HTTPS sem Origin, aplica a regra de Referer. O GET do coletor não comprovou esse fluxo. [Django 5.2 — CSRF](https://docs.djangoproject.com/en/5.2/ref/csrf/).

**Recomendação condicional:** preservar host/origin exatos. Priorizar Host preservado pelo ingresso; se esse caminho não corresponder ao contrato e houver garantia documentada do host encaminhado, USE_X_FORWARDED_HOST é o mecanismo nativo candidato. Nesse caso, o valor deve continuar sujeito a ALLOWED_HOSTS e corresponder à origem aprovada. Fazer somente comparação privada autorizada, com saída booleana ou categoria sanitizada, se a documentação não bastar. Não solicitar publicação de endereços nem escolher um Host interno presumido para contornar a validação.

## 7. Riscos e lacunas efetivos

| Achado | Natureza | Consequência |
|---|---|---|
| Esquema Gunicorn atual não traduz HTTPS em HTTP local | CONFIRMADO por configuração + semântica estática | Modo wsgi atual não tem fundamento para is_secure=True nesse transporte |
| Django trusted_proxy aceita campo independentemente da allowlist Gunicorn | CONFIRMADO na semântica consultada | Exige fronteira de ingresso e local confiável; lista de IPs não sana tudo |
| Matriz não identifica o salto que normalizou | Limitação de evidência | Não declarar strip/overwrite universal do Codespaces |
| Host bruto não igual à origem, causa oculta | INCONCLUSIVO quanto à incompatibilidade | Não alterar ALLOWED_HOSTS nem ativar X-Forwarded-Host cegamente |
| Private depende da plataforma e da custódia da sessão/ambiente | Fronteira documentada + configuração declarada | Não confundir autenticação GitHub com autorização OES |
| Condições de capacidade/filas do ingresso não medidas | Lacuna operacional P2 | HTTP 200 do coletor não atesta capacidade de worker sync ou limites fim a fim |
| Frameworks sem versão instalada atestada | Lacuna de identidade do artefato | Não atribuir ao runtime semântica de versão presumida |

O guia Gunicorn recomenda proxy e cuidado com clientes lentos em workers sync; isso não obriga acrescentar outro proxy quando já existe ingresso gerenciado. Buffering e limites dessa cadeia permanecem não comprovados. Não criar benchmark ou componente só para produzir mais evidência. [Guia oficial de deploy Gunicorn 23.0.0](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/docs/source/deploy.rst).

## 8. Alternativas técnicas proporcionais

Todas são alternativas para decisão, não mudanças autorizadas. Não escolher dois consumidores de esquema simultaneamente sem necessidade.

| Alternativa | Mecanismo existente | Pré-condição e custo lógico | Posição desta minuta |
|---|---|---|---|
| Manter estado atual fechado | Configuração existente | Reconhecer que ainda não atende esquema/Host operacionais | Obrigatório enquanto faltarem garantias |
| Esquema aceito no Django | Modo trusted_proxy já previsto; manter parser Gunicorn sem inferência | Garantia de origem/strip/overwrite e controle de caminhos diretos, inclusive fronteira local | Menor delta de configuração se as pré-condições forem comprovadas |
| Esquema calculado no Gunicorn | secure_scheme_headers e forwarded_allow_ips; Django wsgi | Peer conhecido/confiável, garantia de sanitização, ajuste revisado do arquivo hoje fechado | Alternativa nativa, sem resolver identidade de processos pelo IP por si só |
| TLS até o Gunicorn | TLS nativo Gunicorn + protocolo HTTPS de encaminhamento Codespaces; Django wsgi | Certificado/chave, custódia, comportamento de validação no encaminhamento e garantia de HTTPS original | Possibilidade de stack, não viabilidade comprovada; custo maior; não recomendada como primeiro passo |
| Host encaminhado no Django | USE_X_FORWARDED_HOST e ALLOWED_HOSTS exato | Provar host encaminhado canônico/confiável; preservar origem/CSRF | Candidato somente se Host atual for incompatível |
| Proxy adicional, middleware ou verificador próprio | Novo componente | Nenhuma necessidade demonstrada; cria outra fronteira e manutenção | Não propor implementação nesta fase |

As opções nativas de TLS existem na referência Gunicorn; a seleção de protocolo existe em Codespaces. A combinação não foi homologada, e criptografar um salto não prova sozinho o esquema original nem a autorização do cliente local. [Gunicorn — SSL](https://gunicorn.org/reference/settings/#certfile), [Codespaces — HTTPS forwarding](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace#using-https-forwarding).

Não usar wildcard de hosts ou peers, SECURE_SSL_HOST como remendo de validação, esquema forçado por variável arbitrária, perfil session_test em operação ou novo proxy como substituto de decisão de confiança. Nenhuma dessas medidas é necessária para concluir esta revisão documental.

## 9. Próximo incremento recomendado

**Um único fechamento documental/de configuração, sem nova campanha experimental agora:**

1. Revisão independente desta minuta, com confirmação do alcance das evidências já suficientes. Não repetir Python, dependências, conectividade ou a mesma matriz.
2. Responsável/operador fundamentam a confiança no ingresso existente e no ambiente local: quais atores/processos podem alcançar o backend; qual garantia gerenciada sustenta sanitização de esquema e host. As páginas GitHub consultadas não especificam strip/overwrite de X-Forwarded-Proto/Host; isso é ausência de garantia localizada nas fontes consultadas, não prova de insegurança da plataforma. Se necessário, usar esclarecimento documental oficial aplicável, sem gerar novos testes por rotina.
3. Escolher esquema e host por mecanismos nativos, com um único desenho nominal. A opção de menor delta é trusted_proxy já prevista, **somente** se a garantia requerida pelo P2 for fundamentada; não é recomendação de ativação imediata. O host encaminhado é uma decisão separada e condicional. Se a fronteira não for suficiente, manter HOLD e submeter ao responsável a limitação do destino, sem criar infraestrutura automaticamente.
4. Somente por nova autorização, preparar uma alteração mínima e consolidada de configuração, caso realmente necessária, com versão operacional identificada e regressões offline proporcionais reaproveitando os testes existentes. Não usar check-config/print-config com secrets. Isso não libera `_require_release()` nem uma jornada conectada.

Não criar um novo gate por cabeçalho ou exigir prova universal inatingível. O objetivo é uma garantia suficientemente fundamentada para o recorte privado aprovado, com limites declarados, sem declarar atendida uma condição material do P2 que continua sem suporte.

## 10. Critérios mínimos para eventual aceite futuro

Para aceitar somente o ingresso/esquema, e sem promover o aceite operacional geral:

- Revisão da configuração nominal e da versão exata do servidor/interpretador a usar; nenhum override inesperado de flags, perfil ou variáveis de argumentos do Gunicorn.
- Private, origem exata e custódia do recurso confirmados; alcance da proteção de plataforma e restrições de acesso local documentados. Um processo local autorizado faz parte da fronteira assumida; processo local não autorizado não pode ser declarado excluído somente pelo bind.
- Garantia aplicável de remoção/sobrescrita de entrada do cliente e de proveniência do indicador, incluindo listas, ou alternativa de transporte confiável que cumpra o mesmo objetivo; fundamentar prevenção de caminho direto forjado.
- Uma fonte nominal de esquema e uma fonte nominal de host, sem confiança baseada apenas em loopback; get_host deve validar o host externo aprovado, e o esquema deve representar corretamente a requisição original.
- Comportamento de redirects, URL absoluta, cookies e origem/CSRF coerente no perfil real. A documentação define a semântica, mas não substitui toda evidência de configuração/integração concreta. Se restar lacuna material, descrevê-la na futura unidade integrada autorizada, sem inventar novo coletor ou exigir agora ensaios independentes.
- STOP se a garantia do proxy, Host, artefato ou fronteira direta permanecer indeterminada; não corrigir por wildcard, relaxamento de redirect/cookies ou bypass do gate.

Para aceite P2 integrado, continuam também necessárias as decisões nominais já contratadas de Auth/identidade, ACL/catálogo, limites/capacidade, custódia de credenciais, backup/RPO/RTO, recuperação e fonte de liberação. Não são reabertas nem executadas nesta minuta; CP348 não é autorização para nova escrita.

## 11. Fontes oficiais e limites de aplicabilidade

Consulta documental em **2026-11-17 UTC**. Links são públicos e não contêm endereços do Codespace. Sem citações literais extensas.

| Fonte oficial | Versão/escopo utilizado | Limite |
|---|---|---|
| [GitHub — Forwarding ports](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace) | Documentação corrente do serviço | Protocolo/visibilidade documentados; não especifica garantia de strip/overwrite nas seções consultadas |
| [GitHub — Security in Codespaces](https://docs.github.com/en/codespaces/reference/security-in-github-codespaces) | Documentação corrente do serviço | Garantias da plataforma; não audita configuração/custódia particular |
| [Django — Settings](https://docs.djangoproject.com/en/5.2/ref/settings/) | Série 5.2 | Opções nativas e pré-condições; não comprova deploy |
| [Django — Request/response](https://docs.djangoproject.com/en/5.2/ref/request-response/) | Série 5.2 | API get_host e objetos de requisição |
| [Django — Middleware](https://docs.djangoproject.com/en/5.2/ref/middleware/) | Série 5.2 | Redirect e segurança nativos |
| [Django — CSRF](https://docs.djangoproject.com/en/5.2/ref/csrf/) | Série 5.2 | Proteção de Origin/Referer/token; não exercida pelos GETs do coletor |
| [Django — HttpRequest](https://raw.githubusercontent.com/django/django/stable/5.2.x/django/http/request.py) | Branch oficial stable/5.2.x consultada nesta data | Fonte móvel de série, não hash instalado |
| [Django — WSGIRequest](https://raw.githubusercontent.com/django/django/stable/5.2.x/django/core/handlers/wsgi.py) | Branch oficial stable/5.2.x | Relação entre environ e esquema |
| [Gunicorn — referência corrente](https://gunicorn.org/reference/settings/) | Documentação corrente, não congelada em 23.x | Não aplicar recursos novos automaticamente à faixa declarada |
| [Gunicorn — config.py](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/config.py) | Tag 23.0.0 | Defaults e descrições versionados; não instalação atestada |
| [Gunicorn — HTTP parser](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/http/message.py) | Tag 23.0.0 | Regra de peer/esquema e correspondência exata |
| [Gunicorn — WSGI adapter](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/gunicorn/http/wsgi.py) | Tag 23.0.0 | Transformação para environ; não runtime exercitado |
| [Gunicorn — deploy](https://raw.githubusercontent.com/benoitc/gunicorn/23.0.0/docs/source/deploy.rst) | Tag 23.0.0 | Cuidados de ingresso/worker, sem obrigar infraestrutura adicional |

Os endereços antigos docs.gunicorn.org/en/23.0.0/settings.html e /en/stable/settings.html não forneceram conteúdo utilizável nesta consulta. Foram usados o site oficial atual e as fontes oficiais da tag, sem substituir 23.x por semântica nova silenciosamente.

## 12. Completude, estado da minuta e preservação

Esta minuta cobre topologia, matriz P2, distinção coletor/WSGI, esquema, Host/origem, riscos, alternativas nativas, próximo incremento, critérios de aceite e fontes. A criação deste arquivo é a única mudança documental autorizada nesta atividade. Nenhum contrato, relatório histórico, aplicação, configuração ou gate foi alterado. Sem testes de aplicação, instalação, SQL, serviços, portas, commit, push, PR ou merge.

**Estados preservados:** CP348 vigente; Marco B OPEN; Q0 HARD HOLD; Q1 conectado HOLD; E9 NO-GO; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED; núcleo P1/D3 intacto. O encaminhamento Private existente não foi consultado ou modificado nesta atividade. Ao concluir a análise, o artefato permanecia local, não aprovado e não publicado. Despacho posterior autorizou exclusivamente sua publicação documental em review/oes-codespaces-https-topology, a partir da main, para revisão independente. A publicação não aprova a minuta nem autoriza qualquer execução operacional. Os links das evidências foram fixados em commits públicos para permanecerem válidos nessa branch isolada.
