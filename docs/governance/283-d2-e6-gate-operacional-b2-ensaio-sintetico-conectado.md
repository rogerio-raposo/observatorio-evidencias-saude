# Documento 283 — Gate operacional B2: ensaio sintético conectado e recuperação privada

**OES | 2026-10-24 | HEAD-base `f8d750f306bba8681ca28c6d04f2fbae0a01a888` | PROPOSTA — SEM AUTORIZAÇÃO OPERACIONAL**

## Premissas comprovadas

B1 encerrou-se como atestação de ACL fornecida pelo proprietário e incorporada ao Documento 282. A matriz informou: `oes_e6_capture_login` NOLOGIN, sem membership, USAGE, INSERT ou SELECT; `oes_e6_writer` NOLOGIN, USAGE+INSERT e sem SELECT; `oes_e6_verifier` NOLOGIN, USAGE+SELECT e sem INSERT. A CI offline da etapa A aprovou 63/63 testes na run 40126123398. Tabela privada observada vazia. Não confundir atestação do catálogo, simulações e execução conectada por identidades reais.

## B2 proposto — execução restrita, em gates sucessivos

1. **Preparação e viabilidade (sem modificar o banco):** confirmar a forma exata e permitida de executar SQL com identidade efetiva de writer e verifier sem conceder a ambos privilégios cruzados. O conector já bloqueou tentativa de INSERT positivo anterior; não contornar suas restrições. Evitar produção de novos logins, secrets ou armazenamento de senhas em chat, Git ou logs. A identidade `oes_e6_capture_login` continuará NOLOGIN e sem membership até autorização separada de reativação, se estritamente necessária.
2. **Autorização operacional adicional, depois da viabilidade:** delimitar explicitamente alterações temporárias de privilégio/autenticação, caso necessárias, plano de reversão e escopo de um único payload **inteiramente sintético** com identificador não colidente. Nenhum GET externo.
3. **Ensaio conectado:** escrever uma observação sintética via writer, sem permissão SELECT; consultar o mesmo registro via verifier, sem permissão INSERT; comparar identificador, quantidade de bytes e SHA-256 independente **sem imprimir bytes**. Demonstrar os controles de negação cruzada. A linha pode já estar COMMITTED antes da verificação: falha posterior exige HOLD e saneamento controlado.
4. **Limpeza e reversão:** remover exclusivamente a linha sintética mediante autorização e papel com DELETE apropriado; não presumir DELETE do writer/verifier. Verificar tabela privada vazia, fixture PG-A4 intacta e grants/LOGIN de volta ao baseline. Invalidar a senha transitória antiga antes de qualquer nova ativação; NOLOGIN por si só não significa senha apagada.
5. **Evidência:** registrar exclusivamente hashes, tamanhos, IDs sintéticos, status, branch, banco, papéis efetivos, operações e reversão; nenhum JSON bruto em GitHub/artifacts/logs.

## Critérios de interrupção imediata

Sem via autenticada independente para as duas identidades; bloqueio de ferramenta; discrepância de ACL; falha de integridade; impossibilidade de demonstrar limpeza segura; necessidade não prevista de secrets, novos privilégios ou serviços. Em qualquer caso: STOP, sem improvisar escalonamento de privilégio.

## Fronteiras

**Este documento é apenas a preparação do gate, não autoriza SQL/DML, alteração de roles ou credenciais.** O workflow factual `.github/workflows/d2-e6-a2-gated-capture.yml` permanece desabilitado por `if: ${{ false }}` e ainda contém caminho antigo de artifacts que não poderá ser acionado. Nenhuma aprovação factual E6-G1, produção, pagamento ou promoção científica.

## Decisão solicitada neste momento

Aprovar **somente um desenho executivo e preflight de viabilidade sem alterações**, antes de solicitar autorização separada para cada operação sensível:

`APPROVED — OES / D2-E6 / B2_NONMUTATING_EXECUTION_DESIGN_ONLY / no SQL writes / no role changes / no credential changes / no raw reads / no factual GET / keep workflow disabled / no paid services / fail closed`

**Estado:** `B1_ACL_ATTESTED_PASS / B2_EXECUTION_DESIGN_PENDING_APPROVAL / B2_SQL_NOT_AUTHORIZED / E6_G1_BLOCKED`.

**STOP.**

## Desenho executivo não modificador aprovado — avaliação

**Decisão sobre viabilidade:** a etapa B2 é **tecnicamente concebível, mas ainda não executável sob o baseline vigente**. O catálogo atestado em B1 comprova permissões dos papéis NOLOGIN; não fornece, por si só, duas sessões autenticadas independentes. `oes_e6_capture_login` está NOLOGIN e sem membership. Não há autorização de provisionar novas credenciais, mudar SET ROLE, ou utilizar o login proprietário como substituto silencioso da separação exigida.

**Protocolo mínimo futuro (não executar agora):**

1. **Gate de viabilidade de identidade:** escolher explicitamente entre (a) dois logins transitórios dedicados com memberships não herdáveis e capacidade SET restrita, um para writer e outro para verifier, ou (b) outra rota de duas sessões efetivamente segregadas que a infraestrutura permita. Cada sessão deverá comprovar `session_user`, `current_user` e a ausência de privilégios cruzados, sem expor conexão, password ou payload. A mera alternância de `SET ROLE` dentro de uma única identidade administrativa demonstra ACL, mas **não prova independência de autenticação**. O SQL Editor conectado como proprietário não substitui essa evidência.
2. **Gate de credencial:** senhas novas e efêmeras controladas pelo proprietário, sem reutilizar a anterior e sem reproduzi-las em chat, logs, arquivos ou workflow. Exigir revogação e `NOLOGIN` no fechamento; invalidar credenciais. Não supor que `NOLOGIN` mata sessões existentes. A criação/alteração de papéis depende de aprovação própria.
3. **Gate de registro único:** somente após autorizações operacionais e identidade verificada, INSERT parametrizado de bytes totalmente sintéticos, ID único e metadados válidos sob writer; não imprimir os bytes em nenhum resultado. A identidade writer não poderá consultar o registro para validar a si mesma.
4. **Gate de recuperação:** usar sessão/verifier independente para ler somente o registro sintético por ID e calcular verificação de bytes, hash e tamanho em memória privada; registrar exclusivamente booleanos, tamanho e digest. Não retornar `raw_payload` ao chat nem ao GitHub.
5. **Gate de limpeza e invariantes:** procedimento aprovado com identidade administrativa autorizada apenas para DELETE do ID sintético identificado; verificar zero registros, manter fixture PG-A4 (2 estudos, 2 relatórios, 3 vínculos e 1 proveniência), revogar concessões transitórias precisamente por grantor e inativar logins. Se readback falhar depois de COMMIT, declarar HOLD com registro possivelmente persistido e não repetir INSERT às cegas.

**Segurança e simplificação:** não criar novo workflow nem camada de armazenamento para executar esse único ensaio; tentar resolver a comprovação por meios operacionais já disponíveis e expressamente autorizados. Caso a ferramenta impeça INSERT autenticado por política, **não contornar**: registrar `BLOCKED` e reavaliar utilidade do ensaio antes de novas alterações.

**Decisão resultante:** falta comprovar uma rota autorizada de **duas sessões autenticadas de menor privilégio**, e fixar um plano preciso de criação/revogação, antes de pedir autorização para modificar papéis ou inserir dados. Não existem novas evidências conectadas nesta avaliação. `B2_NOT_READY_FOR_EXECUTION / B2_SQL_NOT_AUTHORIZED / E6_G1_BLOCKED`.

## Comparação de alternativas de identidade — desenho sem alteração (2026-10-24)

Documentação oficial Neon consultada: https://neon.com/docs/manage/roles . **Papéis criados via Console/CLI/API recebem tipicamente associação automática a `neon_superuser`; para menor privilégio, criar por SQL**, com permissões explicitamente limitadas, é a via recomendada pelo fornecedor. Papéis são específicos à branch.

| Alternativa | Benefício | Limitação | Decisão |
|---|---|---|---|
| Sessão administrativa única com `SET ROLE` alternado | Não exige novo login; testes de ACL pontuais já ocorreram no Documento 272 | Não prova duas **autenticações independentes**; conta administrativa continua privilegiada | Não usar como evidência final de B2 |
| Reativar `oes_e6_capture_login` e criar outro login leitor por SQL | Reaproveita identidade conhecida e requer só um papel adicional | Reabre senha antiga, demanda higienização, rotacionar antes de ativar e gerir novas concessões | Possível, mas não preferencial |
| Dois logins efêmeros criados **por SQL** sem privilégios automáticos, associados separadamente a `oes_e6_writer` e `oes_e6_verifier` | Sessões autenticadas independentes e ACL segregada, sem elevar papel administrativo | Exige duas credenciais e mudanças temporárias autorizadas | **Preferida apenas se a prova de duas sessões for indispensável** |

**Juízo de proporcionalidade:** os testes anteriores já provaram isolamento negativo de writer e verifier. A única lacuna material da B2 é a **escrita positiva e recuperação de bytes persistidos com isolamento real**. Antes de criar logins, avaliar se a comprovação estrita de duas autenticações diferentes é requisito de aceite do piloto; se não for, um ensaio transacional sintético sob identidades efetivas controladas, acompanhado de ressalva metodológica explícita, pode ser suficiente. A escolha precisa ser decidida em gate antes de qualquer SQL. Não transformar B2 em implantação do sistema de autenticação de produção.

**Condição de viabilidade:** o conector já bloqueou INSERT positivo em tentativa anterior. Não executar variações para burlar esse bloqueio. Se houver autorização específica, a operação deverá ocorrer por canal aprovado (por exemplo, SQL Editor do proprietário) e documentar a identidade efetiva, sem expor senha ou JSON bruto. O SQL Editor não constitui, por si, autenticação independente da conta proprietária.

**Próxima decisão, sem executar agora:** escolher entre (I) evidência sintética pragmática sob troca de papel, com limitação de autenticação registrada; ou (II) ensaio estrito de duas sessões efêmeras SQL-only, mais complexo. Nenhuma nova conta, credencial, DML ou alteração de workflow autorizada por esta comparação.

**Estado:** `B2_ALTERNATIVES_EVALUATED / IDENTITY_DESIGN_DECISION_PENDING / B2_SQL_NOT_AUTHORIZED / E6_G1_BLOCKED`.

## Decisão do proprietário — opção 1 (2026-10-24)

O proprietário escolheu expressamente **Opção 1: ensaio sintético mediante alternância controlada de papéis por `SET ROLE`**, dispensando para este ensaio a exigência de duas **sessões autenticadas independentes**. Essa é uma decisão de **desenho metodológico**, não autorização de DML, de concessão de `SET`, alteração de `LOGIN`, credenciais ou uso do workflow factual.

**Critério de aceite delimitado:** comprovar escrita sintética positiva sob `current_user=oes_e6_writer`, leitura e comparação de integridade sob `current_user=oes_e6_verifier`, e negações cruzadas. Registrar o `session_user` administrativo, o fato de que as identidades efetivas derivaram de uma sessão controladora e a **não comprovação de autenticação operacional independente**. Não classificar como teste de login de produção.

**Pré-condição técnica:** no baseline histórico, as concessões preexistentes ao proprietário apresentavam `SET FALSE`; obter `SET ROLE` real requer uma concessão transitória específica ou outro mecanismo já autorizado. Não presumir que `SET ROLE` funcionará sem alteração. Se necessária concessão, aprovar separadamente sua criação e revogação seletiva por grantor, preservando memberships preexistentes. Antes de eventual INSERT, fixar limite exato de dados sintéticos, SQL e estratégia de limpeza, com verificação de cardinalidade final e fixture PG-A4 intacta. O conector já bloqueou um teste de escrita anterior: respeitar bloqueios, sem variações destinadas a contorná-los.

**Próxima etapa:** preparar uma única autorização operacional restrita, com SQL pré-revisado e rollback/limpeza; nenhuma operação autorizada nesta decisão. Workflow factual continua `if: ${{ false }}`.

**Estado:** `B2_OPTION_1_SELECTED / ROLE_SWITCH_EXECUTION_GATE_PENDING / B2_WRITES_NOT_AUTHORIZED / E6_G1_BLOCKED`.

## Procedimento executivo restrito — opção 1, preparado sem execução (2026-10-24)

**Escopo:** um único registro inequivocamente sintético na branch `br-gentle-hall-b6jaxehf`, projeto `weathered-boat-65779510`, banco `oes_sandbox`. Não criar logins, usar credenciais temporárias antigas, habilitar workflows, invocar GET ou acessar payload factual. A escolha da opção 1 foi aprovada como desenho; **DML, concessões transitórias e exclusão ainda aguardam autorização operacional específica**.

**Preflight obrigatório antes de modificar qualquer coisa:** confirmar com evidência contemporânea `session_user`, associações e respectivos `grantor`/opções `SET` do proprietário para ambos os papéis, permissões efetivas, schema exato e contagem zero; confirmar fixture PG-A4 (2 estudos, 2 relatórios, 3 links, 1 proveniência). Se o conector bloquear consulta, não insistir nem contornar: interromper e usar procedimento manual aprovado, quando autorizado.

**Acesso temporário:** as associações históricas concedidas por `cloud_admin` ao proprietário não devem ser removidas. Se necessário, acrescentar somente grants temporários com `SET TRUE, INHERIT FALSE`, rastrear `grantor` e retirar exclusivamente os grants criados no ensaio; revogar `GRANTED BY` corretamente, sem `REVOKE` genérico. Confirmar que o proprietário não herda privilégios de writer/verifier por essas concessões.

**Inserção:** utilizar identificador prefixado `SYNTH-B2-` único, bytes UTF-8 sintéticos conhecidos, comprimento real menor ou igual a 2.000.000 e SHA-256 calculado sobre bytes sem reserialização. Executar INSERT somente após comprovar `current_user=oes_e6_writer` na transação `SET LOCAL ROLE`, registrando também `session_user`. Encerrar transação para persistência observável; não executar SELECT sobre payload como writer. A prova de autenticação independente permanece fora de escopo.

**Recuperação:** em transação **separada**, `SET LOCAL ROLE oes_e6_verifier` e comprovar `current_user`; consultar somente o identificador sintético e calcular SHA-256/contagem de bytes no ambiente controlado, retornando metadados sanitizados; não exportar `raw_payload` em tela, chat, log ou artifact. Comparar digest originalmente calculado, coluna armazenada e digest de bytes recuperados. Registrar HOLD se qualquer divergência. Leitura por verifier não confere autorização de escrita.

**Limpeza:** como writer/verifier não têm DELETE, executar exclusão restrita **somente** por identidade administrativa explicitamente autorizada, conferindo observação única pelo ID antes e zero registros depois; validar fixture PG-A4. **Limpeza e revogação devem ocorrer inclusive após HOLD**; se alguma etapa de saneamento falhar, registrar incidente e não declarar baseline restaurado. Revogar exclusivamente memberships de teste com prova do grantor e verificar `pg_has_role(owner,...,'SET')=false` preservando associações prévias. Login `oes_e6_capture_login` deve permanecer NOLOGIN e sem membership.

**Revisão do SQL:** ainda necessária antes de execução, com conferência de tipos/constraints e da semântica do Neon SQL Editor. Não assumir que transações ou contextos de `SET LOCAL ROLE` persistem entre execuções do Editor. Comandos operacionais serão apresentados e submetidos a autorização antes de qualquer execução; esta seção não é script executável.

**Critério de aceite:** um INSERT sintético confirmado, leitura sob verifier efetivo, digests/tamanhos idênticos, nenhuma permissão cruzada, linha removida, fixture inalterada e baseline de grants restaurado. Aprovação de B2 não significa liberação de E6-G1 factual.

**Pedido de autorização para fase operacional posterior (não aprovado):**
`APPROVED — OES / D2-E6 / B2_SINGLE_SYNTHETIC_CONNECTED_SET_ROLE_TRIAL / br-gentle-hall-b6jaxehf / temporary SET grants only if needed / one synthetic INSERT / private verifier hash check / precise cleanup and grantor-aware revoke / no factual GET / no public JSON / no workflow enablement / no paid services / fail closed`

**Estado:** `B2_OPTION_1_EXECUTION_PLAN_PREPARED / B2_SQL_APPROVAL_PENDING / E6_G1_BLOCKED`.
