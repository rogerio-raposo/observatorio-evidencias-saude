# OES — M3-C | Decisão de desenho, evidências e preflight READ ONLY

**Data:** 2026-11-18 (America/Recife)  
**Estado:** PREPARATÓRIO; revisão independente pendente; **não é autorização de ativação HTTP nem de escrita Q0**.  
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

**Decisão de risco proposta, ainda sujeita a aceite expresso:** aceitar perda somente dos **novos dados sintéticos** da campanha se a tentativa estiver adequadamente classificada; não aceitar perda dos registros preexistentes; nenhum RTO garantido; priorizar reutilização de recuperação existente sem criar snapshots, modificar retenção, restaurar ou comprar recursos automaticamente. **Se não houver evidência suficiente de proteção dos registros preexistentes, STOP antes da escrita.** RPO não pode ser apresentado como zero garantido para registros anteriores sem prova.

## 6. Condições para futura M3-C conectada — NÃO AUTORIZADA NESTE BLOCO

1. **Revisão independente** deste relatório, da evidência HTTPS e do SHA; registrar diferenças entre observação de operador, leitura conectada e garantia ainda ausente.
2. Aceite expresso do responsável sobre risco residual HTTPS, capacidade Auth (limite 1), custos, custódia, recuperação, RPO/RTO e tolerância a perda de **novos** dados sintéticos, com decisão separada quanto à proteção dos preexistentes.
3. Preflight final pertinente de sessão **efetiva** Auth/writer/reader, ingressos Django, catálogo/ACL e integridade, sem repetição de inventários extensos; eventuais ações conectadas precisam estar no despacho.
4. Identificadores inéditos, manifesto e conteúdo estritamente sintético aprovados; uma única tentativa, sem retry. Falha ou confirmação de COMMIT desconhecida => STOP, preservar referências e reconciliar apenas pelo reader/D3 autorizado.
5. Eventual autorização operacional **explícita e delimitada**, com sequência de início, login/POST, observação D3, consulta posterior, encerramento/revogação e retorno a HOLD; não usar `runserver` ou ativar perfis legados.
6. Avaliação posterior: resultado técnico da campanha não promove Q0 geral, Q1, E9, Fase 5 nem encerra automaticamente Marco B.

## 7. Integridade da publicação

Este documento é uma **proposta de revisão** em branch isolada e não modifica código, testes, workflows, parâmetros, dados ou gates. O resultado do preflight é observacional, restrito ao instante de consulta. **Sem merge**; qualquer integração futura depende de revisão independente, Freshness Gate e autorização expressa.