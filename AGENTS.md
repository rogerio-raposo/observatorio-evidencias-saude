# OES — Diretriz permanente de autonomia operacional do Codex

## 1. Princípio geral

No projeto Observatório de Evidências em Saúde (OES), o Codex deverá executar integralmente os despachos recebidos, dentro dos limites expressamente autorizados, **sem solicitar confirmações intermediárias desnecessárias**.

Um despacho autorizado constitui autorização suficiente para realizar todas as atividades nele previstas, inclusive suas etapas preparatórias, verificações, testes, correções proporcionais e produção das evidências especificadas.

A autorização não precisa ser renovada a cada comando, arquivo, teste ou etapa.

## 2. Autonomia dentro do escopo

O Codex poderá, sem novas consultas:

- Ler e analisar arquivos do repositório.
- Consultar documentação necessária, quando o acesso estiver permitido.
- Executar comandos locais compatíveis com o despacho.
- Criar e modificar arquivos autorizados.
- Realizar testes offline previstos no escopo.
- Corrigir erros encontrados durante a execução, desde que a correção não altere os limites aprovados.
- Reexecutar testes proporcionais após correções.
- Produzir relatórios Markdown e evidências estruturadas.
- Realizar verificações de integridade, sanitização e Freshness Gate.
- Publicar branches e commits quando a publicação estiver explicitamente autorizada.

O Codex deve conduzir o trabalho até sua conclusão, sem perguntar repetidamente se deve prosseguir.

## 3. Quando solicitar autorização

Solicitar autorização somente quando ocorrer pelo menos uma das situações:

1. A operação necessária estiver fora do escopo aprovado.
2. For necessária uma ação expressamente proibida ou não autorizada pelo despacho.
3. Houver alteração material de arquitetura, contratos, requisitos ou gates.
4. A operação exigir acesso conectado, credenciais, permissões ou recursos não contemplados pela autorização.
5. Houver risco de custo adicional não autorizado.
6. For necessária uma operação destrutiva, irreversível ou com efeitos relevantes sobre recursos compartilhados, não prevista expressamente.
7. For necessário publicar, abrir PR, realizar merge ou implantar sem autorização correspondente.
8. For identificada uma condição de STOP.

Não interpretar uma autorização genérica de execução como autorização para ultrapassar qualquer dessas fronteiras.

## 4. Tratamento de dificuldades

Diante de erros ou dificuldades técnicas:

- Investigar a causa.
- Aplicar correções proporcionais dentro do escopo.
- Reexecutar as verificações necessárias.
- Registrar decisões e resultados.
- Prosseguir até concluir a atividade autorizada.

Não interromper o trabalho apenas para informar dificuldades que possam ser resolvidas com segurança dentro do escopo.

Se houver bloqueio real, interromper exclusivamente a parte afetada e documentar o impedimento. Não improvisar uma solução que ultrapasse a autorização.

## 5. Comunicação com o responsável

Evitar perguntas como:

- "Posso prosseguir?"
- "Deseja que eu execute os testes?"
- "Posso criar o arquivo?"
- "Posso verificar o resultado?"
- "Quer que eu faça o commit?"

Essas perguntas são desnecessárias quando as respectivas ações já estão autorizadas.

Solicitar intervenção humana apenas quando indispensável, explicando objetivamente a ação necessária.

## 6. Entrega

Quando houver autorização de publicação, priorizar evidências sanitizadas em arquivos Markdown e JSON acessíveis no GitHub.

Não exigir que o responsável copie respostas extensas, relatórios, hashes ou resultados técnicos da interface do Codespaces para o ChatGPT.

Ao concluir, apresentar uma mensagem curta indicando o resultado e a localização das evidências.

## 7. Preservação da governança

Esta diretriz não modifica a política de segurança do Codex CLI nem concede permissões técnicas adicionais.

Não autoriza desabilitar o sandbox, contornar verificações, acessar credenciais fora do escopo ou suprimir condições de STOP.

Preservar integralmente os acordos de trabalho, o princípio do contraditório técnico fundamentado, o Freshness Gate e os gates vigentes do OES.

**Regra de execução: uma autorização por escopo delimitado, não uma autorização por comando.**
