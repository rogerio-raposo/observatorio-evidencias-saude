# OES — preparação mínima para Codespaces

Preparação offline sobre `847f9c1ce94c33e73d9f15b10dc077d2cb1eb467`, PR #39 integrado. Não é implantação operacional nem autorização para criar Codespace, conectar PostgreSQL ou liberar `_require_release`. Aplicação única e contrato [P2 versão 2](OES_Q0_OPERATIONAL_CONTRACT_P2.md) preservados. CP348 vigente, Marco B OPEN, Q0 HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY e Fase 5 NOT_STARTED.

## Criação futura manual, somente após autorização

1. Conferir elegibilidade/permissões da conta e organização para Codespaces. Em GitHub Settings → Billing and licensing/Codespaces, consultar franquia, consumo, máquina elegível e política de bloqueio ao esgotar a franquia. Organização pode ter regras próprias. Sem garantia de ausência de cobrança e autorização do responsável, STOP. Nenhuma franquia ou plano foi consultado neste pacote.
2. Selecionar revisão integrada/revisada e a configuração `.devcontainer/devcontainer.json`, máquina de **2 vCPU se elegível**; hostRequirements é requisito mínimo, não garantia de seleção, limite máximo ou disponibilidade. Não aumentar máquina/contratar plano automaticamente. Criar manualmente, sem secrets operacionais inicialmente, conferir Python 3.12. Não há lifecycle command, forwardPorts, servidor, migration ou provisionamento automático. A imagem contém ferramentas de desenvolvimento; não foi construído contêiner neste trabalho.
3. No diretório applications/oes_web, instalar manualmente dependências revisadas: `python -m pip install -r requirements.txt`. Instalação não importa WSGI nem autoriza execução conectada. Revisar dependências antes de disponibilizar segredos; código do repositório e bibliotecas pode ler o ambiente. Não passar secrets ao Docker build ou imagem.

## Custódia e parâmetros

Somente após autorização, cadastrar em **GitHub Codespaces Secrets**, com acesso restrito ao repositório: `OES_MB_OC1_SECRET_KEY`, `OES_MB_OC1_AUTH_PASSWORD`, `OES_MB_OC1_READER_PASSWORD`, `OES_MB_OC1_WRITER_PASSWORD`. Não são Actions Secrets. Não criar/renovar/testar senhas neste pacote. Nunca inserir valores em terminal compartilhado, .env versionado, logs, prints de configuração ou artefatos. Codespace/processo não é cofre independente: código com acesso ao ambiente pode ler as três credenciais, risco já aceito no piloto supervisionado. Reconstrução/reinício com secrets também executa código; revisar a configuração e o SHA antes disso.

Parâmetros não secretos devem ser definidos explicitamente pelo operador, com decisão do responsável: `OES_MB_OC1_HOST`, `OES_MB_OC1_ORIGIN`, `OES_MB_OC1_TLS_TERMINATION`, `OES_MB_OC1_PG_HOST`, os três limites `OES_MB_OC1_CONNECT_TIMEOUT_SECONDS`, `OES_MB_OC1_STATEMENT_TIMEOUT_MS`, `OES_MB_OC1_LOCK_TIMEOUT_MS`, `OES_MB_OC1_SESSION_SECONDS`, mais `OES_CODESPACES_WORKERS`, `OES_CODESPACES_HTTP_TIMEOUT_SECONDS`, `OES_CODESPACES_PG_CONNECTION_BUDGET`. O PG_HOST é o endpoint aprovado já fixado no P2; não escolher banco/branch arbitrários. Não combinar os opt-ins legados.

Sem valores operacionais padrão. O budget PostgreSQL representa conexões disponíveis **para esta aplicação após reservas/outros clientes**; a configuração exige conservadoramente três por worker. Não altera max_connections/limite de role nem comprova capacidade real. Timeout Gunicorn sync é limite de silêncio do worker, não deadline HTTP ponta a ponta: escolher H junto aos tempos de fila, conexão, statements, locks, transação e D3. Matar worker após timeout não comprova rollback; tratar resultado incerto sem retry. Os limites efetivos e RPO/RTO/backup continuam pendências P2.

## Origem, TLS e porta privada

Obter o endereço HTTPS real correspondente à porta 8000 na aba **Ports** do Codespace (ou URL calculada pela plataforma com CODESPACE_NAME e GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN, confirmada na aba). Não fabricar hostname nem copiar URL de outro ambiente. O hostname sem esquema/porta/path corresponde a OES_MB_OC1_HOST; a origem HTTPS exata, sem path/query/fragment, corresponde a OES_MB_OC1_ORIGIN e será usada em CSRF_TRUSTED_ORIGINS. ALLOWED_HOSTS é restrito a esse host; cookies Secure/HttpOnly/SameSite permanecem. Mudança da URL exige nova validação, não wildcard.

Manter **Visibility: Private**, nunca Public ou Organization, e verificar políticas da organização. O devcontainer ignora autoforward; não fixa nem comprova a visibilidade efetiva da plataforma. Encaminhamento, quando autorizado, será manual. Confirmar que cliente sem autorização GitHub não acessa o endereço; não registrar cookies/tokens dessa verificação.

Gunicorn fica em 127.0.0.1:8000, sem exposição direta e sem confiança automática em headers. O Codespaces termina TLS, mas este pacote **não comprova** que o ingresso remove/sobrescreve X-Forwarded-Proto/Host enviados pelo cliente. Antes de iniciar a aplicação, verificar documentalmente e no Codespace autorizado a cadeia de ingresso, tratamento de cabeçalhos forjados e visibilidade. `trusted_proxy` no P2 só pode ser escolhido se essa propriedade estiver comprovada. A seleção `wsgi` não resolve por si só o problema: Gunicorn local usa HTTP e, sem transporte do esquema confiável, poderá ocorrer redirect loop com SECURE_SSL_REDIRECT. Não desabilitar redirects/cookies, confiar em '*' ou aceitar cabeçalhos apenas por virem de loopback.

**STOP operacional se a confiança no esquema/proxy não puder ser demonstrada.** Não introduzimos proxy adicional ou alteramos validadores para simular essa comprovação. Não há incompatibilidade sintática entre o hostname HTTPS real esperado e o validador atual; a topologia/headers só podem ser comprovados no ambiente real.

## Validação e início supervisionado

Verificação local sem rede: executar os testes offline de configuração, que carregam o arquivo Gunicorn com ambiente sintético e bloqueiam conexão. `gunicorn --check-config` pode importar o WSGI e carregar settings: não usar esse comando com segredos reais como se fosse teste sem efeitos. Não usar --print-config (pode expor ambiente/settings).

Somente após pré-condições de ingresso/privacidade/custos/configuração e autorização de execução, no diretório applications/oes_web:

```sh
python -m gunicorn --config config/gunicorn_codespaces.py
```

Não adicionar flags que substituam bind, settings, logs, workers ou headers fora da revisão aprovada. A configuração fixa config.wsgi:application e DJANGO_SETTINGS_MODULE=config.settings_mb_oc1; não usa runserver. Não executa migrations, SQL ou provisionamento. A importação Django não é prova de conexão/ACL; requests Auth podem conectar ao PostgreSQL, mesmo sem escrita científica. Portanto, iniciar/encaminhar/acessar com secrets não está autorizado neste despacho.

O `_require_release()` continua raise incondicional: login/logout/registro/consulta privados ficam bloqueados (423), mesmo com configuração completa. Nenhum script altera esse gate. A liberação científica exige revisão/autorização separadas conforme P2. Leitura D3 continua exclusivamente em oes_synthetic_reader, independente do atomic em oes_q0_writer, com Auth em default; não reintroduzir A/B nem repetir CP348.

## Parada e limites

Interromper Gunicorn no terminal (Ctrl-C) impede novas admissões, sem presumir cancelamento/rollback de tentativa em voo. Preservar IDs e usar somente reconciliação autorizada. **Stop Codespace** interrompe compute, mas storage pode continuar consumindo franquia/custo; **Delete Codespace** remove o recurso após preservar evidências permitidas. Conferir ambos no portal e consumo final; não confundir fechar navegador com parar o Codespace. A política de idle/retention da conta precisa ser decidida, não presumida.

Revogar acesso aos Codespaces Secrets/remover projeções temporárias conforme autorização não revoga senha ou privilégios PostgreSQL. Encerrar sessões/contas sintéticas e revogar credenciais são ações administrativas distintas, sob custódia do responsável. Exclusão de Codespace não comprova essas revogações. Nenhuma dessas ações foi executada aqui.

Evidência deste pacote: análise estática e testes locais com dados falsos. Imagem/máquina, build/install no Codespace, quota/cobrança, origem/headers/Private, capacidade PostgreSQL e operação WSGI real permanecem não comprovados. As pendências não autorizam criação, deploy, dispatch ou conexão adicional automaticamente.
