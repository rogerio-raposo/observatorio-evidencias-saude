# OES — Diagnóstico das aprovações do Codex

**Perfil ativo.** Sandbox `workspace-write` com perfil gerenciado, rede restrita e escrita em `/tmp` e `applications/oes_web`. A raiz Git confirmada é `<raiz-do-repositório>`. Portanto, `docs/governance` e os metadados Git do repositório ficam fora da raiz gravável. A sessão permite elevação por aprovação e já contém prefixos aprovados. O nome exato da política de aprovação e sua configuração de origem não foram confirmados.

**Instruções do projeto.** A diretriz OES está presente no contexto da sessão e em `HEAD:AGENTS.md`. Na publicação anterior, o pai de HEAD foi conferido como `7d29d653e5340b0da723934dc63c97863e6e2e44` e o único arquivo acrescentado foi a minuta HTTPS. Assim, o conteúdo verificado de `AGENTS.md` corresponde à base de main usada pela branch. A presença da diretriz no contexto confirma sua disponibilidade, com o mecanismo de carregamento automático em aberto.

**Resultado dos testes sem elevação.** `git status --short --branch`, `true` e `bwrap --version` retornaram código 1 com o mesmo erro do executor:

```text
bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. [Sugestão genérica do executor omitida.]
```

`git --no-optional-locks status --short --branch` e `git rev-parse --show-toplevel`, cujos prefixos já estavam aprovados, funcionaram sem nova confirmação. Como até `true` falhou, o bloqueio dos comandos comuns ocorre na inicialização do sandbox. A mensagem demonstra que o Bubblewrap foi invocado e falhou ao criar um namespace. A leitura adicional e a checagem da versão ficaram bloqueadas no mesmo ponto. A causa específica entre configuração do kernel, política de segurança ou restrição do contêiner permanece indeterminada. Os limites de escrita e rede também podem exigir aprovação independentemente dessa falha.

**Menor ajuste recomendado.** O administrador deve diagnosticar o suporte a namespaces do executor e restaurar o funcionamento do sandbox pelo mecanismo suportado do ambiente, preservando `workspace-write` e as proteções vigentes. O teste de aceite é rodar `true` e `git status --short --branch` sem elevação e sem depender de prefixos aprovados. Para despachos que escrevem em `docs/governance`, o usuário ou administrador pode provisionar uma sessão com esse caminho autorizado. O Codex pode agrupar verificações locais, reutilizar prefixos aprovados e manter a publicação limitada ao arquivo e à branch de cada despacho. Nenhum ajuste de permissão, sandbox, sistema ou configuração foi realizado.

## Diagnóstico complementar e correção recomendada

O histórico da sessão preserva o relatório original e o trecho sanitizado da saída abaixo. A leitura direta do Markdown pelo executor também ficou bloqueada na inicialização do sandbox. O diagnóstico reaproveitou o registro anterior e não executou novo teste deliberado de reprodução.

```text
bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces. [Sugestão genérica do executor omitida.]
```

O trecho publicado identifica a falha de criação de namespace. A sugestão genérica omitida não informa a configuração efetiva deste Codespaces.

| Controle | Constatação |
| --- | --- |
| Falha de execução | O Bubblewrap foi invocado e a criação de namespace falhou antes da execução de um comando inofensivo. Assim, a falha observada não depende do Git. A presença de um Bubblewrap executável ficou demonstrada pela própria mensagem. Versão, origem do binário, configuração efetiva do kernel, política de segurança e restrições do contêiner continuam indeterminadas. |
| Permissões do workspace | Perfil gerenciado `workspace-write`, com escrita na aplicação `applications/oes_web` e em `/tmp`. A raiz Git é o repositório OES. A escrita em `docs/governance` e nos metadados Git fica fora da área gravável informada. A rede é restrita. Esses limites são independentes da falha do Bubblewrap. |
| Política de aprovação | O executor prevê elevação mediante aprovação e tem prefixos previamente aprovados. Por isso, alguns comandos exatos funcionaram sem nova confirmação. O valor nominal de `approval_policy` e a origem das regras efetivas seguem sem confirmação. Pedidos por acesso fora do perfil são compatíveis com o funcionamento normal da política. Pedidos para repetir uma leitura que falhou na inicialização do sandbox decorrem da falha técnica observada. |

### Alternativas em ordem de preferência

1. **Acionar o responsável pelo executor gerenciado com a mensagem sanitizada.** Pedir que compare a versão e a origem do Bubblewrap e os diagnósticos efetivos do contêiner e da VM com os pré-requisitos oficiais. Essa investigação inicial não requer mudar o projeto nem o perfil. A documentação da OpenAI descreve uma solução específica para Ubuntu 24.04 com AppArmor, cuja aplicabilidade aqui segue indeterminada. Não foi localizada, nas fontes oficiais consultadas, uma correção específica para esta combinação de Codex CLI e Codespaces. [Sandbox do Codex](https://learn.chatgpt.com/docs/sandboxing) · [Implementação oficial do sandbox Linux](https://github.com/openai/codex/blob/main/codex-rs/linux-sandbox/README.md)
2. **Se o administrador não puder corrigir o executor atual dentro das proteções vigentes, usar uma sessão em ambiente compatível com o sandbox nativo.** Um novo ambiente pode consumir franquia e requer preservação prévia de arquivos não versionados. O GitHub oferece reconstrução nativa do dev container para aplicar mudanças ou resolver problemas de contêiner, mas isso não demonstra que um rebuild resolva uma restrição da VM ou do executor gerenciado. [Reconstrução de contêiner no Codespaces](https://docs.github.com/en/codespaces/developing-in-a-codespace/rebuilding-the-container-in-a-codespace)
3. **Tratar a raiz gravável separadamente, se o trabalho exigir escrita em governança.** O responsável pode provisionar uma sessão com acesso de escrita ao caminho necessário. Esse ajuste aumenta o conjunto de arquivos acessíveis e por isso deve acompanhar o escopo do despacho. A troca de raiz gravável não corrige a etapa de criação de namespace. [Aprovações e segurança do Codex](https://learn.chatgpt.com/docs/agent-approvals-security)

O código oficial contempla um caminho legado Landlock, mas o executor pode manter Bubblewrap em uso quando há rede gerenciada. A compatibilidade dessa alternativa com o perfil atual não foi demonstrada. Alterar o mecanismo de isolamento ou relaxar controles do sistema exigiria avaliação do administrador e está fora deste diagnóstico. [Seleção do sandbox no código oficial](https://github.com/openai/codex/blob/main/codex-rs/sandboxing/src/landlock.rs)

**Responsabilidades e validação.** O Codex pode agrupar leituras, aproveitar os prefixos já concedidos e validar a sessão. O responsável ou administrador controla o provisionamento e a investigação do executor. Após eventual correção, executar `true` e `git status --short --branch` com permissões padrão e confirmar que passaram pelo sandbox, sem solicitação de aprovação nem uso de prefixo previamente autorizado. Conferir no perfil a raiz gravável e a manutenção das restrições de rede. Para um despacho de governança, incluir a verificação da escrita no diretório autorizado durante a criação do primeiro artefato previsto. Não houve mudança de configuração ou publicação.
