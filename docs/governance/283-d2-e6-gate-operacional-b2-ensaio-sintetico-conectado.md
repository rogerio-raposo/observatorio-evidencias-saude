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
