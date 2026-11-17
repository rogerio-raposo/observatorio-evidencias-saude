# OES — Decisão arquitetural sobre o ingresso HTTPS no GitHub Codespaces

**Estado. Desenho arquitetural aprovado pelo responsável. Homologação operacional pendente.** Esta minuta formaliza o desenho para o piloto privado, sintético e supervisionado. A eventual configuração e a avaliação operacional dependem de despacho próprio.

## Base e continuidade

O Freshness Gate confirmou `origin/main` e a base da branch local em `7d29d653e5340b0da723934dc63c97863e6e2e44`. Em relação à base da revisão de topologia (`174872af`), a mudança em main incorpora somente `AGENTS.md` pelo squash do PR #41. O commit da branch de origem e o squash têm árvores idênticas. O ponteiro e o STATE confirmam CP348 como checkpoint vigente e reconhecem as integrações offline posteriores de P1, P2 v2, Django único e preparação Codespaces. As evidências HTTPS estão em branches próprias. [AGENTS.md](../../AGENTS.md) · [STATE.md](../../STATE.md) · [Ponteiro de continuidade](../../archive/handoffs/oes/README.md) · [CP348](../../archive/handoffs/oes/OES_Continuidade_2026-11-08_CP348.md)

Marco B OPEN, Q0 geral HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY e Fase 5 NOT_STARTED. Preservam-se P1 e D3, `_require_release()` em HOLD, HTTP mutante 423 e ausência de retry automático. A autorização histórica do CP347 foi delimitada ao ensaio registrado em CP348. [Contrato P2 v2](OES_Q0_OPERATIONAL_CONTRACT_P2.md) · [CP348](../../archive/handoffs/oes/OES_Continuidade_2026-11-08_CP348.md)

## Decisões aprovadas

1. **Fronteira de confiança restrita ao piloto.** O tráfego segue do navegador autenticado no GitHub ao ingresso gerenciado com encaminhamento `Private`, deste ao Gunicorn em `127.0.0.1:8000` e então ao Django pelo WSGI. A fronteira inclui a custódia da sessão GitHub, do Codespace e dos processos, extensões e ferramentas com acesso ao loopback. O bind restringe a escuta à interface local. Processos no mesmo namespace ainda podem alcançar o socket, e a autenticação do ingresso e a autorização Django são controles distintos. O modelo pressupõe acesso local sob custódia do operador durante a janela supervisionada. A URL externa HTTPS e o transporte local são saltos diferentes. [Revisão da topologia HTTPS](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/b99e6ddd62c320ac8c28a364985f160ddb4236e7/docs/governance/OES_CODESPACES_HTTPS_TOPOLOGY_REVIEW_DRAFT.md) · [Preparação Codespaces](OES_CODESPACES_PREPARATION.md)
2. **`trusted_proxy` é o mecanismo preferencial, condicionado às pré-condições abaixo.** O perfil privado já oferece a interpretação do esquema no Django a partir de `X-Forwarded-Proto`. O Gunicorn permanece com a tradução de esquema desativada. Isso evita duas interpretações do mesmo indicador e permite selecionar o modo pelo parâmetro já existente. A opção Django consulta o cabeçalho entregue ao WSGI sem consultar a lista de peers do Gunicorn. Sua segurança depende da proveniência do cabeçalho e da custódia dos caminhos até o socket. A ativação permanece pendente. [Contrato P2 v2](OES_Q0_OPERATIONAL_CONTRACT_P2.md) · [Configuração privada](../../applications/oes_web/config/mb_oc1.py) · [Configuração Gunicorn](../../applications/oes_web/config/gunicorn_codespaces.py)
3. **A fonte inicial do host é o cabeçalho `Host` convencional.** Manter `USE_X_FORWARDED_HOST=False` e um único hostname externo nominal em `ALLOWED_HOSTS`, sujeito à normalização nativa de `get_host()`. A origem externa HTTPS aprovada, coerente com esse hostname, é a única entrada em `CSRF_TRUSTED_ORIGINS`. Validar também a autoridade externa efetiva ao construir URLs e redirects. A comparação bruta do coletor tem alcance diferente da validação nativa de domínio no Django. A origem confiável compõe a proteção CSRF com token e verificação de Origin ou, sob HTTPS e na sua ausência, de Referer. [Revisão da topologia HTTPS](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/b99e6ddd62c320ac8c28a364985f160ddb4236e7/docs/governance/OES_CODESPACES_HTTPS_TOPOLOGY_REVIEW_DRAFT.md) · [Configuração privada](../../applications/oes_web/config/mb_oc1.py)

## Alternativas consideradas

| Alternativa | Disposição e justificativa |
| --- | --- |
| `wsgi` com configuração atual | Descartada para o caminho nominal. O transporte local HTTP e a tradução de esquema desativada resultam, por análise estática, em esquema WSGI HTTP. |
| Tradução pelo Gunicorn com Django em `wsgi` | Descartada para o piloto. Exige alterar a configuração, fundamentar o peer confiável e comprovar sanitização. O endereço de loopback sozinho é compartilhável por processos locais. |
| TLS até o Gunicorn com Django em `wsgi` | Descartada para o primeiro desenho. Exige configuração de protocolo e custódia de chaves e certificados. TLS no salto local, por si só, deixa em aberto a proveniência do esquema original. |
| `USE_X_FORWARDED_HOST=True` | Descartada para a configuração inicial. Só cabe reavaliar sob decisão específica se a incompatibilidade do `Host` convencional for comprovada e o host encaminhado canônico tiver proveniência fundamentada. |
| Proxy adicional, middleware ou verificador próprio | Descartados. A stack existente dispõe dos mecanismos de esquema, host e CSRF. Novos componentes acrescentariam manutenção e outras fronteiras de confiança. |

## Evidências e lacunas

| Evidência histórica | Resultado e alcance |
| --- | --- |
| [Complementar interrompido](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/24b629477a866b34d1504c7681d0e4da91ec3fe3/evidence/runtime/codespaces/https-followup/RELATORIO.md) | Baseline 401, zero casos sintéticos. Causa e camada emissora indeterminadas. |
| [Conectividade pontual](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/24b629477a866b34d1504c7681d0e4da91ec3fe3/evidence/runtime/codespaces/https-followup/pontual-900s/RELATORIO.md) | Uma requisição HTTPS 200 com marcador do coletor, conforme resultado sanitizado do responsável. |
| [Matriz de 14 casos](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/24b629477a866b34d1504c7681d0e4da91ec3fe3/evidence/runtime/codespaces/https-followup/header-matrix-900s/RELATORIO.md) | 14 respostas 200 com marcador. O coletor recebeu uma ocorrência de `X-Forwarded-Proto` com `https`, uma de `X-Forwarded-Host` redigida e nenhuma de `Forwarded` por caso. `hostMatchesOrigin` foi falso em todos. |

Os resultados positivos foram obtidos com `HTTPServer` Python. A matriz é compatível com normalização no caminho exercitado, mas deixa indeterminados o envio efetivo dos campos pelo navegador, o salto que os tratou, a política para listas e campos duplicados e a proteção contra acesso direto. O `Private` foi informado pelo responsável, sem inspeção administrativa independente. A comparação bruta de host pode falhar por quantidade ou representação, incluindo caixa ou porta explícita. O host canônico efetivo em `get_host()`, o esquema no Django, redirects, cookies e CSRF seguem sem evidência no caminho real. As faixas declaradas para Django e Gunicorn também deixam em aberto a versão instalada no artefato futuro. [Revisão da topologia HTTPS](https://github.com/rogerio-raposo/observatorio-evidencias-saude/blob/b99e6ddd62c320ac8c28a364985f160ddb4236e7/docs/governance/OES_CODESPACES_HTTPS_TOPOLOGY_REVIEW_DRAFT.md) · [Dependências declaradas](../../applications/oes_web/requirements.txt)

## Pré-condições para ativação e configuração nominal

- Confirmar no ambiente nominal o encaminhamento `Private`, a identidade do operador, a origem externa exata e a custódia do Codespace. Fundamentar quais processos podem alcançar o loopback e como se impede que clientes fora da fronteira entreguem cabeçalhos forjados diretamente ao backend.
- Fundamentar, para o ingresso utilizado, a remoção de `X-Forwarded-Proto` enviado pelo cliente e sua substituição por indicador confiável do esquema original, incluindo listas e duplicatas. Django 5.2 usa o primeiro componente de uma lista, portanto a custódia precisa abranger a origem desse valor. A matriz histórica é evidência complementar.
- Identificar o artefato, as versões efetivas, o perfil e a configuração do servidor previstos, incluindo ausência de overrides que alterem bind, esquema ou host. Confirmar compatibilidade do `Host` convencional com a origem aprovada.
- Concluir as verificações offline proporcionais abaixo e obter autorização operacional específica antes de ativar qualquer parâmetro.

| Item | Valor efetivo pretendido e mudança necessária |
| --- | --- |
| Perfil e bind | `config.settings_mb_oc1`, `config.wsgi:application`, `127.0.0.1:8000`. Já preparados. |
| Tradução no Gunicorn | `forwarded_allow_ips = ''` e `secure_scheme_headers = {}`. Já preparados. |
| Esquema no Django | Seleção futura indispensável de `OES_MB_OC1_TLS_TERMINATION=trusted_proxy`, produzindo `SECURE_PROXY_SSL_HEADER=('HTTP_X_FORWARDED_PROTO', 'https')`. O builder já contém a opção. |
| Host e origem | Fornecimento futuro indispensável de `OES_MB_OC1_HOST` e `OES_MB_OC1_ORIGIN` com o hostname e a origem HTTPS aprovados, sem wildcard. `ALLOWED_HOSTS` e `CSRF_TRUSTED_ORIGINS` são preenchidos pelo builder. `USE_X_FORWARDED_HOST=False` e `USE_X_FORWARDED_PORT=False` são os defaults aplicáveis. |
| Proteções do perfil | `DEBUG=False`, `SECURE_SSL_REDIRECT=True` e cookies de sessão e CSRF com `Secure`. Já preparados. |

O código atual contempla o desenho nominal. Declarar explicitamente os defaults de host e porta encaminhados seria apenas uma explicitação opcional, sem efeito esperado. Os demais parâmetros e orçamentos nominais já exigidos para eventual execução continuam sob as regras existentes do P2 e da preparação Codespaces. [Configuração privada](../../applications/oes_web/config/mb_oc1.py) · [Perfil Django](../../applications/oes_web/config/settings_mb_oc1.py) · [Configuração Gunicorn](../../applications/oes_web/config/gunicorn_codespaces.py) · [Contrato P2 v2](OES_Q0_OPERATIONAL_CONTRACT_P2.md)

## Testes offline mínimos em etapa futura autorizada

Reaproveitar a cobertura offline existente com entradas sintéticas e requests em memória, sem listener ou credenciais operacionais. Estes testes foram especificados nesta minuta e permanecem pendentes.

- Conferir a seleção do perfil, os valores exatos de host e origem e a rejeição de configuração incompleta ou incompatível. Conferir estaticamente o bind e a tradução de esquema desativada no Gunicorn.
- Exercitar o contrato Django de esquema com indicador HTTPS válido, indicador ausente ou HTTP em contexto WSGI HTTP e listas sintéticas que documentem a regra do primeiro componente. Verificar `is_secure()`, redirect esperado para HTTP e ausência de redirect de esquema quando seguro. Esse teste cobre o consumidor do cabeçalho.
- Exercitar `get_host()` com host aprovado e inesperado, inclusive com `X-Forwarded-Host` divergente. Conferir URL absoluta nominal, rejeição de host divergente e flags seguras dos cookies.
- Verificar CSRF com origem aprovada e origem divergente, token válido e ausente e regra de Referer sob HTTPS. Usar o harness offline pertinente e confirmar que a proteção de ingresso não libera a rota mutante, que segue em 423 sob as demais condições válidas.

[Regressões offline do Codespaces](../../applications/oes_web/evidence/test_codespaces_offline.py) · [Contrato P2 v2](OES_Q0_OPERATIONAL_CONTRACT_P2.md)

## STOP e critério de homologação limitada

Aplicar STOP operacional se a visibilidade for pública, organizacional ou indeterminada, se a custódia ou a prevenção de acesso direto for insuficiente, se a sanitização do indicador continuar sem fundamento, se houver host ou origem incompatíveis, artefato ou configuração efetiva indeterminados, perda de proteção de redirect, cookies ou CSRF, exposição inesperada ou necessidade de ultrapassar a autorização. Preservar as validações exatas e os gates do P2 diante de qualquer falha.

Uma homologação futura, sob autorização própria, deve registrar para o ambiente privado nominal as pré-condições satisfeitas, a revisão do artefato e da configuração, os testes offline aprovados e evidência suficiente na cadeia gerenciada até o perfil Django real. A evidência deve confirmar que o esquema representa a requisição original, que `get_host()` valida o host externo e que redirects, URLs, cookies e CSRF são coerentes com a origem aprovada. Registrar o escopo e os resultados de forma sanitizada, sem divulgar a origem privada ou credenciais. Aproveitar a evidência histórica de conectividade e tratar lacunas remanescentes na avaliação integrada autorizada.

O aceite desse recorte abrange apenas ingresso, esquema e host/origem. Capacidade e limites, identidade e Auth, ACL e catálogo, custódia operacional de credenciais, recuperação e RPO/RTO e fonte de liberação continuam no aceite integrado P2/PF-08. [Contrato P2 v2](OES_Q0_OPERATIONAL_CONTRACT_P2.md)
