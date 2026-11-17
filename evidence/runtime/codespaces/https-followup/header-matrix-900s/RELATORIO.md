# OES — matriz de cabeçalhos HTTPS, limite de 900 segundos

## Resultado e fronteira de interpretação

**Matriz concluída: 14/14 casos com HTTP 200 e marcador confirmado**, conforme saída sanitizada fornecida pelo responsável. Em todos os casos, o coletor recebeu uma ocorrência de X-Forwarded-Proto com um componente `https`; uma ocorrência de X-Forwarded-Host com um componente redigido; e nenhuma ocorrência de Forwarded. A comparação do Host recebido com location.host do navegador foi falsa em todos os casos.

**Observação:** os valores sintéticos adversos solicitados não apareceram na saída recebida pelo coletor. **Inferência limitada:** comportamento compatível com normalização efetiva de X-Forwarded-Proto para https no caminho navegador–ingresso–coletor exercitado. **Não comprovado:** envio efetivo dos campos na rede pelo navegador, etapa responsável por eventual filtragem/substituição, garantia universal do proxy ou prevenção de acesso direto. Não habilitar trusted_proxy ou SECURE_PROXY_SSL_HEADER com base isoladamente neste resultado.

## Autorização, referências e Freshness Gate

Despacho autorizou uma única execução controlada em duas etapas, coletor Python isolado por até 900 segundos, encaminhamento Private preservável por decisão do responsável e publicação de dois novos arquivos nesta branch. Proibidas alterações na aplicação, autenticação, banco ou gates.

- Main remota conferida: `174872af652ff1d98833e7d3fe1aef15e5696e53`.
- HEAD local e branch remota `evidence/oes-codespaces-https-followup` conferidos antes da execução: `240209658390cfecbe543023ca71b3f8cd3903a7`.
- Árvore sem alterações versionadas inesperadas; somente oes_https_probe.js estava não versionado no início. Nenhum arquivo staged.
- Consultados `docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md` e `evidence/runtime/codespaces/https-followup/pontual-900s/RELATORIO.md`. O êxito pontual histórico foi consultado, mas a etapa A foi novamente confirmada na janela atual conforme o despacho.
- Porta 8000 livre antes do início. Encaminhamento privado reutilizado conforme declaração/autorização do responsável, sem inspeção direta da interface pelo executor.

## Preparação anterior ao temporizador

Reutilizada a lógica da matriz revisada, preparando oes_https_headers_probe.js antes de iniciar o servidor: baseline, quatro casos por cabeçalho e combinação, total 14. Conteúdo integral inspecionado e sintaxe verificada por node --check sem execução do JavaScript no terminal. Scripts permanecem não versionados e fora do commit.

O script exige raiz HTTPS e usa somente fetch da raiz relativa `/`, cache:no-store, redirect:error, limite de quatro segundos por requisição e orçamento do lote de 60 segundos. Interrompe diante de HTTP não 200, marcador ausente, estrutura inesperada, falha ou timeout. Registra UTC por caso, status, marcador, valores sintéticos solicitados e observações sanitizadas. Não lê cookies, tokens, credenciais ou armazenamento do navegador; usa a autenticação normal same-origin do navegador, sem extraí-la. Não se afirma ausência de cookies enviados automaticamente pelo navegador.

SHA-256 dos arquivos preparados:

- oes_https_probe.js: `0bc215c276b2933bef94a12d6b95e3737ad4a544fdd6fa9f2ae0e3e6e20d8af0`.
- oes_https_headers_probe.js: `ede50a557bbeec7c616dcfcf9ca2a1515535ee81126959dabef714cf3843e4a2`.

## Coletor e observações diretas do executor

Mesmo coletor Python padrão anterior: HTTPServer em 127.0.0.1:8000, env -i, Python -I -B e timeout externo 900s. Sem aplicação, Django, Gunicorn, Neon, PostgreSQL, SQL ou secrets operacionais. Resposta com marcador oes-https-diagnostic e apenas os quatro cabeçalhos selecionados por get_all(); logs de acesso desabilitados; Cache-Control: no-store. Não foram feitas consultas HTTPS externas pelo terminal.

- `2026-11-17T19:27:40Z`: registro UTC imediatamente anterior ao comando de início, seguido da mensagem de inicialização; não é medição exata do instante do bind.
- `2026-11-17T19:27:51.364253+00:00`: validação local em loopback retornou HTTP 200 e marcador correto. Só então foi solicitada a etapa A.
- `2026-11-17T19:41:51Z`: horário de solicitação de parada; lsof confirmou o coletor Python ainda em LISTEN em 127.0.0.1:8000.
- Após identificar o processo, enviado SIGTERM. Processo encerrou com exit 143, sem reinício.
- `2026-11-17T19:42:03Z`: ss confirmou ausência de listener. O intervalo entre o início registrado e essa confirmação foi de 863 segundos, inferior a 900.

## Etapa A — confirmação exigida antes da matriz

Responsável confirmou visualmente o marcador e forneceu saída do teste pontual: início `2026-11-17T19:34:17.518Z`, resposta `2026-11-17T19:34:18.733Z`, término `2026-11-17T19:34:18.735Z`, duração informada 1217 ms, HTTP 200 e markerConfirmed=true. Somente após receber esse resultado foi solicitada a execução única da matriz.

Uma retransmissão do mesmo JSON foi reconhecida como duplicata documental, sem contá-la como nova execução. O código-fonte enviado depois pelo responsável não foi tratado como resultado; a coleta aguardou o JSON da matriz. Não houve solicitação de repetição da matriz em caso de falha.

## Etapa B — matriz fornecida pelo responsável

Início informado: `2026-11-17T19:37:06.497Z`. Término: `2026-11-17T19:37:11.582Z`. Intervalo informado: 5085 ms. completed=true, 14 casos, nenhum stop informado. O JSON completo sanitizado, incluindo os horários por caso, está em resultados.json.

| Caso | Cabeçalhos sintéticos solicitados ao fetch |
|---|---|
| baseline | Nenhum |
| X-Forwarded-Proto/a | X-Forwarded-Proto: http |
| X-Forwarded-Proto/b | X-Forwarded-Proto: https |
| X-Forwarded-Proto/lista-ab | X-Forwarded-Proto: http, https |
| X-Forwarded-Proto/lista-ba | X-Forwarded-Proto: https, http |
| X-Forwarded-Host/a | X-Forwarded-Host: oes-probe.invalid |
| X-Forwarded-Host/b | X-Forwarded-Host: oes-alt.invalid |
| X-Forwarded-Host/lista-ab | X-Forwarded-Host: oes-probe.invalid, oes-alt.invalid |
| X-Forwarded-Host/lista-ba | X-Forwarded-Host: oes-alt.invalid, oes-probe.invalid |
| Forwarded/a | Forwarded: proto=http;host=oes-probe.invalid |
| Forwarded/b | Forwarded: proto=https;host=oes-alt.invalid |
| Forwarded/lista-ab | Forwarded: proto=http;host=oes-probe.invalid, proto=https;host=oes-alt.invalid |
| Forwarded/lista-ba | Forwarded: proto=https;host=oes-alt.invalid, proto=http;host=oes-probe.invalid |
| combinado | X-Forwarded-Proto: http; X-Forwarded-Host: oes-probe.invalid; Forwarded: proto=http;host=oes-probe.invalid |

Para cada linha: status=200, markerConfirmed=true, stop=null e hostMatchesOrigin=false. Os cabeçalhos recebidos sanitizados foram, em todas as linhas:

```json
{
  "X-Forwarded-Proto": [["https"]],
  "X-Forwarded-Host": [["[REDACTED]"]],
  "Forwarded": []
}
```

A lista externa representa ocorrências devolvidas por get_all(); a interna, componentes separados por vírgula e aparados. Ausência é `[]`. O sanitizador mantém somente tokens sintéticos explicitamente permitidos e troca demais valores por [REDACTED]. Não se preservam espaços brutos ou representação textual exata das listas.

## Observações, inferências e não comprovados

### Observações efetivas, com procedência

O executor observou processo, resposta local e encerramento no terminal. O responsável operou o navegador e forneceu os resultados sanitizados. O executor não capturou diretamente o navegador ou o tráfego autenticado. Os horários do navegador situam a etapa A antes da matriz e ambas antes da observação posterior do mesmo coletor ativo, sem reinício; o relógio do navegador não foi sincronizado/auditado independentemente. Não há logs por requisição para correlação adicional.

Os valores http e listas solicitados para X-Forwarded-Proto não aparecem como tal no coletor; este reportou somente https. Os hosts sintéticos solicitados não aparecem no X-Forwarded-Host recebido, que é presente e redigido. Forwarded está ausente mesmo nos casos em que o JavaScript solicitou esse cabeçalho. Host não coincide com a origem segundo comparação booleana; seu valor real não é divulgado.

### Inferências limitadas

O resultado é favorável à hipótese de normalização efetiva de X-Forwarded-Proto no caminho exercitado. Para X-Forwarded-Host e Forwarded, os valores sintéticos solicitados não foram observados como preservados no coletor. A comparação Host=false aponta diferença entre Host no backend e host da origem do navegador, mas não identifica valor, causa ou ajuste apropriado.

### Aspectos não comprovados

Não houve captura do envio efetivo pelo navegador: requestedSyntheticHeaders registra intenção passada à API, não prova de campos na rede. Não se atribui exclusivamente ao ingresso a etapa que filtrou/substituiu valores. Também não se comprovam tratamento de duplicatas físicas, outros clientes/protocolos/rotas, igualdade entre hosts redigidos, valor real do Host ou de X-Forwarded-Host, impossibilidade de acesso direto, bloqueio de acesso não autorizado nesta execução, autenticação exaustiva ou garantia universal do proxy.

A mesma saída [REDACTED] em várias linhas não significa que os valores originais eram iguais. Nenhum valor redigido deve ser reconstruído por suposição.

## Avaliação perante P2

Classificação: matriz concluída com evidência favorável de normalização no caminho testado, sem aceite operacional integrado ou prova universal de confiança no proxy. A origem/Host exatos e a cadeia confiável de esquema ainda não foram homologados para Django. Continuam pendentes as propriedades de topologia, prevenção de acesso direto e fundamento confiável de remoção/sobrescrita exigidos pelo P2.

Não foram habilitados SECURE_PROXY_SSL_HEADER, trusted_proxy ou TLS_TERMINATION; nenhum redirect, cookie, ALLOWED_HOSTS, autenticação ou validador foi alterado. Não liberar Q0, Q1, E9 ou outros gates com base neste resultado.

## Encerramento, STOP e publicação

Servidor encerrado por SIGTERM após receber a matriz completa, antes de 900 segundos; ausência de listener confirmada. Encaminhamento preservado conforme decisão vigente do responsável e autorização deste despacho; não foi removido nem alterada sua visibilidade pelo executor. A visibilidade Private é declaração do responsável, não inspeção direta do executor.

Nenhuma condição de STOP de requisição foi informada nesta execução. O lote estava preparado para parar em HTTP não 200, marcador ausente, timeout ou estrutura inesperada; o servidor tinha limite externo de 900 segundos. Porta ocupada, exposição pública, necessidade de extrair credenciais ou exposição imprevista também exigiriam STOP. Não houve reinício ou novo ensaio automático.

Somente RELATORIO.md e resultados.json neste novo diretório integram a publicação; evidências e commits anteriores são preservados. Gatilhos de GitHub Actions versionados foram reinspecionados: filtros de push não abrangem estes dois caminhos nesta branch; nenhum workflow_dispatch solicitado. Não se atestam políticas externas não presentes no repositório. Aplicar reconferência remota, revisão integral, validação estrutural e git diff --check antes do push. Sem PR, merge ou alteração de main.

Sem URL privada, identificador do Codespace, cookies, tokens, credenciais ou logs autenticados. Scripts locais não versionados não serão incluídos no commit.

Preservados CP348 vigente, Marco B OPEN, Q0 HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 5 NOT_STARTED e núcleo P1/D3. Nenhuma atividade posterior à matriz foi iniciada.
