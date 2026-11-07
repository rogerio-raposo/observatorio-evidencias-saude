# CP346 — OES | Encerramento técnico restrito do ensaio Django–Q0

**Data:** 2026-11-07 (America/Recife).  
**Estado:** publicado como checkpoint de continuidade.  
**Antecessor:** CP345 (preservado como histórico).  
**Base operacional das evidências:** `9f0df89f42e5cbc12ca816722afb679b14b3bba0` (`main` no momento dos ensaios).  
**Escopo:** consolidação da atestação conectada READ ONLY e do ensaio isolado rollback-only. Não é autorização de escrita persistente, execução adicional ou alteração de gates.

## 1. Evidências conectadas concluídas

### 1.1 Identidade sintética, Django e PostgreSQL

- Execução: [GitHub Actions #42399226510](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42399226510).
- Workflow: `.github/workflows/oes-q0-auth-readonly-manual.yml`, `workflow_dispatch`, `main`, SHA `9f0df89f42e5cbc12ca816722afb679b14b3bba0`, tentativa `run_attempt=1`.
- Jobs `preflight` e `auth-readonly`: `SUCCESS`.
- Marcador efetivo: `Q0_AUTH_DIAG_PASS_READ_ONLY_SYNTHETIC_IDENTITY`.
- Alcance técnico segundo contrato publicado: autenticação de `oes_auth_trial_login` no banco experimental `oes_sandbox`, schema `django_auth`, transação READ ONLY, usuário sintético reservado e vínculo persistido `PreparerIdentity`, UUIDv4, flags, permissão única `prepare_question` e ausência de grupos. Não comprova escrita, rollback ou autorização HTTP.

### 1.2 Ensaio sintético Django–Q0 com rollback obrigatório

- Execução: [GitHub Actions #42399992047](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42399992047).
- Workflow: `.github/workflows/oes-django-q0-single-rollback-hold.yml`, `workflow_dispatch`, `main`, SHA `9f0df89f42e5cbc12ca816722afb679b14b3bba0`, tentativa `run_attempt=1`.
- Jobs `preflight-review-only` e `connected-trial`: `SUCCESS`.
- Marcadores efetivos, em ordem:
  1. `Q0_PHASE_OPERATIONAL_BOUNDARY_VALIDATED`
  2. `Q0_PHASE_DJANGO_INITIALIZED`
  3. `Q0_PHASE_SYNTHETIC_IDENTITY_ATTESTED`
  4. `Q0_PHASE_WRITER_BOUNDARY_CLOSED`
  5. `Q0_PHASE_INDEPENDENT_RECONCILIATION_COMPLETED`
  6. `PASS_ROLLBACK_ZERO_RESIDUES`
- Interpretação: a receita isolada publicada contém cinco operações ORM sintéticas dentro de uma transação PostgreSQL com rollback obrigatório e leitura posterior por alias leitor independente. O PASS final significa que a execução conectada concluiu o caminho previsto e classificou como ausentes os resíduos sintéticos inspecionados. Os marcadores intermediários não provam isoladamente rollback nem ausência de resíduos. Não houve demonstração nem autorização de commit persistente.

### 1.3 Histórico, distinções e proveniência

- Tentativas anteriores de rollback [#42381942493](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42381942493) e [#42385496980](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42385496980) permaneceram inconclusivas; não reclassificar retroativamente.
- Tentativa inicial de auth-only [#42398741408](https://github.com/rogerio-raposo/observatorio-evidencias-saude/actions/runs/42398741408): `HOLD_Q0_AUTH_DIAG_PREFLIGHT` antes do acesso ao banco, por SHA abreviado nas variáveis e no input. O despacho posterior com SHA completo foi PASS.
- [PR #21](https://github.com/rogerio-raposo/observatorio-evidencias-saude/pull/21) integrado por squash em `b472f6d0fd087779a4571475492851d4c511f769`: diagnóstico auth-only e correções offline SQLite. O workflow manual auth-only foi posteriormente publicado na `main`.
- A expiração anterior de `oes_auth_trial_login` foi regularizada até **2026-11-10 23:59:59 UTC** sem troca de senha. A autenticação conectada subsequente foi verificada. Não inferir que expiração foi a única causa das tentativas anteriores.

## 2. Limites e gates inalterados

- **Marco B:** OPEN.
- **Q0 executor geral:** HARD HOLD. A receita específica rollback-only não habilita fluxo operacional de escrita nem commit.
- **E9:** NO-GO.
- **Fase 5:** NOT_STARTED.
- **Fase 4:** CLOSED_METHODOLOGICAL_DOCUMENTARY_ONLY, conforme marco anterior.
- Sem autorização para dados reais, usuários pesquisadores reais, ativação de HTTP write, publicação científica, deploy, migrações, novos grants, novos despachos ou serviços pagos.
- Os resultados atestam o escopo experimental implementado e executado, não prontidão de produção nem validação integral de PostgreSQL/Django.

## 3. Credenciais e controles pós-execução

- O responsável **confirmou a exclusão** das variáveis temporárias do diagnóstico auth-only (`OES_Q0_AUTH_DIAG_APPROVED_SHA`, `OES_Q0_AUTH_DIAG_OPERATIONAL_AUTHORIZATION`) e do ensaio rollback-only (`OES_Q0_APPROVED_SHA`, `OES_Q0_OPERATIONAL_AUTHORIZATION`).
- A ausência dessas variáveis não foi comprovada independentemente por consulta administrativa à API.
- Os três secrets existentes não foram inspecionados nem modificados nesta consolidação. Não renovar, revogar ou alterar credenciais sem procedimento próprio.
- Autorizações nominais das execuções conectadas **consumidas**. Não repetir nem utilizar `Re-run jobs`.

## 4. Decisão de encerramento técnico restrito

Classificar como **PASS técnico conectado restrito** o par de evidências auth-only READ ONLY + rollback-only com reconciliação independente e zero resíduos no conjunto sintético inspecionado. **Não** transformar o marco em GO geral do Q0, em demonstração de commit persistente ou em abertura da Fase 5.

## 5. Retomada e macroatividade prioritária

1. Considerar encerrado o ensaio sintético rollback-only, sem reprodução por padrão.
2. Reavaliar condições remanescentes para o demonstrador Django–PostgreSQL e Q0 operacional, distinguindo **prova rollback-only concluída** de **persistência/commit ainda não autorizados**, autenticação de pesquisadores reais (indisponíveis) e controles necessários ao demonstrador.
3. Escolher próximo incremento funcional proporcional ao risco, sem retestar o que já foi comprovado e sem abrir E9 ou Fase 5 automaticamente.
4. Preservar CP345 e demais documentos históricos como testemunhos de seu estado na época; os ponteiros atuais devem remeter a CP346.

**STOP:** esta consolidação documental não autoriza nova execução conectada.
