# OES — M3-C | Decisão de desenho, evidências e preflight READ ONLY

**Data:** 2026-11-18 (America/Recife)  
**Estado:** PREPARATÓRIO; parecer independente favorável condicionado recebido e conciliado; **não é autorização de ativação HTTP nem de escrita Q0**.  
**Base (Freshness Gate):** `main` em `56d2cef018c07d3a251c5b1b7af410a8fac1bd35`.  
**Âmbito:** Marco B `OPEN`, Q0 geral `HARD HOLD`, Q1 conectado `HOLD`, E9 `NO-GO`, Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`, Fase 5 `NOT_STARTED`.  
**Fontes:** CP349 e ponteiro de continuidade; Documento 362 (especialmente §5.1); estratégia ChatGPT–Codex–GitHub; AGENTS.md; contrato operacional P2 v2; PRs #44, #45 e #47; relatório `evidence/runtime/codespaces/https-ingress-validation/RELATORIO.md`.

## 1. Decisão aprovada pelo responsável — alcance

Foi aprovado o **desenho experimental condicionado** M3-C para uma jornada privada e supervisionada: login de preparador sintético Django → **uma** submissão Q0 inédita → persistência transacional/recibo → verificação independente D3 → apresentação e consulta posterior por referência, sem nova escrita na consulta.

A aprovação **não autorizou** selecionar `OES_MB_OC1_RELEASE_MODE=PRIVATE_SYNTHETIC_Q0`, iniciar Gunicorn operacional, realizar a submissão, modificar papéis/grants, dados ou recursos, contratar serviços, fazer deploy ou promover qualquer gate. O despacho posterior autorizou **somente** (a) documentação em branch isolada para revisão, **sem merge**, e (b) preflight **READ ONLY** no projeto Neon, branch e banco abaixo. Este documento registra fatos e propostas, não é um novo gate nem uma liberação.

## 2. Ambiente nominal e configuração candidata

- Repositório canônico: `rogerio-raposo/observatorio-evidencias-saude`, SHA acima.
- Codespaces existente; porta 8000 declarada `Private` pelo operador; Gunicorn previsto em `127.0.0.1:8000`, um worker, sem autoexecução.
- Destino PostgreSQL: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf` (`oes-pg-a3-synthetic-20261024`), banco `oes_sandbox`.
- Identidade de aplicação: preparador sintético já criado, autorizado para `evidence.prepare_question`; `default`/`oes_auth_trial_login`, `oes_q0_writer`/`oes_qprep_login`, `oes_synthetic_reader`/`oes_pg_a4_reader`.
- Configuração HTTPS **candidata**, não ativada: `OES_MB_OC1_TLS_TERMINATION=trusted_proxy`; `OES_CODESPACES_USE_X_FORWARDED_HOST=1`; `USE_X_FORWARDED_PORT=False`; `ALLOWED_HOSTS` e `CSRF_TRUSTED_ORIGINS` nominais, sem wildcard; cookies Secure/HttpOnly/SameSite e CSRF nativos preservados.
- Limites definidos no terminal pelo operador (não persistidos em arquivo): conexão 5 s; statement 10.000 ms; lock 2.000 ms; sessão 900 s; Gunicorn 1 worker e timeout 30 s; budget planejado de 3 conexões. **Esses tempos não constituem teto da transação HTTP ponta a ponta.**
- Quatro Codespaces Secrets cadastrados e disponibilizados, conforme confirmação do operador; nenhum valor de segredo é registrado aqui.
- `OES_MB_OC1_RELEASE_MODE` deve permanecer ausente/`HOLD` até eventual autorização operacional específica.

## 3. Evidência reutilizada: fonte e limite

**Histórico integrado:** PR #44 contém cobertura offline HTTPS/Host/CSRF; PR #45 documenta host convencional incompatível no caminho observado e proveniência então inconclusiva; PR #47 implementa liberação experimental **opt-in** e conserva HOLD por padrão. Não reinterpretar os relatos anteriores como homologação operacional.

**Relatos do operador nesta campanha:**
1. Porta 8000 `Private`; três logins PostgreSQL com teste de conexão e transação READ ONLY `PASS`; quatro segredos de Codespaces disponíveis.
2. Capturas do ensaio complementar temporário HTTPS, com cliente autenticado e três casos (`CONTROLE`, `PROTO_CONFLITANTE`, `HOST_CONFLITANTE`): observou-se um valor `https` e um host encaminhado nominal, sem os marcadores conflitantes enviados, em cada resposta correlacionada; coletor encerrado. O ensaio **não** examinou todas as listas/duplicatas nem comprova garantias universais do ingresso gerenciado.
3. Regressão offline selecionada `evidence.test_mb_oc1_offline` e `evidence.test_codespaces_offline`: **31 testes OK**, resultado informado pelo operador; não há registro de reexecução independente nem CI específica neste documento.
4. Preparador sintético com senha utilizável e vínculo/permissionamento verificados em procedimento anterior. Não reproduzir senha ou hash.

**Limite de confiança:** o suporte HTTPS sob valores simples conflitantes favorece a avaliação restrita de `trusted_proxy`/`USE_X_FORWARDED_HOST=True`, mas depende da custódia do loopback, de não haver acesso local não autorizado e de aceitação fundamentada do risco residual. A captura de um teste normal no navegador e o erro 404 posterior não substituem a correlação HTTP; 404 recente permanece inconclusivo.

## 4. Preflight conectado READ ONLY — realizado em 2026-11-18

**Escopo e método:** conexão administrativa via ferramenta Neon com papel `oes_sandbox_owner`, `SET TRANSACTION READ ONLY` no início de cada transação; apenas consultas de catálogo, privilégios, configurações e estatísticas transitórias; sem DML/DDL e sem alterar roles/grants, recursos ou credenciais.

**Configuração observada:**
- PostgreSQL 18.7; `max_connections=112`, `superuser_reserved_connections=4`, `reserved_connections=0`.
- `statement_timeout=0`, `lock_timeout=0` e `transaction_timeout=0` **na sessão administrativa consultada**, `idle_in_transaction_session_timeout=5min`; não inferir daí os valores efetivos da futura sessão Django.
- `pg_stat_activity` indicou **2 conexões ativas** para `oes_sandbox` no instante da consulta, incluindo conexões de observação; não é reserva de capacidade e pode variar.
- Papéis: `oes_auth_trial_login` LOGIN, válido, `rolconnlimit=1`; `oes_pg_a4_reader` LOGIN, `rolconnlimit=2`; `oes_qprep_login` LOGIN, `rolconnlimit=-1` (sem limite próprio declarado). Os três não são SUPERUSER/CREATEROLE/CREATEDB/BYPASSRLS. `rolvaliduntil` nulo para reader e writer indica sem expiração explicitamente configurada, não autenticação garantida para sempre.
- Não foram observadas memberships diretas dos três papéis em `pg_auth_members` no recorte consultado.
- AUTH: `CONNECT`, `USAGE` em `django_auth`, SELECT de `auth_user`, UPDATE de `auth_user.last_login`, e SELECT/INSERT/UPDATE/DELETE em `django_session` presentes.
- Reader: `SELECT` nas cinco tabelas científicas; sem INSERT/UPDATE/DELETE em nível de tabela.
- Writer: `SELECT` e `INSERT` nas mesmas cinco tabelas; sem UPDATE/DELETE em nível de tabela.
- As cinco tabelas têm RLS desabilitada; nenhum FK inválido entre as constraints FK inspecionadas nos schemas `core` e `investigation`.

**Atenção à capacidade:** `max_connections=112` não é capacidade reservada nem elimina `rolconnlimit=1` da Auth. Um worker/uma janela serial supervisionada é a hipótese de operação; conexões concorrentes de Auth, administrador ou sessão paralela podem atingir o limite por papel. O preflight não é teste efetivo de três aliases Django concorrentes, nem mede latência, timeout de rede ou capacidade de restauração.

## 5. Retenção e recuperação — observação administrativa

Consultas administrativas Neon (somente leitura) indicaram:
- Retenção de histórico do projeto: **21.600 s = 6 horas**.
- Snapshots existentes: **nenhum**; agendamento automático de snapshots na branch: **nenhum**.
- Compute da branch: leitura/escrita, `idle`, não desabilitado, mínimo/máximo **0,25 CU**.
- Branch `ready`, não protegida; tamanho lógico observado aproximado **34,8 MB**; limite lógico configurado **1 GiB**.

**Não comprovado:** restauração efetiva do ponto no tempo, RPO/RTO operacional, preservação consistente dos registros preexistentes em uma restauração, custos atuais/limites de franquia, backup alternativo nem tempo de retomada. Uma janela de histórico configurada **não** equivale a capacidade de recuperação já testada.

**Decisão de risco proposta, ainda sujeita a aceite expresso:** aceitar perda somente dos **novos dados sintéticos** da campanha se a tentativa estiver adequadamente classificada; não aceitar perda dos registros preexistentes; nenhum RTO garantido. A inspeção posterior identificou que o PITR e snapshots manuais descritos pelo Neon são direcionados a **branches raiz**, ao passo que a branch experimental é **filha**. Portanto a retenção histórica de seis horas não é um mecanismo de recuperação aplicável automaticamente a ela. Foi autorizada e criada uma **branch de segurança por copy-on-write**, descrita em §5.1. A preservação dessa cópia é distinta de demonstração de restauração; não declarar RPO zero nem RTO garantido. **Se não houver proteção suficiente dos registros preexistentes, STOP antes da escrita.**

### 5.1. Proteção adicional executada — branch de segurança Neon (2026-11-18)

**Ação conectada previamente autorizada, concluída:** criado um clone *copy-on-write* da branch experimental **sem compute**, sem alterações dos registros de origem, sem acesso SQL e sem ativar Django ou Q0. Estado administrativo reconsultado após a criação:

| Campo | Evidência observada |
| --- | --- |
| Projeto / plano | `weathered-boat-65779510` / organização Free |
| Origem | `br-gentle-hall-b6jaxehf` (branch filha de `br-wild-field-b6qg7k3p`) |
| Branch de segurança | `oes-m3c-pretrial-safety-20261118` |
| ID da segurança | `br-silent-dream-b6mvn50u` |
| Estado | `ready` |
| Criação (UTC) | `2026-11-18T05:04:42Z` |
| Ponto de origem informado pelo Neon | `parent_lsn=0/2CF88F0`; `parent_timestamp=2026-11-18T04:46:06Z` |
| Compute / consumo computacional da segurança | 0 endpoints; tempo de compute observado 0 |
| Branches do projeto após criação | 3 (limite Free documentado: 10) |
| Expiração programada | Nenhuma informada na resposta administrativa |

**Qualificação crítica:** `parent_timestamp` e `created_at` são campos diferentes; não presumir que o estado é precisamente o do instante da solicitação ou da criação. A metadata `parent_lsn` documenta o ponto de origem reportado, mas **não constitui restauração testada** nem comprovação de todos os objetos por inspeção SQL. Antes da submissão, comparar a continuidade das alterações na origem e os objetos/catálogos relevantes; se ocorrerem escritas na origem depois do ponto de origem, a cópia não deve ser tratada automaticamente como estado pré-ensaio definitivo. A eventual recuperação usará destino separado e autorização específica; não sobrescrever a origem e não criar compute ou despesa automaticamente.

**Referências externas verificadas em 2026-11-18:** [Instant Restore — root branch](https://neon.com/docs/postgres/backup-restore/branch-restore); [Backup & Restore — manual snapshots em root](https://neon.com/docs/guides/backup-restore); [Branching — copy-on-write](https://neon.com/docs/introduction/branching). A nova branch atende à **preservação administrativa de um ponto independente**, não a uma garantia absoluta de recuperação.

## 6. Parecer independente do Codex e conciliação técnica (2026-11-18)

**Proveniência:** parecer recebido do responsável nesta conversa após execução do Codex fora do Codespaces. O Codex confirmou `main` em `56d2cef…` e branch documental em `6ccc03cd…`, sem modificar arquivos, testar nem acessar Neon/SQL. O texto do parecer integral não foi anexado como arquivo assinado ou artefato verificável do GitHub; registrar sua natureza de **relato do responsável**, sem atribuir-lhe CI ou atestação conectada.

| Tema | Classificação do parecer | Conciliação proporcional |
| --- | --- | --- |
| Recuperabilidade dos registros preexistentes | CONFIRMADO — pendência material | D3 não é backup/restauração. Retenção de seis horas não comprova restauração. A hipótese anterior de PITR da própria branch experimental foi afastada após verificar que ela é filha; snapshot manual direto também não é o caminho documentado. A cópia isolada §5.1 foi criada; confirmar cobertura do ponto, responsável, custódia e recuperação em destino separado. |
| Alegação de que `rolconnlimit=1` inviabiliza os três aliases | NÃO PROCEDENTE | O limite é só de Auth; três logins distintos podem coexistir. Exigir janela serial, um worker, sem consumidores paralelos de Auth, sem ampliar limites ou adicionar pool por precaução abstrata. |
| Garantia geral do ingresso HTTPS | INCONCLUSIVO | Os três casos contraditórios simples favorecem a configuração restrita; não cobrem listas/duplicatas ou autenticação universal do loopback. Cabe custódia local/porta Private, Host/CSRF exatos e aceite delimitado de risco, sem homologação pública. |
| Suficiência integral do preflight P1/P2 | PARCIALMENTE PROCEDENTE | Reaproveitar verificadores e completar **apenas** privilégios por coluna, TRUNCATE, Auth/PreparerIdentity e modos efetivos das sessões relevantes; READ ONLY administrativo não comprova sessão Django gravável. Divergência material => STOP. |
| Alegação de incoerência M3-A/M3-C | NÃO PROCEDENTE | M3-A fornece capacidade por opt-in, M3-C ainda não autorizou selecioná-la. HOLD permanece padrão. |

O parecer é **favorável à submissão de autorização operacional condicionada, não ao início imediato**. Não recomenda nova arquitetura, snapshot obrigatório, novos serviços, auditor paralelo ou repetição genérica de campanhas.

### 6.1. Protocolo de recuperação proposto — condição anterior a qualquer escrita

**Objeto protegido:** tanto os cinco objetos científicos quanto esquema/constraints, Auth, `PreparerIdentity` e vínculos necessários para interpretação e consulta consistente dos registros preexistentes; não confundir recuperação científica com recuperação apenas do recibo da tentativa.

1. **Antes da janela:** responsável nomeia operador, supervisor e administrador para intervenção; identifica formalmente a branch original, a branch de segurança §5.1, banco e estado anterior à nova submissão. Confronta a continuidade dos registros e o **ponto concreto** já informado pelo Neon (`parent_lsn=0/2CF88F0`, `parent_timestamp=2026-11-18T04:46:06Z`) com qualquer mudança posterior da origem; não confundir o timestamp do pai com o instante de criação da cópia.
2. **Disponibilidade:** administrador confirma que a cópia `br-silent-dream-b6mvn50u` permanece `ready`, acessível administrativamente e preserva o escopo necessário; define como criar, caso autorizado, um destino de recuperação privado distinto, com compute apenas se necessário e explicitamente aprovado. Branch de segurança sem compute comprova preservação administrativa, não acesso SQL nem restauração. Não usar como substituto o PITR de branch raiz ou snapshot manual não aplicável à origem filha. Na ausência de evidência suficiente, STOP.
3. **Janela de detecção/intervenção:** a cópia `copy-on-write` não tem a mesma dependência direta da janela de PITR de seis horas, mas é necessário preservar sua existência, integridade e elegibilidade no plano Free até decisão de encerramento; não a excluir automaticamente. Definir tempo máximo de observação, supervisor e acionamento de intervenção, sem prometer RTO.
4. **RPO/RTO e risco:** o responsável deve decidir por escrito quais **novos** dados sintéticos podem ser perdidos e qual exposição residual dos registros **preexistentes** é tolerável diante da capacidade comprovada. Não declarar RPO zero nem RTO garantido. Se a política exigir ausência absoluta de perda preexistente, mas isso não puder ser demonstrado, manter HOLD.
5. **Falha:** cessar novas admissões; preservar IDs, horários, erro sanitizado, evidências e estado observado. Quando necessário, reconciliar a tentativa pelo reader/D3 autorizado, **sem** reenviar escrita. D3 pode provar persistência/integridade da tentativa, mas não recompõe dados destruídos.
6. **Recuperação propriamente dita:** qualquer restauração exige autorização própria e destino privado não produtivo separado, sem substituir/sobrescrever a branch de origem nem presumir custo autorizado. Validar schema, restrições, papéis/ACL, Auth, identidade, recibos, autoria e consistência por referências autorizadas; revisar sessões/flags/senhas restauradas antes de qualquer reabertura. Este termo **não executa nem autoriza restauração**.
7. **Prova de suficiência:** registrar documento ou observação concreta da capacidade de recuperar o ponto relevante, plano de ação e janela operacional viável; decidir se evidência administrativa preexistente basta sem teste restaurativo. Se não houver proteção aceitável, STOP antes da submissão.

A inexistência de snapshots não inviabiliza a **cópia por branching**, mas a existência de seis horas de histórico tampouco confere PITR à branch filha. A proteção atualmente observada é a branch isolada sem compute. Sua criação antecede a M3-C, mas a adequação do ponto original e a capacidade de recuperação para uma aplicação futura ainda exigem decisão operacional informada.

### 6.2. Sequência operacional proposta — não autorizada

A decisão futura será **uma campanha integrada**, não novas aprovações por requisição/SQL. Suas classes de efeito, identidades, manifesto e parâmetros deverão constar expressamente do despacho operacional.

1. **Custódia e preflight:** validar SHA e integridade; porta `Private`; nenhum processo indevido na porta 8000; nenhum acesso ao loopback por outro processo/usuário não autorizado; custódia das três credenciais; Host e CSRF nominais; parâmetros de capacidade/timeout e ausência de despesas ou provisionamento não aprovados; branch de segurança §5.1 `ready`, ponto de origem e ausência de alterações incompatíveis confirmados; recuperação §6.1 fundamentada.
2. **Sessões e privilégios efetivos:** com autorização READ ONLY pertinente e reutilizando os verificadores P1/P2, confirmar catálogos, permissões por coluna e TRUNCATE, consultas Auth/`PreparerIdentity`, falta de privilégio writer indevido, modos efetivos Auth/writer/reader, limites de sessão e papel. Privilegios por tabela demonstrados anteriormente não substituem o recorte por coluna. Não alterar grants ou settings diante de divergência.
3. **Admissão controlada:** operador confirma **uma** janela serial sem ferramentas auxiliares consumindo `oes_auth_trial_login`, workers sobrepostos ou segundo Django; evitar duas sessões Auth concorrentes. Um worker sync e `CONN_MAX_AGE=0` são compatíveis com a proposta, não prova de capacidade medida.
4. **Abertura explícita:** apenas mediante autorização operacional futura, selecionar temporariamente `OES_MB_OC1_RELEASE_MODE=PRIVATE_SYNTHETIC_Q0` e HTTPS candidato, reiniciando o único servidor Gunicorn para aplicação dos settings. Verificar ingresso e autenticação sintética, sem público, dados reais, perfis legados ou bypass.
5. **Tentativa única:** manifesto e UUIDs inéditos previamente definidos; login nativo, permissão/vínculo, POST Q0 único, transação writer com cinco registros e recibo, D3 independente reader e GET posterior por referências autorizadas. Nenhum retry automático ou manual se resultado incerto.
6. **Encerramento normal (ordem crítica):** classificar tentativa e recibo → concluir consulta/reconciliação D3 enquanto o gate permite consulta → preservar prova sanitizada → logout/encerramento de sessão na aplicação e revogações previstas pela via autorizada → somente então retornar `RELEASE_MODE=HOLD` e reiniciar/parar Gunicorn. O HOLD impede também login/logout/consulta; fechá-lo antes da reconciliação pode obstruir a única via prevista.
7. **Emergência:** se risco material exigir interrupção imediata, isolar/parar admissões sem assumir rollback por morte do processo; preservar evidências e executar reconciliação/revogação pelo **canal administrativo previamente aprovado**, sem improvisar segunda via ou reabrir escrita. Se não houver tal canal autorizado, STOP e decisão do supervisor.
8. **Resultado:** registrar sucesso/indeterminação/STOP e limites. Não promover automaticamente Marco B, Q0 geral, Q1, E9 ou Fase 5.

## 7. Condições para futura M3-C conectada — NÃO AUTORIZADA NESTE BLOCO

1. **Revisão independente:** parecer Codex favorável condicionado recebido e conciliado na §6; rastreabilidade integral da evidência HTTPS recente continua limitada a capturas relatadas. Examinar apenas eventual fato material novo, sem repetição automática de testes.
2. Aceite expresso do responsável sobre risco residual HTTPS, capacidade Auth (limite 1), custos, custódia, recuperação, RPO/RTO e tolerância a perda de **novos** dados sintéticos, com decisão separada quanto à proteção dos preexistentes.
3. Preflight final pertinente de sessão **efetiva** Auth/writer/reader, ingressos Django, catálogo/ACL e integridade, sem repetição de inventários extensos; eventuais ações conectadas precisam estar no despacho.
4. Identificadores inéditos, manifesto e conteúdo estritamente sintético aprovados; uma única tentativa, sem retry. Falha ou confirmação de COMMIT desconhecida => STOP, preservar referências e reconciliar apenas pelo reader/D3 autorizado.
5. Eventual autorização operacional **explícita e delimitada**, com sequência de início, login/POST, observação D3, consulta posterior, encerramento/revogação e retorno a HOLD; não usar `runserver` ou ativar perfis legados.
6. Avaliação posterior: resultado técnico da campanha não promove Q0 geral, Q1, E9, Fase 5 nem encerra automaticamente Marco B.

### 7.1. Proposta de despacho operacional integrado — texto preparatório, SEM AUTORIZAÇÃO

Objeto: uma campanha M3-C privada, supervisionada e com dados estritamente sintéticos, na branch `br-gentle-hall-b6jaxehf` e banco `oes_sandbox`; preservar `br-silent-dream-b6mvn50u` como ponto isolado, sem compute.

**Condições suspensivas, anteriores a qualquer POST:** (a) confirmar adequação do ponto da cópia de segurança e proteção dos preexistentes; (b) designar operador/supervisor/admin e aceitar expressamente RPO/RTO e risco residual; (c) confirmar custo zero ou custo explicitamente aprovado; (d) preflight de permissões e transações efetivas apenas das lacunas P1/P2; (e) HTTPS privado/custódia e Auth serial; (f) manifesto sintético, referências únicas e SHA do artefato aprovados. Qualquer falha => STOP e `HOLD`.

**Efeitos que dependerão de aprovação operacional específica:** iniciar Gunicorn privado com `PRIVATE_SYNTHETIC_Q0` e configuração nominal, login Django sintético, **um** POST de escrita Q0, leitura independente D3, recuperação por GET, logout/revogação e retorno ao `HOLD`. Não autoriza SQL DDL/GRANT/REVOKE, exclusão ou restauração de branches, execução de workflows, consumidores adicionais, despesas ou dados reais. Resultado de COMMIT desconhecido => não repetir; preservar referências para reconciliação.

**Depois da campanha:** preservar branch de segurança e registros/recibos até decisão explícita de retenção. Não promover automaticamente qualquer gate. Este texto é minuta e **não é uma concessão antecipada** dos efeitos listados.

### 7.2. Manifesto sintético candidato — preparo documental, sem submissão

**Fonte revisada:** `applications/oes_web/evidence/forms.py` (`Q0RegistrationForm`, `prepare_q0_submission`), `evidence/question_preparation.py` (`QuestionCommand`, `validate_register_q0`, `command_fingerprint`) e `evidence/views.py` (`q0_registration`, `q0_reference`), todos lidos na `main` `56d2cef018c07d3a251c5b1b7af410a8fac1bd35`. A ação conectada não foi executada.

| Campo de formulário | Valor candidato |
| --- | --- |
| `request_id` | `OES-M3C-20261118-R01` |
| `question_id` | `OES-M3C-20261118-Q01` |
| `original_text` | `Em um cenário inteiramente fictício de serviço de saúde, qual é a diferença entre registrar uma pergunta de pesquisa e realizar sua avaliação científica?` |
| `expected_version` (serviço, não formulário) | `0` |
| `normalized_text` (serviço, não formulário) | `None` |
| `justification` (serviço, não formulário) | cadeia vazia `""` |
| Ator | resolvido da `PreparerIdentity` persistida após autenticação; **não** fornecido no formulário |
| `fingerprint` | calcular pelo `command_fingerprint` existente sobre o `QuestionCommand` validado, sem valor manual inventado |

**Condições de aceitação:** (i) IDs inéditos e livres de colisão no banco efetivo e dentro do escopo do ator; (ii) preservação literal do texto original, sem Q1/Q2; (iii) identidade/preparador não administrativa e autorizada; (iv) uma submissão HTTP POST com CSRF nativo, sem duplicatas nem campos adicionais; (v) referência de recuperação `request_id` + `question_id` + `fingerprint` preservada por via sanitizada; (vi) não tentar novamente após resultado incerto.

Os identificadores são **candidatos**, não fatos de disponibilidade. O executor deverá conferir a inexistência dos IDs no preflight permitido, sem escrever para reservá-los. O texto é fictício e não representa evidência de pesquisa nem questão científica publicada. A campanha poderá ajustar o manifesto **antes** de sua autorização operacional, caso exista colisão, sem transformar isso em novas submissões.

**Limite documental:** esta seção não seleciona `PRIVATE_SYNTHETIC_Q0`, não autoriza login HTTP, não grava Q0 e não emite identificadores diretamente no PostgreSQL. A execução depende de despacho operacional explícito e de todas as condições suspensivas §7.1.

## 8. Integridade da publicação

Este documento é uma **proposta de revisão** em branch isolada e não modifica código, testes, workflows, parâmetros, dados ou gates. O resultado do preflight é observacional, restrito ao instante de consulta. **Sem merge**; qualquer integração futura depende de revisão independente, Freshness Gate e autorização expressa.