# OES — PF-I04/P4-A34 | Auditoria independente do workflow rollback-only antes de conexão

**Data local:** 2026-10-27 (America/Recife). **Classificação:** `WORKFLOW_CONNECTED_SECURITY_REVIEW_PASS_WITH_BLOCKERS / ACTIVATION_HOLD`.
**Checkpoint de referência:** CP325. **Freshness Gate:** `main` idêntica a `3870cf499f82008200c6abe394f397d2a957af73` antes da publicação.
**Versão auditada do workflow:** `.github/workflows/oes-pf-i04-p4-a32-rollback-only-hold.yml`, Git blob `955de382252e10a287880f387111b2f35d755daf`. **Não alterar essa versão** na presente atividade.

## 1. Evidência já suficiente
- P4-A33: run [40622890545](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/40622890545), `main`, SHA `01553be79f77b198673d45caddfa77f739b042a3`, `workflow_dispatch`, 1 tentativa, `conclusion=success`.
- Job `offline-contract` SUCCESS; log `OFFLINE_PASS: A29 SQL identities and ROLLBACK verified; NO SQL CONNECTION`.
- Job `connected-role-trial` SKIPPED; log `HARD_HOLD_CONFIRMED: connected-role-trial is SKIPPED unconditionally`. Nenhuma conexão ou operação PostgreSQL ocorreu na validação.
- Banco sintético para eventual ensaio, NÃO ACESSADO NESTA ATIVIDADE: projeto `weathered-boat-65779510`, branch `br-gentle-hall-b6jaxehf`, banco `oes_sandbox`, executor `oes_sandbox_owner`. Endpoint direto da branch verificado por metadados na P4-A32: `ep-wispy-dream-b6021bw0.c-2.sa-east-1.aws.neon.tech`; deve ser reconfirmado antes de gate conectado.
- SQL A29 transacional SHA-256 `550b03d428033e1af46e9c0028a73191351a044e96eb47835f7ba137fc8c3e17`; postflight independente SHA-256 `8a34176b4c3d1a44df9f495487f3e90e61686599767add7bdba013cad22ec509`. Nenhum executado no Neon.

## 2. Achados e bloqueios de ativação

### A34-R01 — mudança isolada de if:false NÃO habilita o ensaio [BLOQUEANTE]
O job `offline-contract` exige literalmente `connected-role-trial: ... if: ${{ false }}`. Se alguém simplesmente remover esse bloqueio, o job offline falhará e o job conectado não será liberado. **Não contornar a validação nem retirar o if diretamente.** Preservar o workflow A32 já testado como testemunho offline; eventual implementação conectada deve ser **novo workflow versionado**, com testes próprios e SHA do diff aprovado.

### A34-R02 — credencial do proprietário privilegiado não é descartável por simples remoção do GitHub Secret [BLOQUEANTE]
O job candidato usa `PGUSER=oes_sandbox_owner` e segredo `OES_P4_A32_OWNER_PASSWORD_ONETIME`. Excluir o segredo no GitHub NÃO invalida a senha PostgreSQL ainda válida. Exigir plano verificável, autorizado e reversível de credencial de duração limitada e revogação/rotação **na origem**; nenhuma nova senha, ALTER ROLE ou sessão de autenticação foi aprovada. Não reutilizar credenciais de migração, runtime ou usuários reais. Sem plano de ciclo de vida de senha administrativa, **NO-GO**.

### A34-R03 — GitHub Actions permite reexecuções e múltiplos disparos [BLOQUEANTE]
`concurrency.cancel-in-progress=false` impede simultaneidade, mas **não** impede um segundo `workflow_dispatch` nem `Re-run jobs`. Futuro workflow conectado deve rejeitar `github.run_attempt != 1` e qualquer revisão não exatamente aprovada; isso **não garante** impossibilidade de novo run com outro `run_id`. A defesa decisiva é retirar/revogar a credencial imediatamente depois de um ensaio e não reativar credenciais existentes; exigem-se também aprovação manual isolada e conferência independente. Não alegar garantia técnica de exactly-once apenas pela propriedade `run_attempt`.

### A34-R04 — postflight independente pré-autorizado, mas não embutido no job mutante [BLOQUEANTE]
O workflow A32 atual verifica só `ROLLBACK` e quatro linhas marcadoras; não executa o postflight (deliberadamente). Para um teste conectado, exigir gate nominal **separado, aprovado antes do ensaio**, que autorize UM SELECT catalogal em NOVA sessão inclusive após falha/incerteza. No final, exigir resumo `SUMMARY/PASS`, 0 divergências e total consistente de linhas; nenhum PASS do postflight isoladamente prova execução do ensaio. Falha ou retorno incompleto = HOLD, sem retry. Credencial do postflight deve observar a política de segurança, não perpetuar a senha administrativa.

### A34-R05 — revisão exata do código, destino e controle de logs [BLOQUEANTE para go-live]
Novo workflow precisa manter: execução manual apenas, repositório/branch `main` e commit aprovado **pinados**, escopo `contents: read`, revisão das ações externas, bloqueio pré-conexão por SHA-256 dos dois arquivos, uma única sessão `psql -X -v ON_ERROR_STOP=on -v ON_ERROR_ROLLBACK=off -f`, sem `-1`, sem COMMIT, nenhuma repetição, log apenas efêmero; validação de quatro marcadores com mesmo PID, contagens 1→2→2→1, identidades e `ROLLBACK` final. Confirmar por metadados que endpoint DIRECT não pertence à branch default e que não há `-pooler`. Conferir `session_user` e banco dentro da própria transação; nenhum dado Django/Q0 lido. Em falha, encerrar e preservar HOLD, não confirmar sucesso parcial.

### A34-R06 — independência e disponibilidade de ambiente de aprovação [CONDIÇÃO COMPLEMENTAR]
GitHub public repo pode usar *environments* com segredos isolados e, quando aplicável, aprovação humana; avaliar se útil sem impor um segundo usuário inexistente. Para usuário único, não configurar proteção que torne a liberação impossível. Aprovação em chat continua sendo o gate nominal de projeto e NÃO é substituída pelo botão de GitHub. A plataforma aceita reexecução; `github.run_attempt` é necessário mas insuficiente. Verificar disponibilidade do plano gratuito para o runner padrão e não ativar serviços pagos.

## 3. Arquitetura de redução de risco recomendada
1. **Manter A32 imutável e `if: false`**, com evidência P4-A33 preservada. Não reutilizar workflow A32 para mutações.
2. **P4-A35 (offline):** preparar um workflow conectado v1 em **arquivo novo**, inicialmente `if: false`, com guarda de tentativa, SHA e commit exatos, regras para segredo de ambiente, uma só invocação `psql`, verificador de log e nenhum postflight automático. Criar revisão independente de fonte e de teste de negação; não rodar no Neon.
3. Antes de qualquer gatilho conectado, demonstrar a governança da credencial de `oes_sandbox_owner` (sem texto de senha no chat), obter aprovação nominal por commit/arquivo SHA/projeto/branch/DB/role/efeitos temporários/Rollback, e aprovação nominal separada do postflight, incluindo cenários de erro. Depois de execução **única**, remover o segredo e invalidar/rotacionar a credencial na origem com procedimento autorizado, mais postflight.
4. Se não for possível invalidar uma senha administrativa com segurança no ambiente Neon sem afetar outros fluxos, **manter HOLD** e reconsiderar um método de execução que não exponha o login proprietário em runner, sem mudar o modelo de ownership sem nova decisão.

## 4. Resultado do gate e limites
- **`ACTIVATION_HOLD` para P4-A29 conectado.** Os bloqueios R01 a R05 não são supridos pelo sucesso offline A33.
- Nenhum SQL, senha, GRANT/REVOKE/SET ROLE, conexão Django, alteração de Neon ou ativação do job conectado autorizados.
- Não há autorização de E9, de HTTP, de deploy, de dados reais, de papéis novos, serviços pagos ou início de Fase 5.
- Marco B OPEN; G2-P2B operacional NO-GO; E9 NO-GO; readiness NOT_READY; P4 NOT_AUTHORIZED; Fase 5 NOT_STARTED.

## 5. Fontes de referência
- GitHub `github.run_attempt`: https://docs.github.com/en/actions/reference/workflows-and-actions/contexts
- GitHub reexecução de jobs: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs
- GitHub environment secrets/revisores: https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments
- GitHub quando lê segredos: https://docs.github.com/en/actions/reference/security/secrets
- PostgreSQL 18 `pg_auth_members`: https://www.postgresql.org/docs/18/catalog-pg-auth-members.html

**P4-A34 encerrada como revisão de segurança e decisão `ACTIVATION_HOLD`.** Próxima ação preferida é CP326 (P4-A31–A34) e/ou P4-A35 (novo candidato offline), sem conexão.
