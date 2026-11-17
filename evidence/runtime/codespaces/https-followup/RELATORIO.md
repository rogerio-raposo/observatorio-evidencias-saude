# OES — diagnóstico HTTPS complementar

## Identificação e conclusão

Base aprovada: `174872af652ff1d98833e7d3fe1aef15e5696e53`.
Branch: `evidence/oes-codespaces-https-followup`.
Evidência anterior: branch `evidence/oes-codespaces-https`, commit `b4a54962de84e65e6cb97032575bad838c2b3146`, arquivos `evidence/runtime/codespaces/https/RELATORIO.md` e `resultados.json`.

**Resultado: INCONCLUSIVO.** A requisição baseline feita pelo JavaScript aprovado recebeu HTTP 401. O lote interrompeu antes do envio de qualquer caso com cabeçalhos sintéticos. Não há observação complementar de X-Forwarded-Proto, X-Forwarded-Host ou Forwarded através do ingresso. Não foi demonstrada remoção, sobrescrita ou preservação desses cabeçalhos.

## Fontes e confirmações posteriores ao primeiro relatório

O responsável confirmou, sobre o ensaio anterior, a porta 8000 identificada como Private, o endereço HTTPS identificado em Ports, HTTP 401 ao abrir o endereço encaminhado e a remoção do encaminhamento. São declarações do responsável recebidas após a publicação anterior; não são inspeção direta da interface pelo executor nem garantia da política do proxy.

Neste ensaio complementar, o responsável informou que a página abriu e que executou o JavaScript. Depois entregou o JSON sanitizado reproduzido abaixo. A confirmação textual de página aberta não equivale a captura independente do marcador nem a baseline autenticada bem-sucedida. Não houve nova confirmação explícita de Private da segunda janela; a propriedade não foi reinspecionada diretamente pelo executor. A URL encaminhada recebida na conversa foi omitida integralmente destes arquivos públicos.

## Procedimento executado

Antes de iniciar, confirmou-se árvore de trabalho limpa e ausência de listener TCP na porta 8000. Não foram repetidos testes de Python, dependências ou configuração básica.

Reutilizou-se o mesmo coletor Python padrão anterior: HTTPServer, bind `127.0.0.1:8000`, ambiente limpo por `env -i`, Python em `-I -B`, timeout externo de 300 segundos e nenhum reinício automático. Nenhum Django, Gunicorn, secret ou PostgreSQL foi utilizado. O coletor retorna marcador sintético `oes-https-diagnostic`, transporte local HTTP e somente os quatro cabeçalhos selecionados por `get_all()`, preservando ocorrências. Logs de acesso suprimidos e resposta com Cache-Control: no-store.

Sem ferramenta de navegador autenticado disponível ao executor, apresentou-se previamente um único lote JavaScript ao responsável, que o aprovou. O lote utiliza somente fetch da raiz relativa `/`, sem ler cookies, tokens, localStorage, sessionStorage ou cabeçalhos de autorização. A sessão normal do navegador não foi extraída ou copiada. Requisições têm redirect:error, cache:no-store e timeout de até quatro segundos, com orçamento total do lote de 60 segundos. Somente valores sintéticos permitidos são mantidos na saída; valores desconhecidos são redigidos. Host real é representado apenas por comparação booleana com a origem, quando houver resposta válida do coletor.

O servidor iniciou e o responsável foi avisado para abrir o endereço HTTPS e confirmar o marcador antes da execução do bloco. Após informar que a página abriu, o responsável recebeu instruções para executar o lote uma vez no Console. Os resultados puderam ser entregues após o encerramento do servidor, sem reiniciar o ensaio.

## Matriz planejada e observação efetiva

Planejados 14 casos: baseline; quatro casos para cada um dos três cabeçalhos; e combinação dos três. Para X-Forwarded-Proto: http, https, lista http/https e lista inversa. Para X-Forwarded-Host: dois hosts sintéticos e ambas as ordens de lista. Para Forwarded: dois valores sintéticos com proto/host e ambas as ordens de lista. O coletor preserva duplicatas recebidas; o navegador não comprova envio de campos fisicamente duplicados.

Foi observado somente um resultado, fornecido pelo responsável como saída do bloco aprovado:

```json
{
  "diagnostic": "oes-https-followup",
  "completed": false,
  "results": [
    {
      "case": "baseline",
      "status": 401,
      "stop": "RESPOSTA_NAO_200"
    }
  ]
}
```

O algoritmo verifica status antes de ler o corpo; com 401, não lê cabeçalhos do coletor e não executa casos subsequentes. Portanto: um caso com resultado informado, zero casos sintéticos executados segundo a saída fornecida, 13 casos não executados. Não há valores de cabeçalhos recebidos para interpretar. Não se armazenaram resposta bruta, URL, cookies ou logs autenticados.

## Interpretação perante P2 e limitações

O 401 demonstra recusa dessa requisição baseline, sem determinar causa, identidade da camada emissora ou adequação da autenticação da navegação anterior. Não prova defeito do coletor, segurança de X-Forwarded-Proto nem compatibilidade de trusted_proxy. A diferença entre página relatada como aberta e baseline 401 permanece sem causa demonstrada; não se presume que a navegação e o fetch tiveram condições equivalentes de autenticação. A saída entregue não contém timestamp que comprove a execução do baseline enquanto o coletor ainda estava ativo; essa correlação temporal também permanece não demonstrada.

Classificação: evidência técnica parcial de ensaio isolado, hipótese de tratamento de cabeçalhos INCONCLUSIVA, sem aceite operacional PF-08 ou comprovação da cadeia de confiança. Nenhuma inferência sobre garantia universal do proxy. Nenhuma escolha ou liberação de trusted_proxy/wsgi é autorizada pelo resultado.

Referências: `docs/governance/OES_Q0_OPERATIONAL_CONTRACT_P2.md` e `docs/governance/OES_CODESPACES_PREPARATION.md`. Sem comprovação da topologia, remoção/sobrescrita e prevenção de acesso direto forjado, permanece STOP operacional do P2. Uma investigação futura do acesso pela interface normal do GitHub exigirá despacho próprio; não foi iniciada nem contornou autenticação.

## Encerramento

O processo encerrou automaticamente com exit 124 do timeout de 300 segundos; ausência de listener na porta 8000 confirmada pelo executor, inclusive na reconferência anterior à preparação das evidências. Não houve reinício ou ampliação do prazo.

O responsável informou inicialmente que o encaminhamento ainda estava presente e, após solicitação de remoção, confirmou que foi removido neste ensaio. Remoção: confirmada pelo responsável, não inspecionada diretamente na interface pelo executor. Servidor e encaminhamento possuem evidências de encerramento distintas.

STOP aplicado no baseline não 200 e no limite do servidor. Permanecem condições de STOP: visibilidade Public/Organization, acesso não autorizado ao coletor, necessidade de manipular credenciais, exposição inesperada, porta ocupada ou matriz sem acesso válido. Não relaxar proteção nem executar novos ensaios automaticamente.

## Publicação controlada e invariantes

Branch de follow-up criada da base aprovada, após verificar árvore limpa, main remota na base, evidência anterior no SHA indicado e ausência de branch de follow-up local/remota. Não houve sobrescrita de trabalho existente. Os workflows da base já foram inspecionados: filtros de push não abrangem estes dois caminhos nesta branch. Não foi solicitado workflow_dispatch; políticas externas não presentes no repositório não são atestadas.

Entrega limitada a este relatório e `resultados.json`, sujeitos a revisão integral, validação estrutural e git diff --check antes da publicação. Sem URLs privadas, identificador do Codespace, credenciais, cookies, tokens, dados pessoais ou logs completos de requisições. A única saída do navegador incluída é o JSON sanitizado acima.

Preservados CP348 vigente, Marco B OPEN, Q0 HARD HOLD, Q1 conectado HOLD, E9 NO-GO, Fase 5 NOT_STARTED e núcleo P1/D3. Sem alteração de main, aplicação, configurações Django ou gates; sem PostgreSQL/SQL, PR ou merge. Nenhuma atividade posterior ao diagnóstico foi iniciada.
