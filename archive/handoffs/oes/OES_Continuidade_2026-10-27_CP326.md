# OES — CP326 | PF-I04/P4-A31–A34 — GitHub Actions offline validado; mutações bloqueadas

**Data de referência:** 2026-10-27, America/Recife. **Anterior:** CP325. **Freshness Gate:** `main` idêntica a `3870cf499f82008200c6abe394f397d2a957af73` no início de A34, revalidada idêntica ao commit do parecer `d68c2530acc0d7a5a08ef6f04ae77693849f4b84` antes deste CP. **Tipo:** checkpoint de continuidade; operações de banco NÃO aprovadas.

## 1. Estado herdado e identidades fixas
- Repositório: `rogerio-raposo/observatorio-evidencias-saude`, `main`; ponteiro único `archive/handoffs/oes/README.md`; template `archive/continuity/OES_Template_Abertura_Continuidade.md`.
- Neon sintético: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf` (não default), database `oes_sandbox`, executor administrativo `oes_sandbox_owner`, PostgreSQL 18. Endpoint DIRECT confirmado por metadados na P4-A32 `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`; sempre reconfirmar antes de execução conectada.
- `oes_django_migrator`: NOLOGIN, dono de nove tabelas e oito sequências Django em `oes_app`. Associação originária para `oes_sandbox_owner`: OID `155649`, grantor `cloud_admin`, ADMIN=true, INHERIT=false, SET=false; **NÃO MODIFICAR**.
- `oes_runtime`: LOGIN, INHERIT=false, sem memberships, ainda sem GRANTs Django. Tabelas Q0 protegidas. Sem usuários reais, conexão Django, escrita HTTP ou E9.
- Base factual P4-A27: SELECT catalogal v3 SHA-256 `136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a` executado em Neon com 946 checks + 1 SUMMARY, 64 divergências esperadas pré-GRANT, `SUMMARY/HOLD`, `public_grants_in_scoped_objects=0` no escopo. Isto não aprova acesso ou GRANT.
- P4-A19 **SUPERADO**. P4-A21 **HOLD incondicional — NÃO EXECUTAR**. P4-A29 rollback-only transacional e seu postflight **NÃO EXECUTADOS**.

## 2. Avanços P4-A31–A34
### P4-A31 — canal preferencial
- Revisados workflows existentes que usam PostgreSQL 18/`psql` e segredo temporário no GitHub Actions. `psql` indisponível no ambiente da conversa e instalação no computador do responsável não verificada.
- Decisão: preparar **workflow manual GitHub Actions + `psql` DIRECT**, sem conexão inicialmente, em vez de presumir cliente local. Fonte original integral preservada em `archive/handoffs/oes/artifacts/CP326/OES_PF-I04_P4-A31_DECISAO_CANAL_GITHUB_ACTIONS.md` (Git blob `e4b4ee7724362c7af7759480d450d9cb778cb7e8`).
- `mcp__Neon__run_sql` uma instrução por chamada e `run_sql_transaction` transação gerenciada: não aceitos como substituto sem nova prova de rollback explícito.

### P4-A32 — workflow HARD HOLD no GitHub
- Novo arquivo `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml`, blob Git `955de382252e10a287880f387111b2f35d755daf`. Apenas `workflow_dispatch`, `permissions: contents: read`, branch/main; offline hashes; job conectado **`if: ${{ false }}`**.
- Scripts de A29 preservados em CP325: `OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql` SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`; `OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql` SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`. Hashes reconfirmados localmente ao fechar A34.
- Contrato preservado: `archive/handoffs/oes/artifacts/P4-A32/OES_PF-I04_P4-A32_WORKFLOW_HARD_HOLD_CONTRATO.md`, Git blob `db459c4a1e062278b1d4c3404297110ab9150f54`. Nenhum segredo cadastrado, workflow não disparado em A32.

### P4-A33 — execução REAL no runner somente offline
- Run único `40622890545`, link https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40622890545, `workflow_dispatch`, `main`, head `01553be79f77b198673d45caddfa77f739b042a3`, run_attempt=1, `completed/success`.
- Job offline `122600872545` **SUCCESS**, todos 6 passos SUCCESS. Logs comprovam `OFFLINE_PASS: A29 SQL identities and ROLLBACK verified; NO SQL CONNECTION` e `HARD_HOLD_CONFIRMED: connected-role-trial is SKIPPED unconditionally`.
- Job conectado `122600915025` **SKIPPED**; zero SQL conectado neste run; não houve GRANT/REVOKE/SET ROLE/ROLLBACK real.
- Evidência: `archive/handoffs/oes/artifacts/P4-A33/OES_PF-I04_P4-A33_RESULTADO_REMOTO_40622890545.md` (blob `48ae6cfca50d6e9dc2bfb0454eccf8854adc3f99`); nota pré-run em `archive/handoffs/oes/artifacts/P4-A33/OES_PF-I04_P4-A33_AUDITORIA_OFFLINE_E_LIMITE_DISPATCH.md`.

### P4-A34 — revisão independente de ativação (nova decisão material)
- Parecer publicado `archive/handoffs/oes/artifacts/P4-A34/OES_PF-I04_P4-A34_PARECER_GATES_E_RISCOS_CONEXAO.md` (blob Git `a7f238aacc899ed7c290f5d0f09d8634f9e713bd`), identifica **A34-R01 a R06**; `ACTIVATION_HOLD`.
- **R01:** remover `if: false` isoladamente quebra a própria verificação de hard hold no job offline. **Preservar A32 imutável**; se necessário criar **outro workflow versionado**, inicialmente bloqueado, com novo teste.
- **R02:** segredos GitHub não são credenciais PostgreSQL descartáveis por definição. Excluir Secret não revoga senha de `oes_sandbox_owner`; exigir plano nominal efetivo de invalidar/rotacionar o segredo na ORIGEM sem comprometer ownership/login. Sem isso NO-GO.
- **R03:** `concurrency` não impede múltiplos dispatch ou reruns. `github.run_attempt=1` pode bloquear rerun de um run, mas não repetição por novo run_id; uma-só-execução depende também do ciclo de vida da credencial e da política de aprovação.
- **R04:** pré-autorizar, sob gate **SEPARADO**, postflight catalogal em NOVA sessão que funcione até após erro/resultado incerto. `SUMMARY/PASS` sozinho não prova trial; exigir também quatro marcadores, PID e ROLLBACK.
- **R05:** antes de qualquer liberação, revisar diff exato do novo arquivo, SHA de fontes e commit, endpoint DIRECT/branch, `psql` sem `-1`, logs sem credenciais, ausência de auto-rerun, escopo de membership temporária apenas.
- **R06:** GitHub environments com regras de aprovação podem auxiliar no repositório público, mas não assumir múltiplos revisores disponíveis nem impor mecanismo inviável a único responsável; não substituir aprovação de projeto.
- **Decisão final A34:** `WORKFLOW_CONNECTED_SECURITY_REVIEW_PASS_WITH_BLOCKERS / ACTIVATION_HOLD`. Nenhum workflow conectado alterado/executado nesta atividade.

## 3. Fronteira de segurança e protocolos
- Modo Continuity: uma atividade por `Prossiga`, checkpoints após 3–5 atividades, antecipados por risco; Freshness Gate no início e antes de commits, relatórios de progresso visíveis; STOP ao final.
- **NÃO autorizar** a partir de `Prossiga`: alteração de `if:false`, SQL transacional/mutante, GRANT/REVOKE, alteração de membership, SET ROLE, senha/credencial, execução workflow conectado, SQL Q0, leitura de dados Django, deploy, E9, custo pago. Operações conectadas SQL mesmo READ ONLY exigem gate próprio. Nenhum segredo ou URL com senha no Git.
- Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; PF-I04/P4 NOT_AUTHORIZED; Fase 4 CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY; Fase 5 NOT_STARTED.

## 4. Ponto exato de retomada
**PF-I04/P4-A35:** preparar **somente offline** candidato separado de workflow para ensaio ROLLBACK-ONLY, preservando A32 intacto e conectado SKIPPED. Incorporar guardas de tentativa, revisão/commit fixos e mecanismo de aprovação por etapa, sem armazenar nem usar credencial administrativa e sem remover `if:false` antes de gate nominal. **Reexaminar prioritariamente viabilidade de credencial de owner descartável realmente invalidável**; se inviável, reconhecer NO-GO e procurar alternativa proporcional, sem criar papéis/alterar role automaticamente. O novo workflow não constitui autorização para ensaio. Continuar a partir de CP326 depois de confirmar main e ler o parecer A34.
