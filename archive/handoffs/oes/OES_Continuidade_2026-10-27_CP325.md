# OES — CP325 | PF-I04/P4-A28–A30 — ensaio rollback-only preparado; canal psql direto preferido, sem autorização operacional

**Data:** 2026-10-27. **Anterior:** CP324. **Freshness Gate:** `main` idêntica ao HEAD `bdc9dfb5d587919fb26438093f2759e1dd7a8211` no início da atividade; revalidada imediatamente antes do commit do checkpoint. **Natureza:** consolidação DOCUMENTAL; **nenhuma operação Neon** em P4-A28–A30 ou nesta publicação.

## 1. Contexto estável
- Neon sintético: `weathered-boat-65779510` / branch `br-gentle-hall-b6jaxehf` / banco `oes_sandbox` / executor administrativo `oes_sandbox_owner`. Não tocar a branch default/produção.
- `oes_runtime` criado em P4-A13 com senha privada, LOGIN=true, NOINHERIT, sem privilégios administrativos nem associações. `oes_django_migrator` permanece NOLOGIN, proprietário de 9 tabelas e 8 sequências Django. Associação original migrador→owner: OID **155649**, `grantor=cloud_admin`, ADMIN=true, INHERIT=false, SET=false; não mudar.
- P4-A27: um SELECT catalogal nominalmente aprovado da v3 SHA-256 `136c41c6da4f8b62fb4ebd63145cb88b04d0d4978beb41fbbfe5bce75f20518a` retornou 947 linhas (1 resumo e 946 verificações), `SUMMARY/HOLD` esperado pré-GRANT, 64 divergências por direitos Django ainda não concedidos; `public_grants_in_scoped_objects=0`. Não houve mutação.
- P4-A19 SUPERADO, não executar. P4-A21 contém HOLD incondicional, não executar ou remover sem nova autorização. Bloco A de GRANTs Django NÃO executado; Bloco B Q0 separado e bloqueado.

## 2. Atividades
### P4-A28 — decisão técnica, sem execução
Definido ensaio mínimo **ROLLBACK-ONLY** para testar exclusivamente associação temporária de papel e `SET LOCAL ROLE` sem conceder privilégios em objetos Django/Q0. Prova exigida: preflight identidade/associação OID 155649; concessão temporária owner→owner com SET=true e grantor próprio; coexistência de duas associações; `SET LOCAL ROLE oes_django_migrator`; identidade restaurada; REVOKE grantor-aware com RESTRICT de **somente associação temporária**; `ROLLBACK` final obrigatório; postflight independente em nova sessão. Nenhuma prova executada.

### P4-A29 — SQL e contrato de ensaio, APENAS candidatos
- SQL transacional com **171 linhas**, inclui preflight `DO`, GRANT de **membership temporária**, `SET LOCAL ROLE`, REVOKE da própria concessão, marcadores `A29_PRE`, `A29_TEMP_GRANT`, `A29_MIGRATOR`, `A29_CLEAN` e `ROLLBACK` final, **nunca COMMIT**. SHA-256 exato **`550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`**.
- SQL postflight independente `WITH ... SELECT`, 191 linhas, somente leitura catalogal, outra sessão. SHA-256 exato **`8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`**.
- Contrato define pré-condições, asserções e falha fechada. Arquivos NÃO foram executados no PostgreSQL local/Neon e não constituem autorização operacional.
- Aceite futuro exige quatro marcadores com mesmo `pg_backend_pid`, membership count **1→2→2→1**, identidades `owner→owner→migrator→owner`, ROLLBACK comprovado pelo executor e `SUMMARY/PASS` integral na consulta independente posterior; baseline pós-rollback idêntica à anterior.
- O postflight pode retornar PASS mesmo sem ensaio, portanto **somente prova conjunta** (marcadores + confirmação de rollback + postflight) seria aceitável.

### P4-A30 — escolha documental do canal
- `mcp__Neon__run_sql` aceita uma instrução por chamada: NO-GO para execução multifásica em sessão única.
- `mcp__Neon__run_sql_transaction` gerencia transação, mas não há garantia contratual de respeitar explicitamente o `ROLLBACK` de A29 em vez de conclusão com COMMIT: **NO-GO para script A29 inalterado**. Neon SQL Editor: NO-GO até comprovar controle de sessão/erros/rollback.
- Canal preferido: **`psql` local + conexão PostgreSQL DIRETA (sem `-pooler`)**, um único processo/sessão para script A29 `BEGIN`→`ROLLBACK`, `-X`, `ON_ERROR_STOP=on`, `ON_ERROR_ROLLBACK=off`, **sem `psql -1`**, sem auto-COMMIT externo. Em falha, encerrar conexão, não repetir, e inspecionar postflight sob autorização própria.
- **Canal somente DOCUMENTALMENTE adequado.** Nenhum cliente `psql`, endpoint, autenticação, conexão direta ou logs na máquina do responsável foi verificado. Não obter, registrar, enviar ou revelar senhas/URLs com credenciais ao chat. Não instalar serviços pagos. O assistente não controla a máquina local.
- Decisão operacional: **manter psql direto como referência condicional**; NÃO autorizar execução, não afirmar sessão comprovada. Se o responsável preferir automação pelo Neon, é necessário **novo desenho compatível, novo SHA, ensaio e gate**, não executar A29 inalterado em `run_sql_transaction`.

## 3. Arquivos preservados
Diretório `archive/handoffs/oes/artifacts/CP325/`; quatro arquivos íntegros conferidos por identidade **Git blob SHA-1** após publicação:
1. `OES_PF-I04_P4-A29_ROLLBACK_ONLY_ROLE_TRIAL_CANDIDATO.sql` — SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`, Git blob `68c60abe325acb54621892629fba427234a54d5a`; **CONTAINS MUTATING MEMBERSHIP, NÃO EXECUTAR SEM GATE**.
2. `OES_PF-I04_P4-A29_POSTFLIGHT_INDEPENDENTE_READ_ONLY.sql` — SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`, Git blob `d68d403ace9cb2cbbe206d868b758b9687d5a125`; não executar conectado sem gate.
3. `OES_PF-I04_P4-A29_CONTRATO_ENSAIO_E_GATE.md` — Git blob `70055c5630d597fc27a410e2bf691722ee16fb54`.
4. `OES_PF-I04_P4-A30_CANAL_E_GATES.md` — Git blob `2d09bc38cd12effc747eeb567b3ff8023afe20e4`; contém modelo de comando `psql` e **textos de autorização CANDIDATOS A31/A31-POST ainda não concedidos**.

Pacote ZIP A29 e manifesto de revisão estática continuam artefatos locais de conveniência. **As quatro fontes centrais foram persistidas byte a byte**; os scripts de validação ad hoc não são requisitos canônicos.

## 4. Status/gates preservados
- Marco B `OPEN`; G2-P2B operacional `NO-GO`; E9 `NO-GO`; readiness `NOT_READY`; PF-I04/P4 `NOT_AUTHORIZED`; Fase 4 `CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY`; Fase 5 `NOT_STARTED`.
- Nenhum pesquisador real vinculado. Sem dados reais, HTTP write, deploy, novos papéis/senhas, GRANTs em objetos Django/Q0, serviços pagos ou atualização de credenciais.
- `Prossiga` aprova apenas a próxima atividade delimitada, nunca automaticamente o ensaio transacional com GRANT/REVOKE e `SET ROLE`.
- Qualquer mutação em Neon, inclusive membership que se pretende reverter por ROLLBACK, exige gate nominal por alvo/SQL SHA/executor/canal e autorização distinta para postflight independente.

## 5. Ponto exato de retomada
**PF-I04/P4-A31 — escolher e verificar operacionalmente a modalidade de execução, sem SQL mutante por padrão.** Se houver `psql` direto seguro no ambiente do responsável, verificar disponibilidade, conexão **sem divulgar credenciais**, integridade do arquivo e captura dos marcadores, e então considerar aprovação nominal proposta no documento A30. Se a execução precisar ser completamente via plugin, redesenhar **separadamente** um teste compatível com uma instrução/transação e gatilho de rollback comprovável; o A29 não é aprovado nesse canal. Não assumir disponibilidade de `psql` local nem executar SQL sem autorização exata. Evitar loop documental: a decisão deve preparar um teste demonstrável e proporcional. CP325 vigente após atualização do ponteiro e STATE; Freshness Gate obrigatório antes do próximo trabalho/commit.
