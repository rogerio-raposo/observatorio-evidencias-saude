# OES — P2: contrato operacional Q0 e aceite integrado

**Versão 1 — 10/11/2026. Base:** `42b08aa35099bfdd984522a3a07ab0f4a3f524b6`, PR #37/P1 incorporado. **Estado: preparação offline; liberação operacional não autorizada.** CP348 vigente; Marco B OPEN; Q0 geral HARD HOLD; Q1 conectado HOLD; E9 NO-GO; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED. HTTP mutante permanece 423, sem retry automático.

Este é o documento operacional principal do recorte Q0. O [manifesto físico versionado](../architecture/oes-q0-physical-contract.json) complementa-o; não é DDL executável ou fotografia do banco. Fontes antigas continuam evidência histórica, não novas autorizações. Não há novo executor, ledger, verificador conectado ou plataforma.

## Referências e Freshness Gate

A `main` remota e a base local coincidiram no SHA acima antes da edição. `STATE.md`, [ponteiro](../../archive/handoffs/oes/README.md), [CP348](../../archive/handoffs/oes/OES_Continuidade_2026-11-08_CP348.md), [Documento 362](362-decisao-simplificacao-proporcional-governanca-tecnica-oes-cp329.md) e [estratégia atualizada](OES_ESTRATEGIA_DESENVOLVIMENTO_CHATGPT_CODEX_GITHUB_2026-11-07.md) foram consultados. PR #37 squash `eaef74ddea3fcb609bd8940e9274d03fdd465d35` integra o P1 e o contraditório pós-COMMIT. Publicação por ChatGPT e autorização conjunta explícita publicação+merge são possíveis; revisão, SHA, CI/proteções e STOP continuam exigidos. Este despacho não concede nenhuma delas.

[Documento 300](300-m2-a7-transicao-piloto-tecnico-funcional.md) e [315/PF-I04](315-pf-i04-contrato-minimo-piloto-funcional-candidato.md) orientam PF-05/06/08/09. Não confundir o último com o [315/PF-I02 de catálogo](315-pf-i02-i01-c-constraints-indexes-readonly.md).

## Contrato físico e fronteira de evidência

O manifesto delimita `core.entity`, `core.entity_version`, `investigation.question`, `investigation.question_version` e `investigation.question_command_receipt`; 39 colunas, quatro PKs UUID simples e uma PK composta `(actor_id,request_id)`, oito FKs de saída, unicidades, índices, CHECKs, trigger/função e funções de sessão relevantes. Cada item cita a fonte declarativa; as observações históricas têm escopo próprio; **nenhum estado atual de catálogo foi atestado no P2**.

A linhagem é S1 histórico → estágio Q0/NULL em normalized_text (Docs.316/317) → recibo (330/331) → responsabilidade (337/338), com catálogo 315/344 e função 333. Essa é a ordem documentada, não exigência de repetir migrações. O [manifesto histórico de migrations](../../database/f4-neon-sandbox-schema-migration-manifest.txt) é referenciado, sem reproduzir suas 36 entradas e sem presumir aplicação integral. `database/poc-s1.sql` sozinho é insuficiente: não contém recibo, responsabilidade ou estágio Q0 e ainda declara normalized_text NOT NULL.

Os cinco modelos de [evidence/models.py](../../applications/oes_web/evidence/models.py) são `managed=False`, com schemas explicitamente citados e `CompositePrimaryKey` real no recibo. UUID fields não declaram FKs compostas ao Django: elas pertencem ao PostgreSQL. `inspectdb`, `makemigrations` e `migrate` não são parte deste pacote ou procedimento futuro. Metadados ORM não comprovam constraints no banco.

PostgreSQL deve garantir PK, unicidade, FKs, nulabilidade, CHECKs, trigger tipado e atomicidade/MVCC. A FK composta de versão certifica par entidade/UUID, **não** a igualdade do `question_id` textual ou do número de versão do recibo. Índice parcial corrente garante no máximo uma versão current, não sua existência. OES continua responsável por autenticação, ator/escopo, comando/fingerprint, Q0 original, versão inicial 1/current/initial, q0_draft, recibo correspondente, locks cooperantes e D3. Não há CHECK declarado para texto Q0 não vazio, hash correto do comando, imutabilidade universal de texto/recibo ou atribuição obrigatória de responsável não NULL a todo INSERT. Serviço, ACL e verificação independente cobrem essas invariantes no caminho aprovado; não se inventaram constraints.

`committed_at DEFAULT CURRENT_TIMESTAMP` registra timestamp transacional de inserção; não mede o instante do COMMIT. A visibilidade íntegra em snapshot independente e a confirmação transacional fundamentam persistência, nunca esse nome de coluna isoladamente. Defaults do banco e `db_default` ORM são fontes distintas; estágio e justificativa são explicitamente fornecidos no INSERT canônico, sem depender do default histórico legacy_complete.

## Identidades, contas e privilégios

### Uma matriz de identidade e finalidade

| Camada/identidade | Vínculo e finalidade | Permitido no recorte | Proibido / condição de custódia |
| --- | --- | --- | --- |
| Usuário Django sintético | Django Auth/ModelBackend e sessão persistida; ativo, is_staff=False, is_superuser=False | Permissão explícita `evidence.prepare_question`, inclusive revalidação em novos requests | Anônimo/inativo/admin/sem permissão negados; force_login não é prova de login operacional |
| Ator OES | `PreparerIdentity.user` OneToOne; actor_uuid UUID4 único e estável em default; `oes:actor:<UUID4>` pelo resolver | Autoria no comando/recibo e responsabilidade atual não NULL iguais ao ator persistido | Nunca identidade do navegador ou str(user.pk) legado; não regenerar vínculo para recuperar tentativa |
| `oes_auth_trial_login` | Login técnico Auth, alias default de A/B | Ler Auth/identidade; em A, ciclo de sessão e atualização last_login | Sem escrita científica, provisionamento, migrations, grants, ownership de runtime ou credencial migradora |
| `oes_qprep_login` | Login técnico writer científico atual; alias oes_q0_writer somente A | USAGE core/investigation; SELECT/INSERT nas cinco tabelas; funções necessárias ao Q0 | Sem UPDATE inclusive por coluna, DELETE/TRUNCATE; sem funções/atributos administrativos que ampliem o alcance |
| `oes_pg_a4_reader` | Login do leitor independente; oes_synthetic_reader em A/B | USAGE/SELECT nas cinco tabelas, sessão READ ONLY e snapshot primário consistente | Sem INSERT/UPDATE inclusive por coluna, DELETE/TRUNCATE, writer secret ou função que autorize mutação |
| `oes_qprep_writer` | Papel NOLOGIN histórico W2a, diferente de oes_qprep_login | História: SELECT/INSERT nas cinco e UPDATE(version_status,valid_to) em entity_version | Não é login atual, autorização geral ou fonte presumida de membership; essa ACL efetiva seria rejeitada pelo P1 se herdada pelo login Q0 |
| `oes_auth_migrator` / `oes_sandbox_owner` | Autoridades administrativas históricas, fora de A/B | Eventual provisionamento/revogação/recuperação somente em procedimento próprio autorizado | Nunca fallback, segredo, alias ou credencial de runtime; não renovar/usar neste pacote |

A [política antiga 334](334-pf-i02-politica-leitura-writer-minimo.md), [W2a/335](335-pf-i02-w2a-encerramento-tecnico-restrito.md), [G1/344](344-pf-i02-p2-g1-resultado-catalogo-readonly.md) e [356](356-pf-i02-p2-g2-p2a-resultado-identidade-read-only.md) registram o NOLOGIN e os dois UPDATEs de coluna para Q1 experimental. O registro owner→writer com ADMIN TRUE/INHERIT FALSE/SET FALSE não prova writer→owner nem vínculo do login atual. [CP340](../../archive/handoffs/oes/OES_Continuidade_2026-10-29_CP340.md) descreve depois oes_qprep_login com SELECT/INSERT e sem UPDATE/DELETE; não declara auditoria exaustiva atual de privilégios por coluna.

**Divergência real de escopo/momento:** política Q1 histórica com UPDATE por coluna versus Q0 P1 sem UPDATE. Não é defeito do P1. Antes de qualquer execução, verificar direitos efetivos, PUBLIC, memberships, owners, atributos, funções e grants por coluna do login realmente usado. Se houver UPDATE herdado, **STOP**, sem REVOKE automático, sem trocar login por NOLOGIN, sem alterar o checker para aceitar Q1. A solução administrativa pertence ao responsável e ao administrador autorizado.

### Mesma política verificável do P1

Os booleanos abaixo são exatamente as cinco observações por tabela de `_review_q0_privileges`: SELECT, INSERT, qualquer UPDATE/DELETE/TRUNCATE de tabela, qualquer INSERT de coluna e qualquer UPDATE de coluna. `has_any_column_privilege` também reflete direitos de tabela; true para coluna INSERT no writer não significa concessão isolada nova.

<!-- q0-acl-matrix -->
| Alias | Login | SELECT | INSERT | UPDATE/DELETE/TRUNCATE tabela | INSERT qualquer coluna | UPDATE qualquer coluna |
| --- | --- | --- | --- | --- | --- | --- |
| oes_q0_writer | oes_qprep_login | true | true | false | true | false |
| oes_synthetic_reader | oes_pg_a4_reader | true | false | false | false | false |
<!-- /q0-acl-matrix -->

Aplica-se às cinco tabelas do manifesto, mais USAGE em core/investigation. Não é auditor exaustivo de todo o banco: não comprova ausência de CREATE, atributos administrativos, funções com efeitos laterais, RLS ou memberships em outras famílias. O preflight integrado futuro trata somente as lacunas pertinentes. EXECUTE PUBLIC em `core.assert_entity_type` foi observado no [333](333-pf-i02-trigger-function-readonly-review.md), SECURITY INVOKER, sem SQL dinâmico e com core.entity qualificada; não é, isoladamente, prova de elevação nem motivo para REVOKE indiscriminado. CONNECT por PUBLIC também não é automaticamente incidente.

### Auth: direitos de runtime e limites de leitura

A [arquitetura Auth](oes-auth-single-database-architecture-2026-10-28.md), seções AUTH_RUNTIME_G1_MINIMAL_GRANTS e G2-P1, registra: USAGE sem CREATE em django_auth; SELECT em auth_user, auth_group, auth_permission, django_content_type, auth_user_groups, auth_user_user_permissions, auth_group_permissions, preparer_identity_prepareridentity e django_session; UPDATE somente auth_user.last_login; SELECT/INSERT/UPDATE/DELETE em django_session; nenhum direito em django_migrations ou sequências. A autenticação nativa atualiza last_login e sessões: não conceder UPDATE geral ou criação de usuário ao runtime para fazê-la funcionar. Estado atual, limite de conexões e validade de login/senha continuam não confirmados.

Provisionamento, senha sintética utilizável, criação de vínculo/permissão, desativação e revogação pertencem ao administrador autorizado. [CP342](../../archive/handoffs/oes/OES_Continuidade_2026-10-29_CP342.md) comprova historicamente cadastro único com senha **inutilizável**, não um login operacional pronto. Não repetir esse provisionamento, reutilizar o manifesto CP348, inventar contas reais ou presumir validade de senhas com base em registros antigos. Reutilizar identidades sintéticas aprovadas quando possível; segunda conta de controle não é requisito automático de infraestrutura ([315/PF-I04](315-pf-i04-contrato-minimo-piloto-funcional-candidato.md)). Multiusuário e prova de isolamento real por linha continuam fora do escopo sem decisão própria.

## Perfis privados, ingresso e sessões

### Matriz de aliases preparada

<!-- q0-profile-matrix -->
| Perfil | Alias | Login | Modo de sessão preparado |
| --- | --- | --- | --- |
| A | default | oes_auth_trial_login | AUTH_RW |
| A | oes_q0_writer | oes_qprep_login | Q0_RW |
| A | oes_synthetic_reader | oes_pg_a4_reader | READ_ONLY |
| B | default | oes_auth_trial_login | READ_ONLY |
| B | oes_synthetic_reader | oes_pg_a4_reader | READ_ONLY |
<!-- /q0-profile-matrix -->

AUTH_RW e Q0_RW identificam o modo requerido para as operações de A, não uma observação do servidor. A ausência da opção READ ONLY no perfil A não força read-write contra um default de role/banco; o preflight futuro deve confirmar o modo efetivo também no Auth de A. Se for incompatível, STOP, sem alterar settings do servidor ou relaxar validadores neste pacote.

A usa `config.settings_mb_oc1`, login/logout oficiais e registro Q0; B usa `config.settings_mb_oc1_reader`, somente GET `/questions/q0/review/`. B não possui login/logout, rota de registro, alias oes_q0_writer ou senha writer, inclusive herdada de ambiente/arquivos de A. Ambos incluem o leitor D3, que não é o writer reutilizado. Perfis antigos opt-in não devem ser misturados; settings padrão continuam demonstrativos/fechados.

`config/mb_oc1.py` fixa banco oes_sandbox, endpoint direto `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`, porta 5432 e logins acima, com credenciais distintas por identidade em cada perfil, CONN_MAX_AGE=0 e ATOMIC_REQUESTS=False. A referência documental do destino é projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`; IDs reais de projeto/branch não são dedutíveis só pelo hostname e devem ser verificados futuramente pelo responsável. Não usar pooler, réplica ou banco arbitrário por conveniência. O profile validator não abre sessão nem concede autorização.

A e B devem ser processos privados separados, no mesmo artefato/SHA revisado e auth-store, compartilhando somente o necessário à sessão: SECRET_KEY protegida, backend Auth, cookie/nome/path e mesma origem. B não pode ler ambiente, mounts, arquivos ou `/proc` de A; processo separado no mesmo usuário não comprova essa segregação. Selecionar recurso existente aprovado e servidor WSGI apropriado, sem runserver operacional ou plataforma nova. Não há implantação configurada ou contratada por este P2.

Ingresso HTTPS único: `/accounts/login/`, `/accounts/logout/`, `/questions/q0/register/` → A; `/questions/q0/review/` → B. Portas internas inacessíveis ao cliente; origem/host/CSRF exatos, sem wildcard. DEBUG=False; SECRET_KEY externa com tamanho/padrão validados e sem fallback; cookies Secure/HttpOnly/SameSite=Lax; frame deny/no-sniff, sem cache de resultados privados. Não colocar senha, token ou URL autenticada em chat, arquivo versionado, log ou teste operacional. Os testes usam exclusivamente valores sintéticos.

`OES_MB_OC1_TLS_TERMINATION=wsgi` exige que o servidor informe esquema HTTPS confiável e não confia em cabeçalho encaminhado. `trusted_proxy` prepara SECURE_PROXY_SSL_HEADER=(HTTP_X_FORWARDED_PROTO,https): **não autentica o proxy**. O ingresso deve remover cabeçalhos do cliente, sobrescrevê-los e impedir conexão direta que os forje. Sem essa topologia comprovada, STOP. TLS PostgreSQL `sslmode=require` exige criptografia, não equivale a verify-full; uma exigência adicional de validação de certificado/hostname requer revisão de configuração/validadores, sem afirmar que já existe.

### Sessões A→B e revogação

A usa sessões DB Django e CSRF nos POSTs de login/logout. B usa `config.readonly_sessions.SessionStore` e middleware próprio: lê a sessão, nega save/create/delete/cycle_key e métodos assíncronos, descarta flush inválido em memória, sem DELETE; alteração de sessão não vazia ou tentativa de persistência retorna 503. SESSION_SAVE_EVERY_REQUEST=False, CSRF_USE_SESSIONS=False; B não renova expiração. Cookie pode ser removido em resposta sem DML. A validação de usuário, permissão e vínculo é refeita em novos requests; revogação não cancela magicamente uma transação já em voo.

**Limite material explícito:** B não tem writer **científico**, mas compartilha com A o login Auth que historicamente possui DML em django_session e UPDATE(last_login). Sua sessão READ ONLY e o backend sem DML não tornam esse papel permanentemente SELECT-only: `default_transaction_read_only` não é fronteira de privilégio contra código/credencial comprometidos. O risco deve ser aceito ou resolvido por decisão administrativa antes da operação. Exigir separação de credencial Auth estritamente SELECT-only em B implicaria identidade/configuração/ACL distintas e autorização futura; não foi simulada como garantia, introduzida neste P2 ou contornada com defaults.

Consultar só referências request_id/question_id/fingerprint, sempre resolvendo ator da sessão e reconstruindo o comando de registros autorizados. A entrada B não recebe o texto original nem aceita recibo/finalização fornecidos pelo navegador. A recuperação usa exclusivamente o leitor autorizado; não constrói repositório writer nem repete submissão. SELECT amplo na credencial técnica não prova RLS/isolamento no banco; filtros por ator são obrigação aplicacional. Uso público, dados sensíveis ou expansão multiusuário exigem reavaliação; não se introduziu RLS ou uma API SQL nova apenas para o piloto sintético privado.

No encerramento autorizado, logout em A remove sua sessão; desativar usuário/retirar permissão ou invalidar senha/sessões por procedimento administrativo preserva o vínculo histórico. B nega acesso em novo request e não apaga sessões. Apagar secret/variável, expirar senha PostgreSQL, revogar privilégios, desativar usuário e encerrar sessões são ações diferentes; nenhuma substitui as demais ou é executada automaticamente aqui.

## Limites, capacidade e orçamento de execução

Parâmetros obrigatórios explícitos de `config/q0_limits.py`, sem valores operacionais escolhidos:

| Configuração | Unidade/condição | Decisor e prova necessária |
| --- | --- | --- |
| OES_MB_OC1_CONNECT_TIMEOUT_SECONDS | inteiro positivo, até 2147483647 | Responsável + administrador: orçamento de estabelecimento; conferir valor enviado e efeito no cliente/endpoint |
| OES_MB_OC1_STATEMENT_TIMEOUT_MS | inteiro positivo, até 2147483647 | Responsável + administrador: limite por statement; conferir current_setting e cancelamento controlado se realmente necessário |
| OES_MB_OC1_LOCK_TIMEOUT_MS | inteiro positivo e menor que statement_timeout | Responsável + administrador: limite por espera por lock; provar contenda dentro do escopo autorizado |
| OES_MB_OC1_SESSION_SECONDS | duração explícita positiva | Responsável: janela/custódia e expiração, compatível com recuperação/revogação |
| Workers A/B, limite HTTP e fila de ingresso | Sem defaults operacionais neste contrato | Operador: capacidade privada aprovada e monitoramento, custos e folga para encerramento/D3 |

O restante da configuração exigida permanece no builder existente: OES_MB_OC1_SECRET_KEY, HOST, ORIGIN, TLS_TERMINATION, PG_HOST, AUTH_PASSWORD, READER_PASSWORD e WRITER_PASSWORD somente A. Valores reais não foram decididos, cadastrados nem lidos. Perfil B rejeita inclusive nomes/capacidades writer herdadas, DATABASE_URL/PGPASSWORD e variantes vedadas pelo validador. Não adicionar variável “enabled” como autorização.

`connect_timeout` é por estabelecimento de conexão; `statement_timeout` é por statement; `lock_timeout` é por espera de lock. **Nenhum deles é teto global da transação ou da requisição HTTP.** Autenticação, preflight, locks, cinco INSERTs, encerramento e D3 somam múltiplas operações e sessões. Definir orçamento H que comporte essas etapas, filas e margem de reconciliação; H menor que a soma possível pode perder a resposta após commit. Fechar HTTP/socket ou matar worker não prova rollback no servidor.

O operador deve dimensionar processos/concorrência contra capacidade aprovada do PostgreSQL e consumo por outros clientes. Como teto conservador inicial de planejamento, considerar até três aliases por worker A e dois por worker B, mais reserva administrativa aprovada; não é medição de conexões simultâneas. CONN_MAX_AGE=0 evita persistência entre requests, não limita trabalhadores ou clientes. Conferir ROLE CONNECTION LIMIT/max_connections, limites da plataforma e disponibilidade sem supor o valor 1 de ensaios antigos compatível com A/B simultâneos. Nenhum pool/serviço adicional foi criado.

Inspecionar limites efetivos de sessão/role/banco/servidor e precedência de opções, mais idle_in_transaction_session_timeout e, se suportado, transaction_timeout. Só documentar valores/efeitos observados; P1 não configura os dois últimos. Timeouts de ingresso, processo e rede podem antecipar os do banco; cancelamento de statement/lock no corpo só é rollback conhecido quando houver evidência transacional suficiente. Cancelamento/erro na confirmação não permite presumir ausência. Perfis legados aceitos pelos validadores não passam automaticamente a ter limites finitos.

## Falhas, recibos, apresentação e recuperação

Preservado o percurso `register_authenticated_q0 → D1 → OfflineQuestionUnitOfWork → DjangoQ0Repository → D3`. Pré-validação de usuário/ator/comando e configuração; preflight de sessões, identidade e ACL; atomic writer independente; captura de xid e binding de comando/fingerprint/ator/conexão/bloco/trace antes do primeiro INSERT; lock de request precede lock da questão. Mantêm-se os cinco registros, recibo, atomicidade e idempotência por ator/request/fingerprint. Locks consultivos serializam somente participantes cooperantes. Transferência/revogação do responsável teria de seguir a mesma chave/ordem; não existe autorização para implementá-la ou atualizá-la manualmente neste procedimento.

O P1 consolidou ACL/xid e lock repetido; não reabrir a otimização. Seu primeiro callback on_commit marca confirmação antes de callbacks posteriores: erro de callback pós-commit não é rejeição do COMMIT. SQLSTATE/diagnóstico estruturado e estado transacional distinguem rollback conhecido de confirmação perdida; não interpretar todo IntegrityError como commit incerto, nem SQLSTATE/IDLE isoladamente como confirmação de rollback.

| Resultado/situação | Contrato externo Q0 preparado | Conduta obrigatória |
| --- | --- | --- |
| Entrada inválida | 400, campos preservados | Sem escrita, sem IDs novos silenciosos |
| Anônimo/inativo/admin/sem permissão | 403 | Não revelar dados de outro responsável |
| Operação bloqueada por fonte | 423 antes de formulário/backend | Não procurar executor histórico ou bypass |
| Conflito próprio comprovado antes de INSERT | 409 | Preservar IDs, sem sobrescrever/gerar novo request para contornar |
| Colisão global fora do escopo | 503 sanitizado, sem ampliar 409 | Não revelar proprietário, conteúdo ou existência alheia; política definitiva de namespace é decisão pendente |
| Falha pré-transação | 503 e evidência THIS_ATTEMPT quando disponível | Não prova inexistência de tentativa/recibo anterior |
| Falha determinística/body ou rejeição do COMMIT com rollback confirmado | 503; tentativa ROLLED_BACK | Não converter em incerteza artificial; não autoriza retry |
| Confirmação perdida/transporte ou finalização não demonstrada | 503; tentativa UNKNOWN | STOP novas escritas; preservar IDs e reconciliar somente por leitura autorizada |
| Commit confirmado, readback/callback posterior falha | 503; falha pós-commit | Exceção não vira sucesso mesmo com observação positiva anexa |
| Conclusão normal + D3 íntegro, inclusive replay | 200, persistência comprovada | Replay não significa que esta tentativa criou os registros |
| Consulta independente íntegra por referência | 200, PERSISTED/Q0_RECORDS | Sem reenvio do texto, submissão ou writer |
| ABSENT ou INDETERMINATE na consulta | 503 com escopo/limitação | Ausência não autoriza repetição; evidência insuficiente não vira ausência |

Login/logout seguem respostas nativas Django (por exemplo formulário inválido 200 e redirecionamento após sucesso); não confundir esse HTTP 200 com persistência Q0. CSRF inválido é 403. Q1/Q2 mutantes permanecem 423 e suas propostas offline não abrem Investigation/E9.

`q0_failure` descreve a **tentativa**, `q0_observation` os **registros observados**. Recibo anterior íntegro pode ser PERSISTED com `receipt_association=EXISTING_OR_UNATTRIBUTED` enquanto xid atual continua in progress/UNKNOWN; isso não finaliza a tentativa ou promove exceção a sucesso. Candidato atual em andamento, UUID/fingerprint incompatível, rollback do mesmo candidato, status contraditório ou snapshot inválido permanecem INDETERMINATE. D3 usa snapshot primário REPEATABLE READ READ ONLY para recibo e cinco registros. Prova positiva íntegra não depende universalmente de pg_xact_status; ABSENT/Q0_RECORDS exige evidência de finalização/aborto e ausência consistente de resíduos. Após perda de trace, recibo ausente geralmente continua INDETERMINATE; não aceitar flags do cliente como prova.

Preservar PreparationHold, PreparationConflict e PREPARATORY_ONLY. Uma resposta PREPARATORY_ONLY isolada não é comprovante de commit. Manter mensagens estáticas de `forms.py`, classes sanitizadas de `q0_failure` e códigos de atestação existentes, sem incluir textos do driver/SQL, credenciais, hashes de senha ou tokens de sessão. Requisição/questão/fingerprint/xid podem ser correlacionados no registro autorizado mínimo, com acesso e retenção limitados; não são autorização nem ledger. O log P1 OES_Q0_TX ocorre antes do commit e não prova seu sucesso. Redigir access logs sem query string de referência, POST/body/SQL/segredos, bloquear logs DEBUG e definir custódia. Respostas genéricas não eliminam inferência de ocupação do namespace; responsável decide a política definitiva sem alterar IDs nesta entrega.

## Backup, restauração, incidentes e encerramento

Responsável decide RPO, RTO, retenção, dados sintéticos que podem ser perdidos, orçamento/custos e se evidência prévia de restauração é suficiente. Administrador demonstra capacidade do recurso já aprovado, sem presumir PITR/free tier/retention/restore testados. Se backup/restauração aceitáveis não estiverem comprovados, não abrir escrita operacional. Backup deve abranger catálogo relevante, cinco tabelas, auth-store/PreparerIdentity e vínculos, com consistência entre schemas, proteção e custódia; não registrar material secreto no relatório. Slots/versionamento de schema, ACLs e credenciais externas precisam de plano próprio, não se presumem recuperados por dump de dados.

Restauração futura somente em destino privado não produtivo expressamente aprovado, sem substituir banco existente e sem assumir novos custos autorizados. Manter gates/ingresso fechados; conferir schema/constraints/ACL, identidade/recibos/fingerprint e integridade D3 com referências autorizadas. Preservar UUIDs, texto e autoria; não criar novos atores ou requests para “recompor” persistência. Sessões, senhas/flags e revogações restauradas podem ficar obsoletas: validar e invalidar sessões/revogações por procedimento administrativo aprovado antes de reabrir. Medir RPO/RTO e registrar resultado; sem inferir sucesso de restauração a partir de mock ou disponibilidade declarada do provedor.

Em incidente: operador bloqueia novas admissões de escrita e preserva evidências; supervisor decide isolamento/canal de reconciliação. Não apagar recibos, rodar DELETE compensatório ou repetir comandos. Terminar processo/conexão não prova finalização no servidor. Fechar o gate central bloqueia também login/logout/consulta: concluir leitura/revogação pela via previamente autorizada antes de fechar tudo, ou, em emergência, isolar imediatamente e usar canal administrativo autorizado; não improvisar executor alternativo.

Encerrar por decisão do supervisor: resultado e limitações registrados; sessões/contas temporárias revogadas conforme escopo, processos parados/liberação fechada e projeções temporárias removidas com confirmação. Credenciais compartilhadas não são rotacionadas/revogadas sem autoridade específica. Dados sintéticos e recibos ficam preservados até decisão de retenção; CP348 não é repetido e seus registros não são cleanup automático.

## Aceite integrado

Esta é uma **matriz única**, não novos microgates. E=inspeção estática; O=teste offline; H=evidência histórica conectada registrada; C=prova conectada futura, ainda não executada. Estado O/H nunca é promovido automaticamente a C.

| Critério | E/O reutilizáveis | H pertinente e limite | C/aceite objetivo ainda pendente | STOP e responsável |
| --- | --- | --- | --- | --- |
| Schema e modelos | Manifesto vs managed=False/PK/campos; mapping/compilação ORM; fontes de CHECK/FK | Docs.317/331/338/344; CP336: 8 FKs/1 trigger no inventário, sem atestar catálogo atual completo | Administrador compara tipos, NULL/defaults, PK/unique/indexes/FKs/CHECK/trigger/owners/RLS por definição, sem consultar conteúdo; equivalências não dependem de nomes não registrados | Divergência material, constraint desabilitada/não validada ou função inesperada: STOP; não executar migrations |
| Identidades/ACL | Matriz vs verificador único P1, concessões por coluna; preparer auth e vínculo offline | 335/344: NOLOGIN histórico; CP340: login atual/leitor; Auth G2-P1: ACLs de Auth | Identidades/sessões reais, memberships/atributos, PUBLIC/funções, USAGE/SELECT/INSERT/negativas por tabela/coluna e isolamento científico/Auth | UPDATE legado efetivo, privilégio inexplicado, owner/migrator em runtime ou login vencido: STOP; administrador/responsável decidem, sem GRANT/REVOKE improvisado |
| Perfil privado/PF-08 | A/B builder/validador, limite explícito, defaults fechados | Não há prova histórica de implantação A/B privada | Operador demonstra origem/TLS/proxy/rotas, artefato idêntico, ambiente/mounts segregados e B sem writer; responsável aceita limite Auth compartilhado e custo | Host, proxy, capacidade, segredo/custódia ou decisão ausentes: STOP |
| Auth e sessão/PF-05 | Login por senha/CSRF, permissão, vínculo, A→B sem DML, expiração/revogação SQLite | CP342 cadastro/senha inutilizável e READ ONLY; não é login operacional por senha | Jornada supervisionada com preparador sintético aprovado, sessão A usada em B, revogação negada em novo request sem DML em B; observar direitos last_login/sessões | Sem conta/vínculo/senha autorizados, sessão alterada, acesso cruzado ou necessidade de elevar privilégio: STOP; administrador/operador |
| Limites/capacidade | q0_limits e validadores compatíveis; P1 negativos | Timeouts curtos de migrações antigas não são valores operacionais | Decidir C/S/L/H/workers e verificar limites efetivos de cliente/sessão/role/servidor/ingresso; contenda/cancelamento só se houver hipótese nova não coberta | Sem orçamento ou espera além dele: parar admissões, não presumir rollback; operador/admin |
| Transação/concorrência/PF-06 | UoW/D1/ORM, locks request→questão, P1 falhas/COMMIT/callbacks e agenda simulada | CP346 #42399992047 rollback-only; CP348 #42491887254 primeiro Q0 canônico restrito, sem prova universal de concorrência | Se necessária para o escopo, agenda aprovada de sessões PostgreSQL concorrentes, mesmas referências e invariantes, no máximo um efeito; falha entre INSERTs/commit só em fixture sintética aprovada | Sem controle cooperante, resultado incerto, partial writes ou risco à autoria: STOP; sem retry/transferência administrativa livre; responsável + administrador |
| Recibo/D3/recuperação | snapshot/contradições/recibo anterior/ausência e consulta por referência; sem writer | CP348 D3 embutido positivo; job de recuperação independente SKIPPED, sem auditoria posterior adicional | Ler por B referência própria sem reenvio; confirmar recibo+cinco registros e original; perda de trace/recibo ausente deve permanecer INDETERMINATE se não houver prova de ausência | Leitor indisponível/inconsistente ou contradição: STOP, registrar escopo/IDs; supervisor, sem segunda escrita |
| Backup/restauração/PF-09 | Plano, custódia e roteiro deste documento | Nenhum restore real comprovado pelas fontes deste recorte | Responsável aceita RPO/RTO e administrador apresenta evidência aplicável ou restaura em alvo autorizado e valida schema/atores/recibos/D3/sessões | Sem recuperação aceitável ou restauração inconclusiva: não abrir operação; sem serviço pago/novo destino implícito |
| Gates e encerramento | Source HOLD, HTTP 423, históricos fechados e no retry nas suítes atuais | CP348/STATE mantêm limites; P1 CI offline não é liberação | Aprovação separada de código de liberação e unidade operacional nominal; verificar revogação e fechamento ao terminar | Nenhuma aprovação científica, de Q1/Q2, E9, Fase 5 ou pública; responsável/supervisor |

Históricos adicionais reutilizáveis: [CP340](../../archive/handoffs/oes/OES_Continuidade_2026-10-29_CP340.md) leitor #40877254997; [CP346](../../archive/handoffs/oes/OES_Continuidade_2026-11-07_CP346.md) auth-only #42399226510 e rollback-only #42399992047; [CP347](../../archive/handoffs/oes/OES_Continuidade_2026-11-08_CP347.md) atestação #42483719306; [CP348](../../archive/handoffs/oes/OES_Continuidade_2026-11-08_CP348.md) commit #42491887254. Referências e limites documentados foram reutilizados, sem novo download/auditoria de logs ou despacho. Não repetir campanhas P4/A41, cadastro CP342 ou tentativa CP348 como requisito ritual de aceite.

### Um único procedimento futuro integrado, sujeito a autorização

1. **Termo único:** responsável nomeia operador/supervisor/admin, destino privado já aprovado, artefato/SHA, janela, preparador/manifesto sintético **novo** delimitado, limites/capacidade, custos, retenção e RPO/RTO. Registrar quais evidências H são suficientes e quais lacunas C realmente precisam de execução. Supervisão pode acumular funções se aceita explicitamente. Sem decisões, manter HOLD.
2. **Preparação revisada:** código de liberação por fonte e configuração operacional devem ser aprovados separadamente do P2 offline. O menor ponto existente é `_require_release` em config/mb_oc1.py, que protege A/B, login/logout, emissão de escopo e recuperação; não basta uma variável. Preservar construtor geral/execute_connected_q0 HOLD e CP348 retirado. Nenhuma alteração de fonte foi feita aqui.
3. **Antes de novas escritas:** com autorização READ ONLY explícita do alvo/classes de consulta, conferir a matriz C pertinente de catálogo, sessões/ACL, Auth, TLS/ingresso, capacidade, backup e logs. Usar mecanismos existentes quando suficientes; leitura catalogal complementar escopada não constitui novo auditor. Falha STOP sem correção administrativa implícita.
4. **Jornada supervisionada:** somente se autorizada, login nativo A, identificação persistida/permissão, submissão Q0 sintética delimitada com IDs/texto preservados, preflight/atomic/xid/cinco INSERTs/recibo/D3, apresentação conservadora e consulta independente B por referência. Não usar CP348, seu CLI ou sua dispensa administrativa como autorização geral.
5. **Hipóteses adicionais necessárias:** concorrência real, cancelamentos ou restauração entram como partes expressas da mesma campanha, com fixtures/referências e efeitos previamente descritos. Não confundir retransmissão deliberada para testar idempotência, se expressamente autorizada após resultado conhecido, com retry automático após falha. O padrão é uma submissão supervisionada; resultado incerto bloqueia nova escrita. Se essas provas não forem necessárias à primeira unidade, registrar limitações em vez de criar ensaio isolado.
6. **Recuperação e fim:** em qualquer exceção, preservar referências e ler somente na via aprovada; ABSENT/INDETERMINATE não rearmam escrita. Concluir revogação, verificação posterior e fechamento conforme seção anterior. Resultado aceito inclui limites: êxito Q0 técnico não encerra Marco B nem promove avaliação científica.

O responsável pode aprovar um procedimento operacional integrado proporcional, sem gate por query ou teste. Isso não permite extrapolar leitura para escrita, DDL/grants, deploy/custos ou recuperação em outro destino: cada classe de efeito deve constar explicitamente do termo autorizado; caso contrário, STOP na parte afetada, sem criar mecanismo paralelo.

## Decisões pendentes e proporcionalidade

| Decisão reservada | Responsável pela decisão / evidência | Consequência até decidir |
| --- | --- | --- |
| Destino privado, ingresso e confiança em proxy; limite/custo de recursos | Responsável e operador | Não implantar ou abrir acesso |
| Valores C/S/L/H, workers, conexões e duração de sessão | Responsável, operador e administrador | Configuração operacional permanece incompleta |
| Contas sintéticas, senha utilizável, custódia e revogação | Responsável/admin | Não presumir cadastro histórico operacional |
| ACL atual e divergência com UPDATE por coluna legado; risco do Auth compartilhado em B | Responsável/admin, catálogo futuro | Não relaxar P1, conceder privilégio ou afirmar B como papel Auth imutável |
| Política definitiva de identificadores globais e confidencialidade | Responsável | Manter IDs, política 409/503 e sanitização; reconhecer inferência residual |
| RPO/RTO, backup/restauração, retenção e risco aceitável | Responsável/admin/supervisor | Sem aceite operacional PF-09 |
| Fonte de liberação e escopo da campanha conectada | Responsável, com revisão técnica independente | Gates fechados; nenhum efeito conectado autorizado |

Pelo Contraditório Técnico Fundamentado, não são necessários neste P2: novo framework de identidade, consumo durável de autorização, outro repository/UoW, sexta tabela, RLS indiscriminada, segundo usuário real, novo pool, REVOKE automático ou repetição integral de provas antigas. Não se comprovaria isolamento/capacidade real acrescentando mocks ou executores. Tampouco se deve invalidar prova positiva de recibo anterior só porque outra tentativa está em andamento: P1 já preserva a distinção. São decisões fundamentadas de escopo, não relaxamento de gates.

**Aceite offline do P2:** manifesto rastreado e coerente com modelos, matriz alinhada ao verificador existente, perfis/limites documentados sem defaults reais, regressões proporcionais PASS, lacunas C e STOP/responsáveis explícitos, núcleo P1/gates intactos. Essas condições encerram o programa offline para revisão integrada. Pendências administrativas/conectadas não são defeitos offline a resolver por novos microincrementos; mudança material demonstrada é que justificaria correção adicional.
